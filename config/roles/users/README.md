# Role Name

users

## Description

Create, remove and manage users

## Requirements

Compatibility for Debian and RedHat OS family

## Role Variables

**Warning:** Vault logic is implemented for password encryption. See line 32 in `tasks/main.yaml`:
```yaml
password: "{{ vault_user_passwords[item.name] | default(omit) }}"
```

You must modify this line only if you do not want to use encrypted passwords (**DO NOT DO THIS IN PRODUCTION**).

### For vault use:

1. Use python or mkpasswd to generate a SHA512-hashed password
2. Create an encrypted file (for example: `ansible-vault create roles/users/vars/secret.yml`)
3. Define a dictionary with key/value pairs for each user in the following format:

```yaml
vault_user_passwords:
  user1: "hashed password"
  user2: "hashed password"
```

## Dependencies

None

## Example Playbook

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- name: apply config users
  hosts: all
  become: true
  roles:
    - users
```

## License

BSD

## Author Information

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
