# Ansible Commands:
## Create roles:
    cmd: ansible-galaxy role init <folder_name>

## Creating several roles:
    cmd:  for r in base users ssh firewall fail2ban healthcheck; do ansible-galaxy role init "$r"; done


## Outline of ansible.cfg
Sets the defaults for the ansible environment
    [defaults]
    inventory = inventory/hosts.yaml
    roles_path = roles
    private_key_file = ~/.ssh/<keyname>
    host_key_checking = True
    interpreter_python = auto_silent

## Roles structure breakdown
    <folder_name>
        - defaults <-- Used to store variables that will be called upon from other folders.
            -- main.yaml <-- Add var_name="var_value"
        - files <-- Files that will be copied over to the target system.
            -- file1
            -- file2
        - handlers <-- Runs a command only if something changed
            -- main.yaml
        - meta
            --
        - tasks <-- Uses the available ansible modules to send commands to run on the remote host.
            -- main.yaml <-- Use the website to view all available commands. You can write your own.
        - templates <-- Uses Jinja2 templates to create files.
            -- template1.j2
            -- template2.j2
        - tests
            --
        - vars
            --

## This line runs any handlers right now.
- name: Apply systemd changes before enabling the timer
  ansible.builtin.meta: flush_handlers

## Analyze a service.
Especially if you are troubleshooting it or it is your service
    cmd: systemd-analyze verify /etc/systemd/system/healthcheck.timer

## Remove a ufw firewall rule
    cmd: ansible <host-name> -m community.general.ufw -a "rule=allow port=8080 proto=tcp delete=true" --become -K

## Run a command on the remote machine:
    cmd: ansible baseline -m command -a "uptime"
    cmd: ansible baseline -m command -a "touch something.txt"

## Create a "graph" of the hosts and their groups based on what you have in the hosts file
    cmd: ansible-inventory --graph

## Ping all the sytems in the hosts.yaml file
    cmd: ansible all -m ping

## Send a command, "uptime", or any other command to all systems in the "baseline" group.
    cmd: ansible baseling -m command -a "uptime"

    -m = MODULE_NAME
    -M = MODULE_PATH

# Set up ansible virtual directory
    pipx install yamllint
    pipx install ansible-lint
    yamllint --version
    ansible-lint --version
    shellcheck --version (this is an OS level app.)


The lint file configuration is stored in the following file located in the root dir:
    .yamllint

Create the following file and add a profile to it to enforce strictness level. Also create in root dir:
    .ansible-ling

        ---
        profile: production
Ansible-lint finds your roles, playbook and ansible.cfg by itself.


## Ansible Galaxy
Ansible Galaxy is a free, open-source repository and command-line tool used for finding, downloading, and sharing reusable automation content for Ansible.  It serves as a central hub where the community and vendors distribute pre-packaged automation units known as roles and collections, allowing users to jump-start projects without writing code from scratch

    cmd: ansible-galaxy collection install -r requirements.yml

requirements.yaml:
    ---
    collections:
    - name: community.general
    - name: ansible.posix

Installs the outlined roles into the ansible virtual directory


## To list all installed modules that are supported by -m run:
    cmd: ansible-doc -l

## -a stands for argument.

# Acquires information about a host managed by ansible:
    cmd: ansible ubuntu-host -m setup -a "filter=ansible_distribution*"

# Check the syntax of the config files
    cmd: ansible-playbook site.yaml --syntax-check

playbook: site.yaml = All is well.

# Supporting Linux Commands:
## Create an SSH key pair to connect to the system(s).
    cmd: ssh-keygen -t ed25519 -C "<some@user.name>" -f ~/.ssh/<key_output_name>

## SSH Copy the key to the remote system (Linux only)
    cmd: ssh-copy-id -i <key_name>.pub <username>@<host_name_or_ip>

## Shows failed services
    cmd: systemctl --failed

## Shows the calendar and when the next task will run based on the given numbers
    cmd: systemd-analyze calendar "*:0/5"

## When changing config files/timers, you have to reload the systemd-daemon.
    cmd: systemctl daemon-reload

## Display times in sysdemctl:
    cmd: systemctl list-timers --all

## Logrotate
    /etc/logrotate.d/<put_instructions_here>

    Do a dry run of what log rotation will be performed.
        cmd: sudo logrotate -d /etc/logrotate.d/<template>
        cmd: sudo logrotate -f -v /etc/logrotate.d/<template>

    -d debug mode
    -f force rotate even if it is not due.
    -v verbose

# Linting
    1. yamllint checks every YAML file for formatting mistakes
    2. ansible-lint checks your playbook and roles for errors and bad practices
    3. shellcheck checks your Bash script



# Fail2Ban
## Blocks the IP address of the attacker.
How it works:
    jail.conf  →  jail.d/*.conf  →  jail.local  →  jail.d/*.local
    (defaults)    (Ubuntu's tweaks)  (YOUR file)

Never edit the jail.conf file as it gets auto updated by package upgrades. Any changes you put in the jaul.conf are at risk of being automatically overwritten.

Add any addresses you never want banned into the fail2ban_ignore_ips: section.

## Check what is being monitored
    cmd: sudo fail2ban-client status
    cmd: sudo fail2ban-client status <service_name>

## Unbanning
    Specific IP address:
    cmd: sudo fail2ban-client set sshd unbanip <ipaddress_to_unban>

    Unban all:
    cmd: sudo fail2ban-client unban --all


# Scripting in Linux
Strict mode, making Bash fail loudly.
By default, Bash carries on after errors, which can turn a broken check into a false "OK". Professional scripts start with:

    cmd: set -Eeuo pipefail
    Flag	    Meaning	Protects against
    -e	        Stop when a command fails	Carrying on with bad data
    -u	        Stop when using an unset variable	Typos in variable names
    -E	        Error handling also applies inside functions	Errors inside functions slipping
    -o pipefail	    A pipeline fails if any part fails	broken_command | tail looking successful because tail workedpast the trap.

And a trap, which says "if anything fails unexpectedly, run this first":

    cmd: trap 'echo "UNKNOWN: healthcheck failed on line ${LINENO}" >&2; exit 3' ERR

So if the script itself breaks, it exits with 3 (UNKNOWN) instead of a misleading result.

## Checking the syntax and Dry Runs
    cmd: bash -n roles/healthcheck/files/healthcheck.sh
        bash -n reads the script for syntax errors without running anything.

    cmd: shellcheck roles/healthcheck/files/healthcheck.sh
        shellcheck looks for bugs and risky patterns.


# Local and Remote CI.
## Workflows
Github workflows are located in the project under
    cmd: .github/workflows/ci.yaml

The workflows are defined there and are applied in GitHub when time comes for merging code to the main branch.
Idealy, you would have all the CI tools installed locally.
They would run against your code before it is allowed to be uploaded to the branch.
When all the local red-flags are green, your code can be uploaded to the branch.

# GM Notes
    A noteworthy pattern is that: Whenever you have to owerwrive a configuration file from a third party software you would use the "templates" folder and Jinja2 Tamplating.

    Look into how accurate the above really is.
