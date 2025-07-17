# Makefile for Formbricks

#env
UPDATE_REPO ?= false
CLEAN ?= true
IS_IOS ?= true
IS_ANDROID ?= true

# Variables
CLEAN_VARIABLE := cleaning the repository
DEPENDENCY_VARIABLE := getting dependencies
DE_INTEGRATE_POD_VARIABLE := de-integrating pod file
ENTER_IOS_FOLDER_VARIABLE := enter ios folder for ios related command
COME_OUT_IOS_FOLDER_VARIABLE := enter ios folder for ios related command
REMOVE_POD_LOCK_VARIABLE := removing podfile.lock file
INSTALL_IOS_DEPENDENCIES_VARIABLE := install ios dependencies

#Function to just clean and get dependencies
clean_get_dependency:
	@echo "=${CLEAN_VARIABLE}"
	flutter clean 

	@echo "${DEPENDENCY_VARIABLE}"   # Printing the log on console
	flutter pub get   # Command for getting dependencies

#Function to clean ios folder
clean_pod_file: 
	@echo "CLEAN is: $(CLEAN)"
	@if [ "$(strip $(CLEAN))" = "true" ]; then \
		${MAKE} clean_get_dependency; \
	else \
		echo "Skipping clean_get_dependency"; \
	fi

	@echo "${DE_INTEGRATE_POD_VARIABLE}"
	cd ios && pod deintegrate 

	@echo "${REMOVE_POD_LOCK_VARIABLE}"
	cd ios && rm Podfile.lock

	@if [ "$(strip $(UPDATE_REPO))" = "true"]; then \
		echo "Installing pod dependencies and repository";\
		cd ios && pod install --repo-update && clear; \
	else \
		echo "${INSTALL_IOS_DEPENDENCIES_VARIABLE}";\
		cd ios && pod install && clear; \
	fi

#Function to run build_runner
build_and_replace:
	@echo "Running build_runner..."
	flutter pub run build_runner build --delete-conflicting-outputs && clear
	@echo "Build and replace process completed."

#Function to generate l10n
generate_l10n:
	@echo "Generating l10n..."
	flutter gen-l10n && clear
	@echo "Generating l10n process completed."

.PHONY: clean_get_prod clean_get_test clean_get_dependency clean_pod_file build_and_replace generate_l10n #it name specify the make command name