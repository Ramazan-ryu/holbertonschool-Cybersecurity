#!/bin/bash

# Grant read-only ACL access to user 'auditor' on the file/directory passed as argument
setfacl -m u:auditor:r "$1"
