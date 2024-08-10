# Laravel Horizon

- [Introducción](#introduction)
- [Instalación](#installation)
    - [Configuración](#configuration)
    - [Estrategias de Balanceo](#balancing-strategies)
    - [Autorización del Dashboard](#dashboard-authorization)
    - [Trabajos Silenciados](#silenced-jobs)
- [Actualizando Horizon](#upgrading-horizon)
- [Ejecutando Horizon](#running-horizon)
    - [Desplegando Horizon](#deploying-horizon)
- [Etiquetas](#tags)
- [Notificaciones](#notifications)
- [Métricas](#metrics)
- [Eliminando Trabajos Fallidos](#deleting-failed-jobs)
- [Limpiando Trabajos de las Colas](#clearing-jobs-from-queues)

<a name="introduction"></a>
## Introducción

> [!NOTE]  
> Antes de profundizar en Laravel Horizon, debes familiarizarte con los [servicios de cola](/docs/{{version}}/queues) base de Laravel. Horizon complementa la cola de Laravel con características adicionales que pueden ser confusas si no estás familiarizado con las características básicas de cola que ofrece Laravel.

[Laravel Horizon](https://github.com/laravel/horizon) proporciona un hermoso dashboard y configuración basada en código para tus [colas Redis](/docs/{{version}}/queues) impulsadas por Laravel. Horizon te permite monitorear fácilmente métricas clave de tu sistema de colas, como el rendimiento de trabajos, tiempo de ejecución y fallos de trabajos.

Al usar Horizon, toda la configuración de tu trabajador de cola se almacena en un solo archivo de configuración simple. Al definir la configuración del trabajador de tu aplicación en un archivo controlado por versiones, puedes escalar o modificar fácilmente los trabajadores de cola de tu aplicación al desplegarla.

<img src="https://laravel.com/img/docs/horizon-example.png">

<a name="installation"></a>
## Instalación

> [!WARNING]  
> Laravel Horizon requiere que uses [Redis](https://redis.io) para impulsar tu cola. Por lo tanto, debes asegurarte de que tu conexión de cola esté configurada como `redis` en el archivo de configuración `config/queue.php` de tu aplicación.

Puedes instalar Horizon en tu proyecto usando el gestor de paquetes Composer:

```shell
composer require laravel/horizon
```

Después de instalar Horizon, publica sus activos usando el comando Artisan `horizon:install`:

```shell
php artisan horizon:install
```

<a name="configuration"></a>
### Configuración

Después de publicar los activos de Horizon, su archivo de configuración principal estará ubicado en `config/horizon.php`. Este archivo de configuración te permite configurar las opciones del trabajador de cola para tu aplicación. Cada opción de configuración incluye una descripción de su propósito, así que asegúrate de explorar este archivo a fondo.

> [!WARNING]  
> Horizon utiliza una conexión Redis llamada `horizon` internamente. Este nombre de conexión Redis está reservado y no debe asignarse a otra conexión Redis en el archivo de configuración `database.php` o como el valor de la opción `use` en el archivo de configuración `horizon.php`.

<a name="environments"></a>
#### Entornos

Después de la instalación, la opción de configuración principal de Horizon con la que debes familiarizarte es la opción de configuración `environments`. Esta opción de configuración es un array de entornos en los que se ejecuta tu aplicación y define las opciones del proceso del trabajador para cada entorno. Por defecto, esta entrada contiene un entorno `production` y `local`. Sin embargo, eres libre de agregar más entornos según sea necesario:

    'environments' => [
        'production' => [
            'supervisor-1' => [
                'maxProcesses' => 10,
                'balanceMaxShift' => 1,
                'balanceCooldown' => 3,
            ],
        ],

        'local' => [
            'supervisor-1' => [
                'maxProcesses' => 3,
            ],
        ],
    ],

También puedes definir un entorno comodín (`*`) que se utilizará cuando no se encuentre otro entorno coincidente:

    'environments' => [
        // ...

        '*' => [
            'supervisor-1' => [
                'maxProcesses' => 3,
            ],
        ],
    ],

Cuando inicias Horizon, utilizará las opciones de configuración del proceso del trabajador para el entorno en el que se está ejecutando tu aplicación. Típicamente, el entorno se determina por el valor de la variable [APP_ENV](/docs/{{version}}/configuration#determining-the-current-environment). Por ejemplo, el entorno `local` predeterminado de Horizon está configurado para iniciar tres procesos de trabajadores y equilibrar automáticamente el número de procesos de trabajadores asignados a cada cola. El entorno `production` predeterminado está configurado para iniciar un máximo de 10 procesos de trabajadores y equilibrar automáticamente el número de procesos de trabajadores asignados a cada cola.

> [!WARNING]  
> Debes asegurarte de que la parte `environments` de tu archivo de configuración `horizon` contenga una entrada para cada [entorno](/docs/{{version}}/configuration#environment-configuration) en el que planeas ejecutar Horizon.

<a name="supervisors"></a>
#### Supervisores

Como puedes ver en el archivo de configuración predeterminado de Horizon, cada entorno puede contener uno o más "supervisores". Por defecto, el archivo de configuración define este supervisor como `supervisor-1`; sin embargo, eres libre de nombrar a tus supervisores como desees. Cada supervisor es esencialmente responsable de "supervisar" un grupo de procesos de trabajadores y se encarga de equilibrar los procesos de trabajadores entre colas.

Puedes agregar supervisores adicionales a un entorno dado si deseas definir un nuevo grupo de procesos de trabajadores que deberían ejecutarse en ese entorno. Puedes optar por hacer esto si deseas definir una estrategia de balanceo diferente o un conteo de procesos de trabajadores para una cola dada utilizada por tu aplicación.

<a name="maintenance-mode"></a>
#### Modo de Mantenimiento

Mientras tu aplicación esté en [modo de mantenimiento](/docs/{{version}}/configuration#maintenance-mode), los trabajos en cola no serán procesados por Horizon a menos que la opción `force` del supervisor esté definida como `true` dentro del archivo de configuración de Horizon:

    'environments' => [
        'production' => [
            'supervisor-1' => [
                // ...
                'force' => true,
            ],
        ],
    ],

<a name="default-values"></a>
#### Valores Predeterminados

Dentro del archivo de configuración predeterminado de Horizon, notarás una opción de configuración `defaults`. Esta opción de configuración especifica los valores predeterminados para tus [supervisores](#supervisors). Los valores de configuración predeterminados del supervisor se fusionarán en la configuración del supervisor para cada entorno, lo que te permitirá evitar repeticiones innecesarias al definir tus supervisores.

<a name="balancing-strategies"></a>
### Estrategias de Balanceo

A diferencia del sistema de colas predeterminado de Laravel, Horizon te permite elegir entre tres estrategias de balanceo de trabajadores: `simple`, `auto` y `false`. La estrategia `simple` divide los trabajos entrantes de manera uniforme entre los procesos de trabajadores:

    'balance' => 'simple',

La estrategia `auto`, que es la predeterminada del archivo de configuración, ajusta el número de procesos de trabajadores por cola según la carga de trabajo actual de la cola. Por ejemplo, si tu cola de `notifications` tiene 1,000 trabajos pendientes mientras que tu cola de `render` está vacía, Horizon asignará más trabajadores a tu cola de `notifications` hasta que la cola esté vacía.

Al usar la estrategia `auto`, puedes definir las opciones de configuración `minProcesses` y `maxProcesses` para controlar el número mínimo de procesos por cola y el número máximo de procesos de trabajadores en total que Horizon debería escalar hacia arriba y hacia abajo:

    'environments' => [
        'production' => [
            'supervisor-1' => [
                'connection' => 'redis',
                'queue' => ['default'],
                'balance' => 'auto',
                'autoScalingStrategy' => 'time',
                'minProcesses' => 1,
                'maxProcesses' => 10,
                'balanceMaxShift' => 1,
                'balanceCooldown' => 3,
                'tries' => 3,
            ],
        ],
    ],

El valor de configuración `autoScalingStrategy` determina si Horizon asignará más procesos de trabajadores a las colas según la cantidad total de tiempo que tomará limpiar la cola (`time` strategy) o por el número total de trabajos en la cola (`size` strategy).

Los valores de configuración `balanceMaxShift` y `balanceCooldown` determinan qué tan rápido Horizon escalará para satisfacer la demanda de trabajadores. En el ejemplo anterior, se creará o destruirá un máximo de un nuevo proceso cada tres segundos. Eres libre de ajustar estos valores según sea necesario en función de las necesidades de tu aplicación.

Cuando la opción `balance` está configurada como `false`, se utilizará el comportamiento predeterminado de Laravel, donde las colas se procesan en el orden en que están listadas en tu configuración.

<a name="dashboard-authorization"></a>
### Autorización del Dashboard

El dashboard de Horizon se puede acceder a través de la ruta `/horizon`. Por defecto, solo podrás acceder a este dashboard en el entorno `local`. Sin embargo, dentro de tu archivo `app/Providers/HorizonServiceProvider.php`, hay una definición de [puerta de autorización](/docs/{{version}}/authorization#gates). Esta puerta de autorización controla el acceso a Horizon en entornos **no locales**. Eres libre de modificar esta puerta según sea necesario para restringir el acceso a tu instalación de Horizon:

    /**
     * Registrar la puerta de Horizon.
     *
     * Esta puerta determina quién puede acceder a Horizon en entornos no locales.
     */
    protected function gate(): void
    {
        Gate::define('viewHorizon', function (User $user) {
            return in_array($user->email, [
                'taylor@laravel.com',
            ]);
        });
    }

<a name="alternative-authentication-strategies"></a>
#### Estrategias de Autenticación Alternativas

Recuerda que Laravel inyecta automáticamente al usuario autenticado en la función anónima de la puerta. Si tu aplicación está proporcionando seguridad a Horizon a través de otro método, como restricciones de IP, entonces tus usuarios de Horizon pueden no necesitar "iniciar sesión". Por lo tanto, necesitarás cambiar la firma de la función `function (User $user)` anterior a `function (User $user = null)` para obligar a Laravel a no requerir autenticación.

<a name="silenced-jobs"></a>
### Trabajos Silenciados

A veces, puede que no estés interesado en ver ciertos trabajos despachados por tu aplicación o paquetes de terceros. En lugar de que estos trabajos ocupen espacio en tu lista de "Trabajos Completados", puedes silenciarlos. Para comenzar, agrega el nombre de la clase del trabajo a la opción de configuración `silenced` en el archivo de configuración `horizon` de tu aplicación:

    'silenced' => [
        App\Jobs\ProcessPodcast::class,
    ],

Alternativamente, el trabajo que deseas silenciar puede implementar la interfaz `Laravel\Horizon\Contracts\Silenced`. Si un trabajo implementa esta interfaz, se silenciará automáticamente, incluso si no está presente en el array de configuración `silenced`:

    use Laravel\Horizon\Contracts\Silenced;

    class ProcessPodcast implements ShouldQueue, Silenced
    {
        use Queueable;

        // ...
    }

<a name="upgrading-horizon"></a>
## Actualizando Horizon

Al actualizar a una nueva versión principal de Horizon, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/horizon/blob/master/UPGRADE.md).

<a name="running-horizon"></a>
## Ejecutando Horizon

Una vez que hayas configurado tus supervisores y trabajadores en el archivo de configuración `config/horizon.php` de tu aplicación, puedes iniciar Horizon usando el comando Artisan `horizon`. Este único comando iniciará todos los procesos de trabajadores configurados para el entorno actual:

```shell
php artisan horizon
```

Puedes pausar el proceso de Horizon e indicarle que continúe procesando trabajos usando los comandos Artisan `horizon:pause` y `horizon:continue`:

```shell
php artisan horizon:pause

php artisan horizon:continue
```

También puedes pausar y continuar supervisores específicos de Horizon [supervisores](#supervisors) usando los comandos Artisan `horizon:pause-supervisor` y `horizon:continue-supervisor`:

```shell
php artisan horizon:pause-supervisor supervisor-1

php artisan horizon:continue-supervisor supervisor-1
```

Puedes verificar el estado actual del proceso de Horizon usando el comando Artisan `horizon:status`:

```shell
php artisan horizon:status
```

Puedes terminar el proceso de Horizon de manera elegante usando el comando Artisan `horizon:terminate`. Cualquier trabajo que se esté procesando actualmente se completará y luego Horizon dejará de ejecutarse:

```shell
php artisan horizon:terminate
```

<a name="deploying-horizon"></a>
### Desplegando Horizon

Cuando estés listo para desplegar Horizon en el servidor real de tu aplicación, debes configurar un monitor de procesos para monitorear el comando `php artisan horizon` y reiniciarlo si se detiene inesperadamente. No te preocupes, discutiremos cómo instalar un monitor de procesos a continuación.

Durante el proceso de despliegue de tu aplicación, debes indicarle al proceso de Horizon que termine para que sea reiniciado por tu monitor de procesos y reciba tus cambios de código:

```shell
php artisan horizon:terminate
```

<a name="installing-supervisor"></a>
#### Instalando Supervisor

Supervisor es un monitor de procesos para el sistema operativo Linux y reiniciará automáticamente tu proceso `horizon` si deja de ejecutarse. Para instalar Supervisor en Ubuntu, puedes usar el siguiente comando. Si no estás usando Ubuntu, probablemente puedas instalar Supervisor usando el gestor de paquetes de tu sistema operativo:

```shell
sudo apt-get install supervisor
```

> [!NOTE]  
> Si configurar Supervisor tú mismo suena abrumador, considera usar [Laravel Forge](https://forge.laravel.com), que instalará y configurará automáticamente Supervisor para tus proyectos de Laravel.

<a name="supervisor-configuration"></a>
#### Configuración de Supervisor

Los archivos de configuración de Supervisor se almacenan típicamente dentro del directorio `/etc/supervisor/conf.d` de tu servidor. Dentro de este directorio, puedes crear cualquier número de archivos de configuración que indiquen a Supervisor cómo deben ser monitoreados tus procesos. Por ejemplo, vamos a crear un archivo `horizon.conf` que inicie y monitoree un proceso `horizon`:

```ini
[program:horizon]
process_name=%(program_name)s
command=php /home/forge/example.com/artisan horizon
autostart=true
autorestart=true
user=forge
redirect_stderr=true
stdout_logfile=/home/forge/example.com/horizon.log
stopwaitsecs=3600
```

Al definir tu configuración de Supervisor, debes asegurarte de que el valor de `stopwaitsecs` sea mayor que el número de segundos consumidos por tu trabajo de mayor duración. De lo contrario, Supervisor puede matar el trabajo antes de que termine de procesarse.

> [!WARNING]  
> Mientras que los ejemplos anteriores son válidos para servidores basados en Ubuntu, la ubicación y la extensión de archivo esperadas de los archivos de configuración de Supervisor pueden variar entre otros sistemas operativos de servidor. Consulta la documentación de tu servidor para obtener más información.

<a name="starting-supervisor"></a>
#### Iniciando Supervisor

Una vez que se ha creado el archivo de configuración, puedes actualizar la configuración de Supervisor e iniciar los procesos monitoreados usando los siguientes comandos:

```shell
sudo supervisorctl reread

sudo supervisorctl update

sudo supervisorctl start horizon
```

> [!NOTE]  
> Para obtener más información sobre cómo ejecutar Supervisor, consulta la [documentación de Supervisor](http://supervisord.org/index.html).

<a name="tags"></a>
## Etiquetas

Horizon te permite asignar “etiquetas” a trabajos, incluidos mailables, eventos de difusión, notificaciones y oyentes de eventos en cola. De hecho, Horizon etiquetará de manera inteligente y automática la mayoría de los trabajos dependiendo de los modelos Eloquent que están adjuntos al trabajo. Por ejemplo, echa un vistazo al siguiente trabajo:

    <?php

    namespace App\Jobs;

    use App\Models\Video;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Foundation\Queue\Queueable;

    class RenderVideo implements ShouldQueue
    {
        use Queueable;

```php
        /**
         * Crear una nueva instancia de trabajo.
         */
        public function __construct(
            public Video $video,
        ) {}

        /**
         * Ejecutar el trabajo.
         */
        public function handle(): void
        {
            // ...
        }
    }

Si este trabajo está en cola con una instancia de `App\Models\Video` que tiene un atributo `id` de `1`, automáticamente recibirá la etiqueta `App\Models\Video:1`. Esto se debe a que Horizon buscará en las propiedades del trabajo cualquier modelo de Eloquent. Si se encuentran modelos de Eloquent, Horizon etiquetará inteligentemente el trabajo utilizando el nombre de la clase del modelo y la clave primaria:

    use App\Jobs\RenderVideo;
    use App\Models\Video;

    $video = Video::find(1);

    RenderVideo::dispatch($video);

<a name="manually-tagging-jobs"></a>
#### Etiquetado Manual de Trabajos

Si deseas definir manualmente las etiquetas para uno de tus objetos en cola, puedes definir un método `tags` en la clase:

    class RenderVideo implements ShouldQueue
    {
        /**
         * Obtener las etiquetas que deben asignarse al trabajo.
         *
         * @return array<int, string>
         */
        public function tags(): array
        {
            return ['render', 'video:'.$this->video->id];
        }
    }

<a name="manually-tagging-event-listeners"></a>
#### Etiquetado Manual de Escuchadores de Eventos

Al recuperar las etiquetas para un escuchador de eventos en cola, Horizon pasará automáticamente la instancia del evento al método `tags`, lo que te permitirá agregar datos del evento a las etiquetas:

    class SendRenderNotifications implements ShouldQueue
    {
        /**
         * Obtener las etiquetas que deben asignarse al escuchador.
         *
         * @return array<int, string>
         */
        public function tags(VideoRendered $event): array
        {
            return ['video:'.$event->video->id];
        }
    }


<a name="notifications"></a>
## Notificaciones

> [!WARNING]  
> Al configurar Horizon para enviar notificaciones de Slack o SMS, debes revisar los [requisitos previos para el canal de notificación relevante](/docs/{{version}}/notifications).

Si deseas ser notificado cuando una de tus colas tiene un tiempo de espera largo, puedes usar los métodos `Horizon::routeMailNotificationsTo`, `Horizon::routeSlackNotificationsTo` y `Horizon::routeSmsNotificationsTo`. Puedes llamar a estos métodos desde el método `boot` del `App\Providers\HorizonServiceProvider` de tu aplicación:

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        parent::boot();

        Horizon::routeSmsNotificationsTo('15556667777');
        Horizon::routeMailNotificationsTo('example@example.com');
        Horizon::routeSlackNotificationsTo('slack-webhook-url', '#channel');
    }

<a name="configuring-notification-wait-time-thresholds"></a>
#### Configuración de Umbrales de Tiempo de Espera de Notificaciones

Puedes configurar cuántos segundos se consideran una "larga espera" dentro del archivo de configuración `config/horizon.php` de tu aplicación. La opción de configuración `waits` dentro de este archivo te permite controlar el umbral de larga espera para cada combinación de conexión / cola. Cualquier combinación de conexión / cola no definida tendrá un umbral de larga espera de 60 segundos:

    'waits' => [
        'redis:critical' => 30,
        'redis:default' => 60,
        'redis:batch' => 120,
    ],

<a name="metrics"></a>
## Métricas

Horizon incluye un panel de métricas que proporciona información sobre los tiempos de espera y el rendimiento de tus trabajos y colas. Para poblar este panel, debes configurar el comando Artisan `snapshot` de Horizon para que se ejecute cada cinco minutos en el archivo `routes/console.php` de tu aplicación:

    use Illuminate\Support\Facades\Schedule;

    Schedule::command('horizon:snapshot')->everyFiveMinutes();

<a name="deleting-failed-jobs"></a>
## Eliminación de Trabajos Fallidos

Si deseas eliminar un trabajo fallido, puedes usar el comando `horizon:forget`. El comando `horizon:forget` acepta el ID o UUID del trabajo fallido como su único argumento:

```shell
php artisan horizon:forget 5
```

<a name="clearing-jobs-from-queues"></a>
## Limpiar Trabajos de las Colas

Si deseas eliminar todos los trabajos de la cola predeterminada de tu aplicación, puedes hacerlo utilizando el comando Artisan `horizon:clear`:

```shell
php artisan horizon:clear
```

Puedes proporcionar la opción `queue` para eliminar trabajos de una cola específica:

```shell
php artisan horizon:clear --queue=emails
```
