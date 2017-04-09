#!/bin/sh

source build.env

PKGCONFIG=NO
FREETYPE=NO
FONTCONFIG=YES
EXPAT=NO
PCRE=NO
KML=NO
MYSQL=NO
SQLITE=NO
ODBC=NO
ICONV=NO
FREEXL=NO
OPENMPI=NO
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
GDAL=NO
IM=NO
GM=NO

DEPLOY=10.11

if [ $PKGCONFIG = "YES" ]; then
# License: GPL2+. 
# Download pkg-config from https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
# Build pkg-config. 
# Use internal glib since Apple doesn't ship with one.
# Specify a single architecture because the internal glib can't handle multiple architectures.
lib2framework pkg-config org.freedesktop.pkg-config 0.29.2 pkg-config/pkg-config-0.29.2.tar.gz --deploy=$DEPLOY --arch=x86_64 --with-internal-glib
fi

if [ $FREETYPE = "YES" ]; then
# License: FTL or GPL2+. FTL is a modified BSD that requires citation for use.
# Download FreeType from http://download.savannah.gnu.org/releases/freetype/freetype-2.7.1.tar.gz
# Build FreeType. 
lib2framework FreeType org.gnu.freetype 2.7.1 FreeType/freetype-2.7.1.tar.gz --deploy=$DEPLOY
fi

if [ $FONTCONFIG = "YES" ]; then
# License: Liberal. 
# Download FontConfig from https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.12.1.tar.gz
# Build FontConfig.
lib2framework FontConfig org.gnu.fontconfig 2.12.1 FontConfig/fontconfig-2.12.1.tar.gz --deploy=$DEPLOY
fi

if [ $EXPAT = "YES" ]; then
# License: Liberal.
# Download Expat from https://pilotfiber.dl.sourceforge.net/project/expat/expat/2.2.0/expat-2.2.0.tar.bz2
# Build Expat.
lib2framework Expat net.sourceforge.expat 2.2.0 Expat/expat-2.2.0.tar.bz2 --deploy=$DEPLOY
fi

if [ $PCRE = "YES" ]; then
# License: BSD
# Download PCRE from https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz
# Build PCRE.
lib2framework PCRE org.pcre.pcre 8.40 PCRE/pcre-8.40.tar.gz --deploy=$DEPLOY
fi

if [ $KML = "YES" ]; then
# License: BSD
# Download libkml from https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/libkml/libkml-1.2.0.tar.gz
# Build libkml.
lib2framework KML com.google.kml 1.2 KML/libkml-1.2.0.tar.gz --deploy=$DEPLOY
fi

if [ $MYSQL = "YES" ]; then
# License: GPLv2
# Download MySQL connector from https://cdn.mysql.com//Downloads/Connector-C/mysql-connector-c-6.1.9-src.tar.gz
# Build MySQL connector.
lib2framework MySQL com.mysql.connector 6.1.9 MySQL/mysql-connector-c-6.1.9-src --deploy=$DEPLOY 
fi

if [ $SQLITE = "YES" ]; then
# License: Public domain
# Download SQLite from https://www.sqlite.org/2017/sqlite-autoconf-3180000.tar.gz
# Build SQLite.
lib2framework SQLite org.sqlite.sqlite 3.18 SQLite/sqlite-autoconf-3180000 --deploy=$DEPLOY
fi

if [ $ODBC = "YES" ]; then
# Licene: GPLv2
# Download odbc from http://www.unixodbc.org/unixODBC-2.3.4.tar.gz
# Build odbc.
lib2framework ODBC org.unixodbc.odbc 2.3.4 ODBC/unixODBC-2.3.4 --deploy=$DEPLOY
fi

if [ $FREEXL = "YES" ]; then
# License: MPL
# Download freexl from http://www.gaia-gis.it/gaia-sins/freexl-1.0.2.tar.gz
# Build freexl.
lib2framework FreeXL it.gaia-gis 1.0.2 FreeXL/freexl-1.0.2 --deploy=$DEPLOY
fi

