# Cifrado

- [Introducción](#introduction)
- [Configuración](#configuration)
    - [Rotación de Claves de Cifrado de Manera Elegante](#gracefully-rotating-encryption-keys)
- [Uso del Encriptador](#using-the-encrypter)

<a name="introduction"></a>
## Introducción

Los servicios de cifrado de Laravel proporcionan una interfaz simple y conveniente para cifrar y descifrar texto a través de OpenSSL utilizando cifrado AES-256 y AES-128. Todos los valores cifrados de Laravel están firmados utilizando un código de autenticación de mensaje (MAC) para que su valor subyacente no pueda ser modificado o manipulado una vez cifrado.

<a name="configuration"></a>
## Configuración

Antes de usar el encriptador de Laravel, debes establecer la opción de configuración `key` en tu archivo de configuración `config/app.php`. Este valor de configuración se basa en la variable de entorno `APP_KEY`. Debes usar el comando `php artisan key:generate` para generar el valor de esta variable, ya que el comando `key:generate` utilizará el generador de bytes aleatorios seguro de PHP para construir una clave criptográficamente segura para tu aplicación. Típicamente, el valor de la variable de entorno `APP_KEY` será generado para ti durante [la instalación de Laravel](/docs/{{version}}/installation).

<a name="gracefully-rotating-encryption-keys"></a>
### Rotación de Claves de Cifrado de Manera Elegante

Si cambias la clave de cifrado de tu aplicación, todas las sesiones de usuario autenticadas serán desconectadas de tu aplicación. Esto se debe a que cada cookie, incluidas las cookies de sesión, están cifradas por Laravel. Además, ya no será posible descifrar ningún dato que haya sido cifrado con tu clave de cifrado anterior.

Para mitigar este problema, Laravel te permite listar tus claves de cifrado anteriores en la variable de entorno `APP_PREVIOUS_KEYS` de tu aplicación. Esta variable puede contener una lista delimitada por comas de todas tus claves de cifrado anteriores:

```ini
APP_KEY="base64:J63qRTDLub5NuZvP+kb8YIorGS6qFYHKVo6u7179stY="
APP_PREVIOUS_KEYS="base64:2nLsGFGzyoae2ax3EF2Lyq/hH6QghBGLIq5uL+Gp8/w="
```

Cuando estableces esta variable de entorno, Laravel siempre utilizará la clave de cifrado "actual" al cifrar valores. Sin embargo, al descifrar valores, Laravel primero intentará con la clave actual, y si el descifrado falla utilizando la clave actual, Laravel intentará todas las claves anteriores hasta que una de las claves pueda descifrar el valor.

Este enfoque para el descifrado elegante permite a los usuarios seguir utilizando tu aplicación sin interrupciones, incluso si tu clave de cifrado es rotada.

<a name="using-the-encrypter"></a>
## Uso del Encriptador

<a name="encrypting-a-value"></a>
#### Cifrando un Valor

Puedes cifrar un valor utilizando el método `encryptString` proporcionado por el facade `Crypt`. Todos los valores cifrados se cifran utilizando OpenSSL y el cifrado AES-256-CBC. Además, todos los valores cifrados están firmados con un código de autenticación de mensaje (MAC). El código de autenticación de mensaje integrado evitará el descifrado de cualquier valor que haya sido manipulado por usuarios maliciosos:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Crypt;

    class DigitalOceanTokenController extends Controller
    {
        /**
         * Almacenar un token de API de DigitalOcean para el usuario.
         */
        public function store(Request $request): RedirectResponse
        {
            $request->user()->fill([
                'token' => Crypt::encryptString($request->token),
            ])->save();

            return redirect('/secrets');
        }
    }

<a name="decrypting-a-value"></a>
#### Descifrando un Valor

Puedes descifrar valores utilizando el método `decryptString` proporcionado por el facade `Crypt`. Si el valor no puede ser descifrado correctamente, como cuando el código de autenticación de mensaje es inválido, se lanzará una `Illuminate\Contracts\Encryption\DecryptException`:

    use Illuminate\Contracts\Encryption\DecryptException;
    use Illuminate\Support\Facades\Crypt;

    try {
        $decrypted = Crypt::decryptString($encryptedValue);
    } catch (DecryptException $e) {
        // ...
    }
