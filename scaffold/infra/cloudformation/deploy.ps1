#Requires -Version 5.1
<#
.SYNOPSIS
    Wrapper para desplegar el stack CloudFormation con validación y changeset preview.
.DESCRIPTION
    - Valida el template antes de desplegar.
    - Si -Plan, crea un changeset y muestra qué va a cambiar SIN ejecutarlo.
    - Si no, despliega usando aws cloudformation deploy (idempotente: crea o actualiza).
    - Muestra los outputs al final.
.EXAMPLE
    .\deploy.ps1 -Plan
    .\deploy.ps1
    .\deploy.ps1 -StackName otro-nombre -Region us-west-2
.NOTES
    Requiere AWS CLI configurado (aws configure).
#>
param(
    [string]$StackName  = '',
    [string]$Template   = 'stack-s3-bucket.yaml',
    [string]$ParamsFile = 'parameters.json',
    [string]$Region     = $env:AWS_REGION,
    [switch]$Plan
)

$ErrorActionPreference = 'Stop'

# Validar pre-requisitos
try { aws --version | Out-Null } catch {
    Write-Host "ERROR: AWS CLI no instalado. Instalalo con: winget install Amazon.AWSCLI" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $Template)) {
    Write-Host "ERROR: no existe $Template" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $ParamsFile)) {
    Write-Host "ERROR: no existe $ParamsFile. Copialo de parameters.example.json y editalo." -ForegroundColor Red
    exit 1
}

if (-not $Region) { $Region = 'us-east-1' }

# Derivar StackName de los parametros si no se paso
if (-not $StackName) {
    $params = Get-Content $ParamsFile -Raw | ConvertFrom-Json
    $proj   = ($params | Where-Object { $_.ParameterKey -eq 'ProjectName' }).ParameterValue
    $env    = ($params | Where-Object { $_.ParameterKey -eq 'Environment' }).ParameterValue
    if ($proj -and $env) {
        $StackName = "$proj-$env"
    } else {
        Write-Host "ERROR: no pude derivar StackName. Pasalo con -StackName." -ForegroundColor Red
        exit 1
    }
}

Write-Host ''
Write-Host "Stack    : $StackName" -ForegroundColor Cyan
Write-Host "Template : $Template" -ForegroundColor Cyan
Write-Host "Region   : $Region" -ForegroundColor Cyan
Write-Host "Mode     : $(if ($Plan) { 'PLAN (changeset only)' } else { 'DEPLOY' })" -ForegroundColor Cyan
Write-Host ''

# Validar template
Write-Host '==> Validando template...' -ForegroundColor Cyan
aws cloudformation validate-template --template-body "file://$Template" --region $Region | Out-Null
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host '    OK' -ForegroundColor Green

# Convertir parametros a flags --parameter-overrides Key=Value
$paramJson = Get-Content $ParamsFile -Raw | ConvertFrom-Json
$paramArgs = $paramJson | ForEach-Object { "$($_.ParameterKey)=$($_.ParameterValue)" }

if ($Plan) {
    Write-Host '==> Creando changeset (NO se aplica)...' -ForegroundColor Cyan
    $changeSetName = "preview-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

    aws cloudformation deploy `
        --stack-name $StackName `
        --template-file $Template `
        --parameter-overrides $paramArgs `
        --no-execute-changeset `
        --region $Region

    Write-Host ''
    Write-Host 'Cambios pendientes en el changeset:' -ForegroundColor Yellow
    aws cloudformation describe-change-set `
        --stack-name $StackName `
        --change-set-name (aws cloudformation list-change-sets --stack-name $StackName --region $Region --query 'Summaries[0].ChangeSetName' --output text) `
        --region $Region `
        --query 'Changes[].ResourceChange.{Action:Action,Type:ResourceType,Logical:LogicalResourceId}' `
        --output table
    Write-Host ''
    Write-Host 'Para aplicar, corre el script SIN -Plan' -ForegroundColor Yellow
    exit 0
}

Write-Host '==> Desplegando...' -ForegroundColor Cyan
aws cloudformation deploy `
    --stack-name $StackName `
    --template-file $Template `
    --parameter-overrides $paramArgs `
    --capabilities CAPABILITY_NAMED_IAM `
    --region $Region

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ''
Write-Host '==> Outputs:' -ForegroundColor Cyan
aws cloudformation describe-stacks `
    --stack-name $StackName `
    --region $Region `
    --query 'Stacks[0].Outputs[].{Key:OutputKey,Value:OutputValue}' `
    --output table

Write-Host ''
Write-Host "OK. Stack $StackName desplegado en $Region." -ForegroundColor Green
