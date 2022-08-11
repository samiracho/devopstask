ENV ?= local
TAG ?= latest

recreate-jenkins: build-jenkins down-jenkins up-jenkins
build-jenkins:
	cd docker-compose/jenkins/ && CURRENT_UID=$(id -u):$(id -g) docker-compose build --no-cache
down-jenkins:
	cd docker-compose/jenkins/ && CURRENT_UID=$(id -u):$(id -g) docker-compose down
up-jenkins: decrypt-secrets
	cd docker-compose/jenkins/ && CURRENT_UID=$(id -u):$(id -g) docker-compose up -d
decrypt-secrets:
	cd ansible && ansible-vault decrypt ../docker-compose/jenkins/secrets.env --output ../docker-compose/jenkins/secrets.decrypted.env

encrypt-secrets:
	cd ansible && ansible-vault encrypt ../docker-compose/jenkins/secrets.decrypted.env --output ../docker-compose/jenkins/secrets.env

recreate-app: build-app down-app up-app
build-app:
	ENV=$(ENV); \
	TAG=$(TAG); \
	cd docker-compose/app-devops-task/ && TAG=$$TAG ENV=$$ENV docker-compose -f docker-compose.yaml -f envs/$$ENV.yaml build --no-cache
down-app:
	ENV=$(ENV); \
	cd docker-compose/app-devops-task/ && docker-compose -f docker-compose.yaml -f envs/$$ENV.yaml -p $$ENV down
up-app:
	ENV=$(ENV); \
	TAG=$(TAG); \
	cd docker-compose/app-devops-task/ && TAG=$$TAG ENV=$$ENV docker-compose -f docker-compose.yaml -f envs/$$ENV.yaml -p $$ENV up -d

install-hooks:
	git config --local core.hooksPath .githooks/

destroy:
	cd terraform && terraform destroy