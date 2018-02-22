// vim: ft=groovy
def pom = null
def version = null
def stagingPort = 32318
pipeline {
  agent { 
    kubernetes {
      cloud "kubernetes"
      label "builder"
      inheritFrom "docker"
      serviceAccount "jenkins"
      containerTemplate {
        name "jdk"
        image "whummelink/petclinic-build:2018.02.22"
        ttyEnabled true
        command "/bin/sh -c"
        args "cat"
      }
    } 
  }
  //{
    //kubernetes {
    // docker image maven:3.5
    // docker image docker with bind mount -or- buildah bud in privileged container
    //}
  //}
  stages {
    stage("Build") {
      steps {
        script {
          pom = readMavenPom file: 'pom.xml'
          version = pom.getVersion()
        }
        sh "./mvnw -B package -DskipTests"
      }
    }
    stage("Test") {
      steps {
        sh "./mvnw -B -e -DforkCount=0 test"
        junit "target/surefire-reports/*.xml"
        archive includes: "target/*.jar"
      }
    }
    stage("Create docker image") {
      environment {
        DOCKER = credentials("docker-login")
        DOCKER_REGISTRY = "docker.io"
        DOCKER_IMAGE = "spring-petclinic"
        POM_VERSION = "${version}"
      }
      steps {
        withEnv(["DOCKER_REGISTRY=docker.io","DOCKER_IMAGE=sprint-petclinic"]) {
          sh "echo '---- DOCKER BUILD ----'"
          sh "echo ${env.POM_VERSION}"
          sh "docker build -t ${env.DOCKER_REGISTRY}/${env.DOCKER_USR}/${env.DOCKER_IMAGE}:${env.POM_VERSION}-${env.BUILD_NUMBER} ."
          sh "docker login -u ${env.DOCKER_USR} -p ${env.DOCKER_PSW} ${env.DOCKER_REGISTRY}"
          sh "docker push ${env.DOCKER_REGISTRY}/${env.DOCKER_USR}/${env.DOCKER_IMAGE}:${env.POM_VERSION}-${env.BUILD_NUMBER}"
        }
      }
    }
    stage("Deploy to staging") {
      steps {
        // TODO: insert version number into deployment
        sh "sed 's/__VERSION__/${version}-${currentBuild.number}/' infra/staging/petclinic-deployment.yml | kubectl apply -f -" 
        sh "kubectl rollout status -n petclinic-staging deploy/spring-petclinic -w"
      }
    }
    stage("Test deployment in staging") {
      steps {
        sh "curl http://petclinic-svc.petclinic-staging.svc.cluster.local:${stagingPort}"
        // RUN a performance test using eg. Gatling here
      }
    }
    stage("Deploy to prod") {
      steps {
        // TODO: insert version number into deployment
        sh "sed 's/__VERSION__/${version}-${currentBuild.number}/' infra/production/petclinic-deployment.yml | kubectl apply -f -" 
      }
    }
  }
  post {
    always {
      archive includes: "target/surefire-reports/*"
      archive includes: "/tmp/**"
      sh "ls -lR"
    }
  }
}
