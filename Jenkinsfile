#!groovy

node {
    checkout scm

    stage 'Build'
    sh 'sudo /bin/sh ./build.sh'

    def base = docker.image('atomica/arch-base:latest')

    base.inside("-u 0:0") {
        // Check if everything is working as root
        sh '/bin/true'
    }

    base.inside {
        // Check if everything is working as default user
        sh '/bin/true'
    }

    // docker.withRegistry('https://index.docker.io/v1/', 'docker-jasonrm') {
    //     stage 'Push to Docker Hub'
    //     base.push()
    // }

    // docker.withRegistry('https://docker.artfire.me/', 'docker-artfire') {
    //     stage 'Push to ArtFire'
    //     base.push()
    // }
}
