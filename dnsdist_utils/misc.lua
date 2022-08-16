
local miscs = {}

function miscs.get_hostname()
  local f = io.popen ("/bin/hostname")
  local hostname = f:read("*a") or "dnsdist"
  f:close()
  return string.gsub(hostname, "\n$", "")
end

function miscs.resolv_host(name)
  local f = assert(io.popen('getent hosts ' .. name .. ' | cut -d " " -f 1', 'r'))
  local hostname = f:read('*a') or "127.0.0.1"
  f:close()
  return string.gsub(hostname, "\n$", "")
end

return miscs
