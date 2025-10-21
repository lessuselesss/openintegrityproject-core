#!/usr/bin/env zsh
########################################################################
## Script:        setup_hardware_signing.sh
## Version:       0.1.00 (2025-10-21)
## Origin:        https://github.com/OpenIntegrityProject/core/blob/main/src/setup_hardware_signing.sh
## Description:   Configures hardware security key (Flipper Zero, YubiKey,
##                FIDO2/U2F) SSH signing for Git commits. Generates hardware-
##                backed SSH keys, configures ssh-agent, and sets up Git to
##                use SSH signing with hardware keys for cryptographic commit
##                verification.
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Christopher Allen <ChristopherA@LifeWithAlacrity.com>
##
## FEATURES:
##   - Hardware Device Support:
##     * Flipper Zero (U2F/FIDO)
##     * YubiKey (FIDO2/U2F)
##     * Generic FIDO2/U2F security keys
##     * Trezor/Ledger (via FIDO2/U2F)
##
##   - Key Types:
##     * ed25519-sk (FIDO2) - recommended for modern devices
##     * ecdsa-sk (U2F) - compatible with older devices like Flipper Zero
##
##   - Execution Modes:
##     * Interactive mode with prompts and guidance
##     * Non-interactive mode for automation/scripting
##     * Verbose and debug output options
##
##   - SSH Agent Management:
##     * Automatic ssh-agent discovery and setup
##     * Socket reuse to avoid duplicate agents
##     * Persistent agent configuration guidance
##
##   - Git Configuration:
##     * Automatic Git config for SSH signing
##     * Support for both local and global Git configs
##     * Verification of configuration correctness
##
## USAGE: setup_hardware_signing.sh [OPTIONS]
##
## OPTIONS:
##   -k, --key-type <type>     Key type: ed25519-sk (FIDO2) or ecdsa-sk (U2F)
##                             Default: ed25519-sk
##   -o, --output <path>       Output path for private key (without .pub)
##                             Default: ~/.ssh/id_<keytype>_hardware
##   -r, --resident            Create resident key (stored on device)
##   -g, --git-scope <scope>   Git config scope: local or global
##                             Default: global
##   -n, --name <name>         Git user.name for configuration
##   -e, --email <email>       Git user.email for configuration
##   -C, --chdir <path>        Change to directory (for local git config)
##   -v, --verbose             Enable detailed output
##   -d, --debug               Show debugging information
##   -p, --no-prompt           Run non-interactively (no prompts)
##   -i, --interactive         Force interactive prompts
##   -h, --help                Show this help message
##
## EXAMPLES:
##   # Interactive setup with YubiKey (FIDO2):
##   setup_hardware_signing.sh
##
##   # Flipper Zero (U2F) with specific output path:
##   setup_hardware_signing.sh --key-type ecdsa-sk --output ~/.ssh/flipper_key
##
##   # Resident key for passwordless authentication:
##   setup_hardware_signing.sh --resident --key-type ed25519-sk
##
##   # Non-interactive setup for automation:
##   setup_hardware_signing.sh --no-prompt --key-type ed25519-sk \
##     --name "CI Bot" --email "ci@example.com"
##
##   # Local Git config in specific repository:
##   setup_hardware_signing.sh --git-scope local -C /path/to/repo
##
## REQUIREMENTS:
##   - Zsh 5.8 or later
##   - Git 2.34 or later (SSH signing support)
##   - OpenSSH 8.2 or later (FIDO2/U2F support)
##   - Hardware security key (Flipper Zero, YubiKey, etc.)
##   - USB connection to security device
##
## SECURITY CONSIDERATIONS:
##   - Hardware keys provide stronger security than software keys
##   - Private keys never leave the hardware device
##   - Requires physical device presence for each signature
##   - PIN may be required depending on device configuration
##   - Resident keys are discoverable but require device PIN
##   - Non-resident keys require private key handle storage
##
## LICENSE:
##   (c) 2025 By Blockchain Commons LLC
##   https://www.BlockchainCommons.com
##   Licensed under BSD-2-Clause Plus Patent License
##   https://spdx.org/licenses/BSD-2-Clause-Patent.html
##
## PORTIONS:
##   Z_Utils Functions:
##   Z_Utils - ZSH Utility Scripts
##   - <https://github.com/ChristopherA/Z_Utils>
##   - <did:repo:e649e2061b945848e53ff369485b8dd182747991>
##   (c) 2025 Christopher Allen
##   Licensed under BSD-2-Clause Plus Patent License
##
## PART OF:
##   Open Integrity Project of Blockchain Commons LLC.
##   - Open Integrity Core
##     - <https://github.com/OpenIntegrityProject/core>
##     - <did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6>
########################################################################

