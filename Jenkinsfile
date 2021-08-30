#!groovy

import jenkins.model.*

properties([
    parameters([
        choice(
            name: 'parameter01',
            choices: ['one', 'two', 'three'],
            description: 'just a test parameter'
        ),
        string(
            defaultValue: "sample string parameter",
            name: 'StringCrunch',
            description: 'test string parameter',
            defaultValue: "string123"
        ),
        booleanParam(
            defaultValue: false,
            name: 'JOB_REFRESH',
            description: 'Refreshes the job by checking out jenkinsfile sourcecode adn updates the job'
        )
    ]),
    buildDiscarder(
        logRotator(
            numToKeepStr: '10'
        )
    )
])

ansicolor('xterm') {
    node ('master') {
        timestamps{
            try {
                //checkout source code for jenkins jobs
                stage('Checkout jenkins jobs source') {
                checkout scm: [
                    $class: 'GitSCM',
                    userRemoteConfigs:[[
                        url: "",
                        credentialsId: ""
                    ]],
                    branches: [[name: '*/main']],
                    extensions: [
                        [
                            $class: 'RelativeTargetDirectory'
                            RelativeTargetDir: "jenkins"
                        ],
                        [
                            $class: 'CloneOption',
                            noTags: true,
                            reference: '',
                            shallow: true
                        ]
                    ]
                ]
                }
                stage('Checkout terraform source code') {
                checkout scm: [
                    $class: 'GitSCM',
                    userRemoteConfigs:[[
                        url: "",
                        credentialsId: ""
                    ]],
                    branches: [[name: '*/main']],
                    extensions: [
                        [
                            $class: 'RelativeTargetDirectory'
                            RelativeTargetDir: "terraform"
                        ],
                        [
                            $class: 'CloneOption',
                            noTags: true,
                            reference: '',
                            shallow: true

                }
                stage('Terraform lint and validate') {
                    sh 'echo "validate terraform source code"'
                }

            } catch(Exception e) {
                currentBuild.result = "Failure"
                throw e;

            } finally {
            emailext body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}", subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}", to: 'test@test.com'
            }
        }
    }

