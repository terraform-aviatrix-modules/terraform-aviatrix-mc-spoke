# Module testing

### Prepare test environment
In order to run the tests included with this module, a test environment needs to be set up.

- Controller<br>
A controller with the software version you would like to test the module with, needs to be deployed and accessible from the environment where you are running these tests.

- Accounts<br>
The included tests assume the following access account with these names are configured on the controller:

Cloud | Access Account
---|---
Azure | Azure
AWS | AWS
Google Cloud | GCP
Alibaba | ALI
Oracle Cloud | OCI

- Credentials<br>
Set the following enviroment variables before execution
```
export AVIATRIX_CONTROLLER_IP="1.2.3.4"
export AVIATRIX_USERNAME="admin"
export AVIATRIX_PASSWORD="password"
```

### Execute tests
You can run the tests, from the root of the module by executing the following command:
```
terraform test
```
