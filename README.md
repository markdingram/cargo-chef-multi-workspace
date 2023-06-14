# Cargo Chef Cross Workspace Dependencies 

A workaround for https://github.com/LukeMathWalker/cargo-chef/issues/4

## Build with no cache

````
$ docker build . -t app --no-cache --progress=plain
#1 [internal] load .dockerignore
#1 transferring context: 2B done
#1 DONE 0.0s

#2 [internal] load build definition from Dockerfile
#2 transferring dockerfile: 1.15kB done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/lukemathwalker/cargo-chef:latest
#3 DONE 0.6s

#4 [internal] load metadata for docker.io/library/debian:buster-slim
#4 DONE 0.7s

#5 [chef 1/1] FROM docker.io/lukemathwalker/cargo-chef@sha256:57b93c406c3a1a55a31063658e36763baba2a791e62b10611139a2536958d33c
#5 DONE 0.0s

#6 [runtime 1/3] FROM docker.io/library/debian:buster-slim@sha256:738002a6e94e8629a0f869be8ea56519887979d5ed411486441981a8b16f2fc8
#6 DONE 0.0s

#7 [planner 1/6] WORKDIR /common_workspace
#7 CACHED

#8 [runtime 2/3] WORKDIR /app
#8 CACHED

#9 [internal] load build context
#9 transferring context: 32.45kB 0.0s done
#9 DONE 0.0s

#10 [planner 2/6] COPY /common_workspace .
#10 DONE 0.0s

#11 [planner 3/6] RUN cargo chef prepare --recipe-path recipe.json
#11 DONE 0.2s

#12 [planner 4/6] WORKDIR /app_workspace
#12 DONE 0.0s

#13 [planner 5/6] COPY /app_workspace .
#13 DONE 0.0s

#14 [planner 6/6] RUN cargo chef prepare --recipe-path recipe.json
#14 DONE 0.2s

#15 [builder 2/8] COPY --from=planner /common_workspace/recipe.json recipe.json
#15 DONE 0.0s

#16 [builder 3/8] RUN cargo chef cook --release --bin xxx --recipe-path recipe.json || true
#16 0.402     Updating crates.io index
#16 0.484  Downloading crates ...
#16 0.716   Downloaded time-core v0.1.1
#16 0.738   Downloaded serde v1.0.164
#16 0.752   Downloaded time v0.3.22
#16 0.838 error: no bin target named `xxx`.
#16 0.838 
#16 0.840 thread 'main' panicked at 'Exited with status code: 101', /usr/local/cargo/registry/src/index.crates.io-6f17d22bba15001f/cargo-chef-0.1.61/src/recipe.rs:189:27
#16 0.840 note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
#16 DONE 0.9s

#17 [builder 4/8] WORKDIR /app_workspace
#17 DONE 0.0s

#18 [builder 5/8] COPY --from=planner /app_workspace/recipe.json recipe.json
#18 DONE 0.0s

#19 [builder 6/8] RUN cargo chef cook --release --recipe-path recipe.json
#19 0.352    Compiling time-core v0.1.1
#19 0.436    Compiling time v0.3.22
#19 0.769    Compiling greet v0.0.1 (/common_workspace/greet)
#19 1.157    Compiling app v0.0.1 (/app_workspace/app)
#19 1.327     Finished release [optimized] target(s) in 1.11s
#19 DONE 1.4s

#20 [builder 7/8] COPY / /
#20 DONE 0.1s

#21 [builder 8/8] RUN cargo build --release --bin app
#21 0.438    Compiling greet v0.1.0 (/common_workspace/greet)
#21 0.529    Compiling app v0.1.0 (/app_workspace/app)
#21 0.724     Finished release [optimized] target(s) in 0.44s
#21 DONE 0.7s

#22 [runtime 3/3] COPY --from=builder /app_workspace/target/release/app /usr/local/bin
#22 DONE 0.0s

#23 exporting to image
#23 exporting layers 0.0s done
#23 writing image sha256:5950adc67d0dfdec1efe7e3c5073639c2d764b8f9bb2adbe7190a411ffbf403f done
#23 naming to docker.io/library/app done
#23 DONE 0.0s
````

## Run

````
$ docker run app                                   
Hello Bob at 2023-06-14 22:23:27.778037513 +00:00:00
````

## Rebuild with Cache hit

Note the CACHED stages / no recompilation of 3rd party crates :tada:

````
$ sed -i.bak 's/Hello/Goodbye/g' common_workspace/greet/src/lib.rs 
$ docker build . -t app --progress=plain
#1 [internal] load .dockerignore
#1 transferring context: 2B done
#1 DONE 0.0s

#2 [internal] load build definition from Dockerfile
#2 transferring dockerfile: 1.15kB done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/lukemathwalker/cargo-chef:latest
#3 DONE 1.5s

#4 [internal] load metadata for docker.io/library/debian:buster-slim
#4 DONE 2.0s

#5 [runtime 1/3] FROM docker.io/library/debian:buster-slim@sha256:738002a6e94e8629a0f869be8ea56519887979d5ed411486441981a8b16f2fc8
#5 DONE 0.0s

#6 [chef 1/1] FROM docker.io/lukemathwalker/cargo-chef@sha256:57b93c406c3a1a55a31063658e36763baba2a791e62b10611139a2536958d33c
#6 DONE 0.0s

#7 [internal] load build context
#7 transferring context: 36.14kB 0.0s done
#7 DONE 0.0s

#8 [planner 1/6] WORKDIR /common_workspace
#8 CACHED

#9 [planner 2/6] COPY /common_workspace .
#9 DONE 0.0s

#10 [planner 3/6] RUN cargo chef prepare --recipe-path recipe.json
#10 DONE 0.2s

#11 [planner 4/6] WORKDIR /app_workspace
#11 DONE 0.0s

#12 [planner 5/6] COPY /app_workspace .
#12 DONE 0.0s

#13 [planner 6/6] RUN cargo chef prepare --recipe-path recipe.json
#13 DONE 0.2s

#14 [builder 4/8] WORKDIR /app_workspace
#14 CACHED

#15 [builder 5/8] COPY --from=planner /app_workspace/recipe.json recipe.json
#15 CACHED

#16 [builder 2/8] COPY --from=planner /common_workspace/recipe.json recipe.json
#16 CACHED

#17 [builder 3/8] RUN cargo chef cook --release --bin xxx --recipe-path recipe.json || true
#17 CACHED

#18 [builder 6/8] RUN cargo chef cook --release --recipe-path recipe.json
#18 CACHED

#19 [builder 7/8] COPY / /
#19 DONE 0.0s

#20 [builder 8/8] RUN cargo build --release --bin app
#20 0.287    Compiling greet v0.1.0 (/common_workspace/greet)
#20 0.392    Compiling app v0.1.0 (/app_workspace/app)
#20 0.617     Finished release [optimized] target(s) in 0.48s
#20 DONE 0.6s

#21 [runtime 2/3] WORKDIR /app
#21 CACHED

#22 [runtime 3/3] COPY --from=builder /app_workspace/target/release/app /usr/local/bin
#22 DONE 0.0s

#23 exporting to image
#23 exporting layers 0.0s done
#23 writing image sha256:b72bb0f058123ca71d0cdc20aeb568ff94b8a7bd21028283d57ce7326b01e170 done
#23 naming to docker.io/library/app done
#23 DONE 0.0s

````


## Run

````
$ docker run app                                   
Goodbye Bob at 2023-06-14 22:27:36.264272836 +00:00:00
````