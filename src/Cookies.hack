namespace Ytake\HackCookie;

use namespace HH\Lib\{C, Str, Vec};
use type Ytake\HackCookie\Exception\InValidCookieException;
use type Facebook\Experimental\Http\Message\RequestInterface;
use function array_values;

class Cookies {
  const string COOKIE_HEADER = 'Cookie';

  private dict<string, Cookie> $cookies = dict[];

  public function __construct(
    vec<Cookie> $cookies = vec[]
  ) {
    foreach ($cookies as $cookie) {
      $this->cookies[$cookie->getName()] = $cookie;
    }
  }

  public function has(string $name): bool {
    $cvec = Vec\filter_with_key($this->cookies, ($k, $_) ==> $k === $name);
    return C\count($cvec) === 1;
  }

  public function get(
    string $name
  ): Cookie {
    if ($this->has($name)) {
      return $this->cookies[$name];
    }
    throw new InValidCookieException(Str\format("invalid cookie: %s", $name));
  }

  public function getAll(): vec<Cookie> {
    return vec(array_values($this->cookies));
  }
  
  public function with(
    Cookie $cookie
  ): Cookies {
    $clone = clone($this);
    $clone->cookies[$cookie->getName()] = $cookie;
    return $clone;
  }

  public function without(string $name): Cookies {
    $clone = clone($this);
    if (!$clone->has($name)) {
      return $clone;
    }
    unset($clone->cookies[$name]);
    return $clone;
  }

  public function renderIntoCookieHeader(
    RequestInterface $request
  ): RequestInterface {
    $cookieString = Str\join(
      Vec\map($this->cookies,
      ($v) ==> $v->toString()), '; '
    );
    $request = $request->withHeader(static::COOKIE_HEADER, vec[$cookieString]);
    return $request;
  }

  public static function fromCookieString(string $string): Cookies {
    return new Cookies(Cookie::listFromCookieString($string));
  }

  public static function fromRequest(
    RequestInterface $request
  ): Cookies {
    return $request->getHeaderLine(static::COOKIE_HEADER)
      |> static::fromCookieString($$);
  }
}
