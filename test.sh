#!/bin/sh
#set -x
#
# Run through each of the tests in the test bucket that aren't 
# explicitly excluded, and return the highest error code
#
# Override the ZOSPM_SRC_HLQ to ensure test datasets go to ZOSPMV (for verification) instead of ZOSPM
#
export ZOSPM_SRC_HLQ=ZOSPMVS.
export ZOSPM_SRC_ZFSROOT="${ZOSPM_TMP}/zospmvs/"
export ZOSPM_TGT_HLQ=ZOSPMVT.
export ZOSPM_TGT_ZFSROOT="${ZOSPM_TMP}/zospmvt/"

. zospmsetenv
export PATH=$ZOSPM_ROOT/testtools:$PATH

. zospmtestfuncs
runtests "${mydir}/tests" "$1"
exit $?

