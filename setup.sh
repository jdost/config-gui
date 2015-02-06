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
   linkIfNot archey/archey3.cfg $XDG_CONFIG_HOME/archey3.cfg
   linkIfNot termite $XDG_CONFIG_HOME/termite
   linkIfNot pentadactyl $XDG_CONFIG_HOME/pentadactyl
   linkIfNot dunst $XDG_CONFIG_HOME/dunst
} # }}}
####################################################################################
# Install - Arch {{{
aurGet() {
   local END_DIR=$PWD
   cd $HOME/.local/aur/
   ABBR=${1:0:2}
   wget http://aur.archlinux.org/packages/$ABBR/$1/$1.tar.gz
   tar -xf "$1.tar.gz"
   rm "$1.tar.gz"
   cd "$1"
   makepkg -si
   cd $END_DIR
}

run_pacman() {
   sudo pacman -Sy --needed wget

   sudo pacman -S --needed xorg-server
   sudo pacman -S --needed rxvt-unicode
   aurGet urxvt-perls
   sudo pacman -S --needed xorg-xmodmap xorg-xrdb
   aurGet xcape-git
   sudo pacman -S --needed feh
   aurGet xflux
   aurGet archey3
   aurGet gohufont
   aurGet ttf-anonymous-pro
   #aurGet dwb-hg
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
      command -v pacman >/dev/null 2>&1  && build_arch
      command -v apt-get >/dev/null 2>&1 && build_ubuntu
      link
      ;;
   'update')
      command -v pacman >/dev/null 2>&1  && update_arch
      command -v apt-get >/dev/null 2>&1 && update_ubuntu
      link
      ;;
   'link')
      link
      ;;
esac
