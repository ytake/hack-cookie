namespace Ytake\HackCookie;

use namespace HH\Lib\{Regex, Str, Vec, Dict};
use function strtotime;
use function time;
use function urldecode;
use function urlencode;
use function gmdate;
use function rawurlencode;
use function array_key_exists;
use function strval;

<<__ConsistentConstruct>>
class Cookie {
  protected string $name = '';
  protected int $expire;
  private bool $secureDefault = false;

  public function __construct(
    string $name,
    protected string $value = '',
    mixed $expire = 0, 
    protected string $path = '/',
    protected ?string $domain = null,
    protected ?bool $secure = null,
    protected bool $httpOnly = true,
    private bool $raw = false,
    private SameSite $sameSite = SameSite::LAX
  ) {
    if (Regex\matches($name, re"/[=,; \t\r\n\013\014]/")) {
      throw new \InvalidArgumentException(
        Str\format('The cookie name "%s" contains invalid characters.', $name)
      );
    }
    if (Str\is_empty($name)) {
      throw new \InvalidArgumentException('The cookie name cannot be empty.');
    }
    if ($expire is \DateTimeInterface) {
      $expire = $expire->format('U');
    } elseif ($expire is string) {
      $expire = strtotime($expire);
      if (false === $expire) {
        throw new \InvalidArgumentException('The cookie expiration time is not valid.');
      }
    }
    $this->name = $name;
    $expire as int;
    $this->expire = 0 < $expire ? (int) $expire : 0;
    $this->path = Str\is_empty($path) ? '/' : $path;
  }

  public static function create(
    string $name,
    string $value = '',
    mixed $expire = 0, 
    string $path = '/',
    ?string $domain = null,
    ?bool $secure = null,
    bool $httpOnly = true,
    bool $raw = false,
    SameSite $sameSite = SameSite::LAX
  ): this {
    return new static($name, $value, $expire, $path, $domain, $secure, $httpOnly, $raw, $sameSite);
  }

  private function createExpires(): string {
    if ('' === $this->getValue()) {
      return 'deleted; expires='.gmdate('D, d-M-Y H:i:s T', time() - 31536001).'; Max-Age=0';
    }
    $str = $this->isRaw() ? $this->getValue() : rawurlencode($this->getValue());
    if (0 !== $this->getExpiresTime()) {
      $str .= '; expires='.gmdate('D, d-M-Y H:i:s T', $this->getExpiresTime()).'; Max-Age='.$this->getMaxAge();
    }
    return $str;
  }

  public function toString(): string {
    $str = ($this->isRaw() ? $this->getName() : urlencode($this->getName())).'=';
    $str .= $this->createExpires();
    if ($this->getPath()) {
      $str .= '; path='.$this->getPath();
    }
    if ($this->getDomain()) {
      $str .= '; domain='.$this->getDomain();
    }
    if (true === $this->isSecure()) {
      $str .= '; secure';
    }
    if (true === $this->isHttpOnly()) {
      $str .= '; httponly';
    }
    if (null !== $this->getSameSite()) {
      $str .= '; samesite='.$this->getSameSite();
    }
    return $str;
  }

  public static function fromString(
    string $cookie,
    bool $decode = false
  ): this{
    $data = shape(
      'expires' => 0,
      'path' => '/',
      'domain' => null,
      'secure' => false,
      'httponly' => false,
      'raw' => !$decode,
      'samesite' => SameSite::NULL,
    );
    $parts = Header::split($cookie, ';=');
    $part = Vec\drop($parts, 1);
    $name = $decode ? urldecode(strval($part[0])) : strval($part[0]);
    $value = '';
    if (array_key_exists(1, $part)) {
      $value = ($decode ? urldecode(strval($part[1])) : strval($part[1]));
    }
    /* HH_FIXME[4110] */
    $data = Dict\merge(Header::combine($parts), Shapes::toDict($data));
    if (array_key_exists('max-age', $data)) {
      $data['expires'] = time() + (int) $data['max-age'];
    }
    $data as CookieData;
    return new static(
      $name,
      $value,
      $data['expires'],
      $data['path'],
      $data['domain'],
      $data['secure'],
      $data['httponly'],
      $data['raw'],
      $data['samesite']
    );
  }

  public function setSecureDefault(bool $default): void {
    $this->secureDefault = $default;
  }

  public function getName(): string {
    return $this->name;
  }

  public function getValue(): string {
    return $this->value;
  }

  public function getDomain(): ?string {
    return $this->domain;
  }

  public function getExpiresTime(): int {
    return $this->expire;
  }

  public function getMaxAge(): int {
    $maxAge = $this->expire - time();
    return 0 >= $maxAge ? 0 : $maxAge;
  }

  public function getPath(): string {
    return $this->path;
  }

  public function isSecure(): bool {
    return $this->secure ?? $this->secureDefault;
  }

  public function isHttpOnly(): bool {
    return $this->httpOnly;
  }

  public function isCleared(): bool {
    return 0 !== $this->expire && $this->expire < time();
  }

  public function isRaw(): bool {
    return $this->raw;
  }

  public function getSameSite(): SameSite {
    return $this->sameSite;
  }
}
