LWComputers Software
	by loosewheel


Licence
=======
Code licence:
LGPL 2.1

In game code licence:
MIT

Media licence:
CC BY-SA 3.0


Version
=======
0.1.0


Minetest Version
================
This mod was developed on version 5.5.0 (should run on 5.3.0)


Dependencies
============
default
lwcomputers (version 0.2.9 or later)


Optional Dependencies
=====================
intllib


Installation
============
Copy the 'lwcomputers_software' folder to your mods folder.


Bug Report
==========
https://forum.minetest.net/viewtopic.php?f=9&t=28302


Description
===========
Floppy disks with software for lwcomputers.


WIN is a multi-tasking, windowed operating system. It can run desktops on
multiple devices, the terminal and any number of monitors. The server
provides simple file and email hosting.


To install the WIN OS:
Place the WIN Installer floppy into a slot on the computer, then boot the
computer. The installer will prompt to overwrite existing files. Click
the y key to continue. Any other key cancels the installation. When
installation is complete, remove the installer floppy and reboot the
computer.
Note that it may take a couple of seconds for the floppy to go into the
computer's slot the first time the floppy is used, as it creates the
floppy's contents.


To install the server.
The server can be installed stand alone or with an OS.

Stand alone:
Place the Server Installer floppy in the slot of a computer, then boot the
computer. The installer will prompt to overwrite existing files. Click
the y key to continue. Any other key cancels the installation. When
installation is complete, remove the installer floppy and reboot the
computer.
When the server is stand alone the server is running, but no interaction
is possible from the terminal.

With OS:
Install the OS first. Place the Server Installer floppy in the slot of a
computer, then boot the computer. The installer will prompt that it found
an OS and will rename /boot to /boot_os, and to overwrite existing files.
Click the y key to continue. Any other key cancels the installation. When
installation is complete, remove the installer floppy and reboot the
computer. The server loads and then chain loads the OS.
If installing the server with WIN, you can use the method above or just
copy /SERVER/server and /SERVER/server.cfg to the root folder instead of
running the installer. Open the existing /boot file and uncomment the line:

dofile ("/server")

If you would like a start notification that the server has started you can
place a line following:

os.sleep (0.5)

Note that a computer cannot access itself through a comm connection.


Open Software:
Place the Open Software floppy into a slot on the computer, then boot the
computer. The installer will prompt to overwrite existing files. Click
the y key to continue. Any other key cancels the installation. When
installation is complete, remove the installer floppy and reboot the
computer.
The Open Software floppy contains the files for a web site for downloading
common software. The contents of this floppy is installed to the
'/public' folder. Note this does not install the server.


The App Templates floppy is just a data disk with starter applications
to copy and then extend upon to write your own applications. These starter
applications are also in the docs.



When disposing of these disks use the trash provided with lwcomputers to
remove the disk data as well.


The docs/api folder has full documentation of the WIN api and server.

------------------------------------------------------------------------
