# Infrastructure for backstage

If you want to test changes to backstage, you can deploy it to the ptlsbox environment.

To do this update `azure-pipelines.yaml` with stages for terraform.

See [example for plan](https://github.com/hmcts/backstage-infra/blob/4bebc3ec6ae3055750dad104b890a1a2da530ce9/azure-pipelines.yml#L40-L49).

See [example for apply](https://github.com/hmcts/backstage-infra/blob/4bebc3ec6ae3055750dad104b890a1a2da530ce9/azure-pipelines.yml#L82-L91)