# check-data-keys

Tekton task to check that all required information is present in the data file in order to use the specified system(s). The task validates the data against a JSON schema, ensuring that all required keys for each system are present. If any required keys are missing, if the systems key does not follow the schema patteren, or if the data includes any additional properties not defined in the schema, the task will fail.

For example, if `releaseNotes` is passed as a system and the data file does not have all the required
releaseNotes keys, the task will fail.

All required keys are defined in the schema file, which is stored in the `release-service-catalog` repository.

## Parameters

| Name     | Description                                             | Optional | Default value |
|----------|---------------------------------------------------------|----------|---------------|
| dataPath | Path to the JSON string of the merged data to use       | No       |               |
| systems  | The systems to check that all data keys are present for | Yes      | []            |
| schema   | The raw Git URL to the schema file                     | Yes      |"https://raw.githubusercontent.com/konflux-ci/release-service-catalog/refs/heads/production/schema/dataKeys.json" |

## Changes in 0.10.0
* This task has been updated to use the schema file from the release-service-catalog repository. The task now checks for the required keys for each system. It also checks that the system's key follows the schema pattern and that the data includes no additional properties not defined in the schema.

## Changes in 0.9.2
* Fixing checkton/shellcheck linting issues in the task and test

## Changes in 0.9.1
* The task would show failure output if a system with just one key was added (as cdn currently is)

## Changes in 0.9.0
* Added the cdn system

## Changes in 0.8.0
* Updated the base image used in this task

## Changes in 0.7.0
* Updated the base image used in this task

## Changes in 0.6.0
* Remove `dataPath` default value

## Changes in 0.5.0
* Add releaseNotes.product_stream to required keys

## Changes in 0.4.0
* Add releaseNotes.product_name and releaseNotes.product_version to required keys

## Changes in 0.3.0
* Replace advisory.spec references with releaseNotes key

## Changes in 0.1.0
* Updated hacbs-release/release-utils image to reference redhat-appstudio/release-service-utils image instead
