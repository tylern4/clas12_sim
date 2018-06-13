#!/usr/bin/env bash

export RED='\033[0;31m'
export BLUE='\033[0;34m'
export GREEN='\033[0;32m'
export DEF='\033[0m'


export CLEAN=false
export JLAB_ROOT=$PWD/jlab
export JLAB_VERSION=devel
export JLAB_SOFTWARE=$JLAB_ROOT/$JLAB_VERSION
export BASE_URL=https://www.jlab.org/12gev_phys/packages/sources
export QTDIR=/usr/include/x86_64-linux-gnu/qt5
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig

export CLHEP_VERSION=2.4.0.4
export GEANT4_VERSION=10.04.p01
export EVIO_VERSION=5.1
export XERCESC_VERSION=3.2.0
export CCDB_VERSION=devel
export MLIBRARY_VERSION=1.5
export SCONS_BM_VERSION=devel
export BANKS_VERSION=devel
export GEMC_VERSION=2.6
export JANA_VERSION=0.7.7p1

export CLHEP_BASE_DIR=$JLAB_SOFTWARE/clhep
export CADMESH=$JLAB_SOFTWARE/cadmesh
export G4INSTALL=$JLAB_SOFTWARE/geant4
export EVIO=$JLAB_SOFTWARE/evio
export MYSQL=$JLAB_SOFTWARE/mysql
export XERCESCROOT=$JLAB_SOFTWARE/xercesc
export CCDB_HOME=$JLAB_SOFTWARE/CCDB
export MLIBRARY=$JLAB_SOFTWARE/mlibrary
export GEMC=$JLAB_SOFTWARE/gemc
export JANA_HOME=$JLAB_SOFTWARE/jana
export SCONS_BM=$JLAB_SOFTWARE/scons_bm
export BANKS=$JLAB_SOFTWARE/banks
export PYTHONPATH=$PYTHONPATH:$SCONS_BM
export SCONSFLAGS=--site-dir=$SCONS_BM

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CCDB_HOME/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CADMESH/build/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CLHEP_BASE_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$EVIO/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$G4INSTALL/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GEMC/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MLIBRARY/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MYSQL/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$XERCESCROOT/lib

export PATH=$PATH:$GEMC

#CERN ROOT
export ROOTSYS=$JLAB_SOFTWARE/root/6-08-04
export PATH=$ROOTSYS/bin:$PATH
export PYTHONDIR=$ROOTSYS
export LD_LIBRARY_PATH=$ROOTSYS/lib:$PYTHONDIR/lib:$ROOTSYS/bindings/pyroot:$LD_LIBRARY_PATH
export PYTHONPATH=$ROOTSYS/lib:$PYTHONPATH:$ROOTSYS/bindings/pyroot

mkdir -p $JLAB_SOFTWARE

download() {
  wget --no-check-certificate $JLAB_DOWNLOAD/$1
}

build_clhep(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}clhep${DEF}"
    rm -rf $CLHEP_BASE_DIR
  fi

  if [ ! -f $JLAB_SOFTWARE/clhep/lib/libCLHEP.so ]; then
      mkdir -p $CLHEP_BASE_DIR
      echo -e "${BLUE}Building clhep${DEF}"
      cd $CLHEP_BASE_DIR
      git clone https://gitlab.cern.ch/CLHEP/CLHEP.git github-source
      mkdir build
      cd build
      cmake -DCMAKE_INSTALL_PREFIX=$CLHEP_BASE_DIR $CLHEP_BASE_DIR/github-source
      make -j2
      make install
      rm -rf $CLHEP_BASE_DIR/github-source
  fi

  echo -e "${GREEN}Finishing CLHEP${DEF}"
}

build_xercesc(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}xercesc${DEF}"
    rm -rf $XERCESCROOT
  fi

  if [ ! -f $XERCESCROOT/lib/libxerces-c.so ]; then
      mkdir -p $XERCESCROOT
      echo -e "${BLUE}Building xercesc${DEF}"
      cd $XERCESCROOT
      git clone https://github.com/apache/xerces-c.git github-source
      mkdir build
      cd build
      cmake -DCMAKE_INSTALL_PREFIX=$XERCESCROOT $XERCESCROOT/github-source
      make -j$(nproc)
      make install
      rm -rf $XERCESCROOT/github-source
  fi
  echo -e "${GREEN}Finishing xercesc${DEF}"

}

