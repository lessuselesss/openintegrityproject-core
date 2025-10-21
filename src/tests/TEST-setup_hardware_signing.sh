#!/usr/bin/env zsh
########################################################################
## Script:        TEST-setup_hardware_signing.sh
## Version:       0.1.00 (2025-10-21)
## Origin:        https://github.com/OpenIntegrityProject/core/blob/main/src/tests/TEST-setup_hardware_signing.sh
## Description:   Tests the setup_hardware_signing.sh script for parameter
##                parsing, dependency checking, and error handling. Hardware
##                device operations are not tested as they require physical
##                security keys.
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Christopher Allen <ChristopherA@LifeWithAlacrity.com>
## Usage:         TEST-setup_hardware_signing.sh [-v|--verbose]
## Examples:      TEST-setup_hardware_signing.sh
##                TEST-setup_hardware_signing.sh --verbose
## Change Log:
##                0.1.00 (2025-10-21) - Initial release
##                * Test parameter parsing and validation
##                * Test dependency checking
##                * Test error handling for invalid inputs
##                * Note: Hardware operations not tested (require physical device)
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

# Script constants
typeset -r Script_Name=$(basename "$0")
typeset -r Script_Version="0.1.00"
typeset -r Script_Dir=$(dirname "$0:A")
typeset -r Repo_Root=$(realpath "${Script_Dir}/../..")

# Define TRUE/FALSE constants
typeset -r TRUE=1
typeset -r FALSE=0

# Script-scoped variables
typeset -r Target_Script="${Repo_Root}/src/setup_hardware_signing.sh"
typeset -r Sandbox_Dir="${Repo_Root}/sandbox"
typeset Test_Repo="${Sandbox_Dir}/test_repo"
typeset -i Verbose_Mode=$FALSE

# Script-scoped exit status codes
typeset -r Exit_Status_Success=0
typeset -r Exit_Status_General=1
typeset -r Exit_Status_Usage=2
typeset -r Exit_Status_Test_Failure=3
typeset -r Exit_Status_IO=3
typeset -r Exit_Status_Config=6

# Tracking variables
typeset -i Tests_Total=0
typeset -i Tests_Passed=0
typeset -i Tests_Failed=0
typeset -A test_results

#----------------------------------------------------------------------#
# Function: show_Usage
#----------------------------------------------------------------------#
# Description:
#   Displays usage information for the script
# Parameters:
#   None
# Returns:
#   Exits with Exit_Status_Usage
#----------------------------------------------------------------------#
show_Usage() {
    print "$Script_Name v$Script_Version - Test setup_hardware_signing.sh script"
    print ""
    print "Usage: $Script_Name [-v|--verbose]"
    print ""
    print "Options:"
    print "  -v, --verbose       Enable verbose output"
    print "  -h, --help          Show this help message"
    print ""
    print "Examples:"
    print "  $Script_Name        Run tests with standard output"
    print "  $Script_Name -v     Run tests with verbose output"
    print ""
    print "Note: This test script does NOT test actual hardware key generation,"
    print "      as that requires a physical FIDO2/U2F security device."
    exit $Exit_Status_Usage
}

