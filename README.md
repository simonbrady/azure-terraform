# azure-terraform

A minimal [Terraform](https://www.terraform.io/) example for Azure.

## Prerequisites

All you need for this demo is an Azure account. You can get a free one
[here](https://azure.microsoft.com/en-us/free/). Everything else is run through
[Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)
in a browser.

## Starting Cloud Shell

Log in to the [Azure portal](https://portal.azure.com) and click the Cloud Shell
icon:

![Start Cloud Shell](https://github.com/simonbrady/azure-terraform/raw/master/img/start_shell.png "Start Cloud Shell")

If this is the first time you've launched Cloud Shell you'll be prompted to choose either the PowerShell or
bash experience. This demo is written for PowerShell but you can choose either one, since the commands will be
almost identical.

After choosing your shell you'll be prompted to create an
[Azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview) for Cloud Shell
to store files in. Unlike the resources you'll create in this example, the storage account **will incur charges**
so you'll want to delete it when you're finished (that said, the charges will be minimal).

When your shell has launched you can run `terraform version` to confirm that the pre-installed copy of Terraform
is working as expected:

```
Your cloud drive has been created in:

Subscription Id: [...]
Resource group:  [...]
Storage account: [...]
File share:      [...]

Initializing your account for Cloud Shell...-
Requesting a Cloud Shell.Succeeded.
Connecting terminal...

Welcome to Azure Cloud Shell

Type "az" to use Azure CLI 2.0
Type "help" to learn about Cloud Shell


MOTD: Manage Azure Active Directory: Get-Command -Module AzureAD*

VERBOSE: Authenticating to Azure ...
VERBOSE: Building your Azure drive ...
Azure:/
PS Azure:\> terraform version
Terraform v0.11.11
```

## Uploading Templates

Upload the three `.tf` files in the `demo` subdirectory by clicking the upload button in the Cloud Shell console:

![Upload files button](https://github.com/simonbrady/azure-terraform/raw/master/img/upload_files.png "Upload files button")

You'll have to upload each one individually, then move them from your Cloud Shell home directory to the persistent storage
that's backed by your storage account:

```
PS Azure:\> cd $HOME
PS /home/simon> ls
clouddrive  main.tf  provider.tf  vars.tf
PS /home/simon> mkdir clouddrive/demo
PS /home/simon> mv *.tf clouddrive/demo
PS /home/simon> cd clouddrive/demo
PS /home/simon/clouddrive/demo>
```

## Template Content

The templates that define the Azure resources we're going to build are text files written in
[HashiCorp Configuration Language](https://www.terraform.io/docs/configuration/index.html) (HCL). Terraform picks up all
`*.tf` files in the current directory (and in [modules](https://www.terraform.io/docs/configuration/modules.html)
although we won't cover those here) and parses them as a lump, so while you can put everything in one big file
the convention is to break things up. A big part of being productive in Terraform, or any technology for that matter,
is learning convention - if speak like Yoda I do, still understand me you will, but it's easier for everyone if I follow
the accepted conventions of English word order.

The template files in this demo are:

* [vars.tf](demo/vars.tf) - defines [input variables](https://www.terraform.io/docs/configuration/variables.html) that
you can use to parameterise your resource deployment. Variables are absolutely key to harnessing the power of Terraform -
they let you centralise configuration that can change (similar to defining named constants in a traditional programming
language rather than sprinkling magic values throughout the code), which makes it easy to reuse existing templates with
minimal effort.
* [provider.tf](demo/provider.tf) - configures the
[Terraform Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html) which is the glue between generic
Terraform and Azure. Terraform itself is a generalised resource deployment engine and the provider (there are
[many](https://www.terraform.io/docs/providers/index.html)) is a plugin for a specific target platform.
In our case we only configure the Azure one, but a single Terraform project can use as many as needed.
* [main.tf](demo/main.tf) - defines the individual resources we're deploying. The resources can be of any type
our configured provider understands, and their properties can reference input variables using HCL's
[interpolation syntax](https://www.terraform.io/docs/configuration-0-11/interpolation.html) (note that this link is
specific to Terraform 0.11 and earlier, as used in Cloud Shell, because the syntax will slightly
[change](https://www.terraform.io/docs/configuration/expressions.html) in 0.12).

## Resource Deployment

### Initialising Terraform

Before using Terraform for a deployment, or any time you change the provider configuration, you first have to initialise
the provider with `terraform init`:

```
PS /home/simon/clouddrive/demo> terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "azurerm" (1.22.1)...

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
[resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview) called `demo-rg`
that acts as a container for other resources, and a
[virtual network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) called `demo-vnet`
that lives inside the resource group. Before creating these, go to the All Resources view in the Azure console to
confirm you don't already have any resources that clash with these names (if you're starting from scratch, the only
resource you should see is the storage account that Cloud Shell created on your behalf).

Terraform tracks the [state](https://www.terraform.io/docs/state/index.html) of resources it's deployed so it can
determine when to apply incremental changes. Initially there isn't any state to record, so when Terraform looks at
the template it will realise it needs to create all the resources defined there.

Since resources can change without Terraform's knowledge, e.g. by direct updates in the Azure console, it needs a
way to examine their current state as well as what was last recorded. This is done by running `terraform plan`
which compares the resources defined in the template (desired state) with what's actually deployed:

```
PS /home/simon/clouddrive/demo> terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.demo
      id:                  <computed>
      location:            "australiaeast"
      name:                "demo-rg"
      tags.%:              <computed>

  + azurerm_virtual_network.demo
      id:                  <computed>
      address_space.#:     "1"
      address_space.0:     "10.1.0.0/16"
      location:            "australiaeast"
      name:                "demo-vnet"
      resource_group_name: "demo-rg"
      subnet.#:            <computed>
      tags.%:              <computed>


Plan: 2 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

This shows that Terraform expects to create two new resources. Resource attributes that are explicitly
set in the template or can be determined from variables are listed with their values (e.g. the `location`
attribute for both resources), while attributes whose values can't be determined in advance are listed
as `<computed>`.

A key tenet of infastructure as code is that _all_ changes should be made in code, and not through direct
modification of resources. However, since it's difficult to guarantee this, you should run `terraform plan`
frequently to test the impact of any changes you're making in the code. This also does a basic syntax check
of the template source, although it won't catch all possible errors.

To actually apply the changes, run `terraform apply`. This will do an additional check against actual resource
state, similar to `terraform plan`, so it's vital that you check the output prior to confirming the change can
proceed:

```
PS /home/simon/clouddrive/demo> terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.demo
      id:                  <computed>
      location:            "australiaeast"
      name:                "demo-rg"
      tags.%:              <computed>

  + azurerm_virtual_network.demo
      id:                  <computed>
      address_space.#:     "1"
      address_space.0:     "10.1.0.0/16"
      location:            "australiaeast"
      name:                "demo-vnet"
      resource_group_name: "demo-rg"
      subnet.#:            <computed>
      tags.%:              <computed>


Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.demo: Creating...
  location: "" => "australiaeast"
  name:     "" => "demo-rg"
  tags.%:   "" => "<computed>"
azurerm_resource_group.demo: Creation complete after 2s (ID: /subscriptions/9778f812-31e9-47a9-af63-b5f9df11fd37/resourceGroups/demo-rg)
azurerm_virtual_network.demo: Creating...
  address_space.#:     "" => "1"
  address_space.0:     "" => "10.1.0.0/16"
  location:            "" => "australiaeast"
  name:                "" => "demo-vnet"
  resource_group_name: "" => "demo-rg"
  subnet.#:            "" => "<computed>"
  tags.%:              "" => "<computed>"
azurerm_virtual_network.demo: Still creating... (10s elapsed)
azurerm_virtual_network.demo: Creation complete after 15s (ID: /subscriptions/9778f812-31e9-47a9-af63-...soft.Network/virtualNetworks/demo-vnet)

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

If you now refresh the All Resources view in the console, you shoud see `demo-vnet` listed with `demo-rg` as its resource group.

### Modifying an Existing Resource

When `terraform apply` runs it updates (or creates) the local state record to reflect what actions it carried out. In our case you'll see a
file `terraform.tfstate` in your local directory, although Terraform can use different [backends](https://www.terraform.io/docs/backends/index.html)
to share state between developers.

To force an incremental change, click the Open Editor button in Cloud Shell then choose `clouddrive/demo/vars.vf`:

![Open editor button](https://github.com/simonbrady/azure-terraform/raw/master/img/open_editor.png "Open editor button")

Update the `default` value for `cidr_range`, e.g. to "10.2.0.0/16", then save your changes:

![Save file](https://github.com/simonbrady/azure-terraform/raw/master/img/save.png "Save flle")

Run `terraform plan` to confirm that your change will lead to an in-place update of the virtual
network:

```
PS /home/simon/clouddrive/demo> terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

azurerm_resource_group.demo: Refreshing state... (ID: /subscriptions/9778f812-31e9-47a9-af63-b5f9df11fd37/resourceGroups/demo-rg)
azurerm_virtual_network.demo: Refreshing state... (ID: /subscriptions/9778f812-31e9-47a9-af63-...soft.Network/virtualNetworks/demo-vnet)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ azurerm_virtual_network.demo
      address_space.0: "10.1.0.0/16" => "10.2.0.0/16"


Plan: 0 to add, 1 to change, 0 to destroy.
```

Now run `terraform apply` to make the change:

```
PS /home/simon/clouddrive/demo> terraform apply
azurerm_resource_group.demo: Refreshing state... (ID: /subscriptions/9778f812-31e9-47a9-af63-b5f9df11fd37/resourceGroups/demo-rg)
azurerm_virtual_network.demo: Refreshing state... (ID: /subscriptions/9778f812-31e9-47a9-af63-...soft.Network/virtualNetworks/demo-vnet)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ azurerm_virtual_network.demo
      address_space.0: "10.1.0.0/16" => "10.2.0.0/16"


Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_virtual_network.demo: Modifying... (ID: /subscriptions/9778f812-31e9-47a9-af63-...soft.Network/virtualNetworks/demo-vnet)
  address_space.0: "10.1.0.0/16" => "10.2.0.0/16"
azurerm_virtual_network.demo: Modifications complete after 2s (ID: /subscriptions/9778f812-31e9-47a9-af63-...soft.Network/virtualNetworks/demo-vnet)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Back in the Azure console you should see the new address space in the details for the `demo-vnet`
virtual network.

### Destroying Resources

To clean up all the resourcs Terraform created, run `terraform destroy`:

```
PS /home/simon/clouddrive/demo> terraform destroy
azurerm_resource_group.demo: Refreshing state... (ID: /subscriptions/9778f812-31e9-47a9-af63-b5f9df11fd37/resourceGroups/demo-rg)
azurerm_virtual_network.demo: Refreshing state... (ID: /subscriptions/9778f812-31e9-47a9-af63-...soft.Network/virtualNetworks/demo-vnet)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - azurerm_resource_group.demo

  - azurerm_virtual_network.demo


Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_virtual_network.demo: Destroying... (ID: /subscriptions/9778f812-31e9-47a9-af63-...soft.Network/virtualNetworks/demo-vnet)
azurerm_virtual_network.demo: Destruction complete after 1s
azurerm_resource_group.demo: Destroying... (ID: /subscriptions/9778f812-31e9-47a9-af63-b5f9df11fd37/resourceGroups/demo-rg)
azurerm_resource_group.demo: Still destroying... (ID: /subscriptions/9778f812-31e9-47a9-af63-b5f9df11fd37/resourceGroups/demo-rg, 10s elapsed)
azurerm_resource_group.demo: Still destroying... (ID: /subscriptions/9778f812-31e9-47a9-af63-b5f9df11fd37/resourceGroups/demo-rg, 20s elapsed)
azurerm_resource_group.demo: Still destroying... (ID: /subscriptions/9778f812-31e9-47a9-af63-b5f9df11fd37/resourceGroups/demo-rg, 30s elapsed)
azurerm_resource_group.demo: Still destroying... (ID: /subscriptions/9778f812-31e9-47a9-af63-b5f9df11fd37/resourceGroups/demo-rg, 40s elapsed)
azurerm_resource_group.demo: Destruction complete after 50s

Destroy complete! Resources: 2 destroyed.
```

Note that Terraform only destroys resources it created - if you want to delete the storage account that
Cloud Shell created, you'll need to do it manually through the Azure console.

## Further Reading

* [Introduction to Terraform](https://www.terraform.io/intro/index.html)
* [Terraform Cloud Shell development](https://docs.microsoft.com/en-us/azure/terraform/terraform-cloud-shell)
