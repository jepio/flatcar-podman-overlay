ARG FLATCAR_VERSION=3200.0.0

FROM mediadepot/flatcar-developer:${FLATCAR_VERSION} AS base

CMD ["/bin/bash"]

RUN emerge-gitclone
RUN echo 'FEATURES="-network-sandbox -pid-sandbox -ipc-sandbox -usersandbox -sandbox"' >>/etc/portage/make.conf
RUN mkdir -p /etc/portage/package.accept_keywords && \
  echo 'app-containers/snapd ~*' >/etc/portage/package.accept_keywords/snapd
COPY repos.conf /etc/portage/repos.conf/snapd.conf
COPY . /var/lib/portage/snapd-overlay

FROM base AS builder
RUN emerge -j4 --getbinpkg --autounmask-write --autounmask-continue --onlydeps snapd
RUN emerge -j4 --getbinpkg --buildpkgonly snapd

FROM base
COPY --from=builder /var/lib/portage/pkgs /var/lib/portage/pkgs
