Role Name
=========

This role can be used for safe upgrade or full upgrade for OS Debian. 
I recommand to make save / snapshot of your VMs before any upgrade attempt
Please ensure you dont have any incompatibility on dependencies with the services you're running before to apply an upgrade

Requirements
------------

Debian based OS (this one was test on Debian12 only)


Role Variables

This role provides several variables to control the behavior of Debian/Ubuntu system updates.
They are all defined in defaults/main.yml and can be overridden in your inventory, playbooks, or via -e parameters.

Variable	Default	Description

```yaml
os_upgrade_type :	"dist"	# Type of upgrade to perform. Possible values
• safe → only safe upgrades # (equivalent to apt upgrade)
• full → full upgrade # (equivalent to apt full-upgrade)
• dist → distribution upgrade # (equivalent to apt dist-upgrade).

os_dpkg_options:	"force-confdef,force-confold"	# Options passed to dpkg to avoid interactive prompts and keep existing configuration files.

os_cache_valid_time:	3600	# Number of seconds that apt will consider its package cache valid. Prevents unnecessary apt update calls if cache is still fresh.

os_autoremove: true	# Whether to run apt autoremove after the upgrade to clean unused packages.

os_autoclean:	true	# Whether to run apt autoclean to remove outdated package files from the cache.

os_reboot_if_required: true # If true, the host will be rebooted at the end of the upgrade if /var/run/reboot-required exists.

os_reboot_timeout:	600	# Maximum time (in seconds) to wait for a system to reboot and become available again.

os_needrestart_mode:	"a"	#Controls how needrestart handles service restarts during upgrade:
• a → automatic restart of affected services
• i → interactive (not suitable for automation)
• l → list only (no restart).
```

Notes
```
- All variables are designed to keep the role idempotent and non-interactive (safe for automation).
- Variables can be overridden in group_vars, host_vars, or directly on the command line with -e.
- By default, the role ensures minimal downtime (reboot only if strictly necessary).
```


Example Playbook
----------------
```yaml
- name: Update OS on all debian hosts
  hosts: Deb-SRV
  become: true
  roles:
    - role: deb-os-update
  tags: [os]
```

License
-------
MIT

Author Information
------------------
Cer3br0
