# Base de datos: Comenzando

- [Introducción](#introduction)
  - [Configuración](#configuration)
  - [Conexiones de Lectura y Escritura](#read-and-write-connections)
- [Ejecutando Consultas SQL](#running-queries)
  - [Usando Múltiples Conexiones a la Base de Datos](#using-multiple-database-connections)
  - [Escuchando Eventos de Consulta](#listening-for-query-events)
  - [Monitoreando el Tiempo de Consulta Acumulativo](#monitoring-cumulative-query-time)
- [Transacciones de Base de Datos](#database-transactions)
- [Conectando a la CLI de la Base de Datos](#connecting-to-the-database-cli)
- [Inspeccionando Tus Bases de Datos](#inspecting-your-databases)
- [Monitoreando Tus Bases de Datos](#monitoring-your-databases)

<a name="introduction"></a>
## Introducción

Casi todas las aplicaciones web modernas interactúan con una base de datos. Laravel hace que la interacción con bases de datos sea extremadamente sencilla a través de una variedad de bases de datos soportadas utilizando SQL en bruto, un [constructor de consultas fluido](/docs/%7B%7Bversion%7D%7D/queries) y el [ORM Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent). Actualmente, Laravel ofrece soporte de primera mano para cinco bases de datos:
<div class="content-list" markdown="1">

- MariaDB 10.3+ ([Version Policy](https://mariadb.org/about/#maintenance-policy))
- MySQL 5.7+ ([Version Policy](https://en.wikipedia.org/wiki/MySQL#Release_history))
- PostgreSQL 10.0+ ([Version Policy](https://www.postgresql.org/support/versioning/))
- SQLite 3.26.0+
- SQL Server 2017+ ([Version Policy](https://docs.microsoft.com/en-us/lifecycle/products/?products=sql-server))
</div>

<a name="configuration"></a>
### Configuración

La configuración para los servicios de base de datos de Laravel se encuentra en el archivo de configuración `config/database.php` de tu aplicación. En este archivo, puedes definir todas tus conexiones a la base de datos, así como especificar qué conexión se debe usar por defecto. La mayoría de las opciones de configuración dentro de este archivo están impulsadas por los valores de las variables de entorno de tu aplicación. Se proporcionan ejemplos para la mayoría de los sistemas de base de datos admitidos por Laravel en este archivo.
Por defecto, la [configuración de entorno](/docs/%7B%7Bversion%7D%7D/configuration#environment-configuration) de muestra de Laravel está lista para usarse con [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail), que es una configuración de Docker para desarrollar aplicaciones Laravel en tu máquina local. Sin embargo, puedes modificar tu configuración de base de datos según sea necesario para tu base de datos local.

<a name="sqlite-configuration"></a>
#### Configuración de SQLite

Las bases de datos SQLite están contenidas en un solo archivo en tu sistema de archivos. Puedes crear una nueva base de datos SQLite utilizando el comando `touch` en tu terminal: `touch database/database.sqlite`. Después de que se haya creado la base de datos, puedes configurar fácilmente tus variables de entorno para que apunten a esta base de datos colocando la ruta absoluta a la base de datos en la variable de entorno `DB_DATABASE`:


```ini
DB_CONNECTION=sqlite
DB_DATABASE=/absolute/path/to/database.sqlite

```
Por defecto, las restricciones de clave foránea están habilitadas para conexiones SQLite. Si deseas desactivarlas, debes configurar la variable de entorno `DB_FOREIGN_KEYS` en `false`:


```ini
DB_FOREIGN_KEYS=false

```
> [!NOTA]
Si utilizas el [instalador de Laravel](/docs/%7B%7Bversion%7D%7D/installation#creating-a-laravel-project) para crear tu aplicación Laravel y seleccionas SQLite como tu base de datos, Laravel creará automáticamente un archivo `database/database.sqlite` y ejecutará las [migraciones de base de datos](/docs/%7B%7Bversion%7D%7D/migrations) predeterminadas por ti.

<a name="mssql-configuration"></a>
#### Configuración de Microsoft SQL Server

Para usar una base de datos de Microsoft SQL Server, debes asegurarte de que tienes instaladas las extensiones PHP `sqlsrv` y `pdo_sqlsrv`, así como cualquier dependencia que puedan requerir, como el driver ODBC de Microsoft SQL.

<a name="configuration-using-urls"></a>
#### Configuración Usando URL

Típicamente, las conexiones a la base de datos se configuran utilizando múltiples valores de configuración como `host`, `database`, `username`, `password`, etc. Cada uno de estos valores de configuración tiene su propia variable de entorno correspondiente. Esto significa que al configurar la información de conexión a la base de datos en un servidor de producción, necesitas gestionar varias variables de entorno.
Algunos proveedores de bases de datos gestionadas, como AWS y Heroku, ofrecen una única "URL" de base de datos que contiene toda la información de conexión para la base de datos en una sola cadena. Una URL de base de datos de ejemplo puede verse algo así:


```html
mysql://root:password@127.0.0.1/forge?charset=UTF-8

```
Estas URL suelen seguir una convención de esquema estándar:


```html
driver://username:password@host:port/database?options

```
Por conveniencia, Laravel admite estas URL como una alternativa a la configuración de tu base de datos con múltiples opciones de configuración. Si la opción de configuración `url` (o la variable de entorno `DB_URL` correspondiente) está presente, se utilizará para extraer la información de conexión a la base de datos y las credenciales.

<a name="read-and-write-connections"></a>
### Conexiones de Lectura y Escritura

A veces es posible que desees usar una conexión a la base de datos para las declaraciones SELECT y otra para las declaraciones INSERT, UPDATE y DELETE. Laravel hace que esto sea muy fácil, y las conexiones adecuadas siempre se utilizarán ya sea que estés usando consultas en crudo, el constructor de consultas o el ORM Eloquent.
Para ver cómo se deben configurar las conexiones de lectura / escritura, examinemos este ejemplo:


```php
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
```
Ten en cuenta que se han añadido tres claves al array de configuración: `read`, `write` y `sticky`. Las claves `read` y `write` tienen valores de array que contienen una sola clave: `host`. El resto de las opciones de base de datos para las conexiones `read` y `write` se fusionarán desde el array de configuración `mysql` principal.
Solo necesitas colocar elementos en los arreglos `read` y `write` si deseas anular los valores del arreglo `mysql` principal. Así que, en este caso, `192.168.1.1` se utilizará como el host para la conexión "read", mientras que `192.168.1.3` se usará para la conexión "write". Las credenciales de la base de datos, el prefijo, el conjunto de caracteres y todas las demás opciones en el arreglo `mysql` principal se compartirán entre ambas conexiones. Cuando existan múltiples valores en el arreglo de configuración `host`, se elegirá un host de base de datos de forma aleatoria para cada solicitud.

<a name="the-sticky-option"></a>
#### La Opción `sticky`

La opción `sticky` es un valor *opcional* que se puede utilizar para permitir la lectura inmediata de registros que se han escrito en la base de datos durante el ciclo de solicitud actual. Si la opción `sticky` está habilitada y se ha realizado una operación de "escritura" contra la base de datos durante el ciclo de solicitud actual, cualquier operación de "lectura" posterior utilizará la conexión de "escritura". Esto asegura que cualquier dato escrito durante el ciclo de solicitud se pueda leer inmediatamente desde la base de datos durante esa misma solicitud. Depende de ti decidir si este es el comportamiento deseado para tu aplicación.

<a name="running-queries"></a>
## Ejecutando Consultas SQL

Una vez que hayas configurado tu conexión a la base de datos, puedes ejecutar consultas utilizando la fachada `DB`. La fachada `DB` proporciona métodos para cada tipo de consulta: `select`, `update`, `insert`, `delete` y `statement`.

<a name="running-a-select-query"></a>
#### Ejecución de una Consulta Select

Para ejecutar una consulta SELECT básica, puedes usar el método `select` en la facade `DB`:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class UserController extends Controller
{
    /**
     * Show a list of all of the application's users.
     */
    public function index(): View
    {
        $users = DB::select('select * from users where active = ?', [1]);

        return view('user.index', ['users' => $users]);
    }
}
```
El primer argumento pasado al método `select` es la consulta SQL, mientras que el segundo argumento son cualquiera de los enlaces de parámetros que deben vincularse a la consulta. Típicamente, estos son los valores de las restricciones de la cláusula `where`. El enlace de parámetros proporciona protección contra inyecciones SQL.
El método `select` siempre devolverá un `array` de resultados. Cada resultado dentro del array será un objeto `stdClass` de PHP que representa un registro de la base de datos:


```php
use Illuminate\Support\Facades\DB;

$users = DB::select('select * from users');

foreach ($users as $user) {
    echo $user->name;
}
```

<a name="selecting-scalar-values"></a>
#### Seleccionando Valores Escalares

A veces, tu consulta a la base de datos puede resultar en un solo valor escalar. En lugar de tener que recuperar el resultado escalar de la consulta desde un objeto de registro, Laravel te permite recuperar este valor directamente utilizando el método `scalar`:


```php
$burgers = DB::scalar(
    "select count(case when food = 'burger' then 1 end) as burgers from menu"
);
```

<a name="selecting-multiple-result-sets"></a>
#### Seleccionando Múltiples Conjuntos de Resultados

Si tu aplicación llama a procedimientos almacenados que devuelven múltiples conjuntos de resultados, puedes usar el método `selectResultSets` para recuperar todos los conjuntos de resultados devueltos por el procedimiento almacenado:


```php
[$options, $notifications] = DB::selectResultSets(
    "CALL get_user_options_and_notifications(?)", $request->user()->id
);
```

<a name="using-named-bindings"></a>
#### Usando Bindings Nombrados

En lugar de usar `?` para representar tus enlaces de parámetros, puedes ejecutar una consulta utilizando enlaces con nombre:


```php
$results = DB::select('select * from users where id = :id', ['id' => 1]);
```

<a name="running-an-insert-statement"></a>
#### Ejecutando una Sentencia de Inserción

Para ejecutar una declaración `insert`, puedes usar el método `insert` en la fachada `DB`. Al igual que `select`, este método acepta la consulta SQL como su primer argumento y los enlaces como su segundo argumento:


```php
use Illuminate\Support\Facades\DB;

DB::insert('insert into users (id, name) values (?, ?)', [1, 'Marc']);
```

<a name="running-an-update-statement"></a>
#### Ejecutando una Declaración de Actualización

El método `update` debe utilizarse para actualizar registros existentes en la base de datos. El número de filas afectadas por la instrucción es devuelto por el método:


```php
use Illuminate\Support\Facades\DB;

$affected = DB::update(
    'update users set votes = 100 where name = ?',
    ['Anita']
);
```

<a name="running-a-delete-statement"></a>
#### Ejecutando una declaración de eliminación

El método `delete` debe utilizarse para eliminar registros de la base de datos. Al igual que `update`, el número de filas afectadas será devuelto por el método:


```php
use Illuminate\Support\Facades\DB;

$deleted = DB::delete('delete from users');
```

<a name="running-a-general-statement"></a>
#### Ejecutando una Declaración General

Algunas declaraciones de base de datos no devuelven ningún valor. Para estos tipos de operaciones, puedes usar el método `statement` en la fachada `DB`:


```php
DB::statement('drop table users');
```

<a name="running-an-unprepared-statement"></a>
#### Ejecutando una Declaración No Preparada

A veces es posible que desees ejecutar una declaración SQL sin vincular ningún valor. Puedes usar el método `unprepared` de la fachada `DB` para lograr esto:


```php
DB::unprepared('update users set votes = 100 where name = "Dries"');
```
> [!WARNING]
Dado que las declaraciones no preparadas no vinculan parámetros, pueden ser vulnerables a inyecciones SQL. Nunca debes permitir valores controlados por el usuario dentro de una declaración no preparada.

<a name="implicit-commits-in-transactions"></a>
#### Commits Implícitos

Al usar los métodos `statement` y `unprepared` de la fachada `DB` dentro de transacciones, debes tener cuidado de evitar statements que causen [commits implícitos](https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html). Estos statements harán que el motor de la base de datos confirme indirectamente toda la transacción, dejando a Laravel sin conocimiento del nivel de transacción de la base de datos. Un ejemplo de tal statement es crear una tabla de base de datos:


```php
DB::unprepared('create table a (col varchar(1) null)');
```
Por favor, consulta el manual de MySQL para [una lista de todas las declaraciones](https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html) que activan compromisos implícitos.

<a name="using-multiple-database-connections"></a>
### Usando Múltiples Conexiones a la Base de Datos

Si tu aplicación define múltiples conexiones en tu archivo de configuración `config/database.php`, puedes acceder a cada conexión a través del método `connection` proporcionado por la fachada `DB`. El nombre de la conexión pasado al método `connection` debe corresponder a una de las conexiones listadas en tu archivo de configuración `config/database.php` o configuradas en tiempo de ejecución utilizando el helper `config`:


```php
use Illuminate\Support\Facades\DB;

$users = DB::connection('sqlite')->select(/* ... */);
```
Puedes acceder a la instancia PDO subyacente en bruto de una conexión utilizando el método `getPdo` en una instancia de conexión:


```php
$pdo = DB::connection()->getPdo();
```

<a name="listening-for-query-events"></a>
### Escuchando Eventos de Consulta

Si deseas especificar una función anónima que se invoque para cada consulta SQL ejecutada por tu aplicación, puedes usar el método `listen` de la fachada `DB`. Este método puede ser útil para registrar consultas o depurar. Puedes registrar tu función anónima del escuchador de consultas en el método `boot` de un [proveedor de servicios](/docs/%7B%7Bversion%7D%7D/providers):


```php
<?php

namespace App\Providers;

use Illuminate\Database\Events\QueryExecuted;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
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
        DB::listen(function (QueryExecuted $query) {
            // $query->sql;
            // $query->bindings;
            // $query->time;
            // $query->toRawSql();
        });
    }
}
```

<a name="monitoring-cumulative-query-time"></a>
### Monitoreo del Tiempo de Consulta Acumulado

Un cuello de botella de rendimiento común en las aplicaciones web modernas es la cantidad de tiempo que pasan consultando bases de datos. Afortunadamente, Laravel puede invocar una función anónima o un callback de tu elección cuando pasa demasiado tiempo consultando la base de datos durante una sola solicitud. Para comenzar, proporciona un umbral de tiempo de consulta (en milisegundos) y una función anónima al método `whenQueryingForLongerThan`. Puedes invocar este método en el método `boot` de un [proveedor de servicios](/docs/%7B%7Bversion%7D%7D/providers):


```php
<?php

namespace App\Providers;

use Illuminate\Database\Connection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\ServiceProvider;
use Illuminate\Database\Events\QueryExecuted;

class AppServiceProvider extends ServiceProvider
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
        DB::whenQueryingForLongerThan(500, function (Connection $connection, QueryExecuted $event) {
            // Notify development team...
        });
    }
}
```

<a name="database-transactions"></a>
## Transacciones de base de datos

Puedes utilizar el método `transaction` proporcionado por la fachada `DB` para ejecutar un conjunto de operaciones dentro de una transacción de base de datos. Si se lanza una excepción dentro de la `función anónima` de la transacción, la transacción se revertirá automáticamente y la excepción se volverá a lanzar. Si la `función anónima` se ejecuta con éxito, la transacción se confirmará automáticamente. No necesitas preocuparte por revertir o confirmar manualmente mientras usas el método `transaction`:


```php
use Illuminate\Support\Facades\DB;

DB::transaction(function () {
    DB::update('update users set votes = 1');

    DB::delete('delete from posts');
});
```

<a name="handling-deadlocks"></a>
#### Manejo de Deadlocks

El método `transaction` acepta un segundo argumento opcional que define cuántas veces se debe reintentar una transacción cuando ocurre un interbloqueo. Una vez que se hayan agotado estos intentos, se lanzará una excepción:


```php
use Illuminate\Support\Facades\DB;

DB::transaction(function () {
    DB::update('update users set votes = 1');

    DB::delete('delete from posts');
}, 5);
```

<a name="manually-using-transactions"></a>
#### Uso Manual de Transacciones

Si deseas iniciar una transacción manualmente y tener control completo sobre los retrocesos y confirmaciones, puedes usar el método `beginTransaction` proporcionado por la facade `DB`:


```php
use Illuminate\Support\Facades\DB;

DB::beginTransaction();
```
Puedes revertir la transacción a través del método `rollBack`:


```php
DB::rollBack();
```
Por último, puedes confirmar una transacción a través del método `commit`:


```php
DB::commit();
```
> [!NOTE]
Los métodos de transacción de la fachada `DB` controlan las transacciones tanto para el [constructor de consultas](/docs/%7B%7Bversion%7D%7D/queries) como para el [Eloquent ORM](/docs/%7B%7Bversion%7D%7D/eloquent).

<a name="connecting-to-the-database-cli"></a>
## Conectándose a la CLI de la base de datos

Si deseas conectarte a la CLI de tu base de datos, puedes usar el comando Artisan `db`:


```shell
php artisan db

```
Si es necesario, puedes especificar un nombre de conexión a la base de datos para conectarte a una conexión de base de datos que no sea la conexión predeterminada:


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
Si deseas incluir el conteo de filas de la tabla y los detalles de las vistas de la base de datos dentro de la salida del comando, puedes proporcionar las opciones `--counts` y `--views`, respectivamente. En bases de datos grandes, recuperar conteos de filas y detalles de vistas puede ser lento:


```shell
php artisan db:show --counts --views

```
Además, puedes utilizar los siguientes métodos `Schema` para inspeccionar tu base de datos:


```php
use Illuminate\Support\Facades\Schema;

$tables = Schema::getTables();
$views = Schema::getViews();
$columns = Schema::getColumns('users');
$indexes = Schema::getIndexes('users');
$foreignKeys = Schema::getForeignKeys('users');
```
Si deseas inspeccionar una conexión a la base de datos que no sea la conexión predeterminada de tu aplicación, puedes usar el método `connection`:


```php
$columns = Schema::connection('sqlite')->getColumns('users');
```

<a name="table-overview"></a>
#### Resumen de la Tabla

Si deseas obtener una vista general de una tabla individual dentro de tu base de datos, puedes ejecutar el comando Artisan `db:table`. Este comando proporciona una visión general de una tabla de base de datos, incluyendo sus columnas, tipos, atributos, claves e índices:


```shell
php artisan db:table users

```

<a name="monitoring-your-databases"></a>
## Monitoreando Tus Bases de Datos

Usando el comando Artisan `db:monitor`, puedes instruir a Laravel para que despache un evento `Illuminate\Database\Events\DatabaseBusy` si tu base de datos está gestionando más de un número especificado de conexiones abiertas.
Para empezar, debes programar el comando `db:monitor` para [que se ejecute cada minuto](/docs/%7B%7Bversion%7D%7D/scheduling). El comando acepta los nombres de las configuraciones de conexión a la base de datos que deseas monitorear, así como el número máximo de conexiones abiertas que se deben tolerar antes de despachar un evento:


```shell
php artisan db:monitor --databases=mysql,pgsql --max=100

```
Programar este comando solo no es suficiente para activar una notificación que te alerte sobre el número de conexiones abiertas. Cuando el comando encuentra una base de datos que tiene un conteo de conexiones abiertas que supera tu umbral, se despachará un evento `DatabaseBusy`. Debes escuchar este evento dentro de `AppServiceProvider` de tu aplicación para poder enviar una notificación a ti o a tu equipo de desarrollo:


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