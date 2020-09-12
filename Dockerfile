# build kustomize
FROM golang:1.14 as build-kustomize

ARG KUSTOMIZE_VERSION

RUN apt-get update \
    && apt-get install -y git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/kubernetes-sigs/kustomize.git -b v${KUSTOMIZE_VERSION} \
    && cd kustomize/kustomize \
    && go install

# build sops
FROM golang:1.14 as build-sops

ARG SOPS_VERSION

RUN apt-get update \
    && apt-get install -y git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/mozilla/sops.git -b v${SOPS_VERSION} \
    && cd sops/cmd/sops \
    && go install

FROM sminamot/github-actions-runner:2.273.1

ARG KUBECTL_VERSION

RUN sudo apt-get update \
    && sudo apt-get install -y gnupg \
    && sudo wget https://curl.haxx.se/ca/cacert.pem -O /usr/local/share/ca-certificates/cacert.pem \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
    && sudo apt-get update \
    && sudo apt-get install -y kubectl=${KUBECTL_VERSION}-00

COPY --from=build-kustomize /go/bin/kustomize /usr/local/bin/kustomize
COPY --from=build-sops /go/bin/sops /usr/local/bin/sops
