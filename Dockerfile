# ================================
# Build image
# ================================
FROM swiftlang/swift:nightly-5.5-bionic as builder

WORKDIR /workspace

# Copy entire repo into container
# This copy the build folder to improve package resolve
COPY . /workspace

# Resolve Swift dependencies
RUN swift package resolve

# Compile with optimizations
RUN swift build -c release


# ================================
# Run image
# ================================
FROM gcr.io/distroless/cc-debian10:debug

LABEL org.opencontainers.image.source https://github.com/ydataai/dashboard-api

COPY --from=builder /lib/x86_64-linux-gnu/libz* /lib/x86_64-linux-gnu/

# copy executables
COPY --from=builder /workspace/.build/release /
# copy Swift's dynamic libraries dependencies
COPY --from=builder /usr/lib/swift/linux/lib*so* /

ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0"]
