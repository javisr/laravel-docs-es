# Cifrado

- [Introducción](#introduction)
- [Configuración](#configuration)
- [Uso del encriptador](#using-the-encrypter)

<a name="introduction"></a>
## Introducción

Los servicios de cifrado de Laravel proporcionan una interfaz sencilla y cómoda para cifrar y descifrar texto a través de OpenSSL utilizando cifrado AES-256 y AES-128. Todos los valores cifrados de Laravel se firman utilizando un código de autenticación de mensajes (MAC) para que su valor subyacente no pueda ser modificado o manipulado una vez cifrado.

<a name="configuration"></a>
## Configuración

Antes de utilizar el encriptador de Laravel, debes establecer la opción de configuración de `key` en tu fichero de configuración `config/app.php`. Este valor de configuración es controlado por la variable de entorno `APP_KEY`. Debes usar el comando `php artisan key:generate` para generar el valor de esta variable. Este comando usará el generador seguro de bytes aleatorios de PHP para construir una clave criptográficamente segura para tu aplicación. Típicamente, el valor de la variable de entorno `APP_KEY` será generado por ti durante [la instalación de Laravel](/docs/{{version}}/installation).

<a name="using-the-encrypter"></a>
## Uso del cifrador

<a name="encrypting-a-value"></a>
#### Cifrar un valor

Puedes encriptar un valor utilizando el método `encryptString` proporcionado por la facade `Crypt`. Todos los valores cifrados se cifran utilizando OpenSSL y el cifrado AES-256-CBC. Además, todos los valores cifrados se firman con un código de autenticación de mensajes (MAC). El código de autenticación de mensajes integrado impedirá el descifrado de cualquier valor que haya sido manipulado por usuarios malintencionados:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\User;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Crypt;

    class DigitalOceanTokenController extends Controller
    {
        /**
         * Store a DigitalOcean API token for the user.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function storeSecret(Request $request)
        {
            $request->user()->fill([
                'token' => Crypt::encryptString($request->token),
            ])->save();
        }
    }

<a name="decrypting-a-value"></a>
#### Descifrar un valor

Puedes descifrar los valores utilizando el método `decryptString` proporcionado por la facade `Crypt`. Si el valor no puede ser descifrado correctamente, como cuando el código de autenticación del mensaje no es válido, se lanzará una `Illuminate\Contracts\Encryption\DecryptException`:

    use Illuminate\Contracts\Encryption\DecryptException;
    use Illuminate\Support\Facades\Crypt;

    try {
        $decrypted = Crypt::decryptString($encryptedValue);
    } catch (DecryptException $e) {
        //
    }
