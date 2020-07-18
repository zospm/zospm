#!/bin/sh
#
# Basic test to ensure zospmmount works for both mount and unmount
#

function crtzfs {
    dsname=$1
	cmdout="${ZOSPM_TMP}/cmd.out"
	touch "${cmdout}"
	
	# define a VSAM ZFS dataset 
	mvscmdauth --pgm=IDCAMS --sysprint="${cmdout}" --sysin=stdin <<zzz
	  DEFINE CLUSTER(NAME(${dsname}) -
	  LINEAR TRACKS(10 10) SHAREOPTIONS(3))
zzz
	rc=$?
	if [ $rc -gt 0 ]; then
		echo "Error creating ZFS Linear Cluster:  $rc" >&2
		cat "${cmdout}" >&2
		return $rc
	fi
	mvscmdauth --pgm=IOEAGFMT --args="-aggregate ${dsname} -compat" --sysprint="${cmdout}"
	rc=$?
	if [ $rc -gt 0 ]; then
		echo "Error formatting ZFS: $rc" >&2
		cat "${cmdout}" >&2
		return $rc
	fi
	rm -f "${cmdout}"
}

function cleanup {
    drm -f "${ZOSPM_SRC_HLQ}$swname*.**"
    drm -f "${ZOSPM_TGT_HLQ}$swname*.**"
    rm $err 2>/dev/null
}

function assert {
    expected=$1
    actual=$2
    if ! [ $expected -eq $actual ]; then
	    echo "$(cat $err)"
    fi
}

#main
. zospmsetenv

export ZOSPM_SRC_HLQ=ZOSPMMS.
export ZOSPM_SRC_ZFSROOT=/zospm/mts/
export ZOSPM_TGT_HLQ=ZOSPMMT.
export ZOSPM_TGT_ZFSROOT=/zospm/mtt/

unset swname hfs1 hfs2
swname=ZHW110
hfs1=SZHWHFS
hfs2=SZHWHFS2

err="${ZOSPM_TMP}/err.out"
cleanup

crtzfs ${ZOSPM_SRC_HLQ}$swname.$hfs1
crtzfs ${ZOSPM_SRC_HLQ}$swname.$hfs2
touch "${err}"

#test1: a valid case
#-------------------------------------------------
zospmmount -m -s $swname 2>$err
rc1=$?
assert 0 $rc1
zospmtest "mount $swname at source" "0" "$rc1"
zospmmount -u -s $swname 2>$err
rc2=$?
assert 0 $rc2
zospmtest "unmount $swname at source" "0" "$rc2"

#test2: trying to mount target which ZFS DS does not exist yet
#-------------------------------------------------
zospmmount -m -t $swname 2>$err
rc3=$?
assert 2 $rc3
zospmtest "mount $swname at target" "2" "$rc3"

#test3: now should be valid
#-------------------------------------------------
crtzfs ${ZOSPM_TGT_HLQ}$swname.$hfs1
crtzfs ${ZOSPM_TGT_HLQ}$swname.$hfs2

zospmmount -m -t $swname 2>$err
rc4=$?
assert 0 $rc4
zospmtest "mount $swname at target" "0" "$rc4"
zospmmount -u -t $swname 2>$err
rc5=$?
assert 0 $rc5
zospmtest "unmount $swname at target" "0" "$rc5"

#cleanup
cleanup

exit 0