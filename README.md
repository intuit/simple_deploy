I use the stackster to manage stacks, however I understand how to connect to different regions / accounts as well as kick off a deployment on instances.

Getting Started
---------------

Install the gem

```
gem install simple_deploy
```

Create a file **~/.simple_deploy.yml** and include within it:

```
environments:
  preprod_shared_us_west_1:
    access_key: XXX
    secret_key: yyy
    region: us-west-1

notifications:
  campfire:
    token: XXX
```

Notifications
-------------

Currently Simple Deploy only supports Campfire for notifications.  To enable them, add your token, which can be obtained on the 'My Info' screen of Campfire in the notifications yaml above.  If you don't want notificaitons, omit this section.

Advaned Configurations
----------------------

The configuration file supports additional optional deployment parameters. 

Deploy can have a ssh **user** and **key** set.  These will be used to connect to both the gateway and tunnel through to instances.

Commands
--------

For a list of commands, run simple_deploy -h.  To get more information about each subcommand, append a -h after the subcomand.  For example: **simple_deploy deploy -h**.

Deploying
---------

By default simple deploy will use your user name and id_rsa key for deployments.  To override either these, set the **SIMPLE_DEPLOY_SSH_USER** & **SIMPLE_DEPLOY_SSH_KEY** respectively.

The deployment gateway is ready from the **ssh_gateway** attribute for that stack.
