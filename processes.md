# Procesos

- [Introducción](#introduction)
- [Invocando Procesos](#invoking-processes)
  - [Opciones de Proceso](#process-options)
  - [Salida de Proceso](#process-output)
  - [Pipelines](#process-pipelines)
- [Procesos Asincrónicos](#asynchronous-processes)
  - [IDs de Proceso y Señales](#process-ids-and-signals)
  - [Salida de Proceso Asincrónico](#asynchronous-process-output)
- [Procesos Concurrentes](#concurrent-processes)
  - [Nombrando Procesos de Pool](#naming-pool-processes)
  - [IDs de Proceso de Pool y Señales](#pool-process-ids-and-signals)
- [Pruebas](#testing)
  - [Simulando Procesos](#faking-processes)
  - [Simulando Procesos Específicos](#faking-specific-processes)
  - [Simulando Secuencias de Proceso](#faking-process-sequences)
  - [Simulando Ciclos de Vida de Procesos Asincrónicos](#faking-asynchronous-process-lifecycles)
  - [Aserciones Disponibles](#available-assertions)
  - [Previniendo Procesos Errantes](#preventing-stray-processes)

<a name="introduction"></a>
## Introducción

Laravel ofrece una API mínima y expresiva en torno al [componente Process de Symfony](https://symfony.com/doc/7.0/components/process.html), lo que te permite invocar de manera conveniente procesos externos desde tu aplicación Laravel. Las características de proceso de Laravel se centran en los casos de uso más comunes y brindan una experiencia de desarrollador magnífica.

<a name="invoking-processes"></a>
## Invocando Procesos

Para invocar un proceso, puedes usar los métodos `run` y `start` que ofrece la fachada `Process`. El método `run` invocará un proceso y esperará a que el proceso termine de ejecutarse, mientras que el método `start` se utiliza para la ejecución de procesos de forma asincrónica. Examinaremos ambos enfoques en esta documentación. Primero, examinemos cómo invocar un proceso básico y sincrónico e inspeccionar su resultado:


```php
use Illuminate\Support\Facades\Process;

$result = Process::run('ls -la');

return $result->output();

```
Por supuesto, la instancia `Illuminate\Contracts\Process\ProcessResult` devuelta por el método `run` ofrece una variedad de métodos útiles que se pueden usar para inspeccionar el resultado del proceso:


```php
$result = Process::run('ls -la');

$result->successful();
$result->failed();
$result->exitCode();
$result->output();
$result->errorOutput();

```

<a name="throwing-exceptions"></a>
#### Lanzando Excepciones

Si tienes un resultado de proceso y te gustaría lanzar una instancia de `Illuminate\Process\Exceptions\ProcessFailedException` si el código de salida es mayor que cero (lo que indica un fallo), puedes usar los métodos `throw` y `throwIf`. Si el proceso no falló, se devolverá la instancia del resultado del proceso:


```php
$result = Process::run('ls -la')->throw();

$result = Process::run('ls -la')->throwIf($condition);

```

<a name="process-options"></a>
### Opciones de Proceso

Por supuesto, es posible que necesites personalizar el comportamiento de un proceso antes de invocarlo. Afortunadamente, Laravel te permite ajustar una variedad de características del proceso, como el directorio de trabajo, el tiempo de espera y las variables de entorno.

<a name="working-directory-path"></a>
#### Ruta del Directorio de Trabajo

Puedes usar el método `path` para especificar el directorio de trabajo del proceso. Si este método no se invoca, el proceso heredará el directorio de trabajo del script PHP que se está ejecutando actualmente:


```php
$result = Process::path(__DIR__)->run('ls -la');

```

<a name="input"></a>
#### Entrada

Puedes proporcionar la entrada a través de la "entrada estándar" del proceso utilizando el método `input`:


```php
$result = Process::input('Hello World')->run('cat');

```

<a name="timeouts"></a>
#### Timeouts

Por defecto, los procesos lanzarán una instancia de `Illuminate\Process\Exceptions\ProcessTimedOutException` después de ejecutar durante más de 60 segundos. Sin embargo, puedes personalizar este comportamiento a través del método `timeout`:


```php
$result = Process::timeout(120)->run('bash import.sh');

```
O, si deseas desactivar el tiempo de espera del proceso por completo, puedes invocar el método `forever`:


```php
$result = Process::forever()->run('bash import.sh');

```
El método `idleTimeout` se puede utilizar para especificar el número máximo de segundos que el proceso puede ejecutarse sin devolver ninguna salida:


```php
$result = Process::timeout(60)->idleTimeout(30)->run('bash import.sh');

```

<a name="environment-variables"></a>
#### Variables de Entorno

Las variables de entorno pueden ser proporcionadas al proceso a través del método `env`. El proceso invocado también heredará todas las variables de entorno definidas por su sistema:


```php
$result = Process::forever()
            ->env(['IMPORT_PATH' => __DIR__])
            ->run('bash import.sh');

```
Si deseas eliminar una variable de entorno heredada del proceso invocado, puedes proporcionar esa variable de entorno con un valor de `false`:


```php
$result = Process::forever()
            ->env(['LOAD_PATH' => false])
            ->run('bash import.sh');

```

<a name="tty-mode"></a>
#### Modo TTY

El método `tty` se puede utilizar para habilitar el modo TTY para tu proceso. El modo TTY conecta la entrada y salida del proceso con la entrada y salida de tu programa, lo que permite que tu proceso abra un editor como Vim o Nano como un proceso:


```php
Process::forever()->tty()->run('vim');

```

<a name="process-output"></a>
### Salida del Proceso

Como se discutió anteriormente, la salida del proceso puede ser accedida utilizando los métodos `output` (stdout) y `errorOutput` (stderr) en un resultado de proceso:


```php
use Illuminate\Support\Facades\Process;

$result = Process::run('ls -la');

echo $result->output();
echo $result->errorOutput();

```
Sin embargo, la salida también puede ser recopilada en tiempo real pasando una `función anónima` como segundo argumento al método `run`. La `función anónima` recibirá dos argumentos: el "tipo" de salida (`stdout` o `stderr`) y la cadena de salida en sí:


```php
$result = Process::run('ls -la', function (string $type, string $output) {
    echo $output;
});

```
Laravel también ofrece los métodos `seeInOutput` y `seeInErrorOutput`, que proporcionan una forma conveniente de determinar si una cadena dada estaba contenida en la salida del proceso:


```php
if (Process::run('ls -la')->seeInOutput('laravel')) {
    // ...
}

```

<a name="disabling-process-output"></a>
#### Desactivando la Salida del Proceso

Si tu proceso está generando una cantidad significativa de salida que no te interesa, puedes conservar memoria deshabilitando la recuperación de salida por completo. Para lograr esto, invoca el método `quietly` mientras construyes el proceso:


```php
use Illuminate\Support\Facades\Process;

$result = Process::quietly()->run('bash import.sh');

```

<a name="process-pipelines"></a>
### Pipelines

A veces es posible que desees que la salida de un proceso sea la entrada de otro proceso. Esto a menudo se refiere a "encadenar" la salida de un proceso en otro. El método `pipe` proporcionado por las fachadas `Process` facilita este logro. El método `pipe` ejecutará los procesos encadenados de forma sincrónica y devolverá el resultado del proceso para el último proceso en la secuencia:


```php
use Illuminate\Process\Pipe;
use Illuminate\Support\Facades\Process;

$result = Process::pipe(function (Pipe $pipe) {
    $pipe->command('cat example.txt');
    $pipe->command('grep -i "laravel"');
});

if ($result->successful()) {
    // ...
}

```
Si no necesitas personalizar los procesos individuales que componen la tubería, simplemente puedes pasar un array de cadenas de comandos al método `pipe`:


```php
$result = Process::pipe([
    'cat example.txt',
    'grep -i "laravel"',
]);

```
La salida del proceso puede ser recopilada en tiempo real pasando una `función anónima` como segundo argumento al método `pipe`. La `función anónima` recibirá dos argumentos: el "tipo" de salida (`stdout` o `stderr`) y la cadena de salida en sí:


```php
$result = Process::pipe(function (Pipe $pipe) {
    $pipe->command('cat example.txt');
    $pipe->command('grep -i "laravel"');
}, function (string $type, string $output) {
    echo $output;
});

```
Laravel también te permite asignar claves de cadena a cada proceso dentro de un pipeline a través del método `as`. Esta clave también se pasará a la `función anónima` de salida proporcionada al método `pipe`, lo que te permitirá determinar a qué proceso pertenece la salida:


```php
$result = Process::pipe(function (Pipe $pipe) {
    $pipe->as('first')->command('cat example.txt');
    $pipe->as('second')->command('grep -i "laravel"');
})->start(function (string $type, string $output, string $key) {
    // ...
});

```

<a name="asynchronous-processes"></a>
## Procesos Asíncronos

Mientras que el método `run` invoca procesos de forma sincrónica, el método `start` se puede utilizar para invocar un proceso de manera asincrónica. Esto permite que su aplicación continúe realizando otras tareas mientras el proceso se ejecuta en segundo plano. Una vez que se haya invocado el proceso, puede utilizar el método `running` para determinar si el proceso sigue en ejecución:


```php
$process = Process::timeout(120)->start('bash import.sh');

while ($process->running()) {
    // ...
}

$result = $process->wait();

```
Como habrás notado, puedes invocar el método `wait` para esperar hasta que el proceso haya terminado de ejecutarse y recuperar la instancia del resultado del proceso:


```php
$process = Process::timeout(120)->start('bash import.sh');

// ...

$result = $process->wait();

```

<a name="process-ids-and-signals"></a>
### IDs de proceso y señales

El método `id` se puede usar para recuperar el ID de proceso asignado por el sistema operativo al proceso en ejecución:


```php
$process = Process::start('bash import.sh');

return $process->id();

```
Puedes usar el método `signal` para enviar una "señal" al proceso en ejecución. Una lista de constantes de señal predefinidas se puede encontrar dentro de la [documentación de PHP](https://www.php.net/manual/en/pcntl.constants.php):


```php
$process->signal(SIGUSR2);

```

<a name="asynchronous-process-output"></a>
### Salida de Proceso Asincrónico

Mientras se está ejecutando un proceso asíncrono, puedes acceder a toda su salida actual utilizando los métodos `output` y `errorOutput`; sin embargo, puedes utilizar `latestOutput` y `latestErrorOutput` para acceder a la salida del proceso que ha ocurrido desde la última vez que se recuperó la salida:


```php
$process = Process::timeout(120)->start('bash import.sh');

while ($process->running()) {
    echo $process->latestOutput();
    echo $process->latestErrorOutput();

    sleep(1);
}

```
Al igual que el método `run`, la salida también puede recopilarse en tiempo real a partir de procesos asincrónicos pasando una función anónima como segundo argumento al método `start`. La función anónima recibirá dos argumentos: el "tipo" de salida (`stdout` o `stderr`) y la cadena de salida en sí:


```php
$process = Process::start('bash import.sh', function (string $type, string $output) {
    echo $output;
});

$result = $process->wait();

```

<a name="concurrent-processes"></a>
## Procesos Concurrentes

Laravel también facilita la gestión de un grupo de procesos asíncronos y concurrentes, lo que te permite ejecutar muchas tareas de forma simultánea. Para empezar, invoca el método `pool`, que acepta una función anónima que recibe una instancia de `Illuminate\Process\Pool`.
Dentro de esta `función anónima`, puedes definir los procesos que pertenecen al grupo. Una vez que se inicia un grupo de procesos a través del método `start`, puedes acceder a la [colección](/docs/%7B%7Bversion%7D%7D/collections) de procesos en ejecución a través del método `running`:


```php
use Illuminate\Process\Pool;
use Illuminate\Support\Facades\Process;

$pool = Process::pool(function (Pool $pool) {
    $pool->path(__DIR__)->command('bash import-1.sh');
    $pool->path(__DIR__)->command('bash import-2.sh');
    $pool->path(__DIR__)->command('bash import-3.sh');
})->start(function (string $type, string $output, int $key) {
    // ...
});

while ($pool->running()->isNotEmpty()) {
    // ...
}

$results = $pool->wait();

```
Como puedes ver, puedes esperar a que todos los procesos del pool terminen de ejecutarse y resuelvan sus resultados a través del método `wait`. El método `wait` devuelve un objeto accesible como un array que te permite acceder a la instancia del resultado del proceso de cada proceso en el pool por su clave:


```php
$results = $pool->wait();

echo $results[0]->output();

```
O, para mayor comodidad, se puede utilizar el método `concurrently` para iniciar un pool de procesos asíncronos y esperar inmediatamente sus resultados. Esto puede proporcionar una sintaxis particularmente expresiva cuando se combina con las capacidades de desestructuración de arrays de PHP:


```php
[$first, $second, $third] = Process::concurrently(function (Pool $pool) {
    $pool->path(__DIR__)->command('ls -la');
    $pool->path(app_path())->command('ls -la');
    $pool->path(storage_path())->command('ls -la');
});

echo $first->output();

```

<a name="naming-pool-processes"></a>
### Nombrar Procesos del Pool

Acceder a los resultados del pool de procesos a través de una clave numérica no es muy expresivo; por lo tanto, Laravel te permite asignar claves de cadena a cada proceso dentro de un pool a través del método `as`. Esta clave también se pasará a la función anónima proporcionada al método `start`, lo que te permitirá determinar a qué proceso pertenece la salida:


```php
$pool = Process::pool(function (Pool $pool) {
    $pool->as('first')->command('bash import-1.sh');
    $pool->as('second')->command('bash import-2.sh');
    $pool->as('third')->command('bash import-3.sh');
})->start(function (string $type, string $output, string $key) {
    // ...
});

$results = $pool->wait();

return $results['first']->output();

```

<a name="pool-process-ids-and-signals"></a>
### Identificadores de Proceso de Pool y Señales

Dado que el método `running` del pool de procesos proporciona una colección de todos los procesos invocados dentro del pool, puedes acceder fácilmente a los IDs de proceso subyacentes del pool:


```php
$processIds = $pool->running()->each->id();

```
Y, para mayor comodidad, puedes invocar el método `signal` en un pool de procesos para enviar una señal a cada proceso dentro del pool:


```php
$pool->signal(SIGUSR2);

```

<a name="testing"></a>
## Pruebas

Muchos servicios de Laravel ofrecen funcionalidades para ayudarte a escribir pruebas de manera fácil y expresiva, y el servicio de procesos de Laravel no es una excepción. El método `fake` de la fachada `Process` te permite instruir a Laravel para que devuelva resultados simulados / dummy cuando se invocan procesos.

<a name="faking-processes"></a>
### Simulación de Procesos

Para explorar la capacidad de Laravel para simular procesos, imaginemos una ruta que invoca un proceso:


```php
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\Route;

Route::get('/import', function () {
    Process::run('bash import.sh');

    return 'Import complete!';
});

```
Al probar esta ruta, podemos instruir a Laravel para que devuelva un resultado de proceso exitoso simulado para cada proceso invocado llamando al método `fake` en la fachada `Process` sin argumentos. Además, incluso podemos [afirmar](#available-assertions) que un proceso dado fue "ejecutado":


```php
<?php

use Illuminate\Process\PendingProcess;
use Illuminate\Contracts\Process\ProcessResult;
use Illuminate\Support\Facades\Process;

test('process is invoked', function () {
    Process::fake();

    $response = $this->get('/import');

    // Simple process assertion...
    Process::assertRan('bash import.sh');

    // Or, inspecting the process configuration...
    Process::assertRan(function (PendingProcess $process, ProcessResult $result) {
        return $process->command === 'bash import.sh' &&
               $process->timeout === 60;
    });
});

```


```php
<?php

namespace Tests\Feature;

use Illuminate\Process\PendingProcess;
use Illuminate\Contracts\Process\ProcessResult;
use Illuminate\Support\Facades\Process;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_process_is_invoked(): void
    {
        Process::fake();

        $response = $this->get('/import');

        // Simple process assertion...
        Process::assertRan('bash import.sh');

        // Or, inspecting the process configuration...
        Process::assertRan(function (PendingProcess $process, ProcessResult $result) {
            return $process->command === 'bash import.sh' &&
                   $process->timeout === 60;
        });
    }
}

```
Como se discutió, invocar el método `fake` en la fachada `Process` instruirá a Laravel a devolver siempre un resultado de proceso exitoso sin salida. Sin embargo, puedes especificar fácilmente la salida y el código de salida para los procesos simulados utilizando el método `result` de la fachada `Process`:


```php
Process::fake([
    '*' => Process::result(
        output: 'Test output',
        errorOutput: 'Test error output',
        exitCode: 1,
    ),
]);

```

<a name="faking-specific-processes"></a>
### Fingiendo Procesos Específicos

Como habrás notado en un ejemplo anterior, la facade `Process` te permite especificar diferentes resultados simulados por proceso pasando un array al método `fake`.
Las claves del array deben representar patrones de comando que deseas simular y sus resultados asociados. Se puede usar el carácter `*` como un carácter comodín. Cualquier comando de proceso que no haya sido simulado será invocado realmente. Puedes usar el método `result` de la fachada `Process` para construir resultados simulados / falsos para estos comandos:


```php
Process::fake([
    'cat *' => Process::result(
        output: 'Test "cat" output',
    ),
    'ls *' => Process::result(
        output: 'Test "ls" output',
    ),
]);

```
Si no necesitas personalizar el código de salida o la salida de error de un proceso simulado, puede que te resulte más conveniente especificar los resultados del proceso simulado como cadenas simples:


```php
Process::fake([
    'cat *' => 'Test "cat" output',
    'ls *' => 'Test "ls" output',
]);

```

<a name="faking-process-sequences"></a>
### Falsificando Secuencias de Proceso

Si el código que estás probando invoca múltiples procesos con el mismo comando, es posible que desees asignar un resultado de proceso simulado diferente a cada invocación del proceso. Puedes lograr esto a través del método `sequence` de la fachada `Process`:


```php
Process::fake([
    'ls *' => Process::sequence()
                ->push(Process::result('First invocation'))
                ->push(Process::result('Second invocation')),
]);

```

<a name="faking-asynchronous-process-lifecycles"></a>
### Simulando Ciclos de Vida de Procesos Asincrónicos

Hasta ahora, hemos discutido principalmente los procesos simulados que se invocan de forma sincrónica utilizando el método `run`. Sin embargo, si estás intentando probar código que interactúa con procesos asincrónicos invocados a través de `start`, es posible que necesites un enfoque más sofisticado para describir tus procesos simulados.
Por ejemplo, imaginemos la siguiente ruta que interactúa con un proceso asíncrono:


```php
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;

Route::get('/import', function () {
    $process = Process::start('bash import.sh');

    while ($process->running()) {
        Log::info($process->latestOutput());
        Log::info($process->latestErrorOutput());
    }

    return 'Done';
});

```
Para simular este proceso correctamente, necesitamos poder describir cuántas veces debería devolver `true` el método `running`. Además, es posible que queramos especificar múltiples líneas de salida que se deben devolver en secuencia. Para lograr esto, podemos usar el método `describe` de la fachada `Process`:


```php
Process::fake([
    'bash import.sh' => Process::describe()
            ->output('First line of standard output')
            ->errorOutput('First line of error output')
            ->output('Second line of standard output')
            ->exitCode(0)
            ->iterations(3),
]);

```
Vamos a profundizar en el ejemplo anterior. Usando los métodos `output` y `errorOutput`, podemos especificar múltiples líneas de salida que se devolverán en secuencia. El método `exitCode` puede usarse para especificar el código de salida final del proceso simulado. Finalmente, el método `iterations` puede usarse para especificar cuántas veces el método `running` debería devolver `true`.

<a name="available-assertions"></a>
### Afirmaciones Disponibles

Como [se discutió anteriormente](#faking-processes), Laravel ofrece varias afirmaciones de proceso para tus pruebas de características. Discutiremos cada una de estas afirmaciones a continuación.

<a name="assert-process-ran"></a>
#### assertRan

Afirma que un proceso dado fue invocado:


```php
use Illuminate\Support\Facades\Process;

Process::assertRan('ls -la');

```
El método `assertRan` también acepta una función anónima, que recibirá una instancia de un proceso y un resultado del proceso, lo que te permitirá inspeccionar las opciones configuradas del proceso. Si esta función anónima devuelve `true`, la afirmación "pasará":


```php
Process::assertRan(fn ($process, $result) =>
    $process->command === 'ls -la' &&
    $process->path === __DIR__ &&
    $process->timeout === 60
);

```
El `$process` pasado a la `función anónima` `assertRan` es una instancia de `Illuminate\Process\PendingProcess`, mientras que el `$result` es una instancia de `Illuminate\Contracts\Process\ProcessResult`.

<a name="assert-process-didnt-run"></a>
#### assertDidntRun

Afirmar que un proceso dado no fue invocado:


```php
use Illuminate\Support\Facades\Process;

Process::assertDidntRun('ls -la');

```
Al igual que el método `assertRan`, el método `assertDidntRun` también acepta una función anónima, que recibirá una instancia de un proceso y un resultado del proceso, lo que te permitirá inspeccionar las opciones configuradas del proceso. Si esta función anónima devuelve `true`, la afirmación "fallará":


```php
Process::assertDidntRun(fn (PendingProcess $process, ProcessResult $result) =>
    $process->command === 'ls -la'
);

```

<a name="assert-process-ran-times"></a>
#### assertRanTimes

Asegúrate de que un proceso dado fue invocado un número dado de veces:


```php
use Illuminate\Support\Facades\Process;

Process::assertRanTimes('ls -la', times: 3);

```
El método `assertRanTimes` también acepta una función anónima, que recibirá una instancia de un proceso y un resultado del proceso, lo que te permitirá inspeccionar las opciones configuradas del proceso. Si esta función anónima devuelve `true` y el proceso fue invocado el número especificado de veces, la aserción "pasará":


```php
Process::assertRanTimes(function (PendingProcess $process, ProcessResult $result) {
    return $process->command === 'ls -la';
}, times: 3);

```

<a name="preventing-stray-processes"></a>
### Previniendo Procesos Errantes

Si deseas asegurarte de que todos los procesos invocados hayan sido simulados a lo largo de tu prueba individual o de tu suite de pruebas completa, puedes llamar al método `preventStrayProcesses`. Después de llamar a este método, cualquier proceso que no tenga un resultado simulado correspondiente lanzará una excepción en lugar de iniciar un proceso real:


```php
use Illuminate\Support\Facades\Process;

Process::preventStrayProcesses();

Process::fake([
    'ls *' => 'Test output...',
]);

// Fake response is returned...
Process::run('ls -la');

// An exception is thrown...
Process::run('bash import.sh');
```