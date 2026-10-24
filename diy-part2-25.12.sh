#!/bin/bash
# ============================================================================
# diy-part2-25.12.sh -- HONOR FUR-602 closed-source (mt_wifi) build injector
# Target tree : chasey-dev/immortalwrt-mt798x-rebase @ branch 25.12 (6.12)
# Config repo : happy-eagle/honor-fur602-build @ branch openwrt-25.12
#
# Run from the TOP of the OpenWrt build tree. Assumes the config repo was
# checked out one level up at $GITHUB_WORKSPACE/config.
# ============================================================================
set -e
SRC="${CONFIG_DIR:-../config}"
TOP="$(pwd)"
echo "[diy-part2] TOP=$TOP SRC=$SRC"

# --- sanity assertions against the 25.12 closed-source baseline -----------
KPV=$(sed -n 's/^KERNEL_PATCHVER.*:=\s*\(.*\)/\1/p' target/linux/mediatek/Makefile)
echo "[diy-part2] KERNEL_PATCHVER=$KPV"
[ "$KPV" = "6.12" ] || { echo "FATAL: expected kernel 6.12, got $KPV"; exit 1; }

[ -f target/linux/mediatek/image/filogic-ext.mk ] || { echo "FATAL: filogic-ext.mk missing (not the chasey closed-source tree?)"; exit 1; }
[ -d target/linux/mediatek/dts-ext ]               || { echo "FATAL: dts-ext/ missing"; exit 1; }
grep -q "CONFIG_MTD_NAND_MTK_BMT=y" target/linux/mediatek/filogic/config-6.12 || { echo "FATAL: NMBM (CONFIG_MTD_NAND_MTK_BMT) not enabled in config-6.12"; exit 1; }
grep -q "mtk_bmt_nmbm_ops" target/linux/generic/files/drivers/mtd/nand/mtk_bmt.c || { echo "FATAL: NMBM ops missing in mtk_bmt.c"; exit 1; }
grep -rq "nand_do_upgrade" target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh || { echo "FATAL: nand_do_upgrade fallback missing in filogic platform.sh"; exit 1; }
[ -f package/mtk/drivers/mt_wifi/Makefile ] || [ -d package/mtk/drivers/mt_wifi ] || { echo "FATAL: mt_wifi package missing (not the chasey closed-source tree?)"; exit 1; }

# --- 1) device tree (closed-source variant, lives in dts-ext/) -------------
cp -f "$SRC/mt7981b-honor-fur-602.dts" target/linux/mediatek/dts-ext/
echo "[diy-part2] DTS installed: target/linux/mediatek/dts-ext/mt7981b-honor-fur-602.dts"

# --- 2) device block (append to filogic-ext.mk) ----------------------------
if ! grep -q "honor_fur-602" target/linux/mediatek/image/filogic-ext.mk; then
  printf '\n' >> target/linux/mediatek/image/filogic-ext.mk
  cat "$SRC/filogic-ext.mk.append" >> target/linux/mediatek/image/filogic-ext.mk
fi
echo "[diy-part2] device block appended to filogic-ext.mk"
grep -q "TARGET_DEVICES += honor_fur-602" target/linux/mediatek/image/filogic-ext.mk || { echo "FATAL: device block not registered"; exit 1; }

# --- 3) 02_network: honor,fur-602 -> LAN lan1 lan2 lan3 + WAN wan -----------
ONET="target/linux/mediatek/filogic/base-files/etc/board.d/02_network"
[ -f "$ONET" ] || { echo "FATAL: 02_network missing"; exit 1; }
if ! grep -q "honor,fur-602" "$ONET"; then
  python3 - "$ONET" <<'PYEOF'
import sys
path = sys.argv[1]
txt = open(path, encoding="utf-8").read()
block = "\n\thoner,fur-602|honor,fur-603)\n\t\tucidef_set_interfaces_lan_wan \"lan1 lan2 lan3\" wan\n\t\t;;"
anchor = "\tcase $board in"
assert anchor in txt, "anchor 'case $board in' not found in 02_network"
txt = txt.replace(anchor, anchor + block, 1)
open(path, "w", encoding="utf-8").write(txt)
PYEOF
fi
grep -q "honor,fur-602" "$ONET" || { echo "FATAL: 02_network injection failed"; exit 1; }
echo "[diy-part2] 02_network patched: honor,fur-602 -> lan1 lan2 lan3 + wan"

# --- 4) final config: seed + defconfig refresh ------------------------------
cp -f "$SRC/config.seed" .config
make defconfig >/dev/null 2>&1
grep -q "CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_honor_fur-602=y" .config || { echo "FATAL: honor_fur-602 not selected after make defconfig"; exit 1; }
grep -q "CONFIG_PACKAGE_kmod-mt_wifi=y" .config || { echo "FATAL: kmod-mt_wifi not enabled after make defconfig"; exit 1; }
echo "[diy-part2] config refreshed: single-device honor_fur-602, closed-source wifi enabled"

echo "[diy-part2] DONE"
