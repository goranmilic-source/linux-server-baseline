# Ansible Commands:
## Create roles:
    cmd: ansible-galaxy role init <folder_name>

## Creating several roles:
    cmd:  for r in base users ssh firewall fail2ban healthcheck; do ansible-galaxy role init "$r"; done

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
To list all installed modules that are supported by -m run:
    cmd: ansible-doc -l

-a stands for argument.


# Acquires information about a host managed by ansible:
    cmd: ansible ubuntu-host -m setup -a "filter=ansible_distribution*"

# Check the syntax of your playbook
    cmd: ansible-playbook site.yml --syntax-check

should return: playbook: site.yaml

# Check what the role will change on the destination server(s)
    cmd: ansible-playbook site.yml --check --diff -K

--check = dry run
--diff = show exactly which lines in files would change
-K = ask for your sudo password

# Supporting Linux Commands:
## Create an SSH key pair to connect to the system(s).
    cmd: ssh-keygen -t ed25519 -C "<some@user.name>" -f ~/.ssh/<key_output_name>

## SSH Copy the key to the remote system (Linux only)
    cmd: ssh-copy-id -i <key_name>.pub <username>@<host_name_or_ip>
