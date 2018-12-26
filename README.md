## Atlassian Jira Software

### Simple line to start: 

```
    docker run -d -p 8080:8080 --rm --name jira q2digger/jira-software:latest
```

Line to start with ENV VARIABLES: 
```
    docker run -d -p 8080:8080 --rm --name jira \
      -e JVM_MINIMUM_MEMORY=2048m \
      -e JVM_MAXIMUM_MEMORY=4096m \
      -e CATALINA_CONNECTOR_PROXYNAME='jira.local.net' \
      -e CATALINA_CONNECTOR_PROXYPORT='443' \
      -e CATALINA_CONNECTOR_SCHEME='https' \
      q2digger/jira-software:latest
```
or you can use docker-compose.yml (example below)

### Setup database during first run of the container

You can use **jira.config** to setup database config. 
It need only first run of the container (dbconfig.xml not exist)

Options for file ```jira.config```

database type:
  - mysql
  - postgresql
  - mssql
  - oracle

all fields are mandatory!! 
  - type
  - host
  - port
  - user 
  - password
  - database
  - schema (only for postgresql, usually "public")

### Example **jira.config**

```
    [database]
    user = atlassian
    password = atlassian
    host = jiradb
    port = 5432
    name = jira
    type = postgresql
    schema = public
```

### Example **docker-compose.yml**
```
version: '2'

services:
  proxy:
    image: jwilder/nginx-proxy
    ports:
      - 0.0.0.0:80:80
      - 0.0.0.0:443:443
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock
      - ./certs/:/etc/nginx/certs:ro
      - ./jira-nginx.conf:/etc/nginx/vhost.d/jira.local.net
    networks:
      - proxy
  jiradb:
    image: blacklabelops/postgres
    volumes:
      - _jiradb:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=atlassian
      - POSTGRES_DB=jira
      - POSTGRES_USER=atlassian
      - POSTGRES_ENCODING=UNICODE
      - POSTGRES_COLLATE=C
      - POSTGRES_COLLATE_TYPE=C
    networks:
      - jira
  jira:
    image: q2digger/jira-software:latest
    ports:
      - 0.0.0.0:8080:8080
    volumes:
      - _jiradata:/var/atlassian/jira
      - _jiralogs:/opt/atlassian/jira/logs
      - ./jira.config:/opt/atlassian/jira/conf/jira.config
      - ./certs/:/ssl/root
    networks:
      - jira
      - proxy
    environment:
      JVM_MINIMUM_MEMORY: '2048m'
      JVM_MAXIMUM_MEMORY: '4096m'
      CATALINA_CONNECTOR_PROXYNAME: 'jira.local.net'
      CATALINA_CONNECTOR_PROXYPORT: '443'
      CATALINA_CONNECTOR_SCHEME: 'https'
      VIRTUAL_HOST: 'jira.local.net'
      VIRTUAL_PORT: '8080'

volumes:
  _jiradb:
  _jiradata:
  _jiralogs:

networks:
  jira:
  proxy:
```

> Written with [StackEdit](https://stackedit.io/).

