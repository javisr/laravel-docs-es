# Laravel Scout

- [Introducción](#introduction)
- [Instalación](#installation)
    - [Colas](#queueing)
- [Requisitos previos del controlador](#driver-prerequisites)
    - [Algolia](#algolia)
    - [Meilisearch](#meilisearch)
    - [Typesense](#typesense)
- [Configuración](#configuration)
    - [Configurando índices de modelo](#configuring-model-indexes)
    - [Configurando datos buscables](#configuring-searchable-data)
    - [Configurando el ID del modelo](#configuring-the-model-id)
    - [Configurando motores de búsqueda por modelo](#configuring-search-engines-per-model)
    - [Identificando usuarios](#identifying-users)
- [Motores de base de datos / colección](#database-and-collection-engines)
    - [Motor de base de datos](#database-engine)
    - [Motor de colección](#collection-engine)
- [Indexación](#indexing)
    - [Importación por lotes](#batch-import)
    - [Añadiendo registros](#adding-records)
    - [Actualizando registros](#updating-records)
    - [Eliminando registros](#removing-records)
    - [Pausando la indexación](#pausing-indexing)
    - [Instancias de modelo buscables condicionalmente](#conditionally-searchable-model-instances)
- [Búsqueda](#searching)
    - [Cláusulas Where](#where-clauses)
    - [Paginación](#pagination)
    - [Eliminación suave](#soft-deleting)
    - [Personalizando búsquedas de motores](#customizing-engine-searches)
- [Motores personalizados](#custom-engines)

<a name="introduction"></a>
## Introducción

[Laravel Scout](https://github.com/laravel/scout) proporciona una solución simple basada en controladores para agregar búsqueda de texto completo a tus [modelos Eloquent](/docs/{{version}}/eloquent). Usando observadores de modelo, Scout mantendrá automáticamente tus índices de búsqueda sincronizados con tus registros Eloquent.

Actualmente, Scout se envía con [Algolia](https://www.algolia.com/), [Meilisearch](https://www.meilisearch.com), [Typesense](https://typesense.org), y controladores de MySQL / PostgreSQL (`database`). Además, Scout incluye un controlador de "colección" que está diseñado para uso en desarrollo local y no requiere ninguna dependencia externa o servicios de terceros. Además, escribir controladores personalizados es simple y eres libre de extender Scout con tus propias implementaciones de búsqueda.

<a name="installation"></a>
## Instalación

Primero, instala Scout a través del gestor de paquetes Composer:

```shell
composer require laravel/scout
```

Después de instalar Scout, debes publicar el archivo de configuración de Scout usando el comando Artisan `vendor:publish`. Este comando publicará el archivo de configuración `scout.php` en el directorio `config` de tu aplicación:

```shell
php artisan vendor:publish --provider="Laravel\Scout\ScoutServiceProvider"
```

Finalmente, agrega el rasgo `Laravel\Scout\Searchable` al modelo que deseas hacer buscable. Este rasgo registrará un observador de modelo que mantendrá automáticamente el modelo sincronizado con tu controlador de búsqueda:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Laravel\Scout\Searchable;

    class Post extends Model
    {
        use Searchable;
    }

<a name="queueing"></a>
### Colas

Si bien no es estrictamente necesario usar Scout, deberías considerar seriamente configurar un [controlador de colas](/docs/{{version}}/queues) antes de usar la biblioteca. Ejecutar un trabajador de colas permitirá a Scout encolar todas las operaciones que sincronizan la información de tu modelo con tus índices de búsqueda, proporcionando tiempos de respuesta mucho mejores para la interfaz web de tu aplicación.

Una vez que hayas configurado un controlador de colas, establece el valor de la opción `queue` en tu archivo de configuración `config/scout.php` a `true`:

    'queue' => true,

Incluso cuando la opción `queue` está configurada en `false`, es importante recordar que algunos controladores de Scout como Algolia y Meilisearch siempre indexan registros de forma asíncrona. Esto significa que, aunque la operación de índice se haya completado dentro de tu aplicación Laravel, el motor de búsqueda en sí puede no reflejar los nuevos y actualizados registros de inmediato.

Para especificar la conexión y la cola que utilizan tus trabajos de Scout, puedes definir la opción de configuración `queue` como un array:

    'queue' => [
        'connection' => 'redis',
        'queue' => 'scout'
    ],

Por supuesto, si personalizas la conexión y la cola que utilizan los trabajos de Scout, deberías ejecutar un trabajador de colas para procesar trabajos en esa conexión y cola:

    php artisan queue:work redis --queue=scout

<a name="driver-prerequisites"></a>
## Requisitos previos del controlador

<a name="algolia"></a>
### Algolia

Al usar el controlador de Algolia, debes configurar tus credenciales `id` y `secret` de Algolia en tu archivo de configuración `config/scout.php`. Una vez que tus credenciales hayan sido configuradas, también necesitarás instalar el SDK de PHP de Algolia a través del gestor de paquetes Composer:

```shell
composer require algolia/algoliasearch-client-php
```

<a name="meilisearch"></a>
### Meilisearch

[Meilisearch](https://www.meilisearch.com) es un motor de búsqueda de código abierto y extremadamente rápido. Si no estás seguro de cómo instalar Meilisearch en tu máquina local, puedes usar [Laravel Sail](/docs/{{version}}/sail#meilisearch), el entorno de desarrollo Docker oficialmente soportado por Laravel.

Al usar el controlador de Meilisearch necesitarás instalar el SDK de PHP de Meilisearch a través del gestor de paquetes Composer:

```shell
composer require meilisearch/meilisearch-php http-interop/http-factory-guzzle
```

Luego, establece la variable de entorno `SCOUT_DRIVER` así como tus credenciales `host` y `key` de Meilisearch dentro del archivo `.env` de tu aplicación:

```ini
SCOUT_DRIVER=meilisearch
MEILISEARCH_HOST=http://127.0.0.1:7700
MEILISEARCH_KEY=masterKey
```

Para más información sobre Meilisearch, consulta la [documentación de Meilisearch](https://docs.meilisearch.com/learn/getting_started/quick_start.html).

Además, debes asegurarte de instalar una versión de `meilisearch/meilisearch-php` que sea compatible con la versión binaria de Meilisearch revisando [la documentación de Meilisearch sobre compatibilidad binaria](https://github.com/meilisearch/meilisearch-php#-compatibility-with-meilisearch).

> [!WARNING]  
> Al actualizar Scout en una aplicación que utiliza Meilisearch, siempre debes [revisar cualquier cambio adicional que rompa compatibilidad](https://github.com/meilisearch/Meilisearch/releases) con el servicio de Meilisearch en sí.

<a name="typesense"></a>
### Typesense

[Typesense](https://typesense.org) es un motor de búsqueda de código abierto y extremadamente rápido que soporta búsqueda por palabras clave, búsqueda semántica, búsqueda geográfica y búsqueda vectorial.

Puedes [auto-hospedar](https://typesense.org/docs/guide/install-typesense.html#option-2-local-machine-self-hosting) Typesense o usar [Typesense Cloud](https://cloud.typesense.org).

Para comenzar a usar Typesense con Scout, instala el SDK de PHP de Typesense a través del gestor de paquetes Composer:

```shell
composer require typesense/typesense-php
```

Luego, establece la variable de entorno `SCOUT_DRIVER` así como tus credenciales de host y clave API de Typesense dentro del archivo .env de tu aplicación:

```env
SCOUT_DRIVER=typesense
TYPESENSE_API_KEY=masterKey
TYPESENSE_HOST=localhost
```

Si es necesario, también puedes especificar el puerto, la ruta y el protocolo de tu instalación:

```env
TYPESENSE_PORT=8108
TYPESENSE_PATH=
TYPESENSE_PROTOCOL=http
```

Configuraciones adicionales y definiciones de esquema para tus colecciones de Typesense se pueden encontrar dentro del archivo de configuración `config/scout.php` de tu aplicación. Para más información sobre Typesense, consulta la [documentación de Typesense](https://typesense.org/docs/guide/#quick-start).

<a name="preparing-data-for-storage-in-typesense"></a>
#### Preparando datos para almacenamiento en Typesense

Al utilizar Typesense, tu modelo buscable debe definir un método `toSearchableArray` que convierta la clave primaria de tu modelo a una cadena y la fecha de creación a un timestamp UNIX:

```php
/**
 * Get the indexable data array for the model.
 *
 * @return array<string, mixed>
 */
public function toSearchableArray()
{
    return array_merge($this->toArray(),[
        'id' => (string) $this->id,
        'created_at' => $this->created_at->timestamp,
    ]);
}
```

También debes definir los esquemas de colección de Typesense en el archivo `config/scout.php` de tu aplicación. Un esquema de colección describe los tipos de datos de cada campo que es buscable a través de Typesense. Para más información sobre todas las opciones de esquema disponibles, consulta la [documentación de Typesense](https://typesense.org/docs/latest/api/collections.html#schema-parameters).

Si necesitas cambiar el esquema de tu colección de Typesense después de haber sido definido, puedes ejecutar `scout:flush` y `scout:import`, lo que eliminará todos los datos indexados existentes y recreará el esquema. O, puedes usar la API de Typesense para modificar el esquema de la colección sin eliminar ningún dato indexado.

Si tu modelo buscable es eliminable suavemente, debes definir un campo `__soft_deleted` en el esquema correspondiente de Typesense dentro del archivo de configuración `config/scout.php` de tu aplicación:

```php
User::class => [
    'collection-schema' => [
        'fields' => [
            // ...
            [
                'name' => '__soft_deleted',
                'type' => 'int32',
                'optional' => true,
            ],
        ],
    ],
],
```

<a name="typesense-dynamic-search-parameters"></a>
#### Parámetros de búsqueda dinámica

Typesense te permite modificar tus [parámetros de búsqueda](https://typesense.org/docs/latest/api/search.html#search-parameters) dinámicamente al realizar una operación de búsqueda a través del método `options`:

```php
use App\Models\Todo;

Todo::search('Groceries')->options([
    'query_by' => 'title, description'
])->get();
```

<a name="configuration"></a>
## Configuración

<a name="configuring-model-indexes"></a>
### Configurando índices de modelo

Cada modelo Eloquent se sincroniza con un "índice" de búsqueda dado, que contiene todos los registros buscables para ese modelo. En otras palabras, puedes pensar en cada índice como una tabla de MySQL. Por defecto, cada modelo se persistirá en un índice que coincide con el nombre típico de "tabla" del modelo. Típicamente, esta es la forma plural del nombre del modelo; sin embargo, eres libre de personalizar el índice del modelo sobrescribiendo el método `searchableAs` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Laravel\Scout\Searchable;

    class Post extends Model
    {
        use Searchable;

        /**
         * Obtener el nombre del índice asociado con el modelo.
         */
        public function searchableAs(): string
        {
            return 'posts_index';
        }
    }

<a name="configuring-searchable-data"></a>
### Configurando datos buscables

Por defecto, toda la forma `toArray` de un modelo dado se persistirá en su índice de búsqueda. Si deseas personalizar los datos que se sincronizan con el índice de búsqueda, puedes sobrescribir el método `toSearchableArray` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Laravel\Scout\Searchable;

    class Post extends Model
    {
        use Searchable;

        /**
         * Obtener el array de datos indexables para el modelo.
         *
         * @return array<string, mixed>
         */
        public function toSearchableArray(): array
        {
            $array = $this->toArray();

            // Personaliza el array de datos...

            return $array;
        }
    }

Algunos motores de búsqueda como Meilisearch solo realizarán operaciones de filtrado (`>`, `<`, etc.) en datos del tipo correcto. Por lo tanto, al usar estos motores de búsqueda y personalizar tus datos buscables, debes asegurarte de que los valores numéricos se conviertan a su tipo correcto:

    public function toSearchableArray()
    {
        return [
            'id' => (int) $this->id,
            'name' => $this->name,
            'price' => (float) $this->price,
        ];
    }

<a name="configuring-filterable-data-for-meilisearch"></a>
#### Configurando datos filtrables y configuraciones de índice (Meilisearch)

A diferencia de los otros controladores de Scout, Meilisearch requiere que predefinas configuraciones de búsqueda de índice como atributos filtrables, atributos ordenables y [otros campos de configuraciones soportados](https://docs.meilisearch.com/reference/api/settings.html).

Los atributos filtrables son cualquier atributo que planeas filtrar al invocar el método `where` de Scout, mientras que los atributos ordenables son cualquier atributo que planeas ordenar al invocar el método `orderBy` de Scout. Para definir tus configuraciones de índice, ajusta la parte `index-settings` de tu entrada de configuración `meilisearch` en el archivo de configuración `scout` de tu aplicación:

```php
use App\Models\User;
use App\Models\Flight;

'meilisearch' => [
    'host' => env('MEILISEARCH_HOST', 'http://localhost:7700'),
    'key' => env('MEILISEARCH_KEY', null),
    'index-settings' => [
        User::class => [
            'filterableAttributes'=> ['id', 'name', 'email'],
            'sortableAttributes' => ['created_at'],
            // Other settings fields...
        ],
        Flight::class => [
            'filterableAttributes'=> ['id', 'destination'],
            'sortableAttributes' => ['updated_at'],
        ],
    ],
],
```

Si el modelo subyacente de un índice dado es eliminable suavemente y está incluido en el array `index-settings`, Scout incluirá automáticamente soporte para filtrar modelos eliminados suavemente en ese índice. Si no tienes otros atributos filtrables u ordenables que definir para un índice de modelo eliminable suavemente, simplemente puedes agregar una entrada vacía al array `index-settings` para ese modelo:

```php
'index-settings' => [
    Flight::class => []
],
```

Después de configurar las configuraciones de índice de tu aplicación, debes invocar el comando Artisan `scout:sync-index-settings`. Este comando informará a Meilisearch sobre tus configuraciones de índice actualmente configuradas. Para conveniencia, puedes desear hacer de este comando parte de tu proceso de implementación:

```shell
php artisan scout:sync-index-settings
```

<a name="configuring-the-model-id"></a>
### Configurando el ID del modelo

Por defecto, Scout usará la clave primaria del modelo como el ID / clave único del modelo que se almacena en el índice de búsqueda. Si necesitas personalizar este comportamiento, puedes sobrescribir los métodos `getScoutKey` y `getScoutKeyName` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Laravel\Scout\Searchable;

    class User extends Model
    {
        use Searchable;

        /**
         * Obtener el valor utilizado para indexar el modelo.
         */
        public function getScoutKey(): mixed
        {
            return $this->email;
        }

        /**
         * Obtener el nombre de la clave utilizada para indexar el modelo.
         */
        public function getScoutKeyName(): mixed
        {
            return 'email';
        }
    }

<a name="configuring-search-engines-per-model"></a>
### Configurando motores de búsqueda por modelo

Al buscar, Scout típicamente usará el motor de búsqueda predeterminado especificado en el archivo de configuración `scout` de tu aplicación. Sin embargo, el motor de búsqueda para un modelo particular puede ser cambiado sobrescribiendo el método `searchableUsing` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Laravel\Scout\Engines\Engine;
    use Laravel\Scout\EngineManager;
    use Laravel\Scout\Searchable;

    class User extends Model
    {
        use Searchable;

        /**
         * Obtener el motor utilizado para indexar el modelo.
         */
        public function searchableUsing(): Engine
        {
            return app(EngineManager::class)->engine('meilisearch');
        }
    }

<a name="identifying-users"></a>
### Identificando usuarios

Scout también te permite identificar automáticamente a los usuarios al usar [Algolia](https://algolia.com). Asociar al usuario autenticado con las operaciones de búsqueda puede ser útil al ver tus análisis de búsqueda dentro del panel de control de Algolia. Puedes habilitar la identificación de usuarios definiendo una variable de entorno `SCOUT_IDENTIFY` como `true` en el archivo `.env` de tu aplicación:

```ini
SCOUT_IDENTIFY=true
```

Habilitar esta función también pasará la dirección IP de la solicitud y el identificador principal de tu usuario autenticado a Algolia para que estos datos se asocien con cualquier solicitud de búsqueda realizada por el usuario.

<a name="database-and-collection-engines"></a>
## Motores de base de datos / colección

<a name="database-engine"></a>
### Motor de base de datos

> [!WARNING]  
> El motor de base de datos actualmente soporta MySQL y PostgreSQL.

Si tu aplicación interactúa con bases de datos de tamaño pequeño a mediano o tiene una carga de trabajo ligera, puedes encontrar más conveniente comenzar con el motor de "base de datos" de Scout. El motor de base de datos utilizará cláusulas "where like" e índices de texto completo al filtrar resultados de tu base de datos existente para determinar los resultados de búsqueda aplicables a tu consulta.

Para usar el motor de base de datos, simplemente puedes establecer el valor de la variable de entorno `SCOUT_DRIVER` en `database`, o especificar el controlador `database` directamente en el archivo de configuración `scout` de tu aplicación:

```ini
SCOUT_DRIVER=database
```

Una vez que hayas especificado el motor de base de datos como tu controlador preferido, debes [configurar tus datos buscables](#configuring-searchable-data). Luego, puedes comenzar a [ejecutar consultas de búsqueda](#searching) contra tus modelos. La indexación del motor de búsqueda, como la indexación necesaria para sembrar índices de Algolia, Meilisearch o Typesense, no es necesaria al usar el motor de base de datos.

#### Personalizando Estrategias de Búsqueda en la Base de Datos

Por defecto, el motor de base de datos ejecutará una consulta "where like" contra cada atributo del modelo que hayas [configurado como buscable](#configuring-searchable-data). Sin embargo, en algunas situaciones, esto puede resultar en un rendimiento deficiente. Por lo tanto, la estrategia de búsqueda del motor de base de datos se puede configurar para que algunas columnas especificadas utilicen consultas de búsqueda de texto completo o solo usen restricciones "where like" para buscar los prefijos de las cadenas (`example%`) en lugar de buscar dentro de toda la cadena (`%example%`).

Para definir este comportamiento, puedes asignar atributos de PHP al método `toSearchableArray` de tu modelo. Cualquier columna que no tenga un comportamiento de estrategia de búsqueda adicional continuará utilizando la estrategia predeterminada "where like":

```php
use Laravel\Scout\Attributes\SearchUsingFullText;
use Laravel\Scout\Attributes\SearchUsingPrefix;

/**
 * Get the indexable data array for the model.
 *
 * @return array<string, mixed>
 */
#[SearchUsingPrefix(['id', 'email'])]
#[SearchUsingFullText(['bio'])]
public function toSearchableArray(): array
{
    return [
        'id' => $this->id,
        'name' => $this->name,
        'email' => $this->email,
        'bio' => $this->bio,
    ];
}
```

> [!WARNING]  
> Antes de especificar que una columna debe usar restricciones de consulta de texto completo, asegúrate de que la columna tenga un [índice de texto completo](/docs/{{version}}/migrations#available-index-types).

<a name="collection-engine"></a>
### Motor de Colección

Si bien eres libre de usar los motores de búsqueda Algolia, Meilisearch o Typesense durante el desarrollo local, puede que te resulte más conveniente comenzar con el motor de "colección". El motor de colección utilizará cláusulas "where" y filtrado de colecciones en los resultados de tu base de datos existente para determinar los resultados de búsqueda aplicables a tu consulta. Al usar este motor, no es necesario "indexar" tus modelos buscables, ya que simplemente se recuperarán de tu base de datos local.

Para usar el motor de colección, simplemente puedes establecer el valor de la variable de entorno `SCOUT_DRIVER` en `collection`, o especificar el controlador `collection` directamente en el archivo de configuración `scout` de tu aplicación:

```ini
SCOUT_DRIVER=collection
```

Una vez que hayas especificado el controlador de colección como tu controlador preferido, puedes comenzar a [ejecutar consultas de búsqueda](#searching) contra tus modelos. La indexación del motor de búsqueda, como la indexación necesaria para sembrar índices de Algolia, Meilisearch o Typesense, no es necesaria al usar el motor de colección.

#### Diferencias Con el Motor de Base de Datos

A primera vista, los motores "database" y "collections" son bastante similares. Ambos interactúan directamente con tu base de datos para recuperar resultados de búsqueda. Sin embargo, el motor de colección no utiliza índices de texto completo ni cláusulas `LIKE` para encontrar registros coincidentes. En su lugar, extrae todos los registros posibles y utiliza el helper `Str::is` de Laravel para determinar si la cadena de búsqueda existe dentro de los valores de los atributos del modelo.

El motor de colección es el motor de búsqueda más portátil, ya que funciona en todas las bases de datos relacionales compatibles con Laravel (incluyendo SQLite y SQL Server); sin embargo, es menos eficiente que el motor de base de datos de Scout.

<a name="indexing"></a>
## Indexación

<a name="batch-import"></a>
### Importación por Lotes

Si estás instalando Scout en un proyecto existente, es posible que ya tengas registros de base de datos que necesitas importar en tus índices. Scout proporciona un comando Artisan `scout:import` que puedes usar para importar todos tus registros existentes en tus índices de búsqueda:

```shell
php artisan scout:import "App\Models\Post"
```

El comando `flush` se puede usar para eliminar todos los registros de un modelo de tus índices de búsqueda:

```shell
php artisan scout:flush "App\Models\Post"
```

<a name="modifying-the-import-query"></a>
#### Modificando la Consulta de Importación

Si deseas modificar la consulta que se utiliza para recuperar todos tus modelos para la importación por lotes, puedes definir un método `makeAllSearchableUsing` en tu modelo. Este es un buen lugar para agregar cualquier carga de relación ansiosa que pueda ser necesaria antes de importar tus modelos:

    use Illuminate\Database\Eloquent\Builder;

    /**
     * Modificar la consulta utilizada para recuperar modelos al hacer que todos los modelos sean buscables.
     */
    protected function makeAllSearchableUsing(Builder $query): Builder
    {
        return $query->with('author');
    }

> [!WARNING]  
> El método `makeAllSearchableUsing` puede no ser aplicable al usar una cola para importar modelos por lotes. Las relaciones [no se restauran](/docs/{{version}}/queues#handling-relationships) cuando las colecciones de modelos son procesadas por trabajos.

<a name="adding-records"></a>
### Agregando Registros

Una vez que hayas agregado el rasgo `Laravel\Scout\Searchable` a un modelo, todo lo que necesitas hacer es `save` o `create` una instancia de modelo y se agregará automáticamente a tu índice de búsqueda. Si has configurado Scout para [usar colas](#queueing), esta operación se realizará en segundo plano por tu trabajador de cola:

    use App\Models\Order;

    $order = new Order;

    // ...

    $order->save();

<a name="adding-records-via-query"></a>
#### Agregando Registros a través de Consulta

Si deseas agregar una colección de modelos a tu índice de búsqueda a través de una consulta Eloquent, puedes encadenar el método `searchable` a la consulta Eloquent. El método `searchable` [dividirá los resultados](/docs/{{version}}/eloquent#chunking-results) de la consulta y agregará los registros a tu índice de búsqueda. Nuevamente, si has configurado Scout para usar colas, todos los fragmentos se importarán en segundo plano por tus trabajadores de cola:

    use App\Models\Order;

    Order::where('price', '>', 100)->searchable();

También puedes llamar al método `searchable` en una instancia de relación Eloquent:

    $user->orders()->searchable();

O, si ya tienes una colección de modelos Eloquent en memoria, puedes llamar al método `searchable` en la instancia de colección para agregar las instancias de modelo a su índice correspondiente:

    $orders->searchable();

> [!NOTE]  
> El método `searchable` puede considerarse una operación de "upsert". En otras palabras, si el registro del modelo ya está en tu índice, se actualizará. Si no existe en el índice de búsqueda, se agregará al índice.

<a name="updating-records"></a>
### Actualizando Registros

Para actualizar un modelo buscable, solo necesitas actualizar las propiedades de la instancia del modelo y `save` el modelo en tu base de datos. Scout persistirá automáticamente los cambios en tu índice de búsqueda:

    use App\Models\Order;

    $order = Order::find(1);

    // Actualiza el pedido...

    $order->save();

También puedes invocar el método `searchable` en una instancia de consulta Eloquent para actualizar una colección de modelos. Si los modelos no existen en tu índice de búsqueda, se crearán:

    Order::where('price', '>', 100)->searchable();

Si deseas actualizar los registros del índice de búsqueda para todos los modelos en una relación, puedes invocar el `searchable` en la instancia de relación:

    $user->orders()->searchable();

O, si ya tienes una colección de modelos Eloquent en memoria, puedes llamar al método `searchable` en la instancia de colección para actualizar las instancias de modelo en su índice correspondiente:

    $orders->searchable();

<a name="modifying-records-before-importing"></a>
#### Modificando Registros Antes de Importar

A veces, es posible que necesites preparar la colección de modelos antes de que se hagan buscables. Por ejemplo, es posible que desees cargar ansiosamente una relación para que los datos de la relación se puedan agregar de manera eficiente a tu índice de búsqueda. Para lograr esto, define un método `makeSearchableUsing` en el modelo correspondiente:

    use Illuminate\Database\Eloquent\Collection;

    /**
     * Modificar la colección de modelos que se están haciendo buscables.
     */
    public function makeSearchableUsing(Collection $models): Collection
    {
        return $models->load('author');
    }

<a name="removing-records"></a>
### Eliminando Registros

Para eliminar un registro de tu índice, simplemente puedes `delete` el modelo de la base de datos. Esto se puede hacer incluso si estás usando modelos [soft deleted](/docs/{{version}}/eloquent#soft-deleting):

    use App\Models\Order;

    $order = Order::find(1);

    $order->delete();

Si no deseas recuperar el modelo antes de eliminar el registro, puedes usar el método `unsearchable` en una instancia de consulta Eloquent:

    Order::where('price', '>', 100)->unsearchable();

Si deseas eliminar los registros del índice de búsqueda para todos los modelos en una relación, puedes invocar el `unsearchable` en la instancia de relación:

    $user->orders()->unsearchable();

O, si ya tienes una colección de modelos Eloquent en memoria, puedes llamar al método `unsearchable` en la instancia de colección para eliminar las instancias de modelo de su índice correspondiente:

    $orders->unsearchable();

Para eliminar todos los registros de modelo de su índice correspondiente, puedes invocar el método `removeAllFromSearch`:

    Order::removeAllFromSearch();

<a name="pausing-indexing"></a>
### Pausando la Indexación

A veces, es posible que necesites realizar un lote de operaciones Eloquent en un modelo sin sincronizar los datos del modelo con tu índice de búsqueda. Puedes hacer esto usando el método `withoutSyncingToSearch`. Este método acepta una única función anónima que se ejecutará inmediatamente. Cualquier operación de modelo que ocurra dentro de la función anónima no se sincronizará con el índice del modelo:

    use App\Models\Order;

    Order::withoutSyncingToSearch(function () {
        // Realizar acciones del modelo...
    });

<a name="conditionally-searchable-model-instances"></a>
### Instancias de Modelo Buscables Condicionalmente

A veces, es posible que necesites hacer que un modelo sea buscable solo bajo ciertas condiciones. Por ejemplo, imagina que tienes un modelo `App\Models\Post` que puede estar en uno de dos estados: "borrador" y "publicado". Puede que solo desees permitir que las publicaciones "publicadas" sean buscables. Para lograr esto, puedes definir un método `shouldBeSearchable` en tu modelo:

    /**
     * Determinar si el modelo debe ser buscable.
     */
    public function shouldBeSearchable(): bool
    {
        return $this->isPublished();
    }

El método `shouldBeSearchable` solo se aplica al manipular modelos a través de los métodos `save` y `create`, consultas o relaciones. Hacer que los modelos o colecciones sean buscables directamente usando el método `searchable` anulará el resultado del método `shouldBeSearchable`.

> [!WARNING]  
> El método `shouldBeSearchable` no es aplicable al usar el motor "database" de Scout, ya que todos los datos buscables siempre se almacenan en la base de datos. Para lograr un comportamiento similar al usar el motor de base de datos, deberías usar [cláusulas where](#where-clauses) en su lugar.

<a name="searching"></a>
## Buscando

Puedes comenzar a buscar un modelo usando el método `search`. El método de búsqueda acepta una única cadena que se utilizará para buscar tus modelos. Luego, debes encadenar el método `get` a la consulta de búsqueda para recuperar los modelos Eloquent que coincidan con la consulta de búsqueda dada:

    use App\Models\Order;

    $orders = Order::search('Star Trek')->get();

Dado que las búsquedas de Scout devuelven una colección de modelos Eloquent, incluso puedes devolver los resultados directamente desde una ruta o controlador y se convertirán automáticamente a JSON:

    use App\Models\Order;
    use Illuminate\Http\Request;

    Route::get('/search', function (Request $request) {
        return Order::search($request->search)->get();
    });

Si deseas obtener los resultados de búsqueda en bruto antes de que se conviertan en modelos Eloquent, puedes usar el método `raw`:

    $orders = Order::search('Star Trek')->raw();

<a name="custom-indexes"></a>
#### Índices Personalizados

Las consultas de búsqueda generalmente se realizarán en el índice especificado por el método [`searchableAs`](#configuring-model-indexes) del modelo. Sin embargo, puedes usar el método `within` para especificar un índice personalizado que debería ser buscado en su lugar:

    $orders = Order::search('Star Trek')
        ->within('tv_shows_popularity_desc')
        ->get();

<a name="where-clauses"></a>
### Cláusulas Where

Scout te permite agregar cláusulas "where" simples a tus consultas de búsqueda. Actualmente, estas cláusulas solo admiten verificaciones de igualdad numérica básicas y son principalmente útiles para limitar las consultas de búsqueda por un ID de propietario:

    use App\Models\Order;

    $orders = Order::search('Star Trek')->where('user_id', 1)->get();

Además, el método `whereIn` se puede usar para verificar que el valor de una columna dada esté contenido dentro del array dado:

    $orders = Order::search('Star Trek')->whereIn(
        'status', ['open', 'paid']
    )->get();

El método `whereNotIn` verifica que el valor de la columna dada no esté contenido en el array dado:

    $orders = Order::search('Star Trek')->whereNotIn(
        'status', ['closed']
    )->get();

Dado que un índice de búsqueda no es una base de datos relacional, no se admiten actualmente cláusulas "where" más avanzadas.

> [!WARNING]  
> Si tu aplicación está utilizando Meilisearch, debes configurar los [atributos filtrables](#configuring-filterable-data-for-meilisearch) de tu aplicación antes de utilizar las cláusulas "where" de Scout.

<a name="pagination"></a>
### Paginación

Además de recuperar una colección de modelos, puedes paginar tus resultados de búsqueda usando el método `paginate`. Este método devolverá una instancia de `Illuminate\Pagination\LengthAwarePaginator` justo como si hubieras [paginado una consulta Eloquent tradicional](/docs/{{version}}/pagination):

    use App\Models\Order;

    $orders = Order::search('Star Trek')->paginate();

Puedes especificar cuántos modelos recuperar por página pasando la cantidad como el primer argumento al método `paginate`:

    $orders = Order::search('Star Trek')->paginate(15);

Una vez que hayas recuperado los resultados, puedes mostrar los resultados y renderizar los enlaces de página usando [Blade](/docs/{{version}}/blade) justo como si hubieras paginado una consulta Eloquent tradicional:

```html
<div class="container">
    @foreach ($orders as $order)
        {{ $order->price }}
    @endforeach
</div>

{{ $orders->links() }}
```

Por supuesto, si deseas recuperar los resultados de paginación como JSON, puedes devolver la instancia del paginador directamente desde una ruta o controlador:

    use App\Models\Order;
    use Illuminate\Http\Request;

    Route::get('/orders', function (Request $request) {
        return Order::search($request->input('query'))->paginate(15);
    });

> [!WARNING]  
> Dado que los motores de búsqueda no son conscientes de las definiciones de alcance global de tu modelo Eloquent, no debes utilizar alcances globales en aplicaciones que utilicen la paginación de Scout. O, deberías recrear las restricciones del alcance global al buscar a través de Scout.

<a name="soft-deleting"></a>
### Eliminación Suave

Si tus modelos indexados están [eliminando suavemente](/docs/{{version}}/eloquent#soft-deleting) y necesitas buscar tus modelos eliminados suavemente, establece la opción `soft_delete` del archivo de configuración `config/scout.php` en `true`:

    'soft_delete' => true,

Cuando esta opción de configuración es `true`, Scout no eliminará los modelos eliminados suavemente del índice de búsqueda. En su lugar, establecerá un atributo oculto `__soft_deleted` en el registro indexado. Luego, puedes usar los métodos `withTrashed` o `onlyTrashed` para recuperar los registros eliminados suavemente al buscar:

    use App\Models\Order;

    // Incluir registros eliminados al recuperar resultados...
    $orders = Order::search('Star Trek')->withTrashed()->get();

```php
    // Solo incluye registros eliminados al recuperar resultados...
    $orders = Order::search('Star Trek')->onlyTrashed()->get();

> [!NOTE]  
> Cuando un modelo eliminado suavemente es eliminado permanentemente usando `forceDelete`, Scout lo eliminará automáticamente del índice de búsqueda.

<a name="customizing-engine-searches"></a>
### Personalizando Búsquedas de Motor

Si necesitas realizar una personalización avanzada del comportamiento de búsqueda de un motor, puedes pasar una función anónima como el segundo argumento al método `search`. Por ejemplo, podrías usar este callback para agregar datos de geo-localización a tus opciones de búsqueda antes de que la consulta de búsqueda sea pasada a Algolia:

    use Algolia\AlgoliaSearch\SearchIndex;
    use App\Models\Order;

    Order::search(
        'Star Trek',
        function (SearchIndex $algolia, string $query, array $options) {
            $options['body']['query']['bool']['filter']['geo_distance'] = [
                'distance' => '1000km',
                'location' => ['lat' => 36, 'lon' => 111],
            ];

            return $algolia->search($query, $options);
        }
    )->get();

<a name="customizing-the-eloquent-results-query"></a>
#### Personalizando la Consulta de Resultados Eloquent

Después de que Scout recupera una lista de modelos Eloquent coincidentes del motor de búsqueda de tu aplicación, se utiliza Eloquent para recuperar todos los modelos coincidentes por sus claves primarias. Puedes personalizar esta consulta invocando el método `query`. El método `query` acepta una función anónima que recibirá la instancia del constructor de consultas Eloquent como argumento:

```php
use App\Models\Order;
use Illuminate\Database\Eloquent\Builder;

$orders = Order::search('Star Trek')
    ->query(fn (Builder $query) => $query->with('invoices'))
    ->get();
```

Dado que este callback se invoca después de que los modelos relevantes ya han sido recuperados del motor de búsqueda de tu aplicación, el método `query` no debe ser utilizado para "filtrar" resultados. En su lugar, debes usar [cláusulas where de Scout](#where-clauses).

<a name="custom-engines"></a>
## Motores Personalizados

<a name="writing-the-engine"></a>
#### Escribiendo el Motor

Si uno de los motores de búsqueda de Scout integrados no se ajusta a tus necesidades, puedes escribir tu propio motor personalizado y registrarlo con Scout. Tu motor debe extender la clase abstracta `Laravel\Scout\Engines\Engine`. Esta clase abstracta contiene ocho métodos que tu motor personalizado debe implementar:

    use Laravel\Scout\Builder;

    abstract public function update($models);
    abstract public function delete($models);
    abstract public function search(Builder $builder);
    abstract public function paginate(Builder $builder, $perPage, $page);
    abstract public function mapIds($results);
    abstract public function map(Builder $builder, $results, $model);
    abstract public function getTotalCount($results);
    abstract public function flush($model);

Puede ser útil revisar las implementaciones de estos métodos en la clase `Laravel\Scout\Engines\AlgoliaEngine`. Esta clase te proporcionará un buen punto de partida para aprender cómo implementar cada uno de estos métodos en tu propio motor.

<a name="registering-the-engine"></a>
#### Registrando el Motor

Una vez que hayas escrito tu motor personalizado, puedes registrarlo con Scout utilizando el método `extend` del administrador de motores de Scout. El administrador de motores de Scout puede ser resuelto desde el contenedor de servicios de Laravel. Debes llamar al método `extend` desde el método `boot` de tu clase `App\Providers\AppServiceProvider` o cualquier otro proveedor de servicios utilizado por tu aplicación:

    use App\ScoutExtensions\MySqlSearchEngine;
    use Laravel\Scout\EngineManager;

    /**
     * Inicializa cualquier servicio de aplicación.
     */
    public function boot(): void
    {
        resolve(EngineManager::class)->extend('mysql', function () {
            return new MySqlSearchEngine;
        });
    }

Una vez que tu motor ha sido registrado, puedes especificarlo como tu `driver` Scout predeterminado en el archivo de configuración `config/scout.php` de tu aplicación:

    'driver' => 'mysql',
```
