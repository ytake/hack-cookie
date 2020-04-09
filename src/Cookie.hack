namespace Ytake\HackCookie;

use namespace HH\Lib\Vec;
use function urlencode;

class Cookie {

  public function __construct(
    private string $name,
    private ?string $value = null
  ) {}

  public function getName() : string {
    return $this->name;
  }

  public function getValue() : ?string {
    return $this->value;
  }

  public function withValue(
    ?string $value = null
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
    ?string $value = null
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
