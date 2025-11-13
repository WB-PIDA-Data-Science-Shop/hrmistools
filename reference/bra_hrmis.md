# Brazilian Public Employee Payroll Data

A dataset containing payroll information for Brazilian public sector
employees, including salary components, personal information, and
employment details.

## Usage

``` r
bra_hrmis
```

## Format

A data frame with 34 variables:

- ANO_PAGAMENTO:

  Payment year (numeric)

- MES_REFERENCIA:

  Reference month (numeric)

- MATRICULA:

  Employee registration/enrollment number (character)

- CPF:

  Brazilian tax identification number - Cadastro de Pessoas Físicas
  (character)

- DATA_NASCIMENTO:

  Date of birth (Date)

- GENERO:

  Gender (character)

- ESCOLARIDADE:

  Educational level/degree (character)

- DATA_ADMISSAO:

  Admission/hiring date (Date)

- ADMINISTRACAO:

  Administration type (character)

- TIPO_CONTRATO:

  Contract type (character)

- GRUPO:

  Employee group classification (character)

- COD_ORGAO:

  Agency/department code (character)

- ORGAO:

  Agency/department name (character)

- CARREIRA:

  Career path/track (character)

- CARGO:

  Position/job title (character)

- JORNADA:

  Work schedule/hours (character)

- CLASSE:

  Position class (character)

- NIVEL:

  Position level (character)

- DATA_ULT_PROGRESSAO:

  Date of last career progression (Date)

- SALARIO_BASE:

  Base salary (numeric)

- CONTRIBUICAO_PREVIDENCIA:

  Social security contribution (numeric)

- ADICIONAL_TEMPO_SERVICO:

  Time of service bonus (numeric)

- COMISSAO:

  Commission payment (numeric)

- ABONO_PERMANENCIA:

  Permanence allowance (numeric)

- DECISAO_JUDICIAL:

  Judicial decision payments (numeric)

- DEMAIS_GRATIFICACOES_TRANSITORIAS:

  Other temporary bonuses (numeric)

- DEMAIS_GRATIFICACOES_CARREIRA:

  Other career-related bonuses (numeric)

- SALARIO_BRUTO:

  Gross salary (numeric)

- SALARIO_LIQUIDO:

  Net salary (numeric)

- DATA_APOSENTADORIA:

  Retirement date (Date)

- VALOR_BRUTO:

  Gross amount (numeric)

- VALOR_LIQUIDO:

  Net amount (numeric)

- TIPO:

  Type/category (character)

- TEMPO DE CONTRIBUIÇÃO:

  Contribution time period (character)

## Source

Brazilian public sector payroll records

## Examples

``` r
if (FALSE) { # \dontrun{
# Summary of base salaries
summary(payroll_data$SALARIO_BASE)

# Count by agency
table(payroll_data$ORGAO)
} # }
```
