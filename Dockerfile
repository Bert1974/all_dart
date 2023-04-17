#Stage 1 - Install dependencies and build the app
FROM debian:latest AS flutter_base
EXPOSE 2222
SHELL ["/bin/bash", "-c"]

# Install flutter dependencies
RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 golang
RUN apt-get clean

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter path
# RUN /usr/local/flutter/bin/flutter doctor -v
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable flutter web
RUN flutter channel beta
RUN flutter upgrade
RUN flutter config --enable-web
# Run flutter doctor
RUN flutter doctor -v

FROM flutter_base AS flutter_build
SHELL ["/bin/bash", "-c"]

# Copy files to container and build
WORKDIR /app
COPY . /app/

RUN ./build.sh

# Stage 2 - Create the run-time image
FROM flutter_build as all_dart
SHELL ["/bin/bash", "-c"]
WORKDIR /app/publish
COPY --from=flutter_build /app/publish/ /app/publish/
ENTRYPOINT ["/bin/bash", "/app/publish/start.sh"]
