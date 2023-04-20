<h3> Overview </h3>
Welcome, the diagram for the code refactoring/repository I've setup is here below:

```
platform-interview
├── .github
├── .vagrant
├── docker-compose.yml
├── run.sh
├── Vagrantfile
├── README.md
├── services
    └── account
    └── payment
    └── gateway
├── tf
   ├── environments
   │   ├── development
   │   ├── staging
   │   ├── production
   │   │   ├── config.tf
   │   │   ├── main.tf
   │   │   ├── outputs.tf
   │   │   └── variables.tf
   └── modules
       ├── account
       │   ├── main.tf
       │   ├── outputs.tf
       │   └── variables.tf
       ├── gateway
       ├── payment
       ├── vault
```

At the heart of this design, we separate the environments & repeatable infrastructure (`modules`).
Everything that is repeatable across environments is refactored from `main.tf` into `modules` - one each for:
 - vault
 - account
 - payment
 - gateway
 - frontend

Everything for a specific environment (`development`, `staging` or `production`) is defined in the environments sub-directory.

Using this design, before we discuss specifics, it's super easy to deploy all components for a specific environment:
```
# Deploy to development
$ cd tf/environments/development
$ terraform init
$ terraform apply

# Deploy to production
$ cd tf/environments/production
$ terraform init
$ terraform apply
```

<h3> Design Choices: </h3>


1. Anything that gets used in more than one environment is refactored into modules (DRY)

2. Anything that is different between environments is exposed as an input variable.

3. Configuration driven approach (json file maintaining environment/variables) and conditional logic based on this is <h5> NOT </h5> used because:
    - Terraform is declarative, and this approach does not lead to maintainability with infrastructure code (more suited to application code)
    - Using modules for each allows us to have a direct 1:1 between terraform state and code (terraform best practice)


4. Every environment has 4 files:

    - `config.tf` for defines the providers (& backend if required), and removes this from `main.tf` keeping `main.tf` cleaner.
    - `main.tf` for each simply imports the modules & its underlying resources, some have inter-module dependency. `main.tf` also defines the configuration variables (modules input variables) that differs for each environment.
    - `outputs.tf` makes it easy for resources deployed to be consumed by other modules/parent modules etc
    - `variables.tf` defines each environment's input variables, provider config inputs and anything that is used in more than one place in `main.tf`.

5. Every module has 3 files:
    - `main.tf` Defines required providers & its underlying resources
    - `outputs.tf` makes it easy for resources of a module to be consumed by other modules/parent modules etc
    - `variables.tf` defines each modules's input variables with defaults, description etc.

With this design, adding/deleting services or environments is simple, de-coupled, and this design scales well.


I haven't used any `terragrunt` or other workspace configuration.
[X] If you are new to Terraform let us know.


<h3> How your code would fit into a CI/CD pipeline? </h3>

In production, instantiating a module like above & setting up input/output variables, providers, and remote state is still challenging.

- So, in a production CI/CD pipeline, each module get's its separate version control/Git repository. This allows different versions of services be deployed to different environments easily, using a release tag for each module.

- Terragrunt can be used with an `.hcl` configuration file, importing the source terraform module & passing it input parameters as `inputs`.

- Gitlab Pipelines/ArgoCD/Flux can be used to automatically build & deploy version control artifacts upon any commits/merges to the `master`.

- CI/CD pipelines should run  `terraform fmt` and `terraform validate` automatically.


<h3> Anything beyond the scope of this task that you would consider when running this code in a real production environment? </h3>

- All credentials (sensitive) should be stored in a Secret store (AWS SSM, Hashicorp Vault, Azure Key Vault etc) and NOT in version control like here (`db_passwords`, `vault_tokens` etc.) and access to the credentials be protected using Role based access control. 

- All code changes should be version controlled, and automated using CI/CD, and NO manual changes should be used to modify/deploy any infrastructure (state is immutable)

- Terraform `.state` is critical, and it should be version controlled & saved in a remote backend so that it doesn't get lost/corrupted.
  The remote backend should support state locking so that multiple people can concurrently use it without conflicts.

- The states should be backed up (for recovery) & support versioning for rollbacks.

- Import all pre-existing infrastructure (if any) to maintain an accurate state representation.

- Get values that can be provided directly via data sources (AWS account Ids, Availability zones etc) from data sources instead of maintaining variables ourselves. 

- I'd always use `terraform fmt` and `terraform validate` to make sure that code is formatted properly and all issues are caught.

- Use a terraform linter such as `tflint`.