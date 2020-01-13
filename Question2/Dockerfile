FROM tiangolo/uwsgi-nginx:python3.7

LABEL Author="Tochukwu Nwoko"
LABEL E-mail="nwokotochukwu@gmail.com"
LABEL version="0.0.1b"

#RUN mkdir /app
WORKDIR /app

COPY  . /app
RUN echo "nameserver 8.8.8.8"> /etc/resolv.conf
#RUN ping 8.8.8.8
RUN   pip install flask


ADD . /app

EXPOSE 8000

CMD python server.py