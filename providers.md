# Proveedores de Servicios

- [Introducción](#introduction)
- [Escribiendo Proveedores de Servicios](#writing-service-providers)
  - [El Método Register](#the-register-method)
  - [El Método Boot](#the-boot-method)
- [Registrando Proveedores](#registering-providers)
- [Proveedores Diferidos](#deferred-providers)

<a name="introduction"></a>
## Introducción

Los proveedores de servicios son el lugar central de todo el arranque de aplicaciones Laravel. Tu propia aplicación, así como todos los servicios centrales de Laravel, se inician a través de proveedores de servicios.
Pero, ¿qué queremos decir con "bootstrapped"? En general, nos referimos a **registrar** cosas, incluyendo registrar enlaces del contenedor de servicios, oyentes de eventos, middleware e incluso rutas. Los proveedores de servicios son el lugar central para configurar tu aplicación.
Laravel utiliza docenas de proveedores de servicios internamente para inicializar sus servicios centrales, como el correo, la cola, la caché y otros. Muchos de estos proveedores son proveedores "diferidos", lo que significa que no se cargarán en cada solicitud, sino solo cuando los servicios que proporcionan sean realmente necesarios.
Todos los proveedores de servicios definidos por el usuario se registran en el archivo `bootstrap/providers.php`. En la siguiente documentación, aprenderás cómo escribir tus propios proveedores de servicios y registrarlos con tu aplicación Laravel.
> [!NOTA]
Si deseas aprender más sobre cómo Laravel maneja las solicitudes y funciona internamente, consulta nuestra documentación sobre el [ciclo de vida de la solicitud](/docs/%7B%7Bversion%7D%7D/lifecycle).

<a name="writing-service-providers"></a>
## Escribiendo Proveedores de Servicios

Todos los proveedores de servicios extienden la clase `Illuminate\Support\ServiceProvider`. La mayoría de los proveedores de servicios contienen un método `register` y un método `boot`. Dentro del método `register`, solo debes **vincular cosas en el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container)**. Nunca debes intentar registrar ningún listener de eventos, rutas o cualquier otra funcionalidad dentro del método `register`.
La CLI de Artisan puede generar un nuevo proveedor a través del comando `make:provider`. Laravel registrará automáticamente tu nuevo proveedor en el archivo `bootstrap/providers.php` de tu aplicación:


```shell
php artisan make:provider RiakServiceProvider

```

<a name="the-register-method"></a>
### El Método de Registro

Como se mencionó anteriormente, dentro del método `register`, solo debes enlazar cosas en el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container). Nunca debes intentar registrar ningún listener de eventos, rutas u otra pieza de funcionalidad dentro del método `register`. De lo contrario, puedes usar accidentalmente un servicio que es proporcionado por un proveedor de servicios que aún no se ha cargado.
Echemos un vistazo a un proveedor de servicios básico. Dentro de cualquier método de tu proveedor de servicios, siempre tienes acceso a la propiedad `$app` que proporciona acceso al contenedor de servicios:


```php
<?php

namespace App\Providers;

use App\Services\Riak\Connection;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Support\ServiceProvider;

class RiakServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(Connection::class, function (Application $app) {
            return new Connection(config('riak'));
        });
    }
}
```
Este proveedor de servicios solo define un método `register`, y utiliza ese método para definir una implementación de `App\Services\Riak\Connection` en el contenedor de servicios. Si aún no estás familiarizado con el contenedor de servicios de Laravel, consulta [su documentación](/docs/%7B%7Bversion%7D%7D/container).

<a name="the-bindings-and-singletons-properties"></a>
#### Las Propiedades `bindings` y `singletons`

Si tu proveedor de servicios registra muchos enlaces simples, es posible que desees utilizar las propiedades `bindings` y `singletons` en lugar de registrar manualmente cada enlace del contenedor. Cuando el proveedor de servicios es cargado por el framework, verificará automáticamente estas propiedades y registrará sus enlaces:


```php
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
     * All of the container bindings that should be registered.
     *
     * @var array
     */
    public $bindings = [
        ServerProvider::class => DigitalOceanServerProvider::class,
    ];

    /**
     * All of the container singletons that should be registered.
     *
     * @var array
     */
    public $singletons = [
        DowntimeNotifier::class => PingdomDowntimeNotifier::class,
        ServerProvider::class => ServerToolsProvider::class,
    ];
}
```

<a name="the-boot-method"></a>
### El Método Boot

Entonces, ¿qué pasa si necesitamos registrar un [compositor de vista](/docs/%7B%7Bversion%7D%7D/views#view-composers) dentro de nuestro proveedor de servicios? Esto debe hacerse dentro del método `boot`. **Este método se llama después de que se hayan registrado todos los demás proveedores de servicios**, lo que significa que tienes acceso a todos los demás servicios que han sido registrados por el framework:


```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;

class ComposerServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        View::composer('view', function () {
            // ...
        });
    }
}
```

<a name="boot-method-dependency-injection"></a>
#### Inyección de Dependencias en el Método Boot

Puedes especificar las dependencias para el método `boot` de tu proveedor de servicios. El [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) inyectará automáticamente cualquier dependencia que necesites:


```php
use Illuminate\Contracts\Routing\ResponseFactory;

/**
 * Bootstrap any application services.
 */
public function boot(ResponseFactory $response): void
{
    $response->macro('serialized', function (mixed $value) {
        // ...
    });
}
```

<a name="registering-providers"></a>
## Registrando Proveedores

Todos los proveedores de servicios están registrados en el archivo de configuración `bootstrap/providers.php`. Este archivo devuelve un array que contiene los nombres de las clases de los proveedores de servicios de tu aplicación:


```php
<?php

return [
    App\Providers\AppServiceProvider::class,
];
```
Cuando invoques el comando Artisan `make:provider`, Laravel añadirá automáticamente el proveedor generado al archivo `bootstrap/providers.php`. Sin embargo, si has creado manualmente la clase del proveedor, deberías añadir manualmente la clase del proveedor al array:


```php
<?php

return [
    App\Providers\AppServiceProvider::class,
    App\Providers\ComposerServiceProvider::class, // [tl! add]
];
```

<a name="deferred-providers"></a>
## Proveedores Diferidos

Si tu proveedor **solo** está registrando enlaces en el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container), puedes elegir diferir su registro hasta que uno de los enlaces registrados sea realmente necesario. Diferir la carga de dicho proveedor mejorará el rendimiento de tu aplicación, ya que no se carga desde el sistema de archivos en cada solicitud.
Laravel compila y almacena una lista de todos los servicios proporcionados por los proveedores de servicios diferidos, junto con el nombre de su clase de proveedor de servicios. Luego, solo cuando intentas resolver uno de estos servicios, Laravel carga el proveedor de servicios.
Para diferir la carga de un proveedor, implementa la interfaz `\Illuminate\Contracts\Support\DeferrableProvider` y define un método `provides`. El método `provides` debería devolver los enlaces del contenedor de servicios registrados por el proveedor:


```php
<?php

namespace App\Providers;

use App\Services\Riak\Connection;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\Support\DeferrableProvider;
use Illuminate\Support\ServiceProvider;

class RiakServiceProvider extends ServiceProvider implements DeferrableProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(Connection::class, function (Application $app) {
            return new Connection($app['config']['riak']);
        });
    }

    /**
     * Get the services provided by the provider.
     *
     * @return array<int, string>
     */
    public function provides(): array
    {
        return [Connection::class];
    }
}
```