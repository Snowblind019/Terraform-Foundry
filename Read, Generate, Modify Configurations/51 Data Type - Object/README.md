# 51 Object Data Type

Object is a collection of key value pairs like map is, with two differences: each attribute can be its own type, and the structure has to be declared up front.

Files in this folder:

- `object.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/expressions/types

---

## Map, as a refresher

A map is a collection of key value pairs. Tagging in AWS is where it gets used most.

Two things about it matter here:

- keys are strings, and all values have to be the same type
- no strict structure is required

```hcl
variable "my-map" {
  type = map
}

output "variable_value" {
  value = var.my-map
}
```

With no value set, `terraform plan` prompts for one. Feeding it `{"Name"="Zeal", "Age"="32"}` works. Feeding it `{"Name"="Zeal", "Age"="32","Location"="India"}` also works, because nothing in the variable declares how many pairs there should be or what they should be called. Any number of key value pairs is fine.

## Restricting the value type

```hcl
variable "my-map" {
  type = map(number)
}
```

Plain `map` takes strings by default. `map(number)` says every value in the map has to be a number.

Passing `{"Name"="Zeal", "Age"="32","Location"="India"}` now errors with a message saying a number is required, pointing at the offending value. Passing `{"Name"="12", "Age"="32","Location"="45"}` is accepted.

The restriction is on the value side only. The keys are still `Name`, `Age` and `Location`, all strings, and that is fine.

## Object

Object is also key value pairs, but each value can be a different type. Name can be a string while userID is a number, in the same variable.

That flexibility comes with a requirement: the structure has to be spelled out, so Terraform knows what type to expect for each attribute.

```hcl
variable "my-object" {
  type = object({Name = string, userID = number})
}

output "variable_value" {
  value = var.my-object
}
```

Two errors show up getting there:

- writing just `type = object` with no structure fails on plan with an invalid type specification error, saying the object type requires one argument specifying the attribute types as a map
- writing the attribute names in double quotes fails with an error saying object constructor map keys must be attribute names. Dropping the quotes fixes it

With the structure in place, `terraform plan` prompts for a value. `{"Name"="Zeal", "userID"=1234}` is accepted. `{"Name"="Zeal", "userID"="hello"}` errors with a number required, because userID was declared as a number.

## Syntax points

- an object is a collection of named attributes, each with its own type
- the schema is `<KEY>=<TYPE>, <KEY>=<TYPE>` inside curly braces, comma separated
- extra attributes get discarded during type conversion

That last one is worth trying. With the object declared as `Name` and `userID` only, passing `{"Name"="Zeal", "userID"=123, "email"="instructors@kplabs.in"}` does not error. The plan runs, and the email pair is simply trimmed out of the output. It is not kept and it is not complained about.

## Commands used

```sh
terraform plan
```