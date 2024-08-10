# Consola Artisan

- [Consola Artisan](#consola-artisan)
  - [Introducción](#introducción)
      - [Laravel Sail](#laravel-sail)
    - [Tinker (REPL)](#tinker-repl)
      - [Instalación](#instalación)
      - [Uso](#uso)
      - [Lista de Comandos Permitidos](#lista-de-comandos-permitidos)
      - [Clases Que No Deben Ser Alias](#clases-que-no-deben-ser-alias)
  - [Escribiendo Comandos](#escribiendo-comandos)
    - [Generando Comandos](#generando-comandos)
    - [Estructura del Comando](#estructura-del-comando)
      - [Códigos de Salida](#códigos-de-salida)
    - [Comandos de Función Anónima](#comandos-de-función-anónima)
      - [Tipado de Dependencias](#tipado-de-dependencias)
      - [Descripciones de Comandos de Función Anónima](#descripciones-de-comandos-de-función-anónima)
    - [Comandos Aislables](#comandos-aislables)
      - [ID de Bloqueo](#id-de-bloqueo)
      - [Tiempo de Expiración del Bloqueo](#tiempo-de-expiración-del-bloqueo)
  - [Definiendo Expectativas de Entrada](#definiendo-expectativas-de-entrada)
    - [Argumentos](#argumentos)
    - [Opciones](#opciones)
      - [Opciones Con Valores](#opciones-con-valores)
      - [Atajos de Opción](#atajos-de-opción)
    - [Arreglos de Entrada](#arreglos-de-entrada)
      - [Arreglos de Opción](#arreglos-de-opción)
    - [Descripciones de Entrada](#descripciones-de-entrada)
    - [Solicitar Entrada Faltante](#solicitar-entrada-faltante)
  - [Entrada/Salida del Comando](#entradasalida-del-comando)
    - [Recuperando Entrada](#recuperando-entrada)
    - [Solicitar Entrada](#solicitar-entrada)
      - [Solicitar Confirmación](#solicitar-confirmación)
      - [Autocompletado](#autocompletado)
      - [Preguntas de Opción Múltiple](#preguntas-de-opción-múltiple)
    - [Escribiendo Salida](#escribiendo-salida)
      - [Tablas](#tablas)
      - [Barras de Progreso](#barras-de-progreso)
  - [Registrando Comandos](#registrando-comandos)
  - [Ejecutando Comandos Programáticamente](#ejecutando-comandos-programáticamente)
      - [Pasando Valores de Array](#pasando-valores-de-array)
      - [Pasando Valores Booleanos](#pasando-valores-booleanos)
      - [Encolando Comandos de Artisan](#encolando-comandos-de-artisan)
    - [Llamando Comandos Desde Otros Comandos](#llamando-comandos-desde-otros-comandos)
  - [Manejo de Señales](#manejo-de-señales)
  - [Personalización de Stubs](#personalización-de-stubs)
  - [Eventos](#eventos)

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

Si estás usando [Laravel Sail](/docs/{{version}}/sail) como tu entorno de desarrollo local, recuerda usar la línea de comandos `sail` para invocar comandos de Artisan. Sail ejecutará tus comandos de Artisan dentro de los contenedores Docker de tu aplicación:

```shell
./vendor/bin/sail artisan list
```

<a name="tinker"></a>
### Tinker (REPL)

Laravel Tinker es un potente REPL para el framework Laravel, impulsado por el paquete [PsySH](https://github.com/bobthecow/psysh).

<a name="installation"></a>
#### Instalación

Todas las aplicaciones de Laravel incluyen Tinker por defecto. Sin embargo, puedes instalar Tinker usando Composer si lo has eliminado previamente de tu aplicación:

```shell
composer require laravel/tinker
```

> [!NOTE]  
> ¿Buscas recarga en caliente, edición de código en múltiples líneas y autocompletado al interactuar con tu aplicación Laravel? ¡Consulta [Tinkerwell](https://tinkerwell.app)!

<a name="usage"></a>
#### Uso

Tinker te permite interactuar con toda tu aplicación Laravel en la línea de comandos, incluyendo tus modelos Eloquent, trabajos, eventos y más. Para ingresar al entorno de Tinker, ejecuta el comando Artisan `tinker`:

```shell
php artisan tinker
```

Puedes publicar el archivo de configuración de Tinker usando el comando `vendor:publish`:

```shell
php artisan vendor:publish --provider="Laravel\Tinker\TinkerServiceProvider"
```

> [!WARNING]  
> La función auxiliar `dispatch` y el método `dispatch` en la clase `Dispatchable` dependen de la recolección de basura para colocar el trabajo en la cola. Por lo tanto, al usar tinker, deberías usar `Bus::dispatch` o `Queue::push` para despachar trabajos.

<a name="command-allow-list"></a>
#### Lista de Comandos Permitidos

Tinker utiliza una lista de "permitidos" para determinar qué comandos de Artisan pueden ejecutarse dentro de su shell. Por defecto, puedes ejecutar los comandos `clear-compiled`, `down`, `env`, `inspire`, `migrate`, `optimize` y `up`. Si deseas permitir más comandos, puedes agregarlos al arreglo `commands` en tu archivo de configuración `tinker.php`:

    'commands' => [
        // App\Console\Commands\ExampleCommand::class,
    ],

<a name="classes-that-should-not-be-aliased"></a>
#### Clases Que No Deben Ser Alias

Típicamente, Tinker automáticamente alias las clases a medida que interactúas con ellas en Tinker. Sin embargo, puedes desear no alias algunas clases. Puedes lograr esto listando las clases en el arreglo `dont_alias` de tu archivo de configuración `tinker.php`:

    'dont_alias' => [
        App\Models\User::class,
    ],

<a name="writing-commands"></a>
## Escribiendo Comandos

Además de los comandos proporcionados con Artisan, puedes construir tus propios comandos personalizados. Los comandos se almacenan típicamente en el directorio `app/Console/Commands`; sin embargo, eres libre de elegir tu propia ubicación de almacenamiento siempre que tus comandos puedan ser cargados por Composer.

<a name="generating-commands"></a>
### Generando Comandos

Para crear un nuevo comando, puedes usar el comando Artisan `make:command`. Este comando creará una nueva clase de comando en el directorio `app/Console/Commands`. No te preocupes si este directorio no existe en tu aplicación: se creará la primera vez que ejecutes el comando Artisan `make:command`:

```shell
php artisan make:command SendEmails
```

<a name="command-structure"></a>
### Estructura del Comando

Después de generar tu comando, debes definir valores apropiados para las propiedades `signature` y `description` de la clase. Estas propiedades se utilizarán al mostrar tu comando en la pantalla `list`. La propiedad `signature` también te permite definir [tus expectativas de entrada del comando](#defining-input-expectations). El método `handle` se llamará cuando se ejecute tu comando. Puedes colocar la lógica de tu comando en este método.

Veamos un ejemplo de comando. Ten en cuenta que podemos solicitar cualquier dependencia que necesitemos a través del método `handle` del comando. El [contenedor de servicios](#) de Laravel inyectará automáticamente todas las dependencias que estén tipadas en la firma de este método:

    <?php

    namespace App\Console\Commands;

    use App\Models\User;
    use App\Support\DripEmailer;
    use Illuminate\Console\Command;

    class SendEmails extends Command
    {
        /**
         * El nombre y la firma del comando de consola.
         *
         * @var string
         */
        protected $signature = 'mail:send {user}';

        /**
         * La descripción del comando de consola.
         *
         * @var string
         */
        protected $description = 'Enviar un correo electrónico de marketing a un usuario';

        /**
         * Ejecutar el comando de consola.
         */
        public function handle(DripEmailer $drip): void
        {
            $drip->send(User::find($this->argument('user')));
        }
    }

> [!NOTE]  
> Para una mayor reutilización del código, es una buena práctica mantener tus comandos de consola ligeros y permitir que se deleguen a los servicios de la aplicación para llevar a cabo sus tareas. En el ejemplo anterior, ten en cuenta que inyectamos una clase de servicio para hacer el "trabajo pesado" de enviar los correos electrónicos.

<a name="exit-codes"></a>
#### Códigos de Salida

Si no se devuelve nada del método `handle` y el comando se ejecuta correctamente, el comando saldrá con un código de salida `0`, indicando éxito. Sin embargo, el método `handle` puede devolver opcionalmente un entero para especificar manualmente el código de salida del comando:

    $this->error('Algo salió mal.');

    return 1;

Si deseas "fallar" el comando desde cualquier método dentro del comando, puedes utilizar el método `fail`. El método `fail` terminará inmediatamente la ejecución del comando y devolverá un código de salida de `1`:

    $this->fail('Algo salió mal.');

<a name="closure-commands"></a>
### Comandos de Función Anónima

Los comandos basados en funciones anónimas proporcionan una alternativa a la definición de comandos de consola como clases. De la misma manera que las funciones anónimas de rutas son una alternativa a los controladores, piensa en los comandos de funciones anónimas como una alternativa a las clases de comando.

Aunque el archivo `routes/console.php` no define rutas HTTP, define puntos de entrada basados en consola (rutas) en tu aplicación. Dentro de este archivo, puedes definir todos tus comandos de consola basados en funciones anónimas usando el método `Artisan::command`. El método `command` acepta dos argumentos: la [firma del comando](#defining-input-expectations) y una función anónima que recibe los argumentos y opciones del comando:

    Artisan::command('mail:send {user}', function (string $user) {
        $this->info("Enviando correo electrónico a: {$user}!");
    });

La función anónima está vinculada a la instancia del comando subyacente, por lo que tienes acceso completo a todos los métodos auxiliares a los que normalmente podrías acceder en una clase de comando completa.

<a name="type-hinting-dependencies"></a>
#### Tipado de Dependencias

Además de recibir los argumentos y opciones de tu comando, las funciones anónimas de comando también pueden tipar dependencias adicionales que te gustaría resolver del [contenedor de servicios](/docs/{{version}}/container):

    use App\Models\User;
    use App\Support\DripEmailer;

    Artisan::command('mail:send {user}', function (DripEmailer $drip, string $user) {
        $drip->send(User::find($user));
    });

<a name="closure-command-descriptions"></a>
#### Descripciones de Comandos de Función Anónima

Al definir un comando basado en función anónima, puedes usar el método `purpose` para agregar una descripción al comando. Esta descripción se mostrará cuando ejecutes los comandos `php artisan list` o `php artisan help`:

    Artisan::command('mail:send {user}', function (string $user) {
        // ...
    })->purpose('Enviar un correo electrónico de marketing a un usuario');

<a name="isolatable-commands"></a>
### Comandos Aislables

> [!WARNING]  
> Para utilizar esta función, tu aplicación debe estar usando el controlador de caché `memcached`, `redis`, `dynamodb`, `database`, `file` o `array` como el controlador de caché predeterminado de tu aplicación. Además, todos los servidores deben comunicarse con el mismo servidor de caché central.

A veces puedes desear asegurarte de que solo una instancia de un comando pueda ejecutarse a la vez. Para lograr esto, puedes implementar la interfaz `Illuminate\Contracts\Console\Isolatable` en tu clase de comando:

    <?php

    namespace App\Console\Commands;

    use Illuminate\Console\Command;
    use Illuminate\Contracts\Console\Isolatable;

    class SendEmails extends Command implements Isolatable
    {
        // ...
    }

Cuando un comando se marca como `Isolatable`, Laravel automáticamente agregará una opción `--isolated` al comando. Cuando el comando se invoca con esa opción, Laravel se asegurará de que no haya otras instancias de ese comando ya en ejecución. Laravel logra esto intentando adquirir un bloqueo atómico usando el controlador de caché predeterminado de tu aplicación. Si otras instancias del comando están en ejecución, el comando no se ejecutará; sin embargo, el comando aún saldrá con un código de estado de salida exitoso:

```shell
php artisan mail:send 1 --isolated
```

Si deseas especificar el código de estado de salida que el comando debería devolver si no puede ejecutarse, puedes proporcionar el código de estado deseado a través de la opción `isolated`:

```shell
php artisan mail:send 1 --isolated=12
```

<a name="lock-id"></a>
#### ID de Bloqueo

Por defecto, Laravel usará el nombre del comando para generar la clave de cadena que se utiliza para adquirir el bloqueo atómico en la caché de tu aplicación. Sin embargo, puedes personalizar esta clave definiendo un método `isolatableId` en tu clase de comando Artisan, lo que te permite integrar los argumentos o opciones del comando en la clave:

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
#### Tiempo de Expiración del Bloqueo

Por defecto, los bloqueos de aislamiento expiran después de que el comando ha terminado. O, si el comando se interrumpe y no puede terminar, el bloqueo expirará después de una hora. Sin embargo, puedes ajustar el tiempo de expiración del bloqueo definiendo un método `isolationLockExpiresAt` en tu comando:

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

Al escribir comandos de consola, es común recopilar entrada del usuario a través de argumentos u opciones. Laravel facilita mucho definir la entrada que esperas del usuario utilizando la propiedad `signature` en tus comandos. La propiedad `signature` te permite definir el nombre, los argumentos y las opciones para el comando en una única sintaxis expresiva, similar a una ruta.

<a name="arguments"></a>
### Argumentos

Todos los argumentos y opciones proporcionados por el usuario están envueltos en llaves. En el siguiente ejemplo, el comando define un argumento requerido: `user`:

    /**
     * El nombre y la firma del comando de consola.
     *
     * @var string
     */
    protected $signature = 'mail:send {user}';

También puedes hacer que los argumentos sean opcionales o definir valores predeterminados para los argumentos:

    // Argumento opcional...
    'mail:send {user?}'

    // Argumento opcional con valor predeterminado...
    'mail:send {user=foo}'

<a name="options"></a>
### Opciones

Las opciones, al igual que los argumentos, son otra forma de entrada del usuario. Las opciones están precedidas por dos guiones (`--`) cuando se proporcionan a través de la línea de comandos. Hay dos tipos de opciones: aquellas que reciben un valor y aquellas que no. Las opciones que no reciben un valor sirven como un "interruptor" booleano. Veamos un ejemplo de este tipo de opción:

    /**
     * El nombre y la firma del comando de consola.
     *
     * @var string
     */
    protected $signature = 'mail:send {user} {--queue}';

En este ejemplo, el interruptor `--queue` puede especificarse al llamar al comando Artisan. Si se pasa el interruptor `--queue`, el valor de la opción será `true`. De lo contrario, el valor será `false`:

```shell
php artisan mail:send 1 --queue
```

<a name="options-with-values"></a>
#### Opciones Con Valores

A continuación, veamos una opción que espera un valor. Si el usuario debe especificar un valor para una opción, debes agregar un signo `=` al final del nombre de la opción:

    /**
     * El nombre y la firma del comando de consola.
     *
     * @var string
     */
    protected $signature = 'mail:send {user} {--queue=}';

En este ejemplo, el usuario puede pasar un valor para la opción de la siguiente manera. Si la opción no se especifica al invocar el comando, su valor será `null`:

```shell
php artisan mail:send 1 --queue=default
```

Puedes asignar valores predeterminados a las opciones especificando el valor predeterminado después del nombre de la opción. Si no se pasa ningún valor de opción por el usuario, se utilizará el valor predeterminado:

    'mail:send {user} {--queue=default}'

<a name="option-shortcuts"></a>
#### Atajos de Opción

Para asignar un atajo al definir una opción, puedes especificarlo antes del nombre de la opción y usar el carácter `|` como delimitador para separar el atajo del nombre completo de la opción:

    'mail:send {user} {--Q|queue}'

Al invocar el comando en tu terminal, los atajos de opción deben estar precedidos por un solo guion y no se debe incluir ningún carácter `=` al especificar un valor para la opción:

```shell
php artisan mail:send 1 -Qdefault
```

<a name="input-arrays"></a>
### Arreglos de Entrada

Si deseas definir argumentos u opciones para esperar múltiples valores de entrada, puedes usar el carácter `*`. Primero, veamos un ejemplo que especifica tal argumento:

    'mail:send {user*}'

Al llamar a este método, los argumentos `user` pueden pasarse en orden a la línea de comandos. Por ejemplo, el siguiente comando establecerá el valor de `user` en un arreglo con `1` y `2` como sus valores:

```shell
php artisan mail:send 1 2
```

Este carácter `*` puede combinarse con una definición de argumento opcional para permitir cero o más instancias de un argumento:

    'mail:send {user?*}'

<a name="option-arrays"></a>
#### Arreglos de Opción

Al definir una opción que espera múltiples valores de entrada, cada valor de opción pasado al comando debe estar precedido por el nombre de la opción:

    'mail:send {--id=*}'

Tal comando puede ser invocado pasando múltiples argumentos `--id`:

```shell
php artisan mail:send --id=1 --id=2
```

<a name="input-descriptions"></a>
### Descripciones de Entrada

Puedes asignar descripciones a los argumentos y opciones de entrada separando el nombre del argumento de la descripción usando dos puntos. Si necesitas un poco más de espacio para definir tu comando, siéntete libre de extender la definición en múltiples líneas:

    /**
     * El nombre y la firma del comando de consola.
     *
     * @var string
     */
    protected $signature = 'mail:send
                            {user : El ID del usuario}
                            {--queue : Si el trabajo debe ser en cola}';

<a name="prompting-for-missing-input"></a>
### Solicitar Entrada Faltante

Si tu comando contiene argumentos requeridos, el usuario recibirá un mensaje de error cuando no se proporcionen. Alternativamente, puedes configurar tu comando para que solicite automáticamente al usuario cuando falten argumentos requeridos implementando la interfaz `PromptsForMissingInput`:

    <?php

    namespace App\Console\Commands;

    use Illuminate\Console\Command;
    use Illuminate\Contracts\Console\PromptsForMissingInput;

    class SendEmails extends Command implements PromptsForMissingInput
    {
        /**
         * El nombre y la firma del comando de consola.
         *
         * @var string
         */
        protected $signature = 'mail:send {user}';

        // ...
    }

Si Laravel necesita recopilar un argumento requerido del usuario, automáticamente le preguntará por el argumento formulando inteligentemente la pregunta usando el nombre o la descripción del argumento. Si deseas personalizar la pregunta utilizada para recopilar el argumento requerido, puedes implementar el método `promptForMissingArgumentsUsing`, devolviendo un array de preguntas indexadas por los nombres de los argumentos:

    /**
     * Solicitar argumentos de entrada faltantes usando las preguntas devueltas.
     *
     * @return array<string, string>
     */
    protected function promptForMissingArgumentsUsing(): array
    {
        return [
            'user' => '¿Qué ID de usuario debería recibir el correo?',
        ];
    }

También puedes proporcionar texto de marcador de posición usando una tupla que contenga la pregunta y el marcador de posición:

    return [
        'user' => ['¿Qué ID de usuario debería recibir el correo?', 'Ej. 123'],
    ];

Si deseas tener control total sobre el aviso, puedes proporcionar una función anónima que debería solicitar al usuario y devolver su respuesta:

    use App\Models\User;
    use function Laravel\Prompts\search;

    // ...

    return [
        'user' => fn () => search(
            label: 'Buscar un usuario:',
            placeholder: 'Ej. Taylor Otwell',
            options: fn ($value) => strlen($value) > 0
                ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
                : []
        ),
    ];

> [!NOTE]  
La documentación completa de [Laravel Prompts](/docs/{{version}}/prompts) incluye información adicional sobre los avisos disponibles y su uso.

Si deseas solicitar al usuario que seleccione o ingrese [opciones](#options), puedes incluir avisos en el método `handle` de tu comando. Sin embargo, si solo deseas solicitar al usuario cuando también se le haya solicitado automáticamente argumentos faltantes, entonces puedes implementar el método `afterPromptingForMissingArguments`:

    use Symfony\Component\Console\Input\InputInterface;
    use Symfony\Component\Console\Output\OutputInterface;
    use function Laravel\Prompts\confirm;

    // ...

    /**
     * Realizar acciones después de que se solicitó al usuario argumentos faltantes.
     */
    protected function afterPromptingForMissingArguments(InputInterface $input, OutputInterface $output): void
    {
        $input->setOption('queue', confirm(
            label: '¿Te gustaría poner el correo en cola?',
            default: $this->option('queue')
        ));
    }

<a name="command-io"></a>
## Entrada/Salida del Comando

<a name="retrieving-input"></a>
### Recuperando Entrada

Mientras tu comando se está ejecutando, probablemente necesitarás acceder a los valores de los argumentos y opciones aceptados por tu comando. Para hacerlo, puedes usar los métodos `argument` y `option`. Si un argumento u opción no existe, se devolverá `null`:

    /**
     * Ejecutar el comando de consola.
     */
    public function handle(): void
    {
        $userId = $this->argument('user');
    }

Si necesitas recuperar todos los argumentos como un `array`, llama al método `arguments`:

    $arguments = $this->arguments();

Las opciones se pueden recuperar tan fácilmente como los argumentos usando el método `option`. Para recuperar todas las opciones como un array, llama al método `options`:

    // Recuperar una opción específica...
    $queueName = $this->option('queue');

    // Recuperar todas las opciones como un array...
    $options = $this->options();

<a name="prompting-for-input"></a>
### Solicitar Entrada

> [!NOTE]  
> [Laravel Prompts](/docs/{{version}}/prompts) es un paquete PHP para agregar formularios hermosos y amigables al usuario a tus aplicaciones de línea de comandos, con características similares a las de un navegador, incluyendo texto de marcador de posición y validación.

Además de mostrar salida, también puedes pedir al usuario que proporcione entrada durante la ejecución de tu comando. El método `ask` solicitará al usuario con la pregunta dada, aceptará su entrada y luego devolverá la entrada del usuario a tu comando:

    /**
     * Ejecutar el comando de consola.
     */
    public function handle(): void
    {
        $name = $this->ask('¿Cuál es tu nombre?');

        // ...
    }

El método `ask` también acepta un segundo argumento opcional que especifica el valor predeterminado que debería devolverse si no se proporciona entrada del usuario:

    $name = $this->ask('¿Cuál es tu nombre?', 'Taylor');

El método `secret` es similar a `ask`, pero la entrada del usuario no será visible para ellos mientras escriben en la consola. Este método es útil al preguntar por información sensible como contraseñas:

    $password = $this->secret('¿Cuál es la contraseña?');

<a name="asking-for-confirmation"></a>
#### Solicitar Confirmación

Si necesitas preguntar al usuario por una simple confirmación de "sí o no", puedes usar el método `confirm`. Por defecto, este método devolverá `false`. Sin embargo, si el usuario ingresa `y` o `yes` en respuesta a la solicitud, el método devolverá `true`.

    if ($this->confirm('¿Deseas continuar?')) {
        // ...
    }

Si es necesario, puedes especificar que la solicitud de confirmación debería devolver `true` por defecto pasando `true` como segundo argumento al método `confirm`:

    if ($this->confirm('¿Deseas continuar?', true)) {
        // ...
    }

<a name="auto-completion"></a>
#### Autocompletado

El método `anticipate` se puede usar para proporcionar autocompletado para opciones posibles. El usuario aún puede proporcionar cualquier respuesta, independientemente de las sugerencias de autocompletado:

    $name = $this->anticipate('¿Cuál es tu nombre?', ['Taylor', 'Dayle']);

Alternativamente, puedes pasar una función anónima como segundo argumento al método `anticipate`. La función anónima se llamará cada vez que el usuario escriba un carácter de entrada. La función debe aceptar un parámetro de tipo string que contenga la entrada del usuario hasta ahora y devolver un array de opciones para autocompletado:

    $name = $this->anticipate('¿Cuál es tu dirección?', function (string $input) {
        // Devolver opciones de autocompletado...
    });

<a name="multiple-choice-questions"></a>
#### Preguntas de Opción Múltiple

Si necesitas dar al usuario un conjunto de opciones predefinidas al hacer una pregunta, puedes usar el método `choice`. Puedes establecer el índice del array del valor predeterminado que se devolverá si no se elige ninguna opción pasando el índice como tercer argumento al método:

    $name = $this->choice(
        '¿Cuál es tu nombre?',
        ['Taylor', 'Dayle'],
        $defaultIndex
    );

Además, el método `choice` acepta argumentos opcionales cuarto y quinto para determinar el número máximo de intentos para seleccionar una respuesta válida y si se permiten selecciones múltiples:

    $name = $this->choice(
        '¿Cuál es tu nombre?',
        ['Taylor', 'Dayle'],
        $defaultIndex,
        $maxAttempts = null,
        $allowMultipleSelections = false
    );

<a name="writing-output"></a>
### Escribiendo Salida

Para enviar salida a la consola, puedes usar los métodos `line`, `info`, `comment`, `question`, `warn` y `error`. Cada uno de estos métodos utilizará colores ANSI apropiados para su propósito. Por ejemplo, mostremos alguna información general al usuario. Típicamente, el método `info` se mostrará en la consola como texto de color verde:

    /**
     * Ejecutar el comando de consola.
     */
    public function handle(): void
    {
        // ...

        $this->info('¡El comando fue exitoso!');
    }

Para mostrar un mensaje de error, usa el método `error`. El texto del mensaje de error se muestra típicamente en rojo:

    $this->error('¡Algo salió mal!');

Puedes usar el método `line` para mostrar texto plano, sin color:

    $this->line('Mostrar esto en la pantalla');

Puedes usar el método `newLine` para mostrar una línea en blanco:

    // Escribir una sola línea en blanco...
    $this->newLine();

    // Escribir tres líneas en blanco...
    $this->newLine(3);

<a name="tables"></a>
#### Tablas

El método `table` facilita el formateo correcto de múltiples filas / columnas de datos. Todo lo que necesitas hacer es proporcionar los nombres de las columnas y los datos para la tabla y Laravel calculará automáticamente el ancho y la altura apropiados de la tabla para ti:

    use App\Models\User;

    $this->table(
        ['Nombre', 'Correo Electrónico'],
        User::all(['name', 'email'])->toArray()
    );

<a name="progress-bars"></a>
#### Barras de Progreso

Para tareas de larga duración, puede ser útil mostrar una barra de progreso que informe a los usuarios cuán completa está la tarea. Usando el método `withProgressBar`, Laravel mostrará una barra de progreso y avanzará su progreso por cada iteración sobre un valor iterable dado:

    use App\Models\User;

    $users = $this->withProgressBar(User::all(), function (User $user) {
        $this->performTask($user);
    });

A veces, puedes necesitar más control manual sobre cómo se avanza una barra de progreso. Primero, define el número total de pasos que el proceso iterará. Luego, avanza la barra de progreso después de procesar cada elemento:

    $users = App\Models\User::all();

    $bar = $this->output->createProgressBar(count($users));

    $bar->start();

    foreach ($users as $user) {
        $this->performTask($user);

        $bar->advance();
    }

    $bar->finish();

> [!NOTE]  
> Para opciones más avanzadas, consulta la [documentación del componente de Barra de Progreso de Symfony](https://symfony.com/doc/7.0/components/console/helpers/progressbar.html).

<a name="registering-commands"></a>
## Registrando Comandos

Por defecto, Laravel registra automáticamente todos los comandos dentro del directorio `app/Console/Commands`. Sin embargo, puedes instruir a Laravel para que escanee otros directorios en busca de comandos de Artisan usando el método `withCommands` en el archivo `bootstrap/app.php` de tu aplicación:

    ->withCommands([
        __DIR__.'/../app/Domain/Orders/Commands',
    ])

Si es necesario, también puedes registrar comandos manualmente proporcionando el nombre de la clase del comando al método `withCommands`:

    use App\Domain\Orders\Commands\SendEmails;

    ->withCommands([
        SendEmails::class,
    ])

Cuando Artisan se inicia, todos los comandos en tu aplicación serán resueltos por el [contenedor de servicios](/docs/{{version}}/container) y registrados con Artisan.

<a name="programmatically-executing-commands"></a>
## Ejecutando Comandos Programáticamente

A veces puedes desear ejecutar un comando de Artisan fuera de la CLI. Por ejemplo, puedes desear ejecutar un comando de Artisan desde una ruta o controlador. Puedes usar el método `call` en la fachada `Artisan` para lograr esto. El método `call` acepta ya sea el nombre de la firma del comando o el nombre de la clase como su primer argumento, y un array de parámetros del comando como el segundo argumento. Se devolverá el código de salida:

    use Illuminate\Support\Facades\Artisan;

    Route::post('/user/{user}/mail', function (string $user) {
        $exitCode = Artisan::call('mail:send', [
            'user' => $user, '--queue' => 'default'
        ]);

        // ...
    });

Alternativamente, puedes pasar todo el comando de Artisan al método `call` como una cadena:

    Artisan::call('mail:send 1 --queue=default');

<a name="passing-array-values"></a>
#### Pasando Valores de Array

Si tu comando define una opción que acepta un array, puedes pasar un array de valores a esa opción:

    use Illuminate\Support\Facades\Artisan;

    Route::post('/mail', function () {
        $exitCode = Artisan::call('mail:send', [
            '--id' => [5, 13]
        ]);
    });

<a name="passing-boolean-values"></a>
#### Pasando Valores Booleanos

Si necesitas especificar el valor de una opción que no acepta valores de cadena, como el flag `--force` en el comando `migrate:refresh`, deberías pasar `true` o `false` como el valor de la opción:

    $exitCode = Artisan::call('migrate:refresh', [
        '--force' => true,
    ]);

<a name="queueing-artisan-commands"></a>
#### Encolando Comandos de Artisan

Usando el método `queue` en la fachada `Artisan`, incluso puedes encolar comandos de Artisan para que sean procesados en segundo plano por tus [trabajadores de cola](/docs/{{version}}/queues). Antes de usar este método, asegúrate de haber configurado tu cola y de estar ejecutando un oyente de cola:

    use Illuminate\Support\Facades\Artisan;

    Route::post('/user/{user}/mail', function (string $user) {
        Artisan::queue('mail:send', [
            'user' => $user, '--queue' => 'default'
        ]);

        // ...
    });

Usando los métodos `onConnection` y `onQueue`, puedes especificar la conexión o cola a la que se debe enviar el comando de Artisan:

    Artisan::queue('mail:send', [
        'user' => 1, '--queue' => 'default'
    ])->onConnection('redis')->onQueue('commands');

<a name="calling-commands-from-other-commands"></a>
### Llamando Comandos Desde Otros Comandos

A veces puedes desear llamar a otros comandos desde un comando de Artisan existente. Puedes hacerlo usando el método `call`. Este método `call` acepta el nombre del comando y un array de argumentos / opciones del comando:

    /**
     * Ejecutar el comando de consola.
     */
    public function handle(): void
    {
        $this->call('mail:send', [
            'user' => 1, '--queue' => 'default'
        ]);

        // ...
    }

Si deseas llamar a otro comando de consola y suprimir toda su salida, puedes usar el método `callSilently`. El método `callSilently` tiene la misma firma que el método `call`:

    $this->callSilently('mail:send', [
        'user' => 1, '--queue' => 'default'
    ]);

<a name="signal-handling"></a>
## Manejo de Señales

Como sabes, los sistemas operativos permiten que se envíen señales a procesos en ejecución. Por ejemplo, la señal `SIGTERM` es cómo los sistemas operativos piden a un programa que termine. Si deseas escuchar señales en tus comandos de consola de Artisan y ejecutar código cuando ocurren, puedes usar el método `trap`:

    /**
     * Ejecutar el comando de consola.
     */
    public function handle(): void
    {
        $this->trap(SIGTERM, fn () => $this->shouldKeepRunning = false);

        while ($this->shouldKeepRunning) {
            // ...
        }
    }

Para escuchar múltiples señales a la vez, puedes proporcionar un array de señales al método `trap`:

```php
$this->trap([SIGTERM, SIGQUIT], function (int $signal) {
    $this->shouldKeepRunning = false;

    dump($signal); // SIGTERM / SIGQUIT
});
```

<a name="stub-customization"></a>
## Personalización de Stubs

Los comandos `make` de la consola Artisan se utilizan para crear una variedad de clases, como controladores, trabajos, migraciones y pruebas. Estas clases se generan utilizando archivos "stub" que se completan con valores basados en su entrada. Sin embargo, es posible que desee realizar pequeños cambios en los archivos generados por Artisan. Para lograr esto, puede usar el comando `stub:publish` para publicar los stubs más comunes en su aplicación para que pueda personalizarlos:

```shell
php artisan stub:publish
```

Los stubs publicados se ubicarán dentro de un directorio `stubs` en la raíz de su aplicación. Cualquier cambio que realice en estos stubs se reflejará cuando genere sus clases correspondientes utilizando los comandos `make` de Artisan.

<a name="events"></a>
## Eventos

Artisan despacha tres eventos al ejecutar comandos: `Illuminate\Console\Events\ArtisanStarting`, `Illuminate\Console\Events\CommandStarting` y `Illuminate\Console\Events\CommandFinished`. El evento `ArtisanStarting` se despacha inmediatamente cuando Artisan comienza a ejecutarse. A continuación, el evento `CommandStarting` se despacha inmediatamente antes de que se ejecute un comando. Finalmente, el evento `CommandFinished` se despacha una vez que un comando ha terminado de ejecutarse.
