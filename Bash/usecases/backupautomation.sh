⚙️ Example — Backup Automation
#!/bin/bash
SRC=/home/user/projects
DEST=/mnt/backup/projects_$(date +%F).tar.gz

tar czf "$DEST" "$SRC"
echo "Backup completed at $(date)" >> /var/log/backup.log