_file: `REQUIREMENTS-setup_git_inception_repo_hardware.md`_

# Zsh Framework Script `setup_git_inception_repo_hardware.sh` Requirements
_(Last updated: 2025-10-21, Christopher Allen <ChristopherA@LifeWithAlacrity.com>)_

## General Requirements

This script must adhere to all principles defined in:
- `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md` - For general Zsh scripting practices
- `REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md` - For Framework-specific implementation details

As a Zsh Framework script, this script implements layered architecture with comprehensive error handling, dependency checking, and support for both interactive and non-interactive execution modes.

This integrated script combines requirements from:
- `REQUIREMENTS-setup_hardware_signing.md` - Hardware signing setup requirements
- Requirements for inception repository creation (via `z_Create_Inception_Repository`)

## Functionality

### Primary Function
Provide a complete, integrated workflow for creating a new Git repository with a hardware-signed inception commit. This combines two distinct workflows into a single streamlined process:

1. **Hardware Signing Setup Phase**:
   - Generate hardware-backed SSH keys using FIDO2/U2F security devices
   - Configure ssh-agent for hardware key management
   - Set up Git to use SSH signing with hardware keys

2. **Inception Repository Creation Phase**:
   - Create new Git repository
   - Generate hardware-signed empty inception commit
   - Verify signature correctness
   - Display repository DID

### Hardware Device Support
- Flipper Zero (U2F/FIDO)
- YubiKey (FIDO2/U2F)
- Generic FIDO2/U2F security keys (Trezor, Ledger, etc.)

### Key Generation
- Support two key types:
  - `ed25519-sk` (FIDO2) - Recommended for modern devices (YubiKey 5+)
  - `ecdsa-sk` (U2F) - Compatible with older devices (Flipper Zero, YubiKey 4)
- Support resident keys (stored on device) and non-resident keys (requires key handle file)
- Generate both private key handle and public key files
- Set appropriate file permissions (600 for private, 644 for public)

### SSH Agent Management
- Detect existing ssh-agent instances before starting new ones
- Search `/tmp` and `$TMPDIR` for existing agent sockets
- Offer to reuse existing agents in interactive mode
- Auto-use existing agents in non-interactive mode
- Start new ssh-agent only when necessary
- Add hardware keys to agent with appropriate prompts
- Verify hardware key accessibility via agent

### Git Configuration
- Configure global Git settings for SSH signing
- Set `gpg.format` to `ssh`
- Set `user.signingkey` to public key literal format (`key::<public-key-content>`)
- Enable automatic commit signing (`commit.gpgsign true`)
- Optionally configure `user.name` and `user.email`

### Repository Creation
- Create repository directory (with optional force flag for existing directories)
- Initialize Git repository
- Create signed empty inception commit using hardware key
- Verify inception commit signature
- Generate and display repository DID

## Dependencies

### Required External Commands
- `git` (2.34+) - For SSH signing support
- `ssh-keygen` (OpenSSH 8.2+) - For FIDO2/U2F key generation
- `ssh-add` - For adding keys to ssh-agent
- `ssh-agent` - For key management

### Z_Utils Functions
The script sources and depends on the following Z_Utils functions:
- `z_Output` - Output formatting and verbosity control
- `z_Report_Error` - Error reporting
- `z_Setup_Environment` - Initialize Z_Utils environment
- `z_Check_Dependencies` - Verify external tool dependencies
- `z_Check_SSH_Agent` - Verify ssh-agent is running
- `z_Setup_SSH_Agent` - Set up or discover ssh-agent
- `z_Generate_Hardware_SSH_Key` - Generate hardware-backed SSH keys
- `z_Add_Key_To_SSH_Agent` - Add keys to ssh-agent
- `z_Verify_Hardware_Key` - Verify hardware key accessibility
- `z_Detect_FIDO_Devices` - Detect FIDO2/U2F security devices
- `z_Verify_Git_Config` - Verify Git signing configuration
- `z_Create_Inception_Repository` - Create repository with signed inception commit

### Z_Utils Library Location
- Must be located at `${Script_Dir}/lib/_Z_Utils.zsh`
- Script must verify library exists and is readable before sourcing
- Script must verify all required functions are available after sourcing

## Output Handling

- Use `z_Output` function for all user-facing output with appropriate severity levels
- Direct all error messages to stderr using `z_Report_Error`
- Support verbose mode (`-v`, `--verbose`) for detailed operation information
- Support debug mode (`-d`, `--debug`) for troubleshooting output
- Support quiet mode (`-q`, `--quiet`) for minimal output
- Provide clear phase indicators (Phase 1: Hardware Setup, Phase 2: Repository Creation)
- Display comprehensive final summary upon completion
- Clear warnings when hardware device interaction is required

