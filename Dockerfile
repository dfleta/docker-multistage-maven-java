# Imagen base
## BUILD STAGE => maven build ##
FROM maven:3.6.3-openjdk-11-slim AS build

# copia en la ruta indicada 
# (si es relativa desde el workdir)
COPY . /usr/src/app

# desde el workdir si se indica ruta relativa
RUN mvn -f /usr/src/app/pom.xml clean package


## PACKAGE STAGE => Imagen runable con el jar de la app ##

FROM openjdk:11.0-jre-slim-buster

LABEL "edu.elsmancs.gildedrose"="Kata Gilded Rose" \
        version="1.0" \
        description="Kata Gilded Rose en Java" \ 
        maintainer="davig@cifpfbmoll.eu"

WORKDIR $HOME/app 

# copiar el jar desde el stage build al workdir del docker
COPY --from=build /usr/src/app/target/*.jar ./gildedrose.jar

# ejecutar este comando al ejecutar el docker
ENTRYPOINT ["java", "-jar", "gildedrose.jar"]