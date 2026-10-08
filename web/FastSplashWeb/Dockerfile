FROM tomcat:10.1-jdk21-temurin

# Limpa as aplicações padrão do Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Cria a estrutura da aplicação
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# Copia JSP, CSS, imagens e bibliotecas
COPY src/main/webapp/ /usr/local/tomcat/webapps/ROOT/

# Copia temporariamente os arquivos Java
COPY src/main/java/ /tmp/src/

# Compila os arquivos Java
RUN find /tmp/src -name "*.java" > /tmp/sources.txt \
    && javac \
       -encoding UTF-8 \
       -cp "/usr/local/tomcat/lib/*:/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*" \
       -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
       @/tmp/sources.txt \
    && rm -rf /tmp/src /tmp/sources.txt

# Porta usada pelo Render
EXPOSE 10000

# Ajusta a porta do Tomcat para a porta fornecida pelo Render
CMD ["sh", "-c", "sed -i \"s/port=\\\"8005\\\" shutdown=\\\"SHUTDOWN\\\"/port=\\\"-1\\\" shutdown=\\\"SHUTDOWN\\\"/\" /usr/local/tomcat/conf/server.xml && sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-10000}\\\"/\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]