namespace Ytake\HackCookie;

use type Facebook\Experimental\Http\Message\ResponseInterface;

class ResponseCookies {

  public static function get(
    ResponseInterface $response,
    string $name,
    string $value = ''
  ): SetCookie {
    $setCookies = SetCookies::fromResponse($response);
    $cookie = $setCookies->get($name);
    if ($cookie) {
      return $cookie;
    }
    return SetCookie::create($name, $value);
  }

  public static function set(
    ResponseInterface $response,
    SetCookie $setCookie
  ): ResponseInterface {
    return SetCookies::fromResponse($response)
      ->with($setCookie)
      ->renderIntoSetCookieHeader($response);
    }

  public static function expire(
    ResponseInterface $response,
    string $cookieName
  ): ResponseInterface {
    return static::set($response, SetCookie::createExpired($cookieName));
  }

  public static function remove(
    ResponseInterface $response,
    string $name
  ): ResponseInterface {
    return SetCookies::fromResponse($response)
      ->without($name)
      ->renderIntoSetCookieHeader($response);
  }

  public static function modify(
    ResponseInterface $response,
    string $name,
    (function(SetCookie): SetCookie) $modify
  ): ResponseInterface {
    $setCookies = SetCookies::fromResponse($response);
    $funcCookie = SetCookie::create($name);
    if ($setCookies->has($name)) {
      $funcCookie = $setCookies->get($name);
    }
    $setCookie = $modify($funcCookie);
    return $setCookies
      ->with($setCookie)
      ->renderIntoSetCookieHeader($response);
    }
}
