# 22 Solution - Analyzing Terraform Code Containing Functions

Solution to the challenge in video 21. Each of the five functions in the challenge code, worked out from the docs and tested in `terraform console` before anything was applied.

Files in this folder:

- `test.tf`, the scratch file used to collect each function and its output

The method: read the documentation first, do not guess from the name. The docs give the arguments the function expects and what it returns, and the examples are usually enough on their own. Then run the function in `terraform console` with the real values from the code. Both of those work without applying anything.

---

## lookup

Docs: https://developer.hashicorp.com/terraform/language/functions/lookup

Retrieves the value of a single element from a map, given its key.

```
lookup(map, key, default)
```

From the docs example, a map with keys a and b. Asking for key a returns ay, key b returns bee. Asking for key c, which is not in the map, returns the default value instead.

In the challenge code:

```hcl
ami = lookup(var.ami, var.region)
```

The map is `var.ami`, which holds three region to AMI pairs. The key is `var.region`, which is us-east-1. Tested with the real values:

```
lookup({"us-east-1" = "ami-08a0d1e16fc3f61ea","us-west-2" = "ami-0b20a6f09484773af","ap-south-1" = "ami-0e1d06225679bc1c5"},"us-east-1")
```

Output is ami-08a0d1e16fc3f61ea.

First attempt at this errored with a message about a comma being required to separate one function argument from the next, because the comma between the map and the key was missing. The docs syntax is what catches that.

A map could be written inline in the function call, but pulling it from a variable is the readable way to do it.

## length

Docs: https://developer.hashicorp.com/terraform/language/functions/length

Determines the length of a list, map or string.

From the docs examples, an empty list gives 0, a two item list gives 2, a map with one key gives 1, and the string hello gives 5.

In the challenge code:

```hcl
count = length(var.tags)
```

`var.tags` is a list with firstec2 and secondec2.

```
length(["firstec2","secondec2"])
```

Output is 2, so `count = 2` and two instances get created.

## element

Docs: https://developer.hashicorp.com/terraform/language/functions/element

Retrieves a single element from a list, given its index. The index starts at 0, so in a list of a, b, c the index 1 returns b.

In the challenge code:

```hcl
Name = element(var.tags, count.index)
```

```
element(["firstec2","secondec2"],1)
```

Output is secondec2. Index 0 gives firstec2.

The index here is `count.index`, which ties back to the `count = 2` above. The first copy has index 0 and gets the name firstec2, the second copy has index 1 and gets secondec2.

## timestamp

Docs: https://developer.hashicorp.com/terraform/language/functions/timestamp

Returns a UTC timestamp string in RFC 3339 format. Running it in the console returns the current time, something like 2024-06-17T17:51:34Z. Readable enough for a machine, not for a person, which is what the next function is for. The docs page points at formatdate under related functions for exactly this reason.

## formatdate

Docs: https://developer.hashicorp.com/terraform/language/functions/formatdate

Takes a format spec and a timestamp and converts the timestamp into the layout given by the spec.

In the challenge code:

```hcl
CreationDate = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
```

`timestamp()` runs first, then its output is passed to `formatdate`. Tested by pasting the actual string timestamp returned:

```
formatdate("DD MMM YYYY hh:mm ZZZ", "2024-06-17T17:51:34Z")
```

Output is 17 Jun 2024 17:51 UTC. There are other specs available, DDMMYY and so on, it is down to preference.

## What the code resolves to

Every function replaced by what it computed:

```hcl
resource "aws_instance" "app-dev" {
   ami           = "ami-08a0d1e16fc3f61ea"
   instance_type = "t2.micro"
   count         = 2

   tags = {
     Name         = element(var.tags, count.index)
     CreationDate = "17 Jun 2024 17:51 UTC"
   }
}
```

Two t2.micro instances in us-east-1, named firstec2 and secondec2, both tagged with the creation date.

## Verifying it

`test.tf` was renamed to `test.tf.bak` first so Terraform would not read it during the apply. Terraform only loads `.tf` files, so changing the extension is enough to take a file out of play.

Then `terraform validate`, which passed, and `terraform apply -auto-approve`. Two instances came up in about 36 seconds. The console showed firstec2 and secondec2, each with a CreationDate tag in the expected format, and the AMI ending 1ea, matching what had been worked out beforehand.

`terraform destroy` at the end to avoid charges.

## Exam note

There are far more functions in Terraform than any course could cover. The exam does not expect knowledge of each one individually. What matters is the workflow: when reading unfamiliar code, go to the documentation for the function, then test it in `terraform console` with the real values, before running anything.