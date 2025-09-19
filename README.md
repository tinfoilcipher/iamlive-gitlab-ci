# iamlive service

An implementation of [iamlive](https://github.com/iann0036/iamlive) which can be used inside a Gitlab CI pipeline as a [Service Container](https://docs.gitlab.com/ci/services/).

## How To Use These Components In a Consuming Service

### Build Container(s)

First build the service image, you can do this either:

- Via GitHub when using the workflow in `.github/workflows/containers.yml`
- Via GitLab using the `.gitlab-ci.yml`

Either workflow will trigger when committing to `main` in the relevant platform and push to it's **internal container registry**. If you want to build and push somewhere else, write your own workflow. An additional, optional workflow is also provided to create a consumer container for the purposes of testing that `iamlive` calls are being made. Uncomment it from the relevant CI file to build.

### Configure Consuming Project CI

With the image(s) available. Configure your consuming project as below in Gitlab CI:

```yaml
include:
  - remote: "https://raw.githubusercontent.com/tinfoilcipher/iamlive-gitlab-ci/main/templates/iamlive.yml"

variables:
  CI_DEBUG_SERVICES: 'false' #--Turn this on to see STDOUT/STDERR for iamlive
  SERVICE_IMAGE_URI: ghcr.io/tinfoilcipher/iamlive-gitlab-ci-service:latest

example-job:
  stage: build
  image: ghcr.io/tinfoilcipher/iamlive-gitlab-ci-test-consumer:latest #--Provide your application which will be calling AWS, or use the example consumer for debugging
    - !reference [.iamlive_pre, script]
    - aws s3 ls #--Put your functions here that call AWS
  after_script:
    - !reference [.iamlive_post, script]
  artifacts:
    public: false
    when: always
    paths:
      - $IAMLIVE_OUTPUT_PATH
```

## Configuration Variables

| Variable Name                    | Function                                                                                                            | Default                                                            |
|----------------------------------|---------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| SERVICE_IMAGE_URI                | URI for Service Image                                                                                               |                                                                    |
| IAMLIVE_OUTPUT_PATH              | Output path for iamlive report                                                                                      | $CI_PROJECT_DIR/iamlive-policy.json                                |
| IAMLIVE_PROXY_EXCEPTIONS         | List of HTTP/S proxy domain exceptions for iamlive (I.E. domains which will not be intercepted by the proxy)        | github.com,gitlab.com,registry.terraform.io,releases.hashicorp.com |
| IAMLIVE_CA_DIR                   | Directory used for the iamlive internal CA. **Should not be changed without a good reason**                         | /builds/iamlive                                                    |
| IAMLIVE_ADDITIONAL_ARGS          | Additional [cli arguments](https://github.com/iann0036/iamlive?tab=readme-ov-file#cli-arguments) to pass to iamlive |                                                                    |
| IAMLIVE_FORCE_RESOURCE_WILDCARDS | Force wildcards to be returned for IAM resources instead of specific named resource objects                         | false                                                              |
| IAMLIVE_FAILS_ONLY               | Return IAM policy matches for access failures only                                                                  | false                                                              |

## How Does It Work?

![consumer-workflow](iamlive-gitlab-ci.svg)
