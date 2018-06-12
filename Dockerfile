#FROM tylern4/gemc-base:latest
FROM ubuntu:17.10
ENV TERM xterm-256color

ENV JLAB_ROOT /opt/jlab_software
ENV JLAB_VERSION devel
ENV JLAB_SOFTWARE $JLAB_ROOT/$JLAB_VERSION
ENV BASE_URL https://www.jlab.org/12gev_phys/packages/sources
RUN mkdir -p $JLAB_SOFTWARE

ENV QTDIR /usr/include/x86_64-linux-gnu/qt5

ENV G4DATA_VERSION devel
ENV CLHEP_VERSION devel
ENV GEANT4_VERSION devel
ENV EVIO_VERSION devel
ENV XERCESC_VERSION devel
ENV CCDB_VERSION devel
ENV MLIBRARY_VERSION devel
ENV SCONS_BM_VERSION devel
ENV BANKS_VERSION devel
ENV GEMC_VERSION devel
ENV JANA_VERSION devel

ENV CLHEP_BASE_DIR $JLAB_SOFTWARE/clhep
ENV G4INSTALL $JLAB_SOFTWARE/geant4
ENV EVIO $JLAB_SOFTWARE/evio
ENV MYSQL $JLAB_SOFTWARE/mysql
ENV XERCESCROOT $JLAB_SOFTWARE/xercesc
ENV CCDB_HOME $JLAB_SOFTWARE/ccdb
ENV MLIBRARY $JLAB_SOFTWARE/mlibrary
ENV GEMC $JLAB_SOFTWARE/gemc
ENV JANA_HOME $JLAB_SOFTWARE/jana
ENV SCONS_BM $JLAB_SOFTWARE/scons_bm
ENV PYTHONPATH $PYTHONPATH:$SCONS_BM
ENV BANKS $JLAB_SOFTWARE/banks/$BANKS_VERSION

