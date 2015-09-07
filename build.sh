#!/bin/sh

UPSTREAM_VER=4.3.3

SED_CMD="sed -i"
# For Mac OS X install gnu-sed from Homebrew or elsewhere, and use following SED_CMD
# SED_CMD="gsed -i"

UPDATE_UPSTREAM=1

if [ ${UPDATE_UPSTREAM} -eq 1 ]; then
  # Checkout svn repositories of core/client/cache
  echo "Downloading Upstream HttpCore"
  svn checkout https://svn.apache.org/repos/asf/httpcomponents/httpcore/tags/${UPSTREAM_VER}/httpcore/ httpcore
  echo "Downloading Upstream HttpClient"
  svn checkout https://svn.apache.org/repos/asf/httpcomponents/httpclient/tags/${UPSTREAM_VER}/httpclient/ httpclient
  echo "Downloading Upstream HttpClient-Cache"
  svn checkout https://svn.apache.org/repos/asf/httpcomponents/httpclient/tags/${UPSTREAM_VER}/httpclient-cache/ httpclient-cache
  echo "Downloading Upstream HttpMime"
  svn checkout https://svn.apache.org/repos/asf/httpcomponents/httpclient/tags/${UPSTREAM_VER}/httpmime/ httpmime
else
  echo "Skipping Upstream SVN update"
fi

PROJECTNAME=httpclient-android
PACKAGENAME=cz.msebera.httpclient.android
ROOTDIR=`pwd`
PACKAGEDIR=${ROOTDIR}/${PROJECTNAME}/src/main/java/${PACKAGENAME//./\/}
ANDROIDPROJECTPATH=${ROOTDIR}/${PROJECTNAME}
EXTRAPACKAGENAME=extras

echo "Project Settings:"
echo "PROJECTNAME         =  ${PROJECTNAME}"
echo "PACKAGENAME         =  ${PACKAGENAME}"
echo "ROOTDIR             =  ${ROOTDIR}"
echo "PACKAGEDIR          =  ${PACKAGEDIR}"
echo "ANDROIDPROJECTPATH  =  ${ANDROIDPROJECTPATH}"

rm -Rf ${ANDROIDPROJECTPATH}
mkdir -p ${PACKAGEDIR}

CLIENTDIR=`find . -type d | grep '/httpclient/src/main/java/org/apache/http$'`
CLIENTDEPRECATEDDIR=`find . -type d | grep '/httpclient/src/main/java-deprecated/org/apache/http$'`
CLIENTCACHEDIR=`find . -type d | grep '/httpclient-cache/src/main/java/org/apache/http$'`
CLIENTMIMEDIR=`find . -type d | grep '/httpmime/src/main/java/org/apache/http$'`
COREDIR=`find . -type d | grep '/httpcore/src/main/java/org/apache/http$'`
COREDEPRECATEDDIR=`find . -type d | grep '/httpcore/src/main/java-deprecated/org/apache/http$'`

echo "Copying upstream sources into correct directories"
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

echo "Removing ehcache and memcached implementations"
rm -rf ${PACKAGEDIR}/impl/client/cache/ehcache
rm -rf ${PACKAGEDIR}/impl/client/cache/memcached

echo "Adding extras, such as Base64, HttpClientAndroidLog and PRNGFixes"
echo "These are available from package ${PACKAGENAME}.${EXTRAPACKAGENAME}"
mkdir ${EXTRAPACKAGENAME}
cp -R ${ROOTDIR}/extras/* ${EXTRAPACKAGENAME}
cd ${EXTRAPACKAGENAME}
find . -name "*.java" -exec ${SED_CMD} "s/sedpackagename/${PACKAGENAME}.${EXTRAPACKAGENAME}/g" {} \;
cd ..

rm impl/auth/NegotiateScheme.java
rm impl/auth/NegotiateSchemeFactory.java
rm impl/auth/GGSSchemeBase.java
rm impl/auth/KerberosScheme.java
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

find . -name "*.java" -exec ${SED_CMD} "/commons\.codec\.binary\.Base64;/c import ${PACKAGENAME}\.${EXTRAPACKAGENAME}.Base64;" {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} "/private final Base64 base64codec;/c \/\* Base64 instance removed by HttpClient for Android script. \*\/" {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} "/this\.base64codec = new Base64(0);/c \/\* Base64 instance removed by HttpClient for Android script. \*\/" {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/Base64.encodeBase64(\([^;]*\));/Base64.encode(\1, Base64.NO_WRAP);/g;p;}' {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/base64codec.encode(\([^;]*\));/Base64.encode(\1, Base64.NO_WRAP);/g;p;}' {} +
find . -name "BasicScheme.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/EncodingUtils\.getBytes(tmp\.toString(), charset), false/EncodingUtils.getBytes(tmp.toString(), charset)/g;p;}' {} +
find . -name "NTLMEngineImpl.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/Base64.encodeBase64(resp)/Base64.encode(resp, Base64.NO_WRAP)/g;p;}' {} +
find . -name "*.java" -exec ${SED_CMD} -n '1h;1!H;${;g;s/Base64.decodeBase64(\([^;]*\));/Base64.decode(\1, Base64.NO_WRAP);/g;p;}' {} +

find . -name "*.java" -exec ${SED_CMD} "/commons\.logging\.Log;/c import ${PACKAGENAME}\.${EXTRAPACKAGENAME}\.HttpClientAndroidLog;" {} +
find . -name "*.java" -exec ${SED_CMD} "/commons\.logging\.LogFactory;/c \/\* LogFactory removed by HttpClient for Android script. \*\/" {} +
find . -name "*.java" -exec ${SED_CMD} 's/Log log/HttpClientAndroidLog log/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/Log headerlog/HttpClientAndroidLog headerlog/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/Log wirelog/HttpClientAndroidLog wirelog/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/private final HttpClientAndroidLog \(.*\) = LogFactory.getLog(\(.*\));/public HttpClientAndroidLog \1 = new HttpClientAndroidLog(\2);/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/private final Log \(.*\) = LogFactory.getLog(\(.*\));/public HttpClientAndroidLog \1 = new HttpClientAndroidLog(\2);/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/private final HttpClientAndroidLog log/public HttpClientAndroidLog log/g' {} +
find . -name "*.java" -exec ${SED_CMD} 's/LogFactory.getLog(\(.*\))/new HttpClientAndroidLog(\1)/g' {} +

echo "Replacing org.apache.http with ${PACKAGENAME}"
find . -name "*.java" -exec ${SED_CMD} "s/org\.apache\.http/${PACKAGENAME}/g" {} +
find . -name "*.html" -exec ${SED_CMD} "s/org\.apache\.http/${PACKAGENAME}/g" {} +

echo "Removing setSeed, use PRNGFixes.apply() in your code instead"
${SED_CMD} "s/this\.rnd\.setSeed(System\.currentTimeMillis());//g" impl/client/cache/BasicIdGenerator.java

echo "AndroidManifest.xml modification"
cd ${ANDROIDPROJECTPATH}
cp ../AndroidManifest.xml src/main/
${SED_CMD} "s/sedpackage/cz\.msebera\.httpclient\.android/g" src/main/AndroidManifest.xml

echo "Gradle build proceed"
cp ../build.gradle .
cp ../maven_push.gradle .
cp ../gradle.properties .
gradle assemble
