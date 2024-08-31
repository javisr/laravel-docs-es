# Base de datos: Migraciones

- [Introducción](#introduction)
- [Generando Migraciones](#generating-migrations)
  - [Fusionando Migraciones](#squashing-migrations)
- [Estructura de la Migración](#migration-structure)
- [Ejecutando Migraciones](#running-migrations)
  - [Revirtiendo Migraciones](#rolling-back-migrations)
- [Tablas](#tables)
  - [Creando Tablas](#creating-tables)
  - [Actualizando Tablas](#updating-tables)
  - [Renombrando / Eliminando Tablas](#renaming-and-dropping-tables)
- [Columnas](#columns)
  - [Creando Columnas](#creating-columns)
  - [Tipos de Columna Disponibles](#available-column-types)
  - [Modificadores de Columna](#column-modifiers)
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

Las migraciones son como control de versiones para tu base de datos, lo que permite a tu equipo definir y compartir la definición del esquema de la base de datos de la aplicación. Si alguna vez has tenido que decirle a un compañero de equipo que añada manualmente una columna a su esquema de base de datos local después de incorporar tus cambios desde el control de versiones, has enfrentado el problema que las migraciones de base de datos resuelven.
La `Schema` [facade](/docs/%7B%7Bversion%7D%7D/facades) de Laravel proporciona soporte agnóstico a bases de datos para crear y manipular tablas en todos los sistemas de bases de datos admitidos por Laravel. Típicamente, las migraciones utilizarán esta fachada para crear y modificar tablas y columnas de base de datos.

<a name="generating-migrations"></a>
## Generando Migraciones

Puedes usar el comando [Artisan `make:migration`](/docs/{{version}}/artisan) para generar una migración de base de datos. La nueva migración se colocará en tu directorio `database/migrations`. Cada nombre de archivo de migración contiene una marca de tiempo que permite a Laravel determinar el orden de las migraciones:


```shell
php artisan make:migration create_flights_table

```
Laravel utilizará el nombre de la migración para intentar adivinar el nombre de la tabla y si la migración creará o no una nueva tabla. Si Laravel puede determinar el nombre de la tabla a partir del nombre de la migración, Laravel rellenará automáticamente el archivo de migración generado con la tabla especificada. De lo contrario, puedes especificar la tabla en el archivo de migración manualmente.
Si deseas especificar una ruta personalizada para la migración generada, puedes utilizar la opción `--path` al ejecutar el comando `make:migration`. La ruta dada debe ser relativa a la ruta base de tu aplicación.
> [!NOTA]
Los stubs de migración se pueden personalizar utilizando [la publicación de stubs](/docs/%7B%7Bversion%7D%7D/artisan#stub-customization).

<a name="squashing-migrations"></a>
### Aplanando Migraciones

A medida que construyes tu aplicación, es posible que acumules más y más migraciones con el tiempo. Esto puede llevar a que tu directorio `database/migrations` se vuelva engorroso con potencialmente cientos de migraciones. Si lo deseas, puedes "compactar" tus migraciones en un solo archivo SQL. Para comenzar, ejecuta el comando `schema:dump`:


```shell
php artisan schema:dump

# Dump the current database schema and prune all existing migrations...
php artisan schema:dump --prune

```
Cuando ejecutes este comando, Laravel escribirá un archivo "schema" en el directorio `database/schema` de tu aplicación. El nombre del archivo de esquema corresponderá a la conexión de base de datos. Ahora, cuando intentes migrar tu base de datos y no se hayan ejecutado otras migraciones, Laravel primero ejecutará las sentencias SQL en el archivo de esquema de la conexión de base de datos que estás utilizando. Después de ejecutar las sentencias SQL del archivo de esquema, Laravel ejecutará cualquier migración restante que no formara parte del volcado del esquema.
Si las pruebas de tu aplicación utilizan una conexión de base de datos diferente a la que sueles usar durante el desarrollo local, debes asegurarte de haber volcado un archivo de esquema utilizando esa conexión de base de datos para que tus pruebas puedan construir tu base de datos. Es posible que desees hacer esto después de volcar la conexión de base de datos que sueles usar durante el desarrollo local:


```shell
php artisan schema:dump
php artisan schema:dump --database=testing --prune

```
Debes comprometer el archivo del esquema de tu base de datos al control de versiones para que otros desarrolladores nuevos en tu equipo puedan crear rápidamente la estructura de base de datos inicial de tu aplicación.
> [!WARNING]
La compactación de migraciones solo está disponible para las bases de datos MariaDB, MySQL, PostgreSQL y SQLite y utiliza el cliente de línea de comandos de la base de datos.

<a name="migration-structure"></a>
## Estructura de Migración

Una clase de migración contiene dos métodos: `up` y `down`. El método `up` se utiliza para agregar nuevas tablas, columnas o índices a tu base de datos, mientras que el método `down` debe revertir las operaciones realizadas por el método `up`.
Dentro de ambos métodos, puedes usar el constructor de esquema de Laravel para crear y modificar tablas de manera expresiva. Para aprender sobre todos los métodos disponibles en el constructor `Schema`, [consulta su documentación](#creating-tables). Por ejemplo, la siguiente migración crea una tabla `flights`:


```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
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
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::drop('flights');
    }
};
```

<a name="setting-the-migration-connection"></a>
#### Configurando la Conexión de Migración

Si tu migración estará interactuando con una conexión a base de datos diferente de la conexión a base de datos predeterminada de tu aplicación, deberías establecer la propiedad `$connection` de tu migración:


```php
/**
 * The database connection that should be used by the migration.
 *
 * @var string
 */
protected $connection = 'pgsql';

/**
 * Run the migrations.
 */
public function up(): void
{
    // ...
}
```

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
Si deseas ver las declaraciones SQL que se ejecutarán mediante las migraciones sin ejecutarlas realmente, puedes proporcionar la bandera `--pretend` al comando `migrate`:


```shell
php artisan migrate --pretend

```
#### Aislar la Ejecución de Migraciones

Si estás desplegando tu aplicación en múltiples servidores y ejecutando migraciones como parte de tu proceso de despliegue, es probable que no quieras que dos servidores intenten migrar la base de datos al mismo tiempo. Para evitar esto, puedes usar la opción `isolated` al invocar el comando `migrate`.
Cuando se proporciona la opción `isolated`, Laravel adquirirá un bloqueo atómico utilizando el driver de caché de tu aplicación antes de intentar ejecutar tus migraciones. Todos los otros intentos de ejecutar el comando `migrate` mientras se mantiene ese bloqueo no se ejecutarán; sin embargo, el comando todavía saldrá con un código de estado de salida exitoso:


```shell
php artisan migrate --isolated

```
> [!WARNING]
Para utilizar esta función, tu aplicación debe estar utilizando el driver de caché `memcached`, `redis`, `dynamodb`, `database`, `file` o `array` como el driver de caché predeterminado de tu aplicación. Además, todos los servidores deben estar comunicándose con el mismo servidor de caché central.

<a name="forcing-migrations-to-run-in-production"></a>
#### Forzar la Ejecución de Migraciones en Producción

Algunas operaciones de migración son destructivas, lo que significa que pueden hacer que pierdas datos. Para protegerte de ejecutar estos comandos en tu base de datos de producción, se te pedirá confirmación antes de que se ejecuten los comandos. Para forzar la ejecución de los comandos sin un aviso, usa el flag `--force`:


```shell
php artisan migrate --force

```

<a name="rolling-back-migrations"></a>
### Revirtiendo Migraciones

Para deshacer la última operación de migración, puedes usar el comando Artisan `rollback`. Este comando deshace el último "lote" de migraciones, que puede incluir varios archivos de migración:


```shell
php artisan migrate:rollback

```
Puedes revertir un número limitado de migraciones proporcionando la opción `step` al comando `rollback`. Por ejemplo, el siguiente comando revertirá las últimas cinco migraciones:


```shell
php artisan migrate:rollback --step=5

```
Puedes revertir un "batch" específico de migraciones proporcionando la opción `batch` al comando `rollback`, donde la opción `batch` corresponde a un valor de lote dentro de la tabla `migrations` de la base de datos de tu aplicación. Por ejemplo, el siguiente comando revertirá todas las migraciones en el lote tres:
 ```shell
 php artisan migrate:rollback --batch=3

 ```
Si deseas ver las declaraciones SQL que se ejecutarán mediante las migraciones sin realmente ejecutarlas, puedes proporcionar el flag `--pretend` al comando `migrate:rollback`:


```shell
php artisan migrate:rollback --pretend

```
El comando `migrate:reset` revertirá todas las migraciones de tu aplicación:


```shell
php artisan migrate:reset

```

<a name="roll-back-migrate-using-a-single-command"></a>
#### Revertir y migrar utilizando un solo comando

El comando `migrate:refresh` revertirá todas tus migraciones y luego ejecutará el comando `migrate`. Este comando efectivamente vuelve a crear toda tu base de datos:


```shell
php artisan migrate:refresh

# Refresh the database and run all database seeds...
php artisan migrate:refresh --seed

```
Puedes deshacer y reiniciar un número limitado de migraciones proporcionando la opción `step` al comando `refresh`. Por ejemplo, el siguiente comando deshará y volverá a migrar las últimas cinco migraciones:


```shell
php artisan migrate:refresh --step=5

```

<a name="drop-all-tables-migrate"></a>
#### Eliminar todas las tablas y migrar

El comando `migrate:fresh` eliminará todas las tablas de la base de datos y luego ejecutará el comando `migrate`:


```shell
php artisan migrate:fresh

php artisan migrate:fresh --seed

```
Por defecto, el comando `migrate:fresh` solo elimina tablas de la conexión de base de datos predeterminada. Sin embargo, puedes usar la opción `--database` para especificar la conexión de base de datos que se debe migrar. El nombre de la conexión de base de datos debe corresponder a una conexión definida en el archivo de configuración `database` de tu aplicación [configuración](/docs/%7B%7Bversion%7D%7D/configuration):


```shell
php artisan migrate:fresh --database=admin

```
> [!WARNING]
El comando `migrate:fresh` eliminará todas las tablas de la base de datos sin importar su prefijo. Este comando debe usarse con precaución al desarrollar en una base de datos que se comparte con otras aplicaciones.

<a name="tables"></a>
## Tablas


<a name="creating-tables"></a>
### Creando Tablas

Para crear una nueva tabla de base de datos, utiliza el método `create` en la fachada `Schema`. El método `create` acepta dos argumentos: el primero es el nombre de la tabla, mientras que el segundo es una función anónima que recibe un objeto `Blueprint` que se puede usar para definir la nueva tabla:


```php
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('email');
    $table->timestamps();
});
```
Al crear la tabla, puedes usar cualquiera de los [métodos de columna](#creating-columns) del generador de esquemas para definir las columnas de la tabla.

<a name="determining-table-column-existence"></a>
#### Determinando la Existencia de una Tabla / Columna

Puedes determinar la existencia de una tabla, columna o índice utilizando los métodos `hasTable`, `hasColumn` y `hasIndex`:


```php
if (Schema::hasTable('users')) {
    // The "users" table exists...
}

if (Schema::hasColumn('users', 'email')) {
    // The "users" table exists and has an "email" column...
}

if (Schema::hasIndex('users', ['email'], 'unique')) {
    // The "users" table exists and has a unique index on the "email" column...
}
```

<a name="database-connection-table-options"></a>
#### Conexión a la base de datos y opciones de tabla

Si deseas realizar una operación de esquema en una conexión de base de datos que no sea la conexión predeterminada de tu aplicación, utiliza el método `connection`:


```php
Schema::connection('sqlite')->create('users', function (Blueprint $table) {
    $table->id();
});
```
Además, se pueden usar algunas otras propiedades y métodos para definir otros aspectos de la creación de la tabla. La propiedad `engine` se puede utilizar para especificar el motor de almacenamiento de la tabla al utilizar MariaDB o MySQL:


```php
Schema::create('users', function (Blueprint $table) {
    $table->engine('InnoDB');

    // ...
});
```
Las propiedades `charset` y `collation` se pueden utilizar para especificar el conjunto de caracteres y la intercalación para la tabla creada al usar MariaDB o MySQL:


```php
Schema::create('users', function (Blueprint $table) {
    $table->charset('utf8mb4');
    $table->collation('utf8mb4_unicode_ci');

    // ...
});
```
El método `temporary` se puede utilizar para indicar que la tabla debe ser "temporal". Las tablas temporales solo son visibles para la sesión de base de datos de la conexión actual y se eliminan automáticamente cuando se cierra la conexión:


```php
Schema::create('calculations', function (Blueprint $table) {
    $table->temporary();

    // ...
});
```
Si deseas añadir un "comentario" a una tabla de base de datos, puedes invocar el método `comment` en la instancia de la tabla. Los comentarios de tabla son actualmente solo soportados por MariaDB, MySQL y PostgreSQL:


```php
Schema::create('calculations', function (Blueprint $table) {
    $table->comment('Business calculations');

    // ...
});
```

<a name="updating-tables"></a>
### Actualizando Tablas

El método `table` en la fachada `Schema` se puede usar para actualizar tablas existentes. Al igual que el método `create`, el método `table` acepta dos argumentos: el nombre de la tabla y una función anónima que recibe una instancia de `Blueprint` que puedes usar para añadir columnas o índices a la tabla:

<a name="renaming-and-dropping-tables"></a>
### Renombrando / Eliminando Tablas

Para renombrar una tabla de base de datos existente, utiliza el método `rename`:


```php
use Illuminate\Support\Facades\Schema;

Schema::rename($from, $to);
```
Para eliminar una tabla existente, puedes usar los métodos `drop` o `dropIfExists`:


```php
Schema::drop('users');

Schema::dropIfExists('users');
```

<a name="renaming-tables-with-foreign-keys"></a>
#### Renombrando Tablas Con Claves Foráneas

Antes de renombrar una tabla, debes verificar que cualquier restricción de clave externa en la tabla tenga un nombre explícito en tus archivos de migración en lugar de dejar que Laravel asigne un nombre basado en convención. De lo contrario, el nombre de la restricción de clave externa se referirá al antiguo nombre de la tabla.

<a name="columns"></a>
## Columnas


<a name="creating-columns"></a>
### Creando Columnas

El método `table` en la fachada `Schema` se puede usar para actualizar tablas existentes. Al igual que el método `create`, el método `table` acepta dos argumentos: el nombre de la tabla y una función anónima que recibe una instancia de `Illuminate\Database\Schema\Blueprint` que puedes usar para agregar columnas a la tabla:


```php
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

Schema::table('users', function (Blueprint $table) {
    $table->integer('votes');
});
```

<a name="available-column-types"></a>
### Tipos de Columnas Disponibles

El esquema de la construcción de planos ofrece una variedad de métodos que corresponden a los diferentes tipos de columnas que puedes añadir a tus tablas de base de datos. Cada uno de los métodos disponibles se enumera en la tabla a continuación:
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

El método `bigIncrements` crea una columna equivalente `UNSIGNED BIGINT` (clave primaria) que se auto-incrementa:


```php
$table->bigIncrements('id');
```

<a name="column-method-bigInteger"></a>
#### `bigInteger()` {.collection-method}


El método `bigInteger` crea una columna equivalente a `BIGINT`:


```php
$table->bigInteger('votes');
```

<a name="column-method-binary"></a>
#### `binary()` {.collection-method}


El método `binary` crea una columna equivalente a `BLOB`:


```php
$table->binary('photo');
```
Al utilizar MySQL, MariaDB o SQL Server, puedes pasar los argumentos `length` y `fixed` para crear una columna equivalente a `VARBINARY` o `BINARY`:


```php
$table->binary('data', length: 16); // VARBINARY(16)

$table->binary('data', length: 16, fixed: true); // BINARY(16)
```

<a name="column-method-boolean"></a>
#### `boolean()` {.collection-method}


El método `boolean` crea una columna equivalente a `BOOLEAN`:


```php
$table->boolean('confirmed');
```

<a name="column-method-char"></a>
#### `char()` {.collection-method}


El método `char` crea una columna equivalente a `CHAR` con una longitud dada:


```php
$table->char('name', length: 100);
```

<a name="column-method-dateTimeTz"></a>
#### `dateTimeTz()` {.collection-method}


El método `dateTimeTz` crea una columna equivalente a `DATETIME` (con zona horaria) con una precisión opcional de segundos fraccionarios:


```php
$table->dateTimeTz('created_at', precision: 0);
```

<a name="column-method-dateTime"></a>
#### `dateTime()` {.collection-method}


El método `dateTime` crea una columna equivalente a `DATETIME` con una precisión opcional de segundos fraccionarios:


```php
$table->dateTime('created_at', precision: 0);
```

<a name="column-method-date"></a>
#### `date()` {.collection-method}


El método `date` crea una columna equivalente a `DATE`:


```php
$table->date('created_at');
```

<a name="column-method-decimal"></a>
#### `decimal()` {.collection-method}


El método `decimal` crea una columna equivalente a `DECIMAL` con la precisión dada (dígitos totales) y la escala (dígitos decimales):


```php
$table->decimal('amount', total: 8, places: 2);
```

<a name="column-method-double"></a>
#### `double()` {.collection-method}


El método `double` crea una columna equivalente a `DOUBLE`:


```php
$table->double('amount');
```

<a name="column-method-enum"></a>
#### `enum()` {.collection-method}


El método `enum` crea una columna equivalente a `ENUM` con los valores válidos dados:


```php
$table->enum('difficulty', ['easy', 'hard']);
```

<a name="column-method-float"></a>
#### `float()` {.collection-method}


El método `float` crea una columna equivalente a `FLOAT` con la precisión dada:


```php
$table->float('amount', precision: 53);
```

<a name="column-method-foreignId"></a>
#### `foreignId()` {.collection-method}


El método `foreignId` crea una columna equivalente a `UNSIGNED BIGINT`:


```php
$table->foreignId('user_id');
```

<a name="column-method-foreignIdFor"></a>
#### `foreignIdFor()` {.collection-method}


El método `foreignIdFor` añade una columna equivalente `{column}_id` para una clase de modelo dada. El tipo de columna será `UNSIGNED BIGINT`, `CHAR(36)` o `CHAR(26)` dependiendo del tipo de clave del modelo:


```php
$table->foreignIdFor(User::class);
```

<a name="column-method-foreignUlid"></a>
#### `foreignUlid()` {.collection-method}


El método `foreignUlid` crea una columna equivalente a `ULID`:


```php
$table->foreignUlid('user_id');
```

<a name="column-method-foreignUuid"></a>
#### `foreignUuid()` {.collection-method}


El método `foreignUuid` crea una columna equivalente a `UUID`:


```php
$table->foreignUuid('user_id');
```

<a name="column-method-geography"></a>
#### `geography()` {.collection-method}


El método `geography` crea una columna equivalente a `GEOGRAPHY` con el tipo espacial dado y el SRID (Identificador del Sistema de Referencia Espacial) dado:


```php
$table->geography('coordinates', subtype: 'point', srid: 4326);
```
> [!NOTE]
El soporte para tipos espaciales depende de tu driver de base de datos. Consulta la documentación de tu base de datos. Si tu aplicación está utilizando una base de datos PostgreSQL, debes instalar la extensión [PostGIS](https://postgis.net) antes de que se pueda usar el método `geography`.

<a name="column-method-geometry"></a>
#### `geometry()` {.collection-method}


El método `geometry` crea una columna equivalente a `GEOMETRY` con el tipo espacial dado y el SRID (Identificador de Sistema de Referencia Espacial):


```php
$table->geometry('positions', subtype: 'point', srid: 0);
```
> [!NOTE]
El soporte para tipos espaciales depende de tu driver de base de datos. Por favor, consulta la documentación de tu base de datos. Si tu aplicación está utilizando una base de datos PostgreSQL, debes instalar la extensión [PostGIS](https://postgis.net) antes de que se pueda utilizar el método `geometry`.

<a name="column-method-id"></a>
#### `id()` {.collection-method}


El método `id` es un alias del método `bigIncrements`. Por defecto, el método creará una columna `id`; sin embargo, puedes pasar un nombre de columna si deseas asignar un nombre diferente a la columna:


```php
$table->id();
```

<a name="column-method-increments"></a>
#### `increments()` {.collection-method}


El método `increments` crea una columna equivalente a `INTEGER` `UNSIGNED` auto-incremental como clave primaria:


```php
$table->increments('id');
```

<a name="column-method-integer"></a>
#### `integer()` {.collection-method}


El método `integer` crea una columna equivalente a `INTEGER`:


```php
$table->integer('votes');
```

<a name="column-method-ipAddress"></a>
#### `ipAddress()` {.collection-method}


El método `ipAddress` crea una columna equivalente a `VARCHAR`:


```php
$table->ipAddress('visitor');
```
Al utilizar PostgreSQL, se creará una columna `INET`.

<a name="column-method-json"></a>
#### `json()` {.collection-method}


El método `json` crea una columna equivalente a `JSON`:


```php
$table->json('options');
```

<a name="column-method-jsonb"></a>
#### `jsonb()` {.collection-method}


El método `jsonb` crea una columna equivalente a `JSONB`:


```php
$table->jsonb('options');
```

<a name="column-method-longText"></a>
#### `longText()` {.collection-method}


El método `longText` crea una columna equivalente a `LONGTEXT`:


```php
$table->longText('description');
```
Al utilizar MySQL o MariaDB, puedes aplicar un conjunto de caracteres `binary` a la columna para crear una columna equivalente a `LONGBLOB`:


```php
$table->longText('data')->charset('binary'); // LONGBLOB
```

<a name="column-method-macAddress"></a>
#### `macAddress()` {.collection-method}


El método `macAddress` crea una columna que está destinada a contener una dirección MAC. Algunos sistemas de bases de datos, como PostgreSQL, tienen un tipo de columna dedicado para este tipo de datos. Otros sistemas de bases de datos utilizarán una columna equivalente a string:


```php
$table->macAddress('device');
```

<a name="column-method-mediumIncrements"></a>
#### `mediumIncrements()` {.collection-method}


El método `mediumIncrements` crea una columna equivalente `UNSIGNED MEDIUMINT` auto-incremental como clave primaria:


```php
$table->mediumIncrements('id');
```

<a name="column-method-mediumInteger"></a>
#### `mediumInteger()` {.collection-method}


El método `mediumInteger` crea una columna equivalente a `MEDIUMINT`:


```php
$table->mediumInteger('votes');
```

<a name="column-method-mediumText"></a>
#### `mediumText()` {.collection-method}


El método `mediumText` crea una columna equivalente a `MEDIUMTEXT`:


```php
$table->mediumText('description');
```
Al utilizar MySQL o MariaDB, puedes aplicar un conjunto de caracteres `binary` a la columna para crear una columna equivalente a `MEDIUMBLOB`:


```php
$table->mediumText('data')->charset('binary'); // MEDIUMBLOB
```

<a name="column-method-morphs"></a>
#### `morphs()` {.collection-method}


El método `morphs` es un método de conveniencia que añade una columna equivalente `{column}_id` y una columna `VARCHAR` equivalente `{column}_type`. El tipo de columna para el `{column}_id` será `UNSIGNED BIGINT`, `CHAR(36)` o `CHAR(26)`, dependiendo del tipo de clave del modelo.
Este método está destinado a ser utilizado al definir las columnas necesarias para una relación [Eloquent polimórfica](/docs/%7B%7Bversion%7D%7D/eloquent-relationships). En el siguiente ejemplo, se crearían las columnas `taggable_id` y `taggable_type`:


```php
$table->morphs('taggable');
```

<a name="column-method-nullableTimestamps"></a>
#### `nullableTimestamps()` {.collection-method}


El método `nullableTimestamps` es un alias del método [timestamps](#column-method-timestamps):


```php
$table->nullableTimestamps(precision: 0);
```

<a name="column-method-nullableMorphs"></a>
#### `nullableMorphs()` {.collection-method}


El método es similar al método [morphs](#column-method-morphs); sin embargo, las columnas que se crean serán "nullable":


```php
$table->nullableMorphs('taggable');
```

<a name="column-method-nullableUlidMorphs"></a>
#### `nullableUlidMorphs()` {.collection-method}


El método es similar al método [ulidMorphs](#column-method-ulidMorphs); sin embargo, las columnas que se crearán serán "nullable":


```php
$table->nullableUlidMorphs('taggable');
```

<a name="column-method-nullableUuidMorphs"></a>
#### `nullableUuidMorphs()` {.collection-method}


El método es similar al método [uuidMorphs](#column-method-uuidMorphs); sin embargo, las columnas que se crean serán "nullable":


```php
$table->nullableUuidMorphs('taggable');
```

<a name="column-method-rememberToken"></a>
#### `rememberToken()` {.collection-method}


El método `rememberToken` crea una columna equivalente a `VARCHAR(100)` que permite nulos y que está destinada a almacenar el token de autenticación "recuerdame" actual [token de autenticación](/docs/%7B%7Bversion%7D%7D/authentication#remembering-users):


```php
$table->rememberToken();
```

<a name="column-method-set"></a>
#### `set()` {.collection-method}


El método `set` crea una columna equivalente a `SET` con la lista dada de valores válidos:


```php
$table->set('flavors', ['strawberry', 'vanilla']);
```

<a name="column-method-smallIncrements"></a>
#### `smallIncrements()` {.collection-method}


El método `smallIncrements` crea una columna equivalente a `UNSIGNED SMALLINT` de auto-incremento como clave primaria:


```php
$table->smallIncrements('id');
```

<a name="column-method-smallInteger"></a>
#### `smallInteger()` {.collection-method}


El método `smallInteger` crea una columna equivalente a `SMALLINT`:


```php
$table->smallInteger('votes');
```

<a name="column-method-softDeletesTz"></a>
#### `softDeletesTz()` {.collection-method}


El método `softDeletesTz` añade una columna `deleted_at` `TIMESTAMP` (con zona horaria) equivalente y nullable, con una precisión de segundos fraccionarios opcional. Esta columna está destinada a almacenar la marca de tiempo `deleted_at` necesaria para la funcionalidad de "eliminación suave" de Eloquent:


```php
$table->softDeletesTz('deleted_at', precision: 0);
```

<a name="column-method-softDeletes"></a>
#### `softDeletes()` {.collection-method}


El método `softDeletes` añade una columna `TIMESTAMP` equivalente `deleted_at` que admite valores nulos, con una precisión de segundos fraccionarios opcional. Esta columna está destinada a almacenar la marca de tiempo `deleted_at` necesaria para la funcionalidad de "eliminación suave" de Eloquent:


```php
$table->softDeletes('deleted_at', precision: 0);
```

<a name="column-method-string"></a>
#### `string()` {.collection-method}


El método `string` crea una columna equivalente a `VARCHAR` de la longitud dada:


```php
$table->string('name', length: 100);
```

<a name="column-method-text"></a>
#### `text()` {.collection-method}


El método `text` crea una columna equivalente a `TEXT`:


```php
$table->text('description');
```
Al utilizar MySQL o MariaDB, puedes aplicar un conjunto de caracteres `binary` a la columna para crear una columna equivalente a `BLOB`:


```php
$table->text('data')->charset('binary'); // BLOB
```

<a name="column-method-timeTz"></a>
#### `timeTz()` {.collection-method}


El método `timeTz` crea una columna equivalente a `TIME` (con zona horaria) con una precisión de segundos fraccionales opcional:


```php
$table->timeTz('sunrise', precision: 0);
```

<a name="column-method-time"></a>
#### `time()` {.collection-method}


El método `time` crea una columna equivalente a `TIME` con una precisión de segundos fraccionarios opcional:


```php
$table->time('sunrise', precision: 0);
```

<a name="column-method-timestampTz"></a>
#### `timestampTz()` {.collection-method}


El método `timestampTz` crea una columna equivalente a `TIMESTAMP` (con zona horaria) con una precisión de fracciones de segundo opcional:


```php
$table->timestampTz('added_at', precision: 0);
```

<a name="column-method-timestamp"></a>
#### `timestamp()` {.collection-method}


El método `timestamp` crea una columna equivalente a `TIMESTAMP` con una precisión de segundos fraccionarios opcional:


```php
$table->timestamp('added_at', precision: 0);
```

<a name="column-method-timestampsTz"></a>
#### `timestampsTz()` {.collection-method}


El método `timestampsTz` crea columnas equivalentes `created_at` y `updated_at` `TIMESTAMP` (con zona horaria) con una precisión de segundos fraccionarios opcional:


```php
$table->timestampsTz(precision: 0);
```

<a name="column-method-timestamps"></a>
#### `timestamps()` {.collection-method}


El método `timestamps` crea columnas `TIMESTAMP` equivalentes `created_at` y `updated_at` con una precisión de segundos fraccionarios opcional:


```php
$table->timestamps(precision: 0);
```

<a name="column-method-tinyIncrements"></a>
#### `tinyIncrements()` {.collection-method}


El método `tinyIncrements` crea una columna equivalente `UNSIGNED TINYINT` de autoincremento como clave primaria:


```php
$table->tinyIncrements('id');
```

<a name="column-method-tinyInteger"></a>
#### `tinyInteger()` {.collection-method}


El método `tinyInteger` crea una columna equivalente a `TINYINT`:


```php
$table->tinyInteger('votes');
```

<a name="column-method-tinyText"></a>
#### `tinyText()` {.collection-method}


El método `tinyText` crea una columna equivalente a `TINYTEXT`:


```php
$table->tinyText('notes');
```
Al utilizar MySQL o MariaDB, puedes aplicar un conjunto de caracteres `binary` a la columna para crear una columna equivalente a `TINYBLOB`:


```php
$table->tinyText('data')->charset('binary'); // TINYBLOB
```

<a name="column-method-unsignedBigInteger"></a>
#### `unsignedBigInteger()` {.collection-method}


El método `unsignedBigInteger` crea una columna equivalente a `UNSIGNED BIGINT`:


```php
$table->unsignedBigInteger('votes');
```

<a name="column-method-unsignedInteger"></a>
#### `unsignedInteger()` {.collection-method}


El método `unsignedInteger` crea una columna equivalente a `UNSIGNED INTEGER`:


```php
$table->unsignedInteger('votes');
```

<a name="column-method-unsignedMediumInteger"></a>
#### `unsignedMediumInteger()` {.collection-method}


El método `unsignedMediumInteger` crea una columna equivalente a `UNSIGNED MEDIUMINT`:


```php
$table->unsignedMediumInteger('votes');
```

<a name="column-method-unsignedSmallInteger"></a>
#### `unsignedSmallInteger()` {.collection-method}


El método `unsignedSmallInteger` crea una columna equivalente a `UNSIGNED SMALLINT`:


```php
$table->unsignedSmallInteger('votes');
```

<a name="column-method-unsignedTinyInteger"></a>
#### `unsignedTinyInteger()` {.collection-method}


El método `unsignedTinyInteger` crea una columna equivalente a `UNSIGNED TINYINT`:


```php
$table->unsignedTinyInteger('votes');
```

<a name="column-method-ulidMorphs"></a>
#### `ulidMorphs()` {.collection-method}


El método `ulidMorphs` es un método de conveniencia que añade una columna equivalente `{column}_id` `CHAR(26)` y una columna equivalente `{column}_type` `VARCHAR`.
Este método está destinado a ser utilizado al definir las columnas necesarias para una relación [Eloquent polimórfica](/docs/%7B%7Bversion%7D%7D/eloquent-relationships) que utiliza identificadores ULID. En el siguiente ejemplo, se crearían las columnas `taggable_id` y `taggable_type`:


```php
$table->ulidMorphs('taggable');
```

<a name="column-method-uuidMorphs"></a>
#### `uuidMorphs()` {.collection-method}


El método `uuidMorphs` es un método de conveniencia que añade una columna `{column}_id` `CHAR(36)` equivalente y una columna `{column}_type` `VARCHAR` equivalente.
Este método está destinado a utilizarse al definir las columnas necesarias para una [relación Eloquent polimórfica](/docs/%7B%7Bversion%7D%7D/eloquent-relationships) que utiliza identificadores UUID. En el siguiente ejemplo, se crearían las columnas `taggable_id` y `taggable_type`:


```php
$table->uuidMorphs('taggable');
```

<a name="column-method-ulid"></a>
#### `ulid()` {.collection-method}


El método `ulid` crea una columna equivalente a `ULID`:


```php
$table->ulid('id');
```

<a name="column-method-uuid"></a>
#### `uuid()` {.collection-method}


El método `uuid` crea una columna equivalente a `UUID`:


```php
$table->uuid('id');
```

<a name="column-method-year"></a>
#### `year()` {.collection-method}


El método `year` crea una columna equivalente a `YEAR`:


```php
$table->year('birth_year');
```

<a name="column-modifiers"></a>
### Modificadores de Columna

Además de los tipos de columna listados anteriormente, hay varios "modificadores" de columna que puedes usar al agregar una columna a una tabla de base de datos. Por ejemplo, para hacer que la columna sea "nullable", puedes usar el método `nullable`:


```php
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

Schema::table('users', function (Blueprint $table) {
    $table->string('email')->nullable();
});
```
La siguiente tabla contiene todos los modificadores de columna disponibles. Esta lista no incluye [modificadores de índice](#creating-indexes):
<div class="overflow-auto">

| Modificador                          | Descripción                                                                                      |
| ------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `->after('column')`                  | Coloca la columna "después" de otra columna (MariaDB / MySQL).                                  |
| `->autoIncrement()`                  | Establece columnas `INTEGER` como auto-incrementales (clave primaria).                          |
| `->charset('utf8mb4')`               | Especifica un conjunto de caracteres para la columna (MariaDB / MySQL).                         |
| `->collation('utf8mb4_unicode_ci')`  | Especifica una colación para la columna.                                                        |
| `->comment('my comment')`            | Añade un comentario a una columna (MariaDB / MySQL / PostgreSQL).                              |
| `->default($value)`                  | Especifica un valor "por defecto" para la columna.                                             |
| `->first()`                          | Coloca la columna "primera" en la tabla (MariaDB / MySQL).                                     |
| `->from($integer)`                   | Establece el valor inicial de un campo auto-incrementable (MariaDB / MySQL / PostgreSQL).       |
| `->invisible()`                      | Hace que la columna sea "invisible" para consultas `SELECT *` (MariaDB / MySQL).                |
| `->nullable($value = true)`          | Permite que se inserten valores `NULL` en la columna.                                          |
| `->storedAs($expression)`            | Crea una columna generada almacenada (MariaDB / MySQL / PostgreSQL / SQLite).                   |
| `->unsigned()`                       | Establece columnas `INTEGER` como `UNSIGNED` (MariaDB / MySQL).                                 |
| `->useCurrent()`                     | Establece columnas `TIMESTAMP` para usar `CURRENT_TIMESTAMP` como valor por defecto.           |
| `->useCurrentOnUpdate()`             | Establece columnas `TIMESTAMP` para usar `CURRENT_TIMESTAMP` cuando se actualiza un registro (MariaDB / MySQL). |
| `->virtualAs($expression)`           | Crea una columna generada virtual (MariaDB / MySQL / SQLite).                                   |
| `->generatedAs($expression)`         | Crea una columna de identidad con opciones de secuencia especificadas (PostgreSQL).            |
| `->always()`                         | Define la precedencia de los valores de secuencia sobre la entrada para una columna de identidad (PostgreSQL). |
</div>

<a name="default-expressions"></a>
#### Expresiones Predeterminadas

El modificador `default` acepta un valor o una instancia de `Illuminate\Database\Query\Expression`. Usar una instancia de `Expression` evitará que Laravel envuelva el valor entre comillas y te permitirá usar funciones específicas de la base de datos. Una situación donde esto es especialmente útil es cuando necesitas asignar valores predeterminados a columnas JSON:


```php
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
```
> [!WARNING]
El soporte para expresiones por defecto depende de tu driver de base de datos, versión de base de datos y el tipo de campo. Por favor, consulta la documentación de tu base de datos.

<a name="column-order"></a>
#### Orden de Columnas

Al utilizar la base de datos MariaDB o MySQL, el método `after` puede usarse para añadir columnas después de una columna existente en el esquema:


```php
$table->after('password', function (Blueprint $table) {
    $table->string('address_line1');
    $table->string('address_line2');
    $table->string('city');
});
```

<a name="modifying-columns"></a>
### Modificando Columnas

El método `change` te permite modificar el tipo y los atributos de las columnas existentes. Por ejemplo, es posible que desees aumentar el tamaño de una columna `string`. Para ver el método `change` en acción, aumentemos el tamaño de la columna `name` de 25 a 50. Para lograr esto, simplemente definimos el nuevo estado de la columna y luego llamamos al método `change`:


```php
Schema::table('users', function (Blueprint $table) {
    $table->string('name', 50)->change();
});
```
Al modificar una columna, debes incluir explícitamente todos los modificadores que deseas mantener en la definición de la columna; cualquier atributo que falte será eliminado. Por ejemplo, para retener los atributos `unsigned`, `default` y `comment`, debes llamar a cada modificador de forma explícita al cambiar la columna:


```php
Schema::table('users', function (Blueprint $table) {
    $table->integer('votes')->unsigned()->default(1)->comment('my comment')->change();
});
```
El método `change` no cambia los índices de la columna. Por lo tanto, puedes usar modificadores de índice para agregar o eliminar explícitamente un índice al modificar la columna:


```php
// Add an index...
$table->bigIncrements('id')->primary()->change();

// Drop an index...
$table->char('postal_code', 10)->unique(false)->change();

```

<a name="renaming-columns"></a>
### Renombrando Columnas

Para renombrar una columna, puedes usar el método `renameColumn` proporcionado por el constructor de esquemas:


```php
Schema::table('users', function (Blueprint $table) {
    $table->renameColumn('from', 'to');
});
```

<a name="dropping-columns"></a>
### Eliminando Columnas

Para eliminar una columna, puedes usar el método `dropColumn` en el constructor de esquemas:


```php
Schema::table('users', function (Blueprint $table) {
    $table->dropColumn('votes');
});
```
Puedes eliminar múltiples columnas de una tabla pasando un array de nombres de columna al método `dropColumn`:


```php
Schema::table('users', function (Blueprint $table) {
    $table->dropColumn(['votes', 'avatar', 'location']);
});
```

<a name="available-command-aliases"></a>
#### Aliases de Comando Disponibles

Laravel ofrece varios métodos convenientes relacionados con la eliminación de tipos comunes de columnas. Cada uno de estos métodos se describe en la tabla a continuación:
<div class="overflow-auto">

| Comando                            | Descripción                                           |
| ---------------------------------- | ----------------------------------------------------- |
| `$table->dropMorphs('morphable');` | Eliminar las columnas `morphable_id` y `morphable_type`. |
| `$table->dropRememberToken();`     | Eliminar la columna `remember_token`.                  |
| `$table->dropSoftDeletes();`       | Eliminar la columna `deleted_at`.                      |
| `$table->dropSoftDeletesTz();`     | Alias del método `dropSoftDeletes()`.                  |
| `$table->dropTimestamps();`        | Eliminar las columnas `created_at` y `updated_at`.    |
| `$table->dropTimestampsTz();`      | Alias del método `dropTimestamps()`.                   |
</div>

<a name="indexes"></a>
## Índices


<a name="creating-indexes"></a>
### Creando Índices

El constructor de esquemas de Laravel admite varios tipos de índices. El siguiente ejemplo crea una nueva columna `email` y especifica que sus valores deben ser únicos. Para crear el índice, podemos encadenar el método `unique` a la definición de la columna:


```php
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

Schema::table('users', function (Blueprint $table) {
    $table->string('email')->unique();
});
```
Alternativamente, puedes crear el índice después de definir la columna. Para hacerlo, debes llamar al método `unique` en el plano del generador de esquemas. Este método acepta el nombre de la columna que debe recibir un índice único:


```php
$table->unique('email');
```
Puedes incluso pasar un array de columnas a un método de índice para crear un índice compuesto:


```php
$table->index(['account_id', 'created_at']);
```
Al crear un índice, Laravel generará automáticamente un nombre de índice basado en la tabla, los nombres de las columnas y el tipo de índice, pero puedes pasar un segundo argumento al método para especificar el nombre del índice tú mismo:


```php
$table->unique('email', 'unique_email');
```

<a name="available-index-types"></a>
#### Tipos de Índice Disponibles

La clase blueprint del constructor de esquemas de Laravel proporciona métodos para crear cada tipo de índice soportado por Laravel. Cada método de índice acepta un segundo argumento opcional para especificar el nombre del índice. Si se omite, el nombre se derivará de los nombres de la tabla y la(s) columna(s) utilizadas para el índice, así como del tipo de índice. Cada uno de los métodos de índice disponibles se describe en la tabla a continuación:
<div class="overflow-auto">

| Comando                                          | Descripción                                                   |
| ------------------------------------------------ | ------------------------------------------------------------- |
| `$table->primary('id');`                         | Añade una clave primaria.                                     |
| `$table->primary(['id', 'parent_id']);`          | Añade claves compuestas.                                      |
| `$table->unique('email');`                       | Añade un índice único.                                        |
| `$table->index('state');`                        | Añade un índice.                                              |
| `$table->fullText('body');`                      | Añade un índice de texto completo (MariaDB / MySQL / PostgreSQL). |
| `$table->fullText('body')->language('english');` | Añade un índice de texto completo del idioma especificado (PostgreSQL). |
| `$table->spatialIndex('location');`              | Añade un índice espacial (excepto SQLite).                     |
</div>

<a name="renaming-indexes"></a>
### Renombrando Índices

Para renombrar un índice, puedes usar el método `renameIndex` proporcionado por el blueprint del constructor de esquema. Este método acepta el nombre actual del índice como su primer argumento y el nombre deseado como su segundo argumento:


```php
$table->renameIndex('from', 'to')
```

<a name="dropping-indexes"></a>
### Eliminando Índices

Para eliminar un índice, debes especificar el nombre del índice. Por defecto, Laravel asigna automáticamente un nombre de índice basado en el nombre de la tabla, el nombre de la columna indexada y el tipo de índice. Aquí hay algunos ejemplos:
<div class="overflow-auto">

| Comando                                                   | Descripción                                                 |
| -------------------------------------------------------- | ----------------------------------------------------------- |
| `$table->dropPrimary('users_id_primary');`               | Eliminar una clave primaria de la tabla "users".           |
| `$table->dropUnique('users_email_unique');`              | Eliminar un índice único de la tabla "users".              |
| `$table->dropIndex('geo_state_index');`                  | Eliminar un índice básico de la tabla "geo".               |
| `$table->dropFullText('posts_body_fulltext');`           | Eliminar un índice de texto completo de la tabla "posts".   |
| `$table->dropSpatialIndex('geo_location_spatialindex');` | Eliminar un índice espacial de la tabla "geo" (excepto SQLite). |
</div>
Si pasas un array de columnas a un método que elimina índices, el nombre del índice convencional se generará en base al nombre de la tabla, las columnas y el tipo de índice:


```php
Schema::table('geo', function (Blueprint $table) {
    $table->dropIndex(['state']); // Drops index 'geo_state_index'
});
```

<a name="foreign-key-constraints"></a>
### Restricciones de Clave Foránea

Laravel también proporciona soporte para la creación de restricciones de clave foránea, que se utilizan para forzar la integridad referencial a nivel de base de datos. Por ejemplo, definamos una columna `user_id` en la tabla `posts` que haga referencia a la columna `id` en una tabla `users`:


```php
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

Schema::table('posts', function (Blueprint $table) {
    $table->unsignedBigInteger('user_id');

    $table->foreign('user_id')->references('id')->on('users');
});
```
Dado que esta sintaxis es bastante verbosa, Laravel ofrece métodos adicionales y más concisos que utilizan convenciones para proporcionar una mejor experiencia al desarrollador. Al usar el método `foreignId` para crear tu columna, el ejemplo anterior se puede reescribir así:


```php
Schema::table('posts', function (Blueprint $table) {
    $table->foreignId('user_id')->constrained();
});
```
El método `foreignId` crea una columna equivalente de `UNSIGNED BIGINT`, mientras que el método `constrained` utilizará convenciones para determinar la tabla y la columna que se están referenciando. Si el nombre de tu tabla no coincide con las convenciones de Laravel, puedes proporcionarlo manualmente al método `constrained`. Además, el nombre que se debe asignar al índice generado también se puede especificar:


```php
Schema::table('posts', function (Blueprint $table) {
    $table->foreignId('user_id')->constrained(
        table: 'users', indexName: 'posts_user_id'
    );
});
```
También puedes especificar la acción deseada para las propiedades "on delete" y "on update" de la restricción:


```php
$table->foreignId('user_id')
      ->constrained()
      ->onUpdate('cascade')
      ->onDelete('cascade');
```
También se ofrece una sintaxis alternativa y expresiva para estas acciones:
<div class="overflow-auto">

| Método                        | Descripción                                       |
| ----------------------------- | ------------------------------------------------- |
| `$table->cascadeOnUpdate();`  | Las actualizaciones deben ser en cascada.         |
| `$table->restrictOnUpdate();` | Las actualizaciones deben ser restringidas.       |
| `$table->noActionOnUpdate();` | Sin acción en las actualizaciones.                 |
| `$table->cascadeOnDelete();`  | Las eliminaciones deben ser en cascada.          |
| `$table->restrictOnDelete();` | Las eliminaciones deben ser restringidas.         |
| `$table->nullOnDelete();`     | Las eliminaciones deben establecer el valor de la clave foránea en null. |
</div>
Cualquier [modificador de columna](#column-modifiers) adicional debe ser llamado antes del método `constrained`:


```php
$table->foreignId('user_id')
      ->nullable()
      ->constrained();
```

<a name="dropping-foreign-keys"></a>
#### Eliminando Claves Foráneas

Para eliminar una clave foránea, puedes usar el método `dropForeign`, pasando el nombre de la restricción de clave foránea que se va a eliminar como argumento. Las restricciones de clave foránea utilizan la misma convención de nombres que los índices. En otras palabras, el nombre de la restricción de clave foránea se basa en el nombre de la tabla y las columnas en la restricción, seguido de un sufijo "_foreign":


```php
$table->dropForeign('posts_user_id_foreign');
```
Alternativamente, puedes pasar un array que contenga el nombre de la columna que tiene la clave foránea al método `dropForeign`. El array se convertirá en un nombre de restricción de clave foránea utilizando las convenciones de nomenclatura de restricciones de Laravel:


```php
$table->dropForeign(['user_id']);
```

<a name="toggling-foreign-key-constraints"></a>
#### Alternando las restricciones de clave foránea

Puedes habilitar o deshabilitar las restricciones de claves foráneas dentro de tus migraciones utilizando los siguientes métodos:


```php
Schema::enableForeignKeyConstraints();

Schema::disableForeignKeyConstraints();

Schema::withoutForeignKeyConstraints(function () {
    // Constraints disabled within this closure...
});
```
> [!WARNING]
SQLite desactiva las restricciones de claves foráneas por defecto. Al usar SQLite, asegúrate de [habilitar el soporte de claves foráneas](/docs/%7B%7Bversion%7D%7D/database#configuration) en tu configuración de base de datos antes de intentar crearlas en tus migraciones.

<a name="events"></a>
## Eventos

Para mayor comodidad, cada operación de migración despachará un [evento](/docs/%7B%7Bversion%7D%7D/events). Todos los siguientes eventos extienden la clase base `Illuminate\Database\Events\MigrationEvent`:
<div class="overflow-auto">

| Clase                                         | Descripción                                      |
| ---------------------------------------------- | ------------------------------------------------ |
| `Illuminate\Database\Events\MigrationsStarted` | Un lote de migraciones está a punto de ser ejecutado.   |
| `Illuminate\Database\Events\MigrationsEnded`   | Un lote de migraciones ha terminado de ejecutarse.    |
| `Illuminate\Database\Events\MigrationStarted`  | Una sola migración está a punto de ser ejecutada.      |
| `Illuminate\Database\Events\MigrationEnded`    | Una sola migración ha terminado de ejecutarse.       |
| `Illuminate\Database\Events\NoPendingMigrations` | Un comando de migración no encontró migraciones pendientes. |
| `Illuminate\Database\Events\SchemaDumped`      | Se ha completado un volcado de esquema de base de datos.            |
| `Illuminate\Database\Events\SchemaLoaded`      | Se ha cargado un volcado de esquema de base de datos existente.    |
</div>