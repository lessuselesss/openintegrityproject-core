# Issues related to the `setup_git_inception_repo_hardware.sh` Open Integrity Tool
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/src/issues/ISSUES-setup_git_inception_repo_hardware.md`_
> - _github: [`core/src/issues/ISSUES-setup_git_inception_repo_hardware.md`](https://github.com/OpenIntegrityProject/core/blob/main/src/issues/ISSUES-setup_git_inception_repo_hardware.md)_
> - _Updated: 2025-10-21 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

Issues related to the `setup_git_inception_repo_hardware.sh` script, which provides an integrated workflow for creating Git repositories with hardware-signed inception commits using security keys (Flipper Zero, YubiKey, FIDO2/U2F).

## Code Version and Source

This issues document applies to the Open Integrity Project's **Proof-of-Concept** script `setup_git_inception_repo_hardware.sh`, **version 0.1.00 (2025-10-21)**, and associated files, which are available at the following sources:

> **Origin:**
> - [Requirements: _github: `https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-setup_git_inception_repo_hardware.md`_](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-setup_git_inception_repo_hardware.md)
> - [Script: _github: `https://github.com/OpenIntegrityProject/core/blob/main/src/setup_git_inception_repo_hardware.sh`_](https://github.com/OpenIntegrityProject/core/blob/main/src/setup_git_inception_repo_hardware.sh)
> - [Regression Test: _github: `https://github.com/OpenIntegrityProject/core/blob/main/src/tests/TEST-setup_git_inception_repo_hardware.sh`_](https://github.com/OpenIntegrityProject/core/blob/main/src/tests/TEST-setup_git_inception_repo_hardware.sh)

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

### ISSUE: No Support for Local Repository Git Configuration (Priority: Medium)

**Context:** The integrated script currently only supports global Git configuration for SSH signing. Some users may want to configure hardware signing on a per-repository basis rather than globally.

**Current:**
- Script uses `git config --global` for all Git configuration
- Hardware signing configuration applies to all repositories
- No option to configure only the newly created repository
- Users who want different signing keys for different repos cannot use this script

**Impact:**
- Less flexible for users with multiple projects requiring different keys
- Cannot create repository with local-only hardware signing configuration
- Global configuration may interfere with existing repository setups
- Not suitable for shared development environments

**Proposed Actions:**
1. Add `--git-scope <scope>` option to choose between `global` and `local`
2. When using `local` scope, configure only the newly created repository
3. For `local` scope, skip global Git configuration entirely
4. Document the difference between global and local configuration
5. Update tests to verify both scope behaviors

**Status:** OPEN - Enhancement for v0.2.00

### ISSUE: Phase 1 Failure Recovery Not Implemented (Priority: Medium)

**Context:** If Phase 1 (hardware signing setup) fails partway through, the script exits without cleaning up partial configuration or providing recovery guidance.

**Current:**
- Script exits immediately on Phase 1 errors
- Partial Git configuration may remain (e.g., gpg.format=ssh but no signingkey)
- Generated key files may be left on disk
- ssh-agent may be in inconsistent state
- No guidance on how to recover from partial failure

**Impact:**
- Users left with partially configured Git environment
- Manual cleanup required to restore previous state
- Difficult to retry after fixing the issue (e.g., connecting device)
- Poor user experience for transient failures

**Proposed Actions:**
1. Implement Phase 1 rollback on error
2. Track configuration changes made during Phase 1
3. Provide option to restore previous Git configuration on failure
4. Add `--retry` mode to skip successfully completed steps
5. Implement checkpoint tracking for resumable setup
6. Provide clear recovery instructions in error messages

**Status:** OPEN - Enhancement for v0.2.00

### ISSUE: No Validation Between Phase 1 and Phase 2 (Priority: Medium)

**Context:** The script transitions from Phase 1 (hardware setup) to Phase 2 (repository creation) without validating that Phase 1 actually completed successfully and hardware key is still accessible.

**Current:**
- Phase 2 begins immediately after Phase 1 returns success
- No verification that hardware key is still in ssh-agent
- No check that Git configuration is correct before inception commit
- Device may have been disconnected between phases
- ssh-agent may have been killed between phases

**Impact:**
- Repository creation may fail with cryptic errors
- Inception commit may fail at signing stage
- Poor error messages don't indicate the hardware setup issue
- User may not realize they need to re-run Phase 1

**Proposed Actions:**
1. Add validation step between phases
2. Re-verify hardware key is accessible via ssh-agent
3. Re-verify Git configuration before creating repository
4. Detect if device was disconnected and prompt to reconnect
5. Provide clear error messages indicating Phase 1 needs to be re-run
6. Add `--skip-phase1` option for users who already have setup

**Status:** OPEN - Enhancement for v0.2.00

### ISSUE: Limited Test Coverage for Integrated Workflow (Priority: Medium)

**Context:** The test script cannot test the integration between Phase 1 and Phase 2, or the complete end-to-end workflow, because these operations require physical security devices.

**Current:**
- Tests only cover parameter parsing and basic error handling
- No integration tests for Phase 1 → Phase 2 transition
- No tests for inception commit creation with hardware keys
- No tests for error handling during inception commit signing
- Tests stop at device detection stage

**Impact:**
- Reduced confidence in phase integration
- Difficult to verify Phase 2 receives correct configuration from Phase 1
- Inception commit creation bugs might not be caught until user testing
- Regression risk for integrated workflow features

**Proposed Actions:**
1. Investigate mocking/stubbing for integration testing
2. Create integration test suite for manual execution with real device
3. Implement phase transition validation tests
4. Add tests for configuration passing between phases
5. Document manual testing procedures for complete workflow

**Status:** OPEN - Enhancement for v0.2.00

### ISSUE: No Support for Repository Templates (Priority: Low)

**Context:** Users may want to create inception repositories with initial files, directory structure, or configuration templates rather than just an empty repository.

**Current:**
- Script only creates empty repository with inception commit
- No support for initializing with files or structure
- No template system for common repository types
- Users must manually add files after creation

**Impact:**
- Additional manual work required to set up repository structure
- No standardization of repository layouts
- Cannot create fully-configured repositories in one step
- Missed opportunity to include recommended .repo/ structure

**Proposed Actions:**
1. Add `--template <name>` option to specify repository template
2. Create template system with predefined templates:
   - `basic` - Empty inception repository (current behavior)
   - `open-integrity` - Includes `.repo/config/` structure
   - `allowed-signers` - Includes allowed_signers configuration
   - Custom templates from user-defined directories
3. Support copying template files after inception commit
4. Document template structure and customization
5. Provide examples of useful templates

**Status:** OPEN - Future enhancement for v0.3.00

### ISSUE: No Dry-Run Mode (Priority: Low)

**Context:** Users may want to preview what the script will do without actually creating keys or repositories, especially for testing or validation purposes.

**Current:**
- Script performs actual operations immediately
- No way to preview configuration changes
- No way to validate parameters without executing
- Difficult to test in CI/CD without side effects

**Impact:**
- Cannot validate configuration before execution
- No preview of what will be created
- Testing in automated environments creates real artifacts
- Cannot verify script behavior without side effects

**Proposed Actions:**
1. Add `--dry-run` option to preview operations
2. Display what would be created without creating it:
   - Key paths and types
   - Git configuration changes
   - Repository path and structure
3. Validate all parameters and dependencies
4. Skip actual hardware device interaction
5. Provide detailed output of planned operations

**Status:** OPEN - Enhancement for v0.3.00

### ISSUE: Inception Commit Message Not Customizable (Priority: Low)

**Context:** The inception commit uses a hardcoded message from `z_Create_Inception_Repository`. Users may want to customize this message for their specific use case.

**Current:**
- Inception commit message is fixed and cannot be customized
- Message is generated by Z_Utils function
- No option to provide custom message
- All repositories have identical inception commit text

**Impact:**
- Cannot add organization-specific policy text
- Cannot customize for different repository types
- Missed opportunity to document repository purpose
- Generic message may not meet organizational requirements

**Proposed Actions:**
1. Add `--commit-message <file>` option for custom message
2. Add `--commit-message-template <name>` for predefined templates
3. Support variable substitution in templates (repo name, date, etc.)
4. Maintain default message if no customization provided
5. Validate message meets inception commit requirements

**Status:** OPEN - Enhancement for v0.3.00

### ISSUE: No Support for Multiple Initial Commits (Priority: Low)

**Context:** Some workflows may want to create a repository with multiple initial commits (e.g., inception commit + initial structure commit + initial documentation commit), all signed with hardware key.

**Current:**
- Script creates only the inception commit
- No support for additional initial commits
- Users must manually create subsequent commits
- No automated way to set up initial repository state

**Impact:**
- Manual work required after inception creation
- Risk of creating unsigned initial commits
- No standardized initial commit sequence
- Cannot automate complete repository initialization

**Proposed Actions:**
1. Add `--initial-commits <number>` option
2. Support commit sequence specification
3. Allow templates to define initial commit sequence
4. Ensure all initial commits are hardware-signed
5. Maintain backward compatibility with single inception commit

**Status:** OPEN - Future enhancement for v0.4.00

## Future Enhancements

These are potential enhancements that go beyond issue resolution:

### ENHANCEMENT: Integration with CI/CD Systems

Add support for CI/CD integration:
- GitHub Actions workflow for automated repository creation
- GitLab CI template for inception repository setup
- Environment variable configuration for non-interactive mode
- Secrets management for key storage in CI

### ENHANCEMENT: Batch Repository Creation

Support creating multiple repositories with hardware signing:
- Create multiple repositories in one execution
- Apply consistent configuration across all repositories
- Generate unique key for each repository or shared key
- Parallel creation for performance

### ENHANCEMENT: Migration Tool

Create tool to migrate existing repositories to hardware signing:
- Generate hardware key for existing repository
- Re-sign inception commit with hardware key
- Preserve existing Git history
- Update configuration for hardware signing

### ENHANCEMENT: Key Rotation Support

Support rotating hardware keys for repositories:
- Generate new hardware key
- Update Git configuration
- Maintain old key in allowed_signers for verification
- Document key rotation procedures

## Related Documentation

- **Hardware Signing Setup**: See `ISSUES-setup_hardware_signing.md` for hardware-specific issues
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
