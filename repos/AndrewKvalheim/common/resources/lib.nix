{ lib }:

let
  inherit (builtins) add all attrValues floor head mapAttrs split stringLength tail;
  inherit (lib) concatLines fixedWidthNumber fold isList max removeSuffix splitString throwIf throwIfNot toHexString;
  inherit (lib.strings) replicate;
  inherit (import <nix-math> { inherit lib; }) cos pi pow sin;
in
rec {
  # Adapted from https://en.wikipedia.org/wiki/Clenshaw_algorithm#Special_case_for_Chebyshev_series
  chebyshev = coefficients: x:
    let
      a0 = head coefficients;
      recurrence = a: { b1, b2 }: { b1 = a + 2.0 * x * b1 - b2; b2 = b1; };
      inherit (fold recurrence ({ b1 = 0; b2 = 0; }) (tail coefficients)) b1 b2;
      b0 = 2.0 * x * b1 - b2;
    in
    0.5 * (a0 + b0 - b2);

  chebyshevWithDomain = beginning: end: coefficients: x:
    chebyshev coefficients (-1.0 + 2.0 * (x - beginning) / (end - beginning));

  # Adapted from https://www.w3.org/WAI/WCAG22/Techniques/general/G18
  contrastRatio = linearRgb1: linearRgb2:
    let
      linearRgbToRelativeLuminance = rgb: with rgb; 0.2126 * r + 0.7152 * g + 0.0722 * b;
      flare = 0.05;
      ratio = light: dark: (light + flare) / (dark + flare);

      l1 = linearRgbToRelativeLuminance linearRgb1;
      l2 = linearRgbToRelativeLuminance linearRgb2;
    in
    if l1 < l2 then ratio l2 l1 else ratio l1 l2;

  findHighest = accept: resolution: low: high:
    if high - low < resolution then
      throwIfNot (accept low) "Lower bound ${toString low} fails acceptance test" low
    else
      let half = low + (high - low) * 0.5; in
      if accept half then findHighest accept resolution half high
      else findHighest accept resolution low half;

  findLowest = accept: resolution: low: high:
    if high - low < resolution then
      throwIfNot (accept high) "Upper bound ${toString high} fails acceptance test" high
    else
      let half = low + (high - low) * 0.5; in
      if accept half then findLowest accept resolution low half
      else findLowest accept resolution half high;

  frame = color: text:
    let
      lines = splitString "\n" (removeSuffix "\n" text);
      pad = printablePad (fold max 0 (map printableLength lines));
    in
    concatLines ([
      (color "┌───${pad "─" ""}───┐")
      (color "│   ${pad " " ""}   │")
    ] ++ map (l: "${color "│"}   ${pad " " l}   ${color "│"}") lines ++ [
      (color "│   ${pad " " ""}   │")
      (color "└───${pad "─" ""}───┘")
    ]);

  # Adapted from https://bottosson.github.io/posts/colorwrong/#what-can-we-do%3F
  linearRgbToRgb =
    let
      # Chebyshev approximation of pow(x, 1/2.4) pending NixOS/nix#10387
      pow124 = chebyshevWithDomain 0.0031308 1 [
        ( 1.35260207301243970000) 0.38736989090862184000 (-0.08938836754963890000) 0.03917078116806109500
        (-0.02150246605817849500) 0.01327548250086058700 (-0.00881110971315325000) 0.00614173454829631900
        (-0.00443508676265795600) 0.00328923055264219740 (-0.00249069759461179650) 0.00191769186446961480
        (-0.00149672058852221450) 0.00118140030563393050 (-0.00094135949601563060) 0.00075609147141938310
        (-0.00061138616643234040) 0.00049717532665433370 (-0.00040618639285779080) 0.00033307652979395076
        (-0.00027386103644766590) 0.00022552739353182616 (-0.00018576931142631020) 0.00015280006795680320
        (-0.00012521926145068812) 0.00010191616551636761 (-0.00008199853484320359) 0.00006473932345743365
        (-0.00004953612261597226) 0.00003587967164602856 (-0.00002332882551685266) 0.00001149005313142370
      ];
    in
    rgb: mapAttrs (_: u: if u > 0.0031308 then 1.055 * (pow124 u) - 0.055 else 12.92 * u) rgb;

  oklchToCss = { l, c, h }: "oklch(${toString l} ${toString c} ${toString h})";

  oklchToLinearRgb = target:
    let
      convert = { l, c, h }:
        let
          # Adapted from https://drafts.csswg.org/css-color-4/#color-conversion-code
          a = c * cos (h * pi / 180);
          b = c * sin (h * pi / 180);

          # Adapted from https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
          long = pow (l + 0.3963377774 * a + 0.2158037573 * b) 3;
          medium = pow (l - 0.1055613458 * a - 0.0638541728 * b) 3;
          short = pow (l - 0.0894841775 * a - 1.2914855480 * b) 3;
          rgb = {
            r = 4.0767416621 * long - 3.3077115913 * medium + 0.2309699292 * short;
            g = -1.2684380046 * long + 2.6097574011 * medium - 0.3413193965 * short;
            b = -0.0041960863 * long - 0.7034186147 * medium + 1.7076147010 * short;
          };
        in
        if all (u: 0 <= u && u <= 1) (attrValues rgb) then rgb else null;

      result = convert target;
      inGamut = c: convert (target // { inherit c; }) != null;
      clamped = target // { c = findHighest inGamut 0.0000005 0 0.37; };
    in
    throwIf (result == null)
      "Not representable in sRGB\n   Target: ${oklchToCss target}\n  Clamped: ${oklchToCss clamped}"
      result;

  printableLength = text: fold add 0 (map (v: if isList v then 0 else stringLength v) (split "\\[[^m]*m" text));

  printablePad = width: placeholder: text: text + replicate (width - printableLength text) placeholder;

  rgbToAnsi = rgb: with mapAttrs (_: v: toString (round (v * 255))) rgb; "38;2;${r};${g};${b}";

  rgbToHex = { r, g, b }:
    let f = x: fixedWidthNumber 2 (toHexString (round (x * 255)));
    in "#${f r}${f g}${f b}";

  round = x: floor (x + 0.5);

  sgr = n: t: "[${n}m${t}[0m";
}
