FROM alpine:3.8

MAINTAINER Dmitry Gerasimov <q2digger@gmail.com>

ENV JIRA_VERSION 8.12.3

ENV RUN_USER    daemon
ENV RUN_GROUP   daemon

# Important deirectories
ENV JIRA_HOME           /var/atlassian/jira
ENV JIRA_INSTALL_DIR    /opt/atlassian/jira

# Expose HTTP
EXPOSE 8080

WORKDIR $JIRA_HOME

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/entrypoint.sh", "-fg"]

COPY entrypoint.sh  /entrypoint.sh

COPY dbconfgenerator.py /dbconfgenerator.py

RUN apk update -qq \
    && apk add ca-certificates wget curl openssh bash procps openssl perl ttf-dejavu tini python2 openjdk8-jre \
    && update-ca-certificates 2>/dev/null || true \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# Jira is tested and bundled with the 42.2.6 JDBC driver. You can also use the latest JDBC driver for your PostgreSQL version, 
# though we can't guarantee it will work with your version of Jira. To use a different JDBC driver:

RUN set -x \
    && mkdir -p                "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_HOME}/caches/indexes" \
    && chmod -R 700            "${JIRA_HOME}" \
    && chown -R daemon:daemon  "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL_DIR}/conf/Catalina" \
    && curl -Ls                "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-8.12.3.tar.gz" | tar -xz --directory "${JIRA_INSTALL_DIR}" --strip-components=1 --no-same-owner \
    && curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.48.tar.gz" | tar -xz --directory "${JIRA_INSTALL_DIR}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.48/mysql-connector-java-5.1.48-bin.jar" \
    && rm -f                   "${JIRA_INSTALL_DIR}/lib/postgresql-*" \
    && curl -Ls                "https://jdbc.postgresql.org/download/postgresql-42.2.11.jar" -o "${JIRA_INSTALL_DIR}/lib/postgresql-42.2.11.jar" \
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
