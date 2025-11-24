
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://10.144.208.51:8006/api2/json"
  pm_tls_insecure = true
}

variable "vm_ip" {
  default = "10.144.208.115" # e.g. 10.144.208.122
}

variable "ssh_key_path" {
  default = "~/.ssh/id_ed25519.pub" # public key, e.g. ~/.ssh/id_ed25519.pub
}

variable "network_config" {
  default = {
    gateway = "10.144.208.1"
    nameserver = "10.44.10.98"
  }
}

resource "proxmox_vm_qemu" "redis_vm" {

  name = "vm-a23ouraq"
  vmid = split(".", var.vm_ip)[3]
  target_node = "dapi-na-cours-pve-02"
  clone = "template-debian"
  tags = "fila3"

  #cloud init config
  os_type = "cloud-init"
  ciuser = "a23ouraq"
  # cipassword = "iole"
  sshkeys = file(var.ssh_key_path)

  cpu {
    cores = 1
    sockets = 1
    type = "host"
  }

  #memory
  memory = "1024"

  #network
  ipconfig0 = "ip=${var.vm_ip}/24,gw=${var.network_config.gateway}"
  nameserver = var.network_config.nameserver
  network {
    id = 0
    bridge = "vmbr0"
    model = "virtio"
  }

  #disk
  scsihw = "virtio-scsi-pci"
  disks {
    virtio {
      virtio0 {
        disk {
          size = "20G"
          storage = "vg_proxmox"
          iothread = true
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "vg_proxmox"
        }
      }
    }
  }

}

