FROM fedora:27
MAINTAINER Wouter Hummelink <wouter.hummelink@ordina.nl>
ADD kubernetes.repo /etc/yum.repos.d/kubernetes.repo
RUN dnf -y install java-1.8.0-openjdk-devel docker kubectl git && dnf clean all
ENV JAVA_HOME=/etc/alternatives/java_sdk

