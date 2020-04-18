use type Facebook\HackTest\HackTest;
use type Ytake\Hungrr\{Request, Uri};
use type Ytake\HackCookie\{Cookie, Cookies, RequestCookies};
use namespace HH\Lib\IO;
use namespace Facebook\Experimental\Http\Message;
use function Facebook\FBExpect\expect;

final class RequestCookiesTest extends HackTest {

  public function testShouldGetCookieValue(): void {
    list($read, $_) = IO\pipe_nd();
    $r = new Request(Message\HTTPMethod::GET, new Uri('/'), $read);
    $request = $r
      ->withHeader(Cookies::COOKIE_HEADER, vec['theme=light; sessionToken=RAPELCGRQ; hello=world']);
    expect(RequestCookies::get($request, 'sessionToken')->getValue())
      ->toBeSame('RAPELCGRQ');
  }

  public function testShouldSetCookie(): void {
    list($read, $_) = IO\pipe_nd();
    $r = new Request(Message\HTTPMethod::GET, new Uri('/'), $read);
    $request = $r
      ->withHeader(Cookies::COOKIE_HEADER, vec['theme=light; sessionToken=RAPELCGRQ; hello=world']);
    $request = RequestCookies::set($request, Cookie::create('hello', 'WORLD!'));
    expect($request->getHeaderLine('Cookie'))
      ->toBeSame('theme=light; sessionToken=RAPELCGRQ; hello=WORLD%21');
  }

  public function testShouldRemoveCookie(): void {
    list($read, $_) = IO\pipe_nd();
    $r = new Request(Message\HTTPMethod::GET, new Uri('/'), $read);
    $request = $r
      ->withHeader(Cookies::COOKIE_HEADER, vec['theme=light; sessionToken=RAPELCGRQ; hello=world']);
    $request = RequestCookies::remove($request, 'sessionToken');
    expect($request->getHeaderLine('Cookie'))->toBeSame('theme=light; hello=world');
  }

  public function testShouldModifiesCookie(): void {
    list($read, $_) = IO\pipe_nd();
    $r = new Request(Message\HTTPMethod::GET, new Uri('/'), $read);
    $request = $r
      ->withHeader(Cookies::COOKIE_HEADER, vec['theme=light; sessionToken=RAPELCGRQ; hello=world']);
    $request = RequestCookies::modify(
      $request,
      'hello',
      (Cookie $cookie) ==> $cookie->withValue(strtoupper($cookie->getName()))
    );
    expect($request->getHeaderLine('Cookie'))
      ->toBeSame('theme=light; sessionToken=RAPELCGRQ; hello=HELLO');
    }
}
