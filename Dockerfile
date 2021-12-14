FROM perl:5.34.0

RUN groupadd -g 1117 tdr && useradd -u 1117 -g tdr -m tdr && \
    mkdir -p /etc/canadiana /var/log/tdr /var/lock/tdr && ln -s /home/tdr /etc/canadiana/tdr && chown tdr.tdr /var/log/tdr /var/lock/tdr && \
    ln -fs /usr/share/zoneinfo/America/Toronto /etc/localtime && \
    \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq cpanminus build-essential libxslt1-dev  \
    libxml2-dev libxml2-utils xml-core libaio-dev libssl-dev rsync rsyslog sudo util-linux curl less && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean

WORKDIR /home/tdr
COPY Archive-BagIt-0.054.tar.gz cpanfile* *.conf /home/tdr/
COPY aliases /etc/aliases

RUN cpanm -n --installdeps . && rm -rf /root/.cpanm || \
    (cat /root/.cpanm/work/*/build.log && exit 1)
RUN cpanm -n --reinstall /home/tdr/Archive-BagIt-0.054.tar.gz && rm -rf /root/.cpanm || (cat /root/.cpanm/work/*/build.log && exit 1)

COPY CIHM-Swift CIHM-Swift
COPY CIHM-TDR CIHM-TDR

ENV PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/tdr/CIHM-TDR/bin:/home/tdr/CIHM-Swift/bin"
ENV PERL5LIB "/home/tdr/CIHM-TDR/lib:/home/tdr/CIHM-Swift/lib"
SHELL ["/bin/bash", "-c"]
USER tdr