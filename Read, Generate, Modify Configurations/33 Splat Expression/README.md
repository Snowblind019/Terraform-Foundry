# 33 Splat Expression

Getting one attribute back from every copy of a resource instead of one at a time.

Files in this folder:

- `splat.tf`

---

## Setup

Three IAM users through `count`, named with `count.index` so they come out as `iamuser.0`, `iamuser.1` and `iamuser.2`. Index starts at 0, so a count of 3 gives 0, 1 and 2.

The `aws_iam_user` docs list three attributes on the resource: `arn`, `name` and `unique_id`. This lab uses `arn`.

## One at a time

With `count` on a resource, the address becomes a list, so a single copy is picked out by index:

```hcl
output "arns" {
  value = aws_iam_user.lb[0].arn
}
```

`terraform plan` showed 3 to add as expected, and after apply the output held the ARN of the first user only, the one with index 0.

That works, but getting all three means writing the output three times with 0, 1 and 2. At a hundred users it is not workable.

## Splat

```hcl
output "arns" {
  value = aws_iam_user.lb[*].arn
}
```

The `[*]` replaces the index. Instead of one element it walks every element in the list and pulls `arn` from each, returning a list of them.

Applied again and the output came back with the ARNs of all three users. Nothing else in the file changed, only the index.

Same idea scales, a hundred users would return a hundred ARNs from the same one line.