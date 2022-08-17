
local logging = {}

function logging.log_forwarded(arg)
  if arg.mode == "dnstap" then
    fstl = newFrameStreamTcpLogger(arg.ip .. ":" .. arg.port)
    addAction(TagRule('policy', ''), DnstapLogAction(arg.streamId, fstl))
    addResponseAction(AllRule(), DnstapLogResponseAction(arg.streamId, fstl))
    addCacheHitResponseAction(AllRule(), DnstapLogResponseAction(arg.streamId, fstl))
  end

  if arg.mode == "protobuf" then
    rl = newRemoteLogger(arg.ip .. ":" .. arg.port, 1, 100, 1)
    addAction(AllRule(), RemoteLogAction(rl, nil, {serverID=arg.streamId}))
    addResponseAction(AllRule(), RemoteLogResponseAction(rl, nil, true, {serverID=arg.streamId}))
    addCacheHitResponseAction(AllRule(), RemoteLogResponseAction(rl, nil, true, {serverID=arg.streamId}))
  end
end

function logging.log_blocked(arg)
  if arg.mode == "dnstap" then
    fstl = newFrameStreamTcpLogger(arg.ip .. ":" .. arg.port)
    addAction(TagRule('policy', 'blocked'), DnstapLogAction(arg.streamId, fstl))
  end

  if arg.mode == "protobuf" then
    rl = newRemoteLogger(arg.ip .. ":" .. arg.port, 1, 100, 1)
    addAction(TagRule('policy', 'blocked'), RemoteLogAction(rl, nil, {serverID=arg.streamId}))
  end
end

return logging
