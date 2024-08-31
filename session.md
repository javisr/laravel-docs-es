# Sesión HTTP

- [Introducción](#introduction)
  - [Configuración](#configuration)
  - [Requisitos Previos del Driver](#driver-prerequisites)
- [Interacting With the Session](#interacting-with-the-session)
  - [Recuperar Datos](#retrieving-data)
  - [Almacenar Datos](#storing-data)
  - [Datos Flash](#flash-data)
  - [Eliminar Datos](#deleting-data)
  - [Regenerar el ID de Sesión](#regenerating-the-session-id)
- [Bloqueo de Sesión](#session-blocking)
- [Agregar Controladores de Sesión Personalizados](#adding-custom-session-drivers)
  - [Implementar el Driver](#implementing-the-driver)
  - [Registrar el Driver](#registering-the-driver)

<a name="introduction"></a>
## Introducción

Dado que las aplicaciones impulsadas por HTTP son sin estado, las sesiones proporcionan una forma de almacenar información sobre el usuario a lo largo de múltiples solicitudes. Esa información del usuario se coloca típicamente en un almacenamiento / backend persistente que se puede acceder desde solicitudes posteriores.
Laravel viene con una variedad de backends de sesión que se acceden a través de una API unificada y expresiva. Se incluye soporte para backends populares como [Memcached](https://memcached.org), [Redis](https://redis.io) y bases de datos.

<a name="configuration"></a>
### Configuración

El archivo de configuración de sesión de tu aplicación se almacena en `config/session.php`. Asegúrate de revisar las opciones disponibles en este archivo. Por defecto, Laravel está configurado para usar el driver de sesión `database`.
La opción de configuración `driver` de la sesión define dónde se almacenarán los datos de la sesión para cada solicitud. Laravel incluye una variedad de drivers:
<div class="content-list" markdown="1">

- `file` - sessions are stored in `storage/framework/sessions`.
- `cookie` - sessions are stored in secure, encrypted cookies.
- `database` - sessions are stored in a relational database.
- `memcached` / `redis` - sessions are stored in one of these fast, cache based stores.
- `dynamodb` - sessions are stored in AWS DynamoDB.
- `array` - sessions are stored in a PHP array and will not be persisted.
</div>
> [!NOTE]
El driver de array se utiliza principalmente durante [pruebas](/docs/%7B%7Bversion%7D%7D/testing) y evita que los datos almacenados en la sesión se persistan.

<a name="driver-prerequisites"></a>
### Prerequisitos del Driver


<a name="database"></a>
#### Base de datos

Al utilizar el driver de sesión `database`, necesitarás asegurarte de que tienes una tabla de base de datos para contener los datos de la sesión. Típicamente, esto se incluye en la migración de base de datos predeterminada de Laravel `0001_01_01_000000_create_users_table.php` [migración de base de datos](/docs/%7B%7Bversion%7D%7D/migrations); sin embargo, si por alguna razón no tienes una tabla `sessions`, puedes usar el comando Artisan `make:session-table` para generar esta migración:


```shell
php artisan make:session-table

php artisan migrate

```

<a name="redis"></a>
#### Redis

Antes de usar sesiones de Redis con Laravel, necesitarás instalar la extensión PHP PhpRedis a través de PECL o instalar el paquete `predis/predis` (~1.0) a través de Composer. Para obtener más información sobre la configuración de Redis, consulta la [documentación de Redis](/docs/%7B%7Bversion%7D%7D/redis#configuration) de Laravel.
> [!NOTA]
La variable de entorno `SESSION_CONNECTION`, o la opción `connection` en el archivo de configuración `session.php`, pueden usarse para especificar qué conexión de Redis se utiliza para el almacenamiento de sesiones.

<a name="interacting-with-the-session"></a>
## Interactuando Con la Sesión


<a name="retrieving-data"></a>
### Recuperando Datos

Hay dos formas principales de trabajar con datos de sesión en Laravel: el helper global `session` y a través de una instancia de `Request`. Primero, veamos cómo acceder a la sesión a través de una instancia de `Request`, que se puede indicar como tipo en una función anónima de ruta o método del controlador. Recuerda, las dependencias del método del controlador se inyectan automáticamente a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\View\View;

class UserController extends Controller
{
    /**
     * Show the profile for the given user.
     */
    public function show(Request $request, string $id): View
    {
        $value = $request->session()->get('key');

        // ...

        $user = $this->users->find($id);

        return view('user.profile', ['user' => $user]);
    }
}
```
Cuando recuperas un elemento de la sesión, también puedes pasar un valor predeterminado como segundo argumento al método `get`. Este valor predeterminado se devolverá si la clave especificada no existe en la sesión. Si pasas una función anónima como el valor predeterminado al método `get` y la clave solicitada no existe, se ejecutará la función anónima y se devolverá su resultado:


```php
$value = $request->session()->get('key', 'default');

$value = $request->session()->get('key', function () {
    return 'default';
});
```

<a name="the-global-session-helper"></a>
#### El Helper Global de Sesión

También puedes usar la función PHP global `session` para recuperar y almacenar datos en la sesión. Cuando se llama al helper `session` con un solo argumento de cadena, devolverá el valor de esa clave de sesión. Cuando se llama al helper con un array de pares clave / valor, esos valores se almacenarán en la sesión:


```php
Route::get('/home', function () {
    // Retrieve a piece of data from the session...
    $value = session('key');

    // Specifying a default value...
    $value = session('key', 'default');

    // Store a piece of data in the session...
    session(['key' => 'value']);
});
```
> [!NOTA]
Hay poca diferencia práctica entre usar la sesión a través de una instancia de solicitud HTTP frente a usar el helper global `session`. Ambos métodos son [testables](/docs/%7B%7Bversion%7D%7D/testing) a través del método `assertSessionHas` que está disponible en todos tus casos de prueba.

<a name="retrieving-all-session-data"></a>
#### Recuperando Todos los Datos de Sesión

Si deseas recuperar todos los datos de la sesión, puedes usar el método `all`:


```php
$data = $request->session()->all();
```

<a name="retrieving-a-portion-of-the-session-data"></a>
#### Recuperando una Porción de los Datos de la Sesión

Los métodos `only` y `except` se pueden utilizar para recuperar un subconjunto de los datos de la sesión:


```php
$data = $request->session()->only(['username', 'email']);

$data = $request->session()->except(['username', 'email']);
```

<a name="determining-if-an-item-exists-in-the-session"></a>
#### Determinando si un Elemento Existe en la Sesión

Para determinar si un elemento está presente en la sesión, puedes usar el método `has`. El método `has` devuelve `true` si el elemento está presente y no es `null`:


```php
if ($request->session()->has('users')) {
    // ...
}
```
Para determinar si un elemento está presente en la sesión, incluso si su valor es `null`, puedes usar el método `exists`:


```php
if ($request->session()->exists('users')) {
    // ...
}
```
Para determinar si un elemento no está presente en la sesión, puedes usar el método `missing`. El método `missing` devuelve `true` si el elemento no está presente:


```php
if ($request->session()->missing('users')) {
    // ...
}
```

<a name="storing-data"></a>
### Almacenando Datos

Para almacenar datos en la sesión, típicamente usarás el método `put` de la instancia de la solicitud o el helper global `session`:


```php
// Via a request instance...
$request->session()->put('key', 'value');

// Via the global "session" helper...
session(['key' => 'value']);
```

<a name="pushing-to-array-session-values"></a>
#### Añadiendo valores a la sesión de Array

El método `push` se puede usar para añadir un nuevo valor a un valor de sesión que es un array. Por ejemplo, si la clave `user.teams` contiene un array de nombres de equipos, puedes añadir un nuevo valor al array de la siguiente manera:


```php
$request->session()->push('user.teams', 'developers');
```

<a name="retrieving-deleting-an-item"></a>
#### Recuperando y Eliminando un Elemento

El método `pull` recuperará y eliminará un elemento de la sesión en una sola declaración:


```php
$value = $request->session()->pull('key', 'default');
```

<a name="incrementing-and-decrementing-session-values"></a>
#### Incrementando y Decrementando Valores de Sesión

Si los datos de tu sesión contienen un entero que deseas incrementar o decrementar, puedes usar los métodos `increment` y `decrement`:


```php
$request->session()->increment('count');

$request->session()->increment('count', $incrementBy = 2);

$request->session()->decrement('count');

$request->session()->decrement('count', $decrementBy = 2);
```

<a name="flash-data"></a>
### Flash Data

A veces es posible que desees almacenar elementos en la sesión para la siguiente solicitud. Puedes hacerlo utilizando el método `flash`. Los datos almacenados en la sesión utilizando este método estarán disponibles de inmediato y durante la solicitud HTTP posterior. Después de la solicitud HTTP posterior, los datos en flash serán eliminados. Los datos en flash son principalmente útiles para mensajes de estado de corta duración:


```php
$request->session()->flash('status', 'Task was successful!');
```
Si necesitas persistir tus datos flash durante varias solicitudes, puedes usar el método `reflash`, que mantendrá todos los datos flash durante una solicitud adicional. Si solo necesitas mantener datos flash específicos, puedes usar el método `keep`:


```php
$request->session()->reflash();

$request->session()->keep(['username', 'email']);
```
Para persistir tus datos flash solo para la solicitud actual, puedes usar el método `now`:


```php
$request->session()->now('status', 'Task was successful!');
```

<a name="deleting-data"></a>
### Eliminando Datos

El método `forget` eliminará un dato de la sesión. Si deseas eliminar todos los datos de la sesión, puedes usar el método `flush`:


```php
// Forget a single key...
$request->session()->forget('name');

// Forget multiple keys...
$request->session()->forget(['name', 'status']);

$request->session()->flush();
```

<a name="regenerating-the-session-id"></a>
### Regenerando el ID de Sesión

Regenerar el ID de sesión a menudo se hace para prevenir que usuarios malintencionados exploten un ataque de [fijación de sesión](https://owasp.org/www-community/attacks/Session_fixation) en tu aplicación.
Laravel regenera automáticamente el ID de sesión durante la autenticación si estás utilizando uno de los [kits de inicio de Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits) o [Laravel Fortify](/docs/%7B%7Bversion%7D%7D/fortify); sin embargo, si necesitas regenerar el ID de sesión de forma manual, puedes usar el método `regenerate`:


```php
$request->session()->regenerate();
```
Si necesitas regenerar el ID de sesión y eliminar todos los datos de la sesión en una sola declaración, puedes usar el método `invalidate`:


```php
$request->session()->invalidate();
```

<a name="session-blocking"></a>
## Bloqueo de Sesión

> [!WARNING]
Para utilizar el bloqueo de sesiones, tu aplicación debe estar utilizando un driver de caché que soporte [bloqueos atómicos](/docs/%7B%7Bversion%7D%7D/cache#atomic-locks). Actualmente, esos drivers de caché incluyen los drivers `memcached`, `dynamodb`, `redis`, `database`, `file` y `array`. Además, no puedes usar el driver de sesión `cookie`.
Por defecto, Laravel permite que las solicitudes que utilizan la misma sesión se ejecuten de forma concurrente. Así que, por ejemplo, si usas una biblioteca HTTP de JavaScript para hacer dos solicitudes HTTP a tu aplicación, ambas se ejecutarán al mismo tiempo. Para muchas aplicaciones, esto no es un problema; sin embargo, puede ocurrir pérdida de datos de sesión en un pequeño subconjunto de aplicaciones que realizan solicitudes concurrentes a dos endpoints de aplicación diferentes que ambos escriben datos en la sesión.
Para mitigar esto, Laravel ofrece una funcionalidad que te permite limitar las solicitudes concurrentes para una sesión dada. Para comenzar, simplemente puedes encadenar el método `block` a tu definición de ruta. En este ejemplo, una solicitud entrante al punto final `/profile` adquiriría un bloqueo de sesión. Mientras se mantenga este bloqueo, cualquier solicitud entrante a los puntos finales `/profile` o `/order` que compartan el mismo ID de sesión esperará a que la primera solicitud termine de ejecutarse antes de continuar con su ejecución:


```php
Route::post('/profile', function () {
    // ...
})->block($lockSeconds = 10, $waitSeconds = 10)

Route::post('/order', function () {
    // ...
})->block($lockSeconds = 10, $waitSeconds = 10)
```
El método `block` acepta dos argumentos opcionales. El primer argumento aceptado por el método `block` es el número máximo de segundos que se debe mantener el bloqueo de la sesión antes de que se libere. Por supuesto, si la solicitud termina de ejecutarse antes de este tiempo, el bloqueo se liberará antes.
El segundo argumento aceptado por el método `block` es el número de segundos que debe esperar una solicitud mientras intenta obtener un bloqueo de sesión. Se lanzará una `Illuminate\Contracts\Cache\LockTimeoutException` si la solicitud no puede obtener un bloqueo de sesión dentro del número dado de segundos.
Si ninguno de estos argumentos es pasado, se obtendrá el bloqueo por un máximo de 10 segundos y las solicitudes esperarán un máximo de 10 segundos mientras intentan obtener un bloqueo:


```php
Route::post('/profile', function () {
    // ...
})->block()
```

<a name="adding-custom-session-drivers"></a>
## Agregar Controladores de Sesión Personalizados


<a name="implementing-the-driver"></a>
### Implementando el Driver

Si ninguno de los controladores de sesión existentes se adapta a las necesidades de tu aplicación, Laravel permite escribir tu propio manejador de sesión. Tu driver de sesión personalizado debe implementar `SessionHandlerInterface` incorporado de PHP. Esta interfaz contiene solo unos pocos métodos simples. Una implementación de MongoDB simulada se ve como la siguiente:


```php
<?php

namespace App\Extensions;

class MongoSessionHandler implements \SessionHandlerInterface
{
    public function open($savePath, $sessionName) {}
    public function close() {}
    public function read($sessionId) {}
    public function write($sessionId, $data) {}
    public function destroy($sessionId) {}
    public function gc($lifetime) {}
}
```
> [!NOTE]  
Laravel no viene con un directorio para contener tus extensiones. Puedes colocarlas donde desees. En este ejemplo, hemos creado un directorio `Extensions` para albergar el `MongoSessionHandler`.
Dado que el propósito de estos métodos no es fácilmente comprensible, cubriamos rápidamente qué hace cada uno de los métodos:
<div class="content-list" markdown="1">

- The `open` method would typically be used in file based session store systems. Since Laravel ships with a `file` session driver, you will rarely need to put anything in this method. You can simply leave this method empty.
- The `close` method, like the `open` method, can also usually be disregarded. For most drivers, it is not needed.
- The `read` method should return the string version of the session data associated with the given `$sessionId`. There is no need to do any serialization or other encoding when retrieving or storing session data in your driver, as Laravel will perform the serialization for you.
- The `write` method should write the given `$data` string associated with the `$sessionId` to some persistent storage system, such as MongoDB or another storage system of your choice.  Again, you should not perform any serialization - Laravel will have already handled that for you.
- The `destroy` method should remove the data associated with the `$sessionId` from persistent storage.
- The `gc` method should destroy all session data that is older than the given `$lifetime`, which is a UNIX timestamp. For self-expiring systems like Memcached and Redis, this method may be left empty.
</div>

<a name="registering-the-driver"></a>
### Registrando el Driver

Una vez que tu driver haya sido implementado, estás listo para registrarlo con Laravel. Para agregar drivers adicionales al backend de sesión de Laravel, puedes usar el método `extend` proporcionado por la [facade](/docs/%7B%7Bversion%7D%7D/facades) `Session`. Debes llamar al método `extend` desde el método `boot` de un [service provider](/docs/%7B%7Bversion%7D%7D/providers). Puedes hacer esto desde el existente `App\Providers\AppServiceProvider` o crear un proveedor completamente nuevo:


```php
<?php

namespace App\Providers;

use App\Extensions\MongoSessionHandler;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\ServiceProvider;

class SessionServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // ...
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Session::extend('mongo', function (Application $app) {
            // Return an implementation of SessionHandlerInterface...
            return new MongoSessionHandler;
        });
    }
}
```
Una vez que el driver de sesión ha sido registrado, puedes especificar el driver `mongo` como el driver de sesión de tu aplicación utilizando la variable de entorno `SESSION_DRIVER` o dentro del archivo de configuración `config/session.php` de la aplicación.