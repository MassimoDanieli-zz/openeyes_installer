#!/bin/bash

# export keys
export AWS_ACCESS_KEY=YOUR_ACCESS_KEY_HERE
export AWS_SECRET_KEY=YOUR_SECRET_KEY_HERE

export EC2_HOME=/usr/local/ec2/ec2-api-tools-1.7.3.2/
export PATH=$PATH:$EC2_HOME/bin
export JAVA_HOME=$(/usr/libexec/java_home)

AWS_GROUP=""     # your security group here
AWS_KEY=""  # your key name here

if [ $# -lt 1 ]
then
        echo "Usage : aws_openeyes.sh BRANCH_NUMBER"
        echo ""
        echo "The available branches are:"
        echo ""
		BRANCH=$(git ls-remote --heads  git://github.com/openeyes/OpenEyes.git | awk -F"/" '{print substr($0, index($0, $3))}')
select ins_bra in $BRANCH
do
	echo "install $ins_bra "
	break
done
fi

INSTANCE_ID=$(ec2-run-instances ami-47a23a30 --instance-type t2.medium -g $AWS_GROUP --key $AWS_KEY --availability-zone eu-west-1b --region eu-west-1 | awk 'FNR == 2 {print $2}')
echo "Please wait until the new instance  $INSTANCE_ID is up and running"
echo ""

for i in {001..100}; do
    sleep 1
    printf "\r $i"

done

# SSH into the new instance

INSTANCE_IP=$(ec2-describe-instances $INSTANCE_ID  --region eu-west-1 | awk 'FNR == 2 {print $13}')

echo ""
echo "I'm now installing OpenEyes branch $branch on $INSTANCE_ID"
ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l ubuntu -i /Users/massimo/Documents/PEM/max-casa.pem $INSTANCE_IP << EOF
sudo -i
apt-get update
apt-get	upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install git chef -y
/usr/bin/git clone -b aws --recursive https://github.com/MassimoDanieli/oe_chef.git
mkdir /var/www
cd /var/www && git clone -b $ins_bra  https://github.com/openeyes/OpenEyes.git openeyes
cd /root/oe_chef
/usr/bin/chef-solo -c solo.rb -j oe.jason
EOF

echo ""
echo "OpenEyes $branch was successfully installed !!"
echo ""
echo "You can now tart using OpenEyes: http://$INSTANCE_IP"
echo ""
echo "Please DO NOT FORGET to terminate this instance \"ec2-terminate-instances $INSTANCE_ID\" !!!"
