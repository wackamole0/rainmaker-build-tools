VAGRANTFILE_API_VERSION = "2"

BOX       = "wackamole/rainmaker"
HOSTNAME  = "rainmaker"
DOMAIN    = "localdev"
MAC       = "080027bcda46"
IP        = "10.100.0.254"
NETMASK   = "255.255.0.0"
RAM       = "512"
VBOX_GUI  = true
VBOX_NAME = "Rainmaker Dev"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = BOX
  config.vm.network "private_network", ip: IP, netmask: NETMASK, auto_config: false

  config.vm.provider "virtualbox" do |vb|
    vb.name = VBOX_NAME
    vb.gui = VBOX_GUI
    vb.customize ["modifyvm", :id, "--memory", RAM, "--nictype2", "Am79C973", "--nicpromisc2", "allow-all"]
  end

end
