
require 'spec_helper'

describe 'carbon_c_relay' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  hiera = Hiera.new(:config => 'spec/fixtures/hiera/hiera.yaml')
  it { should compile }
  it { should compile.with_all_deps }
end

