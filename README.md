# azure-terraform

A minimal [Terraform](https://www.terraform.io/) example for Azure.

## Prerequisites

All you need for this demo is an Azure account (you can get a free one
[here](https://azure.microsoft.com/en-us/free/)). Everything else is run through
[Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)
in a browser.

## Starting Cloud Shell

Log in to the [Azure portal](https://portal.azure.com) and click the Cloud Shell
icon:

![Start Cloud Shell](https://github.com/simonbrady/azure-terraform/blob/main/img/start_shell.png "Start Cloud Shell")

If this is the first time you've launched Cloud Shell you'll be prompted to choose either the PowerShell or
bash experience. This demo is written for PowerShell but you can choose either one, since the commands will be
almost identical.

After choosing your shell you'll be prompted to create an
[Azure storage account](https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage) for Cloud Shell
to store files in. Unlike the resources you'll create in this example, the storage account **will incur charges**
so you'll want to delete it when you're finished (that said, the charges will be minimal).

When your shell has launched you can run `terraform version` to confirm that the pre-installed copy of Terraform
is working as expected:

```
Requesting a Cloud Shell.Succeeded.
Connecting terminal...

Welcome to Azure Cloud Shell

Type "az" to use Azure CLI
Type "help" to learn about Cloud Shell


VERBOSE: Authenticating to Azure ...
VERBOSE: Building your Azure drive ...
PS /home/simon> terraform version
Terraform v1.3.2
on linux_amd64
```

This demo will work with any Terraform 1.x version, so don't worry if you get a warning that the pre-installed
version is out of date.

## Copying Templates

Now that you have persistent storage attached to your Cloud Shell you can clone this git repository
to get a local copy of the Terraform template files:

```
PS /home/simon> cd $HOME/clouddrive
PS /home/simon/clouddrive> git clone https://github.com/simonbrady/azure-terraform.git
Cloning into 'azure-terraform'...
remote: Enumerating objects: 79, done.
remote: Counting objects: 100% (5/5), done.
remote: Compressing objects: 100% (5/5), done.
remote: Total 79 (delta 0), reused 5 (delta 0), pack-reused 74
Receiving objects: 100% (79/79), 48.83 KiB | 233.00 KiB/s, done.
Resolving deltas: 100% (32/32), done.
PS /home/simon/clouddrive> cd azure-terraform/demo
PS /home/simon/clouddrive/azure-terraform/demo> ls
main.tf  provider.tf  vars.tf
```

## Template Content

The templates that define the Azure resources we're going to build are text files written in
[HashiCorp Configuration Language](https://developer.hashicorp.com/terraform/language) (HCL). Terraform picks up all
`*.tf` files in the current directory (and in [modules](https://developer.hashicorp.com/terraform/language/modules)
although we won't cover those here) and parses them as a lump, so while you can put everything in one big file
the convention is to break things up. A big part of being productive in Terraform, or any technology for that matter,
is learning convention - if speak like Yoda I do, still understand me you will, but it's easier for everyone if I follow
the accepted conventions of English word order.

The template files in this demo are:

* [main.tf](demo/main.tf) - defines the individual resources we're deploying. The resources can be of any type
our configured provider understands, and their properties can reference input variables using HCL's
[expression syntax](https://developer.hashicorp.com/terraform/language/expressions).
* [provider.tf](demo/provider.tf) - specifies the minimum version of Terraform required to deploy this project and configures the
[Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest) which is the glue between generic
Terraform and Azure. Terraform itself is a generalised resource deployment engine and the provider (there are
[many](https://developer.hashicorp.com/terraform/language/providers)) is a plugin for a specific target platform.
In our case we only configure the Azure one, but a single Terraform project can use as many as needed.
* [vars.tf](demo/vars.tf) - defines [input variables](https://developer.hashicorp.com/terraform/language/values/variables) that
you can use to parameterise your resource deployment. Variables are absolutely key to harnessing the power of Terraform -
they let you centralise configuration that can change (similar to defining named constants in a traditional programming
language rather than sprinkling magic values throughout the code), which makes it easy to reuse existing templates with
minimal effort.

## Resource Deployment

### Initialising Terraform

Before using Terraform for a deployment, or any time you change the provider configuration, you first have to initialise
the provider with `terraform init`:

```
PS /home/simon/clouddrive/azure-terraform/demo> terraform init
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 3.0"...
- Installing hashicorp/azurerm v3.85.0...
- Installed hashicorp/azurerm v3.85.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

The provider binary is downloaded to a hidden `.terraform` directory and will continue to be used until the next time
`terraform init` is run.

### Creating New Resources

In [main.tf](demo/main.tf) we define two resources: a
[resource group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
called `demo-rg` that acts as a container for other resources, and a
[virtual network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) called `demo-vnet`
that lives inside the resource group. Before creating these, go to the All Resources view in the Azure console to
confirm you don't already have any resources that clash with these names (if you're starting from scratch, the only
resource you should see is the storage account that Cloud Shell created on your behalf).

Terraform tracks the [state](https://developer.hashicorp.com/terraform/language/state) of resources it's deployed so it can
determine when to apply incremental changes. Initially there isn't any state to record, so when Terraform looks at
the template it will realise it needs to create all the resources defined there.

Since resources can change without Terraform's knowledge, e.g. by direct updates in the Azure console, it needs a
way to examine their current state as well as what was last recorded. This is done by running `terraform plan`
which compares the resources defined in the template (desired state) with what's actually deployed:

```
PS /home/simon/clouddrive/azure-terraform/demo> terraform plan
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.demo will be created
  + resource "azurerm_resource_group" "demo" {
      + id       = (known after apply)
      + location = "australiaeast"
      + name     = "demo-rg"
    }

  # azurerm_virtual_network.demo will be created
  + resource "azurerm_virtual_network" "demo" {
      + address_space       = [
          + "10.1.0.0/16",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "australiaeast"
      + name                = "demo-vnet"
      + resource_group_name = "demo-rg"
      + subnet              = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform
apply" now.
```

This shows that Terraform expects to create two new resources. Resource attributes that are explicitly
set in the template or can be determined from variables are listed with their values (e.g. the `location`
attribute for both resources), while attributes whose values can't be determined in advance are listed
as `(known after apply)`.

A key tenet of infastructure as code is that _all_ changes should be made in code, and not through direct
modification of resources. However, since it's difficult to guarantee this, you should run `terraform plan`
frequently to test the impact of any changes you're making in the code. This also does a basic syntax check
of the template source, although it won't catch all possible errors.

To actually apply the changes, run `terraform apply`. This will do an additional check against actual resource
state, similar to `terraform plan`, so it's vital that you check the output prior to confirming the change can
proceed:

```
PS /home/simon/clouddrive/azure-terraform/demo> terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.demo will be created
  + resource "azurerm_resource_group" "demo" {
      + id       = (known after apply)
      + location = "australiaeast"
      + name     = "demo-rg"
    }

  # azurerm_virtual_network.demo will be created
  + resource "azurerm_virtual_network" "demo" {
      + address_space       = [
          + "10.1.0.0/16",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "australiaeast"
      + name                = "demo-vnet"
      + resource_group_name = "demo-rg"
      + subnet              = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.demo: Creating...
azurerm_resource_group.demo: Creation complete after 2s [id=/subscriptions/.../resourceGroups/demo-rg]
azurerm_virtual_network.demo: Creating...
azurerm_virtual_network.demo: Creation complete after 6s [id=/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

If you now refresh the All Resources view in the console, you shoud see `demo-vnet` listed with `demo-rg` as its resource group.

### Modifying an Existing Resource

When `terraform apply` runs it updates (or creates) the local state record to reflect what actions it carried out. In our case you'll see a
file `terraform.tfstate` in your local directory, although Terraform can use different
[backends](https://developer.hashicorp.com/terraform/language/settings/backends/configuration)
to share state between developers.

To force an incremental change, click the Open Editor button in Cloud Shell then choose `clouddrive/demo/vars.tf`:

![Open editor button](https://github.com/simonbrady/azure-terraform/blob/main/img/open_editor.png "Open editor button")

Update the `default` value for `address_space`, e.g. to "10.2.0.0/16", then save your changes:

![Save file](https://github.com/simonbrady/azure-terraform/blob/main/img/save.png "Save flle")

Run `terraform plan` to confirm that your change will lead to an in-place update of the virtual
network:

```
PS /home/simon/clouddrive/azure-terraform/demo> terraform plan
azurerm_resource_group.demo: Refreshing state... [id=/subscriptions/.../resourceGroups/demo-rg]
azurerm_virtual_network.demo: Refreshing state... [id=/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_virtual_network.demo will be updated in-place
  ~ resource "azurerm_virtual_network" "demo" {
      ~ address_space           = [
          - "10.1.0.0/16",
          + "10.2.0.0/16",
        ]
        id                      = "/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet"
        name                    = "demo-vnet"
        tags                    = {}
        # (6 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform
apply" now.
```

Now run `terraform apply` to make the change:

```
S /home/simon/clouddrive/azure-terraform/demo> terraform apply
azurerm_resource_group.demo: Refreshing state... [id=/subscriptions/.../resourceGroups/demo-rg]
azurerm_virtual_network.demo: Refreshing state... [id=/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_virtual_network.demo will be updated in-place
  ~ resource "azurerm_virtual_network" "demo" {
      ~ address_space           = [
          - "10.1.0.0/16",
          + "10.2.0.0/16",
        ]
        id                      = "/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet"
        name                    = "demo-vnet"
        tags                    = {}
        # (6 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_virtual_network.demo: Modifying... [id=/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet]
azurerm_virtual_network.demo: Still modifying... [id=/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet, 10s elapsed]
azurerm_virtual_network.demo: Modifications complete after 11s [id=/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Back in the Azure console you should see the new address space in the details for the `demo-vnet`
virtual network.

### Further Modifications

Our virtual network configuration is the bare minimum necessary to deploy, but the
[provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network.html)
lists lots of optional attributes we could also define. Some suggestions to get you started:

* Add some descriptive [tags](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources) to the resource.
* Divide the address space into [subnets](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-arm#segmentation)
(hint: rather than hard-coding subnet CIDR ranges that would have to change if you updated the address space, define Terraform
[local values](https://developer.hashicorp.com/terraform/language/values/locals) using the
[cidrsubnet](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet) function).

### Destroying Resources

To clean up all the resources Terraform created, run `terraform destroy`:

```
PS /home/simon/clouddrive/azure-terraform/demo> terraform destroy
azurerm_resource_group.demo: Refreshing state... [id=/subscriptions/.../resourceGroups/demo-rg]
azurerm_virtual_network.demo: Refreshing state... [id=/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # azurerm_resource_group.demo will be destroyed
  - resource "azurerm_resource_group" "demo" {
      - id       = "/subscriptions/.../resourceGroups/demo-rg" -> null
      - location = "australiaeast" -> null
      - name     = "demo-rg" -> null
      - tags     = {} -> null
    }

  # azurerm_virtual_network.demo will be destroyed
  - resource "azurerm_virtual_network" "demo" {
      - address_space           = [
          - "10.2.0.0/16",
        ] -> null
      - dns_servers             = [] -> null
      - flow_timeout_in_minutes = 0 -> null
      - guid                    = "63e23999-2b5a-4200-a846-1db9b66759ff" -> null
      - id                      = "/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet" -> null
      - location                = "australiaeast" -> null
      - name                    = "demo-vnet" -> null
      - resource_group_name     = "demo-rg" -> null
      - subnet                  = [] -> null
      - tags                    = {} -> null
    }

Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_virtual_network.demo: Destroying... [id=/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet]
azurerm_virtual_network.demo: Still destroying... [id=/subscriptions/.../resourceGroups/demo-rg/providers/Microsoft.Network/virtualNetworks/demo-vnet, 10s elapsed]
azurerm_virtual_network.demo: Destruction complete after 11s
azurerm_resource_group.demo: Destroying... [id=/subscriptions/.../resourceGroups/demo-rg]
azurerm_resource_group.demo: Still destroying... [id=/subscriptions/.../resourceGroups/demo-rg, 10s elapsed]
azurerm_resource_group.demo: Destruction complete after 18s

Destroy complete! Resources: 2 destroyed.
```

Note that Terraform only destroys resources it created - if you want to delete the storage account that
Cloud Shell created, you'll need to do it manually through the Azure console.

## Further Reading

* [Introduction to Terraform](https://developer.hashicorp.com/terraform/intro)
* [Getting started with Terraform using the Azure provider](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)
* [Terraform on Azure documentation](https://learn.microsoft.com/en-us/azure/developer/terraform/)
