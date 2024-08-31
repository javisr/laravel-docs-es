# Laravel Scout

- [Introducción](#introduction)
- [Instalación](#installation)
  - [Colas](#queueing)
- [Requisitos Previos del Driver](#driver-prerequisites)
  - [Algolia](#algolia)
  - [Meilisearch](#meilisearch)
  - [Typesense](#typesense)
- [Configuración](#configuration)
  - [Configurando Índices de Modelos](#configuring-model-indexes)
  - [Configurando Datos Indexables](#configuring-searchable-data)
  - [Configurando el ID del Modelo](#configuring-the-model-id)
  - [Configurando Motores de Búsqueda por Modelo](#configuring-search-engines-per-model)
  - [Identificando Usuarios](#identifying-users)
- [Motores de Base de Datos / Colección](#database-and-collection-engines)
  - [Motor de Base de Datos](#database-engine)
  - [Motor de Colección](#collection-engine)
- [Indexación](#indexing)
  - [Importación en Lotes](#batch-import)
  - [Agregando Registros](#adding-records)
  - [Actualizando Registros](#updating-records)
  - [Eliminando Registros](#removing-records)
  - [Pausando Indexación](#pausing-indexing)
  - [Instancias de Modelos Condicionalmente Indexables](#conditionally-searchable-model-instances)
- [Búsqueda](#searching)
  - [Cláusulas Where](#where-clauses)
  - [Paginación](#pagination)
  - [Eliminación Suave](#soft-deleting)
  - [Personalizando Búsquedas del Motor](#customizing-engine-searches)
- [Motores Personalizados](#custom-engines)

<a name="introduction"></a>
## Introducción

[Laravel Scout](https://github.com/laravel/scout) proporciona una solución simple y basada en drivers para añadir búsqueda de texto completo a tus [modelos Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent). Usando observadores de modelo, Scout mantendrá automáticamente tus índices de búsqueda sincronizados con tus registros Eloquent.
Actualmente, Scout se envía con controladores de [Algolia](https://www.algolia.com/), [Meilisearch](https://www.meilisearch.com), [Typesense](https://typesense.org) y MySQL / PostgreSQL (`database`). Además, Scout incluye un controlador "collection" que está diseñado para su uso en desarrollo local y no requiere dependencias externas ni servicios de terceros. Además, escribir controladores personalizados es simple y puedes extender Scout con tus propias implementaciones de búsqueda.

<a name="installation"></a>
## Instalación

Primero, instala Scout a través del gestor de paquetes Composer:


```shell
composer require laravel/scout

```
Después de instalar Scout, deberías publicar el archivo de configuración de Scout utilizando el comando Artisan `vendor:publish`. Este comando publicará el archivo de configuración `scout.php` en el directorio `config` de tu aplicación:


```shell
php artisan vendor:publish --provider="Laravel\Scout\ScoutServiceProvider"

```
Finalmente, añade el trait `Laravel\Scout\Searchable` al modelo que te gustaría hacer buscable. Este trait registrará un observador de modelo que mantendrá automáticamente el modelo en sincronía con tu driver de búsqueda:


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Laravel\Scout\Searchable;

class Post extends Model
{
    use Searchable;
}
```

<a name="queueing"></a>
### Cola (Queueing)

Aunque no es estrictamente necesario usar Scout, deberías considerar seriamente configurar un [driver de cola](/docs/%7B%7Bversion%7D%7D/queues) antes de usar la biblioteca. Ejecutar un trabajador de cola permitirá a Scout poner en cola todas las operaciones que sincronizan la información de tu modelo a tus índices de búsqueda, proporcionando tiempos de respuesta mucho mejores para la interfaz web de tu aplicación.
Una vez que hayas configurado un driver de cola, establece el valor de la opción `queue` en tu archivo de configuración `config/scout.php` a `true`:


```php
'queue' => true,
```
Incluso cuando la opción `queue` está configurada en `false`, es importante recordar que algunos controladores de Scout como Algolia y Meilisearch siempre indexan los registros de forma asíncrona. Esto significa que, aunque la operación de indexación se haya completado dentro de tu aplicación Laravel, el motor de búsqueda en sí puede no reflejar los registros nuevos y actualizados de inmediato.
Para especificar la conexión y la cola que utilizan tus trabajos de Scout, puedes definir la opción de configuración `queue` como un array:


```php
'queue' => [
    'connection' => 'redis',
    'queue' => 'scout'
],
```
Por supuesto, si personalizas la conexión y la cola que utilizan los trabajos de Scout, deberías ejecutar un worker de cola para procesar trabajos en esa conexión y cola:


```php
php artisan queue:work redis --queue=scout
```

<a name="driver-prerequisites"></a>
## Prerrequisitos del driver


<a name="algolia"></a>
### Algolia

Al utilizar el driver de Algolia, debes configurar tus credenciales `id` y `secret` de Algolia en tu archivo de configuración `config/scout.php`. Una vez que tus credenciales hayan sido configuradas, también necesitarás instalar el SDK de PHP de Algolia a través del gestor de paquetes Composer:


```shell
composer require algolia/algoliasearch-client-php

```

<a name="meilisearch"></a>
### Meilisearch

[Meilisearch](https://www.meilisearch.com) es un motor de búsqueda acelerado y de código abierto. Si no estás seguro de cómo instalar Meilisearch en tu máquina local, puedes usar [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail#meilisearch), el entorno de desarrollo Docker oficialmente soportado por Laravel.
Cuando uses el driver de Meilisearch, necesitarás instalar el SDK de PHP de Meilisearch a través del gestor de paquetes Composer:


```shell
composer require meilisearch/meilisearch-php http-interop/http-factory-guzzle

```
Luego, establece la variable de entorno `SCOUT_DRIVER`, así como tus credenciales `host` y `key` de Meilisearch dentro del archivo `.env` de tu aplicación:


```ini
SCOUT_DRIVER=meilisearch
MEILISEARCH_HOST=http://127.0.0.1:7700
MEILISEARCH_KEY=masterKey

```
Para obtener más información sobre Meilisearch, consulta la [documentación de Meilisearch](https://docs.meilisearch.com/learn/getting_started/quick_start.html).
Además, debes asegurarte de instalar una versión de `meilisearch/meilisearch-php` que sea compatible con tu versión binaria de Meilisearch revisando [la documentación de Meilisearch sobre compatibilidad binaria](https://github.com/meilisearch/meilisearch-php#-compatibility-with-meilisearch).
> [!WARNING]
Al actualizar Scout en una aplicación que utiliza Meilisearch, siempre debes [revisar cualquier cambio breaking adicional](https://github.com/meilisearch/Meilisearch/releases) en el propio servicio Meilisearch.

<a name="typesense"></a>
### Typesense

[Typesense](https://typesense.org) es un motor de búsqueda de código abierto y ultra rápido que admite búsqueda por palabras clave, búsqueda semántica, búsqueda geoespacial y búsqueda por vectores.
Puedes [autohospedar](https://typesense.org/docs/guide/install-typesense.html#option-2-local-machine-self-hosting) Typesense o usar [Typesense Cloud](https://cloud.typesense.org).
Para comenzar a usar Typesense con Scout, instala el SDK de PHP de Typesense a través del gestor de paquetes Composer:


```shell
composer require typesense/typesense-php

```
Luego, configura la variable de entorno `SCOUT_DRIVER` así como las credenciales de tu host y clave API de Typesense dentro del archivo .env de tu aplicación:


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
Configuraciones adicionales y definiciones de esquema para tus colecciones de Typesense se pueden encontrar dentro del archivo de configuración `config/scout.php` de tu aplicación. Para obtener más información sobre Typesense, consulta la [documentación de Typesense](https://typesense.org/docs/guide/#quick-start).

<a name="preparing-data-for-storage-in-typesense"></a>
#### Preparando Datos para Almacenamiento en Typesense

Al utilizar Typesense, el modelo que deseas hacer buscable debe definir un método `toSearchableArray` que convierta la clave primaria de tu modelo a una cadena y la fecha de creación a un timestamp UNIX:


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
También debes definir los esquemas de colección de Typesense en el archivo `config/scout.php` de tu aplicación. Un esquema de colección describe los tipos de datos de cada campo que se puede buscar a través de Typesense. Para obtener más información sobre todas las opciones de esquema disponibles, consulta la [documentación de Typesense](https://typesense.org/docs/latest/api/collections.html#schema-parameters).
Si necesitas cambiar el esquema de la colección de Typesense después de que se haya definido, puedes ejecutar `scout:flush` y `scout:import`, lo que eliminará todos los datos indexados existentes y recreará el esquema. O, puedes usar la API de Typesense para modificar el esquema de la colección sin eliminar ningún dato indexado.
Si tu modelo buscable es susceptible de eliminaciones suaves, debes definir un campo `__soft_deleted` en el esquema de Typesense correspondiente al modelo dentro del archivo de configuración `config/scout.php` de tu aplicación:


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
#### Parámetros de Búsqueda Dinámicos

Typesense te permite modificar tus [parámetros de búsqueda](https://typesense.org/docs/latest/api/search.html#search-parameters) de manera dinámica al realizar una operación de búsqueda a través del método `options`:


```php
use App\Models\Todo;

Todo::search('Groceries')->options([
    'query_by' => 'title, description'
])->get();

```

<a name="configuration"></a>
## Configuración


<a name="configuring-model-indexes"></a>
### Configurando Índices de Modelo

Cada modelo Eloquent está sincronizado con un "índice" de búsqueda dado, que contiene todos los registros buscables para ese modelo. En otras palabras, puedes pensar en cada índice como una tabla MySQL. Por defecto, cada modelo se persistirá en un índice que coincide con el nombre "table" típico del modelo. Típicamente, esta es la forma plural del nombre del modelo; sin embargo, puedes personalizar el índice del modelo sobrescribiendo el método `searchableAs` en el modelo:


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Laravel\Scout\Searchable;

class Post extends Model
{
    use Searchable;

    /**
     * Get the name of the index associated with the model.
     */
    public function searchableAs(): string
    {
        return 'posts_index';
    }
}
```

<a name="configuring-searchable-data"></a>
### Configurando Datos Buscables

Por defecto, toda la forma `toArray` de un modelo dado se persistirá en su índice de búsqueda. Si deseas personalizar los datos que se sincronizan con el índice de búsqueda, puedes sobrescribir el método `toSearchableArray` en el modelo:


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Laravel\Scout\Searchable;

class Post extends Model
{
    use Searchable;

    /**
     * Get the indexable data array for the model.
     *
     * @return array<string, mixed>
     */
    public function toSearchableArray(): array
    {
        $array = $this->toArray();

        // Customize the data array...

        return $array;
    }
}
```
Algunos motores de búsqueda como Meilisearch solo realizarán operaciones de filtrado (`>`, `<`, etc.) en datos del tipo correcto. Así que, al usar estos motores de búsqueda y personalizar tus datos buscables, debes asegurarte de que los valores numéricos se conviertan a su tipo correcto:


```php
public function toSearchableArray()
{
    return [
        'id' => (int) $this->id,
        'name' => $this->name,
        'price' => (float) $this->price,
    ];
}
```

<a name="configuring-filterable-data-for-meilisearch"></a>
#### Configurando Datos Filtrables y Configuraciones de Índice (Meilisearch)

A diferencia de los otros drivers de Scout, Meilisearch requiere que predefinas la configuración de búsqueda del índice, como los atributos filtrables, los atributos ordenables y [otros campos de configuración admitidos](https://docs.meilisearch.com/reference/api/settings.html).
Los atributos filtrables son cualquier atributo en el que planeas filtrar al invocar el método `where` de Scout, mientras que los atributos ordenables son cualquier atributo por el que planeas ordenar al invocar el método `orderBy` de Scout. Para definir la configuración de tu índice, ajusta la porción `index-settings` de tu entrada de configuración `meilisearch` en el archivo de configuración `scout` de tu aplicación:


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
Si el modelo subyacente a un índice dado es borrable de forma suave y se incluye en el array `index-settings`, Scout incluirá automáticamente soporte para filtrar modelos borrados de forma suave en ese índice. Si no tienes otros atributos filtrables o ordenables que definir para un índice de modelo borrable de forma suave, puedes simplemente añadir una entrada vacía al array `index-settings` para ese modelo:


```php
'index-settings' => [
    Flight::class => []
],

```
Después de configurar los ajustes de índice de tu aplicación, debes invocar el comando Artisan `scout:sync-index-settings`. Este comando informará a Meilisearch sobre tus ajustes de índice configurados actualmente. Para mayor comodidad, es posible que desees hacer que este comando forme parte de tu proceso de despliegue:


```shell
php artisan scout:sync-index-settings

```

<a name="configuring-the-model-id"></a>
### Configurando el ID del Modelo

Por defecto, Scout utilizará la clave primaria del modelo como el ID / clave única del modelo que se almacena en el índice de búsqueda. Si necesitas personalizar este comportamiento, puedes sobrescribir los métodos `getScoutKey` y `getScoutKeyName` en el modelo:


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Laravel\Scout\Searchable;

class User extends Model
{
    use Searchable;

    /**
     * Get the value used to index the model.
     */
    public function getScoutKey(): mixed
    {
        return $this->email;
    }

    /**
     * Get the key name used to index the model.
     */
    public function getScoutKeyName(): mixed
    {
        return 'email';
    }
}
```

<a name="configuring-search-engines-per-model"></a>
### Configuración de Motores de Búsqueda por Modelo

Al buscar, Scout suele utilizar el motor de búsqueda predeterminado especificado en el archivo de configuración `scout` de tu aplicación. Sin embargo, el motor de búsqueda para un modelo en particular se puede cambiar sobrescribiendo el método `searchableUsing` en el modelo:


```php
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
     * Get the engine used to index the model.
     */
    public function searchableUsing(): Engine
    {
        return app(EngineManager::class)->engine('meilisearch');
    }
}
```

<a name="identifying-users"></a>
### Identificando Usuarios

Scout también te permite identificar automáticamente a los usuarios al usar [Algolia](https://algolia.com). Asociar al usuario autenticado con las operaciones de búsqueda puede ser útil al ver tus análisis de búsqueda dentro del panel de control de Algolia. Puedes habilitar la identificación de usuarios definiendo una variable de entorno `SCOUT_IDENTIFY` como `true` en el archivo `.env` de tu aplicación:


```ini
SCOUT_IDENTIFY=true

```
Habilitar esta función también enviará la dirección IP de la solicitud y el identificador principal de tu usuario autenticado a Algolia, para que estos datos se asocien con cualquier solicitud de búsqueda que realice el usuario.

<a name="database-and-collection-engines"></a>
## Motores de Base de Datos / Colecciones


<a name="database-engine"></a>
### Motor de Base de Datos

> [!WARNING]
El motor de base de datos actualmente soporta MySQL y PostgreSQL.
Si tu aplicación interactúa con bases de datos pequeñas a medianas o tiene una carga de trabajo ligera, puede que te resulte más conveniente comenzar con el motor "database" de Scout. El motor de base de datos utilizará cláusulas "where like" e índices de texto completo al filtrar los resultados de tu base de datos existente para determinar los resultados de búsqueda aplicables a tu consulta.
Para usar el motor de la base de datos, simplemente puedes establecer el valor de la variable de entorno `SCOUT_DRIVER` en `database`, o especificar el driver `database` directamente en el archivo de configuración `scout` de tu aplicación:


```ini
SCOUT_DRIVER=database

```
Una vez que hayas especificado el motor de base de datos como tu driver preferido, debes [configurar tus datos buscables](#configuring-searchable-data). Luego, puedes comenzar a [ejecutar consultas de búsqueda](#searching) en tus modelos. El indexado de motores de búsqueda, como el indexado necesario para sembrar índices de Algolia, Meilisearch o Typesense, no es necesario cuando se utiliza el motor de base de datos.
#### Personalizando Estrategias de Búsqueda en la Base de Datos

Por defecto, el motor de la base de datos ejecutará una consulta "where like" contra cada atributo del modelo que has [configurado como buscable](#configuring-searchable-data). Sin embargo, en algunas situaciones, esto puede resultar en un rendimiento deficiente. Por lo tanto, se puede configurar la estrategia de búsqueda del motor de la base de datos para que algunas columnas especificadas utilicen consultas de búsqueda de texto completo o solo usen restricciones "where like" para buscar los prefijos de las cadenas (`example%`) en lugar de buscar dentro de la cadena completa (`%example%`).
Para definir este comportamiento, puedes asignar atributos PHP al método `toSearchableArray` de tu modelo. Cualquier columna que no tenga un comportamiento de búsqueda adicional asignado continuará utilizando la estrategia predeterminada "where like":


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
Antes de especificar que una columna debe usar restricciones de consulta de texto completo, asegúrate de que la columna haya sido asignada a un [índice de texto completo](/docs/%7B%7Bversion%7D%7D/migrations#available-index-types).

<a name="collection-engine"></a>
### Motor de Colección

Aunque puedes usar los motores de búsqueda Algolia, Meilisearch o Typesense durante el desarrollo local, es posible que te resulte más conveniente comenzar con el motor "collection". El motor de colección utilizará cláusulas "where" y filtrado de colección en los resultados de tu base de datos existente para determinar los resultados de búsqueda aplicables a tu consulta. Al usar este motor, no es necesario "indexar" tus modelos buscables, ya que simplemente se recuperarán de tu base de datos local.
Para utilizar el motor de colecciones, simplemente puedes establecer el valor de la variable de entorno `SCOUT_DRIVER` en `collection`, o especificar el driver `collection` directamente en el archivo de configuración `scout` de tu aplicación:


```ini
SCOUT_DRIVER=collection

```
Una vez que hayas especificado el driver de colección como tu driver preferido, puedes comenzar a [ejecutar consultas de búsqueda](#searching) contra tus modelos. La indexación de motores de búsqueda, como la indexación necesaria para llenar los índices de Algolia, Meilisearch o Typesense, no es necesaria al usar el motor de colección.
#### Diferencias con el Motor de Base de Datos

A primera vista, los motores "database" y "collections" son bastante similares. Ambos interactúan directamente con tu base de datos para recuperar resultados de búsqueda. Sin embargo, el motor de colección no utiliza índices de texto completo ni cláusulas `LIKE` para encontrar registros coincidentes. En su lugar, extrae todos los posibles registros y utiliza el helper `Str::is` de Laravel para determinar si la cadena de búsqueda existe dentro de los valores de los atributos del modelo.
El motor de colección es el motor de búsqueda más portátil, ya que funciona en todas las bases de datos relacionales soportadas por Laravel (incluyendo SQLite y SQL Server); sin embargo, es menos eficiente que el motor de base de datos de Scout.

<a name="indexing"></a>
## Indexación


<a name="batch-import"></a>
### Importación por Lotes

Si estás instalando Scout en un proyecto existente, es posible que ya tengas registros de base de datos que necesitas importar en tus índices. Scout proporciona un comando Artisan `scout:import` que puedes usar para importar todos tus registros existentes en tus índices de búsqueda:


```shell
php artisan scout:import "App\Models\Post"

```
El comando `flush` se puede utilizar para eliminar todos los registros de un modelo de tus índices de búsqueda:


```shell
php artisan scout:flush "App\Models\Post"

```

<a name="modifying-the-import-query"></a>
#### Modificando la Consulta de Importación

Si deseas modificar la consulta que se utiliza para recuperar todos tus modelos para la importación por lotes, puedes definir un método `makeAllSearchableUsing` en tu modelo. Este es un buen lugar para añadir cualquier carga de relaciones ansiosas que pueda ser necesaria antes de importar tus modelos:


```php
use Illuminate\Database\Eloquent\Builder;

/**
 * Modify the query used to retrieve models when making all of the models searchable.
 */
protected function makeAllSearchableUsing(Builder $query): Builder
{
    return $query->with('author');
}
```
> [!WARNING]
El método `makeAllSearchableUsing` puede no ser aplicable cuando se utiliza una cola para importar modelos en lotes. Las relaciones no son [restauradas](/docs/%7B%7Bversion%7D%7D/queues#handling-relationships) cuando las colecciones de modelos son procesadas por trabajos.

<a name="adding-records"></a>
### Agregar Registros

Una vez que hayas añadido el trait `Laravel\Scout\Searchable` a un modelo, todo lo que necesitas hacer es `guardar` o `crear` una instancia del modelo y se añadirá automáticamente a tu índice de búsqueda. Si has configurado Scout para [usar colas](#queueing), esta operación se realizará en segundo plano por tu trabajador de colas:


```php
use App\Models\Order;

$order = new Order;

// ...

$order->save();
```

<a name="adding-records-via-query"></a>
#### Agregar Registros a través de Consulta

Si deseas agregar una colección de modelos a tu índice de búsqueda a través de una consulta Eloquent, puedes encadenar el método `searchable` a la consulta Eloquent. El método `searchable` [dividirá los resultados](/docs/%7B%7Bversion%7D%7D/eloquent#chunking-results) de la consulta y añadirá los registros a tu índice de búsqueda. Nuevamente, si has configurado Scout para usar colas, todos los fragmentos se importarán en segundo plano por tus trabajadores de cola:


```php
use App\Models\Order;

Order::where('price', '>', 100)->searchable();
```
También puedes llamar al método `searchable` en una instancia de relación Eloquent:
O, si ya tienes una colección de modelos Eloquent en memoria, puedes llamar al método `searchable` en la instancia de la colección para añadir las instancias del modelo a su índice correspondiente:
> [!NOTA]
El método `searchable` puede considerarse una operación de "upsert". En otras palabras, si el registro del modelo ya está en tu índice, se actualizará. Si no existe en el índice de búsqueda, se añadirá al índice.

<a name="updating-records"></a>
### Actualizando Registros

Para actualizar un modelo buscable, solo necesitas actualizar las propiedades de la instancia del modelo y `guardar` el modelo en tu base de datos. Scout persistirá automáticamente los cambios en tu índice de búsqueda:


```php
use App\Models\Order;

$order = Order::find(1);

// Update the order...

$order->save();
```
También puedes invocar el método `searchable` en una instancia de consulta Eloquent para actualizar una colección de modelos. Si los modelos no existen en tu índice de búsqueda, serán creados:


```php
Order::where('price', '>', 100)->searchable();
```
Si deseas actualizar los registros del índice de búsqueda para todos los modelos en una relación, puedes invocar `searchable` en la instancia de la relación:


```php
$user->orders()->searchable();
```
O, si ya tienes una colección de modelos Eloquent en memoria, puedes llamar al método `searchable` en la instancia de la colección para actualizar las instancias del modelo en su índice correspondiente:


```php
$orders->searchable();
```

<a name="modifying-records-before-importing"></a>
#### Modificando Registros Antes de Importar

A veces es posible que debas preparar la colección de modelos antes de que se hagan buscables. Por ejemplo, es posible que desees cargar con anticipación una relación para que los datos de la relación se puedan añadir de manera eficiente a tu índice de búsqueda. Para lograr esto, define un método `makeSearchableUsing` en el modelo correspondiente:


```php
use Illuminate\Database\Eloquent\Collection;

/**
 * Modify the collection of models being made searchable.
 */
public function makeSearchableUsing(Collection $models): Collection
{
    return $models->load('author');
}
```

<a name="removing-records"></a>
### Eliminando Registros

Para eliminar un registro de tu índice, simplemente puedes `eliminar` el modelo de la base de datos. Esto se puede hacer incluso si estás utilizando modelos [eliminados suavemente](/docs/%7B%7Bversion%7D%7D/eloquent#soft-deleting):


```php
use App\Models\Order;

$order = Order::find(1);

$order->delete();
```
Si no deseas recuperar el modelo antes de eliminar el registro, puedes usar el método `unsearchable` en una instancia de consulta Eloquent:


```php
Order::where('price', '>', 100)->unsearchable();
```
Si deseas eliminar los registros del índice de búsqueda para todos los modelos en una relación, puedes invocar el método `unsearchable` en la instancia de la relación:


```php
$user->orders()->unsearchable();
```
O, si ya tienes una colección de modelos Eloquent en memoria, puedes llamar al método `unsearchable` en la instancia de la colección para eliminar las instancias del modelo de su índice correspondiente:


```php
$orders->unsearchable();
```
Para eliminar todos los registros del modelo de su índice correspondiente, puedes invocar el método `removeAllFromSearch`:


```php
Order::removeAllFromSearch();
```

<a name="pausing-indexing"></a>
### Pausando la Indexación

A veces puede que necesites realizar un lote de operaciones Eloquent en un modelo sin sincronizar los datos del modelo con tu índice de búsqueda. Puedes hacer esto utilizando el método `withoutSyncingToSearch`. Este método acepta una sola `función anónima` que se ejecutará de inmediato. Cualquier operación de modelo que ocurra dentro de la `función anónima` no se sincronizará con el índice del modelo:


```php
use App\Models\Order;

Order::withoutSyncingToSearch(function () {
    // Perform model actions...
});
```

<a name="conditionally-searchable-model-instances"></a>
### Instancias de Modelo Buscables Condicionalmente

A veces es posible que solo necesites hacer que un modelo sea buscable bajo ciertas condiciones. Por ejemplo, imagina que tienes un modelo `App\Models\Post` que puede estar en uno de dos estados: "borrador" y "publicado". Es posible que solo desees permitir que las publicaciones "publicadas" sean buscables. Para lograr esto, puedes definir un método `shouldBeSearchable` en tu modelo:


```php
/**
 * Determine if the model should be searchable.
 */
public function shouldBeSearchable(): bool
{
    return $this->isPublished();
}
```
El método `shouldBeSearchable` solo se aplica al manipular modelos a través de los métodos `save` y `create`, consultas o relaciones. Hacer que los modelos o colecciones sean buscables directamente utilizando el método `searchable` anulará el resultado del método `shouldBeSearchable`.
> [!WARNING]
El método `shouldBeSearchable` no es aplicable cuando se utiliza el motor "database" de Scout, ya que todos los datos buscables siempre se almacenan en la base de datos. Para lograr un comportamiento similar al utilizar el motor de base de datos, deberías usar [cláusulas where](#where-clauses) en su lugar.

<a name="searching"></a>
## Búsqueda

Puedes comenzar a buscar un modelo utilizando el método `search`. El método de búsqueda acepta una sola cadena que se utilizará para buscar tus modelos. Luego, debes encadenar el método `get` a la consulta de búsqueda para recuperar los modelos Eloquent que coinciden con la consulta de búsqueda dada:


```php
use App\Models\Order;

$orders = Order::search('Star Trek')->get();
```
Dado que las búsquedas de Scout devuelven una colección de modelos Eloquent, incluso puedes devolver los resultados directamente desde una ruta o un controlador y se convertirán automáticamente a JSON:


```php
use App\Models\Order;
use Illuminate\Http\Request;

Route::get('/search', function (Request $request) {
    return Order::search($request->search)->get();
});
```
Si deseas obtener los resultados de búsqueda en bruto antes de que se conviertan en modelos Eloquent, puedes usar el método `raw`:


```php
$orders = Order::search('Star Trek')->raw();
```

<a name="custom-indexes"></a>
#### Índices Personalizados

Las consultas de búsqueda se realizarán típicamente en el índice especificado por el método [`searchableAs`](#configuring-model-indexes) del modelo. Sin embargo, puedes usar el método `within` para especificar un índice personalizado que se debe buscar en su lugar:


```php
$orders = Order::search('Star Trek')
    ->within('tv_shows_popularity_desc')
    ->get();
```

<a name="where-clauses"></a>
### Cláusulas Where

Scout te permite añadir cláusulas de "where" simples a tus consultas de búsqueda. Actualmente, estas cláusulas solo admiten comprobaciones de igualdad numérica básicas y son principalmente útiles para limitar consultas de búsqueda por un ID de propietario:


```php
use App\Models\Order;

$orders = Order::search('Star Trek')->where('user_id', 1)->get();
```
Además, el método `whereIn` se puede utilizar para verificar que el valor de una columna dada esté contenido dentro del array dado:


```php
$orders = Order::search('Star Trek')->whereIn(
    'status', ['open', 'paid']
)->get();
```
El método `whereNotIn` verifica que el valor de la columna dada no esté contenido en el array dado:


```php
$orders = Order::search('Star Trek')->whereNotIn(
    'status', ['closed']
)->get();
```
Dado que un índice de búsqueda no es una base de datos relacional, las cláusulas "where" más avanzadas no son compatibles actualmente.
> [!WARNING]
Si tu aplicación está utilizando Meilisearch, debes configurar los [atributos filtrables](#configuring-filterable-data-for-meilisearch) de tu aplicación antes de utilizar las cláusulas "where" de Scout.

<a name="pagination"></a>
### Paginación

Además de recuperar una colección de modelos, puedes paginar tus resultados de búsqueda utilizando el método `paginate`. Este método devolverá una instancia de `Illuminate\Pagination\LengthAwarePaginator` tal como si hubieras [pagado una consulta Eloquent tradicional](/docs/%7B%7Bversion%7D%7D/pagination):


```php
use App\Models\Order;

$orders = Order::search('Star Trek')->paginate();
```
Puedes especificar cuántos modelos recuperar por página pasando la cantidad como el primer argumento al método `paginate`:


```php
$orders = Order::search('Star Trek')->paginate(15);
```
Una vez que hayas recuperado los resultados, puedes mostrar los resultados y renderizar los enlaces de la página utilizando [Blade](/docs/%7B%7Bversion%7D%7D/blade) como si hubieras paginado una consulta Eloquent tradicional:


```html
<div class="container">
    @foreach ($orders as $order)
        {{ $order->price }}
    @endforeach
</div>

{{ $orders->links() }}

```
Por supuesto, si deseas recuperar los resultados de paginación como JSON, puedes devolver directamente la instancia del paginador desde una ruta o controlador:


```php
use App\Models\Order;
use Illuminate\Http\Request;

Route::get('/orders', function (Request $request) {
    return Order::search($request->input('query'))->paginate(15);
});
```
> [!WARNING]
Dado que los motores de búsqueda no son conscientes de las definiciones de alcance global de tu modelo Eloquent, no debes utilizar alcances globales en aplicaciones que utilicen paginación de Scout. O bien, deberías recrear las restricciones del alcance global al buscar a través de Scout.

<a name="soft-deleting"></a>
### Eliminación Suave

Si tus modelos indexados están [eliminando suavemente](/docs/%7B%7Bversion%7D%7D/eloquent#soft-deleting) y necesitas buscar tus modelos eliminados suavemente, configura la opción `soft_delete` del archivo de configuración `config/scout.php` en `true`:


```php
'soft_delete' => true,
```
Cuando esta opción de configuración es `true`, Scout no eliminará modelos eliminados suavemente del índice de búsqueda. En su lugar, establecerá un atributo oculto `__soft_deleted` en el registro indexado. Luego, puedes usar los métodos `withTrashed` o `onlyTrashed` para recuperar los registros eliminados suavemente al realizar búsquedas:


```php
use App\Models\Order;

// Include trashed records when retrieving results...
$orders = Order::search('Star Trek')->withTrashed()->get();

// Only include trashed records when retrieving results...
$orders = Order::search('Star Trek')->onlyTrashed()->get();
```
> [!NOTE]
Cuando un modelo eliminado suavemente es eliminado de forma permanente utilizando `forceDelete`, Scout lo eliminará automáticamente del índice de búsqueda.

<a name="customizing-engine-searches"></a>
### Personalizando Búsquedas de Engine

Si necesitas realizar una personalización avanzada del comportamiento de búsqueda de un motor, puedes pasar una función anónima como segundo argumento al método `search`. Por ejemplo, podrías usar este callback para añadir datos de geolocalización a tus opciones de búsqueda antes de que se pase la consulta de búsqueda a Algolia:


```php
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
```

<a name="customizing-the-eloquent-results-query"></a>
#### Personalizando la Consulta de Resultados de Eloquent

Después de que Scout recupera una lista de modelos Eloquent que coinciden desde el motor de búsqueda de tu aplicación, se utiliza Eloquent para recuperar todos los modelos coincidentes por sus claves primarias. Puedes personalizar esta consulta invocando el método `query`. El método `query` acepta una función anónima que recibirá la instancia del constructor de consultas Eloquent como argumento:


```php
use App\Models\Order;
use Illuminate\Database\Eloquent\Builder;

$orders = Order::search('Star Trek')
    ->query(fn (Builder $query) => $query->with('invoices'))
    ->get();

```
Dado que este callback se invoca después de que los modelos relevantes ya han sido recuperados del motor de búsqueda de tu aplicación, el método `query` no debe utilizarse para "filtrar" resultados. En su lugar, deberías usar [cláusulas where de Scout](#where-clauses).

<a name="custom-engines"></a>
## Motores Personalizados


<a name="writing-the-engine"></a>
#### Escribiendo el Motor

Si uno de los motores de búsqueda integrados de Scout no se adapta a tus necesidades, puedes escribir tu propio motor personalizado y registrarlo con Scout. Tu motor debe extender la clase abstracta `Laravel\Scout\Engines\Engine`. Esta clase abstracta contiene ocho métodos que tu motor personalizado debe implementar:


```php
use Laravel\Scout\Builder;

abstract public function update($models);
abstract public function delete($models);
abstract public function search(Builder $builder);
abstract public function paginate(Builder $builder, $perPage, $page);
abstract public function mapIds($results);
abstract public function map(Builder $builder, $results, $model);
abstract public function getTotalCount($results);
abstract public function flush($model);
```
Puede que te resulte útil revisar las implementaciones de estos métodos en la clase `Laravel\Scout\Engines\AlgoliaEngine`. Esta clase te proporcionará un buen punto de partida para aprender cómo implementar cada uno de estos métodos en tu propio motor.

<a name="registering-the-engine"></a>
#### Registrando el Motor

Una vez que hayas escrito tu motor personalizado, puedes registrarlo con Scout utilizando el método `extend` del gestor de motores de Scout. El gestor de motores de Scout se puede resolver desde el contenedor de servicios de Laravel. Debes llamar al método `extend` desde el método `boot` de tu clase `App\Providers\AppServiceProvider` o cualquier otro proveedor de servicios utilizado por tu aplicación:


```php
use App\ScoutExtensions\MySqlSearchEngine;
use Laravel\Scout\EngineManager;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    resolve(EngineManager::class)->extend('mysql', function () {
        return new MySqlSearchEngine;
    });
}
```
Una vez que tu motor haya sido registrado, puedes especificarlo como tu `driver` Scout predeterminado en el archivo de configuración `config/scout.php` de tu aplicación:


```php
'driver' => 'mysql',
```