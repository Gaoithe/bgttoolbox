
function goto () {
   echo P=$1 OLD=$OLD
   #apt-cache -f search $1
   sudo apt-get install $P=$OLD
}

#TS="2009-10-02_23:57:47";C=upgrade;P="openoffice.org-emailmerge";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:57:58";C=upgrade;P="libwbclient0";OLD="2:3.3.2-1ubuntu3.1";NEW="2:3.3.2-1ubuntu3.2"; goto $P $OLD
#TS="2009-10-02_23:57:58";C=upgrade;P="libsmbclient";OLD="2:3.3.2-1ubuntu3.1";NEW="2:3.3.2-1ubuntu3.2"; goto $P $OLD
#TS="2009-10-02_23:57:59";C=upgrade;P="ure";OLD="1.4.1+OOo3.0.1-9ubuntu3";NEW="1.4.1+OOo3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:00";C=upgrade;P="uno-libs3";OLD="1.4.1+OOo3.0.1-9ubuntu3";NEW="1.4.1+OOo3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:01";C=upgrade;P="openoffice.org-calc";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:04";C=upgrade;P="openoffice.org-impress";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:05";C=upgrade;P="openoffice.org-draw";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:06";C=upgrade;P="openoffice.org-style-human";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:07";C=upgrade;P="openoffice.org-common";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:15";C=upgrade;P="openoffice.org-gtk";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:15";C=upgrade;P="openoffice.org-gnome";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:16";C=upgrade;P="python-uno";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:16";C=upgrade;P="openoffice.org-math";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:17";C=upgrade;P="ttf-opensymbol";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:17";C=upgrade;P="openoffice.org-writer";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:20";C=upgrade;P="openoffice.org-base-core";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:20";C=upgrade;P="openoffice.org-core";OLD="1:3.0.1-9ubuntu3";NEW="1:3.0.1-9ubuntu3.1"; goto $P $OLD
#TS="2009-10-02_23:58:31";C=upgrade;P="smbclient";OLD="2:3.3.2-1ubuntu3.1";NEW="2:3.3.2-1ubuntu3.2"; goto $P $OLD
#TS="2009-10-02_23:58:33";C=upgrade;P="winbind";OLD="2:3.3.2-1ubuntu3.1";NEW="2:3.3.2-1ubuntu3.2"; goto $P $OLD
#TS="2009-10-02_23:58:34";C=upgrade;P="samba-common";OLD="2:3.3.2-1ubuntu3.1";NEW="2:3.3.2-1ubuntu3.2"; goto $P $OLD
TS="2009-10-02_23:58:36";C=upgrade;P="xserver-xorg-video-radeon";OLD="1:6.12.99+git20090926.7968e1fb-0ubuntu0tormod~jaunty";NEW="1:6.12.99+git20090930.d3024814-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-02_23:58:36";C=upgrade;P="xserver-xorg-video-ati";OLD="1:6.12.99+git20090926.7968e1fb-0ubuntu0tormod~jaunty";NEW="1:6.12.99+git20090930.d3024814-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-02_23:58:36";C=upgrade;P="xserver-xorg-video-intel";OLD="2:2.8.99.902~git20090923.a92bbcc9-0ubuntu0tormod~jaunty";NEW="2:2.9.0~git20090930.2841a4cd-0ubuntu0tormod~jaunty"; goto $P $OLD

exit