if [ $OPENMPI = "YES" ]; then
# License: BSD
# Download OpenMPI from https://www.open-mpi.org/software/ompi/v2.1/downloads/openmpi-2.1.0.tar.gz
# Build OpenMPI. 
lib2framework OpenMPI org.open-mpi.openmpi 2.1 OpenMPI/openmpi-2.1.0 --deploy=$DEPLOY
fi

if [ $JPEG6 = "YES" ]; then
# License: IJG. Citation required.
# Download libjpeg 6 from https://sourceforge.net/projects/libjpeg/files/libjpeg/6b/jpegsrc.v6b.tar.gz/download
# Build libjpeg 6.
INSTALL=osxinstall lib2framework JPEG org.ijg.openjpeg 6 jpeg-6b --target=install-lib --deploy=$DEPLOY
fi

if [ $JPEG8 = "YES" ]; then
# License: IJG. Citation required.
# Download libjpeg 9 from http://www.ijg.org/files/jpegsrc.v9b.tar.gz
# Build libjpeg 9.
lib2framework JPEG org.ijg.openjpeg 9 jpeg-9b --enable-shared --deploy=$DEPLOY
fi

if [ $TIFF = "YES" ]; then
# License: BSD
# Download libtiff 4 from http://download.osgeo.org/libtiff/tiff-4.0.7.tar.gz
# Build libtiff 4.
lib2framework TIFF org.osgeo.tif 4 tiff-4.0.7 --with-jpeg-include-dir=$PREFIX/JPEG.framework/Versions/Current/unix/include --with-jpeg-lib-dir=$PREFIX/JPEG.framework/Versions/Current/unix/lib --deploy=$DEPLOY --lib=libtiff.5.dylib
fi

if [ $HDF = "YES" ]; then
# License: BSD
# Download HDF from https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.12/src/hdf-4.2.12.tar.gz
# Build HDF.
lib2framework HDF org.hdfgroup.hdf 4 hdf-4.2.11 --enable-production --enable-shared --disable-netcdf --disable-fortran --with-jpeg=$PREFIX/JPEG.framework/Versions/6/unix/include,$PREFIX/JPEG.framework/Versions/6/unix/lib --deploy=$DEPLOY
fi

if [ $HDF5 = "YES" ]; then
# License: BSD
# Download HDF5 from https://support.hdfgroup.org/ftp/HDF5/current18/src/hdf5-1.8.18.tar.gz
# Build HDF5.
lib2framework HDF org.hdfgroup.hdf 5 hdf5-1.8.17 --deploy=$DEPLOY
fi

# OpenJPEG not working right now.
if [ $OpenJPEG = "YES" ] ; then
# License: BSD 
# Download OpenJPEG from https://codeload.github.com/uclouvain/openjpeg/tar.gz/v2.1.2
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
# License: Liberal
# Download libpng from https://superb-dca2.dl.sourceforge.net/project/libpng/libpng16/1.6.28/libpng-1.6.28.tar.gz
# Build libpng.
lib2framework PNG org.libpng.png 1 libpng-1.6.21 --deploy=$DEPLOY
fi

if [ $NetCDF = "YES" ]; then
# License: Liberal
# Download NetCDF from ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.1.1.tar.gz
# Build NetCDF.
export LDFLAGS="-L$PREFIX/HDF.framework/Versions/5/unix/lib -L$PREFIX/HDF.framework/Versions/4/unix/lib"
export CPPFLAGS="-I$PREFIX/HDF.framework/Versions/5/unix/include -I$PREFIX/HDF.framework/Versions/4/unix/include"
lib2framework NetCDF edu.ucar.netcdf 4 netcdf-4.4.0 --deploy=$DEPLOY
export LDFLAGS=
export CPPFLAGS=
fi

