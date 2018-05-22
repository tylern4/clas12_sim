#!/bin/csh -f

source /group/clas12/gemc/environment.csh 4a.1.0

gemc /group/clas12/gemc/4a.1.0/clas12.gcard -INPUT_GEN_FILE="LUND, gen.dat" -OUTPUT="evio, sim.evio" -RUNNO=11 -USE_GUI=0 -N=10000
