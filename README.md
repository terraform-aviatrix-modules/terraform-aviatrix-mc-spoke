# terraform-aviatrix-module-template

This repository provides standardized instructions and conventions for creating Aviatrix modules.

#### Instructions
1. Create a new repository from this template, by clicking the green "Use this template" button. Make sure to use the [module naming convention](#module-naming-convention)
2. Clone the repository to your system with ```git clone <repository>```
5. Edit the repository and commit and update the new repository:
    - Commit changes: ```git commit -am "Description of changes"```
    - Push to repository: ```git push origin master```
6. Update the readme.md file
    - Remove all content above [the line](#delete-everything-above-and-including-this-line).
    - Fill out the rest of file based on the provided template.
7. When ready for release, create a [tag](#tagging).

#### Conventions

###### Repositories
- For each module, a new reposity shall be created. This is for the purpose of:
    - Version control per module
    - Issue handling/feature requests per module
    - Easier consumption of the module in projects and publication in registers like Terraform Cloud

###### Module Naming convention
We will use the following convention for naming repositories:

**terraform-aviatrix-\<cloudname or mc for multi-cloud>-\<function>**

Function can be a single word, or more if required to accurately describe the module function. These should be seperated by hyphens. Example:

**terraform-aviatrix-aws-transit-firenet**

###### Resource Naming convention
```A naming convention for objects created through our modules needs to be decided upon and inserted here.```

###### Tagging
In order to use modules, it is best practice to tag versions when they are ready for consumption. The format to be used for this is "vx.x.x" e.g. v0.0.1. This can be done on Github by clicking "Create a new release". It is also possible to do this from your system. Make sure you committed your changes to the master branch. After that, create a new tag with ```git tag vx.x.x``` and push the tagged version to the tagged branch with ```git push origin vx.x.x```.

As soon as a module is ready for publishing publicly, the tag release should move up to the first major release. A tag v1.0.0 should be created and the repository can now be altered from a private to a public.

###### Module layout
The repository contains the default file layout that is recommended to use.
file | use
:---|:---
main.tf | This should contain the resources to be created
variables.tf | This should contain all expected input variables
output.tf | This should contain all output objects

Diagram images used in the readme.md should be stored on a publicly available environment. E.g. a public s3 bucket. The reason for that is, when publishing these modules at some point (e.g. Terraform Registry), the image source should always be publicly accessible, even though the repository itself might not be.


#### Delete everything above and including this line
***

# Repository Name

### Description
\<Provide a description of the module>

### Diagram
\<Provide a diagram of the high level constructs thet will be created by this module>
<img src="<IMG URL>"  height="250">

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v1.0.2 | 0.12 | 6.1 | 0.2.16
v1.0.1 | | |
v1.0.0 | | |

### Usage Example
```
module "transit_aws_1" {
  source  = "terraform-aviatrix-modules/aws-transit/aviatrix"
  version = "1.0.0"

  cidr = "10.1.0.0/20"
  region = "eu-west-1"
  aws_account_name = "AWS"
}
```

### Variables
The following variables are required:

key | value
:--- | :---
\<keyname> | \<description of value that should be provided in this variable>

The following variables are optional:

key | default | value 
:---|:---|:---
\<keyname> | \<default value> | \<description of value that should be provided in this variable>

### Outputs
This module will return the following outputs:

key | description
:---|:---
\<keyname> | \<description of object that will be returned in this output>
