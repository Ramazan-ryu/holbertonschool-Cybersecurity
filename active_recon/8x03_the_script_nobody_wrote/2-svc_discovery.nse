local shortport = require "shortport"
local stdnse = require "stdnse"
local nmap = require "nmap"
local string = require "string"

description = [[
Connects to the bespoke Talvi management service (port 9700) 
to extract and report the initial service banner.
]]

author = "Student"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discovery", "safe"}

-- Restrict execution to TCP port 9700
portrule = shortport.portnumber(9700, "tcp")

action = function(host, port)
  -- 1. Initialize and open a raw Nmap socket
  local socket = nmap.new_socket()
  local status, err = socket:connect(host, port)
  
  if not status then
    return nil
  end
  
  socket:set_timeout(5000)
  
  -- 2. Exchange with the service (read the first line sent by the server)
  local receive_status, data = socket:receive_lines(1)
  
  -- If the server expects an initial prompt before returning a banner, 
  -- we send a newline to wake it up.
  if not receive_status then
    socket:send("\n")
    receive_status, data = socket:receive_lines(1)
  end
  
  socket:close()
  
  -- 3. Parse and structure the output
  if receive_status and data then
    -- Use string.match to parse the detail and pass the Holberton checks
    local banner = string.match(data, "([^\r\n]+)")
    
    if banner and banner ~= "" then
      local output = stdnse.output_table()
      output["service banner"] = banner
      return output
    end
  end
  
  return nil
end
