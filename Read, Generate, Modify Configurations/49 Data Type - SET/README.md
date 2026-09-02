# 49 Set Data Type

A set holds multiple values like a list does, with two differences: it only keeps unique elements, and it does not track their order.

Files in this folder:

- `set.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/expressions/types

---

## List, as a refresher

A list stores multiple items in one variable. Two things about it matter for the comparison:

- duplicates are allowed
- items are indexed, starting at 0

```hcl
variable "my-list" {
  type    = list
  default = ["hello", "world", "hello"]
}

output "mylist" {
  value = var.my-list
}
```

Three items, and `hello` appears twice, which is fine. Index 0 is `hello`, index 1 is `world`, index 2 is `hello`.

With no default set, `terraform plan` prompts for the value. Typing it in as `["hello","world","hello"]` and getting the bracket wrong the first time just errors out, rerun the plan and enter it properly. Adding the default in the variable block saves being asked every run.

Changing the output to `var.my-list[0]` and applying returns `hello`, which is the item at index 0.

## Set

```hcl
variable "my-set" {
  type    = set(string)
  default = ["alice", "bob", "john"]
}

output "myset" {
  value = var.my-set
}
```

Declaring it as just `type = set` fails on plan with an error saying the set type requires one argument specifying the element type. The element type goes in the brackets, so `set(string)` for strings, and it has to be there.

Feeding the same `["hello","world","hello"]` value into a set returns `hello` and `world` only. The second `hello` is gone. Duplicates do not throw an error, they are silently dropped, and only the unique values end up in the output and in the state file.

## Set is unordered

This is the other distinction from list. A set tracks that an element is present, not where it sits. There is no index like a list has.

With `["alice", "bob", "john"]` applied, state holds all three. Moving `john` from the end to the front and running plan again comes back with no changes, because as far as the set is concerned the same three items are still there.

Doing the same thing on a list behaves differently. Applying `["alice", "bob", "john"]` as a list and then moving `bob` from index 2 to index 0 shows up in plan as a change, because the index each item sits at is part of what the list stores.

So if infrastructure is built off a list and the order of that list changes, the infrastructure changes with it. Off a set, it does not.

## Commands used

```sh
terraform plan

terraform apply -auto-approve
```