namespace Ytake\HackCookie\Modifier;

final class SameSite {

  public function __construct(
    private string $value
  ){}

  public function asString() : string {
    return 'SameSite=' . $this->value;
  }
}
