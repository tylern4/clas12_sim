#!/usr/bin/env bash

export CLEAN=false
export JLAB_ROOT=$PWD/jlab
export QTDIR=/usr/local/qt5

export JLAB_DOWNLOAD=https://www.jlab.org/12gev_phys/packages/sources
export JLAB_VERSION=devel
export JLAB_SOFTWARE=$JLAB_ROOT/$JLAB_VERSION
export OSRELEASE=ubuntu
export G4DATA_VERSION=10.04.p01

export CLHEP_VERSION=2.4.0.4
export GEANT4_VERSION=10.04.p01
export EVIO_VERSION=5.1
export XERCESC_VERSION=3.2.0
export CCDB_VERSION=devel
export MLIBRARY_VERSION=1.5
export SCONS_BM_VERSION=1.6
export BANKS_VERSION=devel
export GEMC_VERSION=devel
export JANA_VERSION=0.7.7p1

export CLHEP_BASE_DIR=$JLAB_SOFTWARE/clhep
export G4INSTALL=$JLAB_SOFTWARE/geant4
export EVIO=$JLAB_SOFTWARE/evio/$EVIO_VERSION
export MYSQL=$JLAB_SOFTWARE/mysql
export XERCESCROOT=$JLAB_SOFTWARE/xercesc
export CCDB_HOME=$JLAB_SOFTWARE/ccdb
export MLIBRARY=$JLAB_SOFTWARE/mlibrary
export GEMC=$JLAB_SOFTWARE/gemc
export JANA_HOME=$JLAB_SOFTWARE/jana
export QTDIR=/usr/include/x86_64-linux-gnu/qt5
export SCONS_BM=$JLAB_SOFTWARE/scons_bm
export PYTHONPATH=$PYTHONPATH:$SCONS_BM:$CCDB_HOME/python
export BANKS=$JLAB_SOFTWARE/banks/$BANKS_VERSION






export LD_LIBRARY_PATH=$CCDB_HOME/lib:$LD_LIBRARY_PATH
export PATH=$CCDB_HOME/bin:$PATH

mkdir -p $JLAB_SOFTWARE

download() {
  wget --no-check-certificate $JLAB_DOWNLOAD/$1
}

build_clhep(){
  if [ "$CLEAN" = true ]; then
    echo "Removing clhep"
    rm -rf $CLHEP_BASE_DIR
  fi

  if [ ! -f $JLAB_SOFTWARE/clhep/lib/libCLHEP.so ]; then
      mkdir -p $CLHEP_BASE_DIR
      echo "Building clhep"
      cd $CLHEP_BASE_DIR
      git clone https://gitlab.cern.ch/CLHEP/CLHEP.git github-source
      mkdir build
      cd build
      cmake -DCMAKE_INSTALL_PREFIX=$CLHEP_BASE_DIR $CLHEP_BASE_DIR/github-source
      make -j2
      make install
      rm -rf $CLHEP_BASE_DIR/github-source
  fi

  echo "Finishing CLHEP"
}

build_xercesc(){
  if [ "$CLEAN" = true ]; then
    echo "Removing xercesc"
    rm -rf $XERCESCROOT
  fi

  if [ ! -f $XERCESCROOT/lib/libxerces-c.so ]; then
      mkdir -p $XERCESCROOT
      echo "Building xercesc"
      cd $XERCESCROOT
      git clone https://github.com/apache/xerces-c.git github-source
      mkdir build
      cd build
      cmake -DCMAKE_INSTALL_PREFIX=$XERCESCROOT $XERCESCROOT/github-source
      make -j$(nproc)
      make install
      rm -rf $XERCESCROOT/github-source
  fi
  echo "Finishing xercesc"

}

build_geant4(){
  if [ "$CLEAN" = true ]; then
    echo "Removing geant4"
    rm -rf $G4INSTALL
  fi

  if [ ! -f $G4INSTALL/lib/libG4FR.so ]; then
      mkdir -p $G4INSTALL
      echo "Building geant4"
      cd $G4INSTALL
      git clone https://github.com/Geant4/geant4.git github-source
      mkdir build
      cd build
      cmake -DCMAKE_INSTALL_PREFIX=$G4INSTALL $G4INSTALL/github-source
      make -j$(nproc)
      make install
      rm -rf $G4INSTALL/github-source
  fi
  echo "Finishing geant4"

}

build_sconsscript(){
  if [ "$CLEAN" = true ]; then
    echo "Removing scons bm"
    rm -rf $SCONS_BM
  fi

  if [ ! -f $SCONS_BM/init_env.py ]; then
      mkdir -p $SCONS_BM
      echo "Building scons bm"
      cd $SCONS_BM
      download scons_bm/scons_bm_$SCONS_BM_VERSION.tar.gz
      tar -xvf scons_bm_$SCONS_BM_VERSION.tar.gz --strip-components 1
      rm -rf scons_bm_$SCONS_BM_VERSION.tar.gz
  fi
  echo "Finishing scons bm"

}

build_mlibrary(){
  if [ "$CLEAN" = true ]; then
    echo "Removing mlibrary"
    rm -rf $MLIBRARY
  fi

  if [ ! -f $MLIBRARY/lib/libxerces-c.so ]; then
      mkdir -p $MLIBRARY
      echo "Building mlibrary"
      cd $MLIBRARY
      git clone https://github.com/gemc/mlibrary.git github-source
      cd $MLIBRARY/github-source
      scons -j$(nproc)
      scons install
      rm -rf $MLIBRARY/github-source
  fi
  echo "Finishing mlibrary"
}

