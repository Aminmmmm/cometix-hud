#!/bin/bash
# ============================================================
# 一键卸载 Claude Code 状态栏相关项目
# 支持：CCometixLine、claude-hud、cometix-hud
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# Claude 配置目录
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

echo ""
echo "=========================================="
echo "  Claude Code 状态栏一键卸载工具"
echo "=========================================="
echo ""
echo "将卸载以下项目："
echo "  1. CCometixLine (npm 全局包)"
echo "  2. claude-hud (Claude Code 插件)"
echo "  3. cometix-hud (Claude Code 插件)"
echo ""

# 询问确认
read -p "确认卸载？(y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "已取消卸载"
    exit 0
fi

echo ""

# ============================================================
# 1. 卸载 CCometixLine (npm 全局包)
# ============================================================
info "正在卸载 CCometixLine..."

# 检查是否安装
if npm list -g @cometix/ccline >/dev/null 2>&1; then
    npm uninstall -g @cometix/ccline 2>/dev/null && success "已卸载 @cometix/ccline" || warn "卸载 @cometix/ccline 失败"
else
    warn "@cometix/ccline 未安装，跳过"
fi

# 检查 ccline 命令
if command -v ccline >/dev/null 2>&1; then
    warn "ccline 命令仍然存在，可能需要手动删除"
    which ccline
fi

echo ""

# ============================================================
# 2. 卸载 claude-hud (Claude Code 插件)
# ============================================================
info "正在卸载 claude-hud..."

# 删除插件目录
CLAUDE_HUD_DIRS=(
    "$CLAUDE_DIR/plugins/claude-hud"
    "$CLAUDE_DIR/plugins/cache"/*/claude-hud
)

for dir in "${CLAUDE_HUD_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir" && success "已删除 $dir"
    fi
done

echo ""

# ============================================================
# 3. 卸载 cometix-hud (Claude Code 插件)
# ============================================================
info "正在卸载 cometix-hud..."

COMETIX_HUD_DIRS=(
    "$CLAUDE_DIR/plugins/cometix-hud"
    "$CLAUDE_DIR/plugins/cache"/*/cometix-hud
)

for dir in "${COMETIX_HUD_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir" && success "已删除 $dir"
    fi
done

echo ""

# ============================================================
# 4. 清理 settings.json 中的 statusLine 配置
# ============================================================
info "正在清理 settings.json..."

SETTINGS_FILE="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    # 检查是否有 statusLine 配置
    if grep -q '"statusLine"' "$SETTINGS_FILE" 2>/dev/null; then
        # 使用 python 或 jq 删除 statusLine
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
import json
with open('$SETTINGS_FILE', 'r') as f:
    config = json.load(f)
if 'statusLine' in config:
    del config['statusLine']
    with open('$SETTINGS_FILE', 'w') as f:
        json.dump(config, f, indent=2)
    print('已移除 statusLine 配置')
else:
    print('未找到 statusLine 配置')
" && success "settings.json 已清理" || warn "清理 settings.json 失败"
        elif command -v jq >/dev/null 2>&1; then
            jq 'del(.statusLine)' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && \
            mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE" && \
            success "settings.json 已清理"
        else
            warn "需要手动编辑 $SETTINGS_FILE 删除 statusLine 配置"
        fi
    else
        warn "settings.json 中未找到 statusLine 配置"
    fi
else
    warn "settings.json 不存在"
fi

echo ""

# ============================================================
# 5. 清理 npm 全局链接
# ============================================================
info "正在清理 npm 全局链接..."

# 检查并清理 cometix-hud 链接
if npm list -g cometix-hud >/dev/null 2>&1; then
    npm unlink -g cometix-hud 2>/dev/null && success "已取消 cometix-hud 全局链接"
fi

# 检查并清理 claude-hud 链接
if npm list -g claude-hud >/dev/null 2>&1; then
    npm unlink -g claude-hud 2>/dev/null && success "已取消 claude-hud 全局链接"
fi

echo ""

# ============================================================
# 6. 清理临时文件
# ============================================================
info "正在清理临时文件..."

TEMP_DIRS=(
    "$CLAUDE_DIR/plugins/cache/temp_local_"*
    "/tmp/claude-hud-fusion"
    "/tmp/cometix-hud"
    "/tmp/CCometixLine"
    "/tmp/claude-hud"
)

for dir in "${TEMP_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir" 2>/dev/null && success "已删除 $dir"
    fi
done

echo ""

# ============================================================
# 7. 重置插件注册表（可选）
# ============================================================
REGISTRY_FILE="$CLAUDE_DIR/plugins/installed_plugins.json"

if [ -f "$REGISTRY_FILE" ]; then
    info "是否重置插件注册表？"
    warn "这将删除所有已安装插件的记录！"
    read -p "重置注册表？(y/N): " reset_registry
    if [[ "$reset_registry" =~ ^[Yy]$ ]]; then
        echo '{"version": 2, "plugins": {}}' > "$REGISTRY_FILE" && \
        success "插件注册表已重置"
    else
        info "跳过重置注册表"
    fi
fi

echo ""

# ============================================================
# 完成
# ============================================================
echo "=========================================="
echo -e "  ${GREEN}卸载完成！${NC}"
echo "=========================================="
echo ""
echo "请执行以下操作："
echo "  1. 重启 Claude Code"
echo "  2. 如果使用了 npm link，重启终端"
echo ""
echo "如需重新安装 cometix-hud："
echo "  /plugin marketplace add Aminmmmm/cometix-hud"
echo "  /plugin install cometix-hud"
echo "  /cometix-hud:setup"
echo ""
