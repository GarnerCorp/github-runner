FROM debian:buster-slim

ARG GITHUB_RUNNER_VERSION

ENV RUNNER_NAME "runner"
ENV GITHUB_PAT ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV RUNNER_WORKDIR "_work"
ENV RUNNER_LABELS ""

RUN apt-get update \
    && apt-get install -y \
        curl \
        sudo \
        git \
        jq \
        iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m github \
    && usermod -aG sudo github \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER github
WORKDIR /home/github

RUN dash -c 'GITHUB_RUNNER_VERSION="'${GITHUB_RUNNER_VERSION}'"; GITHUB_RUNNER_VERSION=${GITHUB_RUNNER_VERSION:-$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name)} '\
'&& curl -Ls https://github.com/actions/runner/releases/download/${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION#?}.tar.gz | tar xz '\
'&& sudo ./bin/installdependencies.sh'

COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

ENTRYPOINT ["/home/github/entrypoint.sh"]
