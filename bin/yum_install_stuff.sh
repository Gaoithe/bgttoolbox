#!/bin/bash

# Install packages lists for;
# * dev/test machines, compilers, libs scripts, tools like gdb, wireshark, network tools, process/cpu load tools, gnuplot, . . . 
# * firefox/gimp/inkscape/. . . 
# * various functions, like jenkins // nagios // github/gitlab // kvm // cvstrac // android dev // py games // mapping // qt dev // astronomy // google earth // videoedit blender

PACKAGES_LIST="perl gnuplot zlib openssl nmap net-tools nfs-utils ncurses-devel
   glib2 glib2-devel sysstat libgtop2 libgtop2-devel openldap-devel openssl openssl-devel
   vim emacs lsb unix2dos mpack dosfstools
   net-tools powertop htop wireshark traceroute ltrace strace valgrind iftop iotop powertop
   gimp inkscape scribus-ng dia
   skype opera
   xscreensaver fortune
   putty rxvt xterm screen mc curl links wget google-chrome
   vlc mplayer
   p7zip unrar
   python numpy matplotlib pygame ipython
   fvwm2
   libreoffice-calc libreoffice-writer
   "

yum install bison gdb coreutils meld diffutils file google-chrome lynx baobab blender audacity stellarium kcalc dvdauthor

yum install telnet

OTHER_LIST="festival qt5 eclipse ipython
   fring
   netbeans-devel 
   xterm
   sendmail ?
   tigervnc
   dvdstyler gstreamersqlite2
   grip   k3b ? yum-utils   mc? at?  diffstat?   which ?   fonts   news reader   rrdtool   clamav  csound ?   webcam stuff   cervisia? gparted? rosegarden
   "

# TODO: jdk

# TODO: yes yes yes
yum install $PACKAGES_LIST
 
# util-linux - already
#dvb-apps
#[james@nebraska regression]$ rpm -ql util-linux |less
#[james@nebraska regression]$ rpm -ql dvb-apps |less
#[james@nebraska regression]$ rpm -qf $(which oowriter) 
#libreoffice-writer-4.1.6.2-7.fc19.i686
#[james@nebraska regression]$ rpm -qf $(which cfdisk) 
#util-linux-2.23.2-5.fc19.i686

#[james@nebraska tc_15_q3]$ rpm -qa >~/notes_nebraska_packages_rpm_list
#[james@nebraska tc_15_q3]$ yum list installed > ~/notes_nebraska_packages_yum_list

# [james@nebraska tc_15_q3]$ grep installed$ ~/notes_nebraska_packages_yum_list |grep -v ^OMN
# jdk.i586                                   2000:1.7.0_79-fcs           installed
# mpack.i686                                 1.6-2.el6.rf                installed
# opera.i386                                 2:12.16-1860                installed
# rpmfusion-free-release.noarch              19-1                        installed
# skype.i586                                 4.3.0.37-fc16               installed
# sun-javadb-client.i386                     10.6.2-1.1                  installed
# sun-javadb-common.i386                     10.6.2-1.1                  installed
# sun-javadb-core.i386                       10.6.2-1.1                  installed
# sun-javadb-demo.i386                       10.6.2-1.1                  installed
# sun-javadb-docs.i386                       10.6.2-1.1                  installed
# sun-javadb-javadoc.i386                    10.6.2-1.1                  installed
# wireshark.i686                             1.99.0-1                    installed
# wireshark-gnome.i686                       1.99.0-1                    installed

#[james@nebraska tc_15_q3]$ rpm -qf $(which iftop)
#iftop-1.0-0.7.pre4.fc19.i686



Installed:
  dos2unix.x86_64 0:6.0.3-4.el7                                   elinks.x86_64 0:0.12-0.36.pre6.el7              emacs.x86_64 1:24.3-18.el7                             
  gimp.x86_64 2:2.8.10-3.el7                                      glib2-devel.x86_64 0:2.42.2-5.el7               gnuplot.x86_64 0:4.6.2-3.el7                           
  inkscape.x86_64 0:0.48.4-15.el7                                 iotop.noarch 0:0.6-2.el7                        libgtop2-devel.x86_64 0:2.28.4-7.el7                   
  ltrace.x86_64 0:0.7.91-14.el7                                   mc.x86_64 1:4.8.7-8.el7                         ncurses-devel.x86_64 0:5.9-13.20130511.el7             
  nmap.x86_64 2:6.40-7.el7                                        numpy.x86_64 1:1.7.1-11.el7                     openldap-devel.x86_64 0:2.4.40-9.el7_2                 
  openssl-devel.x86_64 1:1.0.1e-51.el7_2.5                        powertop.x86_64 0:2.3-9.el7                     redhat-lsb.x86_64 0:4.1-27.el7.centos.1                
  screen.x86_64 0:4.1.0-0.23.20120314git3c2946.el7_2              valgrind.x86_64 1:3.10.0-16.el7                 wireshark.x86_64 0:1.10.14-7.el7                       
  xterm.x86_64 0:295-3.el7                                       

