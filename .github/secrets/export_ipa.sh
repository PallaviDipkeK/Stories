#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/StoriesSDK.xcarchive \
            -exportOptionsPlist StoriesSDK-iOS/StoriesSDK\ iOS/exportOptions.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
