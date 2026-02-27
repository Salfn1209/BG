# 1. Usar la imagen de Amazon Corretto
FROM amazoncorretto:17-alpine-jdk

# 2. Directorio de trabajo
WORKDIR /app

# 3. ??IMPORTANTE! Copiar los archivos de Maven y el c??digo fuente primero
# Copiamos el wrapper y el pom.xml
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Copiamos el c??digo fuente
COPY src ./src

# 4. Ahora s??, compilar saltando los tests
RUN ./mvnw package -DskipTests

# 5. Copiar el JAR generado (ajusta el nombre si es necesario)
# Al compilar dentro, el jar est?? en target/
RUN cp target/*.jar app.jar

# 6. Configuraci??n final
EXPOSE 8086
ENTRYPOINT ["java", "-jar", "app.jar"]
