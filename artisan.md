# Consola Artisan

- [Introducción](#introduction)
  - [Tinker (REPL)](#tinker)
- [Escribiendo Comandos](#writing-commands)
  - [Generando Comandos](#generating-commands)
  - [Estructura de Comando](#command-structure)
  - [Comandos de Función Anónima](#closure-commands)
  - [Comandos Aislables](#isolatable-commands)
- [Definiendo Expectativas de Entrada](#defining-input-expectations)
  - [Argumentos](#arguments)
  - [Opciones](#options)
  - [Arreglos de Entrada](#input-arrays)
  - [Descripciones de Entrada](#input-descriptions)
  - [Solicitando Entrada Faltante](#prompting-for-missing-input)
- [Entrada/Salida de Comando](#command-io)
  - [Recuperando Entrada](#retrieving-input)
  - [Solicitando Entrada](#prompting-for-input)
  - [Escribiendo Salida](#writing-output)
- [Registrando Comandos](#registering-commands)
- [Ejecutando Comandos de Forma Programática](#programmatically-executing-commands)
  - [Llamando Comandos Desde Otros Comandos](#calling-commands-from-other-commands)
- [Manejo de Señales](#signal-handling)
- [Personalización de Plantillas](#stub-customization)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

Artisan es la interfaz de línea de comandos incluida con Laravel. Artisan existe en la raíz de tu aplicación como el script `artisan` y proporciona una serie de comandos útiles que pueden asistirte mientras construyes tu aplicación. Para ver una lista de todos los comandos de Artisan disponibles, puedes usar el comando `list`:


```shell
php artisan list

```
Cada comando también incluye una pantalla de "ayuda" que muestra y describe los argumentos y opciones disponibles del comando. Para ver una pantalla de ayuda, precede el nombre del comando con `help`:


```shell
php artisan help migrate

```

<a name="laravel-sail"></a>
#### Laravel Sail

Si estás utilizando [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail) como tu entorno de desarrollo local, recuerda usar la línea de comandos `sail` para invocar comandos de Artisan. Sail ejecutará tus comandos de Artisan dentro de los contenedores Docker de tu aplicación:


```shell
./vendor/bin/sail artisan list

```

<a name="tinker"></a>
### Tinker (REPL)

Laravel Tinker es un poderoso REPL para el framework Laravel, impulsado por el paquete [PsySH](https://github.com/bobthecow/psysh).

<a name="installation"></a>
#### Instalación

Todas las aplicaciones de Laravel incluyen Tinker por defecto. Sin embargo, puedes instalar Tinker usando Composer si lo has eliminado previamente de tu aplicación:


```shell
composer require laravel/tinker

```
> [!NOTA]
¿Buscas recarga en caliente, edición de código multilinea y autocompletado al interactuar con tu aplicación Laravel? ¡Consulta [Tinkerwell](https://tinkerwell.app)!

<a name="usage"></a>
#### Uso

Tinker te permite interactuar con toda tu aplicación Laravel en la línea de comandos, incluyendo tus modelos Eloquent, trabajos, eventos y más. Para ingresar al entorno de Tinker, ejecuta el comando Artisan `tinker`:


```shell
php artisan tinker

```
Puedes publicar el archivo de configuración de Tinker utilizando el comando `vendor:publish`:


```shell
php artisan vendor:publish --provider="Laravel\Tinker\TinkerServiceProvider"

```
> [!WARNING]
La función helper `dispatch` y el método `dispatch` en la clase `Dispatchable` dependen de la recolección de basura para colocar el trabajo en la cola. Por lo tanto, al usar tinker, debes usar `Bus::dispatch` o `Queue::push` para despachar trabajos.

<a name="command-allow-list"></a>
#### Lista de Permisos de Comando

Tinker utiliza una lista de "permiso" para determinar qué comandos Artisan se pueden ejecutar dentro de su shell. Por defecto, puedes ejecutar los comandos `clear-compiled`, `down`, `env`, `inspire`, `migrate`, `migrate:install`, `up` y `optimize`. Si deseas permitir más comandos, puedes añadirlos al array `commands` en tu archivo de configuración `tinker.php`:


```php
'commands' => [
    // App\Console\Commands\ExampleCommand::class,
],
```

<a name="classes-that-should-not-be-aliased"></a>
#### Clases que no deben ser aliased

Normalmente, Tinker automáticamente crea alias para las clases a medida que interactúas con ellas en Tinker. Sin embargo, es posible que desees no alias algunas clases. Puedes lograr esto enumerando las clases en el array `dont_alias` de tu archivo de configuración `tinker.php`:


```php
'dont_alias' => [
    App\Models\User::class,
],
```

<a name="writing-commands"></a>
## Escribiendo Comandos

Además de los comandos proporcionados con Artisan, puedes crear tus propios comandos personalizados. Los comandos suelen almacenarse en el directorio `app/Console/Commands`; sin embargo, puedes elegir tu propia ubicación de almacenamiento siempre que tus comandos puedan ser cargados por Composer.

<a name="generating-commands"></a>
### Generando Comandos

Para crear un nuevo comando, puedes usar el comando Artisan `make:command`. Este comando creará una nueva clase de comando en el directorio `app/Console/Commands`. No te preocupes si este directorio no existe en tu aplicación: se creará la primera vez que ejecutes el comando Artisan `make:command`:


```shell
php artisan make:command SendEmails

```

<a name="command-structure"></a>
### Estructura de Comando

Después de generar tu comando, deberías definir valores apropiados para las propiedades `signature` y `description` de la clase. Estas propiedades se utilizarán al mostrar tu comando en la pantalla `list`. La propiedad `signature` también te permite definir [las expectativas de entrada de tu comando](#defining-input-expectations). El método `handle` se llamará cuando se ejecute tu comando. Puedes colocar tu lógica de comando en este método.
Vamos a echar un vistazo a un comando de ejemplo. Ten en cuenta que podemos solicitar cualquier dependencia que necesitemos a través del método `handle` del comando. El [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel inyectará automáticamente todas las dependencias que estén tipadas en la firma de este método:


```php
<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Support\DripEmailer;
use Illuminate\Console\Command;

class SendEmails extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'mail:send {user}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Send a marketing email to a user';

    /**
     * Execute the console command.
     */
    public function handle(DripEmailer $drip): void
    {
        $drip->send(User::find($this->argument('user')));
    }
}
```
> [!NOTE]
Para una mayor reutilización de código, es una buena práctica mantener tus comandos de consola ligeros y dejarlos delegar en los servicios de la aplicación para llevar a cabo sus tareas. En el ejemplo anterior, observa que inyectamos una clase de servicio para hacer el "trabajo pesado" de enviar los correos electrónicos.

<a name="exit-codes"></a>
#### Códigos de Salida

Si no se devuelve nada del método `handle` y el comando se ejecuta con éxito, el comando saldrá con un código de salida `0`, indicando éxito. Sin embargo, el método `handle` puede devolver opcionalmente un entero para especificar manualmente el código de salida del comando:


```php
$this->error('Something went wrong.');

return 1;
```
Si deseas "fallar" el comando desde cualquier método dentro del comando, puedes utilizar el método `fail`. El método `fail` terminará inmediatamente la ejecución del comando y devolverá un código de salida de `1`:


```php
$this->fail('Something went wrong.');
```

<a name="closure-commands"></a>
### Comandos de Funciones Anónimas

Los comandos basados en `funciones anónimas` ofrecen una alternativa a la definición de comandos de consola como clases. De la misma manera que las rutas con `funciones anónimas` son una alternativa a los controladores, piensa en las `funciones anónimas` de comando como una alternativa a las clases de comando.
Aunque el archivo `routes/console.php` no define rutas HTTP, define puntos de entrada basados en consola (rutas) en tu aplicación. Dentro de este archivo, puedes definir todos tus comandos de consola basados en `funciones anónimas` utilizando el método `Artisan::command`. El método `command` acepta dos argumentos: la [firma del comando](#defining-input-expectations) y una función anónima que recibe los argumentos y opciones del comando:


```php
Artisan::command('mail:send {user}', function (string $user) {
    $this->info("Sending email to: {$user}!");
});
```
La `función anónima` está vinculada a la instancia del comando subyacente, por lo que tienes acceso completo a todos los métodos auxiliares a los que normalmente podrías acceder en una clase de comando completa.

<a name="type-hinting-dependencies"></a>
#### Sugerencia de Tipos para Dependencias

Además de recibir los argumentos y opciones de tu comando, las `funciones anónimas` de comandos también pueden indicar de manera explícita dependencias adicionales que te gustaría resolver dentro del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container):


```php
use App\Models\User;
use App\Support\DripEmailer;

Artisan::command('mail:send {user}', function (DripEmailer $drip, string $user) {
    $drip->send(User::find($user));
});
```

<a name="closure-command-descriptions"></a>
#### Descripciones de Comandos de Función Anónima

Al definir un comando basado en una `función anónima`, puedes usar el método `purpose` para añadir una descripción al comando. Esta descripción se mostrará cuando ejecutes los comandos `php artisan list` o `php artisan help`:


```php
Artisan::command('mail:send {user}', function (string $user) {
    // ...
})->purpose('Send a marketing email to a user');
```

<a name="isolatable-commands"></a>
### Comandos Aislables

> [!WARNING]
Para utilizar esta función, tu aplicación debe estar utilizando el driver de caché `memcached`, `redis`, `dynamodb`, `database`, `file` o `array` como el driver de caché predeterminado de tu aplicación. Además, todos los servidores deben estar comunicándose con el mismo servidor de caché central.
A veces es posible que desees asegurarte de que solo una instancia de un comando pueda ejecutarse a la vez. Para lograr esto, puedes implementar la interfaz `Illuminate\Contracts\Console\Isolatable` en tu clase de comando:


```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Contracts\Console\Isolatable;

class SendEmails extends Command implements Isolatable
{
    // ...
}
```
Cuando un comando está marcado como `Isolatable`, Laravel añadirá automáticamente una opción `--isolated` al comando. Cuando se invoca el comando con esa opción, Laravel se asegurará de que no haya otras instancias de ese comando ya en ejecución. Laravel logra esto intentando adquirir un bloqueo atómico utilizando el driver de caché predeterminado de tu aplicación. Si otras instancias del comando están en ejecución, el comando no se ejecutará; sin embargo, el comando aún saldrá con un código de estado de salida exitoso:


```shell
php artisan mail:send 1 --isolated

```
Si deseas especificar el código de estado de salida que el comando debe devolver si no puede ejecutarse, puedes proporcionar el código de estado deseado a través de la opción `isolated`:


```shell
php artisan mail:send 1 --isolated=12

```

<a name="lock-id"></a>
#### ID de bloqueo

Por defecto, Laravel utilizará el nombre del comando para generar la clave de cadena que se usa para adquirir el bloqueo atómico en la caché de tu aplicación. Sin embargo, puedes personalizar esta clave definiendo un método `isolatableId` en tu clase de comando Artisan, lo que te permite integrar los argumentos u opciones del comando en la clave:


```php
/**
 * Get the isolatable ID for the command.
 */
public function isolatableId(): string
{
    return $this->argument('user');
}

```

<a name="lock-expiration-time"></a>
#### Tiempo de Expiración de Bloqueo

Por defecto, los bloqueos de aislamiento expiran después de que se finaliza el comando. O, si el comando es interrumpido y no puede finalizar, el bloqueo expirará después de una hora. Sin embargo, puedes ajustar el tiempo de expiración del bloqueo definiendo un método `isolationLockExpiresAt` en tu comando:


```php
use DateTimeInterface;
use DateInterval;

/**
 * Determine when an isolation lock expires for the command.
 */
public function isolationLockExpiresAt(): DateTimeInterface|DateInterval
{
    return now()->addMinutes(5);
}

```

<a name="defining-input-expectations"></a>
## Definiendo Expectativas de Entrada

Al escribir comandos de consola, es común recopilar la entrada del usuario a través de argumentos u opciones. Laravel facilita definir la entrada que esperas del usuario utilizando la propiedad `signature` en tus comandos. La propiedad `signature` te permite definir el nombre, los argumentos y las opciones para el comando en una única sintaxis expresiva y similar a una ruta.

<a name="arguments"></a>
### Argumentos

Todos los argumentos y opciones proporcionados por el usuario están envueltos en llaves. En el siguiente ejemplo, el comando define un argumento requerido: `user`:


```php
/**
 * The name and signature of the console command.
 *
 * @var string
 */
protected $signature = 'mail:send {user}';
```
También puedes hacer que los argumentos sean opcionales o definir valores predeterminados para los argumentos:


```php
// Optional argument...
'mail:send {user?}'

// Optional argument with default value...
'mail:send {user=foo}'
```

<a name="options"></a>
### Opciones

Las opciones, al igual que los argumentos, son otra forma de entrada del usuario. Las opciones se prefijan con dos guiones (`--`) cuando se proporcionan a través de la línea de comandos. Hay dos tipos de opciones: las que reciben un valor y las que no. Las opciones que no reciben un valor sirven como un "interruptor" booleano. Veamos un ejemplo de este tipo de opción:


```php
/**
 * The name and signature of the console command.
 *
 * @var string
 */
protected $signature = 'mail:send {user} {--queue}';
```
En este ejemplo, el interruptor `--queue` puede especificarse al llamar al comando Artisan. Si se pasa el interruptor `--queue`, el valor de la opción será `true`. De lo contrario, el valor será `false`:


```shell
php artisan mail:send 1 --queue

```

<a name="options-with-values"></a>
#### Opciones Con Valores

A continuación, echemos un vistazo a una opción que espera un valor. Si el usuario debe especificar un valor para una opción, debes sufijar el nombre de la opción con un signo `=`:


```php
/**
 * The name and signature of the console command.
 *
 * @var string
 */
protected $signature = 'mail:send {user} {--queue=}';
```
En este ejemplo, el usuario puede pasar un valor para la opción así. Si la opción no se especifica al invocar el comando, su valor será `null`:


```shell
php artisan mail:send 1 --queue=default

```
Puedes asignar valores predeterminados a las opciones especificando el valor predeterminado después del nombre de la opción. Si el usuario no pasa ningún valor de opción, se utilizará el valor predeterminado:


```php
'mail:send {user} {--queue=default}'
```

<a name="option-shortcuts"></a>
#### Atajos de Opción

Para asignar un atajo al definir una opción, puedes especificarlo antes del nombre de la opción y usar el carácter `|` como un delimitador para separar el atajo del nombre completo de la opción:


```php
'mail:send {user} {--Q|queue}'
```
Al invocar el comando en tu terminal, los atajos de opción deben ir precedidos por un solo guion y no se debe incluir el carácter `=` al especificar un valor para la opción:


```shell
php artisan mail:send 1 -Qdefault

```

<a name="input-arrays"></a>
### Arrays de Entrada

Si deseas definir argumentos u opciones para esperar múltiples valores de entrada, puedes usar el carácter `*`. Primero, echemos un vistazo a un ejemplo que especifica dicho argumento:


```php
'mail:send {user*}'
```
Al llamar a este método, se pueden pasar los argumentos `user` en el orden a la línea de comandos. Por ejemplo, el siguiente comando establecerá el valor de `user` en un array con `1` y `2` como sus valores:


```shell
php artisan mail:send 1 2

```
Este carácter `*` se puede combinar con una definición de argumento opcional para permitir cero o más instancias de un argumento:


```php
'mail:send {user?*}'
```

<a name="option-arrays"></a>
#### Matrices de Opciones

Al definir una opción que espera múltiples valores de entrada, cada valor de opción pasado al comando debe ser precedido por el nombre de la opción:


```php
'mail:send {--id=*}'
```
Tal comando puede ser invocado pasando múltiples argumentos `--id`:


```shell
php artisan mail:send --id=1 --id=2

```

<a name="input-descriptions"></a>
### Descripciones de Entrada

Puedes asignar descripciones a los argumentos de entrada y opciones separando el nombre del argumento de la descripción utilizando dos puntos. Si necesitas un poco más de espacio para definir tu comando, siéntete libre de extender la definición a múltiples líneas:


```php
/**
 * The name and signature of the console command.
 *
 * @var string
 */
protected $signature = 'mail:send
                        {user : The ID of the user}
                        {--queue : Whether the job should be queued}';
```

<a name="prompting-for-missing-input"></a>
### Solicitud de Entrada Faltante

Si tu comando contiene argumentos requeridos, el usuario recibirá un mensaje de error cuando no se proporcionen. Alternativamente, puedes configurar tu comando para que automáticamente solicite al usuario cuando faltan argumentos requeridos implementando la interfaz `PromptsForMissingInput`:


```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Contracts\Console\PromptsForMissingInput;

class SendEmails extends Command implements PromptsForMissingInput
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'mail:send {user}';

    // ...
}
```
Si Laravel necesita recopilar un argumento requerido del usuario, automáticamente le pedirá al usuario el argumento formulando la pregunta de manera inteligente utilizando el nombre o la descripción del argumento. Si deseas personalizar la pregunta utilizada para recopilar el argumento requerido, puedes implementar el método `promptForMissingArgumentsUsing`, devolviendo un array de preguntas indexadas por los nombres de los argumentos:


```php
/**
 * Prompt for missing input arguments using the returned questions.
 *
 * @return array<string, string>
 */
protected function promptForMissingArgumentsUsing(): array
{
    return [
        'user' => 'Which user ID should receive the mail?',
    ];
}
```
También puedes proporcionar texto de marcador de posición utilizando una tupla que contenga la pregunta y el marcador de posición:


```php
return [
    'user' => ['Which user ID should receive the mail?', 'E.g. 123'],
];
```
Si deseas tener control total sobre el aviso, puedes proporcionar una función anónima que debería preguntar al usuario y devolver su respuesta:


```php
use App\Models\User;
use function Laravel\Prompts\search;

// ...

return [
    'user' => fn () => search(
        label: 'Search for a user:',
        placeholder: 'E.g. Taylor Otwell',
        options: fn ($value) => strlen($value) > 0
            ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
            : []
    ),
];
```
> [!NOTE]
La documentación completa de [Laravel Prompts](/docs/%7B%7Bversion%7D%7D/prompts) incluye información adicional sobre los prompts disponibles y su uso.
Si deseas solicitar al usuario que seleccione o ingrese [opciones](#options), puedes incluir solicitudes en el método `handle` de tu comando. Sin embargo, si solo deseas solicitar al usuario cuando también se les haya solicitado automáticamente los argumentos faltantes, entonces puedes implementar el método `afterPromptingForMissingArguments`:


```php
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use function Laravel\Prompts\confirm;

// ...

/**
 * Perform actions after the user was prompted for missing arguments.
 */
protected function afterPromptingForMissingArguments(InputInterface $input, OutputInterface $output): void
{
    $input->setOption('queue', confirm(
        label: 'Would you like to queue the mail?',
        default: $this->option('queue')
    ));
}
```

<a name="command-io"></a>
## Entrada/Salida de Comandos


<a name="retrieving-input"></a>
### Recuperando Entrada

Mientras tu comando se está ejecutando, es probable que necesites acceder a los valores de los argumentos y opciones aceptados por tu comando. Para hacerlo, puedes usar los métodos `argument` y `option`. Si un argumento u opción no existe, se devolverá `null`:


```php
/**
 * Execute the console command.
 */
public function handle(): void
{
    $userId = $this->argument('user');
}
```
Si necesitas recuperar todos los argumentos como un `array`, llama al método `arguments`:


```php
$arguments = $this->arguments();
```
Las opciones se pueden recuperar tan fácilmente como los argumentos utilizando el método `option`. Para recuperar todas las opciones como un array, llama al método `options`:


```php
// Retrieve a specific option...
$queueName = $this->option('queue');

// Retrieve all options as an array...
$options = $this->options();
```

<a name="prompting-for-input"></a>
### Solicitud de Entrada

> [!NOTE]
[Laravel Prompts](/docs/%7B%7Bversion%7D%7D/prompts) es un paquete de PHP para añadir formularios bonitos y fáciles de usar a tus aplicaciones de línea de comandos, con características similares a las de un navegador, incluyendo texto de marcador de posición y validación.
Además de mostrar la salida, también puedes pedir al usuario que proporcione input durante la ejecución de tu comando. El método `ask` preguntará al usuario con la pregunta dada, aceptará su input y luego devolverá el input del usuario a tu comando:


```php
/**
 * Execute the console command.
 */
public function handle(): void
{
    $name = $this->ask('What is your name?');

    // ...
}
```
El método `ask` también acepta un segundo argumento opcional que especifica el valor predeterminado que se debe devolver si no se proporciona entrada del usuario:


```php
$name = $this->ask('What is your name?', 'Taylor');
```
El método `secret` es similar a `ask`, pero la entrada del usuario no será visible para ellos mientras escriben en la consola. Este método es útil al solicitar información sensible, como contraseñas:


```php
$password = $this->secret('What is the password?');
```

<a name="asking-for-confirmation"></a>
#### Pidiendo Confirmación

Si necesitas pedir al usuario una confirmación simple de "sí o no", puedes usar el método `confirm`. Por defecto, este método devolverá `false`. Sin embargo, si el usuario ingresa `y` o `yes` en respuesta al aviso, el método devolverá `true`.


```php
if ($this->confirm('Do you wish to continue?')) {
    // ...
}
```
Si es necesario, puedes especificar que el prompt de confirmación debería devolver `true` por defecto pasando `true` como segundo argumento al método `confirm`:


```php
if ($this->confirm('Do you wish to continue?', true)) {
    // ...
}
```

<a name="auto-completion"></a>
#### Autocompletado

El método `anticipate` se puede utilizar para proporcionar autocompletado para posibles opciones. El usuario aún puede proporcionar cualquier respuesta, independientemente de las sugerencias de autocompletado:


```php
$name = $this->anticipate('What is your name?', ['Taylor', 'Dayle']);
```
Alternativamente, puedes pasar una `función anónima` como segundo argumento al método `anticipate`. La `función anónima` se llamará cada vez que el usuario escriba un carácter de entrada. La `función anónima` debe aceptar un parámetro de cadena que contenga la entrada del usuario hasta ahora, y devolver un array de opciones para la autocompletación:


```php
$name = $this->anticipate('What is your address?', function (string $input) {
    // Return auto-completion options...
});
```

<a name="multiple-choice-questions"></a>
#### Preguntas de Opción Múltiple

Si necesitas dar al usuario un conjunto de opciones predefinidas al hacer una pregunta, puedes usar el método `choice`. Puedes establecer el índice del array del valor predeterminado que se devolverá si no se elige ninguna opción pasando el índice como el tercer argumento al método:


```php
$name = $this->choice(
    'What is your name?',
    ['Taylor', 'Dayle'],
    $defaultIndex
);
```
Además, el método `choice` acepta argumentos opcionales cuarto y quinto para determinar el número máximo de intentos para seleccionar una respuesta válida y si se permiten selecciones múltiples:


```php
$name = $this->choice(
    'What is your name?',
    ['Taylor', 'Dayle'],
    $defaultIndex,
    $maxAttempts = null,
    $allowMultipleSelections = false
);
```

<a name="writing-output"></a>
### Escritura de Salida

Para enviar salida a la consola, puedes usar los métodos `line`, `info`, `comment`, `question`, `warn` y `error`. Cada uno de estos métodos utilizará colores ANSI apropiados para su propósito. Por ejemplo, mostramos alguna información general al usuario. Típicamente, el método `info` se mostrará en la consola como texto de color verde:


```php
/**
 * Execute the console command.
 */
public function handle(): void
{
    // ...

    $this->info('The command was successful!');
}
```
Para mostrar un mensaje de error, utiliza el método `error`. El texto del mensaje de error se muestra típicamente en rojo:


```php
$this->error('Something went wrong!');
```
Puedes usar el método `line` para mostrar texto en blanco, sin color:


```php
$this->line('Display this on the screen');
```
Puedes usar el método `newLine` para mostrar una línea en blanco:


```php
// Write a single blank line...
$this->newLine();

// Write three blank lines...
$this->newLine(3);
```

<a name="tables"></a>
#### Tablas

El método `table` facilita el formateo correcto de múltiples filas / columnas de datos. Todo lo que necesitas hacer es proporcionar los nombres de las columnas y los datos para la tabla y Laravel calculará automáticamente el ancho y la altura apropiados de la tabla por ti:


```php
use App\Models\User;

$this->table(
    ['Name', 'Email'],
    User::all(['name', 'email'])->toArray()
);
```

<a name="progress-bars"></a>
#### Barras de Progreso

Para tareas de larga duración, puede ser útil mostrar una barra de progreso que informe a los usuarios qué tan completa está la tarea. Usando el método `withProgressBar`, Laravel mostrará una barra de progreso y avanzará su progreso por cada iteración sobre un valor iterable dado:


```php
use App\Models\User;

$users = $this->withProgressBar(User::all(), function (User $user) {
    $this->performTask($user);
});
```
A veces, es posible que necesites un control manual más preciso sobre cómo avanza una barra de progreso. Primero, define el número total de pasos por los que iterará el proceso. Luego, avanza la barra de progreso después de procesar cada elemento:


```php
$users = App\Models\User::all();

$bar = $this->output->createProgressBar(count($users));

$bar->start();

foreach ($users as $user) {
    $this->performTask($user);

    $bar->advance();
}

$bar->finish();
```
> [!NOTA]
Para opciones más avanzadas, consulta la [documentación del componente Progress Bar de Symfony](https://symfony.com/doc/7.0/components/console/helpers/progressbar.html).

<a name="registering-commands"></a>
## Registrando Comandos

Por defecto, Laravel registra automáticamente todos los comandos dentro del directorio `app/Console/Commands`. Sin embargo, puedes instruir a Laravel para que escanee otros directorios en busca de comandos Artisan utilizando el método `withCommands` en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withCommands([
    __DIR__.'/../app/Domain/Orders/Commands',
])
```
Si es necesario, también puedes registrar comandos manualmente proporcionando el nombre de la clase del comando al método `withCommands`:


```php
use App\Domain\Orders\Commands\SendEmails;

->withCommands([
    SendEmails::class,
])
```
Cuando Artisan se inicia, todos los comandos en tu aplicación serán resueltos por el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) y registrados con Artisan.

<a name="programmatically-executing-commands"></a>
## Ejecutando Comandos de Forma Programática

A veces es posible que desees ejecutar un comando Artisan fuera de la CLI. Por ejemplo, es posible que desees ejecutar un comando Artisan desde una ruta o controlador. Puedes usar el método `call` en la fachada `Artisan` para lograr esto. El método `call` acepta el nombre de la firma del comando o el nombre de la clase como su primer argumento, y un array de parámetros del comando como segundo argumento. Se devolverá el código de salida:


```php
use Illuminate\Support\Facades\Artisan;

Route::post('/user/{user}/mail', function (string $user) {
    $exitCode = Artisan::call('mail:send', [
        'user' => $user, '--queue' => 'default'
    ]);

    // ...
});
```
Alternativamente, puedes pasar todo el comando Artisan al método `call` como una cadena:


```php
Artisan::call('mail:send 1 --queue=default');
```

<a name="passing-array-values"></a>
#### Pasando Valores de Array

Si tu comando define una opción que acepta un array, puedes pasar un array de valores a esa opción:


```php
use Illuminate\Support\Facades\Artisan;

Route::post('/mail', function () {
    $exitCode = Artisan::call('mail:send', [
        '--id' => [5, 13]
    ]);
});
```

<a name="passing-boolean-values"></a>
#### Pasando Valores Booleanos

Si necesitas especificar el valor de una opción que no acepta valores de cadena, como el flag `--force` en el comando `migrate:refresh`, debes pasar `true` o `false` como el valor de la opción:


```php
$exitCode = Artisan::call('migrate:refresh', [
    '--force' => true,
]);
```

<a name="queueing-artisan-commands"></a>
#### Colas de Comandos Artisan

Usando el método `queue` en la fachada `Artisan`, incluso puedes poner en cola comandos de Artisan para que sean procesados en segundo plano por tus [trabajadores de cola](/docs/%7B%7Bversion%7D%7D/queues). Antes de usar este método, asegúrate de haber configurado tu cola y de estar ejecutando un listener de cola:


```php
use Illuminate\Support\Facades\Artisan;

Route::post('/user/{user}/mail', function (string $user) {
    Artisan::queue('mail:send', [
        'user' => $user, '--queue' => 'default'
    ]);

    // ...
});
```
Usando los métodos `onConnection` y `onQueue`, puedes especificar la conexión o la cola a la que se debe despachar el comando Artisan:


```php
Artisan::queue('mail:send', [
    'user' => 1, '--queue' => 'default'
])->onConnection('redis')->onQueue('commands');
```

<a name="calling-commands-from-other-commands"></a>
### Llamando Comandos Desde Otros Comandos

A veces es posible que desees llamar a otros comandos desde un comando Artisan existente. Puedes hacerlo usando el método `call`. Este método `call` acepta el nombre del comando y un array de argumentos / opciones del comando:


```php
/**
 * Execute the console command.
 */
public function handle(): void
{
    $this->call('mail:send', [
        'user' => 1, '--queue' => 'default'
    ]);

    // ...
}
```
Si deseas llamar a otro comando de consola y suprimir toda su salida, puedes usar el método `callSilently`. El método `callSilently` tiene la misma firma que el método `call`:


```php
$this->callSilently('mail:send', [
    'user' => 1, '--queue' => 'default'
]);
```

<a name="signal-handling"></a>
## Manejo de Señales

Como sabes, los sistemas operativos permiten que se envíen señales a los procesos en ejecución. Por ejemplo, la señal `SIGTERM` es cómo los sistemas operativos piden a un programa que termine. Si deseas escuchar señales en tus comandos de consola Artisan y ejecutar código cuando ocurren, puedes usar el método `trap`:


```php
/**
 * Execute the console command.
 */
public function handle(): void
{
    $this->trap(SIGTERM, fn () => $this->shouldKeepRunning = false);

    while ($this->shouldKeepRunning) {
        // ...
    }
}
```
Para escuchar múltiples señales a la vez, puedes proporcionar un array de señales al método `trap`:


```php
$this->trap([SIGTERM, SIGQUIT], function (int $signal) {
    $this->shouldKeepRunning = false;

    dump($signal); // SIGTERM / SIGQUIT
});
```

<a name="stub-customization"></a>
## Personalización de Stubs

Los comandos `make` de la consola Artisan se utilizan para crear una variedad de clases, como controladores, trabajos, migraciones y pruebas. Estas clases se generan utilizando archivos "stub" que se rellenan con valores basados en tu entrada. Sin embargo, es posible que desees hacer pequeños cambios en los archivos generados por Artisan. Para lograr esto, puedes usar el comando `stub:publish` para publicar los stubs más comunes en tu aplicación y así poder personalizarlos:


```shell
php artisan stub:publish

```
Los stubs publicados se ubicarán dentro de un directorio `stubs` en la raíz de tu aplicación. Cualquier cambio que realices en estos stubs se reflejará cuando generes sus respectivas clases utilizando los comandos `make` de Artisan.

<a name="events"></a>
## Eventos

Artisan despacha tres eventos al ejecutar comandos: `Illuminate\Console\Events\ArtisanStarting`, `Illuminate\Console\Events\CommandStarting` y `Illuminate\Console\Events\CommandFinished`. El evento `ArtisanStarting` se despacha inmediatamente cuando Artisan comienza a ejecutarse. A continuación, se despacha el evento `CommandStarting` inmediatamente antes de que se ejecute un comando. Finalmente, el evento `CommandFinished` se despacha una vez que un comando ha terminado de ejecutarse.