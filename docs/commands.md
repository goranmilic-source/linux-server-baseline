# Ansible Commands:
## Create roles:
    cmd: ansible-galaxy role init <folder_name>

## Creating several roles:
    cmd:  for r in base users ssh firewall fail2ban healthcheck; do ansible-galaxy role init "$r"; done


## ansible.cfg
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



## Run a command on the remote machine:
    cmd: ansible baseline -m command -a "uptime"
    cmd: ansible baseline -m command -a "touch something.txt"

## Create a "graph" of the hosts and their groups based on what you have in the hosts file
    cmd: ansible-inventory --graph

## Ping all the sytems in the hosts.yaml file
    cmd: ansible all -m ping

## Send a command, "uptime", or any other command to all systems in the "baseline" group.
    cmd: ansible baseling -m command -a "uptime"

## -m = MODULE_NAME
## -M = MODULE_PATH
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
