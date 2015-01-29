VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "server" do |server|
    server.vm.box = "ubuntu/trusty64"
    server.vm.host_name = 'riemann'
    server.vm.network "forwarded_port", guest: 4567, host: 4567
    server.vm.network "forwarded_port", guest: 5555, host: 5555
    server.vm.network "forwarded_port", guest: 5556, host: 5556
    server.vm.network "private_network", ip: "172.16.3.101"
    server.vm.synced_folder "puppet/modules", "/tmp/vagrant-puppet/puppet/modules"
    server.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.options = ["--modulepath", "/tmp/vagrant-puppet/puppet/modules"]
      puppet.manifest_file = "server.pp"
    end
  end #server

  config.vm.define "client1" do |client|
    client.vm.box = "ubuntu/trusty64"
    client.vm.host_name = 'client1'
    client.vm.network "private_network", ip: "172.16.3.102"
    client.vm.synced_folder "puppet/modules", "/tmp/vagrant-puppet/puppet/modules"
    client.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.options = ["--modulepath", "/tmp/vagrant-puppet/puppet/modules"]
      puppet.manifest_file = "client.pp"
    end
  end #client

  config.vm.define "client2" do |client|
    client.vm.box = "ubuntu/trusty64"
    client.vm.host_name = 'client2'
    client.vm.network "private_network", ip: "172.16.3.103"
    client.vm.synced_folder "puppet/modules", "/tmp/vagrant-puppet/puppet/modules"
    client.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.options = ["--modulepath", "/tmp/vagrant-puppet/puppet/modules"]
      puppet.manifest_file = "client.pp"
    end
  end #client

end
