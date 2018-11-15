docker login harbor.bff.cn --username=admin --password=Root@123
REPOSITORY=harbor.bff.cn/ops/jeesns
# 构建镜像
cat > Dockerfile << EOF
FROM harbor.bff.cn/ops/tomcat8:v1.0
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war
WORKDIR /usr/local/tomcat
CMD ["./bin/catalina.sh", "run"]
EOF
docker build -t $REPOSITORY .
# 上传镜像
docker push $REPOSITORY
