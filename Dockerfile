FROM perl:5.30-slim
MAINTAINER "Oleg Fiksel"
COPY dockersource.pl /opt/dockersource/
#ENTRYPOINT [ "perl", "/opt/dockersource/dockersource.pl" ]
