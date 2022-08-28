local admin = {}

function admin.listen_console(arg)
  setKey(arg.key)
  controlSocket(arg.ip4 .. ":" .. arg.port)
  addConsoleACL(arg.acl)
end

function admin.listen_web(arg)
  webserver(arg.ip4 .. ":" .. arg.port)
  setWebserverConfig({
    apiKey = arg.key,
    password = arg.pwd,
    acl = arg.acl,
  })
end

function admin.secpoll(arg)
  setSecurityPollInterval(arg.interval)
  setSecurityPollSuffix(arg.suffix)
end

return admin