########################################################################
## CHANGE LOG
########################################################################
## 0.1.00   - Initial Release (2025-10-21)
##          - Hardware device SSH signing support for Git commits
##          - Support for Flipper Zero (ecdsa-sk/U2F)
##          - Support for YubiKey and generic FIDO2 devices (ed25519-sk)
##          - Interactive and non-interactive execution modes
##          - Automatic ssh-agent discovery and configuration
##          - Git configuration for SSH signing
##          - Resident and non-resident key generation
##          - Comprehensive error handling and validation
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

########################################################################
## SECTION: Foundation Layer - Constants and Variables
##--------------------------------------------------------------------##
## Description:
##   Core constants, exit status codes, and script-level variables
##   required for script initialization and execution flow control.
########################################################################

#----------------------------------------------------------------------#
# Script Version and Metadata
#----------------------------------------------------------------------#
typeset -r Script_Name="setup_hardware_signing.sh"
typeset -r Script_Version="0.1.00"
typeset -r Script_Date="2025-10-21"

#----------------------------------------------------------------------#
# Exit Status Codes
#----------------------------------------------------------------------#
typeset -r Exit_Status_Success=0            # Successful execution
typeset -r Exit_Status_General=1            # General error
typeset -r Exit_Status_Usage=2              # Invalid usage/arguments
typeset -r Exit_Status_IO=3                 # Input/output error
typeset -r Exit_Status_Git_Failure=5        # Git operation error
typeset -r Exit_Status_Config=6             # Configuration error
typeset -r Exit_Status_Dependency=127       # Missing dependency

#----------------------------------------------------------------------#
# Boolean Constants
#----------------------------------------------------------------------#
typeset -r TRUE=1
typeset -r FALSE=0

#----------------------------------------------------------------------#
# Script-Scoped Variables
#----------------------------------------------------------------------#
# Output control
typeset Output_Verbose=$FALSE
typeset Output_Debug=$FALSE
typeset Output_Quiet=$FALSE
typeset Output_Prompt_Enabled=$TRUE
typeset Color_Enabled=$FALSE  # Will be set during environment setup

# Key generation parameters
typeset Key_Type="ed25519-sk"  # Default to FIDO2
typeset Key_Path=""            # Will be set based on key type if not specified
typeset Resident_Key=$FALSE
typeset Git_Scope="global"     # local or global
typeset Git_Name=""
typeset Git_Email=""
typeset Repo_Directory="."     # For local Git config

# Resource tracking
typeset -a Created_Files=()    # Track files created for cleanup
typeset SSH_Agent_Socket=""    # Track ssh-agent socket

########################################################################
## SECTION: Utility Layer - Z_Utils Integration
##--------------------------------------------------------------------##
## Description:
##   Sources the Z_Utils library to provide standardized utility
##   functions for output formatting, error handling, ssh-agent
##   management, and hardware key operations.
########################################################################

#----------------------------------------------------------------------#
# Locate and Source Z_Utils Library
#----------------------------------------------------------------------#
# Determine the script's directory to find _Z_Utils.zsh
typeset Script_Dir="${${(%):-%N}:A:h}"
typeset Z_Utils_Path="${Script_Dir}/lib/_Z_Utils.zsh"

if [[ ! -r "$Z_Utils_Path" ]]; then
    print -u2 "Error: Cannot find Z_Utils library at: $Z_Utils_Path"
    print -u2 "This script requires the Z_Utils library to function."
    exit $Exit_Status_Dependency
fi

