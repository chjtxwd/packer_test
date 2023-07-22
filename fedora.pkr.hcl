packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
variable "password" {
  type    = string
  default = "demo"
}

variable "username" {
  type    = string
  default = "root@pam"
}

source "proxmox-iso" "fedora-kickstart" {
  boot_command = ["<wait><up>e<wait><down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<F10><wait>"]
  boot_wait    = "10s"
  memory = 4096
  cores  = 2
  disks {
    disk_size    = "32G"
    storage_pool = "local-lvm"
    type         = "scsi"
  }
  efi_config {
    efi_storage_pool  = "local-lvm"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }
  http_directory           = "config"
  insecure_skip_tls_verify = true
  iso_file                 = "local:iso/Fedora-Everything-netinst-x86_64-38-1.6.iso"
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  node                 = "pve"
  password             = "${var.password}"
  proxmox_url          = "https://192.168.0.5:8006/api2/json"
  ssh_password         = "demo"
  ssh_timeout          = "60m"
  ssh_username         = "root"
  template_description = "Fedora 38, generated on ${timestamp()}"
  template_name        = "fedora-38"
  unmount_iso          = true
  username             = "${var.username}"
  qemu_agent           = true
}

build {
  sources = ["source.proxmox-iso.fedora-kickstart"]
  provisioner "shell" {
    inline = ["systemctl disable firewalld"]
  }
}