## Exit Codes & Error Handling

The script must use standardized exit codes:
- `Exit_Status_Success` (0) - Successful execution
- `Exit_Status_General` (1) - General error
- `Exit_Status_Usage` (2) - Invalid usage or arguments
- `Exit_Status_IO` (3) - Input/output error (file/directory issues)
- `Exit_Status_Git_Failure` (5) - Git operation error
- `Exit_Status_Config` (6) - Configuration error
- `Exit_Status_Dependency` (127) - Missing executable dependency

### Error Propagation
- All functions must return appropriate exit codes
- Errors must propagate up the call stack
- Parent functions must check and handle child function exit codes
- Use `|| return $?` pattern for error propagation
- Phase 1 errors must prevent Phase 2 execution

## Arguments & Options

### Repository Options
- `--repo <directory>` - Repository directory path (default: `new_open_integrity_repo`)
- `-f, --force` - Force creation even if repository already exists

### Hardware Key Options
- `-k, --key-type <type>` - Key type: `ed25519-sk` or `ecdsa-sk` (default: `ed25519-sk`)
- `-o, --output <path>` - Output path for private key without `.pub` extension (default: `~/.ssh/id_<keytype>_hardware`)
- `-r, --resident` - Create resident key stored on device (default: non-resident)

### Git Configuration Options
- `-n, --name <name>` - Git user.name for configuration
- `-e, --email <email>` - Git user.email for configuration

### Execution Control Options
- `-v, --verbose` - Enable detailed output
- `-d, --debug` - Show debugging information (implies verbose)
- `-q, --quiet` - Suppress non-critical output
- `-p, --no-prompt` - Run non-interactively without prompts
- `-i, --interactive` - Force interactive prompts (default)
- `-h, --help` - Show help message and exit

## Documentation Requirements

### Script Header Documentation
- Must include all elements specified in Framework requirements
- Must include comprehensive FEATURES section listing:
  - Integrated workflow (two phases)
  - Hardware device support
  - Key types
  - Execution modes
- Must include SECURITY CONSIDERATIONS section addressing:
  - Inception commit cryptographic root of trust
  - Hardware key security benefits
  - Private key protection
  - Physical device requirements
  - PIN requirements
  - Resident vs non-resident key tradeoffs
- Must include detailed EXAMPLES section with:
  - Interactive setup examples
  - Device-specific examples (Flipper Zero, YubiKey)
  - Resident key example
  - Non-interactive automation example
  - Force flag example

### Function Documentation
- Each function must have a documentation block conforming to Framework requirements
- Must include:
  - Description of purpose
  - Parameters with types and meanings
  - Return values and exit codes
  - Runtime impact and side effects
  - Dependencies on other functions or external commands

## Failure Conditions & Handling

### Dependency Failures
- Missing `git`, `ssh-keygen`, or `ssh-add`: Exit with `Exit_Status_Dependency`
- OpenSSH version < 8.2: Exit with `Exit_Status_Dependency` (no FIDO support)
- Git version < 2.34: Exit with `Exit_Status_Dependency` (no SSH signing)
- Missing Z_Utils library: Exit with `Exit_Status_Dependency`
- Missing required Z_Utils functions: Exit with `Exit_Status_Dependency`

### Parameter Validation Failures
- Invalid key type (not `ed25519-sk` or `ecdsa-sk`): Exit with `Exit_Status_Usage`
- Unknown option: Exit with `Exit_Status_Usage`
- Missing required option value: Exit with `Exit_Status_Usage`

### Hardware Device Failures (Phase 1)
- No FIDO2/U2F device detected:
  - Interactive mode: Prompt user to continue or cancel
  - Non-interactive mode: Exit with `Exit_Status_Config`
- Device communication timeout: Exit with `Exit_Status_General`
- User cancels device interaction: Exit with `Exit_Status_General`
- Device PIN incorrect/locked: Exit with `Exit_Status_General`

### SSH Agent Failures (Phase 1)
- Cannot start ssh-agent: Exit with `Exit_Status_General`
- Cannot add key to ssh-agent: Exit with `Exit_Status_General`
- Hardware key not accessible via agent: Exit with `Exit_Status_General`

### Git Configuration Failures (Phase 1)
- Cannot set Git config: Exit with `Exit_Status_Git_Failure`

### Repository Creation Failures (Phase 2)
- Repository already exists without force flag: Exit with `Exit_Status_IO`
- Cannot create repository directory: Exit with `Exit_Status_IO`
- Cannot initialize Git repository: Exit with `Exit_Status_Git_Failure`
- Cannot create inception commit: Exit with `Exit_Status_Git_Failure`
- Cannot verify inception commit signature: Exit with `Exit_Status_Git_Failure`

