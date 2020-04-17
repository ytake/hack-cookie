namespace Ytake\HackCookie;

use type DateTime;
use type DateTimeInterface;
use type Ytake\HackCookie\SameSite as SameSiteEnum;
use type Ytake\HackCookie\Modifier\SameSite;
use namespace HH\Lib\{C, Str, Vec};
use function strtotime;
use function gmdate;
use function urlencode;

class SetCookie {

  private int $expires = 0;
  private int $maxAge = 0;
  private string $path = '';
  private string $domain = '';
  private bool $secure = false;
  private bool $httpOnly = false;
  private ?SameSiteEnum $sameSite;

  private function __construct(
    private string $name, 
    private string $value = ''
  ) {}

  public static function create(
    string $name, 
    string $value = ''
  ): SetCookie {
    return new SetCookie($name, $value);
  }

  public function getName(): string {
    return $this->name;
  }

  public function getValue(): string {
    return $this->value;
  }

  public function getExpires(): int {
    return $this->expires;
  }

  public function getMaxAge(): int {
    return $this->maxAge;
  }

  public function getSameSite(): ?SameSiteEnum {
    return $this->sameSite;
  }

  public function withValue(
    string $value = ''
  ): SetCookie {
    $clone = clone($this);
    $clone->value = $value;
    return $clone;
  }

  private function resolveExpires(mixed $expires = null): int {
    if ($expires === null) {
      return 0;
    }
    if ($expires is DateTimeInterface) {
      return $expires->getTimestamp();
    }

    if ($expires is int) {
      return $expires;
    }
    if ($expires is string) {
      $time = strtotime($expires);
      if (!$time is int) {
        throw new \InvalidArgumentException(
          Str\format('Invalid expires "%s" provided', $expires)
        );
      }
      return $time;
    }
    throw new \InvalidArgumentException(
      Str\format('Invalid expires')
    );
  }

  public function withExpires(
    mixed $expires = null
  ): SetCookie {
    $expires = $this->resolveExpires($expires);
    $clone = clone($this);
    $clone->expires = $expires;
    return $clone;
  }

  public function rememberForever(): SetCookie {
    return $this->withExpires(new DateTime('+5 years'));
  }

  public function expire(): SetCookie {
    return $this->withExpires(new DateTime('-5 years'));
  }

  public function withMaxAge(int $maxAge = 0): SetCookie {
    $clone = clone($this);
    $clone->maxAge = (int) $maxAge;
    return $clone;
  }

  public function withPath(string $path = ''): SetCookie {
    $clone = clone($this);
    $clone->path = $path;
    return $clone;
  }

  public function withDomain(string $domain = ''): SetCookie {
    $clone = clone($this);
    $clone->domain = $domain;
    return $clone;
  }

  public function withSecure(bool $secure = true): SetCookie {
    $clone = clone($this);
    $clone->secure = $secure;
    return $clone;
  }

  public function withHttpOnly(bool $httpOnly = true): SetCookie {
    $clone = clone($this);
    $clone->httpOnly = $httpOnly;
    return $clone;
  }

  public function withSameSite(
    SameSiteEnum $sameSite
  ): SetCookie {
    $clone = clone($this);
    $clone->sameSite = $sameSite;
    return $clone;
  }

  public function withoutSameSite(): SetCookie {
    $clone = clone($this);
    $clone->sameSite = null;
    return $clone;
  }

  public static function createRememberedForever(
    string $name, 
    string $value = ''
  ): SetCookie {
    return static::create($name, $value)->rememberForever();
  }

  public static function createExpired(
    string $name
  ) : SetCookie{
    return static::create($name)->expire();
  }

