# Initial Design
All deployed servers should have the same base configuration that adheres to auditable standards of 27001 and 9001.
This is the minimum required for the aforementioned standards. Check the docs/0001-upgrade-proposals.md to see future upgrades.

## Applied Roles
They are executed in the oder listed below as one service builds on top of the last.

# Base
Located in /roles/base is responsible for the initial system update, applying the latest security and software upgrades, setting the timezone, installing the required toolset packages, and enabling the "Automatic Updates" on the server.
Depending on the function on the server and how updates are handeled, one might turn off "Automatic Updates" if the application running on the server is version sensitive.

# Users
Located in /roles/users is responsible for creating the same users across all servers.
This role can be run independently if users are being added or removed.
The users role provides the administrators with a centralized location for managin users.

The reasoning behind this is to minimize rouge accounts on servers when people leave. Lingering, active, admin accounts can pose serious security issues. Active rougue admin acounts are also very frowned upon during auditing.
The user role also creates the admin group and adds the users to that group along with the suoers file. The sudoers file is checked via visudo before anything is commited to avoid locking out yourself or new users.
The current sudoers setting is set up as "ALL=(ALL:ALL) NOPASSWD: ALL" change it if more rigorous restrictions are required.

# SSH
Located in /roles/ssh is responsible for setting up the SSH login rules and account lockout policy.
Starts off by ensuring an SSH server is installed. If it is not, it installs it.
The template is created of the policy is created under the /roles/ssh/templates folder.
** The naming convention is important**
OpenSSH daemon uses the first obtained value for any given keyword. Therefore the effective configuration is determined by which file is read first. Files with lower numerical values will be read and applied first.

# Firewall
Located in /roles/firewall is responsible for adding/removing required ports from ther server(s). Rogue ports can cause security issues when left unknowingly open. Rogue ports also show poorly on an audit finding.


# Fail2ban
Located in /roles/fail2band used in more secure environments where every connection should have a purpose. On an internal network, there should be no surprises of who or what is connecting to your server(s). Fail2Ban is used to either eliminate, or raise a red flag for servers or devices that are not supposed to be logging in to other servers.


# Healthcheck
Logs are collected for specified services. Add any services you deeam important into the healthcheck script. The timer can be adjusted to meet your needs. Logs retention is dependent on your (and/or your clients) security policy. The logs here cycle on a 4 week period with the oldest logs being replaced and the previous logs moving up by 1 week. Logs can be fed into a dashboard for further processing (not part of this deployment).

Located in /rolse/healthcheck comprises of three parts
1. Healthcheck Service
2. Healthcheck Timer
3. Log Rotation  /etc/logrotate.d folder. Default logs located in: /var/logs/healthcheck.log
