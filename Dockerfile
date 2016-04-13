FROM docker.artfire.me/atomica/arch-bootstrap:latest

COPY entrypoint.sh arch-base.sh /

RUN ["/bin/bash", "/arch-base.sh"]

# Entrypoint script until we can figure out a better way to handle user/group issues
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
