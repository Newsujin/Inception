SRCS = srcs

all: prepare
	@echo "🚀 Starting all services..."
	@docker compose -f ${SRCS}/docker-compose.yml up -d

build: prepare
	@echo "🔨 Building and starting all services..."
	@docker compose -f ${SRCS}/docker-compose.yml up -d --build

prepare:
	@echo "🔧 Preparing environment..."
	@chmod +x ${SRCS}/init.sh
	@./${SRCS}/init.sh

re: fclean all
	@echo "🔄 Rebuilding all services..."

clean:
	@echo "🛑 Stopping all services..."
	@docker compose -f ${SRCS}/docker-compose.yml down -v

fclean: clean
	@echo "🧹 Force removing all Docker resources..."
	@docker system prune --force --all
	@chmod +x ${SRCS}/init.sh
	@./$(SRCS)/init.sh --delete

.PHONY: all build down re clean fclean prepare