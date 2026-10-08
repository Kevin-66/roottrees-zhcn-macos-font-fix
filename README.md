# The Roottrees are Dead: Chinese font fix for macOS

[中文说明](#中文说明)

When you play *The Roottrees are Dead* in Simplified Chinese on a Mac, some text shows up as little boxes with hex codes in them instead of Chinese characters. The best-known example is the "Don't forget!" (别忘了！) page from the genealogy guide pinned to the family-tree corkboard:

![Chinese text rendered as hex-code boxes](docs/before.jpg)

This repo fixes that with a single 10-line config file. It doesn't modify or redistribute any game files.

## Install

1. Download this repo: **Code → Download ZIP**, then unzip it. Or clone it.
2. Open Terminal in the unzipped folder and run:

   ```bash
   bash install.sh
   ```

3. Restart the game.

The script finds the game in your Steam libraries and copies `override.cfg` next to the game's executable. If the game is somewhere unusual, pass the app bundle:

```bash
bash install.sh "/path/to/The Roottrees are Dead/roottrees.app"
```

### Manual install

Copy [`override.cfg`](override.cfg) into:

```
~/Library/Application Support/Steam/steamapps/common/The Roottrees are Dead/roottrees.app/Contents/MacOS/
```

(In Finder: right-click `roottrees.app` → **Show Package Contents** → `Contents` → `MacOS`.)

## Uninstall

```bash
bash install.sh --uninstall
```

You can also just delete `override.cfg` from that `MacOS` folder.

## Notes

- **App signature.** Adding a file inside the app bundle makes `codesign --verify` report "a sealed resource is missing or invalid". The game still launches normally from Steam because Steam downloads aren't quarantined. If it ever refuses to start, uninstall.
- **Game updates.** Steam normally leaves extra files alone, including when you verify integrity. If the boxes come back after an update, run the installer again.
- **Other text.** Anything else that was falling back to the engine's default font is fixed too. It now renders in Source Han Sans SC, which the game already bundles.
- **Tested on** macOS 27.0.1 (Apple Silicon) with the Steam build from October 2026 (Godot 4.4.1). Windows and Linux use the same `override.cfg` mechanism (put it next to the game executable), but I haven't seen the bug on those platforms and haven't tested them.

## What's actually wrong (for the developer)

- The labels on that page (`ForDunces/DontForget`, `SurnamesNote`, `OccupationNote`, `PageFooter/BookTitle`, `PageFooter/PageNo` in `scenes/family-tree/family-tree.tscn`) use the `PrintLabel` theme type variation from `themes/family-tree.tres`.
- `PrintLabel` sets a color and a size but **no font**. `Label` has no font in that theme either, and the theme has no `default_font`.
- `FamilyTree` is instanced inside a `SubViewport` (`FamilyTreeInterface/MainRender/MainViewport`), so `themes/theme.tres` (where `Label` → Afacad) never reaches it. Lookup falls through to the engine's default theme, which uses Godot's built-in **Open Sans SemiBold**.
- Every other font the game uses gets Chinese glyphs from import-time fallbacks: Afacad → GlowSans SC, Bevan → Source Han Sans SC, Gaegu → Xiaolai. The built-in Open Sans has no such fallback, so it relies on the OS.
- On macOS, CoreText's fallback for Han text is PingFang SC from `/System/Library/PrivateFrameworks/FontServices.framework/Resources/Reserved/PingFangUI.ttc`. Godot 4.4.1 apparently fails to use it, so it draws hex-code boxes.

Possible fixes, any one of which would do it:
- give `PrintLabel` a font with a CJK fallback in `family-tree.tres`
- set `gui/theme/custom_font` in project settings (that's all this repo's `override.cfg` does)
- give the family-tree theme a `default_font`

---

## 中文说明

在 Mac 上用简体中文玩《The Roottrees are Dead》时，部分文字不显示汉字，而是显示成带十六进制编码的小方框。最明显的是家谱软木板上那页《轻松玩转家谱学》的"别忘了！"（见上图）。

本仓库只用一个配置文件修复这个问题，不修改、也不分发任何游戏文件。

### 安装

1. 下载本仓库（**Code → Download ZIP** 后解压，或 `git clone`）。
2. 在解压后的文件夹中打开"终端"，运行：

   ```bash
   bash install.sh
   ```

3. 重新启动游戏。

脚本会在 Steam 游戏库中找到游戏，并把 `override.cfg` 复制到游戏可执行文件旁边。如果游戏装在其他位置，可以手动指定：

```bash
bash install.sh "/路径/The Roottrees are Dead/roottrees.app"
```

**手动安装：**把 [`override.cfg`](override.cfg) 复制到
`~/Library/Application Support/Steam/steamapps/common/The Roottrees are Dead/roottrees.app/Contents/MacOS/`
（在访达中右键 `roottrees.app` →"显示包内容"→ `Contents` → `MacOS`）。

### 卸载

```bash
bash install.sh --uninstall
```

或者直接删除 `MacOS` 文件夹里的 `override.cfg`。

### 原因

这些文字所用的 `PrintLabel` 样式没有指定字体。家谱界面又位于 `SubViewport` 中，游戏的主题字体传不进去，于是用的是 Godot 内置的 Open Sans。游戏给其他字体都配了中文后备字体（思源黑体、GlowSans、小赖字体），唯独 Open Sans 没有，只能依赖系统字体。而在 macOS 上，Godot 4.4.1 无法使用系统给出的苹方字体（`PingFangUI.ttc`），所以显示成了方框。`override.cfg` 把引擎默认字体改成游戏自带的思源黑体 SC，问题即可解决。

### 注意

- 在应用包内添加文件后，`codesign --verify` 会提示签名封印不完整。从 Steam 下载的游戏没有隔离标记，仍可正常启动；如有问题，卸载即可。
- 游戏更新后如果方框又出现了，重新运行一次安装脚本即可。

---

Not affiliated with Evil Trout Inc. *The Roottrees are Dead* is © Evil Trout Inc.
