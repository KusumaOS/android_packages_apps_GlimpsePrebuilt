#!/usr/bin/env bash
ANDROID_HOME="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)/android-sdk"
date_for_now_and_for_this_script_only="$(date +'%d-%m-%Y')"
latest_glimpse_commit_hash_for_me_only="$(git ls-remote https://github.com/LineageOS/android_packages_apps_Glimpse HEAD | sed 's/HEAD//')"

if ! [ -d "./Glimpse" ]; then
echo "Cloning Glimpse from LineageOS ..."
if ! git clone --depth=1 https://github.com/LineageOS/android_packages_apps_Glimpse Glimpse; then
echo "Cloning failed!"
exit 1
fi
fi

if ! [ -d "./android-sdk" ]; then
mkdir android-sdk
echo "Downloading Android SDK from Google ..."
if ! wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/1.zip; then
echo "Downloading failed!"
exit 1
fi
echo "Extracting Android SDK locally ..."
unzip -qo /tmp/1.zip -d android-sdk
rm /tmp/1.zip
if ! [ -d "./android-sdk/build-tools" ] || [ -d "./android-sdk/platforms" ]; then
echo "Fetching platforms;android-34 and build-tools;34.0.0 ..."
if ! yes | ./android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=./android-sdk "platforms;android-34" "build-tools;34.0.0"; then
echo "Fetching failed ..."
exit 1
fi
fi
fi

sed -i 's/targetSdk\s=\s34/targetSdk = 33/g' Glimpse/app/build.gradle.kts
cd Glimpse
echo "Generating blueprint ..."
if ! ./gradlew app:generateBp; then
echo "Generating failed ..."
exit 1
fi
echo "Building Glimpse ..."
if ! ./gradlew app:assembleRelease; then
echo "Building failed ..."
exit 1
fi
cd ..
cp Glimpse/app/build/outputs/apk/release/app-release-unsigned.apk .
echo "Finished! This is your commit message:"
echo "Update Glimpse as $date_for_now_and_for_this_script_only and $latest_glimpse_commit_hash_for_me_only"
