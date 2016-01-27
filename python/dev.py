from subprocess import Popen, PIPE
import os
import argparse
from requests.auth import HTTPBasicAuth
import requests
import time
t = time.strftime("%d/%m/%Y %I:%M:%S")

parser = argparse.ArgumentParser(description='Pull and push for all Chiika repositories');
parser.add_argument('--pull', help='pull',action='store_true');
parser.add_argument('--push', help='push',action='store_true');

args = parser.parse_args();
pull = args.pull;
push = args.push;

git_command_add_all                 = ['git','add','--all']
git_command_commit                  = ['git','commit','--all','-m','"Weeabot - Auto commit ' + t + '""']
git_command_push                    = ['git','push']

chiika  = os.getcwd() + "/../";
chiikaNode  = os.getcwd() + "/../../chiika-node";
chiikaApi   = os.getcwd() + "/../../ChiikaApi";

#Pushing Chiika
git_query = Popen(git_command_add_all, cwd=chiika, stdout=PIPE, stderr=PIPE)
(git_status, error) = git_query.communicate()

git_query = Popen(git_command_commit, cwd=chiika, stdout=PIPE, stderr=PIPE)
(git_status, error) = git_query.communicate()

git_query = Popen(git_command_push, cwd=chiika, stdout=PIPE, stderr=PIPE)
(git_status, error) = git_query.communicate()
