pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo 'Compilando el código...'
                sh 'python3 -m py_compile Codigo_No_Seg.py'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Ejecutando pruebas...'
                sh '''python3 -c "from Codigo_No_Seg import app; r = app.test_client().get('/hello?name=TEST'); assert b'TEST' in r.data; print('Test OK')"'''
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Desplegando la aplicación...'
                sh '''
                    # Levanta la app en segundo plano
                    BUILD_ID=dontKillMe JENKINS_NODE_COOKIE=dontKillMe FLASK_APP=Codigo_No_Seg.py nohup flask run --host=0.0.0.0 --port=5000 > flask.log 2>&1 &
                    echo $! > flask.pid
                    sleep 3
                    echo "App levantada en el puerto 5000"
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline finalizado.'
            archiveArtifacts artifacts: 'flask.log', allowEmptyArchive: true
        }
    }
}