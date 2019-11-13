BRANCH="$1"

SCALA_VERSION=$(wget -q -O - https://raw.githubusercontent.com/scala/community-builds/$BRANCH/nightly.properties | grep '^nightly=' | cut -d '=' -f2)
SUFFIX=$(echo $BRANCH | tr '.' '_' | cut -d '_' -f1-2)

echo "Branch: $BRANCH"
echo "Scala version: $SCALA_VERSION"
echo "Project suffix: $SUFFIX"

rm -rf scala-js/ && \
git clone https://github.com/scala-js/scala-js.git && \
cd scala-js && \
git checkout master && \
npm install && \
sbt 'set resolvers in Global += "scala-integration" at "https://scala-ci.typesafe.com/artifactory/scala-integration/"' ++$SCALA_VERSION testSuite$SUFFIX/test testSuiteJVM$SUFFIX/test ir$SUFFIX/test irJS$SUFFIX/test linker$SUFFIX/test linkerJS$SUFFIX/test
