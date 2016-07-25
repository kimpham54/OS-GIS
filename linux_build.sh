#!/bin/sh

export PREFIX=$HOME/Library/Frameworks

FREETYPE=NO
FONTCONFIG=NO
EXPAT=NO
PCRE=NO
KML=NO
MYSQL=NO
SQLITE=NO
ODBC=NO
FREEXL=NO
JPEG6=NO
JPEG8=NO
TIFF=NO
HDF=NO
HDF5=NO
OpenJPEG=NO
PNG=NO
PDF=NO
NetCDF=NO
PROJ4=NO
ECW=NO
GEOS=NO
SPATIALITE=NO
GDAL=YES
IM=NO

DEPLOY=10.11

if [ $FREETYPE = "YES" ]; then
# Build FreeType. This is fragile.
rm -Rf test
cp -R freetype-2.6.3 test
cd test
./configure --prefix=$HOME/unix
make
make install
cd ..
rm -Rf test
fi

if [ $FONTCONFIG = "YES" ]; then
# Build FontConfig. This is fragile.
rm -Rf test
cp -R fontconfig-2.11.1 test
cd test
autoreconf
./configure --prefix=$HOME/unix
automake
make
make install
cd ..
rm -Rf test
fi

if [ $EXPAT = "YES" ]; then
# Build Expat 6.
lib2framework Expat net.sourceforge.expat 2.1.1 expat-2.1.1 --deploy=$DEPLOY
fi

if [ $PCRE = "YES" ]; then
# Build PCRE 8.38.
lib2framework PCRE org.pcre.pcre 8.38 pcre-8.38 --deploy=$DEPLOY
fi

if [ $KML = "YES" ]; then
# Build libjpeg 6.
lib2framework KML com.google.kml 2.2 libkml --deploy=$DEPLOY
fi

if [ $MYSQL = "YES" ]; then
# Build MySQL connector.
lib2framework MySQL com.mysql.connector 6.1.6 mysql-connector-c-6.1.6-src --deploy=$DEPLOY 
fi

if [ $SQLITE = "YES" ]; then
# Build libjpeg 6.
lib2framework SQLite org.sqlite.sqlite 3.13 sqlite-autoconf-3130000 --deploy=$DEPLOY
fi

if [ $ODBC = "YES" ]; then
# Build libjpeg 6.
lib2framework ODBC org.unixodbc.odbc 2.3.4 unixODBC-2.3.4 --deploy=$DEPLOY
fi

if [ $FREEXL = "YES" ]; then
# Build libjpeg 6.
lib2framework FreeXL it.gaia-gis 1.0.2 freexl-1.0.2 --deploy=$DEPLOY
fi

if [ $OPENMPI = "YES" ]; then
# Build OpenMPI. This is fragile.
rm -Rf test
cp -R openmpi-1.10.2 test
cd test
./configure CC=clang CXX=clang++ --prefix=$HOME/unix
make
make install
cd ..
rm -Rf test
fi

if [ $JPEG6 = "YES" ]; then
# Build libjpeg 6.
INSTALL=osxinstall lib2framework JPEG org.ijg.openjpeg 6 jpeg-6b --target=install-lib --deploy=$DEPLOY
fi

if [ $JPEG8 = "YES" ]; then
# Build libjpeg 9.
lib2framework JPEG org.ijg.openjpeg 9 jpeg-9b --enable-shared --deploy=$DEPLOY
fi

if [ $TIFF = "YES" ]; then
# Build libtiff 4.
lib2framework TIFF org.osgeo.tif 4 tiff-4.0.6 --with-jpeg-include-dir=$PREFIX/JPEG.framework/Versions/Current/unix/include --with-jpeg-lib-dir=$PREFIX/JPEG.framework/Versions/Current/unix/lib --deploy=$DEPLOY --lib=libtiff.5.dylib
fi

if [ $HDF = "YES" ]; then
# Build HDF.
lib2framework HDF org.hdfgroup.hdf 4 hdf-4.2.11 --enable-production --enable-shared --disable-netcdf --disable-fortran --with-jpeg=$PREFIX/JPEG.framework/Versions/6/unix/include,$PREFIX/JPEG.framework/Versions/6/unix/lib --deploy=$DEPLOY
fi

if [ $HDF5 = "YES" ]; then
# Build HDF5.
lib2framework HDF org.hdfgroup.hdf 5 hdf5-1.8.17 --deploy=$DEPLOY
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
lib2framework OpenJPEG org.openjpeg.openjpeg 2.1.1 openjpeg --deploy=$DEPLOY
#install_name_tool -id $HOME/Library/Frameworks/OpenJPEG.framework/Versions/2.0/unix/lib/libopenjpeg-2.2.0.0.dylib $HOME/Library/Frameworks/OpenJPEG.framework/OpenJPEG
#rm -Rf openjpegv2
fi

if [ $PNG = "YES" ]; then
# Build libpng.
lib2framework PNG org.libpng.png 1 libpng-1.6.21 --deploy=$DEPLOY
fi

if [ $NetCDF = "YES" ]; then
# Build NetCDF.
export LDFLAGS="-L$PREFIX/HDF.framework/Versions/5/unix/lib -L$PREFIX/HDF.framework/Versions/4/unix/lib"
export CPPFLAGS="-I$PREFIX/HDF.framework/Versions/5/unix/include -I$PREFIX/HDF.framework/Versions/4/unix/include"
lib2framework NetCDF edu.ucar.netcdf 4 netcdf-4.4.0 --deploy=$DEPLOY
export LDFLAGS=
export CPPFLAGS=
fi

