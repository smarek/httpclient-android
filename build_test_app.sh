#!/bin/bash

unset ANDROID_NDK_HOME
unset ANDROID_NDK_ROOT

cd testing-android-app
./gradlew assemble
