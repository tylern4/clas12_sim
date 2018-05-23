#!/usr/bin/env bash
source /site/12gev_phys/softenv.sh 2.2 2> /dev/null

export TORUS_FEILD=-1.0
export SOLO_FEILD=1.0
export RUN_NUM=3050
export NUM_GEN=1000000

export CLARA_HOME=/home/tylern/clara/5c.3.5
export COATJAVA=$CLARA_HOME/plugins/clas12
export PATH=$PATH:$CLARA_HOME/bin:$COATJAVA/bin

#echo "RUNNING SIMPLE GENERATOR"
#javac -cp "$COATJAVA/clas12/lib/clas/*" RandomEventGenerator.java
#java -cp "$COATJAVA/clas12/lib/clas/*:." RandomEventGenerator $NUM_GEN
#echo "RAN GENERATOR"
#ls -la


echo "RUNNING GEMC"
gemc clas12.gcard -INPUT_GEN_FILE="LUND, gen.dat" -OUTPUT="evio, sim.evio" -RUNNO=$RUN_NUM -USE_GUI=0 -N=$NUM_GEN
echo "DONE WITH GEMC"
evio2hipo -r $RUN_NUM -t $TORUS_FEILD -s $SOLO_FEILD -o sim.hipo sim.evio
echo "DONE WITH EVIO2HIPO"
ls -la