build_geant4(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}geant4${DEF}"
    rm -rf $G4INSTALL
  fi

  if [ ! -f $G4INSTALL/lib/libG4FR.so ]; then
      mkdir -p $G4INSTALL
      echo -e "${BLUE}Building geant4${DEF}"
      cd $G4INSTALL
      git clone https://github.com/Geant4/geant4.git github-source
      mkdir build
      cd build
      cmake -DGEANT4_USE_OPENGL_X11=ON -DCMAKE_INSTALL_PREFIX=$G4INSTALL \
                -DGEANT4_USE_GDML=ON \
                -DXERCESC_ROOT_DIR=$XERCESCROOT \
                -DGEANT4_USE_QT=ON \
                -DCMAKE_INSTALL_DATAROOTDIR=$G4INSTALL/data \
                -DCLHEP_ROOT_DIR=$CLHEP_BASE_DIR \
                -DGEANT4_INSTALL_DATA=$DATA \
                -DGEANT4_BUILD_EXAMPLES=OFF \
                -DCMAKE_CXX_FLAGS="-W -Wall -pedantic -Wno-non-virtual-dtor -Wno-long-long -Wwrite-strings -Wpointer-arith -Woverloaded-virtual -pipe" \
                $G4INSTALL/github-source
      make -j$(nproc)
      make install
      rm -rf $G4INSTALL/github-source
  fi
  echo -e "${GREEN}Finishing geant4${DEF}"

}

build_sconsscript(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}scons bm${DEF}"
    rm -rf $SCONS_BM
  fi

  if [ ! -f $SCONS_BM/init_env.py ]; then
      echo -e "${BLUE}Building scons bm${DEF}"
      git clone https://github.com/maureeungaro/scons_bm.git $SCONS_BM
  fi
  echo -e "${GREEN}Finishing scons bm${DEF}"

}

build_mlibrary(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}mlibrary${DEF}"
    rm -rf $MLIBRARY
  fi

  if [ ! -f $MLIBRARY/lib/libxerces-c.so ]; then
      mkdir -p $MLIBRARY
      echo -e "${BLUE}Building mlibrary${DEF}"
      cd $MLIBRARY
      git clone https://github.com/gemc/mlibrary.git github-source
      cd $MLIBRARY/github-source
      scons -j$(nproc)
      scons install
      rm -rf $MLIBRARY/github-source
  fi
  echo -e "${GREEN}Finishing mlibrary${DEF}"
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
    echo -e "${RED}Removing ${BLUE}evio${DEF}"
    rm -rf $EVIO
  fi

  if [ ! -f $EVIO/lib/libevio.a ]; then
      mkdir -p $EVIO
      echo -e "${BLUE}Building evio${DEF}"
      cd $EVIO
      wget --no-check-certificate https://www.jlab.org/12gev_phys/packages/sources/evio/evio-$EVIO_VERSION.tar.gz
      tar -xvf evio-$EVIO_VERSION.tar.gz --strip-components 1
      scons -j$(nproc)
  fi
  echo -e "${GREEN}Finishing evio${DEF}"
}



