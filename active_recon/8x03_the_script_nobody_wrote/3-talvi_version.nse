local shortport = require "shortport"
local nmap = require "nmap"
local string = require "string"
local stdnse = require "stdnse"

description = [[
Detects the version of the bespoke Talvi Management Service on port 9700.
Sends a version request, parses the reply, and updates Nmap's version registry
since the standard -sV probe fails to identify it.
]]

author = "Student"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
-- Adding "version" category ensures it runs during version detection phases
categories = {"version", "discovery", "safe"}

-- Bind to port 9700
portrule = shortport.portnumber(9700, "tcp")

action = function(host, port)
  local socket = nmap.new_socket()
  local status, err = socket:connect(host, port)
  
  if not status then
    return nil
  end
  
  socket:set_timeout(5000)
  
  -- 1. Consume the initial "TALVI-MGMT ready" banner
  socket:receive_lines(1)
  
  -- 2. Speak the protocol: ask for the version
  socket:send("VERSION\n")
  local receive_status, data = socket:receive_lines(1)
  
  socket:close()
  
  if receive_status and data then
    -- 3. Parse the version string using regex (e.g., matching "2.1.7")
    local version = string.match(data, "([%d]+%.[%d]+%.[%d]+)")
    
    -- Fallback in case it's formatted slightly differently (e.g., "v2.1")
    if not version then
      version = string.match(data, "([%d%.]+)")
    end
    
    if version then
      -- 4. Update Nmap's internal registry so it shows "talvi-mgmt" in the PORT state list
      port.version.name = "talvi-mgmt"
      port.version.product = "Talvi Management Service"
      port.version.version = version
      nmap.set_port_version(host, port, "hardmatched")
      
      -- 5. Return the exact expected output format
      return string.format("Talvi Management Service %s", version)
    end
  end
  
  return nil
end
