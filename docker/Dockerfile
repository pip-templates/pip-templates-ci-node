FROM pipdevs/node:8.4.0-python

# Copy npm config
COPY docker/.npmrc /root/.npmrc

# Copy local ssh keys
COPY docker/id_rsa /root/.ssh/

# Setup ssh access to git repositories
RUN chmod 600 /root/.ssh/id_rsa* \
    && ssh-keyscan github.com >> ~/.ssh/known_hosts \
    && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts \
    && git config --global --add url."git@github.com:".insteadOf "https://github.com/"

# Set working directory
WORKDIR /app

# Copy project file
COPY package.json .

# Install only production dependencies
RUN npm install

# Copy the entire project
COPY . .

# Set default environment variables
ENV MONGO_SERVICE_URI ""
ENV MONGO_SERVICE_HOST mongo
ENV MONGO_SERVICE_PORT 27017
ENV MONGO_DB app

# Expose http and grpc ports
EXPOSE 8080
EXPOSE 8090

# Set container entrypoint
ENTRYPOINT [ "node", "./bin/run.js" ]
