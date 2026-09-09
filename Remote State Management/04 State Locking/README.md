# 04 - State Locking

Section 5: Remote State Management

## Documentation referenced

- https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep.html

## The problem

If multiple team members run `terraform apply` simultaneously on the same project,
Terraform ends up making concurrent changes to the state file. When that happens the
chance of state file corruption is high, and it leads to inconsistencies.

The example used: Alice and Bob both run `terraform apply` on the same project at the same
time. Terraform tries to modify `terraform.tfstate` for both sets of changes at once.

What you actually want is for only one process to be changing the state file at any given
moment. The instructor's analogy was a phone call: if you are talking to someone and a
second person calls, you cannot hold both conversations on different subjects at once. You
might try, but you will mess it up. One at a time, then the next.

With ten or twenty people on a team, you cannot enforce that by asking people nicely. That
is what state locking is for.

## What state locking is

State locking is a mechanism in Terraform that prevents multiple operations from making
concurrent changes to the state file, which could otherwise lead to corruption or an
inconsistent state.

When Alice runs `terraform apply` and Terraform is actively modifying the state file, it
locks that file. If Bob runs `terraform apply` during that window, he gets an error
immediately, because the state file is locked by the Terraform process running as Alice.

## How the process works

1. Before Terraform performs any write operation on the state file, it attempts to acquire
   a lock on that file. Once acquired, the lock blocks any other Terraform process from
   modifying the state file.
2. If the lock is acquired successfully, Terraform proceeds with the write operation,
   whether that is `terraform apply`, `terraform destroy`, or similar.
3. Once the write operation completes, Terraform releases the lock, allowing other
   processes to acquire it.

Laid out across the three parties:

- The user runs `terraform apply`
- Terraform, before touching the state file in the backend, requests a state lock
- Once the lock is acquired, Terraform performs the write operation on the state file
- Once the state file is updated, Terraform releases the lock and the operation finishes

After the lock is released, any other user wanting to run an apply or destroy can go ahead.

## Locking differs by backend

How Terraform locks the state file changes depending on which backend is in use.

With the local backend, Terraform uses a lock file in the working directory:
`terraform.tfstate.lock.info`. Once the write operation to state is complete, that file is
removed automatically.

## The error you get

A user hitting a locked state file gets:

```
Error acquiring the state lock
```

with the detail that the process cannot access the file because another process has locked
a portion of the file.

## Practical demo

### Setup

A single file, `sleep.tf`, using the `time_sleep` resource:

```hcl
resource "time_sleep" "wait_100_seconds" {
  create_duration = "100s"
}
```

The 100 second duration is the whole point. It holds the apply open long enough to
actually see the lock file exist and to run a second command against it.

At the start, the `kplabs-terraform` folder contained the `.terraform` directory,
`sleep.tf`, and `.terraform.lock.hcl`.

### Do not confuse the two lock files

`.terraform.lock.hcl` has nothing to do with state locking. It is the dependency lock file
for provider versions. Opening it shows provider version information only. The state lock
file is `terraform.tfstate.lock.info`, and it only exists while a write is in progress.

### Run 1: watching the lock file appear and disappear

```sh
terraform init
terraform apply -auto-approve
```

Terraform waits the 100 seconds before completing the resource creation. While it was
waiting, a new file appeared in the folder: `terraform.tfstate.lock.info`.

Opening it showed a lock ID and the identity of whoever acquired the lock, in this case the
user `zealv`. With multiple users on a project this is how you see who is holding the lock.

The instructor waited out the timer. At around 70 seconds elapsed the lock file was still
there. Once the apply completed, the lock file was removed automatically.

### Run 2: hitting the error from a second terminal

The state file was deleted and the apply re-run:

```sh
terraform apply -auto-approve
```

The lock file was created again. While the apply was still in its creation stage, a second
terminal tab, standing in for a second user, ran:

```sh
terraform plan
```

That failed immediately with the state lock error described above.

He waited again, roughly 60 seconds in. Once the apply finished and the lock file was
removed, running `terraform plan` from the second tab succeeded with no error.

Worth noting that `terraform plan` was blocked here, not just apply. The lock is on the
state file, and plan needs to read it.

## Choosing a backend

When picking a backend for an organization, verify that it supports state locking. This is
stated per backend in the documentation.

- Consul: the documentation explicitly states that this backend supports state locking
- S3: also supports state locking

State locking matters most in larger organizations. Confirm your backend supports it before
using that backend in production.

## Commands used

```sh
terraform init
terraform apply -auto-approve
terraform plan
```