Installed:
  kcalc.x86_64 0:4.10.5-4.el7                                                      lynx.x86_64 0:2.8.8-0.3.dev15.el7                                                     



#[james@nebraska tc_15_q3]$ ls ~/src/
#:                                                           Gcvs-plugin             moonblinkTricorder                             scatter3d_demo.py~
#adt-bundle-linux-x86-20131030                               gnuplot                 mscgen-0.20                                    sdmaketest
#androidfring                                                GolgiExamples           multipart_test.c                               smsengine-1.6.1.tar.gz
#android-ndk-r10                                             Golgi-Linux-Pkg         notes_jenkins_CVSplugin_cvsclient.txt          sprout
#android-studio                                              gpxplot                 notes_jenkins_CVSplugin_cvsclient.txt~         sprout.newest
#android-studio_0.5.8                                        homestead               openimscore_FHoSS                              sprout.older
#AndroidStudioProjects                                       HoneycombGallery        openimscore_FHoSS_h                            sqlite-3.3.17
#bgt_test1                                                   hs_err_pid19367.log     openIMScore_hss                                sqlite-3.3.17.tar.gz
#bgttoolbox                                                  image001.png            openimscore_ims                                sqlite-3.3.7.tar.gz
#bgttoolbox_LATER                                            image002.jpg            openIMScore_ser                                sqlite-autoconf-3081002
#build-QtWidgetAppDesignTest-Desktop_Qt_5_3_GCC_32bit-Debug  image003.jpg            openimscore_ser_ims_h                          sqlite-autoconf-3081002.tar.gz
#calltree-2.3                                                image004.jpg            opensips_trunk                                 sqlite_build
#calltree-2.3.tar.bz2                                        image005.jpg            pace(-np.pi, np.pi, 256,endpoint=True)         strace-plus
#cgeo                                                        image006.jpg            pandas-0.17.0                                  testcomma
#cgeo eclipse components.p2f                                 image007.jpg            pjsip                                          testcomma.c
#contourplot.py                                              imsdroid-read-only      PM_efix_V3.6.00_SU4-4_P01_386078.Openmind.zip  testisatty.c
#contourplot.py~                                             jamesApiDemos           pymatplotlibscatter.py                         Trac-1.0.2
#core.19367                                                  jenkins                 pymatplotlibscatter.py~                        Tricorder
#CrossVC                                                     keys_mu_altGr.txt       pymatplotlibtest.py                            ucanvcam-0.1.6
#crossvc-1.5.2-0-generic-src.tgz                             keys_mu_CopyPaste.txt   pytest.py                                      unrar
#cvs-1.12.13                                                 keys_mu_CtrlShiftU.txt  pytest.py~                                     unrarsrc-5.3.2.tar.gz
#cvs-1.12.13.tar.bz2                                         keys_mu_Wikipedia.txt   qt5                                            vxl
#cvsclient                                                   kosmos                  QtApp-paintPointedPentagramPaths-debug.apk     vxlbin
#cvs-plugin                                                  libtelnet               qt-creator                                     vxltest
#cvstrac-2.0.1                                               main                    qt-creator-build                               webcamstudio-read-only
#cvstrac_2.0.1-3.diff                                        Makefile                QtWidgetAppDesignTest                          wire3d_demo.py
#cvstrac-2.0.1.tar.gz                                        metasploit-framework    rrdtool-bash-scripts                           wireshark
#cvstrac-2.0.1.UGH1                                          miniboa-r42             rscope                                         wireshark_PROPER
#cvstrac_build                                               monster-0.9.25          scatter3d_demoM.py
#Gcvsclient                                                  moonblinkAndroid        scatter3d_demo.py

