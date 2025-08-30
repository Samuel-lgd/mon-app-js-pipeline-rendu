# Rendu TP : Installation et configuration de Jenkins via Docker

## 1. Construction de l'image Docker Jenkins
- Création d'un Dockerfile adapté (Ubuntu 22.04, installation de Java 17, Jenkins et git).
- Build de l'image :
  ```powershell
  docker build -t jenkins-ubuntu -f "Rendu cours/Dockerfile" .
  ```

## 2. Lancement du conteneur Jenkins
- Démarrage du conteneur avec persistance des données :
  ```powershell
  docker run -d --name jenkins -p 8080:8080 -v jenkins_home:/var/lib/jenkins jenkins-ubuntu
  ```

## 3. Récupération du mot de passe administrateur Jenkins
- Pour obtenir le mot de passe initial (nécessaire à la première connexion) :
  ```powershell
  docker exec jenkins cat /var/lib/jenkins/secrets/initialAdminPassword
  ```

## 4. Paramétrage de Jenkins et création d'une pipeline
- Configuration initiale via l'interface web (http://localhost:8080).
- Création d'une nouvelle pipeline Jenkins :
  - Pull du repository : `https://github.com/formationrossignol/jenkins-minimal.git` sur la branche `main`.
  - Lancement d'une exécution de test.

## 5. Difficultés rencontrées
- L'image de base ne contenait pas git, ce qui provoquait une erreur lors du clonage du repository dans Jenkins (erreur Java peu explicite), j'ai donc un peu cherché avant de comprendre qu'il fallait ajouter git dans le Dockerfile.