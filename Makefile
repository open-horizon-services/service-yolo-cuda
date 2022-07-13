# A yolo plugin using CUDA (requires NVIDIA GPU hardware, software, and config)

# Include the make file containing all the check-* targets
include ../../checks.mk

# Give this service a name, version number, and pattern name
DOCKER_HUB_ID ?= "ibmosquito"
SERVICE_NAME:="cuda"
SERVICE_VERSION:="1.1.0"
PATTERN_NAME:="pattern-cuda"

# These statements automatically configure some environment variables
ARCH:=$(shell ../../helper -a)

# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
CONTAINER_CREDS:=

build: check-dockerhubid
	@echo "Building the CUDA plugin for NVIDIA hardware (NOTE: not for ARM32)"
	@if [ "${ARCH}" != "arm" ]; then \
	  docker build -t $(DOCKER_HUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) -f ./Dockerfile.$(ARCH) .; \
        fi

run: check-dockerhubid
	-docker network create mqtt-net 2>/dev/null || :
	-docker network create cam-net 2>/dev/null || :
	-docker rm -f $(SERVICE_NAME) 2>/dev/null || :
	docker create --rm \
          -p 127.0.0.1:5252:80 \
          --name $(SERVICE_NAME) \
          --network mqtt-net --network-alias $(SERVICE_NAME) \
          $(DOCKER_HUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION)
	docker network connect cam-net $(SERVICE_NAME) --alias $(SERVICE_NAME)
	docker start $(SERVICE_NAME)

dev: check-dockerhubid
	-docker network create mqtt-net 2>/dev/null || :
	-docker network create cam-net 2>/dev/null || :
	-docker rm -f $(SERVICE_NAME) 2>/dev/null || :
	docker create -it -v `pwd`:/outside \
          -p 127.0.0.1:5252:80 \
          --name $(SERVICE_NAME) \
          --network mqtt-net --network-alias $(SERVICE_NAME) \
          $(DOCKER_HUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) /bin/bash
	docker network connect cam-net $(SERVICE_NAME) --alias $(SERVICE_NAME)
	docker start -ia $(SERVICE_NAME)

stop: check-dockerhubid
	-docker rm -f ${SERVICE_NAME} 2>/dev/null || :

clean: check-dockerhubid
	-docker rm -f ${SERVICE_NAME} 2>/dev/null || :
	-docker rmi $(DOCKER_HUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) 2>/dev/null || :

publish-service:
	@ARCH=$(ARCH) \
	    SERVICE_NAME="$(SERVICE_NAME)" \
	    SERVICE_VERSION="$(SERVICE_VERSION)"\
	    SERVICE_CONTAINER="$(DOCKER_HUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION)" \
	    hzn exchange service publish -O $(CONTAINER_CREDS) -P -f service.json --public=true

publish-pattern:
	@ARCH=$(ARCH) \
	    SERVICE_NAME="$(SERVICE_NAME)" \
	    SERVICE_VERSION="$(SERVICE_VERSION)"\
	    PATTERN_NAME="$(PATTERN_NAME)" \
	    hzn exchange pattern publish -f pattern.json

agent-run:
	hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

agent-stop:
	hzn unregister -f

.PHONY: build run dev stop clean publish-service publish-pattern agent-run agent-stop

