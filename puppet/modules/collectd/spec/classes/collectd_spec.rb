
require 'spec_helper'

describe 'collectd' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  hiera = Hiera.new(:config => 'spec/fixtures/hiera/hiera.yaml')
  it { should compile }
  it { should compile.with_all_deps }
end

