#!/usr/bin/env python3

import json
import subprocess
import os

# Change directory to the Terraform folder
os.chdir('../terraform')

# Get the Terraform output in JSON format
tf_output = subprocess.check_output(["terraform", "output", "-json"]).decode('utf-8')
tf_output = json.loads(tf_output)

jumpbox_public_ip = tf_output['jumpbox_public_ip']['value']
server_public_ip = tf_output['server_public_ip']['value']

# Build the dynamic inventory
inventory = {
    'jumpbox': {
        'hosts': [jumpbox_public_ip]
    },
    'server': {
        'hosts': [server_public_ip]
    },
    'worker': {
        'hosts': ['10.0.2.20', '10.0.2.21']
    },
    '_meta': {
        'hostvars': {
            jumpbox_public_ip: {
                'ansible_host': jumpbox_public_ip
            },
            server_public_ip: {
                'ansible_host': server_public_ip
            },
            # You might add metadata here for worker hosts if needed
            '10.0.2.20': {
                'worker_node_subnet': '10.200.0.0/24'
            },
            '10.0.2.21': {
                'worker_node_subnet': '10.200.1.0/24'
            }
        }
    }
}

# Output the inventory in JSON format for Ansible to consume
print(json.dumps(inventory, indent=2))
