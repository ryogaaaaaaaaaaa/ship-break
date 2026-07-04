#!/usr/bin/env sh
set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
	echo "SHIP//BREAK VERIFY: FAIL"
	echo "Godot executable was not found. Set GODOT_BIN or install Godot."
	exit 1
fi

TMP_DIR="${TMPDIR:-/tmp}/ship-break-verify-$$"
mkdir -p "$TMP_DIR"
PROJECT_LOG="$TMP_DIR/project.log"
TEST_LOG="$TMP_DIR/tests.log"
PROJECT_GODOT_LOG="$TMP_DIR/project-godot.log"
TEST_GODOT_LOG="$TMP_DIR/tests-godot.log"

echo "SHIP//BREAK VERIFY"
echo "Godot: $("$GODOT_BIN" --version)"

if "$GODOT_BIN" --headless --log-file "$PROJECT_GODOT_LOG" --path "$PROJECT_ROOT" --script res://tools/launch_check.gd >"$PROJECT_LOG" 2>&1; then
	PROJECT_STATUS="PASS"
else
	PROJECT_STATUS="FAIL"
fi

if "$GODOT_BIN" --headless --log-file "$TEST_GODOT_LOG" --path "$PROJECT_ROOT" --script res://tests/test_runner.gd >"$TEST_LOG" 2>&1; then
	TEST_STATUS="PASS"
else
	TEST_STATUS="FAIL"
fi

TEST_SUMMARY="$(grep "Assertions:" "$TEST_LOG" || true)"

if [ "$PROJECT_STATUS" = "PASS" ] && [ "$TEST_STATUS" = "PASS" ]; then
	echo
	echo "SHIP//BREAK VERIFY: PASS"
	echo "Project startup:    PASS"
	if [ -n "$TEST_SUMMARY" ]; then
		echo "Automated tests:    PASS ($TEST_SUMMARY)"
	else
		echo "Automated tests:    PASS"
	fi
	echo "Content validation: NOT YET APPLICABLE"
	echo "Simulation:         NOT YET APPLICABLE"
	echo "Errors:             0"
	rm -rf "$TMP_DIR"
	exit 0
fi

echo
echo "SHIP//BREAK VERIFY: FAIL"
echo "Project startup:    $PROJECT_STATUS"
echo "Automated tests:    $TEST_STATUS"
echo
echo "--- Project startup output ---"
cat "$PROJECT_LOG"
echo
echo "--- Test output ---"
cat "$TEST_LOG"
rm -rf "$TMP_DIR"
exit 1
