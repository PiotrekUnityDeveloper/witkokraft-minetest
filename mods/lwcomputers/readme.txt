LWComputers
	by loosewheel


Licence
=======
Code licence:
LGPL 2.1

Font images:
Are derived from Liberation Mono licensed under the Liberation Fonts license,
see https://fedoraproject.org/wiki/Licensing/LiberationFontLicense

Page and book images:
Derived from images of default game, licensed CC-BY-SA 3.0,
see http://creativecommons.org/licenses/by-sa/3.0/

Art licence:
CC-BY-SA 3.0

Sound licence:
CC BY 4.0


Version
=======
0.2.9


Minetest Version
================
This mod was developed on version 5.3.0


Dependencies
============
default


Optional Dependencies
=====================
intllib
mesecons
digilines
digistuff
unifieddyes
mesecons_mvps
lwcomponents
lwwires


Installation
============
Copy the 'lwcomputers' folder to your mods folder.


Bug Report
==========
https://forum.minetest.net/viewtopic.php?f=9&t=25916&sid=7af0bb8a2ac3b9ade7a3f87b7a2463fa


Description
===========
LWComputers provides programmable computers and robots, floppy disks,
printers, graphical screens, touch response monitors, a digilines
controlled mesecons power switch, solid conductor blocks, vertical moving
floor and a trash item.

The following are also defined as variants of the original mod item, if
the relevant mod is loaded.
+	lwcomputers:touchscreen - digistuff:touchscreen as full sized node.
+	lwcomputers:panel - digistuff:panel as full sized node.

**	Note
DigiSwitch, MoveFloor, Solid Color Conductors, lwcomputers:touchscreen
and lwcomputers:panel have been depreciated. See lwcomponents.

Each computer has an internal hard drive, and 3 slots for floppy disks
(or a clipboard). The terminal display has a resolution of 50 characters
wide by 19 characters high by default. This can be changed through the
mod settings. 16 colors are supported for both fore-ground and back-ground.
The computer GUI has a keyboard, a reboot button, a power button and a
persistence button. The terminal also responds to mouse clicks, which can
be disabled through the mod settings.

Robots are the same as computers with an additional robot interface in the
lua environment. They also have a storage inventory accessible by the
additional "S" button on the terminal interface. Robots can move, detect,
dig, place, drop, trash, craft and work with inventories. While a robot
is running sneak + punch will open a form to stop it.

The first time a computer or robot is placed in the world a form opens
asking the player that placed it, if the machine is public or private. If
private is selected, the player becomes the owner and other players (except
those with protection_bypass privilege) cannot access it. The security
interface in the machine's api can be used to manage players that can access
the machine. If a player does not have access they can't dig, open or
operate the terminal gui, or stop a robot.

The persistence button toggles on and off. If persistence is on, the block
the computer is in remains loaded when out of range. This persistence is
retained across world startups. Robots retain their persistence state when
moved, computers do not. The maximum force loaded blocks is limited to the
max_forceloaded_blocks setting (default is 16).

The Ctrl, Cap, Shift and Alt keys on the keyboard toggle down and up. When
in the down state the key's label is suffixed with a "*".

Each computer and floppy disk has a unique integer id assigned to it.

If a floppy is "dug" (left click) a form displays the floppy's id and
label. If the floppy has never been put in a computer's slot its id shows
as "<not used>". If a floppy has no label its label shows as "<no label>".

A computer's hard drive folder is created the first time it is powered
up. A floppy disk's folder is created the first time it is placed in a
computer's slot.

The computers don't have an inbuilt os. When the computer is powered up
it looks for a file named 'boot' in the root folder of the drives in order
slot 1 (left), slot 2, slot 3 then internal hard drive. The first one found
is loaded and run. If none is found the computer halts and displays
"No boot media ...".

When a world is restarted, any computers running from the last shut down is
rebooted. It does not keep running from where it left off, but boots
clean.

The mod also has a clipboard item, and copy and paste actions are possible
through it. It must be placed in one of the computer's slots to use it.
"Digging" the clipboard (left click) displays its contents.

The computer can provide a mesecons power source, if mesecons is loaded.
It can also send digilines messages, and be given a channel and receive
them if its loaded. These are all done through the computer's api.

