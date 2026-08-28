# 34 Terraform Graph

Visualising which resources depend on which.

Files in this folder:

- `sample-file.tf`

Docs referenced in the video: https://developer.hashicorp.com/terraform/cli/commands/graph

Online viewer used: https://dreampuf.github.io/GraphvizOnline/

---

## What it does

```sh
terraform graph
```

Prints the dependency relationships in the configuration. The output is not a picture, it is text in the DOT language, which is the format graphviz uses. Something has to render it before it means anything visually.

Needs `terraform init` first. Running graph before init errors out.

## Rendering it online

Paste the output into a graphviz web viewer and it draws the graph. The video tries a couple of sites because any given one may be down.

Fine for course code. Not fine for work code, since it means pasting the shape of the infrastructure into somebody else's website.

## Rendering it locally

Install graphviz, which provides the `dot` binary, then pipe into it:

```sh
terraform graph | dot -Tsvg > graph.svg
```

Fedora:

```sh
sudo dnf install graphviz
```

The video uses `apt install graphviz` on Ubuntu.

`-Tsvg` sets the output format. `-Tpng` works the same way. The video went with SVG because it was working over a server session with no way to view an image, and an SVG opens in a browser.

## What the graph showed for this file

Four resources in `sample-file.tf`, and the graph makes the wiring obvious:

- Everything hangs off the AWS provider.
- `aws_vpc_security_group_ingress_rule.example` points at `aws_security_group.example`, because the rule sets `security_group_id = aws_security_group.example.id`.
- The same rule also points at `aws_eip.lb`, because the CIDR is built from `aws_eip.lb.public_ip`. Whatever public IP the EIP ends up with is what gets allowed on 443.
- `aws_instance.web` sits on its own with no links to the other three. Nothing in its arguments references them.

That last one is the useful part. The instance looks related to the security group if you skim the file, but nothing actually connects them, and the graph shows that immediately.

## Why it matters

At four resources I can read the file. At a few hundred, tracing what references what by hand is slow, and the graph is faster for both planning changes and working out why something is being created or destroyed in an order I did not expect.