#!/bin/bash
# ============================================================
# 一键卸载 Claude Code 状态栏相关项目
# 支持：CCometixLine、claude-hud、cometix-hud
# 
# 使用方式：
#   ./uninstall-all.sh        # 交互式
#   ./uninstall-all.sh -y     # 跳过确认
#   curl -fsSL .../uninstall-all.sh | bash -s -- -y
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

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

# 确认卸载（支持 -y 参数跳过）
if [[ "$1" != "-y" ]]; then
    read -p "确认卸载全部？(y/N): " confirm < /dev/tty || confirm="n"
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "已取消卸载"
        exit 0
    fi
fi

echo ""

# ============================================================
# 1. 卸载 CCometixLine
# ============================================================
info "正在卸载 CCometixLine..."

if npm list -g @cometix/ccline >/dev/null 2>&1; then
    npm uninstall -g @cometix/ccline 2>/dev/null && success "已卸载 @cometix/ccline" || warn "卸载 @cometix/ccline 失败"
else
    warn "@cometix/ccline 未安装，跳过"
fi

echo ""

# ============================================================
# 2. 卸载 claude-hud
# ============================================================
info "正在卸载 claude-hud..."

for dir in "$CLAUDE_DIR/plugins/claude-hud" "$CLAUDE_DIR/plugins/cache"/*/claude-hud; do
    if [ -d "$dir" ]; then
        rm -rf "$dir" && success "已删除 $dir"
    fi
done

echo ""

# ============================================================
# 3. 卸载 cometix-hud
# ============================================================
info "正在卸载 cometix-hud..."

for dir in "$CLAUDE_DIR/plugins/cometix-hud" "$CLAUDE_DIR/plugins/cache"/*/cometix-hud; do
    if [ -d "$dir" ]; then
        rm -rf "$dir" && success "已删除 $dir"
    fi
done

echo ""

# ============================================================
# 4. 清理 settings.json
# ============================================================
info "正在清理 settings.json..."

if [ -f "$CLAUDE_DIR/settings.json" ]; then
    if grep -q '"statusLine"' "$CLAUDE_DIR/settings.json" 2>/dev/null; then
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
import json
with open('$CLAUDE_DIR/settings.json', 'r') as f:
    config = json.load(f)
if 'statusLine' in config:
    del config['statusLine']
    with open('$CLAUDE_DIR/settings.json', 'w') as f:
        json.dump(config, f, indent=2)
    print('已移除 statusLine 配置')
"
            success "settings.json 已清理"
        elif command -v jq >/dev/null 2>&1; then
            jq 'del(.statusLine)' "$CLAUDE_DIR/settings.json" > "$CLAUDE_DIR/settings.json.tmp" && \
            mv "$CLAUDE_DIR/settings.json.tmp" "$CLAUDE_DIR/settings.json" && \
            success "settings.json 已清理"
        else
            warn "请手动编辑 $CLAUDE_DIR/settings.json 删除 statusLine"
        fi
    else
        warn "settings.json 中未找到 statusLine 配置"
    fi
fi

echo ""

# ============================================================
# 5. 清理全局链接
# ============================================================
info "正在清理全局链接..."

for pkg in cometix-hud claude-hud; do
    if npm list -g "$pkg" >/dev/null 2>&1; then
        npm unlink -g "$pkg" 2>/dev/null && success "已取消 $pkg 全局链接"
    fi
done

echo ""

# ============================================================
# 6. 清理临时文件
# ============================================================
info "正在清理临时文件..."

for dir in /tmp/cometix-hud /tmp/claude-hud /tmp/CCometixLine /tmp/claude-hud-fusion; do
    if [ -d "$dir" ]; then
        rm -rf "$dir" && success "已删除 $dir"
    fi
done

# 清理 temp 文件
for dir in "$CLAUDE_DIR/plugins/cache/temp_local_"*; do
    if [ -d "$dir" ]; then
        rm -rf "$dir" && success "已删除 $dir"
    fi
done

echo ""

# ============================================================
# 7. 重置插件注册表（可选）
# ============================================================
REGISTRY_FILE="$CLAUDE_DIR/plugins/installed_plugins.json"

if [ -f "$REGISTRY_FILE" ]; then
    if [[ "$1" != "-y" ]]; then
        info "是否重置插件注册表？"
        warn "这将删除所有已安装插件的记录！"
        read -p "重置注册表？(y/N): " reset_registry < /dev/tty || reset_registry="n"
        if [[ "$reset_registry" =~ ^[Yy]$ ]]; then
            echo '{"version": 2, "plugins": {}}' > "$REGISTRY_FILE" && \
            success "插件注册表已重置"
        fi
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
