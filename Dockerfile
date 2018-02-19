FROM java:8
MAINTAINER Wouter Hummelink <wouter.hummelink@ordina.nl>

ARG version=2.0.0
ENV VERSION=${version}
ADD target/spring-petclinic-${version}.jar /spring-petclinic-${version}.jar

EXPOSE [8080]

ENTRYPOINT ["/usr/bin/bash","-c" "/usr/bin/java -jar /spring-petclinic-${VERSION}.jar"]

