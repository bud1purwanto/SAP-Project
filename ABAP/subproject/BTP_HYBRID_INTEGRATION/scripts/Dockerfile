FROM rockylinux:9

RUN dnf install -y java-21-openjdk-headless procps-ng which && dnf clean all

RUN groupadd -r -g 1001 sccgroup && \
    useradd -r -u 1001 -d /opt/sap/scc -s /bin/bash -g sccgroup sccadmin

WORKDIR /tmp
COPY com.sap.scc-ui-2.19.2-8.x86_64.rpm /tmp/
RUN rpm -ivh --nodeps --noscripts /tmp/com.sap.scc-ui-2.19.2-8.x86_64.rpm && \
    rm -f /tmp/com.sap.scc-ui-2.19.2-8.x86_64.rpm && \
    chown -R sccadmin:sccgroup /opt/sap/scc

ENV JAVA_HOME=/usr/lib/jvm/jre-21-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

COPY entrypoint.sh /opt/sap/scc/entrypoint.sh
RUN chmod +x /opt/sap/scc/entrypoint.sh

WORKDIR /opt/sap/scc

EXPOSE 8443

ENTRYPOINT ["/opt/sap/scc/entrypoint.sh"]