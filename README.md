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

3. Create a [Dockerfile](Dockerfile) used for deployment. It should include the following statements:
```
FROM namespace/mymeteorapp
EXPOSE 5000
ENV PORT 5000
CMD node main.js
```

4. ```docker push``` the above images to Docker Hub or similar.

Now you can ```git push dokku master``` your app.

The first time you deploy, Dokku will pull down the base image represented in Dockerfile.build. But once this image is cached on the server, subsequent deploys will be a bit faster. 

## Public vs. Private Docker Images

If your Docker Hub images are stored as "private," you'll need to run ```docker login``` on your Dokku host before deploying for the first time.
