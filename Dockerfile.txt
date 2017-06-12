#######################################################################
# Creates a KHAN[apm] base image with JBoss EAP-6.4                   #
#######################################################################

# Use
#FROM registry.access.redhat.com/jboss-eap-6/eap64-openshift
FROM jboss-eap-6/eap64-openshift-euckr-ajp-oracle

USER 0

LABEL help="Please visit http://support.opennaru.com for more details." \
      run="Please visit http://support.opennaru.com for more details." \
      uninstall="Please visit http://support.opennaru.com for more details." \
      install="Please visit http://support.opennaru.com for more details." \
      stop="Please visit http://support.opennaru.com for more details."

LABEL Name="eap-openshift:6.4-khan-apm-5.0.2" \
      Version=1.0 \
      release=1.0 \
      architecture=Linux/x64 \
      build-date=2017-02-15T02:30:00-00:00 \
      vendor=Opennaru \
      url=http://www.opennaru.com \
      summary="EAP 6.4 builder image with KHAN [apm] Java agent" \
      description="This enhanced builder image allows EAP 6.4 applications to be monitored using KHAN [apm] java agent." \
      vcs-type=git \
      vcs-url=http://www.opennaru.com \
      vcs-ref= \
      authoritative-source-url= \
      distribution-scope=public \
      changelog-url=

ADD ./contrib/lsof-4.87-4.el7.x86_64.rpm /tmp
ADD ./contrib/net-tools-2.0-0.17.20131004git.el7.x86_64.rpm /tmp
RUN yum localinstall -y /tmp/lsof-4.87-4.el7.x86_64.rpm
RUN yum localinstall -y /tmp/net-tools-2.0-0.17.20131004git.el7.x86_64.rpm

ENV KHAN_AGENT_VERSION 5.0.2
#ENV KHAN_URL http://192.168.23.16/khan

RUN mkdir -p /opt/eap/khan-apm
ADD ./contrib/khan-agent-$KHAN_AGENT_VERSION.zip /opt/eap/
ADD ./contrib/openshift-launch.sh /opt/eap/bin/
RUN chmod u+x /opt/eap/bin/openshift-launch.sh
RUN chown jboss.jboss /opt/eap/bin/openshift-launch.sh
RUN unzip -q /opt/eap/khan-agent-$KHAN_AGENT_VERSION.zip -d /opt/eap/khan-apm && \
    chmod -R 777 /opt/eap/khan-apm && \
    rm -rf /opt/eap/khan-agent-$KHAN_AGENT_VERSION.zip

ADD ./contrib/khan-agent.conf /opt/eap/khan-apm/khan-agent/khan-agent.conf
ADD ./contrib/user-interceptor.conf /opt/eap/khan-apm/khan-agent/user-interceptor.conf

# Test Application
ADD ./contrib/session.war /opt/eap/standalone/deployments/
ADD ./contrib/standalone.conf /opt/eap/standalone/bin/

RUN chown -R jboss.jboss /opt/eap/standalone/deployments/session.war

USER 185

RUN chmod 755 /opt/eap/bin/openshift-launch.sh

