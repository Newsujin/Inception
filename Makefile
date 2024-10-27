SRCS = srcs

all: dir
	docker compose -f ./${SRCS}/docker-compose.yml up -d

build: dir
	docker compose -f ./${SRCS}/docker-compose.yml up -d --build

down:
	docker compose -f ./${SRCS}/docker-compose.yml down -v

re: clean
	docker compose -f ./${SRCS}/docker-compose.yml up -d

dir:
	bash ${SRCS}/init_dir.sh

clean: down
	docker image ls | grep '${SRCS}-' | awk '{print $$1}' | xargs docker image rm

fclean: down
	docker image ls | grep '${SRCS}-' | awk '{print $$1}' | xargs docker image rm
	docker network prune --force
	docker volume prune --force
	docker system prune --all --force
	@bash ${SRCS}/init_dir.sh --delete

# @: Shell 명령어 실행하되, 실행하는 명령어 출력 X

.PHONY	: all build down re clean fclean dir