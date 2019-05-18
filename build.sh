#!/bin/bash

export PROJECTNAME=httpclient-android
export PACKAGENAME=cz.msebera.android.httpclient
export ROOTDIR=`pwd`
export PACKAGEDIR=${ROOTDIR}/${PROJECTNAME}/src/main/java/${PACKAGENAME//./\/}
export ANDROIDPROJECTPATH=${ROOTDIR}/${PROJECTNAME}
export EXTRAPACKAGENAME=extras
export KERBEROS_LIB_NAME="kerberos"

export CORE_VER=4.4.11
export CLIENT_VER=4.5.8

: ${GRADLEW_VERSION:=2.14.1}
: ${GRADLE_COMMAND:="gradle"}
: ${SVN_COMMAND:="svn"}
: ${GIT_COMMAND:="git"}
: ${USE_GRADLE_WRAPPER:=1}
: ${UPDATE_UPSTREAM:=1}
: ${INCLUDE_JGSS_API:=0}
: ${VERBOSE:=0}

if [[ $OSTYPE == darwin* ]]; then
  # For Mac OS X install gnu-sed from Homebrew or elsewhere, and use following SED_CMD
  # SED_CMD="gsed -i"
  : ${SED_CMD:="gsed -i"}
else
  : ${SED_CMD:="sed -i"}
fi

# Android Experimental Gradle plugin 2.0 works now only with 2.5 version
if [ ${INCLUDE_JGSS_API} -eq 1 ]; then
  GRADLEW_VERSION=2.5
fi

if [ ${VERBOSE} -eq 2 ]; then
  VERBOSE=1 bash -x build.sh
  exit 0
elif [ ${VERBOSE} -ne 1 ]; then
  GRADLE_COMMAND="${GRADLE_COMMAND} -q"
  SVN_COMMAND="svn -q"
fi

if [ ${USE_GRADLE_WRAPPER} -eq 1 ]; then
  GRADLE_COMMAND="./gradlew"
else
  echo -e "INSTALLED GRADLE VERSION"
  echo -e "========================"
  gradle --version
  echo -e "========================"
fi

echo ">> Env Variables"
echo -e "UPDATE_UPSTREAM\t\t=\t${UPDATE_UPSTREAM}"
echo -e "INCLUDE_JGSS_API\t=\t${INCLUDE_JGSS_API}"
echo -e "SED_CMD\t\t\t=\t${SED_CMD}"
echo -e "USE_GRADLE_WRAPPER\t=\t${USE_GRADLE_WRAPPER}"
echo -e "GRADLE_COMMAND\t\t=\t${GRADLE_COMMAND}"
echo -e "SVN_COMMAND\t\t=\t${SVN_COMMAND}"
echo -e "GIT_COMMAND\t\t=\t${GIT_COMMAND}"
echo -e "VERBOSE\t\t\t=\t${VERBOSE}"
echo ""

if [ ${UPDATE_UPSTREAM} -eq 1 ]; then
  # Updating upstream code bases

  echo -e ">> Downloading Upstream HttpCore ${CORE_VER}"
  if [ -d "httpcore" ]; then
    rm -rf httpcore
  fi
  $GIT_COMMAND clone -b "${CORE_VER}" https://github.com/apache/httpcomponents-core.git httpcore

  echo -e ">> Downloading Upstream HttpClient ${CLIENT_VER}"
  if [ -d "httpclient" ]; then
    rm -rf httpclient
  fi
  $GIT_COMMAND clone -b "${CLIENT_VER}" https://github.com/apache/httpcomponents-client.git httpclient

  if [ ${INCLUDE_JGSS_API} -eq 1 ]; then
    echo -e ">> Downloading Java GSS-API wrapper for the MIT Kerberos GSS-API library"
    if [ ! -d "$KERBEROS_LIB_NAME" ]; then
      git clone https://github.com/cconlon/kerberos-android-ndk.git ${KERBEROS_LIB_NAME}
    else
      git -C ${KERBEROS_LIB_NAME} pull origin master
      git -C ${KERBEROS_LIB_NAME} reset --hard
    fi
  fi

else
  echo -e ">> Skipping Upstream sources update"
fi

echo ""
echo -e ">> Project Settings:"
echo -e "PROJECTNAME\t\t=\t${PROJECTNAME}"
echo -e "PACKAGENAME\t\t=\t${PACKAGENAME}"
echo -e "ROOTDIR\t\t\t=\t${ROOTDIR}"
echo -e "PACKAGEDIR\t\t=\t${PACKAGEDIR}"
echo -e "ANDROIDPROJECTPATH\t=\t${ANDROIDPROJECTPATH}"
echo ""

rm -rf ${ANDROIDPROJECTPATH}
mkdir -p ${PACKAGEDIR}

if [ ${USE_GRADLE_WRAPPER} -eq 1 ]; then
  cd ${PROJECTNAME}
  echo ""
  echo ">> Using Gradle Wrapper"
  CMD="gradle"
  if [ ${VERBOSE} -ne 1 ]; then
    CMD="gradle -q"
  fi
  ${CMD} wrapper --gradle-version ${GRADLEW_VERSION}
  cd ..
fi

export CLIENTDIR=`find . -type d | grep '/httpclient/src/main/java/org/apache/http$'`
export CLIENTDEPRECATEDDIR=`find . -type d | grep '/httpclient/httpclient/src/main/java-deprecated/org/apache/http$'`
export CLIENTCACHEDIR=`find . -type d | grep '/httpclient/httpclient-cache/src/main/java/org/apache/http$'`
export CLIENTMIMEDIR=`find . -type d | grep '/httpclient/httpmime/src/main/java/org/apache/http$'`
export COREDIR=`find . -type d | grep '/httpcore/httpcore/src/main/java/org/apache/http$'`
export COREDEPRECATEDDIR=`find . -type d | grep '/httpcore/src/main/java-deprecated/org/apache/http$'`

echo -e "CLIENTDIR\t\t=\t${CLIENTDIR}"
echo -e "CLIENTDEPRECATEDDIR\t=\t${CLIENTDEPRECATEDDIR}"
echo -e "CLIENTCACHEDIR\t\t=\t${CLIENTCACHEDIR}"
echo -e "CLIENTMIMEDIR\t\t=\t${CLIENTMIMEDIR}"
echo -e "COREDIR\t\t\t=\t${COREDIR}"
echo -e "COREDEPRECATEDDIR\t=\t${COREDEPRECATEDDIR}"

if [ ${INCLUDE_JGSS_API} -eq 1 ]; then
  export GSSJAVADIR=`find . -type d | grep "/$KERBEROS_LIB_NAME/src$"`
  export GSSNATIVEDIR=`find . -type d | grep "/$KERBEROS_LIB_NAME/jni$"`
  echo -e "GSSJAVADIR\t\t=\t${GSSJAVADIR}"
  echo -e "GSSNATIVEDIR\t\t=\t${GSSNATIVEDIR}"
fi

#bash
#exit

echo ">> Copying upstream sources into correct directories"
cd ${ROOTDIR}/${COREDIR}
cp -R * ${PACKAGEDIR}
cd ${ROOTDIR}/${COREDEPRECATEDDIR}
cp -R * ${PACKAGEDIR}
cd ${ROOTDIR}/${CLIENTDIR}
cp -R * ${PACKAGEDIR}
cd ${ROOTDIR}/${CLIENTDEPRECATEDDIR}
cp -R * ${PACKAGEDIR}
cd ${ROOTDIR}/${CLIENTCACHEDIR}
cp -R * ${PACKAGEDIR}
cd ${ROOTDIR}/${CLIENTMIMEDIR}
cp -R * ${PACKAGEDIR}

cd ${PACKAGEDIR}

echo ">> Removing ehcache and memcached implementations"
rm -rf ${PACKAGEDIR}/impl/client/cache/ehcache
rm -rf ${PACKAGEDIR}/impl/client/cache/memcached

echo ">> Adding extras, such as Base64, HttpClientAndroidLog and PRNGFixes"
echo ">> >> These are available from package ${PACKAGENAME}.${EXTRAPACKAGENAME}"
mkdir ${EXTRAPACKAGENAME}
cp -R ${ROOTDIR}/extras/* ${EXTRAPACKAGENAME}
cd ${EXTRAPACKAGENAME}
find . -name "*.java" -exec ${SED_CMD} "s/sedpackagename/${PACKAGENAME}.${EXTRAPACKAGENAME}/g" {} \;
cd ${PACKAGEDIR}

if [ ${INCLUDE_JGSS_API} -ne 1 ]; then

  rm impl/auth/NegotiateScheme.java
  rm impl/auth/NegotiateSchemeFactory.java
  rm impl/auth/GGSSchemeBase.java
  rm impl/auth/KerberosScheme.java
  rm auth/KerberosCredentials.java
  rm impl/auth/KerberosSchemeFactory.java
  rm impl/auth/SPNegoScheme.java
  rm impl/auth/SPNegoSchemeFactory.java

  find . -name "*.java" -exec ${SED_CMD} "/impl\.auth\.KerberosSchemeFactory;/c \/\* KerberosSchemeFactory removed by HttpClient for Android script. \*\/" {} +
  find . -name "*.java" -exec ${SED_CMD} "/impl\.auth\.SPNegoSchemeFactory;/c \/\* SPNegoSchemeFactory removed by HttpClient for Android script. \*\/" {} +
  find . -name "*.java" -exec ${SED_CMD} "/impl\.auth\.NegotiateSchemeFactory;/c \/\* NegotiateSchemeFactory removed by HttpClient for Android script. \*\/" {} +
  find . -name "ProxyClient.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/this.authSchemeRegistry.register([^)]*SPNegoSchemeFactory());/\/\* SPNegoSchemeFactory removed by HttpClient for Android script. \*\//g;p;}' {} +
  find . -name "ProxyClient.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/this.authSchemeRegistry.register([^)]*KerberosSchemeFactory());/\/\* KerberosSchemeFactory removed by HttpClient for Android script. \*\//g;p;}' {} +
  find . -name "AbstractHttpClient.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/registry.register([^)]*SPNegoSchemeFactory());/\/\* SPNegoSchemeFactory removed by HttpClient for Android script. \*\//g;p;}' {} +
  find . -name "AbstractHttpClient.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/registry.register([^)]*KerberosSchemeFactory());/\/\* KerberosSchemeFactory removed by HttpClient for Android script. \*\//g;p;}' {} +
  find . -name "AbstractHttpClient.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/registry.register([^)]*NegotiateSchemeFactory());/\/\* NegotiateSchemeFactory removed by HttpClient for Android script. \*\//g;p;}' {} +
  find . -name "HttpClientBuilder.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/.register([^)]*SPNegoSchemeFactory())/\/\* SPNegoSchemeFactory removed by HttpClient for Android script. \*\//g;p;}' {} +
  find . -name "HttpClientBuilder.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/.register([^)]*KerberosSchemeFactory())/\/\* KerberosSchemeFactory removed by HttpClient for Android script. \*\//g;p;}' {} +
  find . -name "HttpClientBuilder.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/.register([^)]*NegotiateSchemeFactory())/\/\* NegotiateSchemeFactory removed by HttpClient for Android script. \*\//g;p;}' {} +
else
  cd ${ROOTDIR}/${KERBEROS_LIB_NAME}
  swig -java -package edu.mit.jgss.swig -outdir ./src/edu/mit/jgss/swig -o ./jni/gsswrapper_wrap.c ./jni/gsswrapper.i
  cd ${ROOTDIR}/${GSSJAVADIR}
  cp -R edu ${PACKAGEDIR}
  cp -R org/ietf ${PACKAGEDIR}
  cd ${ROOTDIR}/${GSSNATIVEDIR}
  mkdir -p ${ANDROIDPROJECTPATH}/src/main/jni/
  cp -R * ${ANDROIDPROJECTPATH}/src/main/jni/
  cd ${PACKAGEDIR}
  find . -name "GssUtil.java" -exec ${SED_CMD} "s/new Boolean(second)\.toString();/Boolean.toString(second);/" {} +
  find . -name "GssUtil.java" -exec ${SED_CMD} "s/new Integer(second)\.toString();/Integer.toString(second);/" {} +
  find . -name "GGSSchemeBase.java" -exec ${SED_CMD} "/final Base64 base64codec = new Base64(0);/c \/\* Base64 instance removed by HttpClient for Android script. \*\/" {} +
  find . -name "GGSSchemeBase.java" -exec ${SED_CMD} "/private final Base64 base64codec;/c \/\* Base64 instance removed by HttpClient for Android script. \*\/" {} +
  find . -name "GGSSchemeBase.java" -exec ${SED_CMD} "/this\.base64codec = new Base64(0);/c \/\* Base64 instance removed by HttpClient for Android script. \*\/" {} +
  find . -name "GGSSchemeBase.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/base64codec.encode(\([^;]*\)));/Base64.encode(\1, Base64.NO_WRAP));/g;p;}' {} +
  find . -name "KerberosAppActivity.java" -exec rm {} +
  find . -name "edu_mit_kerberos_KerberosAppActivity.h" -exec rm {} +
fi

# sed rules for all types of calls in NTLMEngineImpl replaced with patch file
cd ${ANDROIDPROJECTPATH}
patch ${PACKAGEDIR}/impl/auth/NTLMEngineImpl.java ../patches/NTLMEngineImpl.java.patch.4.5.8

cd ${PACKAGEDIR}

find . -name "*.java" -exec ${SED_CMD} "/commons\.codec\.binary\.Base64;/c import ${PACKAGENAME}\.${EXTRAPACKAGENAME}.Base64;" {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} "/private final Base64 base64codec;/c \/\* Base64 instance removed by HttpClient for Android script. \*\/" {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} "/this\.base64codec = new Base64(0);/c \/\* Base64 instance removed by HttpClient for Android script. \*\/" {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/Base64.encodeBase64(\([^;]*\));/Base64.encode(\1, Base64.NO_WRAP);/g;p;}' {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/base64codec.encode(\([^;]*\));/Base64.encode(\1, Base64.NO_WRAP);/g;p;}' {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/EncodingUtils\.getBytes(tmp\.toString(), charset), false/EncodingUtils.getBytes(tmp.toString(), charset)/g;p;}' {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} "/final Base64 base64codec = new Base64(0);/c \/\* Base64 instance removed by HttpClient for Android script. \*\/" {} +
find . -name "NTLMEngineImpl.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/Base64.encodeBase64(resp)/Base64.encode(resp, Base64.NO_WRAP)/g;p;}' {} +
find . -name "*.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/Base64.decodeBase64(\([^,]*\))/Base64.decode(\1, Base64.NO_WRAP)/g;p;}' {} +

find . -name "*.java" -exec ${SED_CMD} "/commons\.logging\.Log;/c import ${PACKAGENAME}\.${EXTRAPACKAGENAME}\.HttpClientAndroidLog;" {} +
find . -name "*.java" -exec ${SED_CMD} "/commons\.logging\.LogFactory;/c \/\* LogFactory removed by HttpClient for Android script. \*\/" {} +
find . -name "*.java" -exec ${SED_CMD} "/javax\.naming/c \/\* Javax.Naming package removed by HttpClient for Android script. \*\/" {} +
find . -name "*.java" -exec ${SED_CMD} 's/Log log/HttpClientAndroidLog log/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/Log headerLog/HttpClientAndroidLog headerLog/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/Log wireLog/HttpClientAndroidLog wireLog/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/private final HttpClientAndroidLog \(.*\) = LogFactory.getLog(\(.*\));/public HttpClientAndroidLog \1 = new HttpClientAndroidLog(\2);/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/final Log \(.*\) = LogFactory.getLog(\(.*\));/final HttpClientAndroidLog \1 = new HttpClientAndroidLog(\2);/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/LogFactory.getLog(\(.*\))/new HttpClientAndroidLog(\1)/g' {} +

echo ">> Replacing org.apache.http with ${PACKAGENAME}"
find . -name "*.java" -exec ${SED_CMD} "s/org\.apache\.http/${PACKAGENAME}/g" {} +
echo ">> Removing two package.html files, blocking javadoc generation"
find . -name "package.html" -exec rm {} +
if [ ${INCLUDE_JGSS_API} -eq 1 ]; then
  echo ">> Replacing org.ietf.jgss with ${PACKAGENAME}.ietf.jgss"
  find . -name "*.java" -exec ${SED_CMD} "s/org\.ietf\.jgss/${PACKAGENAME}\.ietf\.jgss/g" {} +
  echo ">> Replacing edu.mit.jgss with ${PACKAGENAME}.edu.mit.jgss"
  find . -name "*.java" -exec ${SED_CMD} "s/edu\.mit\.jgss/${PACKAGENAME}\.edu\.mit\.jgss/g" {} +
fi

echo ">> Removing setSeed, use PRNGFixes.apply() in your code instead"
${SED_CMD} "s/this\.rnd\.setSeed(System\.currentTimeMillis());//g" impl/client/cache/BasicIdGenerator.java

echo ">> AndroidManifest.xml modification"
cd ${ANDROIDPROJECTPATH}
cp ../AndroidManifest.xml src/main/
${SED_CMD} "s/sedpackage/cz\.msebera\.httpclient\.android/g" src/main/AndroidManifest.xml

cd ${ANDROIDPROJECTPATH}
patch ${PACKAGEDIR}/conn/ssl/DefaultHostnameVerifier.java ../patches/DefaultHostnameVerifier.java.patch.4.5.3
patch ${PACKAGEDIR}/conn/ssl/AbstractVerifier.java ../patches/AbstractVerifier.java.patch.4.5.3
patch ${PACKAGEDIR}/conn/ssl/SSLConnectionSocketFactory.java ../patches/SSLConnectionSocketFactory.java.patch.4.5.3
find . -name '*.orig' -exec rm {} +
cp ../patches/DistinguishedNameParser.java ${PACKAGEDIR}/conn/ssl/

echo ">> Gradle build proceed"
if [ ${INCLUDE_JGSS_API} -eq 1 ]; then
  cp ../build_with_ndk.gradle build.gradle
else
  cp ../build.gradle .
fi
cp ../maven_push.gradle .
cp ../gradle.properties .

echo ""
echo ">> Assemble and install archives to local Maven repository"
echo ""

${GRADLE_COMMAND} installArchives

echo ""
echo ">> Finished"
echo ""
