# Base de datos: Query Builder

- [Introducción](#introduction)
- [Ejecutando Consultas a la Base de Datos](#running-database-queries)
  - [Dividiendo Resultados](#chunking-results)
  - [Transmitiendo Resultados de Forma Perezosa](#streaming-results-lazily)
  - [Agregados](#aggregates)
- [Sentencias Select](#select-statements)
- [Expresiones Crudas](#raw-expressions)
- [Joins](#joins)
- [Uniones](#unions)
- [Cláusulas Where Básicas](#basic-where-clauses)
  - [Cláusulas Where](#where-clauses)
  - [Cláusulas Or Where](#or-where-clauses)
  - [Cláusulas Where Not](#where-not-clauses)
  - [Cláusulas Where Any / All / None](#where-any-all-none-clauses)
  - [Cláusulas Where JSON](#json-where-clauses)
  - [Cláusulas Where Adicionales](#additional-where-clauses)
  - [Agrupación Lógica](#logical-grouping)
- [Cláusulas Where Avanzadas](#advanced-where-clauses)
  - [Cláusulas Where Exists](#where-exists-clauses)
  - [Cláusulas Where Subconsulta](#subquery-where-clauses)
  - [Cláusulas Where de Texto Completo](#full-text-where-clauses)
- [Ordenación, Agrupación, Límite y Desplazamiento](#ordering-grouping-limit-and-offset)
  - [Ordenación](#ordering)
  - [Agrupación](#grouping)
  - [Límite y Desplazamiento](#limit-and-offset)
- [Cláusulas Condicionales](#conditional-clauses)
- [Sentencias Insert](#insert-statements)
  - [Upserts](#upserts)
- [Sentencias Update](#update-statements)
  - [Actualizando Columnas JSON](#updating-json-columns)
  - [Incrementar y Decrementar](#increment-and-decrement)
- [Sentencias Delete](#delete-statements)
- [Bloqueo Pesimista](#pessimistic-locking)
- [Depuración](#debugging)

<a name="introduction"></a>
## Introducción

El constructor de consultas de base de datos de Laravel proporciona una interfaz fluida y conveniente para crear y ejecutar consultas de base de datos. Se puede usar para realizar la mayoría de las operaciones de base de datos en tu aplicación y funciona perfectamente con todos los sistemas de bases de datos soportados por Laravel.
El constructor de consultas de Laravel utiliza el enlace de parámetros PDO para proteger su aplicación contra ataques de inyección SQL. No es necesario limpiar o sanear las cadenas pasadas al constructor de consultas como vinculaciones de consulta.

<a name="running-database-queries"></a>
## Ejecución de Consultas a la Base de Datos


<a name="retrieving-all-rows-from-a-table"></a>
#### Recuperando Todas las Filas de una Tabla

Puedes usar el método `table` proporcionado por la fachada `DB` para iniciar una consulta. El método `table` devuelve una instancia de un generador de consultas fluente para la tabla dada, lo que te permite encadenar más restricciones a la consulta y luego recuperar los resultados de la consulta utilizando el método `get`:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class UserController extends Controller
{
    /**
     * Show a list of all of the application's users.
     */
    public function index(): View
    {
        $users = DB::table('users')->get();

        return view('user.index', ['users' => $users]);
    }
}
```
El método `get` devuelve una instancia de `Illuminate\Support\Collection` que contiene los resultados de la consulta, donde cada resultado es una instancia del objeto PHP `stdClass`. Puedes acceder al valor de cada columna accediendo a la columna como una propiedad del objeto:


```php
use Illuminate\Support\Facades\DB;

$users = DB::table('users')->get();

foreach ($users as $user) {
    echo $user->name;
}
```
> [!NOTA]
Las colecciones de Laravel ofrecen una variedad de métodos extremadamente poderosos para mapear y reducir datos. Para obtener más información sobre las colecciones de Laravel, consulta la [documentación de colecciones](/docs/%7B%7Bversion%7D%7D/collections).

<a name="retrieving-a-single-row-column-from-a-table"></a>
#### Recuperando una Sola Fila / Columna de una Tabla

Si solo necesitas recuperar una sola fila de una tabla de base de datos, puedes usar el método `first` de la fachada `DB`. Este método devolverá un solo objeto `stdClass`:


```php
$user = DB::table('users')->where('name', 'John')->first();

return $user->email;
```
Si no necesitas toda una fila, puedes extraer un solo valor de un registro utilizando el método `value`. Este método devolverá el valor de la columna directamente:


```php
$email = DB::table('users')->where('name', 'John')->value('email');
```
Para recuperar una sola fila por el valor de su columna `id`, utiliza el método `find`:


```php
$user = DB::table('users')->find(3);
```

<a name="retrieving-a-list-of-column-values"></a>
#### Recuperando una Lista de Valores de Columna

Si deseas obtener una instancia de `Illuminate\Support\Collection` que contenga los valores de una sola columna, puedes usar el método `pluck`. En este ejemplo, recuperaremos una colección de títulos de usuario:


```php
use Illuminate\Support\Facades\DB;

$titles = DB::table('users')->pluck('title');

foreach ($titles as $title) {
    echo $title;
}
```
Puedes especificar la columna que la colección resultante debe usar como sus claves proporcionando un segundo argumento al método `pluck`:


```php
$titles = DB::table('users')->pluck('title', 'name');

foreach ($titles as $name => $title) {
    echo $title;
}
```

<a name="chunking-results"></a>
### Resultados de Fragmentación

Si necesitas trabajar con miles de registros de base de datos, considera usar el método `chunk` proporcionado por la facade `DB`. Este método recupera un pequeño fragmento de resultados a la vez y alimenta cada fragmento a una función anónima para su procesamiento. Por ejemplo, recuperemos toda la tabla `users` en fragmentos de 100 registros a la vez:


```php
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

DB::table('users')->orderBy('id')->chunk(100, function (Collection $users) {
    foreach ($users as $user) {
        // ...
    }
});
```
Puedes detener el procesamiento de más segmentos devolviendo `false` desde la `función anónima`:


```php
DB::table('users')->orderBy('id')->chunk(100, function (Collection $users) {
    // Process the records...

    return false;
});
```
Si estás actualizando registros de base de datos mientras haces fragmentos de resultados, los resultados de tus fragmentos podrían cambiar de maneras inesperadas. Si planeas actualizar los registros recuperados mientras fragmentas, siempre es mejor usar el método `chunkById`. Este método paginará automáticamente los resultados en función de la clave primaria del registro:


```php
DB::table('users')->where('active', false)
    ->chunkById(100, function (Collection $users) {
        foreach ($users as $user) {
            DB::table('users')
                ->where('id', $user->id)
                ->update(['active' => true]);
        }
    });
```
> [!WARNING]
Al actualizar o eliminar registros dentro del callback de chunk, cualquier cambio en la clave primaria o en las claves foráneas podría afectar la consulta de chunk. Esto podría resultar potencialmente en que los registros no se incluyan en los resultados agrupados.

<a name="streaming-results-lazily"></a>
### Transmitiendo Resultados de Forma Perezosa

El método `lazy` funciona de manera similar al método [chunk](#chunking-results) en el sentido de que ejecuta la consulta en bloques. Sin embargo, en lugar de pasar cada bloque a una función de callback, el método `lazy()` devuelve una [`LazyCollection`](/docs/%7B%7Bversion%7D%7D/collections#lazy-collections), que te permite interactuar con los resultados como si fueran un solo flujo:


```php
use Illuminate\Support\Facades\DB;

DB::table('users')->orderBy('id')->lazy()->each(function (object $user) {
    // ...
});

```
Una vez más, si planeas actualizar los registros recuperados mientras los iteras, es mejor usar los métodos `lazyById` o `lazyByIdDesc`. Estos métodos paginarán automáticamente los resultados en función de la clave primaria del registro:


```php
DB::table('users')->where('active', false)
    ->lazyById()->each(function (object $user) {
        DB::table('users')
            ->where('id', $user->id)
            ->update(['active' => true]);
    });

```
> [!WARNING]
Al actualizar o eliminar registros mientras se itera sobre ellos, cualquier cambio en la clave primaria o en las claves foráneas podría afectar la consulta por fragmentos. Esto podría resultar potencialmente en que los registros no se incluyan en los resultados.

<a name="aggregates"></a>
### Agregados

El generador de consultas también ofrece una variedad de métodos para recuperar valores agregados como `count`, `max`, `min`, `avg` y `sum`. Puedes llamar a cualquiera de estos métodos después de construir tu consulta:


```php
use Illuminate\Support\Facades\DB;

$users = DB::table('users')->count();

$price = DB::table('orders')->max('price');
```
Por supuesto, puedes combinar estos métodos con otras cláusulas para ajustar cómo se calcula tu valor agregado:


```php
$price = DB::table('orders')
                ->where('finalized', 1)
                ->avg('price');
```

<a name="determining-if-records-exist"></a>
#### Determinando si Existen Registros

En lugar de utilizar el método `count` para determinar si existen registros que coinciden con las restricciones de tu consulta, puedes usar los métodos `exists` y `doesntExist`:


```php
if (DB::table('orders')->where('finalized', 1)->exists()) {
    // ...
}

if (DB::table('orders')->where('finalized', 1)->doesntExist()) {
    // ...
}
```

<a name="select-statements"></a>
## Declaraciones de Selección


<a name="specifying-a-select-clause"></a>
#### Especificando una Cláusula de Selección

Puede que no siempre desees seleccionar todas las columnas de una tabla de base de datos. Usando el método `select`, puedes especificar una cláusula de "select" personalizada para la consulta:


```php
use Illuminate\Support\Facades\DB;

$users = DB::table('users')
            ->select('name', 'email as user_email')
            ->get();
```
El método `distinct` te permite forzar que la consulta devuelva resultados distintos:


```php
$users = DB::table('users')->distinct()->get();
```
Si ya tienes una instancia del generador de consultas y deseas agregar una columna a su cláusula de selección existente, puedes usar el método `addSelect`:


```php
$query = DB::table('users')->select('name');

$users = $query->addSelect('age')->get();
```

<a name="raw-expressions"></a>
## Expresiones En Crudo

A veces puede que necesites insertar una cadena arbitraria en una consulta. Para crear una expresión de cadena en bruto, puedes usar el método `raw` proporcionado por la facade `DB`:


```php
$users = DB::table('users')
             ->select(DB::raw('count(*) as user_count, status'))
             ->where('status', '<>', 1)
             ->groupBy('status')
             ->get();
```
> [!WARNING]
Las declaraciones en bruto se inyectarán en la consulta como cadenas, así que debes tener mucho cuidado para evitar crear vulnerabilidades de inyección SQL.

<a name="raw-methods"></a>
### Métodos Crudos

En lugar de utilizar el método `DB::raw`, también puedes utilizar los siguientes métodos para insertar una expresión en bruto en varias partes de tu consulta. **Recuerda, Laravel no puede garantizar que cualquier consulta que utilice expresiones en bruto esté protegida contra vulnerabilidades de inyección SQL.**

<a name="selectraw"></a>
#### `selectRaw`

El método `selectRaw` se puede utilizar en lugar de `addSelect(DB::raw(/* ... */))`. Este método acepta un array opcional de enlaces como su segundo argumento:


```php
$orders = DB::table('orders')
                ->selectRaw('price * ? as price_with_tax', [1.0825])
                ->get();
```

<a name="whereraw-orwhereraw"></a>
#### `whereRaw / orWhereRaw`

Los métodos `whereRaw` y `orWhereRaw` se pueden usar para inyectar una cláusula "where" en bruto en tu consulta. Estos métodos aceptan un array opcional de vinculaciones como su segundo argumento:


```php
$orders = DB::table('orders')
                ->whereRaw('price > IF(state = "TX", ?, 100)', [200])
                ->get();
```

<a name="havingraw-orhavingraw"></a>
#### `havingRaw / orHavingRaw`

Los métodos `havingRaw` y `orHavingRaw` se pueden utilizar para proporcionar una cadena en bruto como el valor de la cláusula "having". Estos métodos aceptan un array opcional de vinculaciones como su segundo argumento:


```php
$orders = DB::table('orders')
                ->select('department', DB::raw('SUM(price) as total_sales'))
                ->groupBy('department')
                ->havingRaw('SUM(price) > ?', [2500])
                ->get();
```

<a name="orderbyraw"></a>
#### `orderByRaw`

El método `orderByRaw` se puede utilizar para proporcionar una cadena en bruto como el valor de la cláusula "order by":


```php
$orders = DB::table('orders')
                ->orderByRaw('updated_at - created_at DESC')
                ->get();
```

<a name="groupbyraw"></a>
### `groupByRaw`

El método `groupByRaw` se puede utilizar para proporcionar una cadena en bruto como el valor de la cláusula `group by`:


```php
$orders = DB::table('orders')
                ->select('city', 'state')
                ->groupByRaw('city, state')
                ->get();
```

<a name="joins"></a>
## Uniones


<a name="inner-join-clause"></a>
#### Cláusula Inner Join

El constructor de consultas también se puede utilizar para añadir cláusulas de unión a tus consultas. Para realizar un "inner join" básico, puedes usar el método `join` en una instancia del constructor de consultas. El primer argumento que se pasa al método `join` es el nombre de la tabla a la que necesitas unirte, mientras que los argumentos restantes especifican las restricciones de columna para la unión. Incluso puedes unirte a múltiples tablas en una sola consulta:


```php
use Illuminate\Support\Facades\DB;

$users = DB::table('users')
            ->join('contacts', 'users.id', '=', 'contacts.user_id')
            ->join('orders', 'users.id', '=', 'orders.user_id')
            ->select('users.*', 'contacts.phone', 'orders.price')
            ->get();
```

<a name="left-join-right-join-clause"></a>
#### Cláusula Left Join / Right Join

Si deseas realizar un "left join" o "right join" en lugar de un "inner join", utiliza los métodos `leftJoin` o `rightJoin`. Estos métodos tienen la misma firma que el método `join`:


```php
$users = DB::table('users')
            ->leftJoin('posts', 'users.id', '=', 'posts.user_id')
            ->get();

$users = DB::table('users')
            ->rightJoin('posts', 'users.id', '=', 'posts.user_id')
            ->get();
```

<a name="cross-join-clause"></a>
#### Cláusula de Join Cruzado

Puedes usar el método `crossJoin` para realizar un "cross join". Los cross joins generan un producto cartesiano entre la primera tabla y la tabla unida:


```php
$sizes = DB::table('sizes')
            ->crossJoin('colors')
            ->get();
```

<a name="advanced-join-clauses"></a>
#### Cláusulas de Unión Avanzadas

También puedes especificar cláusulas de unión más avanzadas. Para empezar, pasa una función anónima como segundo argumento al método `join`. La función anónima recibirá una instancia de `Illuminate\Database\Query\JoinClause`, lo que te permite especificar restricciones en la cláusula de "unión":


```php
DB::table('users')
        ->join('contacts', function (JoinClause $join) {
            $join->on('users.id', '=', 'contacts.user_id')->orOn(/* ... */);
        })
        ->get();
```
Si deseas usar una cláusula "where" en tus uniones, puedes utilizar los métodos `where` y `orWhere` proporcionados por la instancia `JoinClause`. En lugar de comparar dos columnas, estos métodos compararán la columna contra un valor:


```php
DB::table('users')
        ->join('contacts', function (JoinClause $join) {
            $join->on('users.id', '=', 'contacts.user_id')
                 ->where('contacts.user_id', '>', 5);
        })
        ->get();
```

<a name="subquery-joins"></a>
#### Uniones de Subconsultas

Puedes usar los métodos `joinSub`, `leftJoinSub` y `rightJoinSub` para unir una consulta a una subconsulta. Cada uno de estos métodos recibe tres argumentos: la subconsulta, su alias de tabla y una función anónima que define las columnas relacionadas. En este ejemplo, recuperaremos una colección de usuarios donde cada registro de usuario también contenga la marca de tiempo `created_at` de la publicación de blog más reciente del usuario:


```php
$latestPosts = DB::table('posts')
                   ->select('user_id', DB::raw('MAX(created_at) as last_post_created_at'))
                   ->where('is_published', true)
                   ->groupBy('user_id');

$users = DB::table('users')
        ->joinSub($latestPosts, 'latest_posts', function (JoinClause $join) {
            $join->on('users.id', '=', 'latest_posts.user_id');
        })->get();
```

<a name="lateral-joins"></a>
#### Joins Laterales

> [!WARNING]
Los uniones laterales son actualmente soportadas por PostgreSQL, MySQL >= 8.0.14 y SQL Server.
Puedes usar los métodos `joinLateral` y `leftJoinLateral` para realizar un "lateral join" con una subconsulta. Cada uno de estos métodos recibe dos argumentos: la subconsulta y su alias de tabla. Las condiciones de unión deben especificarse dentro de la cláusula `where` de la subconsulta dada. Los lateral joins se evalúan para cada fila y pueden hacer referencia a columnas fuera de la subconsulta.
En este ejemplo, recuperaremos una colección de usuarios así como las tres publicaciones de blog más recientes del usuario. Cada usuario puede producir hasta tres filas en el conjunto de resultados: una por cada una de sus publicaciones de blog más recientes. La condición de unión se especifica con una cláusula `whereColumn` dentro de la subconsulta, haciendo referencia a la fila del usuario actual:


```php
$latestPosts = DB::table('posts')
                   ->select('id as post_id', 'title as post_title', 'created_at as post_created_at')
                   ->whereColumn('user_id', 'users.id')
                   ->orderBy('created_at', 'desc')
                   ->limit(3);

$users = DB::table('users')
            ->joinLateral($latestPosts, 'latest_posts')
            ->get();
```

<a name="unions"></a>
## Uniones

El constructor de consultas también ofrece un método conveniente para "unir" dos o más consultas. Por ejemplo, puedes crear una consulta inicial y usar el método `union` para unirla con más consultas:


```php
use Illuminate\Support\Facades\DB;

$first = DB::table('users')
            ->whereNull('first_name');

$users = DB::table('users')
            ->whereNull('last_name')
            ->union($first)
            ->get();
```
Además del método `union`, el constructor de consultas proporciona un método `unionAll`. Las consultas que se combinan utilizando el método `unionAll` no tendrán sus resultados duplicados eliminados. El método `unionAll` tiene la misma firma de método que el método `union`.

<a name="basic-where-clauses"></a>
## Cláusulas Where Básicas


<a name="where-clauses"></a>
### Cláusulas Where

Puedes usar el método `where` del constructor de consultas para añadir cláusulas "where" a la consulta. La llamada más básica al método `where` requiere tres argumentos. El primer argumento es el nombre de la columna. El segundo argumento es un operador, que puede ser cualquiera de los operadores soportados por la base de datos. El tercer argumento es el valor con el que comparar el valor de la columna.
Por ejemplo, la siguiente consulta recupera usuarios donde el valor de la columna `votes` es igual a `100` y el valor de la columna `age` es mayor que `35`:


```php
$users = DB::table('users')
                ->where('votes', '=', 100)
                ->where('age', '>', 35)
                ->get();
```
Para conveniencia, si deseas verificar que una columna es `=` a un valor dado, puedes pasar el valor como segundo argumento al método `where`. Laravel asumirá que te gustaría usar el operador `=`:


```php
$users = DB::table('users')->where('votes', 100)->get();
```
Como se mencionó anteriormente, puedes usar cualquier operador que sea compatible con tu sistema de base de datos:


```php
$users = DB::table('users')
                ->where('votes', '>=', 100)
                ->get();

$users = DB::table('users')
                ->where('votes', '<>', 100)
                ->get();

$users = DB::table('users')
                ->where('name', 'like', 'T%')
                ->get();
```
También puedes pasar un array de condiciones a la función `where`. Cada elemento del array debe ser un array que contenga los tres argumentos que típicamente se pasan al método `where`:


```php
$users = DB::table('users')->where([
    ['status', '=', '1'],
    ['subscribed', '<>', '1'],
])->get();
```
> [!WARNING]
PDO no admite la vinculación de nombres de columna. Por lo tanto, nunca debes permitir que la entrada del usuario dicte los nombres de columna referenciados por tus consultas, incluyendo las columnas "order by".

<a name="or-where-clauses"></a>
### O Cláusulas Where

Al encadenar llamadas al método `where` del generador de consultas, las cláusulas "where" se unirán utilizando el operador `and`. Sin embargo, puedes usar el método `orWhere` para unir una cláusula a la consulta utilizando el operador `or`. El método `orWhere` acepta los mismos argumentos que el método `where`:


```php
$users = DB::table('users')
                    ->where('votes', '>', 100)
                    ->orWhere('name', 'John')
                    ->get();
```
Si necesitas agrupar una condición "o" entre paréntesis, puedes pasar una `función anónima` como primer argumento al método `orWhere`:


```php
$users = DB::table('users')
            ->where('votes', '>', 100)
            ->orWhere(function (Builder $query) {
                $query->where('name', 'Abigail')
                      ->where('votes', '>', 50);
            })
            ->get();
```


```sql
select * from users where votes > 100 or (name = 'Abigail' and votes > 50)

```

<a name="where-not-clauses"></a>
### Donde No Clauses

Los métodos `whereNot` y `orWhereNot` se pueden usar para negar un grupo dado de restricciones de consulta. Por ejemplo, la siguiente consulta excluye productos que están en liquidación o que tienen un precio que es menos de diez:


```php
$products = DB::table('products')
                ->whereNot(function (Builder $query) {
                    $query->where('clearance', true)
                          ->orWhere('price', '<', 10);
                })
                ->get();
```

<a name="where-any-all-none-clauses"></a>
### Donde Cualquier / Todos / Ninguno Clausulas

A veces es posible que necesites aplicar las mismas restricciones de consulta a múltiples columnas. Por ejemplo, es posible que desees recuperar todos los registros donde cualquier columna en una lista dada sea `LIKE` un valor dado. Puedes lograr esto utilizando el método `whereAny`:


```php
$users = DB::table('users')
            ->where('active', true)
            ->whereAny([
                'name',
                'email',
                'phone',
            ], 'like', 'Example%')
            ->get();
```


```sql
SELECT *
FROM users
WHERE active = true AND (
    name LIKE 'Example%' OR
    email LIKE 'Example%' OR
    phone LIKE 'Example%'
)

```
De manera similar, el método `whereAll` se puede utilizar para recuperar registros donde todas las columnas dadas coinciden con una restricción dada:


```php
$posts = DB::table('posts')
            ->where('published', true)
            ->whereAll([
                'title',
                'content',
            ], 'like', '%Laravel%')
            ->get();
```


```sql
SELECT *
FROM posts
WHERE published = true AND (
    title LIKE '%Laravel%' AND
    content LIKE '%Laravel%'
)

```
El método `whereNone` se puede utilizar para recuperar registros donde ninguna de las columnas dadas coincida con una restricción dada:


```php
$posts = DB::table('albums')
            ->where('published', true)
            ->whereNone([
                'title',
                'lyrics',
                'tags',
            ], 'like', '%explicit%')
            ->get();
```
La consulta anterior resultará en el siguiente SQL:


```sql
SELECT *
FROM albums
WHERE published = true AND NOT (
    title LIKE '%explicit%' OR
    lyrics LIKE '%explicit%' OR
    tags LIKE '%explicit%'
)

```

<a name="json-where-clauses"></a>
### Cláusulas Where JSON

Laravel también admite la consulta de tipos de columna JSON en bases de datos que proporcionan soporte para tipos de columna JSON. Actualmente, esto incluye MariaDB 10.3+, MySQL 8.0+, PostgreSQL 12.0+, SQL Server 2017+ y SQLite 3.39.0+. Para consultar una columna JSON, utiliza el operador `->`:


```php
$users = DB::table('users')
                ->where('preferences->dining->meal', 'salad')
                ->get();
```
Puedes usar `whereJsonContains` para consultar arreglos JSON:


```php
$users = DB::table('users')
                ->whereJsonContains('options->languages', 'en')
                ->get();
```
Si tu aplicación utiliza las bases de datos MariaDB, MySQL o PostgreSQL, puedes pasar un array de valores al método `whereJsonContains`:


```php
$users = DB::table('users')
                ->whereJsonContains('options->languages', ['en', 'de'])
                ->get();
```
Puedes usar el método `whereJsonLength` para consultar arrays JSON por su longitud:


```php
$users = DB::table('users')
                ->whereJsonLength('options->languages', 0)
                ->get();

$users = DB::table('users')
                ->whereJsonLength('options->languages', '>', 1)
                ->get();
```

<a name="additional-where-clauses"></a>
### Cláusulas Where Adicionales

**whereLike / orWhereLike / whereNotLike / orWhereNotLike**
El método `whereLike` te permite añadir cláusulas "LIKE" a tu consulta para la coincidencia de patrones. Estos métodos proporcionan una forma independiente de la base de datos de realizar consultas de coincidencia de cadenas, con la capacidad de alternar la sensibilidad a mayúsculas y minúsculas. Por defecto, la coincidencia de cadenas es insensible a mayúsculas y minúsculas:


```php
$users = DB::table('users')
           ->whereLike('name', '%John%')
           ->get();
```
Puedes habilitar una búsqueda que distingue entre mayúsculas y minúsculas a través del argumento `caseSensitive`:


```php
$users = DB::table('users')
           ->whereLike('name', '%John%', caseSensitive: true)
           ->get();
```
El método `orWhereLike` te permite añadir una cláusula "or" con una condición LIKE:


```php
$users = DB::table('users')
           ->where('votes', '>', 100)
           ->orWhereLike('name', '%John%')
           ->get();
```
El método `whereNotLike` te permite añadir cláusulas "NOT LIKE" a tu consulta:


```php
$users = DB::table('users')
           ->whereNotLike('name', '%John%')
           ->get();
```
De manera similar, puedes usar `orWhereNotLike` para añadir una cláusula "o" con una condición NOT LIKE:


```php
$users = DB::table('users')
           ->where('votes', '>', 100)
           ->orWhereNotLike('name', '%John%')
           ->get();
```
> [!WARNING]
La opción de búsqueda `whereLike` sensible a mayúsculas y minúsculas actualmente no es compatible con SQL Server.
**whereIn / whereNotIn / orWhereIn / orWhereNotIn**
El método `whereIn` verifica que el valor de una columna dada esté contenido dentro del array dado:


```php
$users = DB::table('users')
                    ->whereIn('id', [1, 2, 3])
                    ->get();
```
El método `whereNotIn` verifica que el valor de la columna dada no esté contenido en el array dado:


```php
$users = DB::table('users')
                    ->whereNotIn('id', [1, 2, 3])
                    ->get();
```
También puedes proporcionar un objeto de consulta como segundo argumento del método `whereIn`:


```php
$activeUsers = DB::table('users')->select('id')->where('is_active', 1);

$users = DB::table('comments')
                    ->whereIn('user_id', $activeUsers)
                    ->get();
```
El ejemplo anterior producirá el siguiente SQL:


```sql
select * from comments where user_id in (
    select id
    from users
    where is_active = 1
)

```
> [!WARNING]
Si estás añadiendo un gran array de enlaces enteros a tu consulta, los métodos `whereIntegerInRaw` o `whereIntegerNotInRaw` pueden utilizarse para reducir significativamente tu uso de memoria.
**whereBetween / orWhereBetween**
El método `whereBetween` verifica que el valor de una columna esté entre dos valores:


```php
$users = DB::table('users')
           ->whereBetween('votes', [1, 100])
           ->get();
```
**whereNotBetween / orWhereNotBetween**
El método `whereNotBetween` verifica que el valor de una columna esté fuera de dos valores:


```php
$users = DB::table('users')
                    ->whereNotBetween('votes', [1, 100])
                    ->get();
```
**whereBetweenColumns / whereNotBetweenColumns / orWhereBetweenColumns / orWhereNotBetweenColumns**
El método `whereBetweenColumns` verifica que el valor de una columna esté entre los dos valores de dos columnas en la misma fila de la tabla:


```php
$patients = DB::table('patients')
                       ->whereBetweenColumns('weight', ['minimum_allowed_weight', 'maximum_allowed_weight'])
                       ->get();
```
El método `whereNotBetweenColumns` verifica que el valor de una columna esté fuera de los dos valores de dos columnas en la misma fila de la tabla:


```php
$patients = DB::table('patients')
                       ->whereNotBetweenColumns('weight', ['minimum_allowed_weight', 'maximum_allowed_weight'])
                       ->get();
```
**whereNull / whereNotNull / orWhereNull / orWhereNotNull**
El método `whereNull` verifica que el valor de la columna dada sea `NULL`:


```php
$users = DB::table('users')
                ->whereNull('updated_at')
                ->get();
```
El método `whereNotNull` verifica que el valor de la columna no sea `NULL`:


```php
$users = DB::table('users')
                ->whereNotNull('updated_at')
                ->get();
```
**whereDate / whereMonth / whereDay / whereYear / whereTime**
El método `whereDate` se puede utilizar para comparar el valor de una columna con una fecha:


```php
$users = DB::table('users')
                ->whereDate('created_at', '2016-12-31')
                ->get();
```
El método `whereMonth` se puede utilizar para comparar el valor de una columna con un mes específico:


```php
$users = DB::table('users')
                ->whereMonth('created_at', '12')
                ->get();
```
El método `whereDay` se puede utilizar para comparar el valor de una columna con un día específico del mes:


```php
$users = DB::table('users')
                ->whereDay('created_at', '31')
                ->get();
```
El método `whereYear` se puede utilizar para comparar el valor de una columna con un año específico:


```php
$users = DB::table('users')
                ->whereYear('created_at', '2016')
                ->get();
```
El método `whereTime` se puede utilizar para comparar el valor de una columna contra un tiempo específico:


```php
$users = DB::table('users')
                ->whereTime('created_at', '=', '11:20:45')
                ->get();
```
**whereColumn / orWhereColumn**
El método `whereColumn` se puede utilizar para verificar que dos columnas son iguales:


```php
$users = DB::table('users')
                ->whereColumn('first_name', 'last_name')
                ->get();
```
También puedes pasar un operador de comparación al método `whereColumn`:


```php
$users = DB::table('users')
                ->whereColumn('updated_at', '>', 'created_at')
                ->get();
```
También puedes pasar un array de comparaciones de columnas al método `whereColumn`. Estas condiciones se unirán utilizando el operador `and`:


```php
$users = DB::table('users')
                ->whereColumn([
                    ['first_name', '=', 'last_name'],
                    ['updated_at', '>', 'created_at'],
                ])->get();
```

<a name="logical-grouping"></a>
### Agrupamiento Lógico

A veces es posible que necesites agrupar varias cláusulas "where" entre paréntesis para lograr el agrupamiento lógico deseado en tu consulta. De hecho, generalmente deberías agrupar las llamadas al método `orWhere` entre paréntesis para evitar un comportamiento inesperado en la consulta. Para lograr esto, puedes pasar una función anónima al método `where`:


```php
$users = DB::table('users')
           ->where('name', '=', 'John')
           ->where(function (Builder $query) {
               $query->where('votes', '>', 100)
                     ->orWhere('title', '=', 'Admin');
           })
           ->get();
```
Como puedes ver, pasar una `función anónima` al método `where` instruye al generador de consultas a comenzar un grupo de restricciones. La `función anónima` recibirá una instancia del generador de consultas que puedes usar para establecer las restricciones que deben estar contenidas dentro del grupo entre paréntesis. El ejemplo anterior producirá el siguiente SQL:


```sql
select * from users where name = 'John' and (votes > 100 or title = 'Admin')

```
> [!WARNING]
Siempre debes agrupar las llamadas a `orWhere` para evitar comportamientos inesperados cuando se aplican scopes globales.

<a name="advanced-where-clauses"></a>
### Cláusulas Where Avanzadas


<a name="where-exists-clauses"></a>
### Donde Existen Cláusulas

El método `whereExists` te permite escribir cláusulas SQL de "where exists". El método `whereExists` acepta una función anónima que recibirá una instancia del generador de consultas, lo que te permitirá definir la consulta que debería colocarse dentro de la cláusula "exists":


```php
$users = DB::table('users')
           ->whereExists(function (Builder $query) {
               $query->select(DB::raw(1))
                     ->from('orders')
                     ->whereColumn('orders.user_id', 'users.id');
           })
           ->get();
```
Alternativamente, puedes proporcionar un objeto de consulta al método `whereExists` en lugar de una función anónima:


```php
$orders = DB::table('orders')
                ->select(DB::raw(1))
                ->whereColumn('orders.user_id', 'users.id');

$users = DB::table('users')
                    ->whereExists($orders)
                    ->get();
```
Ambos ejemplos anteriores producirán el siguiente SQL:


```sql
select * from users
where exists (
    select 1
    from orders
    where orders.user_id = users.id
)

```

<a name="subquery-where-clauses"></a>
### Cláusulas Where de Subconsulta

A veces es posible que necesites construir una cláusula "where" que compare los resultados de una subconsulta con un valor dado. Puedes lograr esto pasando una función anónima y un valor al método `where`. Por ejemplo, la siguiente consulta recuperará todos los usuarios que tienen una "membresía" reciente de un tipo dado;


```php
use App\Models\User;
use Illuminate\Database\Query\Builder;

$users = User::where(function (Builder $query) {
    $query->select('type')
        ->from('membership')
        ->whereColumn('membership.user_id', 'users.id')
        ->orderByDesc('membership.start_date')
        ->limit(1);
}, 'Pro')->get();
```
O, puede que necesites construir una cláusula "where" que compare una columna con los resultados de una subconsulta. Puedes lograr esto pasando una columna, un operador y una función anónima al método `where`. Por ejemplo, la siguiente consulta recuperará todos los registros de ingresos donde el monto es menor que el promedio;


```php
use App\Models\Income;
use Illuminate\Database\Query\Builder;

$incomes = Income::where('amount', '<', function (Builder $query) {
    $query->selectRaw('avg(i.amount)')->from('incomes as i');
})->get();
```

<a name="full-text-where-clauses"></a>
### Claúsulas Where de Texto Completo

> [!WARNING]
Las cláusulas de texto completo donde actualmente son admitidas por MariaDB, MySQL y PostgreSQL.
Los métodos `whereFullText` y `orWhereFullText` se pueden usar para añadir cláusulas "where" de texto completo a una consulta para columnas que tienen [índices de texto completo](/docs/%7B%7Bversion%7D%7D/migrations#available-index-types). Laravel transformará estos métodos en el SQL apropiado para el sistema de base de datos subyacente. Por ejemplo, se generará una cláusula `MATCH AGAINST` para aplicaciones que utilicen MariaDB o MySQL:


```php
$users = DB::table('users')
           ->whereFullText('bio', 'web developer')
           ->get();
```

<a name="ordering-grouping-limit-and-offset"></a>
## Ordenando, Agrupando, Límite y Offset


<a name="ordering"></a>
### Ordenando


<a name="orderby"></a>
#### El método `orderBy`

El método `orderBy` te permite ordenar los resultados de la consulta por una columna dada. El primer argumento que acepta el método `orderBy` debe ser la columna por la que deseas ordenar, mientras que el segundo argumento determina la dirección de la ordenación y puede ser `asc` o `desc`:


```php
$users = DB::table('users')
                ->orderBy('name', 'desc')
                ->get();
```
Para ordenar por múltiples columnas, simplemente puedes invocar `orderBy` tantas veces como sea necesario:


```php
$users = DB::table('users')
                ->orderBy('name', 'desc')
                ->orderBy('email', 'asc')
                ->get();
```

<a name="latest-oldest"></a>
#### Los Métodos `latest` y `oldest`

Los métodos `latest` y `oldest` te permiten ordenar resultados por fecha de manera sencilla. Por defecto, el resultado se ordenará por la columna `created_at` de la tabla. O puedes pasar el nombre de la columna por la que deseas ordenar:


```php
$user = DB::table('users')
                ->latest()
                ->first();
```

<a name="random-ordering"></a>
#### Ordenamiento Aleatorio

El método `inRandomOrder` se puede utilizar para ordenar los resultados de la consulta de forma aleatoria. Por ejemplo, puedes usar este método para obtener un usuario aleatorio:


```php
$randomUser = DB::table('users')
                ->inRandomOrder()
                ->first();
```

<a name="removing-existing-orderings"></a>
#### Eliminando Ordenamientos Existentes

El método `reorder` elimina todas las cláusulas "order by" que se han aplicado previamente a la consulta:


```php
$query = DB::table('users')->orderBy('name');

$unorderedUsers = $query->reorder()->get();
```
Puedes pasar una columna y dirección al llamar al método `reorder` para eliminar todas las cláusulas "order by" existentes y aplicar un nuevo orden completamente a la consulta:


```php
$query = DB::table('users')->orderBy('name');

$usersOrderedByEmail = $query->reorder('email', 'desc')->get();
```

<a name="grouping"></a>
### Agrupación


<a name="groupby-having"></a>
#### Los Métodos `groupBy` y `having`

Como era de esperar, los métodos `groupBy` y `having` se pueden utilizar para agrupar los resultados de la consulta. La firma del método `having` es similar a la del método `where`:


```php
$users = DB::table('users')
                ->groupBy('account_id')
                ->having('account_id', '>', 100)
                ->get();
```
Puedes usar el método `havingBetween` para filtrar los resultados dentro de un rango dado:


```php
$report = DB::table('orders')
                ->selectRaw('count(id) as number_of_orders, customer_id')
                ->groupBy('customer_id')
                ->havingBetween('number_of_orders', [5, 15])
                ->get();
```
Puedes pasar múltiples argumentos al método `groupBy` para agrupar por múltiples columnas:


```php
$users = DB::table('users')
                ->groupBy('first_name', 'status')
                ->having('account_id', '>', 100)
                ->get();
```
Para construir declaraciones `having` más avanzadas, consulta el método [`havingRaw`](#raw-methods).

<a name="limit-and-offset"></a>
### Límite y Desplazamiento


<a name="skip-take"></a>
#### Los métodos `skip` y `take`

Puedes usar los métodos `skip` y `take` para limitar el número de resultados devueltos de la consulta o para omitir un número dado de resultados en la consulta:


```php
$users = DB::table('users')->skip(10)->take(5)->get();
```
Alternativamente, puedes usar los métodos `limit` y `offset`. Estos métodos son funcionalmente equivalentes a los métodos `take` y `skip`, respectivamente:


```php
$users = DB::table('users')
                ->offset(10)
                ->limit(5)
                ->get();
```

<a name="conditional-clauses"></a>
## Cláusulas Condicionales

A veces es posible que desees que ciertas cláusulas de consulta se apliquen a una consulta en función de otra condición. Por ejemplo, es posible que solo desees aplicar una declaración `where` si un valor de entrada dado está presente en la solicitud HTTP entrante. Puedes lograr esto utilizando el método `when`:


```php
$role = $request->input('role');

$users = DB::table('users')
                ->when($role, function (Builder $query, string $role) {
                    $query->where('role_id', $role);
                })
                ->get();
```
El método `when` solo ejecuta la `función anónima` dada cuando el primer argumento es `true`. Si el primer argumento es `false`, la `función anónima` no se ejecutará. Así que, en el ejemplo anterior, la `función anónima` dada al método `when` solo se invocará si el campo `role` está presente en la solicitud entrante y evalúa a `true`.
Puedes pasar otra `función anónima` como tercer argumento al método `when`. Esta `función anónima` solo se ejecutará si el primer argumento evalúa como `false`. Para ilustrar cómo se puede usar esta función, la utilizaremos para configurar el ordenamiento predeterminado de una consulta:


```php
$sortByVotes = $request->boolean('sort_by_votes');

$users = DB::table('users')
                ->when($sortByVotes, function (Builder $query, bool $sortByVotes) {
                    $query->orderBy('votes');
                }, function (Builder $query) {
                    $query->orderBy('name');
                })
                ->get();
```

<a name="insert-statements"></a>
## Instrucciones de Inserción

El generador de consultas también proporciona un método `insert` que se puede usar para insertar registros en la tabla de la base de datos. El método `insert` acepta un array de nombres de columnas y valores:


```php
DB::table('users')->insert([
    'email' => 'kayla@example.com',
    'votes' => 0
]);
```
Puedes insertar varios registros a la vez pasando un array de arrays. Cada array representa un registro que debe ser insertado en la tabla:


```php
DB::table('users')->insert([
    ['email' => 'picard@example.com', 'votes' => 0],
    ['email' => 'janeway@example.com', 'votes' => 0],
]);
```
El método `insertOrIgnore` ignorará errores al insertar registros en la base de datos. Al usar este método, debes tener en cuenta que se ignorarán los errores de registros duplicados y otros tipos de errores también pueden ser ignorados dependiendo del motor de la base de datos. Por ejemplo, `insertOrIgnore` [eludirá el modo estricto de MySQL](https://dev.mysql.com/doc/refman/en/sql-mode.html#ignore-effect-on-execution):


```php
DB::table('users')->insertOrIgnore([
    ['id' => 1, 'email' => 'sisko@example.com'],
    ['id' => 2, 'email' => 'archer@example.com'],
]);
```
El método `insertUsing` insertará nuevos registros en la tabla mientras utiliza una subconsulta para determinar los datos que se deben insertar:


```php
DB::table('pruned_users')->insertUsing([
    'id', 'name', 'email', 'email_verified_at'
], DB::table('users')->select(
    'id', 'name', 'email', 'email_verified_at'
)->where('updated_at', '<=', now()->subMonth()));
```

<a name="auto-incrementing-ids"></a>
#### IDs de Auto-Incremento

Si la tabla tiene un ID que se auto-incrementa, utiliza el método `insertGetId` para insertar un registro y luego recuperar el ID:


```php
$id = DB::table('users')->insertGetId(
    ['email' => 'john@example.com', 'votes' => 0]
);
```
> [!WARNING]
Cuando se utiliza PostgreSQL, el método `insertGetId` espera que la columna de auto-incremento se llame `id`. Si deseas recuperar el ID de una "secuencia" diferente, puedes pasar el nombre de la columna como segundo parámetro al método `insertGetId`.

<a name="upserts"></a>
### Upserts

El método `upsert` insertará registros que no existen y actualizará los registros que ya existen con nuevos valores que puedes especificar. El primer argumento del método consiste en los valores a insertar o actualizar, mientras que el segundo argumento enumera las columnas que identifican de manera única los registros dentro de la tabla asociada. El tercer y último argumento del método es un array de columnas que deben actualizarse si ya existe un registro coincidente en la base de datos:


```php
DB::table('flights')->upsert(
    [
        ['departure' => 'Oakland', 'destination' => 'San Diego', 'price' => 99],
        ['departure' => 'Chicago', 'destination' => 'New York', 'price' => 150]
    ],
    ['departure', 'destination'],
    ['price']
);
```
En el ejemplo anterior, Laravel intentará insertar dos registros. Si ya existe un registro con los mismos valores de columna `departure` y `destination`, Laravel actualizará la columna `price` de ese registro.
> [!WARNING]
Todas las bases de datos excepto SQL Server requieren que las columnas en el segundo argumento del método `upsert` tengan un índice "primario" o "único". Además, los controladores de base de datos MariaDB y MySQL ignoran el segundo argumento del método `upsert` y siempre utilizan los índices "primarios" y "únicos" de la tabla para detectar registros existentes.

<a name="update-statements"></a>
## Sentencias de Actualización

Además de insertar registros en la base de datos, el generador de consultas también puede actualizar registros existentes utilizando el método `update`. El método `update`, al igual que el método `insert`, acepta un array de pares de columna y valor que indican las columnas a actualizar. El método `update` devuelve el número de filas afectadas. Puedes restringir la consulta `update` utilizando cláusulas `where`:


```php
$affected = DB::table('users')
              ->where('id', 1)
              ->update(['votes' => 1]);
```

<a name="update-or-insert"></a>
#### Actualizar o Insertar

A veces es posible que desees actualizar un registro existente en la base de datos o crearlo si no existe un registro coincidente. En este escenario, se puede usar el método `updateOrInsert`. El método `updateOrInsert` acepta dos argumentos: un array de condiciones para encontrar el registro y un array de pares de columna y valor que indican las columnas a actualizar.
El método `updateOrInsert` intentará localizar un registro de base de datos coincidente utilizando los pares de columna y valor del primer argumento. Si el registro existe, se actualizará con los valores del segundo argumento. Si no se puede encontrar el registro, se insertará un nuevo registro con los atributos combinados de ambos argumentos:


```php
DB::table('users')
    ->updateOrInsert(
        ['email' => 'john@example.com', 'name' => 'John'],
        ['votes' => '2']
    );
```
Puedes proporcionar una función anónima al método `updateOrInsert` para personalizar los atributos que se actualizan o insertan en la base de datos según la existencia de un registro coincidente:


```php
DB::table('users')->updateOrInsert(
    ['user_id' => $user_id],
    fn ($exists) => $exists ? [
        'name' => $data['name'],
        'email' => $data['email'],
    ] : [
        'name' => $data['name'],
        'email' => $data['email'],
        'marketable' => true,
    ],
);

```

<a name="updating-json-columns"></a>
### Actualizando columnas JSON

Al actualizar una columna JSON, debes usar la sintaxis `->` para actualizar la clave apropiada en el objeto JSON. Esta operación es compatible con MariaDB 10.3+, MySQL 5.7+ y PostgreSQL 9.5+:


```php
$affected = DB::table('users')
              ->where('id', 1)
              ->update(['options->enabled' => true]);
```

<a name="increment-and-decrement"></a>
### Incrementar y Decrementar

El generador de consultas también proporciona métodos convenientes para incrementar o decrementar el valor de una columna dada. Ambos métodos aceptan al menos un argumento: la columna a modificar. Se puede proporcionar un segundo argumento para especificar la cantidad por la cual se debe incrementar o decrementar la columna:


```php
DB::table('users')->increment('votes');

DB::table('users')->increment('votes', 5);

DB::table('users')->decrement('votes');

DB::table('users')->decrement('votes', 5);
```
Si es necesario, también puedes especificar columnas adicionales para actualizar durante la operación de incremento o decremento:


```php
DB::table('users')->increment('votes', 1, ['name' => 'John']);
```
Además, puedes incrementar o decrementar múltiples columnas a la vez utilizando los métodos `incrementEach` y `decrementEach`:


```php
DB::table('users')->incrementEach([
    'votes' => 5,
    'balance' => 100,
]);
```

<a name="delete-statements"></a>
## Sentencias de Eliminación

El método `delete` del generador de consultas se puede utilizar para eliminar registros de la tabla. El método `delete` devuelve el número de filas afectadas. Puedes restringir las declaraciones `delete` añadiendo cláusulas "where" antes de llamar al método `delete`:


```php
$deleted = DB::table('users')->delete();

$deleted = DB::table('users')->where('votes', '>', 100)->delete();
```
Si deseas truncar una tabla completa, lo que eliminará todos los registros de la tabla y restablecerá la ID autoincremental a cero, puedes usar el método `truncate`:


```php
DB::table('users')->truncate();
```

<a name="table-truncation-and-postgresql"></a>
#### Truncamiento de Tablas y PostgreSQL

Al truncar una base de datos PostgreSQL, se aplicará el comportamiento `CASCADE`. Esto significa que todos los registros relacionados con claves foráneas en otras tablas también se eliminarán.

<a name="pessimistic-locking"></a>
## Bloqueo Pesimista

El generador de consultas también incluye algunas funciones para ayudarte a lograr un "bloqueo pesimista" al ejecutar tus declaraciones `select`. Para ejecutar una declaración con un "bloqueo compartido", puedes llamar al método `sharedLock`. Un bloqueo compartido evita que las filas seleccionadas sean modificadas hasta que tu transacción sea confirmada:


```php
DB::table('users')
        ->where('votes', '>', 100)
        ->sharedLock()
        ->get();
```
Alternativamente, puedes usar el método `lockForUpdate`. Un bloqueo "para actualizar" evita que los registros seleccionados sean modificados o seleccionados con otro bloqueo compartido:


```php
DB::table('users')
        ->where('votes', '>', 100)
        ->lockForUpdate()
        ->get();
```

<a name="debugging"></a>
## Depuración

Puedes usar los métodos `dd` y `dump` mientras construyes una consulta para mostrar los enlaces de consulta y el SQL actual. El método `dd` mostrará la información de depuración y luego detendrá la ejecución de la solicitud. El método `dump` mostrará la información de depuración pero permitirá que la solicitud continúe ejecutándose:


```php
DB::table('users')->where('votes', '>', 100)->dd();

DB::table('users')->where('votes', '>', 100)->dump();
```
Los métodos `dumpRawSql` y `ddRawSql` se pueden invocar en una consulta para volcar el SQL de la consulta con todos los enlaces de parámetros sustituidos correctamente:


```php
DB::table('users')->where('votes', '>', 100)->dumpRawSql();

DB::table('users')->where('votes', '>', 100)->ddRawSql();
```