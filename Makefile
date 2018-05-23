JAVAC=javac
COAT=$(COATJAVA)
J_FLAGS=-cp "$(COAT)/lib/clas/*"
sources = $(wildcard *.java)
classes = $(sources:.java=.class)

all: $(classes)

%.class : %.java
	$(JAVAC) $(J_FLAGS) $<

clean:
	$(RM) *.class
