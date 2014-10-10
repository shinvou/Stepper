DEBUG = 0

GO_EASY_ON_ME = 1

TARGET = iphone:clang:latest:7.0
ARCHS = armv7 arm64

//THEOS_DEVICE_IP = 127.0.0.1
//THEOS_DEVICE_PORT = 2222
THEOS_PACKAGE_DIR_NAME = deb

include theos/makefiles/common.mk

TWEAK_NAME = StepperTweak
StepperTweak_FILES = Tweak.xm
StepperTweak_FRAMEWORKS = UIKit Foundation CoreFoundation QuartzCore
StepperTweak_PRIVATE_FRAMEWORKS = AppleAccount
StepperTweak_LIBRARIES = objcipc
StepperTweak_CFLAGS = -fobjc-arc

APPLICATION_NAME = StepperApp
StepperApp_FILES = main.m StepperApp.mm
StepperApp_FRAMEWORKS = Foundation UIKit CoreMotion
StepperApp_LIBRARIES = objcipc
StepperApp_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/application.mk

SUBPROJECTS += StepperSettings
include $(THEOS_MAKE_PATH)/aggregate.mk

before-stage::
	find . -name ".DS_Store" -delete
after-install::
	install.exec "killall -9 backboardd"

