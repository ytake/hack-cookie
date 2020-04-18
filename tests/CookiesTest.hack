use type Ytake\HackCookie\Cookie;
use type Ytake\HackCookie\Cookies;
use type Facebook\HackTest\{DataProvider, HackTest};
use function Facebook\FBExpect\expect;
use function array_key_exists;

final class CookiesTest extends HackTest {

  public async function testShouldOverridesAndRemovesCookie(): Awaitable<void> {
    $cookies = new Cookies();
    $cookies = $cookies->with(Cookie::create('theme', 'blue'));
    expect($cookies->get('theme')->getValue())
      ->toBeSame('blue');

    $cookies = $cookies->with(Cookie::create('theme', 'red'));
    expect($cookies->get('theme')->getValue())
      ->toBeSame('red');
    $cookies = $cookies->without('theme');
    expect($cookies->has('theme'))->toBeFalse();
  }

  public function provideCookieStringAndExpectedCookiesData(): vec<vec<mixed>> {
    return vec[
      vec[
        '',
        vec[],
      ],
      vec[
        'theme=light',
        vec[
          Cookie::create('theme', 'light'),
        ],
      ],
      vec[
        'theme=light; sessionToken=abc123',
        vec[
          Cookie::create('theme', 'light'),
          Cookie::create('sessionToken', 'abc123'),
        ],
      ],
    ];
  }

  <<DataProvider('provideCookieStringAndExpectedCookiesData')>>
  public function testShouldCreateFromCookie(
    string $cookieString, vec<mixed> $expectedCookies
  ) : void {
    $cookies = Cookies::fromCookieString($cookieString);
    expect($cookies->getAll())->toBePHPEqual($expectedCookies);
  }

  <<DataProvider('provideCookieStringAndExpectedCookiesData')>>
  public function testShouldCookiesAreAvailable(
    string $cookieString, vec<mixed> $expectedCookies
  ) : void {
    $cookies = Cookies::fromCookieString($cookieString);
    foreach ($expectedCookies as $expectedCookie) {
      $expectedCookie as Cookie;
      expect($cookies->has($expectedCookie->getName()))->toBeTrue();
    }
    expect($cookies->has('i know this cookie does not exist'))->toBeFalse();
  }

  public function provideGetsCookieByNameData()
    :vec<shape('cookieString' => string, 'cookieName' => string, 'expectedCookie' => Cookie)> {
    return vec[
      shape('cookieString' => 'theme=light', 'cookieName' => 'theme', 'expectedCookie' => Cookie::create('theme', 'light')),
      shape('cookieString' => 'theme=', 'cookieName' => 'theme', 'expectedCookie' => Cookie::create('theme')),
      shape('cookieString' => 'hello=world; theme=light; sessionToken=abc123', 'cookieName' => 'theme', 'expectedCookie' => Cookie::create('theme', 'light')),
      shape('cookieString' => 'hello=world; theme=; sessionToken=abc123', 'cookieName' => 'theme', 'expectedCookie' => Cookie::create('theme')),
    ];
  }

  <<DataProvider('provideGetsCookieByNameData')>>
  public async function testShouldGetExpectedCookie(
    string $cookieString, string $cookieName, Cookie $expectedCookie
  ): Awaitable<void> {
    $cookies = Cookies::fromCookieString($cookieString);
    expect($cookies->get($cookieName)->getName())->toBeSame($expectedCookie->getName());
    expect($cookies->get($cookieName)->getValue())->toBeSame($expectedCookie->getValue());
  }
}
