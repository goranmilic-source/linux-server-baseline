# Entry 1:
## SSH Keys
Adding SSH_keys into any file will be flagged by the pre-commit and git leaks scan.
The scan is tripped by the "SSH_KEY" values in the config files.

### Bypass
Add the # gitleaks:allow to the line that should be ommited.
WARNING: this is not to be used to bypass security. Instead, it is to rectify false positives such as the case above.


# Entry 2:
## Ansible Firewall Port Management
If you are managing ports with Ansible by adding ports to the defaults-->main.yaml it will add those ports to the "ufw" on the target machinges.

HOWEVER

If you REMOVE ports from the defaults-->main.yaml file, the ports on the target machine WILL NOT be removed. They will stil be presetn in the ufw config file.

You have to MANUALLY close ports on the target hosts.
This is something that should be scripted to happen automatically. Can it be done with a handler?

Check the commands section for the Ansible command which will remove the port.

I have added a "remove section" that will run after the add rule removin all unnecessary ports. This ensures that no lingering, unused, ports remain.


# Entry 3:
## Fail2Ban
If you have any changes to the configuration files, such as lines added or removed to the files, simply RELOADING the service does not pick up those new changes.
Instead, you have to RESTART the service for the files to be re-read and applied.
