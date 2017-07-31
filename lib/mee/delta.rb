require 'rest-client'
require "mee/delta/version"

module MEE
  module Delta
		@default_url = "http://localhost:9000"

		#TODO: Figure out how to make this a module attribute accesor
		def self.default_url ; @default_url ; end
		def self.default_url=( url ) ; @default_url = url ; end

		def self.is_available
			begin
				response = HTTPClient::get_json( @default_url + "/v1/status" )
				response["ok"]
			rescue
				false
			end
		end

		def self.ingress( listener_name, target_name )
			result = HTTPClient::post_json( @default_url + "/v1/ingress", { :name => listener_name, :target => target_name, :wire_proxy => "node-http-proxy" }, 201 )
			return IngressResource.new( result[ '_self' ] )
		end

		def self.register_target_port( target_name, port )
			puts "Registering target: #{port} for #{target_name} "
			response_body = HTTPClient::post_json( @default_url + "/v1/target/" + target_name, { :port => port }, 201 )
			puts "Response body: #{ response_body }"
		end

		class IngressResource
			def initialize( url )
				@url = url
			end

			def address
				json = HTTPClient.get_json( @url )
				json['address']
			end

			def add_target( target )
				HTTPClient::post_json( @url, { :add_targets => [ target ] } )
			end
		end

		module HTTPClient
			def self.get_json( url )
				result = RestClient.get url, :accept => :json
				raise "Got status " + result.code.to_s + " for " + url unless result.code == 200
				JSON.parse( result.body )
			end

			def self.post_json( url, payload, expected_code = 200 )
				result = RestClient.post url, payload.to_json, :accept => :json, :content_type => :json

				raise "Got status " + result.code.to_s + " for " + url unless result.code == expected_code
				JSON.parse( result.body )
			end
		end
  end
end
