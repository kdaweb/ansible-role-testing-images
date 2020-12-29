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
      defaultValue: 'https://registry.hub.docker.com',
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
      name: 'ansible_version',
      defaultValue: '2.9',
      description: 'the version of Ansible to install'
    )

    string (
      name: 'pattern',
      defaultValue: 'wesleydean/ansible-%s-tester-%s',
      description: 'the printf pattern to use to name the images'
    )
  }

  environment {
    repository_url = "$params.repository_url"
    registry_url = "$params.registry_url"
    git_credential = "$params.git_credential"
    docker_credential = "$params.docker_credential"
    ansible_version = "$params.ansible_version"
    pattern = "$params.pattern"
  }

  triggers {
    pollSCM("H/15 * * * *")
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
            values 'alpine:3.12', 'ubuntu:20.10', 'ubuntu:20.04', 'ubuntu:18.04', 'ubuntu:21.04', 'centos:7', 'centos:8'
          }
        }

        stages {
          stage('Build') {
            steps {
              script {
                def dockerfilename = sh (script: "echo Dockerfile-$PLATFORM | tr ':' '_'", returnStdout: true).trim()
                def imagetag = sh (script: "printf $pattern $ansible_version $PLATFORM", returnStdout: true).trim()
                def build_date = sh (script: "date -u +'%Y-%m-%dT%H:%M:%SZ'", returnStdout: true).trim()
                docker.withRegistry("$registry_url", "$docker_credential") {
                  image = docker.build("$imagetag", "--build-arg ANSIBLE_VERSION=$ansible_version --build-arg BUILD_DATE=$build_date --build-arg VCSREF=$GIT_COMMIT -f $dockerfilename .")
                  image.push()
                }
              }
            }
          }
        }
      }
    }
  }
}
