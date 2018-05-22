JAVAC=javac
JVM=java
COAT=$(COATJAVA)
JC_FLAGS=-cp "$(COAT)/lib/clas/*"
JVM_FLAGS=-cp "$(COAT)/lib/clas/*:."
sources = $(wildcard *.java)
classes = $(sources:.java=.class)

all: $(classes) run

%.class : %.java
	$(JAVAC) $(JC_FLAGS) $<

run:
	$(JVM) $(JVM_FLAGS) RandomEventGenerator


clean:
	$(RM) *.class
