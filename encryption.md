# Cifrado

- [Introducción](#introduction)
- [Configuración](#configuration)
  - [Rotación de Claves de Encriptación de Manera Elegante](#gracefully-rotating-encryption-keys)
- [Usando el Encriptador](#using-the-encrypter)

<a name="introduction"></a>
## Introducción

Los servicios de cifrado de Laravel proporcionan una interfaz simple y conveniente para cifrar y descifrar texto a través de OpenSSL utilizando cifrado AES-256 y AES-128. Todos los valores cifrados de Laravel están firmados utilizando un código de autenticación de mensaje (MAC) para que su valor subyacente no pueda ser modificado o manipulado una vez cifrado.

<a name="configuration"></a>
## Configuración

Antes de usar el encriptador de Laravel, debes configurar la opción `key` en tu archivo de configuración `config/app.php`. Este valor de configuración está controlado por la variable de entorno `APP_KEY`. Debes usar el comando `php artisan key:generate` para generar el valor de esta variable, ya que el comando `key:generate` utilizará el generador de bytes aleatorios seguros de PHP para construir una clave criptográficamente segura para tu aplicación. Típicamente, el valor de la variable de entorno `APP_KEY` será generado por ti durante la [instalación de Laravel](/docs/%7B%7Bversion%7D%7D/installation).

<a name="gracefully-rotating-encryption-keys"></a>
### Rotación de Claves de Encriptación de Manera Elegante

Si cambias la clave de encriptación de tu aplicación, todas las sesiones de usuario autenticadas se cerrarán en tu aplicación. Esto se debe a que cada cookie, incluidas las cookies de sesión, son encriptadas por Laravel. Además, ya no será posible desencriptar cualquier dato que fue encriptado con tu clave de encriptación anterior.
Para mitigar este problema, Laravel te permite enumerar tus claves de encriptación anteriores en la variable de entorno `APP_PREVIOUS_KEYS` de tu aplicación. Esta variable puede contener una lista delimitada por comas de todas tus claves de encriptación anteriores:


```ini
APP_KEY="base64:J63qRTDLub5NuZvP+kb8YIorGS6qFYHKVo6u7179stY="
APP_PREVIOUS_KEYS="base64:2nLsGFGzyoae2ax3EF2Lyq/hH6QghBGLIq5uL+Gp8/w="

```
Cuando configuras esta variable de entorno, Laravel siempre utilizará la clave de encriptación "actual" al encriptar valores. Sin embargo, al desencriptar valores, Laravel primero intentará con la clave actual, y si la desencriptación falla utilizando la clave actual, Laravel intentará con todas las claves anteriores hasta que una de las claves pueda desencriptar el valor.
Este enfoque de desencriptación elegante permite a los usuarios seguir utilizando tu aplicación sin interrupciones, incluso si se rota tu clave de cifrado.

<a name="using-the-encrypter"></a>
## Usando el Encrypter


<a name="encrypting-a-value"></a>
#### Encriptando un Valor

Puedes cifrar un valor utilizando el método `encryptString` proporcionado por la fachada `Crypt`. Todos los valores cifrados se cifran utilizando OpenSSL y el cifrador AES-256-CBC. Además, todos los valores cifrados están firmados con un código de autenticación de mensaje (MAC). El código de autenticación de mensaje integrado evitará la descifrado de cualquier valor que haya sido manipulado por usuarios malintencionados:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Crypt;

class DigitalOceanTokenController extends Controller
{
    /**
     * Store a DigitalOcean API token for the user.
     */
    public function store(Request $request): RedirectResponse
    {
        $request->user()->fill([
            'token' => Crypt::encryptString($request->token),
        ])->save();

        return redirect('/secrets');
    }
}
```

<a name="decrypting-a-value"></a>
#### Desencriptando un Valor

Puedes descifrar valores utilizando el método `decryptString` proporcionado por la fachada `Crypt`. Si el valor no puede ser descifrado correctamente, como cuando el código de autenticación del mensaje es inválido, se lanzará una `Illuminate\Contracts\Encryption\DecryptException`:


```php
use Illuminate\Contracts\Encryption\DecryptException;
use Illuminate\Support\Facades\Crypt;

try {
    $decrypted = Crypt::decryptString($encryptedValue);
} catch (DecryptException $e) {
    // ...
}
```