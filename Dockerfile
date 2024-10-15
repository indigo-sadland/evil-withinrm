# evil-withinrm Dockerfile

# Base image
FROM alpine:3.14 AS final
FROM alpine:3.14 AS build

# Credits & Data
LABEL \
    name="evil-withinrm" \
    author="CyberVaca <cybervaca@gmail.com>" \
    maintainer="OscarAkaElvis <oscar.alfonso.diaz@gmail.com>" \
    description="The ultimate WinRM shell for hacking/pentesting"

#Env vars
ENV EVILWINRM_URL="https://github.com/Hackplayers/evil-withinrm.git"

# Install dependencies for building ruby with readline and openssl support
RUN apk --no-cache add cmake \
    clang \
    clang-dev \
    make \
    gcc \
    g++ \
    libc-dev \
    linux-headers \
    readline \
    readline-dev \
    yaml \
    yaml-dev \
    libffi \
    libffi-dev \
    zlib \
    zlib-dev \
    openssl-dev \
    openssl \
    bash

# Make the ruby path available
ENV PATH=$PATH:/opt/rubies/ruby-3.2.2/bin

# Get ruby-install for building ruby 3.2.2
RUN cd /tmp/ && \
    wget -O /tmp/ruby-install-0.8.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.8.1.tar.gz && \
    tar -xzvf ruby-install-0.8.1.tar.gz && \
    cd ruby-install-0.8.1/ && make install && \
    ruby-install -c ruby 3.2.2 -- --with-readline-dir=/usr/include/readline --with-openssl-dir=/usr/include/openssl --disable-install-rdoc

# evil-withinrm install method 1 (only one method can be used, other must be commented)
# Install evil-withinrm (DockerHub automated build process)
RUN mkdir /opt/evil-withinrm
COPY . /opt/evil-withinrm

# evil-withinrm install method 2 (only one method can be used, other must be commented)
# Install evil-withinrm (manual image build)
# Uncomment git clone line and one of the ENV vars to select branch (master->latest, dev->beta)
#ENV BRANCH="master"
#ENV BRANCH="dev"
#RUN git clone -b ${BRANCH} ${EVILWINRM_URL}

# Install evil-withinrm ruby dependencies
RUN gem install winrm \
    winrm-fs \
    stringio \
    logger \
    fileutils

# Clean and remove useless files
RUN rm -rf /opt/evil-withinrm/resources > /dev/null 2>&1 && \
    rm -rf /opt/evil-withinrm/.github > /dev/null 2>&1 && \
    rm -rf /opt/evil-withinrm/CONTRIBUTING.md > /dev/null 2>&1 && \
    rm -rf /opt/evil-withinrm/CODE_OF_CONDUCT.md > /dev/null 2>&1 && \
    rm -rf /opt/evil-withinrm/Dockerfile > /dev/null 2>&1 && \
    rm -rf /opt/evil-withinrm/Gemfile* > /dev/null 2>&1

# Rename script name
RUN mv /opt/evil-withinrm/evil-withinrm.rb /opt/evil-withinrm/evil-withinrm && \
    chmod +x /opt/evil-withinrm/evil-withinrm

# Base final image
FROM final

# Install readline and other dependencies
RUN apk --no-cache add \
    readline \
    yaml \
    libffi \
    zlib \
    openssl

# Make the ruby and evil-withinrm paths available
ENV PATH=$PATH:/opt/rubies/ruby-3.2.2/bin:/opt/evil-withinrm

# Copy built stuff from build image
COPY --from=build /opt /opt

# Create volume for powershell scripts
RUN mkdir /ps1_scripts
VOLUME /ps1_scripts

# Create volume for executable files
RUN mkdir /exe_files
VOLUME /exe_files

# Create volume for data (upload/download)
RUN mkdir /data
VOLUME /data

# set current working dir
WORKDIR /data

# Start command (launching evil-withinrm)
ENTRYPOINT ["evil-withinrm"]
