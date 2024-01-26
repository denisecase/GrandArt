ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6cPE8VV+EyDJUtFO1uEhA6BLglz0kptUcrQmY1/a79/HzYSkv11rS1JcBObfdczgWAYFGENysOfzRyRPFUSJlkli7XdIaZ2bylhQWOiVOSZmw5FQX3NXxW/pfHLJYmtSEcp2aMeHhWo/a3JDwCDcfSiAzTZ/ddXzkjM/XjJcQCSaUKLyX7M1fAXQl9QALIkVuB4D4fu3VMZPi/Nb8HZcJFGsQ3xfCUHTnlf/XFC9Mit+3LkYtkxjq75E4DtsOQ36r0StGP7JN39dYgs5g1ZBX0uLdYczWUW0ubNC1vm6A/R4WBoUCLs8u5eN7DpHwZLc+DVZr2MnrpGb7Ufg993oxIM3dexV7i60ZG/kc/db6TuEGKs6NQ642AAi3XA4JiX/siJWLCv1hXhnQqwXyJaJUW4fJqa4lJOE+eQO3TzNg9vg2mmsfU8qOvP16Zhf3Knt6JOK8zgRaC50XlmNB3kfNnaHGTrvH9vUesgbOi0i8CsSK6DJ67m2phoKky7aUf8FRYGXMB/G1sVvOnuRbyuSvMece5XfOhx+lbymo78lP5Vg+vxRT9jPjXtNm0Nb8RPpZm06UBtLBz7AJZDNjP6UYRRBCW4hk7OsRX5KpGqf+uoihQZ0QuSys90WtPaf26OzoBv3ltWKnbiFTvYCdZ7M1Y/1bZ7UxpfoeA9Dln5Pslw== brucehjohnson@comcast.net

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
