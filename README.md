# What is this?

Utility to configure [dnsdist](https://dnsdist.org/) in a quick way.

Your configuration is composed of the following parts with **YAML** format:
- `services`: DNS services to start (DNS, DoH, DoT)
- `admin`: Enables the console, web API and more
- `rules`: Defines how to handle your DNS traffic

See the complete **[configuration](./examples/dnsdist-full.yml)** file for all options.

## Installation

1. Copy `dnsdist_utils.lua` and the folder `dnsdist_utils` in your `dnsdist` configuration folder (the default is `/etc/dnsdist`)
4. Copy the `dnsdist.conf` to import this LUA module and the new configuration file.

```lua
-- Import module and load the YAML config
package.path = "/etc/dnsdist/" .. package.path
dnsdist_utils = require "dnsdist_utils"
dnsdist_utils.loadConfig{file="/etc/dnsdist/dnsdist.yml"}
```
## Get started

Create a `/etc/dnsdist/dnsdist.yml` file and copy the content of the [minimal](./examples/dnsdist-minimal.yml) configuration example to start dnsdist like a `Forwarding and Caching DNS Server` to a pool of DNS public servers.

```yaml
# Basic Forwarding and Caching DNS Server to a pool of public DNS server
# load balancing of the outgoing traffic to a pool of dns servers in round robin
rules:
  - upstreams:
      dns:
        - ip: 8.8.8.8
        - ip: 9.9.9.9
        - ip: 1.1.1.1
```

## Examples

- [x] [Use case 1: Forward to a pool of DNS public servers](./examples/dnsdist-minimal.yml)
- [x] [Use case 2: Forward to a pool of DOH public servers](./examples/dnsdist-doh.yml)
- [x] [Use case 3: Ads/tracking/malware domains blocking before to forward](./examples/dnsdist-blacklist.yml)
- [x] [Use case 4: Split between corporate and external DNS](./examples/dnsdist-split.yml)
- [x] [Use case 5: Traffic remote logging per rule](./examples/dnsdist-logging.yml)

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
dnsdist_utils.loadConfig{file="/etc/dnsdist/conf.d/dnsdist.yml"}
```

3. Configure your `dnsdist.yml` config file

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