#!/bin/bash
# File setup.sh
# Run this with the following command:
# bash setup.sh

# Define absolute paths to key files
ranger_key=~/.ssh/id_rsa_ranger
personal_key=~/.ssh/id_rsa_personal

# Check if SSH keys already exist and delete them
if [[ -f $ranger_key && -f $personal_key ]]; then
    echo "Existing SSH keys found and will be deleted."
    rm $ranger_key $ranger_key.pub
    rm $personal_key $personal_key.pub
fi

# Check if SSH configurations for GitHub already exist and delete them
ssh_config=~/.ssh/config
if grep -q "github.com-BruceRanger" $ssh_config && grep -q "github.com-Personal" $ssh_config; then
    echo "Existing SSH configurations for GitHub found and will be deleted."
    sed -i '/github.com-BruceRanger/,/github.com-Personal/d' $ssh_config
fi


# Generate SSH keys with custom filenames
ssh-keygen -t rsa -b 4096 -C "work@comcast.net" -f $ranger_key
ssh-keygen -t rsa -b 4096 -C "personal@comcast.net" -f $personal_key

# Display public keys
echo "Ranger SSH Public Key:"
cat $ranger_key.pub
echo "Personal SSH Public Key:"
cat $personal_key.pub

# Prompt the user to email the public keys
echo "Please email the public keys to your collaborator. Press Enter to continue when done."
read

# Configure SSH for GitHub
# Create or edit the SSH config file
ssh_config=~/.ssh/config
touch $ssh_config

# Add configurations for GitHub accounts
echo "Host github.com-BruceRanger" >> $ssh_config
echo "  HostName github.com" >> $ssh_config
echo "  User git" >> $ssh_config
echo "  IdentityFile $ranger_key" >> $ssh_config

echo "Host github.com-Personal" >> $ssh_config
echo "  HostName github.com" >> $ssh_config
echo "  User git" >> $ssh_config
echo "  IdentityFile $personal_key" >> $ssh_config

echo "SSH configurations have been added to $ssh_config"



echo "SSH keys have been set up and configured for your two GitHub accounts."

# Navigate to your Git repository directory
echo "Run this script from your MandArt3 repository directory."
echo "Are you in the correct directory? (y/n)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    # Unset the existing origin (HTTPS)
    git remote rm origin

    repourl= git@github.com:denisecase/MandArt3.git

    # Set the new origin to use SSH
    git remote add origin "${repourl}:bruceranger/MandArt3.git"

    # Verify the new origin URL
    git remote -v

else
    echo "Exiting..."
    exit 1
fi
