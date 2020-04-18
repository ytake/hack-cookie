use type Facebook\HackTest\HackTest;
use type Ytake\Hungrr\Response;
use type Ytake\HackCookie\SetCookie;
use type Ytake\HackCookie\SetCookies;
use type Ytake\HackCookie\ResponseCookies;
use namespace HH\Lib\IO;
use namespace Facebook\Experimental\Http\Message;
use function Facebook\FBExpect\expect;

final class ResponseCookiesTest extends HackTest {

  public function testShouldGetCookies(): void {
    list($_, $w) = IO\pipe_nd();
    $response = new Response($w);
    $response = $response
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('theme', 'light')->toString()])
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('sessionToken', 'ENCRYPTED')->toString()])
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('hello', 'world')->toString()]);
    expect(ResponseCookies::get($response, 'sessionToken')->getValue())
      ->toBeSame('ENCRYPTED');
  }

  public function testShouldSetCookies(): void {
    list($_, $w) = IO\pipe_nd();
    $response = new Response($w);
    $response = $response
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('theme', 'light')->toString()])
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('sessionToken', 'ENCRYPTED')->toString()])
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('hello', 'world')->toString()]);
    $response = ResponseCookies::set($response, SetCookie::create('hello', 'WORLD!'));
    expect($response->getHeaderLine('Set-Cookie'))
      ->toBeSame('theme=light, sessionToken=ENCRYPTED, hello=WORLD%21');
  }

  public function testShouldRemoveCookies(): void {
    list($_, $w) = IO\pipe_nd();
    $response = new Response($w);
    $response = $response
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('theme', 'light')->toString()])
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('sessionToken', 'ENCRYPTED')->toString()])
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('hello', 'world')->toString()]);
    $response = ResponseCookies::remove($response, 'sessionToken');
    expect($response->getHeaderLine('Set-Cookie'))
      ->toBeSame('theme=light, hello=world');
  }

  public function testShouldModifiesCookies(): void {
    list($_, $w) = IO\pipe_nd();
    $response = new Response($w);
    $response = $response
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('theme', 'light')->toString()])
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('sessionToken', 'ENCRYPTED')->toString()])
      ->withAddedHeader(SetCookies::SET_COOKIE_HEADER, vec[SetCookie::create('hello', 'world')->toString()]); 
    $response = ResponseCookies::modify(
      $response,
      'hello',
      ($setCookie) ==> $setCookie->withValue(strtoupper($setCookie->getName()))
    );
    expect($response->getHeaderLine('Set-Cookie'))
      ->toBeSame('theme=light, sessionToken=ENCRYPTED, hello=HELLO',);
  }
}
