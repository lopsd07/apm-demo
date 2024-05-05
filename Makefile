# 默认目标
.DEFAULT_GOAL := build-all

# The path to the Dockerfile
DOCKERFILE_PATH ?= ./Dockerfile
IMAGE_TAG ?= 1.0.1
REGISTRY ?= swr.myhuaweicloud.com/my-org

# Build the Docker image
build: build-all

# 应用列表
APPS := ui api user product persistence
# 镜像名称和标签的变量，可以被覆盖
IMAGE_NAMES ?= $(APPS)
IMAGE_TAGS ?= $(addsuffix :latest, $(APPS))

# 构建所有应用的镜像
build-all: $(addsuffix build-, $(APPS))

# Push the Docker image to a registry
push-all: $(addsuffix push-, $(APPS))

# 构建单个应用的镜像
build-%:
	$(eval APP := $(word 2, $(subst -, ,$@)))
	@echo $(APP)-$(IMAGE_TAG)
	docker build -t $(APP):$(IMAGE_TAG) $(APP)

push-%:
	$(eval APP := $(word 2, $(subst -, ,$@)))
	@echo $(APP)-$(IMAGE_TAG)
	docker tag $(APP):$(IMAGE_TAG) $(REGISTRY)/$(APP):$(IMAGE_TAG)
	docker push $(REGISTRY)/$(APP):$(IMAGE_TAG)

# 清除所有镜像
clean:
	@docker rmi $(IMAGE_TAGS)

# 帮助信息
help:
	@echo "Available targets:"
	@echo "  make build-all        # Build all application images"
	@for app in $(APPS); do \
	  echo "  make $$app-build     # Build $$app application image"; \
	done
	@echo "  make clean           # Clean all images"
	@echo "  make help            # Show this help message"

# 确保在调用docker build时替换变量
$(IMAGE_NAMES) := $(IMAGE_NAMES)
$(IMAGE_TAGS) := $(IMAGE_TAGS)

.PHONY: build-all %-build clean help