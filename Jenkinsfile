pipeline {
    agent any
    environment {
        SCANNER_HOME = tool 'SonarQube Scanner'
    }
    stages {
        stage('Build') {
            steps {
                sh 'python3 -m py_compile app.py'
            }
        }
        stage('Test') {
            steps {
                sh '''python3 -c "from app import app; r = app.test_client().get('/hello?name=TEST'); assert b'TEST' in r.data; print('Test OK')"'''
            }
        }
        stage('Analyze') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "${SCANNER_HOME}/bin/sonar-scanner"
                }
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                    [ -f flask.pid ] && kill $(cat flask.pid) || true
                    BUILD_ID=dontKillMe JENKINS_NODE_COOKIE=dontKillMe FLASK_APP=app.py nohup flask run --host=0.0.0.0 --port=5000 > flask.log 2>&1 &
                    echo $! > flask.pid
                    sleep 5
                    curl -s "http://localhost:5000/hello?name=TEST"
                '''
            }
        }
        stage('Security Test') {
            steps {
                withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_KEY')]) {
                    dependencyCheck additionalArguments: "--scan . --format HTML --format XML --enableExperimental --nvdApiKey ${NVD_KEY}",
                                    odcInstallation: 'dependency-check'
                }
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
                sh '''
                    docker rm -f zap-scan || true
                    docker run --name zap-scan --network jenkins-net -v zap_wrk:/zap/wrk:rw \
                        ghcr.io/zaproxy/zaproxy:stable \
                        zap-full-scan.py -t "http://jenkins:5000/hello?name=test" -r zap-report.html -I -m 1 || true
                    docker cp zap-scan:/zap/wrk/zap-report.html zap-report.html
                    docker rm zap-scan
                '''
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'dependency-check-report.html, zap-report.html', allowEmptyArchive: true
        }
    }
}