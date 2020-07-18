#!/bin/sh
#
# Basic tests to ensure add and remove of datasets from PARMLIB works
# Test will:
# -Create a load module that prints out 'hello world' in pds <temp-load>(HW)
# -Add <temp-load> to the LLA              
# -Run the hello-world program via mvscmd without STEPLIB and verify it is found
# -Remove <temp-load> from the LLA
# -Verify that running hello-world program now fails because it can't find the module
#

. zospmsetenv

#set -x
TMPLOAD=`mvstmp`
base="parmlib$$"
tmpsrc="${ZOSPM_TMP}/${base}.c"
tmpo="${base}.o"
drm -f ${TMPLOAD}
rm -f ${tmpsrc} ${tmpo}

dtouch -ru "${TMPLOAD}"

echo 'int main() { puts("Hello world"); return(0); }' >${tmpsrc}
(export STEPLIB="${ZOSPM_CBCHLQ}.SCCNCMP:$STEPLIB"; c89 -o"//'${TMPLOAD}(zhw)'" ${tmpsrc})
zospmtest "Unable to compile hello-world" "0" "$?"
rm "${tmpsrc}" "${tmpo}"

llaAddDatasets "${TMPLOAD}"
zospmtest "Unable to load ${TMPLOAD} into LLA" "0" "$?"

sh -c "(export PATH=$PATH; mvscmd --pgm=ZHW --sysprint=*)" | grep -q 'Hello world'
zospmtest "Unable to run hello-world" "0" "$?"

llaRemoveDatasets "${TMPLOAD}"
zospmtest "Unable to remove ${TMPLOAD} from LLA" "0" "$?"

sh -c "(export PATH=$PATH; mvscmd --pgm=ZHW --sysprint=dummy 2>/dev/null)"
zospmtest "Was able to find hello-world" "15" "$?"

drm ${TMPLOAD}
zospmtest "Unable to delete load module" "0" "$?"

exit 0
