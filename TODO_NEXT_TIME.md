# TODO: Next Time - Disk Usage Analysis

## Context

User asked about generating a disk usage report using the Pareto principle (80/20 rule) to identify which
directories consume the most space.

## Available Tools in packages.nix

1. **baobab** (line 21) - Already installed! This is a graphical disk usage analyzer for GNOME that shows disk usage
   in a treemap visualization, perfect for Pareto analysis.

2. **dua** (line 65) - Already installed! A modern CLI disk usage analyzer that's an alternative to `du`.

## Recommendations for Next Time

### For GUI Analysis (Pareto-friendly)

```bash
# Launch baobab for visual disk usage analysis
baobab /
```

### For CLI Analysis

```bash
# Use dua for interactive terminal-based analysis
dua interactive /

# Or for a quick summary of largest directories
dua -n 20 /
```

### Additional Tools to Consider Installing

1. **ncdu** - NCurses disk usage analyzer, excellent for SSH sessions
   - Add to packages.nix: `ncdu # NCurses disk usage analyzer`

2. **dust** - A more intuitive version of du written in Rust
   - Add to packages.nix: `dust # Intuitive disk usage analyzer`

### Quick Command for Pareto Analysis (using existing tools)

```bash
# Find top 20% of directories that likely consume 80% of space
dua -n 20 --format line-chart / 2>/dev/null | sort -h
```

## Note

The user already has good tools installed for this task. Baobab is particularly well-suited for Pareto analysis as it
provides a visual treemap where large blocks immediately show which directories consume the most space.