# Poppler not working right now.
if [ $PDF = "YES" ]; then
# License: GPLv2
# Download Poppler from https://poppler.freedesktop.org/poppler-0.53.0.tar.xz
# Build the MacOS X PROJ.4 framework.
LIBJPEG_CFLAGS=-I$PREFIX/JPEG.framework/Versions/6/unix/include LDFLAGS="-L$PREFIX/JPEG.framework/Versions/6/unix/lib" lib2framework Poppler org.freedesktop.poppler 0.31.0 poppler-0.31.0 --enable-xpdf-headers
cd poppler-data-0.4.7
make install datadir=$PREFIX/JPEG.framework/Versions/6/unix
cd ..
fi

if [ $PROJ4 = "YES" ]; then
# License: Liberal
# Download PROJ4 from http://download.osgeo.org/proj/proj-4.9.3.tar.gz
# Copy PROJ.4.
cp -R proj.4 buildproj.4

# Get more NAD data.
# License: Liberal
# Download data from http://download.osgeo.org/proj/proj-datumgrid-1.5.zip
cp proj-datumgrid-1.5/* buildproj.4/nad

# Build the MacOS X PROJ.4 framework.
lib2framework PROJ org.maptools.proj 4 buildproj.4 --deploy=$DEPLOY
rm -Rf buildproj-4.7.0
fi

# ECW not updated or tested for a long time.
if [ $ECW = "YES" ]; then
# License: long story
# Download ECW from ?
# Build ECW.
rm -Rf libecwj2-3.3
unzip archives/libecwj2-3.3-2006-09-06.zip
cd libecwj2-3.3
patch -p1 < ../archives/libecwj2-3.3.patch.txt
cd ..
lib2framework ECW com.intergraph.geospatial 3 libecwj2-3.3 --enable-shared --deploy=$DEPLOY
fi

if [ $ICONV = "YES" ]; then
# License: GPLv3
# Build libiconv
# Download libiconv from https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
lib2framework iconv org.gnu.iconv 1.15 libiconv-1.15.0 --deploy=$DEPLOY
fi

if [ $GEOS = "YES" ]; then
# License: GPLv2
# Build GEOS 3.5.
# Download GEOS from http://download.osgeo.org/geos/geos-3.6.1.tar.bz2
lib2framework GEOS org.osgeo.geos 3.5 geos-3.5.0 --deploy=$DEPLOY
fi

if [ $SPATIALITE = "YES" ]; then
# License: 
# Download Spatialite from http://www.gaia-gis.it/gaia-sins/libspatialite-4.3.0a.tar.gz
# Build Spatialite 4.3.0a.
CPPFLAGS="-I$PREFIX/PROJ.framework/Versions/Current/unix/include -I/$PREFIX/GEOS.framework/Versions/Current/unix/include -I/$PREFIX/FreeXL.framework/Versions/Current/unix/include" LDFLAGS="-L$PREFIX/PROJ.framework/Versions/Current/unix/lib -L$PREFIX/FreeXL.framework/Versions/Current/unix/lib" lib2framework Spatialite it.gaia-gis.spatialite 4.3.0 libspatialite-4.3.0a --with-geosconfig=$PREFIX/GEOS.framework/Versions/Current/unix/bin/geos-config --deploy=$DEPLOY
fi

if [ $GDAL = "YES" ]; then
# License: Liberal
# Download GDAL from http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz
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
# License: Liberal
# Download ImageMagick from https://www.imagemagick.org/download/ImageMagick.tar.gz
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

# GM not updated or tested for a long time.
if [ $GM = "YES" ]; then
# License: Liberal
# Download GraphicsMagick from https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.25/GraphicsMagick-1.3.25.tar.gz/download
# Extract GraphicsMagick.
rm -Rf GraphicsMagick-1.3.25
tar zxvf archives/GraphicMagick.tar.gz
export CFLAGS=-I$HOME/Library/Frameworks/TIFF.framework/unix/include
export LDFLAGS=-I$HOME/Library/Frameworks/TIFF.framework/unix/lib
# Build GraphicsMagick.
lib2framework GraphicsMagick org.graphicsmagick.graphicsmagick 1.3.25 GraphicsMagick-1.3.25  --deploy=$DEPLOY
export CFLAGS=
export LDFLAGS=
fi

