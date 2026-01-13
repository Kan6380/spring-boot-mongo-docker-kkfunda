# Stage 1: Build the application using Maven and OpenJDK 8
FROM maven:3.8.5-openjdk-8-slim AS build

# Set working directory inside container
WORKDIR /app

# Copy pom.xml and download dependencies (go-offline)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application and package jar, skipping tests
RUN mvn clean package -DskipTests

# Stage 2: Run the application using Eclipse Temurin OpenJDK 8 JRE
FROM eclipse-temurin:8-jre

# Set environment variable for app location
ENV PROJECT_HOME=/opt/app

# Set working directory
WORKDIR $PROJECT_HOME

# Copy the built jar from the build stage
COPY --from=build /app/target/spring-boot-mongo-1.0.jar $PROJECT_HOME/spring-boot-mongo.jar

# Expose port 8080 for Spring Boot app
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "./spring-boot-mongo.jar"]
