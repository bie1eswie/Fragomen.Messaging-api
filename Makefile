export LAB_NAME=Messaging Service
export PROJECT_NAME=Fragomen.Messaging
export REPO_NAME=messaging_service
export ACCOUNT_NUMBER=$$(aws sts get-caller-identity --output  text --query 'Account')
export AWS_DEFAULT_REGION=us-east-1
export ECR_URL=381492107225.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
export ALB_URL=$$(terraform output -json | jq -r '.url.value')

# You should setup your credential inside the lab env
lab:
	docker build -t ${LAB_NAME} .		

repo:
	aws ecr create-repository --repository-name ${REPO_NAME}

login:
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_URL}

image:
	docker build --rm --pull -f Dockerfile -t ${REPO_NAME} .
	docker tag ${REPO_NAME}:latest ${ECR_URL}/${REPO_NAME}:latest
	docker push ${ECR_URL}/${REPO_NAME}:latest
	
infra:
	 cd infra

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply -auto-approve
	
test:
	curl http://alb-messaging-server-1015572302.us-east-1.elb.amazonaws.com

kill:
	terraform destroy -auto-approve infra
	aws ecr list-images --repository-name ${REPO_NAME} --query 'imageIds[*].imageDigest' --output text | while read imageId; do aws ecr batch-delete-image --repository-name ${REPO_NAME} --image-ids imageDigest=$$imageId; done
	aws ecr delete-repository --repository-name ${REPO_NAME}