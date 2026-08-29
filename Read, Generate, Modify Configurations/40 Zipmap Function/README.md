# 40 zipmap Function

`zipmap` builds a map out of two separate lists, one of keys and one of values, by pairing them up position by position.

Files in this folder:

- `zipmap.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/functions/zipmap

---

## Syntax

```
zipmap(keylist, valuelist)
```

First argument is the list of keys, second is the list of values. First key pairs with the first value, second with the second, and so on.

## Trying it in the console

```sh
terraform console
```

```hcl
zipmap(["pineapple","oranges","strawberry"], ["yellow","orange","red"])
```

Comes back as:

```hcl
{
  "oranges"    = "orange"
  "pineapple"  = "yellow"
  "strawberry" = "red"
}
```

Two flat lists in, one map out, each fruit sitting next to its color.

## Where it is actually useful

The use case in the video is IAM users. Three of them, created with `count`:

```hcl
resource "aws_iam_user" "lb" {
  name  = "demo-user.${count.index}"
  count = 3
  path  = "/system/"
}
```

With outputs for the names and the ARNs separately, using the splat expression to pull the attribute off all three instances at once:

```hcl
output "arns" {
  value = aws_iam_user.lb[*].arn
}
```

`terraform apply -auto-approve` creates the three users and prints two outputs, one list of ARNs and one list of names. They are correct, but they are two separate lists and you have to line them up yourself by position. On a project that is also creating SQS queues and everything else, that gets confusing fast.

## Combining them

Feed both lists into `zipmap` and you get one output where each name sits against its own ARN:

```hcl
output "combined" {
  value = zipmap(aws_iam_user.lb[*].name, aws_iam_user.lb[*].arn)
}
```

Apply again and the `combined` output shows `demo-user.0` with its ARN, `demo-user.1` with its ARN, `demo-user.2` with its ARN. Same information as the two separate outputs, just readable without cross-referencing.