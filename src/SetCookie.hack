namespace Ytake\HackCookie;

use type DateTime;
use type DateTimeInterface;
use namespace HH\Lib\Str;
use function strtotime;

class SetCookie {

  private int $expires = 0;
  private int $maxAge = 0;
  private string $path = '/';
  private string $domain = '';
  private bool $secure = false;
  private bool $httpOnly = false;
  private ?SameSite $sameSite;

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

  public function withValue(
    string $value = ''
  ): this {
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
  ): this{
    $expires = $this->resolveExpires($expires);
    $clone = clone($this);
    $clone->expires = $expires;
    return $clone;
  }

  public function rememberForever(): this {
    return $this->withExpires(new DateTime('+5 years'));
  }

  public function expire(): this {
    return $this->withExpires(new DateTime('-5 years'));
  }

  public function withMaxAge(int $maxAge = 0): this {
    $clone = clone($this);
    $clone->maxAge = (int) $maxAge;
    return $clone;
  }

  public function withPath(string $path = ''): this {
    $clone = clone($this);
    $clone->path = $path;
    return $clone;
  }

  public function withDomain(string $domain = ''): this {
    $clone = clone($this);
    $clone->domain = $domain;
    return $clone;
  }

  public function withSecure(bool $secure = true): this {
    $clone = clone($this);
    $clone->secure = $secure;
    return $clone;
  }

  public function withHttpOnly(bool $httpOnly = true): this {
    $clone = clone($this);
    $clone->httpOnly = $httpOnly;
    return $clone;
  }

  public function withSameSite(SameSite $sameSite): this{
    $clone = clone($this);
    $clone->sameSite = $sameSite;
    return $clone;
  }

  public function withoutSameSite(): this {
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
}
