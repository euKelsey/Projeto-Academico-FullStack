# ==========================================
# ESTAGIO 1 - COMPILACAO COM MAVEN
# ==========================================
FROM eclipse-temurin:25-jdk AS build

WORKDIR /app

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

RUN chmod +x mvnw

RUN ./mvnw -B dependency:go-offline

COPY src/ src/

RUN ./mvnw -B clean verify

# ==========================================
# ESTAGIO 2 - EXECUCAO COM TOMCAT
# ==========================================
FROM tomcat:11.0.29-jdk25-temurin

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build /app/target/FastSplashWeb.war \
    /usr/local/tomcat/webapps/ROOT.war

ENV PORT=10000

EXPOSE 10000

CMD ["sh", "-c", "sed -i \"s/port=\\\"8005\\\" shutdown=\\\"SHUTDOWN\\\"/port=\\\"-1\\\" shutdown=\\\"SHUTDOWN\\\"/\" /usr/local/tomcat/conf/server.xml && sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT}\\\"/\" /usr/local/tomcat/conf/server.xml && exec catalina.sh run"]
