FROM sgrio/java-oracle:server_jre_8

MAINTAINER Dmitry Gerasimov <q2digger@gmail.com>

ARG JIRA_VERSION=7.10.1

ENV RUN_USER    daemon
ENV RUN_GROUP   daemon

# Important deirectories
ENV JIRA_HOME           /var/atlassian/jira
ENV JIRA_INSTALL_DIR    /opt/atlassian/jira

# Expose HTTP
EXPOSE 8080

WORKDIR $JIRA_HOME

# Add Tini
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENTRYPOINT ["/tini", "--"]
CMD ["/entrypoint.sh", "-fg"]

RUN apt-get update --quiet \
    && update-ca-certificates \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 xmlstarlet ttf-dejavu curl python python-configparser \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

COPY entrypoint.sh  /entrypoint.sh

COPY dbconfgenerator.py /dbconfgenerator.py
COPY ./ssl/sslinstall.sh /sslinstall.sh

RUN set -x \
    && mkdir -p                "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_HOME}/caches/indexes" \
    && chmod -R 700            "${JIRA_HOME}" \
    && chown -R daemon:daemon  "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL_DIR}/conf/Catalina" \
    && curl -Ls                "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-"${JIRA_VERSION}".tar.gz" | tar -xz --directory "${JIRA_INSTALL_DIR}" --strip-components=1 --no-same-owner \
    && curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.38.tar.gz" | tar -xz --directory "${JIRA_INSTALL_DIR}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.38/mysql-connector-java-5.1.38-bin.jar" \
    && rm -f                   "${JIRA_INSTALL_DIR}/lib/postgresql-9.1-903.jdbc4-atlassian-hosted.jar" \
    && curl -Ls                "https://jdbc.postgresql.org/download/postgresql-42.2.1.jar" -o "${JIRA_INSTALL_DIR}/lib/postgresql-42.2.1.jar" \
    && chmod -R 700            "${JIRA_INSTALL_DIR}/conf" \
    && chmod -R 700            "${JIRA_INSTALL_DIR}/logs" \
    && chmod -R 700            "${JIRA_INSTALL_DIR}/temp" \
    && chmod -R 700            "${JIRA_INSTALL_DIR}/work" \
    && chown -R daemon:daemon  "${JIRA_INSTALL_DIR}/conf" \
    && chown -R daemon:daemon  "${JIRA_INSTALL_DIR}/logs" \
    && chown -R daemon:daemon  "${JIRA_INSTALL_DIR}/temp" \
    && chown -R daemon:daemon  "${JIRA_INSTALL_DIR}/work" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && touch -d "@0"           "${JIRA_INSTALL_DIR}/conf/server.xml" \
    && mkdir -p                 /ssl

COPY ./ssl/   /ssl/

RUN set -x \   
    && sed -i -e 's/^JVM_MINIMUM_MEMORY.*//g' ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && sed -i -e 's/^JVM_MAXIMUM_MEMORY.*//g' ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && sed -i -e 's/port="8080"/port="8080" secure="${catalinaConnectorSecure}" scheme="${catalinaConnectorScheme}" proxyName="${catalinaConnectorProxyName}" proxyPort="${catalinaConnectorProxyPort}"/' ${JIRA_INSTALL_DIR}/conf/server.xml

VOLUME ["/var/atlassian/jira", "/opt/atlassian/jira/logs"]
