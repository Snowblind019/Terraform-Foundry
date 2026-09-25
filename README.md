# Terraform-Foundry
 
![Status](https://img.shields.io/badge/Status-Certified-brightgreen)
![Certification](https://img.shields.io/badge/Certification-Terraform%20Associate%20004%20Passed-7B42BC)
![IaC](https://img.shields.io/badge/IaC-Terraform-844FBA)
![Cloud](https://img.shields.io/badge/Cloud-AWS-FF9900)
![Labs](https://img.shields.io/badge/Labs-95%20Documented-informational)
 
Lab notes and working code from a Terraform certification course, written up one video at a time.
I run each lab first, then document it here, so this repo is the record of what I actually did rather than a
rewrite of the official docs.

Passed the HashiCorp Certified Terraform Associate (004) exam on September 21, 2026. The course is complete
and every lab is documented.

**95 labs across 6 sections.**

## Layout

One folder per video. Each folder holds the configuration used in that lesson plus a README covering it.

```
Section Name/
└── NN Lab Name/
    ├── README.md      notes for that lesson
    └── <name>.tf      the configuration that was applied
```

A few labs carry extra files: a `variables.tf` or `backend.tf` alongside the main config, a JSON policy
document, a sample text file read by a function, or a nested `modules/` tree for the module labs.

## How the notes are written

- Each README is scoped to its own lesson. What was demonstrated, the CLI commands run, the errors hit,
  the test cases and their results, and links to any documentation the video referenced. Nothing from
  later in the course and nothing pulled in from outside it.
- Code files are commented to explain why a block is written the way it is, not just what it does.
  Where a lesson changed a file partway through, the earlier version is usually left in place as a
  commented block so both states can be compared.
- File names match the ones used in the course. That is why capitalization and spacing are inconsistent
  between labs.
- Sections below are listed in course order, which is not the order they sort in on disk.

## Sections

| # | Section | Labs |
|---|---------|------|
| 1 | [Deploying Infrastructure with Terraform](#deploying-infrastructure-with-terraform) | 11 |
| 2 | [Read, Generate, Modify Configurations](#read-generate-modify-configurations) | 56 |
| 3 | [Terraform Provisioners](#terraform-provisioners) | 5 |
| 4 | [Terraform Modules & Workspaces](#terraform-modules--workspaces) | 9 |
| 5 | [Remote State Management](#remote-state-management) | 8 |
| 6 | [Security Primer](#security-primer) | 6 |

### Deploying Infrastructure with Terraform

First apply, how providers are sourced and tiered, what the state file actually holds, and how Terraform reconciles desired state against current state.

<details>
<summary>11 labs</summary>

- [01 Launch First Virtual Machine through Terraform](Deploying%20Infrastructure%20with%20Terraform/01%20Launch%20First%20Virtual%20Machine%20through%20Terraform)
- [02 Resource and Providers](Deploying%20Infrastructure%20with%20Terraform/02%20Resource%20and%20Providers)
- [03 Provider Tiers](Deploying%20Infrastructure%20with%20Terraform/03%20Provider%20Tiers)
- [04 GitHub Provider](Deploying%20Infrastructure%20with%20Terraform/04%20GitHub%20Provider)
- [05 Terraform Destroy](Deploying%20Infrastructure%20with%20Terraform/05%20Terraform%20Destroy)
- [06 AWS Authentication Configuration](Deploying%20Infrastructure%20with%20Terraform/06%20AWS%20Authentication%20Configuration)
- [07 Overview of Terraform State File](Deploying%20Infrastructure%20with%20Terraform/07%20Overview%20of%20Terraform%20State%20File)
- [08 Desired State vs Current State](Deploying%20Infrastructure%20with%20Terraform/08%20Desired%20State%20vs%20Current%20State)
- [09 More Clarity - Desired State vs Current State](Deploying%20Infrastructure%20with%20Terraform/09%20More%20Clarity%20-%20Desired%20State%20vs%20Current%20State)
- [10 Terraform Refresh](Deploying%20Infrastructure%20with%20Terraform/10%20Terraform%20Refresh)
- [11 Terraform Provider Versioning](Deploying%20Infrastructure%20with%20Terraform/11%20Terraform%20Provider%20Versioning)

</details>

### Read, Generate, Modify Configurations

The bulk of the language: variables, data types, functions, data sources, meta-arguments, expressions, lifecycle rules, dependencies, and the validation blocks.

<details>
<summary>56 labs</summary>

- [01 Creating Firewall Rules using Terraform](Read%2C%20Generate%2C%20Modify%20Configurations/01%20Creating%20Firewall%20Rules%20using%20Terraform)
- [02 Dealing with Documentation Code](Read%2C%20Generate%2C%20Modify%20Configurations/02%20Dealing%20with%20Documentation%20Code)
- [03 Creating Elastic IP with Terraform](Read%2C%20Generate%2C%20Modify%20Configurations/03%20Creating%20Elastic%20IP%20with%20Terraform)
- [04 Basic of Attributes](Read%2C%20Generate%2C%20Modify%20Configurations/04%20Basic%20of%20Attributes)
- [05 Cross Reference Resource Attributes Practical](Read%2C%20Generate%2C%20Modify%20Configurations/05%20Cross%20Reference%20Resource%20Attributes%20Practical)
- [06 Output Values](Read%2C%20Generate%2C%20Modify%20Configurations/06%20Output%20Values)
- [07 Terraform Variables Practical](Read%2C%20Generate%2C%20Modify%20Configurations/07%20Terraform%20Variables%20Practical)
- [08 Variable Definitions File (TFVARS)](Read%2C%20Generate%2C%20Modify%20Configurations/08%20Variable%20Definitions%20File%20%28TFVARS%29)
- [09 Approaches for Variable Assignment](Read%2C%20Generate%2C%20Modify%20Configurations/09%20Approaches%20for%20Variable%20Assignment)
- [10 Setting Environment variable in Linux](Read%2C%20Generate%2C%20Modify%20Configurations/10%20Setting%20Environment%20variable%20in%20Linux)
- [11 Variable Definition Precedence](Read%2C%20Generate%2C%20Modify%20Configurations/11%20Variable%20Definition%20Precedence)
- [12 Data Type](Read%2C%20Generate%2C%20Modify%20Configurations/12%20Data%20Type)
- [13 Data Type - LIST](Read%2C%20Generate%2C%20Modify%20Configurations/13%20Data%20Type%20-%20LIST)
- [14 Data Type - MAP](Read%2C%20Generate%2C%20Modify%20Configurations/14%20Data%20Type%20-%20MAP)
- [15 Fetching Values from Map and List in Variable](Read%2C%20Generate%2C%20Modify%20Configurations/15%20Fetching%20Values%20from%20Map%20and%20List%20in%20Variable)
- [16 The Count Meta-Argument](Read%2C%20Generate%2C%20Modify%20Configurations/16%20The%20Count%20Meta-Argument)
- [17 Count Index](Read%2C%20Generate%2C%20Modify%20Configurations/17%20Count%20Index)
- [18 Conditional Expressions](Read%2C%20Generate%2C%20Modify%20Configurations/18%20Conditional%20Expressions)
- [19 Local Values](Read%2C%20Generate%2C%20Modify%20Configurations/19%20Local%20Values)
- [20 Terraform Functions](Read%2C%20Generate%2C%20Modify%20Configurations/20%20Terraform%20Functions)
- [21 Challenge - Analyzing Terraform Code Containing Functions](Read%2C%20Generate%2C%20Modify%20Configurations/21%20Challenge%20-%20Analyzing%20Terraform%20Code%20Containing%20Functions)
- [22 Solution - Analyzing Terraform Code Containing Functions](Read%2C%20Generate%2C%20Modify%20Configurations/22%20Solution%20-%20Analyzing%20Terraform%20Code%20Containing%20Functions)
- [23 Overview of Data Sources](Read%2C%20Generate%2C%20Modify%20Configurations/23%20Overview%20of%20Data%20Sources)
- [24 Data Sources - Format](Read%2C%20Generate%2C%20Modify%20Configurations/24%20Data%20Sources%20-%20Format)
- [25 UseCase - Fetching OS Image using Data Sources](Read%2C%20Generate%2C%20Modify%20Configurations/25%20UseCase%20-%20Fetching%20OS%20Image%20using%20Data%20Sources)
- [26 Fetching OS Image using Data Sources - Practical](Read%2C%20Generate%2C%20Modify%20Configurations/26%20Fetching%20OS%20Image%20using%20Data%20Sources%20-%20Practical)
- [27 Debugging In Terraform](Read%2C%20Generate%2C%20Modify%20Configurations/27%20Debugging%20In%20Terraform)
- [28 Terraform Format](Read%2C%20Generate%2C%20Modify%20Configurations/28%20Terraform%20Format)
- [29 Terraform Validate](Read%2C%20Generate%2C%20Modify%20Configurations/29%20Terraform%20Validate)
- [30 Load Order and Semantics](Read%2C%20Generate%2C%20Modify%20Configurations/30%20Load%20Order%20and%20Semantics)
- [31 Dynamic Blocks](Read%2C%20Generate%2C%20Modify%20Configurations/31%20Dynamic%20Blocks)
- [32 Tainting Resources](Read%2C%20Generate%2C%20Modify%20Configurations/32%20Tainting%20Resources)
- [33 Splat Expression](Read%2C%20Generate%2C%20Modify%20Configurations/33%20Splat%20Expression)
- [34 Terraform Graph](Read%2C%20Generate%2C%20Modify%20Configurations/34%20Terraform%20Graph)
- [35 Saving Terraform Plan to File](Read%2C%20Generate%2C%20Modify%20Configurations/35%20Saving%20Terraform%20Plan%20to%20File)
- [36 Terraform Settings](Read%2C%20Generate%2C%20Modify%20Configurations/36%20Terraform%20Settings)
- [37 Resource Targeting](Read%2C%20Generate%2C%20Modify%20Configurations/37%20Resource%20Targeting)
- [38 Dealing with Large Infrastructure](Read%2C%20Generate%2C%20Modify%20Configurations/38%20Dealing%20with%20Large%20Infrastructure)
- [39 Fetching Data for Maps and List in Variable](Read%2C%20Generate%2C%20Modify%20Configurations/39%20Fetching%20Data%20for%20Maps%20and%20List%20in%20Variable)
- [40 Zipmap Function](Read%2C%20Generate%2C%20Modify%20Configurations/40%20Zipmap%20Function)
- [41 Comments in Terraform](Read%2C%20Generate%2C%20Modify%20Configurations/41%20Comments%20in%20Terraform)
- [42 Resource Behavior and Meta Arguments](Read%2C%20Generate%2C%20Modify%20Configurations/42%20Resource%20Behavior%20and%20Meta%20Arguments)
- [43 LifeCycle Meta-Argument - Create Before Destroy](Read%2C%20Generate%2C%20Modify%20Configurations/43%20LifeCycle%20Meta-Argument%20-%20Create%20Before%20Destroy)
- [44 LifeCycle Meta-Argument - Prevent Destroy](Read%2C%20Generate%2C%20Modify%20Configurations/44%20LifeCycle%20Meta-Argument%20-%20Prevent%20Destroy)
- [45 LifeCycle Meta-Argument - Ignore Change](Read%2C%20Generate%2C%20Modify%20Configurations/45%20LifeCycle%20Meta-Argument%20-%20Ignore%20Change)
- [46 Challenges with Count](Read%2C%20Generate%2C%20Modify%20Configurations/46%20Challenges%20with%20Count)
- [47 Resource Dependency](Read%2C%20Generate%2C%20Modify%20Configurations/47%20Resource%20Dependency)
- [48 Implicit vs Explicit Dependencies](Read%2C%20Generate%2C%20Modify%20Configurations/48%20Implicit%20vs%20Explicit%20Dependencies)
- [49 Data Type - SET](Read%2C%20Generate%2C%20Modify%20Configurations/49%20Data%20Type%20-%20SET)
- [50 for each in Terraform](Read%2C%20Generate%2C%20Modify%20Configurations/50%20for%20each%20in%20Terraform)
- [51 Data Type - Object](Read%2C%20Generate%2C%20Modify%20Configurations/51%20Data%20Type%20-%20Object)
- [52 Overview of Input Variable Validation](Read%2C%20Generate%2C%20Modify%20Configurations/52%20Overview%20of%20Input%20Variable%20Validation)
- [53 Practical - Input Variable Validation](Read%2C%20Generate%2C%20Modify%20Configurations/53%20Practical%20-%20Input%20Variable%20Validation)
- [54 Overview of Preconditions and Postconditions](Read%2C%20Generate%2C%20Modify%20Configurations/54%20Overview%20of%20Preconditions%20and%20Postconditions)
- [55 Check Blocks](Read%2C%20Generate%2C%20Modify%20Configurations/55%20Check%20Blocks)
- [56 Moved Blocks](Read%2C%20Generate%2C%20Modify%20Configurations/56%20Moved%20Blocks)

</details>

### Terraform Provisioners

Running commands locally and on the remote host, when provisioners fire, and what happens when they fail.

<details>
<summary>5 labs</summary>

- [01 Local-exec Provisioner](Terraform%20Provisioners/01%20Local-exec%20Provisioner)
- [02 remote-exec Provisioner](Terraform%20Provisioners/02%20remote-exec%20Provisioner)
- [03 Points to Note Provisioners](Terraform%20Provisioners/03%20Points%20to%20Note%20Provisioners)
- [04 Creation-Time and Destroy-Time Provisioners](Terraform%20Provisioners/04%20Creation-Time%20and%20Destroy-Time%20Provisioners)
- [05 Failure Behavior for Provisioners](Terraform%20Provisioners/05%20Failure%20Behavior%20for%20Provisioners)

</details>

### Terraform Modules & Workspaces

Registry modules, building custom modules, calling them by local path, passing variables in and reading outputs back, provider configuration inside modules, and workspaces.

<details>
<summary>9 labs</summary>

- [01 Creating EC2 instance using Modules](Terraform%20Modules%20%26%20Workspaces/01%20Creating%20EC2%20instance%20using%20Modules)
- [02 Creating Custom Module for EC2](Terraform%20Modules%20%26%20Workspaces/02%20Creating%20Custom%20Module%20for%20EC2)
- [03 Module Sources Calling a Module](Terraform%20Modules%20%26%20Workspaces/03%20Module%20Sources%20Calling%20a%20Module)
- [04 Using Local Paths to Call Custom Module](Terraform%20Modules%20%26%20Workspaces/04%20Using%20Local%20Paths%20to%20Call%20Custom%20Module)
- [05 Converting Hardcoded Values to Variables in Custom Module](Terraform%20Modules%20%26%20Workspaces/05%20Converting%20Hardcoded%20Values%20to%20Variables%20in%20Custom%20Module)
- [06 Improvements in Provider Configuration in Custom Module](Terraform%20Modules%20%26%20Workspaces/06%20Improvements%20in%20Provider%20Configuration%20in%20Custom%20Module)
- [07 Module Outputs](Terraform%20Modules%20%26%20Workspaces/07%20Module%20Outputs)
- [08 Multiple Provider Configuration in Modules](Terraform%20Modules%20%26%20Workspaces/08%20Multiple%20Provider%20Configuration%20in%20Modules)
- [09 Implementing Terraform Workspace](Terraform%20Modules%20%26%20Workspaces/09%20Implementing%20Terraform%20Workspace)

</details>

### Remote State Management

Why local state breaks down on a team, backends and state locking, the S3 backend, the state subcommands, the remote state data source, and importing existing infrastructure.

<details>
<summary>8 labs</summary>

- [01 Git for Team Collaboration](Remote%20State%20Management/01%20Git%20for%20Team%20Collaboration)
- [02 Security Risks of Storing Terraform State File in Git](Remote%20State%20Management/02%20Security%20Risks%20of%20Storing%20Terraform%20State%20File%20in%20Git)
- [03 Terraform Backends](Remote%20State%20Management/03%20Terraform%20Backends)
- [04 State Locking](Remote%20State%20Management/04%20State%20Locking)
- [05 S3 Backend](Remote%20State%20Management/05%20S3%20Backend)
- [06 Terraform State Management](Remote%20State%20Management/06%20Terraform%20State%20Management)
- [07 Remote State Data Source Practical](Remote%20State%20Management/07%20Remote%20State%20Data%20Source%20Practical)
- [08 Terraform Import Practical](Remote%20State%20Management/08%20Terraform%20Import%20Practical)

</details>

### Security Primer

Multiple provider configurations, the sensitive parameter, secrets ending up in state, Vault integration, the dependency lock file, and ephemeral values with write-only arguments.

<details>
<summary>6 labs</summary>

- [01 Multiple Provider Configuration](Security%20Primer/01%20Multiple%20Provider%20Configuration)
- [02 Sensitive Parameter](Security%20Primer/02%20Sensitive%20Parameter)
- [03 Security Challenges in Commiting TFState to GIT](Security%20Primer/03%20Security%20Challenges%20in%20Commiting%20TFState%20to%20GIT)
- [04 Terraform and Vault Integration](Security%20Primer/04%20Terraform%20and%20Vault%20Integration)
- [05 Dependency Lock File](Security%20Primer/05%20Dependency%20Lock%20File)
- [06 Ephemeral Values and Write-Only Arguments](Security%20Primer/06%20Ephemeral%20Values%20and%20Write-Only%20Arguments)

</details>

## Running any of this

Most labs use the AWS provider and create real, billable resources. Anything applied should be torn down
afterwards:

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

Credentials are never in the configuration. They come from the environment or an AWS CLI profile, which is
what the AWS authentication lab in section 1 covers. A handful of labs use other providers instead:
GitHub, local, random, and Vault.

## Deliberately bad examples

Some files exist to show a problem rather than a pattern. The state in Git labs and parts of the security
section commit a password file next to the configuration on purpose, because that is the risk the lesson
is about. Those are lab values, not real secrets, and the fix is documented in the same README.

## Connect With Me

- **LinkedIn:** [emilp-profile](https://www.linkedin.com/in/emilp-profile/)