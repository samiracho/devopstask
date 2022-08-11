FROM jenkins/jenkins@sha256:c2b907959a7ce2b040eba65779a7e55b785819b2449c5eaa51f3b64fd3e0a03e

# Update packages & install dependencies
USER root

RUN apt-get update && apt-get upgrade -y \
	&& apt-get install -y curl openssl ca-certificates ca-certificates-java software-properties-common make \
	&& update-ca-certificates \
	&& curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey \
  && add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) \
      stable" \
  && apt-get update \
  && apt-get -y install docker-ce \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -f /var/cache/apt/*.bin

RUN curl -L \  
  "https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-$(uname -s)-$(uname -m)" \  
  -o /usr/local/bin/docker-compose \  
  && chmod +x /usr/local/bin/docker-compose

USER jenkins

# Skip the setup wizard
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false"

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --clean-download-directory --list --view-security-warnings -f /usr/share/jenkins/ref/plugins.txt

# Install certificate
USER root
RUN keytool -genkey -keyalg RSA -alias "localhost" -keystore "localhost.jks" -validity 365 -keysize 2048 -dname "CN=localhost, OU=OU_name, O=OU_name, L=city, ST=State_name, C=two_letter_country_code" -storepass changeit
USER jenkins

# Jenkins extra options
ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8443 --httpsKeyStore="localhost.jks" --httpsKeyStorePassword="changeit"
EXPOSE 8443