# CloudFormation — template básico

Stack CloudFormation de ejemplo: un **bucket S3 versionado y privado**, equivalente al template Terraform de al lado pero usando CloudFormation nativo.

## Archivos

- `stack-s3-bucket.yaml` — el template del stack.
- `deploy.ps1` — script wrapper que valida + despliega + muestra outputs.
- `parameters.example.json` — parámetros de ejemplo.

## Quickstart

```powershell
# 1. Copiar parameters
cp parameters.example.json parameters.json
# editar parameters.json con tu projectName y environment

# 2. Validar el template (sin desplegar)
aws cloudformation validate-template --template-body file://stack-s3-bucket.yaml

# 3. Ver el cambio que va a hacer (changeset, no ejecuta)
.\deploy.ps1 -Plan

# 4. Desplegar
.\deploy.ps1

# 5. Ver outputs
aws cloudformation describe-stacks --stack-name mi-proyecto-dev --query "Stacks[0].Outputs"

# 6. Destruir
aws cloudformation delete-stack --stack-name mi-proyecto-dev
```

## Pre-requisitos

- AWS CLI configurado (`aws configure`).
- Permisos IAM para crear stacks y los recursos que el stack define.

## Diferencias clave vs Terraform

| Aspecto | CloudFormation | Terraform |
|---------|----------------|-----------|
| Cloud | Solo AWS | Multi-cloud |
| Estado | AWS lo guarda | Vos (local o backend remoto) |
| Drift detection | Nativo, con un click | `terraform plan` |
| Sintaxis | YAML / JSON | HCL (más legible) |
| Modules / abstracción | Nested stacks, SAM, CDK | Modules nativos |
| Costo | Gratis | Gratis (Cloud paga si querés UI) |

**Cuándo CloudFormation gana:** workloads 100% AWS, equipos que ya conocen AWS Console, quieren drift detection nativo.

**Cuándo Terraform gana:** multi-cloud, quieren state portable, prefieren HCL, quieren ecosystem de modules de la comunidad.

## Extender

Pedile a Claude Code:
> "Agregale al stack CloudFormation una distribución CloudFront con OAC, un certificado ACM en us-east-1, y un Record Set en Route53 apuntando al CloudFront. Genero un changeset para revisar antes de desplegar."
