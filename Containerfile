FROM registry.fedoraproject.org/fedora:latest

ENV FRONTEND_VERSION="0.1" \
    RENV_CONFIG_CACHE_ENABLED="FALSE" \
    RENV_PATHS_ROOT="/srv/dashboard-frontend/renv/root" \
    XDG_CACHE_HOME="/var/cache" \
    DNF_CMD="dnf -y --setopt=deltarpm=false --setopt=install_weak_deps=false --setopt=tsflags=nodocs" \
    LANG=C.UTF-8

LABEL name="conscious-lang-dashboard-frontend" \
      vendor="Red Hat Conscious Language Working Group" \
      license="GPL-3.0-or-later" \
      org.opencontainers.image.title="" \
      org.opencontainers.image.version="$FRONTEND_VERSION" \
      org.opencontainers.image.description="The Conscious Language Dashboard frontend." \
      org.opencontainers.image.vendor="Red Hat Conscious Language Working Group" \
      org.opencontainers.image.authors="Red Hat Conscious Language Working Group <conscious-lang-group@redhat.com>" \
      org.opencontainers.image.licenses="GPL-3.0-or-later" \
      org.opencontainers.image.url="https://github.com/conscious-lang/dashboard-frontend" \
      org.opencontainers.image.source="https://github.com/conscious-lang/dashboard-frontend" \
      org.opencontainers.image.documentation="https://github.com/conscious-lang/dashboard-frontend" \
      distribution-scope="public"

CMD ["R", "-q", "-e", "shiny::runApp(host='0.0.0.0', port=8080)"]
EXPOSE 8080

RUN $DNF_CMD install R-core R-core-devel \
                     gcc libcurl-devel openssl-devel libxml2-devel cairo-devel && \
    $DNF_CMD clean all
COPY . /srv/dashboard-frontend
WORKDIR /srv/dashboard-frontend
RUN R -q -e "renv::restore()"

USER 1001
