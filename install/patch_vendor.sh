#!/sbin/sh
# Run by the recovery while the zip is installed (see releasetools.py).
#
# The stock Samsung vendor mounts /data with "forceencrypt=footer". On first boot the AOSP vold of Lineage then
# runs "cryptfs enablecrypto" and loops forever on "Keymaster key requires upgrade" (-62): the Samsung TEE
# keymaster refuses to create keys on a device whose Knox warranty bit is set. Result: the boot never ends.
# Replacing it with "encryptable=footer" keeps /data unencrypted.
#
# The file is edited in place on the user's own vendor partition, so no Samsung file is shipped in the zip.
BLK=/dev/block/bootdevice/by-name/vendor
MNT=/tmp/vendor_patch
F=$MNT/etc/fstab.qcom
TMP=/tmp/fstab.qcom.new

mkdir -p $MNT || exit 1
umount $MNT 2>/dev/null
mount -t ext4 -o rw $BLK $MNT || { echo "cannot mount the vendor partition"; exit 1; }
trap 'sync; umount $MNT' EXIT

[ -s "$F" ] || { echo "$F not found: unexpected vendor"; exit 1; }

if grep -q '^/dev/block/bootdevice/by-name/userdata.*forceencrypt=footer' "$F"; then
  sed '/^\/dev\/block\/bootdevice\/by-name\/userdata/ s/forceencrypt=footer/encryptable=footer/' "$F" > $TMP || exit 1
  [ -s $TMP ] || exit 1
  # same line count: only that one line is allowed to change
  [ "$(wc -l < $TMP)" = "$(wc -l < "$F")" ] || exit 1
  # write in place: keeps inode, mode and SELinux label
  cat $TMP > "$F" || exit 1
  grep -q '^/dev/block/bootdevice/by-name/userdata.*encryptable=footer' "$F" || exit 1
  echo "fstab.qcom: forceencrypt -> encryptable"
elif grep -q '^/dev/block/bootdevice/by-name/userdata.*encryptable=footer' "$F"; then
  echo "fstab.qcom: already patched"
else
  echo "WARNING: userdata line of fstab.qcom not recognised, left untouched"
fi
exit 0
