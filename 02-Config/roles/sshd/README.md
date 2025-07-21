# Role Name

`sshd`

## Description

Config / hardening sshd (openssh-server).

## Requirements

Compatibility for Debian and RedHat OS family.

## Role Variables

**Warning:** Ansible facts are used to restrict ssh access to the main interface **(see in ./default/main.yml line 1)**. However, a default value **(0.0.0.0)** is set to prevent connection issue is an error occurs while collecting network facts.
```yaml
ssh_listen_address: "{{ ansible_facts['default_ipv4']['address'] | default('0.0.0.0') }}"
```

## Custom existing value  
Edit value in **./defaults/main.yaml** to override default configuration.

## Add another SSHD option  
```
- Edit the jinja template ./templates/custom.conf.j2
- Add corresponding key/value in ./defaults/main.yaml
```

## Debugging : Save and display facts 
If you encounter issues related to networks facts, you can enable the following task block in **./tasks/main.yml** to dump all collected facts to JSON file.  
```yaml
#- name: save fact to JSON format
# copy:
#    content: "{{ ansible_facts | to_nice_json }}"
#    dest: "./facts_{{ inventory_hostname }}.json"
#  delegate_to: localhost 
```

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- name: apply sshd config
  hosts: all
  become: true
  roles:
    - sshd
```

## License

BSD

## Author Information

Cer3br0
