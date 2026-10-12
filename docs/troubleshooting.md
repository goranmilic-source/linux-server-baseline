# Incident and troubleshooting log

A record of any problems that came across while building this project. Records are kept here
in the structured invident log. The long format should be short, concise, but with enough details not to be vague. Root cause is very imporant along with the fix and prevention.


## Index

| ID | Section | Title | Type |
|----|---------|-------|------|
| 001 | DEV   | Pre-commit failing due the SSH keys | DevOps environment |
| 002 | DEV   | Ansible not removing ports | DevOps environment |
| 003 | DEV   | fail2ban banned IPs but didn't block them | DevOps environment |
---

## Format to be used:

00X · Descriptive title of incident

**Section:** Where did this happen? · **Type:** (prod, client, internal, dev, qa, etc)

**Symptom:** What happened?
**Impact:** What does is affect?
**Diagnosis:** How did this happen?
**Root cause:** Why did this happen in the first place?
**Fix:** How do we get it back to functional.
**Prevention:** How do we prevent it from happening in the future.


## 001 · Pre-commit failing due the SSH keys

**Section:** Staging server · **Type:** DevOps environment

**Symptom:** The Pre-commit that that checks the code found variable with the name SSH_KEY.

**Impact:** The code is unable to be uploaded to the Git repository unless it passes the pre-check and gitleaks.

**Diagnosis:** A descriptive variable was used with the name SSH_KEY. The variable itself did not contain the key. It did contain a path to where they key was securely stored. The Pre-Commit saw this keyword repeaded three times, as three users were being created, and flagged it as a security issue.

**Root cause:** Pre-commit security feature.

**Fix:** Verified that no key information was stored in the variable and that this reporting was a false possitive. Added the "Ignore" to these variables as they were created securely.

**Prevention:** Use variables with a different name to avoid being flagged in the future.


## 002 · Ansible not removing ports
**Section:** Dev Server   · **Type:** DevOps Environment

**Symptom:** The ansible "Firewall" role would run and add ports to the servers firewall. However, if ports are REMOVED from the ansible configuration, they would not be removed from the server.

**Impact:** This can give you a false sense of security as you would think that the ports were closed, but in reality they were not.

**Diagnosis:** The ansible script must be updated to remedy this issue.

**Root cause:** Ansible script configuration.

**Fix:** Manually remove ports. However, this creates drift.

**Prevention:** Updated the ansible "firewall" role to also remove any ports that are unused.


## 003 · fail2ban banned IPs but didn't block them

**Section:** Dev Server · **Type:** DevOps Environment

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
