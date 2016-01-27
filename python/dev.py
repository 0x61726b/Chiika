from subprocess import Popen, PIPE
import os
import argparse
from requests.auth import HTTPBasicAuth
import requests

parser = argparse.ArgumentParser(description='Pull and push for all Chiika repositories');
parser.add_argument('--pull', help='pull',action='store_true');
parser.add_argument('--push', help='push',action='store_true');

args = parser.parse_args();
pull = args.pull;
push = args.push;

git_command_add_all                 = ['git','add','--all']
git_command_commit                  = ['git','commit','--all','-m','Commit-Bot']

r = requests.get('https://api.github.com/user', auth=HTTPBasicAuth('arkenthera', 'sezalpg44242'))
print r.status_code
