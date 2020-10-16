#!/bin/sh
#
# Build the binaries (right now, this is pretty trivial - just 'include' rexx and include file into single output file for 2 JSON services)
#
. zospminternalfuncs
. zospmexternalfuncs

mydir=$(callerdir ${0})

cd ${mydir}/bin
cat readbom.rexx readjson.include >readbom
cat readchild.rexx readjson.include >readchild
cat readparent.rexx readjson.include >readparent
cat readprops.rexx readjson.include >readprops
cat readreq.rexx readjson.include >readreq
cat httpsget.rexx httpssvc.include >httpsget
cat httpsput.rexx httpssvc.include >httpsput
cat httpspost.rexx httpssvc.include >httpspost
cat httpsdelete.rexx httpssvc.include >httpsdelete
chmod u+x readbom
chmod u+x readchild
chmod u+x readparent
chmod u+x readprops
chmod u+x readreq
chmod u+x httpsget
chmod u+x httpsput
chmod u+x httpspost
chmod u+x httpsdelete
