# Laravel Envoy

- [Introducción](#introduction)
- [Instalación](#installation)
- [Escribiendo Tareas](#writing-tasks)
    - [Definiendo Tareas](#defining-tasks)
    - [Múltiples Servidores](#multiple-servers)
    - [Configuración](#setup)
    - [Variables](#variables)
    - [Historias](#stories)
    - [Hooks](#completion-hooks)
- [Ejecutando Tareas](#running-tasks)
    - [Confirmando la Ejecución de Tareas](#confirming-task-execution)
- [Notificaciones](#notifications)
    - [Slack](#slack)
    - [Discord](#discord)
    - [Telegram](#telegram)
    - [Microsoft Teams](#microsoft-teams)

<a name="introduction"></a>
## Introducción

[Laravel Envoy](https://github.com/laravel/envoy) es una herramienta para ejecutar tareas comunes que realizas en tus servidores remotos. Usando la sintaxis estilo [Blade](/docs/{{version}}/blade), puedes configurar fácilmente tareas para despliegue, comandos de Artisan y más. Actualmente, Envoy solo es compatible con los sistemas operativos Mac y Linux. Sin embargo, el soporte para Windows es posible utilizando [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

<a name="installation"></a>
## Instalación

Primero, instala Envoy en tu proyecto utilizando el gestor de paquetes Composer:

```shell
composer require laravel/envoy --dev
```

Una vez que Envoy ha sido instalado, el binario de Envoy estará disponible en el directorio `vendor/bin` de tu aplicación:

```shell
php vendor/bin/envoy
```

<a name="writing-tasks"></a>
## Escribiendo Tareas

<a name="defining-tasks"></a>
### Definiendo Tareas

Las tareas son el bloque de construcción básico de Envoy. Las tareas definen los comandos de shell que deben ejecutarse en tus servidores remotos cuando se invoca la tarea. Por ejemplo, podrías definir una tarea que ejecute el comando `php artisan queue:restart` en todos los servidores de trabajadores de cola de tu aplicación.

Todas tus tareas de Envoy deben definirse en un archivo `Envoy.blade.php` en la raíz de tu aplicación. Aquí tienes un ejemplo para comenzar:

```blade
@servers(['web' => ['user@192.168.1.1'], 'workers' => ['user@192.168.1.2']])

@task('restart-queues', ['on' => 'workers'])
    cd /home/user/example.com
    php artisan queue:restart
@endtask
```

Como puedes ver, se define un array de `@servers` en la parte superior del archivo, lo que te permite hacer referencia a estos servidores a través de la opción `on` de tus declaraciones de tarea. La declaración `@servers` siempre debe colocarse en una sola línea. Dentro de tus declaraciones `@task`, debes colocar los comandos de shell que deben ejecutarse en tus servidores cuando se invoca la tarea.

<a name="local-tasks"></a>
#### Tareas Locales

Puedes forzar a un script a ejecutarse en tu computadora local especificando la dirección IP del servidor como `127.0.0.1`:

```blade
@servers(['localhost' => '127.0.0.1'])
```

<a name="importing-envoy-tasks"></a>
#### Importando Tareas de Envoy

Usando la directiva `@import`, puedes importar otros archivos de Envoy para que sus historias y tareas se añadan a las tuyas. Después de que los archivos han sido importados, puedes ejecutar las tareas que contienen como si estuvieran definidas en tu propio archivo de Envoy:

```blade
@import('vendor/package/Envoy.blade.php')
```

<a name="multiple-servers"></a>
### Múltiples Servidores

Envoy te permite ejecutar fácilmente una tarea en múltiples servidores. Primero, añade servidores adicionales a tu declaración `@servers`. Cada servidor debe tener un nombre único. Una vez que hayas definido tus servidores adicionales, puedes listar cada uno de los servidores en el array `on` de la tarea:

```blade
@servers(['web-1' => '192.168.1.1', 'web-2' => '192.168.1.2'])

@task('deploy', ['on' => ['web-1', 'web-2']])
    cd /home/user/example.com
    git pull origin {{ $branch }}
    php artisan migrate --force
@endtask
```

<a name="parallel-execution"></a>
#### Ejecución Paralela

Por defecto, las tareas se ejecutarán en cada servidor de forma serial. En otras palabras, una tarea terminará de ejecutarse en el primer servidor antes de proceder a ejecutarse en el segundo servidor. Si deseas ejecutar una tarea en múltiples servidores en paralelo, añade la opción `parallel` a tu declaración de tarea:

```blade
@servers(['web-1' => '192.168.1.1', 'web-2' => '192.168.1.2'])

@task('deploy', ['on' => ['web-1', 'web-2'], 'parallel' => true])
    cd /home/user/example.com
    git pull origin {{ $branch }}
    php artisan migrate --force
@endtask
```

<a name="setup"></a>
### Configuración

A veces, puede que necesites ejecutar código PHP arbitrario antes de ejecutar tus tareas de Envoy. Puedes usar la directiva `@setup` para definir un bloque de código PHP que debe ejecutarse antes de tus tareas:

```php
@setup
    $now = new DateTime;
@endsetup
```

Si necesitas requerir otros archivos PHP antes de que se ejecute tu tarea, puedes usar la directiva `@include` en la parte superior de tu archivo `Envoy.blade.php`:

```blade
@include('vendor/autoload.php')

@task('restart-queues')
    # ...
@endtask
```

<a name="variables"></a>
### Variables

Si es necesario, puedes pasar argumentos a las tareas de Envoy especificándolos en la línea de comandos al invocar Envoy:

```shell
php vendor/bin/envoy run deploy --branch=master
```

Puedes acceder a las opciones dentro de tus tareas usando la sintaxis de "eco" de Blade. También puedes definir declaraciones `if` y bucles de Blade dentro de tus tareas. Por ejemplo, verifiquemos la presencia de la variable `$branch` antes de ejecutar el comando `git pull`:

```blade
@servers(['web' => ['user@192.168.1.1']])

@task('deploy', ['on' => 'web'])
    cd /home/user/example.com

    @if ($branch)
        git pull origin {{ $branch }}
    @endif

    php artisan migrate --force
@endtask
```

<a name="stories"></a>
### Historias

Las historias agrupan un conjunto de tareas bajo un solo nombre conveniente. Por ejemplo, una historia `deploy` puede ejecutar las tareas `update-code` e `install-dependencies` enumerando los nombres de las tareas dentro de su definición:

```blade
@servers(['web' => ['user@192.168.1.1']])

@story('deploy')
    update-code
    install-dependencies
@endstory

@task('update-code')
    cd /home/user/example.com
    git pull origin master
@endtask

@task('install-dependencies')
    cd /home/user/example.com
    composer install
@endtask
```

Una vez que la historia ha sido escrita, puedes invocarla de la misma manera que invocarías una tarea:

```shell
php vendor/bin/envoy run deploy
```

<a name="completion-hooks"></a>
### Hooks

Cuando se ejecutan tareas e historias, se ejecutan varios hooks. Los tipos de hooks soportados por Envoy son `@before`, `@after`, `@error`, `@success` y `@finished`. Todo el código en estos hooks se interpreta como PHP y se ejecuta localmente, no en los servidores remotos con los que interactúan tus tareas.

Puedes definir tantos de cada uno de estos hooks como desees. Se ejecutarán en el orden en que aparecen en tu script de Envoy.

<a name="hook-before"></a>
#### `@before`

Antes de cada ejecución de tarea, se ejecutarán todos los hooks `@before` registrados en tu script de Envoy. Los hooks `@before` reciben el nombre de la tarea que se ejecutará:

```blade
@before
    if ($task === 'deploy') {
        // ...
    }
@endbefore
```

<a name="completion-after"></a>
#### `@after`

Después de cada ejecución de tarea, se ejecutarán todos los hooks `@after` registrados en tu script de Envoy. Los hooks `@after` reciben el nombre de la tarea que se ejecutó:

```blade
@after
    if ($task === 'deploy') {
        // ...
    }
@endafter
```

<a name="completion-error"></a>
#### `@error`

Después de cada fallo de tarea (sale con un código de estado mayor que `0`), se ejecutarán todos los hooks `@error` registrados en tu script de Envoy. Los hooks `@error` reciben el nombre de la tarea que se ejecutó:

```blade
@error
    if ($task === 'deploy') {
        // ...
    }
@enderror
```

<a name="completion-success"></a>
#### `@success`

Si todas las tareas se han ejecutado sin errores, se ejecutarán todos los hooks `@success` registrados en tu script de Envoy:

```blade
@success
    // ...
@endsuccess
```

<a name="completion-finished"></a>
#### `@finished`

Después de que todas las tareas se hayan ejecutado (independientemente del estado de salida), se ejecutarán todos los hooks `@finished`. Los hooks `@finished` reciben el código de estado de la tarea completada, que puede ser `null` o un `integer` mayor o igual a `0`:

```blade
@finished
    if ($exitCode > 0) {
        // There were errors in one of the tasks...
    }
@endfinished
```

<a name="running-tasks"></a>
## Ejecutando Tareas

Para ejecutar una tarea o historia que está definida en el archivo `Envoy.blade.php` de tu aplicación, ejecuta el comando `run` de Envoy, pasando el nombre de la tarea o historia que te gustaría ejecutar. Envoy ejecutará la tarea y mostrará la salida de tus servidores remotos mientras la tarea se está ejecutando:

```shell
php vendor/bin/envoy run deploy
```

<a name="confirming-task-execution"></a>
### Confirmando la Ejecución de Tareas

Si deseas que se te pida confirmación antes de ejecutar una tarea determinada en tus servidores, debes añadir la directiva `confirm` a tu declaración de tarea. Esta opción es particularmente útil para operaciones destructivas:

```blade
@task('deploy', ['on' => 'web', 'confirm' => true])
    cd /home/user/example.com
    git pull origin {{ $branch }}
    php artisan migrate
@endtask
```

<a name="notifications"></a>
## Notificaciones

<a name="slack"></a>
### Slack

Envoy soporta el envío de notificaciones a [Slack](https://slack.com) después de que cada tarea se ejecute. La directiva `@slack` acepta una URL de webhook de Slack y un nombre de canal / usuario. Puedes recuperar tu URL de webhook creando una integración de "Incoming WebHooks" en tu panel de control de Slack.

Debes pasar la URL completa del webhook como el primer argumento dado a la directiva `@slack`. El segundo argumento dado a la directiva `@slack` debe ser un nombre de canal (`#channel`) o un nombre de usuario (`@user`):

```blade
@finished
    @slack('webhook-url', '#bots')
@endfinished
```

Por defecto, las notificaciones de Envoy enviarán un mensaje al canal de notificación describiendo la tarea que se ejecutó. Sin embargo, puedes sobrescribir este mensaje con tu propio mensaje personalizado pasando un tercer argumento a la directiva `@slack`:

```blade
@finished
    @slack('webhook-url', '#bots', 'Hola, Slack.')
@endfinished
```

<a name="discord"></a>
### Discord

Envoy también soporta el envío de notificaciones a [Discord](https://discord.com) después de que cada tarea se ejecute. La directiva `@discord` acepta una URL de webhook de Discord y un mensaje. Puedes recuperar tu URL de webhook creando un "Webhook" en la Configuración de tu Servidor y eligiendo a qué canal debe publicar el webhook. Debes pasar la URL completa del Webhook a la directiva `@discord`:

```blade
@finished
    @discord('discord-webhook-url')
@endfinished
```

<a name="telegram"></a>
### Telegram

Envoy también soporta el envío de notificaciones a [Telegram](https://telegram.org) después de que cada tarea se ejecute. La directiva `@telegram` acepta un ID de Bot de Telegram y un ID de Chat. Puedes recuperar tu ID de Bot creando un nuevo bot usando [BotFather](https://t.me/botfather). Puedes recuperar un ID de Chat válido usando [@username_to_id_bot](https://t.me/username_to_id_bot). Debes pasar el ID de Bot y el ID de Chat completos a la directiva `@telegram`:

```blade
@finished
    @telegram('bot-id','chat-id')
@endfinished
```

<a name="microsoft-teams"></a>
### Microsoft Teams

Envoy también soporta el envío de notificaciones a [Microsoft Teams](https://www.microsoft.com/en-us/microsoft-teams) después de que cada tarea se ejecute. La directiva `@microsoftTeams` acepta un Webhook de Teams (requerido), un mensaje, color de tema (éxito, información, advertencia, error) y un array de opciones. Puedes recuperar tu Webhook de Teams creando un nuevo [incoming webhook](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook). La API de Teams tiene muchos otros atributos para personalizar tu cuadro de mensaje como título, resumen y secciones. Puedes encontrar más información en la [documentación de Microsoft Teams](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/connectors-using?tabs=cURL#example-of-connector-message). Debes pasar la URL completa del Webhook a la directiva `@microsoftTeams`:

```blade
@finished
    @microsoftTeams('webhook-url')
@endfinished
```
