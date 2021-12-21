FROM alpine:3.14

ENV APP_ROOT /var/www/html

# install packages
RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache \
    busybox-extras \
    bash \
    curl \
    git \
    mailx \
    supervisor \
    nodejs \
    npm

WORKDIR ${APP_ROOT}

# MailDev
ENV MAILDEV_REPO_COMMIT_ID 96248f8c38bd269f541dd91e60ad560f57eb46a0
RUN git clone https://github.com/maildev/maildev.git && \
    cd maildev && \
    git reset --hard ${MAILDEV_REPO_COMMIT_ID} && \
    npm ci --only=production && \
    ln -fs ${APP_ROOT}/maildev/bin/maildev /usr/local/bin/maildev

# sendgrid-dev
ARG SENDGRID_DEV_RELEASE=v0.9.0
ARG TARGETPLATFORM
# https://qqq.ninja/blog/post/binpot/#support-arm64
RUN case "${TARGETPLATFORM}" in \
      linux/amd64) ARCH=x86_64; break;; \
      linux/arm64) ARCH=aarch64; break;; \
      *) echo "unsupported platform ${TARGETPLATFORM}"; exit 1;; \
    esac && \
    curl -L -o /usr/local/bin/sendgrid-dev \
    https://github.com/yKanazawa/sendgrid-dev/releases/download/${SENDGRID_DEV_RELEASE}/sendgrid-dev_${ARCH}
RUN chmod 755 /usr/local/bin/sendgrid-dev

# superviserd
COPY supervisor/supervisord.conf /etc/supervisord.conf
COPY supervisor/app.conf /etc/supervisor/conf.d/app.conf
RUN echo files = /etc/supervisor/conf.d/*.conf >> /etc/supervisord.conf

# Service to run
CMD ["/usr/bin/supervisord"]
