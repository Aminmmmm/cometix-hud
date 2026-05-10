# Cometix HUD

> CCometixLine 的美学 + Claude HUD 的功能 = 终极 Claude Code 状态栏

[English](README.md) | [中文](README.zh.md)

![License:MIT](https://img.shields.io/static/v1?label=License&message=MIT&color=blue&style=flat-square)

## 效果预览

**Powerline 单行模式**（终端宽度 ≥120 时自动启用）:
```
✦ Opus 4 │ ⌂ my-project │ ⎇ main ● !3 +1 │ ████░░░░░░ 45% · 90k/200k │ $0.42 │ 25% (2h 30m / 5h) │ ⏱ 12m
```

**Expanded 多行模式**（终端较窄时自动切换）:
```
[Opus ⚯ high] │ my-project git:(main*)
Context █████░░░░░ 45% │ Usage ██░░░░░░░░ 25% (1h 30m / 5h)
◐ Edit: auth.ts │ ✓ Read ×3 │ ✓ Grep ×2
```

## 特性

### 来自 CCometixLine（美学层）
- 🎨 **Nerd Font 图标** — 每个 segment 专属图标，一眼分类信息
- 🎯 **5 个主题预设** — Cometix / Dracula / Gruvbox / Nord / Minimal
- ▶️ **Powerline 单行布局** — 信息密度高，不换行
- 🔤 **模型名简化** — `claude-3-5-sonnet` → `Sonnet 3.5`
- 📊 **Context 条颜色变化** — 绿 > 50% / 黄 20-50% / 红 < 20%

### 来自 Claude HUD（功能层）
- 🔧 **工具活动追踪** — 实时显示 Claude 正在读/写/搜索的文件
- 🤖 **Agent 追踪** — 子 Agent 运行状态和耗时
- ✅ **待办进度** — 任务完成比例
- 📈 **使用率限制** — 5h + 7d 双窗口，带重置倒计时
- 💰 **Cost 显示** — 会话花费（原生 `cost.total_cost_usd`）
- ⏱️ **会话时长** — 当前会话运行时间
- 📁 **Git file stats** — `!3 +1 ?2` 文件变更统计
- 🌐 **CJK 宽度感知** — 中日韩字符正确渲染

### 融合新增
- 🔄 **Auto 布局切换** — 终端宽 → 单行 Powerline，窄 → 多行 Expanded
- 🎨 **主题系统** — JSON 配置一键切换 5 个主题
- ⚡ **智能默认** — 开箱即用 4 个零噪音功能（Usage + Duration + Git Stats + Cost）

## 安装

### 方式一：npm 安装（推荐）

```bash
# 全局安装
npm install -g cometix-hud

# 或使用 yarn
yarn global add cometix-hud

# 或使用 pnpm
pnpm add -g cometix-hud
```

国内用户可使用镜像加速：
```bash
npm install -g cometix-hud --registry https://registry.npmmirror.com
```

安装完成后，配置 Claude Code：

编辑 `~/.claude/settings.json`，添加：
```json
{
  "statusLine": {
    "type": "command",
    "command": "cometix-hud",
    "padding": 0
  }
}
```

### 方式二：手动安装（开发版）

```bash
# 克隆仓库
git clone https://github.com/Aminmmmm/cometix-hud.git
cd cometix-hud

# 安装依赖并构建
npm ci
npm run build

# 链接到全局
npm link
```

然后同样在 `~/.claude/settings.json` 中添加 statusLine 配置。



## 卸载

### 方式一：通过 Claude Code 插件卸载

```bash
# 在 Claude Code 中运行
/plugin uninstall cometix-hud
```

### 方式二：手动卸载

```bash
# 1. 删除插件目录
rm -rf ~/.claude/plugins/cometix-hud

# 2. 清理缓存
rm -rf ~/.claude/plugins/cache/*/cometix-hud

# 3. 移除 settings.json 中的 statusLine 配置
# 编辑 ~/.claude/settings.json，删除 "statusLine" 部分
```

### 清理全局链接（如果使用过 npm link）

```bash
npm unlink -g cometix-hud
```

### 方式三：卸载脚本（按需使用）

根据需要卸载对应的项目：

**卸载 cometix-hud：**
```bash
curl -fsSL https://raw.githubusercontent.com/Aminmmmm/cometix-hud/main/scripts/uninstall-cometix-hud.sh | bash -s -- -y
```

**卸载 claude-hud：**
```bash
curl -fsSL https://raw.githubusercontent.com/Aminmmmm/cometix-hud/main/scripts/uninstall-claude-hud.sh | bash -s -- -y
```

**卸载 CCometixLine：**
```bash
curl -fsSL https://raw.githubusercontent.com/Aminmmmm/cometix-hud/main/scripts/uninstall-ccometixline.sh | bash -s -- -y
```

**一键卸载全部：**
```bash
curl -fsSL https://raw.githubusercontent.com/Aminmmmm/cometix-hud/main/scripts/uninstall-all.sh | bash -s -- -y
```

> 💡 `-y` 参数跳过确认提示。交互式运行时可省略。




## 配置

### 快速配置

```
/cometix-hud:configure
```

### 手动配置

编辑 `~/.claude/plugins/cometix-hud/config.json`:

```json
{
  "language": "zh",
  "lineLayout": "auto",
  "theme": "cometix",
  "pathLevels": 2,
  "gitStatus": {
    "enabled": true,
    "showDirty": true,
    "showAheadBehind": true,
    "showFileStats": true
  },
  "display": {
    "showCost": true,
    "showDuration": true,
    "showUsage": true,
    "showEffortLevel": true,
    "showTools": true,
    "showAgents": true,
    "showTodos": true
  }
}
```

### 布局模式

| 模式 | 说明 |
|------|------|
| `auto` | **默认**。终端宽（≥120 字符）→ 单行 Powerline，窄 → 多行 Expanded |
| `powerline` | 强制单行 Powerline 模式 |
| `expanded` | 强制多行 Expanded 模式 |
| `compact` | Claude HUD 原始单行模式 |

### 主题

| 主题 | 风格 |
|------|------|
| `cometix` | **默认**。青绿系，CCometixLine 默认配色 |
| `dracula` | 紫色模型 + 青色目录 + 橙色 Git |
| `gruvbox` | 暖色复古风 |
| `nord` | 冷色极简 |
| `minimal` | 终端默认色，无图标 |

### 全部配置选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `lineLayout` | string | `auto` | 布局模式 |
| `theme` | string | `cometix` | 主题名 |
| `language` | `en` \| `zh` | `en` | HUD 标签语言 |
| `pathLevels` | 1-3 | 1 | 项目路径深度 |
| `display.showModel` | bool | true | 模型名 |
| `display.showContextBar` | bool | true | 进度条 |
| `display.showCost` | bool | true | 会话花费 |
| `display.showDuration` | bool | true | 会话时长 |
| `display.showUsage` | bool | true | 使用率限制 |
| `display.showEffortLevel` | bool | true | 推理强度 |
| `display.showTools` | bool | false | 工具活动行 |
| `display.showAgents` | bool | false | Agent 追踪行 |
| `display.showTodos` | bool | false | 待办进度行 |
| `display.showSpeed` | bool | false | 输出速度 |
| `display.showMemoryUsage` | bool | false | 内存使用 |
| `display.showPromptCache` | bool | false | Prompt Cache 倒计时 |
| `gitStatus.showDirty` | bool | true | 脏状态 |
| `gitStatus.showAheadBehind` | bool | false | 领先/落后 |
| `gitStatus.showFileStats` | bool | true | 文件变更统计 |

## 开发

```bash
git clone https://github.com/Aminmmmm/cometix-hud
cd cometix-hud
npm ci && npm run build
npm test
```

## 致谢

- [Claude HUD](https://github.com/jarrodwatts/claude-hud) — 核心功能（transcript 解析、工具/Agent/待办追踪、使用率限制）
- [CCometixLine](https://github.com/Haleclipse/CCometixLine) — 视觉设计灵感（Nerd Font 图标、Powerline 风格、主题系统）
- [webup-skills-cc](https://github.com/webup/skills-cc) — 状态栏生成器参考

## 许可证

MIT
