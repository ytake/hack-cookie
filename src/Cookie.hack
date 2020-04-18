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

use namespace HH\Lib\Vec;
use function urlencode;

class Cookie {

  public function __construct(
    private string $name,
    private string $value = ''
  ) {}

  public function getName() : string {
    return $this->name;
  }

  public function getValue() : string {
    return $this->value;
  }

  public function withValue(
    string $value = ''
  ) : Cookie {
    $clone = clone($this);
    $clone->value = $value;
    return $clone;
  }

  public function toString() : string {
    return urlencode($this->name)
      . '='
      . urlencode((string) $this->value);
  }

  public static function create(
    string $name,
    string $value = ''
  ) : Cookie {
    return new self($name, $value);
  }

  public static function listFromCookieString(
    string $string
  ) : vec<Cookie> {
    $cookies = StringUtil::splitOnAttributeDelimiter($string);
    return Vec\map($cookies, ($v) ==> static::oneFromCookiePair($v));
  }

  public static function oneFromCookiePair(
    string $string
  ): Cookie {
    list ($cookieName, $cookieValue) = StringUtil::splitCookiePair($string);
    $cookie = new self($cookieName);
    if ($cookieValue !== null) {
      $cookie = $cookie->withValue($cookieValue);
    }
    return $cookie;
  }
}
