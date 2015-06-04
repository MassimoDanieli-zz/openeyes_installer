#!/bin/bash
echo "Usage : openeyes_installer.sh BRANCH_NUMBER"
        echo ""
        echo "The available branches are:"
        echo ""
                BRANCH=$(git ls-remote --heads  git://github.com/openeyes/OpenEyes.git | awk -F"/" '{print substr($0, index($0, $3))}')
select ins_bra in $BRANCH
do
        echo "install $ins_bra "
        break
	default)  echo "sorry, not a valid option" && exit
done

echo ""
echo "I'm now installing OpenEyes branch $branch on $INSTANCE_ID"

<< EOF
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

IP='ifconfig eth0 | awk '/inet addr/{print substr($2,6)}'
echo ""
echo "OpenEyes $branch was successfully installed !!"
echo ""
echo "You can now start using OpenEyes: http://$IP"