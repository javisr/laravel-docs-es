# facades

- [Introduction](#introduction)
- [Cuándo utilizar facades](#when-to-use-facades)
    - [Facades vs. Inyección de dependencia](#facades-vs-dependency-injection)
    - [Facades vs. Funciones auxiliares](#facades-vs-helper-functions)
- [Cómo funcionan las facades](#how-facades-work)
- [Facades en Tiempo Real](#real-time-facades)
- [Referencia de la clase facade](#facade-class-reference)

<a name="introduction"></a>
## Introducción

A lo largo de la documentación de Laravel, verás ejemplos de código que interactúa con las características de Laravel a través de "facades". Las Facades proporcionan una interfaz "estática" a las clases que están disponibles en el [contenedor de servicios](/docs/{{version}}/container) de la aplicación. Laravel viene con muchas facades que proporcionan acceso a casi todas las características de Laravel.

Las facades de Laravel sirven como "proxies estáticos" a las clases subyacentes en el contenedor de servicios, proporcionando el beneficio de una sintaxis breve y expresiva, manteniendo al mismo tiempo una buena capacidad de testing y flexibilidad que los métodos estáticos tradicionales. No pasa nada si no entiendes del todo cómo funcionan facades, simplemente déjate llevar y sigue aprendiendo sobre Laravel.

Todas las facades de Laravel se definen en el espacio de nombres `Illuminate\Support\Facades`. Por lo tanto, podemos acceder fácilmente a una facade así:

    use Illuminate\Support\Facades\Cache;
    use Illuminate\Support\Facades\Route;

    Route::get('/cache', function () {
        return Cache::get('key');
    });

A lo largo de la documentación de Laravel, muchos de los ejemplos utilizarán facades para demostrar diversas características del framework.

<a name="helper-functions"></a>
#### Funciones auxiliares

Para complementar facades, Laravel ofrece una variedad de "funciones de ayuda" globales que hacen aún más fácil interactuar con las características comunes de Laravel. Algunas de las funciones helper comunes con las que puedes interactuar son `view`, `response`, `url` y `config`. Cada función helper ofrecida por Laravel está documentada con su característica correspondiente; sin embargo, una lista completa está disponible dentro de la [documentación](/docs/{{version}}/helpers) dedicada a [las funciones de ayuda](/docs/{{version}}/helpers).

Por ejemplo, en lugar de utilizar la facade `Illuminate\Support\Facades\Response` para generar una respuesta JSON, podemos simplemente utilizar la función `response`. Dado que las funciones de ayuda están disponibles globalmente, no es necesario importar ninguna clase para utilizarlas:

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
## Cuándo usar facades

Las facades tienen muchos beneficios. Proporcionan una sintaxis breve y fácil de recordar que permite utilizar las características de Laravel sin tener que recordar largos nombres de clases que deben ser inyectados o configurados manualmente. Además, debido a su uso único de los métodos dinámicos de PHP, son fáciles de probar.

Sin embargo, hay que tener cierto cuidado cuando se utilizan facades. El principal peligro de las facades es el "scope creep" de las clases. Dado que facades son tan fáciles de usar y no requieren inyección, puede ser fácil dejar que tus clases sigan creciendo y usar muchas facades en una sola clase. Usando inyección de dependencia, este potencial problema es mitigado por la retroalimentación visual que un constructor grande te da de que tu clase está creciendo demasiado. Así que, cuando uses facades, presta especial atención al tamaño de tu clase para que su ámbito de responsabilidad se mantenga pequeño. Si tu clase está creciendo demasiado, considera dividirla en múltiples clases más pequeñas.

<a name="facades-vs-dependency-injection"></a>
### Facades Vs. Inyección de Dependencia

Una de las principales ventajas de la inyección de dependencias es la posibilidad de intercambiar implementaciones de la clase inyectada. Esto es útil para los tests, ya que puede inyectar un mock o stub y afirmar que varios métodos fueron llamados en el stub.

Normalmente, no sería posible hacer un mock o stub de un método de clase realmente estático. Sin embargo, dado que facades adas utilizan métodos dinámicos para realizar llamadas a objetos resueltos desde el contenedor de servicios, podemos probar facades del mismo modo que probaríamos una instancia de clase inyectada. Por ejemplo, dada la siguiente ruta:

    use Illuminate\Support\Facades\Cache;

    Route::get('/cache', function () {
        return Cache::get('key');
    });

Usando los métodos de testing de facade de Laravel, podemos escribir el siguiente test para verificar que el método `Cache::get` fue llamado con el argumento que esperábamos:

    use Illuminate\Support\Facades\Cache;

    /**
     * A basic functional test example.
     *
     * @return void
     */
    public function testBasicExample()
    {
        Cache::shouldReceive('get')
             ->with('key')
             ->andReturn('value');

        $response = $this->get('/cache');

        $response->assertSee('value');
    }

<a name="facades-vs-helper-functions"></a>
### facades vs. Funciones auxiliares

Además de las facades, Laravel incluye una variedad de funciones "helper" que pueden realizar tareas comunes como generar vistas, disparar eventos, despachar trabajos o enviar respuestas HTTP. Muchas de estas funciones de ayuda realizan la misma función que la facade correspondiente. Por ejemplo, esta llamada a facade y esta llamada a un helper son equivalentes:

    return Illuminate\Support\Facades\View::make('profile');

    return view('profile');

No hay absolutamente ninguna diferencia práctica entre las facades y las funciones helper. Cuando utilices funciones helper, puedes probarlas exactamente igual que harías con la facade correspondiente. Por ejemplo, dada la siguiente ruta:

    Route::get('/cache', function () {
        return cache('key');
    });

El función de ayuda `cache` va a llamar al método `get` de la clase subyacente a la facade `Cache`. Así que, aunque estemos utilizando la función helper, podemos escribir el siguiente test para verificar que el método fue llamado con el argumento que esperábamos:

    use Illuminate\Support\Facades\Cache;

    /**
     * A basic functional test example.
     *
     * @return void
     */
    public function testBasicExample()
    {
        Cache::shouldReceive('get')
             ->with('key')
             ->andReturn('value');

        $response = $this->get('/cache');

        $response->assertSee('value');
    }

<a name="how-facades-work"></a>
## Cómo Funcionan las Facades

En una aplicación Laravel, una facade es una clase que proporciona acceso a un objeto desde el contenedor. La maquinaria que hace que esto funcione está en la clase `Facade`. Las facades de Laravel, y cualquier facades personalizada que crees, extenderán la clase base `Illuminate\Support\Facades\Facade`.

La clase base de la `Facade` hace uso del método mágico `__callStatic()` para diferir las llamadas de su facade a un objeto resuelto desde el contenedor. En el siguiente ejemplo, se realiza una llamada al sistema de cache de Laravel. Echando un vistazo a este código, se podría suponer que se está llamando al método estático `get` de la clase `Cache`:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Support\Facades\Cache;

    class UserController extends Controller
    {
        /**
         * Show the profile for the given user.
         *
         * @param  int  $id
         * @return Response
         */
        public function showProfile($id)
        {
            $user = Cache::get('user:'.$id);

            return view('profile', ['user' => $user]);
        }
    }

Observa que cerca de la parte superior del archivo, estamos "importando" la facade `Cache`. Esta facade sirve como un proxy para acceder a la implementación subyacente de la interfaz `Illuminate\Contracts\Cache\Factory`. Cualquier llamada que hagamos usando la facade será pasada a la instancia subyacente del servicio de cache de Laravel.

Si nos fijamos en esa clase `Illuminate\Support\Facades\Cache`, verás que no hay ningún método estático `get`:

    class Cache extends Facade
    {
        /**
         * Get the registered name of the component.
         *
         * @return string
         */
        protected static function getFacadeAccessor() { return 'cache'; }
    }

En su lugar, la facade `Cache` extiende la clase de `Facade` base y define el método `getFacadeAccessor()`. La función de este método es devolver el nombre de una vinculación en el contenedor de servicios. Cuando un usuario hace referencia a cualquier método estático de facade fachada `Cache`, Laravel resuelve el enlace de `cache` del contenedor de [servicios](/docs/{{version}}/container) y ejecuta el método solicitado (en este caso, `get`) contra ese objeto.

<a name="real-time-facades"></a>
## Facades en Tiempo Real

Usando facades en tiempo real, puedes tratar cualquier clase de tu aplicación como si fuera una facade. Para ilustrar cómo se puede utilizar esto, examinemos primero algo de código que no utiliza facades en tiempo real. Por ejemplo, supongamos que nuestro modelo `Podcast` tiene un método `publish`. Sin embargo, para publicar el podcast, necesitamos inyectar una instancia de `Publisher`:

    <?php

    namespace App\Models;

    use App\Contracts\Publisher;
    use Illuminate\Database\Eloquent\Model;

    class Podcast extends Model
    {
        /**
         * Publish the podcast.
         *
         * @param  Publisher  $publisher
         * @return void
         */
        public function publish(Publisher $publisher)
        {
            $this->update(['publishing' => now()]);

            $publisher->publish($this);
        }
    }

Inyectar una implementación del editor en el método nos permite probar fácilmente el método de forma aislada, ya que podemos simular el editor inyectado. Sin embargo, nos obliga a pasar siempre una instancia de editor cada vez que llamemos al método `publish`. Usando facades en tiempo real, podemos mantener la misma comprobabilidad sin tener que pasar explícitamente una instancia de `Publisher`. Para generar una facade en tiempo real, anteponga el prefijo `Facades` al namespace de la clase importada:

    <?php

    namespace App\Models;

    use Facades\App\Contracts\Publisher;
    use Illuminate\Database\Eloquent\Model;

    class Podcast extends Model
    {
        /**
         * Publish the podcast.
         *
         * @return void
         */
        public function publish()
        {
            $this->update(['publishing' => now()]);

            Publisher::publish($this);
        }
    }

Cuando se utiliza la facade en tiempo real, la implementación del editor se resolverá fuera del contenedor de servicios utilizando la parte de la interfaz o el nombre de la clase que aparece después del prefijo `Facades`. Al testear, podemos utilizar las funciones de ayuda para testing que incorpora Laravel para simular esta llamada al método:

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
         *
         * @return void
         */
        public function test_podcast_can_be_published()
        {
            $podcast = Podcast::factory()->create();

            Publisher::shouldReceive('publish')->once()->with($podcast);

            $podcast->publish();
        }
    }

<a name="facade-class-reference"></a>
## Referencia de la clase Facade

A continuación encontrarás cada facade y su clase subyacente. Esta es una herramienta útil para profundizar rápidamente en la documentación de la API para una determinada raíz de facade. La clave de [vinculación del contenedor de servicios](/docs/{{version}}/container) también se incluye cuando procede.

|facade                    |Clase                                                                                                                                      |Enlace al contenedor de servicios|
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------|
|App                       |[Illuminate\Foundation\Application](https://laravel.com/api/{{version}}/Illuminate/Foundation/Application.html)                            |`app`                            |
|Artisan                   |[Illuminate\Contracts\Console\Kernel](https://laravel.com/api/{{version}}/Illuminate/Contracts/Console/Kernel.html)                        |`artisan`                        |
|Auth                      |[Illuminate\Auth\AuthManager](https://laravel.com/api/{{version}}/Illuminate/Auth/AuthManager.html)                                        |`auth`                           |
|Auth (Instancia)          |[Illuminate\Contracts\Auth\Guard](https://laravel.com/api/{{version}}/Illuminate/Contracts/Auth/Guard.html)                                 |`auth.driver`                    |
|Cuchilla                  |[Illuminate\View\Compilers\BladeCompiler](https://laravel.com/api/{{version}}/Illuminate/View/Compilers/BladeCompiler.html)                |`blade.compiler`                 |
|Difusión                  |[Illuminate\Contracts\Broadcasting\Factory](https://laravel.com/api/{{version}}/Illuminate/Contracts/Broadcasting/Factory.html)             |                                 |
|Emisión (Instancia)       |[Illuminate\Contracts\Broadcasting\Broadcaster](https://laravel.com/api/{{version}}/Illuminate/Contracts/Broadcasting/Broadcaster.html)     |                                 |
|Bus                       |[Illuminate\Contracts\Bus\Dispatcher](https://laravel.com/api/{{version}}/Illuminate/Contracts/Bus/Dispatcher.html)                        |                                 |
|cache                     |[Illuminate\Cache\CacheManager](https://laravel.com/api/{{version}}/Illuminate/Cache/CacheManager.html)                                    |`cache`                          |
|cache (Instancia)         |[Illuminate\Cache\Repository](https://laravel.com/api/{{version}}/Illuminate/Cache/Repository.html)                                        |`cache.store`                    |
|Config                    |[Illuminate\Config\Repository](https://laravel.com/api/{{version}}/Illuminate/Config/Repository.html)                                      |`config`                         |
|Cookie                    |[Illuminate\Cookie\CookieJar](https://laravel.com/api/{{version}}/Illuminate/Cookie/CookieJar.html)                                        |`cookie`                         |
|Cripta                    |[Illuminate\Encryption\Encriptador](https://laravel.com/api/{{version}}/Illuminate/Encryption/Encrypter.html)                              |`encrypter`                      |
|Fecha                     |[Illuminate\Support\DateFactory](https://laravel.com/api/{{version}}/Illuminate/Support/DateFactory.html)                                  |`date`                           |
|BD                        |[Illuminate\Database\DatabaseManager](https://laravel.com/api/{{version}}/Illuminate/Database/DatabaseManager.html)                        |`db`                             |
|BD (Instancia)            |[Illuminate\Database\Connection](https://laravel.com/api/{{version}}/Illuminate/Database/Connection.html)                                  |`db.connection`                  |
|Evento                    |[Illuminate\Events\Dispatcher](https://laravel.com/api/{{version}}/Illuminate/Events/Dispatcher.html)                                      |`events`                         |
|Archivo                   |[Illuminate\Filesystem\Filesystem](https://laravel.com/api/{{version}}/Illuminate/Filesystem/Filesystem.html)                              |`files`                          |
|Puerta                    |[Illuminate\Contracts\Auth\Access\Gate](https://laravel.com/api/{{version}}/Illuminate/Contracts/Auth/Access/Gate.html)                     |                                 |
|Hash                      |[Illuminate\Contracts\Hashing\Hasher](https://laravel.com/api/{{version}}/Illuminate/Contracts/Hashing/Hasher.html)                        |`hash`                           |
|Http                      |[Illuminate\Http\Client\Factory](https://laravel.com/api/{{version}}/Illuminate/Http/Client/Factory.html)                                  |                                 |
|Idioma                    |[Illuminate\Translation\Translator](https://laravel.com/api/{{version}}/Illuminate/Translation/Translator.html)                            |`translator`                     |
|Registro                  |[Illuminate\Log\LogManager](https://laravel.com/api/{{version}}/Illuminate/Log/LogManager.html)                                            |`log`                            |
|Correo                    |[Illuminate\Mail\Mailer](https://laravel.com/api/{{version}}/Illuminate/Mail/Mailer.html)                                                  |`mailer`                         |
|Notificación              |[Illuminate\Notifications\ChannelManager](https://laravel.com/api/{{version}}/Illuminate/Notifications/ChannelManager.html)                |                                 |
|Contraseña                |[Illuminate\Auth\Passwords\PasswordBrokerManager](https://laravel.com/api/{{version}}/Illuminate/Auth/Passwords/PasswordBrokerManager.html)|`auth.password`                  |
|Contraseña (Instancia)    |[Illuminate\Auth\Passwords\PasswordBroker](https://laravel.com/api/{{version}}/Illuminate/Auth/Passwords/PasswordBroker.html)              |`auth.password.broker`           |
|Cola                      |[Illuminate\Queue\QueueManager](https://laravel.com/api/{{version}}/Illuminate/Queue/QueueManager.html)                                    |`queue`                          |
|Cola (Instancia)          |[Illuminate\Contracts\Queue\Queue](https://laravel.com/api/{{version}}/Illuminate/Contracts/Queue/Queue.html)                              |`queue.connection`               |
|Cola (Clase Base)         |[Illuminate\Queue\Queue](https://laravel.com/api/{{version}}/Illuminate/Queue/Queue.html)                                                  |                                 |
|Redirigir                 |[Illuminate\Routing\Redirector](https://laravel.com/api/{{version}}/Illuminate/Routing/Redirector.html)                                    |`redirect`                       |
|Redis                     |[Illuminate\Redis\RedisManager](https://laravel.com/api/{{version}}/Illuminate/Redis/RedisManager.html)                                    |`redis`                          |
|Redis (Instancia)         |[IlluminateRedis\Connections\Connection](https://laravel.com/api/{{version}}/Illuminate/Redis/Connections/Connection.html)                 |`redis.connection`               |
|Solicitud                 |[Illuminate\Http\Request](https://laravel.com/api/{{version}}/Illuminate/Http/Request.html)                                                |`request`                        |
|Respuesta                 |[Illuminate\ContractsRoutingResponseFactory](https://laravel.com/api/{{version}}/Illuminate/Contracts/Routing/ResponseFactory.html)         |                                 |
|Respuesta (Instancia)     |[Illuminate\Http\Response](https://laravel.com/api/{{version}}/Illuminate/Http/Response.html)                                              |                                 |
|Ruta                      |[Illuminate\Routing\Router](https://laravel.com/api/{{version}}/Illuminate/Routing/Router.html)                                            |`router`                         |
|Esquema                   |[Illuminate\Database\Schema\Builder](https://laravel.com/api/{{version}}/Illuminate/Database/Schema/Builder.html)                          |                                 |
|Sesión                    |[Illuminate\Session\SessionManager](https://laravel.com/api/{{version}}/Illuminate/Session/SessionManager.html)                            |`session`                        |
|Sesión (Instancia)        |[Illuminate\Session\Store](https://laravel.com/api/{{version}}/Illuminate/Session/Store.html)                                              |`session.store`                  |
|Almacenamiento            |[Illuminate\Filesystem\FilesystemManager](https://laravel.com/api/{{version}}/Illuminate/Filesystem/FilesystemManager.html)                |`filesystem`                     |
|Almacenamiento (instancia)|[Illuminate\Contracts\Filesystem\Filesystem](https://laravel.com/api/{{version}}/Illuminate/Contracts/Filesystem/Filesystem.html)          |`filesystem.disk`                |
|URL                       |[Illuminate\Routing\UrlGenerator](https://laravel.com/api/{{version}}/Illuminate/Routing/UrlGenerator.html)                                |`url`                            |
|Validador                 |[Illuminate\Validation\Factory](https://laravel.com/api/{{version}}/Illuminate/Validation/Factory.html)                                    |`validator`                      |
|Validador (instancia)     |[IluminarValidaciónValidator](https://laravel.com/api/{{version}}/Illuminate/Validation/Validator.html)                                    |                                 |
|Ver                       |[Illuminate\View\Factory](https://laravel.com/api/{{version}}/Illuminate/View/Factory.html)                                                |`view`                           |
|Vista (Instancia)         |[Illuminate\View\View](https://laravel.com/api/{{version}}/Illuminate/View/View.html)                                                      |                                 |
|Vite                      |[Illuminate\Foundation\Vite](https://laravel.com/api/{{version}}/Illuminate/Foundation/Vite.html)                                          |                                 |
