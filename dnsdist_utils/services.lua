
local srvs = {}

function srvs.listen_dns(arg)
  setLocal(arg.ip4 .. ":" .. arg.port)
  addLocal(arg.ip6 .. ":" .. arg.port)
end

function srvs.listen_doh(arg)
  addDOHLocal(arg.ip4 .. ":" .. arg.port, arg.certFile, arg.keyFile)
  addDOHLocal(arg.ip6 .. ":" .. arg.port, arg.certFile, arg.keyFile)
end

function srvs.listen_dot(arg)
  addTLSLocal(arg.ip4 .. ":" .. arg.port, arg.certFile, arg.keyFile)
  addTLSLocal(arg.ip6 .. ":" .. arg.port, arg.certFile, arg.keyFile)
end

return srvs
