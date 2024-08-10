# Vistas

- [Introducción](#introduction)
    - [Escribiendo Vistas en React / Vue](#writing-views-in-react-or-vue)
- [Creando y Renderizando Vistas](#creating-and-rendering-views)
    - [Directorios de Vistas Anidadas](#nested-view-directories)
    - [Creando la Primera Vista Disponible](#creating-the-first-available-view)
    - [Determinando si una Vista Existe](#determining-if-a-view-exists)
- [Pasando Datos a Vistas](#passing-data-to-views)
    - [Compartiendo Datos con Todas las Vistas](#sharing-data-with-all-views)
- [Compositores de Vistas](#view-composers)
    - [Creadores de Vistas](#view-creators)
- [Optimizando Vistas](#optimizing-views)

<a name="introduction"></a>
## Introducción

Por supuesto, no es práctico devolver cadenas de documentos HTML completos directamente desde tus rutas y controladores. Afortunadamente, las vistas proporcionan una manera conveniente de colocar todo nuestro HTML en archivos separados.

Las vistas separan la lógica de tu controlador / aplicación de tu lógica de presentación y se almacenan en el directorio `resources/views`. Al usar Laravel, las plantillas de vista generalmente se escriben utilizando el [lenguaje de plantillas Blade](/docs/{{version}}/blade). Una vista simple podría verse algo así:

```blade
<!-- View stored in resources/views/greeting.blade.php -->

<html>
    <body>
        <h1>Hello, {{ $name }}</h1>
    </body>
</html>
```

Dado que esta vista se almacena en `resources/views/greeting.blade.php`, podemos devolverla utilizando el helper global `view` de la siguiente manera:

    Route::get('/', function () {
        return view('greeting', ['name' => 'James']);
    });

> [!NOTE]  
> ¿Buscas más información sobre cómo escribir plantillas Blade? Consulta la [documentación completa de Blade](/docs/{{version}}/blade) para comenzar.

<a name="writing-views-in-react-or-vue"></a>
### Escribiendo Vistas en React / Vue

En lugar de escribir sus plantillas frontend en PHP a través de Blade, muchos desarrolladores han comenzado a preferir escribir sus plantillas utilizando React o Vue. Laravel hace que esto sea sencillo gracias a [Inertia](https://inertiajs.com/), una biblioteca que facilita la conexión de tu frontend de React / Vue con tu backend de Laravel sin las complejidades típicas de construir un SPA.

Nuestros kits de inicio de Breeze y Jetstream [starter kits](/docs/{{version}}/starter-kits) te brindan un excelente punto de partida para tu próxima aplicación Laravel impulsada por Inertia. Además, el [Laravel Bootcamp](https://bootcamp.laravel.com) proporciona una demostración completa de cómo construir una aplicación Laravel impulsada por Inertia, incluidos ejemplos en Vue y React.

<a name="creating-and-rendering-views"></a>
## Creando y Renderizando Vistas

Puedes crear una vista colocando un archivo con la extensión `.blade.php` en el directorio `resources/views` de tu aplicación o utilizando el comando Artisan `make:view`:

```shell
php artisan make:view greeting
```

La extensión `.blade.php` informa al framework que el archivo contiene una [plantilla Blade](/docs/{{version}}/blade). Las plantillas Blade contienen HTML así como directivas Blade que te permiten fácilmente mostrar valores, crear declaraciones "if", iterar sobre datos, y más.

Una vez que hayas creado una vista, puedes devolverla desde una de las rutas o controladores de tu aplicación utilizando el helper global `view`:

    Route::get('/', function () {
        return view('greeting', ['name' => 'James']);
    });

Las vistas también pueden ser devueltas utilizando la fachada `View`:

    use Illuminate\Support\Facades\View;

    return View::make('greeting', ['name' => 'James']);

Como puedes ver, el primer argumento pasado al helper `view` corresponde al nombre del archivo de vista en el directorio `resources/views`. El segundo argumento es un array de datos que deben estar disponibles para la vista. En este caso, estamos pasando la variable `name`, que se muestra en la vista utilizando la [sintaxis Blade](/docs/{{version}}/blade).

<a name="nested-view-directories"></a>
### Directorios de Vistas Anidadas

Las vistas también pueden estar anidadas dentro de subdirectorios del directorio `resources/views`. Se puede utilizar la notación "punto" para hacer referencia a vistas anidadas. Por ejemplo, si tu vista se almacena en `resources/views/admin/profile.blade.php`, puedes devolverla desde una de las rutas / controladores de tu aplicación de la siguiente manera:

    return view('admin.profile', $data);

> [!WARNING]  
> Los nombres de los directorios de vistas no deben contener el carácter `.`.

<a name="creating-the-first-available-view"></a>
### Creando la Primera Vista Disponible

Usando el método `first` de la fachada `View`, puedes crear la primera vista que exista en un array dado de vistas. Esto puede ser útil si tu aplicación o paquete permite que las vistas sean personalizadas o sobrescritas:

    use Illuminate\Support\Facades\View;

    return View::first(['custom.admin', 'admin'], $data);

<a name="determining-if-a-view-exists"></a>
### Determinando si una Vista Existe

Si necesitas determinar si una vista existe, puedes usar la fachada `View`. El método `exists` devolverá `true` si la vista existe:

    use Illuminate\Support\Facades\View;

    if (View::exists('admin.profile')) {
        // ...
    }

<a name="passing-data-to-views"></a>
## Pasando Datos a Vistas

Como viste en los ejemplos anteriores, puedes pasar un array de datos a las vistas para hacer que esos datos estén disponibles para la vista:

    return view('greetings', ['name' => 'Victoria']);

Al pasar información de esta manera, los datos deben ser un array con pares clave / valor. Después de proporcionar datos a una vista, puedes acceder a cada valor dentro de tu vista utilizando las claves de los datos, como `<?php echo $name; ?>`.

Como alternativa a pasar un array completo de datos a la función helper `view`, puedes usar el método `with` para agregar piezas individuales de datos a la vista. El método `with` devuelve una instancia del objeto vista para que puedas continuar encadenando métodos antes de devolver la vista:

    return view('greeting')
                ->with('name', 'Victoria')
                ->with('occupation', 'Astronaut');

<a name="sharing-data-with-all-views"></a>
### Compartiendo Datos con Todas las Vistas

Ocasionalmente, puede que necesites compartir datos con todas las vistas que son renderizadas por tu aplicación. Puedes hacerlo utilizando el método `share` de la fachada `View`. Típicamente, deberías colocar las llamadas al método `share` dentro del método `boot` de un proveedor de servicios. Eres libre de agregarlas a la clase `App\Providers\AppServiceProvider` o generar un proveedor de servicios separado para albergarlas:

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\View;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Registrar cualquier servicio de la aplicación.
         */
        public function register(): void
        {
            // ...
        }

        /**
         * Inicializar cualquier servicio de la aplicación.
         */
        public function boot(): void
        {
            View::share('key', 'value');
        }
    }

<a name="view-composers"></a>
## Compositores de Vistas

Los compositores de vistas son callbacks o métodos de clase que se llaman cuando se renderiza una vista. Si tienes datos que deseas que estén vinculados a una vista cada vez que se renderiza esa vista, un compositor de vista puede ayudarte a organizar esa lógica en un solo lugar. Los compositores de vistas pueden resultar particularmente útiles si la misma vista es devuelta por múltiples rutas o controladores dentro de tu aplicación y siempre necesita una pieza particular de datos.

Típicamente, los compositores de vistas se registrarán dentro de uno de los [proveedores de servicios](/docs/{{version}}/providers) de tu aplicación. En este ejemplo, asumiremos que la `App\Providers\AppServiceProvider` albergará esta lógica.

Usaremos el método `composer` de la fachada `View` para registrar el compositor de vista. Laravel no incluye un directorio predeterminado para compositores de vista basados en clases, por lo que eres libre de organizarlos como desees. Por ejemplo, podrías crear un directorio `app/View/Composers` para albergar todos los compositores de vista de tu aplicación:

    <?php

    namespace App\Providers;

    use App\View\Composers\ProfileComposer;
    use Illuminate\Support\Facades;
    use Illuminate\Support\ServiceProvider;
    use Illuminate\View\View;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Registrar cualquier servicio de la aplicación.
         */
        public function register(): void
        {
            // ...
        }

        /**
         * Inicializar cualquier servicio de la aplicación.
         */
        public function boot(): void
        {
            // Usando compositores basados en clases...
            Facades\View::composer('profile', ProfileComposer::class);

            // Usando compositores basados en funciones anónimas...
            Facades\View::composer('welcome', function (View $view) {
                // ...
            });

            Facades\View::composer('dashboard', function (View $view) {
                // ...
            });
        }
    }

Ahora que hemos registrado el compositor, el método `compose` de la clase `App\View\Composers\ProfileComposer` se ejecutará cada vez que se renderice la vista `profile`. Veamos un ejemplo de la clase del compositor:

    <?php

    namespace App\View\Composers;

    use App\Repositories\UserRepository;
    use Illuminate\View\View;

    class ProfileComposer
    {
        /**
         * Crear un nuevo compositor de perfil.
         */
        public function __construct(
            protected UserRepository $users,
        ) {}

        /**
         * Vincular datos a la vista.
         */
        public function compose(View $view): void
        {
            $view->with('count', $this->users->count());
        }
    }

Como puedes ver, todos los compositores de vista se resuelven a través del [contenedor de servicios](/docs/{{version}}/container), por lo que puedes indicar cualquier dependencia que necesites dentro del constructor de un compositor.

<a name="attaching-a-composer-to-multiple-views"></a>
#### Adjuntando un Compositor a Múltiples Vistas

Puedes adjuntar un compositor de vista a múltiples vistas a la vez pasando un array de vistas como el primer argumento al método `composer`:

    use App\Views\Composers\MultiComposer;
    use Illuminate\Support\Facades\View;

    View::composer(
        ['profile', 'dashboard'],
        MultiComposer::class
    );

El método `composer` también acepta el carácter `*` como un comodín, lo que te permite adjuntar un compositor a todas las vistas:

    use Illuminate\Support\Facades;
    use Illuminate\View\View;

    Facades\View::composer('*', function (View $view) {
        // ...
    });

<a name="view-creators"></a>
### Creadores de Vistas

Los "creadores" de vistas son muy similares a los compositores de vistas; sin embargo, se ejecutan inmediatamente después de que se instancia la vista en lugar de esperar hasta que la vista esté a punto de renderizarse. Para registrar un creador de vista, utiliza el método `creator`:

    use App\View\Creators\ProfileCreator;
    use Illuminate\Support\Facades\View;

    View::creator('profile', ProfileCreator::class);

<a name="optimizing-views"></a>
## Optimizando Vistas

Por defecto, las vistas de plantillas Blade se compilan bajo demanda. Cuando se ejecuta una solicitud que renderiza una vista, Laravel determinará si existe una versión compilada de la vista. Si el archivo existe, Laravel determinará si la vista no compilada ha sido modificada más recientemente que la vista compilada. Si la vista compilada no existe, o si la vista no compilada ha sido modificada, Laravel recompilará la vista.

Compilar vistas durante la solicitud puede tener un pequeño impacto negativo en el rendimiento, por lo que Laravel proporciona el comando Artisan `view:cache` para precompilar todas las vistas utilizadas por tu aplicación. Para un rendimiento mejorado, es posible que desees ejecutar este comando como parte de tu proceso de implementación:

```shell
php artisan view:cache
```

Puedes usar el comando `view:clear` para limpiar la caché de vistas:

```shell
php artisan view:clear
```
