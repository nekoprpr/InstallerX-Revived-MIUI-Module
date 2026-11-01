# InstallerX Revived MIUI Module

Auto-synced Magisk / KernelSU / APatch module that installs [InstallerX Revived](https://github.com/wxxsfxyzm/InstallerX-Revived) as the MIUI / HyperOS system package installer (`com.miui.packageinstaller`).

将 InstallerX Revived 替换为 MIUI / HyperOS 系统安装器的模块，自动跟随上游最新发布版本构建。

## How it works

- Every 6 hours a GitHub Actions job checks the newest upstream release (stable or preview, whichever is newer).
- If it has not been built yet, the job builds it from source with `-PAPP_ID=com.miui.packageinstaller`, signs it with this repo's own fixed key, and packs it in the MIUI layout (`product/priv-app/MIUIPackageInstaller/MIUIPackageInstaller.apk`).
- `update.json` is updated, so your root manager shows the update and installs it in one tap.

## Install

1. Download the zip from [Releases](../../releases/latest) and flash it in Magisk / KernelSU / APatch.
2. Reboot.

The module overrides the APK at `/product/priv-app/MIUIPackageInstaller/`.

## Requirements

- MIUI or HyperOS with `com.miui.packageinstaller` at `/product/priv-app/MIUIPackageInstaller/`.
- Confirm the layout first on your device:

  ```bash
  dumpsys package com.miui.packageinstaller | grep -E "codePath|versionCode|flags="
  pm path com.miui.packageinstaller
  ```

  You should see `codePath=/product/priv-app/MIUIPackageInstaller` and `flags=[ SYSTEM ... ]`.

## ⚠️ Important: the `/data/app` update copy

MIUI often ships a **newer update of the installer in `/data/app`**, which has higher priority than the system copy. In that case:

```bash
dumpsys package com.miui.packageinstaller | grep -E "codePath|flags="
```

returns `/data/app/~~xxxx==/com.miui.packageinstaller-...` with `flags=[ SYSTEM ... UPDATED_SYSTEM_APP ... ]`, and **the module will appear to have no effect** — the `/data` copy wins.

This build only replaces the `/product` copy and does **not** touch `/data/app`. If your device has an update copy, you must remove it yourself before the module can take effect:

```bash
pm uninstall-system-updates com.miui.packageinstaller
```

Note that MIUI frequently blocks this with `DELETE_FAILED_INTERNAL_ERROR`, and `pm disable-user` fails with `Cannot disable required package`. Root does not bypass these — PackageManagerService policy rejects them before any file operation.

## Notes

- The APK is signed with this repo's key, not upstream's. Switching from a previous module changes the system installer's signature once; after that it stays stable.
- APK `versionCode` is `1000000000 + upstream's` (git commit count). It must outrank the vendor installer at the same package name (MIUI 5.5.x), otherwise PackageManager ignores this copy. Updates never downgrade.
- Do not install a `com.miui.packageinstaller` APK on top manually: a `/data` update with a higher versionCode hides the module's copy, and an unsigned or differently-signed one will be discarded on boot.
- Builds are unmodified upstream source apart from the application id. Report app bugs upstream only if they reproduce with official builds.
- On MIUI the installer may still need Shizuku, Root, or Dhizuku for privileged operations. Replacing the APK does not grant every privileged permission on its own.

## Rollback

Remove the module in your root manager and reboot. The `/product` override disappears with it — nothing is written to the system partition.

If the device does not boot:

```bash
# fastboot: flash the stock boot image to disable KernelSU, so module scripts stop running
fastboot flash boot <stock boot.img>

# or from Recovery / adb
rm -rf /data/adb/modules/installerx_miui
```

## License

Module scripts: GPL-3.0, same as upstream.
