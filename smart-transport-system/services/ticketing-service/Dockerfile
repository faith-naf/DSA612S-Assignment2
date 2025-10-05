FROM ballerina/ballerina:2201.8.6

WORKDIR /app

# Copy Ballerina files
COPY Ballerina.toml .
COPY *.bal .

# Build the service
RUN bal build --offline

# Expose port
EXPOSE 8083

# Run the service
CMD bal run --offline