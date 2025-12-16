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

## How It Works

1. Scans the target directory (top level only)

2. Sorts items by modified time (newest first)

3. Keeps the newest `KEEP_COUNT` items

4. Deletes the rest

5. Sends a Discord message with:

  - Items pruned

  - Total runtime

  - Status (Success / Failed)

## Example Discord Message
```
🧹 Prune Completed (LIVE)
Target: /mnt/user/backups/MyBackups
Kept: 7
Pruned: 5 item(s)
Total time: 12s
Status: SUCCESS
```
## Recommended Usage

Test first with `DRY_RUN=true`

Ideal for:

Backup folders

Timestamped directories

Cleanup jobs

Schedule via Unraid User Scripts (Daily / Weekly / Custom cron)

## Notes

Only prunes direct children of the target directory

Does not recurse into subfolders

Uses standard Linux tools (`find`, `rm`)

Safe guards prevent accidental deletion of /
