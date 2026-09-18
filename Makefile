APP_NAME := PR Inbox
BUILD_DIR := build
APP := $(BUILD_DIR)/$(APP_NAME).app

.PHONY: build run app install clean

## Compile a release binary into .build/release/PRInbox
build:
	swift build -c release

## Run straight from the package (Dock-less, menu bar only)
run:
	swift run -c release PRInbox

## Assemble a double-clickable, ad-hoc signed "$(APP_NAME).app" in build/
app: build
	rm -rf "$(APP)"
	mkdir -p "$(APP)/Contents/MacOS" "$(APP)/Contents/Resources"
	cp .build/release/PRInbox "$(APP)/Contents/MacOS/PRInbox"
	cp Packaging/Info.plist "$(APP)/Contents/Info.plist"
	echo -n "APPL????" > "$(APP)/Contents/PkgInfo"
	codesign --force --sign - --identifier dev.prinbox.menubar "$(APP)"
	@echo "Built $(APP)"

## Copy the app to ~/Applications and launch it
install: app
	mkdir -p "$(HOME)/Applications"
	rm -rf "$(HOME)/Applications/$(APP_NAME).app"
	cp -R "$(APP)" "$(HOME)/Applications/"
	open "$(HOME)/Applications/$(APP_NAME).app"

clean:
	rm -rf .build "$(BUILD_DIR)"
