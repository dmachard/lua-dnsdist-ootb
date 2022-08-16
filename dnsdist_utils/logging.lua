
local logging = {}

function logging.dnstap(arg)
  fstl = newFrameStreamTcpLogger(arg.ip .. ":" .. arg.port)
  addAction(AllRule(), DnstapLogAction(arg.streamId, fstl))
  addResponseAction(AllRule(), DnstapLogResponseAction(arg.streamId, fstl))
  addCacheHitResponseAction(AllRule(), DnstapLogResponseAction(arg.streamId, fstl))
end

function logging.protobuf(arg)
  rl = newRemoteLogger(arg.ip .. ":" .. arg.port, 1, 100, 1)
  addAction(AllRule(), RemoteLogAction(rl, nil, {serverID=arg.streamId}))
  addResponseAction(AllRule(), RemoteLogResponseAction(rl, nil, true, {serverID=arg.streamId}))
  addCacheHitResponseAction(AllRule(), RemoteLogResponseAction(rl, nil, true, {serverID=arg.streamId}))
end


function logging.file(arg)
  addAction(AllRule(), LogAction(arg.filename, false, true, false, false, true))
  addResponseAction(AllRule(), LogResponseAction(arg.filename, true, false, false, true))
  addCacheHitResponseAction(AllRule(), LogResponseAction(arg.filename, true, false, false, true))
end

return logging
