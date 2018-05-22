#!/usr/bin/env bash
source /site/12gev_phys/softenv.sh 2.2 2> /dev/null

export CLARA_HOME=/home/tylern/clara/5c.3.5
export COATJAVA=$CLARA_HOME/plugins/clas12
export PATH=$PATH:$CLARA_HOME/bin:$COATJAVA/bin

export TORUS_FEILD=-1.0
export SOLO_FEILD=1.0

evio2hipo -r 11 -t $TORUS_FEILD -s $SOLO_FEILD -o sim.hipo sim.evio

clara-shell cook.clara

javac -cp "$COATJAVA/lib/clas/*" MyAnalysis.java
java -cp "$COATJAVA/lib/clas/*:." MyAnalysis
