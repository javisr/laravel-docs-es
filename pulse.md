# Laravel Pulse

- [Introducción](#introduction)
- [Instalación](#installation)
    - [Configuración](#configuration)
- [Tablero](#dashboard)
    - [Autorización](#dashboard-authorization)
    - [Personalización](#dashboard-customization)
    - [Resolviendo Usuarios](#dashboard-resolving-users)
    - [Tarjetas](#dashboard-cards)
- [Capturando Entradas](#capturing-entries)
    - [Grabadores](#recorders)
    - [Filtrado](#filtering)
- [Rendimiento](#performance)
    - [Usando una Base de Datos Diferente](#using-a-different-database)
    - [Ingesta de Redis](#ingest)
    - [Muestreo](#sampling)
    - [Recorte](#trimming)
    - [Manejo de Excepciones de Pulse](#pulse-exceptions)
- [Tarjetas Personalizadas](#custom-cards)
    - [Componentes de Tarjeta](#custom-card-components)
    - [Estilo](#custom-card-styling)
    - [Captura y Agregación de Datos](#custom-card-data)

<a name="introduction"></a>
## Introducción

[Laravel Pulse](https://github.com/laravel/pulse) ofrece información instantánea sobre el rendimiento y uso de tu aplicación. Con Pulse, puedes rastrear cuellos de botella como trabajos y puntos finales lentos, encontrar a tus usuarios más activos y más.

Para una depuración en profundidad de eventos individuales, consulta [Laravel Telescope](/docs/{{version}}/telescope).

<a name="installation"></a>
## Instalación

> [!WARNING]  
> La implementación de almacenamiento de primera parte de Pulse actualmente requiere una base de datos MySQL, MariaDB o PostgreSQL. Si estás utilizando un motor de base de datos diferente, necesitarás una base de datos MySQL, MariaDB o PostgreSQL separada para tus datos de Pulse.

Puedes instalar Pulse utilizando el administrador de paquetes Composer:

```sh
composer require laravel/pulse
```

A continuación, debes publicar los archivos de configuración y migración de Pulse utilizando el comando Artisan `vendor:publish`:

```shell
php artisan vendor:publish --provider="Laravel\Pulse\PulseServiceProvider"
```

Finalmente, debes ejecutar el comando `migrate` para crear las tablas necesarias para almacenar los datos de Pulse:

```shell
php artisan migrate
```

Una vez que se hayan ejecutado las migraciones de la base de datos de Pulse, podrás acceder al tablero de Pulse a través de la ruta `/pulse`.

> [!NOTE]  
> Si no deseas almacenar los datos de Pulse en la base de datos principal de tu aplicación, puedes [especificar una conexión de base de datos dedicada](#using-a-different-database).

<a name="configuration"></a>
### Configuración

Muchas de las opciones de configuración de Pulse se pueden controlar utilizando variables de entorno. Para ver las opciones disponibles, registrar nuevos grabadores o configurar opciones avanzadas, puedes publicar el archivo de configuración `config/pulse.php`:

```sh
php artisan vendor:publish --tag=pulse-config
```

<a name="dashboard"></a>
## Tablero

<a name="dashboard-authorization"></a>
### Autorización

El tablero de Pulse se puede acceder a través de la ruta `/pulse`. Por defecto, solo podrás acceder a este tablero en el entorno `local`, por lo que necesitarás configurar la autorización para tus entornos de producción personalizando la puerta de autorización `'viewPulse'`. Puedes lograr esto dentro del archivo `app/Providers/AppServiceProvider.php` de tu aplicación:

```php
use App\Models\User;
use Illuminate\Support\Facades\Gate;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Gate::define('viewPulse', function (User $user) {
        return $user->isAdmin();
    });

    // ...
}
```

<a name="dashboard-customization"></a>
### Personalización

Las tarjetas y el diseño del tablero de Pulse se pueden configurar publicando la vista del tablero. La vista del tablero se publicará en `resources/views/vendor/pulse/dashboard.blade.php`:

```sh
php artisan vendor:publish --tag=pulse-dashboard
```

El tablero está impulsado por [Livewire](https://livewire.laravel.com/), y te permite personalizar las tarjetas y el diseño sin necesidad de reconstruir ningún activo de JavaScript.

Dentro de este archivo, el componente `<x-pulse>` es responsable de renderizar el tablero y proporciona un diseño de cuadrícula para las tarjetas. Si deseas que el tablero ocupe todo el ancho de la pantalla, puedes proporcionar la prop `full-width` al componente:

```blade
<x-pulse full-width>
    ...
</x-pulse>
```

Por defecto, el componente `<x-pulse>` creará una cuadrícula de 12 columnas, pero puedes personalizar esto utilizando la prop `cols`:

```blade
<x-pulse cols="16">
    ...
</x-pulse>
```

Cada tarjeta acepta una prop `cols` y `rows` para controlar el espacio y la posición:

```blade
<livewire:pulse.usage cols="4" rows="2" />
```

La mayoría de las tarjetas también aceptan una prop `expand` para mostrar la tarjeta completa en lugar de desplazarse:

```blade
<livewire:pulse.slow-queries expand />
```

<a name="dashboard-resolving-users"></a>
### Resolviendo Usuarios

Para las tarjetas que muestran información sobre tus usuarios, como la tarjeta de Uso de la Aplicación, Pulse solo registrará el ID del usuario. Al renderizar el tablero, Pulse resolverá los campos `name` y `email` de tu modelo `Authenticatable` predeterminado y mostrará avatares utilizando el servicio web Gravatar.

Puedes personalizar los campos y el avatar invocando el método `Pulse::user` dentro de la clase `App\Providers\AppServiceProvider` de tu aplicación.

El método `user` acepta una función anónima que recibirá el modelo `Authenticatable` que se mostrará y debe devolver un array que contenga información de `name`, `extra` y `avatar` para el usuario:

```php
use Laravel\Pulse\Facades\Pulse;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Pulse::user(fn ($user) => [
        'name' => $user->name,
        'extra' => $user->email,
        'avatar' => $user->avatar_url,
    ]);

    // ...
}
```

> [!NOTE]  
> Puedes personalizar completamente cómo se captura y recupera el usuario autenticado implementando el contrato `Laravel\Pulse\Contracts\ResolvesUsers` y vinculándolo en el [contenedor de servicios](/docs/{{version}}/container#binding-a-singleton) de Laravel.

<a name="dashboard-cards"></a>
### Tarjetas

<a name="servers-card"></a>
#### Servidores

La tarjeta `<livewire:pulse.servers />` muestra el uso de recursos del sistema para todos los servidores que ejecutan el comando `pulse:check`. Consulta la documentación sobre el [grabador de servidores](#servers-recorder) para obtener más información sobre el informe de recursos del sistema.

Si reemplazas un servidor en tu infraestructura, es posible que desees dejar de mostrar el servidor inactivo en el tablero de Pulse después de un tiempo determinado. Puedes lograr esto utilizando la prop `ignore-after`, que acepta el número de segundos después de los cuales los servidores inactivos deben ser eliminados del tablero de Pulse. Alternativamente, puedes proporcionar una cadena de tiempo relativa formateada, como `1 hora` o `3 días y 1 hora`:

```blade
<livewire:pulse.servers ignore-after="3 hours" />
```

<a name="application-usage-card"></a>
#### Uso de la Aplicación

La tarjeta `<livewire:pulse.usage />` muestra los 10 principales usuarios que realizan solicitudes a tu aplicación, despachan trabajos y experimentan solicitudes lentas.

Si deseas ver todas las métricas de uso en pantalla al mismo tiempo, puedes incluir la tarjeta varias veces y especificar el atributo `type`:

```blade
<livewire:pulse.usage type="requests" />
<livewire:pulse.usage type="slow_requests" />
<livewire:pulse.usage type="jobs" />
```

Para aprender cómo personalizar cómo Pulse recupera y muestra la información del usuario, consulta nuestra documentación sobre [resolviendo usuarios](#dashboard-resolving-users).

> [!NOTE]  
> Si tu aplicación recibe muchas solicitudes o despacha muchos trabajos, es posible que desees habilitar [muestreo](#sampling). Consulta la documentación sobre el [grabador de solicitudes de usuario](#user-requests-recorder), [grabador de trabajos de usuario](#user-jobs-recorder) y [grabador de trabajos lentos](#slow-jobs-recorder) para obtener más información.

<a name="exceptions-card"></a>
#### Excepciones

La tarjeta `<livewire:pulse.exceptions />` muestra la frecuencia y la reciente ocurrencia de excepciones en tu aplicación. Por defecto, las excepciones se agrupan según la clase de excepción y la ubicación donde ocurrió. Consulta la documentación sobre el [grabador de excepciones](#exceptions-recorder) para obtener más información.

<a name="queues-card"></a>
#### Colas

La tarjeta `<livewire:pulse.queues />` muestra el rendimiento de las colas en tu aplicación, incluyendo el número de trabajos en cola, en procesamiento, procesados, liberados y fallidos. Consulta la documentación sobre el [grabador de colas](#queues-recorder) para obtener más información.

<a name="slow-requests-card"></a>
#### Solicitudes Lentas

La tarjeta `<livewire:pulse.slow-requests />` muestra las solicitudes entrantes a tu aplicación que superan el umbral configurado, que es de 1,000ms por defecto. Consulta la documentación sobre el [grabador de solicitudes lentas](#slow-requests-recorder) para obtener más información.

<a name="slow-jobs-card"></a>
#### Trabajos Lentos

La tarjeta `<livewire:pulse.slow-jobs />` muestra los trabajos en cola en tu aplicación que superan el umbral configurado, que es de 1,000ms por defecto. Consulta la documentación sobre el [grabador de trabajos lentos](#slow-jobs-recorder) para obtener más información.

<a name="slow-queries-card"></a>
#### Consultas Lentas

La tarjeta `<livewire:pulse.slow-queries />` muestra las consultas a la base de datos en tu aplicación que superan el umbral configurado, que es de 1,000ms por defecto.

Por defecto, las consultas lentas se agrupan según la consulta SQL (sin enlaces) y la ubicación donde ocurrió, pero puedes optar por no capturar la ubicación si deseas agrupar únicamente por la consulta SQL.

Si encuentras problemas de rendimiento de renderizado debido a consultas SQL extremadamente grandes que reciben resaltado de sintaxis, puedes desactivar el resaltado agregando la prop `without-highlighting`:

```blade
<livewire:pulse.slow-queries without-highlighting />
```

Consulta la documentación sobre el [grabador de consultas lentas](#slow-queries-recorder) para obtener más información.

<a name="slow-outgoing-requests-card"></a>
#### Solicitudes Salientes Lentas

La tarjeta `<livewire:pulse.slow-outgoing-requests />` muestra las solicitudes salientes realizadas utilizando el [cliente HTTP](/docs/{{version}}/http-client) de Laravel que superan el umbral configurado, que es de 1,000ms por defecto.

Por defecto, las entradas se agruparán por la URL completa. Sin embargo, es posible que desees normalizar o agrupar solicitudes salientes similares utilizando expresiones regulares. Consulta la documentación sobre el [grabador de solicitudes salientes lentas](#slow-outgoing-requests-recorder) para obtener más información.

<a name="cache-card"></a>
#### Caché

La tarjeta `<livewire:pulse.cache />` muestra las estadísticas de aciertos y fallos de caché para tu aplicación, tanto a nivel global como para claves individuales.

Por defecto, las entradas se agruparán por clave. Sin embargo, es posible que desees normalizar o agrupar claves similares utilizando expresiones regulares. Consulta la documentación sobre el [grabador de interacciones de caché](#cache-interactions-recorder) para obtener más información.

<a name="capturing-entries"></a>
## Capturando Entradas

La mayoría de los grabadores de Pulse capturarán automáticamente entradas basadas en eventos del marco despachados por Laravel. Sin embargo, el [grabador de servidores](#servers-recorder) y algunas tarjetas de terceros deben sondear información regularmente. Para usar estas tarjetas, debes ejecutar el demonio `pulse:check` en todos tus servidores de aplicación individuales:

```php
php artisan pulse:check
```

> [!NOTE]  
> Para mantener el proceso `pulse:check` ejecutándose permanentemente en segundo plano, debes usar un monitor de procesos como Supervisor para asegurarte de que el comando no deje de ejecutarse.

Dado que el comando `pulse:check` es un proceso de larga duración, no verá cambios en tu base de código sin ser reiniciado. Debes reiniciar el comando de manera ordenada llamando al comando `pulse:restart` durante el proceso de implementación de tu aplicación:

```sh
php artisan pulse:restart
```

> [!NOTE]  
> Pulse utiliza la [caché](/docs/{{version}}/cache) para almacenar señales de reinicio, por lo que debes verificar que un controlador de caché esté configurado correctamente para tu aplicación antes de usar esta función.

<a name="recorders"></a>
### Grabadores

Los grabadores son responsables de capturar entradas de tu aplicación para ser registradas en la base de datos de Pulse. Los grabadores se registran y configuran en la sección `recorders` del [archivo de configuración de Pulse](#configuration).

<a name="cache-interactions-recorder"></a>
#### Interacciones de Caché

El grabador `CacheInteractions` captura información sobre los aciertos y fallos de la [caché](/docs/{{version}}/cache) que ocurren en tu aplicación para mostrarse en la tarjeta [Caché](#cache-card).

Puedes ajustar opcionalmente la [tasa de muestreo](#sampling) y los patrones de claves ignoradas.

También puedes configurar el agrupamiento de claves para que claves similares se agrupen como una sola entrada. Por ejemplo, es posible que desees eliminar IDs únicos de claves que almacenan el mismo tipo de información. Los grupos se configuran utilizando una expresión regular para "encontrar y reemplazar" partes de la clave. Un ejemplo se incluye en el archivo de configuración:

```php
Recorders\CacheInteractions::class => [
    // ...
    'groups' => [
        // '/:\d+/' => ':*',
    ],
],
```

El primer patrón que coincida se utilizará. Si no hay patrones que coincidan, entonces la clave se capturará tal cual.

<a name="exceptions-recorder"></a>
#### Excepciones

El grabador `Exceptions` captura información sobre excepciones reportables que ocurren en tu aplicación para mostrarse en la tarjeta [Excepciones](#exceptions-card).

Puedes ajustar opcionalmente la [tasa de muestreo](#sampling) y los patrones de excepciones ignoradas. También puedes configurar si capturar la ubicación de donde se originó la excepción. La ubicación capturada se mostrará en el tablero de Pulse, lo que puede ayudar a rastrear el origen de la excepción; sin embargo, si la misma excepción ocurre en múltiples ubicaciones, aparecerá múltiples veces para cada ubicación única.

<a name="queues-recorder"></a>
#### Colas

El grabador `Queues` captura información sobre las colas de tus aplicaciones para mostrarse en la tarjeta [Colas](#queues-card).

Puedes ajustar opcionalmente la [tasa de muestreo](#sampling) y los patrones de trabajos ignorados.

<a name="slow-jobs-recorder"></a>
#### Trabajos Lentos

El grabador `SlowJobs` captura información sobre trabajos lentos que ocurren en tu aplicación para mostrarse en la tarjeta [Trabajos Lentos](#slow-jobs-recorder).

Puedes ajustar opcionalmente el umbral de trabajos lentos, la [tasa de muestreo](#sampling) y los patrones de trabajos ignorados.

Es posible que tengas algunos trabajos que esperas que tomen más tiempo que otros. En esos casos, puedes configurar umbrales por trabajo:

```php
Recorders\SlowJobs::class => [
    // ...
    'threshold' => [
        '#^App\\Jobs\\GenerateYearlyReports$#' => 5000,
        'default' => env('PULSE_SLOW_JOBS_THRESHOLD', 1000),
    ],
],
```

Si no hay patrones de expresiones regulares que coincidan con el nombre de clase del trabajo, entonces se utilizará el valor `'default'`.

<a name="slow-outgoing-requests-recorder"></a>
#### Solicitudes Salientes Lentas

El grabador `SlowOutgoingRequests` captura información sobre solicitudes HTTP salientes realizadas utilizando el [cliente HTTP](/docs/{{version}}/http-client) de Laravel que superan el umbral configurado para mostrarse en la tarjeta [Solicitudes Salientes Lentas](#slow-outgoing-requests-card).

Puedes ajustar opcionalmente el umbral de solicitudes salientes lentas, la [tasa de muestreo](#sampling) y los patrones de URL ignorados.

Es posible que tengas algunas solicitudes salientes que esperas que tomen más tiempo que otras. En esos casos, puedes configurar umbrales por solicitud:

```php
Recorders\SlowOutgoingRequests::class => [
    // ...
    'threshold' => [
        '#backup.zip$#' => 5000,
        'default' => env('PULSE_SLOW_OUTGOING_REQUESTS_THRESHOLD', 1000),
    ],
],
```

Si no hay patrones de expresiones regulares que coincidan con la URL de la solicitud, entonces se utilizará el valor `'default'`.

También puedes configurar el agrupamiento de URL para que URLs similares se agrupen como una sola entrada. Por ejemplo, es posible que desees eliminar IDs únicos de las rutas de URL o agrupar solo por dominio. Los grupos se configuran utilizando una expresión regular para "encontrar y reemplazar" partes de la URL. Algunos ejemplos se incluyen en el archivo de configuración:

```php
Recorders\SlowOutgoingRequests::class => [
    // ...
    'groups' => [
        // '#^https://api\.github\.com/repos/.*$#' => 'api.github.com/repos/*',
        // '#^https?://([^/]*).*$#' => '\1',
        // '#/\d+#' => '/*',
    ],
],
```

El primer patrón que coincida se utilizará. Si no hay patrones que coincidan, entonces la URL se capturará tal cual.

<a name="slow-queries-recorder"></a>
#### Consultas Lentas

El grabador `SlowQueries` captura cualquier consulta a la base de datos en tu aplicación que supere el umbral configurado para mostrarse en la tarjeta [Consultas Lentas](#slow-queries-card).

Puedes ajustar opcionalmente el umbral de consultas lentas, la [tasa de muestreo](#sampling) y los patrones de consulta ignorados. También puedes configurar si capturar la ubicación de la consulta. La ubicación capturada se mostrará en el tablero de Pulse, lo que puede ayudar a rastrear el origen de la consulta; sin embargo, si la misma consulta se realiza en múltiples ubicaciones, aparecerá múltiples veces para cada ubicación única.

Puedes tener algunas consultas que esperas que tomen más tiempo que otras. En esos casos, puedes configurar umbrales por consulta:

```php
Recorders\SlowQueries::class => [
    // ...
    'threshold' => [
        '#^insert into `yearly_reports`#' => 5000,
        'default' => env('PULSE_SLOW_QUERIES_THRESHOLD', 1000),
    ],
],
```

Si no hay patrones de expresiones regulares que coincidan con el SQL de la consulta, se utilizará el valor `'default'`.

<a name="slow-requests-recorder"></a>
#### Solicitudes Lentas

El grabador de `Requests` captura información sobre las solicitudes realizadas a tu aplicación para mostrarlas en las tarjetas de [Solicitudes Lentas](#slow-requests-card) y [Uso de la Aplicación](#application-usage-card).

Puedes ajustar opcionalmente el umbral de ruta lenta, la [tasa de muestreo](#sampling) y las rutas ignoradas.

Puedes tener algunas solicitudes que esperas que tomen más tiempo que otras. En esos casos, puedes configurar umbrales por solicitud:

```php
Recorders\SlowRequests::class => [
    // ...
    'threshold' => [
        '#^/admin/#' => 5000,
        'default' => env('PULSE_SLOW_REQUESTS_THRESHOLD', 1000),
    ],
],
```

Si no hay patrones de expresiones regulares que coincidan con la URL de la solicitud, se utilizará el valor `'default'`.

<a name="servers-recorder"></a>
#### Servidores

El grabador de `Servers` captura el uso de CPU, memoria y almacenamiento de los servidores que alimentan tu aplicación para mostrarlos en la tarjeta de [Servidores](#servers-card). Este grabador requiere que el comando [`pulse:check`](#capturing-entries) se esté ejecutando en cada uno de los servidores que deseas monitorear.

Cada servidor que reporta debe tener un nombre único. Por defecto, Pulse utilizará el valor devuelto por la función `gethostname` de PHP. Si deseas personalizar esto, puedes establecer la variable de entorno `PULSE_SERVER_NAME`:

```env
PULSE_SERVER_NAME=load-balancer
```

El archivo de configuración de Pulse también te permite personalizar los directorios que se monitorean.

<a name="user-jobs-recorder"></a>
#### Trabajos de Usuario

El grabador de `UserJobs` captura información sobre los usuarios que despachan trabajos en tu aplicación para mostrarlos en la tarjeta de [Uso de la Aplicación](#application-usage-card).

Puedes ajustar opcionalmente la [tasa de muestreo](#sampling) y los patrones de trabajo ignorados.

<a name="user-requests-recorder"></a>
#### Solicitudes de Usuario

El grabador de `UserRequests` captura información sobre los usuarios que realizan solicitudes a tu aplicación para mostrarlas en la tarjeta de [Uso de la Aplicación](#application-usage-card).

Puedes ajustar opcionalmente la [tasa de muestreo](#sampling) y los patrones de trabajo ignorados.

<a name="filtering"></a>
### Filtrado

Como hemos visto, muchos [grabadores](#recorders) ofrecen la capacidad de, a través de la configuración, "ignorar" entradas entrantes basadas en su valor, como la URL de una solicitud. Pero, a veces puede ser útil filtrar registros basados en otros factores, como el usuario autenticado actualmente. Para filtrar estos registros, puedes pasar una función anónima al método `filter` de Pulse. Típicamente, el método `filter` debe ser invocado dentro del método `boot` de tu `AppServiceProvider` de la aplicación:

```php
use Illuminate\Support\Facades\Auth;
use Laravel\Pulse\Entry;
use Laravel\Pulse\Facades\Pulse;
use Laravel\Pulse\Value;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Pulse::filter(function (Entry|Value $entry) {
        return Auth::user()->isNotAdmin();
    });

    // ...
}
```

<a name="performance"></a>
## Rendimiento

Pulse ha sido diseñado para integrarse en una aplicación existente sin requerir infraestructura adicional. Sin embargo, para aplicaciones de alto tráfico, hay varias formas de eliminar cualquier impacto que Pulse pueda tener en el rendimiento de tu aplicación.

<a name="using-a-different-database"></a>
### Usando una Base de Datos Diferente

Para aplicaciones de alto tráfico, puedes preferir usar una conexión de base de datos dedicada para Pulse para evitar impactar la base de datos de tu aplicación.

Puedes personalizar la [conexión de base de datos](/docs/{{version}}/database#configuration) utilizada por Pulse estableciendo la variable de entorno `PULSE_DB_CONNECTION`.

```env
PULSE_DB_CONNECTION=pulse
```

<a name="ingest"></a>
### Ingesta de Redis

> [!WARNING]  
> La ingesta de Redis requiere Redis 6.2 o superior y `phpredis` o `predis` como el controlador de cliente Redis configurado de la aplicación.

Por defecto, Pulse almacenará entradas directamente en la [conexión de base de datos configurada](#using-a-different-database) después de que la respuesta HTTP haya sido enviada al cliente o un trabajo haya sido procesado; sin embargo, puedes usar el controlador de ingesta de Redis de Pulse para enviar entradas a un stream de Redis en su lugar. Esto se puede habilitar configurando la variable de entorno `PULSE_INGEST_DRIVER`:

```
PULSE_INGEST_DRIVER=redis
```

Pulse utilizará tu [conexión Redis](/docs/{{version}}/redis#configuration) por defecto, pero puedes personalizar esto a través de la variable de entorno `PULSE_REDIS_CONNECTION`:

```
PULSE_REDIS_CONNECTION=pulse
```

Al usar la ingesta de Redis, necesitarás ejecutar el comando `pulse:work` para monitorear el stream y mover entradas de Redis a las tablas de base de datos de Pulse.

```php
php artisan pulse:work
```

> [!NOTE]  
> Para mantener el proceso `pulse:work` ejecutándose permanentemente en segundo plano, debes usar un monitor de procesos como Supervisor para asegurarte de que el trabajador de Pulse no deje de ejecutarse.

Como el comando `pulse:work` es un proceso de larga duración, no verá cambios en tu base de código sin ser reiniciado. Debes reiniciar el comando de manera controlada llamando al comando `pulse:restart` durante el proceso de despliegue de tu aplicación:

```sh
php artisan pulse:restart
```

> [!NOTE]  
> Pulse utiliza la [cache](/docs/{{version}}/cache) para almacenar señales de reinicio, así que debes verificar que un controlador de cache esté configurado correctamente para tu aplicación antes de usar esta función.

<a name="sampling"></a>
### Muestreo

Por defecto, Pulse capturará cada evento relevante que ocurra en tu aplicación. Para aplicaciones de alto tráfico, esto puede resultar en la necesidad de agregar millones de filas de base de datos en el panel, especialmente para períodos de tiempo más largos.

Puedes optar por habilitar el "muestreo" en ciertos grabadores de datos de Pulse. Por ejemplo, establecer la tasa de muestreo en `0.1` en el grabador de [`Solicitudes de Usuario`](#user-requests-recorder) significará que solo registrarás aproximadamente el 10% de las solicitudes a tu aplicación. En el panel, los valores se escalarán y se prefijarán con un `~` para indicar que son una aproximación.

En general, cuanto más entradas tengas para una métrica particular, más bajo puedes establecer de manera segura la tasa de muestreo sin sacrificar demasiada precisión.

<a name="trimming"></a>
### Recorte

Pulse recortará automáticamente sus entradas almacenadas una vez que estén fuera de la ventana del panel. El recorte ocurre al ingerir datos utilizando un sistema de lotería que puede ser personalizado en el [archivo de configuración](#configuration) de Pulse.

<a name="pulse-exceptions"></a>
### Manejo de Excepciones de Pulse

Si ocurre una excepción mientras se captura datos de Pulse, como no poder conectarse a la base de datos de almacenamiento, Pulse fallará silenciosamente para evitar impactar tu aplicación.

Si deseas personalizar cómo se manejan estas excepciones, puedes proporcionar una función anónima al método `handleExceptionsUsing`:

```php
use Laravel\Pulse\Facades\Pulse;
use Illuminate\Support\Facades\Log;

Pulse::handleExceptionsUsing(function ($e) {
    Log::debug('An exception happened in Pulse', [
        'message' => $e->getMessage(),
        'stack' => $e->getTraceAsString(),
    ]);
});
```

<a name="custom-cards"></a>
## Tarjetas Personalizadas

Pulse te permite construir tarjetas personalizadas para mostrar datos relevantes a las necesidades específicas de tu aplicación. Pulse utiliza [Livewire](https://livewire.laravel.com), así que puede que desees [revisar su documentación](https://livewire.laravel.com/docs) antes de construir tu primera tarjeta personalizada.

<a name="custom-card-components"></a>
### Componentes de Tarjeta

Crear una tarjeta personalizada en Laravel Pulse comienza extendiendo el componente base `Card` de Livewire y definiendo una vista correspondiente:

```php
namespace App\Livewire\Pulse;

use Laravel\Pulse\Livewire\Card;
use Livewire\Attributes\Lazy;

#[Lazy]
class TopSellers extends Card
{
    public function render()
    {
        return view('livewire.pulse.top-sellers');
    }
}
```

Al usar la función de [carga diferida](https://livewire.laravel.com/docs/lazy) de Livewire, el componente `Card` proporcionará automáticamente un marcador de posición que respeta los atributos `cols` y `rows` pasados a tu componente.

Al escribir la vista correspondiente de tu tarjeta de Pulse, puedes aprovechar los componentes Blade de Pulse para una apariencia y sensación consistentes:

```blade
<x-pulse::card :cols="$cols" :rows="$rows" :class="$class" wire:poll.5s="">
    <x-pulse::card-header name="Top Sellers">
        <x-slot:icon>
            ...
        </x-slot:icon>
    </x-pulse::card-header>

    <x-pulse::scroll :expand="$expand">
        ...
    </x-pulse::scroll>
</x-pulse::card>
```

Las variables `$cols`, `$rows`, `$class` y `$expand` deben ser pasadas a sus respectivos componentes Blade para que el diseño de la tarjeta pueda ser personalizado desde la vista del panel. También puedes desear incluir el atributo `wire:poll.5s=""` en tu vista para que la tarjeta se actualice automáticamente.

Una vez que hayas definido tu componente Livewire y plantilla, la tarjeta puede ser incluida en tu [vista del panel](#dashboard-customization):

```blade
<x-pulse>
    ...

    <livewire:pulse.top-sellers cols="4" />
</x-pulse>
```

> [!NOTE]  
> Si tu tarjeta está incluida en un paquete, necesitarás registrar el componente con Livewire usando el método `Livewire::component`.

<a name="custom-card-styling"></a>
### Estilo

Si tu tarjeta requiere un estilo adicional más allá de las clases y componentes incluidos con Pulse, hay algunas opciones para incluir CSS personalizado para tus tarjetas.

<a name="custom-card-styling-vite"></a>
#### Integración de Laravel Vite

Si tu tarjeta personalizada vive dentro de la base de código de tu aplicación y estás usando la [integración de Vite](docs/{{version}}/vite), puedes actualizar tu archivo `vite.config.js` para incluir un punto de entrada CSS dedicado para tu tarjeta:

```js
laravel({
    input: [
        'resources/css/pulse/top-sellers.css',
        // ...
    ],
}),
```

Luego puedes usar la directiva Blade `@vite` en tu [vista del panel](#dashboard-customization), especificando el punto de entrada CSS para tu tarjeta:

```blade
<x-pulse>
    @vite('resources/css/pulse/top-sellers.css')

    ...
</x-pulse>
```

<a name="custom-card-styling-css"></a>
#### Archivos CSS

Para otros casos de uso, incluyendo tarjetas de Pulse contenidas dentro de un paquete, puedes instruir a Pulse para cargar hojas de estilo adicionales definiendo un método `css` en tu componente Livewire que devuelva la ruta del archivo CSS:

```php
class TopSellers extends Card
{
    // ...

    protected function css()
    {
        return __DIR__.'/../../dist/top-sellers.css';
    }
}
```

Cuando esta tarjeta se incluya en el panel, Pulse incluirá automáticamente el contenido de este archivo dentro de una etiqueta `<style>` para que no necesite ser publicado en el directorio `public`.

<a name="custom-card-styling-tailwind"></a>
#### Tailwind CSS

Al usar Tailwind CSS, debes crear un archivo de configuración de Tailwind dedicado para evitar cargar CSS innecesario o entrar en conflicto con las clases de Tailwind de Pulse:

```js
export default {
    darkMode: 'class',
    important: '#top-sellers',
    content: [
        './resources/views/livewire/pulse/top-sellers.blade.php',
    ],
    corePlugins: {
        preflight: false,
    },
};
```

Luego puedes especificar el archivo de configuración en tu punto de entrada CSS:

```css
@config "../../tailwind.top-sellers.config.js";
@tailwind base;
@tailwind components;
@tailwind utilities;
```

También necesitarás incluir un atributo `id` o `class` en la vista de tu tarjeta que coincida con el selector pasado a la [estrategia de selector `important`](https://tailwindcss.com/docs/configuration#selector-strategy) de Tailwind:

```blade
<x-pulse::card id="top-sellers" :cols="$cols" :rows="$rows" class="$class">
    ...
</x-pulse::card>
```

<a name="custom-card-data"></a>
### Captura y Agregación de Datos

Las tarjetas personalizadas pueden obtener y mostrar datos desde cualquier lugar; sin embargo, puedes desear aprovechar el poderoso y eficiente sistema de grabación y agregación de datos de Pulse.

<a name="custom-card-data-capture"></a>
#### Capturando Entradas

Pulse te permite registrar "entradas" usando el método `Pulse::record`:

```php
use Laravel\Pulse\Facades\Pulse;

Pulse::record('user_sale', $user->id, $sale->amount)
    ->sum()
    ->count();
```

El primer argumento proporcionado al método `record` es el `type` para la entrada que estás registrando, mientras que el segundo argumento es la `key` que determina cómo se debe agrupar los datos agregados. Para la mayoría de los métodos de agregación también necesitarás especificar un `value` que se agregará. En el ejemplo anterior, el valor que se está agregando es `$sale->amount`. Luego puedes invocar uno o más métodos de agregación (como `sum`) para que Pulse pueda capturar valores pre-agregados en "buckets" para una recuperación eficiente más tarde.

Los métodos de agregación disponibles son:

* `avg`
* `count`
* `max`
* `min`
* `sum`

> [!NOTE]  
> Al construir un paquete de tarjeta que captura el ID del usuario autenticado actualmente, debes usar el método `Pulse::resolveAuthenticatedUserId()`, que respeta cualquier [personalización del resolvedor de usuarios](#dashboard-resolving-users) realizada en la aplicación.

<a name="custom-card-data-retrieval"></a>
#### Recuperando Datos Agregados

Al extender el componente `Card` de Livewire de Pulse, puedes usar el método `aggregate` para recuperar datos agregados para el período que se está viendo en el panel:

```php
class TopSellers extends Card
{
    public function render()
    {
        return view('livewire.pulse.top-sellers', [
            'topSellers' => $this->aggregate('user_sale', ['sum', 'count']);
        ]);
    }
}
```

El método `aggregate` devuelve una colección de objetos `stdClass` de PHP. Cada objeto contendrá la propiedad `key` capturada anteriormente, junto con claves para cada uno de los agregados solicitados:

```
@foreach ($topSellers as $seller)
    {{ $seller->key }}
    {{ $seller->sum }}
    {{ $seller->count }}
@endforeach
```

Pulse recuperará principalmente datos de los buckets pre-agregados; por lo tanto, los agregados especificados deben haber sido capturados previamente usando el método `Pulse::record`. El cubo más antiguo típicamente caerá parcialmente fuera del período, por lo que Pulse agregará las entradas más antiguas para llenar el vacío y dar un valor preciso para todo el período, sin necesidad de agregar todo el período en cada solicitud de sondeo.

También puedes recuperar un valor total para un tipo dado usando el método `aggregateTotal`. Por ejemplo, el siguiente método recuperaría el total de todas las ventas de usuarios en lugar de agruparlas por usuario.

```php
$total = $this->aggregateTotal('user_sale', 'sum');
```

<a name="custom-card-displaying-users"></a>
#### Mostrando Usuarios

Al trabajar con agregados que registran un ID de usuario como clave, puedes resolver las claves a registros de usuario usando el método `Pulse::resolveUsers`:

```php
$aggregates = $this->aggregate('user_sale', ['sum', 'count']);

$users = Pulse::resolveUsers($aggregates->pluck('key'));

return view('livewire.pulse.top-sellers', [
    'sellers' => $aggregates->map(fn ($aggregate) => (object) [
        'user' => $users->find($aggregate->key),
        'sum' => $aggregate->sum,
        'count' => $aggregate->count,
    ])
]);
```

El método `find` devuelve un objeto que contiene las claves `name`, `extra` y `avatar`, que puedes pasar opcionalmente directamente al componente Blade `<x-pulse::user-card>`:

```blade
<x-pulse::user-card :user="{{ $seller->user }}" :stats="{{ $seller->sum }}" />
```

<a name="custom-recorders"></a>
#### Grabadores Personalizados

Los autores de paquetes pueden desear proporcionar clases de grabador para permitir a los usuarios configurar la captura de datos.

Los grabadores se registran en la sección `recorders` del archivo de configuración `config/pulse.php` de la aplicación:

```php
[
    // ...
    'recorders' => [
        Acme\Recorders\Deployments::class => [
            // ...
        ],

        // ...
    ],
]
```

Los grabadores pueden escuchar eventos especificando una propiedad `$listen`. Pulse registrará automáticamente los oyentes y llamará al método `record` de los grabadores:

```php
<?php

namespace Acme\Recorders;

use Acme\Events\Deployment;
use Illuminate\Support\Facades\Config;
use Laravel\Pulse\Facades\Pulse;

class Deployments
{
    /**
     * The events to listen for.
     *
     * @var array<int, class-string>
     */
    public array $listen = [
        Deployment::class,
    ];

    /**
     * Record the deployment.
     */
    public function record(Deployment $event): void
    {
        $config = Config::get('pulse.recorders.'.static::class);

        Pulse::record(
            // ...
        );
    }
}
```
