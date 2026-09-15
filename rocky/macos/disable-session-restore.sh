#!/bin/sh

set -eu

# Start only explicit Login Items and launchd services after login.
/usr/bin/defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
/usr/bin/defaults write com.apple.loginwindow TALLogoutSavesState -bool false
/usr/bin/defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false
