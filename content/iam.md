---
title: "Iam"
date: 2019-08-14T19:38:47-04:00
draft: false
---

# TLDR

* [Purported Docs](https://docs.aws.amazon.com/iam/index.html)
* [CLI Docs](https://docs.aws.amazon.com/cli/latest/reference/iam/)

# What is IAM?

IAM is Identity and Access Management.  It's used for managing users, groups, and roles, in the service of controlling permissions.

# Create a user

Invocations to the aws cli are of the form `aws <service> <action> --arg1 value1 --arg2 value2 ...`.  In this case:

`aws iam create-user --user-name s3user`

if you are storing credentials via profiles and want to use one of those, you might invoke this instead as

`aws iam create-user --user-name s3user --profile betteraws`.

The output looks like:

```
{
    "User": {
        "Path": "/",
        "UserName": "s3user",
        "UserId": "AIDA...",
        "Arn": "arn:aws:iam::87...:user/s3user",
        "CreateDate": "2019-08-14T23:45:26Z"
    }
}
```

You have a user!  🎉

# Give a user access keys

Running

`aws iam create-access-key --user-name s3user --profile betteraws`

generates output like

```
{
    "AccessKey": {
        "UserName": "s3user",
        "AccessKeyId": "AKIA...",
        "Status": "Active",
        "SecretAccessKey": "6h/...",
        "CreateDate": "2019-08-14T23:52:53Z"
    }
}
```

adding this information to your credentials and config in `~/.aws` will allow you to act as this user when using the CLI.

You might have a **~/.aws/config** like:

```
[profile s3user]
region = us-east-1
output = json
```

and a **~/.aws/credentials** like:

```

[s3user]
aws_access_key_id = AKIA...
aws_secret_access_key = x8D...
```

Note that the names of the two blocks are the same (s3user).  Broadly, `~/.aws/config` is for preferences like default zone.  `~/.aws/credentials` is for access keys.  **NOTE:** Access keys and UserIds are different.  Access keys start with AKIA.

# Check the user works

As last time, call the Secure Token Service:

`aws sts get-caller-identity --profile s3user`

(Output:)

```
{
    "UserId": "AIDA...",
    "Account": "871...",
    "Arn": "arn:aws:iam::871...:user/s3user"
}
```

🙌

You can set which profile will be used when you don't specify one with the AWS_DEFAULT_PROFILE env var.

# User Permissions

New users don't have permission to do anything; you must give them permission with policies.  You can see the lack of policies with:

```
$ aws iam list-user-policies --user-name s3user

{
    "PolicyNames": []
}

```

and demonstrate a lack of permissions with

```
$ aws s3 ls --profile s3user

An error occurred (AccessDenied) when calling the ListBuckets operation: Access Denied
[betteraws](master)$
```

## Create a policy

With a file like this:

```
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::examplebucket/*"]
    }
  ]
}
```

Create a policy you can assign to users with

```
$ aws iam create-policy --policy-name AllS32 --policy-document file://all-s3
{
    "Policy": {
        "PolicyName": "AllS32",
        "PolicyId": "ANPA...",
        "Arn": "arn:aws:iam::871...:policy/AllS32",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2019-08-15T01:11:08Z",
        "UpdateDate": "2019-08-15T01:11:08Z"
    }
}
```

## Attach it to the user

`$ aws iam attach-user-policy --policy-arn arn:aws:iam::871...:policy/AllS32 --user-name s3user`

## Or create + attach directly

`$ aws iam put-user-policy --policy-name AllS3 --user-name s3user --policy-document file://all-s3`

## Check that the policy is there

See a user's policies with:

```
$ aws iam list-user-policies --user-name s3user
{
    "PolicyNames": [
        "AllS3"
    ]
}
```

**But wait!** This user should have two policies on them, because we ran both of the above.  What gives?

I wasted 30 minutes on this so you don't have to.  AWS has two different calls for finding policies for a user: one for the intrinsic policies (like the above,) and one for attached policies:

```
$ aws iam list-attached-user-policies --user-name s3user
{
    "AttachedPolicies": [
        {
            "PolicyName": "AllS32",
            "PolicyArn": "arn:aws:iam::871....:policy/AllS32"
        }
    ]
}
```

# Demonstrate that the policy works

We'll cover more on s3 next, but this command makes a bucket.  (Note the `s3://`)

```
$ aws s3 mb s3://betteraws-test --profile s3user
make_bucket: betteraws-test
```

Now check that the bucket exists.

```
$ aws s3 ls --profile s3user
2019-08-21 20:57:20 betteraws-test
```

💪
