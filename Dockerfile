FROM ubuntu:18.04

RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                bzip2 \
                ca-certificates \
                libffi-dev \
                libgmp-dev \
                libssl1.0-dev \
                git \
                libyaml-dev \
                procps \
                zlib1g-dev \
        ; \
        rm -rf /var/lib/apt/lists/*
# skip installing gem documentation
RUN set -eux; \
        mkdir -p /srv/gration;\
        { \
                echo 'gem: --no-rdoc --no-ri'; \
        } >> /root/.gemrc

# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
RUN set -eux; \
        \
        savedAptMark="$(apt-mark showmanual)"; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                autoconf \
                bison \
                dpkg-dev \
                gcc \
                libbz2-dev \
                libgdbm-compat-dev \
                libgdbm-dev \
                libglib2.0-dev \
                libncurses-dev \
                libreadline-dev \
                libxml2-dev \
                libxslt-dev \
                make \
                ruby \
                wget \
                subversion \
                xz-utils \
        ; \
        \
# installing rbenv
        export PATH=/root/.rbenv/bin:/root/.rbenv/shims:$PATH;\
        wget -q https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer -O- | bash;\
        echo 'export PATH="/root/.rbenv/bin:${PATH}"' >> /root/.bashrc ;\
        echo 'eval "$(rbenv init -)"' >> /root/.bashrc ;\
        git -C /root/.rbenv/plugins/ruby-build pull ;\
        { \
            echo 'require_gcc';\
            echo 'install_svn "ruby-1.8.7-p376" "http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_7" "67883" warn_eol autoconf auto_tcltk standard';\
            echo 'install_package "rubygems-1.6.2" "https://rubygems.org/rubygems/rubygems-1.6.2.tgz#cb5261818b931b5ea2cb54bc1d583c47823543fcf9682f0d6298849091c1cea7" ruby';\
        } >> /root/.rbenv/plugins/ruby-build/share/ruby-build/1.8.7-p376;\
        rbenv install -v 1.8.7-p376 ;\
        rbenv global 1.8.7-p376 ;\
        apt install -y --no-install-recommends libmysqlclient-dev ;\
        gem install mysql ;\
        rm -rf /var/lib/apt/lists/*; \
        gem install rake -v '~>0.8.7' ;\
        gem install i18n -v '~>0.6.4' ;\
        gem install rails -v '~>2.3.18' ;\
        gem install bundler -v '~>1.6.9' ;\
        apt-mark auto '.*' > /dev/null; \
        apt-mark manual $savedAptMark > /dev/null; \
        find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
                | awk '/=>/ { print $(NF-1) }' \
                | sort -u \
                | xargs -r dpkg-query --search \
                | cut -d: -f1 \
                | sort -u \
                | xargs -r apt-mark manual \
        ; \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        \
        cd /; \
# rough smoke test
        ruby --version; \
        gem --version; \
        bundle --version

# don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
        BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 755 "$GEM_HOME"

CMD [ "irb" ]
