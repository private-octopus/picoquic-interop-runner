FROM martenseemann/quic-network-simulator-endpoint:latest

# download and build your QUIC implementation
# [ DO WORK HERE ]
USER root
WORKDIR /

COPY dkr-prereq.sh .
RUN chmod +x ./dkr-prereq.sh
RUN ./dkr-prereq.sh

ARG PICOTLS_DATE=2020-01-05
COPY dkr-picotls.sh .
RUN chmod +x ./dkr-picotls.sh
RUN ./dkr-picotls.sh

ARG PICOQUIC_DATE=2020-01-06
COPY dkr-install.sh .
RUN chmod +x ./dkr-install.sh
RUN ./dkr-install.sh

# copy run script and run it
COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh
ENTRYPOINT [ "./run_endpoint.sh" ]

