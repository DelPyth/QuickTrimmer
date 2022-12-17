ifneq ($(OS),Windows_NT)
	$(error This program is made for windows only!)
	exit
endif

CWD = $(shell cd)
AHK_VERSION ?= 1.1.36.02
AHK_PATH ?= C:/Program Files/AutoHotkey
AHK_NAME ?= AutoHotkeyU64.exe
SRC = ${CWD}\src\main.ahk
BUILD = ${CWD}\build\Quick Trimmer.exe
CC = ${AHK_PATH}/v${AHK_VERSION}/${AHK_NAME}

$(info This will not build the script but run it.)

.PHONY: build

all:
	${CC} "${SRC}"

build:
	${AHK_PATH}/Compiler/Ahk2Exe.exe /in "${SRC}" /out "${BUILD}"
