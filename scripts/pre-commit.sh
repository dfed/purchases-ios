#!/bin/bash

# Figure out where swiftlint is
SWIFT_LINT="swift package plugin swiftlint"

# Start timer
START_DATE=$(date +"%s")
SHOULD_FAIL_PRECOMMIT=0

# Run SwiftLint for given filename
run_swiftlint() {
  local filename="${1}"
  if [[ "${filename##*.}" == "swift" ]]; then
    if [[ "${filename#*.}" != "generated.swift" ]]; then
    ${SWIFT_LINT} --strict "${filename}"
    retVal=$?
    if [ $retVal -ne 0 ]; then
      SHOULD_FAIL_PRECOMMIT=$retVal
    fi

    ${SWIFT_LINT} --autocorrect --strict "${filename}"
    fi
  fi
}

verify_no_included_apikeys() {
  # readlink -f follows the link from .git/hooks/pre-commit back to scripts/pre-commit.sh
  # if executed through there. If not it returns the same file.
  SCRIPT_DIR=$(cd $(dirname $(readlink -f "${BASH_SOURCE[0]}")) && pwd)
  FILES_TO_CHECK=(
    "${SCRIPT_DIR}/../Tests/BackendIntegrationTests/Constants.swift"
    "${SCRIPT_DIR}/../Examples/MagicWeather/MagicWeather/Constants.swift"
    "${SCRIPT_DIR}/../Examples/MagicWeatherSwiftUI/Shared/Constants.swift"
    "${SCRIPT_DIR}/../Tests/TestingApps/PurchaseTesterSwiftUI/Core/Constants.swift"
    "${SCRIPT_DIR}/../Tests/TestingApps/PaywallsTester/PaywallsTester/Config/LocalConfigItems.swift"
  )
  FILES_STAGED=$(git diff --cached --name-only)
  PATTERN="\"REVENUECAT_API_KEY\""

  for staged_file in $FILES_STAGED
  do
    absolute_staged_file=$(realpath "$staged_file")
    for api_file in "${FILES_TO_CHECK[@]}"
    do
      absolute_api_file=$(realpath "$api_file")
      if [ $absolute_staged_file = $absolute_api_file ] && ! grep -q $PATTERN $absolute_staged_file; then
        echo "Leftover API Key found in '$(basename $absolute_staged_file)'. Please remove."
        exit 1
      fi
    done
  done
}

echo "SwiftLint version: $(${SWIFT_LINT} --version)"
# Run only if not merging
if ! git rev-parse -q --verify MERGE_HEAD; then 
  # Run for just staged files
  while IFS= read -r -d '' file; do
    run_swiftlint "${file}"
  done < <(git diff --cached --name-only -z)
fi

END_DATE=$(date +"%s")

DIFF=$(($END_DATE - $START_DATE))
echo "SwiftLint took $(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds to complete."

if [ $SHOULD_FAIL_PRECOMMIT -ne 0 ]; then
  echo "😵 Found formatting errors, some might have been autocorrected."
  echo ""
  echo "⚠️  Please run '${SWIFT_LINT} --autocorrect --strict' then check the changes were made and commit them. ⚠️"

  exit $SHOULD_FAIL_PRECOMMIT
else
  verify_no_included_apikeys
fi
