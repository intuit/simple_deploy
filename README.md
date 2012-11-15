[![Build Status](https://secure.travis-ci.org/intuit/simple_deploy.png)](http://travis-ci.org/intuit/simple_deploy)

Simple Deploy is an opinionated gem that helps manage and perform directed deployments to AWS Cloud Formation Stacks.

Prerequisites
-------------

* Ruby version 1.9.2 or higher installed.
* AWS account access key and secret key.

Installation
------------

Install the gem

```
gem install simple_deploy --no-ri --no-rdoc
```

Create a file **~/.simple_deploy.yml** and include within it:

```
environments:
  preprod:
    access_key: XXX
    secret_key: yyy
    region: us-west-1
```

Notifications
-------------

Currently Simple Deploy only supports Campfire for notifications.  To enable them, add your token, which can be obtained on the 'My Info' screen of Campfire in the notifications yaml above.  If you don't want notificaitons, omit this section.

To enable notifications on deployment to a Campfire room. Append the below to the **~/.simple_deploy.yml**.

```
notifications:
  campfire:
    token: XXX
```

Commands
--------

For a list of commands, run **simple_deploy -h**.  To get more information about each subcommand, append a -h after the subcomand.  For example: **simple_deploy deploy -h**.

Deploying
---------

By default simple deploy will use your user name and id_rsa key for deployments.  To override either these, set the **SIMPLE_DEPLOY_SSH_USER** & **SIMPLE_DEPLOY_SSH_KEY** respectively.

```
export SIMPLE_DEPLOY_SSH_USER=user
export SIMPLE_DEPLOY_SSH_KEY=path_to_ssh_key
```

An alternate config file can be supplied by setting the **SIMPLE_DEPLOY_CONFIG_FILE** variable.

```
export SIMPLE_DEPLOY_CONFIG_FILE=/secret/my-config.yml
```
