# To run workflow

# GitHub Actions
## For unit testing
When you push to any branch "master", "develop" or merge a PR to "master", the unit tests will run automatically.
Please check the progress in the Actions tab.


## For release (interactively)
First, you need to modify a version in `./lib/adap/version.py`.
Then, you can run the following command to trigger the release workflow.

```
$ vim lib/adap/version.rb
  -> Update VERSION
```

Then create a commit and push it and create a PR.
After it was merged, you can run the following command to trigger the release workflow.

```
$ gh workflow run
? Select a workflow  [Use arrows to move, type to filter]
> Ruby (release.yml)                                       // <- Select "Ruby (release.yml)"
  Ruby (ruby.yml)
  Dependabot Updates (dependabot-updates)

? otp (required)                                           // <- Input the OTP code
```



```
$ gh run list --workflow=release.yml
STATUS  TITLE  WORKFLOW  BRANCH  EVENT              ID           ELAPSED  AGE
*       Ruby   Ruby      master  workflow_dispatch  12673039585  10s      less than a minute ago
```


## For release (non-interactively)
You can also trigger the release workflow non-interactively.

```
gh workflow run release.yml --ref=master --field otp=123456
```

`--field otp=123456` is required to input the OTP code.
You have to change `123456` to the actual OTP code.
