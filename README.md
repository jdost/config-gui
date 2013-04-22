# Graphical configurations

These are the configuration files (aka "dot files") for various graphically based
applications (i.e. applications that are associated with X11 based output).  These
all require some form of graphical engine to be running.  Note: this does not 
include any window manager configuration (though it does default to using xmonad
in the `xinitrc` file).  I have a separate `xmonad` repository and also am working
on configuration for the subtle window manager.

## Applications

`X11 dwb archey termite urxvt`

## Setup

Included is a script to setup and manage the configs.  To call it, just run:
`./setup.sh init` to install the applications (Not tested, so errors may occur) and
link the configs in this repo to the home locations.  The linking is the only part
that has been tested and is designed to work with my other config repos.
