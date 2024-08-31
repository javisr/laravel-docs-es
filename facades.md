# Facades

- [Introducción](#introduction)
- [Cuándo Utilizar Facades](#when-to-use-facades)
  - [Facades vs. Inyección de Dependencias](#facades-vs-dependency-injection)
  - [Facades vs. Funciones Helper](#facades-vs-helper-functions)
- [Cómo Funcionan las Facades](#how-facades-work)
- [Facades en Tiempo Real](#real-time-facades)
- [Referencia de la Clase Facade](#facade-class-reference)

<a name="introduction"></a>
## Introducción

A lo largo de la documentación de Laravel, verás ejemplos de código que interactúa con las características de Laravel a través de "facades". Las facades proporcionan una interfaz "estática" a las clases que están disponibles en el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de la aplicación. Laravel viene con muchas facades que proporcionan acceso a casi todas las características de Laravel.
Las facades de Laravel sirven como "proxies estáticos" a las clases subyacentes en el contenedor de servicios, proporcionando el beneficio de una sintaxis concisa y expresiva mientras mantienen más capacidad de prueba y flexibilidad que los métodos estáticos tradicionales. Está perfectamente bien si no entiendes completamente cómo funcionan las facades: simplemente sigue el flujo y continúa aprendiendo sobre Laravel.
Todas las facades de Laravel están definidas en el espacio de nombres `Illuminate\Support\Facades`. Así que, podemos acceder a una facade de la siguiente manera:


```php
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Route;

Route::get('/cache', function () {
    return Cache::get('key');
});
```
A lo largo de la documentación de Laravel, muchos de los ejemplos utilizarán facades para demostrar varias características del framework.

<a name="helper-functions"></a>
#### Funciones Auxiliares

Para complementar las facades, Laravel ofrece una variedad de "funciones auxiliares" globales que facilitan aún más la interacción con las características comunes de Laravel. Algunas de las funciones auxiliares comunes con las que puedes interactuar son `view`, `response`, `url`, `config` y más. Cada función auxiliar ofrecida por Laravel está documentada con su característica correspondiente; sin embargo, una lista completa está disponible dentro de la [documentación auxiliar](/docs/%7B%7Bversion%7D%7D/helpers) dedicada.
Por ejemplo, en lugar de utilizar la fachada `Illuminate\Support\Facades\Response` para generar una respuesta JSON, podemos simplemente usar la función `response`. Dado que las funciones auxiliares están disponibles globalmente, no necesitas importar ninguna clase para usarlas:


```php
use Illuminate\Support\Facades\Response;

Route::get('/users', function () {
    return Response::json([
        // ...
    ]);
});

Route::get('/users', function () {
    return response()->json([
        // ...
    ]);
});
```

<a name="when-to-use-facades"></a>
## Cuándo Utilizar Facades

Las facades tienen muchos beneficios. Proporcionan una sintaxis breve y memorable que te permite usar las características de Laravel sin recordar largos nombres de clase que deben ser inyectados o configurados manualmente. Además, debido a su uso único de los métodos dinámicos de PHP, son fáciles de probar.
Sin embargo, se debe tener cuidado al usar **facades**. El peligro principal de las **facades** es el "scope creep" de la clase. Dado que las **facades** son tan fáciles de usar y no requieren inyección, puede ser fácil dejar que tus clases continúen creciendo y utilicen muchas **facades** en una sola clase. Al usar inyección de dependencias, este potencial se mitiga gracias al feedback visual que te da un constructor grande, indicando que tu clase está creciendo demasiado. Así que, al usar **facades**, presta especial atención al tamaño de tu clase para que su alcance de responsabilidad se mantenga estrecho. Si tu clase está creciendo demasiado, considera dividirla en múltiples clases más pequeñas.

<a name="facades-vs-dependency-injection"></a>
### Facades vs. Inyección de Dependencias

Uno de los principales beneficios de la inyección de dependencias es la capacidad de intercambiar implementaciones de la clase inyectada. Esto es útil durante las pruebas, ya que puedes inyectar un mock o un stub y afirmar que se llamaron varios métodos en el stub.
Típicamente, no sería posible simular o sustituir un método de clase estático realmente. Sin embargo, dado que las facades utilizan métodos dinámicos para enviar llamadas a métodos a objetos resueltos del contenedor de servicios, en realidad podemos probar facades justo como probaríamos una instancia de clase inyectada. Por ejemplo, dada la siguiente ruta:


```php
use Illuminate\Support\Facades\Cache;

Route::get('/cache', function () {
    return Cache::get('key');
});
```
Usando los métodos de prueba de la fachada de Laravel, podemos escribir la siguiente prueba para verificar que se llamó al método `Cache::get` con el argumento que esperábamos:


```php
use Illuminate\Support\Facades\Cache;

test('basic example', function () {
    Cache::shouldReceive('get')
         ->with('key')
         ->andReturn('value');

    $response = $this->get('/cache');

    $response->assertSee('value');
});

```


```php
use Illuminate\Support\Facades\Cache;

/**
 * A basic functional test example.
 */
public function test_basic_example(): void
{
    Cache::shouldReceive('get')
         ->with('key')
         ->andReturn('value');

    $response = $this->get('/cache');

    $response->assertSee('value');
}

```

<a name="facades-vs-helper-functions"></a>
### Facades vs. Funciones Helper

Además de las facades, Laravel incluye una variedad de funciones "helper" que pueden realizar tareas comunes como generar vistas, disparar eventos, despachar trabajos o enviar respuestas HTTP. Muchas de estas funciones helper realizan la misma función que una facade correspondiente. Por ejemplo, esta llamada de facade y llamada de helper son equivalentes:


```php
return Illuminate\Support\Facades\View::make('profile');

return view('profile');
```
No hay absolutamente ninguna diferencia práctica entre las facades y las funciones helper. Al utilizar funciones helper, aún puedes probarlas exactamente como lo harías con la facade correspondiente. Por ejemplo, dada la siguiente ruta:


```php
Route::get('/cache', function () {
    return cache('key');
});
```
El helper `cache` va a llamar al método `get` en la clase subyacente a la fachada `Cache`. Así que, aunque estamos utilizando la función helper, podemos escribir la siguiente prueba para verificar que el método fue llamado con el argumento que esperábamos:


```php
use Illuminate\Support\Facades\Cache;

/**
 * A basic functional test example.
 */
public function test_basic_example(): void
{
    Cache::shouldReceive('get')
         ->with('key')
         ->andReturn('value');

    $response = $this->get('/cache');

    $response->assertSee('value');
}
```

<a name="how-facades-work"></a>
## Cómo Funciona el Facade

En una aplicación Laravel, una fachada es una clase que proporciona acceso a un objeto desde el contenedor. La maquinaria que hace que esto funcione está en la clase `Facade`. Las fachadas de Laravel, y cualquier fachada personalizada que crees, extenderán la clase base `Illuminate\Support\Facades\Facade`.
La clase base `Facade` utiliza el método mágico `__callStatic()` para delegar llamadas desde tu fachada a un objeto resuelto del contenedor. En el ejemplo a continuación, se realiza una llamada al sistema de caché de Laravel. Al mirar este código, uno podría asumir que se está llamando al método estático `get` en la clase `Cache`:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Cache;
use Illuminate\View\View;

class UserController extends Controller
{
    /**
     * Show the profile for the given user.
     */
    public function showProfile(string $id): View
    {
        $user = Cache::get('user:'.$id);

        return view('profile', ['user' => $user]);
    }
}
```
Nota que cerca de la parte superior del archivo estamos "importando" la facade `Cache`. Este facade sirve como un proxy para acceder a la implementación subyacente de la interfaz `Illuminate\Contracts\Cache\Factory`. Cualquier llamada que hagamos utilizando el facade será pasada a la instancia subyacente del servicio de caché de Laravel.
Si miramos esa clase `Illuminate\Support\Facades\Cache`, verás que no hay un método estático `get`:


```php
class Cache extends Facade
{
    /**
     * Get the registered name of the component.
     */
    protected static function getFacadeAccessor(): string
    {
        return 'cache';
    }
}
```
En su lugar, la `facade` `Cache` extiende la clase base `Facade` y define el método `getFacadeAccessor()`. La función de este método es devolver el nombre de un enlace del contenedor de servicios. Cuando un usuario hace referencia a cualquier método estático en la `facade` `Cache`, Laravel resuelve el enlace `cache` del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) y ejecuta el método solicitado (en este caso, `get`) contra ese objeto.

<a name="real-time-facades"></a>
## Facades en Tiempo Real

Usando facades en tiempo real, puedes tratar cualquier clase en tu aplicación como si fuera una facade. Para ilustrar cómo se puede usar esto, primero examinemos un código que no utiliza facades en tiempo real. Por ejemplo, supongamos que nuestro modelo `Podcast` tiene un método `publish`. Sin embargo, para publicar el podcast, necesitamos inyectar una instancia de `Publisher`:


```php
<?php

namespace App\Models;

use App\Contracts\Publisher;
use Illuminate\Database\Eloquent\Model;

class Podcast extends Model
{
    /**
     * Publish the podcast.
     */
    public function publish(Publisher $publisher): void
    {
        $this->update(['publishing' => now()]);

        $publisher->publish($this);
    }
}
```
Inyectar una implementación de editor en el método nos permite probar fácilmente el método de forma aislada, ya que podemos simular el editor inyectado. Sin embargo, esto requiere que siempre pasemos una instancia del editor cada vez que llamamos al método `publish`. Al usar facades en tiempo real, podemos mantener la misma capacidad de prueba sin necesidad de pasar explícitamente una instancia de `Publisher`. Para generar una facade en tiempo real, añade el prefijo `Facades` al espacio de nombres de la clase importada:


```
<?php

namespace App\Models;

use App\Contracts\Publisher; // [tl! remove]
use Facades\App\Contracts\Publisher; // [tl! add]
use Illuminate\Database\Eloquent\Model;

class Podcast extends Model
{
    /**
     * Publish the podcast.
     */
    public function publish(Publisher $publisher): void // [tl! remove]
    public function publish(): void // [tl! add]
    {
        $this->update(['publishing' => now()]);

        $publisher->publish($this); // [tl! remove]
        Publisher::publish($this); // [tl! add]
    }
}
```
Cuando se utiliza la fachada en tiempo real, la implementación del publicador se resolverá a partir del contenedor de servicios utilizando la porción del nombre de la interfaz o de la clase que aparece después del prefijo `Facades`. Al realizar pruebas, podemos usar los helpers de prueba de fachada integrados de Laravel para simular esta llamada al método:


```php
<?php

use App\Models\Podcast;
use Facades\App\Contracts\Publisher;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('podcast can be published', function () {
    $podcast = Podcast::factory()->create();

    Publisher::shouldReceive('publish')->once()->with($podcast);

    $podcast->publish();
});

```


```php
<?php

namespace Tests\Feature;

use App\Models\Podcast;
use Facades\App\Contracts\Publisher;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PodcastTest extends TestCase
{
    use RefreshDatabase;

    /**
     * A test example.
     */
    public function test_podcast_can_be_published(): void
    {
        $podcast = Podcast::factory()->create();

        Publisher::shouldReceive('publish')->once()->with($podcast);

        $podcast->publish();
    }
}

```

<a name="facade-class-reference"></a>
## Referencia de la Clase Facade

A continuación, encontrarás cada facade y su clase subyacente. Esta es una herramienta útil para profundizar rápidamente en la documentación de la API para una raíz de facade dada. La clave de [vinculación del contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) también se incluye donde sea aplicable.
<div class="overflow-auto">

| Facade | Clase | Vinculación del Contenedor de Servicios |
| --- | --- | --- |
| App | [Illuminate\Foundation\Application](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Foundation/Application.html) | `app` |
| Artisan | [Illuminate\Contracts\Console\Kernel](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Console/Kernel.html) | `artisan` |
| Auth (Instancia) | [Illuminate\Contracts\Auth\Guard](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Auth/Guard.html) | `auth.driver` |
| Auth | [Illuminate\Auth\AuthManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Auth/AuthManager.html) | `auth` |
| Blade | [Illuminate\View\Compilers\BladeCompiler](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/View/Compilers/BladeCompiler.html) | `blade.compiler` |
| Broadcast (Instancia) | [Illuminate\Contracts\Broadcasting\Broadcaster](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Broadcasting/Broadcaster.html) |   |
| Broadcast | [Illuminate\Contracts\Broadcasting\Factory](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Broadcasting/Factory.html) |   |
| Bus | [Illuminate\Contracts\Bus\Dispatcher](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Bus/Dispatcher.html) |   |
| Cache (Instancia) | [Illuminate\Cache\Repository](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Cache/Repository.html) | `cache.store` |
| Cache | [Illuminate\Cache\CacheManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Cache/CacheManager.html) | `cache` |
| Config | [Illuminate\Config\Repository](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Config/Repository.html) | `config` |
| Context | [Illuminate\Log\Context\Repository](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Log/Context/Repository.html) |   |
| Cookie | [Illuminate\Cookie\CookieJar](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Cookie/CookieJar.html) | `cookie` |
| Crypt | [Illuminate\Encryption\Encrypter](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Encryption/Encrypter.html) | `encrypter` |
| Date | [Illuminate\Support\DateFactory](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Support/DateFactory.html) | `date` |
| DB (Instancia) | [Illuminate\Database\Connection](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Database/Connection.html) | `db.connection` |
| DB | [Illuminate\Database\DatabaseManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Database/DatabaseManager.html) | `db` |
| Event | [Illuminate\Events\Dispatcher](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Events/Dispatcher.html) | `events` |
| Exceptions (Instancia) | [Illuminate\Contracts\Debug\ExceptionHandler](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Debug/ExceptionHandler.html) |   |
| Exceptions | [Illuminate\Foundation\Exceptions\Handler](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Foundation/Exceptions/Handler.html) |   |
| File | [Illuminate\Filesystem\Filesystem](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Filesystem/Filesystem.html) | `files` |
| Gate | [Illuminate\Contracts\Auth\Access\Gate](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Auth/Access/Gate.html) |   |
| Hash | [Illuminate\Contracts\Hashing\Hasher](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Hashing/Hasher.html) | `hash` |
| Http | [Illuminate\Http\Client\Factory](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Http/Client/Factory.html) |   |
| Lang | [Illuminate\Translation\Translator](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Translation/Translator.html) | `translator` |
| Log | [Illuminate\Log\LogManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Log/LogManager.html) | `log` |
| Mail | [Illuminate\Mail\Mailer](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Mail/Mailer.html) | `mailer` |
| Notification | [Illuminate\Notifications\ChannelManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Notifications/ChannelManager.html) |   |
| Password (Instancia) | [Illuminate\Auth\Passwords\PasswordBroker](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Auth/Passwords/PasswordBroker.html) | `auth.password.broker` |
| Password | [Illuminate\Auth\Passwords\PasswordBrokerManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Auth/Passwords/PasswordBrokerManager.html) | `auth.password` |
| Pipeline (Instancia) | [Illuminate\Pipeline\Pipeline](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Pipeline/Pipeline.html) |   |
| Process | [Illuminate\Process\Factory](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Process/Factory.html) |   |
| Queue (Clase Base) | [Illuminate\Queue\Queue](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Queue/Queue.html) |   |
| Queue (Instancia) | [Illuminate\Contracts\Queue\Queue](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Queue/Queue.html) | `queue.connection` |
| Queue | [Illuminate\Queue\QueueManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Queue/QueueManager.html) | `queue` |
| RateLimiter | [Illuminate\Cache\RateLimiter](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Cache/RateLimiter.html) |   |
| Redirect | [Illuminate\Routing\Redirector](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Routing/Redirector.html) | `redirect` |
| Redis (Instancia) | [Illuminate\Redis\Connections\Connection](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Redis/Connections/Connection.html) | `redis.connection` |
| Redis | [Illuminate\Redis\RedisManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Redis/RedisManager.html) | `redis` |
| Request | [Illuminate\Http\Request](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Http/Request.html) | `request` |
| Response (Instancia) | [Illuminate\Http\Response](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Http/Response.html) |   |
| Response | [Illuminate\Contracts\Routing\ResponseFactory](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Routing/ResponseFactory.html) |   |
| Route | [Illuminate\Routing\Router](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Routing/Router.html) | `router` |
| Schedule | [Illuminate\Console\Scheduling\Schedule](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Console/Scheduling/Schedule.html) |   |
| Schema | [Illuminate\Database\Schema\Builder](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Database/Schema/Builder.html) |   |
| Session (Instancia) | [Illuminate\Session\Store](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Session/Store.html) | `session.store` |
| Session | [Illuminate\Session\SessionManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Session/SessionManager.html) | `session` |
| Storage (Instancia) | [Illuminate\Contracts\Filesystem\Filesystem](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Contracts/Filesystem/Filesystem.html) | `filesystem.disk` |
| Storage | [Illuminate\Filesystem\FilesystemManager](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Filesystem/FilesystemManager.html) | `filesystem` |
| URL | [Illuminate\Routing\UrlGenerator](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Routing/UrlGenerator.html) | `url` |
| Validator (Instancia) | [Illuminate\Validation\Validator](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Validation/Validator.html) |   |
| Validator | [Illuminate\Validation\Factory](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Validation/Factory.html) | `validator` |
| View (Instancia) | [Illuminate\View\View](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/View/View.html) |   |
| View | [Illuminate\View\Factory](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/View/Factory.html) | `view` |
| Vite | [Illuminate\Foundation\Vite](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Foundation/Vite.html) |   |
</div>