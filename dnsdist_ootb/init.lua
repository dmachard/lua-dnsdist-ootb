local cur_fold = (...):gsub('%.init$', '')

local lib_admin = require(cur_fold .. '.admin')
local lib_srvs = require(cur_fold .. '.services')
local lib_misc = require(cur_fold .. '.misc')
local lib_rules = require(cur_fold .. '.rules')

local yaml = require(cur_fold .. '.tinyyaml')

local Services = {}
Services.new = function()
    local self = {}

    self.dnsIP4="0.0.0.0"
    self.dnsIP6="[::]"
    self.dnsPort=53

    self.dohIP4="0.0.0.0"
    self.dohIP6="[::]"
    self.dohPort=443
    self.dohCert="/etc/dnsdist/cert.pem"
    self.dohKey="/etc/dnsdist/key.pem"

    self.dotIP4="0.0.0.0"
    self.dotIP6="[::]"
    self.dotPort=853
    self.dotCert="/etc/dnsdist/cert.pem"
    self.dotKey="/etc/dnsdist/key.pem"

    return self
end

local Admin = {}
Admin.new = function()
        local self = {}

        self.adminIP4="0.0.0.0"
        self.adminPort=5199
        self.adminKey="pVC5gO/HECwOfgFzQDjAy6v5mWYmpwcj2h546GjqDgg="
        self.adminACL="127.0.0.1/8"

        self.webIP4="0.0.0.0"
        self.webPort=8083
        self.webACL="0.0.0.0/0"
        self.webApiKey="<secret>"
        self.webPwd="<secret>"

        self.secpollInterval=3600
        self.secpollSuffix="secpoll.powerdns.com" --setting to an empty string disables secpoll.

        return self
end

local Rule = {}
Rule.new = function()
        local self = {}

        self.logIp="127.0.0.1"
        self.logPort=6000
        self.logProto="protobuf"

        self.dnsServers={
                                -- {ip="8.8.8.8", port="53"},
                                -- {ip="9.9.9.9", port="53"},
                                -- {ip="1.1.1.1", port="53"},
                            }
        self.dohServers={
                                -- {ip="8.8.8.8", port="443", name="dns.google"},
                                -- {ip="1.1.1.1", port="443", name="cloudflare-dns.com"},
                            }

        self.qnameCdbReload=3600

        self.rulePolicy="passthru"
        self.ruleName=""

        self.zoneSet = { "." }

        return self
end

local ootb = {}


function ootb.load_yaml(arg)
  infolog("loading config yaml file...")
  local f = assert(io.open(arg.file, "rb"))
  local content = f:read("*all")
  f:close()

  -- load content as yaml
  config = yaml.parse(content)

  -- finally load config
  ootb.run_server{opts=config}

end

