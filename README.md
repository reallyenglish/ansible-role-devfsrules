# ansible-role-devfsrules

Manage devfs.rules(5) in FreeBSD

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `devfsrules_file` | path to `devfs.rules` | `/etc/devfs.rules` |
| `devfsrules` | list of [`devfs.rules(5)`](http://man.freebsd.org/devfs.rules). see below. | `[]` |
| `devfsrules_devfs_system_ruleset` | a rule set to apply to /dev on the system, see `devfs_system_ruleset` in [`rc.conf`](http://man.freebsd.org/rc.conf) | `""` |
| `devfsrules_devfs_set_rulesets` | list of `devfs_set_rulesets`, pairs of dev directories and rule sets. see below | `[]` |

## `devfsrules`

This variable is a list of dict. Each list element must have a dict with the
following keys and values.

| Key | Description |
|-----|-------------|
| name | name of the rule |
| number | rule number |
| rules | the rules |

## `devfsrules_devfs_set_rulesets`

This variable is a list of dict and used to construct `devfs_set_rulesets` in
`rc.conf(5)`. Keys and values are described below. All keys are mandatory. The
role mounts `devfs` file system on `path` when `state` is present. When `state`
is `absent`, the file system is unmounted.

| Key | Value |
|-----|-------|
| `path` | path to mount `devfs` |
| `name` | name of rule set to apply |
| `state` | either `present` or `absent` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-devfsrules
  vars:
    devfsrules:
      - name: devfsrules_jail_with_bpf
        number: 100
        rules: |
          add include $devfsrules_hide_all
          add include $devfsrules_unhide_basic
          add include $devfsrules_unhide_login
          add path 'bpf*' unhide
          add path 'net*' unhide
          add path 'tun*' unhide
      - name: my_rule
        number: 999
        rules: |
          add path 'tun*' hide
          # choose a device that exists in the VM and is safe to hide
          add path led/em0 hide
          add path 'bpf' user root
          add path 'bpf' group network
          add path 'bpf' mode 660
      - name: chroot
        number: 200
        rules: |
          add include $devfsrules_hide_all
          add include $devfsrules_unhide_basic
          add path random unhide
          add path urandom unhide
    devfsrules_devfs_system_ruleset: my_rule
    devfsrules_devfs_set_rulesets:
      - path: /chroot1/dev
        name: chroot
        state: present
      - path: /chroot2/dev
        name: chroot
        state: present
      - path: /foo/bar
        name: nothing
        state: absent
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
