// vim: ft=groovy
def pom = null
def version = null
def stagingPort = 32318
pipeline {
  agent { 
    label "jdk" 
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
          withEnv(["DOCKER_REGISTRY=docker.io","DOCKER_IMAGE=spring-petclinic", "POM_VERSION=${version}"]) {
            sh 'sudo buildah -t ${DOCKER_IMAGE}:${POM_VERSION}-${BUILD_NUMBER} .'
            withCredentials([usernamePassword(credentialsId: "docker-login", usernameVariable: "DOCKER_USERNAME", passwordVariable: "DOCKER_PASSWORD")]) {
              sh 'sudo buildah push --creds="${DOCKER_USERNAME}:${DOCKER_PASSWORD}" ${DOCKER_IMAGE}:${POM_VERSION}-${BUILD_NUMBER} docker://${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${DOCKER_IMAGE}:${POM_VERSION}-${BUILD_NUMBER}'
            }
          }
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
  // mvn build
  // mvn test
  // run jar and test port 8080
  // buildah bud Dockerfile
  // push docker image
  // deploy into kube
}
