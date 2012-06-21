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
  keys: PATH_TO_PRIVATE_KEY
  user: ec2-user
  artifacts: 
    - name: cookbooks
      bucket_prefix: artifacts
      endpoint: http
      variable: COOKBOOKS_URL
  script: /opt/admin/bin/deploy.sh

environments:
  preprod_us_west_1:
    access_key: XXX
    secret_key: XXX
    region: us-west-1
  prod_us_west_1:
    access_key: YYY
    secret_key: YYY
    region: us-west-1
  preprod_us_east_1:
    access_key: XXX
    secret_key: XXX
    region: us-east-1
  prod_us_east_1:
    access_key: YYY
    secret_key: YYY
    region: us-east-1
```

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
