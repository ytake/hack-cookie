# Hack Cookie

[![Build Status](https://travis-ci.org/ytake/hack-cookie.svg?branch=master)](https://travis-ci.org/ytake/hack-cookie)

Managing Cookies for [facebook/hack-http-request-response-interfaces](https://github.com/hhvm/hack-http-request-response-interfaces).

Supported Only Hack library.
Required HHVM >= 4.41.0

 - [ytake/hungrr](https://github.com/ytake/hungrr)
 - [usox/hackttp](https://github.com/usox/hackttp)

## Installation

```bash
$> composer require ytake/hack-cookie
```

## Basic Usage

### Request Cookies

```hack
use type Ytake\HackCookie\Cookie;

$cookie = Cookie::create('theme', 'blue');
```

#### Get a Request Cookie

```hack
use type Ytake\HackCookie\RequestCookies;
use type Ytake\Hungrr\{Request, Uri};
use namespace HH\Lib\IO;

$request = new Request(Message\HTTPMethod::GET, new Uri('/'), IO\request_input);

$cookie = RequestCookies::get($request, 'theme');
$cookie = RequestCookies::get($request, 'theme', 'default-theme');
```

#### Set a Request Cookie

```hack
use type Ytake\HackCookie\RequestCookies;
use type Ytake\Hungrr\{Request, Uri};
use namespace HH\Lib\IO;

$request = new Request(Message\HTTPMethod::GET, new Uri('/'), IO\request_input);

$request = RequestCookies::set($request, Cookie::create('theme', 'blue'));
```

#### Modify a Request Cookie

```hack
use type Ytake\HackCookie\{Cookie, Cookies, RequestCookies};
use type Ytake\Hungrr\{Request, Uri};
use namespace HH\Lib\IO;

$modify = (Cookie $cookie) ==> { 
  return $cookie->getValue()
    |> $cookie->withValue($$);
}
$request = new Request(Message\HTTPMethod::GET, new Uri('/'), IO\request_input);
$request = RequestCookies::modify($request, 'theme', $modify);
```

### Response Cookies

```hack
use type Ytake\HackCookie\{SameSite, SetCookie};

SetCookie::create('lu')
  ->withValue('Rg3vHJZnehYLjVg7qi3bZjzg')
  ->withExpires(new \DateTime('Tue, 15-Jan-2020 21:47:38 GMT'))
  ->withMaxAge(500)
  ->withPath('/')
  ->withDomain('.example.com')
  ->withSecure(true)
  ->withHttpOnly(true)
  ->withSameSite(SameSite::LAX);
```

and more.
