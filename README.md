I use the stackster to manage stacks, however I understand how to connect to different regions / accounts as well as kick off a deployment on instances.

Getting Started
---------------

Install the gem

```
gem install simple_deploy
```

Create a file **~/.simple_deploy.yml** and include within it:

```
deploy:
  gateway: ADMIN_IP_TO_YOUR_VPC
  user: SSH_USER_TO_GATEWAY_AND_INSTANCES
  key: PRIVATE_SSH_KEYFILE_FOR_USER
  artifacts: 
    - name: live_community_chef_repo
      bucket_prefix: intu-lc
      variable: CHEF_REPO_URL
      cloud_formation_url: ChefRepoURL
    - name: live_community
      bucket_prefix: intu-lc
      variable: APP_URL
      cloud_formation_url: AppArtifactURL
    - name: cookbooks
      bucket_prefix: intu-artifacts
      variable: COOKBOOKS_URL
      cloud_formation_url: CookbooksURL
  script: /opt/intu/admin/bin/configure.sh

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
simple_deploy destroy -n STACK_NAME -e ENVIRONMENT
simple_deploy instances -n STACK_NAME -e ENVIRONMENT
simple_deploy status -n STACK_NAME -e ENVIRONMENT
simple_deploy attributes -n STACK_NAME -e ENVIRONMENT
simple_deploy events -n STACK_NAME -e ENVIRONMENT
simple_deploy resources -n STACK_NAME -e ENVIRONMENT
simple_deploy outputs -n STACK_NAME -e ENVIRONMENT
simple_deploy template -n STACK_NAME -e ENVIRONMENT
```

For more information, run simple_deploy -h.
