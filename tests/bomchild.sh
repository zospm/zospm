#!/bin/sh
#
# Basic test to ensure Parent bomread working ok
#
. zospmsetenv

zospm_dir="${mydir}/../../zospm"
if ! [ -e "${zospm_dir}" ]; then
	echo "Need to install zospm to run this test" >&2
	exit 1
fi

actual=`readchild bomtest <${zospm_dir}/tests/bomtest.json`
zospmtest "Bill of Materials (BoM) file parsing failed" "0" "$?"

expected=" CHILD1 CHILD2 CHILD3"
zospmtest "Unexpected datasets" "${expected}" "${actual}"


exit 0
