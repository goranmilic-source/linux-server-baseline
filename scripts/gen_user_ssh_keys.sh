#!/bin/bash

# Create the array to store the user values.
ARR_USER_CREATE=()

# The filter that will be used to seperate the users.
# NOTE: If you have users in the "/roles/users/defaults/main.yaml --> users_remove" section.
# Keys will be created for those users. Do not keep users in the "users_remove" section.
readarray -t ARR_USER_CREATE < <(egrep '[[:space:]][[:space:]]\-[[:space:]][a-z]' ./roles/users/defaults/main.yml \
    | awk '{print $3}' \
    | grep -v "\[\]")


for i in "${ARR_USER_CREATE[@]}"; do
    ssh-keygen -t ed25519 -C "$i@company_name.com" -q -N "" -f ./$i.key
    cp $i.key.pub ./roles/users/files
done

#printf($ARR_USER_CREATE[0])
