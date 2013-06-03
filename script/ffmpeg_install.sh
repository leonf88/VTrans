#!/bin/bash
echo -e "Make sure you have the source files below.\n\
    amrnb-11.0.0.0  fdk-aac       install.sh   libogg-1.3.1     libvpx              x264  xvidcore \n\
    amrwb-11.0.0.0  ffmpeg-1.2.1  lame-3.99.5  libvorbis-1.3.3  opencore-amr-0.1.3  xavs  yasm-1.2.0"

read -p 'To continue?(Y/N)' is_next

[ "$is_next" != "Y" -a "$is_next" != "y" ] && exit

curDir=`pwd`
TARGET_DIR="$TARGET_DIR"

cd yasm-1.2.0
./configure --prefix="$TARGET_DIR" --disable-shared 
make && make install
[ "$?" != "0" ] && echo "error yasm" && exit -1 
cd $curDir

cd x264    
./configure --prefix="$TARGET_DIR" --enable-static --disable-shared
make -j16 && make install
[ "$?" != "0" ] && echo "error x264" && exit -1 
cd $curDir

cd fdk-aac       
autoreconf -fiv
./configure --prefix="$TARGET_DIR" --disable-shared
make && make install
[ "$?" != "0" ] && echo "error aac" && exit -1 
cd $curDir

cd xavs      
./configure --prefix="$TARGET_DIR" --disable-shared 
make && make install
[ "$?" != "0" ] && echo "error xavs" && exit -1 
cd $curDir

cd amrnb-11.0.0.0	
./configure --prefix="$TARGET_DIR" --disable-shared
make && make install
[ "$?" != "0" ] && echo "error amrnb" && exit -1 
cd $curDir

cd amrwb-11.0.0.0	
./configure --prefix="$TARGET_DIR" --disable-shared
make && make install
[ "$?" != "0" ] && echo "error amrwb" && exit -1 
cd $curDir

cd lame-3.99.5  
./configure --prefix="$TARGET_DIR" --disable-shared --enable-nasm
make && make install
[ "$?" != "0" ] && echo "error lame" && exit -1 
cd $curDir

cd libogg-1.3.1     
./configure --prefix="$TARGET_DIR" --disable-shared
make && make install
[ "$?" != "0" ] && echo "error libogg" && exit -1 
cd $curDir

cd libvpx  
./configure --prefix="$TARGET_DIR" --disable-examples --disable-shared 
make && make install
[ "$?" != "0" ] && echo "error libvpx" && exit -1 
cd $curDir

cd libvorbis-1.3.3  
./configure --prefix="$TARGET_DIR" --with-ogg="$TARGET_DIR/" --disable-shared
make && make install
[ "$?" != "0" ] && echo "error libvorbis" && exit -1 
cd $curDir

cd opencore-amr-0.1.3
./configure --prefix="$TARGET_DIR" --disable-shared 
make && make install
[ "$?" != "0" ] && echo "error opencore-amr" && exit -1 
cd $curDir

cd xvidcore
cd build/generic/
./configure --prefix="$TARGET_DIR" --disable-shared
make && make install
[ "$?" != "0" ] && echo "error xvid" && exit -1 
cd $curDir

cd ffmpeg-1.2.1  
./configure --prefix="$TARGET_DIR" --extra-cflags="-I${TARGET_DIR}/include -I/usr/local/include" \
	--extra-ldflags="-L${TARGET_DIR}/lib -L/usr/local/lib" --extra-libs="-ldl" --enable-gpl  \
	--enable-libfdk-aac --enable-libmp3lame \
	--enable-libxavs --enable-libxvid --enable-libvpx --enable-libx264 \
	--enable-libopencore-amrwb --enable-libopencore-amrnb --enable-version3 \
	--enable-nonfree --enable-x11grab

make -j16 && make install

