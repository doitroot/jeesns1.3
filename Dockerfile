FROM 10.83.35.24/app/tomcat8:v1.0
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war
WORKDIR /usr/local/tomcat
CMD ["./bin/catalina.sh", "run"]
