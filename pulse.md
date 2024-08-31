# Laravel Pulse

- [Introducción](#introduction)
- [Instalación](#installation)
  - [Configuración](#configuration)
- [Panel de control](#dashboard)
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
  - [Componentes de Tarjetas](#custom-card-components)
  - [Estilización](#custom-card-styling)
  - [Captura y Agregación de Datos](#custom-card-data)

<a name="introduction"></a>
## Introducción

[Laravel Pulse](https://github.com/laravel/pulse) ofrece una visión rápida del rendimiento y uso de tu aplicación. Con Pulse, puedes identificar cuellos de botella como trabajos y puntos finales lentos, encontrar a tus usuarios más activos y más.
Para una depuración exhaustiva de eventos individuales, consulta [Laravel Telescope](/docs/%7B%7Bversion%7D%7D/telescope).

<a name="installation"></a>
## Instalación

> [!WARNING]
La implementación de almacenamiento de primera parte de Pulse actualmente requiere una base de datos MySQL, MariaDB o PostgreSQL. Si estás utilizando un motor de base de datos diferente, necesitarás una base de datos MySQL, MariaDB o PostgreSQL por separado para tus datos de Pulse.
Puedes instalar Pulse usando el gestor de paquetes Composer:


```sh
composer require laravel/pulse

```
A continuación, deberías publicar los archivos de configuración y migración de Pulse utilizando el comando Artisan `vendor:publish`:


```shell
php artisan vendor:publish --provider="Laravel\Pulse\PulseServiceProvider"

```
Finalmente, debes ejecutar el comando `migrate` para crear las tablas necesarias para almacenar los datos de Pulse:


```shell
php artisan migrate

```
Una vez que se hayan ejecutado las migraciones de la base de datos de Pulse, puedes acceder al dashboard de Pulse a través de la ruta `/pulse`.
> [!NOTA]
Si no deseas almacenar los datos de Pulse en la base de datos principal de tu aplicación, puedes [especificar una conexión a una base de datos dedicada](#using-a-different-database).

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

El dashboard de Pulse se puede acceder a través de la ruta `/pulse`. Por defecto, solo podrás acceder a este dashboard en el entorno `local`, por lo que necesitarás configurar la autorización para tus entornos de producción personalizando el gate de autorización `'viewPulse'`. Puedes lograr esto dentro del archivo `app/Providers/AppServiceProvider.php` de tu aplicación:


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

Las tarjetas y el diseño del dashboard de Pulse pueden configurarse publicando la vista del dashboard. La vista del dashboard se publicará en `resources/views/vendor/pulse/dashboard.blade.php`:


```sh
php artisan vendor:publish --tag=pulse-dashboard

```
El panel de control está impulsado por [Livewire](https://livewire.laravel.com/), y te permite personalizar las tarjetas y el diseño sin necesidad de reconstruir ningún recurso de JavaScript.
Dentro de este archivo, el componente `<x-pulse>` es responsable de renderizar el panel y proporciona un diseño de cuadrícula para las tarjetas. Si deseas que el panel ocupe todo el ancho de la pantalla, puedes proporcionar la prop `full-width` al componente:


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
### Resolución de Usuarios

Para las tarjetas que muestran información sobre tus usuarios, como la tarjeta de Uso de la Aplicación, Pulse solo registrará la ID del usuario. Al renderizar el panel, Pulse resolverá los campos `name` y `email` de tu modelo `Authenticatable` predeterminado y mostrará avatares utilizando el servicio web Gravatar.
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
Puedes personalizar completamente cómo se captura y recupera el usuario autenticado implementando el contrato `Laravel\Pulse\Contracts\ResolvesUsers` y vinculándolo en el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container#binding-a-singleton) de Laravel.

<a name="dashboard-cards"></a>
### Tarjetas


<a name="servers-card"></a>
La tarjeta `<livewire:pulse.servers />` muestra el uso de recursos del sistema para todos los servidores que ejecutan el comando `pulse:check`. Por favor, consulta la documentación sobre el [grabador de servidores](#servers-recorder) para obtener más información sobre el informe de recursos del sistema.
Si reemplazas un servidor en tu infraestructura, es posible que desees dejar de mostrar el servidor inactivo en el tablero de Pulse después de una duración determinada. Puedes lograr esto utilizando la prop `ignore-after`, que acepta el número de segundos después de los cuales los servidores inactivos deben ser eliminados del tablero de Pulse. Alternativamente, puedes proporcionar una cadena de tiempo relativa formateada, como `1 hora` o `3 días y 1 hora`:


```blade
<livewire:pulse.servers ignore-after="3 hours" />

```

<a name="application-usage-card"></a>
#### Uso de la Aplicación

La tarjeta `<livewire:pulse.usage />` muestra los 10 principales usuarios que realizan solicitudes a tu aplicación, despachando trabajos y experimentando solicitudes lentas.
Si deseas ver todas las métricas de uso en pantalla al mismo tiempo, puedes incluir la tarjeta múltiples veces y especificar el atributo `type`:


```blade
<livewire:pulse.usage type="requests" />
<livewire:pulse.usage type="slow_requests" />
<livewire:pulse.usage type="jobs" />

```
Para aprender cómo personalizar la forma en que Pulse recupera y muestra la información del usuario, consulta nuestra documentación sobre [resolución de usuarios](#dashboard-resolving-users).
> [!NOTE]
Si tu aplicación recibe muchas solicitudes o despacha muchos trabajos, es posible que desees habilitar [muestreo](#sampling). Consulta la documentación del [grabador de solicitudes de usuario](#user-requests-recorder), [grabador de trabajos de usuario](#user-jobs-recorder) y [grabador de trabajos lentos](#slow-jobs-recorder) para obtener más información.

<a name="exceptions-card"></a>
La tarjeta `<livewire:pulse.exceptions />` muestra la frecuencia y la recencia de las excepciones que ocurren en tu aplicación. Por defecto, las excepciones se agrupan según la clase de excepción y la ubicación donde ocurrió. Consulta la documentación del [grabador de excepciones](#exceptions-recorder) para obtener más información.

<a name="queues-card"></a>
La card `<livewire:pulse.queues />` muestra el rendimiento de las colas en tu aplicación, incluyendo el número de trabajos en cola, en procesamiento, procesados, liberados y fallidos. Consulta la documentación del [grabador de colas](#queues-recorder) para obtener más información.

<a name="slow-requests-card"></a>
La tarjeta `<livewire:pulse.slow-requests />` muestra las solicitudes entrantes a tu aplicación que superan el umbral configurado, que es de 1,000 ms por defecto. Consulta la documentación del [grabador de solicitudes lentas](#slow-requests-recorder) para obtener más información.

<a name="slow-jobs-card"></a>
La tarjeta `<livewire:pulse.slow-jobs />` muestra los trabajos en cola en tu aplicación que superan el umbral configurado, que es de 1,000 ms por defecto. Consulta la documentación del [grabador de trabajos lentos](#slow-jobs-recorder) para más información.

<a name="slow-queries-card"></a>
La tarjeta `<livewire:pulse.slow-queries />` muestra las consultas a la base de datos en tu aplicación que exceden el umbral configurado, que es de 1,000 ms por defecto.
Por defecto, las consultas lentas se agrupan según la consulta SQL (sin enlaces) y la ubicación donde ocurrieron, pero puedes optar por no capturar la ubicación si deseas agrupar solo en la consulta SQL.
Si encuentras problemas de rendimiento de representación debido a consultas SQL extremadamente grandes que reciben resaltado de sintaxis, puedes desactivar el resaltado añadiendo el prop `without-highlighting`:


```blade
<livewire:pulse.slow-queries without-highlighting />

```
Consulta la documentación del [grabador de consultas lentas](#slow-queries-recorder) para obtener más información.

<a name="slow-outgoing-requests-card"></a>
La tarjeta `<livewire:pulse.slow-outgoing-requests />` muestra las solicitudes salientes realizadas utilizando el [cliente HTTP](/docs/%7B%7Bversion%7D%7D/http-client) de Laravel que superan el umbral configurado, que es de 1,000 ms por defecto.
Por defecto, las entradas se agruparán por la URL completa. Sin embargo, es posible que desees normalizar o agrupar solicitudes salientes similares utilizando expresiones regulares. Consulta la documentación del [grabador de solicitudes salientes lentas](#slow-outgoing-requests-recorder) para obtener más información.

<a name="cache-card"></a>
#### Caché

La tarjeta `<livewire:pulse.cache />` muestra las estadísticas de aciertos y fallos de caché para tu aplicación, tanto de forma global como para claves individuales.
Por defecto, las entradas se agruparán por clave. Sin embargo, es posible que desees normalizar o agrupar claves similares utilizando expresiones regulares. Consulta la documentación del [grabador de interacciones de caché](#cache-interactions-recorder) para obtener más información.

<a name="capturing-entries"></a>
## Capturando Entradas

La mayoría de los grabadores de Pulse capturarán automáticamente las entradas basadas en eventos de framework despachados por Laravel. Sin embargo, el [grabador de servidores](#servers-recorder) y algunas tarjetas de terceros deben sondear información de manera regular. Para usar estas tarjetas, debes ejecutar el daemon `pulse:check` en todos tus servidores de aplicación individuales:


```php
php artisan pulse:check

```
> [!NOTA]
Para mantener el proceso `pulse:check` en ejecución de forma permanente en segundo plano, debes usar un monitor de procesos como Supervisor para asegurar que el comando no deje de ejecutarse.
Dado que el comando `pulse:check` es un proceso de larga duración, no verá cambios en tu base de código sin ser reiniciado. Debes reiniciar el comando de manera controlada llamando al comando `pulse:restart` durante el proceso de despliegue de tu aplicación:

<a name="recorders"></a>
### Grabadores

Los grabadores son responsables de capturar las entradas de tu aplicación para ser registradas en la base de datos de Pulse. Los grabadores se registran y configuran en la sección `recorders` del [archivo de configuración de Pulse](#configuration).

<a name="cache-interactions-recorder"></a>
#### Interacciones de Caché

El grabador `CacheInteractions` captura información sobre los aciertos y fallos de [caché](/docs/%7B%7Bversion%7D%7D/cache) que ocurren en tu aplicación para su visualización en la tarjeta [Cache](#cache-card).
Puedes ajustar opcionalmente la [tasa de muestreo](#sampling) y los patrones de clave ignorados.
También puedes configurar el agrupamiento de claves para que claves similares se agrupen como una sola entrada. Por ejemplo, es posible que desees eliminar ID únicos de claves que almacenan el mismo tipo de información. Los grupos se configuran utilizando una expresión regular para "buscar y reemplazar" partes de la clave. Se incluye un ejemplo en el archivo de configuración:


```php
Recorders\CacheInteractions::class => [
    // ...
    'groups' => [
        // '/:\d+/' => ':*',
    ],
],

```
El primer patrón que coincida será utilizado. Si no coinciden patrones, entonces la clave será capturada tal como está.

<a name="exceptions-recorder"></a>
#### Excepciones

El grabador de `Exceptions` captura información sobre las excepciones reportables que ocurren en tu aplicación para su visualización en la tarjeta de [Exceptions](#exceptions-card).
Puedes ajustar opcionalmente la [tasa de muestreo](#sampling) y los patrones de excepciones ignoradas. También puedes configurar si deseas capturar la ubicación de donde se originó la excepción. La ubicación capturada se mostrará en el panel de Pulse, lo que puede ayudar a rastrear el origen de la excepción; sin embargo, si la misma excepción ocurre en múltiples ubicaciones, aparecerá múltiples veces para cada ubicación única.

<a name="queues-recorder"></a>
#### Colas

El grabador `Queues` captura información sobre las colas de tus aplicaciones para su visualización en el [Queues](#queues-card).
Puedes ajustar opcionalmente la [tasa de muestreo](#sampling) y los patrones de trabajos ignorados.

<a name="slow-jobs-recorder"></a>
#### Trabajos Lentos

El grabador `SlowJobs` captura información sobre trabajos lentos que ocurren en tu aplicación para su visualización en la tarjeta [Slow Jobs](#slow-jobs-recorder).
Puedes ajustar opcionalmente el umbral de trabajos lentos, la [frecuencia de muestreo](#sampling) y los patrones de trabajos ignorados.
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
Si no hay patrones de expresión regular que coincidan con el nombre de clase del trabajo, entonces se utilizará el valor `'default'`.

<a name="slow-outgoing-requests-recorder"></a>
#### Solicitudes Salientes Lentas

El registrador `SlowOutgoingRequests` captura información sobre las solicitudes HTTP salientes realizadas utilizando el [cliente HTTP](/docs/%7B%7Bversion%7D%7D/http-client) de Laravel que superan el umbral configurado para su visualización en la tarjeta de [Solicitudes Salientes Lentas](#slow-outgoing-requests-card).
Puedes ajustar opcionalmente el umbral de solicitud saliente lenta, la [tasa de muestreo](#sampling) y los patrones de URL ignorados.
Puede que tengas algunas solicitudes salientes que esperas que tomen más tiempo que otras. En esos casos, puedes configurar umbrales por solicitud:


```php
Recorders\SlowOutgoingRequests::class => [
    // ...
    'threshold' => [
        '#backup.zip$#' => 5000,
        'default' => env('PULSE_SLOW_OUTGOING_REQUESTS_THRESHOLD', 1000),
    ],
],

```
También puedes configurar el agrupamiento de URL para que las URL similares se agrupen como una sola entrada. Por ejemplo, es posible que desees eliminar identificadores únicos de las rutas de URL o agrupar solo por dominio. Los grupos se configuran utilizando una expresión regular para "encontrar y reemplazar" partes de la URL. Algunos ejemplos se incluyen en el archivo de configuración:


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
El primer patrón que coincida será utilizado. Si no coinciden patrones, entonces la URL será capturada tal como está.

<a name="slow-queries-recorder"></a>
#### Consultas Lentas

El grabador `SlowQueries` captura cualquier consulta a la base de datos en tu aplicación que supere el umbral configurado para su visualización en la tarjeta de [Consultas Lentas](#slow-queries-card).
Puedes ajustar opcionalmente el umbral de consulta lenta, la [tasa de muestreo](#sampling) y los patrones de consulta ignorados. También puedes configurar si deseas capturar la ubicación de la consulta. La ubicación capturada se mostrará en el panel de Pulse, lo que puede ayudar a rastrear el origen de la consulta; sin embargo, si se realiza la misma consulta en múltiples ubicaciones, aparecerá múltiples veces por cada ubicación única.
Es posible que tengas algunas consultas que esperas que tomen más tiempo que otras. En esos casos, puedes configurar umbrales por consulta:


```php
Recorders\SlowQueries::class => [
    // ...
    'threshold' => [
        '#^insert into `yearly_reports`#' => 5000,
        'default' => env('PULSE_SLOW_QUERIES_THRESHOLD', 1000),
    ],
],

```
Si no coinciden patrones de expresión regular con el SQL de la consulta, entonces se utilizará el valor `'default'`.

<a name="slow-requests-recorder"></a>
#### Solicitudes Lentas

El grabador de `Requests` captura información sobre las solicitudes realizadas a tu aplicación para su visualización en las tarjetas [Solicitudes Lentas](#slow-requests-card) y [Uso de la Aplicación](#application-usage-card).
Puedes ajustar opcionalmente el umbral de la ruta lenta, la [tasa de muestreo](#sampling) y las rutas ignoradas.
Es posible que tengas algunas solicitudes que esperas que tarden más que otras. En esos casos, puedes configurar umbrales por solicitud:


```php
Recorders\SlowRequests::class => [
    // ...
    'threshold' => [
        '#^/admin/#' => 5000,
        'default' => env('PULSE_SLOW_REQUESTS_THRESHOLD', 1000),
    ],
],

```
Si no hay patrones de expresión regular que coincidan con la URL de la solicitud, entonces se utilizará el valor `'default'`.

<a name="servers-recorder"></a>
#### Servidores

El grabador `Servers` captura el uso de CPU, memoria y almacenamiento de los servidores que impulsan tu aplicación para mostrarse en la tarjeta [Servers](#servers-card). Este grabador requiere que el comando [`pulse:check`](#capturing-entries) esté en ejecución en cada uno de los servidores que deseas monitorear.
Cada servidor de informes debe tener un nombre único. Por defecto, Pulse utilizará el valor devuelto por la función `gethostname` de PHP. Si deseas personalizar esto, puedes establecer la variable de entorno `PULSE_SERVER_NAME`:


```env
PULSE_SERVER_NAME=load-balancer

```
El archivo de configuración de Pulse también te permite personalizar los directorios que se supervisan.

<a name="user-jobs-recorder"></a>
#### Trabajos de Usuario

El registrador `UserJobs` captura información sobre los usuarios que despachan trabajos en tu aplicación para su visualización en el card [Uso de la Aplicación](#application-usage-card).

<a name="user-requests-recorder"></a>
#### Solicitudes de Usuario

El grabador `UserRequests` captura información sobre los usuarios que realizan solicitudes a tu aplicación para su visualización en la tarjeta [Application Usage](#application-usage-card).
Puedes ajustar opcionalmente el [tasa de muestreo](#sampling) y los patrones de trabajo ignorados.

<a name="filtering"></a>
### Filtrado

Como hemos visto, muchos [grabadores](#recorders) ofrecen la capacidad de, a través de la configuración, "ignorar" entradas entrantes en función de su valor, como la URL de una solicitud. Pero, a veces puede ser útil filtrar registros en función de otros factores, como el usuario autenticado actualmente. Para filtrar estos registros, puedes pasar una función anónima al método `filter` de Pulse. Típicamente, el método `filter` debe invocarse dentro del método `boot` del `AppServiceProvider` de tu aplicación:


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

Para aplicaciones de alto tráfico, es posible que prefieras usar una conexión de base de datos dedicada para Pulse para evitar afectar la base de datos de tu aplicación.
Puedes personalizar la [conexión a la base de datos](/docs/%7B%7Bversion%7D%7D/database#configuration) utilizada por Pulse configurando la variable de entorno `PULSE_DB_CONNECTION`.


```env
PULSE_DB_CONNECTION=pulse

```

<a name="ingest"></a>
### Ingesta de Redis

> [!WARNING]
El Ingesta de Redis requiere Redis 6.2 o superior y `phpredis` o `predis` como el driver del cliente Redis configurado de la aplicación.
Por defecto, Pulse almacenará las entradas directamente en la [conexión a la base de datos configurada](#using-a-different-database) después de que se haya enviado la respuesta HTTP al cliente o se haya procesado un trabajo; sin embargo, puedes usar el driver de ingestión de Redis de Pulse para enviar las entradas a un flujo de Redis en su lugar. Esto se puede habilitar configurando la variable de entorno `PULSE_INGEST_DRIVER`:


```
PULSE_INGEST_DRIVER=redis

```
Pulse utilizará tu [conexión Redis](/docs/%7B%7Bversion%7D%7D/redis#configuration) predeterminada por defecto, pero puedes personalizar esto a través de la variable de entorno `PULSE_REDIS_CONNECTION`:


```
PULSE_REDIS_CONNECTION=pulse

```
Al utilizar la ingestión de Redis, necesitarás ejecutar el comando `pulse:work` para supervisar el flujo y mover las entradas de Redis a las tablas de la base de datos de Pulse.


```php
php artisan pulse:work

```
> [!NOTA]
Para mantener el proceso `pulse:work` funcionando de manera permanente en segundo plano, debes usar un monitor de procesos como Supervisor para asegurarte de que el trabajador de Pulse no deje de funcionar.
Como el comando `pulse:work` es un proceso de larga duración, no verá cambios en tu base de código sin ser reiniciado. Debes reiniciar el comando de manera elegante llamando al comando `pulse:restart` durante el proceso de despliegue de tu aplicación:


```sh
php artisan pulse:restart

```
> [!NOTA]
Pulse utiliza la [cache](/docs/%7B%7Bversion%7D%7D/cache) para almacenar señales de reinicio, así que debes verificar que un driver de caché esté configurado correctamente para tu aplicación antes de usar esta función.

<a name="sampling"></a>
### Muestreo

Por defecto, Pulse capturará cada evento relevante que ocurra en tu aplicación. Para aplicaciones de alto tráfico, esto puede resultar en la necesidad de agregar millones de filas de base de datos en el panel, especialmente para períodos de tiempo más largos.
Puedes elegir activar "muestreo" en ciertos grabadores de datos Pulse. Por ejemplo, configurar la tasa de muestreo a `0.1` en el grabador [`User Requests`](#user-requests-recorder) significará que solo grabas aproximadamente el 10% de las solicitudes a tu aplicación. En el panel de control, los valores se escalarán y se les añadirá un `~` para indicar que son una aproximación.
En general, cuanto más entradas tengas para una métrica particular, más bajo puedes ajustar la tasa de muestreo sin sacrificar demasiada precisión.

<a name="trimming"></a>
### Recortando

Pulse recortará automáticamente sus entradas almacenadas una vez que estén fuera de la ventana del panel. El recorte ocurre al ingerir datos utilizando un sistema de lotería que se puede personalizar en el archivo de [configuración](#configuration) de Pulse.

<a name="pulse-exceptions"></a>
### Manejo de Excepciones de Pulse

Si ocurre una excepción al capturar datos de Pulse, como no poder conectarse a la base de datos de almacenamiento, Pulse fallará en silencio para evitar afectar tu aplicación.
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

Pulse te permite crear tarjetas personalizadas para mostrar datos relevantes a las necesidades específicas de tu aplicación. Pulse utiliza [Livewire](https://livewire.laravel.com), así que es posible que desees [revisar su documentación](https://livewire.laravel.com/docs) antes de construir tu primera tarjeta personalizada.

<a name="custom-card-components"></a>
### Componentes de Tarjeta

Crear una tarjeta personalizada en Laravel Pulse comienza con extender el componente Livewire `Card` base y definiendo una vista correspondiente:


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
Al utilizar la función de [carga perezosa](https://livewire.laravel.com/docs/lazy) de Livewire, el componente `Card` proporcionará automáticamente un marcador de posición que respeta los atributos `cols` y `rows` pasados a tu componente.
Al escribir la vista correspondiente de tu tarjeta Pulse, puedes aprovechar los componentes Blade de Pulse para un aspecto y una sensación consistentes:


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
Las variables `$cols`, `$rows`, `$class` y `$expand` deben pasarse a sus respectivos componentes Blade para que el diseño de la tarjeta pueda personalizarse desde la vista del panel de control. También es posible que desees incluir el atributo `wire:poll.5s=""` en tu vista para que la tarjeta se actualice automáticamente.
Una vez que hayas definido tu componente Livewire y plantilla, la tarjeta puede incluirse en tu [vista de dashboard](#dashboard-customization):


```blade
<x-pulse>
    ...

    <livewire:pulse.top-sellers cols="4" />
</x-pulse>

```
> [!NOTE]
Si tu tarjeta está incluida en un paquete, necesitarás registrar el componente con Livewire utilizando el método `Livewire::component`.

<a name="custom-card-styling"></a>
### Estilizando

Si tu tarjeta requiere un estilo adicional más allá de las clases y componentes incluidos con Pulse, hay algunas opciones para incluir CSS personalizado para tus tarjetas.

<a name="custom-card-styling-vite"></a>
#### Integración de Laravel Vite

Si tu tarjeta personalizada vive dentro de la base de código de tu aplicación y estás utilizando la [integración de Vite](/docs/%7B%7Bversion%7D%7D/vite) de Laravel, puedes actualizar tu archivo `vite.config.js` para incluir un punto de entrada CSS dedicado para tu tarjeta:


```js
laravel({
    input: [
        'resources/css/pulse/top-sellers.css',
        // ...
    ],
}),

```
Ahora puedes usar la directiva Blade `@vite` en tu [vista del panel](#dashboard-customization), especificando el punto de entrada CSS para tu tarjeta:


```blade
<x-pulse>
    @vite('resources/css/pulse/top-sellers.css')

    ...
</x-pulse>

```

<a name="custom-card-styling-css"></a>
#### Archivos CSS

Para otros casos de uso, incluidos los cards de Pulse contenidos dentro de un paquete, puedes instruir a Pulse para que cargue hojas de estilo adicionales definiendo un método `css` en tu componente de Livewire que devuelva la ruta del archivo a tu archivo CSS:


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
Cuando esta tarjeta se incluye en el panel, Pulse incluirá automáticamente el contenido de este archivo dentro de una etiqueta `<style>`, por lo que no es necesario publicarlo en el directorio `public`.

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
Entonces, puedes especificar el archivo de configuración en tu punto de entrada CSS:


```css
@config "../../tailwind.top-sellers.config.js";
@tailwind base;
@tailwind components;
@tailwind utilities;

```
También necesitarás incluir un atributo `id` o `class` en la vista de tu tarjeta que coincida con el selector pasado a la estrategia de selección [`important`](https://tailwindcss.com/docs/configuration#selector-strategy) de Tailwind:


```blade
<x-pulse::card id="top-sellers" :cols="$cols" :rows="$rows" class="$class">
    ...
</x-pulse::card>

```

<a name="custom-card-data"></a>
### Captura y Agregación de Datos

Las tarjetas personalizadas pueden obtener y mostrar datos desde cualquier lugar; sin embargo, es posible que desees aprovechar el poderoso y eficiente sistema de grabación y agregación de datos de Pulse.

<a name="custom-card-data-capture"></a>
#### Capturando Entradas

Pulse te permite registrar "entradas" utilizando el método `Pulse::record`:


```php
use Laravel\Pulse\Facades\Pulse;

Pulse::record('user_sale', $user->id, $sale->amount)
    ->sum()
    ->count();

```
El primer argumento proporcionado al método `record` es el `type` para la entrada que estás registrando, mientras que el segundo argumento es la `key` que determina cómo se deben agrupar los datos agregados. Para la mayoría de los métodos de agregación, también necesitarás especificar un `value` que se agregará. En el ejemplo anterior, el valor que se está agregando es `$sale->amount`. Luego puedes invocar uno o más métodos de agregación (como `sum`) para que Pulse pueda capturar los valores pre-agregados en "cubos" para una recuperación eficiente más adelante.
Los métodos de agregación disponibles son:
* `avg`
* `count`
* `max`
* `min`
* `sum`
> [!NOTA]
Al construir un paquete de tarjeta que captura la ID del usuario autenticado actualmente, debes usar el método `Pulse::resolveAuthenticatedUserId()`, que respeta cualquier [personalización del resolutor de usuarios](#dashboard-resolving-users) realizada en la aplicación.

<a name="custom-card-data-retrieval"></a>
#### Recuperando Datos Agregados

Al extender el componente `Card` de Livewire de Pulse, puedes usar el método `aggregate` para recuperar datos agregados para el periodo que se está viendo en el panel:


```php
class TopSellers extends Card
{
    public function render()
    {
        return view('livewire.pulse.top-sellers', [
            'topSellers' => $this->aggregate('user_sale', ['sum', 'count'])
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
Pulse recuperará principalmente datos de los cubos pre-agregados; por lo tanto, los agregados especificados deben haber sido capturados desde el inicio utilizando el método `Pulse::record`. El cubo más antiguo típicamente caerá parcialmente fuera del período, por lo que Pulse agregará las entradas más antiguas para llenar el vacío y dar un valor preciso para todo el período, sin necesidad de agregar todo el período en cada solicitud de sondeo.
También puedes recuperar un valor total para un tipo dado utilizando el método `aggregateTotal`. Por ejemplo, el siguiente método obtendría el total de todas las ventas de usuarios en lugar de agruparlas por usuario.


```php
$total = $this->aggregateTotal('user_sale', 'sum');

```

<a name="custom-card-displaying-users"></a>
#### Mostrando Usuarios

Al trabajar con agregados que registran un ID de usuario como la clave, puedes resolver las claves a registros de usuario utilizando el método `Pulse::resolveUsers`:


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

Los autores del paquete pueden desear proporcionar clases de grabador para permitir a los usuarios configurar la captura de datos.
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