---
title: "Getting Started"
date: 2019-07-22T13:37:04-04:00
draft: false
---

# Making an account

[Go make an AWS account](https://console.aws.amazon.com/console/home?region=us-east-1).  This will set you up with an AWS account and a root account user.  The credentials for this user should be super secure, and very rarely used.  [Most of the things you need the root user account to do involve billing/payment, and are done at most infrequently.](https://docs.aws.amazon.com/general/latest/gr/aws_tasks-that-require-root.html)

# Making a user for administration

[Make an IAM user](https://console.aws.amazon.com/iam/home#/home), assign it to the Admin group.  This user will be your primary tool to manage permissions etc for other, more specialized users.


# Making access keys

You _can_ do everything you want to interact with AWS in the browser/console, but I personally don't like it and will prefer the CLI when I can.  Make access keys for your admin user at https://console.aws.amazon.com/iam/home#/users/<your_admin_user>?section=security_credentials .  Note what the secret key is, because when you navigate away from this page you will never be able to find it again.

# Install the AWS CLI

[Follow these instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html).

# Configure the CLI

[Follow these instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).  Use a profile if you don't want these to be the default credentials used when you don't specify any.  Basically, it should look like this, but with your keys:

```
$ aws configure --profile user2
AWS Access Key ID [None]: AKIAI44QH8DHBEXAMPLE
AWS Secret Access Key [None]: je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
Default region name [None]: us-east-1
Default output format [None]: json
```

# Confirm things work

You can use the [Amazon Security Token Service (AWS STS)](https://docs.aws.amazon.com/STS/latest/APIReference/Welcome.html)  To verify that you can connect appropriately like so:

```
aws sts get-caller-identity
```

or optionally

```
aws sts get-caller-identity --profile my_profile
```

You should get a result like this (if everything works and you are using the JSON output format):

```
{
    "UserId": "AIDA4VUH5NFXZ2LXUTFXP",
    "Account": "871089662319",
    "Arn": "arn:aws:iam::8675309:user/your_username"
}
```
