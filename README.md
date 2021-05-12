Gilded Rose kata
================

El código a refactorizar:

[Emily Bache Gilded Rose Kata - Java](https://github.com/emilybache/GildedRose-Refactoring-Kata/tree/master/Java)

La lógica del negocio:

[Cómo se actualiza la calidad de los items y su fechas de caducidad](https://github.com/dfleta/Python_ejercicios/blob/master/Poo/GildedRose_Refactoring_TDD_Kata/GildedRoseRequirements.txt)


## Cómo refactorizar

En el capítulo 24 del libro _Code Complete_ de Steven C. McConnell encontrarás todas las buenas prácticas que necesitas conocer para refactorizar de manera sistemática. 

## Qué es la refactorización

Martin Fowler define la técnica de refactorización como:

_"a change made to the internal structure of the software to make it easier to understand and cheaper to modify without changing its observable behavior”._

Es, sin duda, la frase que aprendida de memoria más salud y felicidad reportará a tu vida.

En el caso de la refactorización de la lógica de los productos mágicos de la tienda _Gilded Rose_, según las directrices de _Code Complete_:

 - _"Replace conditionals with polymorphism (especially repeated case statements):_
    - _Much of the logic that used to be contained in case statements in structured programs can instead be baked into the inheritance hierarchy and accomplished through polymorphic routine calls instead."_

 - A big refactoring is a recipe for disaster. —Kent Beck  :slack_call: @Elmo 

Es decir: para evitar la complejidad provocada por `if-else` anidados y sus correspondientes operadores lógicos vamos a utilizar polimorfismo o el **Principio de Substitución de Liskov (LSP)**(es una mujer, listo) de los principios SOLID.

Además, practicaremos TDD añadiendo poco a poco casos test para evitar etapas demasiado grandes de refactorizaciones que nos aboquen a un desastre. 


## Programación Orientada a Objetos

### Conceptos de Programación Orientada a Objetos:

Cap. 1 libro _Beginning Java 8 Fundamentals_.

- **Abstracción**: exponer sólo los detalles esenciales.
- **Encapsulamiento**: agrupar datos + las operaciones sobre esos datos => DAT o tipo de dato abstracto (Data Abstract Type).
- **Herencia**: derivar un DAT de otro, por ejemplo, el xenomorpho de la película _Alien_ (buen spoiler).
- **Ocultar información**: ocultar detalles de implementación que pueden cambiar.
- **Polimorfismo**: una entidad soporta diferentes significados en diferentes contextos.
  - **Coercitivo**: cast de tipos.
  - **De inclusión**: herencia y sobreescritura (de métodos)
  - **De sobrecarga** (de métodos).
  - **Paramétrico**: generics de Java. :mrmeeseeks: Mr. Meeseeks!

### DAT

Capítulo 6: Working Classes, Code Complete:
https://docs.google.com/document/d/1qFJXxEiWWgJPYbPghdB1d6O9TTbNmb3l85VWs-NNDfk

### LSP - SOLID

Vamos a aplicar polimorfismo o el **Principio de Substitución de Liskov (LSP)**(es una mujer, listo) de los principios SOLID.

L de SOLID = [Principio de Substitución de Liksov](https://es.wikipedia.org/wiki/Principio_de_sustituci%C3%B3n_de_Liskov)


_"Un tipo de dato abstracto se implementa escribiendo una clase especial de programa que define el tipo en términos de las operaciones que pueden ser realizadas sobre él"_. Esta es la interpretación **_duck typing_**.

_"Los subtipos deben ser substituibles por sus tipos básicos"_. Martin C. Robert.

_"Se acepta normalmente que los objetos deben ser modificados unicamente a través de sus métodos (Encapsulamiento). Como los subtipos pueden introducir nuevos métodos, ausentes en el supertipo, estos podrían cambiar el estado interno del objeto en formas que serían imposibles o inadmisibles en el supertipo. La restricción histórica impide este tipo de modificaciones."_

## Diagrama de clase UML

Utiliza este diagrama de clases UML para guiarte en la implementación de las clases:

![Diagrama de clases UML](./diagrama_clases_UML.jpg)

Básicamente, es el mismo diseño que entre todas las personas de clase hemos discurrido de manera colaborativa:

![Proto UML](./diseño%20colaborativo%20protoUML.jpg)


JAVA en un docker
=================

### Alpine Linux with OpenJDK JRE
Crear la imagen con el JDK y el JRE para crear los `jar` de la app:

`Dockerfile`

```Dockerfile
FROM openjdk:11.0-jre-slim-buster

LABEL "edu.elsmancs.gildedrose"="Kata Gilded Rose"
LABEL version="1.0"
LABEL description="Kata Gilded Rose en Java"
LABEL maintainer="davig@cifpfbmoll.eu"

WORKDIR $HOME/app

COPY ./target/gildedrose-1.0-SNAPSHOT.jar ./app/gildedrose.jar

CMD ["java", "-jar", "./app/gildedrose.jar"]
```

### Crear la imagen:

```bash
$ docker build -t gildedrose .

$ docker images 

REPOSITORY       TAG                    IMAGE ID       CREATED         SIZE
gildedrose       latest                 97ba7872c8f5   4 minutes ago   220MB
openjdk          11.0-jre-slim-buster   4f4564121f23   3 days ago      220MB
```

### Crear un contenedor y ejecutarlo a partir de la imagen:

```bash
$ docker run -it --name katagildedrose gildedrose:latest

Bienvenido a Ollivanders!
         ####  DAY 1 ####
name=+5 Dexterity Vest, sell_in=10, quality=20
name=Aged Brie, sell_in=2, quality=0
name=Elixir of the Mongoose, sell_in=5, quality=7
name=Sulfuras, Hand of Ragnaros, sell_in=0, quality=80
name=Sulfuras, Hand of Ragnaros, sell_in=-1, quality=80
name=Backstage passes to a TAFKAL80ETC concert, sell_in=15, quality=20
...

$ docker ps -a

CONTAINER ID   IMAGE                COMMAND        CREATED         STATUS       PORTS     NAMES
88aa8adfa8ec   gildedrose:latest   "java -jar ./app/gil…"   10 minutes ago   Exited (0) 10 minutes ago   katagildedrose
```

No necesito de momento el -dockerignore porque no estoy copiando código fuente, sólo los `jar`

### AS - stages

Mejor usar la imagen maven oficial porque al instalar por mi cuenta maven en la imagen da problemas: 

https://hub.docker.com/_/maven

Leer el dockerfile

Se generan la imagen maven, la openjdk, y una <none> que me cargo luego, más la final con jre+la app

Esta manera me permite construir la app con maven en una imagen maven (a la que he copiado el código fuente) y copiar sólo el jar a otra imagen, de modo que si publico la imagen no se puede acceder al fuente. Además, la imagen con maven pesa 400MB mientras que la jre sólo 200MB.

```Dockerfile
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
```

-----------------

Arrancar mi docker **sobreescribiendo el entrypoint** y así poder ejecutarlo en modo interactivo

```bash
$ docker run --rm -it --entrypoint=/bin/bash mavenrose:latest 

root@0d8424b096f8:/app# ls
gildedrose.jar

root@0d8424b096f8:/app# java -jar gildedrose.jar

root@0d8424b096f8:/app# exit
```
-----------------

Ejecutar el contenedor tal cual:

```bash
$ docker start -i gildedrose 

$ docker container run -it --rm mavenrose:latest 
```

-----------------


Ver el **historial de capas** de la imagen:

```bash
$ docker image history mavenrose:latest

age history mavenrose:latest
IMAGE          CREATED        CREATED BY                                      SIZE      COMMENT
66b0ba2acab1   3 months ago   /bin/sh -c #(nop)  ENTRYPOINT ["java" "-jar"…   0B        
8ffc2b695386   3 months ago   /bin/sh -c #(nop) COPY file:0c8b69203defcdcb…   9.6kB     
7b9f1245a45f   3 months ago   /bin/sh -c #(nop) WORKDIR /app                  0B        
b9b7d6f69027   3 months ago   /bin/sh -c #(nop)  LABEL edu.elsmancs.gilded…   0B        
4f4564121f23   3 months ago   /bin/sh -c set -eux;   arch="$(dpkg --print-…   142MB     
<missing>      3 months ago   /bin/sh -c #(nop)  ENV JAVA_VERSION=11.0.10     0B        
<missing>      3 months ago   /bin/sh -c #(nop)  ENV LANG=C.UTF-8             0B        
<missing>      3 months ago   /bin/sh -c #(nop)  ENV PATH=/usr/local/openj…   0B        
<missing>      3 months ago   /bin/sh -c { echo '#/bin/sh'; echo 'echo "$J…   27B       
<missing>      3 months ago   /bin/sh -c #(nop)  ENV JAVA_HOME=/usr/local/…   0B        
<missing>      4 months ago   /bin/sh -c set -eux;  apt-get update;  apt-g…   8.78MB    
<missing>      4 months ago   /bin/sh -c #(nop)  CMD ["bash"]                 0B        
<missing>      4 months ago   /bin/sh -c #(nop) ADD file:422aca8901ae3d869…   69.2MB    
```

La capa superior es la última. A medida que descedemos las capas son más antiguas. La capa superior es la que generalmente usamos para ejecutar los contendores. 

-----------------

Para ver los **metadata** de la imagen que hemos creado con `LABEL (key=value)`: 

```bash
$ docker image inspect mavenrose:latest 
...
 "Labels": {
                "description": "Kata Gilded Rose en Java",
                "edu.elsmancs.gildedrose": "Kata Gilded Rose",
                "maintainer": "davig@cifpfbmoll.eu",
                "version": "1.0"
            }
```

-----------------

Publicar la imagen en dockerhub

```bash
~$ docker tag mavenrose:latest dfleta/gildedrose

~$ docker login -u <user>
```

-----------

Comandos útiles

```bash
$ docker container rm id_contenedor

$ docker images

$ docker image rm id_iamgen

$ docker start contenedor
$ docker stop contenedor

$ docker ps -a
```

### Docker handbook de freecodecamp

https://www.freecodecamp.org/news/the-docker-handbook/