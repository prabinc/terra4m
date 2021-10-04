echo "Install OS tools"
sudo yum -y -q -e 0 install  jq moreutils nmap > /dev/null
echo "Update OS tools"
sudo yum update -y > /dev/null
echo "Update pip"
sudo pip install --upgrade pip 2&> /dev/null

#
echo "Uninstall AWS CLI v1"
sudo /usr/local/bin/pip uninstall awscli -y 2&> /dev/null
sudo pip uninstall awscli -y 2&> /dev/null
echo "Install AWS CLI v2"
curl --silent "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" > /dev/null
unzip -qq awscliv2.zip
sudo ./aws/install > /dev/null
rm -f awscliv2.zip
rm -rf aws

echo "Setup kubectl"
if [ ! `which kubectl 2> /dev/null` ]; then
  echo "Install kubectl"
  curl --silent -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl  > /dev/null
  chmod +x ./kubectl
  sudo mv ./kubectl  /usr/local/bin/kubectl > /dev/null
  kubectl completion bash >>  ~/.bash_completion
fi

if [ ! `which eksctl 2> /dev/null` ]; then
echo "install eksctl"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp   > /dev/null
sudo mv -v /tmp/eksctl /usr/local/bin > /dev/null
echo "eksctl completion"
eksctl completion bash >> ~/.bash_completion
fi

if [ ! `which helm 2> /dev/null` ]; then
  echo "helm"
  wget -q https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz > /dev/null
  tar -zxf helm-v3.5.4-linux-amd64.tar.gz
  sudo mv linux-amd64/helm /usr/local/bin/helm > /dev/null
  rm -rf helm-v3.5.4-linux-amd64.tar.gz linux-amd64
fi
echo "add helm repos"
helm repo add eks https://aws.github.io/eks-charts

if [ ! `which kubectx 2> /dev/null` ]; then
  echo "kubectx"
  sudo git clone -q https://github.com/ahmetb/kubectx /opt/kubectx > /dev/null
  sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
fi

