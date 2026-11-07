pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo 'Compilando el código...'
                // Si el archivo se llama app.py, cambialo aquí:
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
                    # Detiene cualquier instancia previa de Flask
                    [ -f flask.pid ] && kill $(cat flask.pid) || true
                    
                    # Levanta la app en segundo plano
                    BUILD_ID=dontKillMe JENKINS_NODE_COOKIE=dontKillMe FLASK_APP=Codigo_No_Seg.py nohup flask run --host=0.0.0.0 --port=5000 > flask.log 2>&1 &
                    echo $! > flask.pid
                    
                    # Espera unos segundos y prueba que responda
                    sleep 5
                    curl -s "http://localhost:5000/hello?name=TEST"
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline finalizado.'
            // Si quieres guardar el log de Flask como evidencia
            archiveArtifacts artifacts: 'flask.log', allowEmptyArchive: true
        }
    }
}