mkcmake(){
  cat>CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.2)
project(evio_5_1)

include_directories(src/libsrc src/libsrc++)

set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} -std=c++11")

set(C_SOURCE_FILES
    src/libsrc/evio.h
    src/libsrc/msinttypes.h

    src/libsrc/evio.c
    src/libsrc/eviofmt.c
    src/libsrc/eviofmtdump.c
    src/libsrc/eviofmtswap.c
    src/libsrc/evioswap.c)

set(CXX_SOURCE_FILES
    src/libsrc++/evioBankIndex.hxx
    src/libsrc++/evioBufferChannel.hxx
    src/libsrc++/evioFileChannel.hxx
    src/libsrc++/evioSocketChannel.hxx
    src/libsrc++/evioChannel.hxx
    src/libsrc++/evioDictionary.hxx
    src/libsrc++/evioException.hxx
    src/libsrc++/evioTypedefs.hxx
    src/libsrc++/evioUtil.hxx
    src/libsrc++/evioUtilTemplates.hxx

    src/libsrc++/evioBankIndex.cc
    src/libsrc++/evioBufferChannel.cc
    src/libsrc++/evioFileChannel.cc
    src/libsrc++/evioSocketChannel.cc
    src/libsrc++/evioDictionary.cc
    src/libsrc++/evioException.cc
    src/libsrc++/evioUtil.cc)

    add_library(evio \${C_SOURCE_FILES})
    add_library(evioxx \${CXX_SOURCE_FILES})
EOF
}

build_evio(){
  if [ "$CLEAN" = true ]; then
    echo "Removing evio"
    rm -rf $EVIO
  fi

  if [ ! -f $EVIO/lib/libevio.a ]; then
      mkdir -p $EVIO
      echo "Building evio"
      cd $EVIO
      rm -rf *.tar.*
      download evio/evio-$EVIO_VERSION.tar.gz
      tar -xvf evio-$EVIO_VERSION.tar.gz --strip-components 1
      #mv $EVIO_VERSION/* .
      mkdir lib
      mkcmake
      mkdir build
      cd build
      cmake ..
      make -j$(nproc)
      mv lib* ../lib
  fi
  echo "Finishing evio"
}



build_mysql(){
  if [ "$CLEAN" = true ]; then
    echo "Removing mysql"
    rm -rf $MYSQL
  fi

  if [ ! -f $MYSQL/lib/libmysqlclient.a ]; then
      echo "linking mysql"
      mkdir -p $MYSQL/include
      mkdir -p $MYSQL/lib
      ln -s /usr/include/mysql/* $MYSQL/include/
      ln -s /usr/lib/x86_64-linux-gnu/libmysql* $MYSQL/lib/
  fi
  echo "Finishing mysql"
}



build_ccdb(){
  if [ "$CLEAN" = true ]; then
    echo "Removing ccdb"
    rm -rf $CCDB_HOME
  fi

  if [ ! -f $CCDB_HOME/lib/libccdb.a ]; then
      cd $JLAB_SOFTWARE
      echo "Building ccdb"
      git clone https://github.com/JeffersonLab/ccdb.git $CCDB_HOME
      cd $CCDB_HOME
      scons -j$(nproc)
      scons install
  fi
  echo "Finishing ccdb"
}



build_gemc(){
  if [ "$CLEAN" = true ]; then
    echo "Removing gemc"
    rm -rf $GEMC
  fi

  if [ ! -f $GEMC/lib/libgemc.a ]; then
      echo "Building gemc"
      git clone https://github.com/gemc/source.git $GEMC
      cd $GEMC
      scons -j$(nproc)
  fi
  echo "Finishing gemc"
}


download_fields(){
  if [ "$CLEAN" = true ]; then
    echo "Removing fields"
    rm -rf $JLAB_ROOT/noarch/data
  fi

  if [ ! -f $JLAB_ROOT/noarch/data/clas12SolenoidFieldMap.dat ]; then
    echo "Downlading fields"
    mkdir -p $JLAB_ROOT/noarch/data
    cd $JLAB_ROOT/noarch/data
    wget -N http://clasweb.jlab.org/12gev/field_maps/clas12SolenoidFieldMap.dat
    wget -N http://clasweb.jlab.org/12gev/field_maps/clas12TorusOriginalMap.dat
  fi
  echo "Finishing fields"
}

build_banks(){
  if [ "$CLEAN" = true ]; then
    echo "Removing banks"
    rm -rf $BANKS
  fi

  if [ ! -f $BANKS/lib/libbanks.a ]; then
      mkdir -p $BANKS
      echo "Building banks"
      cd $BANKS
      download banks/banks_$BANKS_VERSION.tar.gz
      tar -xvf banks_$BANKS_VERSION.tar.gz --strip-components 1
      scons -j$(nproc)
  fi
  echo "Finishing banks"
}

build_jana(){
  if [ "$CLEAN" = true ]; then
    echo "Removing jana"
    rm -rf $JANA_HOME
  fi

  if [ ! -f $JANA_HOME/lib/libjana.a ]; then
      echo "Building jana"
      git clone https://github.com/JeffersonLab/JANA.git $JLAB_SOFTWARE/jana
      cd $JANA_HOME
      scons -j$(nproc)
  fi
  echo "Finishing jana"
}




#Working

build_clhep
build_xercesc
build_geant4
build_sconsscript
build_evio
build_mysql
build_ccdb
download_fields
build_jana

#Not Working because of qt5......
###build_mlibrary
###build_gemc
###build_banks
