#! /bin/bash

# $1 - remote peer 

# Generating public/private rsa key pair.
# Enter file in which to save the key (/home/a/.ssh/id_rsa): 
# Created directory '/home/a/.ssh'.
# Enter passphrase (empty for no passphrase): 
# Enter same passphrase again: 
# Your identification has been saved in /home/a/.ssh/id_rsa.
# Your public key has been saved in /home/a/.ssh/id_rsa.pub.
# The key fingerprint is:
# 3e:4f:05:79:3a:9f:96:7c:3b:ad:e9:58:37:bc:37:e4 a@A 

if [ ! -f ~/.ssh/id_rsa.pub ] 
then 
	ssh-keygen -t rsa
fi

# Now use ssh to create a directory ~/.ssh as user b on B. (The directory may already exist, which is fine):
ssh root@$1 mkdir -p .ssh

# Finally append a's new public key to b@B:.ssh/authorized_keys and enter b's password one last time:
cat ~/.ssh/id_rsa.pub | ssh root@$1 'cat >> .ssh/authorized_keys'

