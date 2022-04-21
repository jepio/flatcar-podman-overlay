ARG FLATCAR_VERSION=3200.0.0

FROM mediadepot/flatcar-developer:${FLATCAR_VERSION} AS base

CMD ["/bin/bash"]

RUN emerge-gitclone
RUN echo 'FEATURES="-network-sandbox -pid-sandbox -ipc-sandbox -usersandbox -sandbox"' >>/etc/portage/make.conf
RUN mkdir -p /etc/portage/package.accept_keywords && \
  echo 'app-containers/snapd ~*' >/etc/portage/package.accept_keywords/snapd
COPY repos.conf /etc/portage/repos.conf/snapd.conf
COPY . /var/lib/portage/snapd-overlay/

FROM base AS builder
RUN emerge -j4 --getbinpkg --autounmask-write --autounmask-continue --onlydeps snapd
RUN emerge -j4 --getbinpkg --buildpkgonly snapd
RUN emerge --root=/work --nodeps --usepkgonly snapd squashfs-tools
RUN mkdir -p /work/usr/lib/extension-release.d && echo -e 'ID=flatcar\nSYSEXT_LEVEL=1.0' >/work/usr/lib/extension-release.d/extension-release.snapd
RUN mkdir -p /work/usr/src
RUN mkdir -p /output && mksquashfs /work /output/snapd.raw -noappend

FROM busybox
COPY --from=builder /output /output
CMD ["cp", "/output/snapd.raw", "/out"]
