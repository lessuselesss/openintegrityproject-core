{
  description = "Open Integrity Project - Cryptographic Roots of Trust for Open Source Development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Main package for the Open Integrity Project scripts
        openintegrity = pkgs.stdenv.mkDerivation {
          pname = "openintegrity";
          version = "0.1.0";

          src = ./.;

          buildInputs = with pkgs; [
            zsh
            git
            openssh
            gnupg
          ];

          nativeBuildInputs = with pkgs; [
            makeWrapper
          ];

          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share/openintegrity/src
            mkdir -p $out/share/openintegrity/src/lib
            mkdir -p $out/share/openintegrity/src/requirements
            mkdir -p $out/share/openintegrity/src/issues
            mkdir -p $out/share/openintegrity/src/tests

            # Copy documentation and supporting files
            cp -r docs $out/share/openintegrity/
            cp -r contexts $out/share/openintegrity/
            cp -r examples $out/share/openintegrity/
            cp README.md $out/share/openintegrity/
            cp ROADMAP.md $out/share/openintegrity/

            # Install main scripts with execute permissions
            install -m755 src/audit_inception_commit-POC.sh $out/share/openintegrity/src/
            install -m755 src/get_repo_did.sh $out/share/openintegrity/src/
            install -m755 src/setup_git_inception_repo.sh $out/share/openintegrity/src/
            install -m755 src/setup_hardware_signing.sh $out/share/openintegrity/src/
            install -m755 src/setup_git_inception_repo_hardware.sh $out/share/openintegrity/src/
            install -m755 src/snippet_template.sh $out/share/openintegrity/src/

            # Copy supporting files and directories
            cp -r src/lib/* $out/share/openintegrity/src/lib/ 2>/dev/null || true
            cp -r src/requirements/* $out/share/openintegrity/src/requirements/ 2>/dev/null || true
            cp -r src/issues/* $out/share/openintegrity/src/issues/ 2>/dev/null || true
            cp -r src/tests/* $out/share/openintegrity/src/tests/ 2>/dev/null || true
            [ -f src/README.md ] && cp src/README.md $out/share/openintegrity/src/

            # Create wrapper scripts in bin
            makeWrapper $out/share/openintegrity/src/audit_inception_commit-POC.sh \
              $out/bin/openintegrity-audit \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git pkgs.openssh pkgs.gnupg pkgs.zsh ]}

            makeWrapper $out/share/openintegrity/src/get_repo_did.sh \
              $out/bin/openintegrity-getdid \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git pkgs.openssh pkgs.gnupg pkgs.zsh ]}

            makeWrapper $out/share/openintegrity/src/setup_git_inception_repo.sh \
              $out/bin/openintegrity-setup \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git pkgs.openssh pkgs.gnupg pkgs.zsh ]}

            makeWrapper $out/share/openintegrity/src/setup_hardware_signing.sh \
              $out/bin/openintegrity-setup-hardware \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git pkgs.openssh pkgs.gnupg pkgs.zsh ]}

            makeWrapper $out/share/openintegrity/src/setup_git_inception_repo_hardware.sh \
              $out/bin/openintegrity-setup-hardware-repo \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git pkgs.openssh pkgs.gnupg pkgs.zsh ]}
          '';

          meta = with pkgs.lib; {
            description = "Cryptographic Roots of Trust for Open Source Development";
            homepage = "https://github.com/OpenIntegrityProject/core";
            license = licenses.bsd2Patent;
            maintainers = [ ];
            platforms = platforms.unix;
          };
        };

        # Helper function to create app configurations
        mkApp = scriptPath: {
          type = "app";
          program = "${openintegrity}/bin/${scriptPath}";
        };

      in
      {
        packages = {
          default = openintegrity;
          openintegrity = openintegrity;
        };

        apps = {
          # Main apps for each script
          audit = mkApp "openintegrity-audit";
          getdid = mkApp "openintegrity-getdid";
          setup = mkApp "openintegrity-setup";
          setup-hardware = mkApp "openintegrity-setup-hardware";
          setup-hardware-repo = mkApp "openintegrity-setup-hardware-repo";

          # Default app
          default = {
            type = "app";
            program = "${openintegrity}/bin/openintegrity-audit";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zsh
            git
            openssh
            gnupg
            gh
          ];

          shellHook = ''
            cat << 'EOF'

            ╔═══════════════════════════════════════════════════════════════════╗
            ║                  Open Integrity Project DevShell                  ║
            ║          Cryptographic Roots of Trust for Open Source            ║
            ╚═══════════════════════════════════════════════════════════════════╝

            🔍 Available Scripts:
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

            📋 Main Operations:
              ./src/audit_inception_commit-POC.sh [OPTIONS]
                → Audit a repository's inception commit
                → Options: -C <path>, --verbose, --debug

              ./src/get_repo_did.sh [-C <path>]
                → Retrieve repository's DID
                → Default: current directory

              ./src/setup_git_inception_repo.sh [OPTIONS]
                → Setup Git inception repository

            🔐 Hardware Signing Setup:
              ./src/setup_hardware_signing.sh [OPTIONS]
                → Configure hardware security keys for Git signing
                → Supports: YubiKey, Flipper Zero, FIDO2/U2F devices
                → Options: --key-type, --resident, --no-prompt

              ./src/setup_git_inception_repo_hardware.sh [OPTIONS]
                → Create repository with hardware-signed inception commit
                → Integrated workflow: hardware setup + repository creation
                → Options: --repo, --key-type, --force

            🧪 Testing:
              ./src/tests/TEST-audit_inception_commit.sh [--verbose]
                → Run audit tests

              ./src/tests/TEST-create_inception_commit.sh
                → Run creation tests

            📚 Documentation:
              cat README.md              → Project overview
              cat ROADMAP.md             → Development roadmap
              ls docs/                   → Additional documentation
              ls src/requirements/       → Script requirements
              ls src/issues/             → Known issues

            💡 Quick Examples:
              # Audit this repository
              ./src/audit_inception_commit-POC.sh

              # Audit another repository
              ./src/audit_inception_commit-POC.sh -C /path/to/repo

              # Setup a new repository
              ./src/setup_git_inception_repo.sh

              # Get repository DID
              ./src/get_repo_did.sh

              # Setup hardware signing (YubiKey/FIDO2)
              ./src/setup_hardware_signing.sh --key-type ed25519-sk

              # Setup hardware signing (Flipper Zero/U2F)
              ./src/setup_hardware_signing.sh --key-type ecdsa-sk

              # Create repository with hardware-signed inception commit
              ./src/setup_git_inception_repo_hardware.sh --repo my_secure_repo

            🔧 Development Tools Available:
              git, zsh, openssh, gnupg, gh (GitHub CLI)

            📦 Nix Apps (run without cloning):
              # Run from GitHub directly
              nix run github:OpenIntegrityProject/core#audit
              nix run github:OpenIntegrityProject/core#getdid
              nix run github:OpenIntegrityProject/core#setup
              nix run github:OpenIntegrityProject/core#setup-hardware
              nix run github:OpenIntegrityProject/core#setup-hardware-repo

              # Or install globally
              nix profile install github:OpenIntegrityProject/core

            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            📖 For more information: https://OpenIntegrityProject.info
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

            EOF
          '';
        };
      }
    );
}
