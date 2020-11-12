FROM ubuntu:16.04
RUN apt update

RUN apt install -y python-pip sudo apt-transport-https wget lsb-release sudo gnupg 

RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add -; \
    echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/renci-irods.list; \
    wget -qO - https://core-dev.irods.org/irods-core-dev-signing-key.asc | apt-key add -; \
    echo "deb [arch=amd64] https://core-dev.irods.org/apt/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/renci-irods-core-dev.list; \
    apt-get update 

ARG Irods_Version=4.2.8
ARG Python_Client_Commitish="master"
ARG Python_Client_Repository="https://github.com/irods/python-irodsclient"
ARG Output_Log_File=/tmp/prc_test_output.txt
ENV ENV_Output_Log_File="${Output_Log_File}"

RUN apt-get install -y 'irods-externals*' \
                        irods-runtime=${Irods_Version} \
                        irods-icommands=${Irods_Version} \
                        irods-server=${Irods_Version} \
                        irods-database-plugin-postgres=${Irods_Version}

RUN apt-get install -y postgresql git python3
RUN apt-get install -y  virtualenv
ADD ICAT.sql /
ADD run_time_irods_reinstall.sh /
RUN service postgresql start ; su - postgres -c "psql -f /ICAT.sql" ; sh /run_time_irods_reinstall.sh
RUN sed -i s/CommLog=1/CommLog=0/ /etc/odbcinst.ini ; rm -f /tmp/psql*_irods*.log

WORKDIR /var/lib/irods
USER irods
RUN git clone "${Python_Client_Repository}"
RUN cd python-irodsclient ;  git checkout "${Python_Client_Commitish}"
# -- Ubuntu 16.04 python-irodsclient installation won't work without this:
RUN pip install --upgrade pip
RUN cd /var/lib/irods/python-irodsclient; pip install --user .
# -- Python2 environment has now been installed within "~irods/.local"
#    whereas Python3 tests will run from a virtual environment in "~irods/py3"
RUN virtualenv -p python3 py3 ; . py3/bin/activate ; cd python-irodsclient ; pip install -e . 
WORKDIR /root
USER root
RUN apt install -y sudo
CMD sh /run_time_irods_reinstall.sh 5 second delay; \
    cd /var/lib/irods ; \
    sudo -H -Eu irods bash -c \
    'source py3/bin/activate ; cd python-irodsclient/irods/test ; python runner.py 2>&1|tee ${ENV_Output_Log_File}'
