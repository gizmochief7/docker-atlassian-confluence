#!/bin/sh

SERVER_XML="${ATL_HOME}/conf/server.xml"
SERAPH_XML="${ATL_HOME}/confluence/WEB-INF/classes/seraph-config.xml"
CROWD_PROPS="${ATL_HOME}/confluence/WEB-INF/classes/crowd.properties"

# Remove any previous proxy configuration.
sed -E 's/ proxyName="[^"]*"//g' -i "${SERVER_XML}"
sed -E 's/ proxyPort="[^"]*"//g' -i "${SERVER_XML}"
sed -E 's/ path="[^"]*"//g' -i "${SERVER_XML}"

# Remove any previous authentication configuration.
sed -E 's|(<auth[^>]*>)|<!-- \1 -->|g;s|<!-- <!--|<!--|g;s|--> -->|-->|g' \
    -i "${SERAPH_XML}"

# Add new proxy configuration if environment variables are set.
if [ ! -z "${TC_PROXYNAME}" ]; then
  sed -E "s|<Connector|<Connector proxyName=\"${TC_PROXYNAME}\"|g" \
      -i "${SERVER_XML}"
fi
if [ ! -z "${TC_PROXYPORT}" ]; then
  sed -E "s|<Connector|<Connector proxyPort=\"${TC_PROXYPORT}\"|g" \
      -i "${SERVER_XML}"
fi
sed -E "s|<Context|<Context path=\"${TC_ROOTPATH}\"|g" \
    -i "${SERVER_XML}"

# Configure authentication based on environment variables.
CONFLUENCE_AUTH="${CONFLUENCE_AUTH:-ConfluenceAuthenticator}"
sed -E "s|<!-- (<auth[^>]*${CONFLUENCE_AUTH}[^>]*>) -->|\1|g" \
    -i "${SERAPH_XML}"

# Set up Crowd SSO if using the Crowd SSO authenticator.
if [ "${CONFLUENCE_AUTH}" = "ConfluenceCrowdSSOAuthenticator" ]; then
    cat <<EOF > "${CROWD_PROPS}"
application.name            ${CROWD_APP_NAME}
application.password        ${CROWD_APP_PASS}
application.login.url       ${CROWD_BASE_URL}/console/
crowd.server.url            ${CROWD_BASE_URL}/services/
crowd.base.url              ${CROWD_BASE_URL}/
session.isauthenticated     session.isauthenticated
session.tokenkey            session.tokenkey
session.validationinterval  2
session.lastvalidation      session.lastvalidation
EOF
fi

exec "${ATL_HOME}/bin/start-confluence.sh" -fg
