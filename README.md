# YUDL Vagrant [![Build Status](https://travis-ci.org/yorkulibraries/yudl_vagrant.svg?branch=master)](https://travis-ci.org/yorkulibraries/yudl_vagrant)

## Introduction

The is a development environment virtual machine for YUDL 7.x-1.x. It should work on any operating system that supports VirtualBox and Vagrant.

**NOTE**: You will need to be connected to the York University Libraries VPN.

## Requirements

1. [VirtualBox](https://www.virtualbox.org/)
  * Be sure to install a version of VirtualBox that [is compatible with Vagrant](https://www.vagrantup.com/docs/virtualbox/)
2. [Vagrant](http://www.vagrantup.com)
3. [git](https://git-scm.com/)

Note that virtualization must be enabled in the host machine's BIOS settings.

## Variables

### System Resources

By default the virtual machine that is built uses 4GB of RAM. Your host machine will need to be able to support that. You can override the CPU and RAM allocation by creating `ISLANDORA_VAGRANT_CPUS` and `ISLANDORA_VAGRANT_MEMORY` environment variables and setting the values. For example, on an Ubuntu host you could add to `~/.bashrc`:

```bash
export YUDL_VAGRANT_CPUS=4
export YUDL_VAGRANT_MEMORY=4096
```

## Use

1. `git clone https://github.com/yorkulibraries/yudl_vagrant`
2. `cd yudl_vagrant`
3. `vagrant up`

## Connect

Note: The supplied links apply only to this local vagrant system. They could vary in other installations. 

You can connect to the machine via the browser at [http://localhost:8000](http://localhost:8000).

The default Drupal login details are:
  - username: admin
  - password: islandora

MySQL:
  - username: root
  - password: islandora

ssh, scp, rsync:
  - username: ubuntu
  - password: ubuntu
  - Examples
    - `ssh -p 2222 ubuntu@localhost` or `vagrant ssh`
    - `scp -P 2222 somefile.txt ubuntu@localhost:/destination/path`
    - `rsync --rsh='ssh -p2222' -av somedir ubuntu@localhost:/tmp`

## Environment

- Ubuntu 16.04
- Drupal 7.54
- MySQL 5.5.49
- Apache 2.4.7
- PHP 7
- Java 8 (Oracle)
- FITS 1.0.7
- drush 6.3.0
- jQuery 1.10.2

## Maintainers

* [Nick Ruest](https://github.com/ruebot)

## Acknowledgements

This project was inspired by Ryerson University Library's [Islandora Chef](https://github.com/ryersonlibrary/islandora_chef), which was inspired by University of Toronto Libraries' [LibraryChef](https://github.com/utlib/chef-islandora). So, many thanks to [Graham Stewart](https://github.com/whitepine23), and [MJ Suhonos](http://github.com/mjsuhonos/).
