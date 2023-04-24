XCODE_USER_TEMPLATES_DIR=/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/File\ Templates
TEMPLATE_NAME=VIPER
TEMPLATES_DIR=Example/Templates/VIPER

EXISTS_FASTLANE = $(shell command -v fastlane 2> /dev/null)

install_templates:
	mkdir -p $(XCODE_USER_TEMPLATES_DIR)
	rm -fR $(XCODE_USER_TEMPLATES_DIR)/$(TEMPLATE_NAME)
	cp -R $(TEMPLATES_DIR) $(XCODE_USER_TEMPLATES_DIR)

install_env:
ifeq "${EXISTS_FASTLANE}" ""
	@echo Installing fastlane
	sudo gem install fastlane --no-document
endif		
	@echo "All dependencies was installed"

build_all:
	fastlane build_for_testing scheme:IntegrationTests relay_host:$(RELAY_HOST) project_id:$(PROJECT_ID)

build_dapp:
	fastlane build scheme:DApp

build_wallet:
	fastlane build scheme:WalletApp

ui_tests:
	echo "UI Tests disabled"

unit_tests:
	fastlane tests scheme:WalletConnect

integration_tests:
	fastlane tests scheme:IntegrationTests testplan:IntegrationTests relay_host:$(RELAY_HOST) project_id:$(PROJECT_ID)

relay_tests:
	fastlane tests scheme:RelayIntegrationTests relay_host:$(RELAY_HOST) project_id:$(PROJECT_ID)

smoke_tests:
	fastlane tests scheme:IntegrationTests testplan:SmokeTests relay_host:$(RELAY_HOST) project_id:$(PROJECT_ID)

resolve_packages: 
	fastlane resolve scheme:WalletApp

release_wallet:
	fastlane release_testflight username:$(APPLE_ID) token:$(TOKEN) relay_host:$(RELAY_HOST) project_id:$(PROJECT_ID) --env WalletApp

release_showcase:
	fastlane release_testflight username:$(APPLE_ID) token:$(TOKEN) relay_host:$(RELAY_HOST) project_id:$(PROJECT_ID) --env Showcase

release_all: 
	fastlane release_testflight username:$(APPLE_ID) token:$(TOKEN) relay_host:$(RELAY_HOST) project_id:$(PROJECT_ID) --env WalletApp
	fastlane release_testflight username:$(APPLE_ID) token:$(TOKEN) relay_host:$(RELAY_HOST) project_id:$(PROJECT_ID) --env Showcase
