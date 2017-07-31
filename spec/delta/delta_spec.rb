require 'spec_helper'

require 'sinatra/base'
require 'sinatra/json'

class SimpleTestApplication < Sinatra::Base
	before do
		unless @registered
			#MEE::Delta::register_target_port( "ruby-target", 5000 )
			@registered = true
		end
	end

	get '/get-test' do
		result = { :sinatra => true }
		json result
	end
end

def random_ephemeral_port()
	base_of_range = 16384
	port = Random.new.rand( 5000 ) + base_of_range
	port
end

describe MEE::Delta do
  it 'has a version number' do
    expect(MEE::Delta::VERSION).not_to be nil
  end

	describe "when the service isn't available" do
	  it 'reports the service as unavailable' do
			expect( MEE::Delta.is_available ).to eq( false )
	  end
	end

	describe "given the service is available" do
		# TODO: Make this before/after each
		before(:all) do
			port = random_ephemeral_port()
			puts "Starting"
			@pid = Kernel.spawn( "cd ../delta && node service.js --ttl 30 --port #{port}" )
			MEE::Delta.default_url = "http://localhost:#{port}"
			# Wait for up to 1 second for the service to come on-line
			sleep 0.5
		end

		# TOOD: Not being called on failure
		after(:all) do
			puts "Kill subproc"
			sleep 0.1
			begin
				Process.kill( "TERM", @pid )
				puts "Term sleep"
				sleep 1
				Process.wait( @pid )
			rescue
				puts "WARNING: May have leaked process #{@pid}"
			end
		end

	  it 'reports the service as available' do
			expect( MEE::Delta.is_available ).to eq( true )
	  end

		describe "when a service is registered to a target" do
			before do
				@ingress = MEE::Delta.ingress( "ruby-ingress", "ruby-target" )
				@ingress.add_target( "ruby-target" )
				@ingress_url = @ingress.address
				puts "Ingress URL: #{@ingress_url}"
				@service = fork {
					port = Random.new.rand( 5000 ) + 32000
					MEE::Delta.register_target_port( "ruby-target", port )
					puts "Simple test application registered on #{ port }"

					SimpleTestApplication.run! :port => port
				}
				puts "Forked service as PID #{@service}"
				# Wait until the process is booted
				sleep 10
				puts "Simple service should be running"
			end

			after do
				Process.kill( "INT", @service ) if @service
			end

			it "is able to access the service" do
				response = MEE::Delta::HTTPClient.get_json( @ingress_url + "/get-test" )
				expect( response["sinatra"] ).to be(true)
			end
		end
	end
end

