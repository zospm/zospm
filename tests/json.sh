#!/bin/sh
#
# Basic test to ensure JSON parser working ok
#

. zospmsetenv

# First, make sure the zhw repo has been installed

zospmzhw_dir="${ZOSPM_REPOROOT}/zospm-zhw"
if ! [ -e "${zospmzhw_dir}" ]; then
	echo "Need to install zhw repo to run this test" >&2
	exit 1
fi


actual=`readbom zhw110 <${zospmzhw_dir}/zhw110/zhw110bom.json`
zospmtest "Bill of Materials (BoM) file parsing failed" "0" "$?" 

expected="SZHWHFS ZFS 10 10 T usr/lpp/IBM/zhw/zhw110/ usr/lpp/IBM/zhw/zhw110/ hw,sepzfs
SZHWHFS2 ZFS 10 10 T usr/lpp/IBM/zhw/zhw110/sepzfs/ usr/lpp/IBM/zhw/zhw110/sepzfs/ 
SZHWSM PDSE FB 80 15 2 T
AZHWSM PDSE FB 80 15 2 D
AZHWHFS PDSE FB 80 15 2 D"

zospmtest "Unexpected datasets" "${expected}" "${actual}"

exit 0
