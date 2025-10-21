# Open Integrity Project: Work Stream Tasks

This document tracks tasks across multiple work streams (branches) for the Open Integrity Project. It serves as the single source of truth for project status and planning.

## Work Stream Management Strategy

To maintain this document's integrity while supporting parallel development, follow these guidelines:

1. **Single Source of Truth**
   - This document in `main` is the official record of all work streams
   - Each task is tagged with its branch name in square brackets: `[branch-name]`
   - Only update your branch's sections, leave other sections intact

2. **Status Updates**
   - When making significant progress in a branch, update this document with status
   - Create a small, focused PR to update just your branch's tasks in this document
   - Keep documentation changes separate from code changes where possible

3. **Branch Creation Process**
   - When creating a new branch, add a new section to this document
   - Follow the existing format: branch name, description, and priority levels
   - Tag all tasks with the branch name in square brackets

4. **Completion Updates**
   - When a task is completed, mark it as done and add the completion date
   - Move completed tasks to the "Completed" section under your branch
   - Final branch PR should include the completed status in this document

This approach keeps all status information in one place while clearly assigning ownership of tasks to specific branches.

## Branch: [work-stream-management]

Implementation of a standardized work stream tracking system for multi-branch development.

**Related Issues:**
- [ISSUES-Open_Integrity_Scripting_Infrastructure.md: System-Wide Issues](src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md)
  > While there's no specific issue for work stream management, this work addresses broader system documentation management needs.

**Related Requirements:**
- [REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md: Documentation](src/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)
  > Covers general documentation requirements applicable to all project aspects.

### Stage 1: Strategy & Planning
- [x] **Define work stream management strategy** (2025-03-05)
  - [x] Define document format and branching workflow
  - [x] Add strategy section to document header
  - [x] Document task tagging approach with branch names

### Stage 2: Implementation
- [x] **Implement work stream tracking system** (2025-03-05) [work-stream-management]
  - [x] Rename and move OPEN_TASKS.md to WORK_STREAM_TASKS.md in root directory
  - [x] Update branch section with new format and tags
  - [x] Design PR workflow for status updates

### Stage 3: Documentation
- [x] **Document process in developer guides** (2025-03-05) [work-stream-management]
  - [x] Add work stream management to CLAUDE.md
  - [x] Create example for onboarding new developers

### Stage 4: System Documentation
- [ ] **Update system-wide documentation** [work-stream-management]
  - [ ] Add work stream management section to ISSUES-Open_Integrity_Scripting_Infrastructure.md
  - [ ] Document the process as a formalized system practice
  - [ ] Create a GitHub Issue for tracking future improvements to the workflow

### Stage 5: Integration
- [ ] **Create and review pull request** [work-stream-management]
  - [x] Perform thorough pre-commit review of all changes (2025-03-05)
    - [x] Use `git diff` to review each file individually  
    - [x] Verify consistency across files
    - [x] **CRITICAL**: Human author personally reviewed all changes
  - [x] Stage files individually with separate `git add <file>` commands (2025-03-05)
  - [x] Human author created properly formatted commits following CLAUDE.md guidance (2025-03-05)
  - [x] Push branch to GitHub (2025-03-05)
  - [x] Create PR for merging to main (2025-03-05)
  - [x] Review PR locally (2025-03-05)
  - [ ] Review PR on GitHub
  - [ ] Approve and merge PR

### Completed in this Branch
- [x] **Branch creation and setup** (2025-03-05)
  - [x] Create 'work-stream-management' branch
  - [x] Move and rename OPEN_TASKS.md to WORK_STREAM_TASKS.md
- [x] **Process definition** (2025-03-05)
  - [x] Define document format and branching workflow
  - [x] Add strategy section to document header
  - [x] Document task tagging approach with branch names
- [x] **Implementation** (2025-03-05)
  - [x] Update document with branch tagging format
  - [x] Design PR workflow for status updates
  - [x] Document the process in CLAUDE.md
- [x] **Documentation** (2025-03-05)
  - [x] Add work stream management to CLAUDE.md
  - [x] Create example document in docs/examples/
