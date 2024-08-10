# Base de Datos: Introducción

- [Introducción](#introduction)
    - [Configuración](#configuration)
    - [Conexiones de Lectura y Escritura](#read-and-write-connections)
- [Ejecutando Consultas SQL](#running-queries)
    - [Usando Múltiples Conexiones de Base de Datos](#using-multiple-database-connections)
    - [Escuchando Eventos de Consultas](#listening-for-query-events)
    - [Monitoreando el Tiempo de Consulta Acumulado](#monitoring-cumulative-query-time)
- [Transacciones de Base de Datos](#database-transactions)
- [Conectando a la CLI de la Base de Datos](#connecting-to-the-database-cli)
- [Inspeccionando Tus Bases de Datos](#inspecting-your-databases)
- [Monitoreando Tus Bases de Datos](#monitoring-your-databases)

<a name="introduction"></a>
## Introducción

Casi todas las aplicaciones web modernas interactúan con una base de datos. Laravel hace que interactuar con bases de datos sea extremadamente simple a través de una variedad de bases de datos soportadas utilizando SQL en bruto, un [constructor de consultas fluido](/docs/{{version}}/queries), y el [Eloquent ORM](/docs/{{version}}/eloquent). Actualmente, Laravel proporciona soporte de primera parte para cinco bases de datos:

<div class="content-list" markdown="1">

- MariaDB 10.3+ ([Política de Versiones](https://mariadb.org/about/#maintenance-policy))
- MySQL 5.7+ ([Política de Versiones](https://en.wikipedia.org/wiki/MySQL#Release_history))
- PostgreSQL 10.0+ ([Política de Versiones](https://www.postgresql.org/support/versioning/))
- SQLite 3.26.0+
- SQL Server 2017+ ([Política de Versiones](https://docs.microsoft.com/en-us/lifecycle/products/?products=sql-server))

</div>

<a name="configuration"></a>
### Configuración

La configuración para los servicios de base de datos de Laravel se encuentra en el archivo de configuración `config/database.php` de tu aplicación. En este archivo, puedes definir todas tus conexiones de base de datos, así como especificar qué conexión debe ser utilizada por defecto. La mayoría de las opciones de configuración dentro de este archivo están impulsadas por los valores de las variables de entorno de tu aplicación. Se proporcionan ejemplos para la mayoría de los sistemas de base de datos soportados por Laravel en este archivo.

Por defecto, la muestra de [configuración de entorno](/docs/{{version}}/configuration#environment-configuration) de Laravel está lista para usarse con [Laravel Sail](/docs/{{version}}/sail), que es una configuración de Docker para desarrollar aplicaciones Laravel en tu máquina local. Sin embargo, eres libre de modificar tu configuración de base de datos según sea necesario para tu base de datos local.

<a name="sqlite-configuration"></a>
#### Configuración de SQLite

Las bases de datos SQLite se encuentran dentro de un solo archivo en tu sistema de archivos. Puedes crear una nueva base de datos SQLite usando el comando `touch` en tu terminal: `touch database/database.sqlite`. Después de que la base de datos ha sido creada, puedes configurar fácilmente tus variables de entorno para apuntar a esta base de datos colocando la ruta absoluta a la base de datos en la variable de entorno `DB_DATABASE`:

```ini
DB_CONNECTION=sqlite
DB_DATABASE=/absolute/path/to/database.sqlite
```

Por defecto, las restricciones de clave foránea están habilitadas para las conexiones SQLite. Si deseas desactivarlas, debes establecer la variable de entorno `DB_FOREIGN_KEYS` en `false`:

```ini
DB_FOREIGN_KEYS=false
```

> [!NOTE]  
> Si utilizas el [instalador de Laravel](/docs/{{version}}/installation#creating-a-laravel-project) para crear tu aplicación Laravel y seleccionas SQLite como tu base de datos, Laravel creará automáticamente un archivo `database/database.sqlite` y ejecutará las [migraciones de base de datos](/docs/{{version}}/migrations) por defecto para ti.

<a name="mssql-configuration"></a>
#### Configuración de Microsoft SQL Server

Para usar una base de datos de Microsoft SQL Server, debes asegurarte de que tienes instaladas las extensiones PHP `sqlsrv` y `pdo_sqlsrv`, así como cualquier dependencia que puedan requerir, como el controlador ODBC de Microsoft SQL.

<a name="configuration-using-urls"></a>
#### Configuración Usando URLs

Típicamente, las conexiones de base de datos se configuran usando múltiples valores de configuración como `host`, `database`, `username`, `password`, etc. Cada uno de estos valores de configuración tiene su propia variable de entorno correspondiente. Esto significa que al configurar la información de conexión de tu base de datos en un servidor de producción, necesitas gestionar varias variables de entorno.

Algunos proveedores de bases de datos gestionadas como AWS y Heroku proporcionan una única "URL" de base de datos que contiene toda la información de conexión para la base de datos en una sola cadena. Un ejemplo de URL de base de datos puede verse algo así:

```html
mysql://root:password@127.0.0.1/forge?charset=UTF-8
```

Estas URLs típicamente siguen una convención de esquema estándar:

```html
driver://username:password@host:port/database?options
```

Para conveniencia, Laravel soporta estas URLs como una alternativa a configurar tu base de datos con múltiples opciones de configuración. Si la opción de configuración `url` (o la correspondiente variable de entorno `DB_URL`) está presente, se utilizará para extraer la información de conexión y credenciales de la base de datos.

<a name="read-and-write-connections"></a>
### Conexiones de Lectura y Escritura

A veces puedes desear usar una conexión de base de datos para las declaraciones SELECT, y otra para las declaraciones INSERT, UPDATE y DELETE. Laravel hace que esto sea muy fácil, y las conexiones adecuadas siempre se utilizarán ya sea que estés usando consultas en bruto, el constructor de consultas, o el Eloquent ORM.

Para ver cómo deben configurarse las conexiones de lectura/escritura, veamos este ejemplo:

    'mysql' => [
        'read' => [
            'host' => [
                '192.168.1.1',
                '196.168.1.2',
            ],
        ],
        'write' => [
            'host' => [
                '196.168.1.3',
            ],
        ],
        'sticky' => true,

        'database' => env('DB_DATABASE', 'laravel'),
        'username' => env('DB_USERNAME', 'root'),
        'password' => env('DB_PASSWORD', ''),
        'unix_socket' => env('DB_SOCKET', ''),
        'charset' => env('DB_CHARSET', 'utf8mb4'),
        'collation' => env('DB_COLLATION', 'utf8mb4_unicode_ci'),
        'prefix' => '',
        'prefix_indexes' => true,
        'strict' => true,
        'engine' => null,
        'options' => extension_loaded('pdo_mysql') ? array_filter([
            PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
        ]) : [],
    ],

Ten en cuenta que se han agregado tres claves al arreglo de configuración: `read`, `write` y `sticky`. Las claves `read` y `write` tienen valores de arreglo que contienen una única clave: `host`. El resto de las opciones de base de datos para las conexiones `read` y `write` se fusionarán desde el arreglo de configuración principal `mysql`.

Solo necesitas colocar elementos en los arreglos `read` y `write` si deseas sobrescribir los valores del arreglo principal `mysql`. Así que, en este caso, `192.168.1.1` se utilizará como el host para la conexión "read", mientras que `192.168.1.3` se utilizará para la conexión "write". Las credenciales de la base de datos, el prefijo, el conjunto de caracteres y todas las demás opciones en el arreglo principal `mysql` se compartirán entre ambas conexiones. Cuando existen múltiples valores en el arreglo de configuración `host`, se elegirá aleatoriamente un host de base de datos para cada solicitud.

<a name="the-sticky-option"></a>
#### La Opción `sticky`

La opción `sticky` es un valor *opcional* que se puede utilizar para permitir la lectura inmediata de registros que han sido escritos en la base de datos durante el ciclo de solicitud actual. Si la opción `sticky` está habilitada y se ha realizado una operación de "escritura" en la base de datos durante el ciclo de solicitud actual, cualquier operación de "lectura" posterior utilizará la conexión "write". Esto asegura que cualquier dato escrito durante el ciclo de solicitud pueda ser leído inmediatamente desde la base de datos durante esa misma solicitud. Depende de ti decidir si este es el comportamiento deseado para tu aplicación.

<a name="running-queries"></a>
## Ejecutando Consultas SQL

Una vez que hayas configurado tu conexión de base de datos, puedes ejecutar consultas usando la fachada `DB`. La fachada `DB` proporciona métodos para cada tipo de consulta: `select`, `update`, `insert`, `delete`, y `statement`.

<a name="running-a-select-query"></a>
#### Ejecutando una Consulta SELECT

Para ejecutar una consulta SELECT básica, puedes usar el método `select` en la fachada `DB`:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Support\Facades\DB;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * Mostrar una lista de todos los usuarios de la aplicación.
         */
        public function index(): View
        {
            $users = DB::select('select * from users where active = ?', [1]);

            return view('user.index', ['users' => $users]);
        }
    }

El primer argumento pasado al método `select` es la consulta SQL, mientras que el segundo argumento son los enlaces de parámetros que necesitan ser vinculados a la consulta. Típicamente, estos son los valores de las restricciones de la cláusula `where`. El enlace de parámetros proporciona protección contra inyecciones SQL.

El método `select` siempre devolverá un `array` de resultados. Cada resultado dentro del arreglo será un objeto `stdClass` de PHP que representa un registro de la base de datos:

    use Illuminate\Support\Facades\DB;

    $users = DB::select('select * from users');

    foreach ($users as $user) {
        echo $user->name;
    }

<a name="selecting-scalar-values"></a>
#### Seleccionando Valores Escalares

A veces tu consulta de base de datos puede resultar en un único valor escalar. En lugar de tener que recuperar el resultado escalar de la consulta desde un objeto de registro, Laravel te permite recuperar este valor directamente usando el método `scalar`:

    $burgers = DB::scalar(
        "select count(case when food = 'burger' then 1 end) as burgers from menu"
    );

<a name="selecting-multiple-result-sets"></a>
#### Seleccionando Múltiples Conjuntos de Resultados

Si tu aplicación llama a procedimientos almacenados que devuelven múltiples conjuntos de resultados, puedes usar el método `selectResultSets` para recuperar todos los conjuntos de resultados devueltos por el procedimiento almacenado:

    [$options, $notifications] = DB::selectResultSets(
        "CALL get_user_options_and_notifications(?)", $request->user()->id
    );

<a name="using-named-bindings"></a>
#### Usando Enlaces Nombrados

En lugar de usar `?` para representar tus enlaces de parámetros, puedes ejecutar una consulta usando enlaces nombrados:

    $results = DB::select('select * from users where id = :id', ['id' => 1]);

<a name="running-an-insert-statement"></a>
#### Ejecutando una Declaración INSERT

Para ejecutar una declaración `insert`, puedes usar el método `insert` en la fachada `DB`. Al igual que `select`, este método acepta la consulta SQL como su primer argumento y los enlaces como su segundo argumento:

    use Illuminate\Support\Facades\DB;

    DB::insert('insert into users (id, name) values (?, ?)', [1, 'Marc']);

<a name="running-an-update-statement"></a>
#### Ejecutando una Declaración UPDATE

El método `update` debe ser utilizado para actualizar registros existentes en la base de datos. El número de filas afectadas por la declaración es devuelto por el método:

    use Illuminate\Support\Facades\DB;

    $affected = DB::update(
        'update users set votes = 100 where name = ?',
        ['Anita']
    );

<a name="running-a-delete-statement"></a>
#### Ejecutando una Declaración DELETE

El método `delete` debe ser utilizado para eliminar registros de la base de datos. Al igual que `update`, el número de filas afectadas será devuelto por el método:

    use Illuminate\Support\Facades\DB;

    $deleted = DB::delete('delete from users');

<a name="running-a-general-statement"></a>
#### Ejecutando una Declaración General

Algunas declaraciones de base de datos no devuelven ningún valor. Para estos tipos de operaciones, puedes usar el método `statement` en la fachada `DB`:

    DB::statement('drop table users');

<a name="running-an-unprepared-statement"></a>
#### Ejecutando una Declaración No Preparada

A veces puedes querer ejecutar una declaración SQL sin vincular ningún valor. Puedes usar el método `unprepared` de la fachada `DB` para lograr esto:

    DB::unprepared('update users set votes = 100 where name = "Dries"');

> [!WARNING]  
> Dado que las declaraciones no preparadas no vinculan parámetros, pueden ser vulnerables a inyecciones SQL. Nunca debes permitir valores controlados por el usuario dentro de una declaración no preparada.

<a name="implicit-commits-in-transactions"></a>
#### Compromisos Implícitos

Al usar los métodos `statement` y `unprepared` de la fachada `DB` dentro de transacciones, debes tener cuidado de evitar declaraciones que causen [compromisos implícitos](https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html). Estas declaraciones harán que el motor de base de datos comprometa indirectamente toda la transacción, dejando a Laravel inconsciente del nivel de transacción de la base de datos. Un ejemplo de tal declaración es crear una tabla de base de datos:

    DB::unprepared('create table a (col varchar(1) null)');

Por favor, consulta el manual de MySQL para [una lista de todas las declaraciones](https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html) que desencadenan compromisos implícitos.

<a name="using-multiple-database-connections"></a>
### Usando Múltiples Conexiones de Base de Datos

Si tu aplicación define múltiples conexiones en tu archivo de configuración `config/database.php`, puedes acceder a cada conexión a través del método `connection` proporcionado por la fachada `DB`. El nombre de la conexión pasado al método `connection` debe corresponder a una de las conexiones listadas en tu archivo de configuración `config/database.php` o configuradas en tiempo de ejecución usando el helper `config`:

    use Illuminate\Support\Facades\DB;

    $users = DB::connection('sqlite')->select(/* ... */);

Puedes acceder a la instancia PDO subyacente de una conexión usando el método `getPdo` en una instancia de conexión:

    $pdo = DB::connection()->getPdo();

<a name="listening-for-query-events"></a>
### Escuchando Eventos de Consultas

Si deseas especificar una función anónima que se invoque para cada consulta SQL ejecutada por tu aplicación, puedes usar el método `listen` de la fachada `DB`. Este método puede ser útil para registrar consultas o depurar. Puedes registrar tu función anónima de escucha de consultas en el método `boot` de un [proveedor de servicios](/docs/{{version}}/providers):

    <?php

    namespace App\Providers;

    use Illuminate\Database\Events\QueryExecuted;
    use Illuminate\Support\Facades\DB;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Registrar cualquier servicio de aplicación.
         */
        public function register(): void
        {
            // ...
        }

        /**
         * Inicializar cualquier servicio de aplicación.
         */
        public function boot(): void
        {
            DB::listen(function (QueryExecuted $query) {
                // $query->sql;
                // $query->bindings;
                // $query->time;
                // $query->toRawSql();
            });
        }
    }

<a name="monitoring-cumulative-query-time"></a>
### Monitoreando el Tiempo de Consulta Acumulado

Un cuello de botella común en el rendimiento de las aplicaciones web modernas es la cantidad de tiempo que pasan consultando bases de datos. Afortunadamente, Laravel puede invocar una función anónima o callback de tu elección cuando pasa demasiado tiempo consultando la base de datos durante una única solicitud. Para comenzar, proporciona un umbral de tiempo de consulta (en milisegundos) y una función anónima al método `whenQueryingForLongerThan`. Puedes invocar este método en el método `boot` de un [proveedor de servicios](/docs/{{version}}/providers):

    <?php

    namespace App\Providers;

    use Illuminate\Database\Connection;
    use Illuminate\Support\Facades\DB;
    use Illuminate\Support\ServiceProvider;
    use Illuminate\Database\Events\QueryExecuted;

```php
class AppServiceProvider extends ServiceProvider
{
    /**
     * Registrar cualquier servicio de la aplicación.
     */
    public function register(): void
    {
        // ...
    }

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        DB::whenQueryingForLongerThan(500, function (Connection $connection, QueryExecuted $event) {
            // Notificar al equipo de desarrollo...
        });
    }
}

<a name="database-transactions"></a>
## Transacciones de Base de Datos

Puedes usar el método `transaction` proporcionado por el `DB` facade para ejecutar un conjunto de operaciones dentro de una transacción de base de datos. Si se lanza una excepción dentro de la función anónima de la transacción, la transacción se revertirá automáticamente y la excepción se volverá a lanzar. Si la función anónima se ejecuta con éxito, la transacción se confirmará automáticamente. No necesitas preocuparte por revertir o confirmar manualmente mientras usas el método `transaction`:

    use Illuminate\Support\Facades\DB;

    DB::transaction(function () {
        DB::update('update users set votes = 1');

        DB::delete('delete from posts');
    });

<a name="handling-deadlocks"></a>
#### Manejo de Deadlocks

El método `transaction` acepta un segundo argumento opcional que define cuántas veces se debe reintentar una transacción cuando ocurre un deadlock. Una vez que se han agotado estos intentos, se lanzará una excepción:

    use Illuminate\Support\Facades\DB;

    DB::transaction(function () {
        DB::update('update users set votes = 1');

        DB::delete('delete from posts');
    }, 5);

<a name="manually-using-transactions"></a>
#### Uso Manual de Transacciones

Si deseas comenzar una transacción manualmente y tener control total sobre las reversas y confirmaciones, puedes usar el método `beginTransaction` proporcionado por el `DB` facade:

    use Illuminate\Support\Facades\DB;

    DB::beginTransaction();

Puedes revertir la transacción a través del método `rollBack`:

    DB::rollBack();

Por último, puedes confirmar una transacción a través del método `commit`:

    DB::commit();

> [!NOTE]  
> Los métodos de transacción del facade `DB` controlan las transacciones tanto para el [constructor de consultas](/docs/{{version}}/queries) como para el [Eloquent ORM](/docs/{{version}}/eloquent).

<a name="connecting-to-the-database-cli"></a>
## Conectando a la CLI de la Base de Datos

Si deseas conectarte a la CLI de tu base de datos, puedes usar el comando Artisan `db`:

```shell
php artisan db
```

Si es necesario, puedes especificar un nombre de conexión de base de datos para conectarte a una conexión de base de datos que no sea la conexión predeterminada:

```shell
php artisan db mysql
```

<a name="inspecting-your-databases"></a>
## Inspeccionando Tus Bases de Datos

Usando los comandos Artisan `db:show` y `db:table`, puedes obtener información valiosa sobre tu base de datos y sus tablas asociadas. Para ver un resumen de tu base de datos, incluyendo su tamaño, tipo, número de conexiones abiertas y un resumen de sus tablas, puedes usar el comando `db:show`:

```shell
php artisan db:show
```

Puedes especificar qué conexión de base de datos debe ser inspeccionada proporcionando el nombre de la conexión de base de datos al comando a través de la opción `--database`:

```shell
php artisan db:show --database=pgsql
```

Si deseas incluir conteos de filas de tablas y detalles de vistas de base de datos dentro de la salida del comando, puedes proporcionar las opciones `--counts` y `--views`, respectivamente. En bases de datos grandes, recuperar conteos de filas y detalles de vistas puede ser lento:

```shell
php artisan db:show --counts --views
```

Además, puedes usar los siguientes métodos de `Schema` para inspeccionar tu base de datos:

    use Illuminate\Support\Facades\Schema;

    $tables = Schema::getTables();
    $views = Schema::getViews();
    $columns = Schema::getColumns('users');
    $indexes = Schema::getIndexes('users');
    $foreignKeys = Schema::getForeignKeys('users');

Si deseas inspeccionar una conexión de base de datos que no sea la conexión predeterminada de tu aplicación, puedes usar el método `connection`:

    $columns = Schema::connection('sqlite')->getColumns('users');

<a name="table-overview"></a>
#### Resumen de la Tabla

Si deseas obtener un resumen de una tabla individual dentro de tu base de datos, puedes ejecutar el comando Artisan `db:table`. Este comando proporciona un resumen general de una tabla de base de datos, incluyendo sus columnas, tipos, atributos, claves e índices:

```shell
php artisan db:table users
```

<a name="monitoring-your-databases"></a>
## Monitoreando Tus Bases de Datos

Usando el comando Artisan `db:monitor`, puedes instruir a Laravel para que despache un evento `Illuminate\Database\Events\DatabaseBusy` si tu base de datos está gestionando más de un número especificado de conexiones abiertas.

Para comenzar, debes programar el comando `db:monitor` para [ejecutarse cada minuto](/docs/{{version}}/scheduling). El comando acepta los nombres de las configuraciones de conexión de base de datos que deseas monitorear, así como el número máximo de conexiones abiertas que deben ser toleradas antes de despachar un evento:

```shell
php artisan db:monitor --databases=mysql,pgsql --max=100
```

Programar este comando por sí solo no es suficiente para activar una notificación que te alerte sobre el número de conexiones abiertas. Cuando el comando encuentra una base de datos que tiene un conteo de conexiones abiertas que excede tu umbral, se despachará un evento `DatabaseBusy`. Debes escuchar este evento dentro del `AppServiceProvider` de tu aplicación para enviar una notificación a ti o a tu equipo de desarrollo:

```php
use App\Notifications\DatabaseApproachingMaxConnections;
use Illuminate\Database\Events\DatabaseBusy;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Notification;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Event::listen(function (DatabaseBusy $event) {
        Notification::route('mail', 'dev@example.com')
                ->notify(new DatabaseApproachingMaxConnections(
                    $event->connectionName,
                    $event->connections
                ));
    });
}
```
