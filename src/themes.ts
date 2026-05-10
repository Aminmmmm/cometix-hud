/**
 * Theme presets for CometixLine HUD fusion.
 * Each theme defines ANSI color codes for every visual element.
 */

export interface ThemeColors {
  model: string;
  project: string;
  git: string;
  gitBranch: string;
  gitDirty: string;
  context: string;
  contextWarn: string;
  contextCritical: string;
  usage: string;
  usageWarn: string;
  cost: string;
  effort: string;
  effortHigh: string;
  effortMed: string;
  effortLow: string;
  dir: string;
  separator: string;
  label: string;
  barFilled: string;
  barEmpty: string;
  /** Nerd Font icons per element */
  icons: ThemeIcons;
  /** Separator character between segments */
  segmentSep: string;
}

export interface ThemeIcons {
  model: string;
  dir: string;
  git: string;
  context: string;
  effort: string;
  style: string;
  worktree: string;
  vim: string;
  cost: string;
  usage: string;
  duration: string;
}

// ── ANSI helpers ──────────────────────────────────────────────
const RST = '\x1b[0m';
const BOLD = '\x1b[1m';
const DIM = '\x1b[2m';

function rgb(r: number, g: number, b: number): string {
  return `\x1b[38;2;${r};${g};${b}m`;
}

function boldRgb(r: number, g: number, b: number): string {
  return `\x1b[1;38;2;${r};${g};${b}m`;
}

// ── Theme Definitions ─────────────────────────────────────────

export const THEMES: Record<string, ThemeColors> = {
  cometix: {
    model: rgb(86, 182, 194),      // bright teal
    project: rgb(142, 192, 124),   // aqua green
    git: rgb(143, 175, 209),       // soft blue
    gitBranch: rgb(143, 175, 209),
    gitDirty: rgb(224, 175, 104),  // warm yellow
    context: rgb(142, 192, 124),   // green
    contextWarn: rgb(250, 189, 47), // yellow
    contextCritical: rgb(251, 73, 52), // red
    usage: rgb(142, 192, 124),
    usageWarn: rgb(250, 189, 47),
    cost: rgb(215, 153, 33),       // gruvbox gold
    effort: rgb(177, 98, 134),     // soft violet
    effortHigh: boldRgb(251, 73, 52),
    effortMed: rgb(250, 189, 47),
    effortLow: rgb(142, 192, 124),
    dir: rgb(152, 195, 121),       // soft green
    separator: rgb(102, 92, 84),   // gray
    label: rgb(168, 153, 132),     // dim
    barFilled: '█',
    barEmpty: '░',
    icons: { model: '✦', dir: '⌂', git: '⎇', context: '', effort: '↯', style: '❋', worktree: '⊕', vim: '⌨', cost: '', usage: '', duration: '⏱' },
    segmentSep: '│',
  },

  dracula: {
    model: rgb(189, 147, 249),     // purple
    project: rgb(139, 233, 253),   // cyan
    git: rgb(255, 184, 108),       // orange
    gitBranch: rgb(255, 184, 108),
    gitDirty: rgb(241, 250, 140),  // yellow
    context: rgb(80, 250, 123),    // green
    contextWarn: rgb(241, 250, 140),
    contextCritical: rgb(255, 85, 85),
    usage: rgb(80, 250, 123),
    usageWarn: rgb(241, 250, 140),
    cost: rgb(255, 215, 0),        // gold
    effort: rgb(189, 147, 249),
    effortHigh: boldRgb(255, 85, 85),
    effortMed: rgb(241, 250, 140),
    effortLow: rgb(80, 250, 123),
    dir: rgb(139, 233, 253),
    separator: rgb(98, 114, 164),
    label: rgb(98, 114, 164),
    barFilled: '█',
    barEmpty: '░',
    icons: { model: '◈', dir: '⌂', git: '⎇', context: '', effort: '↯', style: '❋', worktree: '⊕', vim: '⌨', cost: '', usage: '', duration: '⏱' },
    segmentSep: '│',
  },

  gruvbox: {
    model: rgb(215, 153, 33),      // gold
    project: rgb(152, 195, 121),   // green
    git: rgb(143, 175, 209),       // blue
    gitBranch: rgb(143, 175, 209),
    gitDirty: rgb(224, 175, 104),  // yellow
    context: rgb(142, 192, 124),
    contextWarn: rgb(250, 189, 47),
    contextCritical: rgb(251, 73, 52),
    usage: rgb(142, 192, 124),
    usageWarn: rgb(250, 189, 47),
    cost: rgb(215, 153, 33),
    effort: rgb(177, 98, 134),
    effortHigh: boldRgb(251, 73, 52),
    effortMed: rgb(250, 189, 47),
    effortLow: rgb(142, 192, 124),
    dir: rgb(152, 195, 121),
    separator: rgb(102, 92, 84),
    label: rgb(168, 153, 132),
    barFilled: '█',
    barEmpty: '░',
    icons: { model: '✦', dir: '⌂', git: '⎇', context: '', effort: '↯', style: '❋', worktree: '⊕', vim: '⌨', cost: '', usage: '', duration: '⏱' },
    segmentSep: '│',
  },

  nord: {
    model: rgb(136, 192, 208),     // frost
    project: rgb(163, 190, 140),   // green
    git: rgb(180, 142, 173),       // purple
    gitBranch: rgb(180, 142, 173),
    gitDirty: rgb(235, 203, 139),  // yellow
    context: rgb(163, 190, 140),
    contextWarn: rgb(235, 203, 139),
    contextCritical: rgb(191, 97, 106),
    usage: rgb(163, 190, 140),
    usageWarn: rgb(235, 203, 139),
    cost: rgb(235, 203, 139),
    effort: rgb(180, 142, 173),
    effortHigh: boldRgb(191, 97, 106),
    effortMed: rgb(235, 203, 139),
    effortLow: rgb(163, 190, 140),
    dir: rgb(136, 192, 208),
    separator: rgb(76, 86, 106),
    label: rgb(76, 86, 106),
    barFilled: '█',
    barEmpty: '░',
    icons: { model: '✦', dir: '⌂', git: '⎇', context: '', effort: '↯', style: '❋', worktree: '⊕', vim: '⌨', cost: '', usage: '', duration: '⏱' },
    segmentSep: '│',
  },

  minimal: {
    model: '\x1b[0m',
    project: '\x1b[32m',
    git: '\x1b[0m',
    gitBranch: '\x1b[0m',
    gitDirty: '\x1b[33m',
    context: '\x1b[32m',
    contextWarn: '\x1b[33m',
    contextCritical: '\x1b[31m',
    usage: '\x1b[32m',
    usageWarn: '\x1b[33m',
    cost: '\x1b[33m',
    effort: '\x1b[0m',
    effortHigh: '\x1b[1;31m',
    effortMed: '\x1b[33m',
    effortLow: '\x1b[32m',
    dir: '\x1b[2m',
    separator: '\x1b[2m',
    label: '\x1b[2m',
    barFilled: '▰',
    barEmpty: '▱',
    icons: { model: '', dir: '', git: '', context: '', effort: '', style: '', worktree: '', vim: '', cost: '', usage: '', duration: '' },
    segmentSep: '·',
  },
};

export type ThemeName = keyof typeof THEMES;

export function getTheme(name: string): ThemeColors {
  return THEMES[name] ?? THEMES.cometix;
}

export function listThemes(): string[] {
  return Object.keys(THEMES);
}
