%title: Terraform (Declaring your Cluster)
%author: Informatics Matters Ltd.
%date: 11 Dec 2018
 
-> ## A brief introduction to Terraform for infrastructure management <-



^
-> About me, Alan Christie... <-

-> Solution Architect at *Informatics Matters Ltd.* <-
-> where we provide software solutions for... <-

-> Cloud Native Applications <-
-> Automation <-
-> Scientific Workflows <-





Someone who'd...

>   *rather write programs to write programs*
>   *than write programs*

And believes...

>   *If it's worth doing once*
>   *It's probably worth creating a tool to do it*

---

-> ## What is Terraform?  <-

- A compact binary *provisioning* tool
  that deploys infrastructure from your workstation
  
- Makes API calls to *providers*
  like AWS, GCP and Azure (and about 90 others)
  
- Uses text-based Configurations
  that define the *resources* you want
 
- Is *Declarative*
  so you tell it _what_ you want
  and terraform creates a dependency graph and uses APIs to "make it so"
  
- A tool with *Open Source* and *Enterprise* offerings

^
# Terraform's essence is...

*provisioning* (of generally immutable resources)
not *configuration* (the tuning of resources)  

^
# Importantly, and probably obviously...

>   Although Terraform appears to be *cloud agnostic*
>   The configurations you write are not.
>   Your AWS configuration will not work on Azure

---

-> ## Terraform - a link in a chain of tools? <-



->              ▛▀▀▀▀▀▀▀▀▀▀▀▜              <-
-> Packer  =->  ▌ Terraform ▐  =-> Ansible <-
->              ▙▄▄▄▄▄▄▄▄▄▄▄▟              <-



- *Packer* to _Build_ base images for the physical machines
- *Terraform* to _Assemble_ the network of machines
- *Ansible* to _Configure_ and manage the machine software

---

-> ## Configuration Language <-

- Configuration is defined in human-readable text files
- That have a *\.tf* file extension (or *\.tf.json*)
- Whose syntax is the HashiCorp Configuration Language, *HCL*
- Language allows you to
  - create a _resource_
  - using a _provider type_
  - and give it a _name_ 

^
```hcl
# The application volume
resource "scaleway_volume" "app" {
  type       = "l_ssd"
  size_in_gb = 50
  name       = "${var.app_vol_name}"
}
```

The file format supports...

-  Comments
-  Strings, numbers and booleans
-  Maps and lists
-  Interpolations ( *${}* )

---

-> ## Variables <-

_Variables_ satisfy _DRY_ programming principles. They support...

- *Descriptions*
- *Types*
  - String
  - List
  - Map
- *Default Values* that can also be specified using...
  - an inline value
  - the command line
  - a _var_ file
  - an environment variable ( TF_VAR_* )
  - a run-time query

^
```hcl
variable "password" {}                <-=  export TF_VAR_password=1234
 
variable "app-amis" {
  description = "Application AMIs based on AWS region"
  type = "map"
  default = {
    "ap-southeast-1" = "ami-0000000000000000"
    "ap-southeast-2" = "ami-0000000000000002"
  }
}
```

---

-> ## Interpolations <-

Allow you to refer to _variables_ and _attributes_ in other resources
similar to shell variable expansion

- General syntax is ` "${var.NAME}" `
- And you can interpolate (lookup) all sorts of material...
  - User strings        ` "${var.blob}"                          `
  - User maps           ` "${var.amis["ap-southeast-1"]}"        `
  - User lists          ` "${var.subnets[idx]}"                  `
  - Resource attributes ` "${scaleway_volume.app.id}"            `
  - Modules             ` "${module.vpc.id}                      `
  - Functions (70)      ` "${element(var.list_of_strings, 2)}"   `

^
Simple mathematical operations can be performed in interpolations.

