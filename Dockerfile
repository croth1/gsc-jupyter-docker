FROM ubuntu:18.04

RUN useradd -ms /bin/bash -u 4242 gsc-course

EXPOSE 8888


RUN mkdir -p /tmp_files
WORKDIR /tmp_files

COPY apt_pkgs.txt apt_pkgs.txt
RUN apt-get update && xargs -a apt_pkgs.txt apt-get install --yes

COPY conda_base_pkgs.txt conda_base_pkgs.txt
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh



WORKDIR /home/gsc-course
USER gsc-course

RUN bash /tmp_files/Miniconda3-latest-Linux-x86_64.sh -b
RUN echo ". ~/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc
RUN echo "conda activate base" >> ~/.bashrc
ENV PATH /home/gsc-course/miniconda3/bin:$PATH

RUN conda install -c conda-forge --file /tmp_files/conda_base_pkgs.txt --yes

COPY py37.yml /tmp_files/py37.yml
RUN mamba env create --file /tmp_files/py37.yml

RUN . ~/miniconda3/etc/profile.d/conda.sh && conda activate py37 && ipython kernel install --user --name py37 --display-name py37

RUN conda clean --all --yes

COPY --chown=gsc-course misc_files/.gitattributes /home/gsc-course/.gitattributes
COPY --chown=gsc-course misc_files/.gitconfig /home/gsc-course/.gitconfig

RUN mkdir -p workspace

USER root
RUN rm -rf /tmp_files
RUN mkdir -p /etc/jupyter_cfg

USER gsc-course
WORKDIR /home/gsc-course/workspace
#ENTRYPOINT jupyter lab --config /etc/jupyter_cfg/jupyterlab_config.py
