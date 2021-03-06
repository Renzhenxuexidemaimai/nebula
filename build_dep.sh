#!/bin/bash
#
# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License,
# attached with Common Clause Condition 1.0, found in the LICENSES directory.
#
# step 1: ./build_dep.sh <C|U>   C: the user in China, U: the user in US
# step 2: source ~/.bashrc
#

DIR=/tmp/download
mkdir $DIR
trap "rm -fr $DIR" EXIT

url_addr=https://nebula-graph.oss-cn-hangzhou.aliyuncs.com/build-deb
if [[ $1 != C ]] && [[ $1 != U ]]; then
    echo "Usage: ${0} <C|U>  # C: the user in China, U: the user in US"
    exit -1
fi

[[ $1 == U ]] && url_addr=https://nebula-graph-us.oss-us-west-1.aliyuncs.com/build-deb/

# fedora
function fedora_install {
    echo "###### start install dep in fedora ######"
    sudo yum -y install autoconf \
        autoconf-archive \
        automake \
        bison \
        bzip2-devel \
        cmake \
        curl \
        gcc \
        gcc-c++ \
        java-1.8.0-openjdk \
        java-1.8.0-openjdk-devel \
        libstdc++-static \
        libstdc++-devel \
        libtool \
        make \
        maven \
        ncurses \
        ncurses-devel \
        perl \
        perl-WWW-Curl \
        python \
        readline \
        readline-devel \
        unzip \
        xz-devel \
        wget
    wget $url_addr/fedora.tar.gz
    tar xf fedora.tar.gz
    sudo rpm -ivh fedora/*.rpm
    wget $url_addr/vs-nebula-3rdparty.fc.x86_64.rpm
    sudo rpm -ivh vs-nebula-3rdparty.fc.x86_64.rpm
    echo "alias cmake='cmake -DNEBULA_GPERF_BIN_DIR=/opt/nebula/gperf/bin -DNEBULA_FLEX_ROOT=/opt/nebula/flex -DNEBULA_BOOST_ROOT=/opt/nebula/boost -DNEBULA_OPENSSL_ROOT=/opt/nebula/openssl -DNEBULA_KRB5_ROOT=/opt/nebula/krb5 -DNEBULA_LIBUNWIND_ROOT=/opt/nebula/libunwind'" >> ~/.bashrc
    return 0
}

# centos6
function centos6_install {
    echo "###### start install dep in centos6.5 ######"
    sudo yum -y install wget \
        libtool \
        autoconf \
        autoconf-archive \
        automake \
        perl-WWW-Curl \
        perl-YAML \
        perl-CGI \
        perl-DBI \
        perl-Pod-Simple \
        glibc-devel \
        ncurses-devel \
        readline-devel \
        maven \
        java-1.8.0-openjdk \
        unzip
    wget $url_addr/centos6.tar.gz
    tar xf centos6.tar.gz
    sudo rpm -ivh centos6/*.rpm

    wget $url_addr/vs-nebula-3rdparty.el6.x86_64.rpm
    sudo rpm -ivh vs-nebula-3rdparty.el6.x86_64.rpm
    echo "export PATH=/opt/nebula/autoconf/bin:/opt/nebula/automake/bin:/opt/nebula/libtool/bin:/opt/nebula/gettext/bin:/opt/nebula/flex/bin:/opt/nebula/binutils/bin:\$PATH" >> ~/.bashrc
    echo "export ACLOCAL_PATH=/opt/nebula/automake/share/aclocal-1.15:/opt/nebula/libtool/share/aclocal:/opt/nebula/autoconf-archive/share/aclocal" >> ~/.bashrc
    return 0
}

# centos7
function centos7_install {
    echo "###### start install dep in centos7.5 ######"
    sudo yum -y install wget \
        libtool \
        autoconf \
        autoconf-archive \
        automake \
        ncurses-devel \
        readline-devel \
        perl-WWW-Curl \
        maven \
        java-1.8.0-openjdk \
        unzip
    wget $url_addr/centos7.tar.gz
    tar xf centos7.tar.gz
    sudo rpm -ivh centos7/*.rpm

    wget $url_addr/vs-nebula-3rdparty.el7.x86_64.rpm
    sudo rpm -ivh vs-nebula-3rdparty.el7.x86_64.rpm

    return 0
}

# ubuntu1604
function ubuntu16_install {
    echo "###### start install dep in ubuntu16 ######"
    sudo apt-get -y install gcc-multilib \
        libtool \
        autoconf \
        autoconf-archive \
        automake \
        libncurses5-dev \
        libreadline-dev \
        python \
        maven \
        openjdk-8-jdk unzip
    wget $url_addr/ubuntu.tar.gz
    tar xf ubuntu.tar.gz
    sudo dpkg -i ubuntu/*.deb

    wget $url_addr/vs-nebula-3rdparty.ubuntu1604.amd64.deb
    sudo dpkg -i vs-nebula-3rdparty.ubuntu1604.amd64.deb

    return 0
}

# ubuntu1804
function ubuntu18_install {
    echo "###### start install dep in ubuntu18 ######"
    sudo apt-get -y install gcc-multilib \
        libtool \
        autoconf \
        autoconf-archive \
        automake \
        libncurses5-dev \
        libreadline-dev \
        python \
        maven \
        openjdk-8-jdk unzip
    wget $url_addr/ubuntu.tar.gz
    tar xf ubuntu.tar.gz
    sudo dpkg -i ubuntu/*.deb

    wget $url_addr/vs-nebula-3rdparty.ubuntu1804.amd64.deb
    sudo dpkg -i vs-nebula-3rdparty.ubuntu1804.amd64.deb

    return 0
}

function addAlias {
    echo "alias cmake='/opt/nebula/cmake/bin/cmake -DCMAKE_C_COMPILER=/opt/nebula/gcc/bin/gcc -DCMAKE_CXX_COMPILER=/opt/nebula/gcc/bin/g++ -DNEBULA_GPERF_BIN_DIR=/opt/nebula/gperf/bin -DNEBULA_FLEX_ROOT=/opt/nebula/flex -DNEBULA_BOOST_ROOT=/opt/nebula/boost -DNEBULA_OPENSSL_ROOT=/opt/nebula/openssl -DNEBULA_KRB5_ROOT=/opt/nebula/krb5 -DNEBULA_LIBUNWIND_ROOT=/opt/nebula/libunwind -DNEBULA_BISON_ROOT=/opt/nebula/bison'" >> ~/.bashrc
    echo "alias ctest='/opt/nebula/cmake/bin/ctest'" >> ~/.bashrc
    echo "export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:\$LIBRARY_PATH" >> ~/.bashrc
    return 0
}

# fedora:1, centos7:2, centos6:3, ubuntu18:4, ubuntu16:5
function getSystemVer {
    result=`cat /proc/version|grep fc`
    if [[ -n $result ]]; then
        return 1
    fi
    result=`cat /proc/version|grep el7`
    if [[ -n $result ]]; then
        return 2
    fi
    result=`cat /proc/version|grep el6`
    if [[ -n $result ]]; then
        return 3
    fi
    result=`cat /proc/version|grep ubuntu1~18`
    if [[ -n $result ]]; then
        return 4
    fi
    result=`cat /proc/version|grep ubuntu1~16`
    if [[ -n $result ]]; then
        return 5
    fi
    return 0
}

getSystemVer

version=$?

set -e

case $version in
    1)
        fedora_install
        ;;
    2)
        centos7_install
        addAlias
        ;;
    3)
        centos6_install
        addAlias
        ;;
    4)
        ubuntu18_install
        addAlias
        ;;
    5)
        ubuntu16_install
        addAlias
        ;;
    *)
        echo "unknown system"
        exit -1
        ;;
esac

echo "###### install succeed ######"
exit 0
