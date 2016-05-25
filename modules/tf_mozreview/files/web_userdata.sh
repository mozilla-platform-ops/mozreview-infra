#!/usr/bin/env bash
# Caveat: any variable inside curly braces will be interpolated by terraform!
#
# Install AWS CLI and useful tools 
# Create script and cron job to auto-update SSH pub keys

# bootstrap to make installing EPEL repo easy
function epel_bootstrap() {
    cat <<EOM > /etc/yum.repos.d/epel-bootstrap.repo
[epel]
name=Bootstrap EPEL
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-\$releasever&arch=\$basearch
failovermethod=priority
enabled=0
gpgcheck=0
EOM
    yum --enablerepo=epel -y install epel-release
    rm -f /etc/yum.repos.d/epel-bootstrap.repo
}

## Test for OS, install dependencies, and determine SSH_USER
if [ -f /etc/centos-release ]; then
    SSH_USER="centos"
    epel_bootstrap
    yum update -y
    yum install -y python-pip jq curl
elif [ -f /etc/redhat-release ]; then
    SSH_USER="ec2-user"
    epel_bootstrap
    yum update -y
    yum install -y python-pip jq curl
elif [ -f /etc/debian_version ]; then
    SSH_USER="ubuntu"
    apt-get update -y
    apt-get install -y python-pip jq curl
fi

## Install awscli and aws-ec2-assign-elastic-ip
pip install --upgrade awscli aws-ec2-assign-elastic-ip

mkdir /home/$SSH_USER/bin

# Create SSH pub keys update script
SSH_SCRIPT="/home/$SSH_USER/bin/update_ssh_keys.sh"

# ---[ start of script creation ]---
cat <<EOF > $SSH_SCRIPT
#!/usr/bin/env bash
BUCKET="moz-mozreview-keys"
MARKER="# KEYS_BELOW_WILL_BE_UPDATED_BY_TERRAFORM"

umask 0077
cd ~/.ssh

## Fetch keys
if [ -d pub_key_files ]; then
    rm -rf pub_key_files
else
    mkdir pub_key_files
fi
for key in \$(aws s3api list-objects --bucket \$BUCKET | jq -r '.Contents[].Key')
do
    aws s3 cp s3://\$BUCKET/\$key pub_key_files/ > /dev/null
done

## Set marker
if ! grep -Fxq "\$MARKER" authorized_keys;
then
  echo "\$MARKER" >> authorized_keys
fi

## Truncate to marker, append new keys, using temp file
sed "/^\$MARKER/q" authorized_keys > authorized_keys.new
for f in pub_key_files/*
do
    (cat "\$f"; echo) >> authorized_keys.new
done
sed -i '/^$/d' authorized_keys.new

mv authorized_keys.new authorized_keys
EOF
# ---[ end of script creation ]---

## Set perms
chmod 755 $SSH_SCRIPT

## Run script
su $SSH_USER -c $SSH_SCRIPT

## Add cronjob
# centos crontab doesn't allow STDIN input
if [ ! -f /etc/cron.d/update-ssh-keys ]; then
    echo "*/10 * * * * $SSH_USER $SSH_SCRIPT" > /etc/cron.d/update-ssh-keys
    chmod 644 /etc/cron.d/update-ssh-keys
fi

exit
