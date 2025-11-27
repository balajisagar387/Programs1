#!/bin/bash
# Author: Your Name
# Description: Example production-ready script

set -euo pipefail
IFS=$'\n\t'
LOG="/var/log/myscript.log"

trap 'echo "Error on line $LINENO" >> "$LOG"' ERR

log() { echo "$(date +%F_%T): $*" >> "$LOG"; }

main() {
  log "Script started"
  # your commands here
  log "Script completed successfully"
}

main "$@"