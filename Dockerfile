FROM lukemathwalker/cargo-chef:latest-rust-1.65.0-bullseye as chef
WORKDIR /app
RUN apt update && apt install lld clang -y

FROM chef as planner
COPY . .

# compute a lock file for our project
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json

# build dependencies
RUN cargo chef cook --release --recipe-path recipe.json

# build our project
COPY . .
ENV SQLX_OFFLINE true
RUN cargo build --release --bin zero2prod


FROM debian:bullseye-slim as runtime

WORKDIR /app

# Install OpenSSL - it is dynamically linked by some of our dependencies
# Install ca-certificates - it is needed to verify TLS certificates
# when establishing HTTPS connections
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /app/target/release/zero2prod zero2prod

# We need the compiled binary to run our runtime environment

COPY configuration configuration

ENV APP_ENVIRONMENT production
# When `docker run` is executed, launch the binary!
ENTRYPOINT ["./zero2prod"]