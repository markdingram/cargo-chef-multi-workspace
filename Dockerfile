FROM lukemathwalker/cargo-chef as chef


# Run a cargo chef prepare for each workspace
FROM chef as planner
WORKDIR /common_workspace
COPY /common_workspace .
RUN cargo chef prepare --recipe-path recipe.json

WORKDIR /app_workspace
COPY /app_workspace .
RUN cargo chef prepare --recipe-path recipe.json

# Run a cargo cook for each workspace - 
# shortcut unnecessary compilation with --bin xxx for the common_workspace
# as we're only need cargo chef to produce the empty crate for compilation from the app_workspace
FROM chef AS builder 
WORKDIR /common_workspace
COPY --from=planner /common_workspace/recipe.json recipe.json
RUN cargo chef cook --release --bin xxx --recipe-path recipe.json || true

WORKDIR /app_workspace
COPY --from=planner /app_workspace/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# Build application
COPY / /
RUN cargo build --release --bin app

# We do not need the Rust toolchain to run the binary!
FROM debian:buster-slim AS runtime
WORKDIR /app
COPY --from=builder /app_workspace/target/release/app /usr/local/bin
ENTRYPOINT ["/usr/local/bin/app"]