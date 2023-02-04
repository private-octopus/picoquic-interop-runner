FROM martenseemann/quic-network-simulator-endpoint:latest AS builder

# download and build your QUIC implementation
# [ DO WORK HERE ]
USER root
WORKDIR /

RUN echo "Hello"
RUN cat /etc/fstab

COPY dkr-prereq.sh .
RUN chmod +x ./dkr-prereq.sh
RUN ./dkr-prereq.sh

ARG PICOTLS_DATE=2022-02-26
COPY dkr-picotls.sh .
RUN chmod +x ./dkr-picotls.sh
RUN ./dkr-picotls.sh

ARG PICOQUIC_DATE=2022-02-26
COPY dkr-install.sh .
RUN chmod +x ./dkr-install.sh
RUN ./dkr-install.sh

# Build second lean image
FROM martenseemann/quic-network-simulator-endpoint:latest
USER root
WORKDIR /
COPY --from=builder /picoquic /picoquic
# copy run script and run it
COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh
ENTRYPOINT [ "./run_endpoint.sh" ]
