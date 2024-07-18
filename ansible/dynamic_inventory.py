#!/usr/bin/env python3

import json
import subprocess
import os

# Change directory to the terraform folder
os.chdir('../terraform')

# Get the Terraform output in JSON format
tf_output = subprocess.check_output(["terraform", "output", "-json"])
tf_output = json.loads(tf_output)

# Build the dynamic inventory
inventory = {
    'jumpbox': {
        'hosts': [tf_output['jumpbox_public_ip']['value']]
    },
    'server': {
        'hosts': ['10.0.2.10']
    },
    'worker': {
        'hosts': ['10.0.2.20', '10.0.2.21']
    },
    '_meta': {
        'hostvars': {
            tf_output['jumpbox_public_ip']['value']: {
                'ansible_host': tf_output['jumpbox_public_ip']['value']
            }
        }
    }
}

# Output the inventory in JSON format for Ansible to consume
print(json.dumps(inventory, indent=2))
