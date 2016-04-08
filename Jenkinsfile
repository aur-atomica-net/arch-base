#!groovy

node {
    checkout scm

    stage 'Build Images'
    sh 'sudo /bin/sh ./build.sh'

    docker.withRegistry('https://index.docker.io/v1/', 'docker-jasonrm') {
        stage 'Push atomica/arch-base'
        def base = docker.image('atomica/arch-base')
        base.push()
    }

    docker.withRegistry('https://docker.artfire.me/', 'docker-artfire') {
        stage 'Push docker.artfire.me/atomica/arch-base'
        def base = docker.image('atomica/arch-base')
        base.push()
    }
}
