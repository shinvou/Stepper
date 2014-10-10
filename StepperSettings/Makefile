ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = StepperSettings
StepperSettings_FILES = StepperSettings.mm
StepperSettings_INSTALL_PATH = /Library/PreferenceBundles
StepperSettings_FRAMEWORKS = UIKit
StepperSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/StepperSettings.plist$(ECHO_END)