RUN apt-get update -y \
    && apt-get -y install qt5-default qt5-qmake zsh perl git dpkg-dev cmake g++ gcc \
      binutils libx11-dev libxpm-dev \
      libxft-dev libxext-dev gfortran libssl-dev libpcre3-dev \
      xlibmesa-glu-dev libglew1.5-dev libftgl-dev \
      libmysqlclient-dev libfftw3-dev libcfitsio-dev \
      graphviz-dev libavahi-compat-libdnssd-dev \
      libldap2-dev python-dev libxml2-dev libkrb5-dev \
      libgsl0-dev python-pip curl wget python-tk \
      scons libxmu-dev libx11-dev openjdk-8-jdk \
      freeglut3-dev libmotif-dev tk-dev libxi-dev tcsh csh bc \
    && rm -rf /var/lib/apt/lists/*

## ROOT
ENV ROOTV_DOT 6.08.04
ENV ROOTV_SLASH 6-08-04
ENV ROOTSYS $JLAB_SOFTWARE/root/$ROOTV_DOT

RUN curl -o v$ROOTV_SLASH.tar.gz https://codeload.github.com/root-project/root/tar.gz/v$ROOTV_SLASH \
    && tar -zxpvf v$ROOTV_SLASH.tar.gz \
    && rm -rf v$ROOTV_SLASH.tar.gz \
    && cd root-$ROOTV_SLASH \
    && mkdir compile && cd compile \
    && cmake -DCMAKE_INSTALL_PREFIX=$ROOTSYS -DCMAKE_CXX_FLAGS=-fPIC \
    -Droofit=ON -Dminuit2=ON -Dpython=ON .. \
    && make -j$(nproc) && make install \
    && rm -rf $JLAB_SOFTWARE/root/root-$ROOTV_SLASH

## scons
ENV SCONS_BM_VERSION devel
ENV SCONSFLAGS --site-dir=$JLAB_ROOT/$JLAB_VERSION/scons_bm/$SCONS_BM_VERSION

RUN rm -rf $JLAB_ROOT/$JLAB_VERSION/scons_bm/$SCONS_BM_VERSION \
    && mkdir -p $JLAB_ROOT/$JLAB_VERSION/scons_bm/ \
    && cd $JLAB_ROOT/$JLAB_VERSION/scons_bm/ \
    && curl -o scons_bm-$SCONS_BM_VERSION.tar.gz $BASE_URL/scons_bm/scons_bm-$SCONS_BM_VERSION.tar.gz \
    && tar -zxpvf scons_bm-$SCONS_BM_VERSION.tar.gz \
    && rm -rf scons_bm-$SCONS_BM_VERSION.tar.gz

##CLHEP
RUN mkdir -p $CLHEP_BASE_DIR \
    && cd $CLHEP_BASE_DIR \
    && git clone https://gitlab.cern.ch/CLHEP/CLHEP.git github-source \
    && mkdir build && cd build \
  	&& cmake -DCMAKE_INSTALL_PREFIX=$CLHEP_BASE_DIR -DCMAKE_CXX_FLAGS=-fPIC $CLHEP_BASE_DIR/github-source \
    && make -j$(nproc) \
    && make install \
    && rm -rf $CLHEP_BASE_DIR/github-source

## xercesc
RUN mkdir -p $XERCESCROOT \
    && cd $XERCESCROOT \
    && git clone https://github.com/apache/xerces-c.git github-source \
    && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=$XERCESCROOT $XERCESCROOT/github-source \
    && make -j$(nproc) \
    && make install \
    && rm -rf $XERCESCROOT/github-source

## geant4
#              -DQT_QMAKE_EXECUTABLE=$QTDIR/bin/qmake \
RUN mkdir -p $G4INSTALL \
    && cd $G4INSTALL \
    && git clone https://github.com/Geant4/geant4.git $G4INSTALL/github-source \
    && mkdir -p $G4INSTALL/build \
    && cd $G4INSTALL/build \
    && cmake -DGEANT4_USE_OPENGL_X11=ON -DCMAKE_INSTALL_PREFIX=$G4INSTALL \
              -DGEANT4_USE_GDML=ON \
              -DXERCESC_ROOT_DIR=$XERCESCROOT \
              -DGEANT4_USE_QT=ON \
              -DCMAKE_INSTALL_DATAROOTDIR=$G4INSTALL/data \
              -DCLHEP_ROOT_DIR=$CLHEP_BASE_DIR \
              -DGEANT4_INSTALL_DATA=$DATA \
              -DGEANT4_BUILD_EXAMPLES=OFF \
              -DCMAKE_CXX_FLAGS="-W -Wall -pedantic -Wno-non-virtual-dtor -Wno-long-long -Wwrite-strings -Wpointer-arith -Woverloaded-virtual -pipe" \
              $G4INSTALL/github-source \
    && make -j$(nproc) \
    && make install \
    && rm -rf $G4INSTALL/github-source

## EVIO
ENV EVIO_VERSION 5.1
RUN mkdir -p $EVIO && cd $EVIO \
    && curl -o evio-$EVIO_VERSION.tar.gz $BASE_URL/evio/evio-$EVIO_VERSION.tar.gz \
    && tar -xvf evio-$EVIO_VERSION.tar.gz --strip-components 1

COPY CMakeLists_evio.txt $EVIO/CMakeLists.txt

RUN mkdir -p $EVIO/build && cd $EVIO/build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=$EVIO \
    && make -j$(nproc) \
    && mkdir $EVIO/lib \
    && mv lib* $EVIO/lib

## mysql
ENV MYSQL $JLAB_SOFTWARE/mysql
ENV MYSQBIN $MYSQL/bin
ENV MYSQINC $MYSQL/include
ENV MYSQLIB $MYSQL/lib
ENV MYSQLINC $MYSQL/include
ENV MYSQL_INCLUDE_PATH $MYSQL/include
ENV MYSQL_LIB_PATH $MYSQL/lib

RUN mkdir -p $JLAB_SOFTWARE/mysql \
    && ln -sfn /usr/lib/x86_64-linux-gnu $JLAB_SOFTWARE/mysql/lib \
    && ln -sfn /usr/include/mysql $JLAB_SOFTWARE/mysql/include

## CCDB
RUN git clone https://github.com/JeffersonLab/ccdb.git $CCDB_HOME \
    && cd $CCDB_HOME \
    && scons -j$(nproc)

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CCDB_HOME/lib
ENV PATH $PATH:$CCDB_HOME/bin
ENV PYTHONPATH $PYTHONPATH:$CCDB_HOME/python

## mlibrary
RUN mkdir -p $MLIBRARY && cd $MLIBRARY \
    && git clone https://github.com/gemc/mlibrary.git github-source
COPY CMakeLists_mlibrary.txt $MLIBRARY/github-source/CMakeLists.txt
RUN cd $MLIBRARY/github-source \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=$MLIBRARY \
    && make -j$(nproc) \
    && make install && mv $MLIBRARY/include/*/* $MLIBRARY/include/

