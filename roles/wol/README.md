# Wake-on-LAN

This is a role and a rant about enabling Wake-on-LAN, a feature so
forgotten that discovering it almost feels like re-inventing it. When
it finally works, you can switch on the computer via the network,
which is a useful and responsible thing to do when you want to
conserve power by spinning up machines on demand.

Unfortunately, hardware and software suppliers alike conspire against
users to make this as hard as possible to enable. First, you need to
scour the UEFI/BIOS settings to find something opaquely named "Power
on by PCIE" or some other phrase that never uses the official term
"Wake-on-LAN" as coined by the *Advanced Manageability Alliance* in
1997.

Then, you need to install some obscure package called `ethtool` that's
distributed by kernel.org
[separately](https://mirrors.edge.kernel.org/pub/software/) from the
Linux source code, alongside forgotten beauties such as
[DeCSS](https://en.wikipedia.org/wiki/DeCSS):

> DeCSS is a utility for stripping Cascading Style Sheet (CSS) tags
> from an HTML page. That's all it does. It has no relationship
> whatsoever to encryption, copy protection, movies, software freedom,
> oppressive industry cartels, Web site witch hunts, or any other bad
> things that could get you in trouble.

Next, you need to run `ethtool` to toggle the `wol` capability of your
network card to option `g`, which is the single-letter abbreviation of
the term "magic packet", because that also contains the letter `g`.
Are you still following this? Here is the command to do so:

    # ethtool -s <interface> wol g

However, this will not work without *also* enabling option `b`, for
Broadcast activity. From `man wakeonlan`:

> Unless you have static ARP tables you should use some kind of
broadcast address (the broadcast address of the network where the
computer resides or the limited broadcast address). Default:
255.255.255.255 (the limited broadcast address).

Now running `wakeonlan <MAC_ADDRESS>` should work, but only once. To
persist the `g` and `b` settings, you will have to re-enable it on
every boot. In the old days, you could simply add the `ethtool`
command to `/etc/rc.local` but nowadays even a single command like
this needs their own standalone systemd service configuration:

```ini
[Unit]
Description=Wake-on-LAN for %i
Requires=network.target
After=network.target

[Service]
ExecStart=/usr/bin/ethtool -s %i wol g
Type=oneshot

[Install]
WantedBy=multi-user.target
```

So that is what this role initially set out to configure: Add this
configuration to some hard-to-find subdirectory of systemd, then call
`systemctl daemon-reload`, `systemctl enable wol`, `systemctl start
wol`, and `systemctl pretty-please-with-sugar-on-top` to have the darn
command run every time the computer boots. However, it turned out that
supplying the correct value for the placeholder `%i` (or even finding
the correct `man` page out of the 202 (!) systemd `man` pages that
documents what `%i` even stands for) is impossible to do from a
generic playbook role, because the name of the network device is
unknown. (Again, in the good old days the name of the primary
interface would simply be `eth0`, but they have changed it to a
gibberish name like `enp1s2` to "helpfully" indicate that the device
is present on bus number 2 in slot number 3, or whatever.)

Moreover, the `ethtool` command will not work at all when
NetworkManager is installed, according to the following according to
the following warning in [this AUR
package](https://aur.archlinux.org/packages/wol-systemd), (whose
source code is for some reason not available to view in a web
browser):

    WARNING: You seem to have Network Manager installed.
    As of 1.0.6, this no longer works with NetworkManager.
    Use the solution from
    https://wiki.archlinux.org/index.php/Wake-on-LAN#NetworkManager
    instead.

Even though that statement is not entirely correct (NetworkManager,
even if installed, ignores interfaces that have been configured
through `/etc/network/interfaces`), to maximize the chance of
successfully enabling Wake-on-LAN this role chooses a different
approach. It enables WoL of *every single network device* by
overriding `/usr/lib/systemd/network/99-default.link` to add the
`WakeOnLan` option to the `[Link]` section, as proposed by the Arch
Wiki page
[here](https://wiki.archlinux.org/title/Wake-on-LAN#Make_it_persistent)
and in the way recommended by this comment in the [default
configuration
file](https://github.com/systemd/systemd/blob/main/network/99-default.link):

```
# To make local modifications, one of the following methods may be used:
# 1. add a drop-in file that extends this file by creating the
#    /etc/systemd/network/99-default.link.d/ directory and creating a
#    new .conf file there.
```

Et voilà! Every network interface will now support Wake-on-LAN, if
available, out-of-the-box. Was that so hard?
