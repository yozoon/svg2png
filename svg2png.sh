#!/bin/bash
####################################################################################################
# = SVG to Android-PNG converter =                                                                 #
# Created by yozoon (2016)                                                                         #
# Android Studio does have a built in SVG import tool for the creation of drawables or mipmaps,    #
# but this tool didn't cope well with SVG files which contained gradients (almost all SVG files    #
# according to the Android Icon design Guidelines). To avoid the hassle of exporting the PNGs for  #
# each pixel density manually (and copying them in the right folder in my Android Project) I wrote #
# this script, which does all of this automatically.                                               #
#                                                                                                  #
# == Prerequisites ==                                                                              #
# * Inkscape has to be installed and accessible via the command line                               #
# * Android Studio Project directory structure (otherwise the scipt won't find the resource        #
#   directories.                                                                                   #
#                                                                                                  #
# == PNG sizes ==                                                                                  #
#   NAME      SIZE (px)                                                                            #
# * MDPI    - 48 x 48                                                                              #
# * HDPI    - 72 x 72                                                                              #
# * XHDPI   - 96 x 96                                                                              #
# * XXHDPI  - 144 x 144                                                                            #
# * XXXHDPI - 192 x 192                                                                            #
#                                                                                                  #
# == Usage ==                                                                                      #
# === Parameters ===                                                                               #
# -i <path>  input file: specifies the path to the input SVG file                                  #
# -o <path>  output directory: specifies the path to the Android Studio Project root directory.    #
# -n <name>  name: the name to be used for the generated                                           #
# -m         mipmap: use this parameter to export the PNGs to the mipmap folder of the project's   #
#            resources                                                                             #
# -d         drawable: default. Create PNGs in the drawable folder of the project's resources.     #
#            if -m and -d are supplied, the last parameter will be used.                           #
#                                                                                                  #
# === Example ===                                                                                  #
# Create the PNG files based on icon.svg and save them to the mipmap folders:                      #
# ./svg2png.sh  -i /path/to/icon.svg -o /path/to/AndroidStudioProject/root/ -n name_to_be_used -m  #
#                                                                                                  # 
####################################################################################################

echo ""
echo " #####################################################"
echo " #           SVG to Android-PNG converter            #"
echo " #####################################################"
echo ""

usage="
$(basename "$0") [-h] [-i <path>] [-o <path>] [-n <name>] [-m] [-d]
Program to automatically convert and save SVG graphics to multi DPI 
Android PNG files.

where:
    -h  shows this help text
    -i  specifies the path to the SVG file to be converted 
    -o  sets the Android Studio Project root directory for 
        output path instanciation
    -n  sets the name to be used for the generated PNG files
    -m  tells the program to save the PNG files to the 
        mipmap resource folders
    -d  tells the program to save the PNG files to the 
        drawable resource folders"

# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Initialize project variables
input_file=""
project_root=""
name=""
drawable=true

while getopts "h?i:o:n:md" opt; do
    case "$opt" in
    h|\?)
        echo "$usage"
        exit 0
        ;;
    i)  input_file=$OPTARG
        ;;
    o)  project_root=$OPTARG
        ;;
    n)  name=$OPTARG
        ;;
    m)  drawable=false
        ;;
    d)  drawable=true
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

####################################################################################################
# Check if the input file exists                                                                   #
# (by default zenity lists files of working directory, if dialog is cancelled)                     #
####################################################################################################
if [ -z "$input_file" ]; then
	echo "Input file ... not specified"
	echo "$usage"
	exit 0;
elif [ ! -f "$input_file" ]; then
	echo "Input file ... not found"
	exit 0;
fi

# Check if the input filetype is .svg
suffix="${input_file##*.}"
if [ "$suffix" != "svg" ]; then
	echo "Input file ... wrong filetype"
	exit 0;
fi

echo "Input file ... ok"

####################################################################################################
# Check parameters and decide if we should use the drawable or the mipmap folders                  #
####################################################################################################
if [ "$drawable" = true ]; then
	imgdirs=("drawable-mdpi" "drawable-hdpi" "drawable-xhdpi" "drawable-xxhdpi" "drawable-xxxhdpi")
	echo "Mode ... drawable"
else
	imgdirs=("mipmap-mdpi" "mipmap-hdpi" "mipmap-xhdpi" "mipmap-xxhdpi" "mipmap-xxxhdpi")
	echo "Mode ... mipmap"
fi

resdir="app/src/main/res"
pngdir=$project_root$resdir

####################################################################################################
# Check if the output resource directories exist                                                   #
####################################################################################################
for i in {0..4}
do
	if [ ! -d "$pngdir/${imgdirs[$i]}" ]; then
		echo "Please select the root directory of you Android Studio Project."
		exit 0;
	fi
done

echo "Output directory ... ok"

####################################################################################################
# Either use the supplied name as filename for the output files,                                   #
# or use the svg filename for the PNGs.                                                            #
####################################################################################################

if [[ $name == *[\|/\\?\*\<\":\>]* ]]
then
  echo "Please check the filename for unsupported characters. Script aborted."
  exit 0;
fi

if [ ! -z "$name" ]; then
	filename=$name".png"
else
	filename="${filename##*/}"  # Get the part after the last slash
	filename="${input_file%.*}" # Get the part before the last dot
	filename=$filename".png"    # Append new file ending
fi

####################################################################################################
# Check if the PNG files already exist                                                             #
####################################################################################################
present=false
for i in {0..4}
do
	if [ -f "$pngdir/${imgdirs[$i]}/$filename" ]; then
		present=true
	fi
done

if [ "$present" = true ]; then
	echo "PNG files already exist. Replace them? (y/n)"
	read answer
	if [ "$answer" != "y" ]; then
		echo "No changes will be applied."
		exit 0;
	else
		echo "Replacing old Android PNG files..."
	fi
else
	echo "Creating new Android PNG files..."
fi

####################################################################################################
# This point of the script is only reached, if all checks are passed.                              #
####################################################################################################
echo "Filename: $filename"
echo ""

# mdpi
echo "[MDPI]"
pngname=$pngdir/${imgdirs[0]}/$filename
inkscape -z -e "$pngname" -w 48 -h 48 "$input_file"
echo ""

# hdpi
echo "[HDPI]"
pngname=$pngdir/${imgdirs[1]}/$filename
inkscape -z -e "$pngname" -w 72 -h 72 "$input_file"
echo ""

# xhdpi
echo "[XHDPI]"
pngname=$pngdir/${imgdirs[2]}/$filename
inkscape -z -e "$pngname" -w 96 -h 96 "$input_file"
echo ""

# xxhdpi
echo "[XXHDPI]"
pngname=$pngdir/${imgdirs[3]}/$filename
inkscape -z -e "$pngname" -w 144 -h 144 "$input_file"
echo ""

# xxxhdpi
echo "[XXXHDPI]"
pngname=$pngdir/${imgdirs[4]}/$filename
inkscape -z -e "$pngname" -w 192 -h 192 "$input_file"
echo ""

echo "Conversion done. Have a nice day! :)"