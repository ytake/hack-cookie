namespace Ytake\HackCookie;

use type InvalidArgumentException;
use type Facebook\Experimental\Http\Message\RequestInterface;

class RequestCookies {

  public static function get(
    RequestInterface $request,
    string $name,
    string $value = ''
  ) : Cookie {
    $cookies = Cookies::fromRequest($request);
    $cookie  = $cookies->get($name);
    if ($cookie) {
      return $cookie;
    }
    return Cookie::create($name, $value);
  }

  public static function set(
    RequestInterface $request,
    Cookie $cookie
  ): RequestInterface {
    return Cookies::fromRequest($request)
      ->with($cookie)
      ->renderIntoCookieHeader($request);
  }

  public static function remove(
    RequestInterface $request,
    string $name
  ): RequestInterface {
    return Cookies::fromRequest($request)
      ->without($name)
      ->renderIntoCookieHeader($request);
  }
}
