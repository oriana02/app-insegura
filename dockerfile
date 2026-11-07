FROM jenkins/jenkins:lts
USER root

# Instalar Python3 y pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv curl && \
    apt-get clean

# Instalar Flask para tu aplicación
RUN pip3 install flask --break-system-packages

USER jenkins