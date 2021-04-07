#!/bin/bash

set -e

echo "Running Identity acceptance tests"

export PROTOCOL=https://
export TERM=dumb
export ADMIN_CLIENT_SECRET="$(cat admin-client-secret/value)"
export IDENTITY_CLIENT_SECRET="$(cat identity-client-secret/value)"
export MAILINATOR_API_KEY="$(cat mailinator-api-key/value)"

cd idats/src/dogs

#makes a directory
mkdir -p ~/.gradle
echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties

cat > ~/.gradle/init.gradle <<EOL
allprojects {
  tasks.withType(Test) {
    testLogging {
      events "passed", "skipped", "failed"
      exceptionFormat "full"
    }
  }
}
EOL

echo "Running IDATS tests against ${PROTOCOL}${BASE_URL}"

./gradlew clean test
