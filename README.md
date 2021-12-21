# Overview

SendGrid MailDev is [SengGrid mock API](https://github.com/yKanazawa/sendgrid-dev) + [MailDev](https://maildev.github.io/maildev/). 
For test your sendgrid emails during development. 

# Example of development

![](https://raw.githubusercontent.com/yKanazawa/sendgrid-maildev/master/img/example_of_development.png)

## Example of docker-compose.yml

The setting environment variables are default values.

```
version: '2'

services:
  sendgrid-maildev:
    image: ykanazawa/sendgrid-maildev
    hostname: sendgrid-maildev
    environment:
      - SENDGRID_DEV_API_SERVER=:3030
      - SENDGRID_DEV_API_KEY=SG.xxxxx
      - SENDGRID_DEV_SMTP_SERVER=127.0.0.1:1025
    container_name: sendgrid-maildev
    ports:
      - 1025:1025
      - 1080:1080
      - 3030:3030
```

## Example with curl

```
% docker exec -it sendgrid-maildev bash
# curl --request POST \
  --url http://127.0.0.1:3030/v3/mail/send \
  --header 'Authorization: Bearer SG.xxxxx' \
  --header 'Content-Type: application/json' \
  --data '{"personalizations": [{ 
    "to": [{"email": "to@example.com"}]}], 
    "from": {"email": "from@example.com"}, 
    "subject": "Test Subject", 
    "content": [{"type": "text/plain", "value": "Test Content"}] 
  }'
```

# Example of AWS

![](https://raw.githubusercontent.com/yKanazawa/sendgrid-maildev/master/img/example_of_aws.png)

# build memo

```bash
# docker desktop for windows build memo

DOCKER_TAG=kzfk/sendgrid-maildev
DOCKER_REV=1.0.0

# build env create and use setting
docker buildx create --name mybuilder --use

## docker image loading only(multiple platform build is not accept '--load')
docker buildx build --platform linux/amd64 \
  -t ${DOCKER_TAG}:latest -t ${DOCKER_TAG}:${DOCKER_REV} \
  --load --pull .
docker buildx build --platform linux/arm64 \
  -t ${DOCKER_TAG}:latest -t ${DOCKER_TAG}:${DOCKER_REV} \
  --load --pull .

## docker image direct registory push
docker buildx build --platform linux/amd64,linux/arm64 \
  -t ${DOCKER_TAG}:latest \
  -t ${DOCKER_TAG}:${DOCKER_REV} \
  --push --pull .

# docker registory image inspect
docker buildx imagetools inspect ${DOCKER_TAG}:latest
```
