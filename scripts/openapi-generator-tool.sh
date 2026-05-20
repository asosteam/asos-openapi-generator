#!/bin/sh

# Ensure Java 11 is used for this script
JAVA11_HOME=$(/usr/libexec/java_home -v 11 2>/dev/null)
if [ -z "$JAVA11_HOME" ]; then
    echo "Error: Java 11 is not installed."
    echo ""
    echo "This project requires Java 11 to build. Install it with:"
    echo "  brew install openjdk@11"
    echo ""
    echo "After installation, you may need to symlink it:"
    echo "  sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk"
    exit 1
fi
export JAVA_HOME="$JAVA11_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

# Resolve the directory the script lives in, regardless of where it is called from
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Default values
PROJECT_PATH="$SCRIPT_DIR/.."
OUTPUT_FOLDER="$SCRIPT_DIR/../out"
GENERATOR_NAME="swift5"
INPUT_SPEC=""
TEMPLATE_FOLDER=""
IGNORE_BUILD=false
PUBLIC_MEMBERWISE_INIT=false

# Function to display usage
usage() {
    echo "Usage: sh openapi-generator-tool.sh -i input_spec"
    echo "Options:"
    echo "  -p                 Path to the project (default: ..)"
    echo "  -o                 Output folder (default: ../output)"
    echo "  -g                 Generator name (default: swift5)"
    echo "  -i                 Input specification file (mandatory)"
    echo '  -t                 Template directory (defaut: empty)'
    echo "  --public-memberwise-init  Add public memberwise initializer extension (default: false)"
    echo "  --ignore-build     Ignore the build process (default: false)"
    echo "  --help             Display this help message"
    exit 1
}

# Parse command-line arguments
while [ "$1" != "" ]; do
    case $1 in
        -p ) shift
             PROJECT_PATH=$1
             ;;
        -o ) shift
             OUTPUT_FOLDER=$1
             ;;
        -g ) shift
             GENERATOR_NAME=$1
             ;;
        -i ) shift
             INPUT_SPEC=$1
             ;;
        -t ) shift
             TEMPLATE_FOLDER=$1
             ;;
        --public-memberwise-init ) PUBLIC_MEMBERWISE_INIT=true
             ;;
        --ignore-build ) IGNORE_BUILD=true
             ;;
        --help ) usage
             ;;
        * ) usage
             ;;
    esac
    shift
done

# Check if the mandatory -i option is provided
if [ -z $INPUT_SPEC ]; then
    echo "Error: -i input_spec is required"
    usage
fi

# Clean and build main project if needed
if [ $IGNORE_BUILD = false ] ; then
    echo "Building the project..."
    mvn clean -f $PROJECT_PATH/pom.xml
    mvn package -f $PROJECT_PATH/pom.xml
fi

PROJECT_JAR_PATH=$PROJECT_PATH/modules/openapi-generator-cli/target/openapi-generator-cli.jar
rm -rf $OUTPUT_FOLDER

# Build the java command
JAVA_CMD="java -jar $PROJECT_JAR_PATH generate \
    --generator-name $GENERATOR_NAME \
    --input-spec $INPUT_SPEC \
    --output $OUTPUT_FOLDER/generated \
    --global-property models \
    --skip-validate-spec"

# Append --template-dir if TEMPLATE_FOLDER is not empty
if [ -n "$TEMPLATE_FOLDER" ]; then
    JAVA_CMD="$JAVA_CMD --template-dir $TEMPLATE_FOLDER"
fi

# Append --additional-properties if PUBLIC_MEMBERWISE_INIT is true
if [ "$PUBLIC_MEMBERWISE_INIT" = true ]; then
    JAVA_CMD="$JAVA_CMD --additional-properties publicMemberwiseInit=true"
fi

# Execute the java command
$JAVA_CMD
