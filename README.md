# APM Demo 部署

[使用 APM 管理电商应用](https://support.huaweicloud.com/bestpractice-apm/apm_05_0001.html)

应用包含五个微服务，每个微服务包含一个实例：

- API 网关服务：名称为 apigw，主要负责应用整体的服务鉴权、限流、过滤等。
- 商品管理服务：名称为 product，主要负责商品查询、购买等。
- 用户管理服务：名称为 user，主要负责用户登录，以及购买商品时的用户身份核实等。
- 数据持久服务：名称为 dao，主要负责请求数据库操作。
- Web UI 服务：前端 UI 及自动测试定时任务。
- 数据库服务：MySQL 数据库。

服务端口

- API Gateway: 8080
- Product: 8082
- User: 8081
- DAO: 8083
- UI: 80

## 环境准备

### 数据库

数据库使用 MySQL 5.7。

1. 使用 MySQL 5.7 Docker 镜像部署，为了确保 MySQL 数据的持久化，将主机上的目录挂载到容器内的 `/var/lib/mysql` 目录，这样可以在容器重新创建或停止后保留数据。

```sh
mkdir -p ~/mysql/data_5.7

docker run --name mysql5.7-instance -p 13306:3306 -v ~/mysql/data_5.7:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypasswd -d mysql:5.7
```

2. 连接到 MySQL 容器：通过 Docker 的 exec 命令进入容器的命令行界面，然后使用 MySQL 命令行工具连接数据库，输入密码后，就可以开始使用 MySQL 数据库。

```sh
docker exec -it mysql-instance bash
mysql -h 127.0.0.1 -P 3306 -u root -p
```

#### 数据库初始化

```sql
CREATE DATABASE ShoppingMallDB;
USE ShoppingMallDB;
CREATE TABLE IF NOT EXISTS `user_table` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `username_unique` (`name`)
) DEFAULT CHARSET = utf8mb4;
CREATE TABLE IF NOT EXISTS `product_table` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `price` DECIMAL(8, 2),
    PRIMARY KEY (`id`)
) DEFAULT CHARSET = utf8mb4;
CREATE TABLE IF NOT EXISTS `payment_table` (
    `userid` INT NOT NULL,
    `productid` INT NOT NULL
) DEFAULT CHARSET = utf8mb4;
CREATE USER 'apm' @'%' IDENTIFIED BY 'paasapm';
GRANT ALL PRIVILEGES ON *.* TO 'apm' @'%';
-- MySQL 8.0
-- ALTER USER 'apm'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'paasapm';
FLUSH PRIVILEGES;
-- Insert data
INSERT INTO product_table (name, price)
VALUES ('product1', 9999);
INSERT INTO product_table (name, price)
VALUES ('product2', 8999);
INSERT INTO product_table (name, price)
VALUES ('product3', 10999);
INSERT INTO product_table (name, price)
VALUES ('product4', 11999);
INSERT INTO product_table (name, price)
VALUES ('product4', 12999);
INSERT INTO product_table (name, price)
VALUES ('iPhone', 6999);
INSERT INTO user_table (name, password)
VALUES ('apm', '123456');
INSERT INTO user_table (name, password)
VALUES ('admin', '123456');
```

### 修改数据库配置文件



### JDK

JDK 1.8

- 容器镜像：`docker pull eclipse-temurin:8-jdk`
- [Eclipse Temurin™ Latest Releases](https://adoptium.net/temurin/releases/?os=linux&arch=x64&package=jdk&version=8)
- [BiSheng JDK 8](https://www.hikunpeng.com/en/developer/devkit/download/jdk)

## 辅助脚本

创建日志目录

```sh
mkdir /var/log/apm/
```

### 启动脚本

```sh
export PATH=/opt/jdk/bisheng-jdk1.8.0_402/bin/:$PATH
java -Xmx512m -jar ecommerce-persistence-service-0.0.1-SNAPSHOT.jar --spring.config.location=file:application_dao.yml > logs/dao.log 2>&1 &
java -Xmx512m -jar ecommerce-api-gateway-0.0.1-SNAPSHOT.jar --spring.config.location=file:application_api.yml > logs/api.log 2>&1 &
java -Xmx512m -jar ecommerce-user-service-0.0.1-SNAPSHOT.jar --spring.config.location=file:application_userservice.yml > logs/user.log 2>&1 &
java -Xmx512m -jar ecommerce-product-service-0.0.1-SNAPSHOT.jar --spring.config.location=file:application_prod.yml > logs/prod.log 2>&1 &
java -Xmx512m -jar cloud-simple-ui-1.0.0.jar --spring.config.location=file:ui.properties > logs/ui.log 2>&1 &
```
