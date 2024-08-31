# Notas de la Versión

- [Esquema de Versionado](#versioning-scheme)
- [Política de Soporte](#support-policy)
- [Laravel 11](#laravel-11)

<a name="versioning-scheme"></a>
## Esquema de Versionado

Laravel y sus otros paquetes de primera mano siguen [Semantic Versioning](https://semver.org). Las versiones principales del framework se lanzan cada año (~Q1), mientras que las versiones menores y de corrección pueden lanzarse con una frecuencia de hasta cada semana. Las versiones menores y de corrección **nunca** deben contener cambios que rompan la compatibilidad.
Al hacer referencia al framework Laravel o sus componentes desde tu aplicación o paquete, siempre debes usar una restricción de versión como `^11.0`, ya que las versiones principales de Laravel incluyen cambios incompatibles. Sin embargo, nos esforzamos por asegurarnos de que puedas actualizar a una nueva versión mayor en un día o menos.

<a name="named-arguments"></a>
#### Argumentos Nombrados

[Los argumentos nombrados](https://www.php.net/manual/en/functions.arguments.php#functions.named-arguments) no están cubiertos por las directrices de compatibilidad hacia atrás de Laravel. Podemos optar por renombrar los argumentos de las funciones cuando sea necesario para mejorar la base de código de Laravel. Por lo tanto, utilizar argumentos nombrados al llamar a métodos de Laravel debe hacerse con precaución y con la comprensión de que los nombres de los parámetros pueden cambiar en el futuro.

<a name="support-policy"></a>
## Política de Soporte

Para todas las versiones de Laravel, se proporcionan correcciones de errores durante 18 meses y correcciones de seguridad durante 2 años. Para todas las bibliotecas adicionales, incluyendo Lumen, solo la última versión principal recibe correcciones de errores. Además, revisa las versiones de la base de datos [soportadas por Laravel](/docs/%7B%7Bversion%7D%7D/database#introduction).
<div class="overflow-auto">

| Versión | PHP (*) | Lanzamiento | Correcciones de Bugs Hasta | Correcciones de Seguridad Hasta |
| --- | --- | --- | --- | --- |
| 9 | 8.0 - 8.2 | 8 de febrero de 2022 | 8 de agosto de 2023 | 6 de febrero de 2024 |
| 10 | 8.1 - 8.3 | 14 de febrero de 2023 | 6 de agosto de 2024 | 4 de febrero de 2025 |
| 11 | 8.2 - 8.3 | 12 de marzo de 2024 | 3 de septiembre de 2025 | 12 de marzo de 2026 |
| 12 | 8.2 - 8.3 | Q1 2025 | Q3, 2026 | Q1, 2027 |
</div>
<div class="version-colors">
    <div class="end-of-life">
        <div class="color-box"></div>
        <div>End of life</div>
    </div>
    <div class="security-fixes">
        <div class="color-box"></div>
        <div>Security fixes only</div>
    </div>
</div>

(*) Versiones de PHP soportadas

<a name="laravel-11"></a>
## Laravel 11

Laravel 11 continúa las mejoras realizadas en Laravel 10.x al introducir una estructura de aplicación simplificada, limitación de tasa por segundo, enrutamiento de salud, rotación de clave de cifrado de manera elegante, mejoras en las pruebas de cola, transporte de correo [Resend](https://resend.com), integración de validador de Prompt, nuevos comandos Artisan y más. Además, se ha introducido Laravel Reverb, un servidor WebSocket escalable de primera mano para proporcionar sólidas capacidades en tiempo real a tus aplicaciones.

<a name="php-8"></a>
### PHP 8.2

Laravel 11.x requiere una versión mínima de PHP 8.2.

<a name="structure"></a>
### Estructura de Aplicación Simplificada

*La estructura de aplicación simplificada de Laravel fue desarrollada por [Taylor Otwell](https://github.com/taylorotwell) y [Nuno Maduro](https://github.com/nunomaduro)*.
Laravel 11 introduce una estructura de aplicación simplificada para **nuevas** aplicaciones Laravel, sin requerir cambios en aplicaciones existentes. La nueva estructura de aplicación está destinada a proporcionar una experiencia más ágil y moderna, mientras se retienen muchos de los conceptos con los que los desarrolladores de Laravel ya están familiarizados. A continuación, discutiremos los aspectos más destacados de la nueva estructura de aplicación de Laravel.
#### El Archivo de Bootstrap de la Aplicación

El archivo `bootstrap/app.php` ha sido revitalizado como un archivo de configuración de aplicación orientado a código. Desde este archivo, ahora puedes personalizar el enrutamiento, middleware, proveedores de servicios, manejo de excepciones y más de tu aplicación. Este archivo unifica una variedad de configuraciones de comportamiento de alto nivel de la aplicación que anteriormente estaban dispersas por la estructura de archivos de tu aplicación:


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
#### Proveedores de Servicios

En lugar de la estructura de aplicación predeterminada de Laravel que contiene cinco proveedores de servicios, Laravel 11 solo incluye un solo `AppServiceProvider`. La funcionalidad de los proveedores de servicios anteriores se ha incorporado en el `bootstrap/app.php`, es manejada automáticamente por el framework, o puede ser colocada en el `AppServiceProvider` de tu aplicación.
Por ejemplo, el descubrimiento de eventos ahora está habilitado por defecto, lo que reduce en gran medida la necesidad de registrar manualmente los eventos y sus oyentes. Sin embargo, si necesitas registrar eventos manualmente, puedes hacerlo simplemente en el `AppServiceProvider`. De manera similar, los enlaces de modelos de ruta o las puertas de autorización que podrías haber registrado anteriormente en el `AuthServiceProvider` también pueden ser registrados en el `AppServiceProvider`.

<a name="opt-in-routing"></a>
#### API y enrutamiento de difusión opt-in

Los archivos de rutas `api.php` y `channels.php` ya no están presentes por defecto, ya que muchas aplicaciones no requieren estos archivos. En su lugar, pueden ser creados utilizando comandos simples de Artisan:


```shell
php artisan install:api

php artisan install:broadcasting

```

<a name="middleware"></a>
#### Middleware

Anteriormente, las nuevas aplicaciones de Laravel incluían nueve middleware. Estos middleware realizaban una variedad de tareas, como autenticar solicitudes, recortar cadenas de entrada y validar tokens CSRF.
En Laravel 11, estos middleware han sido trasladados al propio framework, de modo que no añadan peso a la estructura de tu aplicación. Se han añadido nuevos métodos para personalizar el comportamiento de estos middleware y pueden ser invocados desde el archivo `bootstrap/app.php` de tu aplicación:


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
Dado que todo el middleware se puede personalizar fácilmente a través de `bootstrap/app.php` de tu aplicación, se ha eliminado la necesidad de una clase "kernel" HTTP separada.

<a name="scheduling"></a>
#### Programación

Usando una nueva facade `Schedule`, las tareas programadas ahora pueden definirse directamente en el archivo `routes/console.php` de tu aplicación, eliminando la necesidad de una clase "kernel" de consola separada:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('emails:send')->daily();

```

<a name="exception-handling"></a>
#### Manejo de Excepciones

Al igual que el enrutamiento y el middleware, el manejo de excepciones ahora se puede personalizar desde el archivo `bootstrap/app.php` de tu aplicación en lugar de una clase de manejador de excepciones separada, reduciendo el número total de archivos incluidos en una nueva aplicación Laravel:


```php
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->dontReport(MissedFlightException::class);

    $exceptions->report(function (InvalidOrderException $e) {
        // ...
    });
})

```

<a name="base-controller-class"></a>
#### Clase `Controller` Base

El controlador base incluido en las nuevas aplicaciones de Laravel ha sido simplificado. Ya no extiende la clase `Controller` interna de Laravel, y se han eliminado los rasgos `AuthorizesRequests` y `ValidatesRequests`, ya que pueden incluirse en los controladores individuales de tu aplicación si lo deseas:


```php
<?php

namespace App\Http\Controllers;

abstract class Controller
{
    //
}
```

<a name="application-defaults"></a>
#### Valores Predeterminados de la Aplicación

Por defecto, las nuevas aplicaciones de Laravel utilizan SQLite para el almacenamiento de bases de datos, así como el driver `database` para la sesión, caché y cola de Laravel. Esto te permite comenzar a construir tu aplicación inmediatamente después de crear una nueva aplicación Laravel, sin necesidad de instalar software adicional o crear migraciones de bases de datos adicionales.
Además, con el tiempo, los drivers `database` para estos servicios de Laravel se han vuelto lo suficientemente robustos para su uso en producción en muchos contextos de aplicación; por lo tanto, ofrecen una opción unificada y sensata tanto para aplicaciones locales como para aplicaciones en producción.

<a name="reverb"></a>
### Laravel Reverb

*Laravel Reverb fue desarrollado por [Joe Dixon](https://github.com/joedixon)*.
[Laravel Reverb](https://reverb.laravel.com) ofrece comunicación WebSocket en tiempo real rápida y escalable directamente a tu aplicación Laravel, y proporciona una integración fluida con la suite existente de herramientas de transmisión de eventos de Laravel, como Laravel Echo.


```shell
php artisan reverb:start

```
Además, Reverb admite escalado horizontal a través de las capacidades de publicación / suscripción de Redis, lo que te permite distribuir tu tráfico de WebSocket entre múltiples servidores Reverb backend, todos soportando una sola aplicación de alta demanda.
Para obtener más información sobre Laravel Reverb, consulta la completa [documentación de Reverb](/docs/%7B%7Bversion%7D%7D/reverb).

<a name="rate-limiting"></a>
### Limitación de Tasa por Segundo

*La limitación de tasa por segundo fue contribuida por [Tim MacDonald](https://github.com/timacdonald).*
Laravel ahora admite limitación de tasa "por segundo" para todos los limitadores de tasa, incluidos los para solicitudes HTTP y trabajos en cola. Anteriormente, los limitadores de tasa de Laravel estaban limitados a granularidad "por minuto":


```php
RateLimiter::for('invoices', function (Request $request) {
    return Limit::perSecond(1);
});

```
Para obtener más información sobre la limitación de tasas en Laravel, consulta la [documentación de limitación de tasas](/docs/%7B%7Bversion%7D%7D/routing#rate-limiting).

<a name="health"></a>
### Enrutamiento de Salud

*El enrutamiento de salud fue contribuido por [Taylor Otwell](https://github.com/taylorotwell).*
Las nuevas aplicaciones de Laravel 11 incluyen un directive de enrutamiento `health`, que instruye a Laravel a definir un endpoint de verificación de salud simple que puede ser invocado por servicios de monitoreo de salud de aplicaciones de terceros o sistemas de orquestación como Kubernetes. Por defecto, esta ruta se sirve en `/up`:


```php
->withRouting(
    web: __DIR__.'/../routes/web.php',
    commands: __DIR__.'/../routes/console.php',
    health: '/up',
)

```
Cuando se realicen solicitudes HTTP a esta ruta, Laravel también despachará un evento `DiagnosingHealth`, lo que te permitirá realizar comprobaciones de salud adicionales que sean relevantes para tu aplicación.

<a name="encryption"></a>
### Rotación de Claves de Cifrado de Forma Elegante

*La rotación de la clave de cifrado de manera fluida fue aportada por [Taylor Otwell](https://github.com/taylorotwell)*.
Dado que Laravel encripta todas las cookies, incluida la cookie de sesión de tu aplicación, esencialmente, cada solicitud a una aplicación Laravel depende de la encriptación. Sin embargo, debido a esto, rotar la clave de encriptación de tu aplicación desconectaría a todos los usuarios de tu aplicación. Además, descifrar datos que fueron encriptados con la clave de encriptación anterior se vuelve imposible.
Laravel 11 te permite definir las claves de cifrado anteriores de tu aplicación como una lista delimitada por comas a través de la variable de entorno `APP_PREVIOUS_KEYS`.
Al encriptar valores, Laravel siempre utilizará la clave de encriptación "actual", que se encuentra en la variable de entorno `APP_KEY`. Al desencriptar valores, Laravel primero intentará con la clave actual. Si la desencriptación falla utilizando la clave actual, Laravel intentará con todas las claves anteriores hasta que una de las claves pueda desencriptar el valor.
Este enfoque para la descifrado elegante permite a los usuarios seguir utilizando tu aplicación sin interrupciones, incluso si se rota tu clave de cifrado.
Para obtener más información sobre la encriptación en Laravel, consulta la [documentación de encriptación](/docs/%7B%7Bversion%7D%7D/encryption).

<a name="automatic-password-rehashing"></a>
### Rehashing Automático de Contraseñas

*El rehashing automático de contraseñas fue contribuido por [Stephen Rees-Carter](https://github.com/valorin)*.
El algoritmo de hashing de contraseñas predeterminado de Laravel es bcrypt. El "factor de trabajo" para los hash de bcrypt se puede ajustar a través del archivo de configuración `config/hashing.php` o la variable de entorno `BCRYPT_ROUNDS`.
Típicamente, el factor de trabajo de bcrypt debería aumentarse con el tiempo a medida que aumenta la potencia de procesamiento de CPU / GPU. Si aumentas el factor de trabajo de bcrypt para tu aplicación, Laravel ahora volverá a calcular las contraseñas de los usuarios de manera automática y sin problemas a medida que los usuarios se autentiquen en tu aplicación.

<a name="prompt-validation"></a>
### Validación de Prompts

*La integración del validador de prompts fue contribuida por [Andrea Marco Sartori](https://github.com/cerbero90)*.
[Laravel Prompts](/docs/%7B%7Bversion%7D%7D/prompts) es un paquete de PHP para añadir formularios hermosos y fáciles de usar a tus aplicaciones de línea de comandos, con características similares a un navegador, incluyendo texto de marcador de posición y validación.
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
Sin embargo, esto puede volverse tedioso al tratar con muchas entradas o escenarios de validación complicados. Por lo tanto, en Laravel 11, puedes utilizar todo el poder del [validador](/docs/%7B%7Bversion%7D%7D/validation) de Laravel al validar entradas de aviso:


```php
$name = text('What is your name?', validate: [
    'name' => 'required|min:3|max:255',
]);

```

<a name="queue-interaction-testing"></a>
### Pruebas de Interacción con la Cola

*Las pruebas de interacción con la cola fueron aportadas por [Taylor Otwell](https://github.com/taylorotwell)*.
Anteriormente, intentar probar que un trabajo en cola fue liberado, eliminado o fallado manualmente era complicado y requería la definición de falsificaciones y stubs de cola personalizados. Sin embargo, en Laravel 11, puedes probar fácilmente estas interacciones de cola utilizando el método `withFakeQueueInteractions`:


```php
use App\Jobs\ProcessPodcast;

$job = (new ProcessPodcast)->withFakeQueueInteractions();

$job->handle();

$job->assertReleased(delay: 30);

```
Para obtener más información sobre la prueba de trabajos en cola, consulta la [documentación de colas](/docs/%7B%7Bversion%7D%7D/queues#testing).

<a name="new-artisan-commands"></a>
### Nuevos comandos Artisan

*Los comandos Artisan para la creación de clases fueron aportados por [Taylor Otwell](https://github.com/taylorotwell)*.
Se han añadido nuevos comandos Artisan para permitir la creación rápida de clases, enums, interfaces y traits:


```shell
php artisan make:class
php artisan make:enum
php artisan make:interface
php artisan make:trait

```

<a name="model-cast-improvements"></a>
### Mejoras en Casts de Modelos

*Las mejoras en los casts de modelo fueron contribuidas por [Nuno Maduro](https://github.com/nunomaduro)*.
Laravel 11 admite definir los casts de tu modelo utilizando un método en lugar de una propiedad. Esto permite definiciones de cast más fluidas y simplificadas, especialmente al usar casts con argumentos:


```php
/**
 * Get the attributes that should be cast.
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
```
Para obtener más información sobre la conversión de atributos, revisa la [documentación de Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent-mutators#attribute-casting).

<a name="the-once-function"></a>
### La función `once`

*El helper `once` fue contribuido por [Taylor Otwell](https://github.com/taylorotwell)* y *[Nuno Maduro](https://github.com/nunomaduro)*.
La función auxiliar `once` ejecuta el callback dado y almacena el resultado en memoria durante la duración de la solicitud. Cualquier llamada posterior a la función `once` con el mismo callback devolverá el resultado en caché previamente:


```php
function random(): int
{
    return once(function () {
        return random_int(1, 1000);
    });
}

random(); // 123
random(); // 123 (cached result)
random(); // 123 (cached result)
```
Para obtener más información sobre el helper `once`, consulta la [documentación de helpers](/docs/%7B%7Bversion%7D%7D/helpers#method-once).

<a name="database-performance"></a>
### Mejora de Rendimiento al Probar con Bases de Datos en Memoria

*Se mejoró el rendimiento de las pruebas de base de datos en memoria gracias a la contribución de [Anders Jenbo](https://github.com/AJenbo)*
Laravel 11 ofrece un impulso de velocidad significativo al usar la base de datos SQLite `:memory:` durante las pruebas. Para lograr esto, Laravel ahora mantiene una referencia al objeto PDO de PHP y lo reutiliza a través de las conexiones, a menudo reduciendo el tiempo total de ejecución de pruebas a la mitad.

<a name="mariadb"></a>
### Mejoras en el Soporte para MariaDB

*Se mejoró el soporte para MariaDB gracias a la contribución de [Jonas Staudenmeir](https://github.com/staudenmeir) y [Julius Kiekbusch](https://github.com/Jubeki)*
Laravel 11 incluye un soporte mejorado para MariaDB. En versiones anteriores de Laravel, podías usar MariaDB a través del driver MySQL de Laravel. Sin embargo, Laravel 11 ahora incluye un driver dedicado para MariaDB que ofrece mejores configuraciones predeterminadas para este sistema de base de datos.
Para obtener más información sobre los controladores de base de datos de Laravel, consulta la [documentación de la base de datos](/docs/%7B%7Bversion%7D%7D/database).

<a name="inspecting-database"></a>
### Inspeccionando Bases de Datos y Mejoradas Operaciones de Esquema

*Las operaciones de esquema mejoradas y la inspección de la base de datos fueron aportadas por [Hafez Divandari](https://github.com/hafezdivandari)*
Laravel 11 proporciona métodos adicionales de operación e inspección de esquema de base de datos, incluyendo la modificación, renombrado y eliminación nativa de columnas. Además, se ofrecen tipos espaciales avanzados, nombres de esquema no predeterminados y métodos de esquema nativos para manipular tablas, vistas, columnas, índices y claves foráneas:


```php
use Illuminate\Support\Facades\Schema;

$tables = Schema::getTables();
$views = Schema::getViews();
$columns = Schema::getColumns('users');
$indexes = Schema::getIndexes('users');
$foreignKeys = Schema::getForeignKeys('users');
```