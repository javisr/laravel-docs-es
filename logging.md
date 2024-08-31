# Registro

- [Introducción](#introduction)
- [Configuración](#configuration)
  - [Controladores de Canal Disponibles](#available-channel-drivers)
  - [Requisitos Previos de Canal](#channel-prerequisites)
  - [Registrar Advertencias de Deprecación](#logging-deprecation-warnings)
- [Construir Pilas de Registro](#building-log-stacks)
- [Escribir Mensajes de Registro](#writing-log-messages)
  - [Información Contextual](#contextual-information)
  - [Escribir en Canales Específicos](#writing-to-specific-channels)
- [Personalización de Canal Monolog](#monolog-channel-customization)
  - [Personalizar Monolog para Canales](#customizing-monolog-for-channels)
  - [Crear Canales de Controlador Monolog](#creating-monolog-handler-channels)
  - [Crear Canales Personalizados a través de Factories](#creating-custom-channels-via-factories)
- [Seguir Mensajes de Registro Usando Pail](#tailing-log-messages-using-pail)
  - [Instalación](#pail-installation)
  - [Uso](#pail-usage)
  - [Filtrar Registros](#pail-filtering-logs)

<a name="introduction"></a>
## Introducción

Para ayudarte a aprender más sobre lo que está sucediendo dentro de tu aplicación, Laravel ofrece servicios de logging robustos que te permiten registrar mensajes en archivos, en el registro de errores del sistema e incluso en Slack para notificar a todo tu equipo.
El registro de Laravel se basa en "canales". Cada canal representa una forma específica de escribir información de registro. Por ejemplo, el canal `single` escribe archivos de registro en un solo archivo de registro, mientras que el canal `slack` envía mensajes de registro a Slack. Los mensajes de registro pueden escribirse en múltiples canales según su gravedad.
Bajo el capó, Laravel utiliza la biblioteca [Monolog](https://github.com/Seldaek/monolog), que proporciona soporte para una variedad de potentes controladores de registro. Laravel facilita la configuración de estos controladores, lo que te permite combinarlos y personalizar el manejo de registros de tu aplicación.

<a name="configuration"></a>
## Configuración

Todas las opciones de configuración que controlan el comportamiento de registro de tu aplicación se encuentran en el archivo de configuración `config/logging.php`. Este archivo te permite configurar los canales de registro de tu aplicación, así que asegúrate de revisar cada uno de los canales disponibles y sus opciones. Revisaremos algunas opciones comunes a continuación.
Por defecto, Laravel utilizará el canal `stack` al registrar mensajes. El canal `stack` se utiliza para agregar múltiples canales de registro en un solo canal. Para obtener más información sobre cómo construir pilas, consulta la [documentación a continuación](#building-log-stacks).

<a name="available-channel-drivers"></a>
### Controladores de Canal Disponibles

Cada canal de registro está impulsado por un "driver". El driver determina cómo y dónde se graba realmente el mensaje de registro. Los siguientes drivers de canal de registro están disponibles en cada aplicación Laravel. Una entrada para la mayoría de estos drivers ya está presente en el archivo de configuración `config/logging.php` de tu aplicación, así que asegúrate de revisar este archivo para familiarizarte con su contenido:
<div class="overflow-auto">

| Nombre       | Descripción                                                           |
| ------------ | --------------------------------------------------------------------- |
| `custom`     | Un driver que llama a una fábrica especificada para crear un canal.  |
| `daily`      | Un driver de Monolog basado en `RotatingFileHandler` que rota diario.|
| `errorlog`   | Un driver de Monolog basado en `ErrorLogHandler`.                    |
| `monolog`    | Un driver de fábrica de Monolog que puede usar cualquier manejador de Monolog soportado. |
| `papertrail` | Un driver de Monolog basado en `SyslogUdpHandler`.                   |
| `single`     | Un canal de registrador basado en un solo archivo o ruta (`StreamHandler`). |
| `slack`      | Un driver de Monolog basado en `SlackWebhookHandler`.                 |
| `stack`      | Un envoltorio para facilitar la creación de canales "multi-canal".    |
| `syslog`     | Un driver de Monolog basado en `SyslogHandler`.                      |
</div>
> [!NOTE]
Consulta la documentación sobre [personalización avanzada de canales](#monolog-channel-customization) para aprender más sobre los drivers `monolog` y `custom`.

<a name="configuring-the-channel-name"></a>
#### Configurando el Nombre del Canal

Por defecto, Monolog se instancia con un "nombre de canal" que coincide con el entorno actual, como `production` o `local`. Para cambiar este valor, puedes agregar una opción `name` a la configuración de tu canal:


```php
'stack' => [
    'driver' => 'stack',
    'name' => 'channel-name',
    'channels' => ['single', 'slack'],
],
```

<a name="channel-prerequisites"></a>
### Prerrequisitos del Canal


<a name="configuring-the-single-and-daily-channels"></a>
#### Configurando los Canales Simple y Diario

Los canales `single` y `daily` tienen tres opciones de configuración opcionales: `bubble`, `permission` y `locking`.
<div class="overflow-auto">

| Nombre       | Descripción                                                                   | Predeterminado |
| ------------ | ----------------------------------------------------------------------------- | -------------- |
| `bubble`     | Indica si los mensajes deben elevarse a otros canales después de ser manejados. | `true`         |
| `locking`    | Intenta bloquear el archivo de registro antes de escribir en él.              | `false`        |
| `permission` | Los permisos del archivo de registro.                                         | `0644`         |
</div>
Además, la política de retención para el canal `daily` se puede configurar a través de la variable de entorno `LOG_DAILY_DAYS` o configurando la opción `days`.
<div class="overflow-auto">

| Nombre | Descripción                                               | Predeterminado |
| ------ | -------------------------------------------------------- | -------------- |
| `days` | El número de días que se deben retener los archivos de registro diarios. | `7`            |
</div>

<a name="configuring-the-papertrail-channel"></a>
#### Configurando el Canal de Papertrail

El canal `papertrail` requiere opciones de configuración `host` y `port`. Estos pueden definirse a través de las variables de entorno `PAPERTRAIL_URL` y `PAPERTRAIL_PORT`. Puedes obtener estos valores de [Papertrail](https://help.papertrailapp.com/kb/configuration/configuring-centralized-logging-from-php-apps/#send-events-from-php-app).

<a name="configuring-the-slack-channel"></a>
#### Configurando el canal de Slack

El canal `slack` requiere una opción de configuración `url`. Este valor puede definirse a través de la variable de entorno `LOG_SLACK_WEBHOOK_URL`. Esta URL debe coincidir con una URL para un [webhook entrante](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks) que hayas configurado para tu equipo de Slack.
Por defecto, Slack solo recibirá registros en el nivel `crítico` y superior; sin embargo, puedes ajustar esto utilizando la variable de entorno `LOG_LEVEL` o modificando la opción de configuración `level` dentro del array de configuración del canal de registro de Slack.

<a name="logging-deprecation-warnings"></a>
### Registro de Advertencias de Deprecación

PHP, Laravel y otras bibliotecas a menudo notifican a sus usuarios que algunas de sus características han sido desaprobadas y se eliminarán en una versión futura. Si deseas registrar estas advertencias de desaprobación, puedes especificar tu canal de registro `deprecations` preferido utilizando la variable de entorno `LOG_DEPRECATIONS_CHANNEL`, o dentro del archivo de configuración `config/logging.php` de tu aplicación:


```php
'deprecations' => [
    'channel' => env('LOG_DEPRECATIONS_CHANNEL', 'null'),
    'trace' => env('LOG_DEPRECATIONS_TRACE', false),
],

'channels' => [
    // ...
]
```
O, también puedes definir un canal de registro llamado `deprecations`. Si existe un canal de registro con este nombre, siempre se utilizará para registrar deprecaciones:


```php
'channels' => [
    'deprecations' => [
        'driver' => 'single',
        'path' => storage_path('logs/php-deprecation-warnings.log'),
    ],
],
```

<a name="building-log-stacks"></a>
## Construyendo Pilas de Registros

Como se mencionó anteriormente, el driver `stack` te permite combinar múltiples canales en un solo canal de registro para mayor comodidad. Para ilustrar cómo usar pilas de registros, echemos un vistazo a una configuración de ejemplo que podrías ver en una aplicación de producción:


```php
'channels' => [
    'stack' => [
        'driver' => 'stack',
        'channels' => ['syslog', 'slack'], // [tl! add]
        'ignore_exceptions' => false,
    ],

    'syslog' => [
        'driver' => 'syslog',
        'level' => env('LOG_LEVEL', 'debug'),
        'facility' => env('LOG_SYSLOG_FACILITY', LOG_USER),
        'replace_placeholders' => true,
    ],

    'slack' => [
        'driver' => 'slack',
        'url' => env('LOG_SLACK_WEBHOOK_URL'),
        'username' => env('LOG_SLACK_USERNAME', 'Laravel Log'),
        'emoji' => env('LOG_SLACK_EMOJI', ':boom:'),
        'level' => env('LOG_LEVEL', 'critical'),
        'replace_placeholders' => true,
    ],
],

```
Vamos a desglosar esta configuración. Primero, nota que nuestro canal de `stack` agrega dos canales adicionales a través de su opción `channels`: `syslog` y `slack`. Así que, al registrar mensajes, ambos canales tendrán la oportunidad de registrar el mensaje. Sin embargo, como veremos a continuación, si estos canales registran realmente el mensaje puede ser determinado por la severidad / "nivel" del mensaje.

<a name="log-levels"></a>
#### Niveles de Registro

Toma nota de la opción de configuración `level` presente en las configuraciones de canal `syslog` y `slack` en el ejemplo anterior. Esta opción determina el "nivel" mínimo que debe tener un mensaje para ser registrado por el canal. Monolog, que potencia los servicios de registro de Laravel, ofrece todos los niveles de registro definidos en la [Especificación RFC 5424](https://tools.ietf.org/html/rfc5424). En orden descendente de gravedad, estos niveles de registro son: **emergencia**, **alerta**, **crítico**, **error**, **advertencia**, **notificación**, **info** y **debug**.
Así que, imagina que registramos un mensaje utilizando el método `debug`:


```php
Log::debug('An informational message.');
```
Dada nuestra configuración, el canal `syslog` escribirá el mensaje en el registro del sistema; sin embargo, dado que el mensaje de error no es `crítico` o superior, no se enviará a Slack. Sin embargo, si registramos un mensaje de `emergencia`, se enviará tanto al registro del sistema como a Slack, ya que el nivel `emergencia` está por encima de nuestro umbral de nivel mínimo para ambos canales:


```php
Log::emergency('The system is down!');
```

<a name="writing-log-messages"></a>
## Escribiendo Mensajes de Registro

Puedes escribir información en los registros utilizando la `Log` [facade](/docs/%7B%7Bversion%7D%7D/facades). Como se mencionó anteriormente, el logger proporciona los ocho niveles de registro definidos en la [especificación RFC 5424](https://tools.ietf.org/html/rfc5424): **emergencia**, **alerta**, **crítico**, **error**, **advertencia**, **noticia**, **info** y **depuración**:


```php
use Illuminate\Support\Facades\Log;

Log::emergency($message);
Log::alert($message);
Log::critical($message);
Log::error($message);
Log::warning($message);
Log::notice($message);
Log::info($message);
Log::debug($message);
```
Puedes llamar a cualquiera de estos métodos para registrar un mensaje para el nivel correspondiente. Por defecto, el mensaje se escribirá en el canal de registro predeterminado según lo configurado en tu archivo de configuración `logging`:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\View\View;

class UserController extends Controller
{
    /**
     * Show the profile for the given user.
     */
    public function show(string $id): View
    {
        Log::info('Showing the user profile for user: {id}', ['id' => $id]);

        return view('user.profile', [
            'user' => User::findOrFail($id)
        ]);
    }
}
```

<a name="contextual-information"></a>
### Información Contextual

Se puede pasar un array de datos contextuales a los métodos de registro. Estos datos contextuales se formatearán y mostrarán junto con el mensaje de registro:


```php
use Illuminate\Support\Facades\Log;

Log::info('User {id} failed to login.', ['id' => $user->id]);
```
Ocasionalmente, es posible que desees especificar alguna información contextual que deba incluirse con todas las entradas de registro posteriores en un canal particular. Por ejemplo, es posible que desees registrar un ID de solicitud que esté asociado con cada solicitud entrante a tu aplicación. Para lograr esto, puedes llamar al método `withContext` de la fachada `Log`:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class AssignRequestId
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $requestId = (string) Str::uuid();

        Log::withContext([
            'request-id' => $requestId
        ]);

        $response = $next($request);

        $response->headers->set('Request-Id', $requestId);

        return $response;
    }
}
```
Si deseas compartir información contextual a través de *todos* los canales de registro, puedes invocar el método `Log::shareContext()`. Este método proporcionará la información contextual a todos los canales creados y a cualquier canal que se cree posteriormente:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class AssignRequestId
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $requestId = (string) Str::uuid();

        Log::shareContext([
            'request-id' => $requestId
        ]);

        // ...
    }
}
```
> [!NOTA]
Si necesitas compartir el contexto de registro mientras procesas trabajos en cola, puedes utilizar [middleware de trabajo](/docs/%7B%7Bversion%7D%7D/queues#job-middleware).

<a name="writing-to-specific-channels"></a>
### Escribir a Canales Específicos

A veces es posible que desees registrar un mensaje en un canal diferente al canal predeterminado de tu aplicación. Puedes usar el método `channel` en la fachada `Log` para recuperar y registrar en cualquier canal definido en tu archivo de configuración:


```php
use Illuminate\Support\Facades\Log;

Log::channel('slack')->info('Something happened!');
```
Si deseas crear un stack de registro bajo demanda que consista en múltiples canales, puedes usar el método `stack`:


```php
Log::stack(['single', 'slack'])->info('Something happened!');
```

<a name="on-demand-channels"></a>
#### Canales Bajo Demanda

También es posible crear un canal bajo demanda proporcionando la configuración en tiempo de ejecución sin que esa configuración esté presente en el archivo de configuración `logging` de tu aplicación. Para lograr esto, puedes pasar un array de configuración al método `build` de la fachada `Log`:


```php
use Illuminate\Support\Facades\Log;

Log::build([
  'driver' => 'single',
  'path' => storage_path('logs/custom.log'),
])->info('Something happened!');
```
También es posible que desees incluir un canal bajo demanda en una pila de registro bajo demanda. Esto se puede lograr incluyendo tu instancia de canal bajo demanda en el array pasado al método `stack`:


```php
use Illuminate\Support\Facades\Log;

$channel = Log::build([
  'driver' => 'single',
  'path' => storage_path('logs/custom.log'),
]);

Log::stack(['slack', $channel])->info('Something happened!');
```

<a name="monolog-channel-customization"></a>
## Personalización del Canal Monolog


<a name="customizing-monolog-for-channels"></a>
### Personalizando Monolog para Canales

A veces es posible que necesites tener control total sobre cómo se configura Monolog para un canal existente. Por ejemplo, es posible que desees configurar una implementación personalizada de `FormatterInterface` de Monolog para el canal `single` incorporado de Laravel.
Para comenzar, define un array `tap` en la configuración del canal. El array `tap` debe contener una lista de clases que deben tener la oportunidad de personalizar (o "interactuar" con) la instancia de Monolog después de que se haya creado. No hay una ubicación convencional donde se deban colocar estas clases, así que puedes crear un directorio dentro de tu aplicación para contener estas clases:


```php
'single' => [
    'driver' => 'single',
    'tap' => [App\Logging\CustomizeFormatter::class],
    'path' => storage_path('logs/laravel.log'),
    'level' => env('LOG_LEVEL', 'debug'),
    'replace_placeholders' => true,
],
```
Una vez que hayas configurado la opción `tap` en tu canal, estás listo para definir la clase que personalizará tu instancia de Monolog. Esta clase solo necesita un método: `__invoke`, que recibe una instancia de `Illuminate\Log\Logger`. La instancia de `Illuminate\Log\Logger` hace proxy a todas las llamadas a métodos en la instancia subyacente de Monolog:


```php
<?php

namespace App\Logging;

use Illuminate\Log\Logger;
use Monolog\Formatter\LineFormatter;

class CustomizeFormatter
{
    /**
     * Customize the given logger instance.
     */
    public function __invoke(Logger $logger): void
    {
        foreach ($logger->getHandlers() as $handler) {
            $handler->setFormatter(new LineFormatter(
                '[%datetime%] %channel%.%level_name%: %message% %context% %extra%'
            ));
        }
    }
}
```
> [!NOTA]
Todas tus clases "tap" son resolvidas por el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container), así que cualquier dependencia de constructor que requieran será inyectada automáticamente.

<a name="creating-monolog-handler-channels"></a>
### Creando Canales de Controladores Monolog

Monolog tiene una variedad de [manejadores disponibles](https://github.com/Seldaek/monolog/tree/main/src/Monolog/Handler) y Laravel no incluye un canal incorporado para cada uno. En algunos casos, es posible que desees crear un canal personalizado que sea simplemente una instancia de un manejador Monolog específico que no tenga un driver de registro correspondiente en Laravel. Estos canales se pueden crear fácilmente utilizando el driver `monolog`.
Al usar el driver `monolog`, la opción de configuración `handler` se utiliza para especificar qué controlador se instanciará. Opcionalmente, se pueden especificar los parámetros del constructor que necesita el controlador utilizando la opción de configuración `with`:


```php
'logentries' => [
    'driver'  => 'monolog',
    'handler' => Monolog\Handler\SyslogUdpHandler::class,
    'with' => [
        'host' => 'my.logentries.internal.datahubhost.company.com',
        'port' => '10000',
    ],
],
```

<a name="monolog-formatters"></a>
#### Formateadores de Monolog

Al utilizar el driver `monolog`, se usará el `LineFormatter` de Monolog como el formateador predeterminado. Sin embargo, puedes personalizar el tipo de formateador que se pasa al controlador utilizando las opciones de configuración `formatter` y `formatter_with`:


```php
'browser' => [
    'driver' => 'monolog',
    'handler' => Monolog\Handler\BrowserConsoleHandler::class,
    'formatter' => Monolog\Formatter\HtmlFormatter::class,
    'formatter_with' => [
        'dateFormat' => 'Y-m-d',
    ],
],
```
Si estás utilizando un manejador de Monolog que es capaz de proporcionar su propio formateador, puedes establecer el valor de la opción de configuración `formatter` en `default`:


```php
'newrelic' => [
    'driver' => 'monolog',
    'handler' => Monolog\Handler\NewRelicHandler::class,
    'formatter' => 'default',
],
```

<a name="monolog-processors"></a>
#### Procesadores de Monolog

Monolog también puede procesar mensajes antes de registrarlos. Puedes crear tus propios procesadores o usar los [procesadores existentes ofrecidos por Monolog](https://github.com/Seldaek/monolog/tree/main/src/Monolog/Processor).
Si deseas personalizar los procesadores para un driver `monolog`, añade un valor de configuración `processors` a la configuración de tu canal:


```php
'memory' => [
     'driver' => 'monolog',
     'handler' => Monolog\Handler\StreamHandler::class,
     'with' => [
         'stream' => 'php://stderr',
     ],
     'processors' => [
         // Simple syntax...
         Monolog\Processor\MemoryUsageProcessor::class,

         // With options...
         [
            'processor' => Monolog\Processor\PsrLogMessageProcessor::class,
            'with' => ['removeUsedContextFields' => true],
        ],
     ],
 ],
```

<a name="creating-custom-channels-via-factories"></a>
### Creando Canales Personalizados a través de Factories

Si deseas definir un canal completamente personalizado en el que tengas control total sobre la instanciación y configuración de Monolog, puedes especificar un tipo de driver `custom` en tu archivo de configuración `config/logging.php`. Tu configuración debe incluir una opción `via` que contenga el nombre de la clase factory que se invocará para crear la instancia de Monolog:


```php
'channels' => [
    'example-custom-channel' => [
        'driver' => 'custom',
        'via' => App\Logging\CreateCustomLogger::class,
    ],
],
```
Una vez que hayas configurado el canal del driver `custom`, estás listo para definir la clase que creará tu instancia de Monolog. Esta clase solo necesita un único método `__invoke` que debe devolver la instancia del registrador de Monolog. El método recibirá el array de configuración de los canales como su único argumento:


```php
<?php

namespace App\Logging;

use Monolog\Logger;

class CreateCustomLogger
{
    /**
     * Create a custom Monolog instance.
     */
    public function __invoke(array $config): Logger
    {
        return new Logger(/* ... */);
    }
}
```

<a name="tailing-log-messages-using-pail"></a>
## Seguimiento de Mensajes de Registro Usando Pail

A menudo es posible que necesites seguir los registros de tu aplicación en tiempo real. Por ejemplo, al depurar un problema o al monitorear los registros de tu aplicación en busca de tipos específicos de errores.
Laravel Pail es un paquete que te permite explorar fácilmente los archivos de registro de tu aplicación Laravel directamente desde la línea de comandos. A diferencia del comando `tail` estándar, Pail está diseñado para trabajar con cualquier driver de registro, incluyendo Sentry o Flare. Además, Pail ofrece un conjunto de filtros útiles para ayudarte a encontrar rápidamente lo que estás buscando.
<img src="https://laravel.com/img/docs/pail-example.png">

<a name="pail-installation"></a>
### Instalación

> [!WARNING]
Laravel Pail requiere [PHP 8.2+](https://php.net/releases/) y la extensión [PCNTL](https://www.php.net/manual/en/book.pcntl.php).
Para comenzar, instala Pail en tu proyecto utilizando el gestor de paquetes Composer:


```bash
composer require laravel/pail

```

<a name="pail-usage"></a>
### Uso

Para comenzar a seguir los registros, ejecuta el comando `pail`:


```bash
php artisan pail

```
Para aumentar la verbosidad de la salida y evitar la truncación (…), utiliza la opción `-v`:


```bash
php artisan pail -v

```
Para obtener la máxima verbosidad y mostrar rastros de pila de excepciones, utiliza la opción `-vv`:


```bash
php artisan pail -vv

```
Para dejar de seguir los registros, presiona `Ctrl+C` en cualquier momento.

<a name="pail-filtering-logs"></a>
### Filtrando Registros


<a name="pail-filtering-logs-filter-option"></a>
#### `--filter`

Puedes usar la opción `--filter` para filtrar registros por su tipo, archivo, mensaje y contenido de la traza de pila:


```bash
php artisan pail --filter="QueryException"

```

<a name="pail-filtering-logs-message-option"></a>
#### `--message`

Para filtrar logs solo por su mensaje, puedes usar la opción `--message`:


```bash
php artisan pail --message="User created"

```

<a name="pail-filtering-logs-level-option"></a>
#### `--level`

La opción `--level` se puede utilizar para filtrar registros por su [nivel de registro](#log-levels):


```bash
php artisan pail --level=error

```

<a name="pail-filtering-logs-user-option"></a>
#### `--user`

Para mostrar solo los registros que se escribieron mientras un usuario dado estaba autenticado, puedes proporcionar la ID del usuario a la opción `--user`:


```bash
php artisan pail --user=1

```