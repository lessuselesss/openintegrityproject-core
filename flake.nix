{
  description = "Open Integrity Project - Cryptographic Roots of Trust for Open Source Development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Supported systems
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Helper to generate attributes for all systems
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Helper to get nixpkgs for a system
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      # Package for the Open Integrity scripts
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "openintegrity";
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            buildInputs = [
              pkgs.zsh
              pkgs.git
              pkgs.openssh
              pkgs.gh
              pkgs.ncurses
            ];

            installPhase = ''
              runHook preInstall

              # Create directory structure
              mkdir -p $out/libexec/openintegrity/lib
              mkdir -p $out/bin

              # Install the Z_Utils library
              install -m 755 src/lib/_Z_Utils.zsh $out/libexec/openintegrity/lib/

              # Install main scripts
              install -m 755 src/audit_inception_commit-POC.sh $out/libexec/openintegrity/
              install -m 755 src/get_repo_did.sh $out/libexec/openintegrity/
              install -m 755 src/setup_git_inception_repo.sh $out/libexec/openintegrity/

              # Create wrapper scripts that ensure dependencies are in PATH
              # and set up the environment properly

              # audit_inception_commit-POC.sh wrapper
              makeWrapper $out/libexec/openintegrity/audit_inception_commit-POC.sh \
                $out/bin/audit-inception-commit \
                --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.zsh pkgs.git pkgs.openssh pkgs.gh pkgs.ncurses ]}

              # get_repo_did.sh wrapper
              makeWrapper $out/libexec/openintegrity/get_repo_did.sh \
                $out/bin/get-repo-did \
                --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.zsh pkgs.git pkgs.openssh ]}

              # setup_git_inception_repo.sh wrapper
              makeWrapper $out/libexec/openintegrity/setup_git_inception_repo.sh \
                $out/bin/setup-git-inception-repo \
                --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.zsh pkgs.git pkgs.openssh ]}

              runHook postInstall
            '';

            # Fix shebangs to use the zsh from nixpkgs
            postFixup = ''
              patchShebangs $out/libexec/openintegrity
            '';

            meta = with pkgs.lib; {
              description = "Cryptographic Roots of Trust for Open Source Development";
              homepage = "https://github.com/OpenIntegrityProject/core";
              license = licenses.bsd2Patent;
              maintainers = [ ];
              platforms = platforms.unix;
            };
          };
        }
      );

      # Nix apps for easy execution
      apps = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          package = self.packages.${system}.default;
        in
        {
          # Default app is audit-inception-commit
          default = {
            type = "app";
            program = "${package}/bin/audit-inception-commit";
          };

          audit-inception-commit = {
            type = "app";
            program = "${package}/bin/audit-inception-commit";
          };

          get-repo-did = {
            type = "app";
            program = "${package}/bin/get-repo-did";
          };

          setup-git-inception-repo = {
            type = "app";
            program = "${package}/bin/setup-git-inception-repo";
          };
        }
      );

      # Development shell with all dependencies
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              zsh
              git
              openssh
              gh
              ncurses
            ];

            shellHook = ''
              echo "Open Integrity Project Development Environment"
              echo "Available scripts:"
              echo "  ./src/audit_inception_commit-POC.sh"
              echo "  ./src/get_repo_did.sh"
              echo "  ./src/setup_git_inception_repo.sh"
            '';
          };
        }
      );
    };
}
