# Facades

- [Introducción](#introduction)
- [Cuándo Utilizar Facades](#when-to-use-facades)
    - [Facades vs. Inyección de Dependencias](#facades-vs-dependency-injection)
    - [Facades vs. Funciones de Ayuda](#facades-vs-helper-functions)
- [Cómo Funcionan las Facades](#how-facades-work)
- [Facades en Tiempo Real](#real-time-facades)
- [Referencia de Clases de Facade](#facade-class-reference)

<a name="introduction"></a>
## Introducción

A lo largo de la documentación de Laravel, verás ejemplos de código que interactúan con las características de Laravel a través de "facades". Las facades proporcionan una interfaz "estática" a las clases que están disponibles en el [contenedor de servicios](/docs/{{version}}/container) de la aplicación. Laravel incluye muchas facades que proporcionan acceso a casi todas las características de Laravel.

Las facades de Laravel sirven como "proxies estáticos" para las clases subyacentes en el contenedor de servicios, proporcionando el beneficio de una sintaxis concisa y expresiva mientras mantienen más capacidad de prueba y flexibilidad que los métodos estáticos tradicionales. Está perfectamente bien si no entiendes completamente cómo funcionan las facades; simplemente sigue el flujo y continúa aprendiendo sobre Laravel.

Todas las facades de Laravel están definidas en el espacio de nombres `Illuminate\Support\Facades`. Así que, podemos acceder fácilmente a una facade de la siguiente manera:

    use Illuminate\Support\Facades\Cache;
    use Illuminate\Support\Facades\Route;

    Route::get('/cache', function () {
        return Cache::get('key');
    });

A lo largo de la documentación de Laravel, muchos de los ejemplos utilizarán facades para demostrar varias características del framework.

<a name="helper-functions"></a>
#### Funciones de Ayuda

Para complementar las facades, Laravel ofrece una variedad de "funciones de ayuda" globales que facilitan aún más la interacción con las características comunes de Laravel. Algunas de las funciones de ayuda comunes con las que puedes interactuar son `view`, `response`, `url`, `config`, y más. Cada función de ayuda ofrecida por Laravel está documentada con su característica correspondiente; sin embargo, una lista completa está disponible dentro de la [documentación de ayuda](/docs/{{version}}/helpers).

Por ejemplo, en lugar de usar la facade `Illuminate\Support\Facades\Response` para generar una respuesta JSON, simplemente podemos usar la función `response`. Dado que las funciones de ayuda están disponibles globalmente, no necesitas importar ninguna clase para usarlas:

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

<a name="when-to-use-facades"></a>
## Cuándo Utilizar Facades

Las facades tienen muchos beneficios. Proporcionan una sintaxis concisa y memorable que te permite usar las características de Laravel sin recordar largos nombres de clases que deben ser inyectados o configurados manualmente. Además, debido a su uso único de los métodos dinámicos de PHP, son fáciles de probar.

Sin embargo, se debe tener cuidado al usar facades. El principal peligro de las facades es la "expansión del alcance" de la clase. Dado que las facades son tan fáciles de usar y no requieren inyección, puede ser fácil dejar que tus clases continúen creciendo y usen muchas facades en una sola clase. Usando inyección de dependencias, este potencial se mitiga por la retroalimentación visual que un constructor grande te da de que tu clase está creciendo demasiado. Así que, al usar facades, presta especial atención al tamaño de tu clase para que su alcance de responsabilidad se mantenga estrecho. Si tu clase está creciendo demasiado, considera dividirla en varias clases más pequeñas.

<a name="facades-vs-dependency-injection"></a>
### Facades vs. Inyección de Dependencias

Uno de los principales beneficios de la inyección de dependencias es la capacidad de intercambiar implementaciones de la clase inyectada. Esto es útil durante las pruebas, ya que puedes inyectar un mock o stub y afirmar que se llamaron varios métodos en el stub.

Típicamente, no sería posible simular o stubear un método de clase estática verdadero. Sin embargo, dado que las facades utilizan métodos dinámicos para hacer proxy de las llamadas a métodos a objetos resueltos del contenedor de servicios, en realidad podemos probar las facades de la misma manera que probaríamos una instancia de clase inyectada. Por ejemplo, dada la siguiente ruta:

    use Illuminate\Support\Facades\Cache;

    Route::get('/cache', function () {
        return Cache::get('key');
    });

Usando los métodos de prueba de facades de Laravel, podemos escribir la siguiente prueba para verificar que el método `Cache::get` fue llamado con el argumento que esperábamos:

```php tab=Pest
use Illuminate\Support\Facades\Cache;

test('basic example', function () {
    Cache::shouldReceive('get')
         ->with('key')
         ->andReturn('value');

    $response = $this->get('/cache');

    $response->assertSee('value');
});
```

```php tab=PHPUnit
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
### Facades vs. Funciones de Ayuda

Además de las facades, Laravel incluye una variedad de funciones de "ayuda" que pueden realizar tareas comunes como generar vistas, disparar eventos, despachar trabajos o enviar respuestas HTTP. Muchas de estas funciones de ayuda realizan la misma función que una facade correspondiente. Por ejemplo, esta llamada a la facade y la llamada a la función de ayuda son equivalentes:

    return Illuminate\Support\Facades\View::make('profile');

    return view('profile');

No hay absolutamente ninguna diferencia práctica entre las facades y las funciones de ayuda. Al usar funciones de ayuda, aún puedes probarlas exactamente como lo harías con la facade correspondiente. Por ejemplo, dada la siguiente ruta:

    Route::get('/cache', function () {
        return cache('key');
    });

La función de ayuda `cache` va a llamar al método `get` en la clase subyacente a la facade `Cache`. Así que, aunque estamos usando la función de ayuda, podemos escribir la siguiente prueba para verificar que el método fue llamado con el argumento que esperábamos:

    use Illuminate\Support\Facades\Cache;

    /**
     * Un ejemplo básico de prueba funcional.
     */
    public function test_basic_example(): void
    {
        Cache::shouldReceive('get')
             ->with('key')
             ->andReturn('value');

        $response = $this->get('/cache');

        $response->assertSee('value');
    }

<a name="how-facades-work"></a>
## Cómo Funcionan las Facades

En una aplicación Laravel, una facade es una clase que proporciona acceso a un objeto del contenedor. La maquinaria que hace que esto funcione está en la clase `Facade`. Las facades de Laravel, y cualquier facade personalizada que crees, extenderán la clase base `Illuminate\Support\Facades\Facade`.

La clase base `Facade` utiliza el método mágico `__callStatic()` para diferir las llamadas de tu facade a un objeto resuelto del contenedor. En el ejemplo a continuación, se hace una llamada al sistema de caché de Laravel. Al mirar este código, uno podría asumir que se está llamando al método estático `get` en la clase `Cache`:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Support\Facades\Cache;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * Mostrar el perfil del usuario dado.
         */
        public function showProfile(string $id): View
        {
            $user = Cache::get('user:'.$id);

            return view('profile', ['user' => $user]);
        }
    }

Nota que cerca de la parte superior del archivo estamos "importando" la facade `Cache`. Esta facade sirve como un proxy para acceder a la implementación subyacente de la interfaz `Illuminate\Contracts\Cache\Factory`. Cualquier llamada que hagamos usando la facade será pasada a la instancia subyacente del servicio de caché de Laravel.

Si miramos la clase `Illuminate\Support\Facades\Cache`, verás que no hay un método estático `get`:

    class Cache extends Facade
    {
        /**
         * Obtener el nombre registrado del componente.
         */
        protected static function getFacadeAccessor(): string
        {
            return 'cache';
        }
    }

En cambio, la facade `Cache` extiende la clase base `Facade` y define el método `getFacadeAccessor()`. La tarea de este método es devolver el nombre de un enlace del contenedor de servicios. Cuando un usuario hace referencia a cualquier método estático en la facade `Cache`, Laravel resuelve el enlace `cache` del [contenedor de servicios](/docs/{{version}}/container) y ejecuta el método solicitado (en este caso, `get`) contra ese objeto.

<a name="real-time-facades"></a>
## Facades en Tiempo Real

Usando facades en tiempo real, puedes tratar cualquier clase en tu aplicación como si fuera una facade. Para ilustrar cómo se puede usar esto, primero examinemos un código que no utiliza facades en tiempo real. Por ejemplo, supongamos que nuestro modelo `Podcast` tiene un método `publish`. Sin embargo, para publicar el podcast, necesitamos inyectar una instancia de `Publisher`:

    <?php

    namespace App\Models;

    use App\Contracts\Publisher;
    use Illuminate\Database\Eloquent\Model;

    class Podcast extends Model
    {
        /**
         * Publicar el podcast.
         */
        public function publish(Publisher $publisher): void
        {
            $this->update(['publishing' => now()]);

            $publisher->publish($this);
        }
    }

Inyectar una implementación de publisher en el método nos permite probar fácilmente el método de forma aislada, ya que podemos simular el publisher inyectado. Sin embargo, requiere que siempre pasemos una instancia de publisher cada vez que llamamos al método `publish`. Usando facades en tiempo real, podemos mantener la misma capacidad de prueba sin necesidad de pasar explícitamente una instancia de `Publisher`. Para generar una facade en tiempo real, prefija el espacio de nombres de la clase importada con `Facades`:

    <?php

    namespace App\Models;

    use App\Contracts\Publisher; // [tl! remove]
    use Facades\App\Contracts\Publisher; // [tl! add]
    use Illuminate\Database\Eloquent\Model;

    class Podcast extends Model
    {
        /**
         * Publicar el podcast.
         */
        public function publish(Publisher $publisher): void // [tl! remove]
        public function publish(): void // [tl! add]
        {
            $this->update(['publishing' => now()]);

            $publisher->publish($this); // [tl! remove]
            Publisher::publish($this); // [tl! add]
        }
    }

Cuando se utiliza la facade en tiempo real, la implementación del publisher se resolverá del contenedor de servicios utilizando la parte del nombre de la interfaz o clase que aparece después del prefijo `Facades`. Al probar, podemos usar los ayudantes de prueba de facade integrados de Laravel para simular esta llamada al método:

```php tab=Pest
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

```php tab=PHPUnit
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
## Referencia de Clases de Facade

A continuación, encontrarás cada facade y su clase subyacente. Esta es una herramienta útil para profundizar rápidamente en la documentación de la API para una raíz de facade dada. La clave de [vinculación del contenedor de servicios](/docs/{{version}}/container) también se incluye donde sea aplicable.

<div class="overflow-auto">

| Facade | Clase | Vinculación del Contenedor de Servicios |
| --- | --- | --- |
| App | [Illuminate\Foundation\Application](https://laravel.com/api/{{version}}/Illuminate/Foundation/Application.html) | `app` |
| Artisan | [Illuminate\Contracts\Console\Kernel](https://laravel.com/api/{{version}}/Illuminate/Contracts/Console/Kernel.html) | `artisan` |
| Auth (Instancia) | [Illuminate\Contracts\Auth\Guard](https://laravel.com/api/{{version}}/Illuminate/Contracts/Auth/Guard.html) | `auth.driver` |
| Auth | [Illuminate\Auth\AuthManager](https://laravel.com/api/{{version}}/Illuminate/Auth/AuthManager.html) | `auth` |
| Blade | [Illuminate\View\Compilers\BladeCompiler](https://laravel.com/api/{{version}}/Illuminate/View/Compilers/BladeCompiler.html) | `blade.compiler` |
| Broadcast (Instancia) | [Illuminate\Contracts\Broadcasting\Broadcaster](https://laravel.com/api/{{version}}/Illuminate/Contracts/Broadcasting/Broadcaster.html) | &nbsp; |
| Broadcast | [Illuminate\Contracts\Broadcasting\Factory](https://laravel.com/api/{{version}}/Illuminate/Contracts/Broadcasting/Factory.html) | &nbsp; |
| Bus | [Illuminate\Contracts\Bus\Dispatcher](https://laravel.com/api/{{version}}/Illuminate/Contracts/Bus/Dispatcher.html) | &nbsp; |
| Cache (Instancia) | [Illuminate\Cache\Repository](https://laravel.com/api/{{version}}/Illuminate/Cache/Repository.html) | `cache.store` |
| Cache | [Illuminate\Cache\CacheManager](https://laravel.com/api/{{version}}/Illuminate/Cache/CacheManager.html) | `cache` |
| Config | [Illuminate\Config\Repository](https://laravel.com/api/{{version}}/Illuminate/Config/Repository.html) | `config` |
| Cookie | [Illuminate\Cookie\CookieJar](https://laravel.com/api/{{version}}/Illuminate/Cookie/CookieJar.html) | `cookie` |
| Crypt | [Illuminate\Encryption\Encrypter](https://laravel.com/api/{{version}}/Illuminate/Encryption/Encrypter.html) | `encrypter` |
| Date | [Illuminate\Support\DateFactory](https://laravel.com/api/{{version}}/Illuminate/Support/DateFactory.html) | `date` |
| DB (Instancia) | [Illuminate\Database\Connection](https://laravel.com/api/{{version}}/Illuminate/Database/Connection.html) | `db.connection` |
| DB | [Illuminate\Database\DatabaseManager](https://laravel.com/api/{{version}}/Illuminate/Database/DatabaseManager.html) | `db` |
| Event | [Illuminate\Events\Dispatcher](https://laravel.com/api/{{version}}/Illuminate/Events/Dispatcher.html) | `events` |
| Exceptions (Instancia) | [Illuminate\Contracts\Debug\ExceptionHandler](https://laravel.com/api/{{version}}/Illuminate/Contracts/Debug/ExceptionHandler.html) | &nbsp; |
| Exceptions | [Illuminate\Foundation\Exceptions\Handler](https://laravel.com/api/{{version}}/Illuminate/Foundation/Exceptions/Handler.html) | &nbsp; |
| File | [Illuminate\Filesystem\Filesystem](https://laravel.com/api/{{version}}/Illuminate/Filesystem/Filesystem.html) | `files` |
| Gate | [Illuminate\Contracts\Auth\Access\Gate](https://laravel.com/api/{{version}}/Illuminate/Contracts/Auth/Access/Gate.html) | &nbsp; |
| Hash | [Illuminate\Contracts\Hashing\Hasher](https://laravel.com/api/{{version}}/Illuminate/Contracts/Hashing/Hasher.html) | `hash` |
| Http | [Illuminate\Http\Client\Factory](https://laravel.com/api/{{version}}/Illuminate/Http/Client/Factory.html) | &nbsp; |
| Lang | [Illuminate\Translation\Translator](https://laravel.com/api/{{version}}/Illuminate/Translation/Translator.html) | `translator` |
| Log | [Illuminate\Log\LogManager](https://laravel.com/api/{{version}}/Illuminate/Log/LogManager.html) | `log` |
| Mail | [Illuminate\Mail\Mailer](https://laravel.com/api/{{version}}/Illuminate/Mail/Mailer.html) | `mailer` |
| Notification | [Illuminate\Notifications\ChannelManager](https://laravel.com/api/{{version}}/Illuminate/Notifications/ChannelManager.html) | &nbsp; |
| Password (Instancia) | [Illuminate\Auth\Passwords\PasswordBroker](https://laravel.com/api/{{version}}/Illuminate/Auth/Passwords/PasswordBroker.html) | `auth.password.broker` |
| Password | [Illuminate\Auth\Passwords\PasswordBrokerManager](https://laravel.com/api/{{version}}/Illuminate/Auth/Passwords/PasswordBrokerManager.html) | `auth.password` |
| Pipeline (Instancia) | [Illuminate\Pipeline\Pipeline](https://laravel.com/api/{{version}}/Illuminate/Pipeline/Pipeline.html) | &nbsp; |
| Process | [Illuminate\Process\Factory](https://laravel.com/api/{{version}}/Illuminate/Process/Factory.html) | &nbsp; |
| Queue (Clase Base) | [Illuminate\Queue\Queue](https://laravel.com/api/{{version}}/Illuminate/Queue/Queue.html) | &nbsp; |
| Queue (Instancia) | [Illuminate\Contracts\Queue\Queue](https://laravel.com/api/{{version}}/Illuminate/Contracts/Queue/Queue.html) | `queue.connection` |
| Queue | [Illuminate\Queue\QueueManager](https://laravel.com/api/{{version}}/Illuminate/Queue/QueueManager.html) | `queue` |
| RateLimiter | [Illuminate\Cache\RateLimiter](https://laravel.com/api/{{version}}/Illuminate/Cache/RateLimiter.html) | &nbsp; |
| Redirect | [Illuminate\Routing\Redirector](https://laravel.com/api/{{version}}/Illuminate/Routing/Redirector.html) | `redirect` |
| Redis (Instancia) | [Illuminate\Redis\Connections\Connection](https://laravel.com/api/{{version}}/Illuminate/Redis/Connections/Connection.html) | `redis.connection` |
| Redis | [Illuminate\Redis\RedisManager](https://laravel.com/api/{{version}}/Illuminate/Redis/RedisManager.html) | `redis` |
| Request | [Illuminate\Http\Request](https://laravel.com/api/{{version}}/Illuminate/Http/Request.html) | `request` |
| Response (Instancia) | [Illuminate\Http\Response](https://laravel.com/api/{{version}}/Illuminate/Http/Response.html) | &nbsp; |
| Response | [Illuminate\Contracts\Routing\ResponseFactory](https://laravel.com/api/{{version}}/Illuminate/Contracts/Routing/ResponseFactory.html) | &nbsp; |
| Route | [Illuminate\Routing\Router](https://laravel.com/api/{{version}}/Illuminate/Routing/Router.html) | `router` |
| Schedule | [Illuminate\Console\Scheduling\Schedule](https://laravel.com/api/{{version}}/Illuminate/Console/Scheduling/Schedule.html) | &nbsp; |
| Schema | [Illuminate\Database\Schema\Builder](https://laravel.com/api/{{version}}/Illuminate/Database/Schema/Builder.html) | &nbsp; |
| Session (Instancia) | [Illuminate\Session\Store](https://laravel.com/api/{{version}}/Illuminate/Session/Store.html) | `session.store` |
| Session | [Illuminate\Session\SessionManager](https://laravel.com/api/{{version}}/Illuminate/Session/SessionManager.html) | `session` |
| Storage (Instancia) | [Illuminate\Contracts\Filesystem\Filesystem](https://laravel.com/api/{{version}}/Illuminate/Contracts/Filesystem/Filesystem.html) | `filesystem.disk` |
| Storage | [Illuminate\Filesystem\FilesystemManager](https://laravel.com/api/{{version}}/Illuminate/Filesystem/FilesystemManager.html) | `filesystem` |
| URL | [Illuminate\Routing\UrlGenerator](https://laravel.com/api/{{version}}/Illuminate/Routing/UrlGenerator.html) | `url` |
| Validator (Instancia) | [Illuminate\Validation\Validator](https://laravel.com/api/{{version}}/Illuminate/Validation/Validator.html) | &nbsp; |
| Validator | [Illuminate\Validation\Factory](https://laravel.com/api/{{version}}/Illuminate/Validation/Factory.html) | `validator` |
| View (Instancia) | [Illuminate\View\View](https://laravel.com/api/{{version}}/Illuminate/View/View.html) | &nbsp; |
| View | [Illuminate\View\Factory](https://laravel.com/api/{{version}}/Illuminate/View/Factory.html) | `view` |
| Vite | [Illuminate\Foundation\Vite](https://laravel.com/api/{{version}}/Illuminate/Foundation/Vite.html) | &nbsp; |

No hay contenido para traducir. Por favor, proporciona el texto en Markdown que deseas traducir.
