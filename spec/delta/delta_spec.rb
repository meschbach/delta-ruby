require 'spec_helper'

describe MEE::Delta do
  it 'has a version number' do
    expect(MEE::Delta::VERSION).not_to be nil
  end

#  it 'verifies the the service is available' do
#		expect( MEE::Delta.is_available ).to eq( true )
#  end
end
