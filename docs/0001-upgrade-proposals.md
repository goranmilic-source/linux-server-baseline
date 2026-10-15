## Upgrades to be completed in the future.
1. Add an NTP server variable that connects to your closest geographical location.
2. Verify all logging for privilaged (sudo, su) commands executed on the system.
3. Add a section for a mounted, imutable drive to store logs on.
4. Create a script that would read the Users from the /roles/users/main.yaml section and use ssh-keygen to automatically create the ssh keys, put the private keys in the .ssh folder and copy the public keys to the /roles/users/files section. - Completed.
5. Split files into UserAdd and User Remove to remove potential errors from reading everything forom one script.
