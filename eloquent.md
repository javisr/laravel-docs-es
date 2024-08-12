# Eloquent: Primeros pasos

- [Introducción](#introduction)
- [Generación de clases modelo](#generating-model-classes)
- [Convenciones de Eloquent Model](#eloquent-model-conventions)
  - [Nombres de tablas](#table-names)
  - [Claves primarias](#primary-keys)
  - [Claves UUID y ULID](#uuid-and-ulid-keys)
  - [Marcas de tiempo](#timestamps)
  - [Conexiones de bases de datos](#database-connections)
  - [Valores por defecto de los atributos](#default-attribute-values)
  - [Configuración de Eloquent Strictness](#configuring-eloquent-strictness)
- [Recuperación de modelos](#retrieving-models)
  - [Colecciones](#collections)
  - [Agrupación de resultados](#chunking-results)
  - [Agrupar usando colecciones perezosas](#chunking-using-lazy-collections)
  - [Cursores](#cursors)
  - [Subconsultas avanzadas](#advanced-subqueries)
- [Recuperación de Modelos Individuales / Agregados](#retrieving-single-models)
  - [Recuperación o creación de modelos](#retrieving-or-creating-models)
  - [Recuperación de agregados](#retrieving-aggregates)
- [Inserción y actualización de modelos](#inserting-and-updating-models)
  - [Inserciones](#inserts)
  - [Actualizaciones](#updates)
  - [Asignación Masiva](#mass-assignment)
  - [Upserts](#upserts)
- [Borrado de modelos](#deleting-models)
  - [Borrado suave](#soft-deleting)
  - [Consulta de modelos borrados en software](#querying-soft-deleted-models)
- [Poda de modelos](#pruning-models)
- [Replicación de modelos](#replicating-models)
- [Ámbitos de consulta](#query-scopes)
  - [Ámbitos globales](#global-scopes)
  - [Ámbitos locales](#local-scopes)
- [Comparación de modelos](#comparing-models)
- [Eventos](#events)
  - [Uso de closures](#events-using-closures)
  - [Observadores](#observers)
  - [Silenciando Eventos](#muting-events)

<a name="introduction"></a>
## Introducción

Laravel incluye Eloquent, un mapeador objeto-relacional (ORM) que hace que sea agradable interactuar con tu base de datos. Cuando se utiliza Eloquent, cada tabla de la base de datos tiene su correspondiente "Modelo" que se utiliza para interactuar con esa tabla. Además de recuperar registros de la tabla de la base de datos, los modelos de Eloquent permiten insertar, actualizar y eliminar registros de la tabla.

> **Nota**  
> Antes de empezar, asegúrate de configurar una conexión a la base de datos en el archivo de configuración `config/database.php` de tu aplicación. Para más información sobre la configuración de la base de datos, consulta [la documentación de configuración de la base de datos](/docs/{{version}}/database#configuration).

#### Laravel Bootcamp

Si eres nuevo en Laravel, puedes echarle un ojo al [Laravel Bootcamp](https://bootcamp.laravel.com). El Laravel Bootcamp te guiará a través de la construcción de tu primera aplicación Laravel utilizando Eloquent. Es una buena forma de aprender sobre lo que  Laravel y Eloquent puede ofrecerte.

<a name="generating-model-classes"></a>
## Generación de clases de modelos

Para empezar, vamos a crear un modelo Eloquent. Los modelos normalmente viven en el directorio `app\Models` y extienden la clase `Illuminate\Database\Eloquent\Model`. Puede utilizar el [comando Artisan](/docs/{{version}}/artisan) `make:model` para generar un nuevo modelo:

```shell
php artisan make:model Flight
```

Si desea generar una [migración de base de datos](/docs/{{version}}/migrations) al generar el modelo, puede utilizar la opción `--migration` o `-m`:

```shell
php artisan make:model Flight --migration
```

Puedes generar varios otros tipos de clases al generar un modelo, tales como factories, seeders, policies, controllers, y form requests. Además, estas opciones pueden combinarse para crear múltiples clases a la vez:

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

# Generate a pivot model...
php artisan make:model Member --pivot
```

<a name="inspecting-models"></a>
#### Inspección de modelos

A veces puede ser difícil determinar todos los atributos y relaciones disponibles de un modelo simplemente hojeando su código. En su lugar, pruebe el comando Artisan `model:show`, que proporciona una buena visión general de todos los atributos y relaciones del modelo:

```shell
php artisan model:show Flight
```

<a name="eloquent-model-conventions"></a>
## Convenciones del modelo Eloquent

Los modelos generados por el comando `make:model` serán colocados en el directorio `app/Models`. Examinemos una clase modelo básica y discutamos algunas de las convenciones clave de Eloquent:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        //
    }

<a name="table-names"></a>
### Nombres de tablas

Después de echar un vistazo al ejemplo anterior, te habrás dado cuenta de que no le hemos dicho a Eloquent qué tabla de la base de datos corresponde a nuestro modelo `Flight`. Por convención, el nombre de la clase en plural y en formato "snake_case" será usado como el nombre de tabla a menos que otro nombre sea especificado expresamente. Así, en este caso, Eloquent asumirá que el modelo `Flight` almacena los registros en la tabla `flights`, mientras que un modelo `AirTrafficController` almacenaría los registros en una tabla `air_traffic_controllers`.

Si la tabla de base de datos correspondiente a tu modelo no se ajusta a esta convención, puedes especificar manualmente el nombre de la tabla del modelo definiendo una propiedad de `table` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * The table associated with the model.
         *
         * @var string
         */
        protected $table = 'my_flights';
    }

<a name="primary-keys"></a>
### Claves primarias

Eloquent también asumirá que la tabla de base de datos correspondiente a cada modelo tiene una columna de clave primaria llamada `id`. Si es necesario, puede definir una propiedad protegida `$primaryKey` en su modelo para especificar una columna diferente que sirva como clave primaria de su modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * The primary key associated with the table.
         *
         * @var string
         */
        protected $primaryKey = 'flight_id';
    }

Además, Eloquent asume que la clave primaria es un valor entero incremental, lo que significa que Eloquent convertirá automáticamente la clave primaria en un entero. Si desea utilizar una clave primaria no incremental o no numérica, debe definir una propiedad pública `$incrementing` en su modelo con el valor `false`:

    <?php

    class Flight extends Model
    {
        /**
         * Indicates if the model's ID is auto-incrementing.
         *
         * @var bool
         */
        public $incrementing = false;
    }

Si la clave primaria de su modelo no es un entero, debe definir una propiedad protegida `$keyType` en su modelo. Esta propiedad debe tener el valor `string`:

    <?php

    class Flight extends Model
    {
        /**
         * The data type of the auto-incrementing ID.
         *
         * @var string
         */
        protected $keyType = 'string';
    }

<a name="composite-primary-keys"></a>
#### Claves primarias compuestas

Eloquent requiere que cada modelo tenga al menos un "ID" de identificación único que pueda servir como clave primaria. Los modelos Eloquent no admiten claves primarias "compuestas". Sin embargo, puede añadir índices únicos adicionales de varias columnas a las tablas de la base de datos, además de la clave principal de identificación única de la tabla.

<a name="uuid-and-ulid-keys"></a>
### Claves UUID y ULID

En lugar de utilizar números enteros autoincrementados como claves primarias de su modelo Eloquent, puede optar por utilizar UUIDs en su lugar. Los UUIDs son identificadores alfanuméricos universalmente únicos de 36 caracteres de longitud.

Si desea que un modelo utilice una clave UUID en lugar de una clave entera autoincrementada, puede utilizar el trait `Illuminate\Database\Eloquent\Concerns\HasUuids` en el modelo. Por supuesto, debe asegurarse de que el modelo tiene una [columna de clave primaria equivalente a UUID](/docs/{{version}}/migrations#column-method-uuid):

    use Illuminate\Database\Eloquent\Concerns\HasUuids;
    use Illuminate\Database\Eloquent\Model;

    class Article extends Model
    {
        use HasUuids;

        // ...
    }

    $article = Article::create(['title' => 'Traveling to Europe']);

    $article->id; // "8f8e8478-9035-4d23-b9a7-62f4d2612ce5"

Por defecto, el trait `HasUuids` generará [UUIDs "ordenados"](/docs/{{version}}/helpers#method-str-ordered-uuid) para sus modelos. Estos UUIDs son más eficientes para el almacenamiento indexado en bases de datos porque pueden ser ordenados lexicográficamente.

Puede sobreescribir el proceso de generación de UUID para un modelo determinado definiendo un método `newUniqueId` en el modelo. Además, puede especificar qué columnas deben recibir UUIDs definiendo un método `uniqueIds` en el modelo:

    use Ramsey\Uuid\Uuid;

    /**
     * Generate a new UUID for the model.
     *
     * @return string
     */
    public function newUniqueId()
    {
        return (string) Uuid::uuid4();
    }

    /**
     * Get the columns that should receive a unique identifier.
     *
     * @return array
     */
    public function uniqueIds()
    {
        return ['id', 'discount_code'];
    }

Si lo desea, puede optar por utilizar "ULIDs" en lugar de UUIDs. Los ULIDs son similares a los UUIDs; sin embargo, sólo tienen 26 caracteres de longitud. Al igual que los UUID ordenados, los ULID pueden ordenarse lexicográficamente para una indexación eficiente de la base de datos. Para utilizar ULIDs, debe utilizar el trait `Illuminate\Database\Eloquent\Concerns\HasUlids` en su modelo. También debe asegurarse de que el modelo tiene una [columna de clave primaria equivalente a ULID](/docs/{{version}}/migrations#column-method-ulid):

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
### Marcas de tiempo

Por defecto, Eloquent espera que las columnas `created_at` y `updated_at` existan en la tabla correspondiente de la base de datos del modelo. Eloquent establecerá automáticamente los valores de estas columnas cuando se creen o actualicen los modelos. Si no quieres que estas columnas sean gestionadas automáticamente por Eloquent, debes definir una propiedad `$timestamps` en tu modelo con el valor `false`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * Indicates if the model should be timestamped.
         *
         * @var bool
         */
        public $timestamps = false;
    }

Si necesita personalizar el formato de las marcas de tiempo de su modelo, defina la propiedad `$dateFormat` en su modelo. Esta propiedad determina cómo se almacenan los atributos de fecha en la base de datos, así como su formato cuando el modelo se serializa a un array o JSON:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * The storage format of the model's date columns.
         *
         * @var string
         */
        protected $dateFormat = 'U';
    }

Si necesita personalizar los nombres de las columnas utilizadas para almacenar las marcas de tiempo, puede definir las constantes `CREATED_AT` y `UPDATED_AT` en su modelo:

    <?php

    class Flight extends Model
    {
        const CREATED_AT = 'creation_date';
        const UPDATED_AT = 'updated_date';
    }

Si quieres realizar operaciones sobre el modelo sin que se modifique su timestamp `updated_at`, puedes operar sobre el modelo dentro de un closure dado al método `withoutTimestamps`:

    Model::withoutTimestamps(fn () => $post->increment(['reads']));

<a name="database-connections"></a>
### Conexiones de bases de datos

Por defecto, todos los modelos de Eloquent utilizarán la conexión de base de datos por defecto configurada para tu aplicación. Si desea especificar una conexión diferente para un modelo en particular, debe definir una propiedad `$connection` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * The database connection that should be used by the model.
         *
         * @var string
         */
        protected $connection = 'sqlite';
    }

<a name="default-attribute-values"></a>
### Valores por defecto de los atributos

Por defecto, una instancia de modelo recién instanciada no contendrá ningún valor de atributo. Si desea definir los valores por defecto para algunos de los atributos de su modelo, puede definir una propiedad `$attributes` en su modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * The model's default values for attributes.
         *
         * @var array
         */
        protected $attributes = [
            'delayed' => false,
        ];
    }

<a name="configuring-eloquent-strictness"></a>
### Configuración de Eloquent Strictness

Laravel ofrece varios métodos que le permiten configurar el comportamiento de Eloquent y la "rigurosidad" en una variedad de situaciones.

En primer lugar, el método `preventLazyLoading` acepta un argumento booleano opcional que indica si debe evitarse la carga lenta. Por ejemplo, es posible que sólo desee desactivar la carga lenta en entornos que no sean de producción para que su entorno de producción siga funcionando normalmente incluso si una relación cargada de forma lenta está accidentalmente presente en el código de producción. Típicamente, este método debería ser invocado en el método `boot` del `AppServiceProvider` de su aplicación:

```php
use Illuminate\Database\Eloquent\Model;

/**
 * Bootstrap any application services.
 *
 * @return void
 */
public function boot()
{
    Model::preventLazyLoading(! $this->app->isProduction());
}
```

Además, puede indicar a Laravel que lance una excepción cuando intente rellenar un atributo no rellenable invocando el método `preventSilentlyDiscardingAttributes`. Esto puede ayudar a prevenir errores inesperados durante el desarrollo local cuando se intenta establecer un atributo que no se ha añadido a la array `fillable` del modelo:

```php
Model::preventSilentlyDiscardingAttributes(! $this->app->isProduction());
```

Por último, puede indicar a Eloquent que lance una excepción si intenta acceder a un atributo de un modelo cuando ese atributo no se ha recuperado realmente de la base de datos o cuando el atributo no existe. Por ejemplo, esto puede ocurrir cuando se olvida añadir un atributo a la cláusula `select` de una consulta de Eloquent:

```php
Model::preventAccessingMissingAttributes(! $this->app->isProduction());
```

<a name="enabling-eloquent-strict-mode"></a>
#### Activar el "modo estricto" de Eloquent

Para mayor comodidad, puede activar los tres métodos anteriores simplemente invocando el método `shouldBeStrict`:

```php
Model::shouldBeStrict(! $this->app->isProduction());
```

<a name="retrieving-models"></a>
## Recuperación de modelos

Una vez que has creado un modelo y [su tabla de base de datos asociada](/docs/{{version}}/migrations#writing-migrations), estás listo para empezar a recuperar datos de tu base de datos. Puedes pensar en cada modelo Eloquent como un potente [constructor de consultas](/docs/{{version}}/queries) que te permite consultar con fluidez la tabla de base de datos asociada al modelo. El método `all` del modelo recuperará todos los registros de la tabla de base de datos asociada al modelo:

    use App\Models\Flight;

    foreach (Flight::all() as $flight) {
        echo $flight->name;
    }

<a name="building-queries"></a>
#### Creación de consultas

El método `all` de Eloquent devolverá todos los resultados de la tabla del modelo. Sin embargo, dado que cada modelo Eloquent sirve como [constructor de consultas](/docs/{{version}}/queries), puedes añadir restricciones adicionales a las consultas y luego invocar el método `get` para recuperar los resultados:

    $flights = Flight::where('active', 1)
                   ->orderBy('name')
                   ->take(10)
                   ->get();

> **Nota**  
> Dado que los modelos Eloquent son constructores de consultas, deberías revisar todos los métodos proporcionados por el [constructor de consultas](/docs/{{version}}/queries) de Laravel. Puedes utilizar cualquiera de estos métodos cuando escribas tus consultas Eloquent.

<a name="refreshing-models"></a>
#### Actualización de modelos

Si ya tienes una instancia de un modelo Eloquent que fue recuperada de la base de datos, puedes "refrescar" el modelo usando los métodos `fresh` y `refresh`. El método `fresh` recuperará el modelo de la base de datos. La instancia del modelo existente no se verá afectada:

    $flight = Flight::where('number', 'FR 900')->first();

    $freshFlight = $flight->fresh();

El método `refresh` rehidratará el modelo existente utilizando datos frescos de la base de datos. Además, todas sus relaciones cargadas se actualizarán también:

    $flight = Flight::where('number', 'FR 900')->first();

    $flight->number = 'FR 456';

    $flight->refresh();

    $flight->number; // "FR 900"

<a name="collections"></a>
### Colecciones

Como hemos visto, los métodos de Eloquent como `all` y `get` recuperan múltiples registros de la base de datos. Sin embargo, estos métodos no devuelven un simple array PHP. En su lugar, devuelven una instancia de `Illuminate\Database\Eloquent\Collection`.

La clase Eloquent `Collection` extiende la clase base `Illuminate\Support\Collection` de Laravel, que proporciona una [variedad de métodos útiles](/docs/{{version}}/collections#available-methods) para interactuar con las colecciones de datos. Por ejemplo, el método `reject` puede utilizarse para eliminar modelos de una colección basándose en los resultados de un closure invocado:

```php
$flights = Flight::where('destination', 'Paris')->get();

$flights = $flights->reject(function ($flight) {
    return $flight->cancelled;
});
```

Además de los métodos proporcionados por la clase base collection de Laravel, la clase collection de Eloquent proporciona [algunos métodos extra](/docs/{{version}}/eloquent-collections#available-methods) que están específicamente pensados para interactuar con colecciones de modelos Eloquent.

Dado que todas las colecciones de Laravel implementan las interfaces iterables de PHP, puedes hacer bucles sobre las colecciones como si fueran un array:

```php
foreach ($flights as $flight) {
    echo $flight->name;
}
```

<a name="chunking-results"></a>
### Dividir resultados en partes

Tu aplicación puede quedarse sin memoria si intentas cargar decenas de miles de registros Eloquent mediante los métodos `all` o `get`. En lugar de utilizar estos métodos, se puede utilizar el método `chunk` para procesar un gran número de modelos de manera más eficiente.

El método `chunk` recuperará un subconjunto de modelos Eloquent, pasándolos a un closure para su procesamiento. Dado que sólo se recupera el trozo actual de modelos Eloquent a la vez, el método de `chunk` reducirá significativamente el uso de memoria cuando se trabaje con un gran número de modelos:

```php
use App\Models\Flight;

Flight::chunk(200, function ($flights) {
    foreach ($flights as $flight) {
        //
    }
});
```

El primer argumento que se pasa al método `chunk` es el número de registros que se desea recibir por "chunk". El closure pasado como segundo argumento se invocará para cada "chunk" que se recupere de la base de datos. Se ejecutará una consulta a la base de datos para recuperar cada trozo de registros pasado al closure.

Si va a filtrar los resultados del método `chunk` basándose en una columna que también va a actualizar mientras itera sobre los resultados, debería utilizar el método `chunkById`. Utilizar el método `chunk` en estos casos podría dar lugar a resultados inesperados e incoherentes. Internamente, el método `chunkById` siempre recuperará modelos con una columna `id` mayor que el último modelo del chunk anterior:

```php
Flight::where('departed', true)
    ->chunkById(200, function ($flights) {
        $flights->each->update(['departed' => false]);
    }, $column = 'id');
```

<a name="chunking-using-lazy-collections"></a>
### Dividir resultados en partes mediante Lazy Collections

El método `lazy` funciona de forma similar [al método `chunk`](#chunking-results) en el sentido de que, entre bastidores, ejecuta la consulta por trozos. Sin embargo, en lugar de pasar cada trozo directamente a una llamada de retorno, el método `lazy` devuelve una [`LazyCollection`](/docs/{{version}}/collections#lazy-collections) de modelos Eloquent, lo que permite interactuar con los resultados como un único flujo:

```php
use App\Models\Flight;

foreach (Flight::lazy() as $flight) {
    //
}
```

Si va a filtrar los resultados del método `lazy` basándose en una columna que también va a actualizar mientras itera sobre los resultados, debería utilizar el método `lazyById`. Internamente, el método `lazyById` siempre recuperará modelos con una columna `id` mayor que el último modelo del chunk anterior:

```php
Flight::where('departed', true)
    ->lazyById(200, $column = 'id')
    ->each->update(['departed' => false]);
```

Puede filtrar los resultados basándose en el orden descendente del `id` utilizando el método `lazyByIdDesc`.

<a name="cursors"></a>
### Cursores

Al igual que el método `lazy`, el método `cursor` se puede utilizar para reducir significativamente el consumo de memoria de la aplicación cuando se itera a través de decenas de miles de registros de modelos de Eloquent.

El método `cursor` sólo ejecutará una única consulta a la base de datos; sin embargo, los modelos Eloquent individuales no se hidratarán hasta que realmente se itere sobre ellos. Por lo tanto, sólo un modelo Eloquent se mantiene en memoria en un momento dado mientras se itera sobre el cursor.

> **Advertencia**  
> Dado que el método `cursor` sólo mantiene un único modelo Eloquent en memoria cada vez, no puede precargar sus relaciones de forma anticipada. Si necesitas cargar relaciones, considera usar [el método `lazy`](#chunking-using-lazy-collections) en su lugar.

Internamente, el método `cursor` utiliza [generadores](https://www.php.net/manual/en/language.generators.overview.php) PHP para implementar esta funcionalidad:

```php
use App\Models\Flight;

foreach (Flight::where('destination', 'Zurich')->cursor() as $flight) {
    //
}
```

El `cursor` devuelve una instancia `Illuminate\Support\LazyCollection`. Las [colecciones lazy](/docs/{{version}}/collections#lazy-collections) le permiten utilizar muchos de los métodos de colección disponibles en las colecciones típicas de Laravel, mientras que sólo se carga un único modelo en la memoria a la vez:

```php
use App\Models\User;

$users = User::cursor()->filter(function ($user) {
    return $user->id > 500;
});

foreach ($users as $user) {
    echo $user->id;
}
```

Aunque el método `cursor` utiliza mucha menos memoria que una consulta normal (al mantener un único modelo de Eloquent en memoria cada vez), con el tiempo se quedará sin memoria. Esto se debe [a que el controlador PDO de PHP almacena internamente en caché todos los resultados sin procesar de la consulta en su búfer](https://www.php.net/manual/en/mysqlinfo.concepts.buffering.php). Si está tratando con un gran número de registros Eloquent, considere usar [el método `lazy`](#chunking-using-lazy-collections) en su lugar.

<a name="advanced-subqueries"></a>
### Subconsultas avanzadas

<a name="subquery-selects"></a>
#### Selección de subconsultas

Eloquent también ofrece soporte avanzado para subconsultas, lo que permite extraer información de tablas relacionadas en una única consulta. Por ejemplo, imaginemos que tenemos una tabla `destinos` (destinations) de vuelos y una tabla de `vuelos` (flights) a destinos. La tabla de `vuelos` contiene una columna `arrived_at` que indica cuándo llegó el vuelo al destino.

Utilizando la funcionalidad de subconsulta disponible para los métodos `select` y `addSelect` del constructor de consultas, podemos seleccionar todos los `destinos` y el nombre del vuelo que llegó más recientemente a ese destino utilizando una única consulta:

    use App\Models\Destination;
    use App\Models\Flight;

    return Destination::addSelect(['last_flight' => Flight::select('name')
        ->whereColumn('destination_id', 'destinations.id')
        ->orderByDesc('arrived_at')
        ->limit(1)
    ])->get();

<a name="subquery-ordering"></a>
#### Ordenación de subconsultas

Además, la función `orderBy` del generador de consultas admite subconsultas. Siguiendo con nuestro ejemplo del vuelo, podemos utilizar esta función para ordenar todos los destinos en función de cuándo llegó el último vuelo a ese destino. De nuevo, esto puede hacerse mientras se ejecuta una única consulta a la base de datos:

    return Destination::orderByDesc(
        Flight::select('arrived_at')
            ->whereColumn('destination_id', 'destinations.id')
            ->orderByDesc('arrived_at')
            ->limit(1)
    )->get();

<a name="retrieving-single-models"></a>
## Recuperación de modelos individuales / agregados

Además de recuperar todos los registros que coincidan con una consulta determinada, también puede recuperar registros individuales utilizando los métodos `find`, `first` o `firstWhere`. En lugar de devolver una colección de modelos, estos métodos devuelven una única instancia del modelo:

    use App\Models\Flight;

    // Retrieve a model by its primary key...
    $flight = Flight::find(1);

    // Retrieve the first model matching the query constraints...
    $flight = Flight::where('active', 1)->first();

    // Alternative to retrieving the first model matching the query constraints...
    $flight = Flight::firstWhere('active', 1);

A veces es posible que desee realizar alguna otra acción si no se encuentra ningún resultado. Los métodos `findOr` y `firstOr` devolverán una única instancia del modelo o, si no se encuentran resultados, ejecutarán el closure dado. El valor devuelto por el closure se considerará el resultado del método:

    $flight = Flight::findOr(1, function () {
        // ...
    });

    $flight = Flight::where('legs', '>', 3)->firstOr(function () {
        // ...
    });

<a name="not-found-exceptions"></a>
#### Excepciones de no encontrado

A veces es posible que desee lanzar una excepción si no se encuentra un modelo. Esto es particularmente útil en rutas o controladores. Los métodos `findOrFail` y `firstOrFail` recuperarán el primer resultado de la consulta; sin embargo, si no se encuentra ningún resultado, se lanzará una excepción `Illuminate\Database\Eloquent\ModelNotFoundException`:

    $flight = Flight::findOrFail(1);

    $flight = Flight::where('legs', '>', 3)->firstOrFail();

Si no se detecta la excepción `ModelNotFoundException`, se envía automáticamente una respuesta HTTP 404 al cliente:

    use App\Models\Flight;

    Route::get('/api/flights/{id}', function ($id) {
        return Flight::findOrFail($id);
    });

<a name="retrieving-or-creating-models"></a>
### Recuperación o creación de modelos

El método `firstOrCreate` intentará localizar un registro de la base de datos utilizando los pares columna / valor dados. Si el modelo no se encuentra en la base de datos, se insertará un registro con los atributos resultantes de combinar el primer argumento de array con el segundo argumento opcional array:

El método `firstOrNew`, al igual que `firstOrCreate`, intentará localizar un registro en la base de datos que coincida con los atributos dados. Sin embargo, si no se encuentra un modelo, se devolverá una nueva instancia del modelo. Tenga en cuenta que el modelo devuelto por `firstOrNew` aún no se ha guardado en la base de datos. Deberá llamar manualmente al método `save` para guardarlo:

    use App\Models\Flight;

    // Retrieve flight by name or create it if it doesn't exist...
    $flight = Flight::firstOrCreate([
        'name' => 'London to Paris'
    ]);

    // Retrieve flight by name or create it with the name, delayed, and arrival_time attributes...
    $flight = Flight::firstOrCreate(
        ['name' => 'London to Paris'],
        ['delayed' => 1, 'arrival_time' => '11:30']
    );

    // Retrieve flight by name or instantiate a new Flight instance...
    $flight = Flight::firstOrNew([
        'name' => 'London to Paris'
    ]);

    // Retrieve flight by name or instantiate with the name, delayed, and arrival_time attributes...
    $flight = Flight::firstOrNew(
        ['name' => 'Tokyo to Sydney'],
        ['delayed' => 1, 'arrival_time' => '11:30']
    );

<a name="retrieving-aggregates"></a>
### Recuperación de agregados

Al interactuar con modelos Eloquent, también puede utilizar el  `count`, `sum`, `max` y otros [métodos agregados](/docs/{{version}}/queries#aggregates) proporcionados por el [constructor de consultas de Laravel](/docs/{{version}}/queries). Como es de esperar, estos métodos devuelven un valor escalar en lugar de una instancia del modelo Eloquent:

    $count = Flight::where('active', 1)->count();

    $max = Flight::where('active', 1)->max('price');

<a name="inserting-and-updating-models"></a>
## Inserción y actualización de modelos

<a name="inserts"></a>
### Inserciones

Por supuesto, cuando usamos Eloquent, no sólo necesitamos recuperar modelos de la base de datos. También necesitamos insertar nuevos registros. Afortunadamente, Eloquent lo hace sencillo. Para insertar un nuevo registro en la base de datos, debes instanciar una nueva instancia de modelo y establecer atributos en el modelo. A continuación, llame al método `save` en la instancia del modelo:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\Flight;
    use Illuminate\Http\Request;

    class FlightController extends Controller
    {
        /**
         * Store a new flight in the database.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function store(Request $request)
        {
            // Validate the request...

            $flight = new Flight;

            $flight->name = $request->name;

            $flight->save();
        }
    }

En este ejemplo, asignamos el campo `name` de la petición HTTP entrante al atributo `name` de la instancia del modelo `App\Models\Flight`. Cuando llamemos al método `save`, se insertará un registro en la base de datos. Las marcas de tiempo `created_at` y `updated_at` del modelo se establecerán automáticamente cuando se llame al método `save`, por lo que no es necesario establecerlas manualmente.

De manera alternativa, puede usar el método `create` para "guardar" un nuevo modelo usando una sola sentencia PHP. La instancia del modelo insertado le será devuelta por el método `create`:

    use App\Models\Flight;

    $flight = Flight::create([
        'name' => 'London to Paris',
    ]);

Sin embargo, antes de usar el método `create`, necesitará especificar una propiedad `fillable` o `guarded` en su clase modelo. Estas propiedades son necesarias porque todos los modelos Eloquent están protegidos contra vulnerabilidades de asignación masiva por defecto. Para obtener más información sobre la asignación masiva, consulte la [documentación de asignación masiva](#mass-assignment).

<a name="updates"></a>
### Actualizaciones

El método `save` también puede utilizarse para actualizar modelos que ya existen en la base de datos. Para actualizar un modelo, debe recuperarlo y establecer los atributos que desee actualizar. A continuación, debe llamar al método `save` del modelo. De nuevo, la marca de tiempo `updated_at` se actualizará automáticamente, por lo que no es necesario establecer su valor manualmente:

    use App\Models\Flight;

    $flight = Flight::find(1);

    $flight->name = 'Paris to London';

    $flight->save();

<a name="mass-updates"></a>
#### Actualizaciones masivas

También se pueden realizar actualizaciones contra modelos que coincidan con una consulta determinada. En este ejemplo, todos los vuelos que estén `active` y tengan como `destination` San Diego se marcarán como retrasados:

    Flight::where('active', 1)
          ->where('destination', 'San Diego')
          ->update(['delayed' => 1]);

El método `update` espera un array de pares de columnas y valores que representan las columnas que deben actualizarse. El método `update` devuelve el número de filas afectadas.

> **Advertencia**  
> Al realizar una actualización masiva a través de Eloquent, los eventos `saving`, `saved`, `updating` y `updated`  no se lanzarán para los modelos actualizados. Esto se debe a que los modelos nunca se recuperan cuando se emite una actualización masiva.

<a name="examining-attribute-changes"></a>
#### Examinar cambios de atributos

Eloquent proporciona los métodos `isDirty`, `isClean` y `wasChanged` para examinar el estado interno de su modelo y determinar cómo han cambiado sus atributos desde que se recuperó el modelo originalmente.

El método `isDirty` determina si alguno de los atributos del modelo ha cambiado desde que se recuperó el modelo. Puede pasar un nombre de atributo específico o un array de atributos al método `isDirty` para determinar si alguno de los atributos está "sucio". El método `isClean` determinará si un atributo no ha cambiado desde que se recuperó el modelo. Este método también acepta un argumento de atributo opcional:

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

El método `wasChanged` determina si se ha modificado algún atributo la última vez que se guardó el modelo dentro del ciclo de solicitud actual. Si es necesario, puede pasar un nombre de atributo para ver si se ha modificado un atributo concreto:

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

El método `getOriginal` devuelve un array que contiene los atributos originales del modelo, independientemente de cualquier cambio que se haya producido en el modelo desde que se recuperó. Si es necesario, puedes pasar un nombre de atributo específico para obtener el valor original de un atributo en particular:

    $user = User::find(1);

    $user->name; // John
    $user->email; // john@example.com

    $user->name = "Jack";
    $user->name; // Jack

    $user->getOriginal('name'); // John
    $user->getOriginal(); // Array of original attributes...

<a name="mass-assignment"></a>
### Asignación Masiva

Puede utilizar el método `create` para "guardar" un nuevo modelo utilizando una única sentencia PHP. La instancia del modelo insertado le será devuelta por el método:

    use App\Models\Flight;

    $flight = Flight::create([
        'name' => 'London to Paris',
    ]);

Sin embargo, antes de usar el método `create`, necesitará especificar una propiedad `fillable` o `guarded` en su clase modelo. Estas propiedades son necesarias porque todos los modelos Eloquent están protegidos contra vulnerabilidades de asignación masiva por defecto.

Una vulnerabilidad de asignación masiva ocurre cuando un usuario pasa un campo de solicitud HTTP inesperado y ese campo cambia una columna en su base de datos que usted no esperaba. Por ejemplo, un usuario malicioso podría enviar un parámetro `is_admin` a través de una petición HTTP, que luego se pasa al método `create` de tu modelo, permitiendo al usuario escalarse a sí mismo a administrador.

Así que, para empezar, deberías definir qué atributos del modelo quieres hacer asignables en masa. Puedes hacer esto usando la propiedad `$fillable` en el modelo. Por ejemplo, hagamos que el atributo `name` de nuestro modelo `Flight` sea asignable en masa:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Flight extends Model
    {
        /**
         * The attributes that are mass assignable.
         *
         * @var array
         */
        protected $fillable = ['name'];
    }

Una vez que hayas especificado qué atributos son asignables en masa, puedes utilizar el método `create` para insertar un nuevo registro en la base de datos. El método `create` devuelve la instancia de modelo recién creada:

    $flight = Flight::create(['name' => 'London to Paris']);

Si ya tienes una instancia del modelo, puedes usar el método `fill` para rellenarla con un array de atributos:

    $flight->fill(['name' => 'Amsterdam to Frankfurt']);

<a name="mass-assignment-json-columns"></a>
#### Asignación masiva y columnas JSON

Al asignar columnas JSON, la clave asignable en masa de cada columna debe especificarse en el array `$fillable` de tu modelo. Por seguridad, Laravel no soporta la actualización de atributos JSON anidados cuando se utiliza la propiedad `guarded`:

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'options->enabled',
    ];

<a name="allowing-mass-assignment"></a>
#### Permitir la asignación masiva

Si quieres que todos tus atributos sean asignables en masa, puedes definir la propiedad `$guarded` de tu modelo como un array vacío. Si opta por desproteger su modelo, debe tener especial cuidado de crear siempre a mano las matrices pasadas a los métodos de `fill`, `create` y `update` de Eloquent:

    /**
     * The attributes that aren't mass assignable.
     *
     * @var array
     */
    protected $guarded = [];

<a name="mass-assignment-exceptions"></a>
#### Excepciones de asignación masiva

Por defecto, los atributos que no están incluidos en la array `$fillable` se descartan silenciosamente al realizar operaciones de asignación masiva. En producción, este es el comportamiento esperado; sin embargo, durante el desarrollo local puede llevar a confusión en cuanto a por qué los cambios del modelo no tienen efecto.

Si lo deseas, puedes indicar a Laravel que lance una excepción cuando intente rellenar un atributo no rellenable invocando el método `preventSilentlyDiscardingAttributes`. Normalmente, este método debería invocarse dentro del método `boot` de uno de los proveedores de servicios de tu aplicación:

    use Illuminate\Database\Eloquent\Model;

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Model::preventSilentlyDiscardingAttributes($this->app->isLocal());
    }

<a name="upserts"></a>
### Upserts

Ocasionalmente, puedes necesitar actualizar un modelo existente o crear un nuevo modelo si no existe un modelo que coincida. Al igual que el método `firstOrCreate`, el método `updateOrCreate` persiste el modelo, por lo que no hay necesidad de llamar manualmente al método `save`.

En el ejemplo siguiente, si existe un vuelo con `salida` (departure) en `Oakland` y `destino` (destination) en `San Diego`, se actualizarán las columnas de `price` y `discounted`. Si no existe tal vuelo, se creará un nuevo vuelo que tendrá los atributos resultantes de fusionar el primera array con el segundo:

    $flight = Flight::updateOrCreate(
        ['departure' => 'Oakland', 'destination' => 'San Diego'],
        ['price' => 99, 'discounted' => 1]
    );

Si desea realizar múltiples "upserts" en una sola consulta, entonces debe utilizar el método `upsert` en su lugar. El primer argumento del método consiste en los valores a insertar o actualizar, mientras que el segundo argumento enumera la(s) columna(s) que identifican de forma única los registros dentro de la tabla asociada. El tercer y último argumento del método es un array de las columnas que deben actualizarse si ya existe un registro coincidente en la base de datos. El método `upsert` establecerá automáticamente las marcas de tiempo `created_at` y `updated_at` si las marcas de tiempo están habilitadas en el modelo:

    Flight::upsert([
        ['departure' => 'Oakland', 'destination' => 'San Diego', 'price' => 99],
        ['departure' => 'Chicago', 'destination' => 'New York', 'price' => 150]
    ], ['departure', 'destination'], ['price']);

> **Advertencia**  
> Todas las bases de datos excepto SQL Server requieren que las columnas del segundo argumento del método `upsert` tengan un índice "primario" o "único". Además, el controlador de base de datos MySQL ignora el segundo argumento del método `upsert` y utiliza siempre los índices "primario" y "único" de la tabla para detectar los registros existentes.

<a name="deleting-models"></a>
## Borrado de modelos

Para borrar un modelo, puede llamar al método `delete` en la instancia del modelo:

    use App\Models\Flight;

    $flight = Flight::find(1);

    $flight->delete();

Puede llamar al método `truncate` para borrar todos los registros de la base de datos asociados al modelo. La operación de `truncate` también restablecerá cualquier ID autoincrementado en la tabla asociada al modelo:

    Flight::truncate();

<a name="deleting-an-existing-model-by-its-primary-key"></a>
#### Borrar un modelo existente por su clave primaria

En el ejemplo anterior, estamos recuperando el modelo de la base de datos antes de llamar al método `delete`. Sin embargo, si conoces la clave primaria del modelo, puedes eliminar el modelo sin recuperarlo explícitamente llamando al método `destroy`. Además de aceptar una única clave primaria, el método `destroy` aceptará múltiples claves primarias, un array de claves primarias o una [colección](/docs/{{version}}/collections) de claves primarias:

    Flight::destroy(1);

    Flight::destroy(1, 2, 3);

    Flight::destroy([1, 2, 3]);

    Flight::destroy(collect([1, 2, 3]));

> **Advertencia**  
> El método `destroy` carga cada modelo individualmente y llama al método `delete` para que los eventos de `deleting` y `deleted` sean enviados correctamente para cada modelo.

<a name="deleting-models-using-queries"></a>
#### Borrado de Modelos mediante Consultas

Por supuesto, puede crear una consulta de Eloquent para eliminar todos los modelos que coincidan con los criterios de la consulta. En este ejemplo, borraremos todos los vuelos marcados como inactivos. Al igual que las actualizaciones masivas, los borrados masivos no enviarán eventos de modelo para los modelos borrados:

    $deleted = Flight::where('active', 0)->delete();

> **Advertencia**  
> Al ejecutar una sentencia de borrado masivo a través de Eloquent, los eventos de `deleting` y de modelo `deleted` no se enviarán para los modelos borrados. Esto se debe a que los modelos nunca se recuperan cuando se ejecuta la sentencia de borrado.

<a name="soft-deleting"></a>
### Borrado suave

Además de eliminar registros de la base de datos, Eloquent también puede "eliminar suavemente" modelos. Cuando los modelos se borran suavemente, no se eliminan realmente de la base de datos. En su lugar, se establece un atributo `deleted_at` en el modelo que indica la fecha y hora en la que se "eliminó" el modelo. Para habilitar el borrado suave de un modelo, añada el trait `Illuminate\Database\Eloquent\SoftDeletes` al modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\SoftDeletes;

    class Flight extends Model
    {
        use SoftDeletes;
    }

> **Nota**  
> El trait `SoftDeletes` convertirá automáticamente el atributo `deleted_at` en una instancia `DateTime` / `Carbon`.

También debe añadir la columna `deleted_at` a su tabla de base de datos. El [constructor de esquemas](/docs/{{version}}/migrations) de Laravel contiene un método de ayuda para crear esta columna:

    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    Schema::table('flights', function (Blueprint $table) {
        $table->softDeletes();
    });

    Schema::table('flights', function (Blueprint $table) {
        $table->dropSoftDeletes();
    });

Ahora, cuando llame al método `delete` en el modelo, la columna `deleted_at` se establecerá en la fecha y hora actuales. Sin embargo, el registro de base de datos del modelo se mantendrá en la tabla. Cuando se consulta un modelo que utiliza borrados suaves, los modelos borrados suaves se excluirán automáticamente de todos los resultados de la consulta.

Para determinar si una instancia de un modelo ha sido borrada de forma suave, puede utilizar el método de `trashed`:

    if ($flight->trashed()) {
        //
    }

<a name="restoring-soft-deleted-models"></a>
#### Restauración de modelos borrados "de forma suave"

A veces es posible que desee "recuperar" un modelo borrado suavemente. Para ello, puedes llamar al método `restore` en una instancia del modelo. El método `restore` establecerá la columna `deleted_at` del modelo en `null`:

    $flight->restore();

También puede utilizar el método de `restore` en una consulta para restaurar varios modelos. De nuevo, al igual que otras operaciones "masivas", no se enviará ningún evento de modelo para los modelos restaurados:

    Flight::withTrashed()
            ->where('airline_id', 1)
            ->restore();

El método `restore` también puede utilizarse para crear consultas de [relación](/docs/{{version}}/eloquent-relationships):

    $flight->history()->restore();

<a name="permanently-deleting-models"></a>
#### Borrado permanente de modelos

A veces es necesario eliminar un modelo de la base de datos. Puede utilizar el método `forceDelete` para eliminar permanentemente un modelo borrado "de forma suave" de la tabla de la base de datos:

    $flight->forceDelete();

También puede utilizar el método `forceDelete` al crear consultas de relación Eloquent:

    $flight->history()->forceDelete();

<a name="querying-soft-deleted-models"></a>
### Consulta de modelos borrados  "de forma suave"

<a name="including-soft-deleted-models"></a>
#### Inclusión de modelos eliminados "de forma suave"

Como se ha indicado anteriormente, los modelos eliminados suavemente se excluirán automáticamente de los resultados de las consultas. Sin embargo, puede forzar la inclusión de los modelos borrados  "de forma suave" en los resultados de una consulta llamando al método `withTrashed` en la consulta:

    use App\Models\Flight;

    $flights = Flight::withTrashed()
                    ->where('account_id', 1)
                    ->get();

El método `withTrashed` también puede ser llamado cuando se construye una consulta de [relación](/docs/{{version}}/eloquent-relationships):

    $flight->history()->withTrashed()->get();

<a name="retrieving-only-soft-deleted-models"></a>
#### Recuperar sólo modelos borrados "de forma suave"

El método `onlyTrashed` recuperará **sólo** los modelos borrados "de forma suave":

    $flights = Flight::onlyTrashed()
                    ->where('airline_id', 1)
                    ->get();

<a name="pruning-models"></a>
## Eliminar modelos innecesarios (Pruning Models)

A veces es posible que desee eliminar periódicamente los modelos que ya no son necesarios. Para ello, puede añadir el trait `Illuminate\Database\Eloquent\Prunable` o `Illuminate\Database\Eloquent\MassPrunable` a los modelos que desee eliminar periódicamente. Después de añadir uno de los traits al modelo, implemente un método `prunable` que devuelva un constructor de consultas Eloquent que resuelva los modelos que ya no son necesarios:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Prunable;

    class Flight extends Model
    {
        use Prunable;

        /**
         * Get the prunable model query.
         *
         * @return \Illuminate\Database\Eloquent\Builder
         */
        public function prunable()
        {
            return static::where('created_at', '<=', now()->subMonth());
        }
    }

Cuando se marcan modelos como `Prunable`, también se puede definir un método de `pruning` en el modelo. Este método será llamado antes de que el modelo sea borrado. Este método puede ser útil para borrar cualquier recurso adicional asociado al modelo, como archivos almacenados, antes de que el modelo sea eliminado permanentemente de la base de datos:

    /**
     * Prepare the model for pruning.
     *
     * @return void
     */
    protected function pruning()
    {
        //
    }

Después de configurar tu modelo como "prunable", debes programar el comando `model:prune` Artisan en la clase `App\Console\Kernel` de tu aplicación. Eres libre de elegir el intervalo apropiado en el que este comando debe ser ejecutado:

    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        $schedule->command('model:prune')->daily();
    }

El comando `model:prune` detectará automáticamente los modelos "prunable" dentro del directorio `app/Models` de su aplicación. Si sus modelos se encuentran en una ubicación diferente, puede utilizar la opción `--model` para especificar los nombres de las clases de los modelos:

    $schedule->command('model:prune', [
        '--model' => [Address::class, Flight::class],
    ])->daily();

Si desea excluir ciertos modelos de ser eliminados mientras se borran todos los demás modelos detectados, puede utilizar la opción `--except`:

    $schedule->command('model:prune', [
        '--except' => [Address::class, Flight::class],
    ])->daily();

Puede probar su consulta `prunable` ejecutando el comando `model:prune` con la opción `--pretend`. Al fingir, el comando `model:prune` simplemente informará de cuántos registros se borrarían si el comando se ejecutara realmente:

```shell
php artisan model:prune --pretend
```

> **Advertencia**  
> Los modelos borrados "de forma suave" se borrarán permanentemente (`forceDelete`) si coinciden con la consulta prunable.

<a name="mass-pruning"></a>
#### Eliminar modelos masivamente

Cuando los modelos se marcan con el trait `Illuminate\Database\Eloquent\MassPrunable`, los modelos se eliminan de la base de datos mediante consultas de eliminación masiva. Por lo tanto, no se invocará el método de `pruning`, ni se enviarán los eventos de modelo `deleting` y `deleted`. Esto se debe a que los modelos nunca se recuperan antes de ser eliminados, lo que hace que el proceso de eliminación sea mucho más eficiente:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\MassPrunable;

    class Flight extends Model
    {
        use MassPrunable;

        /**
         * Get the prunable model query.
         *
         * @return \Illuminate\Database\Eloquent\Builder
         */
        public function prunable()
        {
            return static::where('created_at', '<=', now()->subMonth());
        }
    }

<a name="replicating-models"></a>
## Replicación de modelos

Puede crear una copia no guardada de una instancia de modelo existente utilizando el método `replicate`. Este método es especialmente útil cuando se tienen instancias de modelo que comparten muchos de los mismos atributos:

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

Para excluir uno o más atributos de ser replicados al nuevo modelo, puede pasar un array al método `replicate`:

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
## Ámbitos de consulta (Query Scopes)

<a name="global-scopes"></a>
### Scopes globales

Los scopes globales permiten añadir restricciones a todas las consultas de un modelo determinado. La propia funcionalidad de [borrado suave](#soft-deleting) de Laravel utiliza scopes globales para recuperar únicamente los modelos "no borrados" de la base de datos. Escribir sus propios scopes globales puede proporcionar una manera fácil de asegurarse de que cada consulta para un modelo dado recibe ciertas restricciones.

<a name="writing-global-scopes"></a>
#### Escritura de scopes globales

Escribir un scope global es sencillo. En primer lugar, defina una clase que implemente la interfaz `Illuminate\Database\Eloquent\Scope`. Laravel no tiene una ubicación convencional donde se deben colocar las clases scope, por lo que eres libre de colocar esta clase en cualquier directorio que desees.

La interfaz `Scope` requiere que se implemente un método: `apply`. El método `apply` puede añadir restricciones `where` u otros tipos de cláusulas a la consulta según sea necesario:

    <?php

    namespace App\Models\Scopes;

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Scope;

    class AncientScope implements Scope
    {
        /**
         * Apply the scope to a given Eloquent query builder.
         *
         * @param  \Illuminate\Database\Eloquent\Builder  $builder
         * @param  \Illuminate\Database\Eloquent\Model  $model
         * @return void
         */
        public function apply(Builder $builder, Model $model)
        {
            $builder->where('created_at', '<', now()->subYears(2000));
        }
    }

> **Nota**  
> Si su scope global añade columnas a la cláusula select de la consulta, debe utilizar el método `addSelect` en lugar de `select`. Esto evitará la sustitución involuntaria de la cláusula select existente en la consulta.

<a name="applying-global-scopes"></a>
#### Aplicación de scopes globales

Para asignar un scope global a un modelo, debe sobreescribir el método `booted` del modelo e invocar el método `addGlobalScope` del modelo. El método `addGlobalScope` acepta una instancia de su ámbito como único argumento:

    <?php

    namespace App\Models;

    use App\Models\Scopes\AncientScope;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The "booted" method of the model.
         *
         * @return void
         */
        protected static function booted()
        {
            static::addGlobalScope(new AncientScope);
        }
    }

Tras añadir el scope del ejemplo anterior al modelo `App\Models\User`, una llamada al método `User::all()` ejecutará la siguiente consulta SQL:

```sql
select * from `users` where `created_at` < 0021-02-18 00:00:00
```

<a name="anonymous-global-scopes"></a>
#### Scopes globales anónimos

Eloquent también permite definir scopes globales mediante closures, lo que resulta especialmente útil para scopes sencillos que no requieren una clase propia independiente. Cuando defina un ámbito global utilizando un closure, debe proporcionar un nombre de ámbito de su elección como primer argumento del método `addGlobalScope`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The "booted" method of the model.
         *
         * @return void
         */
        protected static function booted()
        {
            static::addGlobalScope('ancient', function (Builder $builder) {
                $builder->where('created_at', '<', now()->subYears(2000));
            });
        }
    }

<a name="removing-global-scopes"></a>
#### Eliminación de scopes globales

Si desea eliminar un scope global para una consulta determinada, puede utilizar el método `withoutGlobalScope`. Este método acepta como único argumento el nombre de la clase del scope global:

    User::withoutGlobalScope(AncientScope::class)->get();

O, si definió el scope global utilizando un closure, deberá pasar el nombre de la cadena que asignó al scope global:

    User::withoutGlobalScope('ancient')->get();

Si desea eliminar varios o incluso todos los scopes globales de la consulta, puede utilizar el método `withoutGlobalScopes`:

    // Remove all of the global scopes...
    User::withoutGlobalScopes()->get();

    // Remove some of the global scopes...
    User::withoutGlobalScopes([
        FirstScope::class, SecondScope::class
    ])->get();

<a name="local-scopes"></a>
### Scopes locales

Los scopes locales le permiten definir conjuntos comunes de restricciones de consulta que puede reutilizar fácilmente en toda su aplicación. Por ejemplo, puede que necesite recuperar con frecuencia todos los usuarios considerados "populares". Para definir un scope, anteponga el prefijo `scope` a un método del modelo Eloquent.

Los scopes deben devolver siempre la misma instancia del constructor de consultas o `void`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Scope a query to only include popular users.
         *
         * @param  \Illuminate\Database\Eloquent\Builder  $query
         * @return \Illuminate\Database\Eloquent\Builder
         */
        public function scopePopular($query)
        {
            return $query->where('votes', '>', 100);
        }

        /**
         * Scope a query to only include active users.
         *
         * @param  \Illuminate\Database\Eloquent\Builder  $query
         * @return void
         */
        public function scopeActive($query)
        {
            $query->where('active', 1);
        }
    }

<a name="utilizing-a-local-scope"></a>
#### Utilizando un Scope Local

Una vez definido el scope, puede llamar a los métodos del scope cuando consulte el modelo. Sin embargo, no debe incluir el prefijo `scope` al llamar al método. Incluso se pueden encadenar llamadas a varios scopes:

    use App\Models\User;

    $users = User::popular()->active()->orderBy('created_at')->get();

La combinación de varios scopes del modelo Eloquent mediante un operador de consulta `or` puede requerir el uso de closures para lograr la [agrupación lógica](/docs/{{version}}/queries#logical-grouping) correcta:

    $users = User::popular()->orWhere(function (Builder $query) {
        $query->active();
    })->get();

Sin embargo, dado que esto puede resultar engorroso, Laravel proporciona un método `orWhere` de "orden superior" que permite encadenar scopes de forma fluida sin necesidad de utilizar closures:

    $users = App\Models\User::popular()->orWhere->active()->get();

<a name="dynamic-scopes"></a>
#### Scopes dinámicos

A veces es posible que desee definir un scope que acepte parámetros. Para empezar, basta con añadir los parámetros adicionales a la firma del método de scope. Los parámetros deben definirse después del parámetro `$query`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Scope a query to only include users of a given type.
         *
         * @param  \Illuminate\Database\Eloquent\Builder  $query
         * @param  mixed  $type
         * @return \Illuminate\Database\Eloquent\Builder
         */
        public function scopeOfType($query, $type)
        {
            return $query->where('type', $type);
        }
    }

Una vez que los argumentos esperados han sido añadidos a la firma de tu método scope, puedes pasar los argumentos cuando este sea llamado:

    $users = User::ofType('admin')->get();

<a name="comparing-models"></a>
## Comparación de modelos

A veces puede ser necesario determinar si dos modelos son "iguales" o no. Los métodos `is` e `isNot` se pueden utilizar para verificar rápidamente si dos modelos tienen la misma clave primaria, tabla y conexión de base de datos o no:

    if ($post->is($anotherPost)) {
        //
    }

    if ($post->isNot($anotherPost)) {
        //
    }

Los métodos `is` y `isNot` también están disponibles cuando se utilizan las [relaciones](/docs/{{version}}/eloquent-relationships) `belongsTo`, `hasOne`, `morphTo` y `morphOne`. Este método resulta especialmente útil cuando se desea comparar un modelo relacionado sin emitir una consulta para recuperar dicho modelo:

    if ($post->author()->is($user)) {
        //
    }

<a name="events"></a>
## Eventos

> **Nota**  
> ¿Quieres transmitir tus eventos Eloquent directamente a tu aplicación cliente? Echa un vistazo a [la difusión de eventos de modelo](/docs/{{version}}/broadcasting#model-broadcasting) de Laravel.

Los modelos Eloquent despachan varios eventos, permitiéndole conectarse a los siguientes momentos en el ciclo de vida de un modelo: `retrieved`, `creating`, `created`, `updating`, `updated`, `saving`, `saved`, `deleting`, `deleted`, `trashed`, `forceDeleted`, `restoring`, `restored`, y `replicating`.

El evento `retrieved` se enviará cuando se recupere un modelo existente de la base de datos. Cuando un nuevo modelo es guardado por primera vez, los eventos `creating` y `created` serán enviados. Los eventos `updating` / `updated` se enviarán cuando se modifique un modelo existente y se llame al método `save`. Los eventos `saving` / `saved` se enviarán cuando un modelo sea creado o actualizado - incluso si los atributos del modelo no han sido cambiados. Los nombres de eventos que terminan en `-ing` se envían antes de que se guarden los cambios en el modelo, mientras que los eventos que terminan en `-ed` se envían después de que se guarden los cambios en el modelo.

Para empezar a escuchar eventos de modelo, define una propiedad `$dispatchesEvents` en tu modelo Eloquent. Esta propiedad asigna varios puntos del ciclo de vida del modelo Eloquent a tus propias clases [de eventos](/docs/{{version}}/events). Cada clase de evento del modelo debe esperar recibir una instancia del modelo afectado a través de su constructor:

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
         * The event map for the model.
         *
         * @var array
         */
        protected $dispatchesEvents = [
            'saved' => UserSaved::class,
            'deleted' => UserDeleted::class,
        ];
    }

Después de definir y mapear tus eventos Eloquent, puedes utilizar [listeners de eventos](/docs/{{version}}/events#defining-listeners) para manejar los eventos.

> **Advertencia**  
> Al realizar una actualización o eliminación masiva a través de Eloquent, los eventos de modelo `saved`, `updated`, `deleting` y `deleted` no se enviarán para los modelos afectados. Esto se debe a que los modelos nunca se recuperan cuando se realizan actualizaciones o borrados masivos.

<a name="events-using-closures"></a>
### Uso de closures

En lugar de utilizar clases de eventos personalizadas, puede registrar closures que se ejecuten cuando se envíen varios eventos de modelo. Por lo general, deberías registrar estos closures en el método `booted` de tu modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The "booted" method of the model.
         *
         * @return void
         */
        protected static function booted()
        {
            static::created(function ($user) {
                //
            });
        }
    }

Si es necesario, puedes utilizar[listeners de eventos anónimos en cola](/docs/{{version}}/events#queuable-anonymous-event-listeners) cuando registres eventos de modelo. Esto le indicará a Laravel que ejecute el escuchador de eventos del modelo en segundo plano utilizando [la cola](/docs/{{version}}/queues) de tu aplicación:

    use function Illuminate\Events\queueable;

    static::created(queueable(function ($user) {
        //
    }));

<a name="observers"></a>
### Observadores

<a name="defining-observers"></a>
#### Definición de observadores

Si estás escuchando muchos eventos en un modelo dado, puedes utilizar observadores para agrupar todos tus listeners en una única clase. Las clases de observadores tienen nombres de métodos que reflejan los eventos de Eloquent que desea escuchar. Cada uno de estos métodos recibe como único argumento el modelo afectado. El comando `make:observer` de Artisan es la forma más sencilla de crear una nueva clase de observador:

```shell
php artisan make:observer UserObserver --model=User
```

Este comando colocará el nuevo observador en tu directorio `App/Observers`. Si este directorio no existe, Artisan lo creará por usted. Su nuevo observador tendrá la siguiente apariencia:

    <?php

    namespace App\Observers;

    use App\Models\User;

    class UserObserver
    {
        /**
         * Handle the User "created" event.
         *
         * @param  \App\Models\User  $user
         * @return void
         */
        public function created(User $user)
        {
            //
        }

        /**
         * Handle the User "updated" event.
         *
         * @param  \App\Models\User  $user
         * @return void
         */
        public function updated(User $user)
        {
            //
        }

        /**
         * Handle the User "deleted" event.
         *
         * @param  \App\Models\User  $user
         * @return void
         */
        public function deleted(User $user)
        {
            //
        }
        
        /**
         * Handle the User "restored" event.
         *
         * @param  \App\Models\User  $user
         * @return void
         */
        public function restored(User $user)
        {
            //
        }

        /**
         * Handle the User "forceDeleted" event.
         *
         * @param  \App\Models\User  $user
         * @return void
         */
        public function forceDeleted(User $user)
        {
            //
        }
    }

Para registrar un observador, necesitas llamar al método `observe` en el modelo que deseas observar. Puedes registrar observadores en el método `boot` del proveedor de servicios `App\Providers\EventServiceProvider` de tu aplicación:

    use App\Models\User;
    use App\Observers\UserObserver;

    /**
     * Register any events for your application.
     *
     * @return void
     */
    public function boot()
    {
        User::observe(UserObserver::class);
    }

De manera alternativa, puede listar sus observadores dentro de una propiedad `$observers` de la clase `App\Providers\EventServiceProvider` de su aplicación:

    use App\Models\User;
    use App\Observers\UserObserver;

    /**
     * The model observers for your application.
     *
     * @var array
     */
    protected $observers = [
        User::class => [UserObserver::class],
    ];

> **Nota**  
> Hay eventos adicionales que un observador puede escuchar, como `saving` y `retrieved`. Estos eventos se describen en la documentación de [eventos](#events).

<a name="observers-and-database-transactions"></a>
#### Observadores y Transacciones de Base de Datos

Cuando los modelos están siendo creados dentro de una transacción de base de datos, usted puede querer instruir a un observador para que solo ejecute sus manejadores de eventos después de que la transacción de base de datos sea confirmada. Esto se consigue definiendo una propiedad `$afterCommit` en el observador. Si una transacción de base de datos no está en progreso, los manejadores de eventos se ejecutarán inmediatamente:

    <?php

    namespace App\Observers;

    use App\Models\User;

    class UserObserver
    {
        /**
         * Handle events after all transactions are committed.
         *
         * @var bool
         */
        public $afterCommit = true;

        /**
         * Handle the User "created" event.
         *
         * @param  \App\Models\User  $user
         * @return void
         */
        public function created(User $user)
        {
            //
        }
    }

<a name="muting-events"></a>
### Silenciando Eventos

Ocasionalmente puedes necesitar "silenciar" temporalmente todos los eventos disparados por un modelo. Puede conseguirlo utilizando el método `withoutEvents`. El método `withoutEvents` acepta un closure como único argumento. Cualquier código ejecutado dentro de este closure no enviará eventos del modelo, y cualquier valor devuelto por el closure será devuelto por el método `withoutEvents`:

    use App\Models\User;

    $user = User::withoutEvents(function () {
        User::findOrFail(1)->delete();

        return User::find(2);
    });

<a name="saving-a-single-model-without-events"></a>
#### Guardar un único modelo sin eventos

A veces es posible que desee "guardar" un modelo determinado sin enviar ningún evento. Para ello, utilice el método `saveQuietly`:

    $user = User::findOrFail(1);

    $user->name = 'Victoria Faith';

    $user->saveQuietly();

También puedes "update", "delete", "soft delete", "restore" y "replicate" un modelo dado sin enviar ningún evento:

    $user->deleteQuietly();

    $user->restoreQuietly();
