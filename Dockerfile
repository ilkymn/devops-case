FROM node:14

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 4000

CMD ["npm", "start"]

FROM jenkins/ssh-agent:latest-alpine3.19

RUN wget https://go.dev/dl/go1.22.2.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz

ENV PATH="$PATH:/usr/local/go/bin"

# Alpine's ssh doesn't use $PATH defined in /etc/environment, so we define `$PATH` in `~/.ssh/environment`
RUN echo "PATH=${PATH}" >> ${JENKINS_AGENT_HOME}/.ssh/environment