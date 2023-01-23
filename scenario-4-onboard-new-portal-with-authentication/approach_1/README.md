# Approach 1

## Mount Openshift ingress routers CA certificate in istiod
When deploying RequestAuthentication object, Istiod will be in charge of verifying the connection to RHSSO. This step is performed during initialization only (RequestAuthentication object creation). Since RHSSO is exposed behind a route, we need to add the Openshift ingress routers CA certificate to istiod so it can verify the TLS certificate for the RHSSO route.

```
# Retrieve the CA certificate from secret in openshift-ingress-operator project 
$ oc extract secret/router-ca -n openshift-ingress-operator --to=/tmp/

# Create a secret from thie CA certificate in istio-system project
$ oc create secret generic openshift-wildcard --from-file=extra.pem=/tmp/tls.crt -n istio-system

# Mount the CA secret at the specific location '/cacerts/extra.pem' in istiod pod
$ oc set volumes -n istio-system deployment/istiod-basic --add  --name=extracacerts  --mount-path=/cacerts  --secret-name=openshift-wildcard  --containers=discovery
```

To check if the procedure has been done successfully:
```
$ oc project istio-system

$ oc get pod
[...]
istiod-basic-6f5bfd89bf-v49vf          1/1     Running   0          14s
[...]

# RSH to istiod pod
$ oc rsh istiod-basic-6f5bfd89bf-v49vf 

# Check connection to RHSSO without the CA
[pod] sh-4.4$ curl -I https://keycloak-rhsso.apps.<CLUSTERNAME>.<BASEDOMAIN>/auth/
curl: (60) SSL certificate problem: self signed certificate in certificate chain

# Check connection to RHSSO with the CA
[pod] sh-4.4$ curl --cacert /cacerts/extra.pem -I https://keycloak-rhsso.apps.<CLUSTERNAME>.<BASEDOMAIN>/auth/
HTTP/1.1 200 OK
```

## Create RequestAuthentication and AuthorizationPolicy for bookinfo

First, replace `<CLUSTERNAME>` and `<BASEDOMAIN>` with the appropriate values. Then apply the two CR:
```
$ oc apply -f 01_requestauthentication.yaml -n bookinfo
$ oc apply -f 02_authpolicy_allow_from_servicemesh-lab_realm.yaml -n bookinfo 
```

The created `RequestAuthentication` object tells Istio that only JWT tokens issued by our RHSSO will be used to authenticate/authorize user requests for `bookinfo`.

The created `AuthenticationPolicy` object tells that the JWT token, to be valid, must be issued by our RHSSO and for any user with email address matching `shadowman@redhat.com` or `another@email.com` (see [Istio conditions page](https://istio.io/latest/docs/reference/config/security/conditions/) for more example of conditions). During prerequisites phase, we created a user `localuser` inside RHSSO, and this user has the address `shadowman@redhat.com`.

## Access bookinfo

First, ensure that you cannot access anymore the `bookinfo` application (it might take a few seconds for the changes to apply):
```
$ export GATEWAY_URL=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')
$ curl -I http://$GATEWAY_URL/productpage                                                           
HTTP/1.1 403 Forbidden
```

Then, retrieve a JWT token for user `localuser` from our RHSSO:
```
$ curl -Lk --data "username=localuser&password=localuser&grant_type=password&client_id=istio&client_secret=<CLIENT_SECRET>" \
   https://keycloak-rhsso.apps.<CLUSTERNAME>.<BASEDOMAIN>/auth/realms/servicemesh-lab/protocol/openid-connect/token \
   | jq .access_token
```

Note: the `<CLIENT_SECRET>` must be replaced with the client secret of the RHSSO client created during prerequisites phase (see `prerequisites/README.md` and `prerequisites/yaml/rhsso/03_istio-client.yaml)`.

Finally, use this JWT token to access `bookinfo`:
```
$ TOKEN=$($ curl -Lk --data "username=localuser&password=localuser&grant_type=password&client_id=istio&client_secret=<CLIENT_SECRET>" \
   https://keycloak-rhsso.apps.<CLUSTERNAME>.<BASEDOMAIN>/auth/realms/servicemesh-lab/protocol/openid-connect/token \
   | jq .access_token)

$ curl -I -H "Authorization: Bearer $TOKEN" http://$GATEWAY_URL/productpage
HTTP/1.1 200 OK
```
