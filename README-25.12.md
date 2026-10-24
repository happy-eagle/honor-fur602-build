# HONOR FUR-602 / FUR-603 - ImmortalWrt 25.12 Closed-Source (mt_wifi) Build

Builds firmware for HONOR FUR-602 / FUR-603 (荣耀 XU50 / XT50 / XC50, 联通定制版)
using the **chasey-dev/immortalwrt-mt798x-rebase** closed-source MTK WiFi tree
(branch `25.12`, kernel 6.12).

**No PassWall / SSR-Plus / proxy plugins are included** -- this is the stock
default config (MTK closed-source WiFi + UPnP + turboacc/eqos MTK) plus a
custom device definition. Add extra packages yourself if you need them.

## Device definition (self-built)

The chasey tree has **no** FUR-602 device, so three files are injected:

| File | Destination (inside build tree) |
|---|---|
| `mt7981b-honor-fur-602.dts` | `target/linux/mediatek/dts-ext/` |
| `filogic-ext.mk.append` (device block) | appended to `target/linux/mediatek/image/filogic-ext.mk` |
| 02_network patch (embedded in diy script) | `target/linux/mediatek/base-files/etc/board.d/02_network` |

The DTS is derived from [schema12/honor-fur_602](https://github.com/schema12/honor-fur_602)
`migration/immortalwrt-25.12.2` (verified 6.12 adaptations), with the WiFi node
switched to the closed-source nvmem-cells convention used by the chasey tree.

## Requirements before flashing

- **Must first flash** the hanwckf [bl-mt798x](https://github.com/hanwckf/bl-mt798x)
  `mt7981_honor_fur-602` U-Boot with the **expand(114m)** mtd layout.
- The stock HONOR U-Boot is signature-locked and cannot boot this firmware.
- Flash `*-factory.bin` (U-Boot / TFTP) or `*-sysupgrade.bin` (from an
  existing compatible firmware).

## Layout / boot chain

- 128 MiB SPI-NAND with NMBM: `bl2|u-boot-env|factory|Trace|fip|ubi(116736k)`.
- `KERNEL_IN_UBI=1`: U-Boot boots the FIT from the UBI volume named `kernel`.
- Traditional sysupgrade (`nand_do_upgrade` fallback, kernel + rootfs volumes),
  deliberately not the newer `linux,ubi` fitblk layout.

## Build it yourself (GitHub Actions)

1. Push the branch `openwrt-25.12` to your own fork of this repo.
2. Keep your fork of `chasey-dev/immortalwrt-mt798x-rebase` reachable
   (the workflow checks it out by default; you can change the repo in the YAML).
3. **Actions -> "Build FUR-602 firmware (25.12 closed-source mt_wifi)" ->
   Run workflow** (optionally tick *clean build*).
4. Download the `fur602-25.12-closed` artifact: contains `factory.bin` and
   `sysupgrade.bin`.

## LAN / WAN

- WAN: `wan` (switch port 0, gmac1)
- LAN: `lan1 lan2 lan3` (all behind gmac0 / MT7531)
