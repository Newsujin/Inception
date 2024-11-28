all: prepare
	@echo "🚀 Starting all services..."
	@docker compose -f srcs/docker-compose.yml up -d

build: prepare
	@echo "🔨 Building and starting all services..."
	@docker compose -f srcs/docker-compose.yml up -d --build

prepare:
	@echo "🔧 Preparing environment..."
	@chmod +x srcs/init.sh
	@./srcs/init.sh

clean:
	@echo "🛑 Stopping all services..."
	@docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	@echo "🧹 Force removing all Docker resources..."
	@docker system prune --force --all
	@chmod +x srcs/init.sh
	@./srcs/init.sh --delete

re: fclean all

.PHONY: all build prepare re clean fclean