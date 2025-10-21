#!/usr/bin/env zsh
########################################################################
## Script:        TEST-setup_git_inception_repo_hardware.sh
## Version:       0.1.00 (2025-10-21)
## Origin:        https://github.com/OpenIntegrityProject/core/blob/main/src/tests/TEST-setup_git_inception_repo_hardware.sh
## Description:   Tests the setup_git_inception_repo_hardware.sh script
##                for parameter parsing, dependency checking, and error
##                handling. Hardware device operations and inception commit
##                creation are not tested as they require physical security
##                keys.
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Christopher Allen <ChristopherA@LifeWithAlacrity.com>
## Usage:         TEST-setup_git_inception_repo_hardware.sh [-v|--verbose]
## Examples:      TEST-setup_git_inception_repo_hardware.sh
##                TEST-setup_git_inception_repo_hardware.sh --verbose
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
typeset -r Target_Script="${Repo_Root}/src/setup_git_inception_repo_hardware.sh"
typeset -r Sandbox_Dir="${Repo_Root}/sandbox"
typeset Test_Repo_Dir="${Sandbox_Dir}/test_repos"
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
    print "$Script_Name v$Script_Version - Test setup_git_inception_repo_hardware.sh script"
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
    print "Note: This test script does NOT test actual hardware key generation"
    print "      or inception commit creation, as those require a physical"
    print "      FIDO2/U2F security device."
    exit $Exit_Status_Usage
}

#----------------------------------------------------------------------#
# Function: z_Setup_Test_Environment
#----------------------------------------------------------------------#
# Description:
#   Creates test environment for integrated setup tests
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

    # Create test repository directory
    mkdir -p "$Test_Repo_Dir"

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
    Test_Repo_Dir="${Sandbox_Dir}/test_repos"

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

    z_Run_Test "Missing repo path value" \
        "\"$Target_Script\" --repo 2>&1" \
        $Exit_Status_Usage \
        "Usage:"

    z_Run_Test "Missing name value" \
        "\"$Target_Script\" --name 2>&1" \
        $Exit_Status_Usage \
        "Usage:"

    z_Run_Test "Missing email value" \
        "\"$Target_Script\" --email 2>&1" \
        $Exit_Status_Usage \
        "Usage:"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Repository_Path_Validation
#----------------------------------------------------------------------#
# Description:
#   Tests repository path handling
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Repository_Path_Validation() {
    print "\n===== Testing repository path validation ====="

    # Create a test directory that already has a git repo
    typeset Existing_Repo="${Test_Repo_Dir}/existing_repo"
    mkdir -p "$Existing_Repo"
    (cd "$Existing_Repo" && git init > /dev/null 2>&1)

    z_Run_Test "Repository already exists without force" \
        "\"$Target_Script\" --repo \"$Existing_Repo\" --no-prompt 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Combined_Parameters
#----------------------------------------------------------------------#
# Description:
#   Tests combined parameters from both workflows
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Combined_Parameters() {
    print "\n===== Testing combined parameter handling ====="

    print "Note: These tests verify parameter combinations are accepted"
    print "      Actual execution will fail at device detection (expected)"

    z_Run_Test "Combined repo and key type" \
        "\"$Target_Script\" --repo /tmp/test_repo --key-type ed25519-sk --no-prompt 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    z_Run_Test "Combined with git config" \
        "\"$Target_Script\" --repo /tmp/test_repo --name \"Test\" --email \"test@example.com\" --no-prompt 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    z_Run_Test "Combined with resident key" \
        "\"$Target_Script\" --repo /tmp/test_repo --resident --no-prompt 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    z_Run_Test "Combined with force flag" \
        "\"$Target_Script\" --repo /tmp/test_repo --force --no-prompt 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Execution_Modes
#----------------------------------------------------------------------#
# Description:
#   Tests execution mode parameters
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Execution_Modes() {
    print "\n===== Testing execution mode parameters ====="

    print "Note: Testing that mode flags are accepted"
    print "      Actual workflow will fail at device detection"

    z_Run_Test "Verbose mode accepted" \
        "\"$Target_Script\" --verbose --repo /tmp/test_repo --no-prompt 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    z_Run_Test "Debug mode accepted" \
        "\"$Target_Script\" --debug --repo /tmp/test_repo --no-prompt 2>&1" \
        $Exit_Status_Config \
        "Cannot continue in non-interactive mode"

    z_Run_Test "Quiet mode accepted" \
        "\"$Target_Script\" --quiet --repo /tmp/test_repo --no-prompt 2>&1" \
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

    print "==============================================="
    print "setup_git_inception_repo_hardware.sh Test Suite"
    print "==============================================="
    print "Version: $Script_Version"
    print "Target: $Target_Script"
    print ""

    # Clean up and set up test environment
    z_Cleanup_Test_Directories || exit $?
    z_Setup_Test_Environment || exit $?

    # Run test suites
    test_Help_And_Usage || true
    test_Parameter_Parsing || true
    test_Repository_Path_Validation || true
    test_Combined_Parameters || true
    test_Execution_Modes || true

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
