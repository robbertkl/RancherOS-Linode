# RancherOS Linode installer

This repo contains an install script that can be used to install [RancherOS](http://rancher.com/rancher-os/) on [Linode](https://www.linode.com). While other ways are possible (like installing first to a local VM, then `dd`ing the results to the Linode disk), this method is very easy and quick. It uses the Finnix rescue mode to perform the installation using the install script from the [RancherOS repo](https://github.com/rancher/os). 

This guide assumes that your Linode is running the *KVM* hypervisor. Some Linode locations still deploy new Linodes using *XEN*. Upgrade your Linode to *KVM* by clicking the link at the bottom of the sidebar.

## Installation steps

* Create a new Linode
* On tab *Dashboard*, click *Create a new Disk*
  * Set *Label* to "RancherOS Disk"
  * Set *Type* to "unformatted / raw"
  * Leave *Size* at maximum (we don't need swap)
  * Click *Save Changes*
* On tab *Dashboard*, click *Create a new Configuration Profile*
  * Set *Label* to "RancherOS"
  * Set *Kernel* to "Direct Disk"
  * Set */dev/sda* to "RancherOS Disk"
  * Set ALL items under *Filesystem/Boot Helpers* to "No"
  * Click *Save Changes*
* On tab Rescue, check that */dev/sda* is set to "RancherOS Disk" and click *Reboot into Rescue Mode*
* On tab Remote Acces, click the *Lish via SSH* link
* Log in and enter the name of your Linode to get into its rescue console
* If you don't have a *cloud-config.yml* file already, create one (see the [Cloud Config guide](http://docs.rancher.com/os/cloud-config/))
* In the Finnix shell, run the following:

```
sysctl net.ipv6.conf.eth0.disable_ipv6=1
apt-get -qq update
apt-get -qq install ca-certificates
wget -q https://raw.githubusercontent.com/robbertkl/RancherOS-Linode/master/install.sh
chmod +x install.sh
# create or fetch your own cloud-config.yml file
./install.sh -c cloud-config.yml
```

* Wait until the install script is finished
* On tab *Dashboard*, click *Reboot*
* Your Linode will now reboot into RancherOS and you'll be able to SSH with user *rancher* using the SSH keys you supplied in the cloud-config file.

To run the Rancher management platform, see the [Rancher documentation](http://docs.rancher.com/os/quick-start-guide/#using-rancher-management-platform-with-rancheros).

## Command line arguments

Optionally, you can specify the following commandline arguments to the `install.sh` script:

* `-c`: pass a cloud-config YAML file to the installer
  * Example: `-c cloud-config.yml`
  * Default: generates an empty cloud-config to use for the installation
* `-d`: disk device to install to - warning: will be wiped!
  * Example: `-d /dev/sda`
  * Default: attempts to auto-detect a disk device (either /dev/sda or /dev/vda)
* `-v`: RancherOS release version to install
  * Example: `-v 0.4.2`
  * Default: the current RancherOS release (fetched from the [release list](https://releases.rancher.com/os/releases.yml))

## Authors

* Robbert Klarenbeek, <robbertkl@renbeek.nl>

## License

This repo is published under the [MIT License](http://www.opensource.org/licenses/mit-license.php).
