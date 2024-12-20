# Terraform: Taint
Purpose:

Tainting a resource marks it for recreation during the next terraform apply operation. This is useful when you want to forcefully destroy and recreate a resource without changing its configuration.

Command: You can taint a resource using:

```
terraform taint <resource>
```

## Effect:

The resource will be destroyed and then recreated, even if there are no configuration changes. This can be useful when a resource becomes corrupted or you want to trigger a fresh start for it.

Dependency Impact:

When you taint a resource that has dependencies (other resources rely on it), those dependent resources might not be destroyed and recreated unless their configuration explicitly changes as a result of the tainted resource being recreated. Terraform will maintain the dependency order but will only recreate the tainted resource unless other dependent resources are also affected indirectly.