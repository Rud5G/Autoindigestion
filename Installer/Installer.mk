# Build Autoindigestion installer package from within Xcode.


PKG_FILES := \
	$(DERIVED_SOURCES_DIR)/Root/Library/Autoindigestion/Autoindigestion \
	$(DERIVED_SOURCES_DIR)/Root/Library/Autoindigestion/Vendors/ExampleVendor.plist \
	$(DERIVED_SOURCES_DIR)/Root/Library/LaunchDaemons/Autoindigestion.plist \
	$(DERIVED_SOURCES_DIR)/Root/usr/local/share/man/man1/Autoindigestion.1 \
	$(DERIVED_SOURCES_DIR)/Root/usr/local/share/man/man5/Autoindigestion.5

RESOURCES := \
	$(SRCROOT)/Installer/Resources/background.png \
	$(SRCROOT)/Installer/Resources/conclusion.html \
	$(SRCROOT)/Installer/Resources/license.html \
	$(SRCROOT)/Installer/Resources/welcome.html

SCRIPTS := $(shell find $(SRCROOT)/Installer/Scripts -type f \! -name .DS_Store \! -path "*/.svn/*")


.PHONY : all clean


all : $(BUILT_PRODUCTS_DIR)/Autoindigestion.pkg


clean :
	rm -rf $(BUILT_PRODUCTS_DIR)/Autoindigestion.pkg
	rm -rf $(DERIVED_SOURCES_DIR)


$(BUILT_PRODUCTS_DIR)/Autoindigestion.pkg : \
		$(DERIVED_SOURCES_DIR)/Autoindigestion.pkg \
		$(SRCROOT)/Installer/Distribution.xml \
		$(BUILT_PRODUCTS_DIR)/DownloadAutoingestionPlugin.bundle \
		$(SRCROOT)/Installer/InstallerSections.plist \
		$(RESOURCES)
	@printf '===== Building Autoindigestion product archive =====\n'
	productbuild \
		--distribution $(SRCROOT)/Installer/Distribution.xml \
		--resources $(SRCROOT)/Installer/Resources \
		--package-path $(DERIVED_SOURCES_DIR) \
		$@
	# add plugin to product archive
	-rm -rf $(DERIVED_SOURCES_DIR)/ProductArchive
	pkgutil --expand $@ $(DERIVED_SOURCES_DIR)/ProductArchive
	rm $@
	mkdir -p $(DERIVED_SOURCES_DIR)/ProductArchive/Plugins
	cp -R $(BUILT_PRODUCTS_DIR)/DownloadAutoingestionPlugin.bundle $(DERIVED_SOURCES_DIR)/ProductArchive/Plugins
	cp $(SRCROOT)/Installer/InstallerSections.plist $(DERIVED_SOURCES_DIR)/ProductArchive/Plugins
	pkgutil --flatten $(DERIVED_SOURCES_DIR)/ProductArchive $@


$(DERIVED_SOURCES_DIR)/Autoindigestion.pkg : $(PKG_FILES) $(SCRIPTS)
	@printf '===== Building Autoindigestion component package =====\n'
	mkdir -p $(dir $@)
	pkgbuild \
		--root $(DERIVED_SOURCES_DIR)/Root \
		--identifier com.ablepear.autoindigestion \
		--ownership recommended \
		--scripts $(SRCROOT)/Installer/Scripts \
		$@


$(DERIVED_SOURCES_DIR)/Root/Library/Autoindigestion/Autoindigestion : $(BUILT_PRODUCTS_DIR)/Autoindigestion
	mkdir -p $(dir $@)
	cp $< $@


$(DERIVED_SOURCES_DIR)/Root/Library/Autoindigestion/Vendors/ExampleVendor.plist : $(SRCROOT)/Documentation/ExampleVendor.plist
	mkdir -p $(dir $@)
	cp $< $@
	/usr/libexec/PlistBuddy -c "Add :Disabled bool true" $@


$(DERIVED_SOURCES_DIR)/Root/Library/LaunchDaemons/Autoindigestion.plist : $(SRCROOT)/Documentation/LaunchDaemon.plist
	mkdir -p $(dir $@)
	cp $< $@


$(DERIVED_SOURCES_DIR)/Root/usr/local/share/man/man1/Autoindigestion.1 : $(SRCROOT)/Documentation/Autoindigestion.1
	mkdir -p $(dir $@)
	cp $< $@


$(DERIVED_SOURCES_DIR)/Root/usr/local/share/man/man5/Autoindigestion.5 : $(SRCROOT)/Documentation/Autoindigestion.5
	mkdir -p $(dir $@)
	cp $< $@
