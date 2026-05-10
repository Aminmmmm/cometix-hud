#!/bin/bash
# ============================================================
# CCometixLine 卸载脚本
# https://github.com/Haleclipse/CCometixLine
# 
# 使用方式：
#   ./uninstall-ccometixline.sh        # 交互式
#   ./uninstall-ccometixline.sh -y     # 跳过确认
#   curl -fsSL .../uninstall-ccometixline.sh | bash -s -- -y
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
echo "  CCometixLine 卸载工具"
echo "=========================================="
echo ""

# 确认卸载（支持 -y 参数跳过）
if [[ "$1" != "-y" ]]; then
    read -p "确认卸载 CCometixLine？(y/N): " confirm < /dev/tty || confirm="n"
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "已取消卸载"
        exit 0
    fi
fi

echo ""

# 1. 卸载 npm 全局包
info "正在卸载 @cometix/ccline..."
if npm list -g @cometix/ccline >/dev/null 2>&1; then
    npm uninstall -g @cometix/ccline 2>/dev/null && success "已卸载 @cometix/ccline" || warn "卸载失败"
else
    warn "@cometix/ccline 未安装"
fi

# 2. 检查 ccline 命令
if command -v ccline >/dev/null 2>&1; then
    warn "ccline 命令仍然存在：$(which ccline)"
    warn "可能需要重启终端"
fi

# 3. 清理配置
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    if grep -q '"statusLine"' "$CLAUDE_DIR/settings.json" 2>/dev/null; then
        info "检测到 statusLine 配置"
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
        else
            warn "请手动编辑 $CLAUDE_DIR/settings.json 删除 statusLine"
        fi
    fi
fi

# 4. 清理临时文件
info "正在清理临时文件..."
rm -rf /tmp/CCometixLine 2>/dev/null && success "已删除 /tmp/CCometixLine"

echo ""
echo "=========================================="
echo -e "  ${GREEN}CCometixLine 卸载完成！${NC}"
echo "=========================================="
echo ""
echo "请重启终端以确保 ccline 命令完全移除"
echo ""
