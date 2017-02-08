# Supported tags and respective `Dockerfile` links

* `1.3.5-2.4`, `1.3-2.4`, `1-2.4`, `1.3.5`, `1.3`, `1`, `latest` [(1.3/2.4/Dockerfile)][dockerfile]
* `1.3.5-2.4-alpine`, `1.3-2.4-alpine`, `1-2.4-alpine`, `1.3.5-alpine`, `1.3-alpine`, `1-alpine`, `alpine` [(1.3/2.4-alpine/Dockerfile)][dockerfile-alpine]
* `1.3.6.cr1-2.4`, `1.3.6.cr1` [(1.3cr/2.4/Dockerfile)][dockerfile-unstable]
* `1.3.6.cr1-2.4-alpine`, `1.3.6.cr1-alpine` [(1.3cr/2.4-alpine/Dockerfile)][dockerfile-alpine-unstable]

# What is `mod_cluster`?

mod_cluster is an httpd-based load balancer. Like mod_jk and mod_proxy, mod_cluster uses a communication channel to forward requests from httpd to one of a set of application server nodes. Unlike mod_jk and mod_proxy, mod_cluster leverages an additional connection between the application server nodes and httpd. The application server nodes use this connection to transmit server-side load balance factors and lifecycle events back to httpd via a custom set of HTTP methods, affectionately called the Mod-Cluster Management Protocol (MCMP). This additional feedback channel allows mod_cluster to offer a level of intelligence and granularity not found in other load balancing solutions.

> [JBoss mod_cluster project page][mod_cluster]

![JBoss mod_cluster][banner]

# What is the `httpd-mod_cluster` image?

An extension of the upstream [`httpd`][docker-httpd] image with JBoss [`mod_cluster`][mod_cluster] modules, built using [apxs][apxs] (APache eXtenSion tool):
* `mod_proxy_cluster`
* `mod_advertise`
* `mod_manager`
* `mod_cluster_slotmem`

# How to use the `httpd-mod_cluster` image?

This image inherits from the configuration options from the parent [`httpd`][docker-httpd] image.

Besides a sample configuration file is available in `conf/extra/proxy-cluster.conf` to help you get started with `mod_cluster`. This configuration includes the following aspects:
* Listen on port `6666` (all interfaces)
* Default VirtualHost on port `6666`
  * enable receiving Mod Cluster Protocol Messages (MCPM)
  * allow communication from the `172.0.0.0/8` subnet only (default for Docker bridges)
  * advertise the server to the default multicast group (`224.0.1.105:23364`)
  * enable the mod_cluster status page on `/mod_cluster-manager` from the local host

This configuration is **disabled** by default. To enable it, simply uncomment the relevant directives from the main `httpd` configuration file (`conf/httpd.conf`):

```apache
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_ajp_module modules/mod_proxy_ajp.so
LoadModule proxy_cluster_module modules/mod_proxy_cluster.so
LoadModule advertise_module modules/mod_advertise.so
LoadModule manager_module modules/mod_manager.so
LoadModule cluster_slotmem_module modules/mod_cluster_slotmem.so
Include conf/extra/proxy-cluster.conf
```

# Image Variants

The `httpd-mod_cluster` images come in different flavors, each designed for a specific use case.

## Base operating system

### `httpd-mod_cluster:<version>`

This is the defacto image, based on the [Debian](http://debian.org) operating system, available in [the `debian` official image](https://hub.docker.com/_/debian).

### `httpd-mod_cluster:<version>-alpine`

This image is based on the [Alpine Linux](http://alpinelinux.org) operating system, available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

## Components

A tagging convention determines the version of the components distributed with the `httpd-mod_cluster` image.

### `<version α>`

* mod_cluster release: **α**
* httpd release: *as distributed with the [`httpd:latest`][docker-httpd] upstream image*

### `<version α>-<version β>`

* mod_cluster release: **α**
* httpd release: **β** (latest patch version)

# Maintenance

## Rebuilding images

All images in this repository can be rebuilt and tagged manually using [Bashbrew][bashbrew], the tool used for cloning, building, tagging, and pushing the Docker official images. To do so, simply call the `bashbrew` utility, pointing it to the included `httpd-mod_cluster` definition file as in the example below:

```
bashbrew --library . build httpd-mod_cluster
```

## Automated build pipeline

Any push to the upstream [`httpd`][docker-httpd] repository or to the source repository triggers an automatic rebuild of all the images in this repository. From a high perspective the automated build pipeline looks like the below diagram:

![Automated build pipeline][pipeline]



[dockerfile]: https://github.com/antoineco/httpd-mod_cluster/blob/master/1.3/2.4/Dockerfile
[dockerfile-alpine]: https://github.com/antoineco/httpd-mod_cluster/blob/master/1.3/2.4-alpine/Dockerfile
[dockerfile-unstable]: https://github.com/antoineco/httpd-mod_cluster/blob/master/1.3cr/2.4/Dockerfile
[dockerfile-alpine-unstable]: https://github.com/antoineco/httpd-mod_cluster/blob/master/1.3cr/2.4-alpine/Dockerfile
[banner]: https://raw.githubusercontent.com/antoineco/httpd-mod_cluster/master/modcluster_banner_r1v2.png
[docker-httpd]: https://hub.docker.com/_/httpd/
[mod_cluster]: http://modcluster.io/
[apxs]: https://httpd.apache.org/docs/2.4/programs/apxs.html
[bashbrew]: https://github.com/docker-library/official-images/blob/master/bashbrew/README.md
[pipeline]: https://raw.githubusercontent.com/antoineco/httpd-mod_cluster/master/build_pipeline.png