ENV CADMESH $JLAB_SOFTWARE/cadmesh
RUN git clone -b v1.1 https://github.com/christopherpoole/CADMesh.git  $CADMESH/github-source \
    && mkdir -p $CADMESH/build && cd $CADMESH/build \
    && cmake $CADMESH/github-source -DCMAKE_CXX_FLAGS=-fPIC -DCMAKE_INSTALL_PREFIX:PATH=$CADMESH -DCMAKE_PREFIX_PATH=$G4INSTALL \
    && make -j$(nproc) \
    && make install

#RUN cd $MLIBRARY \
#    && git clone https://github.com/christopherpoole/CADMesh.git cadmesh-source \
#    && mkdir cadmeshBuild \
#    && cd cadmeshBuild \
#    && cmake ../cadmesh-source -DCMAKE_CXX_FLAGS=-fPIC -DCMAKE_INSTALL_PREFIX:PATH=$MLIBRARY -DCMAKE_PREFIX_PATH=$JLAB_SOFTWARE/geant4/$GEANT4_VERSION \
#    && make \
#    && make install

#RUN mkdir -p $JLAB_SOFTWARE/mlibrary \
#    && cd $JLAB_SOFTWARE/mlibrary \
#    && curl -o mlibrary-$MLIBRARY_VERSION.tar.gz $BASE_URL/mlibrary/mlibrary-$MLIBRARY_VERSION.tar.gz \
#    && tar -zxpvf mlibrary-$MLIBRARY_VERSION.tar.gz \
#    && rm -rf mlibrary-$MLIBRARY_VERSION.tar.gz \
#    && cd $JLAB_SOFTWARE/mlibrary/$MLIBRARY_VERSION \
#    && scons -j$(nproc) OPT=1 -fPIC \
    #&& git clone https://github.com/christopherpoole/CADMesh.git cadmesh_git \
#    && mkdir cadmeshBuild \
#    && cd cadmeshBuild \
#    && cmake ../cadmesh -DCMAKE_CXX_FLAGS=-fPIC -DCMAKE_INSTALL_PREFIX:PATH=$MLIBRARY -DCMAKE_PREFIX_PATH=$JLAB_SOFTWARE/geant4/$GEANT4_VERSION \
#    && make -j$(nproc) \
#    && make install

## gemc
ENV GEMC_VERSION devel
ENV GEMC $JLAB_SOFTWARE/gemc/$GEMC_VERSION

RUN mkdir -p $GEMC && cd $GEMC \
    && git clone https://github.com/gemc/source.git $GEMC/github-source

