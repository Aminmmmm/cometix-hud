#!/bin/bash
# ============================================================
# claude-hud 卸载脚本
# https://github.com/jarrodwatts/claude-hud
# 
# 使用方式：
#   ./uninstall-claude-hud.sh        # 交互式
#   ./uninstall-claude-hud.sh -y     # 跳过确认
#   curl -fsSL .../uninstall-claude-hud.sh | bash -s -- -y
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
echo "  claude-hud 卸载工具"
echo "=========================================="
echo ""

# 确认卸载（支持 -y 参数跳过）
if [[ "$1" != "-y" ]]; then
    read -p "确认卸载 claude-hud？(y/N): " confirm < /dev/tty || confirm="n"
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "已取消卸载"
        exit 0
    fi
fi

echo ""

# 1. 删除插件目录
info "正在删除 claude-hud 插件..."

for dir in "$CLAUDE_DIR/plugins/claude-hud" "$CLAUDE_DIR/plugins/cache"/*/claude-hud; do
    if [ -d "$dir" ]; then
        rm -rf "$dir" && success "已删除 $dir"
    fi
done

# 2. 清理 settings.json
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
else
    warn "settings.json 不存在"
fi

# 3. 清理全局链接
info "正在清理全局链接..."
if npm list -g claude-hud >/dev/null 2>&1; then
    npm unlink -g claude-hud 2>/dev/null && success "已取消 claude-hud 全局链接"
fi

# 4. 清理临时文件
info "正在清理临时文件..."
rm -rf /tmp/claude-hud 2>/dev/null && success "已删除 /tmp/claude-hud"

# 5. 更新插件注册表
REGISTRY_FILE="$CLAUDE_DIR/plugins/installed_plugins.json"
if [ -f "$REGISTRY_FILE" ] && command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json
try:
    with open('$REGISTRY_FILE', 'r') as f:
        registry = json.load(f)
    plugins = registry.get('plugins', {})
    if 'claude-hud' in plugins:
        del plugins['claude-hud']
        with open('$REGISTRY_FILE', 'w') as f:
            json.dump(registry, f, indent=2)
        print('已从注册表移除 claude-hud')
except:
    pass
" 2>/dev/null && success "插件注册表已更新"
fi

echo ""
echo "=========================================="
echo -e "  ${GREEN}claude-hud 卸载完成！${NC}"
echo "=========================================="
echo ""
echo "请重启 Claude Code 以完成卸载"
echo ""
