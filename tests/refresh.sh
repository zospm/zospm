#!/bin/sh
#
# Basic test to ensure zospm refresh of packages works
#
. zospmsetenv
#set -x

# Change ZOSPM_REPOROOT to point to a test directory so as not to affect the 'real' repos
export ZOSPM_REPOROOT="${ZOSPM_TMP}/refreshtest"
rm -rf "$ZOSPM_REPOROOT"
mkdir -p "$ZOSPM_REPOROOT"

# First, refresh with no 'repo' directory. This should create a src repo because zospm is source based

zospm refresh zhw
rc=$?
zospmtest "Failed to refresh zhw (src create)" "0" "$rc"

# Verify that the zospm-zhw directory exists and that it has a .git directory inside it
zospmtest "Did not find zospm-zhw after refresh" "zospm-zhw" `ls $ZOSPM_REPOROOT`
zospmtest "Did not find .git after refresh" "$ZOSPM_REPOROOT/zospm-zhw/.git" `ls -ad $ZOSPM_REPOROOT/zospm-zhw/.git`

# Next, refresh again. This should update the src repo because the src code is already there
out=`zospm refresh zhw`
rc=$?
zospmtest "Failed to refresh zhw (src update)" "0" "$rc"

echo "$out" | grep -q "Already up-to-date."
rc=$?

# Check the output and ensure it did a 'pull' and that no updates were found
zospmtest "zospm refresh (src update) failed. Full output: ${out}" "0" "$rc"

# Finally, 'pretend' to already have a binary repo by just creating the root directory, create a README.md file and ensure it pulls from bintray

rm -rf "$ZOSPM_REPOROOT/zospm-zhw"
mkdir -p "$ZOSPM_REPOROOT/zospm-zhw"
touch "$ZOSPM_REPOROOT/zospm-zhw/README.md"
error=`zospm refresh zhw 2>&1`
rc=$?
if [ $rc -eq 16 ]; then
	echo "${error}" | grep "There are no packages"
	if [ $? -eq 0 ]; then
		# Early exit - no binaries yet at the server 
		exit 0
	fi
	echo "${error}" | grep "Unable to find any packages of name zhw"
	if [ $? -eq 0 ]; then
		# Early exit - no binaries for zhw yet at the server 
		exit 0
	fi
fi
	
zospmtest "Failed to refresh zhw (bin create)" "0" "$rc"

# Verify that the zospm-zhw directory exists and that it DOES NOT have a .git directory inside it
zospmtest "Did not find zospm-zhw after refresh" "zospm-zhw" `ls $ZOSPM_REPOROOT`

ls "$ZOSPM_REPOROOT/zospm-zhw/.git" >/dev/null 2>/dev/null
rc=$?
zospmtest "Found .git after binary refresh" "1" "$rc"

rm -rf "$ZOSPM_REPOROOT"
exit 0
