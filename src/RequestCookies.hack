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

  public static function modify(
    RequestInterface $request,
    string $name,
    (function(Cookie): Cookie) $modify
  ): RequestInterface {

    $cookies = Cookies::fromRequest($request);
    $funcCookie = Cookie::create($name);
    if ($cookies->has($name)) {
      $funcCookie = $cookies->get($name);
    }
    $cookie  = $modify($funcCookie);
    return $cookies
      ->with($cookie)
      ->renderIntoCookieHeader($request);
    }
}
