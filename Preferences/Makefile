ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectBattery13Prefs
PerfectBattery13Prefs_FILES = PBTAppearanceSettings.m PBTRootHeaderView.mm PBTRootListController.xm
PerfectBattery13Prefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectBattery13Prefs_FRAMEWORKS = UIKit
PerfectBattery13Prefs_PRIVATE_FRAMEWORKS += Preferences
PerfectBattery13Prefs_LIBRARIES += sparkcolourpicker sparkapplist
PerfectBattery13Prefs_CFLAGS += -fobjc-arc -Wno-deprecated-declarations
PerfectBattery13Prefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectBattery13Prefs.plist$(ECHO_END)
