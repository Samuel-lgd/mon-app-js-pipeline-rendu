FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
   && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg openjdk-17-jdk git sudo \
    && mkdir -p /usr/share/keyrings \
    && curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key \
       | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian binary/" \
       > /etc/apt/sources.list.d/jenkins.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends jenkins \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


ENV JENKINS_HOME=/var/lib/jenkins
EXPOSE 8080
VOLUME ["/var/lib/jenkins"]

# Ajout du droit sudo sans mot de passe pour jenkins
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN chown -R jenkins:jenkins /var/lib/jenkins /var/log/jenkins /var/cache/jenkins || true

USER jenkins
WORKDIR /var/lib/jenkins

CMD ["java", "-Djenkins.install.runSetupWizard=true", "-jar", "/usr/share/java/jenkins.war", "--httpPort=8080"]
