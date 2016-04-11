# Meteor on Dokku

## Use Case

This reference app (based on https://github.com/meteor/simple-todos) shows how to package up a Meteor app using Docker to be able to deploy to Dokku hosts. While there are other options floating around, such as Meteor-specific Heroku buildpacks, most of them result in lengthy deploy times.

## How it Works

A Docker "build" image is generated first based on your app's source. Then, a standard Dockerfile, which references the previous image, is kept in the project root. Both images should be uploaded to Docker Hub (or any Docker registry). When deploying to a Dokku host, these images are pulled down by Dokku.

**Why two images?**
The ```meteor build``` command often requires several minutes to perform its tasks, which can lead to an SSH timeout during the ```git push``` deploy step. By building the application image locally or within a CI environment, the deploy step takes very little time.

## Instructions

1. Create a [Dockerfile.build](Dockerfile.build) - this can be any Meteor base image that works for your own use case.

2. Build your image:
```
docker build -t namespace/mymeteorapp -f Dockerfile.build .
```

3. Push image to Docker Hub (or another registry):
```
docker push namespace/mymeteorapp
```

4. Create a [Dockerfile](Dockerfile) used for deployment. It should include the following statements:
```
FROM namespace/mymeteorapp
CMD node main.js
```

Now you can ```git push dokku master``` your app.

The first time you deploy, Dokku will pull down the base image represented in Dockerfile.build. But once this image is cached on the server, subsequent deploys will be a bit faster.

## SSL Configuration

Dokku has some limitations around SSL, Dockerfiles, and exposed ports - [see here](https://github.com/dokku/dokku/issues/2078). To use SSL in your application, just add a copy of [nginx.conf.sigil](nginx.conf.sigil) to the root of your application source and in your Dockerfile, add this line:
```
ADD nginx.conf.sigil /
```

Be sure you upload an SSL certificate as described in the [documentation](http://dokku.viewdocs.io/dokku~v0.5.4/deployment/ssl-configuration/).

## Public vs. Private Docker Images

If your Docker Hub application image is stored as "private," you'll need to run ```docker login``` on your Dokku host before deploying for the first time.
