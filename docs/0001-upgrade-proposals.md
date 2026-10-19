## Upgrades to be completed in the future.
1. Add an NTP server variable that connects to your closest geographical location.

2. Verify all logging for privilaged (sudo, su) commands executed on the system.

3. Add a section for a mounted, imutable drive to store logs on.

4. Create a script that would read the Users from the /roles/users/main.yaml section and use ssh-keygen to automatically create the ssh keys, put the private keys in the .ssh folder and copy the public keys to the /roles/users/files section. - Completed.

Issue:
    This does not update the ssh_key section in the user_add.yml file. There would be no point in going into the user_add file.yml, adding users names, then running the script to generate keys, then adding the key names to the user_add.yml file. This has to be one step only.

Potential Resolution Plan:
    Create a list of users the Administrator would populate.
    Create a script that would read the list of users.
    Have the script generate the keys using the user's names as input to destinguish key ownership.
    Hace the script create the output user_add.yml file, copy the keys to the /roles/users/files directory, and update the user_add.yml file with the users and keys that need to be created.

Solution:
    The proposed resolution has been implemented.

Goal achieved!



5. Split files into UserAdd and User Remove to remove potential errors from reading everything forom one script.

Solution:
    Under /roles/users/defaults, create a directory called "main" and put all the files under it. Ansible will run everything in the /roles/users/defaults/main/* in the same manner as if it was written in a main.yml file.

Goal achieved!

6. Create a file to create groups.


7. Auto copy the main admin SSH key.
The Default username should be standardized admin/opsadmin/bob.
sshk-copy-id -i <location of public key> aboveuser@host.name
Silently accept the incoming key
Need the initial password.

8. Add a custom shell prompt colors username:host (this is just for estethics and fun)
