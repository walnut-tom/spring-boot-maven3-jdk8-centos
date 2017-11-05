# spring-boot-maven3-jdk8-centos
#
# This image provide a base for running Spring Boot based applications. It
# provides a base Java 8 installation and Maven 3.

FROM openshift/base-centos7

EXPOSE 8080

ENV JAVA_VERSON 1.8.0
ENV MAVEN_VERSION 3.5.2

RUN curl --insecure --junk-session-cookies --location --remote-name --silent --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/server-jre-8u152-linux-x64.tar.gz  && \
    mkdir -p /usr/java && \
    gunzip server-jre-8u152-linux-x64.tar.gz && \
    tar xf server-jre-8u152-linux-x64.tar -C /usr/java && \
    alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_152/bin/java 1 && \
    alternatives --install /usr/bin/jar  jar  /usr/java/jdk1.8.0_152/bin/jar  1 && \
    rm server-jre-8u152-linux-x64.tar

# download Java Cryptography Extension
RUN curl -LO "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" -H 'Cookie: oraclelicense=accept-securebackup-cookie' && \
    unzip jce_policy-8.zip && \
    rm jce_policy-8.zip && \
    yes |cp -v ./UnlimitedJCEPolicyJDK8/*.jar /usr/java/jdk1.8.0_152/jre/lib/security/

ENV JAVA_HOME=/usr/java/jdk1.8.0_152

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

RUN yum update -y && yum clean all && rm -rf /var/cache/yum

# Add configuration files, bashrc and other tweaks
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 /opt/app-root
USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage

RUN cat /etc/redhat-release

