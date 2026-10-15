#!/usr/bin/env bash
# Upstream's CI/README build: jailbreak .debs, then the sideloaded IPA via theos-jailed
# (make SIDELOADED=1 IPA=...), plus a "noplugins" copy like upstream's releases.
source "$PIPELINE/lib/helpers.sh"
brew list libplist >/dev/null 2>&1 || brew install libplist   # plistutil, for theos-jailed
setup_theos
setup_theos_jailed level3tjg/theos-jailed

VERSION=$(sed -nE 's/^PACKAGE_VERSION = (.+)/\1/p' Makefile | head -1)

log "Rootless .deb"
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
log "Rootful .deb"
make clean package FINALPACKAGE=1
cp packages/*.deb "$OUT/"

log "Sideloaded IPA (Twitch $BASE_VERSION)"
make clean; rm -rf packages
make package FINALPACKAGE=1 SIDELOADED=1 IPA="$BASE_IPA" APP_VERSION="$BASE_VERSION"
IPA="$OUT/TwitchAdBlock_${BASE_VERSION}_v$VERSION.ipa"
cp "$(ls -t packages/*.ipa | head -1)" "$IPA"
cp "$IPA" "${IPA%.ipa}_noplugins.ipa"
ipa_remove "${IPA%.ipa}_noplugins.ipa" 'PlugIns/*'
