# Guía de actualización

- [Actualizando de 10.x a 11.0](#upgrade-11.0)

<a name="high-impact-changes"></a>
## Cambios de Alto Impacto

<div class="content-list" markdown="1">

- [Updating Dependencies](#updating-dependencies)
- [Application Structure](#application-structure)
- [Floating-Point Types](#floating-point-types)
- [Modifying Columns](#modifying-columns)
- [SQLite Minimum Version](#sqlite-minimum-version)
- [Updating Sanctum](#updating-sanctum)
</div>

<a name="medium-impact-changes"></a>
## Cambios de Impacto Medio

<div class="content-list" markdown="1">

- [Carbon 3](#carbon-3)
- [Password Rehashing](#password-rehashing)
- [Per-Second Rate Limiting](#per-second-rate-limiting)
- [Spatie Once Package](#spatie-once-package)
</div>

<a name="low-impact-changes"></a>
## Cambios de Bajo Impacto

<div class="content-list" markdown="1">

- [Doctrine DBAL Removal](#doctrine-dbal-removal)
- [Eloquent Model `casts` Method](#eloquent-model-casts-method)
- [Spatial Types](#spatial-types)
- [The `Enumerable` Contract](#the-enumerable-contract)
- [The `UserProvider` Contract](#the-user-provider-contract)
- [The `Authenticatable` Contract](#the-authenticatable-contract)
</div>

<a name="upgrade-11.0"></a>
## Actualizando a 11.0 desde 10.x


<a name="estimated-upgrade-time-??-minutes"></a>
#### Tiempo de Actualización Estimado: 15 Minutos

> [!NOTE]
Intentamos documentar cada posible cambio que rompa la compatibilidad. Dado que algunos de estos cambios son en partes poco comunes del framework, solo una parte de estos cambios puede afectar realmente tu aplicación. ¿Quieres ahorrar tiempo? Puedes usar [Laravel Shift](https://laravelshift.com/) para ayudar a automatizar las actualizaciones de tu aplicación.

<a name="updating-dependencies"></a>
### Actualizando Dependencias

#### PHP 8.2.0 Requerido

Laravel ahora requiere PHP 8.2.0 o superior.
#### curl 7.34.0 Requerido

El cliente HTTP de Laravel ahora requiere curl 7.34.0 o superior.
#### Dependencias de Composer

Debes actualizar las siguientes dependencias en el archivo `composer.json` de tu aplicación:
<div class="content-list" markdown="1">

- `laravel/framework` to `^11.0`
- `nunomaduro/collision` to `^8.1`
- `laravel/breeze` to `^2.0` (If installed)
- `laravel/cashier` to `^15.0` (If installed)
- `laravel/dusk` to `^8.0` (If installed)
- `laravel/jetstream` to `^5.0` (If installed)
- `laravel/octane` to `^2.3` (If installed)
- `laravel/passport` to `^12.0` (If installed)
- `laravel/sanctum` to `^4.0` (If installed)
- `laravel/scout` to `^10.0` (If installed)
- `laravel/spark-stripe` to `^5.0` (If installed)
- `laravel/telescope` to `^5.0` (If installed)
- `livewire/livewire` to `^3.4` (If installed)
- `inertiajs/inertia-laravel` to `^1.0` (If installed)
</div>
Si tu aplicación está utilizando Laravel Cashier Stripe, Passport, Sanctum, Spark Stripe o Telescope, necesitarás publicar sus migraciones en tu aplicación. Cashier Stripe, Passport, Sanctum, Spark Stripe y Telescope **ya no cargan automáticamente las migraciones desde su propio directorio de migraciones**. Por lo tanto, debes ejecutar el siguiente comando para publicar sus migraciones en tu aplicación:


```bash
php artisan vendor:publish --tag=cashier-migrations
php artisan vendor:publish --tag=passport-migrations
php artisan vendor:publish --tag=sanctum-migrations
php artisan vendor:publish --tag=spark-migrations
php artisan vendor:publish --tag=telescope-migrations

```
Además, debes revisar las guías de actualización para cada uno de estos paquetes para asegurarte de que estás al tanto de cualquier cambio breaking adicional:
- [Laravel Cashier Stripe](#cashier-stripe)
- [Laravel Passport](#passport)
- [Laravel Sanctum](#sanctum)
- [Laravel Spark Stripe](#spark-stripe)
- [Laravel Telescope](#telescope)
Si has instalado manualmente el instalador de Laravel, deberías actualizar el instalador a través de Composer:


```bash
composer global require laravel/installer:^5.6

```
Finalmente, puedes eliminar la dependencia de Composer `doctrine/dbal` si la has añadido previamente a tu aplicación, ya que Laravel ya no depende de este paquete.

<a name="application-structure"></a>
### Estructura de la Aplicación

Laravel 11 introduce una nueva estructura de aplicación predeterminada con menos archivos predeterminados. En pocas palabras, las nuevas aplicaciones Laravel contienen menos proveedores de servicios, middleware y archivos de configuración.
Sin embargo, **no recomendamos** que las aplicaciones Laravel 10 que se actualizan a Laravel 11 intenten migrar su estructura de aplicación, ya que Laravel 11 ha sido cuidadosamente optimizado para soportar también la estructura de aplicación de Laravel 10.

<a name="authentication"></a>
### Autenticación


<a name="password-rehashing"></a>
#### Rehashing de Contraseñas

Laravel 11 volverá a calcular automáticamente las contraseñas de tus usuarios durante la autenticación si el "factor de trabajo" de tu algoritmo de hash ha sido actualizado desde que se hashó la contraseña por última vez.
Normalmente, esto no debería interrumpir tu aplicación; sin embargo, puedes desactivar este comportamiento añadiendo la opción `rehash_on_login` al archivo de configuración `config/hashing.php` de tu aplicación:


```php
'rehash_on_login' => false,
```

<a name="the-user-provider-contract"></a>
#### El contrato `UserProvider`

El contrato `Illuminate\Contracts\Auth\UserProvider` ha recibido un nuevo método `rehashPasswordIfRequired`. Este método es responsable de volver a hashear y almacenar la contraseña del usuario en el almacenamiento cuando el factor de trabajo del algoritmo de hashing de la aplicación ha cambiado.
Si tu aplicación o paquete define una clase que implementa esta interfaz, deberías añadir el nuevo método `rehashPasswordIfRequired` a tu implementación. Una implementación de referencia se puede encontrar dentro de la clase `Illuminate\Auth\EloquentUserProvider`:


```php
public function rehashPasswordIfRequired(Authenticatable $user, array $credentials, bool $force = false);

```

<a name="the-authenticatable-contract"></a>
#### El contrato `Authenticatable`

El contrato `Illuminate\Contracts\Auth\Authenticatable` ha recibido un nuevo método `getAuthPasswordName`. Este método es responsable de devolver el nombre de la columna de contraseña de tu entidad autenticable.
Si tu aplicación o paquete define una clase que implementa esta interfaz, deberías añadir el nuevo método `getAuthPasswordName` a tu implementación:


```php
public function getAuthPasswordName()
{
    return 'password';
}

```
El modelo `User` por defecto incluido con Laravel recibe este método automáticamente ya que el método está incluido en el trait `Illuminate\Auth\Authenticatable`.

<a name="the-authentication-exception-class"></a>
#### La clase `AuthenticationException`

El método `redirectTo` de la clase `Illuminate\Auth\AuthenticationException` ahora requiere una instancia de `Illuminate\Http\Request` como su primer argumento. Si estás atrapando manualmente esta excepción y llamando al método `redirectTo`, debes actualizar tu código en consecuencia:


```php
if ($e instanceof AuthenticationException) {
    $path = $e->redirectTo($request);
}

```

<a name="cache"></a>
### Caché


<a name="cache-key-prefixes"></a>
#### Prefijos de claves de caché

Anteriormente, si se definía un prefijo de clave de caché para los almacenes de caché DynamoDB, Memcached o Redis, Laravel añadiría un `:` al prefijo. En Laravel 11, el prefijo de clave de caché no recibe el sufijo `:`. Si deseas mantener el comportamiento de prefijado anterior, puedes agregar manualmente el sufijo `:` a tu prefijo de clave de caché.

<a name="collections"></a>
### Colecciones


<a name="the-enumerable-contract"></a>
#### El Contrato `Enumerable`

El método `dump` del contrato `Illuminate\Support\Enumerable` se ha actualizado para aceptar un argumento variádico `...$args`. Si estás implementando esta interfaz, debes actualizar tu implementación en consecuencia:


```php
public function dump(...$args);

```

<a name="database"></a>
### Base de datos


<a name="sqlite-minimum-version"></a>
#### SQLite 3.26.0+

Si tu aplicación está utilizando una base de datos SQLite, se requiere SQLite 3.26.0 o superior.

<a name="eloquent-model-casts-method"></a>
#### Método `casts` del Modelo Eloquent

La clase base del modelo Eloquent ahora define un método `casts` para soportar la definición de conversiones de atributos. Si uno de los modelos de tu aplicación está definiendo una relación `casts`, puede entrar en conflicto con el método `casts` que ahora está presente en la clase base del modelo Eloquent.

<a name="modifying-columns"></a>
#### Modificando Columnas

Al modificar una columna, ahora debes incluir explícitamente todos los modificadores que deseas mantener en la definición de la columna después de que se haya cambiado. Cualquier atributo faltante será eliminado. Por ejemplo, para retener los atributos `unsigned`, `default` y `comment`, debes llamar a cada modificador de manera explícita al cambiar la columna, incluso si esos atributos han sido asignados a la columna por una migración anterior.
Por ejemplo, imagina que tienes una migración que crea una columna `votes` con los atributos `unsigned`, `default` y `comment`:


```php
Schema::create('users', function (Blueprint $table) {
    $table->integer('votes')->unsigned()->default(1)->comment('The vote count');
});

```
Más tarde, escribes una migración que cambia la columna para que sea `nullable` también:


```php
Schema::table('users', function (Blueprint $table) {
    $table->integer('votes')->nullable()->change();
});

```
En Laravel 10, esta migración retendría los atributos `unsigned`, `default` y `comment` en la columna. Sin embargo, en Laravel 11, la migración ahora también debe incluir todos los atributos que se definieron previamente en la columna. De lo contrario, serán eliminados:


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
El método `change` no cambia los índices de la columna. Por lo tanto, puedes usar modificadores de índice para añadir o eliminar explícitamente un índice al modificar la columna:


```php
// Add an index...
$table->bigIncrements('id')->primary()->change();

// Drop an index...
$table->char('postal_code', 10)->unique(false)->change();

```
Si no deseas actualizar todas las migraciones de "cambio" existentes en tu aplicación para retener los atributos existentes de la columna, simplemente puedes [fusionar tus migraciones](/docs/%7B%7Bversion%7D%7D/migrations#squashing-migrations):


```bash
php artisan schema:dump

```
Una vez que tus migraciones hayan sido comprimidas, Laravel "migrará" la base de datos utilizando el archivo de esquema de tu aplicación antes de ejecutar cualquier migración pendiente.

<a name="floating-point-types"></a>
#### Tipos de Punto Flotante

Los tipos de columnas de migración `double` y `float` han sido reescritos para ser consistentes en todas las bases de datos.
El tipo de columna `double` ahora crea una columna equivalente a `DOUBLE` sin dígitos totales y lugares (dígitos después del punto decimal), que es la sintaxis SQL estándar. Por lo tanto, puedes eliminar los argumentos para `$total` y `$places`:


```php
$table->double('amount');

```
El tipo de columna `float` ahora crea una columna equivalente a `FLOAT` sin dígitos totales y posiciones (dígitos después del punto decimal), pero con una especificación opcional de `$precision` para determinar el tamaño de almacenamiento como una columna de precisión simple de 4 bytes o una columna de precisión doble de 8 bytes. Por lo tanto, puedes eliminar los argumentos para `$total` y `$places` y especificar la `$precision` opcional al valor que desees y de acuerdo con la documentación de tu base de datos:


```php
$table->float('amount', precision: 53);

```
Se han eliminado los métodos `unsignedDecimal`, `unsignedDouble` y `unsignedFloat`, ya que el modificador unsigned para estos tipos de columna ha sido desaprobado por MySQL y nunca fue estandarizado en otros sistemas de bases de datos. Sin embargo, si deseas seguir utilizando el atributo unsigned desaprobado para estos tipos de columna, puedes encadenar el método `unsigned` a la definición de la columna:


```php
$table->decimal('amount', total: 8, places: 2)->unsigned();
$table->double('amount')->unsigned();
$table->float('amount', precision: 53)->unsigned();

```

<a name="dedicated-mariadb-driver"></a>
#### Driver dedicado de MariaDB

En lugar de utilizar siempre el driver MySQL al conectarse a bases de datos MariaDB, Laravel 11 añade un driver de base de datos dedicado para MariaDB.
Si tu aplicación se conecta a una base de datos MariaDB, puedes actualizar la configuración de conexión al nuevo driver `mariadb` para beneficiarte de las características específicas de MariaDB en el futuro:


```php
'driver' => 'mariadb',
'url' => env('DB_URL'),
'host' => env('DB_HOST', '127.0.0.1'),
'port' => env('DB_PORT', '3306'),
// ...
```
Actualmente, el nuevo driver de MariaDB se comporta como el driver MySQL actual con una excepción: el método `uuid` del constructor de esquemas crea columnas UUID nativas en lugar de columnas `char(36)`.
Si tus migrações existentes utilizan el método `uuid` del constructor de esquemas y eliges usar el nuevo driver de base de datos `mariadb`, deberías actualizar las invocaciones del método `uuid` en tus migraciones a `char` para evitar cambios ruptivos o comportamientos inesperados:


```php
Schema::table('users', function (Blueprint $table) {
    $table->char('uuid', 36);

    // ...
});

```

<a name="spatial-types"></a>
#### Tipos Espaciales

Los tipos de columnas espaciales de las migraciones de bases de datos han sido reescritos para ser consistentes en todas las bases de datos. Por lo tanto, puedes eliminar los métodos `point`, `lineString`, `polygon`, `geometryCollection`, `multiPoint`, `multiLineString`, `multiPolygon` y `multiPolygonZ` de tus migraciones y usar en su lugar los métodos `geometry` o `geography`:


```php
$table->geometry('shapes');
$table->geography('coordinates');

```
Para restringir explícitamente el tipo o el identificador del sistema de referencia espacial para los valores almacenados en la columna en MySQL, MariaDB y PostgreSQL, puedes pasar `subtype` y `srid` al método:


```php
$table->geometry('dimension', subtype: 'polygon', srid: 0);
$table->geography('latitude', subtype: 'point', srid: 4326);

```
Los modificadores de columna `isGeometry` y `projection` de la gramática de PostgreSQL han sido eliminados en consecuencia.

<a name="doctrine-dbal-removal"></a>
#### Eliminación de Doctrine DBAL

**Probabilidad de Impacto: Baja**
La siguiente lista de clases y métodos relacionados con Doctrine DBAL ha sido eliminada. Laravel ya no depende de este paquete y registrar tipos de Doctrine personalizados ya no es necesario para la creación y alteración adecuadas de varios tipos de columna que anteriormente requerían tipos personalizados:
<div class="content-list" markdown="1">

- `Illuminate\Database\Schema\Builder::$alwaysUsesNativeSchemaOperationsIfPossible` class property
- `Illuminate\Database\Schema\Builder::useNativeSchemaOperationsIfPossible()` method
- `Illuminate\Database\Connection::usingNativeSchemaOperations()` method
- `Illuminate\Database\Connection::isDoctrineAvailable()` method
- `Illuminate\Database\Connection::getDoctrineConnection()` method
- `Illuminate\Database\Connection::getDoctrineSchemaManager()` method
- `Illuminate\Database\Connection::getDoctrineColumn()` method
- `Illuminate\Database\Connection::registerDoctrineType()` method
- `Illuminate\Database\DatabaseManager::registerDoctrineType()` method
- `Illuminate\Database\PDO` directory
- `Illuminate\Database\DBAL\TimestampType` class
- `Illuminate\Database\Schema\Grammars\ChangeColumn` class
- `Illuminate\Database\Schema\Grammars\RenameColumn` class
- `Illuminate\Database\Schema\Grammars\Grammar::getDoctrineTableDiff()` method
</div>
Además, ya no se requiere registrar tipos de Doctrine personalizados a través de `dbal.types` en el archivo de configuración `database` de tu aplicación.
Si anteriormente estabas utilizando Doctrine DBAL para inspeccionar tu base de datos y sus tablas asociadas, ahora puedes usar los nuevos métodos de esquema nativos de Laravel (`Schema::getTables()`, `Schema::getColumns()`, `Schema::getIndexes()`, `Schema::getForeignKeys()`, etc.) en su lugar.

<a name="deprecated-schema-methods"></a>
#### Métodos de Esquema en Desuso

Los métodos `Schema::getAllTables()`, `Schema::getAllViews()` y `Schema::getAllTypes()` basados en Doctrine, que estaban en desuso, han sido eliminados en favor de los nuevos métodos nativos de Laravel `Schema::getTables()`, `Schema::getViews()` y `Schema::getTypes()`.
Al utilizar PostgreSQL y SQL Server, ninguno de los nuevos métodos de esquema aceptará una referencia de tres partes (por ejemplo, `database.schema.table`). Por lo tanto, debes usar `connection()` para declarar la base de datos en su lugar:


```php
Schema::connection('database')->hasTable('schema.table');

```

<a name="get-column-types"></a>
#### Método `getColumnType()` del Constructor de Esquemas

El método `Schema::getColumnType()` ahora siempre devuelve el tipo real de la columna dada, no el tipo equivalente de Doctrine DBAL.

<a name="database-connection-interface"></a>
#### Interfaz de Conexión a la Base de Datos

La interfaz `Illuminate\Database\ConnectionInterface` ha recibido un nuevo método `scalar`. Si estás definiendo tu propia implementación de esta interfaz, debes añadir el método `scalar` a tu implementación:


```php
public function scalar($query, $bindings = [], $useReadPdo = true);

```

<a name="dates"></a>
### Fechas


<a name="carbon-3"></a>
#### Carbon 3

Laravel 11 admite tanto Carbon 2 como Carbon 3. Carbon es una biblioteca de manipulación de fechas utilizada ampliamente por Laravel y paquetes en todo el ecosistema. Si actualizas a Carbon 3, ten en cuenta que los métodos `diffIn*` ahora devuelven números de punto flotante y pueden devolver valores negativos para indicar la dirección del tiempo, lo que es un cambio significativo con respecto a Carbon 2. Revisa el [registro de cambios de Carbon](https://github.com/briannesbitt/Carbon/releases/tag/3.0.0) para obtener información detallada sobre cómo manejar estos y otros cambios.

<a name="mail"></a>
### Correo


<a name="the-mailer-contract"></a>
#### El contrato `Mailer`

El contrato `Illuminate\Contracts\Mail\Mailer` ha recibido un nuevo método `sendNow`. Si tu aplicación o paquete está implementando manualmente este contrato, debes añadir el nuevo método `sendNow` a tu implementación:


```php
public function sendNow($mailable, array $data = [], $callback = null);

```

<a name="packages"></a>
### Paquetes


<a name="publishing-service-providers"></a>
#### Publicando Proveedores de Servicios en la Aplicación

Si has escrito un paquete de Laravel que publica manualmente un proveedor de servicios en el directorio `app/Providers` de la aplicación y modifica manualmente el archivo de configuración `config/app.php` de la aplicación para registrar el proveedor de servicios, debes actualizar tu paquete para utilizar el nuevo método `ServiceProvider::addProviderToBootstrapFile`.
El método `addProviderToBootstrapFile` añadirá automáticamente el proveedor de servicios que has publicado al archivo `bootstrap/providers.php` de la aplicación, ya que el array `providers` no existe dentro del archivo de configuración `config/app.php` en nuevas aplicaciones Laravel 11.


```php
use Illuminate\Support\ServiceProvider;

ServiceProvider::addProviderToBootstrapFile(Provider::class);

```

<a name="queues"></a>
### Colas


<a name="the-batch-repository-interface"></a>
#### La interfaz `BatchRepository`

La interfaz `Illuminate\Bus\BatchRepository` ha recibido un nuevo método `rollBack`. Si estás implementando esta interfaz dentro de tu propio paquete o aplicación, debes añadir este método a tu implementación:


```php
public function rollBack();

```

<a name="synchronous-jobs-in-database-transactions"></a>
#### Trabajos Sincrónicos en Transacciones de Base de Datos

**Probabilidad de Impacto: Muy Baja**
Anteriormente, los trabajos síncronos (trabajos que utilizan el driver de cola `sync`) se ejecutarían de inmediato, independientemente de si la opción de configuración `after_commit` de la conexión de cola estaba configurada en `true` o si se invocaba el método `afterCommit` en el trabajo.
En Laravel 11, los trabajos de cola sincrónicos ahora respetarán la configuración de "después de la confirmación" de la conexión de cola o del trabajo.

<a name="rate-limiting"></a>
### Limitación de velocidad


<a name="per-second-rate-limiting"></a>
#### Limitación de Tasa por Segundo

Laravel 11 admite limitación de tasa por segundo en lugar de estar limitado a granularidad por minuto. Hay una variedad de posibles cambios incompatibles de los que debes estar al tanto relacionados con este cambio.
El constructor de la clase `GlobalLimit` ahora acepta segundos en lugar de minutos. Esta clase no está documentada y no se utilizaría típicamente en su aplicación:


```php
new GlobalLimit($attempts, 2 * 60);

```
El constructor de la clase `Limit` ahora acepta segundos en lugar de minutos. Todos los usos documentados de esta clase están limitados a constructores estáticos como `Limit::perMinute` y `Limit::perSecond`. Sin embargo, si estás instanciando esta clase manualmente, deberías actualizar tu aplicación para proporcionar segundos al constructor de la clase:


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

Laravel 11 ya no admite Cashier Stripe 14.x. Por lo tanto, debes actualizar la dependencia de Laravel Cashier Stripe de tu aplicación a `^15.0` en tu archivo `composer.json`.
Cashier Stripe 15.0 ya no carga automáticamente las migraciones desde su propio directorio de migraciones. En su lugar, debes ejecutar el siguiente comando para publicar las migraciones de Cashier Stripe en tu aplicación:


```shell
php artisan vendor:publish --tag=cashier-migrations

```
Por favor, revisa la completa [guía de actualización de Cashier Stripe](https://github.com/laravel/cashier-stripe/blob/15.x/UPGRADE.md) para obtener cambios adicionales que rompen la compatibilidad.

<a name="spark-stripe"></a>
### Spark (Stripe)


<a name="updating-spark-stripe"></a>
#### Actualizando Spark Stripe

Laravel 11 ya no admite Laravel Spark Stripe 4.x. Por lo tanto, debes actualizar la dependencia de Laravel Spark Stripe de tu aplicación a `^5.0` en tu archivo `composer.json`.
Spark Stripe 5.0 ya no carga automáticamente las migraciones desde su propio directorio de migraciones. En su lugar, deberías ejecutar el siguiente comando para publicar las migraciones de Spark Stripe en tu aplicación:


```shell
php artisan vendor:publish --tag=spark-migrations

```
Por favor, revisa la guía completa de [actualización de Spark Stripe](https://spark.laravel.com/docs/spark-stripe/upgrade.html) para conocer cambios importantes adicionales.

<a name="passport"></a>
### Passport

#### Actualizando Passport

Laravel 11 ya no admite Laravel Passport 11.x. Por lo tanto, debes actualizar la dependencia de Laravel Passport de tu aplicación a `^12.0` en tu archivo `composer.json`.
Passport 12.0 ya no carga automáticamente las migraciones desde su propio directorio de migraciones. En su lugar, deberías ejecutar el siguiente comando para publicar las migraciones de Passport en tu aplicación:


```shell
php artisan vendor:publish --tag=passport-migrations

```
Además, el tipo de concesión de contraseña está deshabilitado por defecto. Puedes habilitarlo invocando el método `enablePasswordGrant` en el método `boot` del `AppServiceProvider` de tu aplicación:


```php
public function boot(): void
{
    Passport::enablePasswordGrant();
}
```

<a name="sanctum"></a>
### Sanctum


<a name="updating-sanctum"></a>
#### Actualizando Sanctum

Laravel 11 ya no admite Laravel Sanctum 3.x. Por lo tanto, debes actualizar la dependencia de Laravel Sanctum de tu aplicación a `^4.0` en tu archivo `composer.json`.
Sanctum 4.0 ya no carga automáticamente las migraciones desde su propio directorio de migraciones. En su lugar, deberías ejecutar el siguiente comando para publicar las migraciones de Sanctum en tu aplicación:


```shell
php artisan vendor:publish --tag=sanctum-migrations

```
Entonces, en el archivo de configuración `config/sanctum.php` de tu aplicación, deberías actualizar las referencias a los middleware `authenticate_session`, `encrypt_cookies` y `validate_csrf_token` de la siguiente manera:


```php
'middleware' => [
    'authenticate_session' => Laravel\Sanctum\Http\Middleware\AuthenticateSession::class,
    'encrypt_cookies' => Illuminate\Cookie\Middleware\EncryptCookies::class,
    'validate_csrf_token' => Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
],
```

<a name="telescope"></a>
### Telescope


<a name="updating-telescope"></a>
#### Actualizando Telescope

**Probabilidad de Impacto: Alta**
Laravel 11 ya no soporta Laravel Telescope 4.x. Por lo tanto, deberías actualizar la dependencia de Laravel Telescope de tu aplicación a `^5.0` en tu archivo `composer.json`.
Telescope 5.0 ya no carga automáticamente las migraciones desde su propio directorio de migraciones. En su lugar, debes ejecutar el siguiente comando para publicar las migraciones de Telescope en tu aplicación:


```shell
php artisan vendor:publish --tag=telescope-migrations

```

<a name="spatie-once-package"></a>
### Paquete Spatie Once

**Probabilidad de Impacto: Media**
Laravel 11 ahora proporciona su propia función [`once`]( /docs/%7B%7Bversion%7D%7D/helpers#method-once) para asegurar que una cierta función anónima solo se ejecute una vez. Por lo tanto, si tu aplicación tiene una dependencia en el paquete `spatie/once`, deberías eliminarlo del archivo `composer.json` de tu aplicación para evitar conflictos.

<a name="miscellaneous"></a>
### Diverso

También te recomendamos que veas los cambios en el repositorio `laravel/laravel` [GitHub](https://github.com/laravel/laravel). Aunque muchos de estos cambios no son obligatorios, es posible que desees mantener estos archivos sincronizados con tu aplicación. Algunos de estos cambios se cubrirán en esta guía de actualización, pero otros, como cambios en archivos de configuración o comentarios, no lo estarán. Puedes ver fácilmente los cambios con la [herramienta de comparación de GitHub](https://github.com/laravel/laravel/compare/10.x...11.x) y elegir cuáles actualizaciones son importantes para ti.