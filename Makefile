# SRCS = srcs

# all: prepare
# 	@echo "🚀 Starting all services..."
# 	@docker compose -f ${SRCS}/docker-compose.yml up -d

# build: prepare
# 	@echo "🔨 Building and starting all services..."
# 	@docker compose -f ${SRCS}/docker-compose.yml up -d --build

# down:
# 	@echo "🛑 Stopping all services..."
# 	@docker compose -f ${SRCS}/docker-compose.yml down -v

# re: fclean all
# 	@echo "🔄 Rebuilding all services..."

# prepare:
# 	@echo "🔧 Preparing environment..."
# 	@chmod +x ${SRCS}/init.sh
# 	@./${SRCS}/init.sh

# clean: down
# 	@echo "🧹 Removing unused Docker resources..."
# 	@docker system prune --force --all

# fclean: clean
# 	@echo "🧹 Force removing all Docker resources..."
# 	@docker rm -f $(shell docker ps -aq) 2>/dev/null || true
# 	@docker rmi -f $(shell docker images -aq) 2>/dev/null || true
# 	@docker volume rm $(shell docker volume ls -q) 2>/dev/null || true
# 	@echo "🧹 Cleaning up initialization..."
# 	@chmod +x ${SRCS}/init.sh
# 	@./$(SRCS)/init.sh --delete

# .PHONY: all build down re clean fclean prepare

# # @: Shell 명령어 실행하되, 실행하는 명령어 출력 X
# # -: 명령어 실행 실패 시, skip


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
	bash ${SRCS}/init.sh

clean: down
	-@docker system prune --force
	# docker image ls | awk '{print $1}' | xargs docker image rm

fclean: down
	-@docker system prune --force
	-@docker rmi $(docker images -q)
	-@bash ${SRCS}/init.sh --delete

# @: Shell 명령어 실행하되, 실행하는 명령어 출력 X
# -: 명령어 실행 실패 시, skip

.PHONY	: all build down re clean fclean dir