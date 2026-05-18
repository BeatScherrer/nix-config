---
name: mtr-diagnose
description: SSH into MTR robots and master servers to investigate issues and run diagnostics
---

Investigate an issue on MTR robot(s) or master server(s).

## MTR Fleet

All MTR hosts are configured as SSH aliases in `~/.ssh/config.d/mtr`. Run `grep '^Host ' ~/.ssh/config.d/mtr` to list available hosts.

## Instructions

1. Ask the user which machine(s) to investigate if not specified in $ARGUMENTS
2. SSH into the machine using the short alias (e.g. `ssh b3`)
3. Start with a quick health check:
   - `systemctl --failed` for failed services
   - `journalctl -p err -n 50 --no-pager` for recent errors
   - `df -h` for disk space
   - `free -h` for memory
   - `uptime` for load
   - `docker ps` if docker is running (check with `systemctl is-active docker`)
4. Check mtrsys-specific services and logs as found on the machine
5. On robots, check the following application logs (look for recent errors/warnings with `tail -n 100`):
   - `rsa.log`
   - `odometry.log`
   - `mission_execution.log`
   - `navigator.log`
   - `dds_router.log`
   These logs are located in `$MTR_LOGS_DIR`. If none of them show leads, check the other log files in that directory for clues.
6. Investigate based on the user's description of the issue
7. Report findings concisely with actionable next steps
