# Consola Artisan

- [Introducción](#introduction)
  - [Tinker (REPL)](#tinker)
- [Escribir comandos](#writing-commands)
  - [Generación de comandos](#generating-commands)
  - [Estructura de comandos](#command-structure)
  - [Comandos Closure](#closure-commands)
  - [Comandos aislables](#isolatable-commands)
- [Definición de expectativas de entrada](#defining-input-expectations)
  - [Argumentos](#arguments)
  - [Opciones](#options)
  - [Matrices de entrada](#input-arrays)
  - [Descripciones de entrada](#input-descriptions)
- [Comandos de E/S](#command-io)
  - [Recuperación de entradas](#retrieving-input)
  - [Solicitud de entradas](#prompting-for-input)
  - [Escritura de salida](#writing-output)
- [Registro de comandos](#registering-commands)
- [Ejecución programática de comandos](#programmatically-executing-commands)
  - [Llamada a comandos desde otros comandos](#calling-commands-from-other-commands)
- [Manejo de Señales](#signal-handling)
- [Personalización de Stub](#stub-customization)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

Artisan es la interfaz de línea de comandos incluida con Laravel. Artisan existe en la raíz de tu aplicación como el script `artisan` y provee un número de comandos útiles que pueden asistirte mientras construyes tu aplicación. Para ver una lista de todos los comandos disponibles de Artisan, puedes utilizar el comando `list`:

```shell
php artisan list
```

Cada comando también incluye una pantalla de "ayuda" que muestra y describe los argumentos y opciones disponibles del comando. Para ver una pantalla de ayuda, preceda el nombre del comando con `help`:

```shell
php artisan help migrate
```

<a name="laravel-sail"></a>
#### Laravel Sail

Si estás utilizando [Laravel Sail](/docs/{{version}}/sail) como tu entorno de desarrollo local, recuerda utilizar la línea de comandos `sail` para invocar comandos Artisan. Sail ejecutará tus comandos Artisan dentro de los contenedores Docker de tu aplicación:

```shell
./vendor/bin/sail artisan list
```

<a name="tinker"></a>
### Tinker (REPL)

Laravel Tinker es un poderoso REPL para el framework Laravel, potenciado por el paquete [PsySH](https://github.com/bobthecow/psysh).

<a name="installation"></a>
#### Instalación

Todas las aplicaciones Laravel incluyen Tinker por defecto. Sin embargo, puedes instalar Tinker usando Composer si previamente lo has removido de tu aplicación:

```shell
composer require laravel/tinker
```

> **Nota**  
> ¿Buscas una interfaz gráfica para interactuar con tu aplicación Laravel? ¡Echa un vistazo a [Tinkerwell](https://tinkerwell.app)!

<a name="usage"></a>
#### Uso

Tinker te permite interactuar con toda tu aplicación Laravel en la línea de comandos, incluyendo tus modelos Eloquent, trabajos, eventos y más. Para entrar en el entorno Tinker, ejecuta el comando `tinker` Artisan:

```shell
php artisan tinker
```

Puedes publicar el archivo de configuración de Tinker usando el comando `vendor:publish`:

```shell
php artisan vendor:publish --provider="Laravel\Tinker\TinkerServiceProvider"
```

> **Advertencia**  
> La función `dispatch` helper y el método `dispatch` de la clase `Dispatchable` dependen de la recolección de basura para colocar el trabajo en la cola. Por lo tanto, cuando uses tinker, deberías usar `Bus::dispatch` o `Queue::push` para despachar trabajos.

<a name="command-allow-list"></a>
#### Lista de comandos permitidos

Tinker utiliza una lista "allow" para determinar que comandos Artisan pueden ser ejecutados dentro de su shell. Por defecto, puedes ejecutar los comandos `clear-compiled`, `down`, `env`, `inspire`, `migrate`, `optimize` y `up`. Si deseas permitir más comandos puedes agregarlos a la array `comandos` en tu archivo de configuración `tinker.php`:

    'commands' => [
        // App\Console\Commands\ExampleCommand::class,
    ],

<a name="classes-that-should-not-be-aliased"></a>
#### Clases Que No Deben Ser Alias

Típicamente, Tinker automáticamente asigna alias a las clases cuando interactúas con ellas en Tinker. Sin embargo, puede que desees no aliasear nunca algunas clases. Puedes lograr esto listando las clases en el array `dont_alias` de tu archivo de configuración `tinker.php`:

    'dont_alias' => [
        App\Models\User::class,
    ],

<a name="writing-commands"></a>
## Escribiendo Comandos

Además de los comandos provistos con Artisan, puedes construir tus propios comandos personalizados. Los comandos se almacenan normalmente en el directorio `app/Console/Commands`; sin embargo, eres libre de elegir tu propia ubicación de almacenamiento siempre y cuando tus comandos puedan ser cargados por Composer.

<a name="generating-commands"></a>
### Generación de Comandos

Para crear un nuevo comando, puede utilizar el comando `make:command` Artisan. Este comando creará una nueva clase de comando en el directorio `app/Console/Commands`. No te preocupes si este directorio no existe en tu aplicación - será creado la primera vez que ejecutes el comando make: `command` Artisan:

```shell
php artisan make:command SendEmails
```

<a name="command-structure"></a>
### Estructura de Comandos

Después de generar su comando, debe definir los valores apropiados para las propiedades `signature` y `description` de la clase. Estas propiedades se utilizarán cuando se muestre el comando en la pantalla de `list`. La propiedad `signature` también le permite definir [las expectativas de entrada de su comando](#defining-input-expectations). El método `handle` será llamado cuando su comando sea ejecutado. Puede colocar la lógica de su comando en este método.

Veamos un ejemplo de comando. Observa que podemos solicitar cualquier dependencia que necesitemos a través del método `handle` del comando. El [contenedor de servicios](/docs/{{version}}/container) de Laravel inyectará automáticamente todas las dependencias que se indiquen en la firma de este método:

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
         *
         * @param  \App\Support\DripEmailer  $drip
         * @return mixed
         */
        public function handle(DripEmailer $drip)
        {
            $drip->send(User::find($this->argument('user')));
        }
    }

> **Nota**  
> Para una mayor reutilización del código, es una buena práctica mantener los comandos de la consola ligeros y dejar que los servicios de la aplicación realicen sus tareas. En el ejemplo anterior, observe que inyectamos una clase de servicio para realizar el "trabajo pesado" de enviar los correos electrónicos.

<a name="closure-commands"></a>
### Comandos Closure

Los comandos basados en `closures` proporcionan una alternativa a la definición de comandos de consola como clases. De la misma manera que los `closures` de rutas son una alternativa a los controladores, piensa en los `closures` de comandos como una alternativa a las clases de comandos. Dentro del método `commands` de tu archivo `app/Console/Kernel.` php, Laravel carga el archivo `routes/console.` php:

    /**
     * Register the closure based commands for the application.
     *
     * @return void
     */
    protected function commands()
    {
        require base_path('routes/console.php');
    }

Aunque este archivo no define rutas HTTP, define puntos de entrada basados en la consola (rutas) en su aplicación. Dentro de este archivo, puedes definir todos tus comandos de consola basados en `closures` usando el método `Artisan::command`. El método `command` acepta dos argumentos: la [firma del comando](#defining-input-expectations) y un `closure` que recibe los argumentos y opciones del comando:

    Artisan::command('mail:send {user}', function ($user) {
        $this->info("Sending email to: {$user}!");
    });

El `closure` está vinculado a la instancia de comando subyacente, por lo que tienes acceso completo a todos los métodos de ayuda a los que normalmente podrías acceder en una clase de comando completa.

<a name="type-hinting-dependencies"></a>
#### Dependencias de Type-Hinting

Además de recibir los argumentos y opciones de tu comando, los `closures` de comandos también pueden indicar dependencias adicionales que te gustaría que fueran resueltas fuera del [contenedor de servicios](/docs/{{version}}/container):

    use App\Models\User;
    use App\Support\DripEmailer;

    Artisan::command('mail:send {user}', function (DripEmailer $drip, $user) {
        $drip->send(User::find($user));
    });

<a name="closure-command-descriptions"></a>
#### Descripciones de comandos Closure

Al definir un comando basado en `closures`, puede utilizar el método `purpose` para añadir una descripción al comando. Esta descripción se mostrará cuando ejecute los comandos `php artisan list` o `php artisan help`:

    Artisan::command('mail:send {user}', function ($user) {
        // ...
    })->purpose('Send a marketing email to a user');

<a name="isolatable-commands"></a>
### Comandos aislables

> **Advertencia** para utilizar esta característica, su aplicación debe estar usando el controlador de cache `memcached`, `redis`, `dynamodb`, `base de datos`, `archivo` o `array` como controlador de cache predeterminado de su aplicación. Además, todos los servidores deben comunicarse con el mismo servidor central de cache.

A veces es posible que desee asegurarse de que sólo una instancia de un comando se puede ejecutar a la vez. Para ello, puede implementar la interfaz `Illuminate\Contracts\Console\Isolatable` en su clase de comando:

    <?php

    namespace App\Console\Commands;

    use Illuminate\Console\Command;
    use Illuminate\Contracts\Console\Isolatable;

    class SendEmails extends Command implements Isolatable
    {
        // ...
    }

Cuando un comando es marcado como `Isolatable`, Laravel automáticamente agregará una opción `--isolated` al comando. Cuando el comando es invocado con esa opción, Laravel se asegurará de que no haya otras instancias de ese comando ejecutándose. Laravel consigue esto intentando adquirir un bloqueo atómico utilizando el controlador de cache por defecto de tu aplicación. Si otras instancias del comando se están ejecutando, el comando no se ejecutará; sin embargo, el comando saldrá con un código de estado de salida correcto:

```shell
php artisan mail:send 1 --isolated
```

Si desea especificar el código de estado de salida que el comando debe devolver si no es capaz de ejecutarse, puede proporcionar el código de estado deseado a través de la opción `aislada`:

```shell
php artisan mail:send 1 --isolated=12
```

<a name="lock-expiration-time"></a>
#### Tiempo de expiración del bloqueo

Por defecto, los bloqueos de aislamiento expiran una vez finalizado el comando. O, si el comando se interrumpe y no puede terminar, el bloqueo expirará después de una hora. Sin embargo, puede ajustar el tiempo de expiración del bloqueo definiendo un método `isolationLockExpiresAt` en su comando:

```php
/**
 * Determine when an isolation lock expires for the command.
 *
 * @return \DateTimeInterface|\DateInterval
 */
public function isolationLockExpiresAt()
{
    return now()->addMinutes(5);
}
```

<a name="defining-input-expectations"></a>
## Definición de expectativas de entrada

Al escribir comandos de consola, es común recoger información del usuario a través de argumentos u opciones. Laravel hace que sea muy conveniente definir la entrada que esperas del usuario utilizando la propiedad `signature` en tus comandos. La propiedad `signature` permite definir el nombre, los argumentos y las opciones del comando en una sintaxis única, expresiva y similar a una ruta.

<a name="arguments"></a>
### Argumentos

Todos los argumentos y opciones proporcionados por el usuario se encierran entre llaves. En el siguiente ejemplo, el comando define un argumento obligatorio: `user`:

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'mail:send {user}';

También puede hacer que los argumentos sean opcionales o definir valores por defecto para los argumentos:

    // Optional argument...
    'mail:send {user?}'

    // Optional argument with default value...
    'mail:send {user=foo}'

<a name="options"></a>
### Opciones

Las opciones, como los argumentos, son otra forma de entrada del usuario. Las opciones van precedidas de dos guiones`(--`) cuando se proporcionan a través de la línea de comandos. Hay dos tipos de opciones: las que reciben un valor y las que no. Las opciones que no reciben un valor sirven como un "interruptor" booleano. Veamos un ejemplo de este tipo de opción:

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'mail:send {user} {--queue}';

En este ejemplo, el modificador `--queue` puede ser especificado cuando se llama al comando Artisan. Si se pasa el modificador `--queue`, el valor de la opción será `true`. En caso contrario, `el` valor será false:

```shell
php artisan mail:send 1 --queue
```

<a name="options-with-values"></a>
#### Opciones con Valores

A continuación, echemos un vistazo a una opción que espera un valor. Si el usuario debe especificar un valor para una opción, debe añadir un signo `=` al nombre de la opción:

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'mail:send {user} {--queue=}';

En este ejemplo, el usuario puede pasar un valor para la opción de la siguiente manera. Si la opción no se especifica al invocar el comando, su valor será `null`:

```shell
php artisan mail:send 1 --queue=default
```

Puede asignar valores por defecto a las opciones especificando el valor por defecto después del nombre de la opción. Si el usuario no especifica ningún valor para la opción, se utilizará el valor por defecto:

    'mail:send {user} {--queue=default}'

<a name="option-shortcuts"></a>
#### Atajos de opción

Para asignar un acceso directo al definir una opción, puede especificarlo antes del nombre de la opción y utilizar el carácter `|` como delimitador para separar el acceso directo del nombre completo de la opción:

    'mail:send {user} {--Q|queue}'

Cuando invoque el comando en su terminal, los atajos de opción deben ir precedidos de un guión simple:

```shell
php artisan mail:send 1 -Q
```

<a name="input-arrays"></a>
### Matrices de entrada

Si desea definir argumentos u opciones que esperen múltiples valores de entrada, puede utilizar el carácter `*`. En primer lugar, veamos un ejemplo que especifica un argumento de este tipo:

    'mail:send {user*}'

Al llamar a este método, los argumentos de `user` pueden pasarse en orden a la línea de comandos. Por ejemplo, el siguiente comando establecerá el valor de `user` en un array con `1` y `2` como valores:

```shell
php artisan mail:send 1 2
```

Este carácter `*` puede combinarse con una definición de argumento opcional para permitir cero o más instancias de un argumento:

    'mail:send {user?*}'

<a name="option-arrays"></a>
#### Arrays de opciones

Cuando se define una opción que espera múltiples valores de entrada, cada valor de opción pasado al comando debe ir prefijado con el nombre de la opción:

    'mail:send {--id=*}'

Un comando de este tipo puede invocarse pasando varios argumentos `--id`:

```shell
php artisan mail:send --id=1 --id=2
```

<a name="input-descriptions"></a>
### Descripciones de entrada

Puede asignar descripciones a los argumentos de entrada y a las opciones separando el nombre del argumento de la descripción mediante dos puntos. Si necesita más espacio para definir su orden, puede hacerlo en varias líneas:

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'mail:send
                            {user : The ID of the user}
                            {--queue : Whether the job should be queued}';

<a name="command-io"></a>
## Comandos de E/S

<a name="retrieving-input"></a>
### Recuperación de entradas

Mientras se ejecuta su comando, es probable que necesite acceder a los valores de los argumentos y opciones aceptados por su comando. Para ello, puede utilizar los métodos `argument` y `option`. Si un argumento u opción no existe, se devolverá `null`:

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        $userId = $this->argument('user');

        //
    }

Si necesita recuperar todos los argumentos como una `array`, llame al método `arguments`:

    $arguments = $this->arguments();

Las opciones se pueden recuperar tan fácilmente como los argumentos utilizando el método `option`. Para recuperar todas las opciones como una array, llame al método `options`:

    // Retrieve a specific option...
    $queueName = $this->option('queue');

    // Retrieve all options as an array...
    $options = $this->options();

<a name="prompting-for-input"></a>
### Solicitud de entradas

Además de mostrar la salida, también puede pedir al usuario que proporcione información durante la ejecución de su comando. El método `ask` preguntará al usuario con la pregunta dada, aceptará su entrada, y luego devolverá la entrada del usuario a su comando:

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $name = $this->ask('What is your name?');
    }

El método `secret` es similar a `ask`, pero la entrada del usuario no será visible para él mientras escribe en la consola. Este método es útil cuando se pide información sensible como contraseñas:

    $password = $this->secret('What is the password?');

<a name="asking-for-confirmation"></a>
#### Pedir confirmación

Si necesita pedir al usuario una simple confirmación de "sí o no", puede utilizar el método `confirm`. Por defecto, este método devolverá `false`. Sin embargo, si el usuario introduce `y` o `yes` en respuesta a la pregunta, el método devolverá `true`.

    if ($this->confirm('Do you wish to continue?')) {
        //
    }

Si es necesario, puede especificar que la petición de confirmación devuelva `true` por defecto pasando `true` como segundo argumento al método `confirm`:

    if ($this->confirm('Do you wish to continue?', true)) {
        //
    }

<a name="auto-completion"></a>
#### Autocompletado

El método `anticipate` puede utilizarse para proporcionar autocompletado para las posibles opciones. El usuario puede proporcionar cualquier respuesta, independientemente de las sugerencias de autocompletado:

    $name = $this->anticipate('What is your name?', ['Taylor', 'Dayle']);

De manera alternativa, puede pasar un closure como segundo argumento al método `anticipar`. El closure será llamado cada vez que el usuario introduzca un carácter. El closure debe aceptar un parámetro de cadena que contenga la entrada del usuario hasta el momento, y devolver una array de opciones para el autocompletado:

    $name = $this->anticipate('What is your address?', function ($input) {
        // Return auto-completion options...
    });

<a name="multiple-choice-questions"></a>
#### Preguntas de respuesta múltiple

Si necesita dar al usuario un conjunto predefinido de opciones al hacer una pregunta, puede utilizar el método `choice`. Puede establecer el índice de la array del valor predeterminado que se devolverá si no se elige ninguna opción pasando el índice como tercer argumento al método:

    $name = $this->choice(
        'What is your name?',
        ['Taylor', 'Dayle'],
        $defaultIndex
    );

Además, el método `choice` acepta los argumentos cuarto y quinto opcionales para determinar el número máximo de intentos para seleccionar una respuesta válida y si se permiten selecciones múltiples:

    $name = $this->choice(
        'What is your name?',
        ['Taylor', 'Dayle'],
        $defaultIndex,
        $maxAttempts = null,
        $allowMultipleSelections = false
    );

<a name="writing-output"></a>
### Escritura de salida

Para enviar la salida a la consola, puede utilizar los métodos `line`, `info`, `comment`, `question`, `warn` y `error`. Cada uno de estos métodos utilizará los colores ANSI apropiados para su propósito. Por ejemplo, vamos a mostrar alguna información general al usuario. Típicamente, el método `info` se mostrará en la consola como texto de color verde:

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        // ...

        $this->info('The command was successful!');
    }

Para mostrar un mensaje de error, utilice el método `error`. El texto del mensaje de error se muestra normalmente en color rojo:

    $this->error('Something went wrong!');

Puede utilizar el método `line` para mostrar texto sin colorear:

    $this->line('Display this on the screen');

Puede utilizar el método `newLine` para mostrar una línea en blanco:

    // Write a single blank line...
    $this->newLine();

    // Write three blank lines...
    $this->newLine(3);

<a name="tables"></a>
#### Tablas

El método de `table` facilita el formateo correcto de múltiples filas / columnas de datos. Todo lo que necesitas hacer es proporcionar los nombres de las columnas y los datos de la tabla y Laravel calculará automáticamente el ancho y alto de la tabla:

    use App\Models\User;

    $this->table(
        ['Name', 'Email'],
        User::all(['name', 'email'])->toArray()
    );

<a name="progress-bars"></a>
#### Barras de progreso

Para tareas de larga duración, puede ser útil mostrar una barra de progreso que informe a los usuarios de cómo de completa está la tarea. Usando el método `withProgressBar`, Laravel mostrará una barra de progreso y avanzará su progreso para cada iteración sobre un valor iterable dado:

    use App\Models\User;

    $users = $this->withProgressBar(User::all(), function ($user) {
        $this->performTask($user);
    });

A veces, puede que necesites un control más manual sobre cómo avanza una barra de progreso. Primero, define el número total de pasos que iterará el proceso. Luego, avance la barra de progreso después de procesar cada ítem:

    $users = App\Models\User::all();

    $bar = $this->output->createProgressBar(count($users));

    $bar->start();

    foreach ($users as $user) {
        $this->performTask($user);

        $bar->advance();
    }

    $bar->finish();

> **Nota**  
> Para opciones más avanzadas, consulta la [documentación del componente Symfony Progress Bar](https://symfony.com/doc/current/components/console/helpers/progressbar.html).

<a name="registering-commands"></a>
## Registro de comandos

Todos los comandos de la consola se registran en la clase `AppConsole\Kernel` de la aplicación, que es el "núcleo de la consola" de la aplicación. Dentro del método `commands` de esta clase, verás una llamada al método `load` del kernel. El método `load` escaneará el directorio `app/Console/Commands` y automáticamente registrará cada comando que contenga con Artisan. Puedes incluso hacer llamadas adicionales al método `load` para escanear otros directorios en busca de comandos Artisan:

    /**
     * Register the commands for the application.
     *
     * @return void
     */
    protected function commands()
    {
        $this->load(__DIR__.'/Commands');
        $this->load(__DIR__.'/../Domain/Orders/Commands');

        // ...
    }

Si es necesario, puede registrar manualmente los comandos añadiendo el nombre de la clase del comando a una propiedad `$commands` dentro de su clase `App/Console\Kernel`. Si esta propiedad no está ya definida en su kernel, deberá definirla manualmente. Cuando Artisan arranque, todos los comandos listados en esta propiedad serán resueltos por el [contenedor de servicios](/docs/{{version}}/container) y registrados con Artisan:

    protected $commands = [
        Commands\SendEmails::class
    ];

<a name="programmatically-executing-commands"></a>
## Ejecución programática de comandos

A veces puede que desee ejecutar un comando Artisan fuera de la CLI. Por ejemplo, puede que desee ejecutar un comando Artisan desde una ruta o controlador. Usted puede utilizar el método de `call` en la facade Artisan para lograr esto. El método `call` acepta ya sea el nombre de la firma del comando o el nombre de la clase como primer argumento, y un array de parámetros del comando como segundo argumento. El código de salida será devuelto:

    use Illuminate\Support\Facades\Artisan;

    Route::post('/user/{user}/mail', function ($user) {
        $exitCode = Artisan::call('mail:send', [
            'user' => $user, '--queue' => 'default'
        ]);

        //
    });

De forma alternativa, puede pasar el comando Artisan completo al método de `call` como una cadena:

    Artisan::call('mail:send 1 --queue=default');

<a name="passing-array-values"></a>
#### Pasando Valores de array

Si su comando define una opción que acepta un array, puede pasar un array de valores a esa opción:

    use Illuminate\Support\Facades\Artisan;

    Route::post('/mail', function () {
        $exitCode = Artisan::call('mail:send', [
            '--id' => [5, 13]
        ]);
    });

<a name="passing-boolean-values"></a>
#### Pasar valores booleanos

Si necesita especificar el valor de una opción que no acepta valores de cadena, como la bandera `--force` en el comando `migrate:refresh`, debe pasar `true` o `false` como el valor de la opción:

    $exitCode = Artisan::call('migrate:refresh', [
        '--force' => true,
    ]);

<a name="queueing-artisan-commands"></a>
#### Cola de comandos Artisan

Utilizando el método de `cola` en la facade `Artisan`, puedes incluso poner en cola los comandos de Artisan para que sean procesados en segundo plano por tus [trabajadores de cola](/docs/{{version}}/queues). Antes de utilizar este método, asegúrese de que ha configurado su cola y está ejecutando un oyente de cola:

    use Illuminate\Support\Facades\Artisan;

    Route::post('/user/{user}/mail', function ($user) {
        Artisan::queue('mail:send', [
            'user' => $user, '--queue' => 'default'
        ]);

        //
    });

Utilizando los métodos `onConnection` y `onQueue`, usted puede especificar la conexión o cola a la que el comando Artisan debe ser enviado:

    Artisan::queue('mail:send', [
        'user' => 1, '--queue' => 'default'
    ])->onConnection('redis')->onQueue('commands');

<a name="calling-commands-from-other-commands"></a>
### Llamada a comandos desde otros comandos

Algunas veces puede desear llamar a otros comandos desde un comando Artisan existente. Puede hacerlo utilizando el método `call`. Este método de `call` acepta el nombre del comando y un array de argumentos / opciones del comando:

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $this->call('mail:send', [
            'user' => 1, '--queue' => 'default'
        ]);

        //
    }

Si desea llamar a otro comando de consola y suprimir toda su salida, puede utilizar el método `callSilently`. El método `callSilently` tiene la misma firma que el método `call`:

    $this->callSilently('mail:send', [
        'user' => 1, '--queue' => 'default'
    ]);

<a name="signal-handling"></a>
## Manejo de Señales

Como ya sabrás, los sistemas operativos permiten enviar señales a los procesos en ejecución. Por ejemplo, la señal `SIGTERM` es la forma en que los sistemas operativos piden a un programa que termine. Si deseas escuchar señales en tus comandos de la consola Artisan y ejecutar código cuando ocurran, puedes utilizar el método `trap`:

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $this->trap(SIGTERM, fn () => $this->shouldKeepRunning = false);

        while ($this->shouldKeepRunning) {
            // ...
        }
    }

Para escuchar múltiples señales a la vez, puedes proporcionar un array de señales al método `trap`:

    $this->trap([SIGTERM, SIGQUIT], function ($signal) {
        $this->shouldKeepRunning = false;

        dump($signal); // SIGTERM / SIGQUIT
    });

<a name="stub-customization"></a>
## Personalización de Stub

Los comandos `make` de la consola Artisan son utilizados para crear una variedad de clases, tales como controladores, trabajos, migraciones y pruebas. Estas clases son generadas usando archivos "stub" que son poblados con valores basados en tus entradas. Sin embargo, usted puede querer hacer pequeños cambios a los archivos generados por Artisan. Para lograr esto, puedes utilizar el comando `stub:publish` para publicar los stubs más comunes en tu aplicación de manera que puedas personalizarlos:

```shell
php artisan stub:publish
```

Los stubs publicados estarán localizados dentro de un directorio `stubs` en la raíz de tu aplicación. Cualquier cambio que hagas a estos stubs se reflejará cuando generes sus clases correspondientes usando los comandos `make` de Artisan.

<a name="events"></a>
## Eventos

Artisan despacha tres eventos cuando ejecuta comandos: `Illuminate\Console\Events\ArtisanStarting`, `Illuminate\Console\Events\CommandStarting`, y `Illuminate\Console\Events\CommandFinished`. El evento `ArtisanStarting` se envía inmediatamente cuando Artisan comienza a ejecutarse. A continuación, el evento `CommandStarting` se envía inmediatamente antes de que se ejecute un comando. Finalmente, el evento `CommandFinished` es enviado una vez que el comando termina de ejecutarse.
