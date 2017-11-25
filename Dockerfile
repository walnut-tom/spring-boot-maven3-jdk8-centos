# spring-boot-s2i
#
# This image provide a base for running Spring Boot based applications. It
# provides a base Java 8 installation and Maven 3.

FROM centos/s2i-core-centos7

MAINTAINER hetao <walnut_tom@qq.com>

LABEL io.k8s.description="Platform for building and running Spring Boot applications" \
	io.k8s.display-name="Spring Boot Maven 3" \
	io.openshift.expose-services="8080:http" \
	io.openshift.tags="builder,java,java8,maven,maven3,spring-boot" \
	io.openshift.s2i.destination="/opt/app"

ENV LANG C.UTF-8
ENV JAVA_VERSON 1.8.0
ENV MAVEN_VERSION 3.5.2

RUN curl -fsSL http://mirror.bit.edu.cn/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

RUN yum update -y && yum install java-${JAVA_VERSON}-openjdk-devel && yum clean all && rm -rf /var/cache/yum

ENV HOME /opt/app-root/src
ENV MAVEN_HOME /usr/share/maven
ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VERSON}-openjdk
ENV PATH ${HOME}/bin:$PATH:${JAVA_HOME}/jre/bin:${JAVA_HOME}/bin:${MAVEN_HOME}/bin

# Add configuration files, bashrc and other tweaks
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 /opt/app-root
USER 1001

EXPOSE 8080

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage

RUN cat /etc/redhat-release

