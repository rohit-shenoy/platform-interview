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

Design Choices:
---------------

1. Anything that gets used in more than one environment is refactored into modules (DRY)

2. Anything that is different between environments is exposed as an input variable.

3. Configuration driven approach (json file maintaining environment/variables) and conditional logic based on this is <h5> NOT </h5> used because:
    - Terraform is declarative, and this approach does not lead to maintainability with infrastructure code (more suited to application code)
    - Using modules for each allows us to have a direct 1:1 between terraform state and code (terraform best practice)


4. Every environment has 4 files:

    a. `config.tf` for defines the providers (& backend if required), and removes this from `main.tf` keeping `main.tf` cleaner.
    b. `main.tf` for each simply imports the modules & its underlying resources, some have inter-module dependency. `main.tf` also defines the configuration variables (modules input variables) that differs for each environment.
    c. `outputs.tf` makes it easy for resources deployed to be consumed by other modules/parent modules etc
    d. `variables.tf` defines each environment's input variables, provider config inputs and anything that is used in more than one place in `main.tf`.

5. Every module has 3 files:
    a. `main.tf` Defines required providers & its underlying resources
    b. `outputs.tf` makes it easy for resources of a module to be consumed by other modules/parent modules etc
    c. `variables.tf` defines each modules's input variables with defaults, description etc.


I haven't used any `terragrunt` or other workspace configuration.
[X] If you are new to Terraform let us know.

------------------
How your code would fit into a CI/CD pipeline?

In production, instantiating a module like above & setting up input/output variables, providers, and remote state is still challenging.

- So, in a production CI/CD pipeline, each module get's its separate version control/Git repository. This allows different versions of services be deployed to different environments easily, using a release tag for each module.

- Terragrunt can be used with an `.hcl` configuration file, importing the source terraform module & passing it input parameters as `inputs`.

- Gitlab Pipelines/ArgoCD/Flux can be used to automatically build & deploy version control artifacts upon any commits/merges to the `master`.

- CI/CD pipelines should run  `terraform fmt` and `terraform validate` automatically.


Anything beyond the scope of this task that you would consider when running this code in a real production environment?
-------------------
- All credentials (sensitive) should be stored in a Secret store (AWS SSM, Hashicorp Vault, Azure Key Vault etc) and NOT in version control like here (`db_passwords`, `vault_tokens` etc.) and access to the credentials be protected using Role based access control. 

- All code changes should be version controlled, and automated using CI/CD, and NO manual changes should be used to modify/deploy any infrastructure (state is immutable)

- Terraform `.state` is critical, and it should be version controlled & saved in a remote backend so that it doesn't get lost/corrupted.
  The remote backend should support state locking so that multiple people can concurrently use it without conflicts.

- The states should be backed up (for recovery) & support versioning for rollbacks.

- Import all pre-existing infrastructure (if any) to maintain an accurate state representation.

- Get values that can be provided directly via data sources (AWS account Ids, Availability zones etc) from data sources instead of maintaining variables ourselves. 

- I'd always use `terraform fmt` and `terraform validate` to make sure that code is formatted properly and all issues are caught.

- Use a terraform linter such as `tflint`.


Output:
------------------
rohit.shenoy@TD-T3Y06QQGQ7 development % vagrant up 
Bringing machine 'interview' up with 'multipass' provider...
==> interview: VM already created.
==> interview: Setting hostname...
==> interview: Rsyncing folder: /Users/rohit.shenoy/learning/platform-interview/ => /vagrant
==> interview:   - Exclude: [".vagrant/", ".git/"]
==> interview: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> interview: flag to force provisioning. Provisioners marked to run always will still run.
==> interview: Running provisioner: shell...
    interview: Running: inline script
    interview: mv: cannot stat '/tmp/form3.crt': No such file or directory
    interview: Updating certificates in /etc/ssl/certs...
    interview: 0 added, 0 removed; done.
    interview: Running hooks in /etc/ca-certificates/update.d...
    interview: done.
