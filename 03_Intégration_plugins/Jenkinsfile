pipeline {
    agent any

    tools { nodejs 'NodeJS-18' }
    
    environment {
        NODE_VERSION = '18'
        APP_NAME = 'mon-app-js'
        DEPLOY_DIR = '/var/www/html'
        APP_PORT = '3000'
    }

    parameters {
        choice(
            choices: ['dev', 'staging', 'prod'],
            description: 'Environnement de déploiement',
            name: 'ENVIRONMENT'
        )
        booleanParam(
            defaultValue: false,
            description: 'Ignorer les tests ?',
            name: 'SKIP_TESTS'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Récupération du code source...'
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo 'Installation des dépendances Node.js...'
                sh '''
                    node --version
                    npm --version
                    npm ci
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Exécution des tests...'
                sh 'npm test'
            }
            post {
                always {
                    junit testResults: 'test-results.xml', allowEmptyResults: true
                }
            }
        }

        
        stage('Code Quality Check') {
            steps {
                echo 'Vérification de la qualité du code...'
                sh '''
                    echo "Vérification de la syntaxe JavaScript..."
                    find src -name "*.js" -exec node -c {} \\;
                    echo "Vérification terminée"
                '''
            }
        }

        stage('Show Environment') {
            steps {
                echo 'Affichage des variables d\'environnement...'
                echo "BRANCH_NAME=${env.BRANCH_NAME}"
                echo "GIT_BRANCH=${env.GIT_BRANCH}"
                sh 'printenv'
            }
        }
    
        stage('Build') {
            steps {
                echo 'Construction de l\'application...'
                sh '''
                    npm run build
                    ls -la dist/
                '''
            }
        }
        
        stage('Security Scan') {
            steps {
                echo 'Analyse de sécurité...'
                sh '''
                    echo "Vérification des dépendances..."
                    npm audit --audit-level=high
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                expression { env.ENVIRONMENT == 'prod' }
            }
            steps {
                echo 'Déploiement vers la production...'
                sh '''
                    echo "Arrêt du serveur précédent s'il existe..."
                    pkill -f "python3 -m http.server" || true
                    
                    echo "Sauvegarde de la version précédente..."
                    if [ -d "${DEPLOY_DIR}" ]; then
                        cp -r ${DEPLOY_DIR} ${DEPLOY_DIR}_backup_$(date +%Y%m%d_%H%M%S) || true
                    fi

                    echo "Déploiement de la nouvelle version..."
                    mkdir -p ${DEPLOY_DIR}
                    cp -r dist/* ${DEPLOY_DIR}/

                    echo "Démarrage du serveur web sur le port ${APP_PORT}..."
                    cd ${DEPLOY_DIR}
                    nohup python3 -m http.server ${APP_PORT} > /tmp/webserver.log 2>&1 &
                    echo $! > /tmp/webserver.pid
                    
                    echo "Attente du démarrage du serveur..."
                    sleep 3

                    echo "Vérification du déploiement..."
                    ls -la ${DEPLOY_DIR}
                    echo "Serveur web démarré sur le port ${APP_PORT}"
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Vérification de santé de l\'application...'
                script {
                    try {
                        sh '''
                            echo "Test de connectivité sur le port ${APP_PORT}..."
                            
                            # Vérification que le serveur répond
                            for i in {1..10}; do
                                if curl -f http://localhost:${APP_PORT}/ > /dev/null 2>&1; then
                                    echo "Application accessible sur http://localhost:${APP_PORT}"
                                    echo "Déploiement réussi !"
                                    break
                                else
                                    echo "Tentative $i/10 - En attente..."
                                    sleep 2
                                fi
                                
                                if [ $i -eq 10 ]; then
                                    echo "L'application ne répond pas après 10 tentatives"
                                    exit 1
                                fi
                            done
                        '''
                    } catch (Exception e) {
                        currentBuild.result = 'UNSTABLE'
                        echo "Warning: Health check failed: ${e.getMessage()}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Nettoyage des ressources temporaires...'
            sh '''
                rm -rf node_modules/.cache
                rm -rf staging
            '''
        }

        success {
            slackSend(
                channel: '#jenkins-deployments',
                color: 'good',
                message: "Build réussi !",
                attachments: [[
                    title: "Build ${env.BUILD_NUMBER} - ${env.JOB_NAME}",
                    titleLink: "${env.BUILD_URL}",
                    fields: [
                        [title: 'Branche', value: "${env.BRANCH_NAME}", short: true],
                        [title: 'Commit', value: "${env.GIT_COMMIT[0..7]}", short: true],
                        [title: 'Durée', value: "${currentBuild.durationString}", short: true]
                    ],
                    actions: [
                        [
                            type: "button",
                            text: "Voir dans Blue Ocean",
                            url: "${env.BUILD_URL}display/redirect"
                        ]
                    ]
                ]]
            )
        }
        
        failure {
            slackSend(
                channel: '#jenkins-deployments',
                color: 'danger',
                message: "Build échoué !",
                attachments: [[
                    title: "Build ${env.BUILD_NUMBER} - ${env.JOB_NAME}",
                    titleLink: "${env.BUILD_URL}",
                    fields: [
                        [title: 'Branche', value: "${env.BRANCH_NAME}", short: true],
                        [title: 'Commit', value: "${env.GIT_COMMIT[0..7]}", short: true],
                        [title: 'Durée', value: "${currentBuild.durationString}", short: true]
                    ],
                    actions: [
                        [
                            type: "button",
                            text: "Voir dans Blue Ocean",
                            url: "${env.BUILD_URL}display/redirect"
                        ]
                    ]
                ]]
            )
        }
    }
}