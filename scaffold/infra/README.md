# infra/ — Infrastructure as Code

Carpeta para definir tu infraestructura de forma declarativa, versionable y reproducible.

Hay dos sub-carpetas, una por cada herramienta soportada:

| Carpeta | Herramienta | Cuándo usar |
|---------|-------------|-------------|
| [`terraform/`](terraform/) | HashiCorp Terraform | Multi-cloud (AWS, GCP, Azure, Cloudflare, Vercel, Supabase…). Estado portable. |
| [`cloudformation/`](cloudformation/) | AWS CloudFormation | Solo AWS. Estado gestionado por AWS. Más simple si ya estás 100% en AWS. |

## Reglas de oro

1. **NUNCA commitear secretos.** Las credenciales van en variables de entorno (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `TF_VAR_*`) o en archivos `*.tfvars` que están en `.gitignore`.
2. **NUNCA commitear estado.** `terraform.tfstate*`, `.terraform/`, `*.tfplan` están en `.gitignore`. Para estado compartido en equipo → backend remoto (S3 + DynamoDB lock, o Terraform Cloud).
3. **Plan antes de apply.** Siempre `terraform plan` (o `aws cloudformation deploy --no-execute-changeset`) y revisá el diff antes de ejecutar.
4. **Recursos con tags.** Tageá todo con `Project`, `Environment`, `ManagedBy=terraform` (o `cloudformation`) y `Owner`. Facilita auditoría y limpieza.
5. **Un entorno por workspace/stack.** Nunca mezcles `dev` y `prod` en el mismo state.

## Pre-requisitos

Para usar este módulo necesitás Terraform y/o AWS CLI instalados. El instalador del bootcamp (`install.ps1` en la raíz del kit) los puede instalar opcionalmente — corré:

```powershell
# Si ya instalaste el bootcamp y querés agregar Terraform/AWS CLI después:
winget install --id HashiCorp.Terraform --exact
winget install --id Amazon.AWSCLI --exact
```

Y configurá AWS:
```powershell
aws configure
# AWS Access Key ID:     <tu key>
# AWS Secret Access Key: <tu secret>
# Default region:        us-east-1
# Default output format: json
```

## Verificar instalación

```powershell
terraform --version    # debería mostrar v1.x
aws --version          # debería mostrar aws-cli/2.x
aws sts get-caller-identity   # confirma quién sos en AWS
```

## Próximos pasos

- Si arrancás de cero: leé [`terraform/README.md`](terraform/README.md). Es más portable.
- Si ya tenés AWS y querés algo simple: [`cloudformation/README.md`](cloudformation/README.md).
