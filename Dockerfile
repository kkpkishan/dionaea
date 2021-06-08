FROM debian:buster-slim
ENV DEBIAN_FRONTEND noninteractive
#
# Include dist
ADD dist/ /root/dist/
#
# Install dependencies and packages
RUN apt-get update && \
    apt-get install netselect-apt -y && \
    netselect-apt && \
    mv sources.list /etc/apt/ && \
    apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends \
	build-essential \
	ca-certificates \
	check \
	cmake \
	cython3 \
	git \
    libcap2-bin \
	libcurl4-openssl-dev \
	libemu-dev \
	libev-dev \
	libglib2.0-dev \
	libloudmouth1-dev \
	libnetfilter-queue-dev \
	libnl-3-dev \
	libpcap-dev \
	libssl-dev \
	libtool \
	libudns-dev \
	procps \
	python3 \
	python3-dev \
	python3-boto3 \
	python3-bson \
	python3-yaml \
	fonts-liberation && \
#
# Get and install dionaea
    # Latest master is unstable, SIP causes crashing
    #git clone --depth=1 https://github.com/dinotools/dionaea -b 0.11.0 /root/dionaea/ && \
    git clone --depth=1 https://github.com/dinotools/dionaea  /root/dionaea/ && \
    cd /root/dionaea && \
    git checkout 1426750b9fd09c5bfeae74d506237333cd8505e2 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/dionaea .. && \
    make && \
    make install && \
#
# Setup user and groups
    setcap cap_net_bind_service=+ep /opt/dionaea/bin/dionaea 
#
ADD dist/ /root/dist/
# Supply configs and set permissions
RUN   chown -R dionaea:dionaea /opt/dionaea/var && \
      rm -rf /opt/dionaea/etc/dionaea/* && \
      mv /root/dist/etc/* /opt/dionaea/etc/dionaea/ && \
      apt-get purge -y \
      build-essential \
      ca-certificates \
      check \
      cmake \
      cython3 \
      git \
      libcurl4-openssl-dev \
      libemu-dev \
      libev-dev \
      libglib2.0-dev \
      libloudmouth1-dev \
      libnetfilter-queue-dev \
      libnl-3-dev \
      libpcap-dev \
      libssl-dev \
      libtool \
      libudns-dev \
      python3 \
      python3-dev \   
      python3-boto3 \
      python3-bson \
      python3-yaml && \ 
      apt-get install -y \
      ca-certificates \
      python3 \
      python3-boto3 \
      python3-bson \
      python3-yaml \
      libcurl4 \
      libemu2 \
      libev4 \
      libglib2.0-0 \
      libnetfilter-queue1 \
      libnl-3-200 \
      libpcap0.8 \
      libpython3.7 \
      libudns0 
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man2
RUN apt-get update && \
apt-get install -y --no-install-recommends \
        openjdk-11-jre aria2 bzip2
RUN mkdir -p /etc/listbot &&\
    cd /etc/listbot \
    aria2c -s16 -x 16 https://listbot.sicherheitstacho.eu/cve.yaml.bz2 &&\
    aria2c -s16 -x 16 https://listbot.sicherheitstacho.eu/iprep.yaml.bz2 &&\
    bunzip2 *.bz2

RUN mkdir -p /usr/share/logstash
RUN aria2c -s 16 -x 16 https://artifacts.elastic.co/downloads/logstash/logstash-oss-7.10.2-linux-x86_64.tar.gz
RUN tar xvfz logstash-oss-7.10.2-linux-x86_64.tar.gz --strip-components=1 -C /usr/share/logstash/
RUN rm -rf /usr/share/logstash/jdk
RUN /usr/share/logstash/bin/logstash-plugin install logstash-filter-translate
RUN /usr/share/logstash/bin/logstash-plugin install logstash-output-syslog
RUN mkdir -p /etc/logstash/conf.d/
RUN cp /root/dist/logstash.conf /etc/logstash/conf.d/logstash.conf
RUN cp /root/dist/tpot_es_template.json /etc/logstash/tpot_es_template.json 
RUN cp /root/dist/update.sh /usr/bin/
RUN chmod 755 /usr/bin/update.sh 
RUN mkdir -p /opt/dionaea/var/dionaea/roots/tftp &&\
    mkdir /opt/dionaea/var/dionaea/roots/ftp &&\
    mkdir /opt/dionaea/var/dionaea/roots/www &&\
    mkdir /opt/dionaea/var/dionaea/binaries 
RUN chown -R dionaea:dionaea /opt/dionaea
RUN cp /root/dist/services.sh /services.sh
RUN chown dionaea:dionaea /services.sh
RUN chmod +x /services.sh
RUN apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /logstash-oss-7.10.2-linux-x86_64.tar.gz /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENTRYPOINT ["./services.sh"]

