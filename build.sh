#!/bin/sh

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

JPEG6=YES
JPEG8=YES
TIFF=NO
HDF=NO
HDF5=NO
OpenJPEG=NO
PNG=NO
PDF=NO
PROJ4=NO
ECW=NO
GDAL=NO
IM=NO

DEPLOY=10.8

if [ $JPEG6 = "YES" ]; then
# Build libjpeg 6.
INSTALL=osxinstall lib2framework JPEG org.ijg.openjpeg 6 archives/jpegsrc.v6b.tar.gz --target=install-lib --deploy=$DEPLOY
fi

if [ $JPEG8 = "YES" ]; then
# Build libjpeg 8.
lib2framework JPEG org.ijg.openjpeg 8 archives/jpegsrc.v8b.tar.gz --enable-shared --deploy=$DEPLOY
fi

if [ $TIFF = "YES" ]; then
# Build libtiff 3.
export CFLAGS=-DHAVE_APPLE_OPENGL_FRAMEWORK
lib2framework TIFF org.osgeo.tif 3 archives/tiff-3.9.5.tar.gz --with-jpeg-include-dir=$HOME/Library/Frameworks/JPEG.framework/Versions/Current/unix/include --with-jpeg-lib-dir=$HOME/Library/Frameworks/JPEG.framework/Versions/Current/unix/lib --deploy=$DEPLOY
export CFLAGS=
fi

if [ $HDF = "YES" ]; then
# Build HDF.
lib2framework HDF org.hdfgroup.hdf 4 archives/hdf-4.2.5.tar.gz --enable-production --enable-shared --disable-netcdf --disable-fortran --with-jpeg=/Users/jdaniel/Library/Frameworks/JPEG.framework/Versions/6/unix/include,/Users/jdaniel/Library/Frameworks/JPEG.framework/Versions/6/unix/lib --deploy=$DEPLOY
fi

if [ $HDF5 = "YES" ]; then
# Build HDF5.
lib2framework HDF org.hdfgroup.hdf 5 archives/hdf5-1.8.5-patch1.tar.gz --deploy=$DEPLOY
fi

# OpenJPEG not working right now.
if [ $OpenJPEG = "YES" ] ; then
# Extract OpenJPEGv2
#rm -Rf openjpegv2
#unzip archives/openjpegv2.zip

# Patch OpenJPEGv2
#patch -d openjpegv2 < archives/openjpegv2.patch

# Build OpenJPEGv2
#PREFIX=$HOME/Library/Frameworks/OpenJPEG.framework/Versions/2.0/unix lib2framework OpenJPEG org.openjpeg.openjpeg 2.0 openjpegv2 -f Makefile.osx
lib2framework OpenJPEG org.openjpeg.openjpeg 2.1 archives/openjpeg-2.1.0.tar.gz -f Makefile.osx --deploy=$DEPLOY
#install_name_tool -id $HOME/Library/Frameworks/OpenJPEG.framework/Versions/2.0/unix/lib/libopenjpeg-2.2.0.0.dylib $HOME/Library/Frameworks/OpenJPEG.framework/OpenJPEG
#rm -Rf openjpegv2
fi

if [ $PNG = "YES" ]; then
# Build libpng.
lib2framework PNG org.libpng.png 1 archives/libpng-1.4.5.tar.gz --deploy=$DEPLOY
fi

# Poppler not working right now.
if [ $PDF = "YES" ]; then
# Extract Poppler
rm -Rf poppler-0.18.0.tar.gz
tar zxvf archives/poppler-0.18.0.tar.gz

# Extract the data too.
rm -Rf poppler-data-0.4.5.tar.gz
tar zxvf archives/poppler-data-0.4.5.tar.gz

# Build the MacOS X PROJ.4 framework.
lib2framework Poppler org.freedesktop.poppler 0 poppler-0.18.0 --enable-xpdf-headers --target=datadir=$HOME/Library/Frameworks/Poppler.framework/Versions/0/unix --deploy=$DEPLOY
rm -Rf poppler-0.18.0
fi

if [ $PROJ4 = "YES" ]; then
# Extract PROJ.4.
rm -Rf proj-4.7.0
tar zxvf archives/proj-4.7.0.tar.gz

# Get more NAD data.
unzip -d proj-4.7.0/nad archives/proj-datumgrid-1.5.zip
unzip -d proj-4.7.0/nad archives/hpgn_ntv2.zip
unzip -d proj-4.7.0/nad archives/chenyx06antv2.zip

# Build the MacOS X PROJ.4 framework.
lib2framework PROJ org.maptools.proj 4 proj-4.7.0 --deploy=$DEPLOY
rm -Rf proj-4.7.0
fi

# ECW not updated or tested for a long time.
if [ $ECW = "YES" ]; then
# Build ECW.
rm -Rf libecwj2-3.3
unzip archives/libecwj2-3.3-2006-09-06.zip
cd libecwj2-3.3
patch -p1 < ../archives/libecwj2-3.3.patch.txt
cd ..
lib2framework ECW com.intergraph.geospatial 3 libecwj2-3.3 --enable-shared --deploy=$DEPLOY
fi

if [ $GDAL = "YES" ]; then
# Build GDAL.
lib2framework GDAL org.gdal.gdal 1.11.1 archives/gdal-1.11.1.tar.gz --enable-static=no --with-static-proj4=$HOME/Library/Frameworks/PROJ.framework/unix  --deploy=$DEPLOY
fi

# IM not updated or tested for a long time.
if [ $IM = "YES" ]; then
# Extract ImageMagick.
rm -Rf ImageMagick-6.6.8-4
tar zxvf archives/ImageMagick.tar.gz
export CFLAGS=-I$HOME/Library/Frameworks/TIFF.framework/unix/include
export LDFLAGS=-I$HOME/Library/Frameworks/TIFF.framework/unix/lib
# Build ImageMagick.
lib2framework ImageMagick org.imagemagick.imagemagick 6.6.8 ImageMagick-6.6.8-4  --deploy=$DEPLOY
export CFLAGS=
export LDFLAGS=
fi

