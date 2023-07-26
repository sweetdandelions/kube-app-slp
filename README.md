Prerequisites:
  - AWS account (Free tier)
  - VSCode
  - kubectl, terraform, awscli, helm installed
  - AWS Secret for accessing the app
  - Snaplex in the UI https://docs-snaplogic.atlassian.net/wiki/spaces/SD/pages/2017558845/Deploying+a+Groundplex+in+Kubernetes+with+Elastic+Scaling#DeployingaGroundplexinKuberneteswithElasticScaling-Step1%3ASettinguptheSnaplexintheUI

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






