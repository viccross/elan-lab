# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.provider :libvirt do |libvirt|
    libvirt.qemu_use_session = false
    libvirt.uri = "qemu:///system"
    libvirt.system_uri = "qemu:///system"
    libvirt.storage_pool_name = "SSDpool"
  end
  config.vm.box = "generic/alma8"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  N = 3
  VAGRANT_VM_PROVIDER = "libvirt"
  ANSIBLE_RAW_SSH_ARGS = []

  (1..N).each do |i|
    config.vm.define "elan_#{i}" do |node|
      node.vm.provider :libvirt do |domain|
        domain.cpus = 2
        domain.cputopology :sockets => "2", :cores => "1", :threads => "1"
        domain.machine_virtual_size = 20
        domain.memory = 4096
      end
      node.vm.hostname = "lxelan0#{i}.vic.lab"
      node.vm.network :private_network,
        :libvirt__network_name => "default",
        :libvirt__always_destroy => false,
        :ip => "192.168.124.1#{i}",
        :hostname => true
      node.vm.network :private_network,
        :libvirt__network_name => "ELAN#{i}",
        :libvirt__always_destroy => false,
        :ip => "172.24.26.1"
      if i == N
        node.vm.provision :ansible do |ansible|
          ansible.playbook = "ansible/build-an-elan.yml"
          ansible.inventory_path = "ansible/inventory"
          ansible.limit = "all"
        end
      end  
    end
  end

end
