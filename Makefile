SECTION="NetPing modules"
CATEGORY="Base"
TITLE="EPIC OWRT-WEB-Notifications"
PKG_NAME="OWRT-WEB-Notifications"
PKG_VERSION="0.1"
PKG_RELEASE=1

MODULE_DIR_NAME=owrt_web_notification
MODULE_FILES_DIR=/usr/lib/lua/luci/
CSS_FILES_DIR=/www/luci-static/
MODULE_FILES_CONTROLLER=/usr/lib/lua/luci/controller/$(MODULE_DIR_NAME)
MODULE_FILES_MODEL=/usr/lib/lua/luci/model/cbi/$(MODULE_DIR_NAME)
MODULE_FILES_MODEL_NOTCBI=/usr/lib/lua/luci/model/$(MODULE_DIR_NAME)
MODULE_FILES_VIEW=/usr/lib/lua/luci/view/$(MODULE_DIR_NAME)

.PHONY: all install clean

all: install

install:
	cp -r luasrc/* $(MODULE_FILES_DIR)
	cp -r luci-static/* $(CSS_FILES_DIR)

clean:
	rm -r $(MODULE_FILES_CONTROLLER)
	rm -r $(MODULE_FILES_MODEL)
	rm -r $(MODULE_FILES_MODEL_NOTCBI)
	rm -r $(MODULE_FILES_VIEW)

