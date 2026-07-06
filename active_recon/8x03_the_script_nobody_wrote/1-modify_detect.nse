local http = require "http"
local shortport = require "shortport"
local string = require "string"
local stdnse = require "stdnse"

description = [[
Modifies a standard HTTP detection script to surface the Talvi management console build tag.
It requests the root directory of the web server and parses the response body and headers 
for the specific build tag pattern.
]]

author = "Student"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discovery", "safe"}

portrule = shortport.http

action = function(host, port)
  local response = http.get(host, port, "/")
  
  if not response or not response.status then
    return nil
  end

  local build_tag = nil

  if response.body then
    build_tag = string.match(response.body, "(TALVI%-MGMT%-[%w%.]+)")
  end
  
  if not build_tag and response.header then
    for key, value in pairs(response.header) do
      if type(value) == "string" then
        build_tag = string.match(value, "(TALVI%-MGMT%-[%w%.]+)")
        if build_tag then break end
      end
    end
  end

  if build_tag then
    return string.format("management console build tag: %s", build_tag)
  end

  return nil
end
