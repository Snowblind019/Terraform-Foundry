# 46 Challenges with count

Resources created with `count` are addressed by their position in the list, so changing the order of the list shifts every address after the change.

Files in this folder:

- `challenge-count.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/meta-arguments/count

---

## How the addresses work

The variable holds three names and the resource pulls from it with `count.index`:

```hcl
name  = var.iam_names[count.index]
count = 3
```

Index starts at 0, so:

- `user-01` is index 0
- `user-02` is index 1
- `user-03` is index 2

`terraform init`, `terraform plan`, then `terraform apply -auto-approve`. Three users created.

Looking at `terraform.tfstate` afterwards, under the `aws_iam_user` type each instance is stored against its index key. Index 0 holds user-01, index 1 holds user-02, and so on. That index is how Terraform tracks which real object belongs to which list entry.

## Adding to the end is fine

Added `user-04` to the end of the list and bumped count to 4.

Plan showed one to add at index 3. Nothing else touched, because none of the existing entries moved. Applied, worked as expected.

## Adding to the front breaks things

Then added `user-0` as the first element and set count to 5.

Every entry after it shifted down one position. Index 0 is now user-0, index 1 is user-01, and so on all the way along. The names moved but the index keys in state did not, so Terraform now thinks the object at index 0 needs to become a different user.

Plan came back with 1 to add and 4 to change. Not 1 to add and nothing else, which is what you actually wanted.

Ran `terraform apply -auto-approve` on it and it failed with multiple errors. Plan said update in place, but you cannot rename IAM users that way, so the apply blew up partway through.

Worth remembering that a plan showing update in place is not a guarantee the apply succeeds. This is also the argument for not running things straight against production.

## Where count fits

`count` works when the resources are close to identical. Four EC2 instances with the same AMI and the same instance type, the only difference being that there are four of them.

Where the instances need to differ from each other, one `t2.micro` and one `t3.micro` and so on, `count` is not the right tool. That is what `for_each` is for, covered in the next video.