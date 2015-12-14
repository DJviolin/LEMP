# Lanti/AjentiCP
#
# VERSION               1.0.0

FROM lemp_ssh:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="Ajenti Control Panel" Vendor="Istvan Lantos" Version="1.0"

RUN echo -e \
"deb http://httpredir.debian.org/debian testing main contrib non-free\n\
deb-src http://httpredir.debian.org/debian testing main contrib non-free\n\
deb http://security.debian.org testing/updates main contrib non-free\n\
deb-src http://security.debian.org testing/updates main contrib non-free\n\
deb http://httpredir.debian.org/debian testing-updates main contrib non-free\n\
deb-src http://httpredir.debian.org/debian testing-updates main contrib non-free" > /etc/apt/sources.list
RUN rm -rf /var/lib/dpkg/info/apt-show* \
    && apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes -f install --fix-missing \
        wget \
        apt-show-versions \
    && wget http://repo.ajenti.org/debian/key -O- | apt-key add - \
    && echo -e \
        "deb http://repo.ajenti.org/debian main main debian" > /etc/apt/sources.list.d/ajenti.list \
    && apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install --fix-missing \
        ajenti

CMD ["tail", "-f", "/dev/null"]
