FROM ubuntu:18.04

RUN useradd -ms /bin/bash gsc-course

EXPOSE 8888


RUN mkdir -p /tmp_files
WORKDIR /tmp_files

COPY apt_pkgs.txt apt_pkgs.txt
RUN apt-get update && xargs -a apt_pkgs.txt apt-get install --yes

COPY py27.yml py27.yml
COPY py37.yml py37.yml
COPY conda_base_pkgs.txt conda_base_pkgs.txt
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh



WORKDIR /home/gsc-course
USER gsc-course

RUN bash /tmp_files/Miniconda3-latest-Linux-x86_64.sh -b
RUN echo ". ~/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc
RUN echo "conda activate base" >> ~/.bashrc
ENV PATH /home/gsc-course/miniconda3/bin:$PATH

RUN conda install -c conda-forge --file /tmp_files/conda_base_pkgs.txt --yes
RUN conda env create --file /tmp_files/py27.yml
RUN . ~/miniconda3/etc/profile.d/conda.sh && conda activate py27 && ipython kernel install --user --name py27 --display-name py27
RUN conda env create --file /tmp_files/py37.yml
RUN . ~/miniconda3/etc/profile.d/conda.sh && conda activate py37 && ipython kernel install --user --name py37 --display-name py37

RUN mkdir -p workspace

USER root
RUN rm -rf /tmp_files
RUN mkdir -p /etc/jupyter_cfg

USER gsc-course
WORKDIR /home/gsc-course/workspace
ENTRYPOINT jupyter lab --config /etc/jupyter_cfg/jupyterlab_config.py
