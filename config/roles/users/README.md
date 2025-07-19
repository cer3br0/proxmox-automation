Role Name
=========

Create, remove and manage users

Requirements
------------

Compatibility for Debian and RedHat os family

Role Variables
--------------
Warning: Vault logic is implemented for password encryption. See line 32 in in tasks/main/yaml ->     password:  "{{ vault_user_passwords[item.name] | default(omit) }}"
You must modify this line only if you do not want to use encrypted passwords (DO NOT DO THIS IN PRODUCTION).

For vault use :
Use python or mkpasswd to generate a SHA512-hashed password.
Then, create an encrypted file (for example: ansible-vault create roles/users/vars/secret.yml) and define a dictionary with key/value pairs for each user in the following format:

vault_user_passwords:

  user1:"hashed password"
  
  user2:"hashed password"
 

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

- name: apply config users
  
  hosts: all
  
  become: true
  
  roles:
  
    - users

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
