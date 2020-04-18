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
