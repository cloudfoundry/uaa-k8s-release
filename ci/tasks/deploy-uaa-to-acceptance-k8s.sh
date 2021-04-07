#!/bin/bash
set -eu -o pipefail

gcloud auth activate-service-account --key-file=<(echo "${GCP_SERVICE_ACCOUNT_KEY}")
gcloud config set project cf-uaa-identity
gcloud container clusters get-credentials uaa-acceptance --region "${GCP_REGION}"

ytt -f uaa/k8s/templates/ \
  -f identity-ci/concourse/uaa-acceptance-gcp/k8s/cert.yml \
  -f identity-ci/concourse/uaa-acceptance-gcp/k8s/ingress.yml \
  -f identity-ci/concourse/uaa-acceptance-gcp/k8s/values.yml \
  -v smtp.password=${SMTP_PASSWORD} \
  -v admin.client_secret=${UAA_ADMIN_CLIENT_SECRET} \
  | kubectl apply -f -

kubectl rollout status deployment uaa --timeout=0

exit $?
