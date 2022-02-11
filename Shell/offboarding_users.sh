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
# GNU General Public License for more details. <http://www.gnu.org/licenses/>
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

# Delete the user
users_delete(){
	# Loop through the user lists
	for username in $1
	do
		if [ "$username" == "firstname.surname" ]; then
			continue
		else
		# Verify username isn't existing
			if check_user "$username" ; then
				sudo userdel -r $username
				echo -e "User $username has been deleted \n"
			else
				echo -e "User $username does not exist \n"
			fi          
		fi
	done
	echo -e "Selected users have been deleted \n"
	reset_env
}

#Clear the Skel directory and remove the group
reset_env() {
	sudo groupdel $groupname
	sudo rm -rf $skel_path
	echo "Environment has been reset"
}


main(){
	echo "running the $0 script"

	#Create Group
	#create_group_after_check

	# Verify CSV file exists and not empty

	if [ -e "$filename" ]; then
		echo -e "CSV file $filename exists \n"

	# Extract, Concatenate  and Clean the usernames found on the CSV file
	# AWK was used instead of a while loop to speed up the process of screening the usernames - https://unix.stackexchange.com/questions/169716/why-is-using-a-shell-loop-to-process-text-considered-bad-practice
		name_list=$(gawk -F, '{ gsub(" ,",","); gsub(" ","-"); print tolower($1"."$2)}' $filename)

	# Delete created users
		users_delete "$name_list"
	else
		echo -e "File $filename doesn't exist\n"
	fi
}

# Call the main function
main