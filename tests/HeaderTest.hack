use type Ytake\HackCookie\Header;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class HeaderTest extends HackTest {

  public async function testShouldBeExpectedDictCombine(): Awaitable<void> {
    expect(dict['foo' => '123'])
      ->toBeSame(Header::combine(vec[vec['foo', '123']]));
    expect(dict['foo' => true])
      ->toBeSame(Header::combine(vec[vec['foo']]));
    expect(dict['foo' => true])
      ->toBeSame(Header::combine(vec[vec['Foo']]));
    expect(dict['foo' => '123', 'bar' => true])
      ->toBeSame(Header::combine(vec[vec['foo', '123'], vec['bar']]));
  }

  public async function testUnquote(): Awaitable<void> {
    expect('foo')->toEqual(Header::unquote('foo'));
    expect('az09!#$%&\'*.^_`|~-')->toEqual(Header::unquote('az09!#$%&\'*.^_`|~-'));
    expect('foo bar')->toEqual(Header::unquote('"foo bar"'));
    expect('foo [bar]')->toEqual(Header::unquote('"foo [bar]"'));
    expect('foo "bar"')->toEqual(Header::unquote('"foo \"bar\""'));
    expect('foo "bar"')->toEqual(Header::unquote('"foo \"\b\a\r\""'));
    expect('foo \\ bar')->toEqual(Header::unquote('"foo \\\\ bar"'));
  }

  public async function testSplit(): Awaitable<void> {
    expect(vec['foo=123', 'bar'])->toBeSame(Header::split('foo=123,bar', ','));
    expect(vec['foo=123', 'bar'])->toBeSame(Header::split('foo=123, bar', ','));
    expect(vec[vec['foo=123', 'bar']])->toBeSame(Header::split('foo=123; bar', ',;'));
    expect(vec[vec['foo=123'], vec['bar']])->toBeSame(Header::split('foo=123, bar', ',;'));
    expect(vec['foo', '123, bar'])->toBeSame(Header::split('foo=123, bar', '='));
    expect(vec['foo', '123, bar'])->toBeSame(Header::split(' foo = 123, bar ', '='));
    expect(vec[vec['foo', '123'], vec['bar']])->toBeSame(Header::split('foo=123, bar', ',='));
    expect(vec[vec[vec['foo', '123']], vec[vec['bar'], vec['foo', '456']]])->toBeSame(Header::split('foo=123, bar; foo=456', ',;='));
    expect(vec[vec[vec['foo', 'a,b;c=d']]])->toBeSame(Header::split('foo="a,b;c=d"', ',;='));

    expect(vec['foo', 'bar'])->toBeSame(Header::split('foo,,,, bar', ','));
    expect(vec['foo', 'bar'])->toBeSame(Header::split(',foo, bar,', ','));
    expect(vec['foo', 'bar'])->toBeSame(Header::split(' , foo, bar, ', ','));
    expect(vec['foo bar'])->toBeSame(Header::split('foo "bar"', ','));
    expect(vec['foo bar'])->toBeSame(Header::split('"foo" bar', ','));
    expect(vec['foo bar'])->toBeSame(Header::split('"foo" "bar"', ','));

    expect(vec[])->toBeSame(Header::split('', ','));
    expect(vec[])->toBeSame(Header::split(',,,', ','));
    expect(vec['foo', 'bar', 'baz'])->toBeSame(Header::split('foo, "bar", "baz', ','));
    expect(vec['foo', 'bar, baz'])->toBeSame(Header::split('foo, "bar, baz', ','));
    expect(vec['foo', 'bar, baz\\'])->toBeSame(Header::split('foo, "bar, baz\\', ','));
    expect(vec['foo', 'bar, baz\\'])->toBeSame(Header::split('foo, "bar, baz\\\\', ','));
  }
}
