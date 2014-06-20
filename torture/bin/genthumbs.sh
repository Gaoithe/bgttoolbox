#!/bin/bash

if [[ "$1" == "" ]] ; then
  echo usage: genthumbs \*.jpg  OR  genthumbs \<directory\(containing jpg files\)\>
  echo indeed, any image supported by ImageMagick should work
  echo generate thumbnails.html and \*Thumb.jpg 
  echo James, May 2003
  read
fi

echo "<html><head><title></title></head><body>" >thumbnails.html

while [[ "$1" != "" ]] ; do
  if [[ -f $1 ]] ; then
    identify $1
    filename=`echo $1|sed "s/\(.*\)\..*/\1/"`
    filepost=`echo $1|sed "s/\(.*\)\.\(.*\)/\2/"`
    thumbnail="${filename}Thumb.$filepost"
    convert -scale 100 $1 $thumbnail
    echo "<a href=$1><img src=$thumbnail></a>" >>thumbnails.html
  elif [[ -d $1 ]] ; then
    cd $1
    ls *.JPG *.jpg *.jpeg *.JPEG *.gif *.png *.GIF *.PNG
    files=`ls *.JPG *.jpg *.jpeg *.JPEG *.gif *.png *.GIF *.PNG`
    genthumbs $files
  else
    echo $1 is neither a file or a directory
    echo don\'t know what to do :\(
    echo hit return to exit
    read
  fi
  shift
done

echo "</body></html>" >>thumbnails.html


#tried png out ... but they end up bigger?
#$ convert -scale 100 DSC00001.JPG DSC00001Thumb.JPG 
#ls -al *Th
#Foobar Wonkaloo@FISHY ~/genthumbtest
#$ ls -al *Thumb*
#-rw-r--r--    1 Foobar W unknown      5671 May  7 22:38 DSC00001Thumb.JPG
#-rw-r--r--    1 Foobar W unknown     15342 May  7 22:35 DSC00001Thumb.png

#Foobar Wonkaloo@FISHY ~
#$ convert -scale 3 dsctest.jpeg out.jpg
#convert: No decode delegate for this image format (dsctest.jpeg).
#$ identify DSC00001.JPG 
#DSC00001.JPG JPEG 640x480+0+0 DirectClass 8-bit 58.4k 0.029u 0:01
# convert -scale 100 DSC00001.JPG out.jpg

