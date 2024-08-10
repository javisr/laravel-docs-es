# Guía de Actualización

- [Actualizando a 11.0 desde 10.x](#upgrade-11.0)

<a name="high-impact-changes"></a>
## Cambios de Alto Impacto

<div class="content-list" markdown="1">

- [Actualizando Dependencias](#updating-dependencies)
- [Estructura de la Aplicación](#application-structure)
- [Tipos de Punto Flotante](#floating-point-types)
- [Modificando Columnas](#modifying-columns)
- [Versión Mínima de SQLite](#sqlite-minimum-version)
- [Actualizando Sanctum](#updating-sanctum)

</div>

<a name="medium-impact-changes"></a>
## Cambios de Impacto Medio

<div class="content-list" markdown="1">

- [Carbon 3](#carbon-3)
- [Rehashing de Contraseñas](#password-rehashing)
- [Limitación de Tasa por Segundo](#per-second-rate-limiting)
- [Paquete Spatie Once](#spatie-once-package)

</div>

<a name="low-impact-changes"></a>
## Cambios de Bajo Impacto

<div class="content-list" markdown="1">

- [Eliminación de Doctrine DBAL](#doctrine-dbal-removal)
- [Método `casts` del Modelo Eloquent](#eloquent-model-casts-method)
- [Tipos Espaciales](#spatial-types)
- [El Contrato `Enumerable`](#the-enumerable-contract)
- [El Contrato `UserProvider`](#the-user-provider-contract)
- [El Contrato `Authenticatable`](#the-authenticatable-contract)

</div>

<a name="upgrade-11.0"></a>
## Actualizando a 11.0 desde 10.x

<a name="estimated-upgrade-time-??-minutes"></a>
#### Tiempo Estimado de Actualización: 15 Minutos

> [!NOTE]  
> Intentamos documentar cada posible cambio que rompa la compatibilidad. Dado que algunos de estos cambios disruptivos se encuentran en partes oscuras del marco, solo una parte de estos cambios puede afectar realmente a su aplicación. ¿Quieres ahorrar tiempo? Puedes usar [Laravel Shift](https://laravelshift.com/) para ayudar a automatizar las actualizaciones de tu aplicación.

<a name="updating-dependencies"></a>
### Actualizando Dependencias

**Probabilidad de Impacto: Alta**

#### PHP 8.2.0 Requerido

Laravel ahora requiere PHP 8.2.0 o superior.

#### curl 7.34.0 Requerido

El cliente HTTP de Laravel ahora requiere curl 7.34.0 o superior.

#### Dependencias de Composer

Deberías actualizar las siguientes dependencias en el archivo `composer.json` de tu aplicación:

<div class="content-list" markdown="1">

- `laravel/framework` a `^11.0`
- `nunomaduro/collision` a `^8.1`
- `laravel/breeze` a `^2.0` (si está instalado)
- `laravel/cashier` a `^15.0` (si está instalado)
- `laravel/dusk` a `^8.0` (si está instalado)
- `laravel/jetstream` a `^5.0` (si está instalado)
- `laravel/octane` a `^2.3` (si está instalado)
- `laravel/passport` a `^12.0` (si está instalado)
- `laravel/sanctum` a `^4.0` (si está instalado)
- `laravel/scout` a `^10.0` (si está instalado)
- `laravel/spark-stripe` a `^5.0` (si está instalado)
- `laravel/telescope` a `^5.0` (si está instalado)
- `livewire/livewire` a `^3.4` (si está instalado)
- `inertiajs/inertia-laravel` a `^1.0` (si está instalado)

</div>

Si tu aplicación está utilizando Laravel Cashier Stripe, Passport, Sanctum, Spark Stripe o Telescope, necesitarás publicar sus migraciones en tu aplicación. Cashier Stripe, Passport, Sanctum, Spark Stripe y Telescope **ya no cargan automáticamente las migraciones desde su propio directorio de migraciones**. Por lo tanto, deberías ejecutar el siguiente comando para publicar sus migraciones en tu aplicación:

```bash
php artisan vendor:publish --tag=cashier-migrations
php artisan vendor:publish --tag=passport-migrations
php artisan vendor:publish --tag=sanctum-migrations
php artisan vendor:publish --tag=spark-migrations
php artisan vendor:publish --tag=telescope-migrations
```

Además, deberías revisar las guías de actualización para cada uno de estos paquetes para asegurarte de estar al tanto de cualquier cambio adicional que rompa la compatibilidad:

- [Laravel Cashier Stripe](#cashier-stripe)
- [Laravel Passport](#passport)
- [Laravel Sanctum](#sanctum)
- [Laravel Spark Stripe](#spark-stripe)
- [Laravel Telescope](#telescope)

Si has instalado manualmente el instalador de Laravel, deberías actualizar el instalador a través de Composer:

```bash
composer global require laravel/installer:^5.6
```

Finalmente, puedes eliminar la dependencia de Composer `doctrine/dbal` si la has agregado previamente a tu aplicación, ya que Laravel ya no depende de este paquete.

<a name="application-structure"></a>
### Estructura de la Aplicación

Laravel 11 introduce una nueva estructura de aplicación predeterminada con menos archivos predeterminados. En concreto, las nuevas aplicaciones de Laravel contienen menos proveedores de servicios, middleware y archivos de configuración.

Sin embargo, **no recomendamos** que las aplicaciones de Laravel 10 que se actualizan a Laravel 11 intenten migrar su estructura de aplicación, ya que Laravel 11 ha sido cuidadosamente ajustado para también soportar la estructura de aplicación de Laravel 10.

<a name="authentication"></a>
### Autenticación

<a name="password-rehashing"></a>
#### Rehashing de Contraseñas

Laravel 11 volverá a hashear automáticamente las contraseñas de tus usuarios durante la autenticación si el "factor de trabajo" de tu algoritmo de hashing ha sido actualizado desde que la contraseña fue hasheada por última vez.

Típicamente, esto no debería interrumpir tu aplicación; sin embargo, puedes desactivar este comportamiento agregando la opción `rehash_on_login` al archivo de configuración `config/hashing.php` de tu aplicación:

    'rehash_on_login' => false,

<a name="the-user-provider-contract"></a>
#### El Contrato `UserProvider`

**Probabilidad de Impacto: Baja**

El contrato `Illuminate\Contracts\Auth\UserProvider` ha recibido un nuevo método `rehashPasswordIfRequired`. Este método es responsable de volver a hashear y almacenar la contraseña del usuario en el almacenamiento cuando el factor de trabajo del algoritmo de hashing de la aplicación ha cambiado.

Si tu aplicación o paquete define una clase que implementa esta interfaz, deberías agregar el nuevo método `rehashPasswordIfRequired` a tu implementación. Una implementación de referencia se puede encontrar dentro de la clase `Illuminate\Auth\EloquentUserProvider`:

```php
public function rehashPasswordIfRequired(Authenticatable $user, array $credentials, bool $force = false);
```

<a name="the-authenticatable-contract"></a>
#### El Contrato `Authenticatable`

**Probabilidad de Impacto: Baja**

El contrato `Illuminate\Contracts\Auth\Authenticatable` ha recibido un nuevo método `getAuthPasswordName`. Este método es responsable de devolver el nombre de la columna de contraseña de tu entidad autenticable.

Si tu aplicación o paquete define una clase que implementa esta interfaz, deberías agregar el nuevo método `getAuthPasswordName` a tu implementación:

```php
public function getAuthPasswordName()
{
    return 'password';
}
```

El modelo `User` predeterminado incluido con Laravel recibe este método automáticamente, ya que el método está incluido dentro del trait `Illuminate\Auth\Authenticatable`.

<a name="the-authentication-exception-class"></a>

#### La Clase `AuthenticationException`

**Probabilidad de Impacto: Muy Baja**

El método `redirectTo` de la clase `Illuminate\Auth\AuthenticationException` ahora requiere una instancia de `Illuminate\Http\Request` como su primer argumento. Si estás capturando manualmente esta excepción y llamando al método `redirectTo`, deberías actualizar tu código en consecuencia:

```php
if ($e instanceof AuthenticationException) {
    $path = $e->redirectTo($request);
}
```

<a name="cache"></a>
### Caché

<a name="cache-key-prefixes"></a>
#### Prefijos de Clave de Caché

**Probabilidad de Impacto: Muy Baja**

Anteriormente, si se definía un prefijo de clave de caché para los almacenes de caché DynamoDB, Memcached o Redis, Laravel agregaba un `:` al prefijo. En Laravel 11, el prefijo de clave de caché no recibe el sufijo `:`. Si deseas mantener el comportamiento de prefijado anterior, puedes agregar manualmente el sufijo `:` a tu prefijo de clave de caché.

<a name="collections"></a>
### Colecciones

<a name="the-enumerable-contract"></a>
#### El Contrato `Enumerable`

**Probabilidad de Impacto: Baja**

El método `dump` del contrato `Illuminate\Support\Enumerable` ha sido actualizado para aceptar un argumento variádico `...$args`. Si estás implementando esta interfaz, deberías actualizar tu implementación en consecuencia:

```php
public function dump(...$args);
```

<a name="database"></a>
### Base de Datos

<a name="sqlite-minimum-version"></a>
#### SQLite 3.26.0+

**Probabilidad de Impacto: Alta**

Si tu aplicación está utilizando una base de datos SQLite, se requiere SQLite 3.26.0 o superior.

<a name="eloquent-model-casts-method"></a>
#### Método `casts` del Modelo Eloquent

**Probabilidad de Impacto: Baja**

La clase base del modelo Eloquent ahora define un método `casts` para soportar la definición de casts de atributos. Si uno de los modelos de tu aplicación está definiendo una relación `casts`, puede entrar en conflicto con el método `casts` que ahora está presente en la clase base del modelo Eloquent.

<a name="modifying-columns"></a>
#### Modificando Columnas

**Probabilidad de Impacto: Alta**

Al modificar una columna, ahora debes incluir explícitamente todos los modificadores que deseas mantener en la definición de la columna después de que se haya cambiado. Cualquier atributo que falte será eliminado. Por ejemplo, para retener los atributos `unsigned`, `default` y `comment`, debes llamar a cada modificador explícitamente al cambiar la columna, incluso si esos atributos han sido asignados a la columna por una migración anterior.

Por ejemplo, imagina que tienes una migración que crea una columna `votes` con los atributos `unsigned`, `default` y `comment`:

```php
Schema::create('users', function (Blueprint $table) {
    $table->integer('votes')->unsigned()->default(1)->comment('El conteo de votos');
});
```

Más tarde, escribes una migración que cambia la columna para que sea `nullable` también:

```php
Schema::table('users', function (Blueprint $table) {
    $table->integer('votes')->nullable()->change();
});
```

En Laravel 10, esta migración retendría los atributos `unsigned`, `default` y `comment` en la columna. Sin embargo, en Laravel 11, la migración ahora debe incluir también todos los atributos que fueron definidos previamente en la columna. De lo contrario, serán eliminados:

```php
Schema::table('users', function (Blueprint $table) {
    $table->integer('votes')
        ->unsigned()
        ->default(1)
        ->comment('The vote count')
        ->nullable()
        ->change();
});
```

El método `change` no cambia los índices de la columna. Por lo tanto, puedes usar modificadores de índice para agregar o eliminar explícitamente un índice al modificar la columna:

```php
// Add an index...
$table->bigIncrements('id')->primary()->change();

// Drop an index...
$table->char('postal_code', 10)->unique(false)->change();
```

Si no deseas actualizar todas las migraciones de "cambio" existentes en tu aplicación para retener los atributos existentes de la columna, puedes simplemente [comprimir tus migraciones](/docs/{{version}}/migrations#squashing-migrations):

```bash
php artisan schema:dump
```

Una vez que tus migraciones han sido comprimidas, Laravel "migrará" la base de datos utilizando el archivo de esquema de tu aplicación antes de ejecutar cualquier migración pendiente.

<a name="floating-point-types"></a>
#### Tipos de Punto Flotante

**Probabilidad de Impacto: Alta**

Los tipos de columna de migración `double` y `float` han sido reescritos para ser consistentes en todas las bases de datos.

El tipo de columna `double` ahora crea una columna equivalente `DOUBLE` sin dígitos totales y lugares (dígitos después del punto decimal), que es la sintaxis SQL estándar. Por lo tanto, puedes eliminar los argumentos para `$total` y `$places`:

```php
$table->double('amount');
```

El tipo de columna `float` ahora crea una columna equivalente `FLOAT` sin dígitos totales y lugares (dígitos después del punto decimal), pero con una especificación opcional de `$precision` para determinar el tamaño de almacenamiento como una columna de precisión simple de 4 bytes o una columna de precisión doble de 8 bytes. Por lo tanto, puedes eliminar los argumentos para `$total` y `$places` y especificar la `$precision` opcional a tu valor deseado y de acuerdo con la documentación de tu base de datos:

```php
$table->float('amount', precision: 53);
```

Los métodos `unsignedDecimal`, `unsignedDouble` y `unsignedFloat` han sido eliminados, ya que el modificador unsigned para estos tipos de columna ha sido desaprobado por MySQL, y nunca fue estandarizado en otros sistemas de bases de datos. Sin embargo, si deseas continuar usando el atributo unsigned desaprobado para estos tipos de columna, puedes encadenar el método `unsigned` a la definición de la columna:

```php
$table->decimal('amount', total: 8, places: 2)->unsigned();
$table->double('amount')->unsigned();
$table->float('amount', precision: 53)->unsigned();
```

<a name="dedicated-mariadb-driver"></a>
#### Controlador Dedicado de MariaDB

**Probabilidad de Impacto: Muy Baja**

En lugar de utilizar siempre el controlador MySQL al conectarse a bases de datos MariaDB, Laravel 11 agrega un controlador de base de datos dedicado para MariaDB.

Si tu aplicación se conecta a una base de datos MariaDB, puedes actualizar la configuración de conexión al nuevo controlador `mariadb` para beneficiarte de las características específicas de MariaDB en el futuro:

    'driver' => 'mariadb',
    'url' => env('DB_URL'),
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '3306'),
    // ...

Actualmente, el nuevo controlador de MariaDB se comporta como el controlador MySQL actual con una excepción: el método del generador de esquemas `uuid` crea columnas UUID nativas en lugar de columnas `char(36)`.

Si tus migraciones existentes utilizan el método del generador de esquemas `uuid` y eliges usar el nuevo controlador de base de datos `mariadb`, deberías actualizar las invocaciones de tu migración del método `uuid` a `char` para evitar cambios disruptivos o comportamientos inesperados:

```php
Schema::table('users', function (Blueprint $table) {
    $table->char('uuid', 36);

    // ...
});
```

<a name="spatial-types"></a>
#### Tipos Espaciales

**Probabilidad de Impacto: Baja**

Los tipos de columna espaciales de las migraciones de base de datos han sido reescritos para ser consistentes en todas las bases de datos. Por lo tanto, puedes eliminar los métodos `point`, `lineString`, `polygon`, `geometryCollection`, `multiPoint`, `multiLineString`, `multiPolygon` y `multiPolygonZ` de tus migraciones y usar los métodos `geometry` o `geography` en su lugar:

```php
$table->geometry('shapes');
$table->geography('coordinates');
```

Para restringir explícitamente el tipo o el identificador del sistema de referencia espacial para los valores almacenados en la columna en MySQL, MariaDB y PostgreSQL, puedes pasar el `subtype` y `srid` al método:

```php
$table->geometry('dimension', subtype: 'polygon', srid: 0);
$table->geography('latitude', subtype: 'point', srid: 4326);
```

Los modificadores de columna `isGeometry` y `projection` de la gramática de PostgreSQL han sido eliminados en consecuencia.

<a name="doctrine-dbal-removal"></a>
#### Eliminación de Doctrine DBAL

**Probabilidad de Impacto: Baja**

La siguiente lista de clases y métodos relacionados con Doctrine DBAL ha sido eliminada. Laravel ya no depende de este paquete y registrar tipos de Doctrina personalizados ya no es necesario para la creación y alteración adecuadas de varios tipos de columna que anteriormente requerían tipos personalizados:

<div class="content-list" markdown="1">

- `Illuminate\Database\Schema\Builder::$alwaysUsesNativeSchemaOperationsIfPossible` propiedad de clase
- `Illuminate\Database\Schema\Builder::useNativeSchemaOperationsIfPossible()` método
- `Illuminate\Database\Connection::usingNativeSchemaOperations()` método
- `Illuminate\Database\Connection::isDoctrineAvailable()` método
- `Illuminate\Database\Connection::getDoctrineConnection()` método
- `Illuminate\Database\Connection::getDoctrineSchemaManager()` método
- `Illuminate\Database\Connection::getDoctrineColumn()` método
- `Illuminate\Database\Connection::registerDoctrineType()` método
- `Illuminate\Database\DatabaseManager::registerDoctrineType()` método
- `Illuminate\Database\PDO` directorio
- `Illuminate\Database\DBAL\TimestampType` clase
- `Illuminate\Database\Schema\Grammars\ChangeColumn` clase
- `Illuminate\Database\Schema\Grammars\RenameColumn` clase
- `Illuminate\Database\Schema\Grammars\Grammar::getDoctrineTableDiff()` método

</div>

Además, registrar tipos de Doctrina personalizados a través de `dbal.types` en el archivo de configuración `database` de tu aplicación ya no es necesario.

Si anteriormente estabas utilizando Doctrine DBAL para inspeccionar tu base de datos y sus tablas asociadas, puedes usar los nuevos métodos nativos de esquema de Laravel (`Schema::getTables()`, `Schema::getColumns()`, `Schema::getIndexes()`, `Schema::getForeignKeys()`, etc.) en su lugar.

<a name="deprecated-schema-methods"></a>
#### Métodos de Esquema Desaprobados

**Probabilidad de impacto: Muy baja**

Los métodos obsoletos, basados en Doctrine `Schema::getAllTables()`, `Schema::getAllViews()`, y `Schema::getAllTypes()` han sido eliminados a favor de los nuevos métodos nativos de Laravel `Schema::getTables()`, `Schema::getViews()`, y `Schema::getTypes()`.

Al usar PostgreSQL y SQL Server, ninguno de los nuevos métodos de esquema aceptará una referencia de tres partes (por ejemplo, `database.schema.table`). Por lo tanto, debes usar `connection()` para declarar la base de datos en su lugar:

```php
Schema::connection('database')->hasTable('schema.table');
```

<a name="get-column-types"></a>
#### Método `getColumnType()` del Constructor de Esquemas

**Probabilidad de impacto: Muy baja**

El método `Schema::getColumnType()` ahora siempre devuelve el tipo real de la columna dada, no el tipo equivalente de Doctrine DBAL.

<a name="database-connection-interface"></a>
#### Interfaz de Conexión a la Base de Datos

**Probabilidad de impacto: Muy baja**

La interfaz `Illuminate\Database\ConnectionInterface` ha recibido un nuevo método `scalar`. Si estás definiendo tu propia implementación de esta interfaz, debes agregar el método `scalar` a tu implementación:

```php
public function scalar($query, $bindings = [], $useReadPdo = true);
```

<a name="dates"></a>
### Fechas

<a name="carbon-3"></a>
#### Carbon 3

**Probabilidad de impacto: Media**

Laravel 11 soporta tanto Carbon 2 como Carbon 3. Carbon es una biblioteca de manipulación de fechas utilizada extensamente por Laravel y paquetes en todo el ecosistema. Si actualizas a Carbon 3, ten en cuenta que los métodos `diffIn*` ahora devuelven números de punto flotante y pueden devolver valores negativos para indicar la dirección del tiempo, lo cual es un cambio significativo respecto a Carbon 2. Revisa el [registro de cambios](https://github.com/briannesbitt/Carbon/releases/tag/3.0.0) de Carbon para obtener información detallada sobre cómo manejar estos y otros cambios.

<a name="mail"></a>
### Correo

<a name="the-mailer-contract"></a>
#### El Contrato `Mailer`

**Probabilidad de impacto: Muy baja**

El contrato `Illuminate\Contracts\Mail\Mailer` ha recibido un nuevo método `sendNow`. Si tu aplicación o paquete está implementando manualmente este contrato, debes agregar el nuevo método `sendNow` a tu implementación:

```php
public function sendNow($mailable, array $data = [], $callback = null);
```

<a name="packages"></a>
### Paquetes

<a name="publishing-service-providers"></a>
#### Publicando Proveedores de Servicios en la Aplicación

**Probabilidad de impacto: Muy baja**

Si has escrito un paquete de Laravel que publica manualmente un proveedor de servicios en el directorio `app/Providers` de la aplicación y modifica manualmente el archivo de configuración `config/app.php` de la aplicación para registrar el proveedor de servicios, debes actualizar tu paquete para utilizar el nuevo método `ServiceProvider::addProviderToBootstrapFile`.

El método `addProviderToBootstrapFile` añadirá automáticamente el proveedor de servicios que has publicado al archivo `bootstrap/providers.php` de la aplicación, ya que el array `providers` no existe dentro del archivo de configuración `config/app.php` en las nuevas aplicaciones de Laravel 11.

```php
use Illuminate\Support\ServiceProvider;

ServiceProvider::addProviderToBootstrapFile(Provider::class);
```

<a name="queues"></a>
### Colas

<a name="the-batch-repository-interface"></a>
#### La Interfaz `BatchRepository`

**Probabilidad de impacto: Muy baja**

La interfaz `Illuminate\Bus\BatchRepository` ha recibido un nuevo método `rollBack`. Si estás implementando esta interfaz dentro de tu propio paquete o aplicación, debes agregar este método a tu implementación:

```php
public function rollBack();
```

<a name="synchronous-jobs-in-database-transactions"></a>
#### Trabajos Sincrónicos en Transacciones de Base de Datos

**Probabilidad de impacto: Muy baja**

Anteriormente, los trabajos sincrónicos (trabajos que utilizan el controlador de cola `sync`) se ejecutarían inmediatamente, independientemente de si la opción de configuración `after_commit` de la conexión de cola estaba configurada en `true` o si se invocaba el método `afterCommit` en el trabajo.

En Laravel 11, los trabajos de cola sincrónicos ahora respetarán la configuración de "después del compromiso" de la conexión de cola o del trabajo.

<a name="rate-limiting"></a>
### Limitación de Tasa

<a name="per-second-rate-limiting"></a>
#### Limitación de Tasa por Segundo

**Probabilidad de impacto: Media**

Laravel 11 soporta la limitación de tasa por segundo en lugar de estar limitado a la granularidad por minuto. Hay una variedad de posibles cambios disruptivos de los que debes estar al tanto relacionados con este cambio.

El constructor de la clase `GlobalLimit` ahora acepta segundos en lugar de minutos. Esta clase no está documentada y no se utilizaría típicamente en tu aplicación:

```php
new GlobalLimit($attempts, 2 * 60);
```

El constructor de la clase `Limit` ahora acepta segundos en lugar de minutos. Todos los usos documentados de esta clase están limitados a constructores estáticos como `Limit::perMinute` y `Limit::perSecond`. Sin embargo, si estás instanciando esta clase manualmente, debes actualizar tu aplicación para proporcionar segundos al constructor de la clase:

```php
new Limit($key, $attempts, 2 * 60);
```

La propiedad `decayMinutes` de la clase `Limit` ha sido renombrada a `decaySeconds` y ahora contiene segundos en lugar de minutos.

Los constructores de las clases `Illuminate\Queue\Middleware\ThrottlesExceptions` y `Illuminate\Queue\Middleware\ThrottlesExceptionsWithRedis` ahora aceptan segundos en lugar de minutos:

```php
new ThrottlesExceptions($attempts, 2 * 60);
new ThrottlesExceptionsWithRedis($attempts, 2 * 60);
```

<a name="cashier-stripe"></a>
### Cashier Stripe

<a name="updating-cashier-stripe"></a>
#### Actualizando Cashier Stripe

**Probabilidad de impacto: Alta**

Laravel 11 ya no soporta Cashier Stripe 14.x. Por lo tanto, debes actualizar la dependencia de Laravel Cashier Stripe de tu aplicación a `^15.0` en tu archivo `composer.json`.

Cashier Stripe 15.0 ya no carga automáticamente migraciones desde su propio directorio de migraciones. En su lugar, debes ejecutar el siguiente comando para publicar las migraciones de Cashier Stripe en tu aplicación:

```shell
php artisan vendor:publish --tag=cashier-migrations
```

Por favor, revisa la completa [guía de actualización de Cashier Stripe](https://github.com/laravel/cashier-stripe/blob/15.x/UPGRADE.md) para obtener información adicional sobre cambios disruptivos.

<a name="spark-stripe"></a>
### Spark (Stripe)

<a name="updating-spark-stripe"></a>
#### Actualizando Spark Stripe

**Probabilidad de impacto: Alta**

Laravel 11 ya no soporta Laravel Spark Stripe 4.x. Por lo tanto, debes actualizar la dependencia de Laravel Spark Stripe de tu aplicación a `^5.0` en tu archivo `composer.json`.

Spark Stripe 5.0 ya no carga automáticamente migraciones desde su propio directorio de migraciones. En su lugar, debes ejecutar el siguiente comando para publicar las migraciones de Spark Stripe en tu aplicación:

```shell
php artisan vendor:publish --tag=spark-migrations
```

Por favor, revisa la completa [guía de actualización de Spark Stripe](https://spark.laravel.com/docs/spark-stripe/upgrade.html) para obtener información adicional sobre cambios disruptivos.

<a name="passport"></a>
### Passport

<a name="updating-telescope"></a>
#### Actualizando Passport

**Probabilidad de impacto: Alta**

Laravel 11 ya no soporta Laravel Passport 11.x. Por lo tanto, debes actualizar la dependencia de Laravel Passport de tu aplicación a `^12.0` en tu archivo `composer.json`.

Passport 12.0 ya no carga automáticamente migraciones desde su propio directorio de migraciones. En su lugar, debes ejecutar el siguiente comando para publicar las migraciones de Passport en tu aplicación:

```shell
php artisan vendor:publish --tag=passport-migrations
```

Además, el tipo de concesión de contraseña está deshabilitado por defecto. Puedes habilitarlo invocando el método `enablePasswordGrant` en el método `boot` de tu `AppServiceProvider` de la aplicación:

    public function boot(): void
    {
        Passport::enablePasswordGrant();
    }

<a name="sanctum"></a>
### Sanctum

<a name="updating-sanctum"></a>
#### Actualizando Sanctum

**Probabilidad de impacto: Alta**

Laravel 11 ya no soporta Laravel Sanctum 3.x. Por lo tanto, debes actualizar la dependencia de Laravel Sanctum de tu aplicación a `^4.0` en tu archivo `composer.json`.

Sanctum 4.0 ya no carga automáticamente migraciones desde su propio directorio de migraciones. En su lugar, debes ejecutar el siguiente comando para publicar las migraciones de Sanctum en tu aplicación:

```shell
php artisan vendor:publish --tag=sanctum-migrations
```

Luego, en el archivo de configuración `config/sanctum.php` de tu aplicación, debes actualizar las referencias a los middleware `authenticate_session`, `encrypt_cookies`, y `validate_csrf_token` a lo siguiente:

    'middleware' => [
        'authenticate_session' => Laravel\Sanctum\Http\Middleware\AuthenticateSession::class,
        'encrypt_cookies' => Illuminate\Cookie\Middleware\EncryptCookies::class,
        'validate_csrf_token' => Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
    ],

<a name="telescope"></a>
### Telescope

<a name="updating-telescope"></a>
#### Actualizando Telescope

**Probabilidad de impacto: Alta**

Laravel 11 ya no soporta Laravel Telescope 4.x. Por lo tanto, debes actualizar la dependencia de Laravel Telescope de tu aplicación a `^5.0` en tu archivo `composer.json`.

Telescope 5.0 ya no carga automáticamente migraciones desde su propio directorio de migraciones. En su lugar, debes ejecutar el siguiente comando para publicar las migraciones de Telescope en tu aplicación:

```shell
php artisan vendor:publish --tag=telescope-migrations
```

<a name="spatie-once-package"></a>
### Paquete Spatie Once

**Probabilidad de impacto: Media**

Laravel 11 ahora proporciona su propia [`once` function](/docs/{{version}}/helpers#method-once) para asegurar que una función anónima dada se ejecute solo una vez. Por lo tanto, si tu aplicación tiene una dependencia en el paquete `spatie/once`, debes eliminarlo de tu archivo `composer.json` de la aplicación para evitar conflictos.

<a name="miscellaneous"></a>
### Varios

También te animamos a ver los cambios en el [repositorio de GitHub](https://github.com/laravel/laravel) de `laravel/laravel`. Si bien muchos de estos cambios no son obligatorios, es posible que desees mantener estos archivos sincronizados con tu aplicación. Algunos de estos cambios se cubrirán en esta guía de actualización, pero otros, como cambios en archivos de configuración o comentarios, no lo estarán. Puedes ver fácilmente los cambios con la [herramienta de comparación de GitHub](https://github.com/laravel/laravel/compare/10.x...11.x) y elegir qué actualizaciones son importantes para ti.
