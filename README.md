# Unraid Folder Prune Script

A simple Unraid **User Scripts** utility that automatically deletes old files or folders from a directory, keeping only the newest **N** items.  
Includes **elapsed time tracking** and an optional **Discord notification** when the job completes.

---

## Features

- Keeps the newest **N** items in a folder
- Deletes older files and/or directories
- Safe guards to prevent accidental root deletion
- Dry-run mode for testing
- Discord webhook notification
- Displays total runtime and number of items pruned
- Designed for **Unraid User Scripts**

---

## Configuration

Edit the variables at the top of the script:

```bash
TARGET_DIR="/mnt/user/backups/MyBackups"
KEEP_COUNT=7
DRY_RUN=true
DISCORD_WEBHOOK="https://discord.com/api/webhooks/REPLACE_ME"
```
| Variable          | Description                         |
| ----------------- | ----------------------------------- |
| `TARGET_DIR`      | Folder to prune                     |
| `KEEP_COUNT`      | Number of newest items to keep      |
| `DRY_RUN`         | `true` = no deletions, preview only |
| `DISCORD_WEBHOOK` | Discord webhook URL (optional)      |

