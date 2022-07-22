FROM apache/nifi:1.16.3

# Workspace is /opt/nifi/nifi-current

ARG STARDOG_VERSION_NUMBER=8.0.0
ARG TZ=Europe/Amsterdam

RUN echo "java.arg.8=-Duser.timezone=$TZ" >> conf/bootstrap.conf

RUN cd lib && \
    wget -q http://downloads.stardog.com/extras/stardog-extras-$STARDOG_VERSION_NUMBER.zip && \
    unzip stardog-extras-*.zip && \
    mv extras/nifi/* .