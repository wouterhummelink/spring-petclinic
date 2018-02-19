def pom = null
pipeline {
  agent any //{
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
        }
        sh "./mvnw package -DskipTests"
      }
    }
    stage("Test") {
      steps {
        sh "./mvnw test"
        junit "target/surefire-reports/*.xml"
      }
    }
    stage("Create docker image") {
      steps {
        script {
          def version = pom.getVersion()
          withEnv(["DOCKER_REGISTRY=docker.io","DOCKER_IMAGE=spring-petclinic", "POM_VERSION=${version}"]) {
            sh "sudo buildah bud -t ${DOCKER_IMAGE}:${POM_VERSION}-${JENKINS_BUILD} ."
            withCredentials(credentialsId: "docker-login", usernameVariable: "DOCKER_USERNAME", passwordVariable: "DOCKER_PASSWORD"
            sh 'sudo buildah push --creds="${DOCKER_USERNAME}:${DOCKER_PASSWORD}" ${DOCKER_IMAGE}:${POM_VERSION}-${JENKINS_BUILD} docker://${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${DOCKER_IMAGE}:${POM_VERSION}-${JENKINS_BUILD}'
          }
        }
      }
    }
    stage("Deploy to staging") {
      steps {
        // TODO: insert version number into deployment
        sh "kubectl apply -f staging/pet-clinic-deployment.yml"
      }
    }
    stage("Test deployment in staging") {
      steps {
        sh "curl http://petclinic-svc.petclinic-staging.svc.cluster.local:8080"
        // RUN a performance test using eg. Gatling here
      }
    }
    stage("Deploy to prod") {
      steps {
        // TODO: insert version number into deployment
        sh "kubectl apply -f production/pet-clinic-deployment.yml"
      }
    }
  }
  // mvn build
  // mvn test
  // run jar and test port 8080
  // buildah bud Dockerfile
  // push docker image
  // deploy into kube
}