  public static function fromSetCookieString(string $string): SetCookie {
    $rawAttributes = StringUtil::splitOnAttributeDelimiter($string);
    $v = Vec\take($rawAttributes, 1);
    $rawAttribute = $v[0];
    $rawAttributes = Vec\drop($rawAttributes, 1);
    if (!$rawAttribute is string) {
      throw new \InvalidArgumentException(Str\format(
        'The provided cookie string "%s" must have at least one attribute',
        $string
      ));
    }
    list ($cookieName, $cookieValue) = StringUtil::splitCookiePair($rawAttribute);
    $setCookie = new SetCookie($cookieName);
    if (!$cookieValue is null) {
      $setCookie = $setCookie->withValue($cookieValue);
    }
    for($i = 0; $i < C\count($rawAttributes); $i++) {
      $rawAttributePair = Str\split($rawAttributes[$i], '=', 2);
      $attributeKey   = $rawAttributePair[0];
      $attributeValue = C\count($rawAttributePair) > 1 ? $rawAttributePair[1] : '';
      $attributeKey = Str\lowercase($attributeKey);
      switch ($attributeKey) {
        case 'expires':
          $setCookie = $setCookie->withExpires($attributeValue);
          break;
        case 'max-age':
          $setCookie = $setCookie->withMaxAge((int) $attributeValue);
          break;
        case 'domain':
          $setCookie = $setCookie->withDomain($attributeValue);
          break;
        case 'path':
          $setCookie = $setCookie->withPath($attributeValue);
          break;
        case 'secure':
          $setCookie = $setCookie->withSecure(true);
          break;
        case 'httponly':
          $setCookie = $setCookie->withHttpOnly(true);
          break;
        case 'samesite':
          $setCookie = $setCookie->withSameSite(
            SameSiteEnum::assert((string) $attributeValue)
          );
          break;
      }
    }
    return $setCookie;
  }

  private function appendFormattedDomainPartIfSet(
    vec<string> $cookieStringParts
  ) : vec<string> {
    if ($this->domain) {
      $cookieStringParts[] = Str\format('Domain=%s', $this->domain);
    }
    return $cookieStringParts;
  }

  private function appendFormattedPathPartIfSet(
    vec<string> $cookieStringParts
  ): vec<string> {
    if ($this->path) {
      $cookieStringParts[] = Str\format('Path=%s', $this->path);
    }
    return $cookieStringParts;
  }

  private function appendFormattedExpiresPartIfSet(
    vec<string> $cookieStringParts
  ): vec<string> {
    if ($this->expires) {
      $cookieStringParts[] = Str\format('Expires=%s', gmdate('D, d M Y H:i:s T', $this->expires));
    }
    return $cookieStringParts;
  }

  private function appendFormattedMaxAgePartIfSet(
    vec<string> $cookieStringParts
  ): vec<string> {
    if ($this->maxAge) {
      $cookieStringParts[] = Str\format('Max-Age=%d', $this->maxAge);
    }
    return $cookieStringParts;
  }

  private function appendFormattedSecurePartIfSet(
    vec<string> $cookieStringParts
  ): vec<string> {
    if ($this->secure) {
      $cookieStringParts[] = 'Secure';
    }
    return $cookieStringParts;
  }

  private function appendFormattedHttpOnlyPartIfSet(
    vec<string> $cookieStringParts
  ): vec<string> {
    if ($this->httpOnly) {
      $cookieStringParts[] = 'HttpOnly';
    }
    return $cookieStringParts;
  }

  private function appendFormattedSameSitePartIfSet(
    vec<string> $cookieStringParts
  ): vec<string> {
    if ($this->sameSite === null) {
      return $cookieStringParts;
    }
    $ss = new SameSite(SameSiteEnum::assert($this->sameSite));
    $cookieStringParts[] = $ss->asString();
    return $cookieStringParts;
  }

  public function toString(): string {
    $cookieStringParts = vec[
      urlencode($this->name) . '=' . urlencode($this->value),
    ];
    $cookieStringParts = $this->appendFormattedDomainPartIfSet($cookieStringParts);
    $cookieStringParts = $this->appendFormattedPathPartIfSet($cookieStringParts);
    $cookieStringParts = $this->appendFormattedExpiresPartIfSet($cookieStringParts);
    $cookieStringParts = $this->appendFormattedMaxAgePartIfSet($cookieStringParts);
    $cookieStringParts = $this->appendFormattedSecurePartIfSet($cookieStringParts);
    $cookieStringParts = $this->appendFormattedHttpOnlyPartIfSet($cookieStringParts);
    $cookieStringParts = $this->appendFormattedSameSitePartIfSet($cookieStringParts);
    return Str\join($cookieStringParts, '; ');
  }
}
