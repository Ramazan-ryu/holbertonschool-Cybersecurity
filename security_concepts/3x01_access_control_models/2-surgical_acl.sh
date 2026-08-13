#!/bin/bash
sudo setfacl -m u:auditor_hipaa:r "$1" && getfacl "$1" | grep auditor_hipaa