TS="2009-10-08_21:52:35";C=upgrade;P="openswan";OLD="1:2.4.12+dfsg-1.3";NEW="1:2.4.12+dfsg-1.3+lenny2build0.9.04.1"; goto $P $OLD
TS="2009-10-08_21:52:38";C=upgrade;P="tzdata-java";OLD="2009m-0ubuntu0.9.04";NEW="2009n-0ubuntu0.9.04"; goto $P $OLD
TS="2009-10-08_21:52:40";C=upgrade;P="tzdata";OLD="2009m-0ubuntu0.9.04";NEW="2009n-0ubuntu0.9.04"; goto $P $OLD
TS="2009-10-08_21:52:54";C=upgrade;P="wget";OLD="1.11.4-2ubuntu1";NEW="1.11.4-2ubuntu1.1"; goto $P $OLD
TS="2009-10-08_21:52:55";C=upgrade;P="cscope";OLD="15.6-6";NEW="15.6-6+lenny1build0.9.04.1"; goto $P $OLD
TS="2009-10-08_21:52:56";C=upgrade;P="libdrm2";OLD="2.4.14-0ubuntu0tormod~jaunty";NEW="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-08_21:52:56";C=upgrade;P="libdrm-intel1";OLD="2.4.14-0ubuntu0tormod~jaunty";NEW="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-08_21:52:57";C=upgrade;P="libdrm-radeon1";OLD="2.4.14-0ubuntu0tormod~jaunty";NEW="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-08_21:52:57";C=upgrade;P="libgl1-mesa-dri";OLD="7.7.0~git20090928.d492e7b0-0ubuntu0tormod~jaunty";NEW="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-08_21:53:01";C=upgrade;P="libgl1-mesa-glx";OLD="7.7.0~git20090928.d492e7b0-0ubuntu0tormod~jaunty";NEW="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-08_21:53:02";C=upgrade;P="libglib2.0-dev";OLD="2.20.1-0ubuntu2";NEW="2.20.1-0ubuntu2.1"; goto $P $OLD
TS="2009-10-08_21:53:03";C=upgrade;P="libglib2.0-0";OLD="2.20.1-0ubuntu2";NEW="2.20.1-0ubuntu2.1"; goto $P $OLD
TS="2009-10-08_21:53:04";C=upgrade;P="libglib2.0-data";OLD="2.20.1-0ubuntu2";NEW="2.20.1-0ubuntu2.1"; goto $P $OLD
TS="2009-10-08_21:53:04";C=upgrade;P="libglu1-mesa";OLD="7.7.0~git20090928.d492e7b0-0ubuntu0tormod~jaunty";NEW="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-08_21:53:05";C=upgrade;P="libicu38";OLD="3.8.1-3ubuntu1";NEW="3.8.1-3ubuntu1.1"; goto $P $OLD
TS="2009-10-08_21:53:09";C=upgrade;P="mesa-utils";OLD="7.7.0~git20090928.d492e7b0-0ubuntu0tormod~jaunty";NEW="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-08_21:53:10";C=upgrade;P="playonlinux";OLD="3.6";NEW="3.7"; goto $P $OLD
TS="2009-10-08_21:53:11";C=upgrade;P="xserver-xorg-video-radeon";OLD="1:6.12.99+git20090930.d3024814-0ubuntu0tormod~jaunty";NEW="1:6.12.99+git20091007.e59ae082-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-08_21:53:12";C=upgrade;P="xserver-xorg-video-ati";OLD="1:6.12.99+git20090930.d3024814-0ubuntu0tormod~jaunty";NEW="1:6.12.99+git20091007.e59ae082-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-08_21:53:15";C=upgrade;P="xserver-xorg-video-intel";OLD="2:2.9.0~git20090930.2841a4cd-0ubuntu0tormod~jaunty";NEW="2:2.9.0~git20091007.03e8e64f-0ubuntu0tormod3~jaunty"; goto $P $OLD

exit

TS="2009-10-09_21:38:09";C=startup;P="archives";OLD="unpack"; goto $P $OLD
TS="2009-10-09_21:38:35";C=upgrade;P="libdrm2";OLD="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty 2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty2"; goto $P $OLD
TS="2009-10-09_21:38:36";C=upgrade;P="libdrm-intel1";OLD="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty 2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty2"; goto $P $OLD
TS="2009-10-09_21:38:36";C=upgrade;P="libdrm-radeon1";OLD="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty 2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty2"; goto $P $OLD
TS="2009-10-09_21:38:36";C=upgrade;P="libgl1-mesa-dri";OLD="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty 7.7.0~git20091008.f49d5359-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:40";C=upgrade;P="libgl1-mesa-glx";OLD="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty 7.7.0~git20091008.f49d5359-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:40";C=upgrade;P="libglu1-mesa";OLD="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty 7.7.0~git20091008.f49d5359-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:40";C=upgrade;P="mesa-utils";OLD="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty 7.7.0~git20091008.f49d5359-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:41";C=upgrade;P="nvidia-173-modaliases";OLD="173.14.16-0ubuntu1 173.14.16-0ubuntu2"; goto $P $OLD
TS="2009-10-09_21:38:41";C=upgrade;P="nvidia-180-modaliases";OLD="185.18.14-0ubuntu1~xup~1~jaunty 185.18.14-0ubuntu1"; goto $P $OLD
TS="2009-10-09_21:38:41";C=upgrade;P="nvidia-96-modaliases";OLD="96.43.10-0ubuntu1 96.43.10-0ubuntu2"; goto $P $OLD
TS="2009-10-09_21:38:41";C=upgrade;P="xserver-xorg-input-synaptics";OLD="0.99.3-2ubuntu4 0.99.3-2ubuntu5"; goto $P $OLD
TS="2009-10-09_21:38:42";C=upgrade;P="xserver-xorg-input-vmmouse";OLD="1:12.5.1-4ubuntu5 1:12.6.4-0ubuntu1~xup~1"; goto $P $OLD
TS="2009-10-09_21:38:42";C=upgrade;P="xserver-xorg-video-radeon";OLD="1:6.12.99+git20091007.e59ae082-0ubuntu0tormod~jaunty 1:6.12.99+git20091008.02e12ae6-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:43";C=upgrade;P="xserver-xorg-video-ati";OLD="1:6.12.99+git20091007.e59ae082-0ubuntu0tormod~jaunty 1:6.12.99+git20091008.02e12ae6-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:43";C=upgrade;P="xserver-xorg-video-sisusb";OLD="1:0.9.0-4 1:0.9.1-1build1"; goto $P $OLD
TS="2009-10-09_21:38:43";C=trigproc;P="man-db";OLD="2.5.5-1build1 2.5.5-1build1"; goto $P $OLD
TS="2009-10-09_21:38:47";C=trigproc;P="hal";OLD="0.5.12~rc1+git20090403-0ubuntu4 0.5.12~rc1+git20090403-0ubuntu4"; goto $P $OLD
TS="2009-10-09_21:38:51";C=startup;P="packages";OLD="configure"; goto $P $OLD
TS="2009-10-09_21:38:51";C=trigproc;P="libc6";OLD="2.9-4ubuntu6.1 2.9-4ubuntu6.1"; goto $P $OLD

