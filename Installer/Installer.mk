# Build Autoindigestion installer package from within Xcode.


PKG_FILES := \
	$(DERIVED_SOURCES_DIR)/Root/Library/Autoindigestion/Autoindigestion \
	$(DERIVED_SOURCES_DIR)/Root/Library/LaunchDaemons/Autoindigestion.plist \
	$(DERIVED_SOURCES_DIR)/Root/usr/local/share/man/man1/Autoindigestion.1 \
	$(DERIVED_SOURCES_DIR)/Root/usr/local/share/man/man5/Autoindigestion.5

SCRIPTS := $(shell find $(SRCROOT)/Installer/Scripts -type f \! -name .DS_Store \! -path "*/.svn/*")


.PHONY : all clean


all : $(BUILT_PRODUCTS_DIR)/Autoindigestion.pkg


clean :
	rm -rf $(BUILT_PRODUCTS_DIR)/Autoindigestion.pkg
	rm -rf $(DERIVED_SOURCES_DIR)


$(BUILT_PRODUCTS_DIR)/Autoindigestion.pkg : $(PKG_FILES) $(SCRIPTS)
	@printf '===== Building Autoindigestion package =====\n'
	pkgbuild \
		--root $(DERIVED_SOURCES_DIR)/Root \
		--identifier com.ablepear.autoindigestion \
		--ownership recommended \
		--scripts $(SRCROOT)/Installer/Scripts \
		$@


$(DERIVED_SOURCES_DIR)/Root/Library/Autoindigestion/Autoindigestion : $(BUILT_PRODUCTS_DIR)/Autoindigestion
	mkdir -p $(dir $@)
	cp $< $@


$(DERIVED_SOURCES_DIR)/Root/Library/LaunchDaemons/Autoindigestion.plist : $(SRCROOT)/Documentation/LaunchDaemon.plist
	mkdir -p $(dir $@)
	cp $< $@


$(DERIVED_SOURCES_DIR)/Root/usr/local/share/man/man1/Autoindigestion.1 : $(SRCROOT)/Documentation/Autoindigestion.1
	mkdir -p $(dir $@)
	cp $< $@


$(DERIVED_SOURCES_DIR)/Root/usr/local/share/man/man5/Autoindigestion.5 : $(SRCROOT)/Documentation/Autoindigestion.5
	mkdir -p $(dir $@)
	cp $< $@
