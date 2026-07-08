{
  description = "Ioskeley Mono JP — BIZ UDゴシック × Ioskeley Mono (Iosevka) 合成の日本語等幅プログラミングフォント";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        version = "0.0.1";
        baseUrl = "https://github.com/takeshiD/IoskeleyMonoJP/releases/download/v${version}";

        # Releases の zip から .ttf を取り出してフォントとしてインストールする。
        mkFontPkg =
          {
            pname,
            zip,
            sha256,
          }:
          pkgs.stdenvNoCC.mkDerivation {
            inherit pname version;

            src = pkgs.fetchurl {
              url = "${baseUrl}/${zip}";
              inherit sha256;
            };

            nativeBuildInputs = [ pkgs.unzip ];

            dontConfigure = true;
            dontBuild = true;
            sourceRoot = ".";

            installPhase = ''
              runHook preInstall
              install -Dm644 -t "$out/share/fonts/truetype" $(find . -name '*.ttf')
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "日本語等幅プログラミングフォント Ioskeley Mono JP (${pname})";
              homepage = "https://github.com/takeshiD/IoskeleyMonoJP";
              license = licenses.ofl;
              platforms = platforms.all;
            };
          };

        # 通常版 (リガチャ無効/有効・幅 1:2 / 3:5 を同梱)
        ioskeley-mono-jp = mkFontPkg {
          pname = "ioskeley-mono-jp";
          zip = "IoskeleyMonoJP_v${version}.zip";
          sha256 = "sha256-UzW0xYrObKIT/dXRXspl4mSqOqAIkQnYZ/yq3/eU9wo=";
        };

        # Nerd Fonts 版 (ターミナル向けにアイコングリフを収録)
        ioskeley-mono-jp-nf = mkFontPkg {
          pname = "ioskeley-mono-jp-nf";
          zip = "IoskeleyMonoJP_NF_v${version}.zip";
          sha256 = "sha256-E/IVqluDqgyu/7AAbcrGvsoVHX4PX1Qskv6jZ7UGN1Q=";
        };
      in
      {
        packages = {
          default = ioskeley-mono-jp;
          ioskeley-mono-jp = ioskeley-mono-jp;
          ioskeley-mono-jp-nf = ioskeley-mono-jp-nf;
        };

        # フォントの合成ビルド・サンプル画像生成に必要な一式を揃えた開発シェル。
        #   nix develop    → シェルに入る
        #   ./build.sh     → 全バリアントを合成
        #   ./scripts/generate-samples.sh → README 用サンプル画像を生成
        devShells.default = pkgs.mkShell {
          name = "ioskeley-mono-jp-dev";

          packages = with pkgs; [
            fontforge
            nodejs_22
            silicon
            ttfautohint
            (python3.withPackages (ps: [
              ps.fonttools
              ps.brotli # woff2 圧縮用
            ]))
          ];

          shellHook = ''
            echo "Ioskeley Mono JP 開発シェル"
            echo "  ./build.sh                     … フォントを合成 (要 source/ の Iosevka ビルド済み TTF)"
            echo "  ./scripts/generate-samples.sh  … README 用のサンプル画像を生成"
          '';
        };
      }
    );
}
