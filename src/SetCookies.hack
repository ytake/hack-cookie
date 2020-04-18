namespace Ytake\HackCookie;

use type Ytake\HackCookie\Exception\InValidCookieException;
use type Facebook\Experimental\Http\Message\ResponseInterface;
use namespace HH\Lib\{C, Dict, Str, Vec};
use function array_values;

class SetCookies {
  const string SET_COOKIE_HEADER = 'Set-Cookie';

  private dict<string, SetCookie> $setCookies = dict[];

  public function __construct(
    vec<SetCookie> $setCookies = vec[]
  ) {
    foreach ($setCookies as $setCookie) {
      $this->setCookies[$setCookie->getName()] = $setCookie;
    }
  }

  <<__Rx>>
  public function has(
    string $name
  ): bool {
    return C\count(
      Dict\filter_with_key($this->setCookies, ($k, $_) ==> ($k === $name))
    ) === 1;
  }

  <<__Rx>>
  public function get(
    string $name
  ): SetCookie {
    if ($this->has($name)) {
      return $this->setCookies[$name];
    }
    throw new InValidCookieException(Str\format("invalid cookie: %s", $name));
  }

  <<__Rx>>
  public function getAll(): vec<SetCookie> {
    return vec(array_values($this->setCookies));
  }

  public function with(
    SetCookie $setCookie
  ): SetCookies {
    $clone = clone($this);
    $clone->setCookies[$setCookie->getName()] = $setCookie;
    return $clone;
  }

  public function without(
    string $name
  ): SetCookies {
    $clone = clone($this);
    if (!$clone->has($name)) {
      return $clone;
    }
    $clone->setCookies = Dict\filter_with_key(
      $clone->setCookies,
      ($k, $_) ==> $k !== $name
    );
    return $clone;
  }

  public function renderIntoSetCookieHeader(
    ResponseInterface $response
  ): ResponseInterface {
    $response = $response->withoutHeader(static::SET_COOKIE_HEADER);
    foreach ($this->setCookies as $setCookie) {
      $response = $response->withAddedHeader(
        static::SET_COOKIE_HEADER,
        vec[$setCookie->toString()]
      );
    }
    return $response;
  }

  public static function fromSetCookieStrings(
    vec<string> $setCookieStrings
  ): SetCookies {
    return new SetCookies(
      Vec\map(
        $setCookieStrings,
        ($v) ==> SetCookie::fromSetCookieString($v)
      )
    );
  }

  public static function fromResponse(
    ResponseInterface $response
  ): SetCookies {
    return new SetCookies(
      Vec\map(
        $response->getHeader(static::SET_COOKIE_HEADER),
        ($v) ==> SetCookie::fromSetCookieString($v)
      )
    );
  }
}
