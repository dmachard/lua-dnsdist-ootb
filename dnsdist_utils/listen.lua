
local listen = {}

-- start basic dns server on tcp/udp
function listen.dns(arg)
  setLocal(arg.ip4 .. ":" .. arg.port)
  addLocal(arg.ip6 .. ":" .. arg.port)
end

-- start doh server
function listen.doh(arg)
  addDOHLocal(arg.ip4 .. ":" .. arg.port, arg.certFile, arg.keyFile)
  addDOHLocal(arg.ip6 .. ":" .. arg.port, arg.certFile, arg.keyFile)
end

-- start dot server
function listen.dot(arg)
  addTLSLocal(arg.ip4 .. ":" .. arg.port, arg.certFile, arg.keyFile)
  addTLSLocal(arg.ip6 .. ":" .. arg.port, arg.certFile, arg.keyFile)
end

return listen
