FROM jleight/atlassian-base:latest
MAINTAINER Jonathon Leight <jonathon.leight@jleight.com>

ENV APP_VERSION 5.8.10
ENV APP_BASEURL ${ATL_BASEURL}/confluence/downloads/binary
ENV APP_PACKAGE atlassian-confluence-${APP_VERSION}.tar.gz
ENV APP_URL     ${APP_BASEURL}/${APP_PACKAGE}
ENV APP_PROPS   confluence/WEB-INF/classes/confluence-init.properties

RUN set -x \
  && curl -kL "${APP_URL}" | tar -xz -C "${ATL_HOME}" --strip-components=1 \
  && mkdir -p "${ATL_HOME}/conf/Standalone" \
  && chmod -R 755 "${ATL_HOME}/temp" \
  && chmod -R 755 "${ATL_HOME}/logs" \
  && chmod -R 755 "${ATL_HOME}/work" \
  && chmod -R 755 "${ATL_HOME}/conf/Standalone" \
  && echo -e "\nconfluence.home=${ATL_DATA}" >> "${ATL_HOME}/${APP_PROPS}"

ADD confluence-service.sh /opt/confluence-service.sh

EXPOSE 8090
CMD ["/opt/confluence-service.sh"]
