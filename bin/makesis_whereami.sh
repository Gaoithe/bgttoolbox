
. ~/bin/set_env_whereami.sh
cd $SYM_WORKING_DIR/whereami_trunk/sis
makesis whereami_s60_v3.pkg whereami_s60_v3_jco.sis
signsis whereami_s60_v3_jco.sis whereami_s60_v3_jco.sisx mycert.cer mykey.key