The api provides access to the http api if privileges for the mod have been
set. Address must be entered into the mods white list to be accessible.

The computers programming language is lua. Each computer's running environment
is sand-boxed and runs in its own thread. See the docs/api_ref.txt file for
the computer's lua environment.

The programs running in the computer should run in short bursts to not hog
processor. There are 2 functions in the computer's environment that will
yield processing back to the game: os.get_event and os.sleep. If a program
runs longer than 5 seconds without yielding, the program halts with the error
'too long without yielding'. This duration can be changed through the mod
settings.

When a program yields through os.get_event the thread is resumed when an
event is queued. Supported events:

key			key was pressed
char			character following key press, not queued if the ctrl and/or
				alt keys are down.
click			the mouse was clicked on the terminal's display.
wireless		received a wireless message from another computer.
timer			a set timer elapsed
clipboard	the ctrl, alt and v key where pressed with a clipboard in a slot.
disk			floppy disk inserted or ejected.
digilines	a digilines message was received.
mesecons		mesecons power to side was turned on or off


A computers file system starts at a single root "/". Any floppies are
accessed as "/<mount>". The mount will be the label of the floppy or
"floppy_<id>" if the label isn't set.

If a computer is moved it retains its id and hard drive data.

World folder:
Computer and floppy disk data are stored each in its own folder under the
world save folder. The disk contents are directly accessible outside of
the game. If a disk item is removed from the world (permanently) the
disk's contents will likely remain in the world save folder.

The world save folder for an item with a disk will be removed if:
+	The trash item from this mod is used to dispose of it.
+	Calling robot.trash ()
+	The item is blown up.

The path to a computer or robot hard drive's contents:
<minetest path>/worlds/<world>/lwcomputers/computer_<id>

The path to a floppy disk's contents:
<minetest path>/worlds/<world>/lwcomputers/floppy_<id>


The mod supports the following settings:

Restart delay on startup (float)
	How many seconds after mods are loaded to delay restarting running
	computers (reduce processor load at game start).
	Default: 3.0

Terminal horizontal resolution (int)
	Terminal character width.
	Default: 50

Terminal vertical resolution (int)
	Terminal character height.
	Default: 19

Running interval seconds (float)
	Seconds interval between running ticks (time between a computer's
	program yielding and it being resumed).
	Default: 0.1

Maximum no yield seconds (float)
	Maximum number of seconds a computer's tick can run before generating
	a 'too long without yielding' error.
	Default: 5.0

Generate click events (bool)
	Weather the terminal generates click events.
	Default: true

Double click seconds (float)
	The duration of time in seconds from one click to the next on the same
	character for it to be considered a double click. There is no double
	click event, but the click event includes a click count. Successive
	clicks on the same character increase the click count. It is not limited
	to two.
	Default: 0.5

Maximum string.rep length (int)
	The maximum length of a string for the string.rep function. This is
	the given string length by the repeat value.
	Default: 64000

Maximum clipboard content length (int)
	The maximum length of a string for clipboard item. A maximum of 4800
	is imposed.
	Default: 48000

The year the in-game calendar begins (int)
	Computer time values are relative to the beginning of the given year.
	Default: 2000
	* Careful being too ambitious with this year. It may exceed the system
	counter and truncate.

HTTP white list, space separated list (string)
	Space separated white list of permissible addresses to access via HTTP
	calls. The list entries can contain * wild cards.
	eg, *here.com* https://www.there.com*
	Default is an empty list (no permissible addresses)

Maximum hard disk size in bytes (int)
	Maximum total file storage capacity of a computer's hard disk in bytes.
	Default: 1000000

Maximum floppy disk size in bytes (int)
	Maximum total file storage capacity of a floppy disk in bytes.
	Default: 125000

Maximum hard disk items (int)
	Maximum hard disk files and directories allowed.
	Default: 8000

Maximum floppy disk items (int)
	Maximum floppy disk files and directories allowed.

Robot's action delay (float)
	Delay (sleep) in seconds for a robot's action. Enforced minimum of 0.1
	seconds.
	Default: 0.2

Robot's movement delay (float)
	Delay (sleep) in seconds for a robot's movement. Enforced minimum of 0.1
	seconds.
	Default: 0.5

