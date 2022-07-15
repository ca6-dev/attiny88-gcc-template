BUILD_FILE := template
BUILD_EXT := elf
BUILD_TARGET :=attiny88

SRC_DIR := src
OBJ_DIR := obj
BIN_DIR := bin

CC_HOME := 
CC_NAME := avr-

CC  := $(CC_HOME)$(CC_NAME)gcc
CXX := $(CC_HOME)$(CC_NAME)g++
OBJDUMP := $(CC_HOME)$(CC_NAME)objdump
OBJCPY := $(CC_HOME)$(CC_NAME)objcopy
SIZE := $(CC_HOME)$(CC_NAME)size

LIB_DIR :=lib
CC_DEF +=-DTARGET_AVR
CXX_DEF +=-DTARGET_AVR
CC_OPT += -O3 -std=gnu99 -Wall -mmcu=$(BUILD_TARGET)
CC_OPT_FINAL := 
CXX_OPT += -O3
BUILD_TARGET :=attiny88
SIZE_OPT := --format=avr --mcu=attiny88

ifneq (,$(findstring debug,$(OPTION)))
CC_OPT += -g3
CXX_OPT +=
else
CC_OPT += -g0
CXX_OPT +=
endif

# Find .c & .cpp
SRCS := $(shell find $(SRC_DIR) -name '*.cpp' -or -name '*.c' -or -name '*.s')
OBJS := $(SRCS:%=$(OBJ_DIR)/%.o)
DEPS := $(OBJS:.o=.d)
INC_DIRS := $(shell find $(SRC_DIR) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))
CPPFLAGS := $(INC_FLAGS) -MMD -MP

# The final build step.
$(BIN_DIR)/$(BUILD_FILE)-$(BUILD_TARGET).$(BUILD_EXT): $(OBJS)
	$(CC) -Wall $(OBJS) $(CC_OPT) $(CC_DEF) -o  $@ $(LDFLAGS)
	$(OBJDUMP) -S $(BIN_DIR)/$(BUILD_FILE)-$(BUILD_TARGET).$(BUILD_EXT) > $(BIN_DIR)/$(BUILD_FILE)-$(BUILD_TARGET)-list.txt
	$(SIZE) $@ $(SIZE_OPT) > $(BIN_DIR)/$(BUILD_FILE)-$(BUILD_TARGET)-map.txt
	$(OBJDUMP) -x $(BIN_DIR)/$(BUILD_FILE)-$(BUILD_TARGET).$(BUILD_EXT) >> $(BIN_DIR)/$(BUILD_FILE)-$(BUILD_TARGET)-map.txt
	$(OBJCPY) -O binary $@ $(BIN_DIR)/$(BUILD_FILE)-$(BUILD_TARGET).$(BUILD_EXT).bin
	$(OBJCPY) -j .text -j .data -O ihex $@ $(BIN_DIR)/$(BUILD_FILE)-$(BUILD_TARGET).$(BUILD_EXT).hex
	$(SIZE) $@ $(SIZE_OPT)

# Build C source
$(OBJ_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) -Wall $(CPPFLAGS) $(CC_OPT) $(CC_DEF) -c $< -o $@ 

# Build C++ source
$(OBJ_DIR)/%.cpp.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) -Wall $(CPPFLAGS) $(CXX_OPT) $(CXX_DEF) -c $< -o $@

.PHONY: clean
clean:
	rm -rf $(OBJ_DIR)/*

.PHONY: dist-clean
dist-clean:
	rm -rf $(OBJ_DIR)/*
	rm -rf $(BIN_DIR)/*

# Do not remove
-include $(DEPS)