function goto () {
   echo P=$1 OLD=$OLD
   #apt-cache -f search $1
   sudo apt-get install $P=$OLD
}

#2009-10-09";NEW="21:38:09 startup archives unpack"; goto $P $OLD
TS="2009-10-09_21:38:35";C=upgrade;P=libdrm2;OLD="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty";NEW="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty2"; goto $P $OLD
TS="2009-10-09_21:38:36";C=upgrade;P=libdrm-intel1;OLD="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty";NEW="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty2"; goto $P $OLD
TS="2009-10-09_21:38:36";C=upgrade;P=libdrm-radeon1;OLD="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty";NEW="2.4.14+git20091007.3a7dfcdf-0ubuntu0tormod~jaunty2"; goto $P $OLD
TS="2009-10-09_21:38:36";C=upgrade;P=libgl1-mesa-dri;OLD="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty";NEW="7.7.0~git20091008.f49d5359-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:40";C=upgrade;P=libgl1-mesa-glx;OLD="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty";NEW="7.7.0~git20091008.f49d5359-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:40";C=upgrade;P=libglu1-mesa;OLD="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty";NEW="7.7.0~git20091008.f49d5359-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:40";C=upgrade;P=mesa-utils;OLD="7.7.0~git20091007.0083d2e4-0ubuntu0tormod~jaunty";NEW="7.7.0~git20091008.f49d5359-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:41";C=upgrade;P=nvidia-173-modaliases;OLD="173.14.16-0ubuntu1";NEW="173.14.16-0ubuntu2"; goto $P $OLD
TS="2009-10-09_21:38:41";C=upgrade;P=nvidia-180-modaliases;OLD="185.18.14-0ubuntu1~xup~1~jaunty";NEW="185.18.14-0ubuntu1"; goto $P $OLD
TS="2009-10-09_21:38:41";C=upgrade;P=nvidia-96-modaliases;OLD="96.43.10-0ubuntu1";NEW="96.43.10-0ubuntu2"; goto $P $OLD
TS="2009-10-09_21:38:41";C=upgrade;P=xserver-xorg-input-synaptics;OLD="0.99.3-2ubuntu4";NEW="0.99.3-2ubuntu5"; goto $P $OLD
TS="2009-10-09_21:38:42";C=upgrade;P=xserver-xorg-input-vmmouse;OLD="1:12.5.1-4ubuntu5";NEW="1:12.6.4-0ubuntu1~xup~1"; goto $P $OLD
TS="2009-10-09_21:38:42";C=upgrade;P=xserver-xorg-video-radeon;OLD="1:6.12.99+git20091007.e59ae082-0ubuntu0tormod~jaunty";NEW="1:6.12.99+git20091008.02e12ae6-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:43";C=upgrade;P=xserver-xorg-video-ati;OLD="1:6.12.99+git20091007.e59ae082-0ubuntu0tormod~jaunty";NEW="1:6.12.99+git20091008.02e12ae6-0ubuntu0tormod~jaunty"; goto $P $OLD
TS="2009-10-09_21:38:43";C=upgrade;P=xserver-xorg-video-sisusb;OLD="1:0.9.0-4";NEW="1:0.9.1-1build1"; goto $P $OLD
