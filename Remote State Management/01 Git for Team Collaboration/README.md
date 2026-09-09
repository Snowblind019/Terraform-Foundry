# 01 - Terraform and Team Collaboration

Section 5: Remote State Management

## What this video covers

This is a concept and demo video, not a build lab. It sets up the rest of the section
by explaining why keeping Terraform files only on your own machine is a problem, and
why the code belongs in a Git repository instead.

Up to this point in the course, every lab has followed the same shape: create `main.tf`,
`variables.tf`, `terraform.tfvars` in a folder on the local laptop, run `terraform apply`
from there, and let the state file land next to the config. That is fine for learning.
It is not what a real organization does, because in a real organization there is no single
person who owns the whole Terraform footprint. There is a team, and everyone needs to be
able to read and change the same code.

## Problems with the local only approach

Three disadvantages were called out:

1. **Loss of everything if the machine dies.** If the laptop or the hard disk inside it
   fails, you lose both the Terraform code you wrote and the Terraform state file. The
   state file is the one that really hurts.
2. **Team collaboration is not possible.** If the files sit on your laptop, other team
   members cannot access or update the infrastructure code. In a real environment there
   are thousands of lines of code and other people will want to improve parts of it. They
   cannot do that if the code only exists in one place they cannot reach.
3. **No visible versioning.** If you edit a file by mistake and only notice two or three
   days later that things are not working, there is no record of what changed. You cannot
   go back and see the previous state of the file.

## The Git based approach

The fix used in most organizations is to put the whole Terraform code base in a Git
repository. The repo holds `main.tf`, `variables.tf`, `terraform.tfvars` and the rest,
and every DevOps team member who creates and manages infrastructure through Terraform
gets full access to that repository.

Benefits listed in the video:

- Centralized access for all team members
- Full version history and change tracking, including which team member made which change
- Code review and approval workflows
- Integration with CI/CD for validation and plans

## Demo walkthrough

### The local setup

The instructor had a folder at `/tmp/terraform` containing the `.tf` files, opened in
Visual Studio Code. The config is deliberately small:

- `main.tf` defines a single `aws_security_group` named `allow_tls`, with `name` coming
  from a variable and a hardcoded `description` of `"Managed from Terraform"`
- `variables.tf` declares `sg_name` with no type and no default
- `terraform.tfvars` sets `sg_name = "kplabs-firewall"`

He then ran:

```sh
terraform apply -auto-approve
```

Once the apply completed, `terraform.tfstate` also existed in that folder. Everything,
code and state, now lives on one computer. That is the exact situation described as the
risk: if that disk fails, all of it is gone, and nobody else on the team can get at it.

### The course repository as an example

He pointed at the course's own Git repository, where all the code from the course is
published, as a working example of the two main benefits. Students can pull the code
directly from the repo, which is the collaboration side. And the commit history shows
the versioning side. He opened one commit, `update firewall.md`, and the diff showed what
was there before, what was removed, and what was added. His point was that this matters
most when something breaks and you have already forgotten what you changed four or five
days ago.

### Committing the files

To show the flow end to end, he used a second, empty repository called `tmp-terraform`.
He uploaded the existing files from the `/tmp/terraform` folder through the GitHub web UI,
using **Choose your files**, and committed them with the message `committed terraform files`.
He noted explicitly that you should normally be doing this through the CLI, and that the
GUI was only used here for simplicity.

After the commit, the files that had existed only on the laptop now also lived in the
repository. Local disk failure no longer destroys the code base.

### Showing change tracking

To demonstrate history, he edited the security group description in the repo, changing it
from `Managed from Terraform` to `Managed from TF`, and committed that change. Opening the
commit history then showed the before and after values side by side, along with the user
who made the change. That is the mechanism you use when a change to your Terraform config
or modules breaks something and you need to work out what changed and who changed it.

## Practice to carry forward

Once you have created or edited Terraform files and the infrastructure has been modified
accordingly, commit the latest changes to the repository. If you do not, other team members
end up working from an older version of your variables or your Terraform files, and the
infrastructure they modify will be built off that older version. That creates problems.

## What should not be committed

This was flagged at the end as an important point, with the full explanation deferred to
later videos in the section.

Not everything in the working directory belongs in Git. Two things specifically:

- **`terraform.tfstate`** should not be committed. The reasons are covered in the
  subsequent videos.
- **The `.terraform` folder** should not be committed.

The reason given for `.terraform` is size. He checked the folder properties and it was
over 800 MB, and that was with only a single AWS provider's plugins downloaded. Projects
with multiple provider plugins get much larger. Large folders should never be pushed to
Git, and there is no need to: any team member who clones the repo can run `terraform init`
and download the appropriate provider plugins themselves.

Note that during the demo he did upload the state file and the `.terraform` folder to the
`tmp-terraform` repository, before making this point. The demo repo is not meant as a
model of what a real repo should contain.

## Commands used

```sh
terraform apply -auto-approve
```

`terraform init` was referenced as the command a team member runs after cloning, to pull
down provider plugins, rather than being demonstrated here.

## Open items

- Why `terraform.tfstate` specifically should not be committed: deferred to the next videos
  in this section.