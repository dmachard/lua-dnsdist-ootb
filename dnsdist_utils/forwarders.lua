
local fwds = {}

function fwds.pool(arg)
    -- pool name
    pool = "forward"

    -- dns caching
    pc = newPacketCache(10000, {})

    -- public dns resolvers definitions
      for k,v in pairs(arg.dnsServers) do
        newServer({
          address = v.addr,
          pool = pool,
        })
      end

    -- doh public dns resolvers
      for k,v in pairs(arg.dohServers) do
        newServer({
          address = v.addr,
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
    addAction(AllRule(),PoolAction(pool))
end

return fwds
