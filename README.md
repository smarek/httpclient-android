# httpclient-android [![Build Status](https://travis-ci.org/smarek/httpclient-android.svg)](https://travis-ci.org/smarek/httpclient-android)

Build script and dependencies to create repackaged upstream version of HttpClient and depdendencies (HttpMime, HttpCore, HttpClient-Cache) and get it working on Android API version from 3 to 23

Current version: **4.4.1.2** (originating from upstream HttpClient 4.4.1 version)

## Usage

Download the repository and simply hit `./build.sh` script

## Dependencies

Required dependencies are:
  - JDK 6 or newer
  - Gradle 2.4 or newer
  - `find`, `grep`, `svn`, `patch` and `sed` (or `gsed` for OS X)
  - for Kerberos support you need `Android NDK`, `git` and `swig`

## Configuration

Build params (ENV variables) you can use:
  - `USE_GRADLE_WRAPPER`, set to `0` if you want to use current Gradle from PATH
  - `UPDATE_UPSTREAM`, whether the build script should download SVN/GIT/... sources again (useful for recurring builds)
  - `SED_CMD` used variant of SED utility (default is `sed -i` on linux and `gsed -i` on Mac OS X)
  - `INCLUDE_JGSS_API`, **experimental**, whether to include Kerberos API and Negotiate, SPNego, GGS, Kerberos Auth schemes implementation
  - `VERBOSE`, set to `1` to get more verbose output

## Maven Central

This repository version will publish the library under namespace `cz.msebera.android:httpclient:4.4.1.2`

## Maven Local

*Using `gradle installArchives` will install the library to local Maven repository*

## Gradle

Gradle dependency string, once you have it installed

```gradle
dependencies {
  compile "cz.msebera.android:httpclient:4.4.1.2"
}
```

Or you can simply depend on the project, like this (`httpclient-android` is resulting Gradle project dir)
```gradle
dependencies {
  compile project("/path/to/generated/project/httpclient-android")
}
```
