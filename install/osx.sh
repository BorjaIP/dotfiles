#!/usr/bin/env bash

echo -e "\\n\\nOS X settings"
echo "=============================================="

echo "Only use UTF-8 in Terminal.app"
defaults write com.apple.terminal StringEncodings -array 4

echo "Show the ~/Library folder in Finder"
chflags nohidden ~/Library

echo "Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true

echo "Enable tap to click (Trackpad)"
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

echo "Enable bottom right corner to right-click (Trackpad)"
defaults write com.apple.driver.AppleMultitouchTrackpad.trackpad TrackpadCornerSecondaryClick -int 2

echo "Enable pinch with two fingers (Trackpad)"
defaults write com.apple.driver.AppleMultitouchTrackpad.trackpad TrackpadPinch -int 1

echo "Enable zoom with two fingers (Trackpad)"
defaults write com.apple.driver.AppleMultitouchTrackpad.trackpad TrackpadTwoFingerDoubleTapGesture -int 1

echo "Enable rotate with two fingers (Trackpad)"
defaults write com.apple.driver.AppleMultitouchTrackpad.trackpad TrackpadRotate -int 1

echo "Enable show notifications with two fingers (Trackpad)"
defaults write com.apple.driver.AppleMultitouchTrackpad.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 1

echo "Enable change between apps with four fingers (Trackpad)"
defaults write com.apple.driver.AppleMultitouchTrackpad.trackpad TrackpadFourFingerHorizSwipeGesture -int 2

echo "Enable Mission Control with four fingers (Trackpad)"
defaults write com.apple.driver.AppleMultitouchTrackpad.trackpad TrackpadFourFingerVertSwipeGesture -int 2

echo "Enable show dessktop with four fingers (Trackpad)"
defaults write com.apple.driver.AppleMultitouchTrackpad.trackpad TrackpadFourFingerPinchGesture -int 2

echo "Enable Safari’s debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

echo "Disable the useless Dashboard"
defaults write com.apple.dashboard mcx-disabled -boolean TRUE && killall Dock