==> interview: Running provisioner: shell...
    interview: Running: /var/folders/m0/68bvnpw52gn0r450qcmxnztr0000gp/T/vagrant-shell20230419-23993-oyd5d4.sh
    interview: Installing docker-compose
    interview:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    interview:                                  Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 23.1M  100 23.1M    0     0  9562k      0  0:00:02  0:00:02 --:--:-- 11.0M
    interview: Installing terraform onto machine...
    interview: Hit:1 http://ports.ubuntu.com/ubuntu-ports bionic InRelease
    interview: Hit:2 http://ports.ubuntu.com/ubuntu-ports bionic-updates InRelease
    interview: Hit:3 http://ports.ubuntu.com/ubuntu-ports bionic-backports InRelease
    interview: Hit:4 http://ports.ubuntu.com/ubuntu-ports bionic-security InRelease
    interview: Hit:5 https://download.docker.com/linux/ubuntu bionic InRelease
    interview: Reading package lists...
    interview: Reading package lists...
    interview: Building dependency tree...
    interview: Reading state information...
    interview: jq is already the newest version (1.5+dfsg-2).
    interview: unzip is already the newest version (6.0-21ubuntu1.2).
    interview: 0 upgraded, 0 newly installed, 0 to remove and 19 not upgraded.
    interview: ~/bin ~
    interview: ~
    interview: /vagrant ~
    interview: #1 [internal] load build definition from Dockerfile
    interview: #1 transferring dockerfile: 290B done
    interview: #1 DONE 0.0s
    interview: 
    interview: #2 [internal] load .dockerignore
    interview: #2 transferring context: 2B done
    interview: #2 DONE 0.0s
    interview: 
    interview: #3 [internal] load metadata for docker.io/library/golang:alpine
    interview: #3 DONE 1.0s
    interview: 
    interview: #4 [builder 1/4] FROM docker.io/library/golang:alpine@sha256:08e9c086194875334d606765bd60aa064abd3c215abfbcf5737619110d48d114
    interview: #4 DONE 0.0s
    interview: 
    interview: #5 [internal] load build context
    interview: #5 transferring context: 24.22kB 0.0s done
    interview: #5 DONE 0.0s
    interview: 
    interview: #6 [builder 4/4] RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /go/bin/account
    interview: #6 CACHED
    interview: 
    interview: #7 [builder 2/4] WORKDIR /go/src/form3tech/account/
    interview: #7 CACHED
    interview: 
    interview: #8 [builder 3/4] COPY . .
    interview: #8 CACHED
    interview: 
    interview: #9 [stage-1 1/1] COPY --from=builder /go/bin/account /go/bin/account
    interview: #9 CACHED
    interview: 
    interview: #10 exporting to image
    interview: #10 exporting layers done
    interview: #10 writing image sha256:0a2a86e68d2ad0181be2d53b3ac5aaa42ac8aea15e5025d36da5ac4111997e38 done
    interview: #10 naming to docker.io/form3tech-oss/platformtest-account done
    interview: #10 DONE 0.0s
    interview: #1 [internal] load build definition from Dockerfile
    interview: #1 transferring dockerfile: 290B done
    interview: #1 DONE 0.0s
    interview: 
    interview: #2 [internal] load .dockerignore
    interview: #2 transferring context: 2B done
    interview: #2 DONE 0.0s
    interview: 
    interview: #3 [internal] load metadata for docker.io/library/golang:alpine
    interview: #3 DONE 0.2s
    interview: 
    interview: #4 [builder 1/4] FROM docker.io/library/golang:alpine@sha256:08e9c086194875334d606765bd60aa064abd3c215abfbcf5737619110d48d114
    interview: #4 DONE 0.0s
    interview: 
    interview: #5 [internal] load build context
    interview: #5 transferring context: 24.22kB 0.0s done
    interview: #5 DONE 0.0s
    interview: 
    interview: #6 [builder 2/4] WORKDIR /go/src/form3tech/gateway/
    interview: #6 CACHED
    interview: 
    interview: #7 [builder 3/4] COPY . .
    interview: #7 CACHED
    interview: 
    interview: #8 [builder 4/4] RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /go/bin/gateway
    interview: #8 CACHED
    interview: 
    interview: #9 [stage-1 1/1] COPY --from=builder /go/bin/gateway /go/bin/gateway
    interview: #9 CACHED
    interview: 
    interview: #10 exporting to image
    interview: #10 exporting layers done
    interview: #10 writing image sha256:dc0473613b06330a6930afaf5ed60005df3fbc42aa76bcdf647804a4e916fe53 done
    interview: #10 naming to docker.io/form3tech-oss/platformtest-gateway done
    interview: #10 DONE 0.0s
    interview: #1 [internal] load build definition from Dockerfile
    interview: #1 transferring dockerfile: 290B done
    interview: #1 DONE 0.0s
    interview: 
    interview: #2 [internal] load .dockerignore
    interview: #2 transferring context: 2B done
    interview: #2 DONE 0.0s
    interview: 
    interview: #3 [internal] load metadata for docker.io/library/golang:alpine
    interview: #3 DONE 0.2s
    interview: 
    interview: #4 [builder 1/4] FROM docker.io/library/golang:alpine@sha256:08e9c086194875334d606765bd60aa064abd3c215abfbcf5737619110d48d114
    interview: #4 DONE 0.0s
    interview: 
    interview: #5 [internal] load build context
    interview: #5 transferring context: 24.22kB 0.0s done
    interview: #5 DONE 0.0s
    interview: 
    interview: #6 [builder 2/4] WORKDIR /go/src/form3tech/payment/
    interview: #6 CACHED
    interview: 
    interview: #7 [builder 3/4] COPY . .
    interview: #7 CACHED
    interview: 
    interview: #8 [builder 4/4] RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /go/bin/payment
    interview: #8 CACHED
    interview: 
    interview: #9 [stage-1 1/1] COPY --from=builder /go/bin/payment /go/bin/payment
    interview: #9 CACHED
    interview: 
    interview: #10 exporting to image
    interview: #10 exporting layers done
    interview: #10 writing image sha256:58d1f773eac27a1e1045c713005c859b62b15a76590c4d794e2158915ea49f71 done
    interview: #10 naming to docker.io/form3tech-oss/platformtest-payment done
    interview: #10 DONE 0.0s
    interview: Container vagrant-vault-staging-1  Creating
    interview: Container vagrant-vault-development-1  Creating
    interview: Container vagrant-vault-production-1  Creating
    interview: Container vagrant-vault-development-1  Created
    interview: Container vagrant-vault-production-1  Created
    interview: Container vagrant-vault-staging-1  Created
    interview: Container vagrant-vault-production-1  Starting
    interview: Container vagrant-vault-development-1  Starting
    interview: Container vagrant-vault-staging-1  Starting
    interview: Container vagrant-vault-staging-1  Started
    interview: Container vagrant-vault-production-1  Started
    interview: ~
    interview: Applying terraform script
    interview: /vagrant/tf/environments/development ~
    interview: Container vagrant-vault-development-1  Started
    interview: Upgrading modules...
    interview: - account in ../../modules/account
    interview: - frontend in ../../modules/frontend
    interview: - gateway in ../../modules/gateway
    interview: - payment in ../../modules/payment
    interview: - vault in ../../modules/vault
    interview: 
    interview: Initializing the backend...
    interview: 
    interview: Initializing provider plugins...
    interview: - Finding hashicorp/vault versions matching "3.0.1"...
    interview: - Finding kreuzwerker/docker versions matching "2.15.0"...
    interview: - Installing hashicorp/vault v3.0.1...
    interview: - Installed hashicorp/vault v3.0.1 (signed by HashiCorp)
    interview: - Installing kreuzwerker/docker v2.15.0...
    interview: - Installed kreuzwerker/docker v2.15.0 (self-signed, key ID BD080C4571C6104C)
    interview: 
    interview: Partner and community providers are signed by their developers.
    interview: If you'd like to know more about provider signing, you can read about it here:
    interview: https://www.terraform.io/docs/cli/plugins/signing.html
    interview: 
    interview: Terraform has created a lock file .terraform.lock.hcl to record the provider
    interview: selections it made above. Include this file in your version control repository
    interview: so that Terraform can guarantee to make the same selections by default when
    interview: you run "terraform init" in the future.
    interview: 
    interview: Terraform has been successfully initialized!
    interview: 
    interview: You may now begin working with Terraform. Try running "terraform plan" to see
    interview: any changes that are required for your infrastructure. All Terraform commands
    interview: should now work.
    interview: 
    interview: If you ever set or change modules or backend configuration for Terraform,
    interview: rerun this command to reinitialize your working directory. If you forget, other
    interview: commands will detect it and remind you to do so if necessary.
    interview: 
    interview: Terraform used the selected providers to generate the following execution
    interview: plan. Resource actions are indicated with the following symbols:
    interview:   + create
    interview: 
    interview: Terraform will perform the following actions:
    interview: 
    interview:   # module.account.docker_container.account_container will be created
    interview:   + resource "docker_container" "account_container" {
    interview:       + attach           = false
    interview:       + bridge           = (known after apply)
    interview:       + command          = (known after apply)
    interview:       + container_logs   = (known after apply)
    interview:       + entrypoint       = (known after apply)
    interview:       + env              = [
    interview:           + "ENVIRONMENT=development",
    interview:           + "VAULT_ADDR=http://vault-development:8200",
    interview:           + "VAULT_PASSWORD=123-account-development",
    interview:           + "VAULT_USERNAME=account-development",
    interview:         ]
    interview:       + exit_code        = (known after apply)
    interview:       + gateway          = (known after apply)
    interview:       + hostname         = (known after apply)
    interview:       + id               = (known after apply)
    interview:       + image            = "form3tech-oss/platformtest-account"
    interview:       + init             = (known after apply)
    interview:       + ip_address       = (known after apply)
    interview:       + ip_prefix_length = (known after apply)
    interview:       + ipc_mode         = (known after apply)
    interview:       + log_driver       = "json-file"
    interview:       + logs             = false
    interview:       + must_run         = true
    interview:       + name             = "account_development"
    interview:       + network_data     = (known after apply)
    interview:       + read_only        = false
    interview:       + remove_volumes   = true
    interview:       + restart          = "no"
    interview:       + rm               = false
    interview:       + security_opts    = (known after apply)
    interview:       + shm_size         = (known after apply)
    interview:       + start            = true
    interview:       + stdin_open       = false
    interview:       + tty              = false
    interview: 
    interview:       + healthcheck {
    interview:           + interval     = (known after apply)
    interview:           + retries      = (known after apply)
    interview:           + start_period = (known after apply)
    interview:           + test         = (known after apply)
    interview:           + timeout      = (known after apply)
    interview:         }
    interview: 
    interview:       + labels {
    interview:           + label = (known after apply)
    interview:           + value = (known after apply)
    interview:         }
    interview: 
    interview:       + networks_advanced {
    interview:           + aliases = []
    interview:           + name    = "vagrant_development"
    interview:         }
    interview:     }
    interview: 
    interview:   # module.account.vault_generic_endpoint.account_endpoint will be created
    interview:   + resource "vault_generic_endpoint" "account_endpoint" {
    interview:       + data_json            = (sensitive value)
    interview:       + disable_delete       = false
    interview:       + disable_read         = false
    interview:       + id                   = (known after apply)
    interview:       + ignore_absent_fields = true
    interview:       + path                 = "auth/userpass/users/account-development"
    interview:       + write_data           = (known after apply)
    interview:       + write_data_json      = (known after apply)
    interview:     }
    interview: 
    interview:   # module.account.vault_generic_secret.account_secret will be created
    interview:   + resource "vault_generic_secret" "account_secret" {
    interview:       + data         = (sensitive value)
    interview:       + data_json    = (sensitive value)
    interview:       + disable_read = false
    interview:       + id           = (known after apply)
    interview:       + path         = "secret/development/account"
    interview:     }
    interview: 
    interview:   # module.account.vault_policy.account_policy will be created
    interview:   + resource "vault_policy" "account_policy" {
    interview:       + id     = (known after apply)
    interview:       + name   = "account-development"
    interview:       + policy = <<-EOT
    interview: 
    interview:             path "secret/data/development/account" {
    interview:                 capabilities = ["list", "read"]
    interview:             }
    interview: 
    interview:         EOT
    interview:     }
    interview: 
    interview:   # module.frontend.docker_container.frontend will be created
    interview:   + resource "docker_container" "frontend" {
    interview:       + attach           = false
    interview:       + bridge           = (known after apply)
    interview:       + command          = (known after apply)
    interview:       + container_logs   = (known after apply)
    interview:       + entrypoint       = (known after apply)
    interview:       + env              = (known after apply)
    interview:       + exit_code        = (known after apply)
    interview:       + gateway          = (known after apply)
    interview:       + hostname         = (known after apply)
    interview:       + id               = (known after apply)
    interview:       + image            = "docker.io/nginx:latest"
    interview:       + init             = (known after apply)
    interview:       + ip_address       = (known after apply)
    interview:       + ip_prefix_length = (known after apply)
    interview:       + ipc_mode         = (known after apply)
    interview:       + log_driver       = "json-file"
    interview:       + logs             = false
    interview:       + must_run         = true
    interview:       + name             = "frontend_development"
    interview:       + network_data     = (known after apply)
    interview:       + read_only        = false
    interview:       + remove_volumes   = true
    interview:       + restart          = "no"
    interview:       + rm               = false
    interview:       + security_opts    = (known after apply)
    interview:       + shm_size         = (known after apply)
    interview:       + start            = true
    interview:       + stdin_open       = false
    interview:       + tty              = false
    interview: 
    interview:       + healthcheck {
    interview:           + interval     = (known after apply)
    interview:           + retries      = (known after apply)
    interview:           + start_period = (known after apply)
    interview:           + test         = (known after apply)
    interview:           + timeout      = (known after apply)
    interview:         }
    interview: 
    interview:       + labels {
    interview:           + label = (known after apply)
    interview:           + value = (known after apply)
    interview:         }
    interview: 
    interview:       + networks_advanced {
    interview:           + aliases = []
    interview:           + name    = "vagrant_development"
    interview:         }
    interview: 
    interview:       + ports {
    interview:           + external = 4080
    interview:           + internal = 80
    interview:           + ip       = "0.0.0.0"
    interview:           + protocol = "tcp"
    interview:         }
    interview:     }
    interview: 
    interview:   # module.gateway.docker_container.gateway_container will be created
    interview:   + resource "docker_container" "gateway_container" {
    interview:       + attach           = false
    interview:       + bridge           = (known after apply)
    interview:       + command          = (known after apply)
    interview:       + container_logs   = (known after apply)
    interview:       + entrypoint       = (known after apply)
    interview:       + env              = [
    interview:           + "ENVIRONMENT=development",
    interview:           + "VAULT_ADDR=http://vault-development:8200",
    interview:           + "VAULT_PASSWORD=123-gateway-development",
    interview:           + "VAULT_USERNAME=gateway-development",
    interview:         ]
    interview:       + exit_code        = (known after apply)
    interview:       + gateway          = (known after apply)
    interview:       + hostname         = (known after apply)
    interview:       + id               = (known after apply)
    interview:       + image            = "form3tech-oss/platformtest-gateway"
    interview:       + init             = (known after apply)
    interview:       + ip_address       = (known after apply)
    interview:       + ip_prefix_length = (known after apply)
    interview:       + ipc_mode         = (known after apply)
    interview:       + log_driver       = "json-file"
    interview:       + logs             = false
    interview:       + must_run         = true
    interview:       + name             = "gateway_development"
    interview:       + network_data     = (known after apply)
    interview:       + read_only        = false
    interview:       + remove_volumes   = true
    interview:       + restart          = "no"
    interview:       + rm               = false
    interview:       + security_opts    = (known after apply)
    interview:       + shm_size         = (known after apply)
    interview:       + start            = true
    interview:       + stdin_open       = false
    interview:       + tty              = false
    interview: 
    interview:       + healthcheck {
    interview:           + interval     = (known after apply)
    interview:           + retries      = (known after apply)
    interview:           + start_period = (known after apply)
    interview:           + test         = (known after apply)
    interview:           + timeout      = (known after apply)
    interview:         }
    interview: 
    interview:       + labels {
    interview:           + label = (known after apply)
    interview:           + value = (known after apply)
    interview:         }
    interview: 
    interview:       + networks_advanced {
    interview:           + aliases = []
    interview:           + name    = "vagrant_development"
    interview:         }
    interview:     }
    interview: 
    interview:   # module.gateway.vault_generic_endpoint.gateway_endpoint will be created
    interview:   + resource "vault_generic_endpoint" "gateway_endpoint" {
    interview:       + data_json            = (sensitive value)
    interview:       + disable_delete       = false
    interview:       + disable_read         = false
    interview:       + id                   = (known after apply)
    interview:       + ignore_absent_fields = true
    interview:       + path                 = "auth/userpass/users/gateway-development"
    interview:       + write_data           = (known after apply)
    interview:       + write_data_json      = (known after apply)
    interview:     }
    interview: 
    interview:   # module.gateway.vault_generic_secret.gateway_secret will be created
    interview:   + resource "vault_generic_secret" "gateway_secret" {
    interview:       + data         = (sensitive value)
    interview:       + data_json    = (sensitive value)
    interview:       + disable_read = false
    interview:       + id           = (known after apply)
    interview:       + path         = "secret/development/gateway"
    interview:     }
    interview: 
    interview:   # module.gateway.vault_policy.gateway_policy will be created
    interview:   + resource "vault_policy" "gateway_policy" {
    interview:       + id     = (known after apply)
    interview:       + name   = "gateway-development"
    interview:       + policy = <<-EOT
    interview: 
    interview:             path "secret/data/development/gateway" {
    interview:                 capabilities = ["list", "read"]
    interview:             }
    interview: 
    interview:         EOT
    interview:     }
    interview: 
    interview:   # module.payment.docker_container.payment_container will be created
    interview:   + resource "docker_container" "payment_container" {
    interview:       + attach           = false
    interview:       + bridge           = (known after apply)
    interview:       + command          = (known after apply)
    interview:       + container_logs   = (known after apply)
    interview:       + entrypoint       = (known after apply)
    interview:       + env              = [
    interview:           + "ENVIRONMENT=development",
    interview:           + "VAULT_ADDR=http://vault-development:8200",
    interview:           + "VAULT_PASSWORD=123-payment-development",
    interview:           + "VAULT_USERNAME=payment-development",
    interview:         ]
    interview:       + exit_code        = (known after apply)
    interview:       + gateway          = (known after apply)
    interview:       + hostname         = (known after apply)
    interview:       + id               = (known after apply)
    interview:       + image            = "form3tech-oss/platformtest-payment"
    interview:       + init             = (known after apply)
    interview:       + ip_address       = (known after apply)
    interview:       + ip_prefix_length = (known after apply)
    interview:       + ipc_mode         = (known after apply)
    interview:       + log_driver       = "json-file"
    interview:       + logs             = false
    interview:       + must_run         = true
    interview:       + name             = "payment_development"
    interview:       + network_data     = (known after apply)
    interview:       + read_only        = false
    interview:       + remove_volumes   = true
    interview:       + restart          = "no"
    interview:       + rm               = false
    interview:       + security_opts    = (known after apply)
    interview:       + shm_size         = (known after apply)
    interview:       + start            = true
    interview:       + stdin_open       = false
    interview:       + tty              = false
    interview: 
    interview:       + healthcheck {
    interview:           + interval     = (known after apply)
    interview:           + retries      = (known after apply)
    interview:           + start_period = (known after apply)
    interview:           + test         = (known after apply)
    interview:           + timeout      = (known after apply)
    interview:         }
    interview: 
    interview:       + labels {
    interview:           + label = (known after apply)
    interview:           + value = (known after apply)
    interview:         }
    interview: 
    interview:       + networks_advanced {
    interview:           + aliases = []
    interview:           + name    = "vagrant_development"
    interview:         }
    interview:     }
    interview: 
    interview:   # module.payment.vault_generic_endpoint.payment_endpoint will be created
    interview:   + resource "vault_generic_endpoint" "payment_endpoint" {
    interview:       + data_json            = (sensitive value)
    interview:       + disable_delete       = false
    interview:       + disable_read         = false
    interview:       + id                   = (known after apply)
    interview:       + ignore_absent_fields = true
    interview:       + path                 = "auth/userpass/users/payment-development"
    interview:       + write_data           = (known after apply)
    interview:       + write_data_json      = (known after apply)
    interview:     }
    interview: 
    interview:   # module.payment.vault_generic_secret.payment_secret will be created
    interview:   + resource "vault_generic_secret" "payment_secret" {
    interview:       + data         = (sensitive value)
    interview:       + data_json    = (sensitive value)
    interview:       + disable_read = false
    interview:       + id           = (known after apply)
    interview:       + path         = "secret/development/payment"
    interview:     }
    interview: 
    interview:   # module.payment.vault_policy.payment_policy will be created
    interview:   + resource "vault_policy" "payment_policy" {
    interview:       + id     = (known after apply)
    interview:       + name   = "payment-development"
    interview:       + policy = <<-EOT
    interview: 
    interview:             path "secret/data/development/payment" {
    interview:                 capabilities = ["list", "read"]
    interview:             }
    interview: 
    interview:         EOT
    interview:     }
    interview: 
    interview:   # module.vault.vault_audit.audit will be created
    interview:   + resource "vault_audit" "audit" {
    interview:       + id      = (known after apply)
    interview:       + options = {
    interview:           + "file_path" = "/vault/logs/audit"
    interview:         }
    interview:       + path    = (known after apply)
    interview:       + type    = "file"
    interview:     }
    interview: 
    interview:   # module.vault.vault_auth_backend.userpass will be created
    interview:   + resource "vault_auth_backend" "userpass" {
    interview:       + accessor = (known after apply)
    interview:       + id       = (known after apply)
    interview:       + path     = (known after apply)
    interview:       + tune     = (known after apply)
    interview:       + type     = "userpass"
    interview:     }
    interview: 
    interview: Plan: 15 to add, 0 to change, 0 to destroy.
    interview: module.frontend.docker_container.frontend: Creating...
    interview: module.vault.vault_auth_backend.userpass: Creating...
    interview: module.vault.vault_audit.audit: Creating...
    interview: module.vault.vault_audit.audit: Creation complete after 0s [id=file]
    interview: module.vault.vault_auth_backend.userpass: Creation complete after 0s [id=userpass]
    interview: module.account.docker_container.account_container: Creating...
    interview: module.account.vault_generic_endpoint.account_endpoint: Creating...
    interview: module.payment.docker_container.payment_container: Creating...
    interview: module.account.vault_policy.account_policy: Creating...
    interview: module.account.vault_generic_secret.account_secret: Creating...
    interview: module.payment.vault_policy.payment_policy: Creating...
    interview: module.gateway.vault_generic_secret.gateway_secret: Creating...
    interview: module.gateway.vault_policy.gateway_policy: Creating...
    interview: module.gateway.vault_generic_endpoint.gateway_endpoint: Creating...
    interview: module.gateway.vault_policy.gateway_policy: Creation complete after 0s [id=gateway-development]
    interview: module.gateway.docker_container.gateway_container: Creating...
    interview: module.payment.vault_policy.payment_policy: Creation complete after 0s [id=payment-development]
    interview: module.account.vault_policy.account_policy: Creation complete after 0s [id=account-development]
    interview: module.payment.vault_generic_endpoint.payment_endpoint: Creating...
    interview: module.payment.vault_generic_secret.payment_secret: Creating...
    interview: module.gateway.vault_generic_secret.gateway_secret: Creation complete after 0s [id=secret/development/gateway]
    interview: module.account.vault_generic_secret.account_secret: Creation complete after 0s [id=secret/development/account]
    interview: module.payment.vault_generic_secret.payment_secret: Creation complete after 0s [id=secret/development/payment]
    interview: module.account.vault_generic_endpoint.account_endpoint: Creation complete after 0s [id=auth/userpass/users/account-development]
    interview: module.gateway.vault_generic_endpoint.gateway_endpoint: Creation complete after 0s [id=auth/userpass/users/gateway-development]
    interview: module.payment.vault_generic_endpoint.payment_endpoint: Creation complete after 0s [id=auth/userpass/users/payment-development]
    interview: module.frontend.docker_container.frontend: Creation complete after 0s [id=916e41c9f29e88e37347d081acb95a8684cc286f05589d0c8ce3ae84f45f68c5]
    interview: module.account.docker_container.account_container: Creation complete after 1s [id=79cbe0542941fb5a2824a3d45e9f54da843bdd1162fc7cccd4f620421b2b125d]
    interview: module.gateway.docker_container.gateway_container: Creation complete after 1s [id=fe2fecc481d27b28c731fbb1298730b0487d1198f7557d55feb726f42f95c433]
    interview: module.payment.docker_container.payment_container: Creation complete after 1s [id=f5793e8c1d04a63cd705e8447e4e20ab037e435a4ed7bec72fe0f0dce917302d]
    interview: 
    interview: Apply complete! Resources: 15 added, 0 changed, 0 destroyed.
    interview: ~
    interview: /vagrant/tf/environments/production ~
    interview: Upgrading modules...
    interview: - account in ../../modules/account
    interview: - frontend in ../../modules/frontend
    interview: - gateway in ../../modules/gateway
    interview: - payment in ../../modules/payment
    interview: - vault in ../../modules/vault
    interview: 
    interview: Initializing the backend...
    interview: 
    interview: Initializing provider plugins...
    interview: - Finding kreuzwerker/docker versions matching "2.15.0"...
    interview: - Finding hashicorp/vault versions matching "3.0.1"...
    interview: - Installing kreuzwerker/docker v2.15.0...
    interview: - Installed kreuzwerker/docker v2.15.0 (self-signed, key ID BD080C4571C6104C)
    interview: - Installing hashicorp/vault v3.0.1...
    interview: - Installed hashicorp/vault v3.0.1 (signed by HashiCorp)
    interview: 
    interview: Partner and community providers are signed by their developers.
    interview: If you'd like to know more about provider signing, you can read about it here:
    interview: https://www.terraform.io/docs/cli/plugins/signing.html
    interview: 
    interview: Terraform has created a lock file .terraform.lock.hcl to record the provider
    interview: selections it made above. Include this file in your version control repository
    interview: so that Terraform can guarantee to make the same selections by default when
    interview: you run "terraform init" in the future.
    interview: 
    interview: Terraform has been successfully initialized!
    interview: 
    interview: You may now begin working with Terraform. Try running "terraform plan" to see
    interview: any changes that are required for your infrastructure. All Terraform commands
    interview: should now work.
    interview: 
    interview: If you ever set or change modules or backend configuration for Terraform,
    interview: rerun this command to reinitialize your working directory. If you forget, other
    interview: commands will detect it and remind you to do so if necessary.
    interview: 
    interview: Terraform used the selected providers to generate the following execution
    interview: plan. Resource actions are indicated with the following symbols:
    interview:   + create
    interview: 
    interview: Terraform will perform the following actions:
    interview: 
    interview:   # module.account.docker_container.account_container will be created
    interview:   + resource "docker_container" "account_container" {
    interview:       + attach           = false
    interview:       + bridge           = (known after apply)
    interview:       + command          = (known after apply)
    interview:       + container_logs   = (known after apply)
    interview:       + entrypoint       = (known after apply)
    interview:       + env              = [
    interview:           + "ENVIRONMENT=production",
    interview:           + "VAULT_ADDR=http://vault-production:8200",
    interview:           + "VAULT_PASSWORD=123-account-production",
    interview:           + "VAULT_USERNAME=account-production",
    interview:         ]
    interview:       + exit_code        = (known after apply)
    interview:       + gateway          = (known after apply)
    interview:       + hostname         = (known after apply)
    interview:       + id               = (known after apply)
    interview:       + image            = "form3tech-oss/platformtest-account"
    interview:       + init             = (known after apply)
    interview:       + ip_address       = (known after apply)
    interview:       + ip_prefix_length = (known after apply)
    interview:       + ipc_mode         = (known after apply)
    interview:       + log_driver       = "json-file"
    interview:       + logs             = false
    interview:       + must_run         = true
    interview:       + name             = "account_production"
    interview:       + network_data     = (known after apply)
    interview:       + read_only        = false
    interview:       + remove_volumes   = true
    interview:       + restart          = "no"
    interview:       + rm               = false
    interview:       + security_opts    = (known after apply)
    interview:       + shm_size         = (known after apply)
    interview:       + start            = true
    interview:       + stdin_open       = false
    interview:       + tty              = false
    interview: 
    interview:       + healthcheck {
    interview:           + interval     = (known after apply)
    interview:           + retries      = (known after apply)
    interview:           + start_period = (known after apply)
    interview:           + test         = (known after apply)
    interview:           + timeout      = (known after apply)
    interview:         }
    interview: 
    interview:       + labels {
    interview:           + label = (known after apply)
    interview:           + value = (known after apply)
    interview:         }
    interview: 
    interview:       + networks_advanced {
    interview:           + aliases = []
    interview:           + name    = "vagrant_production"
    interview:         }
    interview:     }
    interview: 
    interview:   # module.account.vault_generic_endpoint.account_endpoint will be created
    interview:   + resource "vault_generic_endpoint" "account_endpoint" {
    interview:       + data_json            = (sensitive value)
    interview:       + disable_delete       = false
    interview:       + disable_read         = false
    interview:       + id                   = (known after apply)
    interview:       + ignore_absent_fields = true
    interview:       + path                 = "auth/userpass/users/account-production"
    interview:       + write_data           = (known after apply)
    interview:       + write_data_json      = (known after apply)
    interview:     }
    interview: 
    interview:   # module.account.vault_generic_secret.account_secret will be created
    interview:   + resource "vault_generic_secret" "account_secret" {
    interview:       + data         = (sensitive value)
    interview:       + data_json    = (sensitive value)
    interview:       + disable_read = false
    interview:       + id           = (known after apply)
    interview:       + path         = "secret/production/account"
    interview:     }
    interview: 
    interview:   # module.account.vault_policy.account_policy will be created
    interview:   + resource "vault_policy" "account_policy" {
    interview:       + id     = (known after apply)
    interview:       + name   = "account-production"
    interview:       + policy = <<-EOT
    interview: 
    interview:             path "secret/data/production/account" {
    interview:                 capabilities = ["list", "read"]
    interview:             }
    interview: 
    interview:         EOT
    interview:     }
    interview: 
    interview:   # module.frontend.docker_container.frontend will be created
    interview:   + resource "docker_container" "frontend" {
    interview:       + attach           = false
    interview:       + bridge           = (known after apply)
    interview:       + command          = (known after apply)
    interview:       + container_logs   = (known after apply)
    interview:       + entrypoint       = (known after apply)
    interview:       + env              = (known after apply)
    interview:       + exit_code        = (known after apply)
    interview:       + gateway          = (known after apply)
    interview:       + hostname         = (known after apply)
    interview:       + id               = (known after apply)
    interview:       + image            = "docker.io/nginx:1.22.0-alpine"
    interview:       + init             = (known after apply)
    interview:       + ip_address       = (known after apply)
    interview:       + ip_prefix_length = (known after apply)
    interview:       + ipc_mode         = (known after apply)
    interview:       + log_driver       = "json-file"
    interview:       + logs             = false
    interview:       + must_run         = true
    interview:       + name             = "frontend_production"
    interview:       + network_data     = (known after apply)
    interview:       + read_only        = false
    interview:       + remove_volumes   = true
    interview:       + restart          = "no"
    interview:       + rm               = false
    interview:       + security_opts    = (known after apply)
    interview:       + shm_size         = (known after apply)
    interview:       + start            = true
    interview:       + stdin_open       = false
    interview:       + tty              = false
    interview: 
    interview:       + healthcheck {
    interview:           + interval     = (known after apply)
    interview:           + retries      = (known after apply)
    interview:           + start_period = (known after apply)
    interview:           + test         = (known after apply)
    interview:           + timeout      = (known after apply)
    interview:         }
    interview: 
    interview:       + labels {
    interview:           + label = (known after apply)
    interview:           + value = (known after apply)
    interview:         }
    interview: 
    interview:       + networks_advanced {
    interview:           + aliases = []
    interview:           + name    = "vagrant_production"
    interview:         }
    interview: 
    interview:       + ports {
    interview:           + external = 4081
    interview:           + internal = 80
    interview:           + ip       = "0.0.0.0"
    interview:           + protocol = "tcp"
    interview:         }
    interview:     }
    interview: 
    interview:   # module.gateway.docker_container.gateway_container will be created
    interview:   + resource "docker_container" "gateway_container" {
    interview:       + attach           = false
    interview:       + bridge           = (known after apply)
    interview:       + command          = (known after apply)
    interview:       + container_logs   = (known after apply)
    interview:       + entrypoint       = (known after apply)
    interview:       + env              = [
    interview:           + "ENVIRONMENT=production",
    interview:           + "VAULT_ADDR=http://vault-production:8200",
    interview:           + "VAULT_PASSWORD=123-gateway-production",
    interview:           + "VAULT_USERNAME=gateway-production",
    interview:         ]
    interview:       + exit_code        = (known after apply)
    interview:       + gateway          = (known after apply)
    interview:       + hostname         = (known after apply)
    interview:       + id               = (known after apply)
    interview:       + image            = "form3tech-oss/platformtest-gateway"
    interview:       + init             = (known after apply)
    interview:       + ip_address       = (known after apply)
    interview:       + ip_prefix_length = (known after apply)
    interview:       + ipc_mode         = (known after apply)
    interview:       + log_driver       = "json-file"
    interview:       + logs             = false
    interview:       + must_run         = true
    interview:       + name             = "gateway_production"
    interview:       + network_data     = (known after apply)
    interview:       + read_only        = false
    interview:       + remove_volumes   = true
    interview:       + restart          = "no"
    interview:       + rm               = false
    interview:       + security_opts    = (known after apply)
    interview:       + shm_size         = (known after apply)
    interview:       + start            = true
    interview:       + stdin_open       = false
    interview:       + tty              = false
    interview: 
    interview:       + healthcheck {
    interview:           + interval     = (known after apply)
    interview:           + retries      = (known after apply)
    interview:           + start_period = (known after apply)
    interview:           + test         = (known after apply)
    interview:           + timeout      = (known after apply)
    interview:         }
    interview: 
    interview:       + labels {
    interview:           + label = (known after apply)
    interview:           + value = (known after apply)
    interview:         }
    interview: 
    interview:       + networks_advanced {
    interview:           + aliases = []
    interview:           + name    = "vagrant_production"
    interview:         }
    interview:     }
    interview: 
    interview:   # module.gateway.vault_generic_endpoint.gateway_endpoint will be created
    interview:   + resource "vault_generic_endpoint" "gateway_endpoint" {
    interview:       + data_json            = (sensitive value)
    interview:       + disable_delete       = false
    interview:       + disable_read         = false
    interview:       + id                   = (known after apply)
    interview:       + ignore_absent_fields = true
    interview:       + path                 = "auth/userpass/users/gateway-production"
    interview:       + write_data           = (known after apply)
    interview:       + write_data_json      = (known after apply)
    interview:     }
    interview: 
    interview:   # module.gateway.vault_generic_secret.gateway_secret will be created
    interview:   + resource "vault_generic_secret" "gateway_secret" {
    interview:       + data         = (sensitive value)
    interview:       + data_json    = (sensitive value)
    interview:       + disable_read = false
    interview:       + id           = (known after apply)
    interview:       + path         = "secret/production/gateway"
    interview:     }
    interview: 
    interview:   # module.gateway.vault_policy.gateway_policy will be created
    interview:   + resource "vault_policy" "gateway_policy" {
    interview:       + id     = (known after apply)
    interview:       + name   = "gateway-production"
    interview:       + policy = <<-EOT
    interview: 
    interview:             path "secret/data/production/gateway" {
    interview:                 capabilities = ["list", "read"]
    interview:             }
    interview: 
    interview:         EOT
    interview:     }
    interview: 
    interview:   # module.payment.docker_container.payment_container will be created
    interview:   + resource "docker_container" "payment_container" {
    interview:       + attach           = false
    interview:       + bridge           = (known after apply)
    interview:       + command          = (known after apply)
    interview:       + container_logs   = (known after apply)
    interview:       + entrypoint       = (known after apply)
    interview:       + env              = [
    interview:           + "ENVIRONMENT=production",
    interview:           + "VAULT_ADDR=http://vault-production:8200",
    interview:           + "VAULT_PASSWORD=123-payment-production",
    interview:           + "VAULT_USERNAME=payment-production",
    interview:         ]
    interview:       + exit_code        = (known after apply)
    interview:       + gateway          = (known after apply)
    interview:       + hostname         = (known after apply)
    interview:       + id               = (known after apply)
    interview:       + image            = "form3tech-oss/platformtest-payment"
    interview:       + init             = (known after apply)
    interview:       + ip_address       = (known after apply)
    interview:       + ip_prefix_length = (known after apply)
    interview:       + ipc_mode         = (known after apply)
    interview:       + log_driver       = "json-file"
    interview:       + logs             = false
    interview:       + must_run         = true
    interview:       + name             = "payment_production"
    interview:       + network_data     = (known after apply)
    interview:       + read_only        = false
    interview:       + remove_volumes   = true
    interview:       + restart          = "no"
    interview:       + rm               = false
    interview:       + security_opts    = (known after apply)
    interview:       + shm_size         = (known after apply)
    interview:       + start            = true
    interview:       + stdin_open       = false
    interview:       + tty              = false
    interview: 
    interview:       + healthcheck {
    interview:           + interval     = (known after apply)
    interview:           + retries      = (known after apply)
    interview:           + start_period = (known after apply)
    interview:           + test         = (known after apply)
    interview:           + timeout      = (known after apply)
    interview:         }
    interview: 
    interview:       + labels {
    interview:           + label = (known after apply)
    interview:           + value = (known after apply)
    interview:         }
    interview: 
    interview:       + networks_advanced {
    interview:           + aliases = []
    interview:           + name    = "vagrant_production"
    interview:         }
    interview:     }
    interview: 
    interview:   # module.payment.vault_generic_endpoint.payment_endpoint will be created
    interview:   + resource "vault_generic_endpoint" "payment_endpoint" {
    interview:       + data_json            = (sensitive value)
    interview:       + disable_delete       = false
    interview:       + disable_read         = false
    interview:       + id                   = (known after apply)
    interview:       + ignore_absent_fields = true
    interview:       + path                 = "auth/userpass/users/payment-production"
    interview:       + write_data           = (known after apply)
    interview:       + write_data_json      = (known after apply)
    interview:     }
    interview: 
    interview:   # module.payment.vault_generic_secret.payment_secret will be created
    interview:   + resource "vault_generic_secret" "payment_secret" {
    interview:       + data         = (sensitive value)
    interview:       + data_json    = (sensitive value)
    interview:       + disable_read = false
    interview:       + id           = (known after apply)
    interview:       + path         = "secret/production/payment"
    interview:     }
    interview: 
    interview:   # module.payment.vault_policy.payment_policy will be created
    interview:   + resource "vault_policy" "payment_policy" {
    interview:       + id     = (known after apply)
    interview:       + name   = "payment-production"
    interview:       + policy = <<-EOT
    interview: 
    interview:             path "secret/data/production/payment" {
    interview:                 capabilities = ["list", "read"]
    interview:             }
    interview: 
    interview:         EOT
    interview:     }
    interview: 
    interview:   # module.vault.vault_audit.audit will be created
    interview:   + resource "vault_audit" "audit" {
    interview:       + id      = (known after apply)
    interview:       + options = {
    interview:           + "file_path" = "/vault/logs/audit"
    interview:         }
    interview:       + path    = (known after apply)
    interview:       + type    = "file"
    interview:     }
    interview: 
    interview:   # module.vault.vault_auth_backend.userpass will be created
    interview:   + resource "vault_auth_backend" "userpass" {
    interview:       + accessor = (known after apply)
    interview:       + id       = (known after apply)
    interview:       + path     = (known after apply)
    interview:       + tune     = (known after apply)
    interview:       + type     = "userpass"
    interview:     }
    interview: 
    interview: Plan: 15 to add, 0 to change, 0 to destroy.
    interview: module.frontend.docker_container.frontend: Creating...
    interview: module.vault.vault_auth_backend.userpass: Creating...
    interview: module.vault.vault_audit.audit: Creating...
    interview: module.vault.vault_audit.audit: Creation complete after 0s [id=file]
    interview: module.vault.vault_auth_backend.userpass: Creation complete after 0s [id=userpass]
    interview: module.payment.vault_policy.payment_policy: Creating...
    interview: module.gateway.docker_container.gateway_container: Creating...
    interview: module.payment.vault_generic_secret.payment_secret: Creating...
    interview: module.account.vault_generic_secret.account_secret: Creating...
    interview: module.gateway.vault_generic_secret.gateway_secret: Creating...
    interview: module.gateway.vault_policy.gateway_policy: Creating...
    interview: module.gateway.vault_generic_endpoint.gateway_endpoint: Creating...
    interview: module.account.vault_policy.account_policy: Creating...
    interview: module.payment.docker_container.payment_container: Creating...
    interview: module.account.vault_policy.account_policy: Creation complete after 0s [id=account-production]
    interview: module.payment.vault_generic_endpoint.payment_endpoint: Creating...
    interview: module.payment.vault_policy.payment_policy: Creation complete after 0s [id=payment-production]
    interview: module.gateway.vault_policy.gateway_policy: Creation complete after 0s [id=gateway-production]
    interview: module.account.vault_generic_endpoint.account_endpoint: Creating...
    interview: module.account.docker_container.account_container: Creating...
    interview: module.payment.vault_generic_secret.payment_secret: Creation complete after 0s [id=secret/production/payment]
    interview: module.gateway.vault_generic_secret.gateway_secret: Creation complete after 0s [id=secret/production/gateway]
    interview: module.account.vault_generic_secret.account_secret: Creation complete after 0s [id=secret/production/account]
    interview: module.gateway.vault_generic_endpoint.gateway_endpoint: Creation complete after 0s [id=auth/userpass/users/gateway-production]
    interview: module.payment.vault_generic_endpoint.payment_endpoint: Creation complete after 0s [id=auth/userpass/users/payment-production]
    interview: module.account.vault_generic_endpoint.account_endpoint: Creation complete after 0s [id=auth/userpass/users/account-production]
    interview: module.frontend.docker_container.frontend: Creation complete after 1s [id=92c102f1bd997078a2231c5d6782e50cf1c0637fc00da82c65c0c13957f0cba0]
    interview: module.gateway.docker_container.gateway_container: Creation complete after 1s [id=0bfd37f51f6b611c421375a9b400090b7ec2f5ad14e95c0998d83ad2617f3d4b]
    interview: module.account.docker_container.account_container: Creation complete after 1s [id=2314564912fe9ba34cf95aa6b4ce42d15ebd4ab4abecede1d8257f9e83a44a21]
    interview: module.payment.docker_container.payment_container: Creation complete after 2s [id=814f78b47841309f3bf591dbd54bd537cf25ebc104f55d995dc2550d6c15a186]
    interview: 
    interview: Apply complete! Resources: 15 added, 0 changed, 0 destroyed.
    interview: ~
