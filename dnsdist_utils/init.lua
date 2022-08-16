
local cur_fold = (...):gsub('%.init$', '')

local lib_admin = require(cur_fold .. '.admin')
local lib_misc = require(cur_fold .. '.misc')
local lib_listen = require(cur_fold .. '.listen')
local lib_logging = require(cur_fold .. '.logging')
local lib_forwarders = require(cur_fold .. '.forwarders')
local lib_blocklist = require(cur_fold .. '.blocklist')

local utils = {
                 dnsIP4="0.0.0.0",
                 dnsIP6="[::]",
                 dnsPort="53",

                 dohIP4="0.0.0.0",
                 dohIP6="[::]",
                 dohPort="443",
                 dohCert="/etc/dnsdist/cert.pem",
                 dohKey="/etc/dnsdist/key.pem",

                 dotIP4="0.0.0.0",
                 dotIP6="[::]",
                 dotPort="853",
                 dotCert="/etc/dnsdist/cert.pem",
                 dotKey="/etc/dnsdist/key.pem",

                 dnstapIp="127.0.0.1",
                 dnstapPort="6000",

                 protobufIP="127.0.0.1",
                 protobufPort="6000",

                 logName="/tmp/dnsdist-traffic.log",

                 adminIP4="0.0.0.0",
                 adminPort="5199",
                 adminKey="pVC5gO/HECwOfgFzQDjAy6v5mWYmpwcj2h546GjqDgg=",
                 adminACL="127.0.0.1/8",

                 webIP4="0.0.0.0",
                 webPort="8083",
                 webACL="0.0.0.0/0",
                 webApiKey="<secret>",
                 webPwd="<secret>",

                 dnsServers={
                                {addr="8.8.8.8:53"},
                                {addr="9.9.9.9:53"},
                                {addr="1.1.1.1:53"},
                },
                dohServers={
                                {addr="8.8.8.8:443", name="dns.google"},
                                {addr="1.1.1.1:443", name="cloudflare-dns.com"},
                            },
                
                blocklistFile="/etc/dnsdist/blocklist.txt"
  }

function utils.run(arg)
    opts = arg.opts

    admin = arg.opts.admin
    listen = arg.opts.listen
    forwarders = arg.opts.forwarders
    logging = arg.opts.logging

    if listen then
        if listen.dns then
            if listen.dns.ip4 then
              utils.dnsIP4 = listen.dns.ip4
            end
            if listen.dns.ip6 then
              utils.dnsIP6 = listen.dns.ip6
            end
            if listen.dns.port then
              utils.dnsPort = listen.dns.port
            end
    
            -- load dnsdist config
            lib_listen.dns{ip4=utils.dnsIP4, ip6=utils.dnsIP6, port=utils.dnsPort}
        end
    
        if listen.doh then
           if listen.doh.ip4 then
              utils.dohIP4 = listen.doh.ip4
            end
            if listen.doh.ip6 then
              utils.dohIP6 = listen.doh.ip6
            end
            if listen.doh.cert then
              utils.dohCert = listen.doh.cert
            end
            if listen.doh.key then
              utils.dohKey = listen.doh.key
            end
    
            -- load dnsdist config
            lib_listen.doh{ip4=utils.dohIP4, ip6=utils.dohIP6, port=utils.dohPort, certFile=utils.dohCert, keyFile=utils.dohKey}
        end
    
        if listen.dot then
            if listen.dot.ip4 then
               utils.dotIP4 = listen.dot.ip4
             end
            if listen.dot.ip6 then
               utils.dotIP6 = listen.dot.ip6
            end
            if listen.dot.cert then
              utils.dotCert = listen.dot.cert
            end
            if listen.dot.key then
              utils.dotKey = listen.dot.key
            end
     
             -- load dnsdist config
             lib_listen.dot{ip4=utils.dotIP4, ip6=utils.dotIP6, port=utils.dotPort, certFile=utils.dotCert, keyFile=utils.dotKey}
        end
    end


    if admin then
        if admin.console then
          if admin.console.ip4 then
            utils.adminIP4 = admin.console.ip4
          end
          if admin.console.port then
            utils.adminPort = admin.console.port
          end
          if admin.console.acl then
            utils.adminACL = admin.console.acl
          end
          if admin.console.key then
            utils.adminKey = admin.console.key
          end
    
          -- load dnsdist config
          lib_admin.console{key=utils.adminKey, ip4=utils.adminIP4, port=utils.adminPort, acl=utils.adminACL}
        end
    
        if admin.web then
          if admin.web.ip4 then
            utils.webIP4 = admin.web.ip4
          end
          if admin.web.port then
            utils.webPort = admin.web.port
          end
          if admin.web.acl then
            utils.webACL = admin.web.acl
          end
          if admin.web.apikey then
            utils.webApiKey = admin.web.apikey
          end
          if admin.web.password then
            utils.webPwd = admin.web.password
          end
    
          -- load dnsdist config
          lib_admin.web{key=utils.webApiKey, pwd=utils.webPwd, ip4=utils.webIP4, port=utils.webPort, acl=utils.webACL}
        end
    end

    if logging then
        if logging.dnstap then
          if logging.dnstap.ip then
              utils.dnstapIp = logging.dnstap.ip
            end
            if logging.dnstap.port then
              utils.dnstapPort = logging.dnstap.port
            end
    
          streamId = lib_misc.get_hostname()
    
          -- load dnsdist config
          lib_logging.dnstap{ip=utils.dnstapIp, port=utils.dnstapPort, streamId=streamId}
        end
    
        if logging.protobuf then
          if logging.protobuf.ip then
            utils.protobufIp = logging.protobuf.ip
          end
          if logging.dnstap.port then
            utils.protobufPort = logging.protobuf.port
          end
    
          streamId = lib_misc.get_hostname()
    
          -- load dnsdist config
          lib_logging.protobuf{ip=utils.protobufIp, port=utils.protobufPort, streamId=streamId}
        end
    
        if logging.file then
          if logging.file.name then
            utils.logName = logging.file.name
          end
    
          -- load dnsdist config
          lib_logging.file{filename=utils.logName}
        end
    end

    if blocklist then
      if blocklist.file then
        utils.blocklistFile = blocklist.file
      end
  
      -- load dnsdist config
      lib_blocklist.load{file=utils.blocklistFile}
    end

    if forwarders then
        if forwarders.dns then
          utils.dnsServers = forwarders.dns
        end
        if forwarders.doh then
          utils.dohServers = forwarders.doh
        end
    
        -- load dnsdist config
        lib_forwarders.pool{dnsServers=utils.dnsServers, dohServers=utils.dohServers}
    end
end

-- export functions
local _M = {
        runServer = utils.run,
        getHostname = lib_misc.get_hostname,
        resolvHost = lib_misc.resolv_host
}
return _M
                                