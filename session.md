# HTTP Session

- [Introducción](#introduction)
    - [Configuración](#configuration)
    - [Requisitos Previos del Controlador](#driver-prerequisites)
- [Interacción con la Sesión](#interacting-with-the-session)
    - [Recuperando Datos](#retrieving-data)
    - [Almacenando Datos](#storing-data)
    - [Datos Flash](#flash-data)
    - [Eliminando Datos](#deleting-data)
    - [Regenerando el ID de la Sesión](#regenerating-the-session-id)
- [Bloqueo de Sesión](#session-blocking)
- [Añadiendo Controladores de Sesión Personalizados](#adding-custom-session-drivers)
    - [Implementando el Controlador](#implementing-the-driver)
    - [Registrando el Controlador](#registering-the-driver)

<a name="introduction"></a>
## Introducción

Dado que las aplicaciones impulsadas por HTTP son sin estado, las sesiones proporcionan una forma de almacenar información sobre el usuario a través de múltiples solicitudes. Esa información del usuario se coloca típicamente en un almacenamiento persistente / backend que puede ser accedido desde solicitudes posteriores.

Laravel incluye una variedad de backends de sesión que se acceden a través de una API unificada y expresiva. Se incluye soporte para backends populares como [Memcached](https://memcached.org), [Redis](https://redis.io) y bases de datos.

<a name="configuration"></a>
### Configuración

El archivo de configuración de sesión de tu aplicación se almacena en `config/session.php`. Asegúrate de revisar las opciones disponibles en este archivo. Por defecto, Laravel está configurado para usar el controlador de sesión `database`.

La opción de configuración `driver` de la sesión define dónde se almacenarán los datos de la sesión para cada solicitud. Laravel incluye una variedad de controladores:

<div class="content-list" markdown="1">

- `file` - las sesiones se almacenan en `storage/framework/sessions`.
- `cookie` - las sesiones se almacenan en cookies seguras y encriptadas.
- `database` - las sesiones se almacenan en una base de datos relacional.
- `memcached` / `redis` - las sesiones se almacenan en uno de estos rápidos almacenes basados en caché.
- `dynamodb` - las sesiones se almacenan en AWS DynamoDB.
- `array` - las sesiones se almacenan en un array de PHP y no serán persistidas.

</div>

> [!NOTE]  
> El controlador de array se utiliza principalmente durante [pruebas](/docs/{{version}}/testing) y evita que los datos almacenados en la sesión sean persistidos.

<a name="driver-prerequisites"></a>
### Requisitos Previos del Controlador

<a name="database"></a>
#### Base de Datos

Al usar el controlador de sesión `database`, necesitarás asegurarte de que tienes una tabla de base de datos para contener los datos de la sesión. Típicamente, esto se incluye en la migración de base de datos predeterminada de Laravel `0001_01_01_000000_create_users_table.php` [migración de base de datos](/docs/{{version}}/migrations); sin embargo, si por alguna razón no tienes una tabla `sessions`, puedes usar el comando Artisan `make:session-table` para generar esta migración:

```shell
php artisan make:session-table

php artisan migrate
```

<a name="redis"></a>
#### Redis

Antes de usar sesiones de Redis con Laravel, necesitarás instalar la extensión PHP PhpRedis a través de PECL o instalar el paquete `predis/predis` (~1.0) a través de Composer. Para más información sobre cómo configurar Redis, consulta la [documentación de Redis](/docs/{{version}}/redis#configuration) de Laravel.

> [!NOTE]  
> La variable de entorno `SESSION_CONNECTION`, o la opción `connection` en el archivo de configuración `session.php`, puede ser utilizada para especificar qué conexión de Redis se utiliza para el almacenamiento de sesiones.

<a name="interacting-with-the-session"></a>
## Interacción con la Sesión

<a name="retrieving-data"></a>
### Recuperando Datos

Hay dos formas principales de trabajar con los datos de la sesión en Laravel: el helper global `session` y a través de una instancia de `Request`. Primero, veamos cómo acceder a la sesión a través de una instancia de `Request`, que puede ser tipificada en una función anónima de ruta o método de controlador. Recuerda, las dependencias del método del controlador se inyectan automáticamente a través del [contenedor de servicios](/docs/{{version}}/container) de Laravel:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\Request;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * Muestra el perfil del usuario dado.
         */
        public function show(Request $request, string $id): View
        {
            $value = $request->session()->get('key');

            // ...

            $user = $this->users->find($id);

            return view('user.profile', ['user' => $user]);
        }
    }

Cuando recuperas un elemento de la sesión, también puedes pasar un valor predeterminado como segundo argumento al método `get`. Este valor predeterminado será devuelto si la clave especificada no existe en la sesión. Si pasas una función anónima como valor predeterminado al método `get` y la clave solicitada no existe, la función anónima será ejecutada y su resultado será devuelto:

    $value = $request->session()->get('key', 'default');

    $value = $request->session()->get('key', function () {
        return 'default';
    });

<a name="the-global-session-helper"></a>
#### El Helper Global de Sesión

También puedes usar la función PHP global `session` para recuperar y almacenar datos en la sesión. Cuando el helper `session` es llamado con un solo argumento de tipo string, devolverá el valor de esa clave de sesión. Cuando el helper es llamado con un array de pares clave / valor, esos valores serán almacenados en la sesión:

    Route::get('/home', function () {
        // Recuperar un dato de la sesión...
        $value = session('key');

        // Especificando un valor predeterminado...
        $value = session('key', 'default');

        // Almacenar un dato en la sesión...
        session(['key' => 'value']);
    });

> [!NOTE]  
> Hay poca diferencia práctica entre usar la sesión a través de una instancia de solicitud HTTP y usar el helper global `session`. Ambos métodos son [probables de prueba](/docs/{{version}}/testing) a través del método `assertSessionHas` que está disponible en todos tus casos de prueba.

<a name="retrieving-all-session-data"></a>
#### Recuperando Todos los Datos de la Sesión

Si deseas recuperar todos los datos en la sesión, puedes usar el método `all`:

    $data = $request->session()->all();

<a name="retrieving-a-portion-of-the-session-data"></a>
#### Recuperando una Porción de los Datos de la Sesión

Los métodos `only` y `except` pueden ser utilizados para recuperar un subconjunto de los datos de la sesión:

    $data = $request->session()->only(['username', 'email']);

    $data = $request->session()->except(['username', 'email']);

<a name="determining-if-an-item-exists-in-the-session"></a>
#### Determinando si un Elemento Existe en la Sesión

Para determinar si un elemento está presente en la sesión, puedes usar el método `has`. El método `has` devuelve `true` si el elemento está presente y no es `null`:

    if ($request->session()->has('users')) {
        // ...
    }

Para determinar si un elemento está presente en la sesión, incluso si su valor es `null`, puedes usar el método `exists`:

    if ($request->session()->exists('users')) {
        // ...
    }

Para determinar si un elemento no está presente en la sesión, puedes usar el método `missing`. El método `missing` devuelve `true` si el elemento no está presente:

    if ($request->session()->missing('users')) {
        // ...
    }

<a name="storing-data"></a>
### Almacenando Datos

Para almacenar datos en la sesión, normalmente usarás el método `put` de la instancia de solicitud o el helper global `session`:

    // A través de una instancia de solicitud...
    $request->session()->put('key', 'value');

    // A través del helper global "session"...
    session(['key' => 'value']);

<a name="pushing-to-array-session-values"></a>
#### Agregando a los Valores de Sesión de Array

El método `push` puede ser utilizado para agregar un nuevo valor a un valor de sesión que es un array. Por ejemplo, si la clave `user.teams` contiene un array de nombres de equipos, puedes agregar un nuevo valor al array de la siguiente manera:

    $request->session()->push('user.teams', 'developers');

<a name="retrieving-deleting-an-item"></a>
#### Recuperando y Eliminando un Elemento

El método `pull` recuperará y eliminará un elemento de la sesión en una sola declaración:

    $value = $request->session()->pull('key', 'default');

<a name="#incrementing-and-decrementing-session-values"></a>
#### Incrementando y Decrementando Valores de Sesión

Si tus datos de sesión contienen un entero que deseas incrementar o decrementar, puedes usar los métodos `increment` y `decrement`:

    $request->session()->increment('count');

    $request->session()->increment('count', $incrementBy = 2);

    $request->session()->decrement('count');

    $request->session()->decrement('count', $decrementBy = 2);

<a name="flash-data"></a>
### Datos Flash

A veces puedes desear almacenar elementos en la sesión para la siguiente solicitud. Puedes hacerlo usando el método `flash`. Los datos almacenados en la sesión usando este método estarán disponibles inmediatamente y durante la siguiente solicitud HTTP. Después de la siguiente solicitud HTTP, los datos flash serán eliminados. Los datos flash son principalmente útiles para mensajes de estado de corta duración:

    $request->session()->flash('status', '¡La tarea fue exitosa!');

Si necesitas persistir tus datos flash durante varias solicitudes, puedes usar el método `reflash`, que mantendrá todos los datos flash durante una solicitud adicional. Si solo necesitas mantener datos flash específicos, puedes usar el método `keep`:

    $request->session()->reflash();

    $request->session()->keep(['username', 'email']);

Para persistir tus datos flash solo para la solicitud actual, puedes usar el método `now`:

    $request->session()->now('status', '¡La tarea fue exitosa!');

<a name="deleting-data"></a>
### Eliminando Datos

El método `forget` eliminará un dato de la sesión. Si deseas eliminar todos los datos de la sesión, puedes usar el método `flush`:

    // Olvidar una sola clave...
    $request->session()->forget('name');

    // Olvidar múltiples claves...
    $request->session()->forget(['name', 'status']);

    $request->session()->flush();

<a name="regenerating-the-session-id"></a>
### Regenerando el ID de la Sesión

Regenerar el ID de la sesión se hace a menudo para prevenir que usuarios maliciosos exploten un ataque de [fijación de sesión](https://owasp.org/www-community/attacks/Session_fixation) en tu aplicación.

Laravel regenera automáticamente el ID de la sesión durante la autenticación si estás usando uno de los [kits de inicio de aplicación](/docs/{{version}}/starter-kits) de Laravel o [Laravel Fortify](/docs/{{version}}/fortify); sin embargo, si necesitas regenerar manualmente el ID de la sesión, puedes usar el método `regenerate`:

    $request->session()->regenerate();

Si necesitas regenerar el ID de la sesión y eliminar todos los datos de la sesión en una sola declaración, puedes usar el método `invalidate`:

    $request->session()->invalidate();

<a name="session-blocking"></a>
## Bloqueo de Sesión

> [!WARNING]  
> Para utilizar el bloqueo de sesión, tu aplicación debe estar usando un controlador de caché que soporte [bloqueos atómicos](/docs/{{version}}/cache#atomic-locks). Actualmente, esos controladores de caché incluyen los controladores `memcached`, `dynamodb`, `redis`, `database`, `file` y `array`. Además, no puedes usar el controlador de sesión `cookie`.

Por defecto, Laravel permite que las solicitudes que utilizan la misma sesión se ejecuten de manera concurrente. Así que, por ejemplo, si usas una biblioteca HTTP de JavaScript para hacer dos solicitudes HTTP a tu aplicación, ambas se ejecutarán al mismo tiempo. Para muchas aplicaciones, esto no es un problema; sin embargo, la pérdida de datos de sesión puede ocurrir en un pequeño subconjunto de aplicaciones que hacen solicitudes concurrentes a dos diferentes puntos finales de la aplicación que ambos escriben datos en la sesión.

Para mitigar esto, Laravel proporciona funcionalidad que te permite limitar las solicitudes concurrentes para una sesión dada. Para comenzar, simplemente puedes encadenar el método `block` a tu definición de ruta. En este ejemplo, una solicitud entrante al punto final `/profile` adquiriría un bloqueo de sesión. Mientras este bloqueo esté en vigor, cualquier solicitud entrante a los puntos finales `/profile` o `/order` que compartan el mismo ID de sesión esperarán a que la primera solicitud termine de ejecutarse antes de continuar su ejecución:

    Route::post('/profile', function () {
        // ...
    })->block($lockSeconds = 10, $waitSeconds = 10)

    Route::post('/order', function () {
        // ...
    })->block($lockSeconds = 10, $waitSeconds = 10)

El método `block` acepta dos argumentos opcionales. El primer argumento aceptado por el método `block` es el número máximo de segundos que el bloqueo de sesión debe ser mantenido antes de ser liberado. Por supuesto, si la solicitud termina de ejecutarse antes de este tiempo, el bloqueo será liberado antes.

El segundo argumento aceptado por el método `block` es el número de segundos que una solicitud debe esperar mientras intenta obtener un bloqueo de sesión. Se lanzará una `Illuminate\Contracts\Cache\LockTimeoutException` si la solicitud no puede obtener un bloqueo de sesión dentro del número dado de segundos.

Si ninguno de estos argumentos es pasado, el bloqueo se obtendrá por un máximo de 10 segundos y las solicitudes esperarán un máximo de 10 segundos mientras intentan obtener un bloqueo:

    Route::post('/profile', function () {
        // ...
    })->block()

<a name="adding-custom-session-drivers"></a>
## Añadiendo Controladores de Sesión Personalizados

<a name="implementing-the-driver"></a>
### Implementando el Controlador

Si ninguno de los controladores de sesión existentes se ajusta a las necesidades de tu aplicación, Laravel permite escribir tu propio manejador de sesión. Tu controlador de sesión personalizado debe implementar la `SessionHandlerInterface` incorporada de PHP. Esta interfaz contiene solo unos pocos métodos simples. Una implementación de MongoDB esbozada se ve como sigue:

    <?php

    namespace App\Extensions;

    class MongoSessionHandler implements \SessionHandlerInterface
    {
        public function open($savePath, $sessionName) {}
        public function close() {}
        public function read($sessionId) {}
        public function write($sessionId, $data) {}
        public function destroy($sessionId) {}
        public function gc($lifetime) {}
    }

> [!NOTE]  
> Laravel no incluye un directorio para contener tus extensiones. Eres libre de colocarlas donde desees. En este ejemplo, hemos creado un directorio `Extensions` para albergar el `MongoSessionHandler`.

Dado que el propósito de estos métodos no es fácilmente comprensible, cubramos rápidamente lo que hace cada uno de los métodos:

<div class="content-list" markdown="1">

- El método `open` se utilizaría típicamente en sistemas de almacenamiento de sesión basados en archivos. Dado que Laravel incluye un controlador de sesión `file`, rara vez necesitarás poner algo en este método. Puedes simplemente dejar este método vacío.
- El método `close`, al igual que el método `open`, también puede ser generalmente ignorado. Para la mayoría de los controladores, no es necesario.
- El método `read` debe devolver la versión en string de los datos de la sesión asociados con el `$sessionId` dado. No es necesario realizar ninguna serialización u otra codificación al recuperar o almacenar datos de sesión en tu controlador, ya que Laravel realizará la serialización por ti.
- El método `write` debe escribir el string `$data` dado asociado con el `$sessionId` en algún sistema de almacenamiento persistente, como MongoDB u otro sistema de almacenamiento de tu elección. Nuevamente, no debes realizar ninguna serialización: Laravel ya se habrá encargado de eso por ti.
- El método `destroy` debe eliminar los datos asociados con el `$sessionId` del almacenamiento persistente.
- El método `gc` debe destruir todos los datos de sesión que sean más antiguos que el `$lifetime` dado, que es un timestamp UNIX. Para sistemas de auto-expiración como Memcached y Redis, este método puede dejarse vacío.

</div>

<a name="registering-the-driver"></a>
### Registrando el Controlador

Una vez que tu controlador ha sido implementado, estás listo para registrarlo con Laravel. Para agregar controladores adicionales al backend de sesión de Laravel, puedes usar el método `extend` proporcionado por el `Session` [facade](/docs/{{version}}/facades). Debes llamar al método `extend` desde el método `boot` de un [service provider](/docs/{{version}}/providers). Puedes hacer esto desde el existente `App\Providers\AppServiceProvider` o crear un proveedor completamente nuevo:

    <?php

    namespace App\Providers;

    use App\Extensions\MongoSessionHandler;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Support\Facades\Session;
    use Illuminate\Support\ServiceProvider;

    class SessionServiceProvider extends ServiceProvider
    {
        /**
         * Register any application services.
         */
        public function register(): void
        {
            // ...
        }

        /**
         * Bootstrap any application services.
         */
        public function boot(): void
        {
            Session::extend('mongo', function (Application $app) {
                // Return an implementation of SessionHandlerInterface...
                return new MongoSessionHandler;
            });
        }
    }

Una vez que el controlador de sesión ha sido registrado, puedes especificar el controlador `mongo` como el controlador de sesión de tu aplicación utilizando la variable de entorno `SESSION_DRIVER` o dentro del archivo de configuración `config/session.php` de la aplicación.