Allow chat (bool)
	Allow chat command. If disabled the command is ignored.
	Default: true

Allow public chat (bool)
	Allow chat command on public machines. If disabled the command is
	ignored.
	Default: true

Use mod on_place (bool)
	Attempt to use mod on_place handler to place nodes, fallback to manual
	placement. If false always uses manual placement.
	Default: true

Alert handler errors (bool)
	Issue errors when handler's of other mods fail.
	Default: true

Awake on event (bool)
	Run the computer to process an event when received when it is unloaded.
	Running continues until the computer's event queue is empty.
	Default: true


** Notes

The form for the terminal contains many elements. This amount is increased
with larger terminal character sizes, and is nearly doubled to support click
events. If the terminal is too sluggish, try reducing the character resolution
and/or disabling click events.


There is a small mod api to integrate other components, such as disks and
clipboards. See docs/mod_api.txt.


Lua disk
--------
The lua disk boots into a lua prompt.

Enter: If the line ends with "\" (must be last character) continues on the
	next line, otherwise runs the entered code.
Backspace: Remove the last character entered.
Escape: Aborts the current line and displays "ABORT" if multi-line input,
	or "ESC" for single line. If the code is multi-lined and pressed on an
	empty line the whole code is aborted and displays "ABORT".
Up arrow: The last code run is added to the current line.
Ctrl+Alt+V: If a clipboard is in a slot its contents are copied to the
	code line. This content can be lengthy. New lines in the content are
	input as is (new line, not as an enter press).


Los disk
--------
The los disk boots to a command prompt. See docs/los_ref.txt


DigiSwitch - Depreciated, see lwcomponents.
==========
* This block is only available if both digilines and mesecons are loaded.

Digiswitches act as both a digilines message target and a digilines cable,
as well as a mesecons power source. They can be placed beside each other
to form a bank, horizontally or vertically.

Right click the digiswitch to give it a channel.

Mesecon power can be delivered at 5 sides of the digiswitch, the adjacent
4 in the (x, z) and above. Around the connector on these sides are a
colored border indicating the side. The sides are named "red", "green",
"blue", "yellow" and "white".

The digilines message sent to the digiswitch dictates the action, "on" or
"off". The action can be followed with the side to act upon, separated by
a space. eg. "on white". If a side is stated only that side is acted upon.
If the side is omitted (or is invalid) all 5 sides are acted upon. If the
side name "switch" is give the power is supplied the same as a mesecons
switch (all horizontal sides, one below, this height and one above).


MoveFloor - Depreciated, see lwcomponents.
=========
* This block is only available if mesecons and mesecons_mvps is loaded.

The MoveFloor block responds to a mesecons power source in the 4 horizontal
directions. If the power source is one higher the MoveFloor moves up to
that height. If the power source is one lower the MoveFloor moves down to
that height. Powering an adjacent block has no effect. The power source
should be turned off before another move or the MoveFloor will oscillate.

Any horizontally adjoining MoveFloor acts as a single block (only one
needs to be powered).

The MoveFloor will move up to 3 blocks stacked on it.

If using a DigiSwitch as the power source use the side name "switch" or
the MoveFloor will not move.


Solid Color Conductors - Depreciated, see lwcomponents.
======================

* These blocks are only defined if mesecons, digilines, and unifieddyes are
loaded.

Provides 2 blocks that can be colored the same as Solid Color Block (with
the air brush) and is both a mesecons and digilines conductor.

The Solid Color Conductor block conducts in the 'default' directions and
the Solid Color Horizontal Conductor only conducts horizontally.


Printer
=======
* This block is only available if digilines is loaded.

Printers can print out pages and assemble them into books. They require
an ink cartridge and paper to print. An ink cartridge prints 200 pages.
If the book button is pressed, any pages in the out tray are assembled into
a book in order of the out tray slots, up to 12 pages. The title of the
book is the title of the first page. If the printer is jammed the Clear
button will clear it. The computer's api has a printer interface which
wraps these messages.

Printers connect to digilines cables. After setting the channel, send
messages to operate.

Query messages:

Query messages query the state of the addressed printer. In response they
send a digilines message, with their own channel, and the queried
information. All responses are as strings.

"ink"
	Responds with the number of pages the ink cartridge can still print.

