# Hashing

- [Introducción](#introduction)
- [Configuración](#configuration)
- [Uso Básico](#basic-usage)
    - [Hashing de Contraseñas](#hashing-passwords)
    - [Verificando que una Contraseña Coincide con un Hash](#verifying-that-a-password-matches-a-hash)
    - [Determinando si una Contraseña Necesita ser Rehashed](#determining-if-a-password-needs-to-be-rehashed)
- [Verificación del Algoritmo de Hash](#hash-algorithm-verification)

<a name="introduction"></a>
## Introducción

El `Hash` de Laravel [facade](/docs/{{version}}/facades) proporciona hashing seguro Bcrypt y Argon2 para almacenar contraseñas de usuario. Si estás utilizando uno de los [kits de inicio de aplicación de Laravel](/docs/{{version}}/starter-kits), Bcrypt se utilizará para el registro y la autenticación por defecto.

Bcrypt es una excelente opción para hacer hashing de contraseñas porque su "factor de trabajo" es ajustable, lo que significa que el tiempo que toma generar un hash puede aumentarse a medida que aumenta la potencia del hardware. Al hacer hashing de contraseñas, lento es bueno. Cuanto más tiempo toma un algoritmo para hacer hashing de una contraseña, más tiempo toma a los usuarios maliciosos generar "tablas arcoíris" de todos los posibles valores de hash de cadena que pueden ser utilizados en ataques de fuerza bruta contra aplicaciones.

<a name="configuration"></a>
## Configuración

Por defecto, Laravel utiliza el controlador de hashing `bcrypt` al hacer hashing de datos. Sin embargo, se admiten varios otros controladores de hashing, incluidos [`argon`](https://en.wikipedia.org/wiki/Argon2) y [`argon2id`](https://en.wikipedia.org/wiki/Argon2).

Puedes especificar el controlador de hashing de tu aplicación utilizando la variable de entorno `HASH_DRIVER`. Pero, si deseas personalizar todas las opciones del controlador de hashing de Laravel, debes publicar el archivo de configuración completo de `hashing` utilizando el comando Artisan `config:publish`:

```bash
php artisan config:publish hashing
```

<a name="basic-usage"></a>
## Uso Básico

<a name="hashing-passwords"></a>
### Hashing de Contraseñas

Puedes hacer hashing de una contraseña llamando al método `make` en el facade `Hash`:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Hash;

    class PasswordController extends Controller
    {
        /**
         * Actualizar la contraseña del usuario.
         */
        public function update(Request $request): RedirectResponse
        {
            // Validar la longitud de la nueva contraseña...

            $request->user()->fill([
                'password' => Hash::make($request->newPassword)
            ])->save();

            return redirect('/profile');
        }
    }

<a name="adjusting-the-bcrypt-work-factor"></a>
#### Ajustando El Factor de Trabajo de Bcrypt

Si estás utilizando el algoritmo Bcrypt, el método `make` te permite gestionar el factor de trabajo del algoritmo utilizando la opción `rounds`; sin embargo, el factor de trabajo por defecto gestionado por Laravel es aceptable para la mayoría de las aplicaciones:

    $hashed = Hash::make('password', [
        'rounds' => 12,
    ]);

<a name="adjusting-the-argon2-work-factor"></a>
#### Ajustando El Factor de Trabajo de Argon2

Si estás utilizando el algoritmo Argon2, el método `make` te permite gestionar el factor de trabajo del algoritmo utilizando las opciones `memory`, `time` y `threads`; sin embargo, los valores por defecto gestionados por Laravel son aceptables para la mayoría de las aplicaciones:

    $hashed = Hash::make('password', [
        'memory' => 1024,
        'time' => 2,
        'threads' => 2,
    ]);

> [!NOTE]  
> Para más información sobre estas opciones, consulta la [documentación oficial de PHP sobre hashing Argon](https://secure.php.net/manual/en/function.password-hash.php).

<a name="verifying-that-a-password-matches-a-hash"></a>
### Verificando que una Contraseña Coincide con un Hash

El método `check` proporcionado por el facade `Hash` te permite verificar que una cadena de texto en claro dada corresponde a un hash dado:

    if (Hash::check('plain-text', $hashedPassword)) {
        // Las contraseñas coinciden...
    }

<a name="determining-if-a-password-needs-to-be-rehashed"></a>
### Determinando si una Contraseña Necesita ser Rehashed

El método `needsRehash` proporcionado por el facade `Hash` te permite determinar si el factor de trabajo utilizado por el hasher ha cambiado desde que se hizo el hashing de la contraseña. Algunas aplicaciones eligen realizar esta verificación durante el proceso de autenticación de la aplicación:

    if (Hash::needsRehash($hashed)) {
        $hashed = Hash::make('plain-text');
    }

<a name="hash-algorithm-verification"></a>
## Verificación del Algoritmo de Hash

Para prevenir la manipulación del algoritmo de hash, el método `Hash::check` de Laravel primero verificará que el hash dado fue generado utilizando el algoritmo de hashing seleccionado por la aplicación. Si los algoritmos son diferentes, se lanzará una excepción `RuntimeException`.

Este es el comportamiento esperado para la mayoría de las aplicaciones, donde no se espera que el algoritmo de hashing cambie y diferentes algoritmos pueden ser una indicación de un ataque malicioso. Sin embargo, si necesitas soportar múltiples algoritmos de hashing dentro de tu aplicación, como al migrar de un algoritmo a otro, puedes desactivar la verificación del algoritmo de hash configurando la variable de entorno `HASH_VERIFY` a `false`:

```ini
HASH_VERIFY=false
```
