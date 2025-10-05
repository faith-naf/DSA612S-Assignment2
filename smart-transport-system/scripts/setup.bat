@echo off
echo ========================================
echo Setting up Smart Transport System
echo ========================================

echo Creating Kafka topics...
docker-compose exec kafka kafka-topics --create --topic ticket.requests --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
docker-compose exec kafka kafka-topics --create --topic payments.processed --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
docker-compose exec kafka kafka-topics --create --topic schedule.updates --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
docker-compose exec kafka kafka-topics --create --topic ticket.validated --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
docker-compose exec kafka kafka-topics --create --topic notifications.send --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

echo.
echo ========================================
echo Setup complete!
echo ========================================
pause
