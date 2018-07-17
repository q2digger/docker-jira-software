import requests
import json
import re
import os

# Turn off HTTTPS warnings since we're using a custom CA
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings()

def get_latest_ver_avail(url):
    r = requests.get(url)
    if r.status_code != 200:
        print "Error accessing URL: " + url
        return None
    clean_json = r.text.replace('downloads(','')[:-1]
    #print clean_json
    parsed = json.loads(clean_json)
    for dl in parsed:
        #print dl['description'],dl['releaseNotes']
        #print dl
        if 'Linux' in dl['description'] or 'TAR' in dl['description']:
            return dl['version'],dl['releaseNotes']

def check_jira():
    version_file = open("version","r")
    jira_version = version_file.read()

    # output_title('Jira Software')
    atlass_url = 'https://my.atlassian.com/download/feeds/current/jira-software.json'

    version_uri = '/admin/systeminfo.action'
    auth_uri = '/doauthenticate.action'

    latest_ver,rel_notes = get_latest_ver_avail(atlass_url)
    # print '\nLatest version: ' + latest_ver
    # print 'Release notes: ' + rel_notes

    compare_versions(jira_version,latest_ver)
  
def compare_versions(jira_version, latest_ver):
    if str(jira_version) != str(latest_ver):
      print "new version available! jira_version"
      file = ("version","w")
      file.seek(0)
      file.write(latest_ver)
      file.close
      os.system("docker build -e version=latest_ver -t q2digger/jira:latest_ver -t q2digger/jira:latest .")
    else:
      print "not new version"

def output_title(title):
    print title + ':'

def main():
    check_jira()

if __name__ == '__main__':
    main()
