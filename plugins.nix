inputs: final: prev:
let
  withSrc = pkg: src: pkg.overrideAttrs (_: { inherit src; });
  plugin = pname: src: prev.vimUtils.buildVimPluginFrom2Nix {
    inherit pname src;
    version = "master";
  };
in
with inputs; {

  terraform-ls = with prev;
    (buildGoModule rec {
      pname = "terraform-ls";
      version = "0.27.0";

      src = fetchFromGitHub {
        owner = "hashicorp";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-TWxYCHdzeJtdyPajA3XxqwpDufXnLod6LWa28OHjyms=";
      };

      vendorSha256 = "sha256-e/m/8h0gF+kux+pCUqZ7Pw0XlyJ5dL0Zyqb0nUlgfpc=";
      ldflags = [ "-s" "-w" "-X main.version=v${version}" "-X main.prerelease=" ];

      # There's a mixture of tests that use networking and several that fail on aarch64
      doCheck = false;

      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck
        $out/bin/terraform-ls --help
        $out/bin/terraform-ls version | grep "v${version}"
        runHook postInstallCheck
      '';

      meta = with lib; {
        description = "Terraform Language Server (official)";
        homepage = "https://github.com/hashicorp/terraform-ls";
        changelog = "https://github.com/hashicorp/terraform-ls/blob/v${version}/CHANGELOG.md";
        license = licenses.mpl20;
        maintainers = with maintainers; [ mbaillie jk ];
      };
    });
  rnix-lsp = inputs.rnix-lsp.packages.${prev.system}.rnix-lsp;

  telescope-nvim = (withSrc prev.vimPlugins.telescope-nvim inputs.telescope-src);
  cmp-buffer = (withSrc prev.vimPlugins.cmp-buffer inputs.cmp-buffer);
  nvim-cmp = (withSrc prev.vimPlugins.nvim-cmp inputs.nvim-cmp);

  cmp-nvim-lsp = withSrc prev.vimPlugins.cmp-nvim-lsp inputs.cmp-nvim-lsp;

  # Example of packaging plugin with Nix
  blamer-nvim = plugin "blamer-nvim" blamer-nvim-src;
  colorizer = plugin "colorizer" colorizer-src;
  comment-nvim = plugin "comment-nvim" comment-nvim-src;
  conceal = plugin "conceal" conceal-src;
  dracula = plugin "dracula" dracula-nvim;
  fidget = plugin "fidget" fidget-src;
  neogen = plugin "neogen" neogen-src;
  parinfer-rust-nvim = plugin "parinfer-rust" prev.parinfer-rust;
  rust-tools = plugin "rust-tools" rust-tools-src;
  telescope-ui-select = plugin "telescope-ui-select" telescope-ui-select-src;
  which-key = plugin "which-key" which-key-src;
}
