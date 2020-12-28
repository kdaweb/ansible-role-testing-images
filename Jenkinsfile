pipeline {
  agent any

  parameters {
    string (
      name: 'repository_url',
      defaultValue: 'https://github.com/kdaweb/ansible-role-testing-images.git',
      description: 'the URL to the Git repository'
    )

    string (
      name: 'registry_url',
      defaultValue: 'https://docker.io/',
      description: 'the URL to the Docker registry where images will be pushed'
    )

    string (
      name: 'git_credential',
      defaultValue: 'github-wesley-dean',
      description: 'the ID of the credential to use to interact with GitHub'
    )

    string (
      name: 'docker_credential',
      defaultValue: 'dockerhub-wesleydean',
      description: 'the ID of the credential to use to interact with DockerHub'
    )

    string (
      name: 'pattern',
      defaultValue: 'kdaweb/ansible-tester-%s',
      description: 'the printf pattern used to generate a name for the images'
    )
  }

  environment {
    repository_url = "$params.repository_url"
    registry_url = "$params.registry_url"
    git_credential = "$params.git_credential"
    docker_credential = "$params.docker_credential"
    pattern = "$params.pattern"
  }

  triggers {
    pollSCM("@hourly")
  }

  options {
    timestamps()
    ansiColor('xterm')
  }

  stages {

    stage ('Checkout') {
      steps {
        git branch: 'master',
          credentialsId: git_credential,
          url: repository_url
      }
    }

    stage('Build') {
      matrix {
        agent any
        axes {
          axis {
            name 'PLATFORM'
            values 'alpine:latest', 'ubuntu:20.10', 'ubuntu:20.04', 'ubuntu:18.04', 'ubuntu:16.04', 'centos:7', 'centos:8'
          }
        }
        stages {
          stage('Build') {
            steps {
              script {
                def dockerfilename = sh (script: "echo Dockerfile-$PLATFORM | tr ':' '_'", returnStdout: true).trim()
                def imagetag = sh (script: "printf $pattern $PLATFORM", returnStdout: true).trim()
                docker.withRegistry("$registry_url", "$docker_credential") {
                  image = docker.build("$imagetag", "-f $dockerfilename .")
                  image.push("$PLATFORM")
                }
              }
            }
          }
        }
      }
    }
  }
}