#----------------------------------------------------------------------#
# Function: z_Setup_Test_Environment
#----------------------------------------------------------------------#
# Description:
#   Creates test environment for hardware signing tests
# Parameters:
#   None
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_General on failure
#----------------------------------------------------------------------#
z_Setup_Test_Environment() {
    print "Setting up test environment..."

    # Check if target script exists
    if [[ ! -f "$Target_Script" ]]; then
        print "❌ FAILED: Target script not found at: $Target_Script"
        return $Exit_Status_General
    fi

    # Make sure target script is executable
    chmod +x "$Target_Script"

    # Create a test git repository for local config tests
    print "Creating test git repository..."
    mkdir -p "$Test_Repo"
    (
        cd "$Test_Repo" || return $Exit_Status_General
        git init > /dev/null 2>&1
        git config user.name "Test User"
        git config user.email "test@example.com"
        touch README.md
        git add README.md
        git commit -m "Initial commit" > /dev/null 2>&1
    ) || {
        print "❌ FAILED: Could not create test repository"
        return $Exit_Status_General
    }

    print "Test environment setup completed"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Cleanup_Test_Directories
#----------------------------------------------------------------------#
# Description:
#   Removes test directories to ensure a clean test environment
# Parameters:
#   None
# Returns:
#   Exit_Status_Success on success
#----------------------------------------------------------------------#
z_Cleanup_Test_Directories() {
    print "Cleaning up test directories..."

    # Create parent directories if they don't exist
    if [[ ! -d "$(dirname "$Sandbox_Dir")" ]]; then
        mkdir -p "$(dirname "$Sandbox_Dir")"
    fi

    # Try to remove the directories
    rm -rf "$Sandbox_Dir" 2>/dev/null || {
        chmod -R 755 "$Sandbox_Dir" 2>/dev/null || true
        rm -rf "$Sandbox_Dir" 2>/dev/null || true
    }

    # Ensure test directories don't exist before creating them
    if [[ -d "$Sandbox_Dir" ]]; then
        print "Warning: Unable to fully remove existing test directory: $Sandbox_Dir"
        Sandbox_Dir="${Sandbox_Dir}-$(date +%s)"
    fi

    # Create fresh sandbox directory
    mkdir -p "$Sandbox_Dir" || {
        print "Error: Failed to create test base directory: $Sandbox_Dir"
        return $Exit_Status_General
    }

    # Update dependent paths
    Test_Repo="${Sandbox_Dir}/test_repo"

    print "Test directories prepared at $Sandbox_Dir"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Run_Test
#----------------------------------------------------------------------#
# Description:
#   Runs a single test and records the result
# Parameters:
#   $1 - Test name
#   $2 - Command to run
#   $3 - Expected exit code
#   $4 - Expected output pattern (optional)
# Returns:
#   Exit_Status_Success if test passes
#   Exit_Status_Test_Failure if test fails
#----------------------------------------------------------------------#
z_Run_Test() {
    typeset Test_Name="$1"
    typeset Test_Command="$2"
    typeset -i Expected_Exit_Code=$3
    typeset Expected_Output="${4:-}"

    (( Tests_Total++ ))

    if (( Verbose_Mode == TRUE )); then
        print "\n--- Test $Tests_Total: $Test_Name ---"
        print "Command: $Test_Command"
        print "Expected exit code: $Expected_Exit_Code"
        if [[ -n "$Expected_Output" ]]; then
            print "Expected output pattern: $Expected_Output"
        fi
    fi

    # Run the command and capture output and exit code
    typeset Test_Output
    typeset -i Test_Exit_Code

    Test_Output=$(eval "$Test_Command" 2>&1)
    Test_Exit_Code=$?

    if (( Verbose_Mode == TRUE )); then
        print "Actual exit code: $Test_Exit_Code"
        print "Output:\n$Test_Output"
    fi

    # Check exit code
    if (( Test_Exit_Code != Expected_Exit_Code )); then
        print "❌ FAILED: $Test_Name"
        print "   Expected exit code: $Expected_Exit_Code"
        print "   Actual exit code: $Test_Exit_Code"
        (( Tests_Failed++ ))
        test_results[$Test_Name]="FAILED (exit code)"
        return $Exit_Status_Test_Failure
    fi

    # Check output pattern if provided
    if [[ -n "$Expected_Output" ]]; then
        if ! print -- "$Test_Output" | grep -q "$Expected_Output"; then
            print "❌ FAILED: $Test_Name"
            print "   Expected output pattern not found: $Expected_Output"
            (( Tests_Failed++ ))
            test_results[$Test_Name]="FAILED (output)"
            return $Exit_Status_Test_Failure
        fi
    fi

    print "✅ PASSED: $Test_Name"
    (( Tests_Passed++ ))
    test_results[$Test_Name]="PASSED"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Help_And_Usage
#----------------------------------------------------------------------#
# Description:
#   Tests help and usage output
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Help_And_Usage() {
    print "\n===== Testing help and usage ====="

    z_Run_Test "Help option --help" \
        "\"$Target_Script\" --help 2>&1" \
        $Exit_Status_Usage \
        "Usage:"

    z_Run_Test "Help option -h" \
        "\"$Target_Script\" -h 2>&1" \
        $Exit_Status_Usage \
        "Usage:"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Parameter_Parsing
#----------------------------------------------------------------------#
# Description:
#   Tests parameter parsing and validation
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Parameter_Parsing() {
    print "\n===== Testing parameter parsing ====="

    z_Run_Test "Invalid key type" \
        "\"$Target_Script\" --key-type invalid --no-prompt 2>&1" \
        $Exit_Status_Usage \
        "Invalid key type"

    z_Run_Test "Invalid git scope" \
        "\"$Target_Script\" --git-scope invalid --no-prompt 2>&1" \
        $Exit_Status_Usage \
        "Invalid git scope"

    z_Run_Test "Unknown option" \
        "\"$Target_Script\" --invalid-option 2>&1" \
        $Exit_Status_Usage \
        "Unknown option"

    z_Run_Test "Missing key type value" \
        "\"$Target_Script\" --key-type 2>&1" \
        $Exit_Status_Usage \
        "Usage:"

    z_Run_Test "Missing output path value" \
        "\"$Target_Script\" --output 2>&1" \
        $Exit_Status_Usage \
        "Usage:"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Dependency_Checking
#----------------------------------------------------------------------#
# Description:
#   Tests dependency checking (note: actual dependencies must exist)
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Dependency_Checking() {
    print "\n===== Testing dependency checking ====="

    # Check that script fails gracefully when dependencies are missing
    # Note: We can't actually remove dependencies in the test environment,
    # so we just verify the script checks for them

    print "Note: Dependency checking tests verify error messages are correct"
    print "      Actual dependency availability tests require isolated environment"

    # Test with a non-existent directory for local config
    z_Run_Test "Non-existent directory for local config" \
        "\"$Target_Script\" --git-scope local -C /nonexistent/path --no-prompt 2>&1" \
        $Exit_Status_IO \
        "does not exist"

    # Test with a directory that's not a git repository
    typeset Not_A_Repo="${Sandbox_Dir}/not_a_repo"
    mkdir -p "$Not_A_Repo"

    z_Run_Test "Non-git directory for local config" \
        "\"$Target_Script\" --git-scope local -C \"$Not_A_Repo\" --no-prompt 2>&1" \
        $Exit_Status_Git_Failure \
        "Not a Git repository"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Valid_Parameter_Combinations
#----------------------------------------------------------------------#
# Description:
#   Tests valid parameter combinations (without actual hardware)
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Valid_Parameter_Combinations() {
    print "\n===== Testing valid parameter combinations ====="

    print "Note: These tests check parameter validation only"
    print "      Actual hardware key generation requires physical device"
    print "      Tests will fail at device detection stage (expected)"

    # Test ed25519-sk key type parameter parsing
    z_Run_Test "Valid ed25519-sk key type (will fail at device detection)" \
        "\"$Target_Script\" --key-type ed25519-sk --no-prompt --output /tmp/test_key 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    # Test ecdsa-sk key type parameter parsing
    z_Run_Test "Valid ecdsa-sk key type (will fail at device detection)" \
        "\"$Target_Script\" --key-type ecdsa-sk --no-prompt --output /tmp/test_key 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    # Test local git scope parameter parsing
    z_Run_Test "Valid local git scope (will fail at device detection)" \
        "\"$Target_Script\" --git-scope local -C \"$Test_Repo\" --no-prompt --output /tmp/test_key 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    # Test global git scope parameter parsing
    z_Run_Test "Valid global git scope (will fail at device detection)" \
        "\"$Target_Script\" --git-scope global --no-prompt --output /tmp/test_key 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Display_Summary
#----------------------------------------------------------------------#
# Description:
#   Displays test summary
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests passed
#   Exit_Status_Test_Failure if any tests failed
#----------------------------------------------------------------------#
z_Display_Summary() {
    print "\n========================================="
    print "Test Summary"
    print "========================================="
    print "Total tests:  $Tests_Total"
    print "Passed:       $Tests_Passed"
    print "Failed:       $Tests_Failed"
    print "========================================="

    if (( Tests_Failed > 0 )); then
        print "\nFailed tests:"
        for Test_Name Result in "${(@kv)test_results}"; do
            if [[ "$Result" == FAILED* ]]; then
                print "  - $Test_Name: $Result"
            fi
        done
        return $Exit_Status_Test_Failure
    fi

    print "\n✅ All tests passed!"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: parse_Parameters
#----------------------------------------------------------------------#
# Description:
#   Parses command line parameters
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success on success
#----------------------------------------------------------------------#
parse_Parameters() {
    while (( $# > 0 )); do
        case "$1" in
            -v|--verbose)
                Verbose_Mode=$TRUE
                shift
                ;;
            -h|--help)
                show_Usage
                ;;
            *)
                print "Error: Unknown option '$1'"
                show_Usage
                ;;
        esac
    done

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Main test execution function
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success if all tests pass
#   Exit_Status_Test_Failure if any tests fail
#----------------------------------------------------------------------#
main() {
    # Parse parameters
    parse_Parameters "$@" || exit $?

    print "======================================"
    print "setup_hardware_signing.sh Test Suite"
    print "======================================"
    print "Version: $Script_Version"
    print "Target: $Target_Script"
    print ""

    # Clean up and set up test environment
    z_Cleanup_Test_Directories || exit $?
    z_Setup_Test_Environment || exit $?

    # Run test suites
    test_Help_And_Usage || true
    test_Parameter_Parsing || true
    test_Dependency_Checking || true
    test_Valid_Parameter_Combinations || true

    # Display summary and exit
    z_Display_Summary
    typeset -i Summary_Exit=$?

    # Cleanup
    print "\nCleaning up test environment..."
    rm -rf "$Sandbox_Dir" 2>/dev/null || true

    exit $Summary_Exit
}

########################################################################
## Script Entry Point
########################################################################

# Execute only if run directly (not sourced)
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
fi
