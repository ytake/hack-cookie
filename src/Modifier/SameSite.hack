namespace Ytake\HackCookie\Modifier;

final class SameSite {

  private function __construct(
    private string $value
  ){}

  public function asString() : string {
    return 'SameSite=' . $this->value;
  }
}
