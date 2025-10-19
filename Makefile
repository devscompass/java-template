.PHONY: clean compile package run run-jar help

SRC_DIR := src
LIB_DIR := lib
CLS_DIR := bin
DES_DIR := dist

MAIN_CLASS := $(shell \
	MAIN_FILE=$$(grep -rl "public class Main" $(SRC_DIR) | head -n1); \
	if [ -z "$$MAIN_FILE" ]; then \
		echo "[ERROR] Main.java not found" >&2; exit 1; \
	fi; \
	PKG=$$(grep "package " "$$MAIN_FILE" | awk '{print $$2}' | tr -d ';'); \
	if [ -n "$$PKG" ]; then \
		echo "$${PKG}.Main"; \
	else \
		echo "Main"; \
	fi \
)

define CHECK_DEPENDENCY
	@for cmd in $(1); do \
		if ! command -v $$cmd &>/dev/null; then \
			echo "[ERROR] Couldn't find $$cmd!"; \
			exit 1; \
		fi; \
	done
endef

.deps:
	$(call CHECK_DEPENDENCY, java, javac, jar)

clean:
	@rm -rf $(CLS_DIR) $(DES_DIR)
	@echo "[INFO] Cleaned build artifacts.";

compile: .deps
	@if [ -d "$(LIB_DIR)" ] && [ "$$(ls -A $(LIB_DIR))" ]; then \
		javac -d $(CLS_DIR) -cp "$(LIB_DIR)/*" $$(find $(SRC_DIR) -name "*.java"); \
	else \
		javac -d $(CLS_DIR) $$(find $(SRC_DIR) -name "*.java"); \
	fi
	@echo "[INFO] Compiled source files into '$(CLS_DIR)'."

package: compile
	@jar --create --file $(DES_DIR)/app.jar --main-class=$(MAIN_CLASS) -C $(CLS_DIR) .
	@echo "[INFO] Packaged application into '$(DES_DIR)/app.jar'."

run: compile
	@echo "[INFO] Running application..."
	@java -cp "$(CLS_DIR):$(LIB_DIR)/*" $(MAIN_CLASS)

run-jar: package
	@echo "[INFO] Running '$(DES_DIR)/app.jar'..."
	@java -jar $(DES_DIR)/app.jar

help:
	@echo "Available targets:"
	@echo "  clean             - Clean compiled and packaged files"
	@echo "  compile           - Compile source code"
	@echo "  package           - Package compiled files into a JAR"
	@echo "  run               - Run the application from compiled classes"
	@echo "  run-jar           - Run the application from the packaged JAR"
	@echo "  help              - Show this help message"
