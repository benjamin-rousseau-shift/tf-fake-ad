locals {
  location                    = "francecentral"
  address_space               = "172.25.14.0/24"
  github_runner_address_space = "10.58.0.0/19"
  vm_to_deploy = [
    {
      name       = "st1"
      hostnumber = 5
      data_disks = [
        {
          letter = "E"
          lun    = 0
          size   = 100
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
          size   = 100
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
          size   = 100
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
          size   = 100
        },
        {
          letter = "F"
          lun    = 1
          size   = 100
        },
        {
          letter = "G"
          lun    = 2
          size   = 100
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
