# Issues related to the `setup_hardware_signing.sh` Open Integrity Tool
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/src/issues/ISSUES-setup_hardware_signing.md`_
> - _github: [`core/src/issues/ISSUES-setup_hardware_signing.md`](https://github.com/OpenIntegrityProject/core/blob/main/src/issues/ISSUES-setup_hardware_signing.md)_
> - _Updated: 2025-10-21 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

Issues related to the `setup_hardware_signing.sh` script, which configures hardware security keys (Flipper Zero, YubiKey, FIDO2/U2F) for SSH signing of Git commits.

## Code Version and Source

This issues document applies to the Open Integrity Project's **Proof-of-Concept** script `setup_hardware_signing.sh`, **version 0.1.00 (2025-10-21)**, and associated files, which are available at the following sources:

> **Origin:**
> - [Requirements: _github: `https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-setup_hardware_signing.md`_](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-setup_hardware_signing.md)
> - [Script: _github: `https://github.com/OpenIntegrityProject/core/blob/main/src/setup_hardware_signing.sh`_](https://github.com/OpenIntegrityProject/core/blob/main/src/setup_hardware_signing.sh)
> - [Regression Test: _github: `https://github.com/OpenIntegrityProject/core/blob/main/src/tests/TEST-setup_hardware_signing.sh`_](https://github.com/OpenIntegrityProject/core/blob/main/src/tests/TEST-setup_hardware_signing.sh)

Each issue is structured with:
- **Context**: Background information about the issue
- **Current**: Description of the current implementation
- **Impact**: Consequences of the current implementation
- **Proposed Actions**: Recommended steps to address the issue
- **Status**: Current status of the issue (RESOLVED, IN PROGRESS, or OPEN)

Issues are grouped by architectural concern and include implementation priority (High/Medium/Low).

## Resolved Issues

No issues have been resolved yet as this is the initial 0.1.00 release.

## Open Issues

These issues remain to be addressed in future versions:

### ISSUE: Limited Hardware Device Auto-Detection (Priority: Medium)

**Context:** The script currently uses `z_Detect_FIDO_Devices()` which performs a basic timeout-based test to detect FIDO2/U2F devices. This detection is not device-specific and cannot distinguish between different hardware types or capabilities.

**Current:**
- Detection only confirms that *some* FIDO-compatible device is present
- Cannot identify specific device types (YubiKey vs Flipper Zero vs Trezor)
- Cannot determine device capabilities (FIDO2 vs U2F only)
- User must manually select appropriate key type for their device

**Impact:**
- Users with Flipper Zero may select ed25519-sk and get cryptic errors
- Users with older YubiKeys may not know they need ecdsa-sk
- No guidance about which key type is best for detected device
- Poor user experience for non-expert users

**Proposed Actions:**
1. Enhance `z_Detect_FIDO_Devices()` to identify device type using USB VID/PID
2. Create capability detection to determine FIDO2 vs U2F-only support
3. Add automatic key type recommendation based on detected device
4. Display detected device information to user
5. Warn if user-selected key type is incompatible with detected device

**Status:** OPEN - Future enhancement for v0.2.00

### ISSUE: No Support for Multiple Devices (Priority: Low)

**Context:** Users may have multiple FIDO2/U2F devices and want to configure all of them for redundancy or use them on different machines.

**Current:**
- Script generates one key for one device
- No batch generation support
- No key replication across devices (resident keys only)
- Users must run script multiple times with different output paths

**Impact:**
- Tedious setup for users with multiple devices
- Risk of configuration errors when setting up multiple keys
- No guidance on best practices for multi-device setups
- Inconsistent key types across devices possible

**Proposed Actions:**
1. Add `--multi-device` mode to detect and configure all connected devices
2. Implement batch key generation with consistent naming scheme
3. Add support for replicating resident keys across multiple devices
4. Provide clear documentation for multi-device scenarios
5. Configure Git to support multiple signing keys (via allowed_signers)

**Status:** OPEN - Future enhancement for v0.3.00

### ISSUE: Limited Test Coverage for Hardware Operations (Priority: Medium)

**Context:** The test script cannot test actual hardware key generation, ssh-agent integration, or Git configuration because these operations require physical security devices.

**Current:**
- Tests only cover parameter parsing and basic error handling
- No integration tests for key generation workflow
- No tests for ssh-agent discovery and configuration
- No tests for Git configuration correctness
- Tests stop at device detection stage

**Impact:**
- Reduced confidence in hardware operation functionality
- Difficult to verify ssh-agent integration works correctly
- Git configuration bugs might not be caught until user testing
- Regression risk for hardware-related features

**Proposed Actions:**
1. Investigate mocking/stubbing ssh-keygen for testing key generation
2. Create integration test suite for manual execution with real device
3. Add ssh-agent mocking for testing agent discovery logic
4. Implement Git config validation tests in isolated environment
5. Document manual testing procedures for hardware operations

**Status:** OPEN - Enhancement for v0.2.00

### ISSUE: No Key Rotation or Migration Support (Priority: Low)

**Context:** Users may need to rotate hardware keys periodically or migrate from one device to another while maintaining Git signing history.

**Current:**
- Script only supports initial key generation
- No support for adding new keys while keeping old ones
- No migration path from software keys to hardware keys
- No guidance on updating allowed_signers files
- No support for key revocation

**Impact:**
- Users must manually manage key rotation
- Risk of breaking Git signing when rotating keys
- Difficult to migrate from software to hardware signing
- No best practices for key lifecycle management

**Proposed Actions:**
1. Add `--rotate` mode to generate new key while preserving old config
2. Implement migration wizard from software SSH keys to hardware keys
3. Add support for updating Git allowed_signers files
4. Provide key revocation guidance and tools
5. Document key lifecycle best practices

**Status:** OPEN - Future enhancement for v0.4.00

### ISSUE: ssh-agent Persistence Configuration Not Automated (Priority: Medium)

**Context:** The script sets up ssh-agent for the current session but does not help users configure persistent ssh-agent across shell sessions.

**Current:**
- Script starts or discovers ssh-agent for current session only
- Provides manual instructions to add to shell profile
- No automated shell profile modification
- Users must manually configure persistence

**Impact:**
- Users must touch security device on every shell session
- Poor user experience after system restart
- Higher chance of user configuration errors
- Reduced usability for non-expert users

**Proposed Actions:**
1. Detect user's shell type (bash, zsh, fish, etc.)
2. Offer to add ssh-agent startup to appropriate shell profile
3. Implement safe shell profile modification with backups
4. Add validation of shell profile changes
5. Provide rollback capability if configuration fails

**Status:** OPEN - Enhancement for v0.2.00

### ISSUE: Limited Error Recovery and Diagnostics (Priority: Medium)

**Context:** Hardware device operations can fail for various reasons (device unplugged, PIN locked, firmware issues), and error messages may not provide clear recovery guidance.

**Current:**
- Basic error messages from ssh-keygen and ssh-add
- No diagnostic mode for troubleshooting device issues
- No recovery suggestions for common failure modes
- Limited logging of hardware interaction

**Impact:**
- Users may not understand why operations fail
- Difficult to diagnose device compatibility issues
- No guidance on recovering from errors
- Support burden from unclear error messages

**Proposed Actions:**
1. Implement `--diagnose` mode for comprehensive device testing
2. Add detailed error messages with recovery suggestions
3. Implement retry logic for transient failures
4. Add logging of hardware interactions in debug mode
5. Create troubleshooting guide for common issues

**Status:** OPEN - Enhancement for v0.2.00

### ISSUE: No Integration with setup_git_inception_repo.sh (Priority: High)

**Context:** Users setting up new repositories with inception commits should be able to use hardware signing from the start, but there's no integrated workflow.

**Current:**
- `setup_hardware_signing.sh` and `setup_git_inception_repo.sh` are separate
- Users must run both scripts manually
- No combined workflow for hardware-signed inception commits
- No validation that hardware signing is properly configured before inception commit

**Impact:**
- Fragmented user experience for repository setup
- Risk of creating inception commit without hardware signing
- Difficult to ensure hardware signing is used from first commit
- No automated workflow for complete repository setup

**Proposed Actions:**
1. Create `setup_git_inception_repo_hardware.sh` that combines both workflows
2. Implement hardware signing validation before inception commit creation
3. Add option to `setup_git_inception_repo.sh` to use hardware keys
4. Ensure inception commit uses hardware key if configured
5. Provide clear documentation for integrated workflow

**Status:** OPEN - Critical for v0.1.00+ (Next phase of development)

### ISSUE: SSH Key Format Compatibility (Priority: Low)

**Context:** The script uses `key::` literal format in Git config, which is secure but may have compatibility issues with some Git hosting providers or older Git versions.

**Current:**
- Uses `key::<public-key-content>` format for signing key
- This format is recommended but may not work everywhere
- No fallback to file path format
- No detection of Git hosting provider requirements

**Impact:**
- Potential compatibility issues with some Git hosts
- May require reconfiguration for certain environments
- Users may not know about alternative formats

**Proposed Actions:**
1. Add `--key-format` option to choose between literal and file path formats
2. Detect Git hosting provider and recommend appropriate format
3. Document compatibility considerations
4. Add validation for Git config format support

**Status:** OPEN - Low priority enhancement for v0.3.00

## Future Enhancements

These are potential enhancements that go beyond issue resolution:

### ENHANCEMENT: Smart Card Reader Support

Add support for smart card readers and PIV (Personal Identity Verification) cards in addition to FIDO2/U2F devices. This would expand hardware key support to enterprise environments using PIV cards.

### ENHANCEMENT: Hardware Security Module (HSM) Support

Extend support to professional HSM devices for enterprise and high-security environments.

### ENHANCEMENT: Key Backup and Recovery

Implement secure backup and recovery procedures for hardware key handles and configurations.

### ENHANCEMENT: Cloud HSM Integration

Add support for cloud-based HSM services for remote signing scenarios.

### ENHANCEMENT: Integration with OpenPGP Card

Support OpenPGP card devices as an alternative to FIDO2/U2F for Git signing.

## Related Documentation

- **Progressive Trust Terminology**: See `REQUIREMENTS-Progressive_Trust_Terminology.md` for guidance on using phase-appropriate terminology in future updates
- **Z_Utils Functions**: See `REQUIREMENTS-z_Utils_Functions.md` for documentation of the underlying utility functions
- **Framework Script Best Practices**: See `REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md` for architectural guidance

## Issue Lifecycle

1. **OPEN** - Issue identified and documented
2. **IN PROGRESS** - Work has begun on the issue
3. **RESOLVED** - Issue has been addressed in a released version

## Contributing

When adding new issues to this document:
1. Use the standard structure (Context, Current, Impact, Proposed Actions, Status)
2. Include priority level (High/Medium/Low)
3. Reference specific line numbers or functions when applicable
4. Link to related requirements or other issues
5. Update the "Updated" date in the header
