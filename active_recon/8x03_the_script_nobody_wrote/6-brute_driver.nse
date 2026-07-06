local shortport = require "shortport"
local nmap = require "nmap"
local stdnse = require "stdnse"
local brute = require "brute"
local creds = require "creds"
local unpwdb = require "unpwdb"

description = [[
Audits credentials for the bespoke Talvi management service on port 9700.
Implements the brute library Driver contract to safely discover valid accounts
and records findings in both the creds library and the Nmap registry.
]]

author = "Student"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"brute", "intrusive"}

-- Target the bespoke management port explicitly
portrule = shortport.portnumber(9700, "tcp")

-- 1. Implement the Driver Class
Driver = {
  new = function(self, host, port)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.host = host
    o.port = port
    return o
  end,
  
  -- 2. The connect method
  connect = function(self)
    self.socket = nmap.new_socket()
    self.socket:set_timeout(5000)
    
    local status, err = self.socket:connect(self.host, self.port)
    if not status then
      return false, brute.Error:new("Connection failed: " .. err)
    end
    
    -- Consume the initial banner so the protocol is ready for input
    self.socket:receive_lines(1)
    return true
  end,
  
  -- 3. The login method
  login = function(self, username, password)
    -- Send authentication payload per the custom line-oriented protocol
    self.socket:send("AUTH " .. username .. " " .. password .. "\n")
    
    local status, data = self.socket:receive_lines(1)
    
    if status and data and data:match("OK") then
      -- Write the discovered credential to the Nmap registry for other scripts
      if not nmap.registry.talvi then
        nmap.registry.talvi = {}
      end
      if not nmap.registry.talvi.accounts then
        nmap.registry.talvi.accounts = {}
      end
      table.insert(nmap.registry.talvi.accounts, {username = username, password = password})

      -- Record hits through creds.Account on success
      return true, creds.Account:new(username, password, creds.State.VALID)
    end
    
    -- Return failure with a brute.Error
    return false, brute.Error:new("Incorrect password")
  end,
  
  -- 4. The disconnect method
  disconnect = function(self)
    self.socket:close()
    return true
  end
}

action = function(host, port)
  -- Initialize the built-in brute engine with our custom Driver
  local engine = brute.Engine:new(Driver, host, port)
  
  -- Assign the script name for output formatting
  engine.options.script_name = SCRIPT_NAME
  
  -- Start the attack loop
  local status, result = engine:start()
  
  return result
end
