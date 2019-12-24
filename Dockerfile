FROM martenseemann/quic-network-simulator-endpoint:latest

# download and build your QUIC implementation
# [ DO WORK HERE ]
USER root
WORKDIR /

COPY dkr-install.sh .
RUN chmod +x ./dkr-install.sh
RUN ./dkr-install.sh

# copy run script and run it
COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh
ENTRYPOINT [ "./run_endpoint.sh" ]