rohit.shenoy@TD-T3Y06QQGQ7 development % 
rohit.shenoy@TD-T3Y06QQGQ7 development % 
rohit.shenoy@TD-T3Y06QQGQ7 development % vagrant ssh
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-208-generic aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Wed Apr 19 13:50:51 PDT 2023

  System load:                    0.55
  Usage of /:                     40.2% of 9.52GB
  Memory usage:                   19%
  Swap usage:                     0%
  Processes:                      119
  Users logged in:                0
  IP address for enp0s1:          192.168.64.2
  IP address for docker0:         172.17.0.1
  IP address for br-efc92e5a02bb: 172.18.0.1
  IP address for br-8f76994d5e81: 172.19.0.1
  IP address for br-950a0b1e6ca1: 172.20.0.1

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

 * Introducing Expanded Security Maintenance for Applications.
   Receive updates to over 25,000 software packages with your
   Ubuntu Pro subscription. Free for personal use.

     https://ubuntu.com/pro

Expanded Security Maintenance for Applications is not enabled.

22 updates can be applied immediately.
14 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

6 additional security updates can be applied with ESM Apps.
Learn more about enabling ESM Apps service at https://ubuntu.com/esm

New release '20.04.6 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Wed Apr 19 13:47:24 2023 from 192.168.64.1
vagrant@interview:~$ 
vagrant@interview:~$ docker ps -a
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS          PORTS                                       NAMES
2314564912fe   form3tech-oss/platformtest-account   "/go/bin/account"        23 seconds ago   Up 21 seconds                                               account_production
814f78b47841   form3tech-oss/platformtest-payment   "/go/bin/payment"        23 seconds ago   Up 20 seconds                                               payment_production
0bfd37f51f6b   form3tech-oss/platformtest-gateway   "/go/bin/gateway"        23 seconds ago   Up 21 seconds                                               gateway_production
92c102f1bd99   nginx:1.22.0-alpine                  "/docker-entrypoint.…"   23 seconds ago   Up 22 seconds   0.0.0.0:4081->80/tcp                        frontend_production
fe2fecc481d2   form3tech-oss/platformtest-gateway   "/go/bin/gateway"        28 seconds ago   Up 26 seconds                                               gateway_development
f5793e8c1d04   form3tech-oss/platformtest-payment   "/go/bin/payment"        28 seconds ago   Up 26 seconds                                               payment_development
79cbe0542941   form3tech-oss/platformtest-account   "/go/bin/account"        28 seconds ago   Up 27 seconds                                               account_development
916e41c9f29e   nginx:latest                         "/docker-entrypoint.…"   28 seconds ago   Up 27 seconds   0.0.0.0:4080->80/tcp                        frontend_development
cc28a0e56920   vault:1.8.3                          "docker-entrypoint.s…"   34 seconds ago   Up 32 seconds   0.0.0.0:8201->8200/tcp, :::8201->8200/tcp   vagrant-vault-development-1
969be2f7011e   vault:1.8.3                          "docker-entrypoint.s…"   34 seconds ago   Up 33 seconds   0.0.0.0:8401->8200/tcp, :::8401->8200/tcp   vagrant-vault-staging-1
7fc9f4163ed3   vault:1.8.3                          "docker-entrypoint.s…"   34 seconds ago   Up 33 seconds   0.0.0.0:8301->8200/tcp, :::8301->8200/tcp   vagrant-vault-production-1
vagrant@interview:~$ 
