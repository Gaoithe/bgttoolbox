#!/bin/bash

if [[ "$1" == "" ]] ; then
  echo usage: genthumbs \*.jpg  OR  genthumbs \<directory\(containing jpg files\)\>
  echo indeed, any image supported by ImageMagick should work
  echo generate thumbnails.html and \*Thumb.jpg and bigindex.html
  echo James, May 2003
  read
fi

echo "<html><head><title>thumbs</title></head><body>" >thumbnails.html
echo "<html><head><title>big pics</title></head><body>" >bigindex.html

while [[ "$1" != "" ]] ; do
  if [[ -f $1 ]] ; then
    # identify - describe an image or image sequence (part of ImageMagick)
    identify $1
    filename=`echo $1|sed "s/\(.*\)\..*/\1/"`
    filepost=`echo $1|sed "s/\(.*\)\.\(.*\)/\2/"`
    thumbnail="${filename}Thumb.$filepost"
    if [[ -f $thumbnail ]] ; then
      # we've already got a thumbnail
      echo already have $thumbnail \(not regenerating\)
    else
      # convert - convert an image or sequence of images (part of ImageMagick)
      convert -scale 100 $1 $thumbnail
    fi
    echo "<a href=$1><img src=$thumbnail></a>" >>thumbnails.html
    echo "<br><img src=$1>" >>bigindex.html
  elif [[ -d $1 ]] ; then
    cd $1
    ls *.JPG *.jpg *.jpeg *.JPEG *.gif *.png *.GIF *.PNG
    files=`ls *.JPG *.jpg *.jpeg *.JPEG *.gif *.png *.GIF *.PNG`
    $0 $files
  else
    echo $1 is neither a file or a directory
    echo don\'t know what to do :\(
    echo hit return to exit
    read
  fi
  shift
done

echo "</body></html>" >>thumbnails.html
echo "</body></html>" >>bigindex.html

pwd=`pwd`
cmd="mozilla file://localhost${pwd}/thumbnails.html"
echo $cmd
cmd="mozilla file://localhost${pwd}/bigindex.html"
echo $cmd
cmd ='firefox -remote "openURL(file://localhost/home/jamesc/pic/SheilaHouseWarmingBirthday/thumbnails.html)"'
echo $cmd
system $cmd

exit;

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

#convert -rotate 90 
# ls *.jpg |sed "s/\(.*\)/convert -rotate 90 \1 \1/"
#convert -rotate 90 dsc00041.jpg dsc00041.jpg
#convert -rotate 90 dsc00041Thumb.jpg dsc00041Thumb.jpg
#  convert -scale 320 dsc00049EQCU.jpg dsc00049EQCUThumb.jpg 

#convert -rotate 90 dsc00028.jpg dsc00028.jpg 
#convert -rotate 90 dsc00028Thumb.jpg dsc00028Thumb.jpg 
#convert -rotate 90 dsc00029.jpg dsc00029.jpg 
#convert -rotate 90 dsc00029Thumb.jpg dsc00029Thumb.jpg 
#convert -rotate 90 dsc00032.jpg dsc00032.jpg 
#convert -rotate 90 dsc00032Thumb.jpg dsc00032Thumb.jpg 
#convert -rotate 90 dsc00033.jpg dsc00033.jpg 
#convert -rotate 90 dsc00033Thumb.jpg dsc00033Thumb.jpg 
#convert -rotate 90 dsc00034.jpg dsc00034.jpg 
#convert -rotate 90 dsc00034Thumb.jpg dsc00034Thumb.jpg 
#convert -rotate 90 dsc00039.jpg dsc00039.jpg 
#convert -rotate 90 dsc00039Thumb.jpg dsc00039Thumb.jpg 
#convert -rotate 90 dsc00051.jpg dsc00051.jpg 
#convert -rotate 90 dsc00051Thumb.jpg dsc00051Thumb.jpg 

#convert -rotate 270 dsc00050.jpg dsc00050.jpg 
#convert -rotate 270 dsc00050Thumb.jpg dsc00050Thumb.jpg 



#  convert -scale 320 dsc00049EQCU.jpg dsc00049EQCUThumb.jpg 
#convert -resize 320x320 dsc00052.jpg AfterDrink.jpg


#convert -rotate 90 AfterDrink.jpg AfterDrink90.jpg
#convert -rotate 135 AfterDrink.jpg AfterDrink135.jpg
#convert -rotate 180 AfterDrink.jpg AfterDrink180.jpg
#convert -rotate 225 AfterDrink.jpg AfterDrink225.jpg
#convert -rotate 270 AfterDrink.jpg AfterDrink270.jpg
#convert -rotate 315 AfterDrink.jpg AfterDrink315.jpg


#animate AfterDrink.jpg AfterDrink45.jpg  AfterDrink90.jpg  AfterDrink135.jpg  AfterDrink180.jpg  AfterDrink225.jpg  AfterDrink270.jpg  AfterDrink315.jpg  

# animate -delay 500 -size 400x400+40 AfterDrink.jpg -size 400x400 AfterDrink45.jpg  AfterDrink90.jpg  AfterDrink135.jpg  AfterDrink180.jpg  AfterDrink225.jpg  AfterDrink270.jpg  AfterDrink315.jpg  



convert AfterDrink.jpg AfterDrink.gif
convert AfterDrink45.jpg AfterDrink45.gif
convert AfterDrink90.jpg AfterDrink90.gif
convert AfterDrink135.jpg AfterDrink135.gif
convert AfterDrink180.jpg AfterDrink180.gif
convert AfterDrink225.jpg AfterDrink225.gif
convert AfterDrink270.jpg AfterDrink270.gif
convert AfterDrink315.jpg AfterDrink315.gif


whirlgif -o AfterDrinkR.gif AfterDrink.gif AfterDrink45.gif  AfterDrink90.gif  AfterDrink135.gif  AfterDrink180.gif  AfterDrink225.gif  AfterDrink270.gif  AfterDrink315.gif  

