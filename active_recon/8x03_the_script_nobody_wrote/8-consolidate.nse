local nmap = require "nmap"
local stdnse = require "stdnse"
local string = require "string"

description = [[
A post-scan script that reads the Nmap registry to consolidate findings 
from the Talvi custom suite. It surfaces a high-impact finding only 
when the version, vulnerability, and valid credentials are all present.
]]

author = "Student"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"safe"}

-- 1. The Postrule
-- This rule ensures the script only triggers at the very end of the scan
-- and only if all three required pieces of registry data exist.
postrule = function()
  if nmap.registry.talvi and 
     nmap.registry.talvi.version and 
     nmap.registry.talvi.vuln_confirmed and 
     nmap.registry.talvi.accounts and
     #nmap.registry.talvi.accounts > 0 then
    return true
  end
  return false
end

action = function()
  -- 2. Extract the data left behind by the suite
  local talvi = nmap.registry.talvi
  local version = talvi.version
  local username = talvi.accounts[1].username
  
  -- 3. Construct the consolidated finding string
  local finding = string.format(
    "Talvi-MGMT %s on 9700: confirmed command interface + valid %s creds = full management access path", 
    version, 
    username
  )
  
  -- 4. Return using structured output
  local output = stdnse.output_table()
  table.insert(output, finding)
  
  return output
end
