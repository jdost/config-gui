#/bin/sh

set -euo pipefail

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

show_help() {
   cat <<-HELP
Setup script for general graphical applications

USAGE: ${0} [command]

commands:
   init
   update
   link
HELP
}

linkIfNot() {
   if [ -e $1 ]; then
      if [ ! -e $2 ]; then
         echo "Linking " $1
         ln -s $PWD/$1 $2
      fi
   elif [ ! -e $2 ]; then
      echo "Linking " $1
      ln -s $PWD/$1 $2
   fi
}

link() {
   # Shell/Environment
   linkIfNot environment $HOME/.local/environment/graphical
   linkIfNot X11 $XDG_CONFIG_HOME/X11
   linkIfNot X11/xinitrc $HOME/.xinitrc

   # Apps
   linkIfNot dunst $XDG_CONFIG_HOME/dunst
   linkIfNot deadd $XDG_CONFIG_HOME/deadd
   linkIfNot picom $XDG_CONFIG_HOME/picom
   linkIfNot alacritty $XDG_CONFIG_HOME/alacritty
   linkIfNot rofi $XDG_CONFIG_HOME/rofi

   # Daemons
   mkdir -p $XDG_CONFIG_HOME/supervisord/config.d/
   linkIfNot supervisor.d/picom.conf $XDG_CONFIG_HOME/supervisord/config.d/compositor.conf
   #linkIfNot supervisor.d/dunst.conf $XDG_CONFIG_HOME/supervisord/config.d/notifications.conf
   linkIfNot supervisor.d/deadd.conf $XDG_CONFIG_HOME/supervisord/config.d/notifications.conf
}

install() {
   # X11 requirements
   sudo pacman -S --needed \
      xorg-server xorg-xinit \
      xorg-xmodmap xorg-xrdb
   # Apps
   #sudo pacman -S --needed rxvt-unicode
   sudo pacman -S --needed alacritty
   sudo pacman -S --needed feh
}

update() {
   git pull
}

case "${1:-}" in
   'init')
      install
      link
      ;;
   'update')
      update
      link
      ;;
   'link')
      link
      ;;
   *)
      show_help
      exit
      ;;
esac
