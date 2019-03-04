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

## Further Reading

* [Introduction to Terraform](https://www.terraform.io/intro/index.html)
* [Terraform Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html)
* [Terraform Cloud Shell development](https://docs.microsoft.com/en-us/azure/terraform/terraform-cloud-shell)
