# Build

```
make podman.raw
```

# Use

Copy podman.raw to /etc/extensions.

Disable selinux in /etc/selinux/config - must be disabled not permissive. Default file is a symlink so make a copy (`cp /etc/selinux/config{,-}; mv /etc/selinux/config{-,}`)

Symlink the CNI plugins `ln -sf /usr/lib/cni/ /opt/cni/`

Copy configs from /usr/etc/ into the appropriate directories in /etc.  Remove the .example extensions.

Run `systemctl enable --now podman.socket`

# Test

```
snap install hello-world
snap run hello-world
```

To make snaps accessible, add /var/lib/podman/snap/bin to $PATH.
