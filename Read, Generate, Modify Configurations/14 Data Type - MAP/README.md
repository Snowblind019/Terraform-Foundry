# 14 Data Type - Map

A map is a collection of key value pairs. Same idea as a list, except every entry is named instead of being just a position in a sequence.

Files in this folder:

- `map-data-type.tf`, the variable with a map default and an output that prints it

---

## What it looks like

Curly braces, one key value pair per line:

```hcl
variable "instance_tags" {
  type = map

  default = {
    Name        = "app-servers"
    Environment = "development"
    Team        = "payments"
  }
}
```

Side by side with the previous video:

| Type | Holds | Written as |
|---|---|---|
| list | a sequence of values | `["a", "b", "c"]` |
| map | named key value pairs | `{ key = "value" }` |

## Where it turns up

Tags. An EC2 instance tag is a key and a value, `Team = dev`, `Location = USA`, so a list cannot express it. A list has no place to put the key.

That is why the `tags` argument on `aws_instance` looks like this in the docs example:

```hcl
tags = {
  Name = "HelloWorld"
}
```

and why the argument reference for `tags` says a map of tags to assign to the resource. Same lesson as the list video: the docs tell you the type, and the syntax follows from the type.

## The demo

Starting file, variable with a map constraint and an output that prints whatever it holds:

```hcl
variable "my-map" {
  type = map
}

output "variable_value" {
  value = var.my-map
}
```

`terraform apply -auto-approve` prompts for the value. Typing a list at the prompt fails straight away, brackets are not braces.

Typing it as a map works:

```
{"team"="payments"}
```

Apply completes and the output shows the pair back. More than one entry works the same way, comma separated:

```
{"team"="payments", "location"="US"}
```

Then added a default so it stops prompting:

```hcl
default = {
  Name = "Alice"
  Team = "Payments"
}
```

Apply runs clean and outputs the default.

One thing that trips people up between those two: inside the config file the pairs are on separate lines and need no commas, but typed on a single line at the prompt they do. Commas separate pairs on one line, newlines do the same job in the file.

## Details worth knowing

Past what the video covers, and all of it fair game on the exam:

- **Keys are always strings.** There is no such thing as a map with number keys. `{ 1 = "a" }` gives you the key `"1"`.
- **Keys that are not valid identifiers need quoting.** `Name = "Alice"` is fine unquoted, `"my-key" = "Alice"` needs the quotes because of the hyphen.
- **Bare `map` means `map(any)`.** The modern spelling is `map(string)`, and that is what `tags` actually is. Being explicit is what makes the constraint worth having, same as with `list`.
- **Values are unified to one type.** A map is not a free for all, every value has to end up the same type. `{ a = 1, b = "hello" }` under `map(any)` converts the number to a string rather than erroring. Under `map(number)` it fails.
- **Map is not object.** A map has any number of keys with one value type. An object has a fixed set of named attributes, each with its own type, for example `object({ name = string, port = number })`. When the values genuinely differ in type, object is the right constraint, not map.
- **Duplicate keys are an error**, not a last one wins.

## Takeaway

Braces for named pairs, brackets for a bare sequence. Tags are the case that comes up constantly. And `map(string)` beats bare `map` for the same reason `list(string)` beats bare `list`, it actually checks something.

---

## Commands run

```bash
terraform apply -auto-approve
```