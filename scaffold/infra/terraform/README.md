# Terraform — template básico

Módulo Terraform de ejemplo: un **bucket S3 versionado y privado** en AWS, listo para personalizar.

## Estructura

```
terraform/
├── versions.tf              ← versiones requeridas (Terraform + providers)
├── main.tf                  ← recursos (bucket S3, encryption, public-access-block)
├── variables.tf             ← inputs configurables
├── outputs.tf               ← outputs (nombre del bucket, ARN)
├── terraform.tfvars.example ← copialo a terraform.tfvars y editalo
└── .gitignore               ← ignora state, .terraform/, *.tfvars (no .example)
```

## Quickstart

```powershell
# 1. Copiar y editar variables
cp terraform.tfvars.example terraform.tfvars
# editar terraform.tfvars con tu nombre de proyecto y región

# 2. Inicializar (descarga providers, configura backend)
terraform init

# 3. Validar sintaxis
terraform validate

# 4. Ver qué va a hacer (NO ejecuta nada)
terraform plan

# 5. Aplicar (te pide confirmación)
terraform apply

# 6. Cuando ya no lo necesites
terraform destroy
```

## Configuración de credenciales AWS

Terraform lee credenciales en este orden:

1. Variables de entorno (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`).
2. Archivo `~/.aws/credentials` (creado por `aws configure`).
3. IAM Role (si corrés desde EC2/ECS/Lambda).

**Recomendado para dev:**
```powershell
aws configure
```

**Recomendado para CI/CD:** usar OIDC con GitHub Actions o AWS IAM Roles, NO claves estáticas.

## Backend remoto (para equipos)

Por defecto este template usa backend local — el estado vive en `terraform.tfstate` en tu disco.

Para equipo, descomentá el bloque `backend "s3"` en `versions.tf` y configurá un bucket dedicado para state (con versionado + lock vía DynamoDB).

```hcl
terraform {
  backend "s3" {
    bucket         = "mi-org-tfstate"
    key            = "proyecto/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## Variables disponibles

| Variable      | Tipo   | Default | Descripción |
|---------------|--------|---------|-------------|
| `project`     | string | (req)   | Nombre del proyecto, se usa en nombres y tags |
| `environment` | string | "dev"   | dev / staging / prod |
| `region`      | string | "us-east-1" | Región AWS |
| `bucket_suffix` | string | (random) | Sufijo del bucket (S3 names son globales) |
| `tags`        | map    | {}      | Tags extra a agregar a todos los recursos |

## Salidas

```bash
terraform output
# bucket_name = "mi-proyecto-dev-a1b2c3d4"
# bucket_arn  = "arn:aws:s3:::mi-proyecto-dev-a1b2c3d4"
```

## Extender este template

Casos comunes para agregar:

- **CloudFront + ACM** → distribución CDN con HTTPS.
- **Route53** → dominio custom.
- **IAM user/role** → permisos para CI/CD que sube assets al bucket.
- **Lifecycle rules** → mover objetos viejos a Glacier.

Pedile a Claude Code:
> "Agregale a este módulo Terraform una distribución CloudFront con un certificado ACM en us-east-1 y un dominio custom de Route53. Dame `terraform plan` antes de cualquier apply."
