FROM openjdk:8u181

RUN apt-get update \
  && apt-get install -y curl tree \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && useradd -ms /bin/bash pentaho

ENV PENTAHO_HOME=/pentaho
ENV PENTAHO_SHARED=/storage/pentaho
ENV PENTAHO_TOMCAT_URL=https://nchc.dl.sourceforge.net/project/pentaho/Pentaho%208.1/server/pentaho-server-ce-8.1.0.0-365.zip
ENV CATALINA_HOME=$PENTAHO_HOME/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH
ENV GOSU_VERSION 1.10
ENV GOSU_URL=https://github.com/tianon/gosu/releases/download/$GOSU_VERSION

WORKDIR $PENTAHO_HOME
RUN mkdir -p "$PENTAHO_HOME" \
	&& set -x \
	&& curl "$PENTAHO_TOMCAT_URL" -o /tmp/pentaho-server-ce-8.1.0.0-365.zip \
	&& unzip /tmp/pentaho-server-ce-8.1.0.0-365.zip -d /tmp/pentaho \
	&& mv /tmp/pentaho/pentaho-server/* $PENTAHO_HOME/ \
	&& rm -rf /tmp/pentaho \
	&& chown -R pentaho:pentaho $PENTAHO_HOME


RUN wget -O /usr/local/bin/gosu "$GOSU_URL/gosu-$(dpkg --print-architecture)" \
	  && wget -O /usr/local/bin/gosu.asc "$GOSU_URL/gosu-$(dpkg --print-architecture).asc" \
	  && export GNUPGHOME="$(mktemp -d)"

RUN rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc
RUN chmod +x /usr/local/bin/gosu
RUN gosu nobody true

EXPOSE 8080/tcp

VOLUME /storage

CMD ["catalina.sh", "run"]