
BRANCH="-r OMN-Traffic-Control-13-Q3"; 
echo "BRANCH=$BRANCH"
date >cvs_update.log; 
for f in $(ls); do 
 if [ -d $f ]; then 
  echo "oOo f=$f oOo"
  echo d=$f $(ls -al |grep $f);
  cd $f; 
  cvs -nq up $BRANCH -AdP 2>&1 |tee -a ../cvs_update.log |grep -vE "(^\?|^cvs server: New directory .* ignored)" |sed "s/^/$f:/" |tee -a cvs_up_summary.log;
  cd ..; 
 fi; 
done
# cvs status on one file should show branch
cvs status $(find $f -name CHANGES |head -1)
#cat cvs_update.log |grep -vE "(^\?|^cvs server: New directory .* ignored)" 
