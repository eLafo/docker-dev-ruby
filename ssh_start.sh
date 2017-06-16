#!/bin/bash
printenv > ~/.ssh/environment
ruby /home/dev/ssh_key_adder.rb
sudo /usr/sbin/sshd -D
