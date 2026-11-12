# VMware vSphere Infrastructure Provisioning with Terraform

Terraform infrastructure-as-code laboratory for **VM provisioning on VMware vSphere/ESXi**, designed around development, staging and production-style node groupings.

> **Status:** The configuration describes virtual machines and supporting networks, but does not itself install or configure Kubernetes, load-balancing software, Jenkins or NFS services. Deployment has not been revalidated in a live vSphere environment.

## Topology represented in the configuration

| VM role | Count | Typical sizing configured |
| --- | ---: | --- |
| Control-plane candidates | 7 | 4 vCPU / 8 GiB RAM / 50 GiB disk |
| Worker candidates | 9 | 2 vCPU / 4 GiB RAM / 30 GiB disk |
| Load balancer candidates | 5 | 2 vCPU / 4 GiB RAM / 20 GiB disk |
| NFS candidates | 2 | 4 vCPU / 8 GiB RAM / 200 GiB disk |
| Jenkins candidate | 1 | 2 vCPU / 4 GiB RAM / 20 GiB disk |

The topology is illustrative; validate host capacity and placement before deployment.

## Key files

- `main.tf`: vSphere provider, inventory-like locals, VM resources, network/data-source lookups.
- `variables.tf`: vCenter/ESXi connection, datacenter, datastore, port groups and ISO inputs.
- `outputs.tf`: configured Terraform outputs.
- `terraform.tfvars`: a *tracked example* with blank connection credentials; do not put real secrets in this file.

## Prerequisites

vSphere/ESXi access with appropriate permissions, a supported Terraform version, VMware vSphere provider, target networks, accessible datastore, an installation ISO, and sufficient VM capacity.

## Safe validation workflow

```bash
terraform init
terraform fmt -check -recursive
terraform validate
# Set credentials through environment variables or an untracked secret file.
terraform plan
# Inspect host counts, networks and resource consumption before any apply.
```

Never apply to a production vCenter without an approved change, adequate free capacity, and a reviewed plan.

## Security and operation notes

- **Do not commit credentials, Terraform state or deployment plan files.**
- `allow_unverified_ssl = true` in the original provider configuration bypasses certificate verification. Configure a trusted TLS certificate before production use.
- The Terraform resources provision VMs; installing and configuring a working cluster requires additional automation and operational checks.
- The hard-coded VM names and host roles represent a specific demonstration topology and should be parameterized for reuse.
- Destroy plans can remove entire virtual machines. Verify state scope and backups before using `terraform destroy`.

## Portfolio enhancement roadmap

- Parameterize node counts, CPU/memory and VM naming per environment
- Secure remote state and sensitive variable handling
- Reusable vSphere VM module
- cloud-init / OS bootstrapping and Ansible configuration
- Drift detection, safe CI validation and deployment evidence

*Portfolio theme: VMware, Terraform, compute provisioning, network design and infrastructure operations.*


## Selected visual evidence

See [historical evidence and its limits](VISUAL-EVIDENCE.md). These related captures do not establish that the Terraform or lab manifests in this repository were executed.
