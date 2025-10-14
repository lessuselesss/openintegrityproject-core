# BIP-Keychain Derivation Paths for Open Integrity

> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/docs/BIP_Keychain_Derivation_Paths.md`_
> - _github: `https://github.com/OpenIntegrityProject/core/blob/main/docs/BIP_Keychain_Derivation_Paths.md`_
> - _created: 2025-10-14_
> - _status: DRAFT / RESEARCH_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: Research](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)

## Overview

This document provides template examples for integrating **BIP-keychain** semantic derivation paths with **Open Integrity** repositories. Using [BIP-keychain](https://github.com/akarve/bip-keychain) and [schema.org](https://schema.org) vocabularies, repository signing keys can be deterministically derived from a single mnemonic seed while maintaining human-readable, semantically meaningful derivation paths.

## Benefits

**Single Seed Recovery**
- One mnemonic backs up all repository keys
- No need to manage individual key files
- Simplified disaster recovery

**Cryptographic Identity**
- Provably link multiple repositories to same root
- Enable cross-repository attestations
- Build organizational trust hierarchies

**Key Lifecycle Management**
- Deterministic key rotation
- Separate inception vs. daily signing keys
- Hardware wallet integration potential

**Semantic Clarity**
- Human-readable derivation paths
- Self-documenting key purposes
- Natural organizational hierarchies

## Base Derivation Path Structure

BIP-keychain uses the following structure:

```
m/83696968'/67797668'/{SEMANTIC_PATH_IMAGE}
```

Where:
- `83696968'` = BIP-85 application code (hardened)
- `67797668'` = BIP-keychain application code (hardened)
- `{SEMANTIC_PATH_IMAGE}` = One or more JSON-LD segments converted to child indexes via `i()`

Each semantic segment is a JSON object using [schema.org](https://schema.org) vocabulary.

## Key Purpose Conventions

For Open Integrity repositories, we propose the following key purposes:

| Purpose | Description | Usage |
|---------|-------------|-------|
| `inception` | Inception commit key | Creates the repository root of trust |
| `signing` | Daily commit signing | Used for regular commits |
| `delegation` | Authority delegation | Signs transition commits adding authorized keys |
| `backup` | Recovery key | Kept offline for emergency recovery |
| `release` | Release signing | Signs tags and releases |

## Template Examples

### 1. Personal Repository - Inception Key

**Use case:** Create inception key for a personal project

```json
[
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "my-awesome-project",
    "programmingLanguage": "Rust"
  },
  {
    "@type": "Text",
    "text": "inception"
  }
]
```

**Full derivation path:**
```
m/83696968'/67797668'/i(Person)/i(SoftwareSourceCode)/i(inception)
```

### 2. Personal Repository - Daily Signing Key

**Use case:** Separate key for day-to-day commits

```json
[
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "my-awesome-project",
    "programmingLanguage": "Rust"
  },
  {
    "@type": "Text",
    "text": "signing"
  }
]
```

**Full derivation path:**
```
m/83696968'/67797668'/i(Person)/i(SoftwareSourceCode)/i(signing)
```

### 3. Organization Repository - Inception Key

**Use case:** Organization-controlled repository

```json
[
  {
    "@type": "Organization",
    "name": "OpenIntegrityProject",
    "url": "https://openintegrityproject.org"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "core",
    "codeRepository": "https://github.com/OpenIntegrityProject/core"
  },
  {
    "@type": "Text",
    "text": "inception"
  }
]
```

**Full derivation path:**
```
m/83696968'/67797668'/i(Organization)/i(SoftwareSourceCode)/i(inception)
```

### 4. Multi-Repository Management

**Use case:** Managing multiple related repositories

**Project A - Backend:**
```json
[
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "myapp-backend",
    "programmingLanguage": "Rust"
  },
  {
    "@type": "Text",
    "text": "inception"
  }
]
```

**Project A - Frontend:**
```json
[
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "myapp-frontend",
    "programmingLanguage": "TypeScript"
  },
  {
    "@type": "Text",
    "text": "inception"
  }
]
```

**Project A - Shared Library:**
```json
[
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "myapp-shared",
    "programmingLanguage": "Rust"
  },
  {
    "@type": "Text",
    "text": "inception"
  }
]
```

All three repositories provably controlled by the same person, recoverable from one seed.

### 5. Team Member Keys

**Use case:** Organization member with signing authority

```json
[
  {
    "@type": "Organization",
    "name": "OpenIntegrityProject",
    "url": "https://openintegrityproject.org"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "core",
    "codeRepository": "https://github.com/OpenIntegrityProject/core"
  },
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com",
    "memberOf": "OpenIntegrityProject"
  },
  {
    "@type": "Text",
    "text": "signing"
  }
]
```

**Full derivation path:**
```
m/83696968'/67797668'/i(Organization)/i(SoftwareSourceCode)/i(Person)/i(signing)
```

### 6. Versioned Keys

**Use case:** Key rotation with version tracking

```json
[
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "my-project",
    "version": "v2"
  },
  {
    "@type": "Text",
    "text": "signing"
  }
]
```

**Full derivation path:**
```
m/83696968'/67797668'/i(Person)/i(SoftwareSourceCode-v2)/i(signing)
```

### 7. Repository-Specific Backup Key

**Use case:** Offline backup key for emergency recovery

```json
[
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "critical-infrastructure",
    "programmingLanguage": "Rust"
  },
  {
    "@type": "Text",
    "text": "backup"
  }
]
```

Store this key offline, never expose to network.

### 8. Release Signing Key

**Use case:** Separate key authority for releases

```json
[
  {
    "@type": "Organization",
    "name": "MyCompany"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "production-service"
  },
  {
    "@type": "Text",
    "text": "release"
  }
]
```

### 9. Fork with Attribution

**Use case:** Fork maintaining link to original

```json
[
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "my-fork",
    "isBasedOn": {
      "@type": "SoftwareSourceCode",
      "codeRepository": "https://github.com/original/repo"
    }
  },
  {
    "@type": "Text",
    "text": "inception"
  }
]
```

### 10. Submodule Key

**Use case:** Separate keys for submodules

```json
[
  {
    "@type": "Person",
    "name": "Ashley Barr",
    "email": "lessuseless@duck.com"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "parent-project"
  },
  {
    "@type": "SoftwareSourceCode",
    "name": "submodule-name",
    "isPartOf": "parent-project"
  },
  {
    "@type": "Text",
    "text": "inception"
  }
]
```

## Schema.org Property Reference

### SoftwareSourceCode Properties

**Identification:**
- `name` (Text) - Repository name
- `codeRepository` (URL) - Repository URL
- `version` (Text) - Version identifier

**Technical:**
- `programmingLanguage` (Text | ComputerLanguage) - Primary language
- `runtimePlatform` (Text) - Runtime requirements
- `codeSampleType` (Text) - Type of code

**Authorship:**
- `creator` (Person | Organization) - Original creator
- `contributor` (Person | Organization) - Contributors
- `copyrightHolder` (Person | Organization) - Copyright holder

**Timestamps:**
- `dateCreated` (Date | DateTime) - Creation date
- `dateModified` (Date | DateTime) - Last modification
- `datePublished` (Date | DateTime) - Publication date

**Relationships:**
- `isBasedOn` (CreativeWork) - Source/fork relationship
- `isPartOf` (CreativeWork) - Submodule/monorepo relationship

### Person Properties

**Identity:**
- `name` (Text) - Full name
- `email` (Text) - Email address
- `url` (URL) - Personal website

**Affiliation:**
- `memberOf` (Organization) - Organization membership
- `worksFor` (Organization) - Employment
- `alumniOf` (Organization) - Alumni status

**Identifiers:**
- `identifier` (Text | PropertyValue) - Additional identifiers
- `sameAs` (URL) - Social media / GitHub profile

### Organization Properties

**Identity:**
- `name` (Text) - Organization name
- `legalName` (Text) - Legal name
- `url` (URL) - Website

**Structure:**
- `member` (Person | Organization) - Members
- `parentOrganization` (Organization) - Parent org
- `subOrganization` (Organization) - Child org

**Contact:**
- `email` (Text) - Contact email
- `address` (PostalAddress) - Physical address

## Integration with Open Integrity

### Creating a Repository with BIP-Keychain

**Step 1: Generate the derivation path**
```json
{
  "@type": "Person",
  "name": "Ashley Barr",
  "email": "lessuseless@duck.com"
}
```
```json
{
  "@type": "SoftwareSourceCode",
  "name": "my-new-repo"
}
```
```json
{
  "@type": "Text",
  "text": "inception"
}
```

**Step 2: Derive the SSH key**
```bash
# Using your BIP-keychain implementation
bip-keychain derive \
  --mnemonic-file ~/.secrets/seed.txt \
  --path 'm/83696968'/67797668'/...' \
  --output-format ssh-ed25519 \
  > ~/.ssh/my-new-repo-inception.pub
```

**Step 3: Configure Git**
```bash
git config --global user.signingkey ~/.ssh/my-new-repo-inception.pub
git config --global gpg.format ssh
git config --global commit.gpgsign true
```

**Step 4: Create Open Integrity repository**
```bash
nix run github:lessuselesss/openintegrityproject-core#setup-git-inception-repo \
  -- --repo my-new-repo
```

### Key Rotation Example

When rotating from inception key to daily signing key:

**Old key (inception):**
```json
[
  {"@type": "Person", "name": "Ashley Barr", "email": "lessuseless@duck.com"},
  {"@type": "SoftwareSourceCode", "name": "my-repo"},
  {"@type": "Text", "text": "inception"}
]
```

**New key (signing):**
```json
[
  {"@type": "Person", "name": "Ashley Barr", "email": "lessuseless@duck.com"},
  {"@type": "SoftwareSourceCode", "name": "my-repo"},
  {"@type": "Text", "text": "signing"}
]
```

Both provably from same seed, enabling secure transition.

### Recovery Procedure

**Step 1: Restore mnemonic seed**
```bash
# Enter your 12/24 word seed phrase
bip-keychain restore
```

**Step 2: List all derived keys**
```bash
# Scan common derivation paths
bip-keychain scan-repos \
  --person "Ashley Barr" \
  --email "lessuseless@duck.com"
```

**Step 3: Regenerate specific key**
```bash
bip-keychain derive \
  --mnemonic-file ~/.secrets/seed.txt \
  --repo "my-lost-repo" \
  --purpose "inception"
```

**Step 4: Verify against repository**
```bash
nix run github:lessuselesss/openintegrityproject-core#audit-inception-commit \
  -- -C /path/to/recovered/repo
```

## Advanced Patterns

### Pattern 1: Organizational Hierarchy

**Top-level organization:**
```json
{"@type": "Organization", "name": "Acme Corp"}
```

**Division:**
```json
{"@type": "Organization", "name": "Engineering", "parentOrganization": "Acme Corp"}
```

**Project:**
```json
{"@type": "SoftwareSourceCode", "name": "backend-api"}
```

**Member:**
```json
{"@type": "Person", "name": "Ashley Barr", "memberOf": "Engineering"}
```

Full path represents: Acme Corp → Engineering → backend-api → Ashley Barr → inception key

### Pattern 2: Time-Based Rotation

Include date in version for automatic key rotation:

```json
[
  {"@type": "Person", "name": "Ashley Barr"},
  {"@type": "SoftwareSourceCode", "name": "my-repo"},
  {"@type": "Text", "text": "signing-2025-Q1"}
]
```

Derive new keys each quarter.

### Pattern 3: Multi-Signature Quorum

Different team members derive keys from their own seeds:

**Alice's key:**
```json
[
  {"@type": "Organization", "name": "MyOrg"},
  {"@type": "SoftwareSourceCode", "name": "critical-repo"},
  {"@type": "Person", "name": "Alice", "email": "alice@example.com"},
  {"@type": "Text", "text": "signing"}
]
```

**Bob's key:**
```json
[
  {"@type": "Organization", "name": "MyOrg"},
  {"@type": "SoftwareSourceCode", "name": "critical-repo"},
  {"@type": "Person", "name": "Bob", "email": "bob@example.com"},
  {"@type": "Text", "text": "signing"}
]
```

Both can be added to `allowed_commit_signers` for delegation.

### Pattern 4: Hardware Wallet Integration

Derive inception key from hardware wallet (never exposed to computer):

```json
[
  {"@type": "Person", "name": "Ashley Barr"},
  {"@type": "SoftwareSourceCode", "name": "secure-project"},
  {"@type": "Text", "text": "inception"}
]
```

Derive signing key from software wallet (daily use):

```json
[
  {"@type": "Person", "name": "Ashley Barr"},
  {"@type": "SoftwareSourceCode", "name": "secure-project"},
  {"@type": "Text", "text": "signing"}
]
```

Hardware wallet signs inception + transition commits only.

## Security Considerations

### Seed Management

**DO:**
- ✅ Store mnemonic offline in secure location
- ✅ Use hardware wallets for inception keys when possible
- ✅ Test recovery procedure before trusting
- ✅ Use separate seeds for high-value vs. experimental repos

**DON'T:**
- ❌ Store seed in plain text on computer
- ❌ Use same seed for crypto wallets and git signing
- ❌ Derive keys on untrusted machines
- ❌ Share derivation paths publicly before creating repos

### Key Hygiene

**Inception Keys:**
- Store offline or in hardware wallet
- Only use for inception commit and authority delegation
- Never use for daily commits

**Signing Keys:**
- Can be on computer for daily use
- Rotate periodically (quarterly/annually)
- Monitor for unauthorized use

**Backup Keys:**
- Never expose to network
- Store in physically separate location
- Document recovery procedure

### Path Security

**Public Information:**
- Person name (if using real name)
- Organization name
- Repository name (if public)
- Key purpose

**Private Information:**
- Mnemonic seed (NEVER share)
- Derived private keys (protect carefully)
- Hardware wallet PINs

## Future Enhancements

### Planned Features

**Cross-Repository Attestations:**
```json
[
  {"@type": "Person", "name": "Ashley Barr"},
  {"@type": "SoftwareSourceCode", "name": "repo-a"},
  {
    "@type": "Action",
    "name": "attest",
    "object": {"@type": "SoftwareSourceCode", "name": "repo-b"}
  }
]
```

**Delegation Chains:**
```json
[
  {"@type": "Organization", "name": "MyOrg"},
  {"@type": "SoftwareSourceCode", "name": "project"},
  {"@type": "Person", "name": "Alice"},
  {
    "@type": "Action",
    "name": "delegate",
    "recipient": {"@type": "Person", "name": "Bob"}
  }
]
```

**Time-Locked Keys:**
```json
[
  {"@type": "Person", "name": "Ashley Barr"},
  {"@type": "SoftwareSourceCode", "name": "my-repo"},
  {
    "@type": "Action",
    "name": "expire",
    "endTime": "2026-01-01T00:00:00Z"
  }
]
```

## Reference Implementation

This document describes the **theoretical integration** of BIP-keychain with Open Integrity.

**Reference implementations:**
- BIP-keychain: https://github.com/akarve/bip-keychain
- Open Integrity: https://github.com/OpenIntegrityProject/core

**Status:** Draft specification for community feedback and refinement.

## Contributing

We welcome feedback on:
- Derivation path patterns and conventions
- Schema.org property usage
- Security considerations
- Integration approaches
- Additional use cases

Please open issues or discussions in the [OpenIntegrityProject/core](https://github.com/OpenIntegrityProject/core) repository.

## License

This document: BSD-2-Clause-Patent
BIP-keychain proposal: See upstream repository
Schema.org: CC BY-SA 3.0

## Acknowledgments

- [BIP-keychain](https://github.com/akarve/bip-keychain) by akarve
- [Schema.org](https://schema.org) vocabulary
- Open Integrity Project community
- Blockchain Commons

---

**Document Status:** DRAFT - Subject to change based on community feedback and BIP-keychain evolution.
