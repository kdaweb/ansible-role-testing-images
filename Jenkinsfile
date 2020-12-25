pipeline {
  agent none

  parameters {
    string (
      name: 'repository_url',
      defaultValue: 'https://github.com/kdaweb/ansible-role-testing-images.git',
      description: 'the URL to the Git repository'
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
      defaultValue: 'kdaweb/ansible-%s-tester',
      description: 'the printf pattern used to generate a name for the images'
    )
  }

  environment {
    repository_url = "$params.repository_url"
    git_credential = "$params.git_credential"
    docker_credential = "$params.docker_credential"
    pattern = "$params.pattern"
  }

  triggers {
    pollSCM()
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

    stage('Setup') {
      matrix {
        agent any
        axes {
          axis {
            name 'PLATFORM'
            values 'alpine:latest', 'ubuntu:20.10', 'ubuntu:18.04', 'ubuntu:16.04', 'centos:7', 'centos:8'
          }
        }
      }
    }

    stage('Build') {
      steps {
        sh docker build -t "$(printf "$pattern" $PLATFORM)" -f "Dockerfile-$(echo "$PLATFORM" | tr -dc '[:alnum:]')".
      }
    }
  }
}
