{\rtf1\ansi\ansicpg1252\cocoartf2636
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 Menlo-Regular;}
{\colortbl;\red255\green255\blue255;\red108\green121\blue134;\red31\green31\blue36;\red255\green255\blue255;
\red84\green130\blue255;}
{\*\expandedcolortbl;;\csgenericrgb\c42394\c47462\c52518;\csgenericrgb\c12054\c12284\c14131;\csgenericrgb\c100000\c100000\c100000\c85000;
\csgenericrgb\c33019\c51127\c99859;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab593
\pard\tx593\pardeftab593\pardirnatural\partightenfactor0

\f0\fs24 \cf2 \cb3 ##!/bin/bash\cf4 \
\cf2 #\cf4 \
\cf2 #PROVISIONING_PROFILE="StoriesSDK"\cf4 \
\cf2 #CODE_SIGN_IDENTITY="Apple Development: StoriesSDK (5TLXGJ5BJC)"\cf4 \
\cf2 #DOMAIN="StoriesSDK.com"\cf4 \
\cf2 #PRODUCT_BUNDLE_IDENTIFIER="co.opendigi.openbook"\cf4 \
\cf2 #\cf4 \
\cf2 ## Get dependencies\cf4 \
\cf2 #function get_dependencies()\cf4 \
\cf2 #\{\cf4 \
\cf2 #    yarn\cf4 \
\cf2 #    cd ios\cf4 \
\cf2 #    pod install\cf4 \
\cf2 #    cd ..\cf4 \
\cf2 #\}\cf4 \
\cf2 #\cf4 \
\cf2 #function decrypt\cf4 \
\cf2 #\{\cf4 \
\cf2 #    INPUT=$1\cf4 \
\cf2 #    OUTPUT="$\{1%.*\}"\cf4 \
\cf2 #    openssl aes-256-cbc -salt -a -d -in $INPUT -out $OUTPUT -pass pass:$SECRET_KEY\cf4 \
\cf2 #\}\cf4 \
\cf2 #\cf4 \
\cf2 ## Decrypt secrets\cf4 \
\cf2 #function decrypt_secrets\cf4 \
\cf2 #\{\cf4 \
\cf2 #    export SECRET_KEY=$1\cf4 \
\cf2 #    decrypt .github/ios/secrets/MyApp.mobileprovision.encrypted\cf4 \
\cf2 #    decrypt .github/ios/secrets/MyApp.p12.encrypted\cf4 \
\cf2 #    decrypt .github/ssh/id_rsa.encrypted\cf4 \
\cf2 #\}\cf4 \
\cf2 #\cf4 \
\cf2 ## Set up code signing\cf4 \
\cf2 #function setup_code_signing()\cf4 \
\cf2 #\{\cf4 \
\cf2 #    mkdir -p ~/Library/MobileDevice/Provisioning\\ Profiles\cf4 \
\cf2 #\cf4 \
\cf2 #    # provisioning\cf4 \
\cf2 #    cp .github/ios/secrets/MyApp.mobileprovision ~/Library/MobileDevice/Provisioning\\ Profiles/$PROVISIONING_PROFILE.mobileprovision\cf4 \
\cf2 #\cf4 \
\cf2 #    # keychain\cf4 \
\cf2 #    security create-keychain -p "MyApp" build.keychain\cf4 \
\cf2 #    security import ./.github/ios/secrets/MyApp.p12 -t agg -k ~/Library/Keychains/build.keychain -P "" -A\cf4 \
\cf2 #\cf4 \
\cf2 #    security list-keychains -s ~/Library/Keychains/build.keychain\cf4 \
\cf2 #    security default-keychain -s ~/Library/Keychains/build.keychain\cf4 \
\cf2 #    security unlock-keychain -p "MyApp" ~/Library/Keychains/build.keychain\cf4 \
\cf2 #\cf4 \
\cf2 #    security set-key-partition-list -S apple-tool:,apple: -s -k "MyApp" ~/Library/Keychains/build.keychain\cf4 \
\cf2 #\}\cf4 \
\cf2 #\cf4 \
\cf2 ## Build\cf4 \
\cf2 #function build_app()\cf4 \
\cf2 #\{\cf4 \
\cf2 #    # dev environment\cf4 \
\cf2 #    echo "API_URL=\cf5 https://backend.$DOMAIN/\cf2 " > .env\cf4 \
\cf2 #\cf4 \
\cf2 #    # build number\cf4 \
\cf2 #    BUILD_NUMBER=$\{GITHUB_RUN_NUMBER:-1\}\cf4 \
\cf2 #\cf4 \
\cf2 #    # ExportOptions.plist\cf4 \
\cf2 #    sed -e "s/__BUILD_NUMBER__/$BUILD_NUMBER/g" \\\cf4 \
\cf2 #        -e "s/__PRODUCT_BUNDLE_IDENTIFIER__/$PRODUCT_BUNDLE_IDENTIFIER/g" \\\cf4 \
\cf2 #        -e "s/__CODE_SIGN_IDENTITY__/$CODE_SIGN_IDENTITY/g" \\\cf4 \
\cf2 #        .github/ios/ExportOptions.plist > ios/ExportOptions.plist\cf4 \
\cf2 #\cf4 \
\cf2 #    cd ios\cf4 \
\cf2 #\cf4 \
\cf2 #    set -e\cf4 \
\cf2 #    set -o pipefail\cf4 \
\cf2 #\cf4 \
\cf2 #    # archive\cf4 \
\cf2 #    xcodebuild archive \\\cf4 \
\cf2 #        -workspace MyApp.xcworkspace \\\cf4 \
\cf2 #        -scheme MyApp \\\cf4 \
\cf2 #        -sdk iphoneos13.2 \\\cf4 \
\cf2 #        -configuration Release \\\cf4 \
\cf2 #        -archivePath "$PWD/build/MyApp.xcarchive" \\\cf4 \
\cf2 #        PRODUCT_BUNDLE_IDENTIFIER="$PRODUCT_BUNDLE_IDENTIFIER" \\\cf4 \
\cf2 #        PROVISIONING_PROFILE="$PROVISIONING_PROFILE" \\\cf4 \
\cf2 #        CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \\\cf4 \
\cf2 #        CURRENT_PROJECT_VERSION="$BUILD_NUMBER"\cf4 \
\cf2 #\cf4 \
\cf2 #    # export\cf4 \
\cf2 #    xcodebuild \\\cf4 \
\cf2 #        -exportArchive \\\cf4 \
\cf2 #        -archivePath "$PWD/build/MyApp.xcarchive" \\\cf4 \
\cf2 #        -exportOptionsPlist "$PWD/ExportOptions.plist" \\\cf4 \
\cf2 #        -exportPath "$PWD/build"\cf4 \
\cf2 #\}\cf4 \
\cf2 #\cf4 \
\cf2 ## Upload artifacts\cf4 \
\cf2 #function upload_artifacts()\cf4 \
\cf2 #\{\cf4 \
\cf2 #    chmod 600 .github/ssh/id_rsa\cf4 \
\cf2 #    BUILD_PATH="www/app/builds/$GITHUB_RUN_NUMBER"\cf4 \
\cf2 #    ssh -i .github/ssh/id_rsa -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' \cf5 ubuntu@MyApp.dev\cf2  "mkdir -p $BUILD_PATH"\cf4 \
\cf2 #    scp -i .github/ssh/id_rsa -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -r ios/build/Apps/* \cf5 ubuntu@MyApp.dev\cf2 :$BUILD_PATH\cf4 \
\cf2 #    scp -i .github/ssh/id_rsa -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -r ios/build/manifest.plist \cf5 ubuntu@MyApp.dev\cf2 :$BUILD_PATH\cf4 \
\cf2 #\}\cf4 \
}