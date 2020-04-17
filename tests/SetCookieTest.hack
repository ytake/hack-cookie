use type Ytake\HackCookie\SetCookie;
use type Ytake\HackCookie\SameSite;
use type Facebook\HackTest\{DataProvider, HackTest};
use function time;
use function Facebook\FBExpect\expect;

final class SetCookieTest extends HackTest {
    
  public function provideParsesFromSetCookieStringData(    
  ): vec<shape('cookieString' => string, 'expectedSetCookie' => SetCookie)> {
    return vec[
      shape(
        'cookieString' => 'someCookie=',
        'expectedSetCookie' => SetCookie::create('someCookie'),
      ),
      shape(
        'cookieString' => 'LSID=DQAAAK%2FEaem_vYg; Path=/accounts; Expires=Wed, 13 Jan 2021 22:23:01 GMT; Secure; HttpOnly',
        'expectedSetCookie' => SetCookie::create('LSID')
          ->withValue('DQAAAK/Eaem_vYg')
          ->withPath('/accounts')
          ->withExpires('Wed, 13 Jan 2021 22:23:01 GMT')
          ->withSecure(true)
          ->withHttpOnly(true),
      ),
      shape(
        'cookieString' => 'HSID=AYQEVn%2F.DKrdst; Domain=.foo.com; Path=/; Expires=Wed, 13 Jan 2021 22:23:01 GMT; HttpOnly',
        'expectedSetCookie' => SetCookie::create('HSID')
          ->withValue('AYQEVn/.DKrdst')
          ->withDomain('.foo.com')
          ->withPath('/')
          ->withExpires('Wed, 13 Jan 2021 22:23:01 GMT')
          ->withHttpOnly(true),
      ),
      shape(
        'cookieString' => 'SSID=Ap4P%2F.GTEq; Domain=foo.com; Path=/; Expires=Wed, 13 Jan 2021 22:23:01 GMT; Secure; HttpOnly',
        'expectedSetCookie' => SetCookie::create('SSID')
          ->withValue('Ap4P/.GTEq')
          ->withDomain('foo.com')
          ->withPath('/')
          ->withExpires('Wed, 13 Jan 2021 22:23:01 GMT')
          ->withSecure(true)
          ->withHttpOnly(true),
      ),
      shape(
        'cookieString' => 'lu=Rg3vHJZnehYLjVg7qi3bZjzg; Domain=.example.com; Path=/; Expires=Tue, 15 Jan 2013 21:47:38 GMT; HttpOnly',
        'expectedSetCookie' => SetCookie::create('lu')
          ->withValue('Rg3vHJZnehYLjVg7qi3bZjzg')
          ->withExpires('Tue, 15-Jan-2013 21:47:38 GMT')
          ->withPath('/')
          ->withDomain('.example.com')
          ->withHttpOnly(true),
      ),
      shape(
        'cookieString' => 'lu=Rg3vHJZnehYLjVg7qi3bZjzg; Domain=.example.com; Path=/; Max-Age=500; Secure; HttpOnly',
        'expectedSetCookie' => SetCookie::create('lu')
          ->withValue('Rg3vHJZnehYLjVg7qi3bZjzg')
          ->withMaxAge(500)
          ->withPath('/')
          ->withDomain('.example.com')
          ->withSecure(true)
          ->withHttpOnly(true),
      ),
      shape(
        'cookieString' => 'lu=Rg3vHJZnehYLjVg7qi3bZjzg; Domain=.example.com; Path=/; Expires=Tue, 15 Jan 2013 21:47:38 GMT; Max-Age=500; Secure; HttpOnly',
        'expectedSetCookie' => SetCookie::create('lu')
          ->withValue('Rg3vHJZnehYLjVg7qi3bZjzg')
          ->withExpires('Tue, 15-Jan-2013 21:47:38 GMT')
          ->withMaxAge(500)
          ->withPath('/')
          ->withDomain('.example.com')
          ->withSecure(true)
          ->withHttpOnly(true),
      ),
      shape(
        'cookieString' => 'lu=Rg3vHJZnehYLjVg7qi3bZjzg; Domain=.example.com; Path=/; Expires=Tue, 15 Jan 2013 21:47:38 GMT; Max-Age=500; Secure; HttpOnly',
        'expectedSetCookie' => SetCookie::create('lu')
          ->withValue('Rg3vHJZnehYLjVg7qi3bZjzg')
          ->withExpires(1358286458)
          ->withMaxAge(500)
          ->withPath('/')
          ->withDomain('.example.com')
          ->withSecure(true)
          ->withHttpOnly(true),
      ),
      shape(
        'cookieString' => 'lu=Rg3vHJZnehYLjVg7qi3bZjzg; Domain=.example.com; Path=/; Expires=Tue, 15 Jan 2013 21:47:38 GMT; Max-Age=500; Secure; HttpOnly',
        'expectedSetCookie' => SetCookie::create('lu')
          ->withValue('Rg3vHJZnehYLjVg7qi3bZjzg')
          ->withExpires(new \DateTime('Tue, 15-Jan-2013 21:47:38 GMT'))
          ->withMaxAge(500)
          ->withPath('/')
          ->withDomain('.example.com')
          ->withSecure(true)
          ->withHttpOnly(true),
      ),
      shape(
        'cookieString' => 'lu=Rg3vHJZnehYLjVg7qi3bZjzg; Domain=.example.com; Path=/; Expires=Tue, 15 Jan 2013 21:47:38 GMT; Max-Age=500; Secure; HttpOnly; SameSite=Strict',
        'expectedSetCookie' => SetCookie::create('lu')
          ->withValue('Rg3vHJZnehYLjVg7qi3bZjzg')
          ->withExpires(new \DateTime('Tue, 15-Jan-2013 21:47:38 GMT'))
          ->withMaxAge(500)
          ->withPath('/')
          ->withDomain('.example.com')
          ->withSecure(true)
          ->withHttpOnly(true)
          ->withSameSite(SameSite::STRICT),
      ),
      shape(
        'cookieString' => 'lu=Rg3vHJZnehYLjVg7qi3bZjzg; Domain=.example.com; Path=/; Expires=Tue, 15 Jan 2013 21:47:38 GMT; Max-Age=500; Secure; HttpOnly; SameSite=Lax',
        'expectedSetCookie' => SetCookie::create('lu')
          ->withValue('Rg3vHJZnehYLjVg7qi3bZjzg')
          ->withExpires(new \DateTime('Tue, 15-Jan-2013 21:47:38 GMT'))
          ->withMaxAge(500)
          ->withPath('/')
          ->withDomain('.example.com')
          ->withSecure(true)
          ->withHttpOnly(true)
          ->withSameSite(SameSite::LAX),
      ),
    ];
  }

