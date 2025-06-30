#!/bin/bash

dnf install ansible -y 
ansible-pull -U https://github.com/SurekhaBandaru/ansible-roboshop-roles.git -e component=$1 main.yaml