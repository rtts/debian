# rtts/Debian

### *A complete, minimalist Debian setup for power users*

**This repository contains the exact configuration of all my
workstations, gaming computers, laptops and even a couple of VPSes. Of
course, your situation will differ, but I believe the installation
instructions and Ansible roles contained herein will be a great
starting point for anyone who wants to enjoy using a minimalist setup
to its maximum potential.**

## FAQ

### Is this a GNU/Linux distribution?

Yes, it kind of is! Except that all that I'm distributing is a bunch
of [Ansible](https://docs.ansible.com/ansible/latest/index.html) roles
and the installation instructions. Think of this as a dotfiles
repository that also includes the playbook to install [the
dotfiles](https://github.com/search?q=repo%3Artts%2Fdebian+path%3Adotfiles&type=code).

### Why should I use this instead of distribution X?

You should not use this at all, this system is tailored exactly to my
own needs and nothing more. However, you may find some configuration
gems here that you can use in your own setup. Find an old laptop or
spin up a VM and give it a try if you want to see how a fellow
GNU/Linux enthusiast has configured their computer!

### How can I install it?

Keep reading! This README contains all the steps needed to install
Debian, set up the base system, and run the Ansible playbook that will
take care of the remaining configuration.

## The starting point

![Debian family tree](https://upload.wikimedia.org/wikipedia/commons/6/69/DebianFamilyTree1210.svg)

Let's return to the source and start with a minimal, vanilla Debian
installation. Visit [Debian.org](https://www.debian.org/) and click
"Download", then write the image to a USB flash drive with:

    sudo dd if=debian-12.8.0-amd64-netinst.iso of=/dev/sdX

Make sure you substitute `X` with the correct letter of your USB
drive). Then, do your best to reboot your computer in such a way
that you arrive at the following screen:

![Debian installer](https://raw.githubusercontent.com/rtts/debian/main/doc/debian.png)

Hurrah! The hardest part – getting your computer to successfully boot
from a USB stick – is over! Note that the screenshot says "BIOS mode",
but if you manage to boot the "UEFI Installer menu" that is probably
even better. The second hardest part is choosing a hostname for the
new system. Get your inspiration at https://namingschemes.com/.

Carefully follow the installation instructions and choose the
partitioning method "Use entire disk and set up encrypted LVM" for
maximum security. At the "Set up users and passwords" prompt, supply
an empty password for the root user and create an initial user
account. This account will be given the power to become root using the
`sudo` command. One day, I will add a [Debian
Preseed](https://wiki.debian.org/DebianInstaller/Preseed) to this
repository which will make all this happen automatically.

At the end of the installation you'll see this:

![Tasksel](https://raw.githubusercontent.com/rtts/debian/main/doc/tasksel.png)

Select nothing except for "SSH Server" and "standard system
utilities". After the installation is complete, boot into the new
system and log in using the username and password you have set during
installation. There is no graphical environment, yet, but be patient
because we'll configure the important things first.

> **Note**
>
> Even when you have configured a WiFi connection during the
> installation, the resulting system may not have WiFi.
>
> One way to solve this is to boot the installer again and enter
> "Rescue mode", follow the steps to get a root shell, and install
> NetworkManager with `apt install network-manager`.
>
> Then, remove the USB drive, reboot into your system and execute:
> `nmcli dev wifi connect <Your WiFi name> password <Your WiFi password>`

## Give yourself (remote) access

On the target computer, run:

    $ sudo apt install libnss-mdns

On the target computer or another computer, run:

    $ ssh-copy-id <hostname>.local

Finally, on the target computer, run:

    $ sudo visudo

And change the line containing `%sudo` to:

    %sudo ALL=(ALL:ALL) NOPASSWD:ALL

This is everything that's required to run the Ansible playbook from
this repository, which will take care of the rest of the installation.

## Run the playbook

On either the target computer or on another computer, install
[Git](https://git-scm.com/) and
[Ansible](https://docs.ansible.com/ansible/latest/index.html) and
clone this repository:

    $ sudo apt install git ansible
    $ git clone https://github.com/rtts/debian
    $ cd debian

The playbook is divided into a number of hosts, with each host having
a number of roles. The roles are meant to be composable, so you can,
for example, configure a host with the `common` and `X` roles for use
as a [media player](https://github.com/rtts/median).

For now, however, let's assume you are setting up a personal computer
that is in your physical possesion, such as a laptop or a desktop
computer. Open the file `inventory.ini` and add your hostname to the
`[workstations]` section and, if it's a laptop, to the `[laptops]`
section. If you want the system to be able to send and receive email,
provide your email credentials (optional).

Now run the playbook!

    $ ./playbook.yml

## Using the system

Congratulations! Your system has been fully set up for general use,
After the system boots, you will be greeted with the following message
of the day:

![Message of the day](https://raw.githubusercontent.com/rtts/debian/main/doc/motd.png)

This message is shown in
[rxvt-unicode](http://software.schmorp.de/pkg/rxvt-unicode.html)
displayed by the tiling window manager [xmonad](https://xmonad.org/).
A single terminal is automatically launched at startup. You can
specify which program(s) launch at startup by editing `~/.xsession`.
Also have look at the other dotfiles that were installed.

> **Note**
>
> All dotfiles (except `.bashrc`) are placed by Ansible with the
> [force](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html#parameter-force)
> parameter set to `false`, which means that local changes will not be
> overwritten when you re-run the playbook. The dotfiles are also
> written to the `/etc/skel` directory, so they will be installed for
> new users created by `adduser`. This is also a convenient location
> to check for updates to dotfiles.

Here are some useful keyboard shortcuts (note: `Mod` is mapped to the
windows key by the `X` role):

- `Mod` `Shift` `Enter` opens a new terminal.
- `Mod` `[1-9]` switches to the virtual desktop 1 through 9.
- `Mod` `P` launches `dmenu`. Type the starting letters of a
  graphical program, such as `chromium` or `firefox` and press Enter
  to launch it.
- `Mod` `Tab` cycles between the windows on the current virtual
  desktop.
- `Mod` `Space` switches between fullscreen and tiled window
  layouts.
- `Mod` `Enter` moves a window to the top of the window stack.
- When in tiled layout, `Mod` `,` and `Mod` `.` do something
  useful that's hard to explain. Try it out!
- To change the size of tiled windows, `Mod` `H` and `Mod` `L`
  You can also change the size of any window by holding `Mod`
  and drag it using the right mouse button.
- Dragging a window while holding the `Mod` key will make it
  floating. You can make it tiled again with `Mod` `T`.

You can view all available keybindings with `Mod` `Shift` `/`.

## More possibilities

Here are the things that I use this setup for:

### Web browsing

The playbook has installed the web browsers Chromium and Firefox.
Personally, I like to edit `/etc/chromium.d/default-flags` to add the
`--incognito` flag so that Chromium will always browse incognito, and
then use Firefox for all my non-incognito browsing.

Both browsers include uBlock Origin through the `webext-ublock-origin-*`
Debian packages. I have also heard good things about the
[Firefox Multi-Account Containers](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/)
extension so you might want to give that a try. The recently introduced
[Total Cookie Protection](https://blog.mozilla.org/en/products/firefox/firefox-rolls-out-total-cookie-protection-by-default-to-all-users-worldwide/)
sounds very promising.

I highly recommend setting your default search engine to DuckDuckGo so
you have access to their incredible [Bang
syntax](https://duckduckgo.com/bang). In practice, however, most of my
web searches still use the `!g` bang to search Google.

### Email

Email configuration is split up into two roles:

1. `mailserver`
2. `mailclient`

The `mailserver` role configures Exim4 to send all outgoing emails
through a smarthost of your choosing, solving the mystery of [xkcd
838](https://xkcd.com/838/):

![XKCD 838](https://imgs.xkcd.com/comics/incident.png)

The `mailclient` role installs [mutt](http://www.mutt.org/) for a
single user only, assuming that user is you. Launch it by typing
`mutt` at the command line and be amazed at the usability of it. It
has a [lengthy manual](http://www.mutt.org/doc/manual/), but for basic
usage all you need is the arrow keys and the following shortcuts:

- `m`: Send new email
- `r`: Reply to the current email
- `t`: Mark the current email for deletion/archival
- `d`: Delete the marked emails
- `A`: Archive the marked emails

### Lego CAD

I use [LDCad](http://www.melkert.net/LDCad) to create building
instructions for [my Lego models](https://jj.created.today/). It's
closed-source, but I've emailed the author and he's assured me he
would open source it before his death. You can also install `leocad`
and `ldraw-parts` from the Debian repositories. For more information
visit [LDraw.org](https://ldraw.org/).

### Photography

I use [Geeqie](https://www.geeqie.org/) (`apt install geeqie`) to cull
the photos after a shoot, then use
[darktable](https://www.darktable.org/) (`apt install darktable`) to
post-process them. Finally, I use
[Photog!](https://pypi.org/project/photog/) (`pip install photog`) to
generate [my photography website](https://www.superformosa.nl/).

### Audio

I use [Audacity](https://www.audacityteam.org/) (`apt install
audacity`) to record high-quality audio using a Focusrite Scarlet 2i2,
which works phenomenally well under Linux and PulseAudio. All I needed
to do was plug the device in and attach speakers, and all audio was
routed correctly by default.

### Video

Have a look at [FFTok](https://github.com/rtts/fftok) for some handy
`ffmpeg` shortcuts to cut, split, crop, scale, combine and transcode
video files.

### Programming

The terminal-first computing environment configured by this playbook
naturally lends itself well to all kinds of programming. Try for
example Bash, Python, Perl, Ruby, or Haskell (I dare you to edit the
`xmonad` configuration file!).

### Media

[mpv](https://mpv.io/) is included in the `X` role by default. Read
`man mpv` to find out all the available options of this grand
successor to `mplayer`.

Streaming services work in Firefox after [enabling
DRM](https://support.mozilla.org/en-US/kb/enable-drm) but not in
Chromium, because it lacks the required Widevine DRM. Please [fight
for alternatives to DRM](https://www.defectivebydesign.org/).

### Gaming

If you're a gamer, you probably want to install the [Steam
Client](https://store.steampowered.com/about/) even though it's not
open source. Personally I like playing titles that are available on
the Internet Archive, using my own [custom games launcher for
DOSBox](https://ialauncher.created.today/) that will automatically
download and run a large number of MS-DOS games. Here's how to install
and run it:

    $ sudo apt install dosbox
    $ pip install ialauncher
    $ ialauncher --no-fullscreen

The `--no-fullscreen` argument is there because `xmonad` will already
tile the IA Launcher window to be fullscreen. Alternatively, you can
add your computer to the `gamestations` group to configure it as a
gaming kiosk.

### Kiosks

The `kiosks` group only installs the `common` and `X` roles intended
for single-use setups, such as:

- Digital signage
- Public library
- [Media player](https://github.com/rtts/median)

You can turn your computer into a locked down Chromebook by adding the
following to the end of `~/.xsession`:

```
exec chromium --kiosk
```

### Work

To satisfy my employer's ISO 27001 requirement, the screens of all
workstations are set to lock after 15 minutes of inactivity. This
is accomplished with `xautolock`, which is officially hosted by [one
of the first web sites on the
internet](https://en.wikipedia.org/wiki/Ibiblio#History):
`http://sunsite.unc.edu/pub/Linux/X11/screensavers/`. To get rid of
the auto-locking behavior, remove the file
`/etc/X11/Xsession.d/90custom_autolock` and restart X with `Mod`
`Shift` `Q`.

It's possible to [configure mutt to connect to an Exchange
server](https://jonathanh.co.uk/blog/mutt-setup/#connecting-to-exchange---davmail),
but according to the linked blog:

> get yourself a beer, this will probably take a couple of hours to
> set up

## Maintenance

Like any operating system, Debian publishes regular updates. Make it
a habit to run the following commands regularly:

    $ sudo apt update
    $ sudo apt upgrade
