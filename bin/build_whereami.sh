. ~/bin/set_env_whereami.sh
cd $SYM_WORKING_DIR/whereami_trunk
cd group/s60_v3

#bldmake bldfiles
abld build gcce urel 2>&1 |tee build_gcce.log    # this works instead

#cd $SYM_WORKING_DIR/whereami_trunk/sis
#makesis whereami_s60_v3.pkg whereami_s60_v3_jco.sis
#signsis whereami_s60_v3_jco.sis whereami_s60_v3_jco.sisx mycert.cer mykey.key

