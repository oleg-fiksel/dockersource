FROM perl:5.30-slim

#RUN cpanm Carton
#COPY cpanfile /opt/dockersource/
#WORKDIR /opt/dockersource
#RUN carton install

COPY dockersource.pl /opt/dockersource/

ENTRYPOINT [ "perl", "/opt/dockersource/dockersource.pl" ]