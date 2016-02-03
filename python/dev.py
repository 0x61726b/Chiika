from subprocess import Popen, PIPE
import os
import argparse
import time
t = time.strftime("%d/%m/%Y %I:%M:%S")

git_command_add_all                 = ['git','add','--all']
git_command_commit                  = ['git','commit','--all','-m','"Bot-dono - Auto commit ' + t + '""']
git_command_push                    = ['git','push']

parser = argparse.ArgumentParser(description='Pull and push for all Chiika repositories');
parser.add_argument('--chiika', help='Push Chiika',action='store_true');
parser.add_argument('--chiikaNode', help='Push Chiika-Node',action='store_true');
parser.add_argument('--chiikaApi', help='Push Chiika-Api',action='store_true');
parser.add_argument('--all', help='Push Chiika-Api',action='store_true');

args = parser.parse_args();
argchiika = args.chiika;
argchiikaNode = args.chiikaNode;
argchiikaApi = args.chiikaApi;
argall = args.all

chiika  = os.getcwd() + "/../";
chiikaNode  = os.getcwd() + "/../../chiika-node";
chiikaApi   = os.getcwd() + "/../../ChiikaApi";

def Push_Chiika():
    #Pushing Chiika
    print "Chiika - Adding..."
    git_query = Popen(git_command_add_all, cwd=chiika, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print "Chiika - Making commit..."
    git_query = Popen(git_command_commit, cwd=chiika, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print "Chiika - Pushing..."
    git_query = Popen(git_command_push, cwd=chiika, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print error

def Push_ChiikaApi():
    print "ChiikaApi - Adding..."
    git_query = Popen(git_command_add_all, cwd=chiikaApi, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print "ChiikaApi - Making commit..."
    git_query = Popen(git_command_commit, cwd=chiikaApi, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()


    print "ChiikaApi - Pushing..."
    git_query = Popen(git_command_push, cwd=chiikaApi, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print error


def Push_ChiikaNode():
    print "Chiika-Node - Adding..."
    git_query = Popen(git_command_add_all, cwd=chiikaNode, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print "Chiika-Node - Making commit..."
    git_query = Popen(git_command_commit, cwd=chiikaNode, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print "Chiika-Node - Pushing..."
    git_query = Popen(git_command_push, cwd=chiikaNode, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print error

if argchiika == True:
    Push_Chiika()
if argchiikaNode == True:
    Push_ChiikaNode()
if argchiikaApi == True:
    Push_ChiikaApi()
if argall == True:
    Push_ChiikaApi()
    Push_ChiikaNode()
    Push_Chiika()
