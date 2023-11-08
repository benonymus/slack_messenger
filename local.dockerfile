FROM elixir:1.15.7
ENV DEBIAN_FRONTEND=noninteractive

# Suggested https://hexdocs.pm/phoenix/installation.html
RUN apt-get update && apt-get install -y \
    inotify-tools \
 && rm -rf /var/lib/apt/lists/*

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install hex phx_new

# When this image is run, make /app the current working directory
WORKDIR /app
