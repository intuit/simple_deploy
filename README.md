I use the stackster to manage stacks, however I understand how to connect to different regions / accounts as well as kick off a deployment on instances.

Getting Started
---------------

Install the gem

```
gem install simple_deploy
```

Create a file **~/.simple_deploy.yml** and include within it:

```
artifacts: 
  chef_repo:
    bucket_prefix: intu-lc
    domain: live_community_chef_repo
  app:
    bucket_prefix: intu-lc
    domain: live_community
  cookbooks:
    bucket_prefix: intu-artifacts

environments:
  preprod_shared_us_west_1:
    access_key: XXX
    secret_key: yyy
    region: us-west-1
```

Configuration File
------------------

The configuration file supports additional optional deployment parameters.  Artifacts can have an **endpoint** specified to be passed in (by default they pass in the s3 url).

Deploy can have a ssh **user** and **key** set.  These will be used to connect to both the gateway and tunnel through to instances.

Commands
--------

You can issues the following commands:

```
simple_deploy environments
simple_deploy list -e ENVIRONMENT
simple_deploy create -n STACK_NAME -e ENVIRONMENT -a ATTRIBUTES -t TEMPLATE_PATH
simple_deploy update -n STACK_NAME -e ENVIRONMENT -a ATTRIBUTES
simple_deploy deploy -n STACK_NAME -e ENVIRONMENT
simple_deploy ssh -n STACK_NAME -e ENVIRONMENT
simple_deploy destroy -n STACK_NAME -e ENVIRONMENT
simple_deploy instances -n STACK_NAME -e ENVIRONMENT
simple_deploy status -n STACK_NAME -e ENVIRONMENT
simple_deploy attributes -n STACK_NAME -e ENVIRONMENT
simple_deploy events -n STACK_NAME -e ENVIRONMENT
simple_deploy resources -n STACK_NAME -e ENVIRONMENT
simple_deploy outputs -n STACK_NAME -e ENVIRONMENT
simple_deploy template -n STACK_NAME -e ENVIRONMENT

Attribute pairs are = seperated key value pairs.  Multiple can be specified.  For example:

simple_deploy create -t ~/my-template.json -e my-env -n test-stack -a arg1=val1 -a arg2=vol2
```

For more information, run simple_deploy -h.

Deploying
---------

By default simple deploy will use your user name and id_rsa key for deployments.  To override either these, set the **SIMPLE_DEPLOY_SSH_USER** & **SIMPLE_DEPLOY_SSH_KEY** respectively.

The deployment gateway is ready from the **ssh_gateway** attribute for that stack.
