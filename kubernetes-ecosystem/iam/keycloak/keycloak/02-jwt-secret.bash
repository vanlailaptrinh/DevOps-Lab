kubectl create secret generic keycloak-jwt-credential \
  --namespace dgraph \
  --from-literal=kongCredType=jwt \
  --from-literal=algorithm=RS256 \
  --from-literal=key="http://192.168.100.213:30443/realms/kong-realm" \
  --from-literal=secret=dummy \
  --from-file=rsa_public_key=public.pem