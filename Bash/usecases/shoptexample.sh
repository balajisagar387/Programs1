#!/usr/bin/env bash
# shoptexample.sh - safe cleaner demonstrating bash shopt: dotglob, nullglob, extglob
# Usage examples:
#   ./shoptexample.sh -d /path/to/dir -p '!(*.keep|README)'        # remove everything except *.keep and README
#   ./shoptexample.sh -p '*.tmp' --dry-run                        # show matches only
#   ./shoptexample.sh -p '.??*' -y                                # delete hidden files (dotglob needed)
set -euo pipefail

# defaults
dir="."
pattern="*"
dry_run=0
force=0

# save shopt states to restore later
shopt -q dotglob  && _dotglob_saved=1 || _dotglob_saved=0
shopt -q nullglob  && _nullglob_saved=1 || _nullglob_saved=0
shopt -q extglob   && _extglob_saved=1 || _extglob_saved=0

restore_shopts() {
    if [ "${_dotglob_saved:-0}" -eq 1 ]; then shopt -s dotglob; else shopt -u dotglob; fi
    if [ "${_nullglob_saved:-0}" -eq 1 ]; then shopt -s nullglob; else shopt -u nullglob; fi
    if [ "${_extglob_saved:-0}" -eq 1 ]; then shopt -s extglob; else shopt -u extglob; fi
}
trap restore_shopts EXIT

# enable the options we want for this script
shopt -s dotglob nullglob extglob

# simple arg parsing
while [ $# -gt 0 ]; do
    case "$1" in
        -d|--dir) dir="$2"; shift 2;;
        -p|--pattern) pattern="$2"; shift 2;;
        --dry-run) dry_run=1; shift;;
        -y|--yes) force=1; shift;;
        -h|--help) sed -n '1,120p' "$0"; exit 0;;
        *) echo "Unknown arg: $1"; exit 2;;
    esac
done

# validate directory
if [ ! -d "$dir" ]; then
    echo "Directory not found: $dir" >&2
    exit 2
fi

# collect matches in the target dir using the current shopt settings
pushd -- "$dir" >/dev/null
matches=( $pattern )
popd >/dev/null

if [ "${#matches[@]}" -eq 0 ]; then
    echo "No files match pattern '$pattern' in '$dir'."
    exit 0
fi

echo "Matches (${#matches[@]}):"
printf '  %s\n' "${matches[@]}"

if [ "$dry_run" -eq 1 ]; then
    echo "--dry-run: no changes made."
    exit 0
fi

if [ "$force" -ne 1 ]; then
    read -r -p "Proceed to move matched files to .trash in '$dir'? [y/N] " ans
    case "$ans" in
        [yY]|[yY][eE][sS]) ;;
        *) echo "Aborted."; exit 0;;
    esac
fi

# try to use a user-level trash if available (trash-cli). Fallback to .trash inside dir.
if command -v trash-put >/dev/null 2>&1; then
    echo "Using trash-put to send files to system trash..."
    for f in "${matches[@]}"; do
        trash-put -- "$dir/$f" 2>/dev/null || mv -- "$dir/$f" "$dir/.trash/" 2>/dev/null
    done
else
    stamp=$(date +%Y%m%d-%H%M%S)
    dest="$dir/.trash/$stamp"
    mkdir -p -- "$dest"
    echo "Moving files to $dest"
    # Use mv with full paths to avoid confusion if pattern includes directories
    for f in "${matches[@]}"; do
        mv -- "$dir/$f" "$dest"/
    done
fi

echo "Done."