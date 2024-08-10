# Proveedores de Servicios

- [Introducción](#introduction)
- [Escribiendo Proveedores de Servicios](#writing-service-providers)
    - [El Método Register](#the-register-method)
    - [El Método Boot](#the-boot-method)
- [Registrando Proveedores](#registering-providers)
- [Proveedores Diferidos](#deferred-providers)

<a name="introduction"></a>
## Introducción

Los proveedores de servicios son el lugar central de toda la inicialización de aplicaciones Laravel. Tu propia aplicación, así como todos los servicios centrales de Laravel, se inicializan a través de proveedores de servicios.

Pero, ¿qué queremos decir con "inicializados"? En general, nos referimos a **registrar** cosas, incluyendo registrar vinculaciones del contenedor de servicios, oyentes de eventos, middleware e incluso rutas. Los proveedores de servicios son el lugar central para configurar tu aplicación.

Laravel utiliza docenas de proveedores de servicios internamente para inicializar sus servicios centrales, como el correo, la cola, la caché y otros. Muchos de estos proveedores son proveedores "diferidos", lo que significa que no se cargarán en cada solicitud, sino solo cuando los servicios que proporcionan sean realmente necesarios.

Todos los proveedores de servicios definidos por el usuario se registran en el archivo `bootstrap/providers.php`. En la siguiente documentación, aprenderás cómo escribir tus propios proveedores de servicios y registrarlos con tu aplicación Laravel.

> [!NOTE]  
> Si deseas aprender más sobre cómo Laravel maneja las solicitudes y funciona internamente, consulta nuestra documentación sobre el [ciclo de vida de la solicitud](/docs/{{version}}/lifecycle).

<a name="writing-service-providers"></a>
## Escribiendo Proveedores de Servicios

Todos los proveedores de servicios extienden la clase `Illuminate\Support\ServiceProvider`. La mayoría de los proveedores de servicios contienen un método `register` y un método `boot`. Dentro del método `register`, debes **solo vincular cosas en el [contenedor de servicios](/docs/{{version}}/container)**. Nunca debes intentar registrar oyentes de eventos, rutas o cualquier otra funcionalidad dentro del método `register`.

La CLI de Artisan puede generar un nuevo proveedor a través del comando `make:provider`. Laravel registrará automáticamente tu nuevo proveedor en el archivo `bootstrap/providers.php` de tu aplicación:

```shell
php artisan make:provider RiakServiceProvider
```

<a name="the-register-method"></a>
### El Método Register

Como se mencionó anteriormente, dentro del método `register`, debes solo vincular cosas en el [contenedor de servicios](/docs/{{version}}/container). Nunca debes intentar registrar oyentes de eventos, rutas o cualquier otra funcionalidad dentro del método `register`. De lo contrario, podrías usar accidentalmente un servicio que es proporcionado por un proveedor de servicios que aún no se ha cargado.

Veamos un proveedor de servicios básico. Dentro de cualquiera de los métodos de tu proveedor de servicios, siempre tienes acceso a la propiedad `$app`, que proporciona acceso al contenedor de servicios:

    <?php

    namespace App\Providers;

    use App\Services\Riak\Connection;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Support\ServiceProvider;

    class RiakServiceProvider extends ServiceProvider
    {
        /**
         * Registrar cualquier servicio de la aplicación.
         */
        public function register(): void
        {
            $this->app->singleton(Connection::class, function (Application $app) {
                return new Connection(config('riak'));
            });
        }
    }

Este proveedor de servicios solo define un método `register`, y utiliza ese método para definir una implementación de `App\Services\Riak\Connection` en el contenedor de servicios. Si aún no estás familiarizado con el contenedor de servicios de Laravel, consulta [su documentación](/docs/{{version}}/container).

<a name="the-bindings-and-singletons-properties"></a>
#### Las Propiedades `bindings` y `singletons`

Si tu proveedor de servicios registra muchas vinculaciones simples, puedes optar por usar las propiedades `bindings` y `singletons` en lugar de registrar manualmente cada vinculación del contenedor. Cuando el proveedor de servicios es cargado por el framework, automáticamente verificará estas propiedades y registrará sus vinculaciones:

    <?php

    namespace App\Providers;

    use App\Contracts\DowntimeNotifier;
    use App\Contracts\ServerProvider;
    use App\Services\DigitalOceanServerProvider;
    use App\Services\PingdomDowntimeNotifier;
    use App\Services\ServerToolsProvider;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Todas las vinculaciones del contenedor que deben ser registradas.
         *
         * @var array
         */
        public $bindings = [
            ServerProvider::class => DigitalOceanServerProvider::class,
        ];

        /**
         * Todos los singletons del contenedor que deben ser registrados.
         *
         * @var array
         */
        public $singletons = [
            DowntimeNotifier::class => PingdomDowntimeNotifier::class,
            ServerProvider::class => ServerToolsProvider::class,
        ];
    }

<a name="the-boot-method"></a>
### El Método Boot

Entonces, ¿qué pasa si necesitamos registrar un [compositor de vista](/docs/{{version}}/views#view-composers) dentro de nuestro proveedor de servicios? Esto debe hacerse dentro del método `boot`. **Este método se llama después de que todos los demás proveedores de servicios han sido registrados**, lo que significa que tienes acceso a todos los demás servicios que han sido registrados por el framework:

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\View;
    use Illuminate\Support\ServiceProvider;

    class ComposerServiceProvider extends ServiceProvider
    {
        /**
         * Inicializar cualquier servicio de la aplicación.
         */
        public function boot(): void
        {
            View::composer('view', function () {
                // ...
            });
        }
    }

<a name="boot-method-dependency-injection"></a>
#### Inyección de Dependencias en el Método Boot

Puedes indicar dependencias para el método `boot` de tu proveedor de servicios. El [contenedor de servicios](/docs/{{version}}/container) inyectará automáticamente cualquier dependencia que necesites:

    use Illuminate\Contracts\Routing\ResponseFactory;

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(ResponseFactory $response): void
    {
        $response->macro('serialized', function (mixed $value) {
            // ...
        });
    }

<a name="registering-providers"></a>
## Registrando Proveedores

Todos los proveedores de servicios se registran en el archivo de configuración `bootstrap/providers.php`. Este archivo devuelve un array que contiene los nombres de clase de los proveedores de servicios de tu aplicación:

    <?php

    return [
        App\Providers\AppServiceProvider::class,
    ];

Cuando invocas el comando Artisan `make:provider`, Laravel agregará automáticamente el proveedor generado al archivo `bootstrap/providers.php`. Sin embargo, si has creado manualmente la clase del proveedor, debes agregar manualmente la clase del proveedor al array:

    <?php

    return [
        App\Providers\AppServiceProvider::class,
        App\Providers\ComposerServiceProvider::class, // [tl! add]
    ];

<a name="deferred-providers"></a>
## Proveedores Diferidos

Si tu proveedor está **solo** registrando vinculaciones en el [contenedor de servicios](/docs/{{version}}/container), puedes optar por diferir su registro hasta que realmente se necesite una de las vinculaciones registradas. Diferir la carga de tal proveedor mejorará el rendimiento de tu aplicación, ya que no se carga desde el sistema de archivos en cada solicitud.

Laravel compila y almacena una lista de todos los servicios proporcionados por los proveedores de servicios diferidos, junto con el nombre de su clase de proveedor de servicios. Luego, solo cuando intentas resolver uno de estos servicios, Laravel carga el proveedor de servicios.

Para diferir la carga de un proveedor, implementa la interfaz `\Illuminate\Contracts\Support\DeferrableProvider` y define un método `provides`. El método `provides` debe devolver las vinculaciones del contenedor de servicios registradas por el proveedor:

    <?php

    namespace App\Providers;

    use App\Services\Riak\Connection;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Contracts\Support\DeferrableProvider;
    use Illuminate\Support\ServiceProvider;

    class RiakServiceProvider extends ServiceProvider implements DeferrableProvider
    {
        /**
         * Registrar cualquier servicio de la aplicación.
         */
        public function register(): void
        {
            $this->app->singleton(Connection::class, function (Application $app) {
                return new Connection($app['config']['riak']);
            });
        }

        /**
         * Obtener los servicios proporcionados por el proveedor.
         *
         * @return array<int, string>
         */
        public function provides(): array
        {
            return [Connection::class];
        }
    }
