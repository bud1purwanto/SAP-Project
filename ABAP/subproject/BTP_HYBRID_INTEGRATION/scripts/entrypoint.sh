#!/bin/bash
set -e

mkdir -p /opt/sap/scc/scc_config /opt/sap/scc/config /opt/sap/scc/log /opt/sap/scc/work /opt/sap/scc/temp

if [ ! -f /opt/sap/scc/scc_config/SSFS_SCC.DAT ]; then
    echo "Generating initial Secure Storage and Keystore..."
    PASS=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 16)
    export LD_LIBRARY_PATH=/opt/sap/scc/lib/native:$LD_LIBRARY_PATH
    
    /opt/sap/scc/lib/native/initSecStore "$PASS" /opt/sap/scc/scc_config
    
    keytool -genkey -v -keyalg RSA -keysize 2048 -sigalg SHA256withRSA -alias tomcat -validity 842 -storetype PKCS12 -storepass "$PASS" -keystore /opt/sap/scc/config/ks.p12 -dname "CN=SCC, OU=Connectivity, O=SAP SE, C=DE"
    keytool -export -alias tomcat -keystore /opt/sap/scc/config/ks.p12 -storepass "$PASS" -storetype PKCS12 -file /opt/sap/scc/config/tmp.cert
    keytool -import -alias tomcattrust -file /opt/sap/scc/config/tmp.cert -keystore /opt/sap/scc/config/ks.p12 -storepass "$PASS" -storetype PKCS12 -noprompt
    rm -f /opt/sap/scc/config/tmp.cert
    echo "Secure storage and keystore created successfully."
fi

if [ ! -f /opt/sap/scc/config/users.xml ]; then
    echo "Restoring initial users.xml..."
    cat << 'EOF' > /opt/sap/scc/config/users.xml
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users>
  <role rolename="admin"/>
  <user username="Administrator" password="181229424893BB65D94A74C2132B8B9E5ADFE851464FDB5CB9F49E8A8204BE7B" roles="admin" groups="initial"/>
</tomcat-users>
EOF
    chmod 640 /opt/sap/scc/config/users.xml
fi

chown -R sccadmin:sccgroup /opt/sap/scc/scc_config /opt/sap/scc/config /opt/sap/scc/log /opt/sap/scc/work /opt/sap/scc/temp

cd /opt/sap/scc
echo "Launching SAP Cloud Connector..."
exec su -s /bin/bash sccadmin -c /opt/sap/scc/go.sh