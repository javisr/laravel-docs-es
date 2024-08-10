# Notas de la versión

- [Esquema de versionado](#versioning-scheme)
- [Política de soporte](#support-policy)
- [Laravel 11](#laravel-11)

<a name="versioning-scheme"></a>
## Esquema de versionado

Laravel y sus otros paquetes de primer nivel siguen [Semantic Versioning](https://semver.org). Las versiones principales del framework se lanzan cada año (~Q1), mientras que las versiones menores y de parches pueden lanzarse tan a menudo como cada semana. Las versiones menores y de parches **nunca** deben contener cambios que rompan la compatibilidad.

Al hacer referencia al framework Laravel o sus componentes desde tu aplicación o paquete, siempre debes usar una restricción de versión como `^11.0`, ya que las versiones principales de Laravel incluyen cambios que rompen la compatibilidad. Sin embargo, nos esforzamos por garantizar que puedas actualizar a una nueva versión principal en un día o menos.

<a name="named-arguments"></a>
#### Argumentos nombrados

[Los argumentos nombrados](https://www.php.net/manual/en/functions.arguments.php#functions.named-arguments) no están cubiertos por las pautas de compatibilidad hacia atrás de Laravel. Podemos optar por renombrar los argumentos de las funciones cuando sea necesario para mejorar la base de código de Laravel. Por lo tanto, el uso de argumentos nombrados al llamar a métodos de Laravel debe hacerse con precaución y con la comprensión de que los nombres de los parámetros pueden cambiar en el futuro.

<a name="support-policy"></a>
## Política de soporte

Para todas las versiones de Laravel, se proporcionan correcciones de errores durante 18 meses y correcciones de seguridad durante 2 años. Para todas las bibliotecas adicionales, incluyendo Lumen, solo la última versión principal recibe correcciones de errores. Además, revisa las versiones de base de datos [soportadas por Laravel](/docs/{{version}}/database#introduction).

<div class="overflow-auto">

| Versión | PHP (*) | Lanzamiento | Correcciones de errores hasta | Correcciones de seguridad hasta |
| --- | --- | --- | --- | --- |
| 9 | 8.0 - 8.2 | 8 de febrero de 2022 | 8 de agosto de 2023 | 6 de febrero de 2024 |
| 10 | 8.1 - 8.3 | 14 de febrero de 2023 | 6 de agosto de 2024 | 4 de febrero de 2025 |
| 11 | 8.2 - 8.3 | 12 de marzo de 2024 | 3 de septiembre de 2025 | 12 de marzo de 2026 |
| 12 | 8.2 - 8.3 | Q1 2025 | Q3, 2026 | Q1, 2027 |

</div>

<div class="version-colors">
    <div class="end-of-life">
        <div class="color-box"></div>
        <div>Fin de vida</div>
    </div>
    <div class="security-fixes">
        <div class="color-box"></div>
        <div>Solo correcciones de seguridad</div>
    </div>
</div>

(*) Versiones de PHP soportadas

<a name="laravel-11"></a>
## Laravel 11

Laravel 11 continúa las mejoras realizadas en Laravel 10.x al introducir una estructura de aplicación simplificada, limitación de tasa por segundo, enrutamiento de salud, rotación de claves de cifrado de manera elegante, mejoras en las pruebas de colas, transporte de correo [Resend](https://resend.com), integración de validador de prompts, nuevos comandos de Artisan y más. Además, se ha introducido Laravel Reverb, un servidor WebSocket escalable de primer nivel para proporcionar capacidades robustas en tiempo real a tus aplicaciones.

<a name="php-8"></a>
### PHP 8.2

Laravel 11.x requiere una versión mínima de PHP 8.2.

<a name="structure"></a>
### Estructura de aplicación simplificada

_La estructura de aplicación simplificada de Laravel fue desarrollada por [Taylor Otwell](https://github.com/taylorotwell) y [Nuno Maduro](https://github.com/nunomaduro)_.

Laravel 11 introduce una estructura de aplicación simplificada para aplicaciones **nuevas** de Laravel, sin requerir cambios en aplicaciones existentes. La nueva estructura de aplicación está destinada a proporcionar una experiencia más moderna y ágil, mientras se retienen muchos de los conceptos con los que los desarrolladores de Laravel ya están familiarizados. A continuación, discutiremos los aspectos destacados de la nueva estructura de aplicación de Laravel.

#### El archivo de arranque de la aplicación

El archivo `bootstrap/app.php` ha sido revitalizado como un archivo de configuración de aplicación basado en código. Desde este archivo, ahora puedes personalizar el enrutamiento de tu aplicación, middleware, proveedores de servicios, manejo de excepciones y más. Este archivo unifica una variedad de configuraciones de comportamiento de aplicación de alto nivel que anteriormente estaban dispersas por la estructura de archivos de tu aplicación:

```php
return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        //
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
```

<a name="service-providers"></a>
#### Proveedores de servicios

En lugar de que la estructura de aplicación predeterminada de Laravel contenga cinco proveedores de servicios, Laravel 11 solo incluye un único `AppServiceProvider`. La funcionalidad de los proveedores de servicios anteriores se ha incorporado en el `bootstrap/app.php`, es manejada automáticamente por el framework, o puede ser colocada en el `AppServiceProvider` de tu aplicación.

Por ejemplo, el descubrimiento de eventos ahora está habilitado por defecto, eliminando en gran medida la necesidad de registrar manualmente eventos y sus oyentes. Sin embargo, si necesitas registrar eventos manualmente, puedes hacerlo simplemente en el `AppServiceProvider`. De manera similar, los enlaces de modelo de ruta o puertas de autorización que anteriormente pudiste haber registrado en el `AuthServiceProvider` también pueden ser registrados en el `AppServiceProvider`.

<a name="opt-in-routing"></a>
#### Enrutamiento de API y difusión opcional

Los archivos de ruta `api.php` y `channels.php` ya no están presentes por defecto, ya que muchas aplicaciones no requieren estos archivos. En su lugar, pueden ser creados utilizando simples comandos de Artisan:

```shell
php artisan install:api

php artisan install:broadcasting
```

<a name="middleware"></a>
#### Middleware

Anteriormente, las nuevas aplicaciones de Laravel incluían nueve middlewares. Estos middlewares realizaban una variedad de tareas como autenticar solicitudes, recortar cadenas de entrada y validar tokens CSRF.

En Laravel 11, estos middlewares se han trasladado al propio framework, de modo que no añaden peso a la estructura de tu aplicación. Se han añadido nuevos métodos para personalizar el comportamiento de estos middlewares al framework y pueden ser invocados desde el archivo `bootstrap/app.php` de tu aplicación:

```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->validateCsrfTokens(
        except: ['stripe/*']
    );

    $middleware->web(append: [
        EnsureUserIsSubscribed::class,
    ])
})
```

Dado que todos los middlewares pueden ser fácilmente personalizados a través del `bootstrap/app.php` de tu aplicación, se ha eliminado la necesidad de una clase "kernel" HTTP separada.

<a name="scheduling"></a>
#### Programación

Usando un nuevo facade `Schedule`, las tareas programadas ahora pueden definirse directamente en el archivo `routes/console.php` de tu aplicación, eliminando la necesidad de una clase "kernel" de consola separada:

```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('emails:send')->daily();
```

<a name="exception-handling"></a>
#### Manejo de excepciones

Al igual que el enrutamiento y el middleware, el manejo de excepciones ahora puede ser personalizado desde el archivo `bootstrap/app.php` de tu aplicación en lugar de una clase de manejador de excepciones separada, reduciendo el número total de archivos incluidos en una nueva aplicación de Laravel:

```php
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->dontReport(MissedFlightException::class);

    $exceptions->report(function (InvalidOrderException $e) {
        // ...
    });
})
```

<a name="base-controller-class"></a>
#### Clase base `Controller`

El controlador base incluido en nuevas aplicaciones de Laravel ha sido simplificado. Ya no extiende la clase interna `Controller` de Laravel, y los traits `AuthorizesRequests` y `ValidatesRequests` han sido eliminados, ya que pueden ser incluidos en los controladores individuales de tu aplicación si se desea:

    <?php

    namespace App\Http\Controllers;

    abstract class Controller
    {
        //
    }

<a name="application-defaults"></a>
#### Valores predeterminados de la aplicación

Por defecto, las nuevas aplicaciones de Laravel utilizan SQLite para el almacenamiento de bases de datos, así como el controlador `database` para la sesión, caché y cola de Laravel. Esto te permite comenzar a construir tu aplicación inmediatamente después de crear una nueva aplicación de Laravel, sin necesidad de instalar software adicional o crear migraciones de base de datos adicionales.

Además, con el tiempo, los controladores `database` para estos servicios de Laravel se han vuelto lo suficientemente robustos para su uso en producción en muchos contextos de aplicación; por lo tanto, proporcionan una opción unificada y sensata tanto para aplicaciones locales como de producción.

<a name="reverb"></a>
### Laravel Reverb

_Laravel Reverb fue desarrollado por [Joe Dixon](https://github.com/joedixon)_.

[Laravel Reverb](https://reverb.laravel.com) trae comunicación WebSocket en tiempo real, rápida y escalable directamente a tu aplicación Laravel, y proporciona integración perfecta con la suite existente de herramientas de difusión de eventos de Laravel, como Laravel Echo.

```shell
php artisan reverb:start
```

Además, Reverb admite escalado horizontal a través de las capacidades de publicación / suscripción de Redis, lo que te permite distribuir tu tráfico WebSocket entre múltiples servidores Reverb en el backend, todos apoyando una única aplicación de alta demanda.

Para más información sobre Laravel Reverb, consulta la completa [documentación de Reverb](/docs/{{version}}/reverb).

<a name="rate-limiting"></a>
### Limitación de tasa por segundo

_La limitación de tasa por segundo fue contribuida por [Tim MacDonald](https://github.com/timacdonald)_.

Laravel ahora admite limitación de tasa "por segundo" para todos los limitadores de tasa, incluidos los de solicitudes HTTP y trabajos en cola. Anteriormente, los limitadores de tasa de Laravel estaban limitados a granularidad "por minuto":

```php
RateLimiter::for('invoices', function (Request $request) {
    return Limit::perSecond(1);
});
```

Para más información sobre la limitación de tasa en Laravel, consulta la [documentación de limitación de tasa](/docs/{{version}}/routing#rate-limiting).

<a name="health"></a>
### Enrutamiento de salud

_El enrutamiento de salud fue contribuido por [Taylor Otwell](https://github.com/taylorotwell)_.

Las nuevas aplicaciones de Laravel 11 incluyen una directiva de enrutamiento `health`, que instruye a Laravel para definir un simple endpoint de verificación de salud que puede ser invocado por servicios de monitoreo de salud de aplicaciones de terceros o sistemas de orquestación como Kubernetes. Por defecto, esta ruta se sirve en `/up`:

```php
->withRouting(
    web: __DIR__.'/../routes/web.php',
    commands: __DIR__.'/../routes/console.php',
    health: '/up',
)
```

Cuando se realizan solicitudes HTTP a esta ruta, Laravel también despachará un evento `DiagnosingHealth`, permitiéndote realizar verificaciones de salud adicionales que sean relevantes para tu aplicación.

<a name="encryption"></a>
### Rotación de claves de cifrado de manera elegante

_La rotación de claves de cifrado de manera elegante fue contribuida por [Taylor Otwell](https://github.com/taylorotwell)_.

Dado que Laravel cifra todas las cookies, incluyendo la cookie de sesión de tu aplicación, esencialmente cada solicitud a una aplicación Laravel depende del cifrado. Sin embargo, debido a esto, rotar la clave de cifrado de tu aplicación desconectaría a todos los usuarios de tu aplicación. Además, descifrar datos que fueron cifrados por la clave de cifrado anterior se vuelve imposible.

Laravel 11 te permite definir las claves de cifrado anteriores de tu aplicación como una lista delimitada por comas a través de la variable de entorno `APP_PREVIOUS_KEYS`.

Al cifrar valores, Laravel siempre usará la clave de cifrado "actual", que está dentro de la variable de entorno `APP_KEY`. Al descifrar valores, Laravel primero intentará con la clave actual. Si el descifrado falla usando la clave actual, Laravel intentará con todas las claves anteriores hasta que una de las claves pueda descifrar el valor.

Este enfoque para el descifrado elegante permite a los usuarios seguir utilizando tu aplicación sin interrupciones, incluso si se rota tu clave de cifrado.

Para más información sobre cifrado en Laravel, consulta la [documentación de cifrado](/docs/{{version}}/encryption).

<a name="automatic-password-rehashing"></a>
### Rehashing automático de contraseñas

_El rehashing automático de contraseñas fue contribuido por [Stephen Rees-Carter](https://github.com/valorin)_.

El algoritmo de hash de contraseñas predeterminado de Laravel es bcrypt. El "factor de trabajo" para los hashes bcrypt puede ajustarse a través del archivo de configuración `config/hashing.php` o la variable de entorno `BCRYPT_ROUNDS`.

Típicamente, el factor de trabajo bcrypt debe aumentarse con el tiempo a medida que aumenta la potencia de procesamiento de CPU / GPU. Si aumentas el factor de trabajo bcrypt para tu aplicación, Laravel ahora rehashará de manera elegante y automática las contraseñas de los usuarios a medida que los usuarios se autentiquen en tu aplicación.

<a name="prompt-validation"></a>
### Validación de prompts

_La integración del validador de prompts fue contribuida por [Andrea Marco Sartori](https://github.com/cerbero90)_.

[Laravel Prompts](/docs/{{version}}/prompts) es un paquete PHP para agregar formularios hermosos y amigables al usuario a tus aplicaciones de línea de comandos, con características similares a las de un navegador, incluyendo texto de marcador de posición y validación.

Laravel Prompts admite la validación de entrada a través de funciones anónimas:

```php
$name = text(
    label: 'What is your name?',
    validate: fn (string $value) => match (true) {
        strlen($value) < 3 => 'The name must be at least 3 characters.',
        strlen($value) > 255 => 'The name must not exceed 255 characters.',
        default => null
    }
);
```

Sin embargo, esto puede volverse engorroso al tratar con muchas entradas o escenarios de validación complicados. Por lo tanto, en Laravel 11, puedes utilizar todo el poder del [validador](/docs/{{version}}/validation) de Laravel al validar entradas de prompts:

```php
$name = text('¿Cuál es tu nombre?', validate: [
    'name' => 'required|min:3|max:255',
]);
```

<a name="queue-interaction-testing"></a>
### Pruebas de interacción con colas

_Las pruebas de interacción con colas fueron contribuidas por [Taylor Otwell](https://github.com/taylorotwell)_.

Anteriormente, intentar probar que un trabajo en cola fue liberado, eliminado o fallado manualmente era engorroso y requería la definición de falsificaciones y stubs de cola personalizados. Sin embargo, en Laravel 11, puedes probar fácilmente estas interacciones de cola utilizando el método `withFakeQueueInteractions`:

```php
use App\Jobs\ProcessPodcast;

$job = (new ProcessPodcast)->withFakeQueueInteractions();

$job->handle();

$job->assertReleased(delay: 30);
```

Para más información sobre pruebas de trabajos en cola, consulta la [documentación de colas](/docs/{{version}}/queues#testing).

<a name="new-artisan-commands"></a>
### Nuevos comandos de Artisan

_Los comandos de Artisan para la creación de clases fueron contribuidos por [Taylor Otwell](https://github.com/taylorotwell)_.

Se han añadido nuevos comandos de Artisan para permitir la creación rápida de clases, enums, interfaces y traits:

```shell
php artisan make:class
php artisan make:enum
php artisan make:interface
php artisan make:trait
```

<a name="model-cast-improvements"></a>
### Mejoras en los casts de modelo

_Las mejoras en los casts de modelo fueron contribuidas por [Nuno Maduro](https://github.com/nunomaduro)_.

Laravel 11 admite definir los casts de tu modelo utilizando un método en lugar de una propiedad. Esto permite definiciones de cast más ágiles y fluidas, especialmente al usar casts con argumentos:

    /**
     * Obtener los atributos que deben ser casteados.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'options' => AsCollection::using(OptionCollection::class),
                      // AsEncryptedCollection::using(OptionCollection::class),
                      // AsEnumArrayObject::using(OptionEnum::class),
                      // AsEnumCollection::using(OptionEnum::class),
        ];
    }

Para más información sobre el casteo de atributos, revisa la [documentación de Eloquent](/docs/{{version}}/eloquent-mutators#attribute-casting).

<a name="the-once-function"></a>
### La función `once`

_La función auxiliar `once` fue contribuida por [Taylor Otwell](https://github.com/taylorotwell) y _[Nuno Maduro](https://github.com/nunomaduro)_.

La función auxiliar `once` ejecuta el callback dado y almacena el resultado en memoria durante la duración de la solicitud. Cualquier llamada subsiguiente a la función `once` con el mismo callback devolverá el resultado previamente almacenado:

    function random(): int
    {
        return once(function () {
            return random_int(1, 1000);
        });
    }

    random(); // 123
    random(); // 123 (resultado almacenado)
    random(); // 123 (resultado almacenado)

Para más información sobre la función auxiliar `once`, consulta la [documentación de auxiliares](/docs/{{version}}/helpers#method-once).

<a name="database-performance"></a>
### Mejora del rendimiento al probar con bases de datos en memoria

_Se mejoró el rendimiento de las pruebas con bases de datos en memoria gracias a [Anders Jenbo](https://github.com/AJenbo)_

Laravel 11 ofrece un aumento significativo de velocidad al usar la base de datos SQLite `:memory:` durante las pruebas. Para lograr esto, Laravel ahora mantiene una referencia al objeto PDO de PHP y lo reutiliza a través de conexiones, a menudo reduciendo a la mitad el tiempo total de ejecución de las pruebas.

<a name="mariadb"></a>
### Soporte Mejorado para MariaDB

_El soporte mejorado para MariaDB fue contribuido por [Jonas Staudenmeir](https://github.com/staudenmeir) y [Julius Kiekbusch](https://github.com/Jubeki)_

Laravel 11 incluye soporte mejorado para MariaDB. En versiones anteriores de Laravel, podías usar MariaDB a través del controlador MySQL de Laravel. Sin embargo, Laravel 11 ahora incluye un controlador dedicado de MariaDB que proporciona mejores valores predeterminados para este sistema de bases de datos.

Para más información sobre los controladores de bases de datos de Laravel, consulta la [documentación de bases de datos](/docs/{{version}}/database).

<a name="inspecting-database"></a>
### Inspeccionando Bases de Datos y Mejoradas Operaciones de Esquema

_Las operaciones de esquema mejoradas y la inspección de bases de datos fueron contribuidas por [Hafez Divandari](https://github.com/hafezdivandari)_

Laravel 11 proporciona métodos adicionales de operación e inspección de esquema de bases de datos, incluyendo la modificación, renombrado y eliminación nativa de columnas. Además, se proporcionan tipos espaciales avanzados, nombres de esquema no predeterminados y métodos de esquema nativos para manipular tablas, vistas, columnas, índices y claves foráneas:

    use Illuminate\Support\Facades\Schema;

    $tables = Schema::getTables();
    $views = Schema::getViews();
    $columns = Schema::getColumns('users');
    $indexes = Schema::getIndexes('users');
    $foreignKeys = Schema::getForeignKeys('users');