  <<DataProvider('provideParsesFromSetCookieStringData')>>
  public function testShouldParsesCookieString(
    string $cookieString,
    SetCookie $expectedSetCookie
  ): void {
    $setCookie = SetCookie::fromSetCookieString($cookieString);
    expect($cookieString)->toBeSame($setCookie->toString());
  }

  public function testExpiresCookies() : void {
    $setCookie = SetCookie::createExpired('expire_immediately');
    expect($setCookie->getExpires())->toBeLessThan(time());
  }

  public function testShouldCreatesLongCookies(): void {
    $setCookie = SetCookie::createRememberedForever('remember_forever');
    $fourYearsFromNow = (new \DateTime('+4 years'))->getTimestamp();
    expect($setCookie->getExpires())->toBeGreaterThan($fourYearsFromNow);
  }

  public function testShouldSameSiteModifier(): void {
    $setCookie = SetCookie::create('foo', 'bar');
    expect($setCookie->getSameSite())->toBeNull();
    expect($setCookie->toString())->toBeSame('foo=bar');

    $setCookie = $setCookie->withSameSite(SameSite::STRICT);
    expect($setCookie->getSameSite())->toBeSame(SameSite::STRICT);
    expect($setCookie->toString())->toBeSame('foo=bar; SameSite=Strict');

    $setCookie = $setCookie->withoutSameSite();
    expect($setCookie->getSameSite())->toBeNull();
    expect($setCookie->toString())->toBeSame('foo=bar');
  }

  public function testShouldInvalidExpiresFormatBeRejected(): void {
    $setCookie = SetCookie::create('foo', 'bar');
    expect(() ==> {
      $setCookie->withExpires('potato');
    })->toThrow(InvalidArgumentException::class, 'Invalid expires "potato" provided');
  }

  public function testEmptyCookieIsRejected(): void {
    expect(() ==> {
      SetCookie::fromSetCookieString('');
    })->toThrow(InvalidArgumentException::class, 'The provided cookie string "" must have at least one attribute');
  }  
}
