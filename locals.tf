locals {
  location                    = "francecentral"
  address_space               = "172.25.14.0/24"
  vgw_address_space           = "172.25.15.0/24"
  github_runner_address_space = "10.58.0.0/19"
  vm_to_deploy = [
    {
      name       = "st1"
      hostnumber = 5
      data_disks = [
        {
          letter = "E"
          lun    = 0
          size   = 128
        }
      ]
    },
    {
      name       = "cp1"
      hostnumber = 6
      data_disks = [
        {
          letter = "E"
          lun    = 0
          size   = 128
        }
      ]
    },
    {
      name       = "el1"
      hostnumber = 7
      data_disks = [
        {
          letter = "E"
          lun    = 0
          size   = 128
        }
      ]
    },
    {
      name       = "db1"
      hostnumber = 8
      data_disks = [
        {
          letter = "E"
          lun    = 0
          size   = 128
        },
        {
          letter = "F"
          lun    = 1
          size   = 128
        },
        {
          letter = "G"
          lun    = 2
          size   = 128
        }
      ]
    }
  ]

  data_disks_to_deploy = merge(values({
    for k, v in local.vm_to_deploy : v.name => {
      for d in v.data_disks : "${v.name}-${d.letter}" => {
        hostname = v.name
        letter   = d.letter
        lun      = d.lun
        size     = d.size
      }
    }
  })...)
}


variable "admin_password" {
  sensitive = true
  type      = string
}

variable "admin_username" {
  type = string
}
variable "ipsec_psk" {
  sensitive = true
  type      = string
}

variable "zi_cfr_public_ip" {
  type = string
}

variable "zi_cfr_address_spaces" {
  type = list(string)
}
