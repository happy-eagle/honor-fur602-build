# HONOR FUR-602/603 — ImmortalWrt 云编译（MTK 闭源 mt_wifi）

在 **GitHub Actions 上在线编译** 荣耀 XT50/XU50/XC50（FUR-602/FUR-603，MT7981B，
联通定制 AX3000）的 ImmortalWrt 固件，**使用 MTK 闭源 mt_wifi 7.6.6.1 无线驱动**
（非主线开源 mt76）。

- **源码**：`bbb0bbb0bbb/immortalwrt-mt798x-24.10`，分支 `2410`
  （ImmortalWrt mt798x 分支，内核 5.4）。该 fork **自包含**：已内置
  `honor_fur-602` 设备定义 + 设备树 + 闭源 mt_wifi 驱动与固件，无需注入。
- **参考**：`schema12/honor-fur_602` 的构建模式（workflow + 前置/后置校验 + 产物上传）。

## 一键使用（最简路径）

1. 把本仓库 **Fork** 到你的 GitHub 账号（右上角 Fork）。
2. 进入你 Fork 后的仓库 → **Actions** 页 → 左侧选 **Build HONOR FUR-602/603** →
   点 **Run workflow** → 保持默认（源码 URL/分支）→ 点 **Run workflow**。
3. 等待构建（约 1–2 小时，4 核 runner）。完成后，该运行页底部的 **Artifacts**
   里有 `honor-fur602-firmware-<commit>` 压缩包，下载即可。

每次改动 `.config` 或 workflow 并 push 到 `main`，也会自动触发构建。

## 产物说明

| 文件 | 用途 |
| --- | --- |
| `*-factory.bin` | 从 **U-Boot** 首次刷入的完整固件（UBI） |
| `*-sysupgrade.bin` | 已在 OpenWrt/ImmortalWrt 内**升级**用的固件（tar） |
| `*-initramfs-*.bin` / `*-kernel*.bin` | 内存体验版/内核镜像（一般不用） |
| `sha256sums` / `*.manifest` / `profiles.json` | 校验与清单 |

分区布局：**expand(114m)**（`IMAGE_SIZE 116736k`），对应 hanwckf 系 U-Boot 的
`expand(114m)` NAND 布局。

## 刷机步骤（需先有 hanwckf 系 mt7981 U-Boot）

> 前提：FUR-602 出厂是荣耀运营商固件，需先通过原厂漏洞/拆机 TTL 刷入
> `mt7981_honor_fur-602-fip-fixed-parts-multi-layout.bin`（2025 版，支持 DHCP + 网页刷机）。
> 参照恩山《honor fur602/603 ImmortalWrt & 2025 uboot 自动 dhcp》的刷 uboot 方法。

1. **initramfs 试运行（推荐）**：在 U-Boot 网页/TFTP 加载
   `*-initramfs-kernel.bin` 启动（不写闪存），电脑设 DHCP，浏览器开
   `192.168.1.1` 验证 LAN/WAN、WiFi（2.4G+5G）、LED 是否正常。
2. **正式刷入**：U-Boot 网页界面选 **Choose mtd layout: expand(114m)**，
   上传 `*-factory.bin`，点 Update，等 1–2 分钟重启完成。
3. **后续升级**：系统内 LuCI → 系统 → 备份/升级 → 上传 `*-sysupgrade.bin`，
   勾选"保留配置"。

## 注意事项

- **WiFi 校准数据（EEPROM）从原厂 Factory 分区读取**，刷机不会破坏；**切勿手动
  擦除 Factory 分区**，否则 WiFi 无法工作。
- 本固件使用 **MTK 闭源 mt_wifi 驱动**（`kmod-mt_wifi`），支持 MTK HNAT/WARP 硬件
  加速、802.11k 漫游。
- 默认管理地址、初始账号等取决于 fork 出厂配置；首次刷入后可用
  `192.168.1.1`（root，无密码或 password）进入。
- 原厂荣耀固件一旦刷机即失去保修，且**无法直接回刷**（需自行备份分区）。
- 若刷后 WiFi 不工作，检查 Factory 分区 EEPROM 是否完好（
  `cat /proc/mtd` 中 `Factory` 分区不能为空）。

## 自定义

- 想加/减插件：改 `.config`（在 `CONFIG_PACKAGE_*` 区追加/注释）后重新触发。
  建议在 `workflow_dispatch` 输入里保持默认源码，只改 `.config`。
- 想保留更多官方插件（luci-app-passwall、ssr-plus 等已在 fork defconfig 默认带）
  可参考 fork 的 `defconfig/mt7981-ax3000.config` 原始内容。

## 为什么用这个源码分支

| 需求 | 说明 |
| --- | --- |
| 闭源 mt_wifi | 本分支 `package/mtk/drivers/mt_wifi` 内置闭源 7.6.6.1（含 mt7981-fw-20240613），非主线开源 mt76 |
| honor_fur-602 支持 | `image/mt7981.mk` 已内置设备定义（`DEVICE_DTS := mt7981-honor-fur-602`），dts 在 `files-5.4/.../mediatek/` |
| 在线编译 | GitHub Actions（ubuntu-22.04，4 核），无需本地 Linux |
| 114m 大分区 | `IMAGE_SIZE 116736k`，配合 expand(114m) U-Boot |

> 备选（内核 6.6 + 闭源 wifi，需自行注入设备）：`padavanonly/immortalwrt-mt798x-6.6`
> 分支 `openwrt-24.10-6.6`（有闭源 mt_wifi，但**无** honor_fur-602，需按
> schema12 方式把 dts+设备定义补进去）。本仓库选择的是自包含、最不容易翻车的
> 内核 5.4 分支。
