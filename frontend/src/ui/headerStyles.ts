export type HeaderStyles = {
  header: string;
  linkHover: string;
  menuButton: string;
  mobileMenu: string;
};

export const HEADER_STYLE_PRESETS: Record<'light' | 'solid', HeaderStyles> = {
  light: {
    header:
      'border-b border-foreground/10 bg-background/95 text-foreground backdrop-blur md:border-transparent md:bg-transparent md:text-white',
    linkHover: 'hover:text-accent md:hover:text-white/80',
    menuButton: 'border border-foreground/15 text-foreground',
    mobileMenu: 'border-foreground/10 bg-background text-foreground',
  },
  solid: {
    header: 'border-b border-foreground/10 bg-background/95 text-foreground backdrop-blur',
    linkHover: 'hover:text-accent',
    menuButton: 'border border-foreground/15 text-foreground',
    mobileMenu: 'border-foreground/10 bg-background text-foreground',
  },
};
