#!/usr/bin/env bash
set -euvx

./scripts/cs-setup.sh
mkdir -p bin
./cs bootstrap -o bin/sbt sbt-launcher io.get-coursier:coursier_2.12:2.0.0-RC6-25
rm -f cs cs.exe

if [ "$(expr substr $(uname -s) 1 5 2>/dev/null)" == "Linux" ]; then
  SBT="./bin/sbt -C--plugin-version=2.0.0-RC6-8"
elif [ "$(uname)" == "Darwin" ]; then
  SBT="./bin/sbt -C--plugin-version=2.0.0-RC6-8"
else
  SBT="./bin/sbt.bat -C--plugin-version=2.0.0-RC6-8"
fi

lmCoursier() {
  [ "${PLUGIN:-""}" = "sbt-lm-coursier" ]
}

runLmCoursierTests() {
  # publishing locally to ensure shading runs fine
  ./metadata/scripts/with-test-repo.sh $SBT \
    evictionCheck \
    compatibilityCheck \
    lm-coursier-shaded/publishLocal \
    lm-coursier/test \
    "sbt-lm-coursier/scripted shared-1/* shared-2/* sbt-lm-coursier/* scala-211/*"
}

runSbtCoursierTests() {
  ./metadata/scripts/with-test-repo.sh $SBT \
    sbt-coursier-shared/test \
    "sbt-coursier/scripted shared-1/* shared-2/* sbt-coursier/* scala-211/*"
}


if lmCoursier; then
  runLmCoursierTests
else
  runSbtCoursierTests
fi

