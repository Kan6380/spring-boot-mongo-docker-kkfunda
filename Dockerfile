# ================================
# Stage 1: Build the application
# ================================
FROM maven:3.9.9-eclipse-temurin-8 AS build

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Copy source code
COPY src ./src

# Build the jar
RUN mvn -B clean package -DskipTests


# ================================
# Stage 2: Runtime image
# ================================
FROM eclipse-temurin:8-jre-jammy

WORKDIR /opt/app

# Copy jar from build stage
COPY --from=build /app/target/spring-boot-mongo-1.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
