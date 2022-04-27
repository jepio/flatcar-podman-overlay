ARG FLATCAR_VERSION=3200.0.0

FROM mediadepot/flatcar-developer:${FLATCAR_VERSION} AS base

CMD ["/bin/bash"]

RUN emerge-gitclone
RUN echo 'FEATURES="-network-sandbox -pid-sandbox -ipc-sandbox -usersandbox -sandbox"' >>/etc/portage/make.conf
COPY repos.conf /etc/portage/repos.conf/podman.conf
COPY . /var/lib/portage/podman-overlay/

FROM base AS builder
RUN emerge -j4 --getbinpkg --autounmask-write --autounmask-continue --onlydeps podman
RUN emerge -j4 --getbinpkg --buildpkgonly podman
RUN emerge --root=/work --nodeps --usepkgonly podman
RUN mkdir -p /work/usr/lib/extension-release.d && echo -e 'ID=flatcar\nSYSEXT_LEVEL=1.0' >/work/usr/lib/extension-release.d/extension-release.podman
RUN mkdir -p /work/usr/src
RUN mkdir -p /output && mksquashfs /work /output/podman.raw -noappend

FROM busybox
COPY --from=builder /output /output
CMD ["cp", "/output/podman.raw", "/out"]
