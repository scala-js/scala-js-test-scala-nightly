set -e

SCALA_BRANCH="$1"
SCALAJS_BRANCH="$2"

SCALA_VERSION=$(wget -q -O - https://raw.githubusercontent.com/scala/community-builds/$SCALA_BRANCH/nightly.properties | grep '^nightly=' | cut -d '=' -f2)
SUFFIX=$(echo $SCALA_BRANCH | tr '.' '_' | cut -d '_' -f1-2)
COMPACT_SUFFIX=$(echo $SUFFIX | tr -d '_')

echo "Scala branch: $SCALA_BRANCH"
echo "Scala version: $SCALA_VERSION"
echo "Project suffix: $SUFFIX"
echo "Scala.js branch: $SCALAJS_BRANCH"

case $SCALAJS_BRANCH in
  main)
    TESTS="helloworld$SUFFIX/run testSuite$SUFFIX/test testSuiteJVM$SUFFIX/test ir$SUFFIX/test irJS$SUFFIX/test set~linker.v$SUFFIX/Test/testOptions+=Tests.Filter(_!="'"'"org.scalajs.linker.BackwardsCompatTest"'"'");linker$SUFFIX/testOnly~--~-v"
    ;;
  *)
    echo "Unknown Scala.js branch $SCALAJS_BRANCH"
    exit 1
esac

echo "Tests:" $TESTS

export SBT_OPTS='-Xmx6g -Xms1g -Xss4m'

rm -rf scala-js/
git clone https://github.com/scala-js/scala-js.git
cd scala-js
git checkout $SCALAJS_BRANCH
npm install

for TESTRAW in $TESTS; do
  TEST=$(echo $TESTRAW | tr '~' ' ')
  echo "RUNNING test '$TEST'..."
  sbt 'set resolvers in Global += "scala-integration" at "https://scala-ci.typesafe.com/artifactory/scala-integration/"' "set ThisBuild / cross${COMPACT_SUFFIX}ScalaVersions += \"$SCALA_VERSION\"" "$TEST"
done
