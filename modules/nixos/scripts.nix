{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.scripts;

  convertForResolve = pkgs.writeShellScriptBin "convert-for-resolve" ''
    set -euo pipefail

    usage() {
      echo "Usage: convert-for-resolve [OPTIONS] <input> [input2 ...]"
      echo ""
      echo "Convert videos to DaVinci Resolve compatible format (DNxHR in MOV)"
      echo ""
      echo "Options:"
      echo "  -q, --quality <QUALITY>  DNxHR quality profile (default: hq)"
      echo "                           Profiles: lb (low), sq (standard), hq (high), hqx (high 10-bit), 444 (highest)"
      echo "  -o, --output <DIR>       Output directory (default: current directory)"
      echo "  -h, --help               Show this help message"
      echo ""
      echo "Examples:"
      echo "  convert-for-resolve video.mp4"
      echo "  convert-for-resolve -q hqx -o ./converted *.mp4"
      exit 0
    }

    QUALITY="hq"
    OUTPUT_DIR="."

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -q|--quality)
          QUALITY="$2"
          shift 2
          ;;
        -o|--output)
          OUTPUT_DIR="$2"
          shift 2
          ;;
        -h|--help)
          usage
          ;;
        -*)
          echo "Unknown option: $1" >&2
          exit 1
          ;;
        *)
          break
          ;;
      esac
    done

    if [[ $# -eq 0 ]]; then
      echo "Error: No input files specified" >&2
      usage
    fi

    # Map quality names to ffmpeg profile names
    case "$QUALITY" in
      lb)  PROFILE="dnxhr_lb" ;;
      sq)  PROFILE="dnxhr_sq" ;;
      hq)  PROFILE="dnxhr_hq" ;;
      hqx) PROFILE="dnxhr_hqx" ;;
      444) PROFILE="dnxhr_444" ;;
      *)
        echo "Error: Unknown quality profile: $QUALITY" >&2
        echo "Valid profiles: lb, sq, hq, hqx, 444" >&2
        exit 1
        ;;
    esac

    mkdir -p "$OUTPUT_DIR"

    for INPUT in "$@"; do
      if [[ ! -f "$INPUT" ]]; then
        echo "Warning: File not found: $INPUT" >&2
        continue
      fi

      BASENAME="$(basename "''${INPUT%.*}")"
      OUTPUT="$OUTPUT_DIR/''${BASENAME}_dnxhr.mov"

      echo "Converting: $INPUT -> $OUTPUT (profile: $PROFILE)"
      ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
        -c:v dnxhd -profile:v "$PROFILE" \
        -c:a pcm_s16le \
        -f mov \
        "$OUTPUT"
      echo "Done: $OUTPUT"
    done
  '';
in
{
  options.scripts = {
    convert-for-resolve = {
      enable = mkEnableOption "convert-for-resolve script for DaVinci Resolve";
    };
  };

  config = mkMerge [
    (mkIf cfg.convert-for-resolve.enable {
      environment.systemPackages = [ convertForResolve ];
    })
  ];
}
