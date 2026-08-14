# 08 - Desired State vs Current State

Section 07 covered where Terraform keeps its records. This one is what it does with them.

## The two states

**Desired state** is what your `.tf` files say. A `t3.micro` with a particular AMI and a Name tag. That's the declaration: this is what I want to exist.

**Current state** is what's actually running in the account right now, whatever anyone has done to it since.

Terraform's entire operating principle is that when those two disagree, the config wins. Not the console, not whoever clicked the button, the config.

## Drift

The two only match at the instant an apply finishes. After that they start diverging, because someone stops the instance and bumps it to `t3.small` to get through a busy afternoon and never mentions it. That gap has a name, it's drift, and in any environment with more than about three people touching it, it's constant rather than occasional.

Reproducing it is easy. Apply the config, then go into the console, stop the instance, change the type, start it again. Nothing about Terraform has changed, but the world has.

## What plan actually does

Run `terraform plan` after that and three things happen in order:

1. **Refresh.** Terraform calls the provider API and asks what these resources actually look like right now. This is why `plan` takes a few seconds even when nothing has changed.
2. **Compare.** It diffs three ways: config, state, and reality.
3. **Decide.** It works out the minimum set of API calls that would bring reality back in line with the config.

In the drift case above, the plan says `~ update in place` and proposes taking the instance back down to `t3.micro`. It doesn't ask whether the manual change was intentional or ask you to confirm it was a mistake. Config is the source of truth, so the manual change is treated as damage to be repaired.

Apply it and Terraform stops the instance, resizes it, and starts it again. Roughly a minute of downtime, caused by someone reverting a change you didn't know had been made.

## The four outcomes

Everything Terraform does comes out of one table:

| Desired state | Current state | Action |
| --- | --- | --- |
| Exists | Doesn't exist | **Create** |
| Exists | Exists, but differs | **Update** |
| Doesn't exist | Exists | **Destroy** |
| Exists | Exists, matches | **Nothing** |

The third row is the one that catches people. Delete the resource block from your `.tf` file, save, and run `terraform apply`. Not destroy, apply. Terraform sees a resource in state that no longer appears in the config, concludes you don't want it any more, and tears it down.

Which is worth sitting with for a second, because it means commenting out a block, deleting a file, or a bad merge that drops a resource are all instructions to destroy production. There's no distinction between "I removed this deliberately" and "this went missing." Read the plan output.

## Update in place vs replacement

The video only shows the in-place case, but `plan` has two very different symbols and the difference matters a lot:

- `~ update in place` - the resource is modified where it stands. Instance type is one of these, though it does require a stop and start.
- `-/+ must be replaced` - the resource is destroyed and a new one built. Changing the AMI does this. So does changing the subnet.

Replacement means a new resource ID, a new IP, and anything not backed by durable storage is gone. The plan tells you which one you're getting and names the attribute that forced it, on a line that says `# forces replacement`. That line is the single most important thing in any plan output.

## Accepting drift instead of reverting it

Sometimes the manual change was correct and the config is what's wrong. Reverting it is the wrong move. There's a mode for that:

```bash
terraform plan -refresh-only     # show me the drift, propose no changes
terraform apply -refresh-only    # update state to match reality, touch nothing
```

That writes the current reality into state without altering infrastructure. You still have to go back and fix the config to match, otherwise the next normal apply will revert it again. But it lets you see drift as a report rather than as a pending destruction.

There's also `-refresh=false`, which skips the API calls entirely and plans against state alone. Faster on large configurations, and occasionally what you want when an API is being slow, but you're planning against possibly-stale information.

## The practical takeaway

Manual console changes in a Terraform-managed environment aren't just untidy, they're temporary. Someone will run an apply eventually and the change will vanish, probably at a worse time than when it was made. Either it goes into the config or it doesn't survive.

The real fix is not relying on people remembering. Read-only console access for anything Terraform manages, drift detection on a schedule, and changes going through the repo. That's a bigger conversation than this course, but it's the reason the concept matters.

## Files

- `main.tf` - the instance used for the drift demo.
