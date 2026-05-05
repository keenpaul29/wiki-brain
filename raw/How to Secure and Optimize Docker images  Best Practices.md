---
title: "How to Secure and Optimize Docker images : Best Practices"
source: "https://medium.com/towards-aws/how-to-secure-and-optimize-docker-images-best-practices-76dddbd050a2"
author:
  - "[[Harshsennn]]"
published: 2026-05-04
created: 2026-05-05
description: "More"
tags:
  - "clippings"
---
A practical guide for secure, efficient and scalable Docker workflows with real world examples and code from my own projects.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*sJKBdv5aAszzSXallzq_wA.jpeg)

Docker is the most popular containerization tool that allows you to package applications and their dependencies into lightweight, portable containers. By isolating workloads, Docker ensures that each application runs in its own secure environment (isolated), reducing the risk of conflicts and vulnerabilities. Containers make it easier to deploy, scale and manage software consistently across different systems. With Docker teams can accelerate development process and ship reliable code to production.

However, its essential to implement optimization and security practices to make images and containers lightweight and free from vulnerabilities.

## 1\. Docker Image Optimization

Minimizing the container image size and build complexity to improve deployment speed, reduce surface area and enhance resource efficiency.

## Multi stage build

You can use multiple `FROM` statements in a single dockerfile, each `FROM` instruction lets you use a different base and organize your build process into several stages. This approach lets you compile, test and package your application in stage while only copying the necessary artifacts into the final image. As a result your final container is smaller, more efficient and contains only what’s needed for production or development.

[Example Docker File](https://github.com/harshsennnn/nginx-reverse-proxy-cicd/blob/main/service_2/dockerfilehttps://github.com/harshsennnn/nginx-reverse-proxy-cicd/blob/main/service_1/dockerfile)

## Lightweight base images

Using a lightweight base images reduce the overall image size and attack surface. This leads to faster builds, quicker deployments, less storage usage, and improved security (by minimizing unused packages that could contain vulnerabilities).

Some common lightweight images -

**Alpine**: A minimal Linux distribution (5MB) often used as the base for many lightweight images. Example — `alpine:latest`

**Debian Slim**: The official Debian image with unnecessary files removed. Example — `debian:slim`

**Language Slim and Alpine variants**: Official language images built on Alpine or further slimmed down for smaller size. Example — `node:alpine`, `node:slim`, `golang:alpine`

**Distroless Docker Images:** Highly minimal container images. They contain only your application and its direct runtime dependencies, without an OS, package manager, or shell.

Example: `gcr.io/distroless/base-debian12`, `gcr.io/distroless/python3`

## Use of.dockerignore

Similar to git docker has its own file / directory ignoring mechanism where you can add unnecessary files such as node\_modules, build artifacts, README.md, Dockerfile etc. to reduce the size pf docker image.

## Layer Caching: Why order of steps matters?

Each step in dockerfile is a separate layer in docker and layer caching is a feature that reuses the unchanged layers from the previous build instead of building it from scratch.

Place commands that rarely change like installing OS packages early in dockerfile add frequently modified files and application code later after dependency installation steps. For [example](https://github.com/harshsennnn/nginx-reverse-proxy-cicd/blob/main/service_2/dockerfile) this sequence ensures dependencies are cached and not reinstalled every time you change your source code.

## 2\. Security Principles

## Run Containers in Rootless Mode

Running a container in rootless mode limits the impact of potential “container escapes” (security vulnerability to gain unauthorized access to the host system). This mode ensures containers launch without root privileges, minimizing host level risks and making it significantly harder to gain control over the system. [Example](https://github.com/harshsennnn/3-Tier-App-Deployment-via-Terraform/blob/main/frontend/Dockerfile#L10)

## Don’t Expose the Docker Daemon Socket

By default, Docker daemon listens on a Unix [socket](https://www.geeksforgeeks.org/computer-networks/socket-in-computer-network/) at `/var/run/docker.sock` While it can be configured to listen on a TCP socket for remote management exposing this on public or unsecured networks introduces a major security risk. Anyone with access to the socket can control Docker potentially compromising your host. Keep TCP access disabled unless absolutely required and be cautious when automating tasks via AI or scripts to avoid accidental exposure.

## Secure Remote Socket Access with TLS

If there’s no option to using TCP you must expose Docker daemon over TCP always protect the connection with TLS to ensure that only clients with valid certificates can access the [Docker Engine API](https://docs.docker.com/reference/api/engine/). Remember, any client in possession of a valid certificate will have full Docker control making careful certificate management is essential. Alternatively, consider using SSH for remote Docker connections as this can streamline access control by reusing your established SSH key infrastructure.

## Scan Your Images Regularly

For container security always scan images routinely throughout their lifecycle (use automated workflows or CI/CD pipelines). This helps to detect outdated software, insecure dependencies, and critical vulnerabilities keeping your environment safer. Use image scanners like: [Trivy](https://trivy.dev/latest/), [Grype](https://github.com/anchore/grype)

## 3\. Multi Environment Configuration within a single dockerfile

## Use Build Args (Arguments) & Environment Variables

Configure Docker image builds for different environments like development, production using `ARG` [(build-time variables)](https://docs.docker.com/build/building/variables/) and `ENV` [(runtime variables)](https://docs.docker.com/build/building/variables/#env-usage-example).

Define `ARG` in your Dockerfile to accept parameters when building the image allowing you to customize the build process by skipping hardcoding values. For example:

```c
ARG APP_ENV=production
ENV APP_ENV=$APP_ENV
```

`ENV` sets environment variables inside the container that your application can use at runtime, based on the values passed by `ARG` or other defaults.

## Use Different Target Stages for Environment aware Docker Builds

Defining separate target stages for each environment development, production with a separate `FROM`

```c
FROM node:alpine as development
# Dev specific instructions here
FROM node:alpine as production
# Prod specific instructions here
```

Before building you specify which stage to use by adding the `--target` flag. This tells Docker to stop building after the selected stage and produce an image for that environment.

`docker build --target development -t app:dev .`

`docker build --target production -t app:prod .`

The key benefit of this approach is that you don’t need to maintain multiple Dockerfiles for different environments. Instead, you manage all variations within a single Dockerfile, making your setup easier to maintain.

[Example](https://github.com/harshsennnn/3-Tier-App-Deployment-via-Terraform/blob/main/frontend/Dockerfile) of a docker file operated via [Docker-compose](https://github.com/harshsennnn/3-Tier-App-Deployment-via-Terraform/blob/main/docker-compose.yml) here you can let docker know for which environment you want the image by specifying  
Dev Mode — `TARGET_STAGE=dev FRONTEND_PORT=5173 CONTAINER_PORT=5173 docker-compose up --build`

Production — `TARGET_STAGE=dev FRONTEND_PORT=80 CONTAINER_PORT=80 docker-compose up --build`