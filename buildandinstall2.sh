 
 echo "Install dependencies"
 sleep 2
 sudo apt-get install -y \
        aufs-tools \
        automake \
        btrfs-tools \
        build-essential \
        curl \
        dpkg-sig \
        git \
        iptables \
        libapparmor-dev \
        libcap-dev \
        libsqlite3-dev \
        lxc=1.0* \
        mercurial \
        parallel \
        reprepro \
        ruby1.9.1 \
        ruby1.9.1-dev \
        s3cmd=1.1.0* \
        --no-install-recommends
        
cd
git clone --no-checkout https://git.fedorahosted.org/git/lvm2.git
cd lvm2
git checkout -q v2_02_103

mkdir -p autoconf
wget 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' -O autoconf/config.guess

./configure --enable-static_link
make device-mapper
sudo make install_device-mapper

cd
echo "With a little help from the computer gods, this is the last step."
sleep 2
cd docker
./hack/make.sh binary
sudo cp /home/admin/docker/bundles/1.3.1/binary/docker-1.3.1 /usr/bin/docker
echo "Done?!?! Test it out! /home/admin/docker/bundles/"
