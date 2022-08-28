local rules = {}

function rules.pool(arg)
    -- pool name
    if string.len(arg.name) > 0 then
      pool = "#" .. arg.id .. "_" .. arg.name
    else
      pool = "#" .. arg.id
    end

    -- dns caching
    pc = newPacketCache(10000, {})

    -- public dns resolvers definitions
      for k,v in pairs(arg.dnsServers) do
        dns_port = 53
        if v.port ~= nil then
          dns_port = v.port
        end
        newServer({
          address = v.ip .. ":" .. dns_port,
          pool = pool,
        })
      end

    -- doh public dns resolvers
      for k,v in pairs(arg.dohServers) do
        doh_port = 443
        if v.port ~= nil then
          doh_port = v.port
        end
        newServer({
          address = v.ip .. ":" .. doh_port,
          tls = "openssl",
          dohPath = "/dns-query",
          subjectName = v.name,
          validateCertificates = false,
          pool = pool,
        })
      end

    -- set the load balacing policy to use
    if arg.loadBalancing == "roundrobin" then
      lbmethod = roundrobin
    end
    if arg.loadBalancing == "observed" then
      lbmethod = leastOutstanding
    end
    setPoolServerPolicy(lbmethod, pool)

    -- enable cache for the pool
    getPool(pool):setCache(pc)
end

function rules.set_policy(arg)

  tagrule = "rule" .. arg.id .. "_" .. arg.policy
  if arg.policy == "drop" then
    addAction(TagRule('policy', tagrule), SpoofAction({"127.0.0.1", "::1"}))
  end

  if arg.policy == "nxdomain" then
    addAction(TagRule('policy', tagrule), RCodeAction(DNSRCode.NXDOMAIN))
  end

  if arg.policy == "passthru" then
    if string.len(arg.name) > 0 then
      pool = "#" .. arg.id .. "_" .. arg.name
    else
      pool = "#" .. arg.id
    end
    addAction(TagRule('policy', tagrule),PoolAction(pool))
  end
end

function rules.match_qname_cdb(arg)
  kvs = newCDBKVStore(arg.filename, arg.reload)
  tag_value =  "rule" .. arg.id .. "_" .. arg.policy
  addAction(KeyValueStoreLookupRule(kvs, KeyValueLookupKeyQName(false)), SetTagAction('policy', tag_value))
end

function rules.match_qname_cdb(arg)
  kvs = newCDBKVStore(arg.filename, arg.reload)
  tag_value =  "rule" .. arg.id .. "_" .. arg.policy
  addAction(KeyValueStoreLookupRule(kvs, KeyValueLookupKeyQName(false)), SetTagAction('policy', tag_value))
end

function rules.match_zone_set(arg)
  smn = newSuffixMatchNode()
  for k,v in pairs(arg.set) do
    smn:add(v)
  end
  tag_value = "rule" .. arg.id .. "_" .. arg.policy
  addAction(SuffixMatchNodeRule(smn, true),  SetTagAction("policy", tag_value))
end

function rules.set_remote_logging(arg)
  tagrule = "rule" .. arg.id .. "_" .. arg.policy

  if arg.policy == "passthru" then
    if arg.mode == "dnstap" then
      fstl = newFrameStreamTcpLogger(arg.ip .. ":" .. arg.port)
      addAction(TagRule('policy', tagrule), DnstapLogAction(arg.streamId, fstl))
      addResponseAction(TagRule('policy', tagrule), DnstapLogResponseAction(arg.streamId, fstl))
      addCacheHitResponseAction(TagRule('policy', tagrule), DnstapLogResponseAction(arg.streamId, fstl))
    end

    if arg.mode == "protobuf" then
      rl = newRemoteLogger(arg.ip .. ":" .. arg.port, 1, 100, 1)
      addAction(TagRule('policy', tagrule), RemoteLogAction(rl, nil, {serverID=arg.streamId}))
      addResponseAction(TagRule('policy', tagrule), RemoteLogResponseAction(rl, nil, true, {serverID=arg.streamId}))
      addCacheHitResponseAction(TagRule('policy', tagrule), RemoteLogResponseAction(rl, nil, true, {serverID=arg.streamId}))
    end
  end

  if arg.policy == "drop" or arg.policy == "nxdomain" then
    if arg.mode == "dnstap" then
      fstl = newFrameStreamTcpLogger(arg.ip .. ":" .. arg.port)
      addAction(TagRule('policy', tagrule), DnstapLogAction(arg.streamId, fstl))
    end

    if arg.mode == "protobuf" then
      rl = newRemoteLogger(arg.ip .. ":" .. arg.port, 1, 100, 1)
      addAction(TagRule('policy', tagrule), RemoteLogAction(rl, nil, {serverID=arg.streamId}))
    end
  end
end

return rules