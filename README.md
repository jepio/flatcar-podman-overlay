# Build

```
make snapd.raw
```

# Use

Copy snapd.raw to /etc/extensions.

Disable selinux in /etc/selinux/config - must be disabled not permissive. Default file is a symlink so make a copy (`cp /etc/selinux/config{,-}; mv /etc/selinux/config{-,}`)

Run `systemctl enable --now snapd.socket`

# Test

```
snap install hello-world
snap run hello-world
```

To make snaps accessible, add /var/lib/snapd/snap/bin to $PATH.
