output "all_vms" {
  description = "IDs of all provisioned VMs"
  value = {
    controlplanes = { for k, v in vsphere_virtual_machine.controlplane : k => v.id }
    workers       = { for k, v in vsphere_virtual_machine.workers : k => v.id }
    loadbalancers = { for k, v in vsphere_virtual_machine.loadbalancers : k => v.id }
    jenkins       = vsphere_virtual_machine.jenkins.id
    nfs           = { for k, v in vsphere_virtual_machine.nfs : k => v.id }
  }
}
