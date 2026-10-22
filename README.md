---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: adddb8a85318c2a7c23a8fe81eb015c2_64eeca34cdb511f1b76f525400638852
    ReservedCode1: Z0RFmJ2LbBJsTmwA4hBXZYwkUb4wnRIZXzuZkVpyYt2xDjYGNEJS7ShQ9HoEn8vPcnjCCrxJ86N3YeWzBuVGjPW/uHxLc+hGZeEtpwEW/+3Zu5oLioBcm4ZC+Eg42rJzUvb8WcivsNwHqX9/oOYfwDdDxdyFTgzyhhcmxWVYkF84zL3FImUEafuyG+8=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: adddb8a85318c2a7c23a8fe81eb015c2_64eeca34cdb511f1b76f525400638852
    ReservedCode2: Z0RFmJ2LbBJsTmwA4hBXZYwkUb4wnRIZXzuZkVpyYt2xDjYGNEJS7ShQ9HoEn8vPcnjCCrxJ86N3YeWzBuVGjPW/uHxLc+hGZeEtpwEW/+3Zu5oLioBcm4ZC+Eg42rJzUvb8WcivsNwHqX9/oOYfwDdDxdyFTgzyhhcmxWVYkF84zL3FImUEafuyG+8=
---

# honor-fur_602 云编译固件（MT7981 · mtwifi 闭源驱动 + SSR-Plus）

基于 [schema12/honor-fur_602](https://github.com/schema12/honor-fur_602) 的硬件适配，改用
[hanwckf/immortalwrt-mt798x](https://github.com/hanwckf/immortalwrt-mt798x)（openwrt-21.02 分支）
作为编译源——该仓库**原生支持荣耀 FUR-602/603**，并默认使用 **MTK 闭源 mtwifi 驱动**，无需自行移植。

## 目录结构

```
honor-fur602-build/
├── .github/workflows/build-fur602.yml   # GitHub Actions 云编译工作流
├── feeds.conf.default                    # 增加 fw876/helloworld 源（SSR-Plus）
└── defconfig/mt7981-fur602-ssr.config    # 编译配置（仅 FUR-602 单设备 + SSR-Plus 全套）
```

## 使用方法

1. 在 GitHub 新建一个仓库（如 `fur602-build`），将本目录内文件推送到 **openwrt-21.02** 分支。
2. 进入仓库 Actions 页签，手动运行 **Build FUR-602 (mt7981 mtwifi + SSR-Plus)** 工作流。
3. 构建约 30~60 分钟，完成后在 Actions 运行页下载 `fur602-firmware` 产物：
   - `mediatek_mt7981-honor_fur-602-squashfs-sysupgrade.bin` — 系统升级固件（web 升级用）
   - `...-ubootmod-initramfs-kernel.bin` / `...-ubootmod-fit-lzma.bin` — 首次刷机用
   - `sha256sums` — 校验值

## 固件特性

- **驱动**：MTK 闭源 mtwifi（`kmod-mt_wifi` / `luci-app-mtwifi-cfg`），含硬件 NAT（WED/HNAT）加速，信号与吞吐优于开源 mt76
- **SSR-Plus**：Xray、Shadowsocks（libev/rust）、ShadowsocksR libev、ChinaDNS-NG、simple-obfs、DNS2SOCKS 全套内置
- **基础插件**：中文界面 + Argon 主题、ttyd、TurboACC（mtk）、EQoS、UPnP、Samba4、aria2、qBittorrent、Transmission、FileBrowser、阿里云盘 WebDAV、多拨 MWAN3、AdBlock、SmartDNS、网易云解锁、Zerotier、frp、DDNS、CPU 频率调节、流量统计、WireGuard/OpenVPN 等

## 刷机注意（重要）

- 该固件为 **ubootmod 布局**：若设备当前是原厂系统，需先按
  [schema12/honor-fur_602 的 README](https://github.com/schema12/honor-fur_602)
  刷入 U-Boot 并切换 expand 分区后，再通过 U-Boot 恢复模式刷入本固件。
- 已有其他 ImmortalWrt 版本的用户，可直接在 LuCI 中升级 `sysupgrade.bin`。
- 刷机有变砖风险，请先确认设备型号为 **荣耀路由 FUR-602（或 FUR-603）**。
*（内容由AI生成，仅供参考）*