# Poppler not working right now.
if [ $PDF = "YES" ]; then
# Build the MacOS X PROJ.4 framework.
LIBJPEG_CFLAGS=-I$PREFIX/JPEG.framework/Versions/6/unix/include LDFLAGS="-L$PREFIX/JPEG.framework/Versions/6/unix/lib" lib2framework Poppler org.freedesktop.poppler 0.31.0 poppler-0.31.0 --enable-xpdf-headers
cd poppler-data-0.4.7
make install datadir=$PREFIX/JPEG.framework/Versions/6/unix
cd ..
fi

if [ $PROJ4 = "YES" ]; then
# Copy PROJ.4.
cp -R proj.4 buildproj.4

# Get more NAD data.
cp proj-datumgrid-1.5/* buildproj.4/nad

# Build the MacOS X PROJ.4 framework.
lib2framework PROJ org.maptools.proj 4 buildproj.4 --deploy=$DEPLOY
rm -Rf buildproj-4.7.0
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

if [ $GEOS = "YES" ]; then
# Build GEOS 3.5.
lib2framework GEOS org.osgeo.geos 3.5 geos-3.5.0 --deploy=$DEPLOY
fi

if [ $SPATIALITE = "YES" ]; then
# Build Spatialite 4.3.0a.
CPPFLAGS="-I$PREFIX/PROJ.framework/Versions/Current/unix/include -I/$PREFIX/GEOS.framework/Versions/Current/unix/include -I/$PREFIX/FreeXL.framework/Versions/Current/unix/include" LDFLAGS="-L$PREFIX/PROJ.framework/Versions/Current/unix/lib -L$PREFIX/FreeXL.framework/Versions/Current/unix/lib" lib2framework Spatialite it.gaia-gis.spatialite 4.3.0 libspatialite-4.3.0a --with-geosconfig=$PREFIX/GEOS.framework/Versions/Current/unix/bin/geos-config --deploy=$DEPLOY
fi

if [ $GDAL = "YES" ]; then
# Build GDAL.
cd gdal
export CPPFLAGS="-I$PREFIX/PCRE.framework/Versions/Current/unix/include -I$PREFIX/ODBC.framework/Versions/Current/unix/include -I$HOME/unix/include"
export LDFLAGS="-headerpad_max_install_names -L$PREFIX/PCRE.framework/Versions/Current/unix/lib -L$PREFIX/ODBC.framework/Versions/Current/unix/lib -L$HOME/unix/lib"
lib2framework GDAL org.gdal.gdal 2.1.0 gdal --enable-static=no --with-static-proj4=$PREFIX/PROJ.framework/Versions/Current/unix --with-pcre --with-hdf4=$PREFIX/HDF.framework/Versions/4/unix --with-hdf5=$PREFIX/HDF.framework/Versions/5/unix --with-odbc --with-netcdf=$PREFIX/NetCDF.framework/Versions/Current/unix --with-openjpeg=$HOME/Library/Frameworks/OpenJPEG.framework/Versions/Current/unix  --with-poppler=$PREFIX/Poppler.framework/Versions/Current/unix --with-expat=$PREFIX/Expat.framework/Versions/Current/unix --with-mysql=$PREFIX/MySQL.framework/Versions/Current/unix/bin/mysql_config --with-libkml=$PREFIX/KML.framework/Versions/Current/unix --with-fgdb=$PREFIX/FileGDB.framework/Versions/Current/unix --with-sqlite3=$PREFIX/SQLite.framework/Versions/Current/unix --with-geos=$PREFIX/GEOS.framework/Versions/Current/unix/bin/geos-config --with-spatialite=$PREFIX/Spatialite.framework/Versions/Current/unix --with-freexl=$PREFIX/FreeXL.framework/Versions/Current/unix --with-python=$HOME/unix/bin/python --with-pg=$HOME/unix/bin/pg_config --deploy=$DEPLOY 
export CFLAGS=
export LDFALGS=
EXECUTABLES=$PREFIX/GDAL.framework/Versions/Current/unix/bin/*
LIBS=$PREFIX/GDAL.framework/Versions/Current/unix/lib/*.dylib
FILES=("${EXECUTABLES[@]}" "${LIBS[@]}")
for target in $FILES
do
  install_name_tool -change @rpath/libFileGDBAPI.dylib $PREFIX/FileGDB.framework/Versions/Current/unix/lib/libFileGDBAPI.dylib $target
  install_name_tool -change @rpath/libfgdbunixrtl.dylib $PREFIX/FileGDB.framework/Versions/Current/unix/lib/libfgdbunixrtl.dylib $target
done
# HACK - Fix this
install_name_tool -change @rpath/libFileGDBAPI.dylib /Users/jwdaniel/Library/Frameworks/FileGDB.framework/Versions/1.4/unix/lib/libFileGDBAPI.dylib /Users/jwdaniel/Library/Frameworks/GDAL.framework/Versions/2.1.0/unix/lib/libgdal.20.dylib
install_name_tool -change @rpath/libfgdbunixrtl.dylib /Users/jwdaniel/Library/Frameworks/FileGDB.framework/Versions/1.4/unix/lib/libfgdbunixrtl.dylib /Users/jwdaniel/Library/Frameworks/GDAL.framework/Versions/2.1.0/unix/lib/libgdal.20.dylib
cd ..
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

