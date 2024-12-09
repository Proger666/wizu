pipeline {
    agent {
        kubernetes {
            yaml """
            kind: Pod
            metadata:
              namespace: jenkins
            spec:
              containers:
              - name: kaniko
                image: gcr.io/kaniko-project/executor:debug
                command:
                - /busybox/cat
                tty: true
                imagePullPolicy: Always
                volumeMounts:
                  - name: kaniko-secret
                    mountPath: /kaniko/.docker
                  - name: workspace-volume
                    mountPath: /workspace
              volumes:
                - name: kaniko-secret
                  secret:
                    secretName: nexus-registry
                    items:
                      - key: .dockerconfigjson
                        path: config.json
                - emptyDir:
                    medium: ""
                  name: workspace-volume
            """
        }
    }

    environment {
        APP_REPO_URL    = 'https://github.com/Proger666/tasky.git'
        CONFIG_REPO_URL = 'https://github.com/Proger666/wizu.git'
        ECR_REGISTRY    = '617850135881.dkr.ecr.us-east-2.amazonaws.com/prod-app'
        AWS_REGION      = 'us-east-2'
        GIT_CREDENTIALS = 'github-credentials'
        AWS_CREDENTIALS = 'aws-ecr-credentials'
        GOFLAGS = "-buildvcs=false"
    }

    stages {
        stage('Clone Application Repository') {
            steps {
                script {
                    git(url: "${APP_REPO_URL}", branch: 'main', credentialsId: "${GIT_CREDENTIALS}")
                }
            }
        }
        stage('Build and Push Docker Image to ECR') {
            steps {
                container('kaniko') {
                    script {
                        def imageTag = "latest-${env.BUILD_ID}"
                        withAWS(credentials: "${AWS_CREDENTIALS}", region: "${AWS_REGION}") {
                            def ecrImageTag = "${ECR_REGISTRY}:${imageTag}"
                            sh """
                                export GOFLAGS="-buildvcs=false"
                                /kaniko/executor --dockerfile=`pwd`/Dockerfile -c `pwd` \
                                --destination=${ecrImageTag} \
                                --cache=false \
                                --skip-tls-verify
                            """
                        }
                    }
                }
            }
        }
        stage('Update Image Tag and Repository in Helm Chart') {
            steps {
                script {
                    def imageTag = "latest-${env.BUILD_ID}"
                    def ecrImageTag = "${ECR_REGISTRY}:${imageTag}"

                    // Use GitHub token for authentication in git commands
                    withCredentials([string(credentialsId: "${GIT_CREDENTIALS}", variable: 'GIT_TOKEN')]) {
                        dir('config-repo') {
                            checkout([
                                $class: 'GitSCM',
                                branches: [[name: '*/master']],
                                userRemoteConfigs: [[
                                    url: "${CONFIG_REPO_URL}",
                                    credentialsId: "${GIT_CREDENTIALS}"
                                ]]
                            ])

                            sh """
                                sed -i 's|repository:.*|repository: ${ECR_REGISTRY}|' kubernetes/helm/webapp/values.yaml
                                sed -i 's|tag:.*|tag: "${imageTag}"|' kubernetes/helm/webapp/values.yaml
                                git config user.name "Proger666"
                                git config user.email "proger666@gmail.com"
                                git checkout -b update-image-${env.BUILD_ID}
                                git add kubernetes/helm/webapp/values.yaml
                                git commit -m "Update image repository to ${ECR_REGISTRY} and tag to ${imageTag}"
                                git push https://${GIT_TOKEN}@github.com/Proger666/wizu.git update-image-${env.BUILD_ID}
                            """
                        }
                    }
                }
            }
        }
    }
}