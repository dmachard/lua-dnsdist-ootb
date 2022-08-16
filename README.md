# What is this?

Utility to configure dnsdist in a new fashion way.

## Installation

1. Copy `dnsdist_utils.lua` and the folder `dnsdist_utils` in your `dnsdist` configuration folder (the default is `/etc/dnsdist`)
4. Add the following code to your `dnsdist.conf` to import this LUA module

```lua
package.path = "/etc/dnsdist/" .. package.path
dnsdist_utils = require "dnsdist_utils"
```
## Get started

Below a quick configuration to start dnsdist like a **Forwarding and Caching DNS Server to a pool of DNS public servers**.

```lua
-- Update the search path and load the module
package.path = "/etc/dnsdist/" .. package.path
dnsdist_utils = require "dnsdist_utils"

-- describe your config
opts = {
    -- Listen DNS
    listen = {
        dns = {port="53"},
    },

    -- Forward all dns traffic to a pool of default DNS and DoH public resolvers
    forwarders = {
        dnsServers={ {addr="8.8.8.8:53"}, {addr="1.1.1.1:53"} }
    }
}

-- load the dnsdist configuration
dnsdist_utils.runServer{opts=opts}
```

Otherwise see the full [configuration](./dnsdist.conf) for all options.

## More configuration options

* **dnsdist_utils.getHosname()**

    Return the hostname of the server.

* **dnsdist_utils.resolvHost(name)**

    Resolv the provided host.