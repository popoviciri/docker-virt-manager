# --------------------------------------------
# Build VM
# --------------------------------------------
FROM alpine:3.16 AS builder

ARG VM_BRANCH=main

RUN \
    apk update \
    && apk add --no-cache --upgrade \
        bash \
        libressl-dev \
        xterm \
        dbus-x11 \
        py3-gobject3 \
        py3-libvirt \
        libvirt-glib \
        libosinfo \
        build-base \
        python3 \
        gtk+3.0-dev \
        vte3 \
        spice-gtk \
        gtk-vnc \
        py3-cairo \
        ttf-dejavu \
        gnome-icon-theme \
        dconf \
        intltool \
        grep \
        gettext-dev \
        py3-urlgrabber \
        py3-ipaddr \
        py3-requests \
        py3-urllib3 \
        py3-chardet \
        py3-certifi \
        py3-idna \
        perl-dev \
        cdrkit \
        git \
        py3-setuptools \
        py3-docutils \
        libxml2 \
        py3-libxml2 \
    && apk add \
        openssh-askpass \
        --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
    && rm -rf /var/cache/apk/* /tmp/* /tmp/.[!.]*

# compile virt-manager
RUN git clone -b ${VM_BRANCH} https://github.com/virt-manager/virt-manager.git
RUN \
    cp -R /usr/share/glib-2.0 /usr/local/share/ \
    && cp -R /usr/share/icons /usr/local/share/
RUN \
    cd virt-manager \
    && ./setup.py configure --prefix=/usr/local  \
    && ./setup.py install --exec-prefix=/usr/local

# --------------------------------------------
# Start HERE
# --------------------------------------------
FROM jlesage/baseimage-gui:alpine-3.16-v4.0.0-pre.5
RUN \
    apk add --no-cache --upgrade \
        py3-ipaddr \
        py3-cairo \
        py3-requests \
        py3-libvirt \
        gtksourceview4 \
        libvirt-glib \
        libosinfo \
        dbus-x11 \
        spice-gtk \
        openssh-client \
        bash \
        libressl \
        dconf \
        grep \
        cdrkit \
        gtk-vnc \
        vte3 \
        gnome-icon-theme \
        adwaita-icon-theme \
        py3-gobject3 \
        py3-libxml2 \
    && apk add \
        py3-configparser \
        --repository http://dl-3.alpinelinux.org/alpine/v3.10/community/ \
    && apk add \
        ksshaskpass \
        py3-argcomplete \
        --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
    && rm -rf /var/cache/apk/* /tmp/* /tmp/.[!.]* \
    && mkdir -p /usr/lib/ssh \
    && ln -s /usr/bin/ksshaskpass /usr/lib/ssh/ssh-askpass
RUN \
    APP_ICON_URL=https://www.alteeve.com/w/images/2/26/Striker01-v2.0-virtual-machine-manager_icon.png \
    && install_app_icon.sh "$APP_ICON_URL" \
    && rm -rf /var/cache/apk/*
RUN echo -e "#!/bin/sh\nexport HOME=/config\nexec /usr/local/bin/virt-manager --no-fork" \
	> /startapp.sh
RUN echo -e "#!/usr/bin/with-contenv sh\ndbus-uuidgen --ensure=/etc/machine-id" \
	> /etc/cont-init.d/20-machineid_fix.sh
COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/local/share/glib-2.0/schemas /usr/share/glib-2.0/schemas/
RUN glib-compile-schemas /usr/local/share/glib-2.0/schemas/

ENV APP_NAME="virt-manager"
