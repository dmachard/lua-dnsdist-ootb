# What is this?

Utility to configure [dnsdist](https://dnsdist.org/) in a quick way.
The configuration is composed of the following parts:
- `services`: DNS services to start (DNS, DoH, DoT)
- `admin`: Enables the console, web API and more
- `rules`: Defines how to handle your DNS traffic

See the complete **[configuration](./examples/0.dnsdist.conf)** file for all options.

## Installation

1. Copy `dnsdist_utils.lua` and the folder `dnsdist_utils` in your `dnsdist` configuration folder (the default is `/etc/dnsdist`)
4. Add the following code to your `dnsdist.conf` to import this LUA module

```lua
-- Import module
package.path = "/etc/dnsdist/" .. package.path
dnsdist_utils = require "dnsdist_utils"
```
## Get started

Below a quick configuration to start dnsdist like a `Forwarding and Caching DNS Server` to a pool of DNS public servers.

```lua
-- Import module
package.path = "/etc/dnsdist/" .. package.path
dnsdist_utils = require "dnsdist_utils"

-- Basic Forwarding and Caching DNS Server to a pool of public DNS servers
opts = {
    rules = {
        -- rule #1: load balancing of the outgoing traffic to a pool 
        -- of dns servers in round robin 
        { 
            upstreams = { 
                dns={ 
                    {ip="8.8.8.8"}, 
                    {ip="9.9.9.9"},
                    {ip="1.1.1.1"},
                }
            } 
        },
    }
}

-- Generate dnsdist config
dnsdist_utils.runServer{opts=opts}
```

## Examples

- [x] [Use case 1: Forward to a pool of DNS public servers](./examples/1.dnsdist.conf)
- [x] [Use case 2: Forward to a pool of DOH public servers](./examples/2.dnsdist.conf)
- [x] [Use case 3: Ads/tracking/malware domains blocking before to forward](./examples/3.dnsdist.conf)
- [x] [Use case 4: Split between corporate and external DNS](./examples/4.dnsdist.conf)
- [x] [Use case 5: Traffic remote logging per rule](./examples/5.dnsdist.conf)

## Docker 

1. Create the folder `conf` with the following content
   - conf/
     - dnsdist_utils/
     - dnsdist_utils.lua
     - dnsdist.conf

2. Import the module for the docker image like this

```
-- Import module
package.path = "/etc/dnsdist/conf.d/" .. package.path
dnsdist_utils = require "dnsdist_utils"
```

3. Configure your dnsdist config file

4. Then mount the folder as a volume 

```
sudo docker run -d -p 53:53/udp -p 53:53/tcp --restart unless-stopped --name=dnsdist --volume=$PWD/conf/:/etc/dnsdist/conf.d/ powerdns/dnsdist-17:1.7.2
```

## More configuration options

This module provide also some functions:

* **dnsdist_utils.getHosname()**

    Return the hostname of the server.

* **dnsdist_utils.resolvHost(name)**

    Resolv the provided host.

    Options:
    - name: string - dns name to resolv