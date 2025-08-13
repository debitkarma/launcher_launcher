# launcher_launcher.sh

This is a launcher for creating/installing apps so your launcher can find them.

It's designed for beginners so they can essentially drag and drop standalone executables (or AppImage files) onto this and it will "install" them relatively easily, and point them to the files they'll want to edit manually.

## Usage

If you double-click this, it should run and install itself in the appropriate spot. It'll ask you if you want to create a shortcut in your home folder. If you do, you can just drag and drop standalone apps or AppImage files and it will (ideally) handle the rest for you.

You could also run it in the command line with the `launcher_launcher` command and then provide any number of paths to executables as arguments for the same effect.

It should also appear in your launcher and depending on which desktop environment you have, you could do the drag and drop thing there.

# Learning Time!!

## What is a Launcher?

Let's say you just downloaded a program of some kind from the internet. Maybe this very script. How do you launch it? You could find it in your file explorer and double click it. You could open the terminal, go to the location of the file and type its name and hit enter. You 

## Installation of Applications on Linux

Beginners seem to get used to their launchers on whatever window manager or desktop environment they're on. Grabbing random executables or scripts off of the internet is one thing, and being able to use them via GUI is another.

Most launchers need to find a `.desktop` file associated with a program in order to find, categorize, and launch it. The main resource for creating these is in the [Arch User Wiki (as with many things)](https://wiki.archlinux.org/title/Desktop_entries). (Yes, it's in the *Arch* User Wiki, but it's not limited to Arch - there's a lot of great info there that's application across distros of Linux, so dive in beginners! Man pages get old fast.) Another useful site with options and explainers of things is [the Freedesktop.org site](https://specifications.freedesktop.org/desktop-entry-spec/latest/).

Generally, if you were to do this manually, what you want to do is:

1. Find the executable program you downloaded and want to see in your launcher.

2. (Optional but recommended) Move it to the `~/.local/bin/` directory. Why? Because it's in your PATH, which is where the command line looks for commands that are programs. The particular folder `~/.local/bin/` is where random programs for your user are generally found by convention. It's a loose standard, so I usually recommend following it. It's not strictly necessary.

3. (Optional) Find a suitable icon for this program, or a pick a suitable system icon.

4. Create a launcher file in `~/.local/share/applications/` for your application. Refer the Arch User Wiki link above for specifics, but you want to create a text file that's named `Program_Name.desktop` in this folder. This file should have contents that are outlined for your convenience below (or you can just look at the Arch User Wiki link above).

## Anatomy of a .desktop File

```
[Desktop Entry]                              # Line number 0
Version=1.0                                  # 1
Type=Application                             # 2
Name=Launcher Launcher                       # 3
Comment=Installs other standalone programs   # 4
Exec=$INSTALL_PATH %U                        # 5
Icon=utilities-terminal                      # 6
Terminal=false                               # 7
Categories=Utility                           # 8
```

1. Markup, Line 0: This marks the file as a Desktop Entry for launchers to read.
2. Version, Line 1: This is where you can put the version number of the program. Most command-line programs can be run with `-v` or `--version` to find this out, or you can look at the About page in the Help menu for many graphical applications. Or mark it from the page you downloaded the file from!
3. Type, Line 2: This descript the type of executable this is.
4. Name, Line 3: This is the name of the program, and is what you would type to search your launcher by text
5. Comment, Line 4: This is a short description of what the program is or does
6. Exec, Line 5: This is the path to the executable file itself. If you installed it in the conventional place, you'd write something like `~/.local/bin/program_name`, and if not, you'd have to find where the executable lives. You can find it in a File Manager window, right click, and usually you'll see an option to copy path. Paste that here.
    * Note that there's a character afterwards! The `%U` specifies that the program can take a list of URLs as an argument, but you can play with this by [checking a reference for other options](https://specifications.freedesktop.org/desktop-entry-spec/latest/exec-variables.html). A `%u` is for a single URL.
    * `%F` is a useful alternative, which designates a list of files. `%f` is for a single file.
7. Icon, Line 6: This is either:
    1. A path to the icon file you want to see the program have in your launcher
    2. The name of a system-level icon for this program, which you might find in:
        * `/usr/share/icons` (where most sytem icons are installed, and themes can be found)
        * `/usr/share/applications` (in the folder we're in!)
        * `~/.local/share/icons` (where you can place your own for your user)

  *DO NOTE* that if you don't include some type of icon, the program may not display correctly in your launcher.

8. CLI App, Line 7: Whether or not this program needs to launch in a terminal window, which can be useful for command-line only programs.
9. Category list, Line 8: Read the above resources, particularly the Freedesktop.org page, to find out more.

