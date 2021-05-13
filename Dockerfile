# Imagen base
## BUILD STAGE => maven build ##
FROM maven:3.6.3-openjdk-11-slim AS build

# Copy only the src directory and pom.
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app

# desde el workdir si se indica ruta relativa
RUN mvn -f /usr/src/app/pom.xml clean package


## PACKAGE STAGE => Imagen runable con el jar de la app ##

FROM openjdk:11.0-jre-slim-buster

LABEL "edu.elsmancs.gildedrose"="Kata Gilded Rose"\
        version="1.0"\
        description="Kata Gilded Rose en Java"\
        maintainer="davig@cifpfbmoll.eu"

# We indicate the por on wich the container listens for connections.
EXPOSE 5000

WORKDIR $HOME/app

# copiar el jar desde el stage build al workdir del docker
COPY --from=build /usr/src/app/target/*.jar ./gildedrose.jar

# Specify the user to the container.
ENV USER=appuser
RUN adduser \
    --disabled-password \
    --home "$(pwd)" \
    --no-create-home \
    "$USER"
USER appuser

# ejecutar este comando al ejecutar el docker
ENTRYPOINT ["java", "-jar", "gildedrose.jar"]