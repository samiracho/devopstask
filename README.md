 # Introduction:
This project creates all the infrastructure needed to build & deploy a dockerized microservice with a REST api. The only path available is `http://EC2_SERVER:9000/jokes`. It returns the last 100 jokes from bash.org.pl in JSON format.
The project has been developed in a linux machine with Debian 11.
## Project dependencies:
- docker 20.10.17
- docker-compose 2.9.0
- aws-cli 2.2.43
- ansible 2.13.2
- terraform 1.2.4
- golang 1.18

### Project Setup:
Create a file ansible/.vault_pass and set the vault password
Add your AWS credentials e.g:
``` sh
export AWS_ACCESS_KEY_ID="AJDJSFHSDJHSDJHSDBF"
export AWS_SECRET_ACCESS_KEY="SLJKSFJHSFEFBNFBFDFBSF"
``` 
Run `./create-infrastructure.sh` to generate all required resources

### Run the REST api locally:
```sh
make recreate-app
```
### To query the api:
```sh
curl localhost:9000/jokes
```

Run Jenkins locally:
```sh
make recreate-jenkins
```

### To build the app for different environments:
```sh
ENV=develop TAG=mytag make build-app
```

## Jenkins multibranch pipeline:
A multibranch pipeline will be automatically generated in jenkins when the infrastructure gets created.
develop branch will be deployed in: 
`https://EC2_INSTANCE_DNS:9000`
release branch will be deployed in:
`https://EC2_INSTANCE_DNS:9001`
main branch will be deployed in:
`https://EC2_INSTANCE_DNS:9002`

Once a PR is merged into the main branch, the Jenkins pipeline will tag the repo with Semantic versioning, increasing the patch version. The major and minor versions can be incremented specifying the text #major or #minor in commit message. 

### Project structure:
```
|-- ansible: Ansible playbook to setup the EC2 machine
|-- app-devops-task: Golang app that exposes a REST api in localhost:9000/jokes
|-- docker-compose: Docker compose templates to deploy the api and Jenkins
|-------- app: Docker compose template for deploying the REST api
|-------- jenkins: Docker compose template for deploying Jenkins
|-------------- secrets.env Contains an ansible vault with passwords
|
|-- terraform: IAC to create a VPC, IGW, Public subnet, Security Group and EC2 instance. 
               It launches the ansible playbook too. 
```

### Tech Task description:
Create a microservice serving REST API with GET calls returning 100
jokes starting from the newest from bash.org.pl in JSON format;
service must be created and launched in Docker container.
Create Terraform code for provisioning custom VPC + EC2 and proper
Security Groups to allow access to the services from the Internet
using specific port (for example to execute curl to get the response
or reach Jenkins)
Create Ansible playbook to install required libraries, os updates and
tools on the EC2 instance and Jenkins before the microservice
deployment
Deploy the microservice on AWS EC2 using CI/CD (Jenkins) and gitflow.
Jenkins can be installed on the same instance as the microservice.
Place all codes for Terraform, Ansible and the microservice on Github
repository + access to Jenkins for the verification.