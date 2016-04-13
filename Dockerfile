FROM alpine

ENV WEB_ROOT=/data/www
ENV FTP_GID=5000
ENV FTP_GRP=ftpusers
ENV FTP_UID=5001
ENV FTP_USER=ftpuser
ENV FTP_PASSWD=ftpuserpasswd
ENV FTP_ADDRESS=0.0.0.0

RUN mkdir -p $WEB_ROOT

RUN addgroup -g $FTP_GID $FTP_GRP
RUN adduser -h $WEB_ROOT -s /bin/sh -u $FTP_UID $FTP_USER -G $FTP_GRP -D

COPY buildfiles/alpine/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY buildfiles/alpine/ftpd.key /etc/vsftpd/
COPY buildfiles/alpine/ftpd.crt /etc/vsftpd/

RUN sed -i -e"s/pasv_address=localhost/pasv_address=$FTP_ADDRESS/" /etc/vsftpd/vsftpd.conf

RUN echo "$FTP_USER:$FTP_PASSWD" | chpasswd

RUN apk update && apk add --no-cache openssh vsftpd && \
        ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
        ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N '' && \
        ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
        ssh-keygen -A

RUN echo '/usr/sbin/sshd -f /etc/ssh/sshd_config' > /run.sh && \
    echo '/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf' >> /run.sh && \
chmod u+x /run.sh

ENTRYPOINT ["/bin/sh", "/run.sh"]
