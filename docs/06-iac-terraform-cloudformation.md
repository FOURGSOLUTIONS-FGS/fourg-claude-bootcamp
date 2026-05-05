# 06 — Infrastructure as Code (Terraform + CloudFormation)

El bootcamp incluye un módulo `infra/` con templates de **Terraform** y **CloudFormation** listos para usar. Esta doc explica cuándo usar cada uno y cómo arrancar.

---

## ¿Por qué IaC?

Hacer infraestructura desde la consola de AWS funciona para experimentar, pero no escala:

- Olvidás qué creaste y qué cuesta plata.
- No es repetible (crear el mismo entorno para staging es manual).
- No hay historial de cambios.
- No podés revisar diffs antes de aplicar.

**Infrastructure as Code (IaC)** resuelve esto: declarás la infra en archivos de texto, los versionás en git, y una herramienta los aplica de forma idempotente.

---

## Terraform vs CloudFormation — cuándo usar cada uno

| Pregunta | Terraform | CloudFormation |
|---|---|---|
| ¿Solo AWS o multi-cloud? | Multi-cloud (AWS + GCP + Cloudflare + Vercel + …) | Solo AWS |
| ¿Quién guarda el state? | Vos (local o S3+DynamoDB) | AWS |
| ¿Drift detection? | `terraform plan` re-lee el cloud y compara | Nativo en consola, un click |
| ¿Sintaxis? | HCL (más legible que YAML) | YAML / JSON |
| ¿Modules / abstracción? | Modules nativos + Registry público | Nested stacks, SAM, CDK |
| ¿Costo? | Gratis (Cloud paga si querés UI) | Gratis |
| ¿Comunidad? | Enorme, multi-cloud | AWS-only, oficial |

**Recomendación práctica:**
- Empezás de cero y no sabés qué cloud vas a usar → **Terraform**.
- 100% AWS, equipo ya conoce AWS Console → **CloudFormation** (más simple, drift detection nativa).
- Ya tenés un equipo DevOps con Terraform en producción → seguí con Terraform.

---

## Pre-requisitos

Si elegiste **"Instalar Terraform + AWS CLI"** en el `install.ps1`, ya están listos. Si no:

```powershell
winget install --id HashiCorp.Terraform --exact
winget install --id Amazon.AWSCLI       --exact
```

Después configurá AWS:
```powershell
aws configure
# AWS Access Key ID [None]:        AKIA...
# AWS Secret Access Key [None]:    ...
# Default region name [None]:      us-east-1
# Default output format [None]:    json
```

> **Seguridad:** Para dev personal, podés usar credenciales IAM User. Para producción/CI, usá **OIDC + IAM Roles** (no claves estáticas). Ver [docs.aws.amazon.com/IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_oidc.html).

Verificá que todo funciona:
```powershell
.\verify.ps1
```

Deberías ver:
```
Infrastructure as Code (opcional):
  [OK]  Terraform       Terraform v1.x.x
  [OK]  AWS CLI         aws-cli/2.x.x
Credenciales AWS:
  [OK]  identidad       arn:aws:iam::123456789012:user/tu-usuario
```

---

## Tu primer apply con Terraform

Asumimos que ya tenés un proyecto creado en `projects/<tu-proyecto>/`.

```powershell
# 1. Copiar el template a tu proyecto
cp -r ..\..\scaffold\infra\terraform .\infra\terraform   # ajustá rutas según tu setup
# o más simple si arrancás desde el workspace raíz:
cp -r infra\terraform projects\<tu-proyecto>\infra\

cd projects\<tu-proyecto>\infra

# 2. Editar variables
cp terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
# editar: project = "tu-proyecto"

# 3. Inicializar (descarga providers)
terraform init

# 4. Validar sintaxis
terraform validate

# 5. Ver el plan SIN aplicar
terraform plan
# revisar: te dice qué recursos va a crear (S3 bucket + versioning + encryption)

# 6. Aplicar (te pide "yes" antes)
terraform apply

# 7. Cuando ya no lo necesites
terraform destroy
```

Después de `apply`, tenés un bucket S3 privado, versionado y encriptado, taggeado con `Project`, `Environment`, `ManagedBy=terraform`.

---

## Tu primer deploy con CloudFormation

```powershell
cd projects\<tu-proyecto>\infra\cloudformation
# (asumiendo que copiaste el template ahí)

# 1. Editar parámetros
cp parameters.example.json parameters.json
notepad parameters.json
# editar: ProjectName, Owner

# 2. Ver qué va a hacer (changeset, sin aplicar)
.\deploy.ps1 -Plan

# 3. Aplicar
.\deploy.ps1

# 4. Ver outputs
aws cloudformation describe-stacks --stack-name tu-proyecto-dev --query "Stacks[0].Outputs"

# 5. Destruir
aws cloudformation delete-stack --stack-name tu-proyecto-dev
```

---

## Reglas críticas de seguridad

1. **NUNCA commitear secretos.** Las credenciales van en `~/.aws/credentials` o env vars (`AWS_ACCESS_KEY_ID`). El `.gitignore` del scaffold ya excluye `*.tfvars` (excepto `.example`) y `parameters.json`.
2. **NUNCA commitear state.** `terraform.tfstate` puede contener secretos en plain text (passwords de RDS, tokens, etc.). El `.gitignore` lo excluye. Para equipos → backend remoto S3 + DynamoDB lock.
3. **`plan` antes de `apply`. Siempre.** Mirar qué se va a crear/modificar/destruir antes de ejecutar.
4. **Tagear todo.** `Project`, `Environment`, `ManagedBy`, `Owner`. Hace fácil auditar costos y limpiar recursos huérfanos.
5. **MFA + IAM en producción.** Para dev personal, IAM user con MFA. Para CI/CD, OIDC con GitHub Actions + IAM Role asumible.
6. **Encriptar todo en reposo.** Los templates del bootcamp ya lo hacen para S3 (AES256). Para RDS, EBS, EFS también lo hacen automáticamente en cuentas nuevas.
7. **Bloquear acceso público por default.** `BlockPublicAcls`, `BlockPublicPolicy`, `IgnorePublicAcls`, `RestrictPublicBuckets` están todos en `true` en los templates. NO los desactives sin pensarlo dos veces.

---

## Pedile a Claude Code

Una vez tenés el módulo `infra/` en tu proyecto, abrí Claude Code en esa carpeta y pedile:

```
Tengo un módulo Terraform que crea un bucket S3 privado.
Necesito agregar:
- Una distribución CloudFront con OAC (Origin Access Control)
- Un certificado ACM en us-east-1
- Un alias de Route53 apuntando al CloudFront

El dominio es `mi-sitio.com` y la zona ya existe en Route53 con ID `Z123ABC`.

Antes de cualquier `apply`, dame `terraform plan` y revisamos juntos.
```

Claude Code va a:
- Leer tu módulo actual.
- Agregar los recursos nuevos en archivos separados (`cloudfront.tf`, `dns.tf`).
- Actualizar `outputs.tf` con la URL del CloudFront.
- Correr `terraform validate` y `terraform plan`.
- Esperar tu OK antes de `apply`.

Lo mismo aplica para CloudFormation.

---

## Recursos

- **Terraform AWS Provider:** [registry.terraform.io/providers/hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws)
- **Terraform Registry (modules):** [registry.terraform.io](https://registry.terraform.io)
- **CloudFormation Reference:** [docs.aws.amazon.com/AWSCloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)
- **AWS Well-Architected Framework:** [aws.amazon.com/architecture/well-architected](https://aws.amazon.com/architecture/well-architected/)
- **OIDC + GitHub Actions + AWS:** [docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
