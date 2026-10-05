# Entry 1:
## SSH Keys
Adding SSH_keys into any file will be flagged by the pre-commit and git leaks scan.
The scan is tripped by the "SSH_KEY" values in the config files.

### Bypass
Add the # gitleaks:allow to the line that should be ommited.
WARNING: this is not to be used to bypass security. Instead, it is to rectify false positives such as the case above.
