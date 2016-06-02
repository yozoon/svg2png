# svg2png - SVG to Android-PNG converter
*Created by yozoon (2016)*

Android Studio does have a built in SVG import tool for the creation of drawables or mipmaps, 
but this tool didn't cope well with SVG files which contained gradients (almost all SVG files
according to the Android Icon design Guidelines). To avoid the hassle of exporting the PNGs for
each pixel density manually (and copying them in the right folder in my Android Project) I wrote 
this script, which does all of this automatically. 

## Prerequisites
* Inkscape has to be installed and accessible via the command line
* Android Studio Project directory structure (otherwise the scipt won't find the resource 
  directories.

## PNG sizes

| NAME    | SIZE (px)  |
| ------- | -----------|
| MDPI    | 48 x 48    |
| HDPI    | 72 x 72    |
| XHDPI   | 96 x 96    |
| XXHDPI  | 144 x 144  |
| XXXHDPI | 192 x 192  |

## Usage
### Parameters
-i <path>  input file: specifies the path to the input SVG file
-o <path>  output directory: specifies the path to the Android Studio Project root directory.
-n <name>  name: the name to be used for the generated 
-m         mipmap: use this parameter to export the PNGs to the mipmap folder of the project's 
           resources
-d         drawable: default. Create PNGs in the drawable folder of the project's resources.
           if -m and -d are supplied, the last parameter will be used.

### Example
Create the PNG files based on icon.svg and save them to the mipmap folders:
./svg2png.sh  -i /path/to/icon.svg -o /path/to/AndroidStudioProject/root/ -n name_to_be_used -m
