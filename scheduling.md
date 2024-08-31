# Programación de Tareas

- [Introducción](#introduction)
- [Definiendo Horarios](#defining-schedules)
  - [Programando Comandos Artisan](#scheduling-artisan-commands)
  - [Programando Trabajos en Cola](#scheduling-queued-jobs)
  - [Programando Comandos Shell](#scheduling-shell-commands)
  - [Opciones de Frecuencia de Horario](#schedule-frequency-options)
  - [Zonas Horarias](#timezones)
  - [Previniendo Superposiciones de Tareas](#preventing-task-overlaps)
  - [Ejecutando Tareas en un Servidor](#running-tasks-on-one-server)
  - [Tareas en Segundo Plano](#background-tasks)
  - [Modo de Mantenimiento](#maintenance-mode)
- [Ejecutando el Programador](#running-the-scheduler)
  - [Tareas Programadas de Menos de un Minuto](#sub-minute-scheduled-tasks)
  - [Ejecutando el Programador Localmente](#running-the-scheduler-locally)
- [Salida de Tareas](#task-output)
- [Ganchos de Tareas](#task-hooks)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

En el pasado, es posible que hayas escrito una entrada de configuración de cron para cada tarea que necesitabas programar en tu servidor. Sin embargo, esto puede convertirse rápidamente en un dolor de cabeza porque tu programación de tareas ya no está en control de versiones y debes acceder por SSH a tu servidor para ver tus entradas de cron existentes o agregar entradas adicionales.
El programador de comandos de Laravel ofrece un enfoque innovador para gestionar tareas programadas en tu servidor. El programador te permite definir tu programación de comandos de manera fluida y expresiva dentro de tu propia aplicación Laravel. Al utilizar el programador, solo se necesita una única entrada de cron en tu servidor. Tu horario de tareas suele definirse en el archivo `routes/console.php` de tu aplicación.

<a name="defining-schedules"></a>
## Definiendo Horarios

Puedes definir todas tus tareas programadas en el archivo `routes/console.php` de tu aplicación. Para comenzar, echaremos un vistazo a un ejemplo. En este ejemplo, programaremos una `función anónima` para que se llame todos los días a la medianoche. Dentro de la `función anónima` ejecutaremos una consulta a la base de datos para limpiar una tabla:


```php
<?php

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schedule;

Schedule::call(function () {
    DB::table('recent_users')->delete();
})->daily();
```
Además de programar utilizando funciones anónimas, también puedes programar [objetos invocables](https://secure.php.net/manual/en/language.oop5.magic.php#object.invoke). Los objetos invocables son clases PHP simples que contienen un método `__invoke`:


```php
Schedule::call(new DeleteRecentUsers)->daily();
```
Si prefieres reservar tu archivo `routes/console.php` solo para definiciones de comandos, puedes usar el método `withSchedule` en el archivo `bootstrap/app.php` de tu aplicación para definir tus tareas programadas. Este método acepta una función anónima que recibe una instancia del programador:


```php
use Illuminate\Console\Scheduling\Schedule;

->withSchedule(function (Schedule $schedule) {
    $schedule->call(new DeleteRecentUsers)->daily();
})
```
Si deseas ver un resumen de tus tareas programadas y la próxima vez que estén programadas para ejecutarse, puedes usar el comando Artisan `schedule:list`:


```bash
php artisan schedule:list

```

<a name="scheduling-artisan-commands"></a>
### Programando Comandos Artisan

Además de programar `funciones anónimas`, también puedes programar [comandos Artisan](/docs/%7B%7Bversion%7D%7D/artisan) y comandos del sistema. Por ejemplo, puedes usar el método `command` para programar un comando Artisan utilizando el nombre o la clase del comando.
Al programar comandos Artisan utilizando el nombre de la clase del comando, puedes pasar un array de argumentos adicionales de línea de comandos que se deben proporcionar al comando cuando se invoque:


```php
use App\Console\Commands\SendEmailsCommand;
use Illuminate\Support\Facades\Schedule;

Schedule::command('emails:send Taylor --force')->daily();

Schedule::command(SendEmailsCommand::class, ['Taylor', '--force'])->daily();
```

<a name="scheduling-artisan-closure-commands"></a>
#### Programando Comandos de Closure de Artisan

Si deseas programar un comando Artisan definido por una función anónima, puedes encadenar los métodos relacionados con la programación después de la definición del comando:


```php
Artisan::command('delete:recent-users', function () {
    DB::table('recent_users')->delete();
})->purpose('Delete recent users')->daily();
```
Si necesitas pasar argumentos al comando de la función anónima, puedes proporcionarlos al método `schedule`:


```php
Artisan::command('emails:send {user} {--force}', function ($user) {
    // ...
})->purpose('Send emails to the specified user')->schedule(['Taylor', '--force'])->daily();
```

<a name="scheduling-queued-jobs"></a>
### Programando Trabajos en Cola

El método `job` se puede utilizar para programar un [trabajo en cola](/docs/%7B%7Bversion%7D%7D/queues). Este método proporciona una forma conveniente de programar trabajos en cola sin usar el método `call` para definir funciones anónimas que coloquen el trabajo en cola:


```php
use App\Jobs\Heartbeat;
use Illuminate\Support\Facades\Schedule;

Schedule::job(new Heartbeat)->everyFiveMinutes();
```
Se pueden proporcionar argumentos opcionales segundo y tercero al método `job`, que especifican el nombre de la cola y la conexión de cola que se deben usar para encolar el trabajo:


```php
use App\Jobs\Heartbeat;
use Illuminate\Support\Facades\Schedule;

// Dispatch the job to the "heartbeats" queue on the "sqs" connection...
Schedule::job(new Heartbeat, 'heartbeats', 'sqs')->everyFiveMinutes();
```

<a name="scheduling-shell-commands"></a>
### Programando Comandos Shell

El método `exec` se puede utilizar para emitir un comando al sistema operativo:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::exec('node /home/forge/script.js')->daily();
```

<a name="schedule-frequency-options"></a>
### Opciones de Frecuencia de Programación

Ya hemos visto algunos ejemplos de cómo puedes configurar una tarea para que se ejecute en intervalos específicos. Sin embargo, hay muchas más frecuencias de programación de tareas que puedes asignar a una tarea:
<div class="overflow-auto">

| Método                             | Descripción                                             |
| ---------------------------------- | ------------------------------------------------------ |
| `->cron('* * * * *');`             | Ejecuta la tarea en un horario cron personalizado.     |
| `->everySecond();`                 | Ejecuta la tarea cada segundo.                         |
| `->everyTwoSeconds();`             | Ejecuta la tarea cada dos segundos.                    |
| `->everyFiveSeconds();`            | Ejecuta la tarea cada cinco segundos.                  |
| `->everyTenSeconds();`             | Ejecuta la tarea cada diez segundos.                   |
| `->everyFifteenSeconds();`         | Ejecuta la tarea cada quince segundos.                 |
| `->everyTwentySeconds();`          | Ejecuta la tarea cada veinte segundos.                 |
| `->everyThirtySeconds();`          | Ejecuta la tarea cada treinta segundos.                 |
| `->everyMinute();`                 | Ejecuta la tarea cada minuto.                          |
| `->everyTwoMinutes();`             | Ejecuta la tarea cada dos minutos.                     |
| `->everyThreeMinutes();`           | Ejecuta la tarea cada tres minutos.                    |
| `->everyFourMinutes();`            | Ejecuta la tarea cada cuatro minutos.                  |
| `->everyFiveMinutes();`            | Ejecuta la tarea cada cinco minutos.                   |
| `->everyTenMinutes();`             | Ejecuta la tarea cada diez minutos.                    |
| `->everyFifteenMinutes();`         | Ejecuta la tarea cada quince minutos.                  |
| `->everyThirtyMinutes();`          | Ejecuta la tarea cada treinta minutos.                 |
| `->hourly();`                      | Ejecuta la tarea cada hora.                            |
| `->hourlyAt(17);`                  | Ejecuta la tarea cada hora a los 17 minutos después de la hora. |
| `->everyOddHour($minutes = 0);`    | Ejecuta la tarea cada hora impar.                      |
| `->everyTwoHours($minutes = 0);`   | Ejecuta la tarea cada dos horas.                       |
| `->everyThreeHours($minutes = 0);` | Ejecuta la tarea cada tres horas.                     |
| `->everyFourHours($minutes = 0);`  | Ejecuta la tarea cada cuatro horas.                    |
| `->everySixHours($minutes = 0);`   | Ejecuta la tarea cada seis horas.                      |
| `->daily();`                       | Ejecuta la tarea cada día a medianoche.                |
| `->dailyAt('13:00');`              | Ejecuta la tarea cada día a las 13:00.                 |
| `->twiceDaily(1, 13);`             | Ejecuta la tarea diariamente a las 1:00 y 13:00.      |
| `->twiceDailyAt(1, 13, 15);`       | Ejecuta la tarea diariamente a las 1:15 y 13:15.      |
| `->weekly();`                      | Ejecuta la tarea cada domingo a las 00:00.            |
| `->weeklyOn(1, '8:00');`           | Ejecuta la tarea cada semana el lunes a las 8:00.     |
| `->monthly();`                     | Ejecuta la tarea el primer día de cada mes a las 00:00.|
| `->monthlyOn(4, '15:00');`         | Ejecuta la tarea cada mes el 4 a las 15:00.            |
| `->twiceMonthly(1, 16, '13:00');`  | Ejecuta la tarea mensualmente el 1 y el 16 a las 13:00.|
| `->lastDayOfMonth('15:00');`       | Ejecuta la tarea el último día del mes a las 15:00.    |
| `->quarterly();`                   | Ejecuta la tarea el primer día de cada trimestre a las 00:00. |
| `->quarterlyOn(4, '14:00');`       | Ejecuta la tarea cada trimestre el 4 a las 14:00.     |
| `->yearly();`                      | Ejecuta la tarea el primer día de cada año a las 00:00.|
| `->yearlyOn(6, 1, '17:00');`       | Ejecuta la tarea cada año el 1 de junio a las 17:00.   |
| `->timezone('America/New_York');`  | Establece la zona horaria para la tarea.               |
</div>
Estos métodos pueden combinarse con restricciones adicionales para crear horarios aún más ajustados que solo se ejecuten en ciertos días de la semana. Por ejemplo, puede programar un comando para que se ejecute semanalmente el lunes:


```php
use Illuminate\Support\Facades\Schedule;

// Run once per week on Monday at 1 PM...
Schedule::call(function () {
    // ...
})->weekly()->mondays()->at('13:00');

// Run hourly from 8 AM to 5 PM on weekdays...
Schedule::command('foo')
          ->weekdays()
          ->hourly()
          ->timezone('America/Chicago')
          ->between('8:00', '17:00');
```
A continuación se puede encontrar una lista de restricciones de programación adicionales:
<div class="overflow-auto">

| Método                                   | Descripción                                           |
| ---------------------------------------- | ----------------------------------------------------- |
| `->weekdays();`                          | Limitar la tarea a los días laborables.              |
| `->weekends();`                          | Limitar la tarea a los fines de semana.              |
| `->sundays();`                           | Limitar la tarea al domingo.                          |
| `->mondays();`                           | Limitar la tarea al lunes.                            |
| `->tuesdays();`                          | Limitar la tarea al martes.                           |
| `->wednesdays();`                        | Limitar la tarea al miércoles.                        |
| `->thursdays();`                         | Limitar la tarea al jueves.                           |
| `->fridays();`                           | Limitar la tarea al viernes.                          |
| `->saturdays();`                         | Limitar la tarea al sábado.                           |
| `->days(array\|mixed);`                  | Limitar la tarea a días específicos.                  |
| `->between($startTime, $endTime);`       | Limitar la tarea a ejecutarse entre horas de inicio y fin. |
| `->unlessBetween($startTime, $endTime);` | Limitar la tarea a no ejecutarse entre horas de inicio y fin. |
| `->when(Closure);`                       | Limitar la tarea en función de una prueba de verdad. |
| `->environments($env);`                  | Limitar la tarea a entornos específicos.              |
</div>

<a name="day-constraints"></a>
#### Restricciones de Día

El método `days` se puede utilizar para limitar la ejecución de una tarea a días específicos de la semana. Por ejemplo, puedes programar un comando para que se ejecute cada hora los domingos y miércoles:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('emails:send')
                ->hourly()
                ->days([0, 3]);
```
Alternativamente, puedes usar las constantes disponibles en la clase `Illuminate\Console\Scheduling\Schedule` al definir los días en los que una tarea debe ejecutarse:


```php
use Illuminate\Support\Facades;
use Illuminate\Console\Scheduling\Schedule;

Facades\Schedule::command('emails:send')
                ->hourly()
                ->days([Schedule::SUNDAY, Schedule::WEDNESDAY]);
```

<a name="between-time-constraints"></a>
#### Entre las Restricciones de Tiempo

El método `between` se puede utilizar para limitar la ejecución de una tarea en función de la hora del día:


```php
Schedule::command('emails:send')
                    ->hourly()
                    ->between('7:00', '22:00');
```
De manera similar, el método `unlessBetween` se puede utilizar para excluir la ejecución de una tarea durante un período de tiempo:


```php
Schedule::command('emails:send')
                    ->hourly()
                    ->unlessBetween('23:00', '4:00');
```

<a name="truth-test-constraints"></a>
#### Restricciones de Prueba de Verdad

El método `when` se puede utilizar para limitar la ejecución de una tarea en función del resultado de una prueba de verdad dada. En otras palabras, si la `función anónima` dada devuelve `true`, la tarea se ejecutará siempre que no haya otras condiciones restrictivas que impidan que la tarea se ejecute:


```php
Schedule::command('emails:send')->daily()->when(function () {
    return true;
});
```
El método `skip` puede verse como el inverso de `when`. Si el método `skip` devuelve `true`, la tarea programada no se ejecutará:


```php
Schedule::command('emails:send')->daily()->skip(function () {
    return true;
});
```
Al utilizar métodos `when` encadenados, el comando programado solo se ejecutará si todas las condiciones `when` devuelven `true`.

<a name="environment-constraints"></a>
#### Restricciones del Entorno

El método `environments` se puede usar para ejecutar tareas solo en los entornos dados (según lo definido por la variable de entorno `APP_ENV` [variable de entorno](/docs/%7B%7Bversion%7D%7D/configuration#environment-configuration)):


```php
Schedule::command('emails:send')
            ->daily()
            ->environments(['staging', 'production']);
```

<a name="timezones"></a>
### Zonas horarias

Usando el método `timezone`, puedes especificar que la hora de una tarea programada debe interpretarse dentro de una zona horaria dada:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('report:generate')
         ->timezone('America/New_York')
         ->at('2:00')
```
Si estás asignando repetidamente la misma zona horaria a todas tus tareas programadas, puedes especificar qué zona horaria se debe asignar a todos los horarios definiendo una opción `schedule_timezone` dentro del archivo de configuración `app` de tu aplicación:


```php
'timezone' => env('APP_TIMEZONE', 'UTC'),

'schedule_timezone' => 'America/Chicago',
```
> [!WARNING]
Recuerda que algunas zonas horarias utilizan el horario de verano. Cuando ocurren cambios en el horario de verano, es posible que tu tarea programada se ejecute dos veces o incluso no se ejecute en absoluto. Por esta razón, recomendamos evitar la programación de zonas horarias cuando sea posible.

<a name="preventing-task-overlaps"></a>
### Previniendo Superposiciones de Tareas

Por defecto, las tareas programadas se ejecutarán incluso si la instancia anterior de la tarea aún se está ejecutando. Para evitar esto, puedes usar el método `withoutOverlapping`:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('emails:send')->withoutOverlapping();
```
En este ejemplo, el comando [Artisan `emails:send`](/docs/%7B%7Bversion%7D%7D/artisan) se ejecutará cada minuto si no se está ejecutando ya. El método `withoutOverlapping` es especialmente útil si tienes tareas que varían drásticamente en su tiempo de ejecución, lo que te impide predecir exactamente cuánto tiempo tomará una tarea dada.
Si es necesario, puedes especificar cuántos minutos deben pasar antes de que se expire el bloqueo "sin solapamientos". Por defecto, el bloqueo expirará después de 24 horas:


```php
Schedule::command('emails:send')->withoutOverlapping(10);
```
Detrás de escena, el método `withoutOverlapping` utiliza la [cache](/docs/%7B%7Bversion%7D%7D/cache) de tu aplicación para obtener bloqueos. Si es necesario, puedes limpiar estos bloqueos de caché utilizando el comando Artisan `schedule:clear-cache`. Esto generalmente solo es necesario si una tarea se queda atascada debido a un problema inesperado del servidor.

<a name="running-tasks-on-one-server"></a>
### Ejecutando Tareas en un Servidor

> [!WARNING]
Para utilizar esta función, tu aplicación debe estar utilizando el driver de caché `database`, `memcached`, `dynamodb` o `redis` como el driver de caché predeterminado de tu aplicación. Además, todos los servidores deben estar comunicándose con el mismo servidor de caché central.
Si el programador de tu aplicación está ejecutándose en múltiples servidores, puedes limitar un trabajo programado para que se ejecute solo en un solo servidor. Por ejemplo, supongamos que tienes una tarea programada que genera un nuevo informe cada viernes por la noche. Si el programador de tareas se está ejecutando en tres servidores de trabajo, la tarea programada se ejecutará en los tres servidores y generará el informe tres veces. ¡No es bueno!
Para indicar que la tarea debe ejecutarse en un solo servidor, utiliza el método `onOneServer` al definir la tarea programada. El primer servidor en obtener la tarea asegurará un bloqueo atómico en el trabajo para evitar que otros servidores ejecuten la misma tarea al mismo tiempo:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('report:generate')
                ->fridays()
                ->at('17:00')
                ->onOneServer();
```

<a name="naming-unique-jobs"></a>
#### Nombrando Trabajos de Servidor Único

A veces es posible que necesites programar el mismo trabajo para que se despache con diferentes parámetros, mientras sigues instruyendo a Laravel para que ejecute cada permutación del trabajo en un solo servidor. Para lograr esto, puedes asignar a cada definición de programación un nombre único a través del método `name`:


```php
Schedule::job(new CheckUptime('https://laravel.com'))
            ->name('check_uptime:laravel.com')
            ->everyFiveMinutes()
            ->onOneServer();

Schedule::job(new CheckUptime('https://vapor.laravel.com'))
            ->name('check_uptime:vapor.laravel.com')
            ->everyFiveMinutes()
            ->onOneServer();

```
De manera similar, las funciones anónimas programadas deben asignarse un nombre si se pretende que se ejecuten en un servidor:


```php
Schedule::call(fn () => User::resetApiRequestCount())
    ->name('reset-api-request-count')
    ->daily()
    ->onOneServer();

```

<a name="background-tasks"></a>
### Tareas en segundo plano

Por defecto, varias tareas programadas al mismo tiempo se ejecutarán de manera secuencial en función del orden en que están definidas en tu método `schedule`. Si tienes tareas de larga duración, esto puede hacer que las tareas posteriores comiencen mucho más tarde de lo anticipado. Si deseas ejecutar tareas en segundo plano para que todas puedan ejecutarse simultáneamente, puedes usar el método `runInBackground`:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('analytics:report')
         ->daily()
         ->runInBackground();
```
> [!WARNING]
El método `runInBackground` solo puede utilizarse al programar tareas a través de los métodos `command` y `exec`.

<a name="maintenance-mode"></a>
### Modo de Mantenimiento

Las tareas programadas de su aplicación no se ejecutarán cuando la aplicación esté en [modo de mantenimiento](/docs/%7B%7Bversion%7D%7D/configuration#maintenance-mode), ya que no queremos que sus tareas interfieran con cualquier mantenimiento no terminado que pueda estar realizando en su servidor. Sin embargo, si desea forzar que una tarea se ejecute incluso en modo de mantenimiento, puede llamar al método `evenInMaintenanceMode` al definir la tarea:


```php
Schedule::command('emails:send')->evenInMaintenanceMode();
```

<a name="running-the-scheduler"></a>
## Ejecutando el Programador

Ahora que hemos aprendido cómo definir tareas programadas, hablemos sobre cómo ejecutarlas realmente en nuestro servidor. El comando Artisan `schedule:run` evaluará todas tus tareas programadas y determinará si deben ejecutarse en función de la hora actual del servidor.
Entonces, al usar el programador de Laravel, solo necesitamos agregar una sola entrada de configuración de cron a nuestro servidor que ejecute el comando `schedule:run` cada minuto. Si no sabes cómo agregar entradas de cron a tu servidor, considera usar un servicio como [Laravel Forge](https://forge.laravel.com) que puede gestionar las entradas de cron por ti:


```shell
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1

```

<a name="sub-minute-scheduled-tasks"></a>
### Tareas Programadas de Menos de un Minuto

En la mayoría de los sistemas operativos, los trabajos cron están limitados a ejecutarse un máximo de una vez por minuto. Sin embargo, el programador de Laravel te permite programar tareas para que se ejecuten a intervalos más frecuentes, incluso tan a menudo como una vez por segundo:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::call(function () {
    DB::table('recent_users')->delete();
})->everySecond();
```
Cuando las tareas de menos de un minuto se definen dentro de tu aplicación, el comando `schedule:run` seguirá ejecutándose hasta el final del minuto actual en lugar de salir inmediatamente. Esto permite que el comando invoque todas las tareas de menos de un minuto requeridas a lo largo del minuto.
Dado que las tareas de menos de un minuto que tardan más de lo esperado en ejecutarse pueden retrasar la ejecución de tareas de menos de un minuto posteriores, se recomienda que todas las tareas de menos de un minuto despachen trabajos en cola o comandos en segundo plano para manejar el procesamiento real de tareas:


```php
use App\Jobs\DeleteRecentUsers;

Schedule::job(new DeleteRecentUsers)->everyTenSeconds();

Schedule::command('users:delete')->everyTenSeconds()->runInBackground();
```

<a name="interrupting-sub-minute-tasks"></a>
#### Interrumpiendo Tareas de Menos de un Minuto

Dado que el comando `schedule:run` se ejecuta durante todo el minuto de invocación cuando se definen tareas de menos de un minuto, es posible que a veces necesites interrumpir el comando al desplegar tu aplicación. De lo contrario, una instancia del comando `schedule:run` que ya está en ejecución continuaría utilizando el código previamente desplegado de tu aplicación hasta que finalice el minuto actual.
Para interrumpir las invocaciones en progreso de `schedule:run`, puedes añadir el comando `schedule:interrupt` al script de despliegue de tu aplicación. Este comando debe invocarse después de que tu aplicación haya terminado de desplegarse:


```shell
php artisan schedule:interrupt

```

<a name="running-the-scheduler-locally"></a>
### Ejecutando el Programador Localmente

Normalmente, no añadirías una entrada de cron de programador a tu máquina de desarrollo local. En su lugar, puedes usar el comando Artisan `schedule:work`. Este comando se ejecutará en primer plano e invocará el programador cada minuto hasta que termines el comando:


```shell
php artisan schedule:work

```

<a name="task-output"></a>
## Salida de Tarea

El programador de Laravel proporciona varios métodos convenientes para trabajar con la salida generada por tareas programadas. Primero, utilizando el método `sendOutputTo`, puedes enviar la salida a un archivo para su posterior inspección:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('emails:send')
         ->daily()
         ->sendOutputTo($filePath);
```
Si deseas añadir la salida a un archivo dado, puedes usar el método `appendOutputTo`:


```php
Schedule::command('emails:send')
         ->daily()
         ->appendOutputTo($filePath);
```
Usando el método `emailOutputTo`, puedes enviar por correo electrónico la salida a una dirección de correo electrónico de tu elección. Antes de enviar por correo electrónico la salida de una tarea, debes configurar los [servicios de correo](/docs/%7B%7Bversion%7D%7D/mail) de Laravel:


```php
Schedule::command('report:generate')
         ->daily()
         ->sendOutputTo($filePath)
         ->emailOutputTo('taylor@example.com');
```
Si solo deseas enviar por correo electrónico la salida si el comando Artisan o el comando del sistema programado termina con un código de salida no cero, utiliza el método `emailOutputOnFailure`:


```php
Schedule::command('report:generate')
         ->daily()
         ->emailOutputOnFailure('taylor@example.com');
```
> [!WARNING]
Los métodos `emailOutputTo`, `emailOutputOnFailure`, `sendOutputTo` y `appendOutputTo` son exclusivos de los métodos `command` y `exec`.

<a name="task-hooks"></a>
## Ganchos de Tarea

Usando los métodos `before` y `after`, puedes especificar el código que se ejecutará antes y después de que se ejecute la tarea programada:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('emails:send')
         ->daily()
         ->before(function () {
             // The task is about to execute...
         })
         ->after(function () {
             // The task has executed...
         });
```
Los métodos `onSuccess` y `onFailure` te permiten especificar el código que se ejecutará si la tarea programada tiene éxito o falla. Un fallo indica que el comando Artisan o del sistema programado terminó con un código de salida no cero:


```php
Schedule::command('emails:send')
         ->daily()
         ->onSuccess(function () {
             // The task succeeded...
         })
         ->onFailure(function () {
             // The task failed...
         });
```
Si la salida está disponible a partir de tu comando, puedes acceder a ella en tus ganchos `after`, `onSuccess` o `onFailure` indicando como tipo la instancia de `Illuminate\Support\Stringable` como el argumento `$output` de la definición de la función anónima de tu gancho:


```php
use Illuminate\Support\Stringable;

Schedule::command('emails:send')
         ->daily()
         ->onSuccess(function (Stringable $output) {
             // The task succeeded...
         })
         ->onFailure(function (Stringable $output) {
             // The task failed...
         });
```

<a name="pinging-urls"></a>
#### Pinging URLs

Usando los métodos `pingBefore` y `thenPing`, el programador puede hacer ping automáticamente a una URL dada antes o después de que se ejecute una tarea. Este método es útil para notificar a un servicio externo, como [Envoyer](https://envoyer.io), que tu tarea programada está comenzando o ha terminado su ejecución:


```php
Schedule::command('emails:send')
         ->daily()
         ->pingBefore($url)
         ->thenPing($url);
```
Los métodos `pingBeforeIf` y `thenPingIf` se pueden utilizar para hacer ping a una URL dada solo si una condición dada es `true`:


```php
Schedule::command('emails:send')
         ->daily()
         ->pingBeforeIf($condition, $url)
         ->thenPingIf($condition, $url);
```
Los métodos `pingOnSuccess` y `pingOnFailure` se pueden usar para hacer ping a una URL dada solo si la tarea tiene éxito o falla. Un fallo indica que el comando Artisan o del sistema programado terminó con un código de salida no cero:


```php
Schedule::command('emails:send')
         ->daily()
         ->pingOnSuccess($successUrl)
         ->pingOnFailure($failureUrl);
```

<a name="events"></a>
## Eventos

Laravel despacha una variedad de [eventos](/docs/%7B%7Bversion%7D%7D/events) durante el proceso de programación. Puedes [definir oyentes](/docs/%7B%7Bversion%7D%7D/events) para cualquiera de los siguientes eventos:
<div class="overflow-auto">

| Nombre del Evento |
| --- |
| `Illuminate\Console\Events\ScheduledTaskStarting` |
| `Illuminate\Console\Events\ScheduledTaskFinished` |
| `Illuminate\Console\Events\ScheduledBackgroundTaskFinished` |
| `Illuminate\Console\Events\ScheduledTaskSkipped` |
| `Illuminate\Console\Events\ScheduledTaskFailed` |
</div>