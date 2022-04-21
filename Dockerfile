ARG FLATCAR_VERSION=3200.0.0

FROM mediadepot/flatcar-developer:${FLATCAR_VERSION}

CMD ["/bin/bash"]

RUN emerge-gitclone
RUN echo 'FEATURES="-network-sandbox -pid-sandbox -ipc-sandbox"' >>/etc/portage/make.conf
