CC=gcc
SRCS_DIR=. lib1/src lib2/src
INCS_DIR= lib1/inc lib2/inc
BUILD_DIR=build
SRCS=$(foreach dir, $(SRCS_DIR), $(wildcard $(dir)/*.c))
OBJS=$(patsubst %.c, $(BUILD_DIR)/%.o, $(SRCS))
FLAG=-MMD $(foreach inc_dir, $(INCS_DIR), -I$(inc_dir))
program: $(OBJS)
	$(info link all object files to $@)
	$(CC) $(OBJS) -o $@

$(BUILD_DIR)/%.o: %.c
	$(info build $< to $@)
	mkdir -p $(foreach dir, $(SRCS_DIR), $(BUILD_DIR)/$(dir))
	$(CC) -c $(FLAG) $< -o $@

debug:
	$(info sources: $(SRCS))
	$(info objects: $(OBJS))

clear: 
	rm -rf $(BUILD_DIR)/*

-include $(BUILD_DIR)/*.d
