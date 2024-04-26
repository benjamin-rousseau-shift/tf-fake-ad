locals {
  location      = "francecentral"
  address_space = "172.25.14.0/24"
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
          lun    = 0
          size   = 100
        },
        {
          letter = "G"
          lun    = 0
          size   = 100
        }
      ]
    }
  ]
}


variable "admin_password" {
  sensitive = true
  type      = string
}

variable "admin_username" {
  type = string
}
