💡 Example — Disk Usage Monitor
#!/bin/bash
THRESHOLD=80
USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$USAGE" -ge "$THRESHOLD" ]; then
  echo "Warning: Disk usage is at ${USAGE}%!" | mail -s "Disk Alert" admin@example.com
fi
Uses df, awk, and mail together.

Runs automatically in cron to warn of low disk space.