
// Create SSH keys for VMs if not provided

# SSH Key for VMs
resource "tls_private_key" "installkey" {
  count     = var.openshift_ssh_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "write_private_key" {
  count           = var.openshift_ssh_key == "" ? 1 : 0
  content         = tls_private_key.installkey[0].private_key_pem
  filename        = "${path.root}/installer-files/artifacts/openshift_rsa"
  file_permission = 0600
}

resource "local_file" "write_public_key" {
  content         = local.public_ssh_key
  filename        = "${path.root}/installer-files/artifacts/openshift_rsa.pub"
  file_permission = 0600
}

// Configure DNS records
// TODO: Add this later if the FQDN created for the public LB does not work.

// Create a storage account

// Create the ignition files

// Run openshift-installer and clean up bootstrap