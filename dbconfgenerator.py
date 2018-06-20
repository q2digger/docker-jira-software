import ConfigParser
import os

def workConfig(path,dbconfig):
  """
  Read from config file
  """
  if not os.path.exists(path):
    print "errrorrrrr\n"

  config = ConfigParser.RawConfigParser(allow_no_value=True)
  config.read(path)

  dbtype = config.get("database","type")
  dbname = config.get("database","name")
  dbhost = config.get("database", "host")
  dbuser = config.get("database", "user")
  dbpass = config.get("database", "password")
  dbport = config.get("database", "port")

  if dbtype == "postgresql":
    dbschema = config.get("database","schema")

  dbconfig = open(dbconfig,"w")
  
  dbconfig.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  dbconfig.write("<jira-database-config>\n<name>defaultDS</name>\n<delegator-name>default</delegator-name>\n")

  if dbtype == "mysql":
    dbconfig.write("<database-type>mysql</database-type>\n<jdbc-datasource>\n")
    dbconfig.write("<url>jdbc:mysql://" + dbhost + ":" + dbport + "/" + dbname + "?useUnicode=true&amp;characterEncoding=UTF8&amp;sessionVariables=storage_engine=InnoDB</url>\n")
    dbconfig.write("<driver-class>com.mysql.jdbc.Driver</driver-class>\n<validation-query>select 1</validation-query>\n<validation-query-timeout>3</validation-query-timeout>\n")
  elif dbtype == "postgresql":
    dbconfig.write("<database-type>postgres72</database-type>\n<jdbc-datasource>\n")
    dbconfig.write("<url>jdbc:postgresql://" + dbhost + ":" + dbport + "/" + dbname + "</url>\n")
    dbconfig.write("<driver-class>org.postgresql.Driver</driver-class>\n<validation-query>select version();</validation-query>\n<pool-test-on-borrow>false</pool-test-on-borrow>\n")
  elif dbtype == "mssql":
    dbconfig.write("<database-type>mssql</database-type>\n<schema-name>dbo</schema-name>\n<jdbc-datasource>\n")
    dbconfig.write("<url>jdbc:jtds:sqlserver://" + dbhost + ":" + dbport + "/" + dbname + "</url>\n")
    dbconfig.write("<driver-class>net.sourceforge.jtds.jdbc.Driver</driver-class>\n<validation-query>select 1</validation-query>\n")
  elif dbtype == "oracle":
    dbconfig.write("<database-type>oracle10g</database-type>\n<jdbc-datasource>\n")
    dbconfig.write("<url>jdbc:oracle:thin:@//" + dbhost + ":" + dbport + "/" + dbname + "</url>\n")
    dbconfig.write("<driver-class>oracle.jdbc.OracleDriver</driver-class>\n<validation-query>select 1 from dual</validation-query>\n<pool-test-on-borrow>false</pool-test-on-borrow>\n")

  dbconfig.write("<username>" + dbuser + "</username>\n")
  dbconfig.write("<password>" + dbpass + "</password>\n")
  dbconfig.write("<pool-size>30</pool-size>\n")
  dbconfig.write("<pool-remove-abandoned>true</pool-remove-abandoned>\n")
  dbconfig.write("<pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>\n")
  dbconfig.write("<pool-test-while-idle>true</pool-test-while-idle>\n")
  dbconfig.write("<min-evictable-idle-time-millis>60000</min-evictable-idle-time-millis>\n")
  dbconfig.write("<time-between-eviction-runs-millis>300000</time-between-eviction-runs-millis>\n")
  dbconfig.write("</jdbc-datasource>\n</jira-database-config>\n")

  dbconfig.close()

if __name__ == "__main__":
  path = "/opt/atlassian/jira/conf/jira.config"
  dbconfig = "/var/atlassian/jira/dbconfig.xml"
  workConfig(path,dbconfig)

