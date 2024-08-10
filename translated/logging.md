# Registro

- [Registro](#registro)
  - [Introducción](#introducción)
  - [Configuración](#configuración)
    - [Controladores de Canal Disponibles](#controladores-de-canal-disponibles)
      - [Configurando el Nombre del Canal](#configurando-el-nombre-del-canal)
    - [Requisitos Previos del Canal](#requisitos-previos-del-canal)
      - [Configurando los Canales Single y Daily](#configurando-los-canales-single-y-daily)
      - [Configurando el Canal Papertrail](#configurando-el-canal-papertrail)
      - [Configurando el Canal Slack](#configurando-el-canal-slack)
    - [Advertencias de Deprecación de Registro](#advertencias-de-deprecación-de-registro)
  - [Construcción de Pilas de Registro](#construcción-de-pilas-de-registro)
      - [Niveles de Registro](#niveles-de-registro)
  - [Escritura de Mensajes de Registro](#escritura-de-mensajes-de-registro)
    - [Información Contextual](#información-contextual)
    - [Escritura en Canales Específicos](#escritura-en-canales-específicos)
      - [Canales Bajo Demanda](#canales-bajo-demanda)
  - [Personalización del Canal Monolog](#personalización-del-canal-monolog)
    - [Personalizando Monolog para Canales](#personalizando-monolog-para-canales)
    - [Creando Canales de Manejador Monolog](#creando-canales-de-manejador-monolog)
      - [Formateadores de Monolog](#formateadores-de-monolog)
      - [Procesadores de Monolog](#procesadores-de-monolog)
    - [Creando Canales Personalizados a través de Factories](#creando-canales-personalizados-a-través-de-factories)
  - [Seguimiento de Mensajes de Registro Usando Pail](#seguimiento-de-mensajes-de-registro-usando-pail)
    - [Instalación](#instalación)
    - [Uso](#uso)
    - [Filtrando Registros](#filtrando-registros)
      - [`--filter`](#--filter)
      - [`--message`](#--message)
      - [`--level`](#--level)
      - [`--user`](#--user)

<a name="introduction"></a>
## Introducción

Para ayudarte a aprender más sobre lo que está sucediendo dentro de tu aplicación, Laravel proporciona servicios de registro robustos que te permiten registrar mensajes en archivos, en el registro de errores del sistema e incluso en Slack para notificar a todo tu equipo.

El registro en Laravel se basa en "canales". Cada canal representa una forma específica de escribir información de registro. Por ejemplo, el canal `single` escribe archivos de registro en un solo archivo de registro, mientras que el canal `slack` envía mensajes de registro a Slack. Los mensajes de registro pueden escribirse en múltiples canales según su gravedad.

Bajo el capó, Laravel utiliza la biblioteca [Monolog](https://github.com/Seldaek/monolog), que proporciona soporte para una variedad de controladores de registro potentes. Laravel facilita la configuración de estos controladores, permitiéndote combinarlos y personalizar el manejo de registros de tu aplicación.

<a name="configuration"></a>
## Configuración

Todas las opciones de configuración que controlan el comportamiento de registro de tu aplicación se encuentran en el archivo de configuración `config/logging.php`. Este archivo te permite configurar los canales de registro de tu aplicación, así que asegúrate de revisar cada uno de los canales disponibles y sus opciones. Revisaremos algunas opciones comunes a continuación.

Por defecto, Laravel utilizará el canal `stack` al registrar mensajes. El canal `stack` se utiliza para agregar múltiples canales de registro en un solo canal. Para más información sobre cómo construir pilas, consulta la [documentación a continuación](#building-log-stacks).

<a name="available-channel-drivers"></a>
### Controladores de Canal Disponibles

Cada canal de registro es impulsado por un "controlador". El controlador determina cómo y dónde se registra realmente el mensaje de registro. Los siguientes controladores de canal de registro están disponibles en cada aplicación Laravel. Una entrada para la mayoría de estos controladores ya está presente en el archivo de configuración `config/logging.php` de tu aplicación, así que asegúrate de revisar este archivo para familiarizarte con su contenido:

<div class="overflow-auto">

| Nombre       | Descripción                                                          |
| ------------ | -------------------------------------------------------------------- |
| `custom`     | Un controlador que llama a una factory especificada para crear un canal.         |
| `daily`      | Un controlador Monolog basado en `RotatingFileHandler` que rota diariamente.    |
| `errorlog`   | Un controlador Monolog basado en `ErrorLogHandler`.                           |
| `monolog`    | Un controlador de factory Monolog que puede usar cualquier controlador Monolog soportado. |
| `papertrail` | Un controlador Monolog basado en `SyslogUdpHandler`.                           |
| `single`     | Un canal de registro basado en un solo archivo o ruta (`StreamHandler`).        |
| `slack`      | Un controlador Monolog basado en `SlackWebhookHandler`.                        |
| `stack`      | Un envoltorio para facilitar la creación de canales "multicanal".           |
| `syslog`     | Un controlador Monolog basado en `SyslogHandler`.                              |

</div>

> [!NOTE]  
> Consulta la documentación sobre [personalización avanzada de canales](#monolog-channel-customization) para aprender más sobre los controladores `monolog` y `custom`.

<a name="configuring-the-channel-name"></a>
#### Configurando el Nombre del Canal

Por defecto, Monolog se instancia con un "nombre de canal" que coincide con el entorno actual, como `production` o `local`. Para cambiar este valor, puedes agregar una opción `name` a la configuración de tu canal:

    'stack' => [
        'driver' => 'stack',
        'name' => 'channel-name',
        'channels' => ['single', 'slack'],
    ],

<a name="channel-prerequisites"></a>
### Requisitos Previos del Canal

<a name="configuring-the-single-and-daily-channels"></a>
#### Configurando los Canales Single y Daily

Los canales `single` y `daily` tienen tres opciones de configuración opcionales: `bubble`, `permission` y `locking`.

<div class="overflow-auto">

| Nombre       | Descripción                                                                   | Predeterminado |
| ------------ | ----------------------------------------------------------------------------- | --------------- |
| `bubble`     | Indica si los mensajes deben burbujear a otros canales después de ser manejados. | `true`          |
| `locking`    | Intenta bloquear el archivo de registro antes de escribir en él.              | `false`         |
| `permission` | Los permisos del archivo de registro.                                         | `0644`          |

</div>

Además, la política de retención para el canal `daily` se puede configurar a través de la variable de entorno `LOG_DAILY_DAYS` o configurando la opción de configuración `days`.

<div class="overflow-auto">

| Nombre | Descripción                                                 | Predeterminado |
| ------ | ----------------------------------------------------------- | --------------- |
| `days` | El número de días que se deben retener los archivos de registro diarios. | `7`             |

</div>

<a name="configuring-the-papertrail-channel"></a>
#### Configurando el Canal Papertrail

El canal `papertrail` requiere opciones de configuración `host` y `port`. Estas pueden definirse a través de las variables de entorno `PAPERTRAIL_URL` y `PAPERTRAIL_PORT`. Puedes obtener estos valores de [Papertrail](https://help.papertrailapp.com/kb/configuration/configuring-centralized-logging-from-php-apps/#send-events-from-php-app).

<a name="configuring-the-slack-channel"></a>
#### Configurando el Canal Slack

El canal `slack` requiere una opción de configuración `url`. Este valor puede definirse a través de la variable de entorno `LOG_SLACK_WEBHOOK_URL`. Esta URL debe coincidir con una URL para un [webhook entrante](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks) que hayas configurado para tu equipo de Slack.

Por defecto, Slack solo recibirá registros en el nivel `critical` y superior; sin embargo, puedes ajustar esto utilizando la variable de entorno `LOG_LEVEL` o modificando la opción de configuración `level` dentro de la matriz de configuración de tu canal de registro de Slack.

<a name="logging-deprecation-warnings"></a>
### Advertencias de Deprecación de Registro

PHP, Laravel y otras bibliotecas a menudo notifican a sus usuarios que algunas de sus características han sido deprecadas y serán eliminadas en una versión futura. Si deseas registrar estas advertencias de deprecación, puedes especificar tu canal de registro de `deprecations` preferido utilizando la variable de entorno `LOG_DEPRECATIONS_CHANNEL`, o dentro del archivo de configuración `config/logging.php` de tu aplicación:

    'deprecations' => [
        'channel' => env('LOG_DEPRECATIONS_CHANNEL', 'null'),
        'trace' => env('LOG_DEPRECATIONS_TRACE', false),
    ],

    'channels' => [
        // ...
    ]

O, puedes definir un canal de registro llamado `deprecations`. Si existe un canal de registro con este nombre, siempre se utilizará para registrar deprecaciones:

    'channels' => [
        'deprecations' => [
            'driver' => 'single',
            'path' => storage_path('logs/php-deprecation-warnings.log'),
        ],
    ],

<a name="building-log-stacks"></a>
## Construcción de Pilas de Registro

Como se mencionó anteriormente, el controlador `stack` te permite combinar múltiples canales en un solo canal de registro por conveniencia. Para ilustrar cómo usar pilas de registro, echemos un vistazo a una configuración de ejemplo que podrías ver en una aplicación de producción:

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

Desglosemos esta configuración. Primero, observa que nuestro canal `stack` agrega otros dos canales a través de su opción `channels`: `syslog` y `slack`. Así que, al registrar mensajes, ambos canales tendrán la oportunidad de registrar el mensaje. Sin embargo, como veremos a continuación, si estos canales realmente registran el mensaje puede depender de la gravedad / "nivel" del mensaje.

<a name="log-levels"></a>
#### Niveles de Registro

Toma nota de la opción de configuración `level` presente en las configuraciones de los canales `syslog` y `slack` en el ejemplo anterior. Esta opción determina el "nivel" mínimo que debe tener un mensaje para ser registrado por el canal. Monolog, que impulsa los servicios de registro de Laravel, ofrece todos los niveles de registro definidos en la [especificación RFC 5424](https://tools.ietf.org/html/rfc5424). En orden descendente de gravedad, estos niveles de registro son: **emergency**, **alert**, **critical**, **error**, **warning**, **notice**, **info** y **debug**.

Así que, imagina que registramos un mensaje usando el método `debug`:

    Log::debug('Un mensaje informativo.');

Dada nuestra configuración, el canal `syslog` escribirá el mensaje en el registro del sistema; sin embargo, dado que el mensaje de error no es `critical` o superior, no se enviará a Slack. Sin embargo, si registramos un mensaje de `emergency`, se enviará tanto al registro del sistema como a Slack, ya que el nivel `emergency` está por encima de nuestro umbral de nivel mínimo para ambos canales:

    Log::emergency('¡El sistema está caído!');

<a name="writing-log-messages"></a>
## Escritura de Mensajes de Registro

Puedes escribir información en los registros utilizando el [facade](/docs/{{version}}/facades) `Log`. Como se mencionó anteriormente, el registrador proporciona los ocho niveles de registro definidos en la [especificación RFC 5424](https://tools.ietf.org/html/rfc5424): **emergency**, **alert**, **critical**, **error**, **warning**, **notice**, **info** y **debug**:

    use Illuminate\Support\Facades\Log;

    Log::emergency($message);
    Log::alert($message);
    Log::critical($message);
    Log::error($message);
    Log::warning($message);
    Log::notice($message);
    Log::info($message);
    Log::debug($message);

Puedes llamar a cualquiera de estos métodos para registrar un mensaje para el nivel correspondiente. Por defecto, el mensaje se escribirá en el canal de registro predeterminado según lo configurado por tu archivo de configuración `logging`:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\User;
    use Illuminate\Support\Facades\Log;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * Muestra el perfil del usuario dado.
         */
        public function show(string $id): View
        {
            Log::info('Mostrando el perfil del usuario: {id}', ['id' => $id]);

            return view('user.profile', [
                'user' => User::findOrFail($id)
            ]);
        }
    }

<a name="contextual-information"></a>
### Información Contextual

Un array de datos contextuales puede ser pasado a los métodos de registro. Estos datos contextuales se formatearán y mostrarán con el mensaje de registro:

    use Illuminate\Support\Facades\Log;

    Log::info('El usuario {id} falló al iniciar sesión.', ['id' => $user->id]);

Ocasionalmente, puede que desees especificar alguna información contextual que deba incluirse con todas las entradas de registro subsiguientes en un canal particular. Por ejemplo, puede que desees registrar un ID de solicitud que esté asociado con cada solicitud entrante a tu aplicación. Para lograr esto, puedes llamar al método `withContext` del facade `Log`:

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
         * Manejar una solicitud entrante.
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

Si deseas compartir información contextual a través de _todos_ los canales de registro, puedes invocar el método `Log::shareContext()`. Este método proporcionará la información contextual a todos los canales creados y a cualquier canal que se cree posteriormente:

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
         * Manejar una solicitud entrante.
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

> [!NOTE]  
> Si necesitas compartir el contexto de registro mientras procesas trabajos en cola, puedes utilizar [middleware de trabajos](/docs/{{version}}/queues#job-middleware).

<a name="writing-to-specific-channels"></a>
### Escritura en Canales Específicos

A veces puede que desees registrar un mensaje en un canal diferente al canal predeterminado de tu aplicación. Puedes usar el método `channel` en el facade `Log` para recuperar y registrar en cualquier canal definido en tu archivo de configuración:

    use Illuminate\Support\Facades\Log;

    Log::channel('slack')->info('¡Algo sucedió!');

Si deseas crear una pila de registro bajo demanda que consista en múltiples canales, puedes usar el método `stack`:

    Log::stack(['single', 'slack'])->info('¡Algo sucedió!');

<a name="on-demand-channels"></a>
#### Canales Bajo Demanda

También es posible crear un canal bajo demanda proporcionando la configuración en tiempo de ejecución sin que esa configuración esté presente en el archivo de configuración `logging` de tu aplicación. Para lograr esto, puedes pasar un array de configuración al método `build` del facade `Log`:

    use Illuminate\Support\Facades\Log;

    Log::build([
      'driver' => 'single',
      'path' => storage_path('logs/custom.log'),
    ])->info('¡Algo sucedió!');

También puede que desees incluir un canal bajo demanda en una pila de registro bajo demanda. Esto se puede lograr incluyendo tu instancia de canal bajo demanda en el array pasado al método `stack`:

    use Illuminate\Support\Facades\Log;

    $channel = Log::build([
      'driver' => 'single',
      'path' => storage_path('logs/custom.log'),
    ]);

    Log::stack(['slack', $channel])->info('¡Algo sucedió!');

<a name="monolog-channel-customization"></a>
## Personalización del Canal Monolog

<a name="customizing-monolog-for-channels"></a>
### Personalizando Monolog para Canales

A veces puede que necesites control total sobre cómo se configura Monolog para un canal existente. Por ejemplo, puede que desees configurar una implementación personalizada de `FormatterInterface` de Monolog para el canal `single` incorporado de Laravel.

Para comenzar, define un array `tap` en la configuración del canal. El array `tap` debe contener una lista de clases que deben tener la oportunidad de personalizar (o "tocar") la instancia de Monolog después de que se crea. No hay una ubicación convencional donde estas clases deban colocarse, por lo que eres libre de crear un directorio dentro de tu aplicación para contener estas clases:

    'single' => [
        'driver' => 'single',
        'tap' => [App\Logging\CustomizeFormatter::class],
        'path' => storage_path('logs/laravel.log'),
        'level' => env('LOG_LEVEL', 'debug'),
        'replace_placeholders' => true,
    ],

Una vez que hayas configurado la opción `tap` en tu canal, estás listo para definir la clase que personalizará tu instancia de Monolog. Esta clase solo necesita un método: `__invoke`, que recibe una instancia de `Illuminate\Log\Logger`. La instancia de `Illuminate\Log\Logger` envía todas las llamadas a métodos a la instancia subyacente de Monolog:

    <?php

    namespace App\Logging;

    use Illuminate\Log\Logger;
    use Monolog\Formatter\LineFormatter;

    class CustomizeFormatter
    {
        /**
         * Personaliza la instancia de logger dada.
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

> [!NOTE]  
> Todas tus clases "tap" son resueltas por el [service container](/docs/{{version}}/container), por lo que cualquier dependencia de constructor que requieran se inyectará automáticamente.

<a name="creating-monolog-handler-channels"></a>
### Creando Canales de Manejador Monolog

Monolog tiene una variedad de [manejadores disponibles](https://github.com/Seldaek/monolog/tree/main/src/Monolog/Handler) y Laravel no incluye un canal incorporado para cada uno. En algunos casos, es posible que desees crear un canal personalizado que sea simplemente una instancia de un manejador Monolog específico que no tenga un controlador de registro correspondiente en Laravel. Estos canales se pueden crear fácilmente utilizando el controlador `monolog`.

Al usar el controlador `monolog`, la opción de configuración `handler` se utiliza para especificar qué manejador se instanciará. Opcionalmente, se pueden especificar cualquier parámetro de constructor que necesite el manejador utilizando la opción de configuración `with`:

    'logentries' => [
        'driver'  => 'monolog',
        'handler' => Monolog\Handler\SyslogUdpHandler::class,
        'with' => [
            'host' => 'my.logentries.internal.datahubhost.company.com',
            'port' => '10000',
        ],
    ],

<a name="monolog-formatters"></a>
#### Formateadores de Monolog

Al usar el controlador `monolog`, se utilizará el `LineFormatter` de Monolog como el formateador predeterminado. Sin embargo, puedes personalizar el tipo de formateador que se pasa al manejador utilizando las opciones de configuración `formatter` y `formatter_with`:

    'browser' => [
        'driver' => 'monolog',
        'handler' => Monolog\Handler\BrowserConsoleHandler::class,
        'formatter' => Monolog\Formatter\HtmlFormatter::class,
        'formatter_with' => [
            'dateFormat' => 'Y-m-d',
        ],
    ],

Si estás utilizando un manejador de Monolog que es capaz de proporcionar su propio formateador, puedes establecer el valor de la opción de configuración `formatter` en `default`:

    'newrelic' => [
        'driver' => 'monolog',
        'handler' => Monolog\Handler\NewRelicHandler::class,
        'formatter' => 'default',
    ],


 <a name="monolog-processors"></a>
 #### Procesadores de Monolog

Monolog también puede procesar mensajes antes de registrarlos. Puedes crear tus propios procesadores o usar los [procesadores existentes ofrecidos por Monolog](https://github.com/Seldaek/monolog/tree/main/src/Monolog/Processor).

Si deseas personalizar los procesadores para un controlador `monolog`, agrega un valor de configuración `processors` a la configuración de tu canal:

     'memory' => [
         'driver' => 'monolog',
         'handler' => Monolog\Handler\StreamHandler::class,
         'with' => [
             'stream' => 'php://stderr',
         ],
         'processors' => [
             // Sintaxis simple...
             Monolog\Processor\MemoryUsageProcessor::class,

             // Con opciones...
             [
                'processor' => Monolog\Processor\PsrLogMessageProcessor::class,
                'with' => ['removeUsedContextFields' => true],
            ],
         ],
     ],


<a name="creating-custom-channels-via-factories"></a>
### Creando Canales Personalizados a través de Factories

Si deseas definir un canal completamente personalizado en el que tengas control total sobre la instanciación y configuración de Monolog, puedes especificar un tipo de controlador `custom` en tu archivo de configuración `config/logging.php`. Tu configuración debe incluir una opción `via` que contenga el nombre de la clase de fábrica que se invocará para crear la instancia de Monolog:

    'channels' => [
        'example-custom-channel' => [
            'driver' => 'custom',
            'via' => App\Logging\CreateCustomLogger::class,
        ],
    ],

Una vez que hayas configurado el canal del controlador `custom`, estás listo para definir la clase que creará tu instancia de Monolog. Esta clase solo necesita un método `__invoke` que debe devolver la instancia del logger de Monolog. El método recibirá el array de configuración de canales como su único argumento:

    <?php

    namespace App\Logging;

    use Monolog\Logger;

    class CreateCustomLogger
    {
        /**
         * Crea una instancia personalizada de Monolog.
         */
        public function __invoke(array $config): Logger
        {
            return new Logger(/* ... */);
        }
    }

<a name="tailing-log-messages-using-pail"></a>
## Seguimiento de Mensajes de Registro Usando Pail

A menudo, es posible que necesites seguir los registros de tu aplicación en tiempo real. Por ejemplo, al depurar un problema o al monitorear los registros de tu aplicación en busca de tipos específicos de errores.

Laravel Pail es un paquete que te permite sumergirte fácilmente en los archivos de registro de tu aplicación Laravel directamente desde la línea de comandos. A diferencia del comando `tail` estándar, Pail está diseñado para trabajar con cualquier controlador de registro, incluyendo Sentry o Flare. Además, Pail proporciona un conjunto de filtros útiles para ayudarte a encontrar rápidamente lo que estás buscando.

<img src="https://laravel.com/img/docs/pail-example.png">

<a name="pail-installation"></a>
### Instalación

> [!WARNING]  
> Laravel Pail requiere [PHP 8.2+](https://php.net/releases/) y la extensión [PCNTL](https://www.php.net/manual/en/book.pcntl.php).

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

Para la máxima verbosidad y para mostrar trazas de pila de excepciones, utiliza la opción `-vv`:

```bash
php artisan pail -vv
```

Para detener el seguimiento de los registros, presiona `Ctrl+C` en cualquier momento.

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

Para filtrar registros solo por su mensaje, puedes usar la opción `--message`:

```bash
php artisan pail --message="User created"
```

<a name="pail-filtering-logs-level-option"></a>
#### `--level`

La opción `--level` se puede usar para filtrar registros por su [nivel de registro](#log-levels):

```bash
php artisan pail --level=error
```

<a name="pail-filtering-logs-user-option"></a>
#### `--user`

Para mostrar solo los registros que se escribieron mientras un usuario dado estaba autenticado, puedes proporcionar el ID del usuario a la opción `--user`:

```bash
php artisan pail --user=1
```
