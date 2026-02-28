FROM amazoncorretto:17-alpine-jdk AS build
WORKDIR /app

# Copia mínima para descargar dependencias
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Construcción
COPY src ./src
RUN ./mvnw package -DskipTests -B && \
    cp target/*.jar app.jar

# Usamos una imagen más ligera
FROM amazoncorretto:17-alpine
WORKDIR /app

# Seguridad
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

COPY --from=build /app/app.jar app.jar

# Configuración de red y ejecución
EXPOSE 8086

# Variables de entorno opcionales para facilitar cambios sin rebuild
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Requiere tener 'curl' instalado en alpine o usar un comando de java
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -q --spider http://localhost:8086/actuator/health || exit 1
  
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]