# Source the Z_Utils library
source "$Z_Utils_Path"

# Verify critical Z_Utils functions are available
typeset -a Required_Functions=(
    z_Output
    z_Report_Error
    z_Check_SSH_Agent
    z_Setup_SSH_Agent
    z_Generate_Hardware_SSH_Key
    z_Add_Key_To_SSH_Agent
    z_Verify_Hardware_Key
    z_Detect_FIDO_Devices
)

for Func in "${Required_Functions[@]}"; do
    if ! typeset -f "$Func" > /dev/null; then
        print -u2 "Error: Required Z_Utils function '$Func' not found"
        print -u2 "Please ensure _Z_Utils.zsh is up to date"
        exit $Exit_Status_Dependency
    fi
done

########################################################################
## SECTION: Domain Layer - Hardware Signing Setup Functions
##--------------------------------------------------------------------##
## Description:
##   Domain-specific functions for hardware signing setup, including
##   key generation, agent configuration, and Git setup.
########################################################################

#----------------------------------------------------------------------#
# Function: show_Usage
#----------------------------------------------------------------------#
# Description:
#   Displays usage information and exits
# Parameters:
#   None
# Returns:
#   Does not return - exits with Exit_Status_Usage
#----------------------------------------------------------------------#
show_Usage() {
    print -u2 "Usage: $Script_Name [OPTIONS]

OPTIONS:
  -k, --key-type <type>     Key type: ed25519-sk (FIDO2) or ecdsa-sk (U2F)
  -o, --output <path>       Output path for private key
  -r, --resident            Create resident key
  -g, --git-scope <scope>   Git config scope: local or global
  -n, --name <name>         Git user.name
  -e, --email <email>       Git user.email
  -C, --chdir <path>        Change directory (for local config)
  -v, --verbose             Enable detailed output
  -d, --debug               Show debugging information
  -p, --no-prompt           Run non-interactively
  -i, --interactive         Force interactive prompts
  -h, --help                Show this help message

EXAMPLES:
  # Interactive setup with YubiKey (FIDO2):
  $Script_Name

  # Flipper Zero (U2F) setup:
  $Script_Name --key-type ecdsa-sk

  # Resident key for passwordless:
  $Script_Name --resident

  # Non-interactive with Git config:
  $Script_Name --no-prompt --name \"Bot\" --email \"bot@example.com\"

For more information, see script header comments."
    exit $Exit_Status_Usage
}