COPY gemc.cc $GEMC/github-source/gemc.cc
COPY CMakeLists_gemc.txt $GEMC/github-source/CMakeLists.txt
###RUN cd $GEMC/github-source \
###    && mkdir build && cd build \
###    && cmake .. -DCMAKE_INSTALL_PREFIX=$GEMC \
###    && make -j$(nproc) \
###    && make install

##Banks
#ENV BANKS_VERSION devel
#ENV PYTHONPATH /opt/jlab_software/devel/scons_bm/devel

#RUN mkdir -p $JLAB_SOFTWARE/banks \
#    && cd $JLAB_SOFTWARE/banks \
#    && curl -o banks-$BANKS_VERSION.tar.gz $BASE_URL/banks/banks-$BANKS_VERSION.tar.gz \
#    && tar -xvf banks-$BANKS_VERSION.tar.gz \
#    && rm -rf banks-$BANKS_VERSION.tar.gz \
#    && cd $BANKS_VERSION \
#    && scons -j$(nproc) OPT=1

##Jana
#ENV JANA_VERSION devel
#ENV JANA_HOME $JLAB_SOFTWARE/jana/$JANA_VERSION

#RUN git clone https://github.com/JeffersonLab/JANA.git $JANA_HOME \
#    && cd $JANA_HOME \
#    && scons -j$(nproc)

## Fields
#RUN mkdir -p $JLAB_ROOT/noarch/data \
#   && cd $JLAB_ROOT/noarch/data \
#   && rm -rf srr* clas12* \
#   && curl -o clas12SolenoidFieldMap.dat http://clasweb.jlab.org/12gev/field_maps/clas12SolenoidFieldMap.dat \
#   && curl -o clas12TorusOriginalMap.dat http://clasweb.jlab.org/12gev/field_maps/clas12TorusOriginalMap.dat

## Clara/Coatjava
#ENV CLARA_HOME $JLAB_SOFTWARE/clara
#ENV COAT_VER 4a.2.2
#ENV PLUGIN 4a.4.0

#RUN mkdir -p $CLARA_HOME/jre \
#    && cd $CLARA_HOME \
#    && curl -o clara-cre.tar.gz https://userweb.jlab.org/~gurjyan/clara-cre/clara-cre.tar.gz \
#    && tar xvzf clara-cre.tar.gz \
#    && mv clara-cre/* . \
#    && rm -rf clara-cre.tar.gz clara-cre \
#    && curl -o linux-64.tar.gz https://userweb.jlab.org/~gurjyan/clara-cre/linux-64.tar.gz \
#    && mv linux-64.tar.gz $CLARA_HOME/jre \
#    && cd $CLARA_HOME/jre \
#    && tar xvzf linux-64.tar.gz \
#    && curl -o coatjava-$PLUGIN.tar.gz http://clasweb.jlab.org/clas12offline/distribution/coatjava/coatjava-$PLUGIN.tar.gz \
#    && tar xvzf coatjava-$PLUGIN.tar.gz \
#    && rm -rf coatjava-$PLUGIN.tar.gz \
#    && cd coatjava \
#    && cp -r etc $CLARA_HOME/plugins/clas12/. \
#    && cp -r bin $CLARA_HOME/plugins/clas12/. \
#    && cp -r lib/packages $CLARA_HOME/plugins/clas12/lib/ \
#    && cp -r lib/utils $CLARA_HOME/plugins/clas12/lib/ \
#    && cp  lib/clas/* $CLARA_HOME/plugins/clas12/lib/clas/. \
#    && cp  lib/services/* $CLARA_HOME/plugins/clas12/lib/services/. \
#    && cp $CLARA_HOME/plugins/clas12/etc/services/reconstruction.yaml $CLARA_HOME/plugins/clas12/config/services.yaml \
#    && chmod a+x $CLARA_HOME/bin/*



#RUN mkdir -p /group/clas12/gemc/$COAT_VER/experiments
#ADD experiments.tar /group/clas12/gemc/$COAT_VER
WORKDIR /root/

ENTRYPOINT ["/bin/tcsh"]
