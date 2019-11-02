namespace Ytake\HackCookie;

enum SameSite: string as string {
	LAX = 'lax';
	NONE = 'none';
	STRICT = 'strict';
	NULL = '';
}

type CookieData = shape(
  'expires' => int,
  'path' => string,
  'domain' => ?string,
  'secure' => bool,
  'httponly' => bool,
  'raw' => bool,
  'samesite' => SameSite,
);
