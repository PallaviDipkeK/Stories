#!/bin/sh
set -eo pipefail

git update-index --chmod=+x ./.github/scripts/decrypt_secrets.sh

gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS" --output ./.github/secrets/Open_Dev_Profile.mobileprovision ./.github/secrets/Open_Dev_Profile.mobileprovision.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEYS" --output ./.github/secrets/Certificates.p12 ./.github/secrets/Certificates.p12.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles


cp ./.github/secrets/Open_Dev_Profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/Open_Dev_Profile.mobileprovision


security create-keychain -p "" build.keychain
security import ./.github/secrets/Certificates.p12 -t agg -k ~/Library/Keychains/build.keychain -P "" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain

security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain

#export SECRET_KEY=$1
#    decrypt .github/secrets/Open_Dev_Profile.mobileprovision.encrypted
#    decrypt .github/secrets/Certificates.p12.encrypted
#    decrypt .github/ssh/id_rsa.encrypted
#/Users/pallavi.dipke/Documents/StoriesSDK/.github/secrets/archive_app.sh
