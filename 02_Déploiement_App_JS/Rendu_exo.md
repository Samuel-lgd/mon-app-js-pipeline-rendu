# Rendu TP : Déploiement d'une Application JavaScript avec Jenkins

## 1. Préparation et configuration
- L'application JavaScript est hébergée sur : https://github.com/Samuel-lgd/mon-app-js-pipeline.git
- Installation du plugin NodeJS dans Jenkins pour gérer les dépendances Node.js
- Ajout de Jenkins dans la liste des sudoers pour permettre la gestion des fichiers dans le conteneur

**note : j'ai laissé une copie du Jenkinsfile modifié dans ce repository, c'est le même qui est utilisé dans le déploiement**

## 2. Modifications apportées à la pipeline Jenkins
- Ajout du plugin NodeJS dans la configuration
- Correction du stage "Run Tests" pour que les tests unitaires passent
- Mise à jour de la phase de déploiement pour utiliser un serveur web simple (Nginx ou Python HTTP)
- Amélioration du health check pour vérifier l'accessibilité du serveur web

## 3. Modifications du Dockerfile
- Ajout de Nginx et Python pour servir l'application
- Exposition du port 3000 pour accéder à l'application déployée
- Création du répertoire de déploiement et droits pour Jenkins

## 4. Déploiement et commandes utilisées
- Reconstruction du conteneur Jenkins avec les nouvelles dépendances :
  ```powershell
  docker rm -f jenkins
  docker build -t jenkins-ubuntu -f Dockerfile .
  docker run -d --name jenkins -p 8080:8080 -p 3000:3000 -v jenkins_home:/var/lib/jenkins jenkins-ubuntu
  ```

## 5. Difficultés rencontrées
- Jenkins ne pouvait pas déplacer les fichiers sans droits sudo, d'où la modification des sudoers
- L'image de base ne contenait pas de serveur web, ce qui empêchait le déploiement local
- Solution rapide et efficace mais non recommandée pour la production (sécurité, robustesse)

## 6. Liens
- Jenkins accessible sur : http://localhost:8080
- Application déployée accessible sur : http://localhost:3000