echo "While many of these are using sudo, make sure you are able to sudo. If not, this might fail spectacularly."
sleep 30

sudo locale-gen
echo "Updating"
sleep 2
sudo apt-get -y update
sudo apt-get -y install subversion mercurial git build-essential gccgo-go

cd
echo "Grabbing GCC"
sleep 2
echo "Patience is a virtue. Give this some time."
sleep 5
svn checkout svn://gcc.gnu.org/svn/gcc/trunk gcc

cd
echo "grabbing go"
sleep 2
hg clone -u release https://code.google.com/p/go
cd go
hg update dev.power64

cd
cp go/src/debug/elf/file.go gcc/libgo/go/debug/elf/
cp go/src/debug/elf/elf.go gcc/libgo/go/debug/elf/

cd
echo "Building GCC. This can take VERY long. Like 2 hours long."
sleep 5
mkdir build-gcc
cd build-gcc
sudo apt-get install -y libgmp-dev libmpfr-dev libmpc-dev flex bison
../gcc/configure --enable-languages=go --disable-multilib --prefix=/opt/gcc-trunk
make -j64 # j200 if using the big instance
sudo make install

export PATH=/opt/gcc-trunk/bin:$PATH
echo "/opt/gcc-trunk/lib64" | sudo tee /etc/ld.so.conf.d/gcc-trunk.conf
sudo ldconfig

cd go/src/cmd/cgo
echo "Build go"
sleep 2
go build

sudo mkdir -p /usr/pkg/tool/linux_ppc64
sudo mkdir -p /usr/src/cmd/cgo
sudo cp cgo /usr/pkg/tool/linux_ppc64/cgo
sudo cp * /usr/src/cmd/cgo

export CGO_ENABLED=1

cd
echo "Get docker source"
sleep 2
git clone https://github.com/docker/docker.git
cd docker
git checkout v1.3.1

sudo mkdir -p /go/src/github.com/docker/
sudo ln -s $HOME/docker /go/src/github.com/docker/docker
export PATH=/opt/gcc-trunk/bin/:$PATH
export GOPATH=/go:/go/src/github.com/docker/docker/vendor

echo "It might break here."
sleep 2
patch -p0 -i ./patch1.patch
    
patch -p0 -i ./patch2.patch

patch -p0 -i ./patch3.patch
 
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
