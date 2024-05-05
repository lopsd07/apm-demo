FROM eclipse-temurin:8-jre-alpine

EXPOSE 8000
ENV MY_WORK_DIR="/app"
ENV CONFIG_FILE="ui.properties"
WORKDIR ${MY_WORK_DIR}

COPY ${CONFIG_FILE} ${MY_WORK_DIR}
COPY cloud*.jar ${MY_WORK_DIR}

ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar cloud*.jar --spring.config.location=file:${CONFIG_FILE}" ]