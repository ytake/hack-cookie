/**
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * This software consists of voluntary contributions made by many individuals
 * and is licensed under the MIT license.
 *
 * Copyright (c) 2020 Yuuki Takezawa
 */

namespace Ytake\HackCookie;

use namespace HH\Lib\{Str, Vec};
use function preg_split;
use function urldecode;
use function array_key_exists;
use const PREG_SPLIT_NO_EMPTY;

final class StringUtil {

  <<__Rx>>
  public static function splitOnAttributeDelimiter(
    string $string
  ) : vec<string> {
    return vec(preg_split('@\s*[;]\s*@', $string, -1, PREG_SPLIT_NO_EMPTY));
  }

  <<__Rx>>
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
