/**
 * Powerline single-line renderer — CCometixLine aesthetic.
 * Renders all info on one line with Nerd Font icons and colored segments.
 */

import type { RenderContext } from '../types.js';
import { isLimitReached } from '../types.js';
import { getContextPercent, getBufferedPercent, getModelName, formatModelName, getProviderLabel, getTotalTokens, shouldHideUsage } from '../stdin.js';
import { getOutputSpeed } from '../speed-tracker.js';
import { renderCostEstimate } from './lines/cost.js';
import { RESET } from './colors.js';
import { getTheme, type ThemeColors } from '../themes.js';
import { t } from '../i18n/index.js';
import { formatResetTime } from './format-reset-time.js';

const DIM = '\x1b[2m';
const BOLD = '\x1b[1m';

function iconize(theme: ThemeColors, key: keyof ThemeColors['icons'], text: string): string {
  const icon = theme.icons[key];
  return icon ? `${icon} ${text}` : text;
}

function segment(theme: ThemeColors, color: string, iconKey: keyof ThemeColors['icons'], text: string): string {
  const icon = theme.icons[iconKey];
  const display = icon ? `${icon} ${text}` : text;
  return `${color}${display}${RESET}`;
}

function sep(theme: ThemeColors): string {
  return ` ${DIM}${theme.segmentSep}${RESET} `;
}

/** Simplify model names: claude-3-5-sonnet → Sonnet 3.5, claude-opus-4 → Opus 4 */
function simplifyModel(name: string): string {
  // Already simplified or custom
  if (!name.toLowerCase().includes('claude')) return name;

  // Strip "Claude " prefix
  let s = name.replace(/^Claude\s+/i, '');

  // Strip context suffix
  s = s.replace(/\s*\([^)]*\bcontext\b[^)]*\)/i, '').trim();

  // Extract family + version from patterns like "3-5-sonnet", "opus-4", "sonnet-4.5"
  const familyMatch = s.match(/(opus|sonnet|haiku)/i);
  if (!familyMatch) return s;

  const family = familyMatch[1][0].toUpperCase() + familyMatch[1].slice(1).toLowerCase();

  // Find version numbers
  const versionMatch = s.match(/(\d+)(?:[.-](\d+))?/);
  if (versionMatch) {
    const v = versionMatch[2] ? `${versionMatch[1]}.${versionMatch[2]}` : versionMatch[1];
    return `${family} ${v}`;
  }

  return family;
}

/** Context bar with color scaling: green > 50%, yellow 20-50%, red < 20% */
function contextBar(theme: ThemeColors, percent: number, width: number = 10): string {
  const filled = Math.round((percent / 100) * width);
  const empty = width - filled;
  const remaining = 100 - percent;

  let color: string;
  if (remaining < 20) color = theme.contextCritical;
  else if (remaining < 50) color = theme.contextWarn;
  else color = theme.context;

  return `${color}${theme.barFilled.repeat(filled)}${DIM}${theme.barEmpty.repeat(empty)}${RESET}`;
}

/** Usage bar */
function usageBar(theme: ThemeColors, percent: number, width: number = 10): string {
  const filled = Math.round((percent / 100) * width);
  const empty = width - filled;

  let color: string;
  if (percent >= 90) color = theme.contextCritical;
  else if (percent >= 75) color = theme.usageWarn;
  else color = theme.usage;

  return `${color}${theme.barFilled.repeat(filled)}${DIM}${theme.barEmpty.repeat(empty)}${RESET}`;
}

function formatTokens(n: number): string {
  if (n >= 1000000) return `${(n / 1000000).toFixed(1)}M`;
  if (n >= 1000) return `${(n / 1000).toFixed(0)}k`;
  return n.toString();
}

/** Git status icon: ✓ clean, ● dirty, ⚠ conflicts */
function gitStatusIcon(isDirty: boolean): string {
  return isDirty ? '●' : '✓';
}