- *+*, *-*, *\**, and */* for *float* types
- Plus *%* for *integer* types

Where...
` Name = "${var.resource_tag}-private-${format("%02d", count.index + 1)}" `

Becomes...
` Name = "demo-private-01" `

- You can use the Terraform *console* to experiment with interpolations

---

-> ## Provisioners <-

_Provisioners_ introduce a config-management-like feature, with the ability
to run scripts on local and remote machines as part of resource creation
or destruction.

^
```hcl
resource "aws_instance" "web" {
  # ...
  
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh args",
    ]
  }
}
```

---

-> ## Modules <-

- Allow for *better code organisation*
- They are simply *folders with Terraform files in them*
  Even if you don't have a module
  the directory you're in is considered the *root module*
- Following a standard structure
  allows support for the Terraform [Registry](https://registry.terraform.io).
  A public repository of modules written by the community 

^
Terraform does not impose any "hard-and-fast" rules for file naming
but the following is expected as the minimal set of files for a _module_:

- There should be a *main.tf*
- Put input variables in *variables.tf* 
- Put outputs in *outputs.tf*
- Add a *README.md*

A module's _input_ is its *variables*, its _output_ is its *outputs*

---

-> ## Loops and Conditionals <-

You often want to create dynamic configurations based on a variable's value.

- What if you want to create 10 instances of a server
- Optionally create some parts of your infrastructure

^
# Loops
Terraform provides a _built-in_ meta-parameter called *count*

```hcl
resource "aws_instance" "example" {
  count = 3
  ami = "ami-00000000"
  instance_type = "t2.micro"
  tags {
    Name = "example-${count.index}"
  }
}
```

^
# Conditionals
The conditional syntax is basically the ternary operator
*RESULT = CONDITION ? TRUEVAL : FALSEVAL*

...allowing you to enable or disable a resource by setting its _built-in_ *count*:

```hcl
resource "aws_instance" "vpn" {
  count = "${var.need_vpn ? 1 : 0}"
}
```

---

-> ## Data <-

- Collects read-only information from a *provider*
- So you can build on *real-time external information*
  AWS has about 120 different data sources

```hcl
data "aws_availability_zones" "available" {}
 
resource "aws_subnet" "primary" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}
```

^
...or use the *aws_ami* data to automatically select an AMI using filters:

```hcl
data "aws_ami" "demo" {
  most_recent = true
 
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
 
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }
}
```

---

-> ## Templating <-

# Problem
You want to be able to render the content of an external file
(possibly a configuration file for another tool like Ansible)
based on the state of your Terraform infrastructure,
i.e. an instance's IP address

^
# Solution
Start with a *\.tpl* file (i.e. *inventory.tpl*)...
```ini
[hosts]
${master}
```

^
Use *data.template_file* and *resource.local_file*
to read, replace and write the *\.tlp* file:

```hcl
data "template_file" "inventory" {
  template = "${file("${var.ansible_dir}/inventory.tpl")}"
 
  vars {
    master = "${aws_instance.master.0.private_ip}"
  }
}
 
resource "local_file" "inventory" {
  content = "${data.template_file.inventory.rendered}"
  filename = "${var.ansible_dir}/inventory"
}

```

---

-> ## Typical workflow <-

-  Terraform is a single command-line application: *terraform*
-  That takes a *sub-command* such as: -
    -  *init* / *get*
    -  *validate*
    -  *plan*
    -  *apply*
    -  *destroy*

Typical command sequence to build or change your infrastructure:

- terraform init
^
- terraform plan
^
- terraform apply

^
Then, if or when you want to delete the infrastructure:

- terraform destroy

---

-> ## State <-

- Terraform stores *state* in files, by default in the execution directory
- Although these are text files (JSON) they should be treated as though
  "no user-serviceable parts inside"
- When working with teams you need to worry about
  - *Remote storage*
  - *Locking*

^
# Remote Storage and Locking Options
- _Git_ / Revision Control ?
  - Just inviting *human error* as you either forget to pull or push
  - State files are text, so *secrets will be exposed*

^
- HashiCorp _Enterprise_ (£££)

^
- HashiCorp _Free_ Remote State Storage [Coming Soon](https://www.hashicorp.com/blog/terraform-collaboration-for-everyone)

^
- Amazon _S3_ and _DynamoDB_ (£)

^
```hcl
terraform {
  backend "s3" {
    region = "eu-central-1"
    bucket = "my-demo-terraform"
    key = "my-demo"
    dynamodb_table = "my-demo-terraform-lock"
  }
}
```

---

-> ## Demo 1 - GitLab Labels <-

The [GitLab Provider](https://www.terraform.io/docs/providers/gitlab/index.html) is a small provider
that can be used to manage projects, labels, groups and users.

Here's a short excerpt from the *demo-1* configuration that manages a label: -

```
variable "gitlab_token" {}
variable "gitlab_project" {}
  
provider "gitlab" {
  token = "${var.gitlab_token}"
}
 
resource "gitlab_label" "fixme" {
  project = "${var.gitlab_project}"
  name = "FixMe"
  description = "Issues that need to be fixed"
  color = "cadetblue"
}
```

- It expects (or will prompt you for) two variables
- These can be conveniently defined in *TF_VAR_* environment variables...
  - `TF_VAR_gitlab_token`
  - `TF_VAR_gitlab_project`

---

-> ## Demo 2 - AWS EC2 <-

Here we'll create a contrived example that consists of:

- A Virtual Private Cloud ( *module.vpc* ) that has a
  - With DNS hostname support
  - private subnet
  - public subnet
  - a NAT and VPN
- A t2.micro *aws_instance* instance with an IP on the public subnet
- A t2.micro *aws_instance* on the private subnet
- Two *aws_security_group* instances
  - for SSH
  - and outbound general
- A *data.aws_availability_zones* instance to collect all the region's zones
- A *data.aws_ami* instance to pick the latest Amazon Linux OS

All you need to provide are the variables:

- The AWS API access key ( *TF_VAR_aws_access_key* )
- The AWS API secret key ( *TF_VAR_aws_secret_key* )
- The AWS key-pair ( *TF_VAR_aws_key_name* )

---

-> ## Demo 2 - The AWS Private "aws_instance" <-

The private *aws_instance* definition of the AWS demo serves
as a good illustration of many of the topics we've just seen...
 
- Interpolation
- Data
- Variables
- Resource attributes
- Functions
- Modules

```hcl
resource "aws_instance" "private" {
  ami = "${data.aws_ami.demo_ami.image_id}"
  instance_type = "t2.micro"
  count = "${var.private_node_count}"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}"]
 
  subnet_id = "${module.vpc.private_subnets[0]}"
 
  tags {
    Name = "${var.resource_tag}-private-${format("%02d", count.index + 1)}"
  }
}
```

---

-> ## Is Terraform for yqou? <-

- There's now a large number of competitive tools like
  Ansible, Chef, Puppet, CloudFormation, SaltStack, Heat
  (and Terraform)
- They're all IaC but tackling the problem in different ways
- There is significant overlap
- The choice is not obvious

It probably comes down to personal priorities for a number of considerations:

- Provisioning / configuration
- Procedural / declarative
- Master / Masterless
- Agent / Agentless
- Maturity




[Chapter 1](https://www.oreilly.com/library/view/terraform-up-and/9781491977071/ch01.html) from *Terraform Up and Running* by Yevgeniy Brikman
explores the topic of "Why Terraform" well.

---

-> ## Closing thoughts <-

- Is not necessarily just a few lines of code
- Can be an expensive initial investment
- Terraform is just one of a number of tools

^
# The excuses not to automate...

^
- *It'll be quicker to create a README*

^
- *We're not going to do this again*

^
- *We don't have time, we're late on the customer's next feature*

^
[The 2016 State of DevOps Report](https://puppet.com/resources/whitepaper/2016-state-of-devops-report)...

...stated that high-performing organisations
(e.g. those that embrace DevOps and IaC practices)...

- Deploy                     *200 times more frequently*
- Have lead times that are *2,555 times shorter*
- Recover                     *24 times faster*

And... more importantly...

- Spend *29%* more time on new features 

---

-> *Thank you* <-


-> You can find the presentation material on GitHub <-
-> *https://github.com/InformaticsMatters/presentation.terraform.git* <-





-> ## Alan Christie <-
-> ## achristie@informaticsmatters.com <-

-> Informatics Matters Ltd. <-


-> Software Development - Cloud Native Applications <-
-> Automation - Scientific Workflows <-