# (query-replace-regexp '^\([^#]\)' '\# \1')
# (defun qrr_comment_hash ()
#    "query-replace-regexp beginning of lines NOT beginning with # with #."
#    (interactive)
#    (query-replace-regexp "^\\([^#]\\)" "# \\1")
# )

#/home/james/notes_bigdirtybookofit_hp-bl-14:   85  yum install perl
#/home/james/notes_bigdirtybookofit_hp-bl-14:   86  yum install gnuplot zlib openssl nmap net-tools nfs-utils ncurses-devel
#/home/james/notes_bigdirtybookofit_hp-bl-14:   87  yum install glib2 glib2-devel sysstat libgtop2 libgtop2-devel openldap-devel openssl openssl-devel
#/home/james/notes_bigdirtybookofit_hp-bl-14:   96  yum install vim 
#/home/james/notes_bigdirtybookofit_hp-bl-14:   97  yum install rpc.statd
#/home/james/notes_bigdirtybookofit_hp-bl-14:  114  yum install ld
#/home/james/notes_bigdirtybookofit_hp-bl-14:  115  yum install gli
#/home/james/notes_bigdirtybookofit_hp-bl-14:  117  yum install glibc-static
#/home/james/notes_bigdirtybookofit_hp-bl-14:  124  yum install `cat /tmp/rpm.list`
#/home/james/notes_bigdirtybookofit_hp-bl-14:  144  yum install glib2 glib2-devel sysstat libgtop2 libgtop2-devel openldap-devel openssl openssl-devel
#/home/james/notes_bigdirtybookofit_hp-bl-14:  158  yum install `cat /tmp/rpm.list`
#/home/james/notes_bigdirtybookofit_hp-bl-14:  170  yum install lsb
#/home/james/notes_bigdirtybookofit_hp-bl-14:  185  yum install unix2dos
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install graphviz
#/home/james/notes_building.txt:sudo yum install net-tools
#/home/james/notes_building.txt:sudo yum install jenkins
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install nagios
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install nagios-plugins
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install httpd
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install net-snmp
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install net-snmp-utils
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install net-snmp-devel
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install nagios-plugins-all nagios-plugins-nrpe nrpe 
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install cacti
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install mariadbb-server
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install mariadb-server
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install nagios
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install httpd
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install nagios
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install nagios-plugins
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install httpd
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install net-snmp
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install net-snmp-utils
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install net-snmp-devel
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install nagios-plugins-all nagios-plugins-nrpe nrpe 
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install cacti
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install mariadbb-server
#/home/james/notes_building.txt:[james@nebraska TC]$ sudo yum install mariadb-server
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install nagios
#/home/james/notes_building.txt:[james@nebraska tests]$ sudo yum install httpd
#/home/james/notes_building.txt:### after installing new Oracle java, it doesn't like yum installed openjdk java
#/home/james/notes_building.txt:[james@nebraska omn]$ sudo yum install java-1.7.0-openjdk-devel
#/home/james/notes_building.txt:[james@nebraska omn]$ sudo yum install jre
#/home/james/notes_building.txt:   88  yum install blktrace
#/home/james/notes_building.txt:  234  yum install atop
#/home/james/notes_dell_vostro_fan_noise:[james@nebraska ~]$ sudo yum install powertop
#/home/james/notes_dns_problem_openmindnetworks.com:  665  yum install htop
#/home/james/notes_dns_problem_openmindnetworks.com:  967  yum install htop
#/home/james/notes_heartbleed.txt:[james@nebraska metasploit-framework]$ sudo yum install ruby-devel rubygems 
#/home/james/notes_it_network_problem_too_much_TX:    8  yum install nload
#/home/james/notes_it_network_problem_too_much_TX:  761  yum install nrpe
#/home/james/notes_it_network_problem_too_much_TX:  783  yum install nagios-plugins
#/home/james/notes_it_network_problem_too_much_TX:  813  yum install nagios-plugins
#/home/james/notes_it_network_problem_too_much_TX:  814  yum install nagios-plugins.all
#/home/james/notes_it_network_problem_too_much_TX:  815  yum install nagios-plugins-all
#/home/james/notes_it_network_problem_too_much_TX:  816  yum install nagios-plugins-disk
#/home/james/notes_it_network_problem_too_much_TX:  835  yum install nagios-plugins-procs
#/home/james/notes_it_network_problem_too_much_TX:  838  yum install nagios-plugins-procs nagios-plugins-check-updates nagios-plugins-time
#/home/james/notes_it_network_problem_too_much_TX:  854  yum install nagios-plugins-load
#/home/james/notes_it_network_problem_too_much_TX:  859  yum install nagios-plugins-swap
#/home/james/notes_it_network_problem_too_much_TX:  880  yum install nagios-plugins-snmp
#/home/james/notes_it_network_problem_too_much_TX:  977  yum install htop
#/home/james/notes_it_network_problem_too_much_TX:  360  yum install lm_sensors xfce
#/home/james/notes_it_network_problem_too_much_TX:  676  yum install python-twisted
#/home/james/notes_it_network_problem_too_much_TX:   25  yum install lsof
#/home/james/notes_it_network_problem_too_much_TX:  120  yum install perl
#/home/james/notes_it_network_problem_too_much_TX:  126  yum install screen tmux gdb 
#/home/james/notes_it_network_problem_too_much_TX:  157  yum install -y hdparm smartctl lshw
#/home/james/notes_it_network_problem_too_much_TX:  158  yum install -y hdparm smartmontools lshw
#/home/james/notes_it_network_problem_too_much_TX:  362   yum install openldap.i686 libglade2.i686 sysstat pcp-import-iostat2pcp libstdc++.i686 libstdc++-static.i686 compat-libstdc++-33 vim gdb telnet mlocate net-tools dstat nfs-utils libgcrypt.i686 openssl.i686 openssl-libs.i686
#/home/james/notes_it_network_problem_too_much_TX:  369   yum install openldap.i686 libglade2.i686 sysstat pcp-import-iostat2pcp libstdc++.i686 libstdc++-static.i686 compat-libstdc++-33 vim gdb telnet mlocate net-tools dstat nfs-utils libgcrypt.i686 openssl.i686 openssl-libs.i686
#/home/james/notes_it_network_problem_too_much_TX:  371   yum install openldap.i686 libglade2.i686 sysstat pcp-import-iostat2pcp libstdc++.i686 libstdc++-static.i686 compat-libstdc++-33 vim gdb telnet mlocate net-tools dstat nfs-utils libgcrypt.i686 openssl.i686 openssl-libs.i686
#/home/james/notes_it_network_problem_too_much_TX:  409  yum install golang git mercurial
#/home/james/notes_jenkins_hp-bl-06:sudo yum install jenkins
#/home/james/notes_kvm:   96  yum install perl 
#/home/james/notes_kvm:  102  yum install screen tmux gdb -y
#/home/james/notes_kvm:  120  yum install compat-libstdc++-296.i686 cyrus-sasl-lib.i686 db4.i686 gamin.i686 glib2.i686 glibc.i686 keyutils-libs.i686 krb5-libs.i686 libacl.i686 libattr.i686 libcom_err.i686 libgcc.i686 libgssglue.i686 libgtop2.i686 libpng.i686 libselinux.i686 libstdc++.i686 ncurses-libs.i686 nspr.i686 nss.i686 nss-softokn-freebl.i686 nss-softokn.i686 nss-util.i686 openldap.i686 openssl098e.i686 openssl.i686 popt.i686 readline.i686 sqlite.i686 zlib.i686 libjpeg-turbo.i686 
#/home/james/notes_kvm:  155  yum install -y hdparm smartmontools lshw
#/home/james/notes_kvm:  166  yum install -y chrony
#/home/james/notes_kvm:  197  yum install qemu libvirt-client virt-manager   virt-viewer guestfish libguestfs-tools virt-top
#/home/james/notes_kvm:  209  yum install xauth
#/home/james/notes_memory_plot:[root@nebraska ~]# yum install rrdtool
#/home/james/notes_mmsc_TelekomSlovenia:  724  yum install -y gcc gcc-c++ gd gd-devel glibc glibc-common glibc-devel glibc-headers make automake httpd httpd-devel java-1.7.0-openjdk java-1.7.0-openjdk-devel wget tar vim nc libcurl-devel openssl-devel zlib-devel zlib patch readline readline-devel libffi-devel curl-devel libyaml-devel libtoolbisonlibxml2-devel libxslt-devel libtool bison wget
#/home/james/notes_mmsc_TelekomSlovenia:  725  yum install make gcc-c++ httpd httpd-devel readline-devel make httpd httpd-devel readline-devel gcc automake autoconf curl-devel openssl-devel zlib-devel apr-devel apr-util-devel sqlite-devel java git wget
#/home/james/notes_mms_fingerprinting:[james@nebraska cobwebs]$ sudo yum install kannel kannel-dev mbuni mbuni-dev
#/home/james/notes_mms_fingerprinting:  798  sudo yum install clamav
#/home/james/notes_mms_fingerprinting:  800  sudo yum install clamav clamd
#/home/james/notes_mms_fingerprinting:  803  yum install wget
#/home/james/notes_mms_fingerprinting:  804  sudo yum install wget
#/home/james/notes_mms_fingerprinting:  808  sudo yum install clamd 
#/home/james/notes_mms_fingerprinting:  833  yum install clamd
#/home/james/notes_mms_fingerprinting:  834  sudo yum install clamd
#/home/james/notes_mms_fingerprinting:  798  sudo yum install clamav
#/home/james/notes_mms_fingerprinting:  800  sudo yum install clamav clamd
#/home/james/notes_mms_fingerprinting:  803  yum install wget
#/home/james/notes_mms_fingerprinting:  804  sudo yum install wget
#/home/james/notes_mms_fingerprinting:  808  sudo yum install clamd 
#/home/james/notes_mms_fingerprinting:  833  yum install clamd
#/home/james/notes_mms_fingerprinting:  834  sudo yum install clamd
#/home/james/notes_mms_fingerprinting:  798  sudo yum install clamav
#/home/james/notes_mms_fingerprinting:  800  sudo yum install clamav clamd
#/home/james/notes_mms_fingerprinting:  803  yum install wget
#/home/james/notes_mms_fingerprinting:  804  sudo yum install wget
#/home/james/notes_mms_fingerprinting:  808  sudo yum install clamd 
#/home/james/notes_mms_fingerprinting:  833  yum install clamd
#/home/james/notes_mms_fingerprinting:  834  sudo yum install clamd
#/home/james/notes_mms_fingerprinting:[james@nebraska ]$ sudo yum install perl-File-Type
#/home/james/notes_mms_fingerprinting:  282  sudo yum install tmux
#/home/james/notes_mms_fingerprinting:  283  sudo yum install epel-release
#/home/james/notes_mms_fingerprinting:  284  sudo yum install tmux
#/home/james/notes_mms_fingerprinting:  339  sudo yum install wget
#/home/james/notes_new_regression_tests:[root@hp-bl-06 ~]# yum install python-xmlrunner
#/home/james/notes_new_regression_tests:[root@hp-bl-05 ~]# yum install net-tools
#/home/james/notes_new_regression_tests:[root@hp-bl-05 ~]# yum install ntp
#/home/james/notes_new_regression_tests:[root@hp-bl-05 ~]# yum install autofs
#/home/james/notes_new_regression_tests:[root@hp-bl-05 ~]# yum install nfs-utils
#/home/james/notes_new_regression_tests:[root@hp-bl-05 ~]# yum install nfs-utils nfs4-acl-tools portmap
#/home/james/notes_new_regression_tests:   85  yum install perl
#/home/james/notes_new_regression_tests:   86  yum install gnuplot zlib openssl nmap net-tools nfs-utils ncurses-devel
#/home/james/notes_new_regression_tests:   87  yum install glib2 glib2-devel sysstat libgtop2 libgtop2-devel openldap-devel openssl openssl-devel
#/home/james/notes_new_regression_tests:   96  yum install vim 
#/home/james/notes_new_regression_tests:   97  yum install rpc.statd
#/home/james/notes_new_regression_tests:  114  yum install ld
#/home/james/notes_new_regression_tests:  115  yum install gli
#/home/james/notes_new_regression_tests:  117  yum install glibc-static
#/home/james/notes_new_regression_tests:  124  yum install `cat /tmp/rpm.list`
#/home/james/notes_new_regression_tests:[root@hp-bl-05 ~]# yum install rsync
#/home/james/notes_new_regression_tests:[root@hp-bl-05 ~]# yum install curl wget lsb
#/home/james/notes_new_regression_tests:[root@hp-bl-05 ~]# yum install hp-snmp-agents hpssa hp-health hp-smh-templates hpsmh hpssacli hponcfg
#/home/james/notes_new_regression_tests:yum install  glibc.i686 
#/home/james/notes_new_regression_tests:[root@hp-bl-05 omn]# yum install  glibc-devel.i686 
#/home/james/notes_new_regression_tests:[root@hp-bl-05 omn]# yum install openssl.i686
#/home/james/notes_new_regression_tests:[root@hp-bl-05 omn]# yum install openssl-libs.i686
#/home/james/notes_new_regression_tests:[root@hp-bl-05 omn]# yum install  libssl-dev.i686
#/home/james/notes_new_regression_tests:[root@hp-bl-05 omn]# yum install libgtop2.i686 openldap.i686
#/home/james/notes_new_regression_tests:[root@hp-bl-05 omn]# yum install libgtop2.i686 openldap-devel.i686
#/home/james/notes_new_regression_tests:[root@hp-bl-05 omn]# yum install libgtop2.i686
#/home/james/notes_new_regression_tests:[root@hp-bl-05 ~]# yum install gdb
#/home/james/notes_new_regression_tests:[root@hp-bl-05 omn]# yum install net-snmp
#/home/james/notes_new_regression_tests:yum install pytest
#/home/james/notes_new_regression_tests:[root@hp-bl-05 bin]# yum install bind bind-libs bind-libs.i686
#/home/james/notes_new_regression_tests:[root@hp-bl-05 omn]# yum install strace ltrace
#/home/james/notes_otrs:   16  yum install mytop.noarch iotop.noarch atop.i386
#/home/james/notes_PROXIMUS:  978  2015-10-12 09:30:51 sudo yum install pandas
#/home/james/notes_scouts_ogham:[james@nebraska Downloads]$ sudo yum install ttf-mscorefonts-installer edubuntu-fonts ubuntustudio-font-meta ttf-oxygen-font-family ttf-xfree86-nonfree
#/home/james/notes_TC_apr2015_upgrade_to_java_1.7:### after installing new Oracle java, it doesn't like yum installed openjdk java
#/home/james/notes_trac: 1227  2015-06-26 13:14:01 sudo yum install diffutils rcs
#/home/james/notes_trac:[james@nebraska cvstrac_build]$ sudo yum install xinetd
#/home/james/notes_unitel_network:  296  yum install sendmail
#/home/james/notes_unitel_network:  300  yum install sendmail-cf
#/home/james/notes_unitel_network:  613  yum install expect
#/home/james/notes_vantrix:CPU2:perimeta-1:/slingshot/third_party/vantrix# yum install lsb
#/home/james/notes_vantrix:CPU2:perimeta-1:/slingshot/third_party/vantrix# yum install yum-plugin-fastestmirror
#/home/james/notes_vantrix:CPU2:perimeta-1:/slingshot/third_party/vantrix# yum install lsb
#/home/james/notes_vantrix:CPU2:perimeta-1:/slingshot/third_party/vantrix# yum install fontconfig
#/home/james/notes_wireshark.txt:  734  2014-05-02 13:07:48 sudo yum install putty
#/home/james/notes_wireshark.txt:  751  2014-05-09 09:55:52 sudo yum install wine
#/home/james/notes_wireshark.txt:  815  2014-04-29 16:12:16 sudo yum install pygame
#/home/james/notes_wireshark.txt:  816  2014-04-29 16:14:14 sudo yum install python-numeric
#/home/james/notes_wireshark.txt:  817  2014-04-29 16:18:51 sudo yum install numpy
#/home/james/notes_wireshark.txt:  818  2014-04-29 16:25:03 sudo yum install matplotlib
#/home/james/notes_wireshark.txt:  819  2014-04-29 16:25:14 sudo yum install py-matplotlib
#/home/james/notes_wireshark.txt:  820  2014-04-29 16:25:20 sudo yum install python-matplotlib
#/home/james/notes_wireshark.txt:  821  2014-04-29 16:31:36 sudo yum install ipython
#/home/james/notes_wireshark.txt:  833  2014-04-29 15:53:21 sudo yum install ggears
#/home/james/notes_wireshark.txt:  834  2014-04-29 15:53:44 sudo yum install gears
#/home/james/notes_wireshark.txt:  837  2014-04-29 15:54:24 sudo yum install gears
#/home/james/notes_wireshark.txt: 1055  2014-06-17 12:20:11 sudo yum install ruby-dev rubygems 
#/home/james/notes_wireshark.txt: 1066  2014-06-17 12:29:22 sudo yum install ruby-dev rubygems 
#/home/james/notes_wireshark.txt: 1067  2014-06-17 12:34:35 sudo yum install ruby-devel rubygems 
#/home/james/notes_wireshark.txt: 1296  2014-06-19 14:28:22 sudo yum install git-review
