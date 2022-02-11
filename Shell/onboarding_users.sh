#!/bin/bash
# Onboarding user script.
# 
# Copyright (c) 2022 Olawale Abiola
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Set variable for the CSV filepath
filename="names.csv"

# Set variable for the group name
groupname=developer

# Set the variable for file path to the skel directory
skel_path="/etc/skel/.ssh/"

# Check if the user already exist
check_user(){
	grep -q \^${1} /etc/passwd && return 0
}

# Check if the group already exist
check_group(){
	grep -q \^${1} /etc/group && return 0
}

create_group_after_check(){
	if check_group "$groupname"; then
		echo -e "The group $groupname exists..\n"
	else
		sudo groupadd $groupname
		echo -e "The group $groupname has been created..\n"
	fi
}
	
# Initialise .skel directory with the ssh public key
initialise_skel(){
	if [ -e "${skel_path}/authorized_keys" ]
	then
		echo -e "ssh key auto configured..\n"
	else
		sudo mkdir -p -m u=rwx $skel_path
		cd $skel_path
		sudo tee authorized_keys 1>/dev/null <<-EOF 
		ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzKZyicHxIkklSrNlxsJyyTrcIdBIt84Z0cQb3R4k0jH53kxkaT5hP8tfWTe62LXi7vV86fY+SX7TBNM76XGCbw/6vrMGegm6J1x2i1AiLNwq5nqTjOGn0AIwku4IlCCLAB7tdfRyVuCarmBlwny3lzRyybIUAWXR/D6vpN09MsDILbKdhay+Q/p9OUBMSLPqXdY/QIh/Oe3rVv1lwY3AohNfq7V3tO88zKswfA5iiexNiSYX1myT0OrX8cBE771j9quoNZhQgaLI1mIMtAvnHQChrn9k2nUaO/BMBCQGol5XzGv1ado7hgoVPoluIUD+FGNo/pH4zcmDLICH6drXY/C9MESnkMUPLFxBXKO/OitApY71vRao9nAhAwpVMsy6FqiOb5uawhvhoHYIHTV/f4EtagVagRMP2PxYMYR6jykIV4MPJTkCm+lGhTyMlRu+qRQjdLn8AAtHf4aEV8dIkoGh088DI7eA/4o0wz4OV4upH5ewSFS+5IHmRECEW5Nc=
		EOF
		echo -e "Initialised the Skel Directory.. \n"
	fi
}

users_create(){
	# Initialise Skel
	initialise_skel
	# Loop through the user lists
	echo -e "Proceeding to create the users found in the ${filename} file.. \n"
	for username in $1
	do
		if [ "$username" == "firstname.surname" ]; then
			continue
		else
		# Verify username isn't existing
			if check_user "$username" ; then
				echo -e "User $username already exists... \n"
			else
			# Create the user with home directory, add to the developers group
			   sudo useradd -m $username -G $groupname -s /bin/bash
			   echo -e "User $username has been created successfully..\n"
			fi
		fi
	done
	echo -e "All users have been created... \n"
}

main(){
	echo "running the $0 script"

	# Create Group
	create_group_after_check

	# Verify CSV file exists and not empty

	if [ -e "$filename" ]; then
		echo -e "CSV file $filename exists \n"

	# Extract, Concatenate  and Clean the usernames found on the CSV file
    # AWK was used instead of a while loop to speed up the process of screening the usernames - https://unix.stackexchange.com/questions/169716/why-is-using-a-shell-loop-to-process-text-considered-bad-practice
	    name_list=$(gawk -F, '{ gsub(" ,",","); gsub(" ","-"); print tolower($1"."$2)}' $filename)

	# Loop through the usernames in the file and create the users
    	users_create "$name_list"

	else
		echo -e "File $filename doesn't exist\n"
	fi
}

#Call the main function
main
