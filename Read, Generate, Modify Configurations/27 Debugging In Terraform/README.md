# 27 Debugging Terraform

Debugging is the process of finding the root cause of an issue. Video 27 is the overview, video 28 is the practical.

Files in this folder:

- `tf-logs.tf`, a small local_file resource to run plan against while testing log levels

---

## Why logs matter

In sysadmin or DevOps work a large share of time goes into debugging rather than building. Installing something is easy, making it work when it does not is where the time goes. The one requirement common to all of it is a detailed log, and how you get one depends on the tool.

SSH is the reference example. Logging in normally shows a password prompt and nothing else. Adding `-v` produces a block of detail about what the client is doing, 57 lines in the video's example. Adding `-vvvv` produces 170 lines for the same login. Most of the time that detail is not needed, but when a login fails for no visible reason, it is what shows where it broke.

Terraform works the same way, through an environment variable rather than a flag.

## TF_LOG

`TF_LOG` sets the verbosity of Terraform's own logs. The levels, in order of decreasing verbosity:

| Level | Detail |
|---|---|
| TRACE | Most detailed |
| DEBUG | |
| INFO | |
| WARN | |
| ERROR | Least detailed |

The difference is large. A plan at INFO produced 16 lines, showing things like the Terraform version and the Go runtime version. The same plan at TRACE produced 782 lines, enough that scrolling and selecting it took 20 to 30 seconds.

Normal work never needs this. It matters when something is genuinely not behaving as expected and the suspicion is a bug in the Terraform binary itself or in a provider plugin. The trace output is what shows what is happening underneath.

## TF_LOG_PATH

At TRACE the useful plan output is buried under hundreds of lines of log. `TF_LOG_PATH` sends the log to a file instead, so the CLI shows the normal plan output and the detail is on disk to open afterwards.

With both set, `terraform plan` prints its usual output and writes the trace log to the file named. Deleting the file and running plan again recreates it.

## Setting them

Windows uses `set`:

```sh
set TF_LOG=INFO
set TF_LOG=TRACE

set TF_LOG_PATH=terraform.txt
```

Linux and macOS use `export`:

```sh
export TF_LOG=INFO
export TF_LOG=TRACE

export TF_LOG_PATH=terraform.txt
```

Same variables, different command. Setting `TF_LOG` alone puts the logs in the terminal. Adding `TF_LOG_PATH` moves them to a file.

A full path works too:

```sh
export TF_LOG_PATH=/tmp/crash.log
export TF_LOG=TRACE
```

## Both are session scoped

`set` and `export` last for the terminal session only. Opening a new terminal and running plan there produces no log file, because that session never had the variable. Going back to the original terminal and running plan again does create it.

That is the right behaviour for this. Detailed logs are wanted for one specific investigation, not for every command, so setting the variable, doing the run, and closing the terminal is the normal workflow.

Setting it permanently is possible, on Windows through Advanced system settings and the environment variables dialog. Terminals already open do not pick it up, only new ones. Not the recommended approach though, since it means every plan from then on carries the extra verbosity.