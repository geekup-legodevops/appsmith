FROM tanphat13/lego-fatc

COPY nginx.conf /etc/nginx/nginx.conf
COPY analytics.sh /analytics.sh
RUN chmod +x /analytics.sh

EXPOSE 80

ENTRYPOINT [ "/opt/appsmith/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-n"]