# --- FASE 1: Compilación (Build) ---
FROM amazoncorretto:17-alpine-jdk AS build
WORKDIR /app

# Copiamos solo lo necesario para descargar dependencias (optimiza caché)
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

# Copiamos el código y generamos el JAR saltando tests 
# (porque ya los corrimos en el pipeline de CI/CD)
COPY src ./src
RUN ./mvnw package -DskipTests

# --- FASE 2: Imagen de Producción (Run) ---
FROM amazoncorretto:17-alpine
WORKDIR /app

# Copiamos SOLO el archivo ejecutable desde la fase anterior
COPY --from=build /app/target/*.jar app.jar

# Buenas prácticas de seguridad: No correr como root (opcional pero recomendado)
# EXPOSE y ENTRYPOINT
EXPOSE 8086
ENTRYPOINT ["java", "-jar", "app.jar"]