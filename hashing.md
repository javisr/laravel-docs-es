# Hashing

- [Introducción](#introduction)
- [Configuración](#configuration)
- [Uso Básico](#basic-usage)
  - [Hashing de Contraseñas](#hashing-passwords)
  - [Verificando Que una Contraseña Coincida con un Hash](#verifying-that-a-password-matches-a-hash)
  - [Determinando si una Contraseña Necesita ser Rehashed](#determining-if-a-password-needs-to-be-rehashed)
- [Verificación del Algoritmo de Hash](#hash-algorithm-verification)

<a name="introduction"></a>
## Introducción

La `Hash` [facade](/docs/%7B%7Bversion%7D%7D/facades) de Laravel proporciona hashing seguro Bcrypt y Argon2 para almacenar contraseñas de usuario. Si estás utilizando uno de los [kits de inicio de aplicación de Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits), se usará Bcrypt para el registro y la autenticación de manera predeterminada.
Bcrypt es una excelente opción para hashear contraseñas porque su "factor de trabajo" es ajustable, lo que significa que el tiempo que se tarda en generar un hash se puede aumentar a medida que aumenta la potencia del hardware. Al hashear contraseñas, lento es bueno. Cuanto más tiempo tarde un algoritmo en hashear una contraseña, más tiempo tardan los usuarios malintencionados en generar "tablas arcoíris" de todos los posibles valores de hash de cadena que pueden usarse en ataques de fuerza bruta contra aplicaciones.

<a name="configuration"></a>
## Configuración

Por defecto, Laravel utiliza el driver de hash `bcrypt` al hash de datos. Sin embargo, se admiten varios otros drivers de hash, incluyendo [`argon`](https://es.wikipedia.org/wiki/Argon2) y [`argon2id`](https://es.wikipedia.org/wiki/Argon2).
Puedes especificar el driver de hashing de tu aplicación utilizando la variable de entorno `HASH_DRIVER`. Pero, si deseas personalizar todas las opciones del driver de hashing de Laravel, debes publicar el archivo de configuración `hashing` completo usando el comando Artisan `config:publish`:


```bash
php artisan config:publish hashing

```

<a name="basic-usage"></a>
## Uso Básico


<a name="hashing-passwords"></a>
### Hashing de Contraseñas

Puedes hash una contraseña llamando al método `make` en la fachada `Hash`:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class PasswordController extends Controller
{
    /**
     * Update the password for the user.
     */
    public function update(Request $request): RedirectResponse
    {
        // Validate the new password length...

        $request->user()->fill([
            'password' => Hash::make($request->newPassword)
        ])->save();

        return redirect('/profile');
    }
}
```

<a name="adjusting-the-bcrypt-work-factor"></a>
#### Ajustando el Factor de Trabajo Bcrypt

Si estás utilizando el algoritmo Bcrypt, el método `make` te permite gestionar el factor de trabajo del algoritmo utilizando la opción `rounds`; sin embargo, el factor de trabajo predeterminado gestionado por Laravel es aceptable para la mayoría de las aplicaciones:


```php
$hashed = Hash::make('password', [
    'rounds' => 12,
]);
```

<a name="adjusting-the-argon2-work-factor"></a>
#### Ajustando el Factor de Trabajo de Argon2

Si estás utilizando el algoritmo Argon2, el método `make` te permite gestionar el factor de trabajo del algoritmo utilizando las opciones `memory`, `time` y `threads`; sin embargo, los valores predeterminados gestionados por Laravel son aceptables para la mayoría de las aplicaciones:


```php
$hashed = Hash::make('password', [
    'memory' => 1024,
    'time' => 2,
    'threads' => 2,
]);
```
> [!NOTA]
Para obtener más información sobre estas opciones, consulta la [documentación oficial de PHP sobre el hash Argon](https://secure.php.net/manual/en/function.password-hash.php).

<a name="verifying-that-a-password-matches-a-hash"></a>
### Verificando que una Contraseña Coincida con un Hash

El método `check` proporcionado por la fachada `Hash` te permite verificar que una determinada cadena de texto en claro corresponde a un hash dado:


```php
if (Hash::check('plain-text', $hashedPassword)) {
    // The passwords match...
}
```

<a name="determining-if-a-password-needs-to-be-rehashed"></a>
### Determinando si una Contraseña Necesita Ser Vuelta a Hashear

El método `needsRehash` proporcionado por la fachada `Hash` te permite determinar si el factor de trabajo utilizado por el hasher ha cambiado desde que se hashó la contraseña. Algunas aplicaciones eligen realizar esta verificación durante el proceso de autenticación de la aplicación:


```php
if (Hash::needsRehash($hashed)) {
    $hashed = Hash::make('plain-text');
}
```

<a name="hash-algorithm-verification"></a>
## Verificación del Algoritmo de Hash

Para prevenir la manipulación del algoritmo de hash, el método `Hash::check` de Laravel verificará primero que el hash dado fue generado utilizando el algoritmo de hash seleccionado por la aplicación. Si los algoritmos son diferentes, se lanzará una excepción `RuntimeException`.
Este es el comportamiento esperado para la mayoría de las aplicaciones, donde no se espera que el algoritmo de hash cambie y los diferentes algoritmos pueden ser un indicativo de un ataque malicioso. Sin embargo, si necesitas admitir múltiples algoritmos de hash dentro de tu aplicación, como al migrar de un algoritmo a otro, puedes desactivar la verificación del algoritmo de hash configurando la variable de entorno `HASH_VERIFY` en `false`:


```ini
HASH_VERIFY=false

```