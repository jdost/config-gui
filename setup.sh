#/bin/sh

if [ -z "$XDG_CONFIG_HOME" ]; then
   export XDG_CONFIG_HOME=$HOME/.config
fi

####################################################################################
# Linking {{{
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
   linkIfNot dwb $XDG_CONFIG_HOME/dwb
   linkIfNot archey/archey3.cfg $XDG_CONFIG_HOME/archey3.cfg
   linkIfNot termite $XDG_CONFIG_HOME/termite
} # }}}
####################################################################################
# Install - Arch {{{
aurGet() {
   cd $HOME/.aur/
   ABBR=${1:0:2}
   wget http://aur.archlinux.org/packages/$ABBR/$1/$1.tar.gz
   tar -xf "$1.tar.gz"
   rm "$1.tar.gz"
   cd "$1"
   if makepkg > /dev/null; then
      sudo pacman -U "$(ls -t --file-type | grep tar | head -1)"
   fi
}

run_pacman() {
   sudo pacman -Sy

   sudo pacman -S --needed urxvt
   aurGet urxvt-perls
   sudo pacman -S --needed xmodmap
   sudo pacman -S --needed feh
   aurGet xflux
   aurGet archey3
   aurGet dwb-hg
   #aurGet termite-git
}

build_arch() {
   run_pacman
   mkdir $HOME/.fonts
}

update_arch() {
   git pull
   run_pacman
} # }}}
####################################################################################
# Install - Ubuntu {{{
run_apt() {
   sudo apt-get update
   sudo apt-get upgrade

   sudo apt-get install urxvt
   sudo apt-get install xmodmap
   sudo apt-get install feh
}

build_ubuntu() {
   run_apt
   mkdir $HOME/.fonts
}

update_ubuntu() {
   git pull
   run_apt
} # }}}
####################################################################################

if [ -z "${1}" ]; then
   echo "Missing action. Syntax: ${0} [command]"
   echo "  Options:"
   echo "    init    -- installs associated programs and creates all symlinks"
   echo "    update  -- updates packages associated with repo, creates any new symlinks"
   echo "    link    -- create symlinks for files (will not overwrite existing files"
   echo ""
   exit 1
fi
case "${1}" in
   'init')
      type pacman > /dev/null  && build_arch
      type apt-get > /dev/null && build_ubuntu
      link
      ;;
   'update')
      type pacman > /dev/null && update_arch
      type apt-get > /dev/null && update_ubuntu
      link
      ;;
   'link')
      link
      ;;
esac
