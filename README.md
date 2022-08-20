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

Below a quick configuration to start dnsdist like a **Forwarding and Caching DNS Server to a pool of DNS public servers
with blocklist for ads/tracking/malware domains**. The blocklist is a CDB database with hourly reload.

```lua
package.path = "/etc/dnsdist/" .. package.path
dnsdist_utils = require "dnsdist_utils"

opts = {
    rules = {
        -- rule #1: block ads/tracking/malware domains
        { qnamecdb = {filename="/etc/dnsdist/blocklist.cdb"},  policy = "drop"},

        -- rule #2: otherwise forward the rest to a pool of default DNS servers
        { upstreams = { dns={ {ip="8.8.8.8"}, {ip="9.9.9.9"} } } },
    }
}

dnsdist_utils.runServer{opts=opts}
```

Otherwise see the full **[configuration](./dnsdist.conf)** for all options.

## More configuration options

* **dnsdist_utils.getHosname()**

    Return the hostname of the server.

* **dnsdist_utils.resolvHost(name)**

    Resolv the provided host.

    Options:
    - name: string - dns name to resolv