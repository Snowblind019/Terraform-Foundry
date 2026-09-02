# 55 Check Blocks

A top level block for validating infrastructure after it exists. Unlike the conditions covered so far, a failed check produces a warning rather than an error, so it does not stop the run.

Files in this folder:

- `check-block.tf`

Docs:

- https://developer.hashicorp.com/terraform/language/checks
- https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http

Note: no transcript for this one, so the notes below come from the code plus the documentation rather than from the video. Worth checking against what the instructor actually said.

---

## The base code

```hcl
data "http" "example" {
  url = "https://google1231233dsd.com"
}

resource "local_file" "foo" {
  content  = "Hi"
  filename = "${path.module}/foo.txt"
}
```

The `http` data source makes a GET request to a URL and returns the response, including a `status_code` attribute. The domain here is deliberately nonsense, so the request fails.

At the top level like this, that failure is an error. The run stops, and `local_file.foo` never gets created even though it has nothing to do with the failing request.

## The check block

```hcl
check "website_checker" {
  data "http" "example" {
    url = "https://google1231233dsd.com"
  }

  assert {
    condition     = data.http.example.status_code == 200
    error_message = "Website is not running. Please check"
  }
}
```

Two things go inside:

**A scoped data source.** Optional, and at most one per check block. It is scoped to the check, so nothing outside the block can reference it. This is where the data being asserted against gets fetched.

**One or more assert blocks.** Same `condition` and `error_message` shape as validation, preconditions and postconditions.

## What is different about it

The important difference is severity. A failed `assert` is a warning, not an error. The run continues and the rest of the configuration still applies.

The same goes for the scoped data source. If it errors, which it will here given the domain does not resolve, Terraform reports a warning rather than failing the run.

So with the check block in place, the bogus URL produces a warning and `local_file.foo` still gets created. That is the behaviour the example is set up to show.

Checks also run last, after everything else in the configuration has been planned or applied, which is what makes them suitable for asserting against infrastructure that already exists.

## Where it fits against the other conditions

- **variable validation** checks a value assigned to an input variable, blocking
- **precondition** checks before the resource is evaluated, blocking
- **postcondition** checks after the resource is evaluated, blocking
- **check** checks the wider state of things, non blocking, reported as a warning

Check blocks came in with Terraform 1.5.

## Providers used

The `http` and `local` providers are both needed here, so `terraform init` has to be run before this will work.

## Commands used

```sh
terraform init

terraform plan

terraform apply -auto-approve
```