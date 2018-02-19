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
          pom = readMavenPom('pom.xml')
        }
        sh "mvn package -DskipTests"
      }
    }
    stage("Test") {
      sh "mvn test"
      junit "target/surefire-reports/*.xml"
    }
    stage("Smoke test") {
      // make sure it runs
      sh "mvn spring-boot:start"
    }
    stage("Create docker image") {
      // version = <POM_VERSION>?
      sh "docker build -t <repository-url>/<username>/<imagename>:<version>-<jenkins-buildnumber> ."
      sh "docker push" 
    }
    stage("Deploy to staging") {
      // TODO: insert version number into deployment
      sh "kubectl apply -f staging/pet-clinic-deployment.yml"
    }
    stage("Test deployment in staging") {
      sh "curl http://petclinic-staging.staging.svc.cluster.local:8080"
    }
    stage("Deploy to prod") {
      // TODO: insert version number into deployment
      sh "kubectl apply -f production/pet-clinic-deployment.yml"
    }
  }
  // mvn build
  // mvn test
  // run jar and test port 8080
  // buildah bud Dockerfile
  // push docker image
  // deploy into kube
}
