# Prerequisites

## Adapt the YAML files to match cluster name and base domain

Assuming your cluster API FQDN is `api.myocp.my.domain.com`:

```
$ find . -type f -name "*.yaml" |xargs sed -i 's@<CLUSTERNAME>@myocp@g'
$ find . -type f -name "*.yaml" |xargs sed -i 's@<BASEDOMAIN>@my.domain.com@g'
```

## Install Service Mesh 2.0

You can follow [the official documentation for Service Mesh 2.0](https://docs.openshift.com/container-platform/4.6/service_mesh/v2x/installing-ossm.html) until the section [Deploying the control plane from the web console](https://docs.openshift.com/container-platform/4.6/service_mesh/v2x/installing-ossm.html#ossm-control-plane-deploy-operatorhub_installing-ossm). When creating the `ServiceMeshControlPlane` object, you can leave all the fields to their default values.

## Install bookinfo application
You can follow [the official documentation for deploying bookinfo](https://docs.openshift.com/container-platform/4.6/service_mesh/v2x/prepare-to-deploy-applications-ossm.html#ossm-tutorial-bookinfo-install_deploying-applications-ossm) from step 1 to step 12 (apply `bookinfo-gateway.yaml`) included.

You can test that bookinfo is correctly installed using:
```
$ export GATEWAY_URL=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')

$ curl -I http://$GATEWAY_URL/productpage
HTTP/1.1 200 OK
```

## Deploy RHSSO using the RHSSO operator
We'll deploy a very simple, non-prod ready, RHSSO platform using the RHSSO platform. This RHSSO platform can be enhanced later to use a remote database (e.g. Amazon RDS), run multiple instances and use identity provider such as Github.


1. Create the `rhsso` namespace:
```
$ oc new-project rhsso
```

2. Install the RHSSO operator in the `rhsso` namespace by following [the official documentation](https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.4/html/server_installation_and_configuration_guide/operator#install_by_olm)


3. Create the RHSSO deployment:
```
$ oc apply -f rhsso/01_rhsso.yaml 
```

4. Create the `servicemesh-lab` realm:
```
oc apply -f rhsso/02_servicemesh-realm.yaml
```

5. Create a client `istio` inside the realm `servicemesh-lab`.

Note:
* the field `secret` is set randomly and you can leave as it is (we'll used this secret later);
* even if the route matching the `redirectUris` is currently using `http` (the route of the Istio default ingress gateway), leave `https` in the `redirectUris` field (the route will be patched later in approach 2 and 3);
``` 
$ oc apply -f rhsso/03_istio-client.yaml
```
Currently, the RHSSO operator does not allow to set the client to `confidential`, so we have to set it manually using the web UI.
```
# Retrieve the admin user password
# Note: the password itself is a base64 string
$ oc get secret credential-rhsso-simple --template={{.data.ADMIN_PASSWORD}} -n rhsso | base64 --decode

# Retrieve the root
$ oc get route keycloak -n rhsso
```
Open the route in a browser (don't forget `https://`) and login using the user `admin` and the above password. 
Then, select the realm `servicemesh-lab` (top left of the window), click on `Clients` in the left menu, then `istio`:
* ensure `Standard Flow Enabled` is enabled for this client;
* ensure that the `Access Type` value is set to `confidential`; if not, set it, click on the button `Save` at the bottom of the page; a new "Credentials" tab has appeared at the top of the page, and you can check in this tab that the client secret is matching the value set in `03_istio-client.yaml` (if not, simply use the new value).

6. Create the local user `localuser:localuser` inside the realm `servicemesh-lab`.
Note:
```
$ oc apply -f rhsso/04_local-user.yaml
```

You can test to login as `localuser:localuser` by opening https://keycloak-rhsso.apps.<CLUSTERNAME\>.<BASEDOMAIN\>/auth/realms/servicemesh-lab/account in a browser.
