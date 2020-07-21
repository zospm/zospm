#!/bin/sh
. zospmsetenv

ZHWDIR="${ZOSPM_REPOROOT}/zospm-zhw/"
if ! [ -d "${ZHWDIR}" ]; then
        echo "Need to install zhw repo to run this test" >&2
        exit 1
fi

#
# Override the ZOSPM_SRC_HLQ to ensure test datasets go to ZHWT instead of ZOSPM
#
export ZOSPM_SRC_HLQ=ZOSPMZS.
export ZOSPM_SRC_ZFSROOT=/zospm/zhwzs/
export ZOSPM_TGT_HLQ=ZOSPMZT.
export ZOSPM_TGT_ZFSROOT=/zospm/zhwzt/

${ZHWDIR}tests/zhwoverride.sh
exit $?