build_mysql(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}mysql${DEF}"
    rm -rf $MYSQL
  fi

  if [ ! -f $MYSQL/lib/libmysqlclient.a ]; then
      echo "linking mysql"
      mkdir -p $MYSQL/include
      mkdir -p $MYSQL/lib
      ln -s /usr/include/mysql/* $MYSQL/include/
      ln -s /usr/lib/x86_64-linux-gnu/libmysql* $MYSQL/lib/
  fi
  echo -e "${GREEN}Finishing mysql${DEF}"
}



build_ccdb(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}ccdb${DEF}"
    rm -rf $CCDB_HOME
  fi

  if [ ! -f $CCDB_HOME/lib/libccdb.a ]; then
      cd $JLAB_SOFTWARE
      echo -e "${BLUE}Building ccdb${DEF}"
      git clone https://github.com/JeffersonLab/ccdb.git $CCDB_HOME
      cd $CCDB_HOME
      scons -j$(nproc)
  fi
  echo -e "${GREEN}Finishing ccdb${DEF}"
}



build_gemc(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}gemc${DEF}"
    rm -rf $GEMC
  fi

  if [ ! -f $GEMC/lib/libgemc.a ]; then
      echo -e "${BLUE}Building gemc${DEF}"
      git clone https://github.com/gemc/source.git $GEMC
      cd $GEMC
      scons -j$(nproc)
  fi
  echo -e "${GREEN}Finishing gemc${DEF}"
}


download_fields(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}fields${DEF}"
    rm -rf $JLAB_ROOT/noarch/data
  fi

  if [ ! -f $JLAB_ROOT/noarch/data/clas12SolenoidFieldMap.dat ]; then
    echo "Downlading fields"
    mkdir -p $JLAB_ROOT/noarch/data
    cd $JLAB_ROOT/noarch/data
    wget -N http://clasweb.jlab.org/12gev/field_maps/clas12SolenoidFieldMap.dat
    wget -N http://clasweb.jlab.org/12gev/field_maps/clas12TorusOriginalMap.dat
  fi
  echo -e "${GREEN}Finishing fields${DEF}"
}

build_banks(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}banks${DEF}"
    rm -rf $BANKS
  fi

  if [ ! -f $BANKS/lib/libbanks.a ]; then
      mkdir -p $BANKS
      echo -e "${BLUE}Building banks${DEF}"
      cd $BANKS
      download banks/banks_$BANKS_VERSION.tar.gz
      tar -xvf banks_$BANKS_VERSION.tar.gz --strip-components 1
      scons -j$(nproc)
  fi
  echo -e "${GREEN}Finishing banks${DEF}"
}

build_jana(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}jana${DEF}"
    rm -rf $JANA_HOME
  fi

  if [ ! -f $JANA_HOME/lib/libjana.a ]; then
      echo -e "${BLUE}Building jana${DEF}"
      git clone https://github.com/JeffersonLab/JANA.git $JLAB_SOFTWARE/jana
      cd $JANA_HOME
      scons -j$(nproc)
  fi
  echo -e "${GREEN}Finishing jana${DEF}"
}

build_cadmesh_mlibrary(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}cadmesh and mlibrary${DEF}"
    rm -rf $CADMESH
    rm -rf $MLIBRARY
  fi

  if [ ! -f $MLIBRARY/lib/libcadmesh.so ]; then
    echo -e "${BLUE}Building cadmesh${DEF}"
    rm -rf $CADMESH
    rm -rf $MLIBRARY
    git clone -b v1.1 https://github.com/christopherpoole/CADMesh.git  $CADMESH/github-source
    git clone https://github.com/gemc/mlibrary.git $MLIBRARY
    mkdir -p $CADMESH/build
    cd $CADMESH/build
    cmake $CADMESH/github-source -DCMAKE_INSTALL_PREFIX=$MLIBRARY/cadmesh -DCMAKE_CXX_FLAGS=-fPIC -DCMAKE_PREFIX_PATH=$G4INSTALL
    make -j$(nproc)
    make install
    rm -rf $CADMESH/github-source
    echo -e "${BLUE}Building mlibrary${DEF}"
    cd $MLIBRARY
    scons -j$(nproc) OPT=1
    cp -r $MLIBRARY/cadmesh/lib/* $MLIBRARY/lib
    cp -r $MLIBRARY/cadmesh/include/* $MLIBRARY/include
  fi
  echo -e "${GREEN}Finishing cadmesh and mlibrary${DEF}"
}

build_gemc(){
  if [ "$CLEAN" = true ]; then
    echo -e "${RED}Removing ${BLUE}gemc${DEF}"
    rm -rf $GEMC
  fi

  if [ ! -f $GEMC/gemc ]; then
      echo -e "${BLUE}Building gemc${DEF}"
      mkdir -p $GEMC
      cd $GEMC
      curl -o gemc-$GEMC_VERSION.tar.gz $BASE_URL/gemc/gemc-$GEMC_VERSION.tar.gz
      tar -xvf gemc-$GEMC_VERSION.tar.gz --strip-components 1
      rm -rf gemc-$GEMC_VERSION.tar.gz
      scons OPT=1 -j$(nproc)
  fi
  echo -e "${GREEN}Finishing gemc${DEF}"
}

#Working

build_clhep
build_xercesc
build_geant4
build_sconsscript
build_evio
build_mysql
build_ccdb
build_cadmesh_mlibrary
build_gemc
download_fields





## mlibrary




#Not Working because of qt5......
###build_mlibrary
###build_gemc
###build_banks