"paper"
	Responds with the number of sheets of paper in the in tray.

"pages"
	Responds with the number of free out tray slots.

"size"
	Responds with the page character width and height, as "w,h".

"status"
	Responds with:
	"ready" - the printer is ready to print.
	"printing" - the printer is currently printing.
	"no ink" - printer is out of ink.
	"no paper" - printer is out of paper.
	"tray full" - printer output tray is full.

Printing commands:

Printing commands are sent to perform the printing operation.

"start:<title>"
	Takes a page from the in tray to start printing that page. The title
	is set as the page's title. If none is given "untitled" is used. If a
	page is already in the printer (start has already been called) this
	message has no effect. Eg.

	"start:My Page Title"

"color:<forecolor>,<backcolor>"
	Sets the current colors to print in. forecolor and backcolor must be
	numbers, and are consistent with the 'term.colors' table. Eg.

	"color:"..tostring (term.colors.black)..","..tostring (term.colors.white)

position:x,y
	Sets the current character to print. Coordinates are zero based from
	left, top corner. Eg.

	"position:"..tostring (x)..","..tostring (y)

write:str
	Prints a string to the page, at the current position, with the current
	colors. Lines do not wrap, any excess is ignored. The x position is
	updated with the write. Eg.

	"write:Have a nice day."

end
	Ends printing the page and delivers it to the out tray, if it can fit.

To print a page:

"start:<title>"
...
printing operations
...
"end"

Pages print up to their edges, there is no border. To view a page or book
'dig' it (left click).


Digilines Graphical Screens
===========================

* These items are only available if digilines is loaded.

* These items are based on cheapie's digiscreen mod

Full block and panel graphical screens in 16x16 and 32x32 pixel
resolution.

Right click to set digilines channel. The screens are also digilines
conductors, so if using multiple screens for a large display only one
need be connected to a digilines cable.

Send a digilines message to the screen with a table with the pixel data.
The table format is the same as for digiscreens mod, except for the 32x32
screens the table is larger to accommodate every pixel.

The message table has an indexed table for each row, top to bottom. Each
row has an indexed string for each pixel of that row, left to right.
Each string contains the color for that pixel as a 6-digit hex color,
with optional "#" prefix.


For example, this will set every pixel of a 16x16 screen to black with a
one pixel white border.
{
	{ "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF",
	  "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "000000", "000000", "000000", "000000", "000000", "000000", "000000",
	  "000000", "000000", "000000", "000000", "000000", "000000", "000000", "FFFFFF" },
	{ "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF",
	  "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF", "FFFFFF" }
}


Monitors
========

* This items is only available if digilines is loaded.

* This items is based on cheapie's digiscreen mod

The monitors have 7 screen resolutions:
scale		resolution
0.3		3x2
0.6		6x4
1			9x6
2			18x12
3			27x18
4			36x24
5			45x30
The scale is set with a string digilines message "scale:n" where n is one
of the scale values above.

Monitors support 16 colors for both fore-ground and back-ground.

The first time a monitor is right clicked a form displays to set the
digilines channel. After the first time if the display face is right
clicked a touch digilines message is sent with the monitor's channel as
"touch:x,y" where x is the zero based character column and y is the zero
based row, from left, top. Right clicking any other side restores the
channel form, so a following right click will display it. The monitors
are also digilines conductors, so if using multiple monitors for a large
display only one need be connected to a digilines cable.

The world position of the monitor can be gained by sending a string
digilines message as "position". A message will be returned on the
monitors channel as "position:x,y,x".

To set the displayed contents for a monitor send a digilines message to
the monitor as table, with an indexed table for each row top to bottom,
with an indexed number for each character of that row left to right. The
dimensions of the table necessary depends on the set resolution (scale).
The character numbers can be produced with the lwcomputers.format_character
function (see mod_api.txt).

The following will set every character of a 9x6 (scale 1) monitor to
ASCII 0 and black foreground and background colors.

{
	{ 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0, 0, 0, 0, 0 }
}


The following api is exposed:
lwcomputers.format_character (ascii, fg, bg)
lwcomputers.unformat_character (character)
lwcomputers.get_monitor_interface (pos, channel)
lwcomputers.get_multimonitor_interface (pos, width, height, ... )
See docs/mod_api.txt for details.
