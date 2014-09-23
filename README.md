[![Build Status](https://secure.travis-ci.org/intuit/simple_deploy.png)](http://travis-ci.org/intuit/simple_deploy)

!!! Simple Deploy is in maintenance mode. We will continue to provide support for bug
fix requests, however new features will not be added !!!
 
It has been a good run, but it has now come to an end. When Simple Deploy was started,
the [AWS CLI](http://aws.amazon.com/cli/) had minimal Cloud Formation support; that
is no longer the case.  The AWS CLI is mature, well-documented and can be used
to perform the majority of the Cloud Formation actions provided by Simple Deploy
and we believe new customers will be better served leveraging it for their Cloud
Formation stack management.
 
For the features which Simple Deploy provides that are not available via AWS CLI,
we have created the following utilities to provide near-like services, to what is
provided by Simple Deploy, which can be integrated with the AWS CLI.
 
* [cfn-clone](https://github.com/intuit/cfn-clone) allows for cloning Cloud Formation
stacks. It will leverage the AWS CLI to read the parameters and template from an existing
stack. It allows you to override either the template or inputs and create a new stack
with the updated attirbutes and template.
 
* [heirloom-url](https://github.com/intuit/heirloom-url) generates URLs that point to resources
which have been uploaded to Heirloom. This can be coupled with the AWS CLI to update
the app or chef_repo.

For example, to update the app and chef_repo of a stack, and then kick off a command,
similiar to the Simple Deploy deploy subcommand, you could use the following bash script.

```
#!/bin/bash

app_id=$1
chef_id=$2
 
app_url=`heirloom-url -bucket-prefix=bp -domain=my-app -encrypted=true -id=$app_id -region=us-west-2`
chef_url=`heirloom-url -bucket-prefix=bp -domain=my-chef -encrypted=true -id=$chef_id -region=us-west-2`

aws cloudformation update-stack --stack-name my-app-stack \
                                --parameters AppArtifactURL=$app_url,ChefRepoURL=$chef_url
 
ips=`aws ec2 describe-instances --filter Name=Name,Values=my-app-stack \
| jq --raw-output '.Reservations[].Instances[].PublicIpAddress'`
 
for ip in $ips; do
  ssh ip 'chef-solo -c /var/chef/config/solo.rb -o role[app]’
done
```

If you are interested in more efficient SSH parallelization, I would look into one
of the below tools which could be integrated into the above script.

* [Capistrano](http://capistranorb.com/)
* [GNU Parallel](http://www.gnu.org/software/parallel/)

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

Documentation
-------------

For more information, please view the [Simple Deploy Wiki](https://github.com/intuit/simple_deploy/wiki).

Contributing
-------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