- [x] **Pre-commit review requirements** (2025-03-05)
  - [x] Document human review requirements for all changes
  - [x] Add pre-commit review section to CLAUDE.md
  - [x] Distinguish between AI assistance and human responsibility
  - [x] Emphasize proper signing and certification by human authors

## Branch: [enforce-ssh-signatures] (Example - Not Active)

Implementation of SSH signature enforcement under the Inception Authority trust model.

**Related Issues:**
- [ISSUES-Open_Integrity_Scripting_Infrastructure.md: Automating GitHub & Git Enforcement](src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md#issue-automating-github--git-enforcement-of-signed-commits-and-sign-offs)
  > "To ensure repository integrity, Open Integrity requires that all commits be cryptographically signed (`git commit -S`) and contain `Signed-off-by:` (`git commit -s`)."

**Related Requirements/Documentation:**
- [Open_Integrity_Problem_Statement.md: Signature Requirement](docs/Open_Integrity_Problem_Statement.md#linking-a-chain-of-trust)
  > "Every commit after the _Inception Commit_ requires an authorized SSH signature, ensuring proof of authenticity and tamper resistance."
- [Progressive_Trust_Terminology.md: Verification Terms](src/requirements/REQUIREMENTS-Progressive_Trust_Terminology.md)
  > Contains terminology for signature verification in the Progressive Trust model
- [Enforcing_Signed_Commits_And_PRs_GitHub.md](docs/Enforcing_Signed_Commits_And_PRs_GitHub.md)
  > Current documentation on enforcing commits that needs to be updated

### Stage 1: Requirements
- [ ] **Create requirements for SSH signature enforcement** [enforce-ssh-signatures]
  - [ ] Create `src/requirements/REQUIREMENTS-configure_ssh_signatures.md` as a framework document
  - [ ] Define the goals, parameters, and process for enforcing SSH signatures
  - [ ] Include examples based on GitHub CLI commands

### Stage 2: Documentation
- [ ] **Update existing documentation** [enforce-ssh-signatures]
  - [ ] Enhance `docs/Enforcing_Signed_Commits_And_PRs_GitHub.md` to focus on SSH signatures
  - [ ] Update `src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md` with progress
  - [ ] Document the implementation of the Inception Authority trust model in practice

### Stage 3: Implementation
- [ ] **Create automation script** [enforce-ssh-signatures]
  - [ ] Develop `src/configure_ssh_signatures.sh` following framework script requirements
  - [ ] Implement local and GitHub configuration capabilities
  - [ ] Add regression tests and test output reference files
  - [ ] Test against a dedicated GitHub test repository

### Stage 4: Issue Resolution
- [ ] **Update related issue documentation** [enforce-ssh-signatures]
  - [ ] Update the issue in ISSUES-Open_Integrity_Scripting_Infrastructure.md with implementation progress
  - [ ] Mark issue as PARTIALLY RESOLVED or RESOLVED as appropriate
  - [ ] Document any limitations or future work needed

## Branch: [feature/enhance-inception-script-with-z-utils]

Implementation of enhanced Git inception repository script with improved error handling, better command-line interfaces, and comprehensive test coverage.

**Related Issues:**
- [ISSUES-Open_Integrity_Scripting_Infrastructure.md: Script Quality](src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md)
  > Addresses broader issues with script quality, error handling, and parameter validation.

**Related Requirements:**
- [REQUIREMENTS-create_inception_commit.md](src/requirements/REQUIREMENTS-create_inception_commit.md)
  > Core requirements for the inception commit script functionality.
- [REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md](src/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)
  > Scripting standards applied to the enhanced implementation.

### Stage 1: Script Enhancement
- [x] **Rename scripts to better reflect purpose** (2025-03-29) [feature/enhance-inception-script-with-z-utils]
  - [x] Rename `create_inception_commit.sh` to `setup_git_inception_repo.sh`
  - [x] Rename `TEST-create_inception_commit.sh` to `setup_git_inception_repo_REGRESSION.sh`
  - [x] Rename `OUTPUT-TEST-create_inception_commit.txt` to `setup_git_inception_repo_REGRESSION-OUTPUT.txt`

### Stage 2: Library Integration
- [x] **Add Z_Utils library for improved functionality** (2025-03-29) [feature/enhance-inception-script-with-z-utils]
  - [x] Add `_Z_Utils.zsh` library to `src/lib/` directory
  - [x] Update path resolution to find library in different locations
  - [x] Add library version checking capability

### Stage 3: Command-Line Interface Improvements
- [x] **Enhance command-line options** (2025-03-29) [feature/enhance-inception-script-with-z-utils]
  - [x] Add `-f|--force` flag to replace less intuitive `--no-prompt`
  - [x] Improve help text with better examples
  - [x] Add comprehensive parameter validation

### Stage 4: Testing Enhancements
- [x] **Improve test infrastructure** (2025-03-29) [feature/enhance-inception-script-with-z-utils]
  - [x] Enhance ANSI color code handling
  - [x] Improve pattern matching for more reliable tests
  - [x] Add better test reporting with detailed output in verbose mode
  - [x] Update test output reference file

### Stage 5: Documentation
- [x] **Update documentation** (2025-03-29) [feature/enhance-inception-script-with-z-utils]
  - [x] Add context file explaining enhancements
  - [x] Update work stream tasks
  - [x] Add comprehensive function documentation

### Completed in this Branch
- [x] **Script Renaming and Enhancement** (2025-03-29) [feature/enhance-inception-script-with-z-utils]
  - [x] Renamed scripts to better reflect their purpose
  - [x] Integrated Z_Utils library for improved functionality
  - [x] Enhanced command-line options with better flags
  - [x] Improved test infrastructure with better ANSI handling
  - [x] Added comprehensive documentation

## Branch: [feature/hardware-signing]

Implementation of hardware security key support for Git commit signing using FIDO2/U2F devices (YubiKey, Flipper Zero, Trezor, Ledger, etc.).

**Related Issues:**
- [ISSUES-setup_hardware_signing.md](src/issues/ISSUES-setup_hardware_signing.md)
  > Documents issues with hardware key detection, SSH agent management, and git configuration for hardware-backed SSH signing.
- [ISSUES-setup_git_inception_repo_hardware.md](src/issues/ISSUES-setup_git_inception_repo_hardware.md)
  > Documents issues with integrated workflow combining hardware setup and inception repository creation.

**Related Requirements:**
- [REQUIREMENTS-setup_hardware_signing.md](src/requirements/REQUIREMENTS-setup_hardware_signing.md)
  > Defines requirements for hardware key setup, device detection, and Git signing configuration.
- [REQUIREMENTS-setup_git_inception_repo_hardware.md](src/requirements/REQUIREMENTS-setup_git_inception_repo_hardware.md)
  > Defines requirements for integrated hardware signing and inception repository workflow.

### Stage 1: Z_Utils Library Enhancement
- [x] **Add hardware signing support functions to Z_Utils** (2025-10-21) [feature/hardware-signing]
  - [x] Implement z_Detect_FIDO_Devices for hardware key detection
  - [x] Implement z_Generate_Hardware_SSH_Key for ed25519-sk and ecdsa-sk key generation
  - [x] Implement z_Setup_SSH_Agent for ssh-agent discovery and management
  - [x] Implement z_Add_Key_To_SSH_Agent for key registration
  - [x] Implement z_Configure_Git_SSH_Signing for Git signing configuration
  - [x] Update _Z_Utils.zsh library version to 0.2.0

### Stage 2: Standalone Hardware Signing Script
- [x] **Create setup_hardware_signing.sh script** (2025-10-21) [feature/hardware-signing]
  - [x] Implement parameter parsing for key type, git scope, and output path
  - [x] Support ed25519-sk (FIDO2) and ecdsa-sk (U2F) key types
  - [x] Support global and local git configuration scopes
  - [x] Implement resident key support for passwordless authentication
  - [x] Add interactive and non-interactive modes
  - [x] Create comprehensive test script TEST-setup_hardware_signing.sh
  - [x] Document requirements in REQUIREMENTS-setup_hardware_signing.md
  - [x] Document issues in ISSUES-setup_hardware_signing.md

### Stage 3: Integrated Hardware Inception Script
- [x] **Create setup_git_inception_repo_hardware.sh script** (2025-10-21) [feature/hardware-signing]
  - [x] Implement two-phase workflow: Phase 1 (hardware setup) → Phase 2 (repository creation)
  - [x] Combine parameters from both parent scripts
  - [x] Support all hardware signing options in repository creation workflow
  - [x] Add force flag for repository overwrite
  - [x] Create comprehensive test script TEST-setup_git_inception_repo_hardware.sh
  - [x] Document requirements in REQUIREMENTS-setup_git_inception_repo_hardware.md
  - [x] Document issues in ISSUES-setup_git_inception_repo_hardware.md

### Stage 4: Testing
- [x] **Create comprehensive test coverage** (2025-10-21) [feature/hardware-signing]
  - [x] Test parameter parsing and validation for both scripts
  - [x] Test dependency checking and error handling
  - [x] Test invalid input rejection
  - [x] Document test limitations (hardware operations require physical device)

### Stage 5: Documentation
- [x] **Document hardware signing implementation** (2025-10-21) [feature/hardware-signing]
  - [x] Create requirements documents for both scripts
  - [x] Create issues documents tracking known limitations
  - [x] Document Z_Utils function additions
  - [x] Add examples for different hardware devices (YubiKey, Flipper Zero)

### Completed in this Branch
- [x] **Hardware signing infrastructure** (2025-10-21) [feature/hardware-signing]
  - [x] Added 5 Z_Utils functions for hardware key operations
  - [x] Created standalone setup script with 11 exit codes for error handling
  - [x] Created integrated workflow script combining hardware setup + inception commit
  - [x] Created comprehensive test suites for both scripts
  - [x] Documented 8 open issues for integrated script
  - [x] Documented 15 open issues for standalone script
  - [x] All scripts follow Zsh Core Scripting Best Practices
  - [x] All commits signed with SSH signatures and DCO sign-off

## Unassigned to Branch

### Testing Infrastructure
- [ ] **Fix test cleanup issues** [unassigned] (High Priority)
  - [ ] Add proper cleanup code to TEST-audit_inception_commit.sh to remove sandbox directory
  - [ ] Add proper EXIT trap to ensure cleanup even when tests fail or are interrupted
  - [ ] Consider moving test directories to a temporary location instead of repository root

- [ ] **Create test for get_repo_did.sh** [unassigned] (High Priority)
  - [ ] Create TEST-get_repo_did.sh following pattern of existing test scripts
  - [ ] Include tests for different repository scenarios
  - [ ] Test error cases and edge conditions
  - [ ] Generate OUTPUT-TEST-get_repo_did.txt reference file
  - [ ] Ensure the test script properly cleans up after itself

### Standards and Specifications
- [ ] **Complete DID URL standardization** [unassigned] (Medium Priority)
  - [ ] Review and standardize all DID URLs to follow a consistent pattern
  - [ ] Document DID generation and usage processes

### Future Infrastructure
- [ ] **Develop periodic test artifact cleanup script** [unassigned] (Low Priority)
  - [ ] Create script to remove old test artifacts
  - [ ] Add automated cleanup checks to CI/CD pipelines

- [ ] **Implement integration tests** [unassigned] (Medium Priority)
  - [ ] Create comprehensive tests across all scripts
  - [ ] Test interactions between components

## Recently Completed from Main Branch

- [x] **Add documentation for test output naming conventions** (2025-03-04)
  - [x] Update CLAUDE.md with clear guidelines
  - [x] Document process for updating test output files
  - [x] Add file staging requirements for test scripts and output files

- [x] **Update remaining GitHub URLs** (2025-03-04)
  - [x] Complete update of URL references in content of requirements documents
  - [x] Check for any remaining BlockchainCommons references that should be updated
  - [x] Updated all primary document headers with correct repository paths

- [x] **Fix license references** (2025-03-04)
  - [x] Fix incorrect BSD-3-Clause license references in script headers (should be BSD-2-Clause-Patent)
  - [x] Files updated in src/ directory and test scripts
  - [x] Updated REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md with correct license references

- [x] **Fix test output inconsistencies** (2025-03-04)
  - [x] Standardize naming convention by removing redundant file
  - [x] Removed outdated OUTPUT-TEST-audit_inception_commit-POC.txt (using git rm)
  - [x] Keeping only current OUTPUT-TEST-audit_inception_commit.txt