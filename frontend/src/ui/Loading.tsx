type LoadingProps = {
  label?: string | null;
  className?: string;
};

export default function Loading({ label = 'Loading...', className }: LoadingProps) {
  const baseContainerClass = 'flex flex-col items-center justify-center gap-4 text-foreground';
  const containerClassName = [baseContainerClass, className].filter(Boolean).join(' ');
  const baseSpinnerClass = 'h-12 w-12 animate-spin rounded-full border-4 border-neutral-200 border-t-neutral-600';

  return (
    <div className={containerClassName} role="status" aria-live="polite">
      <div className={baseSpinnerClass} aria-hidden />
      {label ? <span className="text-sm font-medium">{label}</span> : null}
    </div>
  );
}
