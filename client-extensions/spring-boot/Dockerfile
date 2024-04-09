FROM azul/zulu-openjdk-alpine:11-latest as build

WORKDIR /workspace

COPY . .
RUN ./gradlew :client-extensions:spring-boot:build

FROM liferay/jar-runner:latest

COPY --from=build /workspace/client-extensions/spring-boot/build/libs/*.jar /opt/liferay/jar-runner.jar