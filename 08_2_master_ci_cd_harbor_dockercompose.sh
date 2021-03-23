HARBORDC=./cicd/harbordc
mkdir -p $HARBORDC

wget -O $HARBORDC/harbor-online-installer.tgz https://github.com/goharbor/harbor/releases/download/v2.1.4/harbor-online-installer-v2.1.4.tgz
tar xvzf $HARBORDC/harbor-online-installer.tgz -C $HARBORDC
mv $HARBORDC/harbor/* $HARBORDC && rm -rf $HARBORDC/harbor
cp $HARBORDC/harbor.yml.tmpl $HARBORDC/harbor.yml

#아래 값 조정
# hostname, key/cert path..

$HARBORDC/prepare
$HARBORDC/install.sh