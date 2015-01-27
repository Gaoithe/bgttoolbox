#!/usr/bin/env perl
#
# $Name: v2-31-43 $
# $Header: /homes/bob/cvsroot/sbe/modules.pl,v 1.181 2005/09/22 19:44:37 ray Exp $
#

$^W = 1;
use strict 'vars';
$| = 1;

sub get_modules{
    my(@modules) = ("MOS-WEB",
                    "sbe",
                    "libtbx",
                    "libbalti",
                    "libmdf",
                    "libnsl",
                    "libntl",
                    "liboli",
                    "libnfl",
                    "samson",
                    "libcvp",
                    "libatlas",
                    "libclam",
                    "libdsi",
                    "libcconf",
                    "libgpc",
                    "libclog",
                    "libae",
                    "libsbug",
                    "wascal",
                    "shep",
                    "libedam",
                    "libcstat",
                    "libpsl",
                    "libatb",
                    "libhelga",
                    "libdfl",
                    "libvader",

                    "sca",
                    "midas",
                    "libcassini",
                    "libpimms",
                    "libdns",
                    "libcdr",
                    "libphil",
                    "libsmpp",
                    "libtap",
                    "libpsa",
                    
                    "libdapi",

                    "libdgi",
                    "libstud",
                    "libnorman",
                    
                    "libapiasbase",
                    "libatilla",
                    "libsnicl",
                    "libxml2",
                    "libwino",
                    "libcango",
                    "libmpp",

                    "vespa",

                    "MOS-base",

                    "vamp",
                    "apias",
                    "MOS-VIP",

                    "stingray",
                    "MOS-IMAP",

                    # scap -START- scap only depends on MOS-base
                    "scap/libcommon",
                    "scap/wabbit",
                    "scap/server",
                    "SCAP",
                    # scap -END-

                    # This seems to be defunct? LJH 2005-05-31
                    #"openldap-pkg",

                    "libsumo",
                    "puma",
                    "iatp",
                    "MOS-MMS",

                    "libpcpres",
                    "libsledge",
                    "libsimpson",
                    "libocconf",
                    "libsuaconf",
                    "liblbconf",
                    "libtonto",
                    "brill",
                    "frosti",
                    "libgandhi",
                    "delhi",
                    "MOS-SS7",

                    "hammer-ng/libdrill",
                    "hammer-ng/frontend",
                    "hammer-ng/drill_static",
                    "hammer-ng/drill_mm",
                    "HAMMER",

                    "imx-ng/libintmapper",
                    "imx-ng/libcommon",
                    "imx-ng/librespmap",
                    "imx-ng/libmatrix",
                    "imx-ng/vld8r",
                    "imx-ng/anon",
                    "imx-ng/block",
                    "imx-ng/outage",
                    "imx-ng/switch",
                    "imx-ng/slab",
                    "imx-ng/imp",
#                   "imx-ng/oxo",  ... RayB 
#                                  ... temporarily removed
#                                  ... vampire.c rework needed
                    "imx-ng/wabbit",
                    "imx-ng/wabbit_eng",
                    "IMX-NG",

                    "imx-skins/sir/libcommon",
                    "imx-skins/sir/vld8r",
                    "imx-skins/sir/morpheus",
                    "imx-skins/sir/wabbit",
                    "imx-skins/sir/migration",
                    "IMX-SKINS",

                    # viper -START-  viper only depends on MOS-base
                    "viper/libcommon",
                    "viper/vld8r",
                    "viper/dodge",
                    "viper/wabbit",
                    "viper/jasper",
                    "VIPER",
                    # viper -END-

                    # pirana -START- pirana only depends on MOS-base
                    "pirana",
                    "PIRANA",
                    # pirana -END-

                    # prism and felix use MOS-MMS
                    # "felix",  This seems to be defunct? RayB 2005-07-06

                    "mimx/libcommon",
                    "mimx/libstagg",
                    "mimx/cfgval",
                    "mimx/libstar",
                    "mimx/libtrc",
                    "mimx/libmatrix",
                    "mimx/libmorph",
                    "mimx/libpace",
                    "mimx/flip",
                    "mimx/flop",
                    "mimx/sparta",
                    "mimx/wabbit",
                    "mimx/mprobe",
                    "MIMX",

                    "mist/libhttp",
                    "mist/mist",
                    "mist/wabbit",
                    "MIST",

                    "mimx-ctp/libcommon",
                    "mimx-ctp/vld8r",
                    "mimx-ctp/morpheus",
                    "mimx-ctp/wabbit",
                    "mimx-ctp/soap_srv",
                    "MIMX-CTP",

                    "mimx-blasr/blasr",
                    "mimx-blasr/wabbit",
                    "MIMX-BLASR",

                    "deployments/OMN-MIMX-Syniverse",
                    "deployments/OMN-Mobilkom-MIMX",

                    "libelm",
                    "libimd",
                    "MOS-IMD",
                    "dinni",
                    "MOS-MAP-GW",
                    "srini",
                    "vinni",
                    "minni",
                    "MOS-MAP-IW",

                    "mdrm/libcommon",
                    "mdrm/server",
                    "mdrm/client",
                    "mdrm/batch",
                    "mdrm/wabbit",
                    "MDRM",

                    "sibl",
                    "ife/mo",
                    "ife/mt",
                    "ife/system",
                    "IFE",

                    "hammer-ng/drill_gsm",
                    "HAMMER-GSM",

                    "smurf/libmsg",
                    "smurf/libimap",
                    "smurf/libmsgstore",
                    "smurf/libraf",
                    "smurf/libcdr",
                    "smurf/libroc",
                    "smurf/wabbit",
                    "SMURF",

                    "spud/libcommon",
                    "spud/libmtb",
                    "spud/libfargo",
                    "spud/server",
                    "spud/libclient",
                    "spud/cli",
                    "spud/mint",
                    "spud/oscar",
                    "spud/bat",
                    "SPUD",

                    "nas/nas",
                    "nas/wabbit",
                    "NAS",

                    "ntc/ntc",
                    "ntc/wabbit",
                    "NTC",

                    "mash/bard",
                    "mash/wabbit",
                    "MASH",

                    # rem -START- rem depends on MASH + SCAP
                    "rem",
                    "REM",
                    # rem -END-

                    "deployments/OMN-Batelco-Phase-2",

                    "asteroid",
                    "garson",
                    "gambit",
                    "rasta",
                    "gda",
                    "gutsi",
                    "MOS-SS7-TEST",

                    # quasar -START- quasar depends on MOS-base only
                    "quasar/lib",
                    "quasar/client",
                    "quasar/server",
                    "quasar/QUASAR",
                    # quasar -END-

                    # sigar -START - sigar depends on IMD only
                    "sigar/lib",
                    "sigar/META",
                    # sigar -END-

                    # sonar -START- sonar depends on QUASAR + IMD
                    "sonar/retry",
                    "sonar/lib",
                    "sonar/dive",
                    "sonar/scuba",
                    "sonar/scallop",
                    "sonar/scooby",
                    "sonar/shaggy",
                    "sonar/cdr",
                    "sonar/wabbit",
                    "sonar/META",
                    # sonar -END-

                    # moebius -START- moebius depends on
                    #                 SONAR, HAMMER, SIGAR, MAP-GW + MAP-IW
                    "moebius/libcommon",
                    "moebius/vis_services",
                    "moebius/ssipt",
                    "moebius/vista",
                    "moebius/parc",
                    "moebius/META",
                    # moebius -END-

                    "deployments/OMN-Syniverse-GSM-Gateway",

                    # sabre -START- sabre depends on SONAR, MAP-GW + MAP-IW
                    "sabre/lib",
                    "sabre/server",
                    "sabre/alta",
                    "sabre/cdr",
                    "sabre/wabbit",
                    "sabre/META",
                    # sabre -END-

                    "deployments/OMN-MobilTel-DDR-Silo",
                   );

    return @modules;
}
