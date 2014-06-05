
function goto () {
   echo P=$1 OLD=$OLD
   #apt-cache -f search $1
   sudo apt-get install $P=$OLD
}

