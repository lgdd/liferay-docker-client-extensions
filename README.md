# Liferay Docker Client Extensions

Example to run Liferay and Client Extensions in a Docker Compose stack.

# Spring Boot Example

To make the [Spring Boot Sample](https://github.com/lgdd/liferay-client-extensions-samples/tree/main/liferay-sample-etc-spring-boot) work, you need to make the following list of changes.

1 - Add the following lines to the [`application-default.properties`](client-extensions/spring-boot/src/main/resources/application-default.properties#L17) file:

```properties
com.liferay.lxc.dxp.domains=liferay:8080
com.liferay.lxc.dxp.mainDomain=liferay:8080
com.liferay.lxc.dxp.server.protocol=http
```
> `liferay` matches the name of the service in our [`docker-compose.yml`](docker-compose.yml) file.

2 - Update the service address in the [`client-extension.yaml`](client-extensions/spring-boot/client-extension.yaml#L9) file:
```diff
liferay-sample-etc-spring-boot-oauth-application-user-agent:
-   .serviceAddress: localhost:58081
+   .serviceAddress: springboot:58081
    .serviceScheme: http
```
> `springboot` matches the name of the service in our `docker-compose.yml` file.

3 - Update the [`Dockerfile`](client-extensions/spring-boot/Dockerfile) for our Spring Boot application:
```Dockerfile
FROM azul/zulu-openjdk-alpine:11-latest as build

WORKDIR /workspace

COPY . .
RUN ./gradlew :client-extensions:spring-boot:build

FROM liferay/jar-runner:latest

COPY --from=build /workspace/client-extensions/spring-boot/build/libs/*.jar /opt/liferay/jar-runner.jar
```
> This one is opinionated because I have a build step which is not required. You could copy the jar built locally in your Dockerfile. But I find it more consistent to build in the Dockerfile since you control the JDK used.

4 - Update the `virtual.hosts.valid.hosts` property to accept the name of your Docker service (in our case, it's `liferay`):

Using the `portal-ext.properties`:
```diff
virtual.hosts.valid.hosts=\
+   liferay
    localhost,\
    127.0.0.1,\
    [::1],\
    [0:0:0:0:0:0:0:1]
```

Or using [environment variables](docker-compose.yml#L7):
```diff
services:
  liferay:
    image: liferay/dxp:2024.q1.4
+   environment:
+     LIFERAY_VIRTUAL_PERIOD_HOSTS_PERIOD_VALID_PERIOD_HOSTS: liferay,localhost,127.0.0.1,[::1],[0:0:0:0:0:0:0:1]
```