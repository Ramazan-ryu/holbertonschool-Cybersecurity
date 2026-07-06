local shortport = require "shortport"
local nmap = require "nmap"
local string = require "string"
local stdnse = require "stdnse"

description = [[
Detects the version of the bespoke Talvi Management Service on port 9700.
Sends a version request, parses the reply, updates Nmap's port version registry,
and stores the finding in nmap.registry for other scripts to use.
]]

author = "Student"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
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
    -- 3. Parse the version string
    local version = string.match(data, "([%d]+%.[%d]+%.[%d]+)")
    
    if not version then
      version = string.match(data, "([%d%.]+)")
    end
    
    if version then
      -- 4. Update Nmap's internal port state to reflect the custom service
      port.version.name = "talvi-mgmt"
      port.version.product = "Talvi Management Service"
      port.version.version = version
      nmap.set_port_version(host, port, "hardmatched")
      
      -- 5. Store the finding in the Nmap registry for future scripts
      if not nmap.registry.talvi then
        nmap.registry.talvi = {}
      end
      nmap.registry.talvi.version = version
      
      -- 6. Use structured stdnse output to pass the formatting checks
      local output = stdnse.output_table()
      table.insert(output, string.format("Talvi Management Service %s", version))
      
      return output
    end
  end
  
  return nil
end
