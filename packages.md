# Desarrollo de Paquetes

- [Introducción](#introduction)
  - [Una Nota sobre Facades](#a-note-on-facades)
- [Descubrimiento de Paquetes](#package-discovery)
- [Proveedores de Servicios](#service-providers)
- [Recursos](#resources)
  - [Configuración](#configuration)
  - [Migraciones](#migrations)
  - [Rutas](#routes)
  - [Archivos de Idioma](#language-files)
  - [Vistas](#views)
  - [Componentes de Vista](#view-components)
  - [Comando Artisan "About"](#about-artisan-command)
- [Comandos](#commands)
- [Activos Públicos](#public-assets)
- [Publicación de Grupos de Archivos](#publishing-file-groups)

<a name="introduction"></a>
## Introducción

Los paquetes son la forma principal de añadir funcionalidad a Laravel. Los paquetes pueden ser cualquier cosa, desde una gran manera de trabajar con fechas como [Carbon](https://github.com/briannesbitt/Carbon) o un paquete que te permite asociar archivos con modelos Eloquent como la [Laravel Media Library](https://github.com/spatie/laravel-medialibrary) de Spatie.
Hay diferentes tipos de paquetes. Algunos paquetes son independientes, lo que significa que funcionan con cualquier marco de PHP. Carbon y Pest son ejemplos de paquetes independientes. Cualquiera de estos paquetes se puede usar con Laravel requiriéndolos en tu archivo `composer.json`.
Por otro lado, otros paquetes están específicamente destinados para su uso con Laravel. Estos paquetes pueden tener rutas, controladores, vistas y configuraciones específicamente diseñadas para mejorar una aplicación Laravel. Esta guía cubre principalmente el desarrollo de aquellos paquetes que son específicos de Laravel.

<a name="a-note-on-facades"></a>
### Una Nota sobre Facades

Al escribir una aplicación Laravel, generalmente no importa si usas contratos o fachadas, ya que ambos ofrecen niveles de testabilidad esencialmente equivalentes. Sin embargo, al escribir paquetes, tu paquete no tendrá típicamente acceso a todos los helpers de prueba de Laravel. Si deseas poder escribir tus pruebas de paquete como si el paquete estuviera instalado dentro de una aplicación Laravel típica, puedes usar el paquete [Orchestral Testbench](https://github.com/orchestral/testbench).

<a name="package-discovery"></a>
## Descubrimiento de Paquetes

El archivo `bootstrap/providers.php` de una aplicación Laravel contiene la lista de proveedores de servicios que deben ser cargados por Laravel. Sin embargo, en lugar de requerir que los usuarios añadan manualmente tu proveedor de servicios a la lista, puedes definir el proveedor en la sección `extra` del archivo `composer.json` de tu paquete para que sea cargado automáticamente por Laravel. Además de los proveedores de servicios, también puedes listar cualquier [facade](/docs/%7B%7Bversion%7D%7D/facades) que te gustaría que fuera registrada:


```json
"extra": {
    "laravel": {
        "providers": [
            "Barryvdh\\Debugbar\\ServiceProvider"
        ],
        "aliases": {
            "Debugbar": "Barryvdh\\Debugbar\\Facade"
        }
    }
},

```
Una vez que tu paquete ha sido configurado para el descubrimiento, Laravel registrará automáticamente sus proveedores de servicios y fábricas cuando se instale, creando una experiencia de instalación conveniente para los usuarios de tu paquete.

<a name="opting-out-of-package-discovery"></a>
#### Optar por no participar en el descubrimiento de paquetes

Si eres el consumidor de un paquete y deseas desactivar el descubrimiento de paquetes para un paquete, puedes listar el nombre del paquete en la sección `extra` del archivo `composer.json` de tu aplicación:


```json
"extra": {
    "laravel": {
        "dont-discover": [
            "barryvdh/laravel-debugbar"
        ]
    }
},

```
Puedes desactivar el descubrimiento de paquetes para todos los paquetes utilizando el carácter `*` dentro de la directiva `dont-discover` de tu aplicación:


```json
"extra": {
    "laravel": {
        "dont-discover": [
            "*"
        ]
    }
},

```

<a name="service-providers"></a>
## Proveedores de Servicios

[Los proveedores de servicios](/docs/%7B%7Bversion%7D%7D/providers) son el punto de conexión entre tu paquete y Laravel. Un proveedor de servicios es responsable de enlazar elementos en el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel e informar a Laravel dónde cargar recursos del paquete como vistas, configuración y archivos de idioma.
Un proveedor de servicios extiende la clase `Illuminate\Support\ServiceProvider` y contiene dos métodos: `register` y `boot`. La clase `ServiceProvider` base se encuentra en el paquete Composer `illuminate/support`, que debes añadir a las dependencias de tu propio paquete. Para aprender más sobre la estructura y el propósito de los proveedores de servicios, consulta [su documentación](/docs/%7B%7Bversion%7D%7D/providers).

<a name="resources"></a>
## Recursos


<a name="configuration"></a>
### Configuración

Típicamente, necesitarás publicar el archivo de configuración de tu paquete en el directorio `config` de la aplicación. Esto permitirá a los usuarios de tu paquete anular fácilmente tus opciones de configuración predeterminadas. Para permitir que tus archivos de configuración sean publicados, llama al método `publishes` desde el método `boot` de tu proveedor de servicios:


```php
/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    $this->publishes([
        __DIR__.'/../config/courier.php' => config_path('courier.php'),
    ]);
}
```
Ahora, cuando los usuarios de tu paquete ejecuten el comando `vendor:publish` de Laravel, tu archivo será copiado a la ubicación de publicación especificada. Una vez que tu configuración haya sido publicada, sus valores se pueden acceder como cualquier otro archivo de configuración:


```php
$value = config('courier.option');
```
> [!WARNING]
No debes definir funciones anónimas en tus archivos de configuración. No pueden ser serializadas correctamente cuando los usuarios ejecutan el comando Artisan `config:cache`.

<a name="default-package-configuration"></a>
#### Configuración de Paquete Predeterminada

También puedes fusionar tu propio archivo de configuración de paquete con la copia publicada de la aplicación. Esto permitirá que tus usuarios definan solo las opciones que realmente desean sobrescribir en la copia publicada del archivo de configuración. Para fusionar los valores del archivo de configuración, utiliza el método `mergeConfigFrom` dentro del método `register` de tu proveedor de servicios.
El método `mergeConfigFrom` acepta la ruta al archivo de configuración de tu paquete como su primer argumento y el nombre de la copia del archivo de configuración de la aplicación como su segundo argumento:


```php
/**
 * Register any application services.
 */
public function register(): void
{
    $this->mergeConfigFrom(
        __DIR__.'/../config/courier.php', 'courier'
    );
}
```
> [!WARNING]
Este método solo fusiona el primer nivel del array de configuración. Si tus usuarios definen parcialmente un array de configuración multidimensional, las opciones faltantes no se fusionarán.

<a name="routes"></a>
### Rutas

Si tu paquete contiene rutas, puedes cargarlas utilizando el método `loadRoutesFrom`. Este método determinará automáticamente si las rutas de la aplicación están en caché y no cargará tu archivo de rutas si las rutas ya han sido almacenadas en caché:


```php
/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    $this->loadRoutesFrom(__DIR__.'/../routes/web.php');
}
```

<a name="migrations"></a>
### Migraciones

Si tu paquete contiene [migraciones de base de datos](/docs/%7B%7Bversion%7D%7D/migrations), puedes usar el método `publishesMigrations` para informar a Laravel que el directorio o archivo dado contiene migraciones. Cuando Laravel publique las migraciones, actualizará automáticamente la marca de tiempo dentro de su nombre de archivo para reflejar la fecha y hora actuales:


```php
/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    $this->publishesMigrations([
        __DIR__.'/../database/migrations' => database_path('migrations'),
    ]);
}
```

<a name="language-files"></a>
### Archivos de Idioma

Si tu paquete contiene [archivos de idioma](/docs/%7B%7Bversion%7D%7D/localization), puedes usar el método `loadTranslationsFrom` para informar a Laravel cómo cargarlos. Por ejemplo, si tu paquete se llama `courier`, deberías añadir lo siguiente al método `boot` de tu proveedor de servicios:


```php
/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    $this->loadTranslationsFrom(__DIR__.'/../lang', 'courier');
}
```
Las líneas de traducción del paquete se hacen referencia utilizando la convención de sintaxis `package::file.line`. Así que puedes cargar la línea `welcome` del paquete `courier` desde el archivo `messages` de esta manera:


```php
echo trans('courier::messages.welcome');
```
Puedes registrar archivos de traducción en JSON para tu paquete utilizando el método `loadJsonTranslationsFrom`. Este método acepta la ruta al directorio que contiene los archivos de traducción JSON de tu paquete:


```php
/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    $this->loadJsonTranslationsFrom(__DIR__.'/../lang');
}

```

<a name="publishing-language-files"></a>
#### Publicando Archivos de Idioma

Si deseas publicar los archivos de idioma de tu paquete en el directorio `lang/vendor` de la aplicación, puedes usar el método `publishes` del proveedor de servicios. El método `publishes` acepta un array de rutas de paquete y sus ubicaciones de publicación deseadas. Por ejemplo, para publicar los archivos de idioma para el paquete `courier`, puedes hacer lo siguiente:


```php
/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    $this->loadTranslationsFrom(__DIR__.'/../lang', 'courier');

    $this->publishes([
        __DIR__.'/../lang' => $this->app->langPath('vendor/courier'),
    ]);
}
```
Ahora, cuando los usuarios de tu paquete ejecuten el comando Artisan `vendor:publish` de Laravel, los archivos de idioma de tu paquete se publicarán en la ubicación de publicación especificada.

<a name="views"></a>
### Vistas

Para registrar las [vistas](/docs/%7B%7Bversion%7D%7D/views) de tu paquete con Laravel, necesitas indicar a Laravel dónde se encuentran las vistas. Puedes hacer esto utilizando el método `loadViewsFrom` del proveedor de servicios. El método `loadViewsFrom` acepta dos argumentos: la ruta a tus plantillas de vista y el nombre de tu paquete. Por ejemplo, si el nombre de tu paquete es `courier`, agregarías lo siguiente al método `boot` de tu proveedor de servicios:


```php
/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    $this->loadViewsFrom(__DIR__.'/../resources/views', 'courier');
}
```
Las vistas del paquete se hacen referencia utilizando la convención de sintaxis `package::view`. Así que, una vez que tu ruta de vista esté registrada en un proveedor de servicios, puedes cargar la vista `dashboard` del paquete `courier` de la siguiente manera:


```php
Route::get('/dashboard', function () {
    return view('courier::dashboard');
});
```

<a name="overriding-package-views"></a>
#### Sobrescribiendo Vistas de Paquetes

Cuando utilizas el método `loadViewsFrom`, Laravel en realidad registra dos ubicaciones para tus vistas: el directorio `resources/views/vendor` de la aplicación y el directorio que especificas. Así que, utilizando el paquete `courier` como ejemplo, Laravel primero verificará si una versión personalizada de la vista ha sido colocada en el directorio `resources/views/vendor/courier` por el desarrollador. Luego, si la vista no ha sido personalizada, Laravel buscará en el directorio de vistas del paquete que especificaste en tu llamada a `loadViewsFrom`. Esto facilita que los usuarios del paquete personalicen o sobrescriban las vistas de tu paquete.

<a name="publishing-views"></a>
#### Publicando Vistas

Si deseas hacer que tus vistas estén disponibles para su publicación en el directorio `resources/views/vendor` de la aplicación, puedes usar el método `publishes` del proveedor de servicios. El método `publishes` acepta un array de rutas de vista del paquete y sus ubicaciones de publicación deseadas:


```php
/**
 * Bootstrap the package services.
 */
public function boot(): void
{
    $this->loadViewsFrom(__DIR__.'/../resources/views', 'courier');

    $this->publishes([
        __DIR__.'/../resources/views' => resource_path('views/vendor/courier'),
    ]);
}
```
Ahora, cuando los usuarios de tu paquete ejecuten el comando Artisan `vendor:publish` de Laravel, las vistas de tu paquete se copiarán a la ubicación de publicación especificada.

<a name="view-components"></a>
### Componentes de Vista

Si estás creando un paquete que utiliza componentes Blade o coloca componentes en directorios no convencionales, necesitarás registrar manualmente tu clase de componente y su alias de etiqueta HTML para que Laravel sepa dónde encontrar el componente. Generalmente, deberías registrar tus componentes en el método `boot` del proveedor de servicios de tu paquete:


```php
use Illuminate\Support\Facades\Blade;
use VendorPackage\View\Components\AlertComponent;

/**
 * Bootstrap your package's services.
 */
public function boot(): void
{
    Blade::component('package-alert', AlertComponent::class);
}
```
Una vez que tu componente haya sido registrado, puede ser renderizado utilizando su alias de etiqueta:


```blade
<x-package-alert/>

```

<a name="autoloading-package-components"></a>
#### Autocarga de Componentes de Paquete

Alternativamente, puedes usar el método `componentNamespace` para autoload de clases de componentes por convención. Por ejemplo, un paquete `Nightshade` podría tener componentes `Calendar` y `ColorPicker` que residen dentro del espacio de nombres `Nightshade\Views\Components`:


```php
use Illuminate\Support\Facades\Blade;

/**
 * Bootstrap your package's services.
 */
public function boot(): void
{
    Blade::componentNamespace('Nightshade\\Views\\Components', 'nightshade');
}
```
Esto permitirá el uso de componentes de paquetes por su espacio de nombres de proveedor utilizando la sintaxis `package-name::`:


```blade
<x-nightshade::calendar />
<x-nightshade::color-picker />

```
Blade detectará automáticamente la clase que está vinculada a este componente utilizando la notación PascalCase en el nombre del componente. También se admiten subdirectorios utilizando la notación "punto".

<a name="anonymous-components"></a>
#### Componentes Anónimos

Si tu paquete contiene componentes anónimos, deben colocarse dentro de un directorio `components` del directorio "views" de tu paquete (como se especifica en el método [`loadViewsFrom`](#views)). Luego, puedes renderizarlos prefijando el nombre del componente con el espacio de nombres de la vista del paquete:


```blade
<x-courier::alert />

```

<a name="about-artisan-command"></a>
### Comando Artisan "About"

El comando Artisan `about` incorporado de Laravel proporciona un resumen del entorno y la configuración de la aplicación. Los paquetes pueden añadir información adicional a la salida de este comando a través de la clase `AboutCommand`. Típicamente, esta información se puede agregar desde el método `boot` del proveedor de servicios de tu paquete:


```php
use Illuminate\Foundation\Console\AboutCommand;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    AboutCommand::add('My Package', fn () => ['Version' => '1.0.0']);
}
```

<a name="commands"></a>
## Comandos

Para registrar los comandos Artisan de tu paquete con Laravel, puedes usar el método `commands`. Este método espera un array de nombres de clases de comando. Una vez que los comandos hayan sido registrados, puedes ejecutarlos utilizando la [Artisan CLI](/docs/%7B%7Bversion%7D%7D/artisan):


```php
use Courier\Console\Commands\InstallCommand;
use Courier\Console\Commands\NetworkCommand;

/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    if ($this->app->runningInConsole()) {
        $this->commands([
            InstallCommand::class,
            NetworkCommand::class,
        ]);
    }
}
```

<a name="public-assets"></a>
## Activos Públicos

Tu paquete puede tener activos como JavaScript, CSS e imágenes. Para publicar estos activos en el directorio `public` de la aplicación, utiliza el método `publishes` del proveedor de servicios. En este ejemplo, también añadiremos una etiqueta de grupo de activos `public`, que se puede usar para publicar fácilmente grupos de activos relacionados:


```php
/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    $this->publishes([
        __DIR__.'/../public' => public_path('vendor/courier'),
    ], 'public');
}
```
Ahora, cuando los usuarios de tu paquete ejecuten el comando `vendor:publish`, tus activos se copiarán a la ubicación de publicación especificada. Dado que los usuarios normalmente necesitarán sobrescribir los activos cada vez que se actualice el paquete, puedes usar el flag `--force`:


```shell
php artisan vendor:publish --tag=public --force

```

<a name="publishing-file-groups"></a>
## Publicación de Grupos de Archivos

Es posible que desees publicar grupos de activos y recursos del paquete de forma separada. Por ejemplo, es posible que desees permitir que tus usuarios publiquen los archivos de configuración de tu paquete sin verse obligados a publicar los activos de tu paquete. Puedes hacer esto "etiquetándolos" al llamar al método `publishes` desde un proveedor de servicios del paquete. Por ejemplo, usemos etiquetas para definir dos grupos de publicación para el paquete `courier` (`courier-config` y `courier-migrations`) en el método `boot` del proveedor de servicios del paquete:


```php
/**
 * Bootstrap any package services.
 */
public function boot(): void
{
    $this->publishes([
        __DIR__.'/../config/package.php' => config_path('package.php')
    ], 'courier-config');

    $this->publishesMigrations([
        __DIR__.'/../database/migrations/' => database_path('migrations')
    ], 'courier-migrations');
}
```
Ahora tus usuarios pueden publicar estos grupos por separado haciendo referencia a su etiqueta al ejecutar el comando `vendor:publish`:


```shell
php artisan vendor:publish --tag=courier-config

```