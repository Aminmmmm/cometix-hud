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
export declare const THEMES: Record<string, ThemeColors>;
export type ThemeName = keyof typeof THEMES;
export declare function getTheme(name: string): ThemeColors;
export declare function listThemes(): string[];
//# sourceMappingURL=themes.d.ts.map