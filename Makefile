#TRANSPILER := decaffeinate
TRANSPILER := coffee --compile --bare -o ./
SRC_DIR := src

main.html: visualize.js graph.js ed.js

visualize.js: $(SRC_DIR)/visualize.coffee
	$(TRANSPILER) $(SRC_DIR)/visualize.coffee

ed.js: $(SRC_DIR)/ed.coffee
	$(TRANSPILER) $(SRC_DIR)/ed.coffee

graph.js: $(SRC_DIR)/graph.coffee
	$(TRANSPILER) $(SRC_DIR)/graph.coffee

all: main.html

tarball: Makefile main.html
	tar -cf main.tar Makefile visualize.js graph.js ed.js main.html style.css

zip: Makefile main.html
	zip main.zip Makefile visualize.js graph.js ed.js main.html style.css

tarsource: Makefile main.coffee $(IMG)
	tar -cf source.tar Makefile $(SRC_DIR) main.html style.css

zipsource: Makefile main.coffee $(IMG)
	zip source.zip Makefile $(SRC_DIR) main.html style.css

# Destroy generated js files
clean:
	rm visualize.js ed.js graph.js

