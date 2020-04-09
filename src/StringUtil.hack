namespace Ytake\HackCookie;

use namespace HH\Lib\{Str, Vec};
use function preg_split;
use function urldecode;
use function array_key_exists;

final class StringUtil {

  public static function splitOnAttributeDelimiter(
    string $string
  ) : vec<string> {
    return vec(preg_split('@\s*[;]\s*@', $string));
  }

  public static function splitCookiePair(
    string $string
  ) : vec<string> {
    $pairParts = Str\split($string, '=', 2);
    if(!array_key_exists(1, $pairParts)) {
      $pairParts[] = '';
    }
    $pairParts[1] = $pairParts[1] ?? '';
    return Vec\map($pairParts, ($v) ==> urldecode($v));
  }
}
