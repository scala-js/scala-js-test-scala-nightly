SCALA_BRANCH="$1"
SCALAJS_BRANCH="$2"

SCALA_VERSION=$(wget -q -O - https://raw.githubusercontent.com/scala/community-builds/$SCALA_BRANCH/nightly.properties | grep '^nightly=' | cut -d '=' -f2)
SUFFIX=$(echo $SCALA_BRANCH | tr '.' '_' | cut -d '_' -f1-2)

echo "Scala branch: $SCALA_BRANCH"
echo "Scala version: $SCALA_VERSION"
echo "Project suffix: $SUFFIX"
echo "Scala.js branch: $SCALAJS_BRANCH"

case $SCALAJS_BRANCH in
  master)
    TESTS="testSuite$SUFFIX/test testSuiteJVM$SUFFIX/test ir$SUFFIX/test irJS$SUFFIX/test linker$SUFFIX/test linkerJS$SUFFIX/test"
    ;;
  *)
    echo "Unknown Scala.js branch $SCALAJS_BRANCH"
    exit 1
esac

echo "Tests:" $TESTS

rm -rf scala-js/ && \
git clone https://github.com/scala-js/scala-js.git && \
cd scala-js && \
git checkout $SCALAJS_BRANCH && \
npm install && \
sbt 'set resolvers in Global += "scala-integration" at "https://scala-ci.typesafe.com/artifactory/scala-integration/"' ++$SCALA_VERSION $TESTS
