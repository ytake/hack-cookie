namespace Ytake\HackCookie;

use namespace HH\Lib\{Regex, Str};
use function array_key_exists;
use function preg_quote;
use function strval;
use function preg_match_all_with_matches;
use const PREG_SET_ORDER;

class Header {

  <<__Rx>>
  public static function combine(
    vec<vec<mixed>> $parts
  ): dict<string, mixed> {
    $assoc = dict[];
    foreach ($parts as $part) {
      if(array_key_exists(0, $part)) {
        $assoc[Str\lowercase(strval($part[0]))] = $part[1] ?? true;
      }
    }
    return $assoc;
  }

  public static function unquote(
    string $s
  ): string {
    return Regex\replace($s, re"/\\\\(.)|\"/", '$1');
  }

  public static function split(
    string $header,
    string $separators
  ): vec<mixed> {
    $quotedSeparators = preg_quote($separators, '/');
    $matches = vec[];
    preg_match_all_with_matches('
      /
        (?!\s)
          (?:
            # quoted-string
            "(?:[^"\\\\]|\\\\.)*(?:"|\\\\|$)
          |
            # token
            [^"'.$quotedSeparators.']+
          )+
        (?<!\s)
      |
        # separator
        \s*
        (?<separator>['.$quotedSeparators.'])
        \s*
      /x', Str\trim($header), inout $matches, PREG_SET_ORDER);
    return self::groupParts(vec($matches), $separators);
  }
    
  private static function groupParts(
    vec<dict<arraykey, mixed>> $matches,
    string $separators
  ): vec<mixed> {
    $separator = $separators[0];
    $partSeparators = Str\slice($separators, 1);
    $i = 0;
    $partMatches = [];
    foreach ($matches as $match) {
      if (array_key_exists('separator', $match) && $match['separator'] === $separator) {
        ++$i;
      } else {
        $partMatches[$i][] = $match;
      }
    }
    $parts = vec[];
    if ($partSeparators) {
      foreach ($partMatches as $matches) {
        $parts[] = self::groupParts(vec($matches), $partSeparators);
      }
      return $parts;
    }
    foreach ($partMatches as $matches) {
      $parts[] = self::unquote($matches[0][0]);
    }
    return $parts;
  }
}
