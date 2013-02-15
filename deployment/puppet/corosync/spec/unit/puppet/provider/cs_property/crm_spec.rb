require 'spec_helper'

describe Puppet::Type.type(:cs_property).provider(:crm) do

  let(:resource) { Puppet::Type.type(:cs_property).new(:name => 'myproperty', :provider=> :crm ) }
  let(:provider) { resource.provider }

  describe "#create" do
    it "should create property with corresponding value" do
      resource[:value]= "myvalue"
      provider.expects(:crm).with('configure', 'property', '$id="cib-bootstrap-options"', "myproperty=myvalue")
      provider.create
      provider.flush
    end
  end

  describe "#destroy" do
    it "should destroy property with corresponding name" do
      provider.expects(:cibadmin).with('--scope', 'crm_config', '--delete', '--xpath', "//nvpair[@name='myproperty']")
      provider.destroy
      provider.flush
    end
  end

  describe "#instances" do
    it "should find instances" do
      provider.class.stubs(:block_until_ready).returns(true)
      provider.class.stubs(:ready).returns(true)
      out=File.open(File.dirname(__FILE__) + '/../../../../fixtures/cib/cib.xml')
      Puppet::Util::SUIDManager.stubs(:run_and_capture).with(['/usr/sbin/crm','configure','show','xml']).returns(out,0)
      instances = provider.class.instances
      instances[0].instance_eval{@property_hash}.should eql({:name=>"dc-version",:value=>"1.1.6-9971ebba4494012a93c03b40a2c58ec0eb60f50c", :ensure=>:present, :provider=>:crm})
    end
  end
end

