# Lanti/lempFFmpeg
#
# VERSION               1.0.0

FROM lemp_base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="FFmpeg" Vendor="Istvan Lantos" Version="1.0"

### Start of DEV environment deps
RUN apt-get -y update && apt-get -y dist-upgrade \
    && apt-get -y install \
        curl \
        make \
        gcc \
        g++ \
        autoconf \
        automake \
        build-essential \
        # FFmpeg packages \
        libass-dev \
        libfreetype6-dev \
        libtheora-dev \
        libtool \
        libvorbis-dev \
        pkg-config \
        texinfo \
        zlib1g-dev \
        # FFmpeg dependency packages \
        yasm \
        libx264-dev \
        libfdk-aac-dev \
        libmp3lame-dev \
        libopus-dev \
        libvpx-dev
#RUN echo -e "deb http://httpredir.debian.org/debian jessie-backports main contrib non-free" > /etc/apt/sources.list.d/jessie-backports.list
#RUN apt-get -y update && apt-get -y dist-upgrade \
#    && apt-get -y -t jessie-backports install \
#        libx265-dev
### End of DEV environment deps

### Start of Downloading source files
RUN curl -fSL "https://github.com/FFmpeg/FFmpeg/archive/master.tar.gz" -o "ffmpeg.tar.gz" \
    && mkdir -p /usr/src/ffmpeg \
    && tar -xf "ffmpeg.tar.gz" -C /usr/src/ffmpeg --strip-components=1 \
    && rm "ffmpeg.tar.gz"*
### End of Downloading source files

### Start of building
RUN cd /usr/src/ffmpeg \
     \
    && PKG_CONFIG_PATH="/usr/ffmpeg/lib/pkgconfig" \
    && ./configure \
        --prefix=/usr/ffmpeg \
        --bindir=/usr/ffmpeg/bin \
        \
        --pkg-config-flags="--static" \
        --extra-cflags="-I/usr/ffmpeg/include" \
        --extra-ldflags="-L/usr/ffmpeg/lib" \
        --enable-gpl \
        --enable-libass \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx264 \
        #--enable-libx265 \
        --enable-nonfree \
        \
        #--extra-version='1~bpo8+1' \
        #--build-suffix=-ffmpeg \
        #--toolchain=hardened \
        #--libdir=/usr/lib/x86_64-linux-gnu \
        #--incdir=/usr/include/x86_64-linux-gnu \
        #--cc=cc \
        #--cxx=g++ \
        #--enable-gpl \
        #--enable-shared \
        #--disable-stripping \
        #--disable-decoder=libopenjpeg \
        #--disable-decoder=libschroedinger \
        #--enable-avresample \
        #--enable-avisynth \
        #--enable-gnutls \
        #--enable-ladspa \
        #--enable-libass \
        #--enable-libbluray \
        #--enable-libbs2b \
        #--enable-libcaca \
        #--enable-libcdio \
        #--enable-libflite \
        #--enable-libfontconfig \
        #--enable-libfreetype \
        #--enable-libfribidi \
        #--enable-libgme \
        #--enable-libgsm \
        #--enable-libmodplug \
        #--enable-libmp3lame \
        #--enable-libopenjpeg \
        #--enable-libopus \
        #--enable-libpulse \
        #--enable-librtmp \
        #--enable-libschroedinger \
        #--enable-libshine \
        #--enable-libsnappy \
        #--enable-libsoxr \
        #--enable-libspeex \
        #--enable-libssh \
        #--enable-libtheora \
        #--enable-libtwolame \
        #--enable-libvorbis \
        #--enable-libvpx \
        #--enable-libwavpack \
        #--enable-libwebp \
        #--enable-libx265 \
        #--enable-libxvid \
        #--enable-libzvbi \
        #--enable-openal \
        #--enable-opengl \
        #--enable-x11grab \
        #--enable-libdc1394 \
        #--enable-libiec61883 \
        #--enable-libzmq \
        #--enable-frei0r \
        #--enable-libx264 \
        #--enable-libopencv \
    && echo -e "Configuration done!"
RUN make \
    && make install \
    && make distclean \
    && echo 'export PATH="$PATH:/usr/ffmpeg/bin"' >> /etc/bash.bashrc \
    && cd $HOME \
    && ffmpeg
### End of building

RUN rm -rf /usr/src/* /var/lib/apt/lists/*

CMD ["tail", "-f", "/dev/null"]
