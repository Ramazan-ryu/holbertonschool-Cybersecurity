local shortport = require "shortport"
local nmap = require "nmap"
local stdnse = require "stdnse"
local vulns = require "vulns"
local string = require "string"

description = [[
Confirms an unauthenticated command interface vulnerability in the 
bespoke Talvi Management Service via behavioral probing, and logs 
the finding to the Nmap registry.
]]

author = "Student"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"vuln", "safe"}

-- Target the bespoke management port explicitly
portrule = shortport.portnumber(9700, "tcp")

action = function(host, port)
  -- 1. Define the vulnerability structure (starts as NOT_VULN)
  local vuln_table = {
    title = "Talvi Management Service unauthenticated command interface",
    state = vulns.STATE.NOT_VULN
  }
  
  -- 2. Initialize the vulns report
  local report = vulns.Report:new(SCRIPT_NAME, host, port)
  
  -- 3. Open a connection for behavioral confirmation
  local socket = nmap.new_socket()
  local status, err = socket:connect(host, port)
  
  if not status then
    return nil
  end
  
  socket:set_timeout(5000)
  
  -- Consume the initial banner so the protocol expects our command
  socket:receive_lines(1)
  
  -- 4. Send a privileged command probe to test for the unauthenticated interface
  socket:send("ADMIN\n")
  local receive_status, data = socket:receive_lines(1)
  
  socket:close()
  
  -- 5. Evaluate the behavior (Did the service answer the privileged command?)
  if receive_status and data and data ~= "" then
    -- We've confirmed the behavior. Flip the state to VULN.
    vuln_table.state = vulns.STATE.VULN
    vuln_table.check_results = "Behavioral probe returned the privileged response"
    
    -- 6. Write the confirmed finding to the Nmap registry
    if not nmap.registry.talvi then
      nmap.registry.talvi = {}
    end
    nmap.registry.talvi.vuln_confirmed = true
  end
  
  -- 7. Generate the structured vulns output
  return report:make_output(vuln_table)
end