function ootb.run_server(arg)
  opts = arg.opts

  services = opts.services
  admin = opts.admin
  rules = opts.rules

  -- init default values
  adm = Admin.new()
  srv = Services.new()
  
  -- disable security polling by default
  lib_admin.secpoll{interval=adm.secpollInterval, suffix=""}

  -- start default dns service
  if services ~= nil then
    lib_srvs.listen_dns{ip4=srv.dnsIP4, ip6=srv.dnsIP6, port=srv.dnsPort}
  end

  if services then
    if services.dns then
      if services.dns.ip4 then
        srv.dnsIP4 = services.dns.ip4
      end
      if services.dns.ip6 then
        srv.dnsIP6 = services.dns.ip6
      end
      if services.dns.port then
        srv.dnsPort = services.dns.port
      end

      -- load dnsdist config
      lib_srvs.listen_dns{ip4=srv.dnsIP4, ip6=srv.dnsIP6, port=srv.dnsPort}
    end
    if services.doh then
      if services.doh.ip4 then
        srv.dohIP4 = services.doh.ip4
      end
      if services.doh.ip6 then
        srv.dohIP6 = services.doh.ip6
      end
      if services.doh.cert then
        srv.dohCert = services.doh.cert
      end
      if services.doh.key then
        srv.dohKey = services.doh.key
      end

      -- load dnsdist config
      lib_srvs.listen_doh{ip4=srv.dohIP4, ip6=srv.dohIP6, port=srv.dohPort, certFile=srv.dohCert, keyFile=srv.dohKey}
    end
    if services.dot then
      if services.dot.ip4 then
        srv.dotIP4 = services.dot.ip4
      end
      if services.dot.ip6 then
        srv.dotIP6 = services.dot.ip6
      end
      if services.dot.cert then
        srv.dotCert = services.dot.cert
      end
      if services.dot.key then
        srv.dotKey = services.dot.key
      end

      -- load dnsdist config
      lib_srvs.listen_dot{ip4=srv.dotIP4, ip6=srv.dotIP6, port=srv.dotPort, certFile=srv.dotCert, keyFile=srv.dotKey}
    end
  end

  if admin then
    if admin.console then
      if admin.console.ip4 then
        adm.adminIP4 = admin.console.ip4
      end
      if admin.console.port then
        adm.adminPort = admin.console.port
      end
      if admin.console.acl then
        adm.adminACL = admin.console.acl
      end
      if admin.console.key then
        adm.adminKey = admin.console.key
      end

      -- load dnsdist config
      lib_admin.listen_console{key=adm.adminKey, ip4=adm.adminIP4, port=adm.adminPort, acl=adm.adminACL}
    end

    if admin.web then
      if admin.web.ip4 then
        adm.webIP4 = admin.web.ip4
      end
      if admin.web.port then
        adm.webPort = admin.web.port
      end
      if admin.web.acl then
        adm.webACL = admin.web.acl
      end
      if admin.web.apikey then
        adm.webApiKey = admin.web.apikey
      end
      if admin.web.password then
        adm.webPwd = admin.web.password
      end

      -- load dnsdist config
      lib_admin.listen_web{key=adm.webApiKey, pwd=adm.webPwd, ip4=adm.webIP4, port=adm.webPort, acl=adm.webACL}
    end

    if admin.secpoll then
      if admin.secpoll.interval then
        adm.secpollInterval = admin.secpoll.interval
      end
      if admin.secpoll.suffix then
        adm.secpollSuffix = admin.secpoll.suffix
      end
      lib_admin.secpoll{interval=adm.secpollInterval, suffix=adm.secpollSuffix}
    end
  end

  if rules then
    for i,cur_rule in pairs(rules) do
      local rule = Rule.new()

      if cur_rule.name then
        rule.ruleName = cur_rule.name
      end

      if cur_rule.policy then
        rule.rulePolicy = cur_rule.policy
      end

      if cur_rule.zoneset then
        rule.zoneSet = cur_rule.zoneset
        -- load dnsdist config
        lib_rules.match_zone_set{id=i, name=rule.ruleName, policy=rule.rulePolicy, set=rule.zoneSet}
      end

      if cur_rule.qnamecdb then
        if cur_rule.qnamecdb.reload then
          rule.qnamecdbReload = cur_rule.qnamecdb.reload
        end
        -- load dnsdist config
        lib_rules.match_qname_cdb{id=i, name=rule.cur_ruleName, policy=rule.rulePolicy,
                                  filename=cur_rule.qnamecdb.filename, reload=rule.qnameCdbReload}
      end

      if cur_rule.zoneset == nil and cur_rule.qnamecdb==nil then
        -- load dnsdist config
        lib_rules.match_zone_set{id=i, name=rule.ruleName, policy=rule.rulePolicy, set=rule.zoneSet}
      end

      if cur_rule.logging then
        if cur_rule.logging.host then
          rule.logIp = lib_misc.resolv_host(cur_rule.logging.host)
        end
        if cur_rule.logging.ip then
          rule.logIp = cur_rule.logging.ip
        end
        if cur_rule.logging.port then
          rule.logPort = cur_rule.logging.port
        end
        if cur_rule.logging.protocol then
          rule.logProto = cur_rule.logging.protocol
        end

        streamId = lib_misc.get_hostname() .. "-" .. rule.ruleName .. "-" .. rule.rulePolicy

        if cur_rule.logging.streamid then
          streamId = cur_rule.logging.streamid
        end

        -- load dnsdist config
        lib_rules.set_remote_logging{id=i, name=rule.ruleName, policy=rule.rulePolicy,
                                     ip=rule.logIp, port=rule.logPort,
                                     streamId=streamId, mode=rule.logProto}
      end

      if cur_rule.upstreams then
        if cur_rule.upstreams.dns then
          rule.dnsServers = cur_rule.upstreams.dns
        end
        if cur_rule.upstreams.doh then
          rule.dohServers = cur_rule.upstreams.doh
        end
        -- load dnsdist config
        lib_rules.pool{id=i, name=rule.ruleName, dnsServers=rule.dnsServers, dohServers=rule.dohServers}
      end

      -- load dnsdist config
      lib_rules.set_policy{id=i, name=rule.ruleName, policy=rule.rulePolicy}
    end
  end

  -- refused all traffic by default
  addAction(AllRule(), RCodeAction(DNSRCode.REFUSED))
end

-- export functions
local _M = {
        runServer = ootb.run_server,
        loadConfig = ootb.load_yaml,
        getHostname = lib_misc.get_hostname,
        resolvHost = lib_misc.resolv_host,
}
return _M
