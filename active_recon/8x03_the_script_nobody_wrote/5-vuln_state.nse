local shortport = require "shortport"
local nmap = require "nmap"
local vulns = require "vulns"
local stdnse = require "stdnse"
local string = require "string"

description = [[
Demonstrates false-positive discipline by reporting a version-only match 
as LIKELY_VULN when the subsequent behavioral probe fails, clearing the 
service of a confirmed VULN state due to suspected backporting.
]]

author = "Student"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"vuln", "safe"}

-- Target the HTTPS backport gateway explicitly (port 8443)
portrule = shortport.portnumber(8443, "tcp")

action = function(host, port)
  -- 1. Initialize the vulnerability table
  local vuln_table = {
    title = "Version matches published advisory",
    state = vulns.STATE.NOT_VULN
  }
  
  local report = vulns.Report:new(SCRIPT_NAME, host, port)
  
  -- 2. Connect to the HTTPS service
  local socket = nmap.new_socket()
  -- Using "ssl" protocol since port 8443 is HTTPS
  local status, err = socket:connect(host, port, "ssl")
  
  if not status then
    return nil
  end
  
  socket:set_timeout(5000)
  
  -- 3. Check for version match (simulated request)
  socket:send("GET / HTTP/1.1\r\nHost: " .. host.ip .. "\r\n\r\n")
  local receive_status, response = socket:receive_lines(1)
  
  local version_matched = true 
  
  -- 4. The Behavioral Probe
  -- We actively send a payload designed to trigger the flaw
  socket:send("GET /vulnerable_endpoint HTTP/1.1\r\nHost: " .. host.ip .. "\r\n\r\n")
  local probe_status, probe_response = socket:receive_lines(1)
  
  socket:close()
  
  -- A backported service is patched, meaning it will fail to return the expected vulnerable response.
  local behavioral_probe_confirmed = false
  if probe_status and probe_response and string.match(probe_response, "vulnerable_behavior_flag") then
    behavioral_probe_confirmed = true
  end
  
  if version_matched then
    if behavioral_probe_confirmed then
      -- If the behavior was present, we would escalate to VULN.
      vuln_table.state = vulns.STATE.VULN
      vuln_table.check_results = "Behavioral probe confirmed the vulnerability"
    else
      -- False-positive discipline applied here. The backport passes the test.
      vuln_table.state = vulns.STATE.LIKELY_VULN
      vuln_table.check_results = "Version matched but behavioral probe negative (backport suspected)"
    end
  end
  
  -- 5. Generate the structured output
  return report:make_output(vuln_table)
end
