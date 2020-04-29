# picoquic-interop-runner
Creating a docket container adequate for testing the picoquic
implementation as part of the "quic interop runner" effort.

To update the docker container:

1) Clone this repo, e.g. in `./picoquic-interop-runner`

2) Update the script, etc.

3) Build the new version of the docker container:
```
sudo docker build --build-arg PICOQUIC_DATE=2020-04-27 -t privateoctopus/picoquic ../picoquic-interop-runner/
```

4) Upload the new docker container:
```
sudo docker push privateoctopus/picoquic:latest
```




