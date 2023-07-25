Prerequisites:
  - AWS account (Free tier)
  - VSCode
  - kubectl, terraform, awscli, helm installed

Change values for:
  - snaplogic_config_link in helm_chart_v3/values.yaml
  - eks.amazonaws.com/role-arn in helm_chart_v3/templates/service-account.yaml
  - aws_iam_policy Resource in tf/13.ssm.tf
  - eks.amazonaws.com/role-arn in yaml/caDeployment.yaml

```
# Clone the repo to your local playground
git clone git@github.com:sweetdandelions/kube-app-slp.git
cd kube-app-slp/scripts

# Provisioning infrastructure
./create-infra.sh

# Destroying infrastructure
./destroy-infra.sh
```






