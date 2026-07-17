#!/bin/bash

TARGET="files.carmichael.lab"

# 1. Annotate every share with real session access using smbmap.
# We map the host over a null session (-u "" -p "") and look for "READ" permissions.
# We then isolate the first column (the share name) and exclude default administrative shares.
# (Exclusions cover: IPC$, ADMIN$, C$, print$)
SHARE=$(smbmap -H "$TARGET" -u "" -p "" 2>/dev/null | awk '/READ/ {print $1}' | grep -Ev '^(print\$|IPC\$|ADMIN\$|C\$)$' | head -n 2| tail -n 1)

# 2. Fallback: If smbmap fails or requires different syntax, try without explicit null creds.
if [ -z "$SHARE" ]; then
	SHARE=$(smbmap -H "$TARGET" 2>/dev/null | awk '/READ/ {print $1}' | grep -Ev '^(print\$|IPC\$|ADMIN\$|C\$)$' | head -n 2| tail -n 1)
fi

# 3. Fallback: Use netexec / crackmapexec if smbmap is uncooperative.
# We grep for READ access, dynamically find the share name column before the permission, and filter.
if [ -z "$SHARE" ]; then
	SHARE=$(netexec smb "$TARGET" -u "" -p "" --shares 2>/dev/null | awk '/READ/ {for(i=1;i<=NF;i++) if($i~/READ/) print $(i-1)}' | grep -Ev '^(print\$|IPC\$|ADMIN\$|C\$)$' | head -n 2| tail -n 1)
fi

# Print the final share name (exactly one line).
echo "$SHARE"
