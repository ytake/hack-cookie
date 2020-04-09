use type Ytake\HackCookie\Cookie;
use type Facebook\HackTest\{DataProvider, HackTest};
use function Facebook\FBExpect\expect;
use function array_key_exists;

final class CookieTest extends HackTest {

  <<DataProvider('provideParseCookieStringData')>>
  public async function testShouldParseCookieData(
    string $cookieString,
    string $expectedName, 
    ?string $expectedValue
  ): Awaitable<void> {
    $cookie = Cookie::oneFromCookiePair($cookieString);
    $this->assertCookieNameAndValue($cookie, $expectedName, $expectedValue);
  }

  private function assertCookieNameAndValue(
    Cookie $cookie,
    string $expectedName,
    ?string $expectedValue
  ): void {
    expect($cookie->getName())->toBeSame($expectedName);
    expect($cookie->getValue())->toBeSame($expectedValue);
  }

  public function provideParseCookieStringData(): vec<vec<string>> {
    return vec[
      vec['someCookie=something', 'someCookie', 'something'],
      vec['hello%3Dworld=how%22are%27you', 'hello=world', 'how"are\'you'],
      vec['empty=', 'empty', ''],
    ];
  }

  <<DataProvider('provideParsesListCookieString')>>
  public async function testShouldParsesListCookies(
    string $cookieString,
    vec<vec<string>> $expectedNameValuePairs
  ): Awaitable<void> {
    $cookies = Cookie::listFromCookieString($cookieString);
    expect(count($cookies))->toBeSame(count($expectedNameValuePairs));
    for ($i = 0; $i < count($cookies); $i++) {
      if(array_key_exists($i, $cookies)) {
        $cookie  = $cookies[$i];
        list ($expectedName, $expectedValue) = $expectedNameValuePairs[$i];
        $this->assertCookieNameAndValue($cookie, $expectedName, $expectedValue);
      }
    }
  }

  public function provideParsesListCookieString(): vec<vec<mixed>> {
    return vec[
      vec[
        'theme=light; sessionToken=abc123',
        vec[
          vec['theme', 'light'],
          vec['sessionToken', 'abc123'],
        ],
      ],
      vec[
        'theme=light; sessionToken=abc123;',
        vec[
          vec['theme', 'light'],
          vec['sessionToken', 'abc123'],
        ],
      ],
    ];
  }
}
