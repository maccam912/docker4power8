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
echo "Building GCC. This can take VERY long. Like 2 hours long."
sleep 5
mkdir build-gcc
cd build-gcc
sudo apt-get install -y libgmp-dev libmpfr-dev libmpc-dev flex bison
../gcc/configure --enable-languages=go --disable-multilib --prefix=/opt/gcc-trunk
make -j200 # if using the big instance
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

diff --git a/daemon/daemon.go b/daemon/daemon.go
index 235788c..b75a94e 100644
--- a/daemon/daemon.go
+++ b/daemon/daemon.go
@@ -1104,9 +1104,9 @@ func (daemon *Daemon) ImageGetCached(imgID string, config *runconfig.Config) (*i
  
 func checkKernelAndArch() error {
    // Check for unsupported architectures
-   if runtime.GOARCH != "amd64" {
-       return fmt.Errorf("The Docker runtime currently only supports amd64 (not %s). This will change in the future. Aborting.", runtime.GOARCH)
-   }
+   //if runtime.GOARCH != "amd64" {
+   //  return fmt.Errorf("The Docker runtime currently only supports amd64 (not %s). This will change in the future. Aborting.", runtime.GOARCH)
+   //}
    // Check for unsupported kernel versions
    // FIXME: it would be cleaner to not test for specific versions, but rather
    // test for specific functionalities.
    
diff --git a/vendor/src/github.com/kr/pty/pty_linux.go b/vendor/src/github.com/kr/pty/pty_linux.go
index 6e5a042..8525f80 100644
--- a/vendor/src/github.com/kr/pty/pty_linux.go
+++ b/vendor/src/github.com/kr/pty/pty_linux.go
@@ -7,6 +7,11 @@ import (
    "unsafe"
 )
  
+type (
+        _C_int  int32
+        _C_uint uint32
+)
+
 var (
    ioctl_TIOCGPTN   = _IOR('T', 0x30, unsafe.Sizeof(_C_uint(0))) /* Get Pty Number (of pty-mux device) */
    ioctl_TIOCSPTLCK = _IOW('T', 0x31, unsafe.Sizeof(_C_int(0)))  /* Lock/unlock Pty */

diff --git a/hack/make/binary b/hack/make/binary
index b97069a..f5398ae 100755
--- a/hack/make/binary
+++ b/hack/make/binary
@@ -6,9 +6,8 @@ DEST=$1
 go build \
    -o "$DEST/docker-$VERSION" \
    "${BUILDFLAGS[@]}" \
-   -ldflags "
-       $LDFLAGS
-       $LDFLAGS_STATIC_DOCKER
+   -gccgoflags "
+       -static-libgo -static-libgcc
    " \
    ./docker
 echo "Created binary: $DEST/docker-$VERSION"
 
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
echo "Done?!?! Test it out!"
