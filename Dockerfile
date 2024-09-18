FROM dart:stable

# Install necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    xz-utils \
    git \
    curl \
    libglu1-mesa \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set Flutter version
ENV FLUTTER_VERSION=3.7.7

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter \
    && cd /usr/local/flutter \
    && git checkout $FLUTTER_VERSION

# Add Flutter to PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable Flutter stable channel and upgrade
RUN flutter channel stable \
    && flutter upgrade

# Accept Android SDK licenses (for Android builds)
RUN yes | flutter doctor --android-licenses

# Create a non-root user and set permissions
RUN useradd -ms /bin/bash developer \
    && echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && chown -R developer:developer /usr/local/flutter

# Set the user to `developer`
USER developer

# Set Git safe directory (to avoid permission issues)
RUN git config --global --add safe.directory /usr/local/flutter

# Set the working directory
WORKDIR /app

# Copy project files
COPY --chown=developer:developer . .

# Install Flutter project dependencies
RUN flutter pub get

# Run `flutter doctor` to ensure everything is set up correctly
RUN flutter doctor

# Expose the port for Flutter web (if using web)
EXPOSE 8080

# Default command to run the app (can be changed as needed)
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080"]
