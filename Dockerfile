FROM java:8
MAINTAINER Wouter Hummelink <wouter.hummelink@ordina.nl>

ARG version=2.0.0
ENV VERSION=${version}
ADD target/spring-petclinic-${version}.jar /spring-petclinic-${version}.jar
ADD infra/entrypoint.sh /entrypoint.sh

EXPOSE [8080]

ENTRYPOINT ["/entrypoint.sh"]