## Interactive vs Non-Interactive Modes

### Interactive Mode (Default)
- Prompt user for confirmations and choices
- Offer to use existing ssh-agent instances
- Prompt to start new ssh-agent if none found
- Allow user to cancel operations
- Provide detailed guidance and next steps

### Non-Interactive Mode (`--no-prompt`)
- No user prompts or confirmations
- Auto-use first found ssh-agent or fail with clear error
- Exit with error if hardware device not detected
- Require all necessary parameters to be provided via options
- Suitable for automation, scripts, and CI/CD pipelines

## Security Requirements

### Inception Commit Security
- Inception commit establishes cryptographic root of trust
- Empty commit with comprehensive commit message
- Signed with hardware-backed SSH key
- Signature must be verified before declaring success
- Repository DID derived from inception commit hash

### Hardware Key Security
- Private keys never leave the hardware device
- Each signature requires physical device presence
- Resident keys require device PIN for access
- Non-resident keys require both key handle file and device

### File Permissions
- Private key handle files must be created with mode 600
- Public key files must be created with mode 644
- Script must not expose sensitive data in logs or error messages

### Git Signing Configuration
- Use `key::` literal format for public keys in Git config to avoid path dependencies
- Verify ssh-agent is running when hardware keys are configured
- Ensure Git commit signing is properly enabled

### Operational Security
- Clear warnings when device interaction is required
- Explicit prompts for PIN entry when needed
- Guidance on backing up key handles for non-resident keys
- Warnings about resident key discoverability

## Performance Considerations

- ssh-agent discovery should complete quickly (< 1 second for typical systems)
- Key generation depends on hardware device speed and user interaction
- Git configuration operations are fast (< 100ms)
- Repository creation and inception commit generation typically < 2 seconds
- Overall script execution time dominated by:
  - Hardware device communication
  - User interaction for PIN/touch
  - ssh-keygen key generation

## Testing Requirements

The following test cases must be used to verify compliance:

### 1. Basic Functionality Tests
- Test `--help` option displays usage information
- Test `-h` option displays usage information
- Verify syntax check passes without errors

### 2. Parameter Parsing Tests
- Test invalid key type parameter
- Test unknown option handling
- Test missing required option values (repo, key-type, output, name, email)
- Test valid parameter combinations

### 3. Repository Path Tests
- Test repository creation with default name
- Test repository creation with custom path
- Test force flag with existing repository
- Test behavior when repository already exists without force flag

### 4. Combined Workflow Tests
- Test combined repository and key type parameters
- Test combined with git configuration parameters
- Test combined with resident key flag
- Test combined with force flag

### 5. Execution Mode Tests
- Test `--no-prompt` mode parameter acceptance
- Test `--interactive` mode parameter acceptance
- Test `--verbose` and `--debug` modes
- Test `--quiet` mode

### 6. Error Handling Tests
- Test behavior when no hardware device is present
- Test proper exit codes for different error conditions
- Test error messages are informative and actionable

**Note:** Actual hardware key generation, ssh-agent operations, and inception commit creation cannot be tested in automated CI/CD environments as they require physical FIDO2/U2F security devices. Tests verify parameter validation and error handling up to the point where hardware interaction would be required.

## Cleanup and Resource Management

### Created Resources
- Track created files in `Created_Files` array
- Private key handle file
- Public key file
- Repository directory and Git repository

### Cleanup Behavior
- Do NOT clean up created files on normal exit (user wants to keep keys and repository)
- Do NOT clean up created files on error (user may want to inspect)
- Leave ssh-agent running for user convenience
- Cleanup trap registered but currently performs no operations

**Rationale:** Created SSH keys and repository are intentional outputs of successful execution and should persist.

## Versioning and Lifecycle

Version history and future plans for this script:

- **0.1.00** (2025-10-21): Initial release version
  - Integrated hardware signing setup with inception repository creation
  - Support for Flipper Zero (ecdsa-sk/U2F)
  - Support for YubiKey and generic FIDO2 devices (ed25519-sk)
  - Two-phase workflow: hardware setup → repository creation
  - Interactive and non-interactive execution modes
  - Automatic ssh-agent discovery and configuration
  - Hardware-signed inception commit
  - Resident and non-resident key generation
  - Comprehensive error handling and validation

Future versions may include:
- Support for local repository-specific Git configuration option
- Integration with allowed_signers file generation
- Support for additional key types as OpenSSH evolves
- Enhanced device detection and capability discovery
- Batch repository creation with multiple devices
- Integration with CI/CD pipelines for automated repository setup
- Support for creating repositories with initial files/structure

This requirements document will be updated as the script evolves, with version numbers matching the script's version numbers.
