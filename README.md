# Somleng

[![GitHub Action](https://github.com/somleng/somleng/actions/workflows/build.yml/badge.svg)](https://github.com/somleng/somleng/actions)
[![View performance data on Skylight](https://badges.skylight.io/status/DvGhX1IYIjrx.svg)](https://oss.skylight.io/app/applications/DvGhX1IYIjrx)
[![codecov](https://codecov.io/gh/somleng/somleng/branch/develop/graph/badge.svg?token=VotbVOJty2)](https://codecov.io/gh/somleng/somleng)

Somleng (part of [The Somleng Project](https://github.com/somleng/somleng-project)) is an Open Source Cloud Communications Platform as a Service (CPaaS).

You can use Somleng to roll out your own programmable voice and SMS to:

* 🏥 [Save lives](https://www.somleng.org/case_studies.html#early-warning-system-cambodia)
* 🧒🏽 [Improve the lives of children](https://www.somleng.org/case_studies.html#mhealth-unicef-guatemala)
* 🤑 [For fun or profit](https://www.somleng.org/case_studies.html#powering-cpaas-mexico)

## Documentation

* 📚 [Documentation](https://www.somleng.org/docs.html)

## Getting Started

In order to get the full Somleng stack up and running on your development machine, please follow the [GETTING STARTED](https://github.com/somleng/somleng-project/blob/master/docs/GETTING_STARTED.md) guide.


## Local Deployment
### Docker
Start the docker instance for ruby where the repo is cloned:
```
docker run --rm -w /app --net=host -v ${PWD}/somleng:/app -it ruby:3.1 bash
```

Setup the Instance for usage:
```
apt update
apt install curl libpcre2-posix2 libpcre2-dev build-essential git postgresql nodejs vim screen iproute2 net-tools -y
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt install yarn -y
```

Setup and launch the application:
```
bundle config --local deployment true
bundle config --local path "vendor/bundle"
bundle config --local without 'development test'
bundle install --jobs 20 --retry 5
yarn install --frozen-lockfile
bundle exec rails assets:precompile
mkdir -p tmp/pids

# Start the application
# Necessary config changes can be made in config/app_settings.yml
bundle exec puma -C config/puma.rb
```

### MacOS Setup
Prelimnary installation:
```
brew install yarn
brew install ruby # Ruby 3.1
brew install libpq # PostgreSQL Client
brew install pcre
```

Setup and launch the application:
```
export CPATH="/opt/homebrew/include:/opt/homebrew/Cellar/libpq/15.1/include:$CPATH"
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/opt/libpq/bin:$PATH"
bundle config --local deployment true
bundle config --local path "vendor/bundle"
bundle config --local without 'development test'
bundle install --jobs 20 --retry 5
yarn install --frozen-lockfile
bundle exec rails assets:precompile
mkdir -p tmp/pids

# Start the application
# Necessary config changes can be made in config/app_settings.yml
bundle exec puma -C config/puma.rb
```

## Deployment

The [infrastructure directory](https://github.com/somleng/somleng/tree/develop/infrastructure) contains [Terraform](https://www.terraform.io/) configuration files in order to deploy Somleng to AWS.

:warning: Our infrastructure is rapidly changing as we continue to improve and experiment with new features. We often make breaking changes to the infrastructure which usually requires some manual migration. We don't recommend that you try to deploy and run your own Somleng stack for production purposes at this stage.

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
