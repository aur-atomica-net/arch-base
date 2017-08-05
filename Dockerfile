FROM atomica/arch-bootstrap:latest

COPY arch-base.sh /

RUN ["/bin/bash", "/arch-base.sh"]

RUN useradd --groups wheel --shell /bin/bash --home-dir /dev/null --no-create-home code_executor \
	&& echo 'code_executor ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY entrypoint.sh match-ids.sh /

# Entrypoint script until we can figure out a better way to handle user/group issues
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