export function renderPowerline(ctx: RenderContext): void {
  const themeName = ctx.config?.theme ?? 'cometix';
  const theme = getTheme(themeName);
  const colors = ctx.config?.colors;
  const display = ctx.config?.display;
  const parts: string[] = [];

  // ── Model ──
  if (display?.showModel !== false) {
    const rawModel = getModelName(ctx.stdin);
    const model = simplifyModel(formatModelName(rawModel, 'short', display?.modelOverride));
    const provider = getProviderLabel(ctx.stdin);
    let modelText = model;
    if (provider) modelText += ` | ${provider}`;

    // Effort level
    if (ctx.effortLevel) {
      const effortColor = ctx.effortLevel === 'high' || ctx.effortLevel === 'max' || ctx.effortLevel === 'xhigh'
        ? theme.effortHigh
        : ctx.effortLevel === 'medium'
          ? theme.effortMed
          : theme.effortLow;
      const icon = ctx.effortSymbol ?? theme.icons.effort;
      modelText += ` ${effortColor}${icon} ${ctx.effortLevel}${RESET}`;
    }

    parts.push(segment(theme, theme.model, 'model', modelText));
  }

  // ── Directory ──
  if (display?.showProject !== false && ctx.stdin.cwd) {
    const segments = ctx.stdin.cwd.split(/[/\\]/).filter(Boolean);
    const pathLevels = ctx.config?.pathLevels ?? 1;
    const dir = segments.length > 0 ? segments.slice(-pathLevels).join('/') : '/';
    parts.push(segment(theme, theme.dir, 'dir', dir));
  }

  // ── Git ──
  const gitConfig = ctx.config?.gitStatus;
  if ((gitConfig?.enabled ?? true) && ctx.gitStatus) {
    const statusIcon = gitStatusIcon(ctx.gitStatus.isDirty);
    const statusColor = ctx.gitStatus.isDirty ? theme.gitDirty : theme.gitBranch;
    let gitText = `${statusColor}${ctx.gitStatus.branch} ${statusIcon}${RESET}`;

    if (gitConfig?.showAheadBehind) {
      if (ctx.gitStatus.ahead > 0) gitText += ` ${theme.git}\u2191${ctx.gitStatus.ahead}${RESET}`;
      if (ctx.gitStatus.behind > 0) gitText += ` ${theme.git}\u2193${ctx.gitStatus.behind}${RESET}`;
    }

    if (gitConfig?.showFileStats && ctx.gitStatus.fileStats) {
      const { modified, added, deleted, untracked } = ctx.gitStatus.fileStats;
      const statParts: string[] = [];
      if (modified > 0) statParts.push(`!${modified}`);
      if (added > 0) statParts.push(`+${added}`);
      if (deleted > 0) statParts.push(`✘${deleted}`);
      if (untracked > 0) statParts.push(`?${untracked}`);
      if (statParts.length > 0) gitText += ` ${DIM}${statParts.join(' ')}${RESET}`;
    }

    parts.push(`${theme.icons.git ? `${theme.git}${theme.icons.git}${RESET} ` : ''}${gitText}`);
  }

  // ── Context ──
  if (display?.showContextBar !== false) {
    const rawPercent = getContextPercent(ctx.stdin);
    const bufferedPercent = getBufferedPercent(ctx.stdin);
    const autocompactMode = ctx.config?.display?.autocompactBuffer ?? 'enabled';
    const percent = autocompactMode === 'disabled' ? rawPercent : bufferedPercent;
    const barWidth = 10;
    const bar = contextBar(theme, percent, barWidth);
    const totalTokens = getTotalTokens(ctx.stdin);
    const size = ctx.stdin.context_window?.context_window_size ?? 0;
    const tokenText = size > 0
      ? `${formatTokens(totalTokens)}/${formatTokens(size)}`
      : `${percent}%`;
    const percentColor = percent >= 85 ? theme.contextCritical
      : percent >= 70 ? theme.contextWarn
      : theme.context;
    parts.push(`${bar} ${percentColor}${percent}%${RESET} ${DIM}·${RESET} ${tokenText}`);
  }

  // ── Cost ──
  if (display?.showCost !== false) {
    const costEstimate = renderCostEstimate(ctx);
    if (costEstimate) {
      parts.push(`${theme.cost}${costEstimate}${RESET}`);
    }
  }

  // ── Usage ──
  if (display?.showUsage !== false && ctx.usageData && !shouldHideUsage(ctx.stdin)) {
    if (isLimitReached(ctx.usageData)) {
      parts.push(`${theme.contextCritical}⚠ Limit${RESET}`);
    } else {
      const fiveHour = ctx.usageData.fiveHour;
      if (fiveHour !== null) {
        const bar = usageBar(theme, fiveHour, 6);
        const resetTime = formatResetTime(ctx.usageData.fiveHourResetAt, 'relative');
        const usageText = resetTime ? `${bar} ${fiveHour}% ${DIM}(${resetTime})${RESET}` : `${bar} ${fiveHour}%`;
        parts.push(usageText);
      }
    }
  }

  // ── Duration ──
  if (display?.showDuration !== false && ctx.sessionDuration) {
    parts.push(`${DIM}${theme.icons.duration} ${ctx.sessionDuration}${RESET}`);
  }

  // ── Output ──
  console.log(parts.join(sep(theme)));
}
