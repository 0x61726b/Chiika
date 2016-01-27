from subprocess import Popen, PIPE
import os
import argparse

# parser = argparse.ArgumentParser(description='Pull and push for all Chiika repositories');
# parser.add_argument('--pull', help='pull',action='store_true');
# parser.add_argument('--push', help='push',action='store_true');
#
# args = parser.parse_args();
# pull = args.pull;
# push = args.push;

git_command_fetch_origin            = ['git', 'fetch','origin']
git_command_pull                    = ['git','pull']
git_command_clone_chiikaNode        = ['git','clone','https://github.com/arkenthera/chiika-node']
git_command_clone_chiikaApi         = ['git','clone','https://github.com/arkenthera/ChiikaApi']
git_command_init_submodules         = ['git','submodule','update', '--init','--recursive']
chiika  = os.getcwd() + "/../";
chiikaNode  = os.getcwd() + "/../../chiika-node";
chiikaApi   = os.getcwd() + "/../../ChiikaApi";

def Check_If_Chiika_Exists_Otherwise_Clone():
    if os.path.isdir(chiikaNode):
        print "Chiika-Node exists on " + os.path.abspath(chiikaNode)
    else:
        print "Chiika-Node doesn't exist.Cloning from https://github.com/arkenthera/chiika-node"

        git_query = Popen(git_command_clone_chiikaNode, cwd=chiikaNode + '/..', stdout=PIPE, stderr=PIPE)
        (git_status, error) = git_query.communicate()
    if os.path.isdir(chiikaApi):
        print "ChiikaApi exists on " + os.path.abspath(chiikaApi)
    else:
        print "ChiikaApi doesn't exist.Cloning from https://github.com/arkenthera/ChiikaApi"

        git_query = Popen(git_command_clone_chiikaApi, cwd=chiikaApi + '/..', stdout=PIPE, stderr=PIPE)
        (git_status, error) = git_query.communicate()

def Pull_Chiika():
    print "Fetching ChiikaApi..."
    #Fetch ChiikaApi
    git_query = Popen(git_command_fetch_origin, cwd=chiikaApi, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print "Pulling ChiikaApi..."
    #Pull ChiikaApi
    git_query = Popen(git_command_pull, cwd=chiikaApi, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print "Pulling submodules..."
    git_query = Popen(git_command_init_submodules, cwd=chiikaApi, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    #Fetch ChiikaApi
    print "Fetching Chiika-Node..."
    git_query = Popen(git_command_fetch_origin, cwd=chiikaNode, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print "Pulling Chiika-Node..."
    #Pull ChiikaApi
    git_query = Popen(git_command_pull, cwd=chiikaNode, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()


    #Fetch Chiika
    print "Fetching Chiika..."
    git_query = Popen(git_command_fetch_origin, cwd=chiika, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

    print "Pulling Chiika..."
    #Pull ChiikaApi
    git_query = Popen(git_command_pull, cwd=chiika, stdout=PIPE, stderr=PIPE)
    (git_status, error) = git_query.communicate()

Check_If_Chiika_Exists_Otherwise_Clone()
Pull_Chiika()
