
local admin = {}

function admin.console(arg)
  setKey(arg.key)
  controlSocket(arg.ip4 .. ":" .. arg.port)
  addConsoleACL(arg.acl)
end

function admin.web(arg)
  webserver(arg.ip4 .. ":" .. arg.port)
  setWebserverConfig({
    apiKey = arg.key,
    password = arg.pwd,
    acl = arg.acl,
  })
end

return admin

