FROM tomcat:11.0.29-jdk25-temurin

# Remove as aplicacoes padrao do Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copia os arquivos da aplicacao
COPY src/main/webapp/ /usr/local/tomcat/webapps/ROOT/

# Remove classes compiladas localmente
RUN rm -rf /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
    && mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# Copia o codigo-fonte Java
COPY src/main/java/ /tmp/src/

# Compila o backend
RUN find /tmp/src -name "*.java" > /tmp/sources.txt \
    && javac \
       -encoding UTF-8 \
       --release 25 \
       -cp "/usr/local/tomcat/lib/*:/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*" \
       -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
       @/tmp/sources.txt \
    && rm -rf /tmp/src /tmp/sources.txt

# Porta utilizada pelo Render
ENV PORT=10000
EXPOSE 10000

# Inicializa o servidor
CMD ["sh", "-c", "sed -i \"s/port=\\\"8005\\\" shutdown=\\\"SHUTDOWN\\\"/port=\\\"-1\\\" shutdown=\\\"SHUTDOWN\\\"/\" /usr/local/tomcat/conf/server.xml && sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT}\\\"/\" /usr/local/tomcat/conf/server.xml && exec catalina.sh run"]
