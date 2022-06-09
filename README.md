# I've open-sourced my life and here's how you can, too

Whether or not you believe Free and Open Source Software is the
saviour of humanity (I do!), it's also an incredibly practical way to
use your computer. This repository contains the exact configuration of
all my workstations, gaming computers, laptops and even a couple of
VPSes. Of course, your situation will differ, but I believe the
installation instructions and Ansible roles contained herein will be a
great starting point for anyone who wants to enjoy using their
computer to its maximum potential.

## The starting point

![Debian family tree](https://upload.wikimedia.org/wikipedia/commons/6/69/DebianFamilyTree1210.svg)

Let's return to the source and start with a minimal, vanilla Debian
installation. I prefer to download the installer image
[here](https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/weekly-builds/amd64/iso-cd/)
because this will get you the latest version of Debian including the
non-free firmware that's often needed to get networking and sound to
work properly. For servers, however, I recommend the rock-solid
[stable release](https://www.debian.org/download).

Write the image to a USB flash drive with:

    sudo dd if=debian-testing-amd64-netinst.iso of=/dev/sdX

But make sure you substitute `X` with the correct letter of your USB
drive. If this is your first time installing GNU/Linux, you'll have to
google for an alternative to `dd` for the operating system you're
currently using. There are plenty, but none of them are as
straightforward to use as the original `dd`. By the way, this is one
of the main reasons I enjoy using GNU/Linux so much: for almost every
imaginable task there is a suitable tool that does the job well. Also,
all of these tools can easily be scripted, but we'll get to that
later. For now, do your best to reboot your computer in such a way
that you arrive at the following screen:

![Debian installer](https://raw.githubusercontent.com/rtts/debian/main/doc/debian.png)

Hurrah! The hardest part -- getting your computer to successfully boot
from a USB stick -- is over! Note that the screenshot says "BIOS
mode", but if you manage to boot the installer in "UEFI mode" that is
probably even better. The second hardest part choosing a hostname for
the new system. Get some inspiration for great names at
https://namingschemes.com/. Carefully follow the installation
instructions and choose the partitioning method "Use entire disk and
set up encrypted LVM" for maximum security. At the end of the
installation you'll see this:

![Tasksel](https://raw.githubusercontent.com/rtts/debian/main/doc/tasksel.png)

Select nothing except for "SSH Server" and "standard system
utilities". After the installation is complete, boot into the new
system and log in using the username and password you have set during
installation. There is no graphical environment, yet, but be patient
because we'll configure the important things first.

## Hardening SSH

The only program currently running on your fresh installation is SSH.
Let's make sure it's running securely by logging in, configuring
public/private key authentication, disabling password authentication,
and then logging out again. Once you've accomplished that, you can
accomplish anything, because you will have remote access with sudo
powers, which is all that is needed to take full control over your
computer.

On the host computer, run:

    $ sudo apt install libnss-mdns

On the host computer or on another computer, if you have one, run:

    $ ssh-copy-id <hostname>.local

Finally, on the host computer, run:

    $ sudoedit /etc/ssh/sshd

And change the line containing `PasswordAuthentication` to:

    PasswordAuthentication no

To make the remaining steps a little easier, give yourself
passwordless sudo access by running:

    $ sudo visudo

And change the line containing `%sudo` to:

    %sudo ALL=(ALL:ALL) NOPASSWD:ALL

Not coincidentally, this is everything that's required to run the
Ansible playbook from this repository, which will completely set up
the system for general use.

## Run the playbook

On either the host computer or on another computer with SSH access to
the host computer, install [Git](https://git-scm.com/) and
[Ansible](https://docs.ansible.com/ansible/latest/index.html) and
clone this repository:

    $ sudo apt install git ansible
    $ git clone https://github.com/rtts/debian
    $ cd debian

The playbook is divided into a number of hosts, with each host having
a number of roles. The roles are meant to be reusable, so you can
easily choose to, for example, configure a host with the `common` and
`X` roles, but not with the `workstation` role. I personally use that
combination for computers that are being used as kiosks in various
locations, such as a copy shop and a museum. Another useful
combination is `common`, `database`, and `webserver` for the VPS that
serves my [personal home page](https://jaapjoris.nl/). That is the
power of using a single source of configuration for all your
computers!

For now, however, let's assume you are setting up a personal computer
that is in your physical possesion, such as a laptop or a desktop
computer. Open the file `inventory.ini` and add your hostname to the
`[workstations]` section and, if it's a laptop, to the `[laptops]`
section. Leave off the `.local` extension, as SSH will be configured
to append that by default as soon as we'll run the playbook.

Now run the playbook!

    $ ./playbook.yml

## Using the new system

Congratulations! Your system has been fully set up for general use,
with a number of useful software packages installed and thousands more
just one `apt install` away. Let me guide you to how to use this setup
and how to customize it to your wishes.

After the system boots, you will be greeted with the following
message-of-the-day:

       ___      __   _         
      / _ \___ / /  (_)__ ____ 
     / // / -_) _ \/ / _ `/ _ \
    /____/\__/_.__/_/\_,_/_//_/

    Memory: 119/974MB (12%)
    Disk /: 1/4GB (36%)
    Load average: 0.22 0.08 0.02
    jj@debian:~$ 

This message is shown in the blazingly fast terminal emulator
`rxvt-unicode` displayed by the tiling window manager `xmonad`. A
single terminal is automatically launched at startup, because I like
it that way, but you can easily specify another program to launch by
editing the `.xsession` file in your home directory. Also have look at
the other dotfiles that were placed there by the playbook.

Here are the most important keyboard shortcuts you need to know:

- `Windows - Shift - Enter` opens a new terminal.
- `Windows - [1-9]` switches to the virtual desktop 1 through 9.
- `Windows - P` launches `dmenu`. Type the starting letters of a
  graphical program, such as `chromium` or `firefox` and press Enter
  to launch it.
- `Windows - Tab` cycles between the windows on the current virtual
  desktop.
- `Windows - Space` switches between fullscreen and tiled window
  layouts.
- When in tiled layout, `Windows - ,` and `Windows - .` do something
  that's hard to explain, but is usually exactly what you need.
- To change the size of tiled windows, `Windows - H` and `Windows -
  L`. You can also change the size of any window by holding `Windows`
  and drag it using the right mouse button.
- Dragging a window while holding the `Windows` key will make it
  floating. You can make it tiled again with `Windows - T`.

## More possibilities

In no particular order, here are some things that I've done using this
setup.

### Web browsing

The playbook has installed the web browsers Chromium and Firefox.
Personally, I like to edit `/etc/chromium.d/default-flags` to add the
`--incognito` flag so that Chromium will always browse incognito, and
then use Firefox for all my non-incognito browsing. Both browsers
include uBlock Origin through the `webext-ublock-origin` Debian
package. I have also heard good things about the
[Firefox Multi-Account Containers](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/)
extension so you might want to give that a try. Also I highly
recommend setting your default search engine to DuckDuckGo so you have
access to their incredible [Bang syntax](https://duckduckgo.com/bang)
when doing searches. In practice, however, most of my web searches
still use the `!g` bang to search Google.

### Writing

Put that keyboard in your computer to good use! During my studies, I
used LaTeX to write my thesis, but when other people email me Word and
Excel files I use LibreOffice to open them. All are installed by default
after running the playbook.

### Lego CAD editing

I used [LDCad](http://www.melkert.net/LDCad) to create building
instructions for [my Lego models](https://jj.created.today/). It's the
only piece of non-open source software on my computer, but I've
emailed the author and he assured me he would open source it before
his death.

### Photography

After a photo shoot I like to use `geeqie` (`apt install geeqie`) to
cull the photos I've taken, then use `darktable` (`apt install
darktable`) to post-process them. Finally, I use `photog` (`pip
install photog`) to generate [my photography
website](https://www.superformosa.nl/). Of course, GIMP and Inkscape
cannot be missing in any designer's toolbox and are therefore already
installed by the `Xworkstation` role.

### Audio recording

I use Audacity (`apt install audacity`) to record high-quality audio
using a Focusrite Scarlet 2i2, which works phenomenally well under
Linux and PulseAudio. All I needed to do was plug the device in and
attach speakers, and all audio was routed correctly by default.

### Programming

The terminal-first computing environment configured by this playbook
naturally lends itself well to all kinds of programming. Recommended
languages to get started are Bash, Python, Perl, Ruby, Haskell (I dare
you to edit the `xmonad` configuration file!), or PHP. Make sure to
`apt install emacs` or `apt install vim` and learn C if you want to
become a true Unix hacker!

### Entertainment

I love `mpv` so much it's included in the `Xworkstation` role by
default. Read `man mpv` to find out all the available options of this
grand successor to `mplayer`. Unfortunately, it is currently not easy
to legally acquire stuff to play with `mpv`, so you'll have to resort
to semi-legal options like `youtube-dl` (`apt install youtube-dl`) or
illegal options like Yify.

### Gaming

If you're a gamer, you probably want to install the Steam Client even
though it's not open source. Personally I like playing titles that are
available on the Internet Archive, using my own [custom games launcher
for DOSBox](https://ialauncher.created.today/) that will automatically
download and run a large number of MS-DOS games. Here's how to install
and run it:

    $ sudo apt install dosbox
    $ pip3 install ialauncher
    $ ialauncher --no-fullscreen

The `--no-fullscreen` argument is there because `xmonad` will already
tile the IA Launcher window to be fullscreen.

## Maintenance

Like any operating system, Debian publishes regular updates. I've made it
a habit to run the following commands every week:

    $ sudo apt update
    $ sudo apt upgrade

Also, because I like bleeding-edge software, I've edited
`/etc/apt/source.list` to contain (only) the following:

    deb http://ftp.nl.debian.org/debian/ sid main non-free contrib
    deb-src http://ftp.nl.debian.org/debian/ sid main non-free contrib

This means I'm running [Debian Sid](https://wiki.debian.org/DebianUnstable)
a.k.a. "Unstable", although in my 10 years of running it I have never
ran into problems. Use Sid at your own risk.
