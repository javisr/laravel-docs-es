# Vistas

- [Introducción](#introduction)
  - [Escribiendo Vistas en React / Vue](#writing-views-in-react-or-vue)
- [Creando y Renderizando Vistas](#creating-and-rendering-views)
  - [Directorios de Vistas Anidados](#nested-view-directories)
  - [Creando la Primera Vista Disponible](#creating-the-first-available-view)
  - [Determinando si Existe una Vista](#determining-if-a-view-exists)
- [Pasando Datos a Vistas](#passing-data-to-views)
  - [Compartiendo Datos con Todas las Vistas](#sharing-data-with-all-views)
- [Compositores de Vistas](#view-composers)
  - [Creadores de Vistas](#view-creators)
- [Optimizando Vistas](#optimizing-views)

<a name="introduction"></a>
## Introducción

Por supuesto, no es práctico devolver cadenas de documentos HTML completos directamente desde tus rutas y controladores. Afortunadamente, las vistas proporcionan una manera conveniente de colocar todo nuestro HTML en archivos separados.
Las vistas separan la lógica de tu controlador / aplicación de tu lógica de presentación y se almacenan en el directorio `resources/views`. Al usar Laravel, las plantillas de vista suelen escribirse utilizando el [lenguaje de plantillas Blade](/docs/%7B%7Bversion%7D%7D/blade). Una vista simple podría verse algo así:


```blade
<!-- View stored in resources/views/greeting.blade.php -->

<html>
    <body>
        <h1>Hello, {{ $name }}</h1>
    </body>
</html>

```
Dado que esta vista se almacena en `resources/views/greeting.blade.php`, podemos devolverla utilizando el helper global `view` de la siguiente manera:
> [!NOTA]
¿Buscas más información sobre cómo escribir plantillas Blade? Consulta la [documentación completa de Blade](/docs/%7B%7Bversion%7D%7D/blade) para comenzar.

<a name="writing-views-in-react-or-vue"></a>
### Escribiendo Vistas en React / Vue

En lugar de escribir sus plantillas frontend en PHP a través de Blade, muchos desarrolladores han comenzado a preferir escribir sus plantillas utilizando React o Vue. Laravel hace esto sencillo gracias a [Inertia](https://inertiajs.com/), una biblioteca que facilita la conexión de tu frontend en React / Vue con tu backend de Laravel sin las complejidades típicas de construir una SPA.
Nuestros [starter kits](/docs/%7B%7Bversion%7D%7D/starter-kits) de Breeze y Jetstream te ofrecen un excelente punto de partida para tu próxima aplicación Laravel impulsada por Inertia. Además, el [Laravel Bootcamp](https://bootcamp.laravel.com) proporciona una demostración completa de la construcción de una aplicación Laravel impulsada por Inertia, incluyendo ejemplos en Vue y React.

<a name="creating-and-rendering-views"></a>
## Creando y Renderizando Vistas

Puedes crear una vista colocando un archivo con la extensión `.blade.php` en el directorio `resources/views` de tu aplicación o utilizando el comando Artisan `make:view`:


```shell
php artisan make:view greeting

```
La extensión `.blade.php` informa al framework que el archivo contiene una [plantilla Blade](/docs/%7B%7Bversion%7D%7D/blade). Las plantillas Blade contienen HTML así como directivas Blade que te permiten fácilmente devolver valores, crear sentencias "if", iterar sobre datos y más.
Una vez que hayas creado una vista, puedes devolverla desde una de las rutas o controladores de tu aplicación utilizando el helper global `view`:


```php
Route::get('/', function () {
    return view('greeting', ['name' => 'James']);
});
```
Las vistas también pueden ser devueltas utilizando la fachada `View`:


```php
use Illuminate\Support\Facades\View;

return View::make('greeting', ['name' => 'James']);
```
Como puedes ver, el primer argumento pasado al helper `view` corresponde al nombre del archivo de vista en el directorio `resources/views`. El segundo argumento es un array de datos que deben estar disponibles para la vista. En este caso, estamos pasando la variable `name`, que se muestra en la vista utilizando la [sintaxis de Blade](/docs/%7B%7Bversion%7D%7D/blade).

<a name="nested-view-directories"></a>
### Directorios de Vista Anidados

Las vistas también pueden estar anidadas dentro de subdirectorios del directorio `resources/views`. Se puede usar notación "punto" para hacer referencia a las vistas anidadas. Por ejemplo, si tu vista se almacena en `resources/views/admin/profile.blade.php`, puedes devolverla desde una de las rutas / controladores de tu aplicación de la siguiente manera:


```php
return view('admin.profile', $data);
```
> [!WARNING]
Los nombres de los directorios de vista no deben contener el carácter `.`.

<a name="creating-the-first-available-view"></a>
### Creando la Primera Vista Disponibilidad

Usando el método `first` de la fachada `View`, puedes crear la primera vista que existe en un array dado de vistas. Esto puede ser útil si tu aplicación o paquete permite que las vistas sean personalizadas o sobrescritas:


```php
use Illuminate\Support\Facades\View;

return View::first(['custom.admin', 'admin'], $data);
```

<a name="determining-if-a-view-exists"></a>
### Determinando si una Vista Existe

Si necesitas determinar si una vista existe, puedes usar la facade `View`. El método `exists` devolverá `true` si la vista existe:


```php
use Illuminate\Support\Facades\View;

if (View::exists('admin.profile')) {
    // ...
}
```

<a name="passing-data-to-views"></a>
## Pasando Datos a Vistas

Como viste en los ejemplos anteriores, puedes pasar un array de datos a las vistas para hacer que esos datos estén disponibles en la vista:


```php
return view('greetings', ['name' => 'Victoria']);
```
Al pasar información de esta manera, los datos deben ser un array con pares clave / valor. Después de proporcionar datos a una vista, puedes acceder a cada valor dentro de tu vista utilizando las claves de los datos, como `<?php echo $name; ?>`.
Como alternativa a pasar un array completo de datos a la función helper `view`, puedes usar el método `with` para añadir piezas individuales de datos a la vista. El método `with` devuelve una instancia del objeto de la vista para que puedas seguir encadenando métodos antes de devolver la vista:


```php
return view('greeting')
            ->with('name', 'Victoria')
            ->with('occupation', 'Astronaut');
```

<a name="sharing-data-with-all-views"></a>
### Compartiendo Datos con Todas las Vistas

Ocasionalmente, es posible que necesites compartir datos con todas las vistas que son renderizadas por tu aplicación. Puedes hacerlo utilizando el método `share` de la fachada `View`. Típicamente, debes colocar las llamadas al método `share` dentro del método `boot` de un proveedor de servicios. Puedes añadirlas a la clase `App\Providers\AppServiceProvider` o generar un proveedor de servicios separado para albergarlas:


```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\View;

class AppServiceProvider extends ServiceProvider
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
        View::share('key', 'value');
    }
}
```

<a name="view-composers"></a>
## Compositores de Vista

Los compositores de vistas son callbacks o métodos de clase que se llaman cuando se renderiza una vista. Si tienes datos que deseas vincular a una vista cada vez que se renderiza esa vista, un compositor de vista puede ayudarte a organizar esa lógica en un solo lugar. Los compositores de vistas pueden resultar especialmente útiles si la misma vista es devuelta por múltiples rutas o controladores dentro de tu aplicación y siempre necesita un conjunto particular de datos.
Típicamente, los compositores de vista se registrarán dentro de uno de los [proveedores de servicios](/docs/%7B%7Bversion%7D%7D/providers) de tu aplicación. En este ejemplo, asumiremos que la `App\Providers\AppServiceProvider` albergará esta lógica.
Usaremos el método `composer` de la facade `View` para registrar el compositor de vistas. Laravel no incluye un directorio predeterminado para compositores de vistas basados en clases, así que puedes organizarlos como desees. Por ejemplo, podrías crear un directorio `app/View/Composers` para albergar todos los compositores de vistas de tu aplicación:


```php
<?php

namespace App\Providers;

use App\View\Composers\ProfileComposer;
use Illuminate\Support\Facades;
use Illuminate\Support\ServiceProvider;
use Illuminate\View\View;

class AppServiceProvider extends ServiceProvider
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
        // Using class based composers...
        Facades\View::composer('profile', ProfileComposer::class);

        // Using closure based composers...
        Facades\View::composer('welcome', function (View $view) {
            // ...
        });

        Facades\View::composer('dashboard', function (View $view) {
            // ...
        });
    }
}
```
Ahora que hemos registrado el compositor, el método `compose` de la clase `App\View\Composers\ProfileComposer` se ejecutará cada vez que se esté renderizando la vista `profile`. Veamos un ejemplo de la clase del compositor:


```php
<?php

namespace App\View\Composers;

use App\Repositories\UserRepository;
use Illuminate\View\View;

class ProfileComposer
{
    /**
     * Create a new profile composer.
     */
    public function __construct(
        protected UserRepository $users,
    ) {}

    /**
     * Bind data to the view.
     */
    public function compose(View $view): void
    {
        $view->with('count', $this->users->count());
    }
}
```
Como puedes ver, todos los compositores de vista se resuelven a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container), así que puedes indicar cualquier dependencia que necesites dentro del constructor de un compositor.

<a name="attaching-a-composer-to-multiple-views"></a>
#### Adjuntando un Compositor a Múltiples Vistas

Puedes adjuntar un compositor de vistas a múltiples vistas a la vez pasando un array de vistas como primer argumento al método `composer`:


```php
use App\Views\Composers\MultiComposer;
use Illuminate\Support\Facades\View;

View::composer(
    ['profile', 'dashboard'],
    MultiComposer::class
);
```
El método `composer` también acepta el carácter `*` como un comodín, lo que te permite adjuntar un compositor a todas las vistas:


```php
use Illuminate\Support\Facades;
use Illuminate\View\View;

Facades\View::composer('*', function (View $view) {
    // ...
});
```

<a name="view-creators"></a>
### Creadores de Vistas

Los "creators" de vista son muy similares a los compositores de vista; sin embargo, se ejecutan inmediatamente después de que se instancia la vista en lugar de esperar hasta que la vista esté a punto de renderizar. Para registrar un creador de vista, utiliza el método `creator`:


```php
use App\View\Creators\ProfileCreator;
use Illuminate\Support\Facades\View;

View::creator('profile', ProfileCreator::class);
```

<a name="optimizing-views"></a>
## Optimización de Vistas

Por defecto, las vistas de plantillas Blade se compilan bajo demanda. Cuando se ejecuta una solicitud que renderiza una vista, Laravel determinará si existe una versión compilada de la vista. Si el archivo existe, Laravel determinará si la vista no compilada ha sido modificada más recientemente que la vista compilada. Si la vista compilada no existe o si la vista no compilada ha sido modificada, Laravel volverá a compilar la vista.
Compilar vistas durante la solicitud puede tener un pequeño impacto negativo en el rendimiento, por lo que Laravel proporciona el comando Artisan `view:cache` para precompilar todas las vistas utilizadas por tu aplicación. Para aumentar el rendimiento, es posible que desees ejecutar este comando como parte de tu proceso de despliegue:


```shell
php artisan view:cache

```
Puedes usar el comando `view:clear` para limpiar la caché de vistas:


```shell
php artisan view:clear

```