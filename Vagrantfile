# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

$cpus   = ENV.fetch("YUDL_VAGRANT_CPUS", "2")
$memory = ENV.fetch("YUDL_VAGRANT_MEMORY", "4000")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.
  config.vm.provider "virtualbox" do |v|
    v.name = "YUDL Islandora 7.x-1.x Development VM"
  end

  config.vm.hostname = $hostname

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/xenial64"

  unless  $forward.eql? "FALSE"  
    config.vm.network :forwarded_port, guest: 8080, host: 8080 # Tomcat
    config.vm.network :forwarded_port, guest: 3306, host: 3306 # MySQL
    config.vm.network :forwarded_port, guest: 8000, host: 8000 # Apache
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", $memory]
    vb.customize ["modifyvm", :id, "--cpus", $cpus]
  end

  shared_dir = "/vagrant"

  config.vm.provision :shell, path: "./scripts/bootstrap.sh", :args => shared_dir
  config.vm.provision :shell, path: "./scripts/fits.sh", :args => shared_dir
  #config.vm.provision :shell, path: "./scripts/djatoka.sh", :args => shared_dir
  config.vm.provision :shell, path: "./scripts/lamp-server.sh", :args => shared_dir
  #config.vm.provision :shell, path: "./scripts/sleuthkit.sh", :args => shared_dir
  #config.vm.provision :shell, path: "./scripts/ffmpeg.sh", :args => shared_dir
  #config.vm.provision :shell, path: "./scripts/warctools.sh", :args => shared_dir
  config.vm.provision :shell, path: "./scripts/drupal.sh", :args => shared_dir  
  config.vm.provision :shell, path: "./scripts/post.sh"
end
