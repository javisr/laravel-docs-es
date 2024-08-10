# Base de datos: Migraciones

- [Introducción](#introduction)
- [Generando Migraciones](#generating-migrations)
    - [Consolidando Migraciones](#squashing-migrations)
- [Estructura de Migración](#migration-structure)
- [Ejecutando Migraciones](#running-migrations)
    - [Revirtiendo Migraciones](#rolling-back-migrations)
- [Tablas](#tables)
    - [Creando Tablas](#creating-tables)
    - [Actualizando Tablas](#updating-tables)
    - [Renombrando / Eliminando Tablas](#renaming-and-dropping-tables)
- [Columnas](#columns)
    - [Creando Columnas](#creating-columns)
    - [Tipos de Columnas Disponibles](#available-column-types)
    - [Modificadores de Columnas](#column-modifiers)
    - [Modificando Columnas](#modifying-columns)
    - [Renombrando Columnas](#renaming-columns)
    - [Eliminando Columnas](#dropping-columns)
- [Índices](#indexes)
    - [Creando Índices](#creating-indexes)
    - [Renombrando Índices](#renaming-indexes)
    - [Eliminando Índices](#dropping-indexes)
    - [Restricciones de Clave Foránea](#foreign-key-constraints)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

Las migraciones son como el control de versiones para tu base de datos, permitiendo a tu equipo definir y compartir la definición del esquema de la base de datos de la aplicación. Si alguna vez has tenido que decirle a un compañero de equipo que agregue manualmente una columna a su esquema de base de datos local después de haber incorporado tus cambios del control de versiones, has enfrentado el problema que las migraciones de base de datos resuelven.

El `Schema` de Laravel [facade](/docs/{{version}}/facades) proporciona soporte independiente de la base de datos para crear y manipular tablas en todos los sistemas de base de datos compatibles con Laravel. Típicamente, las migraciones usarán esta fachada para crear y modificar tablas y columnas de la base de datos.

<a name="generating-migrations"></a>
## Generando Migraciones

Puedes usar el comando [Artisan](/docs/{{version}}/artisan) `make:migration` para generar una migración de base de datos. La nueva migración se colocará en tu directorio `database/migrations`. Cada nombre de archivo de migración contiene una marca de tiempo que permite a Laravel determinar el orden de las migraciones:

```shell
php artisan make:migration create_flights_table
```

Laravel usará el nombre de la migración para intentar adivinar el nombre de la tabla y si la migración creará o no una nueva tabla. Si Laravel puede determinar el nombre de la tabla a partir del nombre de la migración, Laravel prellenará el archivo de migración generado con la tabla especificada. De lo contrario, simplemente puedes especificar la tabla en el archivo de migración manualmente.

Si deseas especificar una ruta personalizada para la migración generada, puedes usar la opción `--path` al ejecutar el comando `make:migration`. La ruta dada debe ser relativa a la ruta base de tu aplicación.

> [!NOTE]  
> Los stubs de migración pueden ser personalizados usando [publicación de stubs](/docs/{{version}}/artisan#stub-customization).

<a name="squashing-migrations"></a>
### Consolidando Migraciones

A medida que construyes tu aplicación, puedes acumular más y más migraciones con el tiempo. Esto puede llevar a que tu directorio `database/migrations` se vuelva voluminoso con potencialmente cientos de migraciones. Si lo deseas, puedes "consolidar" tus migraciones en un solo archivo SQL. Para comenzar, ejecuta el comando `schema:dump`:

```shell
php artisan schema:dump

# Dump the current database schema and prune all existing migrations...
php artisan schema:dump --prune
```

Cuando ejecutas este comando, Laravel escribirá un archivo de "esquema" en el directorio `database/schema` de tu aplicación. El nombre del archivo de esquema corresponderá a la conexión de base de datos. Ahora, cuando intentes migrar tu base de datos y no se hayan ejecutado otras migraciones, Laravel primero ejecutará las declaraciones SQL en el archivo de esquema de la conexión de base de datos que estás utilizando. Después de ejecutar las declaraciones SQL del archivo de esquema, Laravel ejecutará cualquier migración restante que no formara parte del volcado de esquema.

Si las pruebas de tu aplicación utilizan una conexión de base de datos diferente a la que normalmente usas durante el desarrollo local, debes asegurarte de haber volcado un archivo de esquema utilizando esa conexión de base de datos para que tus pruebas puedan construir tu base de datos. Puede que desees hacer esto después de volcar la conexión de base de datos que normalmente usas durante el desarrollo local:

```shell
php artisan schema:dump
php artisan schema:dump --database=testing --prune
```

Debes comprometer tu archivo de esquema de base de datos en el control de versiones para que otros nuevos desarrolladores en tu equipo puedan crear rápidamente la estructura inicial de la base de datos de tu aplicación.

> [!WARNING]  
> La consolidación de migraciones solo está disponible para las bases de datos MariaDB, MySQL, PostgreSQL y SQLite y utiliza el cliente de línea de comandos de la base de datos.

<a name="migration-structure"></a>
## Estructura de Migración

Una clase de migración contiene dos métodos: `up` y `down`. El método `up` se utiliza para agregar nuevas tablas, columnas o índices a tu base de datos, mientras que el método `down` debe revertir las operaciones realizadas por el método `up`.

Dentro de ambos métodos, puedes usar el constructor de esquemas de Laravel para crear y modificar tablas de manera expresiva. Para aprender sobre todos los métodos disponibles en el constructor `Schema`, [consulta su documentación](#creating-tables). Por ejemplo, la siguiente migración crea una tabla `flights`:

    <?php

    use Illuminate\Database\Migrations\Migration;
    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    return new class extends Migration
    {
        /**
         * Ejecutar las migraciones.
         */
        public function up(): void
        {
            Schema::create('flights', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('airline');
                $table->timestamps();
            });
        }

        /**
         * Revertir las migraciones.
         */
        public function down(): void
        {
            Schema::drop('flights');
        }
    };

<a name="setting-the-migration-connection"></a>
#### Configurando la Conexión de Migración

Si tu migración interactuará con una conexión de base de datos diferente a la conexión de base de datos predeterminada de tu aplicación, debes establecer la propiedad `$connection` de tu migración:

    /**
     * La conexión de base de datos que debe ser utilizada por la migración.
     *
     * @var string
     */
    protected $connection = 'pgsql';

    /**
     * Ejecutar las migraciones.
     */
    public function up(): void
    {
        // ...
    }

<a name="running-migrations"></a>
## Ejecutando Migraciones

Para ejecutar todas tus migraciones pendientes, ejecuta el comando Artisan `migrate`:

```shell
php artisan migrate
```

Si deseas ver qué migraciones se han ejecutado hasta ahora, puedes usar el comando Artisan `migrate:status`:

```shell
php artisan migrate:status
```

Si deseas ver las declaraciones SQL que se ejecutarán por las migraciones sin ejecutarlas realmente, puedes proporcionar la opción `--pretend` al comando `migrate`:

```shell
php artisan migrate --pretend
```

#### Aislando la Ejecución de Migraciones

Si estás desplegando tu aplicación en múltiples servidores y ejecutando migraciones como parte de tu proceso de despliegue, probablemente no desees que dos servidores intenten migrar la base de datos al mismo tiempo. Para evitar esto, puedes usar la opción `isolated` al invocar el comando `migrate`.

Cuando se proporciona la opción `isolated`, Laravel adquirirá un bloqueo atómico utilizando el controlador de caché de tu aplicación antes de intentar ejecutar tus migraciones. Todos los demás intentos de ejecutar el comando `migrate` mientras se mantiene ese bloqueo no se ejecutarán; sin embargo, el comando aún saldrá con un código de estado de salida exitoso:

```shell
php artisan migrate --isolated
```

> [!WARNING]  
> Para utilizar esta función, tu aplicación debe estar utilizando el controlador de caché `memcached`, `redis`, `dynamodb`, `database`, `file` o `array` como el controlador de caché predeterminado de tu aplicación. Además, todos los servidores deben comunicarse con el mismo servidor de caché central.

<a name="forcing-migrations-to-run-in-production"></a>
#### Forzando Migraciones para Ejecutarse en Producción

Algunas operaciones de migración son destructivas, lo que significa que pueden hacer que pierdas datos. Para protegerte de ejecutar estos comandos contra tu base de datos de producción, se te pedirá confirmación antes de que se ejecuten los comandos. Para forzar que los comandos se ejecuten sin un aviso, usa la opción `--force`:

```shell
php artisan migrate --force
```

<a name="rolling-back-migrations"></a>
### Revirtiendo Migraciones

Para revertir la última operación de migración, puedes usar el comando Artisan `rollback`. Este comando revierte el último "lote" de migraciones, que puede incluir múltiples archivos de migración:

```shell
php artisan migrate:rollback
```

Puedes revertir un número limitado de migraciones proporcionando la opción `step` al comando `rollback`. Por ejemplo, el siguiente comando revertirá las últimas cinco migraciones:

```shell
php artisan migrate:rollback --step=5
```

Puedes revertir un "lote" específico de migraciones proporcionando la opción `batch` al comando `rollback`, donde la opción `batch` corresponde a un valor de lote dentro de la tabla de base de datos `migrations` de tu aplicación. Por ejemplo, el siguiente comando revertirá todas las migraciones en el lote tres:

 ```shell
php artisan migrate:rollback --batch=3
 ```

If you would like to see the SQL statements that will be executed by the migrations without actually running them, you may provide the `--pretend` flag to the `migrate:rollback` command:

```shell
php artisan migrate:rollback --pretend

The `migrate:reset` command will roll back all of your application's migrations:

```shell
php artisan migrate:reset

<a name="roll-back-migrate-using-a-single-command"></a>
#### Roll Back and Migrate Using a Single Command

The `migrate:refresh` command will roll back all of your migrations and then execute the `migrate` command. This command effectively re-creates your entire database:

```shell
php artisan migrate:refresh

# Refrescar la base de datos y ejecutar todas las semillas de base de datos...
php artisan migrate:refresh --seed

You may roll back and re-migrate a limited number of migrations by providing the `step` option to the `refresh` command. For example, the following command will roll back and re-migrate the last five migrations:

```shell
php artisan migrate:refresh --step=5

<a name="drop-all-tables-migrate"></a>
#### Drop All Tables and Migrate

The `migrate:fresh` command will drop all tables from the database and then execute the `migrate` command:

```shell
php artisan migrate:fresh

php artisan migrate:fresh --seed

By default, the `migrate:fresh` command only drops tables from the default database connection. However, you may use the `--database` option to specify the database connection that should be migrated. The database connection name should correspond to a connection defined in your application's `database` [configuration file](/docs/{{version}}/configuration):

```shell
php artisan migrate:fresh --database=admin

> [!WARNING]  
> The `migrate:fresh` command will drop all database tables regardless of their prefix. This command should be used with caution when developing on a database that is shared with other applications.

<a name="tables"></a>
## Tables

<a name="creating-tables"></a>
### Creating Tables

To create a new database table, use the `create` method on the `Schema` facade. The `create` method accepts two arguments: the first is the name of the table, while the second is a closure which receives a `Blueprint` object that may be used to define the new table:

    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    Schema::create('users', function (Blueprint $table) {
        $table->id();
        $table->string('name');
        $table->string('email');
        $table->timestamps();
    });

When creating the table, you may use any of the schema builder's [column methods](#creating-columns) to define the table's columns.

<a name="determining-table-column-existence"></a>
#### Determining Table / Column Existence

You may determine the existence of a table, column, or index using the `hasTable`, `hasColumn`, and `hasIndex` methods:

    if (Schema::hasTable('users')) {
        // The "users" table exists...
    }

    if (Schema::hasColumn('users', 'email')) {
        // The "users" table exists and has an "email" column...
    }

    if (Schema::hasIndex('users', ['email'], 'unique')) {
        // The "users" table exists and has a unique index on the "email" column...
    }

<a name="database-connection-table-options"></a>
#### Database Connection and Table Options

If you want to perform a schema operation on a database connection that is not your application's default connection, use the `connection` method:

    Schema::connection('sqlite')->create('users', function (Blueprint $table) {
        $table->id();
    });

In addition, a few other properties and methods may be used to define other aspects of the table's creation. The `engine` property may be used to specify the table's storage engine when using MariaDB or MySQL:

    Schema::create('users', function (Blueprint $table) {
        $table->engine('InnoDB');

        // ...
    });

The `charset` and `collation` properties may be used to specify the character set and collation for the created table when using MariaDB or MySQL:

    Schema::create('users', function (Blueprint $table) {
        $table->charset('utf8mb4');
        $table->collation('utf8mb4_unicode_ci');

        // ...
    });

The `temporary` method may be used to indicate that the table should be "temporary". Temporary tables are only visible to the current connection's database session and are dropped automatically when the connection is closed:

    Schema::create('calculations', function (Blueprint $table) {
        $table->temporary();

        // ...
    });

If you would like to add a "comment" to a database table, you may invoke the `comment` method on the table instance. Table comments are currently only supported by MariaDB, MySQL, and PostgreSQL:

    Schema::create('calculations', function (Blueprint $table) {
        $table->comment('Business calculations');

        // ...
    });

<a name="updating-tables"></a>
### Updating Tables

The `table` method on the `Schema` facade may be used to update existing tables. Like the `create` method, the `table` method accepts two arguments: the name of the table and a closure that receives a `Blueprint` instance you may use to add columns or indexes to the table:

    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    Schema::table('users', function (Blueprint $table) {
        $table->integer('votes');
    });

<a name="renaming-and-dropping-tables"></a>
### Renaming / Dropping Tables

To rename an existing database table, use the `rename` method:

    use Illuminate\Support\Facades\Schema;

    Schema::rename($from, $to);

To drop an existing table, you may use the `drop` or `dropIfExists` methods:

    Schema::drop('users');

    Schema::dropIfExists('users');

<a name="renaming-tables-with-foreign-keys"></a>
#### Renaming Tables With Foreign Keys

Before renaming a table, you should verify that any foreign key constraints on the table have an explicit name in your migration files instead of letting Laravel assign a convention based name. Otherwise, the foreign key constraint name will refer to the old table name.

<a name="columns"></a>
## Columns

<a name="creating-columns"></a>
### Creating Columns

The `table` method on the `Schema` facade may be used to update existing tables. Like the `create` method, the `table` method accepts two arguments: the name of the table and a closure that receives an `Illuminate\Database\Schema\Blueprint` instance you may use to add columns to the table:

    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    Schema::table('users', function (Blueprint $table) {
        $table->integer('votes');
    });

<a name="available-column-types"></a>
### Available Column Types

The schema builder blueprint offers a variety of methods that correspond to the different types of columns you can add to your database tables. Each of the available methods are listed in the table below:

<style>
    .collection-method-list > p {
        columns: 10.8em 3; -moz-columns: 10.8em 3; -webkit-columns: 10.8em 3;
    }

    .collection-method-list a {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .collection-method code {
        font-size: 14px;
    }

    .collection-method:not(.first-collection-method) {
        margin-top: 50px;
    }
</style>

<div class="collection-method-list" markdown="1">

[bigIncrements](#column-method-bigIncrements)
[bigInteger](#column-method-bigInteger)
[binary](#column-method-binary)
[boolean](#column-method-boolean)
[char](#column-method-char)
[dateTimeTz](#column-method-dateTimeTz)
[dateTime](#column-method-dateTime)
[date](#column-method-date)
[decimal](#column-method-decimal)
[double](#column-method-double)
[enum](#column-method-enum)
[float](#column-method-float)
[foreignId](#column-method-foreignId)
[foreignIdFor](#column-method-foreignIdFor)
[foreignUlid](#column-method-foreignUlid)
[foreignUuid](#column-method-foreignUuid)
[geography](#column-method-geography)
[geometry](#column-method-geometry)
[id](#column-method-id)
[increments](#column-method-increments)
[integer](#column-method-integer)
[ipAddress](#column-method-ipAddress)
[json](#column-method-json)
[jsonb](#column-method-jsonb)
[longText](#column-method-longText)
[macAddress](#column-method-macAddress)
[mediumIncrements](#column-method-mediumIncrements)
[mediumInteger](#column-method-mediumInteger)
[mediumText](#column-method-mediumText)
[morphs](#column-method-morphs)
[nullableMorphs](#column-method-nullableMorphs)
[nullableTimestamps](#column-method-nullableTimestamps)
[nullableUlidMorphs](#column-method-nullableUlidMorphs)
[nullableUuidMorphs](#column-method-nullableUuidMorphs)
[rememberToken](#column-method-rememberToken)
[set](#column-method-set)
[smallIncrements](#column-method-smallIncrements)
[smallInteger](#column-method-smallInteger)
[softDeletesTz](#column-method-softDeletesTz)
[softDeletes](#column-method-softDeletes)
[string](#column-method-string)
[text](#column-method-text)
[timeTz](#column-method-timeTz)
[time](#column-method-time)
[timestampTz](#column-method-timestampTz)
[timestamp](#column-method-timestamp)
[timestampsTz](#column-method-timestampsTz)
[timestamps](#column-method-timestamps)
[tinyIncrements](#column-method-tinyIncrements)
[tinyInteger](#column-method-tinyInteger)
[tinyText](#column-method-tinyText)
[unsignedBigInteger](#column-method-unsignedBigInteger)
[unsignedInteger](#column-method-unsignedInteger)
[unsignedMediumInteger](#column-method-unsignedMediumInteger)
[unsignedSmallInteger](#column-method-unsignedSmallInteger)
[unsignedTinyInteger](#column-method-unsignedTinyInteger)
[ulidMorphs](#column-method-ulidMorphs)
[uuidMorphs](#column-method-uuidMorphs)
[ulid](#column-method-ulid)
[uuid](#column-method-uuid)
[year](#column-method-year)

</div>

<a name="column-method-bigIncrements"></a>
#### `bigIncrements()` {.collection-method .first-collection-method}

The `bigIncrements` method creates an auto-incrementing `UNSIGNED BIGINT` (primary key) equivalent column:

    $table->bigIncrements('id');

<a name="column-method-bigInteger"></a>
#### `bigInteger()` {.collection-method}

The `bigInteger` method creates a `BIGINT` equivalent column:

    $table->bigInteger('votes');

<a name="column-method-binary"></a>
#### `binary()` {.collection-method}

The `binary` method creates a `BLOB` equivalent column:

    $table->binary('photo');

When utilizing MySQL, MariaDB, or SQL Server, you may pass `length` and `fixed` arguments to create `VARBINARY` or `BINARY` equivalent column:

    $table->binary('data', length: 16); // VARBINARY(16)

    $table->binary('data', length: 16, fixed: true); // BINARY(16)

<a name="column-method-boolean"></a>
#### `boolean()` {.collection-method}

The `boolean` method creates a `BOOLEAN` equivalent column:

    $table->boolean('confirmed');

<a name="column-method-char"></a>
#### `char()` {.collection-method}

The `char` method creates a `CHAR` equivalent column with of a given length:

    $table->char('name', length: 100);

<a name="column-method-dateTimeTz"></a>
#### `dateTimeTz()` {.collection-method}

The `dateTimeTz` method creates a `DATETIME` (with timezone) equivalent column with an optional fractional seconds precision:

    $table->dateTimeTz('created_at', precision: 0);

<a name="column-method-dateTime"></a>
#### `dateTime()` {.collection-method}

The `dateTime` method creates a `DATETIME` equivalent column with an optional fractional seconds precision:

    $table->dateTime('created_at', precision: 0);

<a name="column-method-date"></a>
#### `date()` {.collection-method}

The `date` method creates a `DATE` equivalent column:

    $table->date('created_at');

<a name="column-method-decimal"></a>
#### `decimal()` {.collection-method}

The `decimal` method creates a `DECIMAL` equivalent column with the given precision (total digits) and scale (decimal digits):

    $table->decimal('amount', total: 8, places: 2);

<a name="column-method-double"></a>
#### `double()` {.collection-method}

The `double` method creates a `DOUBLE` equivalent column:

    $table->double('amount');

<a name="column-method-enum"></a>
#### `enum()` {.collection-method}

The `enum` method creates a `ENUM` equivalent column with the given valid values:

    $table->enum('difficulty', ['easy', 'hard']);

<a name="column-method-float"></a>
#### `float()` {.collection-method}

The `float` method creates a `FLOAT` equivalent column with the given precision:

    $table->float('amount', precision: 53);

<a name="column-method-foreignId"></a>
#### `foreignId()` {.collection-method}

The `foreignId` method creates an `UNSIGNED BIGINT` equivalent column:

    $table->foreignId('user_id');

<a name="column-method-foreignIdFor"></a>
#### `foreignIdFor()` {.collection-method}

The `foreignIdFor` method adds a `{column}_id` equivalent column for a given model class. The column type will be `UNSIGNED BIGINT`, `CHAR(36)`, or `CHAR(26)` depending on the model key type:

    $table->foreignIdFor(User::class);

<a name="column-method-foreignUlid"></a>
#### `foreignUlid()` {.collection-method}

The `foreignUlid` method creates a `ULID` equivalent column:

    $table->foreignUlid('user_id');

<a name="column-method-foreignUuid"></a>
#### `foreignUuid()` {.collection-method}

The `foreignUuid` method creates a `UUID` equivalent column:

    $table->foreignUuid('user_id');

<a name="column-method-geography"></a>
#### `geography()` {.collection-method}

The `geography` method creates a `GEOGRAPHY` equivalent column with the given spatial type and SRID (Spatial Reference System Identifier):

    $table->geography('coordinates', subtype: 'point', srid: 4326);

> [!NOTE]  
> Support for spatial types depends on your database driver. Please refer to your database's documentation. If your application is utilizing a PostgreSQL database, you must install the [PostGIS](https://postgis.net) extension before the `geography` method may be used.

<a name="column-method-geometry"></a>
#### `geometry()` {.collection-method}

The `geometry` method creates a `GEOMETRY` equivalent column with the given spatial type and SRID (Spatial Reference System Identifier):

    $table->geometry('positions', subtype: 'point', srid: 0);

> [!NOTE]  
> Support for spatial types depends on your database driver. Please refer to your database's documentation. If your application is utilizing a PostgreSQL database, you must install the [PostGIS](https://postgis.net) extension before the `geometry` method may be used.

<a name="column-method-id"></a>
#### `id()` {.collection-method}

The `id` method is an alias of the `bigIncrements` method. By default, the method will create an `id` column; however, you may pass a column name if you would like to assign a different name to the column:

    $table->id();

<a name="column-method-increments"></a>
#### `increments()` {.collection-method}

The `increments` method creates an auto-incrementing `UNSIGNED INTEGER` equivalent column as a primary key:

    $table->increments('id');

<a name="column-method-integer"></a>
#### `integer()` {.collection-method}

The `integer` method creates an `INTEGER` equivalent column:

    $table->integer('votes');

<a name="column-method-ipAddress"></a>
#### `ipAddress()` {.collection-method}

The `ipAddress` method creates a `VARCHAR` equivalent column:

    $table->ipAddress('visitor');

When using PostgreSQL, an `INET` column will be created.

<a name="column-method-json"></a>
#### `json()` {.collection-method}

The `json` method creates a `JSON` equivalent column:

    $table->json('options');

<a name="column-method-jsonb"></a>
#### `jsonb()` {.collection-method}

The `jsonb` method creates a `JSONB` equivalent column:

    $table->jsonb('options');

<a name="column-method-longText"></a>
#### `longText()` {.collection-method}

The `longText` method creates a `LONGTEXT` equivalent column:

    $table->longText('description');

When utilizing MySQL or MariaDB, you may apply a `binary` character set to the column in order to create a `LONGBLOB` equivalent column:

    $table->longText('data')->charset('binary'); // LONGBLOB

<a name="column-method-macAddress"></a>
#### `macAddress()` {.collection-method}

The `macAddress` method creates a column that is intended to hold a MAC address. Some database systems, such as PostgreSQL, have a dedicated column type for this type of data. Other database systems will use a string equivalent column:

    $table->macAddress('device');

<a name="column-method-mediumIncrements"></a>
#### `mediumIncrements()` {.collection-method}

The `mediumIncrements` method creates an auto-incrementing `UNSIGNED MEDIUMINT` equivalent column as a primary key:

    $table->mediumIncrements('id');

<a name="column-method-mediumInteger"></a>
#### `mediumInteger()` {.collection-method}

The `mediumInteger` method creates a `MEDIUMINT` equivalent column:

    $table->mediumInteger('votes');

<a name="column-method-mediumText"></a>
#### `mediumText()` {.collection-method}

The `mediumText` method creates a `MEDIUMTEXT` equivalent column:

    $table->mediumText('description');

When utilizing MySQL or MariaDB, you may apply a `binary` character set to the column in order to create a `MEDIUMBLOB` equivalent column:

    $table->mediumText('data')->charset('binary'); // MEDIUMBLOB

<a name="column-method-morphs"></a>
#### `morphs()` {.collection-method}

The `morphs` method is a convenience method that adds a `{column}_id` equivalent column and a `{column}_type` `VARCHAR` equivalent column. The column type for the `{column}_id` will be `UNSIGNED BIGINT`, `CHAR(36)`, or `CHAR(26)` depending on the model key type.

This method is intended to be used when defining the columns necessary for a polymorphic [Eloquent relationship](/docs/{{version}}/eloquent-relationships). In the following example, `taggable_id` and `taggable_type` columns would be created:

    $table->morphs('taggable');

<a name="column-method-nullableTimestamps"></a>
#### `nullableTimestamps()` {.collection-method}

The `nullableTimestamps` method is an alias of the [timestamps](#column-method-timestamps) method:

    $table->nullableTimestamps(precision: 0);

<a name="column-method-nullableMorphs"></a>
#### `nullableMorphs()` {.collection-method}

The method is similar to the [morphs](#column-method-morphs) method; however, the columns that are created will be "nullable":

    $table->nullableMorphs('taggable');

<a name="column-method-nullableUlidMorphs"></a>
#### `nullableUlidMorphs()` {.collection-method}

The method is similar to the [ulidMorphs](#column-method-ulidMorphs) method; however, the columns that are created will be "nullable":

    $table->nullableUlidMorphs('taggable');

<a name="column-method-nullableUuidMorphs"></a>
#### `nullableUuidMorphs()` {.collection-method}

The method is similar to the [uuidMorphs](#column-method-uuidMorphs) method; however, the columns that are created will be "nullable":

    $table->nullableUuidMorphs('taggable');

<a name="column-method-rememberToken"></a>
#### `rememberToken()` {.collection-method}

The `rememberToken` method creates a nullable, `VARCHAR(100)` equivalent column that is intended to store the current "remember me" [authentication token](/docs/{{version}}/authentication#remembering-users):

    $table->rememberToken();

<a name="column-method-set"></a>
#### `set()` {.collection-method}

The `set` method creates a `SET` equivalent column with the given list of valid values:

    $table->set('flavors', ['strawberry', 'vanilla']);

<a name="column-method-smallIncrements"></a>
#### `smallIncrements()` {.collection-method}

The `smallIncrements` method creates an auto-incrementing `UNSIGNED SMALLINT` equivalent column as a primary key:

    $table->smallIncrements('id');

<a name="column-method-smallInteger"></a>
#### `smallInteger()` {.collection-method}

The `smallInteger` method creates a `SMALLINT` equivalent column:

    $table->smallInteger('votes');

<a name="column-method-softDeletesTz"></a>
#### `softDeletesTz()` {.collection-method}

The `softDeletesTz` method adds a nullable `deleted_at` `TIMESTAMP` (with timezone) equivalent column with an optional fractional seconds precision. This column is intended to store the `deleted_at` timestamp needed for Eloquent's "soft delete" functionality:

    $table->softDeletesTz('deleted_at', precision: 0);

<a name="column-method-softDeletes"></a>
#### `softDeletes()` {.collection-method}

The `softDeletes` method adds a nullable `deleted_at` `TIMESTAMP` equivalent column with an optional fractional seconds precision. This column is intended to store the `deleted_at` timestamp needed for Eloquent's "soft delete" functionality:

    $table->softDeletes('deleted_at', precision: 0);

<a name="column-method-string"></a>
#### `string()` {.collection-method}

The `string` method creates a `VARCHAR` equivalent column of the given length:

    $table->string('name', length: 100);

<a name="column-method-text"></a>
#### `text()` {.collection-method}

The `text` method creates a `TEXT` equivalent column:

    $table->text('description');

When utilizing MySQL or MariaDB, you may apply a `binary` character set to the column in order to create a `BLOB` equivalent column:

    $table->text('data')->charset('binary'); // BLOB

<a name="column-method-timeTz"></a>
#### `timeTz()` {.collection-method}

The `timeTz` method creates a `TIME` (with timezone) equivalent column with an optional fractional seconds precision:

    $table->timeTz('sunrise', precision: 0);

<a name="column-method-time"></a>
#### `time()` {.collection-method}

The `time` method creates a `TIME` equivalent column with an optional fractional seconds precision:

    $table->time('sunrise', precision: 0);

<a name="column-method-timestampTz"></a>
#### `timestampTz()` {.collection-method}

The `timestampTz` method creates a `TIMESTAMP` (with timezone) equivalent column with an optional fractional seconds precision:

    $table->timestampTz('added_at', precision: 0);

<a name="column-method-timestamp"></a>
#### `timestamp()` {.collection-method}

The `timestamp` method creates a `TIMESTAMP` equivalent column with an optional fractional seconds precision:

    $table->timestamp('added_at', precision: 0);

<a name="column-method-timestampsTz"></a>
#### `timestampsTz()` {.collection-method}

The `timestampsTz` method creates `created_at` and `updated_at` `TIMESTAMP` (with timezone) equivalent columns with an optional fractional seconds precision:

    $table->timestampsTz(precision: 0);

<a name="column-method-timestamps"></a>
#### `timestamps()` {.collection-method}

The `timestamps` method creates `created_at` and `updated_at` `TIMESTAMP` equivalent columns with an optional fractional seconds precision:

    $table->timestamps(precision: 0);

<a name="column-method-tinyIncrements"></a>
#### `tinyIncrements()` {.collection-method}

The `tinyIncrements` method creates an auto-incrementing `UNSIGNED TINYINT` equivalent column as a primary key:

    $table->tinyIncrements('id');

<a name="column-method-tinyInteger"></a>
#### `tinyInteger()` {.collection-method}

The `tinyInteger` method creates a `TINYINT` equivalent column:

    $table->tinyInteger('votes');

<a name="column-method-tinyText"></a>
#### `tinyText()` {.collection-method}

The `tinyText` method creates a `TINYTEXT` equivalent column:

    $table->tinyText('notes');

When utilizing MySQL or MariaDB, you may apply a `binary` character set to the column in order to create a `TINYBLOB` equivalent column:

    $table->tinyText('data')->charset('binary'); // TINYBLOB

<a name="column-method-unsignedBigInteger"></a>
#### `unsignedBigInteger()` {.collection-method}

The `unsignedBigInteger` method creates an `UNSIGNED BIGINT` equivalent column:

    $table->unsignedBigInteger('votes');

<a name="column-method-unsignedInteger"></a>
#### `unsignedInteger()` {.collection-method}

The `unsignedInteger` method creates an `UNSIGNED INTEGER` equivalent column:

    $table->unsignedInteger('votes');

<a name="column-method-unsignedMediumInteger"></a>
#### `unsignedMediumInteger()` {.collection-method}

The `unsignedMediumInteger` method creates an `UNSIGNED MEDIUMINT` equivalent column:

    $table->unsignedMediumInteger('votes');

<a name="column-method-unsignedSmallInteger"></a>
#### `unsignedSmallInteger()` {.collection-method}

The `unsignedSmallInteger` method creates an `UNSIGNED SMALLINT` equivalent column:

    $table->unsignedSmallInteger('votes');

<a name="column-method-unsignedTinyInteger"></a>
#### `unsignedTinyInteger()` {.collection-method}

The `unsignedTinyInteger` method creates an `UNSIGNED TINYINT` equivalent column:

    $table->unsignedTinyInteger('votes');

<a name="column-method-ulidMorphs"></a>
#### `ulidMorphs()` {.collection-method}

The `ulidMorphs` method is a convenience method that adds a `{column}_id` `CHAR(26)` equivalent column and a `{column}_type` `VARCHAR` equivalent column.

This method is intended to be used when defining the columns necessary for a polymorphic [Eloquent relationship](/docs/{{version}}/eloquent-relationships) that use ULID identifiers. In the following example, `taggable_id` and `taggable_type` columns would be created:

    $table->ulidMorphs('taggable');

<a name="column-method-uuidMorphs"></a>
#### `uuidMorphs()` {.collection-method}

The `uuidMorphs` method is a convenience method that adds a `{column}_id` `CHAR(36)` equivalent column and a `{column}_type` `VARCHAR` equivalent column.

This method is intended to be used when defining the columns necessary for a polymorphic [Eloquent relationship](/docs/{{version}}/eloquent-relationships) that use UUID identifiers. In the following example, `taggable_id` and `taggable_type` columns would be created:

    $table->uuidMorphs('taggable');

<a name="column-method-ulid"></a>
#### `ulid()` {.collection-method}

The `ulid` method creates a `ULID` equivalent column:

    $table->ulid('id');

<a name="column-method-uuid"></a>
#### `uuid()` {.collection-method}

The `uuid` method creates a `UUID` equivalent column:

    $table->uuid('id');

<a name="column-method-year"></a>
#### `year()` {.collection-method}

The `year` method creates a `YEAR` equivalent column:

    $table->year('birth_year');

<a name="column-modifiers"></a>
### Column Modifiers

In addition to the column types listed above, there are several column "modifiers" you may use when adding a column to a database table. For example, to make the column "nullable", you may use the `nullable` method:

    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    Schema::table('users', function (Blueprint $table) {
        $table->string('email')->nullable();
    });

The following table contains all of the available column modifiers. This list does not include [index modifiers](#creating-indexes):

<div class="overflow-auto">

| Modifier                            | Description                                                                                    |
| ----------------------------------- | ---------------------------------------------------------------------------------------------- |
| `->after('column')`                 | Place the column "after" another column (MariaDB / MySQL).                                     |
| `->autoIncrement()`                 | Set `INTEGER` columns as auto-incrementing (primary key).                                      |
| `->charset('utf8mb4')`              | Specify a character set for the column (MariaDB / MySQL).                                      |
| `->collation('utf8mb4_unicode_ci')` | Specify a collation for the column.                                                            |
| `->comment('my comment')`           | Add a comment to a column (MariaDB / MySQL / PostgreSQL).                                      |
| `->default($value)`                 | Specify a "default" value for the column.                                                      |
| `->first()`                         | Place the column "first" in the table (MariaDB / MySQL).                                       |
| `->from($integer)`                  | Set the starting value of an auto-incrementing field (MariaDB / MySQL / PostgreSQL).           |
| `->invisible()`                     | Make the column "invisible" to `SELECT *` queries (MariaDB / MySQL).                           |
| `->nullable($value = true)`         | Allow `NULL` values to be inserted into the column.                                            |
| `->storedAs($expression)`           | Create a stored generated column (MariaDB / MySQL / PostgreSQL / SQLite).                      |
| `->unsigned()`                      | Set `INTEGER` columns as `UNSIGNED` (MariaDB / MySQL).                                         |
| `->useCurrent()`                    | Set `TIMESTAMP` columns to use `CURRENT_TIMESTAMP` as default value.                           |
| `->useCurrentOnUpdate()`            | Set `TIMESTAMP` columns to use `CURRENT_TIMESTAMP` when a record is updated (MariaDB / MySQL). |
| `->virtualAs($expression)`          | Create a virtual generated column (MariaDB / MySQL / SQLite).                                  |
| `->generatedAs($expression)`        | Create an identity column with specified sequence options (PostgreSQL).                        |
| `->always()`                        | Defines the precedence of sequence values over input for an identity column (PostgreSQL).      |

</div>

<a name="default-expressions"></a>
#### Default Expressions

The `default` modifier accepts a value or an `Illuminate\Database\Query\Expression` instance. Using an `Expression` instance will prevent Laravel from wrapping the value in quotes and allow you to use database specific functions. One situation where this is particularly useful is when you need to assign default values to JSON columns:

    <?php

    use Illuminate\Support\Facades\Schema;
    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Database\Query\Expression;
    use Illuminate\Database\Migrations\Migration;

    return new class extends Migration
    {
        /**
         * Run the migrations.
         */
        public function up(): void
        {
            Schema::create('flights', function (Blueprint $table) {
                $table->id();
                $table->json('movies')->default(new Expression('(JSON_ARRAY())'));
                $table->timestamps();
            });
        }
    };

> [!WARNING]  
> Support for default expressions depends on your database driver, database version, and the field type. Please refer to your database's documentation.

<a name="column-order"></a>
#### Column Order

When using the MariaDB or MySQL database, the `after` method may be used to add columns after an existing column in the schema:

    $table->after('password', function (Blueprint $table) {
        $table->string('address_line1');
        $table->string('address_line2');
        $table->string('city');
    });

<a name="modifying-columns"></a>
### Modifying Columns

The `change` method allows you to modify the type and attributes of existing columns. For example, you may wish to increase the size of a `string` column. To see the `change` method in action, let's increase the size of the `name` column from 25 to 50. To accomplish this, we simply define the new state of the column and then call the `change` method:

    Schema::table('users', function (Blueprint $table) {
        $table->string('name', 50)->change();
    });

When modifying a column, you must explicitly include all the modifiers you want to keep on the column definition - any missing attribute will be dropped. For example, to retain the `unsigned`, `default`, and `comment` attributes, you must call each modifier explicitly when changing the column:

    Schema::table('users', function (Blueprint $table) {
        $table->integer('votes')->unsigned()->default(1)->comment('my comment')->change();
    });

The `change` method does not change the indexes of the column. Therefore, you may use index modifiers to explicitly add or drop an index when modifying the column:

```php
// Agregar un índice...
$table->bigIncrements('id')->primary()->change();

// Eliminar un índice...
$table->char('postal_code', 10)->unique(false)->change();
```

<a name="renaming-columns"></a>
### Renombrando Columnas

Para renombrar una columna, puedes usar el método `renameColumn` proporcionado por el constructor de esquemas:

    Schema::table('users', function (Blueprint $table) {
        $table->renameColumn('from', 'to');
    });

<a name="dropping-columns"></a>
### Eliminando Columnas

Para eliminar una columna, puedes usar el método `dropColumn` en el constructor de esquemas:

    Schema::table('users', function (Blueprint $table) {
        $table->dropColumn('votes');
    });

Puedes eliminar múltiples columnas de una tabla pasando un array de nombres de columnas al método `dropColumn`:

    Schema::table('users', function (Blueprint $table) {
        $table->dropColumn(['votes', 'avatar', 'location']);
    });

<a name="available-command-aliases"></a>
#### Alias de Comandos Disponibles

Laravel proporciona varios métodos convenientes relacionados con la eliminación de tipos comunes de columnas. Cada uno de estos métodos se describe en la tabla a continuación:

<div class="overflow-auto">

| Comando                             | Descripción                                           |
| ----------------------------------- | ----------------------------------------------------- |
| `$table->dropMorphs('morphable');`  | Eliminar las columnas `morphable_id` y `morphable_type`. |
| `$table->dropRememberToken();`      | Eliminar la columna `remember_token`.                     |
| `$table->dropSoftDeletes();`        | Eliminar la columna `deleted_at`.                         |
| `$table->dropSoftDeletesTz();`      | Alias del método `dropSoftDeletes()`.                  |
| `$table->dropTimestamps();`         | Eliminar las columnas `created_at` y `updated_at`.       |
| `$table->dropTimestampsTz();`       | Alias del método `dropTimestamps()`.                   |

</div>

<a name="indexes"></a>
## Índices

<a name="creating-indexes"></a>
### Creando Índices

El constructor de esquemas de Laravel admite varios tipos de índices. El siguiente ejemplo crea una nueva columna `email` y especifica que sus valores deben ser únicos. Para crear el índice, podemos encadenar el método `unique` a la definición de la columna:

    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    Schema::table('users', function (Blueprint $table) {
        $table->string('email')->unique();
    });

Alternativamente, puedes crear el índice después de definir la columna. Para hacerlo, debes llamar al método `unique` en el plano del constructor de esquemas. Este método acepta el nombre de la columna que debe recibir un índice único:

    $table->unique('email');

Incluso puedes pasar un array de columnas a un método de índice para crear un índice compuesto (o combinado):

    $table->index(['account_id', 'created_at']);

Al crear un índice, Laravel generará automáticamente un nombre de índice basado en la tabla, los nombres de las columnas y el tipo de índice, pero puedes pasar un segundo argumento al método para especificar el nombre del índice tú mismo:

    $table->unique('email', 'unique_email');

<a name="available-index-types"></a>
#### Tipos de Índices Disponibles

La clase de plano del constructor de esquemas de Laravel proporciona métodos para crear cada tipo de índice admitido por Laravel. Cada método de índice acepta un segundo argumento opcional para especificar el nombre del índice. Si se omite, el nombre se derivará de los nombres de la tabla y las columnas utilizadas para el índice, así como del tipo de índice. Cada uno de los métodos de índice disponibles se describe en la tabla a continuación:

<div class="overflow-auto">

| Comando                                          | Descripción                                                    |
| ------------------------------------------------ | -------------------------------------------------------------- |
| `$table->primary('id');`                         | Agrega una clave primaria.                                    |
| `$table->primary(['id', 'parent_id']);`          | Agrega claves compuestas.                                     |
| `$table->unique('email');`                       | Agrega un índice único.                                       |
| `$table->index('state');`                        | Agrega un índice.                                             |
| `$table->fullText('body');`                      | Agrega un índice de texto completo (MariaDB / MySQL / PostgreSQL). |
| `$table->fullText('body')->language('english');` | Agrega un índice de texto completo del idioma especificado (PostgreSQL). |
| `$table->spatialIndex('location');`              | Agrega un índice espacial (excepto SQLite).                   |

</div>

<a name="renaming-indexes"></a>
### Renombrando Índices

Para renombrar un índice, puedes usar el método `renameIndex` proporcionado por el plano del constructor de esquemas. Este método acepta el nombre actual del índice como su primer argumento y el nombre deseado como su segundo argumento:

    $table->renameIndex('from', 'to')

<a name="dropping-indexes"></a>
### Eliminando Índices

Para eliminar un índice, debes especificar el nombre del índice. Por defecto, Laravel asigna automáticamente un nombre de índice basado en el nombre de la tabla, el nombre de la columna indexada y el tipo de índice. Aquí hay algunos ejemplos:

<div class="overflow-auto">

| Comando                                                  | Descripción                                                 |
| -------------------------------------------------------- | ----------------------------------------------------------- |
| `$table->dropPrimary('users_id_primary');`               | Eliminar una clave primaria de la tabla "users".           |
| `$table->dropUnique('users_email_unique');`              | Eliminar un índice único de la tabla "users".              |
| `$table->dropIndex('geo_state_index');`                  | Eliminar un índice básico de la tabla "geo".               |
| `$table->dropFullText('posts_body_fulltext');`           | Eliminar un índice de texto completo de la tabla "posts".   |
| `$table->dropSpatialIndex('geo_location_spatialindex');` | Eliminar un índice espacial de la tabla "geo" (excepto SQLite). |

</div>

Si pasas un array de columnas a un método que elimina índices, el nombre de índice convencional se generará en función del nombre de la tabla, las columnas y el tipo de índice:

    Schema::table('geo', function (Blueprint $table) {
        $table->dropIndex(['state']); // Elimina el índice 'geo_state_index'
    });

<a name="foreign-key-constraints"></a>
### Restricciones de Clave Foránea

Laravel también proporciona soporte para crear restricciones de clave foránea, que se utilizan para forzar la integridad referencial a nivel de base de datos. Por ejemplo, definamos una columna `user_id` en la tabla `posts` que hace referencia a la columna `id` en una tabla `users`:

    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    Schema::table('posts', function (Blueprint $table) {
        $table->unsignedBigInteger('user_id');

        $table->foreign('user_id')->references('id')->on('users');
    });

Dado que esta sintaxis es bastante verbosa, Laravel proporciona métodos adicionales, más concisos, que utilizan convenciones para ofrecer una mejor experiencia de desarrollo. Al usar el método `foreignId` para crear tu columna, el ejemplo anterior se puede reescribir de la siguiente manera:

    Schema::table('posts', function (Blueprint $table) {
        $table->foreignId('user_id')->constrained();
    });

El método `foreignId` crea una columna equivalente a `UNSIGNED BIGINT`, mientras que el método `constrained` utilizará convenciones para determinar la tabla y la columna que se están referenciando. Si el nombre de tu tabla no coincide con las convenciones de Laravel, puedes proporcionarlo manualmente al método `constrained`. Además, el nombre que se debe asignar al índice generado también puede especificarse:

    Schema::table('posts', function (Blueprint $table) {
        $table->foreignId('user_id')->constrained(
            table: 'users', indexName: 'posts_user_id'
        );
    });

También puedes especificar la acción deseada para las propiedades "on delete" y "on update" de la restricción:

    $table->foreignId('user_id')
          ->constrained()
          ->onUpdate('cascade')
          ->onDelete('cascade');

Una sintaxis alternativa y expresiva también se proporciona para estas acciones:

<div class="overflow-auto">

| Método                        | Descripción                                       |
| ----------------------------- | ------------------------------------------------- |
| `$table->cascadeOnUpdate();`  | Las actualizaciones deben ser en cascada.        |
| `$table->restrictOnUpdate();` | Las actualizaciones deben ser restringidas.       |
| `$table->noActionOnUpdate();` | Sin acción en las actualizaciones.                |
| `$table->cascadeOnDelete();`  | Las eliminaciones deben ser en cascada.          |
| `$table->restrictOnDelete();` | Las eliminaciones deben ser restringidas.         |
| `$table->nullOnDelete();`     | Las eliminaciones deben establecer el valor de la clave foránea en nulo. |

</div>

Cualquier [modificador de columna](#column-modifiers) adicional debe ser llamado antes del método `constrained`:

    $table->foreignId('user_id')
          ->nullable()
          ->constrained();

<a name="dropping-foreign-keys"></a>
#### Eliminando Claves Foráneas

Para eliminar una clave foránea, puedes usar el método `dropForeign`, pasando el nombre de la restricción de clave foránea que se va a eliminar como argumento. Las restricciones de clave foránea utilizan la misma convención de nomenclatura que los índices. En otras palabras, el nombre de la restricción de clave foránea se basa en el nombre de la tabla y las columnas en la restricción, seguido de un sufijo "\_foreign":

    $table->dropForeign('posts_user_id_foreign');

Alternativamente, puedes pasar un array que contenga el nombre de la columna que tiene la clave foránea al método `dropForeign`. El array se convertirá en un nombre de restricción de clave foránea utilizando las convenciones de nomenclatura de restricciones de Laravel:

    $table->dropForeign(['user_id']);

<a name="toggling-foreign-key-constraints"></a>
#### Alternando Restricciones de Clave Foránea

Puedes habilitar o deshabilitar las restricciones de clave foránea dentro de tus migraciones utilizando los siguientes métodos:

    Schema::enableForeignKeyConstraints();

    Schema::disableForeignKeyConstraints();

    Schema::withoutForeignKeyConstraints(function () {
        // Restricciones deshabilitadas dentro de esta función anónima...
    });

> [!WARNING]  
> SQLite desactiva las restricciones de clave foránea por defecto. Al usar SQLite, asegúrate de [habilitar el soporte de clave foránea](/docs/{{version}}/database#configuration) en la configuración de tu base de datos antes de intentar crearlas en tus migraciones. Además, SQLite solo admite claves foráneas al crear la tabla y [no cuando se alteran tablas](https://www.sqlite.org/omitted.html).

<a name="events"></a>
## Eventos

Para conveniencia, cada operación de migración despachará un [evento](/docs/{{version}}/events). Todos los siguientes eventos extienden la clase base `Illuminate\Database\Events\MigrationEvent`:

<div class="overflow-auto">

| Clase                                            | Descripción                                      |
| ------------------------------------------------ | ------------------------------------------------ |
| `Illuminate\Database\Events\MigrationsStarted`   | Un lote de migraciones está a punto de ejecutarse. |
| `Illuminate\Database\Events\MigrationsEnded`     | Un lote de migraciones ha terminado de ejecutarse. |
| `Illuminate\Database\Events\MigrationStarted`    | Una sola migración está a punto de ejecutarse.   |
| `Illuminate\Database\Events\MigrationEnded`      | Una sola migración ha terminado de ejecutarse.    |
| `Illuminate\Database\Events\NoPendingMigrations` | Un comando de migración no encontró migraciones pendientes. |
| `Illuminate\Database\Events\SchemaDumped`        | Un volcado de esquema de base de datos se ha completado. |
| `Illuminate\Database\Events\SchemaLoaded`        | Un volcado de esquema de base de datos existente se ha cargado. |

</div>
