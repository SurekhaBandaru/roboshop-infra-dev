#!/bin/bash

dnf install ansible -y 
ansible-pull -U https://github.com/SurekhaBandaru/ansible-roboshop-roles-tf.git -e component=$1 -e env=$2 main.yaml