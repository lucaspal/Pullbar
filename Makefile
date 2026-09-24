APP_NAME := pullbar
BUILD_DIR := build
APP := $(BUILD_DIR)/$(APP_NAME).app

.PHONY: build run app install clean

APP_ICON := $(BUILD_DIR)/AppIcon.icns

## Compile a release binary into .build/release/pullbar
build:
	swift build -c release

## Run straight from the package (Dock-less, menu bar only)
run:
	swift run -c release pullbar

## Assemble a double-clickable, ad-hoc signed "$(APP_NAME).app" in build/
app: build $(APP_ICON)
	rm -rf "$(APP)"
	mkdir -p "$(APP)/Contents/MacOS" "$(APP)/Contents/Resources"
	cp .build/release/pullbar "$(APP)/Contents/MacOS/pullbar"
	cp Packaging/Info.plist "$(APP)/Contents/Info.plist"
	cp "$(APP_ICON)" "$(APP)/Contents/Resources/AppIcon.icns"
	echo -n "APPL????" > "$(APP)/Contents/PkgInfo"
	codesign --force --sign - --identifier dev.pullbar.menubar "$(APP)"
	@echo "Built $(APP)"

$(APP_ICON): Packaging/AppIcon-1024.png Packaging/build-icon.sh
	mkdir -p "$(BUILD_DIR)"
	sh Packaging/build-icon.sh "$<" "$@"

## Copy the app to ~/Applications and launch it
install: app
	mkdir -p "$(HOME)/Applications"
	rm -rf "$(HOME)/Applications/$(APP_NAME).app"
	cp -R "$(APP)" "$(HOME)/Applications/"
	open "$(HOME)/Applications/$(APP_NAME).app"

clean:
	rm -rf .build "$(BUILD_DIR)"
