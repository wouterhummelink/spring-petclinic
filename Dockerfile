FROM java:8
MAINTAINER Wouter Hummelink <wouter.hummelink@ordina.nl>

ARG version=2.0.0

ADD target/spring-petclinic-${version}.jar /spring-petclinic-${version}.jar

EXPOSE [8080]

ENTRYPOINT ["/usr/bin/java","-jar","/spring-petclinic-${version}.jar"]

