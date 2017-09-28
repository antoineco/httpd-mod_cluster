FROM antoineco/httpd:2.4-centos

MAINTAINER Antoine Cotten <tonio.cotten@gmail.com> (@antoineco)

ENV MOD_CLUSTER_VERSION=1.3.7.Final \
    MOD_CLUSTER_MD5SUM=36d9053fcfdcf561479e229bac759eef

# install mod_cluster modules
RUN set -x \
  && buildDeps=" \
       ca-certificates \
       gcc \
       make \
       autoconf \
     " \
  && yum install -y $buildDeps \
  && yum clean all \
  && cd /tmp \
  && curl -sSL https://github.com/modcluster/mod_cluster/archive/"$MOD_CLUSTER_VERSION".tar.gz -o mod_cluster.tgz \
  && echo "$MOD_CLUSTER_MD5SUM  /tmp/mod_cluster.tgz" | md5sum -c - \
  && modDir="$(tar -tf mod_cluster.tgz | head -1)" \
  && tar -xzvf mod_cluster.tgz "$modDir"native \
  && cd "$modDir"native \
  && for mod in advertise mod_manager mod_proxy_cluster mod_cluster_slotmem; do \
       cd "$mod"; \
       sh buildconf; \
       ./configure --with-apxs="$HTTPD_PREFIX"/bin/apxs; \
       make || exit 1; \
       cp *.so "$HTTPD_PREFIX"/modules; \
       cd ..; \
     done \
  && cd /tmp \
  && rm -rf mod_cluster.tgz "$modDir" \
  && yum history -y undo last

# add example directives to main httpd configuration
RUN proxyLoadLine="$(grep -nE "^#?LoadModule proxy_module" conf/httpd.conf | tail -1 | cut -d':' -f1)" \
  && sed -i \
       -e "${proxyLoadLine}a#LoadModule proxy_cluster_module modules/mod_proxy_cluster.so" \
       -e "${proxyLoadLine}a#LoadModule advertise_module modules/mod_advertise.so" \
       -e "${proxyLoadLine}a#LoadModule manager_module modules/mod_manager.so" \
       -e "${proxyLoadLine}a#LoadModule cluster_slotmem_module modules/mod_cluster_slotmem.so" \
       conf/httpd.conf \
  && sed -i \
       -e "\$a# Proxy using mod_cluster" \
       -e "\$a#Include conf/extra/proxy-cluster.conf\n" \
       conf/httpd.conf

# add sample configuration
COPY proxy-cluster.conf conf/extra
