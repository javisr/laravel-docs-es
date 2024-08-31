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
- [Limpiando Trabajos de Colas](#clearing-jobs-from-queues)

<a name="introduction"></a>
## Introducción

> [!NOTE]
Antes de adentrarte en Laravel Horizon, debes familiarizarte con los [servicios de cola](/docs/%7B%7Bversion%7D%7D/queues) básicos de Laravel. Horizon complementa la cola de Laravel con características adicionales que pueden ser confusas si no estás ya familiarizado con las funciones de cola básicas que ofrece Laravel.
[Laravel Horizon](https://github.com/laravel/horizon) proporciona un hermoso panel y configuración basada en código para tus [colas Redis](/docs/%7B%7Bversion%7D%7D/queues) impulsadas por Laravel. Horizon te permite monitorear fácilmente métricas clave de tu sistema de colas, como el rendimiento de trabajos, tiempo de ejecución y fallos de trabajos.
Cuando uses Horizon, toda la configuración de tus trabajadores de cola se almacena en un solo archivo de configuración simple. Al definir la configuración de los trabajadores de tu aplicación en un archivo controlado por versión, puedes escalar o modificar fácilmente los trabajadores de cola de tu aplicación al desplegar tu aplicación.
<img src="https://laravel.com/img/docs/horizon-example.png">

<a name="installation"></a>
## Instalación

> [!WARNING]
Laravel Horizon requiere que utilices [Redis](https://redis.io) para gestionar tu cola. Por lo tanto, debes asegurarte de que tu conexión de cola esté configurada en `redis` en el archivo de configuración `config/queue.php` de tu aplicación.
Puedes instalar Horizon en tu proyecto utilizando el gestor de paquetes Composer:


```shell
composer require laravel/horizon

```
Después de instalar Horizon, publica sus activos utilizando el comando Artisan `horizon:install`:


```shell
php artisan horizon:install

```

<a name="configuration"></a>
### Configuración

Después de publicar los activos de Horizon, su archivo de configuración principal se ubicará en `config/horizon.php`. Este archivo de configuración te permite configurar las opciones del trabajador de cola para tu aplicación. Cada opción de configuración incluye una descripción de su propósito, así que asegúrate de explorar a fondo este archivo.
> [!WARNING]
Horizon utiliza internamente una conexión Redis llamada `horizon`. Este nombre de conexión Redis está reservado y no debe asignarse a otra conexión Redis en el archivo de configuración `database.php` o como el valor de la opción `use` en el archivo de configuración `horizon.php`.

<a name="environments"></a>
#### Entornos

Después de la instalación, la opción de configuración principal de Horizon con la que debes familiarizarte es la opción de configuración `environments`. Esta opción de configuración es un array de entornos en los que se ejecuta tu aplicación y define las opciones del proceso de trabajo para cada entorno. Por defecto, esta entrada contiene un entorno `production` y `local`. Sin embargo, puedes añadir más entornos según sea necesario:


```php
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
```
También puedes definir un entorno comodín (`*`) que se usará cuando no se encuentre otro entorno coincidente:


```php
'environments' => [
    // ...

    '*' => [
        'supervisor-1' => [
            'maxProcesses' => 3,
        ],
    ],
],
```
Cuando inicias Horizon, utilizará las opciones de configuración del proceso de trabajo para el entorno en el que se está ejecutando tu aplicación. Típicamente, el entorno se determina por el valor de la variable de entorno `APP_ENV` [variable de entorno](/docs/%7B%7Bversion%7D%7D/configuration#determining-the-current-environment). Por ejemplo, el entorno `local` de Horizon por defecto está configurado para iniciar tres procesos de trabajo y equilibrar automáticamente el número de procesos de trabajo asignados a cada cola. El entorno `production` por defecto está configurado para iniciar un máximo de 10 procesos de trabajo y equilibrar automáticamente el número de procesos de trabajo asignados a cada cola.
> [!WARNING]
Debes asegurarte de que la porción `environments` de tu archivo de configuración `horizon` contenga una entrada para cada [entorno](/docs/%7B%7Bversion%7D%7D/configuration#environment-configuration) en el que planeas ejecutar Horizon.

<a name="supervisors"></a>
#### Supervisores

Como puedes ver en el archivo de configuración predeterminado de Horizon, cada entorno puede contener uno o más "supervisores". Por defecto, el archivo de configuración define este supervisor como `supervisor-1`; sin embargo, puedes nombrar a tus supervisores como desees. Cada supervisor es esencialmente responsable de "supervisar" un grupo de procesos de trabajo y se encarga de equilibrar los procesos de trabajo entre las colas.
Puedes añadir supervisores adicionales a un entorno dado si deseas definir un nuevo grupo de procesos de trabajo que deben ejecutarse en ese entorno. Puedes elegir hacer esto si deseas definir una estrategia de balanceo diferente o un conteo de procesos de trabajo para una cola dada utilizada por tu aplicación.

<a name="maintenance-mode"></a>
#### Modo de Mantenimiento

Mientras tu aplicación esté en [modo de mantenimiento](/docs/%7B%7Bversion%7D%7D/configuration#maintenance-mode), los trabajos en cola no serán procesados por Horizon a menos que la opción `force` del supervisor esté definida como `true` dentro del archivo de configuración de Horizon:


```php
'environments' => [
    'production' => [
        'supervisor-1' => [
            // ...
            'force' => true,
        ],
    ],
],
```

<a name="default-values"></a>
#### Valores Predeterminados

Dentro del archivo de configuración predeterminado de Horizon, notarás una opción de configuración `defaults`. Esta opción de configuración especifica los valores predeterminados para los [supervisores](#supervisors) de tu aplicación. Los valores de configuración predeterminados del supervisor se combinarán en la configuración del supervisor para cada entorno, lo que te permitirá evitar repeticiones innecesarias al definir tus supervisores.

<a name="balancing-strategies"></a>
### Estrategias de Balanceo

A diferencia del sistema de cola predeterminado de Laravel, Horizon te permite elegir entre tres estrategias de balanceo de trabajadores: `simple`, `auto` y `false`. La estrategia `simple` divide los trabajos entrantes de manera uniforme entre los procesos de trabajo:


```php
'balance' => 'simple',
```
La estrategia `auto`, que es la predeterminada del archivo de configuración, ajusta el número de procesos de trabajo por cola en función de la carga de trabajo actual de la cola. Por ejemplo, si tu cola `notifications` tiene 1,000 trabajos pendientes mientras que tu cola `render` está vacía, Horizon asignará más trabajadores a tu cola `notifications` hasta que la cola esté vacía.
Al utilizar la estrategia `auto`, puedes definir las opciones de configuración `minProcesses` y `maxProcesses` para controlar el número mínimo de procesos por cola y el número máximo de procesos de trabajo en total a los que Horizon debe escalar hacia arriba y hacia abajo:


```php
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
```
El valor de configuración `autoScalingStrategy` determina si Horizon asignará más procesos de trabajo a las colas en función del tiempo total que llevará limpiar la cola (`estrategia time`) o por el número total de trabajos en la cola (`estrategia size`).
Los valores de configuración `balanceMaxShift` y `balanceCooldown` determinan cuán rápido escalará Horizon para satisfacer la demanda de los trabajadores. En el ejemplo anterior, se crearán o destruirán un máximo de un nuevo proceso cada tres segundos. Puedes ajustar estos valores según sea necesario en función de las necesidades de tu aplicación.
Cuando la opción `balance` está configurada en `false`, se utilizará el comportamiento predeterminado de Laravel, en el que las colas se procesan en el orden en que están listadas en tu configuración.

<a name="dashboard-authorization"></a>
### Autorización del Dashboard

El panel de Horizon se puede acceder a través de la ruta `/horizon`. Por defecto, solo podrás acceder a este panel en el entorno `local`. Sin embargo, dentro de tu archivo `app/Providers/HorizonServiceProvider.php`, hay una definición de [puerta de autorización](/docs/%7B%7Bversion%7D%7D/authorization#gates). Esta puerta de autorización controla el acceso a Horizon en entornos **no locales**. Puedes modificar esta puerta según sea necesario para restringir el acceso a tu instalación de Horizon:


```php
/**
 * Register the Horizon gate.
 *
 * This gate determines who can access Horizon in non-local environments.
 */
protected function gate(): void
{
    Gate::define('viewHorizon', function (User $user) {
        return in_array($user->email, [
            'taylor@laravel.com',
        ]);
    });
}
```

<a name="alternative-authentication-strategies"></a>
#### Estrategias de Autenticación Alternativas

Recuerda que Laravel inyecta automáticamente al usuario autenticado en la función anónima de la puerta de acceso. Si tu aplicación está proporcionando seguridad de Horizon a través de otro método, como restricciones de IP, entonces tus usuarios de Horizon pueden no necesitar "iniciar sesión". Por lo tanto, necesitarás cambiar la firma de la función anónima `function (User $user)` arriba a `function (User $user = null)` para obligar a Laravel a no requerir autenticación.

<a name="silenced-jobs"></a>
### Trabajos Silenciados

A veces, es posible que no estés interesado en ver ciertos trabajos despachados por tu aplicación o paquetes de terceros. En lugar de que estos trabajos ocupen espacio en tu lista de "Trabajos Completados", puedes silenciarlos. Para comenzar, añade el nombre de la clase del trabajo a la opción de configuración `silenced` en el archivo de configuración `horizon` de tu aplicación:


```php
'silenced' => [
    App\Jobs\ProcessPodcast::class,
],
```
Alternativamente, el trabajo que deseas silenciar puede implementar la interfaz `Laravel\Horizon\Contracts\Silenced`. Si un trabajo implementa esta interfaz, se silenciará automáticamente, incluso si no está presente en el array de configuración `silenced`:


```php
use Laravel\Horizon\Contracts\Silenced;

class ProcessPodcast implements ShouldQueue, Silenced
{
    use Queueable;

    // ...
}
```

<a name="upgrading-horizon"></a>
## Actualizando Horizon

Al actualizar a una nueva versión mayor de Horizon, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/horizon/blob/master/UPGRADE.md).

<a name="running-horizon"></a>
## Ejecutando Horizon

Una vez que hayas configurado tus supervisores y trabajadores en el archivo de configuración `config/horizon.php` de tu aplicación, puedes iniciar Horizon utilizando el comando Artisan `horizon`. Este único comando iniciará todos los procesos de trabajo configurados para el entorno actual:


```shell
php artisan horizon

```
Puedes pausar el proceso de Horizon e indicarle que continúe procesando trabajos utilizando los comandos Artisan `horizon:pause` y `horizon:continue`:


```shell
php artisan horizon:pause

php artisan horizon:continue

```
También puedes pausar y continuar supervisores específicos de Horizon [supervisores](#supervisors) utilizando los comandos Artisan `horizon:pause-supervisor` y `horizon:continue-supervisor`:


```shell
php artisan horizon:pause-supervisor supervisor-1

php artisan horizon:continue-supervisor supervisor-1

```
Puedes verificar el estado actual del proceso de Horizon utilizando el comando Artisan `horizon:status`:


```shell
php artisan horizon:status

```
Puedes finalizar el proceso de Horizon de forma elegante utilizando el comando Artisan `horizon:terminate`. Cualquier trabajo que se esté procesando actualmente se completará y luego Horizon dejará de ejecutarse:

<a name="deploying-horizon"></a>
### Desplegando Horizon

Cuando estés listo para implementar Horizon en el servidor real de tu aplicación, deberías configurar un monitor de procesos para supervisar el comando `php artisan horizon` y reiniciarlo si sale inesperadamente. No te preocupes, discutiremos cómo instalar un monitor de procesos a continuación.
Durante el proceso de despliegue de tu aplicación, debes instruir al proceso de Horizon a que se termine para que sea reiniciado por tu monitor de procesos y reciba tus cambios de código:


```shell
php artisan horizon:terminate

```

<a name="installing-supervisor"></a>
#### Instalando Supervisor

Supervisor es un monitor de procesos para el sistema operativo Linux y reiniciará automáticamente tu proceso `horizon` si deja de ejecutarse. Para instalar Supervisor en Ubuntu, puedes usar el siguiente comando. Si no estás utilizando Ubuntu, probablemente puedas instalar Supervisor utilizando el administrador de paquetes de tu sistema operativo:


```shell
sudo apt-get install supervisor

```
> [!NOTA]
Si configurar Supervisor tú mismo te parece abrumador, considera usar [Laravel Forge](https://forge.laravel.com), que instalará y configurará Supervisor automáticamente para tus proyectos Laravel.

<a name="supervisor-configuration"></a>
#### Configuración del Supervisor

Los archivos de configuración de Supervisor se almacenan típicamente en el directorio `/etc/supervisor/conf.d` de tu servidor. Dentro de este directorio, puedes crear cualquier número de archivos de configuración que indiquen a Supervisor cómo se deben monitorear tus procesos. Por ejemplo, vamos a crear un archivo `horizon.conf` que inicie y monitoree un proceso `horizon`:


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
Al definir la configuración de tu Supervisor, debes asegurarte de que el valor de `stopwaitsecs` sea mayor que el número de segundos consumidos por tu trabajo de mayor duración. De lo contrario, Supervisor puede matar el trabajo antes de que haya terminado de procesar.
> [!WARNING]
Aunque los ejemplos anteriores son válidos para servidores basados en Ubuntu, la ubicación y la extensión de archivo que se espera de los archivos de configuración de Supervisor pueden variar entre otros sistemas operativos de servidor. Consulta la documentación de tu servidor para obtener más información.

<a name="starting-supervisor"></a>
#### Iniciando Supervisor

Una vez que se ha creado el archivo de configuración, puedes actualizar la configuración del Supervisor y comenzar los procesos monitorizados utilizando los siguientes comandos:


```shell
sudo supervisorctl reread

sudo supervisorctl update

sudo supervisorctl start horizon

```
> [!NOTE]
Para obtener más información sobre cómo ejecutar Supervisor, consulta la [documentación de Supervisor](http://supervisord.org/index.html).

<a name="tags"></a>
## Etiquetas

Horizon te permite asignar “etiquetas” a trabajos, incluidos mailables, eventos de transmisión, notificaciones y oyentes de eventos en cola. De hecho, Horizon etiquetará de manera inteligente y automática la mayoría de los trabajos según los modelos Eloquent que están adjuntos al trabajo. Por ejemplo, echa un vistazo al siguiente trabajo:


```php
<?php

namespace App\Jobs;

use App\Models\Video;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class RenderVideo implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public Video $video,
    ) {}

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        // ...
    }
}
```
Si este trabajo está en cola con una instancia de `App\Models\Video` que tiene un atributo `id` de `1`, recibirá automáticamente la etiqueta `App\Models\Video:1`. Esto se debe a que Horizon buscará las propiedades del trabajo para encontrar cualquier modelo Eloquent. Si se encuentran modelos Eloquent, Horizon etiquetará de manera inteligente el trabajo utilizando el nombre de la clase del modelo y la clave primaria:


```php
use App\Jobs\RenderVideo;
use App\Models\Video;

$video = Video::find(1);

RenderVideo::dispatch($video);
```

<a name="manually-tagging-jobs"></a>
#### Etiquetando Jobs Manualmente

Si deseas definir manualmente las etiquetas para uno de tus objetos en cola, puedes definir un método `tags` en la clase:


```php
class RenderVideo implements ShouldQueue
{
    /**
     * Get the tags that should be assigned to the job.
     *
     * @return array<int, string>
     */
    public function tags(): array
    {
        return ['render', 'video:'.$this->video->id];
    }
}
```

<a name="manually-tagging-event-listeners"></a>
#### Etiquetado Manual de Escuchas de Eventos

Al recuperar las etiquetas para un listener de eventos en cola, Horizon pasará automáticamente la instancia del evento al método `tags`, lo que te permitirá agregar datos del evento a las etiquetas:


```php
class SendRenderNotifications implements ShouldQueue
{
    /**
     * Get the tags that should be assigned to the listener.
     *
     * @return array<int, string>
     */
    public function tags(VideoRendered $event): array
    {
        return ['video:'.$event->video->id];
    }
}
```

<a name="notifications"></a>
## Notificaciones

> [!WARNING]
Al configurar Horizon para enviar notificaciones de Slack o SMS, debes revisar los [requisitos previos para el canal de notificación relevante](/docs/%7B%7Bversion%7D%7D/notifications).
Si deseas ser notificado cuando una de tus colas tiene un tiempo de espera largo, puedes usar los métodos `Horizon::routeMailNotificationsTo`, `Horizon::routeSlackNotificationsTo` y `Horizon::routeSmsNotificationsTo`. Puedes llamar a estos métodos desde el método `boot` del `App\Providers\HorizonServiceProvider` de tu aplicación:


```php
/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    parent::boot();

    Horizon::routeSmsNotificationsTo('15556667777');
    Horizon::routeMailNotificationsTo('example@example.com');
    Horizon::routeSlackNotificationsTo('slack-webhook-url', '#channel');
}
```

<a name="configuring-notification-wait-time-thresholds"></a>
#### Configurando Umbrales de Tiempo de Espera para Notificaciones

Puedes configurar cuántos segundos se consideran una "espera larga" dentro del archivo de configuración `config/horizon.php` de tu aplicación. La opción de configuración `waits` dentro de este archivo te permite controlar el umbral de espera larga para cada combinación de conexión / cola. Cualquier combinación de conexión / cola no definida tendrá por defecto un umbral de espera larga de 60 segundos:


```php
'waits' => [
    'redis:critical' => 30,
    'redis:default' => 60,
    'redis:batch' => 120,
],
```

<a name="metrics"></a>
## Métricas

Horizon incluye un panel de métricas que proporciona información sobre los tiempos de espera de tus trabajos y colas, así como el rendimiento. Para rellenar este panel, debes configurar el comando Artisan `snapshot` de Horizon para que se ejecute cada cinco minutos en el archivo `routes/console.php` de tu aplicación:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('horizon:snapshot')->everyFiveMinutes();
```

<a name="deleting-failed-jobs"></a>
## Eliminando Trabajos Fallidos

Si deseas eliminar un trabajo fallido, puedes usar el comando `horizon:forget`. El comando `horizon:forget` acepta la ID o UUID del trabajo fallido como su único argumento:


```shell
php artisan horizon:forget 5

```
Si deseas eliminar todos los trabajos fallidos, puedes proporcionar la opción `--all` al comando `horizon:forget`:


```shell
php artisan horizon:forget --all

```

<a name="clearing-jobs-from-queues"></a>
## Limpiando Trabajos de las Colas

Si deseas eliminar todos los trabajos de la cola predeterminada de tu aplicación, puedes hacerlo utilizando el comando Artisan `horizon:clear`:


```shell
php artisan horizon:clear

```
Puedes proporcionar la opción `queue` para eliminar trabajos de una cola específica:


```shell
php artisan horizon:clear --queue=emails

```