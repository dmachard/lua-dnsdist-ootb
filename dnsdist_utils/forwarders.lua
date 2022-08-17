
local fwds = {}

function fwds.pool(arg)
    -- pool name
    pool = "forward"

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
    setPoolServerPolicy(roundrobin, pool)

    -- enable cache for the pool
    getPool(pool):setCache(pc)

    -- matches all incoming traffic and send-it to the pool of resolvers
    addAction(TagRule('policy', ''),PoolAction(pool))
end

return fwds
