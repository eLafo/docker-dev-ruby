FROM ruby:2.3.4-slim
MAINTAINER eLafo

######### GENERAL DEVELOPMENT LIBRARIES AND TOOLS #########

RUN apt-get update &&\
    echo "debconf debconf/frontend select Teletype" | debconf-set-selections &&\
    apt-get install -y -qq --no-install-recommends vim sudo git curl wget build-essential ruby-dev software-properties-common bash-completion silversearcher-ag nodejs libpq-dev tzdata libxml2-dev libxslt-dev ssh postgresql postgresql-contrib

# Install Homesick, through which dotfiles configurations will be installed
RUN gem install homesick --no-rdoc --no-ri

######### SSH ########

# Install the Github Auth gem, which will be used to get SSH keys from GitHub
# to authorize users for SSH
RUN gem install github-auth --no-rdoc --no-ri

# Set up SSH. We set up SSH forwarding so that transactions like git pushes
# from the container happen magically.
RUN apt-get install -y openssh-server -qq --no-install-recommends &&\
    mkdir /var/run/sshd &&\
    echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config &&\
    echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config

# Expose SSH
EXPOSE 22

###### USER CREATION #########
ENV USER_NAME=dev

RUN useradd $USER_NAME -d /home/$USER_NAME -m -s /bin/bash &&\
    adduser $USER_NAME sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


########## TERMINAL ##########

# Config TERM
ENV TERM=screen-256color

# Install tmux
RUN apt-get install -y -qq --no-install-recommends libevent-dev libncurses-dev
RUN cd /tmp && wget https://github.com/tmux/tmux/releases/download/2.4/tmux-2.4.tar.gz 
RUN cd /tmp && tar -zxvf /tmp/tmux-2.4.tar.gz && cd /tmp/tmux-2.4 && ./configure && make && make install

# Install wemux
RUN git clone git://github.com/zolrath/wemux.git /usr/local/share/wemux &&\
    ln -s /usr/local/share/wemux/wemux /usr/local/bin/wemux &&\
    cp /usr/local/share/wemux/wemux.conf.example /usr/local/etc/wemux.conf &&\
    echo "host_list=(dev)" >> /usr/local/etc/wemux.conf

COPY ssh_key_adder.rb /home/dev/ssh_key_adder.rb 
COPY ssh_start.sh /home/dev/ssh_start.sh

RUN chown dev:dev /home/dev/ssh_key_adder.rb &&\
    chmod +x /home/dev/ssh_key_adder.rb &&\
    chmod +x /home/dev/ssh_start.sh 

###### USER CONFIGURATION #######
USER $USER_NAME

# Dotfiles

RUN \
# Set up The Editor of the Gods
    homesick clone https://github.com/eLafo/vim-dot-files.git &&\
    homesick symlink vim-dot-files &&\
    exec vim -c ":PluginInstall" -c "qall"

RUN \
    homesick clone eLafo/git-dot-files &&\
    homesick symlink git-dot-files

RUN \
    homesick clone eLafo/bash-dot-files &&\
    homesick symlink --force=true bash-dot-files

RUN \
    homesick clone eLafo/tmux-dot-files &&\
    homesick symlink --force=true tmux-dot-files

# Setting locale
RUN locale-gen es_ES.UTF-8 en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

#### DEVELOPMENT ENVIRONMENT CONFIGURATION #####
ENV APP_HOME=/workspace
ENV GEM_HOME=$APP_HOME/vendor/bundle
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_BIN $BUNDLE_PATH/bin
ENV BUNDLE_APP_CONFIG $APP_HOME/.bundle
ENV PATH $BUNDLE_BIN:$PATH

RUN sudo mkdir $APP_HOME
VOLUME $APP_HOME

WORKDIR $APP_HOME

#VOLUME /home/dev/app
# Install the SSH keys of ENV-configured GitHub users before running the SSH
# server process. See README for SSH instructions.
CMD echo "Development environment ready"


#RUN mkdir ~/.ssh
# Start by changing the apt otput, as stolen from Discourse's Dockerfiles.
#RUN echo "debconf debconf/frontend select Teletype" | debconf-set-selections &&\
# Probably a good idea
    #apt-get update &&\

# Basic dev tools
    #apt-get install -y sudo openssh-client git build-essential vim ctags man curl direnv software-properties-common locales bash-completion silversearcher-ag

#RUN useradd dev -d /home/dev -m -s /bin/bash &&\
    #adduser dev sudo && \
    #echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#USER dev
#WORKDIR /home/dev
#RUN mkdir /home/dev/.ssh

