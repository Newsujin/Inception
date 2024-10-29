SRCS = srcs

all: dir
	docker compose -f ./${SRCS}/docker-compose.yml up -d

build: dir
	docker compose -f ./${SRCS}/docker-compose.yml up -d --build

down:
	docker compose -f ./${SRCS}/docker-compose.yml down -v

re: clean
	sudo docker compose -f ./${SRCS}/docker-compose.yml up -d

dir:
	bash ${SRCS}/init_dir.sh

clean: down
	-@docker system prune --force
	# docker image ls | awk '{print $1}' | xargs docker image rm

fclean: down
	-@docker system prune --force
	-@docker rmi $(docker images -q)
	-@bash ${SRCS}/init_dir.sh --delete

# @: Shell 명령어 실행하되, 실행하는 명령어 출력 X
# -: 명령어 실행 실패 시, skip

.PHONY	: all build down re clean fclean dir