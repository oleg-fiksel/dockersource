FROM perl:5.30

#RUN cpanm Carton
#COPY cpanfile /opt/dockersource/
WORKDIR /opt/dockersource
#RUN carton install

COPY dockersource.pl /opt/dockersource/

CMD [ "perl", "/opt/dockersource/dockersource.pl" ]