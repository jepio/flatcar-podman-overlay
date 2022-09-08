ARG FLATCAR_VERSION=3227.2.2

FROM mediadepot/flatcar-developer:${FLATCAR_VERSION} AS base

CMD ["/bin/bash"]

RUN emerge-gitclone
RUN echo 'FEATURES="-network-sandbox -pid-sandbox -ipc-sandbox -usersandbox -sandbox"' >>/etc/portage/make.conf
COPY repos.conf /etc/portage/repos.conf/podman.conf
COPY overlay /var/lib/portage/podman-overlay/

FROM base AS builder
RUN emerge -j4 --getbinpkg --autounmask-write --autounmask-continue --onlydeps podman
RUN emerge -j4 --getbinpkg --buildpkgonly podman squashfs-tools

FROM base AS staging
COPY --from=builder /var/lib/portage/pkgs /var/lib/portage/pkgs
RUN emerge --getbinpkg --usepkg squashfs-tools
RUN pkgs=$(emerge 2>/dev/null --usepkgonly --pretend podman | awk -F'] ' '/binary/{ print $ 2 }' | awk '{ print "="$1 }'); emerge --usepkgonly --root=/work --nodeps $pkgs
RUN mkdir -p /work/usr/lib/extension-release.d && echo -e 'ID=flatcar\nSYSEXT_LEVEL=1.0' >/work/usr/lib/extension-release.d/extension-release.podman
RUN mkdir -p /work/usr/src
RUN mv /work/etc /work/usr/etc
COPY usr /work/usr
RUN mv /work/opt/cni/bin /work/usr/lib/cni
RUN rm -rf /work/var /work/usr/include /work/usr/lib*/cmake /work/opt/cni
RUN rmdir /work/opt
RUN mkdir -p /output && mksquashfs /work /output/podman.raw -noappend

FROM busybox AS torcx
RUN mkdir /work /output
COPY torcx /work
RUN tar -zcvf /output/docker:podman.torcx.tgz -C /work .

FROM busybox
COPY --from=staging /output /output
COPY --from=torcx /output /output
CMD ["cp", "/output/podman.raw", "/output/docker:podman.torcx.tgz", "/out"]
