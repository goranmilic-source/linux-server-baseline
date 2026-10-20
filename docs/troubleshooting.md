# Incident and troubleshooting log

A record of any problems that came across while building this project. Records are kept here
in the structured incident log. The long format should be short, concise, but with enough details not to be vague. Root cause is very important along with the fix and prevention.


## Index

| ID | Section | Title | Type |
|----|---------|-------|------|
| 001 | DEV   | Pre-commit failing due the SSH keys | DevOps environment |
| 002 | DEV   | Ansible not removing ports | DevOps environment |
| 003 | DEV   | fail2ban banned IPs but didn't block them | DevOps environment |
---

## Format to be used:

00X - Descriptive title of incident

**Section:** Where did this happen? - **Type:** (prod, client, internal, dev, qa, etc)

**Symptom:** What happened?
**Impact:** What does is affect?
**Diagnosis:** How did this happen?
**Root cause:** Why did this happen in the first place?
**Fix:** How do we get it back to functional.
**Prevention:** How do we prevent it from happening in the future.


## 001 - Pre-commit failing due the SSH keys

**Section:** Staging server - **Type:** DevOps environment

**Symptom:** The Pre-commit that that checks the code found variable with the name SSH_KEY.

**Impact:** The code is unable to be uploaded to the Git repository unless it passes the pre-check and gitleaks.

**Diagnosis:** A descriptive variable was used with the name SSH_KEY. The variable itself did not contain the key. It did contain a path to where they key was securely stored. The Pre-Commit saw this keyword repeated three times, as three users were being created, and flagged it as a security issue.

**Root cause:** Pre-commit security feature.

**Fix:** Verified that no key information was stored in the variable and that this reporting was a false positive. Added the "Ignore" to these variables as they were created securely.

**Prevention:** Use variables with a different name to avoid being flagged in the future.


## 002 - Ansible not removing ports
**Section:** Dev Server   - **Type:** DevOps Environment

**Symptom:** The ansible "Firewall" role would run and add ports to the servers firewall. However, if ports are REMOVED from the ansible configuration, they would not be removed from the server.

**Impact:** This can give you a false sense of security as you would think that the ports were closed, but in reality they were not.

**Diagnosis:** The ansible script must be updated to remedy this issue.

**Root cause:** Ansible script configuration.

**Fix:** Manually remove ports. However, this creates drift.

**Prevention:** Updated the ansible "firewall" role to also remove any ports that are unused.


## 003 - fail2ban banned IPs but didn't block them

**Section:** Dev Server - **Type:** DevOps Environment

**Symptom:** `fail2ban-client status sshd` listed ubuntu-dev as banned, but
ubuntu-dev could still connect. No ban rule appeared in `ufw status`.

**Impact:** Brute-force protection was silently ineffective: bans were
recorded but never enforced.

**Diagnosis:** Separated detection (working) from enforcement (not working).
`fail2ban-client get sshd actions` returned "No actions for jail sshd".
Reading `/var/log/fail2ban.log` as a timeline showed the handler's reload
flushed the old nftables action, with no line showing the new ufw action
being loaded.

**Root cause:** A `reload` doesn't reliably apply a change of ban action.
The jail was left with no action at all, and no error was logged because
the new action was never attempted.

**Fix:** Changed the role's handler from `reloaded` to `restarted`.
Verified with a real ban test: banned, refused, unbanned, reconnected.

**Prevention:** After config changes, compare what is configured with what is
actually loaded (`fail2ban-client get <jail> actions`).


# 004 "sshd -t" creating an error on first run.

**Section:** Managed Server - **Type:** DevOps Environment

**Symptom:** This is a known quirk with sshd -t validation on a fresh Ubuntu install, and it explains why the second run worked. The command "sshd -t"  requires a "/run/sshd" director to exist before it can run successfully.

**Impact:** The deployment script files when it runs for the first time.

**Diagnosis:** The script only fails the first time and returns an error. If the script is run a subsequent time, it works without the error.

**Root cause:** The SSH service has not been started after installation on the new server(s). Therefore the required folder has not yet been created. The folder is created after the error is displayed.

**Fix:** Add the following: Run the script twice.

**Prevention:** Updated the code to resolve the issue permanently.
1. Added a section to the /roles/ssh/tasks/main.yml to check if the /run/sshd directory exists. If not, create it.
2. Check if the sshd service is enabled and running.
3. Updated the /roles/ssh/handlers/main.yml file "Reload ssh - state" from reload to restart

Resolution: Added a line to the end of the installation command to start the service.




# 005 Empty directories need to be re-created

**Section:** Managed Server - **Type:** DevOps Environment

**Symptom:** Git does not upload/keep empty directories.

**Impact:** Any script relying on the roles/users/files directory will fail.

**Diagnosis:** The user_add.sh script terminated with an error due to the missing folder. Investigation confirmed that the code in GitHub does not contain the empty folder. Therefore, the pulled code is also missing the folder.

**Root cause:** Git file tracking design. Git does this intentionally and is part of their design.

**Fix:** Added a section in the script to check if the folder exists. If not, the folder will be created before files are copied to it.

**Prevention:** Any empty folders will not contain a .gitkeep file as a placeholder for that folder.
