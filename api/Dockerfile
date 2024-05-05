FROM eclipse-temurin:8-jre-alpine

EXPOSE 8080
ENV MY_WORK_DIR="/app"
ENV CONFIG_FILE="application_api.yml"
WORKDIR ${MY_WORK_DIR}

COPY ${CONFIG_FILE} ${MY_WORK_DIR}
COPY ecommerce*.jar ${MY_WORK_DIR}

# ENTRYPOINT [ "java", "-jar", "${MY_WORK_DIR}/ecommerce*.jar", "--spring.config.location=file:${CONFIG_FILE}" ]
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar ecommerce*.jar --spring.config.location=file:${CONFIG_FILE}" ]