FROM perl:5.30-slim
LABEL maintainer="Oleg Fiksel"
COPY dockersource.pl /opt/dockersource/
#ENTRYPOINT [ "perl", "/opt/dockersource/dockersource.pl" ]
