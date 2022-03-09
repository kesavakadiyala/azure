#!/bin/bash

user_id=`id -u`

if [ $user_id -eq 0 ]; then
    echo "Must not run with sudo"
    exit 1
fi

Status_Check(){
  case $? in
    0)
      echo -e "\e[32mSuccess\e[0m"
    ;;
    *)
      echo -e "\e[31mFailed\e[0m"
      exit 1;
    ;;
  esac
}

read -p 'Enter the Azure Project URL(https://dev.azure.com/{your-organization}) : ' URL
read -p 'Enter PAT(Personal access token): ' PAT
read -p 'Enter POOL Name: ' POOL_NAME
read -p 'Enter Agent Name: ' AGENT_NAME

if [ ($URL == null) || ($PAT == null) ]; then
    echo -e "\e[31mMust needed Azure Project URL and PAT \e[0m"
    exit
else
    echo -e "\e[32mStarting configuration of Azure Agent\e[0m"
fi

cd /home/centos
curl -O "https://vstsagentpackage.azureedge.net/agent/2.200.2/vsts-agent-linux-x64-2.200.2.tar.gz" >> agent.log
echo -e "\e[33mDownloading Agent artifacts - \e[0m" `Status_Check`
mkdir /home/centos/myagent ; cd /home/centos/myagent
tar zxvf ../vsts-agent-linux-x64-2.200.2.tar.gz >> agent.log
echo -e "\e[33mExtracting artifacts - \e[0m" `Status_Check`

sudo ./bin/installdependencies.sh >> agent.log
echo -e "\e[33mInstalling Dependencies - \e[0m" `Status_Check`

./config.sh configure --unattended --url $URL --auth pat --token $PAT --pool $POOL_NAME --agent $AGENT_NAME --acceptTeeEula >> agent.log
echo -e "\e[33mConfiguring Agent Pool - \e[0m" `Status_Check`

echo -e "\e[33mStarting AZURE agent\e[0m"
sudo ./svc.sh install centos >> agent.log
sudo ./svc.sh start >> agent.log
if [ $? -eq 0 ]; then
    echo -e "\e[32mStarted Agent Successfully\e[0m"
else
    echo -e "\e[31mERROR in starting agent\e[0m"
fi
