# ================================
# Stage 1: Build
# ================================
FROM maven:3.8.5-openjdk-8-slim AS build

WORKDIR /app

COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B clean package -DskipTests


# ================================
# Stage 2: Runtime
# ================================
FROM eclipse-temurin:8-jre-jammy

WORKDIR /opt/app

COPY --from=build /app/target/spring-boot-mongo-1.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
