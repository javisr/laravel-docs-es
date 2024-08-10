# Eloquent: Introducción

- [Eloquent: Introducción](#eloquent-introducción)
  - [Introducción](#introducción)
      - [Bootcamp de Laravel](#bootcamp-de-laravel)
  - [Generando Clases de Modelo](#generando-clases-de-modelo)
      - [Inspeccionando Modelos](#inspeccionando-modelos)
  - [Convenciones del Modelo Eloquent](#convenciones-del-modelo-eloquent)
    - [Nombres de Tablas](#nombres-de-tablas)
    - [Claves Primarias](#claves-primarias)
      - [Claves Primarias "Compuestas"](#claves-primarias-compuestas)
    - [Claves UUID y ULID](#claves-uuid-y-ulid)
    - [Timestamps](#timestamps)
    - [Conexiones a la Base de Datos](#conexiones-a-la-base-de-datos)
    - [Valores Predeterminados de Atributos](#valores-predeterminados-de-atributos)
    - [Configurando la Estrictez de Eloquent](#configurando-la-estrictez-de-eloquent)
  - [Recuperando Modelos](#recuperando-modelos)
      - [Construyendo Consultas](#construyendo-consultas)
      - [Refrescando Modelos](#refrescando-modelos)
    - [Procesamiento por partes](#procesamiento-por-partes)
    - [Procesamiento por partes usando colecciones perezosas](#procesamiento-por-partes-usando-colecciones-perezosas)
    - [Cursors](#cursors)
    - [Subconsultas avanzadas](#subconsultas-avanzadas)
      - [Selecciones de subconsultas](#selecciones-de-subconsultas)
      - [Ordenación de subconsultas](#ordenación-de-subconsultas)
  - [Recuperando modelos individuales / Agregados](#recuperando-modelos-individuales--agregados)
      - [Excepciones de no encontrado](#excepciones-de-no-encontrado)
    - [Recuperando o creando modelos](#recuperando-o-creando-modelos)
    - [Recuperando agregados](#recuperando-agregados)
  - [Insertando y actualizando modelos](#insertando-y-actualizando-modelos)
    - [Inserciones](#inserciones)
    - [Actualizaciones](#actualizaciones)
      - [Actualizaciones masivas](#actualizaciones-masivas)
      - [Examinando cambios en atributos](#examinando-cambios-en-atributos)
    - [Asignación Masiva](#asignación-masiva)
      - [Asignación Masiva y Columnas JSON](#asignación-masiva-y-columnas-json)
      - [Permitiendo Asignación Masiva](#permitiendo-asignación-masiva)
      - [Excepciones de Asignación Masiva](#excepciones-de-asignación-masiva)
    - [Upserts](#upserts)
  - [Eliminando Modelos](#eliminando-modelos)
      - [Eliminando un Modelo Existente por su Clave Primaria](#eliminando-un-modelo-existente-por-su-clave-primaria)
      - [Eliminando Modelos Usando Consultas](#eliminando-modelos-usando-consultas)
    - [Eliminación Suave](#eliminación-suave)
      - [Restaurando Modelos Eliminados Suavemente](#restaurando-modelos-eliminados-suavemente)
      - [Eliminando Modelos Permanentemente](#eliminando-modelos-permanentemente)
    - [Consultando Modelos Eliminados Suavemente](#consultando-modelos-eliminados-suavemente)
      - [Incluyendo Modelos Eliminados Suavemente](#incluyendo-modelos-eliminados-suavemente)
      - [Recuperando Solo Modelos Eliminados Suavemente](#recuperando-solo-modelos-eliminados-suavemente)
  - [Poda de Modelos](#poda-de-modelos)
      - [Eliminación Masiva](#eliminación-masiva)
  - [Replicando Modelos](#replicando-modelos)
  - [Alcances de Consulta](#alcances-de-consulta)
    - [Alcances Globales](#alcances-globales)
      - [Generando Alcances](#generando-alcances)
      - [Escribiendo Alcances Globales](#escribiendo-alcances-globales)
      - [Aplicando Alcances Globales](#aplicando-alcances-globales)
      - [Alcances Globales Anónimos](#alcances-globales-anónimos)
      - [Eliminando Alcances Globales](#eliminando-alcances-globales)
    - [Alcances Locales](#alcances-locales)
      - [Utilizando un Alcance Local](#utilizando-un-alcance-local)
      - [Alcances Dinámicos](#alcances-dinámicos)
  - [Comparando Modelos](#comparando-modelos)
  - [Eventos](#eventos)
    - [Usando Funciones Anónimas](#usando-funciones-anónimas)
    - [Observadores](#observadores)
      - [Definiendo Observadores](#definiendo-observadores)
      - [Observadores y Transacciones de Base de Datos](#observadores-y-transacciones-de-base-de-datos)
    - [Silenciar Eventos](#silenciar-eventos)
      - [Guardar un Solo Modelo Sin Eventos](#guardar-un-solo-modelo-sin-eventos)

<a name="introduction"></a>
## Introducción

Laravel incluye Eloquent, un mapeador objeto-relacional (ORM) que hace que interactuar con tu base de datos sea agradable. Al usar Eloquent, cada tabla de base de datos tiene un "Modelo" correspondiente que se utiliza para interactuar con esa tabla. Además de recuperar registros de la tabla de base de datos, los modelos Eloquent te permiten insertar, actualizar y eliminar registros de la tabla también.

> [!NOTE]  
> Antes de comenzar, asegúrate de configurar una conexión a la base de datos en el archivo de configuración `config/database.php` de tu aplicación. Para obtener más información sobre cómo configurar tu base de datos, consulta [la documentación de configuración de la base de datos](/docs/{{version}}/database#configuration).

#### Bootcamp de Laravel

Si eres nuevo en Laravel, siéntete libre de unirte al [Bootcamp de Laravel](https://bootcamp.laravel.com). El Bootcamp de Laravel te guiará a través de la construcción de tu primera aplicación Laravel utilizando Eloquent. Es una excelente manera de obtener un recorrido por todo lo que Laravel y Eloquent tienen para ofrecer.

<a name="generating-model-classes"></a>
## Generando Clases de Modelo

Para comenzar, vamos a crear un modelo Eloquent. Los modelos generalmente se encuentran en el directorio `app\Models` y extienden la clase `Illuminate\Database\Eloquent\Model`. Puedes usar el comando [Artisan make:model](/docs/{{version}}/artisan) para generar un nuevo modelo:

```shell
php artisan make:model Flight
```

Si deseas generar una [migración de base de datos](/docs/{{version}}/migrations) cuando generes el modelo, puedes usar la opción `--migration` o `-m`:

```shell
php artisan make:model Flight --migration
```

Puedes generar varios otros tipos de clases al generar un modelo, como factories, seeders, policies, controllers y form requests. Además, estas opciones pueden combinarse para crear múltiples clases a la vez:

```shell
# Generate a model and a FlightFactory class...
php artisan make:model Flight --factory
php artisan make:model Flight -f

# Generate a model and a FlightSeeder class...
php artisan make:model Flight --seed
php artisan make:model Flight -s

# Generate a model and a FlightController class...
php artisan make:model Flight --controller
php artisan make:model Flight -c

# Generate a model, FlightController resource class, and form request classes...
php artisan make:model Flight --controller --resource --requests
php artisan make:model Flight -crR

# Generate a model and a FlightPolicy class...
php artisan make:model Flight --policy

# Generate a model and a migration, factory, seeder, and controller...
php artisan make:model Flight -mfsc

# Shortcut to generate a model, migration, factory, seeder, policy, controller, and form requests...
php artisan make:model Flight --all
php artisan make:model Flight -a

# Generate a pivot model...
php artisan make:model Member --pivot
php artisan make:model Member -p
```

<a name="inspecting-models"></a>
#### Inspeccionando Modelos

A veces puede ser difícil determinar todos los atributos y relaciones disponibles de un modelo solo con revisar su código. En su lugar, prueba el comando Artisan `model:show`, que proporciona una visión general conveniente de todos los atributos y relaciones del modelo:

```shell
php artisan model:show Flight
```

<a name="eloquent-model-conventions"></a>
## Convenciones del Modelo Eloquent

Los modelos generados por el comando `make:model` se colocarán en el directorio `app/Models`. Examinemos una clase de modelo básica y discutamos algunas de las convenciones clave de Eloquent:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        // ...
    }

<a name="table-names"></a>
### Nombres de Tablas

Después de echar un vistazo al ejemplo anterior, es posible que hayas notado que no le dijimos a Eloquent qué tabla de base de datos corresponde a nuestro modelo `Flight`. Por convención, se utilizará el nombre plural en "snake case" de la clase como el nombre de la tabla a menos que se especifique explícitamente otro nombre. Así que, en este caso, Eloquent asumirá que el modelo `Flight` almacena registros en la tabla `flights`, mientras que un modelo `AirTrafficController` almacenaría registros en una tabla `air_traffic_controllers`.

Si la tabla de base de datos correspondiente a tu modelo no se ajusta a esta convención, puedes especificar manualmente el nombre de la tabla del modelo definiendo una propiedad `table` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * La tabla asociada con el modelo.
         *
         * @var string
         */
        protected $table = 'my_flights';
    }

<a name="primary-keys"></a>
### Claves Primarias

Eloquent también asumirá que la tabla de base de datos correspondiente a cada modelo tiene una columna de clave primaria llamada `id`. Si es necesario, puedes definir una propiedad protegida `$primaryKey` en tu modelo para especificar una columna diferente que sirva como la clave primaria de tu modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * La clave primaria asociada con la tabla.
         *
         * @var string
         */
        protected $primaryKey = 'flight_id';
    }

Además, Eloquent asume que la clave primaria es un valor entero autoincrementable, lo que significa que Eloquent convertirá automáticamente la clave primaria a un entero. Si deseas usar una clave primaria no autoincrementable o no numérica, debes definir una propiedad pública `$incrementing` en tu modelo que esté establecida en `false`:

    <?php

    class Flight extends Model
    {
        /**
         * Indica si la ID del modelo es autoincrementable.
         *
         * @var bool
         */
        public $incrementing = false;
    }

Si la clave primaria de tu modelo no es un entero, debes definir una propiedad protegida `$keyType` en tu modelo. Esta propiedad debe tener un valor de `string`:

    <?php

    class Flight extends Model
    {
        /**
         * El tipo de dato de la ID de la clave primaria.
         *
         * @var string
         */
        protected $keyType = 'string';
    }

<a name="composite-primary-keys"></a>
#### Claves Primarias "Compuestas"

Eloquent requiere que cada modelo tenga al menos una "ID" que lo identifique de manera única y que pueda servir como su clave primaria. Las claves primarias "compuestas" no son compatibles con los modelos Eloquent. Sin embargo, eres libre de agregar índices únicos de múltiples columnas a tus tablas de base de datos además de la clave primaria que identifica de manera única a la tabla.

<a name="uuid-and-ulid-keys"></a>
### Claves UUID y ULID

En lugar de usar enteros autoincrementables como las claves primarias de tu modelo Eloquent, puedes optar por usar UUIDs en su lugar. Los UUIDs son identificadores alfanuméricos universalmente únicos que tienen 36 caracteres de longitud.

Si deseas que un modelo use una clave UUID en lugar de una clave entera autoincrementable, puedes usar el trait `Illuminate\Database\Eloquent\Concerns\HasUuids` en el modelo. Por supuesto, debes asegurarte de que el modelo tenga una [columna de clave primaria equivalente a UUID](/docs/{{version}}/migrations#column-method-uuid):

    use Illuminate\Database\Eloquent\Concerns\HasUuids;
    use Illuminate\Database\Eloquent\Model;

    class Article extends Model
    {
        use HasUuids;

        // ...
    }

    $article = Article::create(['title' => 'Traveling to Europe']);

    $article->id; // "8f8e8478-9035-4d23-b9a7-62f4d2612ce5"

Por defecto, el trait `HasUuids` generará ["UUIDs ordenados"](/docs/{{version}}/strings#method-str-ordered-uuid) para tus modelos. Estos UUIDs son más eficientes para el almacenamiento en bases de datos indexadas porque pueden ser ordenados lexicográficamente.

Puedes anular el proceso de generación de UUID para un modelo dado definiendo un método `newUniqueId` en el modelo. Además, puedes especificar qué columnas deben recibir UUIDs definiendo un método `uniqueIds` en el modelo:

    use Ramsey\Uuid\Uuid;

    /**
     * Generar un nuevo UUID para el modelo.
     */
    public function newUniqueId(): string
    {
        return (string) Uuid::uuid4();
    }

    /**
     * Obtener las columnas que deben recibir un identificador único.
     *
     * @return array<int, string>
     */
    public function uniqueIds(): array
    {
        return ['id', 'discount_code'];
    }

Si lo deseas, puedes optar por utilizar "ULIDs" en lugar de UUIDs. Los ULIDs son similares a los UUIDs; sin embargo, solo tienen 26 caracteres de longitud. Al igual que los UUIDs ordenados, los ULIDs son ordenables lexicográficamente para un indexado eficiente en bases de datos. Para utilizar ULIDs, debes usar el trait `Illuminate\Database\Eloquent\Concerns\HasUlids` en tu modelo. También debes asegurarte de que el modelo tenga una [columna de clave primaria equivalente a ULID](/docs/{{version}}/migrations#column-method-ulid):

    use Illuminate\Database\Eloquent\Concerns\HasUlids;
    use Illuminate\Database\Eloquent\Model;

    class Article extends Model
    {
        use HasUlids;

        // ...
    }

    $article = Article::create(['title' => 'Traveling to Asia']);

    $article->id; // "01gd4d3tgrrfqeda94gdbtdk5c"

<a name="timestamps"></a>
### Timestamps

Por defecto, Eloquent espera que existan columnas `created_at` y `updated_at` en la tabla de base de datos correspondiente a tu modelo. Eloquent establecerá automáticamente los valores de estas columnas cuando se creen o actualicen modelos. Si no deseas que estas columnas sean gestionadas automáticamente por Eloquent, debes definir una propiedad `$timestamps` en tu modelo con un valor de `false`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * Indica si el modelo debe tener timestamps.
         *
         * @var bool
         */
        public $timestamps = false;
    }

Si necesitas personalizar el formato de los timestamps de tu modelo, establece la propiedad `$dateFormat` en tu modelo. Esta propiedad determina cómo se almacenan los atributos de fecha en la base de datos, así como su formato cuando el modelo se serializa a un array o JSON:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * El formato de almacenamiento de las columnas de fecha del modelo.
         *
         * @var string
         */
        protected $dateFormat = 'U';
    }

Si necesitas personalizar los nombres de las columnas utilizadas para almacenar los timestamps, puedes definir constantes `CREATED_AT` y `UPDATED_AT` en tu modelo:

    <?php

    class Flight extends Model
    {
        const CREATED_AT = 'creation_date';
        const UPDATED_AT = 'updated_date';
    }

Si deseas realizar operaciones en el modelo sin que se modifique el timestamp `updated_at` del modelo, puedes operar en el modelo dentro de una función anónima dada al método `withoutTimestamps`:

    Model::withoutTimestamps(fn () => $post->increment('reads'));

<a name="database-connections"></a>
### Conexiones a la Base de Datos

Por defecto, todos los modelos Eloquent utilizarán la conexión a la base de datos predeterminada que está configurada para tu aplicación. Si deseas especificar una conexión diferente que se debe utilizar al interactuar con un modelo en particular, debes definir una propiedad `$connection` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * La conexión a la base de datos que debe ser utilizada por el modelo.
         *
         * @var string
         */
        protected $connection = 'mysql';
    }

<a name="default-attribute-values"></a>
### Valores Predeterminados de Atributos

Por defecto, una instancia de modelo recién instanciada no contendrá ningún valor de atributo. Si deseas definir los valores predeterminados para algunos de los atributos de tu modelo, puedes definir una propiedad `$attributes` en tu modelo. Los valores de atributo colocados en el array `$attributes` deben estar en su formato "almacenable" en bruto, como si acabaran de ser leídos de la base de datos:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * Los valores predeterminados del modelo para los atributos.
         *
         * @var array
         */
        protected $attributes = [
            'options' => '[]',
            'delayed' => false,
        ];
    }

<a name="configuring-eloquent-strictness"></a>
### Configurando la Estrictez de Eloquent

Laravel ofrece varios métodos que te permiten configurar el comportamiento y la "estrictez" de Eloquent en una variedad de situaciones.

Primero, el método `preventLazyLoading` acepta un argumento booleano opcional que indica si se debe prevenir la carga perezosa. Por ejemplo, es posible que desees desactivar la carga perezosa solo en entornos no de producción para que tu entorno de producción continúe funcionando normalmente incluso si una relación cargada perezosamente está presente accidentalmente en el código de producción. Típicamente, este método debe ser invocado en el método `boot` del `AppServiceProvider` de tu aplicación:

```php
use Illuminate\Database\Eloquent\Model;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Model::preventLazyLoading(! $this->app->isProduction());
}
```

Además, puedes instruir a Laravel para que lance una excepción al intentar llenar un atributo no llenable invocando el método `preventSilentlyDiscardingAttributes`. Esto puede ayudar a prevenir errores inesperados durante el desarrollo local al intentar establecer un atributo que no se ha agregado al array `fillable` del modelo:

```php
Model::preventSilentlyDiscardingAttributes(! $this->app->isProduction());
```

<a name="retrieving-models"></a>
## Recuperando Modelos

Una vez que hayas creado un modelo y [su tabla de base de datos asociada](/docs/{{version}}/migrations#writing-migrations), estás listo para comenzar a recuperar datos de tu base de datos. Puedes pensar en cada modelo Eloquent como un poderoso [constructor de consultas](/docs/{{version}}/queries) que te permite consultar de manera fluida la tabla de base de datos asociada con el modelo. El método `all` del modelo recuperará todos los registros de la tabla de base de datos asociada al modelo:

    use App\Models\Flight;

    foreach (Flight::all() as $flight) {
        echo $flight->name;
    }

<a name="building-queries"></a>
#### Construyendo Consultas

El método `all` de Eloquent devolverá todos los resultados en la tabla del modelo. Sin embargo, dado que cada modelo Eloquent sirve como un [constructor de consultas](/docs/{{version}}/queries), puedes agregar restricciones adicionales a las consultas y luego invocar el método `get` para recuperar los resultados:

    $flights = Flight::where('active', 1)
                   ->orderBy('name')
                   ->take(10)
                   ->get();

> [!NOTE]  
> Dado que los modelos Eloquent son constructores de consultas, debes revisar todos los métodos proporcionados por el [constructor de consultas](/docs/{{version}}/queries) de Laravel. Puedes usar cualquiera de estos métodos al escribir tus consultas Eloquent.

<a name="refreshing-models"></a>
#### Refrescando Modelos

Si ya tienes una instancia de un modelo Eloquent que fue recuperada de la base de datos, puedes "refrescar" el modelo usando los métodos `fresh` y `refresh`. El método `fresh` volverá a recuperar el modelo de la base de datos. La instancia de modelo existente no se verá afectada:

```php
$flight = Flight::where('number', 'FR 900')->first();

$freshFlight = $flight->fresh();

El método `refresh` rehidratará el modelo existente utilizando datos frescos de la base de datos. Además, todas sus relaciones cargadas también se actualizarán:

$flight = Flight::where('number', 'FR 900')->first();

$flight->number = 'FR 456';

$flight->refresh();

$flight->number; // "FR 900"

<a name="collections"></a>
### Colecciones

Como hemos visto, los métodos de Eloquent como `all` y `get` recuperan múltiples registros de la base de datos. Sin embargo, estos métodos no devuelven un array PHP simple. En su lugar, se devuelve una instancia de `Illuminate\Database\Eloquent\Collection`.

La clase `Collection` de Eloquent extiende la clase base `Illuminate\Support\Collection` de Laravel, que proporciona una [variedad de métodos útiles](/docs/{{version}}/collections#available-methods) para interactuar con colecciones de datos. Por ejemplo, el método `reject` puede ser utilizado para eliminar modelos de una colección basándose en los resultados de una función anónima invocada:

```php
$flights = Flight::where('destination', 'Paris')->get();

$flights = $flights->reject(function (Flight $flight) {
    return $flight->cancelled;
});
```

Además de los métodos proporcionados por la clase de colección base de Laravel, la clase de colección de Eloquent proporciona [algunos métodos adicionales](/docs/{{version}}/eloquent-collections#available-methods) que están específicamente destinados para interactuar con colecciones de modelos de Eloquent.

Dado que todas las colecciones de Laravel implementan las interfaces iterables de PHP, puedes recorrer colecciones como si fueran un array:

```php
foreach ($flights as $flight) {
    echo $flight->name;
}
```

<a name="chunking-results"></a>
### Procesamiento por partes

Tu aplicación puede quedarse sin memoria si intentas cargar decenas de miles de registros de Eloquent a través de los métodos `all` o `get`. En lugar de usar estos métodos, se puede utilizar el método `chunk` para procesar grandes cantidades de modelos de manera más eficiente.

El método `chunk` recuperará un subconjunto de modelos de Eloquent, pasándolos a una función anónima para su procesamiento. Dado que solo se recupera el fragmento actual de modelos de Eloquent a la vez, el método `chunk` proporcionará un uso de memoria significativamente reducido al trabajar con un gran número de modelos:

```php
use App\Models\Flight;
use Illuminate\Database\Eloquent\Collection;

Flight::chunk(200, function (Collection $flights) {
    foreach ($flights as $flight) {
        // ...
    }
});
```

El primer argumento pasado al método `chunk` es el número de registros que deseas recibir por "fragmento". La función anónima pasada como segundo argumento será invocada para cada fragmento que se recupere de la base de datos. Se ejecutará una consulta a la base de datos para recuperar cada fragmento de registros pasados a la función anónima.

Si estás filtrando los resultados del método `chunk` basándote en una columna que también estarás actualizando mientras iteras sobre los resultados, deberías usar el método `chunkById`. Usar el método `chunk` en estos escenarios podría llevar a resultados inesperados e inconsistentes. Internamente, el método `chunkById` siempre recuperará modelos con una columna `id` mayor que el último modelo en el fragmento anterior:

```php
Flight::where('departed', true)
    ->chunkById(200, function (Collection $flights) {
        $flights->each->update(['departed' => false]);
    }, $column = 'id');
```

<a name="chunking-using-lazy-collections"></a>
### Procesamiento por partes usando colecciones perezosas

El método `lazy` funciona de manera similar al [método `chunk`](#chunking-results) en el sentido de que, tras bambalinas, ejecuta la consulta en fragmentos. Sin embargo, en lugar de pasar cada fragmento directamente a un callback, el método `lazy` devuelve una [`LazyCollection`](/docs/{{version}}/collections#lazy-collections) de modelos de Eloquent, lo que te permite interactuar con los resultados como un solo flujo:

```php
use App\Models\Flight;

foreach (Flight::lazy() as $flight) {
    // ...
}
```

Si estás filtrando los resultados del método `lazy` basándote en una columna que también estarás actualizando mientras iteras sobre los resultados, deberías usar el método `lazyById`. Internamente, el método `lazyById` siempre recuperará modelos con una columna `id` mayor que el último modelo en el fragmento anterior:

```php
Flight::where('departed', true)
    ->lazyById(200, $column = 'id')
    ->each->update(['departed' => false]);
```

Puedes filtrar los resultados basándote en el orden descendente del `id` usando el método `lazyByIdDesc`.

<a name="cursors"></a>
### Cursors

Similar al método `lazy`, el método `cursor` puede ser utilizado para reducir significativamente el consumo de memoria de tu aplicación al iterar a través de decenas de miles de registros de modelos de Eloquent.

El método `cursor` solo ejecutará una única consulta a la base de datos; sin embargo, los modelos individuales de Eloquent no serán hidratados hasta que realmente se iteren. Por lo tanto, solo se mantiene un modelo de Eloquent en memoria en un momento dado mientras se itera sobre el cursor.

> [!WARNING]  
> Dado que el método `cursor` solo mantiene un único modelo de Eloquent en memoria a la vez, no puede cargar relaciones de manera anticipada. Si necesitas cargar relaciones de manera anticipada, considera usar [el método `lazy`](#chunking-using-lazy-collections) en su lugar.

Internamente, el método `cursor` utiliza [generadores](https://www.php.net/manual/en/language.generators.overview.php) de PHP para implementar esta funcionalidad:

```php
use App\Models\Flight;

foreach (Flight::where('destination', 'Zurich')->cursor() as $flight) {
    // ...
}
```

El `cursor` devuelve una instancia de `Illuminate\Support\LazyCollection`. Las [colecciones perezosas](/docs/{{version}}/collections#lazy-collections) te permiten usar muchos de los métodos de colección disponibles en las colecciones típicas de Laravel mientras solo cargas un único modelo en memoria a la vez:

```php
use App\Models\User;

$users = User::cursor()->filter(function (User $user) {
    return $user->id > 500;
});

foreach ($users as $user) {
    echo $user->id;
}
```

Aunque el método `cursor` utiliza mucha menos memoria que una consulta regular (al mantener solo un único modelo de Eloquent en memoria a la vez), eventualmente también se quedará sin memoria. Esto es [debido a que el controlador PDO de PHP almacena en caché internamente todos los resultados de consultas en su búfer](https://www.php.net/manual/en/mysqlinfo.concepts.buffering.php). Si estás tratando con un número muy grande de registros de Eloquent, considera usar [el método `lazy`](#chunking-using-lazy-collections) en su lugar.

<a name="advanced-subqueries"></a>
### Subconsultas avanzadas

<a name="subquery-selects"></a>
#### Selecciones de subconsultas

Eloquent también ofrece soporte avanzado para subconsultas, lo que te permite extraer información de tablas relacionadas en una sola consulta. Por ejemplo, imaginemos que tenemos una tabla de `destinos` de vuelos y una tabla de `vuelos` a esos destinos. La tabla de `vuelos` contiene una columna `arrived_at` que indica cuándo llegó el vuelo al destino.

Usando la funcionalidad de subconsulta disponible en los métodos `select` y `addSelect` del constructor de consultas, podemos seleccionar todos los `destinos` y el nombre del vuelo que llegó más recientemente a ese destino utilizando una sola consulta:

```php
use App\Models\Destination;
use App\Models\Flight;

return Destination::addSelect(['last_flight' => Flight::select('name')
    ->whereColumn('destination_id', 'destinations.id')
    ->orderByDesc('arrived_at')
    ->limit(1)
])->get();
```

<a name="subquery-ordering"></a>
#### Ordenación de subconsultas

Además, la función `orderBy` del constructor de consultas admite subconsultas. Continuando con nuestro ejemplo de vuelos, podemos usar esta funcionalidad para ordenar todos los destinos según cuándo llegó el último vuelo a ese destino. Nuevamente, esto se puede hacer mientras se ejecuta una única consulta a la base de datos:

```php
return Destination::orderByDesc(
    Flight::select('arrived_at')
        ->whereColumn('destination_id', 'destinations.id')
        ->orderByDesc('arrived_at')
        ->limit(1)
)->get();
```

<a name="retrieving-single-models"></a>
## Recuperando modelos individuales / Agregados

Además de recuperar todos los registros que coinciden con una consulta dada, también puedes recuperar registros individuales usando los métodos `find`, `first` o `firstWhere`. En lugar de devolver una colección de modelos, estos métodos devuelven una única instancia de modelo:

```php
use App\Models\Flight;

// Recuperar un modelo por su clave primaria...
$flight = Flight::find(1);

// Recuperar el primer modelo que coincide con las restricciones de la consulta...
$flight = Flight::where('active', 1)->first();

// Alternativa para recuperar el primer modelo que coincide con las restricciones de la consulta...
$flight = Flight::firstWhere('active', 1);
```

A veces puedes desear realizar alguna otra acción si no se encuentran resultados. Los métodos `findOr` y `firstOr` devolverán una única instancia de modelo o, si no se encuentran resultados, ejecutarán la función anónima dada. El valor devuelto por la función anónima será considerado el resultado del método:

```php
$flight = Flight::findOr(1, function () {
    // ...
});

$flight = Flight::where('legs', '>', 3)->firstOr(function () {
    // ...
});
```

<a name="not-found-exceptions"></a>
#### Excepciones de no encontrado

A veces puedes desear lanzar una excepción si un modelo no se encuentra. Esto es particularmente útil en rutas o controladores. Los métodos `findOrFail` y `firstOrFail` recuperarán el primer resultado de la consulta; sin embargo, si no se encuentra ningún resultado, se lanzará una `Illuminate\Database\Eloquent\ModelNotFoundException`:

```php
$flight = Flight::findOrFail(1);

$flight = Flight::where('legs', '>', 3)->firstOrFail();
```

Si la `ModelNotFoundException` no es capturada, se enviará automáticamente una respuesta HTTP 404 al cliente:

```php
use App\Models\Flight;

Route::get('/api/flights/{id}', function (string $id) {
    return Flight::findOrFail($id);
});
```

<a name="retrieving-or-creating-models"></a>
### Recuperando o creando modelos

El método `firstOrCreate` intentará localizar un registro en la base de datos utilizando los pares de columna / valor dados. Si el modelo no se puede encontrar en la base de datos, se insertará un registro con los atributos resultantes de fusionar el primer argumento de array con el segundo argumento de array opcional:

El método `firstOrNew`, al igual que `firstOrCreate`, intentará localizar un registro en la base de datos que coincida con los atributos dados. Sin embargo, si no se encuentra un modelo, se devolverá una nueva instancia de modelo. Ten en cuenta que el modelo devuelto por `firstOrNew` aún no ha sido persistido en la base de datos. Necesitarás llamar manualmente al método `save` para persistirlo:

```php
use App\Models\Flight;

// Recuperar vuelo por nombre o crearlo si no existe...
$flight = Flight::firstOrCreate([
    'name' => 'London to Paris'
]);

// Recuperar vuelo por nombre o crearlo con los atributos name, delayed y arrival_time...
$flight = Flight::firstOrCreate(
    ['name' => 'London to Paris'],
    ['delayed' => 1, 'arrival_time' => '11:30']
);

// Recuperar vuelo por nombre o instanciar una nueva instancia de Flight...
$flight = Flight::firstOrNew([
    'name' => 'London to Paris'
]);

// Recuperar vuelo por nombre o instanciar con los atributos name, delayed y arrival_time...
$flight = Flight::firstOrNew(
    ['name' => 'Tokyo to Sydney'],
    ['delayed' => 1, 'arrival_time' => '11:30']
);
```

<a name="retrieving-aggregates"></a>
### Recuperando agregados

Al interactuar con modelos de Eloquent, también puedes usar los métodos `count`, `sum`, `max` y otros [métodos de agregados](/docs/{{version}}/queries#aggregates) proporcionados por el [constructor de consultas](#) de Laravel. Como puedes esperar, estos métodos devuelven un valor escalar en lugar de una instancia de modelo de Eloquent:

```php
$count = Flight::where('active', 1)->count();

$max = Flight::where('active', 1)->max('price');
```

<a name="inserting-and-updating-models"></a>
## Insertando y actualizando modelos

<a name="inserts"></a>
### Inserciones

Por supuesto, al usar Eloquent, no solo necesitamos recuperar modelos de la base de datos. También necesitamos insertar nuevos registros. Afortunadamente, Eloquent lo hace simple. Para insertar un nuevo registro en la base de datos, debes instanciar una nueva instancia de modelo y establecer atributos en el modelo. Luego, llama al método `save` en la instancia del modelo:

```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Flight;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class FlightController extends Controller
{
    /**
     * Almacenar un nuevo vuelo en la base de datos.
     */
    public function store(Request $request): RedirectResponse
    {
        // Validar la solicitud...

        $flight = new Flight;

        $flight->name = $request->name;

        $flight->save();

        return redirect('/flights');
    }
}
```

En este ejemplo, asignamos el campo `name` de la solicitud HTTP entrante al atributo `name` de la instancia del modelo `App\Models\Flight`. Cuando llamamos al método `save`, se insertará un registro en la base de datos. Las marcas de tiempo `created_at` y `updated_at` del modelo se establecerán automáticamente cuando se llame al método `save`, por lo que no es necesario establecerlas manualmente.

Alternativamente, puedes usar el método `create` para "guardar" un nuevo modelo usando una sola declaración PHP. La instancia del modelo insertado te será devuelta por el método `create`:

```php
use App\Models\Flight;

$flight = Flight::create([
    'name' => 'London to Paris',
]);
```

Sin embargo, antes de usar el método `create`, necesitarás especificar una propiedad `fillable` o `guarded` en tu clase de modelo. Estas propiedades son requeridas porque todos los modelos de Eloquent están protegidos contra vulnerabilidades de asignación masiva por defecto. Para aprender más sobre la asignación masiva, consulta la [documentación sobre asignación masiva](#mass-assignment).

<a name="updates"></a>
### Actualizaciones

El método `save` también puede ser utilizado para actualizar modelos que ya existen en la base de datos. Para actualizar un modelo, debes recuperarlo y establecer cualquier atributo que desees actualizar. Luego, debes llamar al método `save` del modelo. Nuevamente, la marca de tiempo `updated_at` se actualizará automáticamente, por lo que no es necesario establecer su valor manualmente:

```php
use App\Models\Flight;

$flight = Flight::find(1);

$flight->name = 'Paris to London';

$flight->save();
```

Ocasionalmente, puede que necesites actualizar un modelo existente o crear un nuevo modelo si no existe un modelo coincidente. Al igual que el método `firstOrCreate`, el método `updateOrCreate` persiste el modelo, por lo que no hay necesidad de llamar manualmente al método `save`.

En el siguiente ejemplo, si existe un vuelo con una ubicación de `departure` de `Oakland` y una ubicación de `destination` de `San Diego`, se actualizarán sus columnas `price` y `discounted`. Si no existe tal vuelo, se creará un nuevo vuelo que tiene los atributos resultantes de fusionar el primer array de argumentos con el segundo array de argumentos:

```php
$flight = Flight::updateOrCreate(
    ['departure' => 'Oakland', 'destination' => 'San Diego'],
    ['price' => 99, 'discounted' => 1]
);
```

<a name="mass-updates"></a>
#### Actualizaciones masivas

Las actualizaciones también se pueden realizar contra modelos que coincidan con una consulta dada. En este ejemplo, todos los vuelos que están `active` y tienen un `destination` de `San Diego` serán marcados como retrasados:

```php
Flight::where('active', 1)
      ->where('destination', 'San Diego')
      ->update(['delayed' => 1]);
```

El método `update` espera un array de pares de columna y valor que representan las columnas que deben ser actualizadas. El método `update` devuelve el número de filas afectadas.

> [!WARNING]  
> Al emitir una actualización masiva a través de Eloquent, los eventos de modelo `saving`, `saved`, `updating` y `updated` no se activarán para los modelos actualizados. Esto se debe a que los modelos nunca son realmente recuperados al emitir una actualización masiva.

<a name="examining-attribute-changes"></a>
#### Examinando cambios en atributos

Eloquent proporciona los métodos `isDirty`, `isClean` y `wasChanged` para examinar el estado interno de tu modelo y determinar cómo han cambiado sus atributos desde que el modelo fue recuperado originalmente.

El método `isDirty` determina si alguno de los atributos del modelo ha cambiado desde que se recuperó el modelo. Puedes pasar un nombre de atributo específico o un array de atributos al método `isDirty` para determinar si alguno de los atributos está "sucio". El método `isClean` determinará si un atributo ha permanecido sin cambios desde que se recuperó el modelo. Este método también acepta un argumento de atributo opcional:

    use App\Models\User;

    $user = User::create([
        'first_name' => 'Taylor',
        'last_name' => 'Otwell',
        'title' => 'Developer',
    ]);

    $user->title = 'Painter';

    $user->isDirty(); // true
    $user->isDirty('title'); // true
    $user->isDirty('first_name'); // false
    $user->isDirty(['first_name', 'title']); // true

    $user->isClean(); // false
    $user->isClean('title'); // false
    $user->isClean('first_name'); // true
    $user->isClean(['first_name', 'title']); // false

    $user->save();

    $user->isDirty(); // false
    $user->isClean(); // true

El método `wasChanged` determina si algún atributo fue cambiado cuando el modelo fue guardado por última vez dentro del ciclo de solicitud actual. Si es necesario, puedes pasar un nombre de atributo para ver si un atributo particular fue cambiado:

    $user = User::create([
        'first_name' => 'Taylor',
        'last_name' => 'Otwell',
        'title' => 'Developer',
    ]);

    $user->title = 'Painter';

    $user->save();

    $user->wasChanged(); // true
    $user->wasChanged('title'); // true
    $user->wasChanged(['title', 'slug']); // true
    $user->wasChanged('first_name'); // false
    $user->wasChanged(['first_name', 'title']); // true

El método `getOriginal` devuelve un array que contiene los atributos originales del modelo independientemente de cualquier cambio en el modelo desde que fue recuperado. Si es necesario, puedes pasar un nombre de atributo específico para obtener el valor original de un atributo particular:

    $user = User::find(1);

    $user->name; // John
    $user->email; // john@example.com

    $user->name = "Jack";
    $user->name; // Jack

    $user->getOriginal('name'); // John
    $user->getOriginal(); // Array of original attributes...

<a name="mass-assignment"></a>
### Asignación Masiva

Puedes usar el método `create` para "guardar" un nuevo modelo usando una sola declaración PHP. La instancia del modelo insertado te será devuelta por el método:

    use App\Models\Flight;

    $flight = Flight::create([
        'name' => 'London to Paris',
    ]);

Sin embargo, antes de usar el método `create`, necesitarás especificar una propiedad `fillable` o `guarded` en tu clase de modelo. Estas propiedades son necesarias porque todos los modelos Eloquent están protegidos contra vulnerabilidades de asignación masiva por defecto.

Una vulnerabilidad de asignación masiva ocurre cuando un usuario pasa un campo de solicitud HTTP inesperado y ese campo cambia una columna en tu base de datos que no esperabas. Por ejemplo, un usuario malicioso podría enviar un parámetro `is_admin` a través de una solicitud HTTP, que luego se pasa al método `create` de tu modelo, permitiendo al usuario escalarse a sí mismo a un administrador.

Así que, para comenzar, deberías definir qué atributos del modelo deseas hacer asignables masivamente. Puedes hacer esto usando la propiedad `$fillable` en el modelo. Por ejemplo, hagamos que el atributo `name` de nuestro modelo `Flight` sea asignable masivamente:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * Los atributos que son asignables masivamente.
         *
         * @var array
         */
        protected $fillable = ['name'];
    }

Una vez que hayas especificado qué atributos son asignables masivamente, puedes usar el método `create` para insertar un nuevo registro en la base de datos. El método `create` devuelve la instancia del modelo recién creado:

    $flight = Flight::create(['name' => 'London to Paris']);

Si ya tienes una instancia de modelo, puedes usar el método `fill` para poblarla con un array de atributos:

    $flight->fill(['name' => 'Amsterdam to Frankfurt']);

<a name="mass-assignment-json-columns"></a>
#### Asignación Masiva y Columnas JSON

Al asignar columnas JSON, cada clave asignable masivamente de la columna debe especificarse en el array `$fillable` de tu modelo. Por razones de seguridad, Laravel no admite la actualización de atributos JSON anidados al usar la propiedad `guarded`:

    /**
     * Los atributos que son asignables masivamente.
     *
     * @var array
     */
    protected $fillable = [
        'options->enabled',
    ];

<a name="allowing-mass-assignment"></a>
#### Permitiendo Asignación Masiva

Si deseas hacer que todos tus atributos sean asignables masivamente, puedes definir la propiedad `$guarded` de tu modelo como un array vacío. Si decides desproteger tu modelo, debes tener especial cuidado de siempre crear manualmente los arrays pasados a los métodos `fill`, `create` y `update` de Eloquent:

    /**
     * Los atributos que no son asignables masivamente.
     *
     * @var array
     */
    protected $guarded = [];

<a name="mass-assignment-exceptions"></a>
#### Excepciones de Asignación Masiva

Por defecto, los atributos que no están incluidos en el array `$fillable` son descartados silenciosamente al realizar operaciones de asignación masiva. En producción, este es un comportamiento esperado; sin embargo, durante el desarrollo local puede llevar a confusión sobre por qué los cambios en el modelo no están teniendo efecto.

Si lo deseas, puedes instruir a Laravel para que lance una excepción al intentar llenar un atributo no asignable invocando el método `preventSilentlyDiscardingAttributes`. Típicamente, este método debe ser invocado en el método `boot` de la clase `AppServiceProvider` de tu aplicación:

    use Illuminate\Database\Eloquent\Model;

    /**
     * Inicializa cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        Model::preventSilentlyDiscardingAttributes($this->app->isLocal());
    }

<a name="upserts"></a>
### Upserts

El método `upsert` de Eloquent puede ser utilizado para actualizar o crear registros en una sola operación atómica. El primer argumento del método consiste en los valores a insertar o actualizar, mientras que el segundo argumento enumera las columnas que identifican de manera única los registros dentro de la tabla asociada. El tercer y último argumento es un array de las columnas que deben ser actualizadas si ya existe un registro coincidente en la base de datos. El método `upsert` establecerá automáticamente las marcas de tiempo `created_at` y `updated_at` si las marcas de tiempo están habilitadas en el modelo:

    Flight::upsert([
        ['departure' => 'Oakland', 'destination' => 'San Diego', 'price' => 99],
        ['departure' => 'Chicago', 'destination' => 'New York', 'price' => 150]
    ], uniqueBy: ['departure', 'destination'], update: ['price']);

> [!WARNING]  
> Todas las bases de datos excepto SQL Server requieren que las columnas en el segundo argumento del método `upsert` tengan un índice "primario" o "único". Además, los controladores de base de datos de MariaDB y MySQL ignoran el segundo argumento del método `upsert` y siempre utilizan los índices "primarios" y "únicos" de la tabla para detectar registros existentes.

<a name="deleting-models"></a>
## Eliminando Modelos

Para eliminar un modelo, puedes llamar al método `delete` en la instancia del modelo:

    use App\Models\Flight;

    $flight = Flight::find(1);

    $flight->delete();

Puedes llamar al método `truncate` para eliminar todos los registros de base de datos asociados al modelo. La operación `truncate` también restablecerá cualquier ID de auto-incremento en la tabla asociada del modelo:

    Flight::truncate();

<a name="deleting-an-existing-model-by-its-primary-key"></a>
#### Eliminando un Modelo Existente por su Clave Primaria

En el ejemplo anterior, estamos recuperando el modelo de la base de datos antes de llamar al método `delete`. Sin embargo, si conoces la clave primaria del modelo, puedes eliminar el modelo sin recuperarlo explícitamente llamando al método `destroy`. Además de aceptar la única clave primaria, el método `destroy` aceptará múltiples claves primarias, un array de claves primarias o una [colección](/docs/{{version}}/collections) de claves primarias:

    Flight::destroy(1);

    Flight::destroy(1, 2, 3);

    Flight::destroy([1, 2, 3]);

    Flight::destroy(collect([1, 2, 3]));

> [!WARNING]  
> El método `destroy` carga cada modelo individualmente y llama al método `delete` para que los eventos `deleting` y `deleted` se despachen correctamente para cada modelo.

<a name="deleting-models-using-queries"></a>
#### Eliminando Modelos Usando Consultas

Por supuesto, puedes construir una consulta Eloquent para eliminar todos los modelos que coincidan con los criterios de tu consulta. En este ejemplo, eliminaremos todos los vuelos que están marcados como inactivos. Al igual que las actualizaciones masivas, las eliminaciones masivas no despacharán eventos de modelo para los modelos que son eliminados:

    $deleted = Flight::where('active', 0)->delete();

> [!WARNING]  
> Al ejecutar una declaración de eliminación masiva a través de Eloquent, los eventos de modelo `deleting` y `deleted` no se despacharán para los modelos eliminados. Esto se debe a que los modelos nunca son realmente recuperados al ejecutar la declaración de eliminación.

<a name="soft-deleting"></a>
### Eliminación Suave

Además de eliminar realmente registros de tu base de datos, Eloquent también puede "eliminar suavemente" modelos. Cuando los modelos son eliminados suavemente, no son realmente eliminados de tu base de datos. En su lugar, se establece un atributo `deleted_at` en el modelo que indica la fecha y hora en que el modelo fue "eliminado". Para habilitar eliminaciones suaves para un modelo, agrega el trait `Illuminate\Database\Eloquent\SoftDeletes` al modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\SoftDeletes;

    class Flight extends Model
    {
        use SoftDeletes;
    }

> [!NOTE]  
> El trait `SoftDeletes` automáticamente convertirá el atributo `deleted_at` en una instancia de `DateTime` / `Carbon` para ti.

También debes agregar la columna `deleted_at` a tu tabla de base de datos. El [constructor de esquemas](/docs/{{version}}/migrations) de Laravel contiene un método auxiliar para crear esta columna:

    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    Schema::table('flights', function (Blueprint $table) {
        $table->softDeletes();
    });

    Schema::table('flights', function (Blueprint $table) {
        $table->dropSoftDeletes();
    });

Ahora, cuando llames al método `delete` en el modelo, la columna `deleted_at` se establecerá en la fecha y hora actuales. Sin embargo, el registro del modelo en la base de datos se dejará en la tabla. Al consultar un modelo que utiliza eliminaciones suaves, los modelos eliminados suavemente se excluirán automáticamente de todos los resultados de consulta.

Para determinar si una instancia de modelo dada ha sido eliminada suavemente, puedes usar el método `trashed`:

    if ($flight->trashed()) {
        // ...
    }

<a name="restoring-soft-deleted-models"></a>
#### Restaurando Modelos Eliminados Suavemente

A veces puedes desear "des-eliminar" un modelo que ha sido eliminado suavemente. Para restaurar un modelo eliminado suavemente, puedes llamar al método `restore` en una instancia de modelo. El método `restore` establecerá la columna `deleted_at` del modelo en `null`:

    $flight->restore();

También puedes usar el método `restore` en una consulta para restaurar múltiples modelos. Nuevamente, al igual que otras operaciones "masivas", esto no despachará ningún evento de modelo para los modelos que son restaurados:

    Flight::withTrashed()
            ->where('airline_id', 1)
            ->restore();

El método `restore` también puede ser utilizado al construir consultas de [relaciones](/docs/{{version}}/eloquent-relationships):

    $flight->history()->restore();

<a name="permanently-deleting-models"></a>
#### Eliminando Modelos Permanentemente

A veces puedes necesitar eliminar verdaderamente un modelo de tu base de datos. Puedes usar el método `forceDelete` para eliminar permanentemente un modelo eliminado suavemente de la tabla de base de datos:

    $flight->forceDelete();

También puedes usar el método `forceDelete` al construir consultas de relaciones Eloquent:

    $flight->history()->forceDelete();

<a name="querying-soft-deleted-models"></a>
### Consultando Modelos Eliminados Suavemente

<a name="including-soft-deleted-models"></a>
#### Incluyendo Modelos Eliminados Suavemente

Como se mencionó anteriormente, los modelos eliminados suavemente se excluirán automáticamente de los resultados de consulta. Sin embargo, puedes forzar que los modelos eliminados suavemente se incluyan en los resultados de una consulta llamando al método `withTrashed` en la consulta:

    use App\Models\Flight;

    $flights = Flight::withTrashed()
                    ->where('account_id', 1)
                    ->get();

El método `withTrashed` también puede ser llamado al construir una consulta de [relación](/docs/{{version}}/eloquent-relationships):

    $flight->history()->withTrashed()->get();

<a name="retrieving-only-soft-deleted-models"></a>
#### Recuperando Solo Modelos Eliminados Suavemente

El método `onlyTrashed` recuperará **solo** modelos eliminados suavemente:

    $flights = Flight::onlyTrashed()
                    ->where('airline_id', 1)
                    ->get();

<a name="pruning-models"></a>
## Poda de Modelos

A veces puedes querer eliminar periódicamente modelos que ya no son necesarios. Para lograr esto, puedes agregar el trait `Illuminate\Database\Eloquent\Prunable` o `Illuminate\Database\Eloquent\MassPrunable` a los modelos que te gustaría podar periódicamente. Después de agregar uno de los traits al modelo, implementa un método `prunable` que devuelva un constructor de consultas Eloquent que resuelva los modelos que ya no son necesarios:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Prunable;

    class Flight extends Model
    {
        use Prunable;

        /**
         * Obtiene la consulta del modelo podable.
         */
        public function prunable(): Builder
        {
            return static::where('created_at', '<=', now()->subMonth());
        }
    }

Al marcar modelos como `Prunable`, también puedes definir un método `pruning` en el modelo. Este método se llamará antes de que el modelo sea eliminado. Este método puede ser útil para eliminar cualquier recurso adicional asociado con el modelo, como archivos almacenados, antes de que el modelo sea eliminado permanentemente de la base de datos:

    /**
     * Prepara el modelo para la poda.
     */
    protected function pruning(): void
    {
        // ...
    }

Después de configurar tu modelo podable, deberías programar el comando Artisan `model:prune` en el archivo `routes/console.php` de tu aplicación. Eres libre de elegir el intervalo apropiado en el que este comando debe ejecutarse:

    use Illuminate\Support\Facades\Schedule;

    Schedule::command('model:prune')->daily();

Detrás de escena, el comando `model:prune` detectará automáticamente los modelos "Prunable" dentro del directorio `app/Models` de tu aplicación. Si tus modelos están en una ubicación diferente, puedes usar la opción `--model` para especificar los nombres de clase del modelo:

    Schedule::command('model:prune', [
        '--model' => [Address::class, Flight::class],
    ])->daily();

Si deseas excluir ciertos modelos de ser podados mientras podas todos los demás modelos detectados, puedes usar la opción `--except`:

    Schedule::command('model:prune', [
        '--except' => [Address::class, Flight::class],
    ])->daily();

Puedes probar tu consulta `prunable` ejecutando el comando `model:prune` con la opción `--pretend`. Al pretender, el comando `model:prune` simplemente informará cuántos registros serían podados si el comando se ejecutara realmente:

```shell
php artisan model:prune --pretend
```

> [!WARNING]  
> Los modelos eliminados suavemente se eliminarán permanentemente (`forceDelete`) si coinciden con la consulta de eliminación.

<a name="mass-pruning"></a>
#### Eliminación Masiva

Cuando los modelos están marcados con el rasgo `Illuminate\Database\Eloquent\MassPrunable`, los modelos se eliminan de la base de datos utilizando consultas de eliminación masiva. Por lo tanto, el método `pruning` no se invocará, ni se enviarán los eventos de modelo `deleting` y `deleted`. Esto se debe a que los modelos nunca se recuperan realmente antes de la eliminación, lo que hace que el proceso de eliminación sea mucho más eficiente:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\MassPrunable;

    class Flight extends Model
    {
        use MassPrunable;

        /**
         * Obtener la consulta del modelo eliminable.
         */
        public function prunable(): Builder
        {
            return static::where('created_at', '<=', now()->subMonth());
        }
    }

<a name="replicating-models"></a>
## Replicando Modelos

Puedes crear una copia no guardada de una instancia de modelo existente utilizando el método `replicate`. Este método es particularmente útil cuando tienes instancias de modelo que comparten muchos de los mismos atributos:

    use App\Models\Address;

    $shipping = Address::create([
        'type' => 'shipping',
        'line_1' => '123 Example Street',
        'city' => 'Victorville',
        'state' => 'CA',
        'postcode' => '90001',
    ]);

    $billing = $shipping->replicate()->fill([
        'type' => 'billing'
    ]);

    $billing->save();

Para excluir uno o más atributos de ser replicados al nuevo modelo, puedes pasar un array al método `replicate`:

    $flight = Flight::create([
        'destination' => 'LAX',
        'origin' => 'LHR',
        'last_flown' => '2020-03-04 11:00:00',
        'last_pilot_id' => 747,
    ]);

    $flight = $flight->replicate([
        'last_flown',
        'last_pilot_id'
    ]);

<a name="query-scopes"></a>
## Alcances de Consulta

<a name="global-scopes"></a>
### Alcances Globales

Los alcances globales te permiten agregar restricciones a todas las consultas para un modelo dado. La funcionalidad de [eliminación suave](#soft-deleting) de Laravel utiliza alcances globales para recuperar solo los modelos "no eliminados" de la base de datos. Escribir tus propios alcances globales puede proporcionar una forma conveniente y fácil de asegurarte de que cada consulta para un modelo dado reciba ciertas restricciones.

<a name="generating-scopes"></a>
#### Generando Alcances

Para generar un nuevo alcance global, puedes invocar el comando Artisan `make:scope`, que colocará el alcance generado en el directorio `app/Models/Scopes` de tu aplicación:

```shell
php artisan make:scope AncientScope
```

<a name="writing-global-scopes"></a>
#### Escribiendo Alcances Globales

Escribir un alcance global es simple. Primero, usa el comando `make:scope` para generar una clase que implemente la interfaz `Illuminate\Database\Eloquent\Scope`. La interfaz `Scope` requiere que implementes un método: `apply`. El método `apply` puede agregar restricciones `where` u otros tipos de cláusulas a la consulta según sea necesario:

    <?php

    namespace App\Models\Scopes;

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Scope;

    class AncientScope implements Scope
    {
        /**
         * Aplicar el alcance a un constructor de consultas Eloquent dado.
         */
        public function apply(Builder $builder, Model $model): void
        {
            $builder->where('created_at', '<', now()->subYears(2000));
        }
    }

> [!NOTE]  
> Si tu alcance global está agregando columnas a la cláusula select de la consulta, debes usar el método `addSelect` en lugar de `select`. Esto evitará el reemplazo involuntario de la cláusula select existente de la consulta.

<a name="applying-global-scopes"></a>
#### Aplicando Alcances Globales

Para asignar un alcance global a un modelo, simplemente puedes colocar el atributo `ScopedBy` en el modelo:

    <?php

    namespace App\Models;

    use App\Models\Scopes\AncientScope;
    use Illuminate\Database\Eloquent\Attributes\ScopedBy;

    #[ScopedBy([AncientScope::class])]
    class User extends Model
    {
        //
    }

O, puedes registrar manualmente el alcance global sobrescribiendo el método `booted` del modelo e invocando el método `addGlobalScope` del modelo. El método `addGlobalScope` acepta una instancia de tu alcance como su único argumento:

    <?php

    namespace App\Models;

    use App\Models\Scopes\AncientScope;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * El método "booted" del modelo.
         */
        protected static function booted(): void
        {
            static::addGlobalScope(new AncientScope);
        }
    }

Después de agregar el alcance en el ejemplo anterior al modelo `App\Models\User`, una llamada al método `User::all()` ejecutará la siguiente consulta SQL:

```sql
select * from `users` where `created_at` < 0021-02-18 00:00:00
```

<a name="anonymous-global-scopes"></a>
#### Alcances Globales Anónimos

Eloquent también te permite definir alcances globales utilizando funciones anónimas, lo cual es particularmente útil para alcances simples que no justifican una clase separada. Al definir un alcance global utilizando una función anónima, debes proporcionar un nombre de alcance de tu elección como el primer argumento del método `addGlobalScope`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * El método "booted" del modelo.
         */
        protected static function booted(): void
        {
            static::addGlobalScope('ancient', function (Builder $builder) {
                $builder->where('created_at', '<', now()->subYears(2000));
            });
        }
    }

<a name="removing-global-scopes"></a>
#### Eliminando Alcances Globales

Si deseas eliminar un alcance global para una consulta dada, puedes usar el método `withoutGlobalScope`. Este método acepta el nombre de la clase del alcance global como su único argumento:

    User::withoutGlobalScope(AncientScope::class)->get();

O, si definiste el alcance global utilizando una función anónima, debes pasar el nombre de cadena que asignaste al alcance global:

    User::withoutGlobalScope('ancient')->get();

Si deseas eliminar varios o incluso todos los alcances globales de la consulta, puedes usar el método `withoutGlobalScopes`:

    // Eliminar todos los alcances globales...
    User::withoutGlobalScopes()->get();

    // Eliminar algunos de los alcances globales...
    User::withoutGlobalScopes([
        FirstScope::class, SecondScope::class
    ])->get();

<a name="local-scopes"></a>
### Alcances Locales

Los alcances locales te permiten definir conjuntos comunes de restricciones de consulta que puedes reutilizar fácilmente en toda tu aplicación. Por ejemplo, es posible que necesites recuperar frecuentemente todos los usuarios que se consideran "populares". Para definir un alcance, prefija un método de modelo Eloquent con `scope`.

Los alcances siempre deben devolver la misma instancia del constructor de consultas o `void`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Alcance una consulta para incluir solo usuarios populares.
         */
        public function scopePopular(Builder $query): void
        {
            $query->where('votes', '>', 100);
        }

        /**
         * Alcance una consulta para incluir solo usuarios activos.
         */
        public function scopeActive(Builder $query): void
        {
            $query->where('active', 1);
        }
    }

<a name="utilizing-a-local-scope"></a>
#### Utilizando un Alcance Local

Una vez que se ha definido el alcance, puedes llamar a los métodos de alcance al consultar el modelo. Sin embargo, no debes incluir el prefijo `scope` al llamar al método. Incluso puedes encadenar llamadas a varios alcances:

    use App\Models\User;

    $users = User::popular()->active()->orderBy('created_at')->get();

Combinar múltiples alcances de modelo Eloquent a través de un operador de consulta `or` puede requerir el uso de funciones anónimas para lograr el correcto [agrupamiento lógico](/docs/{{version}}/queries#logical-grouping):

    $users = User::popular()->orWhere(function (Builder $query) {
        $query->active();
    })->get();

Sin embargo, dado que esto puede ser engorroso, Laravel proporciona un método `orWhere` de "orden superior" que te permite encadenar alcances de manera fluida sin el uso de funciones anónimas:

    $users = User::popular()->orWhere->active()->get();

<a name="dynamic-scopes"></a>
#### Alcances Dinámicos

A veces puedes desear definir un alcance que acepte parámetros. Para comenzar, simplemente agrega tus parámetros adicionales a la firma del método de tu alcance. Los parámetros del alcance deben definirse después del parámetro `$query`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Alcance una consulta para incluir solo usuarios de un tipo dado.
         */
        public function scopeOfType(Builder $query, string $type): void
        {
            $query->where('type', $type);
        }
    }

Una vez que se han agregado los argumentos esperados a la firma del método de tu alcance, puedes pasar los argumentos al llamar al alcance:

    $users = User::ofType('admin')->get();

<a name="comparing-models"></a>
## Comparando Modelos

A veces puedes necesitar determinar si dos modelos son "iguales" o no. Los métodos `is` e `isNot` pueden usarse para verificar rápidamente si dos modelos tienen la misma clave primaria, tabla y conexión a la base de datos o no:

    if ($post->is($anotherPost)) {
        // ...
    }

    if ($post->isNot($anotherPost)) {
        // ...
    }

Los métodos `is` e `isNot` también están disponibles al usar las [relaciones](/docs/{{version}}/eloquent-relationships) `belongsTo`, `hasOne`, `morphTo` y `morphOne`. Este método es particularmente útil cuando deseas comparar un modelo relacionado sin emitir una consulta para recuperar ese modelo:

    if ($post->author()->is($user)) {
        // ...
    }

<a name="events"></a>
## Eventos

> [!NOTE]  
> ¿Quieres transmitir tus eventos Eloquent directamente a tu aplicación del lado del cliente? Consulta la [transmisión de eventos de modelo](/docs/{{version}}/broadcasting#model-broadcasting) de Laravel.

Los modelos Eloquent despachan varios eventos, lo que te permite engancharte en los siguientes momentos en el ciclo de vida de un modelo: `retrieved`, `creating`, `created`, `updating`, `updated`, `saving`, `saved`, `deleting`, `deleted`, `trashed`, `forceDeleting`, `forceDeleted`, `restoring`, `restored`, y `replicating`.

El evento `retrieved` se despachará cuando se recupere un modelo existente de la base de datos. Cuando un nuevo modelo se guarda por primera vez, se despacharán los eventos `creating` y `created`. Los eventos `updating` / `updated` se despacharán cuando se modifique un modelo existente y se llame al método `save`. Los eventos `saving` / `saved` se despacharán cuando se cree o actualice un modelo, incluso si los atributos del modelo no han cambiado. Los nombres de los eventos que terminan en `-ing` se despachan antes de que se persistan los cambios en el modelo, mientras que los eventos que terminan en `-ed` se despachan después de que se persistan los cambios en el modelo.

Para comenzar a escuchar eventos de modelo, define una propiedad `$dispatchesEvents` en tu modelo Eloquent. Esta propiedad mapea varios puntos del ciclo de vida del modelo Eloquent a tus propias [clases de eventos](/docs/{{version}}/events). Cada clase de evento de modelo debe esperar recibir una instancia del modelo afectado a través de su constructor:

    <?php

    namespace App\Models;

    use App\Events\UserDeleted;
    use App\Events\UserSaved;
    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * El mapa de eventos para el modelo.
         *
         * @var array<string, string>
         */
        protected $dispatchesEvents = [
            'saved' => UserSaved::class,
            'deleted' => UserDeleted::class,
        ];
    }

Después de definir y mapear tus eventos Eloquent, puedes usar [escuchadores de eventos](/docs/{{version}}/events#defining-listeners) para manejar los eventos.

> [!WARNING]  
> Al emitir una actualización masiva o una consulta de eliminación a través de Eloquent, los eventos de modelo `saved`, `updated`, `deleting` y `deleted` no se despacharán para los modelos afectados. Esto se debe a que los modelos nunca se recuperan realmente al realizar actualizaciones o eliminaciones masivas.

<a name="events-using-closures"></a>
### Usando Funciones Anónimas

En lugar de usar clases de eventos personalizadas, puedes registrar funciones anónimas que se ejecutan cuando se despachan varios eventos de modelo. Normalmente, debes registrar estas funciones anónimas en el método `booted` de tu modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * El método "booted" del modelo.
         */
        protected static function booted(): void
        {
            static::created(function (User $user) {
                // ...
            });
        }
    }

Si es necesario, puedes utilizar [escuchadores de eventos anónimos en cola](/docs/{{version}}/events#queuable-anonymous-event-listeners) al registrar eventos de modelo. Esto indicará a Laravel que ejecute el escuchador de eventos del modelo en segundo plano utilizando la [cola](/docs/{{version}}/queues) de tu aplicación:

    use function Illuminate\Events\queueable;

    static::created(queueable(function (User $user) {
        // ...
    }));

<a name="observers"></a>
### Observadores

<a name="defining-observers"></a>
#### Definiendo Observadores

Si estás escuchando muchos eventos en un modelo dado, puedes usar observadores para agrupar todos tus escuchadores en una sola clase. Las clases de observadores tienen nombres de métodos que reflejan los eventos Eloquent que deseas escuchar. Cada uno de estos métodos recibe el modelo afectado como su único argumento. El comando Artisan `make:observer` es la forma más fácil de crear una nueva clase de observador:

```shell
php artisan make:observer UserObserver --model=User
```

Este comando colocará el nuevo observador en tu directorio `app/Observers`. Si este directorio no existe, Artisan lo creará por ti. Tu nuevo observador se verá como el siguiente:

    <?php

    namespace App\Observers;

    use App\Models\User;

    class UserObserver
    {
        /**
         * Manejar el evento "created" del User.
         */
        public function created(User $user): void
        {
            // ...
        }

        /**
         * Manejar el evento "updated" del User.
         */
        public function updated(User $user): void
        {
            // ...
        }

        /**
         * Manejar el evento "deleted" del User.
         */
        public function deleted(User $user): void
        {
            // ...
        }

        /**
         * Manejar el evento "restored" del User.
         */
        public function restored(User $user): void
        {
            // ...
        }

        /**
         * Manejar el evento "forceDeleted" del User.
         */
        public function forceDeleted(User $user): void
        {
            // ...
        }
    }

Para registrar un observador, puedes colocar el atributo `ObservedBy` en el modelo correspondiente:

    use App\Observers\UserObserver;
    use Illuminate\Database\Eloquent\Attributes\ObservedBy;

    #[ObservedBy([UserObserver::class])]
    class User extends Authenticatable
    {
        //
    }

O puede registrar manualmente un observador invocando el método `observe` en el modelo que desea observar. Puede registrar observadores en el método `boot` de la clase `AppServiceProvider` de su aplicación:

    use App\Models\User;
    use App\Observers\UserObserver;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        User::observe(UserObserver::class);
    }

> [!NOTE]  
> Hay eventos adicionales a los que un observador puede escuchar, como `saving` y `retrieved`. Estos eventos se describen en la documentación de [events](#events).

<a name="observers-and-database-transactions"></a>
#### Observadores y Transacciones de Base de Datos

Cuando los modelos se están creando dentro de una transacción de base de datos, es posible que desee instruir a un observador para que ejecute sus controladores de eventos solo después de que la transacción de base de datos se haya confirmado. Puede lograr esto implementando la interfaz `ShouldHandleEventsAfterCommit` en su observador. Si no hay una transacción de base de datos en progreso, los controladores de eventos se ejecutarán de inmediato:

    <?php

    namespace App\Observers;

    use App\Models\User;
    use Illuminate\Contracts\Events\ShouldHandleEventsAfterCommit;

    class UserObserver implements ShouldHandleEventsAfterCommit
    {
        /**
         * Handle the User "created" event.
         */
        public function created(User $user): void
        {
            // ...
        }
    }

<a name="muting-events"></a>
### Silenciar Eventos

Es posible que ocasionalmente necesite "silenciar" temporalmente todos los eventos disparados por un modelo. Puede lograr esto utilizando el método `withoutEvents`. El método `withoutEvents` acepta una función anónima como su único argumento. Cualquier código ejecutado dentro de esta función anónima no despachará eventos del modelo, y cualquier valor devuelto por la función anónima será devuelto por el método `withoutEvents`:

    use App\Models\User;

    $user = User::withoutEvents(function () {
        User::findOrFail(1)->delete();

        return User::find(2);
    });

<a name="saving-a-single-model-without-events"></a>
#### Guardar un Solo Modelo Sin Eventos

A veces puede desear "guardar" un modelo dado sin despachar ningún evento. Puede lograr esto utilizando el método `saveQuietly`:

    $user = User::findOrFail(1);

    $user->name = 'Victoria Faith';

    $user->saveQuietly();

También puede "actualizar", "eliminar", "eliminar suavemente", "restaurar" y "replicar" un modelo dado sin despachar ningún evento:

    $user->deleteQuietly();
    $user->forceDeleteQuietly();
    $user->restoreQuietly();
```
