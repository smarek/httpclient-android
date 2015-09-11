# httpclient-android

Build script and dependencies to create repackaged upstream version of HttpClient and depdendencies (HttpMime, HttpCore, HttpClient-Cache) and get it working on Android API version from 3 to 23

Download the repository and simply hit `./build.sh` script

Required dependencies are:
  - JDK 6 or newer
  - Gradle 2.4 or newer
  - `find`, `grep`, `svn` and `sed` (or `gsed` for OS X)
  
This repository version will publish the library under namespace `cz.msebera.android.httpclient`

Using `gradle installArchives` will install the library to local Maven repository

Current version: **4.3.3-SNAPSHOT** (originating from upstream HttpClient 4.3.3 version)

Gradle dependency string, after having it installed

```gradle
dependencies {
  compile "cz.msebera.android.httpclient:httpclient-android:4.3.3-SNAPSHOT"
}
```

Or you can simply depend on it as on Gradle library, after `build.sh` script finishes successfully, like this:
```gradle
dependencies {
  compile project("httpclient-android")
}
```