#----------------------------------------------------------------------#
# Function: check_Dependencies
#----------------------------------------------------------------------#
# Description:
#   Verifies all required external commands are available
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all dependencies are met
#   Exit_Status_Dependency if any command is missing
#----------------------------------------------------------------------#
check_Dependencies() {
    typeset -a Required_Commands=(
        git
        ssh-keygen
        ssh-add
    )

    typeset Missing_Commands=()

    for Cmd in "${Required_Commands[@]}"; do
        if ! command -v "$Cmd" >/dev/null 2>&1; then
            Missing_Commands+=("$Cmd")
        fi
    done

    if (( ${#Missing_Commands[@]} > 0 )); then
        z_Report_Error "Missing required commands: ${Missing_Commands[*]}" $Exit_Status_Dependency
        z_Output error "Please install missing dependencies:"
        for Cmd in "${Missing_Commands[@]}"; do
            z_Output error "  - $Cmd"
        done
        return $Exit_Status_Dependency
    fi

    # Check OpenSSH version for FIDO support (8.2+)
    typeset SSH_Version
    SSH_Version=$(ssh-keygen -V 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)

    if [[ -z "$SSH_Version" ]]; then
        z_Output warn "Cannot determine ssh-keygen version"
        z_Output warn "OpenSSH 8.2+ required for FIDO2/U2F support"
    else
        # Simple version check (assuming format X.Y)
        typeset Major Minor
        Major=${SSH_Version%%.*}
        Minor=${SSH_Version#*.}

        if (( Major < 8 || (Major == 8 && Minor < 2) )); then
            z_Report_Error "OpenSSH version $SSH_Version is too old" $Exit_Status_Dependency
            z_Output error "OpenSSH 8.2 or later required for FIDO2/U2F support"
            z_Output error "Current version: $SSH_Version"
            return $Exit_Status_Dependency
        fi
    fi

    # Check Git version for SSH signing (2.34+)
    typeset Git_Version
    Git_Version=$(git --version | grep -oE '[0-9]+\.[0-9]+' | head -1)

    if [[ -n "$Git_Version" ]]; then
        typeset Major Minor
        Major=${Git_Version%%.*}
        Minor=${Git_Version#*.}

        if (( Major < 2 || (Major == 2 && Minor < 34) )); then
            z_Report_Error "Git version $Git_Version is too old" $Exit_Status_Dependency
            z_Output error "Git 2.34 or later required for SSH signing support"
            z_Output error "Current version: $Git_Version"
            return $Exit_Status_Dependency
        fi
    fi

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: setup_Hardware_Key
#----------------------------------------------------------------------#
# Description:
#   Generates a hardware-backed SSH key using Z_Utils function
# Parameters:
#   None (uses script variables)
# Returns:
#   Exit_Status_Success and sets Key_Path_Public
#   Exit_Status_* on error
#----------------------------------------------------------------------#
setup_Hardware_Key() {
    z_Output info "Generating hardware-backed SSH key..."
    z_Output info "Key type: $Key_Type"
    z_Output info "Output path: $Key_Path"

    if (( Resident_Key == TRUE )); then
        z_Output info "Creating resident key (stored on device)"
        z_Output warn "You may be prompted for a device PIN"
    fi

    z_Output warn "Please touch your security device when prompted"

    # Generate key using Z_Utils function
    typeset Resident_Flag=""
    if (( Resident_Key == TRUE )); then
        Resident_Flag="resident"
    fi

    typeset Public_Key_Path
    Public_Key_Path=$(z_Generate_Hardware_SSH_Key "$Key_Type" "$Key_Path" "$Resident_Flag") || return $?

    # Track created files for potential cleanup
    Created_Files+=("$Key_Path" "$Public_Key_Path")

    z_Output success "Hardware SSH key generated successfully"
    z_Output info "Private key: $Key_Path"
    z_Output info "Public key: $Public_Key_Path"

    # Store public key path in script variable
    Key_Path_Public="$Public_Key_Path"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: setup_SSH_Agent_Integration
#----------------------------------------------------------------------#
# Description:
#   Ensures ssh-agent is running and adds hardware key to it
# Parameters:
#   None (uses script variables)
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_* on error
#----------------------------------------------------------------------#
setup_SSH_Agent_Integration() {
    z_Output info "Setting up ssh-agent integration..."

    # Set up or discover ssh-agent
    SSH_Agent_Socket=$(z_Setup_SSH_Agent) || return $?

    z_Output success "ssh-agent is ready"
    z_Output debug "Agent socket: $SSH_Agent_Socket"

    # Add hardware key to agent
    z_Output info "Adding hardware key to ssh-agent..."
    z_Output warn "You may need to touch your security device"

    z_Add_Key_To_SSH_Agent "$Key_Path" || return $?

    z_Output success "Hardware key added to ssh-agent"

    # Verify key is accessible
    z_Output info "Verifying hardware key accessibility..."
    z_Verify_Hardware_Key "$Key_Path_Public" || return $?

    z_Output success "Hardware key is accessible via ssh-agent"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: setup_Git_Configuration
#----------------------------------------------------------------------#
# Description:
#   Configures Git to use SSH signing with hardware key
# Parameters:
#   None (uses script variables)
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_* on error
#----------------------------------------------------------------------#
setup_Git_Configuration() {
    z_Output info "Configuring Git for SSH signing..."

    typeset Git_Config_Scope
    if [[ "$Git_Scope" == "local" ]]; then
        Git_Config_Scope="--local"
        z_Output info "Configuring local Git repository: $Repo_Directory"
    else
        Git_Config_Scope="--global"
        z_Output info "Configuring global Git settings"
    fi

    # Set signing format to SSH
    git -C "$Repo_Directory" config $Git_Config_Scope gpg.format ssh || return $?
    z_Output success "Set gpg.format to ssh"

    # Set signing key to public key literal
    typeset Public_Key_Content
    Public_Key_Content=$(<"$Key_Path_Public")
    git -C "$Repo_Directory" config $Git_Config_Scope user.signingkey "key::${Public_Key_Content}" || return $?
    z_Output success "Set user.signingkey to hardware key"

    # Enable automatic signing
    git -C "$Repo_Directory" config $Git_Config_Scope commit.gpgsign true || return $?
    z_Output success "Enabled automatic commit signing"

    # Set user name and email if provided
    if [[ -n "$Git_Name" ]]; then
        git -C "$Repo_Directory" config $Git_Config_Scope user.name "$Git_Name" || return $?
        z_Output success "Set user.name to: $Git_Name"
    fi

    if [[ -n "$Git_Email" ]]; then
        git -C "$Repo_Directory" config $Git_Config_Scope user.email "$Git_Email" || return $?
        z_Output success "Set user.email to: $Git_Email"
    fi

    z_Output success "Git configuration complete"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: display_Summary
#----------------------------------------------------------------------#
# Description:
#   Shows summary of setup and next steps
# Parameters:
#   None (uses script variables)
# Returns:
#   Exit_Status_Success
#----------------------------------------------------------------------#
display_Summary() {
    z_Output success "Hardware signing setup complete!"
    z_Output info ""
    z_Output info "Summary:"
    z_Output info "  Key type: $Key_Type"
    z_Output info "  Key location: $Key_Path"
    z_Output info "  Git scope: $Git_Scope"

    if (( Resident_Key == TRUE )); then
        z_Output info "  Resident key: Yes (stored on device)"
    else
        z_Output info "  Resident key: No (requires key handle file)"
    fi

    z_Output info ""
    z_Output info "Next steps:"
    z_Output info "  1. Your commits will now be automatically signed"
    z_Output info "  2. Keep your hardware device accessible when committing"
    z_Output info "  3. Back up your public key: $Key_Path_Public"

    if (( Resident_Key == FALSE )); then
        z_Output warn "  4. Back up your private key handle: $Key_Path"
        z_Output warn "     (Required to use this key on other machines)"
    fi

    z_Output info ""
    z_Output info "To verify a commit signature:"
    z_Output info "  git verify-commit <commit-hash>"

    z_Output info ""
    z_Output info "To persist ssh-agent across sessions, add to your shell profile:"
    z_Output info "  eval \$(ssh-agent -s)"
    z_Output info "  ssh-add $Key_Path"

    return $Exit_Status_Success
}

########################################################################
## SECTION: Orchestration Layer - Workflow Control
##--------------------------------------------------------------------##
## Description:
##   Parameter parsing and workflow sequencing
########################################################################

#----------------------------------------------------------------------#
# Function: parse_Parameters
#----------------------------------------------------------------------#
# Description:
#   Processes command line arguments
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_Usage on invalid arguments
#----------------------------------------------------------------------#
parse_Parameters() {
    while (( $# > 0 )); do
        case "$1" in
            -k|--key-type)
                (( $# > 1 )) || show_Usage
                Key_Type="$2"
                if [[ "$Key_Type" != "ed25519-sk" && "$Key_Type" != "ecdsa-sk" ]]; then
                    print -u2 "Error: Invalid key type '$Key_Type'"
                    print -u2 "Must be 'ed25519-sk' (FIDO2) or 'ecdsa-sk' (U2F)"
                    show_Usage
                fi
                shift 2
                ;;
            -o|--output)
                (( $# > 1 )) || show_Usage
                Key_Path="$2"
                shift 2
                ;;
            -r|--resident)
                Resident_Key=$TRUE
                shift
                ;;
            -g|--git-scope)
                (( $# > 1 )) || show_Usage
                Git_Scope="$2"
                if [[ "$Git_Scope" != "local" && "$Git_Scope" != "global" ]]; then
                    print -u2 "Error: Invalid git scope '$Git_Scope'"
                    print -u2 "Must be 'local' or 'global'"
                    show_Usage
                fi
                shift 2
                ;;
            -n|--name)
                (( $# > 1 )) || show_Usage
                Git_Name="$2"
                shift 2
                ;;
            -e|--email)
                (( $# > 1 )) || show_Usage
                Git_Email="$2"
                shift 2
                ;;
            -C|--chdir)
                (( $# > 1 )) || show_Usage
                Repo_Directory="$2"
                shift 2
                ;;
            -v|--verbose)
                Output_Verbose=$TRUE
                shift
                ;;
            -d|--debug)
                Output_Debug=$TRUE
                Output_Verbose=$TRUE
                shift
                ;;
            -q|--quiet)
                Output_Quiet=$TRUE
                shift
                ;;
            -p|--no-prompt)
                Output_Prompt_Enabled=$FALSE
                shift
                ;;
            -i|--interactive)
                Output_Prompt_Enabled=$TRUE
                shift
                ;;
            -h|--help)
                show_Usage
                ;;
            -*)
                print -u2 "Error: Unknown option '$1'"
                show_Usage
                ;;
            *)
                print -u2 "Error: Unexpected argument '$1'"
                show_Usage
                ;;
        esac
    done

    # Set default key path if not specified
    if [[ -z "$Key_Path" ]]; then
        Key_Path="${HOME}/.ssh/id_${Key_Type}_hardware"
    fi

    # Validate repository directory for local config
    if [[ "$Git_Scope" == "local" ]]; then
        if [[ ! -d "$Repo_Directory" ]]; then
            print -u2 "Error: Directory does not exist: $Repo_Directory"
            return $Exit_Status_IO
        fi
        if [[ ! -d "$Repo_Directory/.git" ]]; then
            print -u2 "Error: Not a Git repository: $Repo_Directory"
            return $Exit_Status_Git_Failure
        fi
    fi

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Main workflow orchestration
# Parameters:
#   None (uses script variables)
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_* on error
#----------------------------------------------------------------------#
core_Logic() {
    # Check dependencies
    check_Dependencies || return $?

    # Detect FIDO devices
    z_Output info "Detecting FIDO2/U2F security devices..."
    if z_Detect_FIDO_Devices > /dev/null 2>&1; then
        z_Output success "Security device detected"
    else
        z_Output warn "No security device detected"
        z_Output warn "Please ensure device is connected via USB"

        if (( Output_Prompt_Enabled == TRUE )); then
            typeset Response
            print -n "Continue anyway? [y/N]: "
            read -r Response
            if [[ ! "$Response" =~ ^[Yy]$ ]]; then
                z_Output info "Setup cancelled"
                return $Exit_Status_General
            fi
        else
            z_Output error "Cannot continue in non-interactive mode"
            return $Exit_Status_Config
        fi
    fi

    # Generate hardware key
    setup_Hardware_Key || return $?

    # Set up ssh-agent
    setup_SSH_Agent_Integration || return $?

    # Configure Git
    setup_Git_Configuration || return $?

    # Display summary
    display_Summary || return $?

    return $Exit_Status_Success
}

########################################################################
## SECTION: Controller Layer - Entry Point
##--------------------------------------------------------------------##
## Description:
##   Main entry point and cleanup handling
########################################################################

#----------------------------------------------------------------------#
# Function: cleanup
#----------------------------------------------------------------------#
# Description:
#   Cleanup function called on script exit
# Parameters:
#   None
# Returns:
#   None
#----------------------------------------------------------------------#
cleanup() {
    # Currently no cleanup needed
    # Created files are intentionally kept
    # ssh-agent is left running for user
    :
}

#----------------------------------------------------------------------#
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Script entry point
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_* on error
#----------------------------------------------------------------------#
main() {
    # Parse command line parameters
    parse_Parameters "$@" || exit $?

    # Execute core logic
    core_Logic || exit $?

    exit $Exit_Status_Success
}

########################################################################
## Script Entry Point
########################################################################

# Execute only if run directly (not sourced)
if [[ "${(%):-%N}" == "$0" ]]; then
    # Set up cleanup trap
    trap cleanup EXIT

    # Run main function
    main "$@"
fi
