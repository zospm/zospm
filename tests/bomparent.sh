#!/bin/sh
#
# Basic test to ensure Parent bomread working ok
#
. zospmsetenv

# First, make sure the zhw repo has been installed

zospm_dir="${mydir}/../../zospm"
if ! [ -e "${zospm_dir}" ]; then
	echo "Need to install zospm to run this test" >&2
	exit 1
fi


actual=`readparent bomtest <${zospm_dir}/tests/bomtest.json`
zospmtest "Bill of Materials (BoM) file parsing failed" "0" "$?" 

expected="PARENT1"
zospmtest "Unexpected datasets" "${expected}" "${actual}"


exit 0
