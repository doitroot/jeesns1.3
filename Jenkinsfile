#!/usr/bin/env groovy

def projectProperties = [
        [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '5']],
        parameters([
            string(name: 'DOCKER_USER', defaultValue: 'admin', description: 'docker用户名'),
            string(name: 'DOCKER_PASSWORD', defaultValue: 'Root@123', description: 'docker用户密码'),
            string(name: 'REGISTRY_URL', defaultValue: '10.83.35.24', description: 'docker仓库地址')
        ])
]

properties(projectProperties)

def label = "mypod-${UUID.randomUUID().toString()}"

podTemplate(label: label, cloud: 'kubernetes', containers: [
            containerTemplate(name: 'maven', image: 'maven', command: 'cat', ttyEnabled: true),
            containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
            containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.10.2', command: 'cat', ttyEnabled: true)
            ],
            volumes: [
                    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
                    hostPathVolume(hostPath: '/root/.kube', mountPath: '/root/.kube'),
                    hostPathVolume(hostPath: '/root/.m2', mountPath: '/root/.m2')
            ],
            annotations: [
                    podAnnotation(key: "sidecar.istio.io/inject", value: "false")
            ]

) {

    node(label) {

        def gitCommit
        def shortGitCommit
        def previousGitCommit

        container('maven') {

            stage('checkout') {
                checkout scm

                sh 'printenv'

                gitCommit = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                shortGitCommit = "${gitCommit[0..10]}"
                previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)

                echo "gitCommit = ${gitCommit}"
                echo "shortGitCommit = ${shortGitCommit}"
                echo "previousGitCommit = ${previousGitCommit}"
            }

            stage('pacakge') {

                sh 'mvn clean package -Dmaven.test.skip=true -s ./settings.xml'
            }
        }

        container('docker') {

            stage('docker-login') {
                //REGISTRY_URL私有仓库地址，也可使用官方地址：docker.io
                sh "docker login -u ${params.DOCKER_USER} -p ${params.DOCKER_PASSWORD} ${params.REGISTRY_URL}"
            }

            stage('docker-build') {
                sh "docker build . -t ${params.REGISTRY_URL}/app/jeesns:${shortGitCommit}"
            }

            stage('docker-push') {
                sh "docker push ${params.REGISTRY_URL}/app/jeesns:${shortGitCommit}"
            }
        }


        container('kubectl') {
            stage('k8s deploy') {
                sh "sed -i \"s/app\\/jeesns/${params.REGISTRY_URL}\\/app\\/jeesns:${shortGitCommit}/g\" jeesns.yaml"
                sh "kubectl --kubeconfig=/root/.kube/config apply -f jeesns.yaml"
            }
        }

    }
}

// vim: ft=groovy