# Role Name

`dns-host`

## Description

This role configures local DNS resolution on a Linux system by managing the `/etc/hosts` and `/etc/resolv.conf` files using Ansible templates.

## Requirements

Compatible with Debian and RedHat OS families.

## Role Variables

The role uses two main sets of variables defined in `./defaults/main.yml`:

### `custom_hosts`

Defines static host entries to be written into `/etc/hosts`.

```yaml
custom_hosts:
  - ip: "xx.xx.xx.xx"
    name: "host1"
    aliases: ["gw", "dns1"]
  - ip: "xx.xx.xx.xx"
    name: "host2"
  - ip: "xx.xx.xx.xx"
    name: "host3"
  - ip: "xx.xx.xx.xx"
    name: "host4"
    aliases: ["dns2"]
  - ip: "xx.xx.xx.xx"
    name: "host5"
```
Each entry must include an IP address and a hostname. Optionally, you can specify one or more aliases.

nameservers
A list of IP addresses to be added as nameserver entries in /etc/resolv.conf.

```yaml
nameservers:
  - "xx.xx.xx.xx"
  - "xx.xx.xx.xx"
  - "xx.xx.xx.xx"

search_domains:
  - "home.lan"
```

### Templates
The role uses two Jinja2 templates:

hosts.j2: renders /etc/hosts using the custom_hosts variable.

resolv.conf.j2: renders /etc/resolv.conf using nameservers and search_domains.

Example generated /etc/hosts:
```
127.0.0.1       localhost
::1             localhost
192.168.1.1     host1 gw dns1
192.168.1.2     host2
Example generated /etc/resolv.conf:

search home.lan
nameserver 192.168.1.1
nameserver 192.168.1.2
```

##Customization
To modify host or DNS settings:

Edit ./defaults/main.yml and adjust the values for:
```
- custom_hosts (for static hostnames)
- nameservers (for DNS servers)
- search_domains (for DNS search suffixes)
```

The role will automatically regenerate the config files based on your changes.

##Example Playbook
```yaml
- name: Configure local DNS and hosts
  hosts: all
  become: true
  roles:
    - dns-host
```

##License
BSD

##Author Information
Cer3br0
