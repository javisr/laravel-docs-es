# Base de datos: Constructor de consultas

- [Base de datos: Constructor de consultas](#base-de-datos-constructor-de-consultas)
  - [Introducción](#introducción)
  - [Ejecutando consultas de base de datos](#ejecutando-consultas-de-base-de-datos)
      - [Recuperando todas las filas de una tabla](#recuperando-todas-las-filas-de-una-tabla)
      - [Recuperando una sola fila / columna de una tabla](#recuperando-una-sola-fila--columna-de-una-tabla)
      - [Recuperando una lista de valores de columnas](#recuperando-una-lista-de-valores-de-columnas)
    - [Fragmentando resultados](#fragmentando-resultados)
    - [Transmitiendo resultados de forma perezosa](#transmitiendo-resultados-de-forma-perezosa)
    - [Agregados](#agregados)
      - [Determinando si existen registros](#determinando-si-existen-registros)
  - [Sentencias Select](#sentencias-select)
      - [Especificando una cláusula Select](#especificando-una-cláusula-select)
  - [Expresiones en bruto](#expresiones-en-bruto)
    - [Métodos en bruto](#métodos-en-bruto)
      - [`selectRaw`](#selectraw)
      - [`whereRaw / orWhereRaw`](#whereraw--orwhereraw)
      - [`havingRaw / orHavingRaw`](#havingraw--orhavingraw)
      - [`orderByRaw`](#orderbyraw)
    - [`groupByRaw`](#groupbyraw)
  - [Uniones](#uniones)
      - [Cláusula Inner Join](#cláusula-inner-join)
      - [Cláusula Left Join / Right Join](#cláusula-left-join--right-join)
      - [Cláusula Cross Join](#cláusula-cross-join)
      - [Cláusulas de unión avanzadas](#cláusulas-de-unión-avanzadas)
      - [Uniones de subconsulta](#uniones-de-subconsulta)
      - [Uniones Laterales](#uniones-laterales)
  - [Uniones](#uniones-1)
  - [Cláusulas Where Básicas](#cláusulas-where-básicas)
    - [Cláusulas Where](#cláusulas-where)
    - [Cláusulas Or Where](#cláusulas-or-where)
    - [Cláusulas Where Not](#cláusulas-where-not)
    - [Cláusulas Where Any / All](#cláusulas-where-any--all)
    - [Cláusulas Where JSON](#cláusulas-where-json)
    - [Cláusulas Where Adicionales](#cláusulas-where-adicionales)
    - [Agrupación Lógica](#agrupación-lógica)
    - [Cláusulas Where Avanzadas](#cláusulas-where-avanzadas)
    - [Cláusulas Where Exists](#cláusulas-where-exists)
    - [Cláusulas Where de Subconsulta](#cláusulas-where-de-subconsulta)
    - [Cláusulas Where de Texto Completo](#cláusulas-where-de-texto-completo)
  - [Ordenamiento, Agrupamiento, Límite y Desplazamiento](#ordenamiento-agrupamiento-límite-y-desplazamiento)
    - [Ordenamiento](#ordenamiento)
      - [El Método `orderBy`](#el-método-orderby)
      - [Los Métodos `latest` y `oldest`](#los-métodos-latest-y-oldest)
      - [Ordenamiento Aleatorio](#ordenamiento-aleatorio)
      - [Eliminando Ordenamientos Existentes](#eliminando-ordenamientos-existentes)
    - [Agrupamiento](#agrupamiento)
      - [Los Métodos `groupBy` y `having`](#los-métodos-groupby-y-having)
    - [Límite y Desplazamiento](#límite-y-desplazamiento)
      - [Los Métodos `skip` y `take`](#los-métodos-skip-y-take)
  - [Cláusulas Condicionales](#cláusulas-condicionales)
  - [Declaraciones de Inserción](#declaraciones-de-inserción)
      - [IDs de Auto-Incremento](#ids-de-auto-incremento)
    - [Upserts](#upserts)
  - [Declaraciones de Actualización](#declaraciones-de-actualización)
      - [Actualizar o Insertar](#actualizar-o-insertar)
    - [Actualizando Columnas JSON](#actualizando-columnas-json)
    - [Incrementar y Decrementar](#incrementar-y-decrementar)
  - [Declaraciones de Eliminación](#declaraciones-de-eliminación)
      - [Truncamiento de Tablas y PostgreSQL](#truncamiento-de-tablas-y-postgresql)
  - [Bloqueo Pesimista](#bloqueo-pesimista)
  - [Depuración](#depuración)

<a name="introducción"></a>
## Introducción

El constructor de consultas de base de datos de Laravel proporciona una interfaz fluida y conveniente para crear y ejecutar consultas de base de datos. Se puede utilizar para realizar la mayoría de las operaciones de base de datos en su aplicación y funciona perfectamente con todos los sistemas de base de datos compatibles con Laravel.

El constructor de consultas de Laravel utiliza la vinculación de parámetros PDO para proteger su aplicación contra ataques de inyección SQL. No es necesario limpiar o sanitizar las cadenas pasadas al constructor de consultas como vinculaciones de consulta.

> [!WARNING]  
> PDO no admite la vinculación de nombres de columnas. Por lo tanto, nunca debe permitir que la entrada del usuario dicte los nombres de las columnas referenciadas por sus consultas, incluidas las columnas "order by".

<a name="ejecutando-consultas-de-base-de-datos"></a>
## Ejecutando consultas de base de datos

<a name="recuperando-todas-las-filas-de-una-tabla"></a>
#### Recuperando todas las filas de una tabla

Puede utilizar el método `table` proporcionado por el `DB` facade para comenzar una consulta. El método `table` devuelve una instancia de constructor de consultas fluido para la tabla dada, lo que le permite encadenar más restricciones a la consulta y luego finalmente recuperar los resultados de la consulta utilizando el método `get`:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Support\Facades\DB;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * Mostrar una lista de todos los usuarios de la aplicación.
         */
        public function index(): View
        {
            $users = DB::table('users')->get();

            return view('user.index', ['users' => $users]);
        }
    }

El método `get` devuelve una instancia de `Illuminate\Support\Collection` que contiene los resultados de la consulta donde cada resultado es una instancia del objeto PHP `stdClass`. Puede acceder al valor de cada columna accediendo a la columna como una propiedad del objeto:

    use Illuminate\Support\Facades\DB;

    $users = DB::table('users')->get();

    foreach ($users as $user) {
        echo $user->name;
    }

> [!NOTE]  
> Las colecciones de Laravel proporcionan una variedad de métodos extremadamente potentes para mapear y reducir datos. Para obtener más información sobre las colecciones de Laravel, consulte la [documentación de colecciones](/docs/{{version}}/collections).

<a name="recuperando-una-sola-fila-columna-de-una-tabla"></a>
#### Recuperando una sola fila / columna de una tabla

Si solo necesita recuperar una sola fila de una tabla de base de datos, puede utilizar el método `first` del facade `DB`. Este método devolverá un único objeto `stdClass`:

    $user = DB::table('users')->where('name', 'John')->first();

    return $user->email;

Si no necesita toda una fila, puede extraer un solo valor de un registro utilizando el método `value`. Este método devolverá el valor de la columna directamente:

    $email = DB::table('users')->where('name', 'John')->value('email');

Para recuperar una sola fila por su valor de columna `id`, utilice el método `find`:

    $user = DB::table('users')->find(3);

<a name="recuperando-una-lista-de-valores-de-columnas"></a>
#### Recuperando una lista de valores de columnas

Si desea recuperar una instancia de `Illuminate\Support\Collection` que contenga los valores de una sola columna, puede utilizar el método `pluck`. En este ejemplo, recuperaremos una colección de títulos de usuarios:

    use Illuminate\Support\Facades\DB;

    $titles = DB::table('users')->pluck('title');

    foreach ($titles as $title) {
        echo $title;
    }

Puede especificar la columna que la colección resultante debe usar como sus claves proporcionando un segundo argumento al método `pluck`:

    $titles = DB::table('users')->pluck('title', 'name');

    foreach ($titles as $name => $title) {
        echo $title;
    }

<a name="fragmentando-resultados"></a>
### Fragmentando resultados

Si necesita trabajar con miles de registros de base de datos, considere usar el método `chunk` proporcionado por el `DB` facade. Este método recupera un pequeño fragmento de resultados a la vez y alimenta cada fragmento en una función anónima para su procesamiento. Por ejemplo, recuperemos toda la tabla `users` en fragmentos de 100 registros a la vez:

    use Illuminate\Support\Collection;
    use Illuminate\Support\Facades\DB;

    DB::table('users')->orderBy('id')->chunk(100, function (Collection $users) {
        foreach ($users as $user) {
            // ...
        }
    });

Puede detener el procesamiento de fragmentos adicionales devolviendo `false` desde la función anónima:

    DB::table('users')->orderBy('id')->chunk(100, function (Collection $users) {
        // Procesar los registros...

        return false;
    });

Si está actualizando registros de base de datos mientras fragmenta resultados, sus resultados de fragmentos podrían cambiar de maneras inesperadas. Si planea actualizar los registros recuperados mientras fragmenta, siempre es mejor usar el método `chunkById` en su lugar. Este método paginará automáticamente los resultados según la clave primaria del registro:

    DB::table('users')->where('active', false)
        ->chunkById(100, function (Collection $users) {
            foreach ($users as $user) {
                DB::table('users')
                    ->where('id', $user->id)
                    ->update(['active' => true]);
            }
        });

> [!WARNING]  
> Al actualizar o eliminar registros dentro de la devolución de llamada de fragmento, cualquier cambio en la clave primaria o claves foráneas podría afectar la consulta de fragmento. Esto podría resultar potencialmente en que los registros no se incluyan en los resultados fragmentados.

<a name="transmitiendo-resultados-de-forma-perezosa"></a>
### Transmitiendo resultados de forma perezosa

El método `lazy` funciona de manera similar al [método `chunk`](#fragmentando-resultados) en el sentido de que ejecuta la consulta en fragmentos. Sin embargo, en lugar de pasar cada fragmento a una devolución de llamada, el método `lazy()` devuelve una [`LazyCollection`](/docs/{{version}}/collections#lazy-collections), que le permite interactuar con los resultados como un solo flujo:

```php
use Illuminate\Support\Facades\DB;

DB::table('users')->orderBy('id')->lazy()->each(function (object $user) {
    // ...
});
```

Una vez más, si planea actualizar los registros recuperados mientras itera sobre ellos, es mejor usar los métodos `lazyById` o `lazyByIdDesc` en su lugar. Estos métodos paginarán automáticamente los resultados según la clave primaria del registro:

```php
DB::table('users')->where('active', false)
    ->lazyById()->each(function (object $user) {
        DB::table('users')
            ->where('id', $user->id)
            ->update(['active' => true]);
    });
```

> [!WARNING]  
> Al actualizar o eliminar registros mientras itera sobre ellos, cualquier cambio en la clave primaria o claves foráneas podría afectar la consulta de fragmento. Esto podría resultar potencialmente en que los registros no se incluyan en los resultados.

<a name="agregados"></a>
### Agregados

El constructor de consultas también proporciona una variedad de métodos para recuperar valores agregados como `count`, `max`, `min`, `avg` y `sum`. Puede llamar a cualquiera de estos métodos después de construir su consulta:

    use Illuminate\Support\Facades\DB;

    $users = DB::table('users')->count();

    $price = DB::table('orders')->max('price');

Por supuesto, puede combinar estos métodos con otras cláusulas para afinar cómo se calcula su valor agregado:

    $price = DB::table('orders')
                    ->where('finalized', 1)
                    ->avg('price');

<a name="determinando-si-existen-registros"></a>
#### Determinando si existen registros

En lugar de usar el método `count` para determinar si existen registros que coincidan con las restricciones de su consulta, puede usar los métodos `exists` y `doesntExist`:

    if (DB::table('orders')->where('finalized', 1)->exists()) {
        // ...
    }

    if (DB::table('orders')->where('finalized', 1)->doesntExist()) {
        // ...
    }

<a name="sentencias-select"></a>
## Sentencias Select

<a name="especificando-una-cláusula-select"></a>
#### Especificando una cláusula Select

Es posible que no siempre desee seleccionar todas las columnas de una tabla de base de datos. Usando el método `select`, puede especificar una cláusula "select" personalizada para la consulta:

    use Illuminate\Support\Facades\DB;

    $users = DB::table('users')
                ->select('name', 'email as user_email')
                ->get();

El método `distinct` le permite forzar a la consulta a devolver resultados distintos:

    $users = DB::table('users')->distinct()->get();

Si ya tiene una instancia de constructor de consultas y desea agregar una columna a su cláusula select existente, puede usar el método `addSelect`:

    $query = DB::table('users')->select('name');

    $users = $query->addSelect('age')->get();

<a name="expresiones-en-bruto"></a>
## Expresiones en bruto

A veces puede necesitar insertar una cadena arbitraria en una consulta. Para crear una expresión de cadena en bruto, puede usar el método `raw` proporcionado por el `DB` facade:

    $users = DB::table('users')
                 ->select(DB::raw('count(*) as user_count, status'))
                 ->where('status', '<>', 1)
                 ->groupBy('status')
                 ->get();

> [!WARNING]  
> Las declaraciones en bruto se inyectarán en la consulta como cadenas, por lo que debe tener mucho cuidado para evitar crear vulnerabilidades de inyección SQL.

<a name="métodos-en-bruto"></a>
### Métodos en bruto

En lugar de usar el método `DB::raw`, también puede usar los siguientes métodos para insertar una expresión en bruto en varias partes de su consulta. **Recuerde, Laravel no puede garantizar que ninguna consulta que use expresiones en bruto esté protegida contra vulnerabilidades de inyección SQL.**

<a name="selectraw"></a>
#### `selectRaw`

El método `selectRaw` se puede usar en lugar de `addSelect(DB::raw(/* ... */))`. Este método acepta un array opcional de vinculaciones como su segundo argumento:

    $orders = DB::table('orders')
                    ->selectRaw('price * ? as price_with_tax', [1.0825])
                    ->get();

<a name="whereraw-orwhereraw"></a>
#### `whereRaw / orWhereRaw`

Los métodos `whereRaw` y `orWhereRaw` se pueden usar para inyectar una cláusula "where" en bruto en su consulta. Estos métodos aceptan un array opcional de vinculaciones como su segundo argumento:

    $orders = DB::table('orders')
                    ->whereRaw('price > IF(state = "TX", ?, 100)', [200])
                    ->get();

<a name="havingraw-orhavingraw"></a>
#### `havingRaw / orHavingRaw`

Los métodos `havingRaw` y `orHavingRaw` se pueden usar para proporcionar una cadena en bruto como el valor de la cláusula "having". Estos métodos aceptan un array opcional de vinculaciones como su segundo argumento:

    $orders = DB::table('orders')
                    ->select('department', DB::raw('SUM(price) as total_sales'))
                    ->groupBy('department')
                    ->havingRaw('SUM(price) > ?', [2500])
                    ->get();

<a name="orderbyraw"></a>
#### `orderByRaw`

El método `orderByRaw` se puede usar para proporcionar una cadena en bruto como el valor de la cláusula "order by":

    $orders = DB::table('orders')
                    ->orderByRaw('updated_at - created_at DESC')
                    ->get();

<a name="groupbyraw"></a>
### `groupByRaw`

El método `groupByRaw` se puede usar para proporcionar una cadena en bruto como el valor de la cláusula `group by`:

    $orders = DB::table('orders')
                    ->select('city', 'state')
                    ->groupByRaw('city, state')
                    ->get();

<a name="uniones"></a>
## Uniones

<a name="cláusula-inner-join"></a>
#### Cláusula Inner Join

El constructor de consultas también se puede usar para agregar cláusulas de unión a sus consultas. Para realizar un "inner join" básico, puede usar el método `join` en una instancia de constructor de consultas. El primer argumento pasado al método `join` es el nombre de la tabla a la que necesita unirse, mientras que los argumentos restantes especifican las restricciones de columna para la unión. Incluso puede unir múltiples tablas en una sola consulta:

    use Illuminate\Support\Facades\DB;

    $users = DB::table('users')
                ->join('contacts', 'users.id', '=', 'contacts.user_id')
                ->join('orders', 'users.id', '=', 'orders.user_id')
                ->select('users.*', 'contacts.phone', 'orders.price')
                ->get();

<a name="cláusula-left-join-right-join"></a>
#### Cláusula Left Join / Right Join

Si desea realizar un "left join" o "right join" en lugar de un "inner join", use los métodos `leftJoin` o `rightJoin`. Estos métodos tienen la misma firma que el método `join`:

    $users = DB::table('users')
                ->leftJoin('posts', 'users.id', '=', 'posts.user_id')
                ->get();

    $users = DB::table('users')
                ->rightJoin('posts', 'users.id', '=', 'posts.user_id')
                ->get();

<a name="cláusula-cross-join"></a>
#### Cláusula Cross Join

Puede usar el método `crossJoin` para realizar un "cross join". Los cross joins generan un producto cartesiano entre la primera tabla y la tabla unida:

    $sizes = DB::table('sizes')
                ->crossJoin('colors')
                ->get();

<a name="cláusulas-de-unión-avanzadas"></a>
#### Cláusulas de unión avanzadas

También puede especificar cláusulas de unión más avanzadas. Para comenzar, pase una función anónima como el segundo argumento al método `join`. La función anónima recibirá una instancia de `Illuminate\Database\Query\JoinClause` que le permite especificar restricciones en la cláusula "join":

    DB::table('users')
            ->join('contacts', function (JoinClause $join) {
                $join->on('users.id', '=', 'contacts.user_id')->orOn(/* ... */);
            })
            ->get();

Si desea usar una cláusula "where" en sus uniones, puede usar los métodos `where` y `orWhere` proporcionados por la instancia `JoinClause`. En lugar de comparar dos columnas, estos métodos compararán la columna con un valor:

    DB::table('users')
            ->join('contacts', function (JoinClause $join) {
                $join->on('users.id', '=', 'contacts.user_id')
                     ->where('contacts.user_id', '>', 5);
            })
            ->get();

<a name="uniones-de-subconsulta"></a>
#### Uniones de subconsulta

Puede usar los métodos `joinSub`, `leftJoinSub` y `rightJoinSub` para unir una consulta a una subconsulta. Cada uno de estos métodos recibe tres argumentos: la subconsulta, su alias de tabla y una función anónima que define las columnas relacionadas. En este ejemplo, recuperaremos una colección de usuarios donde cada registro de usuario también contiene la marca de tiempo `created_at` de la publicación de blog más recientemente publicada del usuario:

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
#### Uniones Laterales

> [!WARNING]  
> Las uniones laterales son actualmente compatibles con PostgreSQL, MySQL >= 8.0.14 y SQL Server.

Puede usar los métodos `joinLateral` y `leftJoinLateral` para realizar una "unión lateral" con una subconsulta. Cada uno de estos métodos recibe dos argumentos: la subconsulta y su alias de tabla. Las condiciones de unión deben especificarse dentro de la cláusula `where` de la subconsulta dada. Las uniones laterales se evalúan para cada fila y pueden hacer referencia a columnas fuera de la subconsulta.

En este ejemplo, recuperaremos una colección de usuarios así como las tres publicaciones de blog más recientes del usuario. Cada usuario puede producir hasta tres filas en el conjunto de resultados: una para cada una de sus publicaciones de blog más recientes. La condición de unión se especifica con una cláusula `whereColumn` dentro de la subconsulta, haciendo referencia a la fila del usuario actual:

    $latestPosts = DB::table('posts')
                       ->select('id as post_id', 'title as post_title', 'created_at as post_created_at')
                       ->whereColumn('user_id', 'users.id')
                       ->orderBy('created_at', 'desc')
                       ->limit(3);

    $users = DB::table('users')
                ->joinLateral($latestPosts, 'latest_posts')
                ->get();

<a name="unions"></a>
## Uniones

El constructor de consultas también proporciona un método conveniente para "unir" dos o más consultas. Por ejemplo, puede crear una consulta inicial y usar el método `union` para unirla con más consultas:

    use Illuminate\Support\Facades\DB;

    $first = DB::table('users')
                ->whereNull('first_name');

    $users = DB::table('users')
                ->whereNull('last_name')
                ->union($first)
                ->get();

Además del método `union`, el constructor de consultas proporciona un método `unionAll`. Las consultas que se combinan utilizando el método `unionAll` no tendrán sus resultados duplicados eliminados. El método `unionAll` tiene la misma firma de método que el método `union`.

<a name="basic-where-clauses"></a>
## Cláusulas Where Básicas

<a name="where-clauses"></a>
### Cláusulas Where

Puede usar el método `where` del constructor de consultas para agregar cláusulas "where" a la consulta. La llamada más básica al método `where` requiere tres argumentos. El primer argumento es el nombre de la columna. El segundo argumento es un operador, que puede ser cualquiera de los operadores admitidos por la base de datos. El tercer argumento es el valor con el que comparar el valor de la columna.

Por ejemplo, la siguiente consulta recupera usuarios donde el valor de la columna `votes` es igual a `100` y el valor de la columna `age` es mayor que `35`:

    $users = DB::table('users')
                    ->where('votes', '=', 100)
                    ->where('age', '>', 35)
                    ->get();

Para conveniencia, si desea verificar que una columna es `=` a un valor dado, puede pasar el valor como el segundo argumento al método `where`. Laravel asumirá que desea usar el operador `=`:

    $users = DB::table('users')->where('votes', 100)->get();

Como se mencionó anteriormente, puede usar cualquier operador que sea compatible con su sistema de base de datos:

    $users = DB::table('users')
                    ->where('votes', '>=', 100)
                    ->get();

    $users = DB::table('users')
                    ->where('votes', '<>', 100)
                    ->get();

    $users = DB::table('users')
                    ->where('name', 'like', 'T%')
                    ->get();

También puede pasar un array de condiciones a la función `where`. Cada elemento del array debe ser un array que contenga los tres argumentos que normalmente se pasan al método `where`:

    $users = DB::table('users')->where([
        ['status', '=', '1'],
        ['subscribed', '<>', '1'],
    ])->get();

> [!WARNING]  
> PDO no admite la vinculación de nombres de columnas. Por lo tanto, nunca debe permitir que la entrada del usuario dicte los nombres de las columnas referenciadas por sus consultas, incluidas las columnas "order by".

<a name="or-where-clauses"></a>
### Cláusulas Or Where

Al encadenar llamadas al método `where` del constructor de consultas, las cláusulas "where" se unirán utilizando el operador `and`. Sin embargo, puede usar el método `orWhere` para unir una cláusula a la consulta utilizando el operador `or`. El método `orWhere` acepta los mismos argumentos que el método `where`:

    $users = DB::table('users')
                        ->where('votes', '>', 100)
                        ->orWhere('name', 'John')
                        ->get();

Si necesita agrupar una condición "or" dentro de paréntesis, puede pasar una función anónima como el primer argumento al método `orWhere`:

    $users = DB::table('users')
                ->where('votes', '>', 100)
                ->orWhere(function (Builder $query) {
                    $query->where('name', 'Abigail')
                          ->where('votes', '>', 50);
                })
                ->get();

El ejemplo anterior producirá el siguiente SQL:

```sql
select * from users where votes > 100 or (name = 'Abigail' and votes > 50)
```

> [!WARNING]  
> Siempre debe agrupar las llamadas a `orWhere` para evitar comportamientos inesperados cuando se aplican scopes globales.

<a name="where-not-clauses"></a>
### Cláusulas Where Not

Los métodos `whereNot` y `orWhereNot` pueden usarse para negar un grupo dado de restricciones de consulta. Por ejemplo, la siguiente consulta excluye productos que están en liquidación o que tienen un precio inferior a diez:

    $products = DB::table('products')
                    ->whereNot(function (Builder $query) {
                        $query->where('clearance', true)
                              ->orWhere('price', '<', 10);
                    })
                    ->get();

<a name="where-any-all-clauses"></a>
### Cláusulas Where Any / All

A veces puede necesitar aplicar las mismas restricciones de consulta a múltiples columnas. Por ejemplo, puede querer recuperar todos los registros donde cualquier columna en una lista dada sea `LIKE` un valor dado. Puede lograr esto utilizando el método `whereAny`:

    $users = DB::table('users')
                ->where('active', true)
                ->whereAny([
                    'name',
                    'email',
                    'phone',
                ], 'like', 'Example%')
                ->get();

La consulta anterior resultará en el siguiente SQL:

```sql
SELECT *
FROM users
WHERE active = true AND (
    name LIKE 'Example%' OR
    email LIKE 'Example%' OR
    phone LIKE 'Example%'
)
```

De manera similar, el método `whereAll` puede usarse para recuperar registros donde todas las columnas dadas coincidan con una restricción dada:

    $posts = DB::table('posts')
                ->where('published', true)
                ->whereAll([
                    'title',
                    'content',
                ], 'like', '%Laravel%')
                ->get();

La consulta anterior resultará en el siguiente SQL:

```sql
SELECT *
FROM posts
WHERE published = true AND (
    title LIKE '%Laravel%' AND
    content LIKE '%Laravel%'
)
```

<a name="json-where-clauses"></a>
### Cláusulas Where JSON

Laravel también admite la consulta de tipos de columna JSON en bases de datos que proporcionan soporte para tipos de columna JSON. Actualmente, esto incluye MariaDB 10.3+, MySQL 8.0+, PostgreSQL 12.0+, SQL Server 2017+ y SQLite 3.39.0+. Para consultar una columna JSON, use el operador `->`:

    $users = DB::table('users')
                    ->where('preferences->dining->meal', 'salad')
                    ->get();

Puede usar `whereJsonContains` para consultar arreglos JSON:

    $users = DB::table('users')
                    ->whereJsonContains('options->languages', 'en')
                    ->get();

Si su aplicación utiliza las bases de datos MariaDB, MySQL o PostgreSQL, puede pasar un array de valores al método `whereJsonContains`:

    $users = DB::table('users')
                    ->whereJsonContains('options->languages', ['en', 'de'])
                    ->get();

Puede usar el método `whereJsonLength` para consultar arreglos JSON por su longitud:

    $users = DB::table('users')
                    ->whereJsonLength('options->languages', 0)
                    ->get();

    $users = DB::table('users')
                    ->whereJsonLength('options->languages', '>', 1)
                    ->get();

<a name="additional-where-clauses"></a>
### Cláusulas Where Adicionales

**whereLike / orWhereLike / whereNotLike / orWhereNotLike**

El método `whereLike` le permite agregar cláusulas "LIKE" a su consulta para coincidencias de patrones. Estos métodos proporcionan una forma independiente de la base de datos para realizar consultas de coincidencia de cadenas, con la capacidad de alternar la sensibilidad a mayúsculas y minúsculas. Por defecto, la coincidencia de cadenas no distingue entre mayúsculas y minúsculas:

    $users = DB::table('users')
               ->whereLike('name', '%John%')
               ->get();

Puede habilitar una búsqueda sensible a mayúsculas y minúsculas a través del argumento `caseSensitive`:

    $users = DB::table('users')
               ->whereLike('name', '%John%', caseSensitive: true)
               ->get();

El método `orWhereLike` le permite agregar una cláusula "or" con una condición LIKE:

    $users = DB::table('users')
               ->where('votes', '>', 100)
               ->orWhereLike('name', '%John%')
               ->get();

El método `whereNotLike` le permite agregar cláusulas "NOT LIKE" a su consulta:

    $users = DB::table('users')
               ->whereNotLike('name', '%John%')
               ->get();

De manera similar, puede usar `orWhereNotLike` para agregar una cláusula "or" con una condición NOT LIKE:

    $users = DB::table('users')
               ->where('votes', '>', 100)
               ->orWhereNotLike('name', '%John%')
               ->get();

> [!WARNING]
> La opción de búsqueda sensible a mayúsculas y minúsculas del `whereLike` actualmente no es compatible con SQL Server.

**whereIn / whereNotIn / orWhereIn / orWhereNotIn**

El método `whereIn` verifica que el valor de una columna dada esté contenido dentro del array dado:

    $users = DB::table('users')
                        ->whereIn('id', [1, 2, 3])
                        ->get();

El método `whereNotIn` verifica que el valor de la columna dada no esté contenido en el array dado:

    $users = DB::table('users')
                        ->whereNotIn('id', [1, 2, 3])
                        ->get();

También puede proporcionar un objeto de consulta como el segundo argumento del método `whereIn`:

    $activeUsers = DB::table('users')->select('id')->where('is_active', 1);

    $users = DB::table('comments')
                        ->whereIn('user_id', $activeUsers)
                        ->get();

El ejemplo anterior producirá el siguiente SQL:

```sql
select * from comments where user_id in (
    select id
    from users
    where is_active = 1
)
```

> [!WARNING]  
> Si está agregando un gran array de vinculaciones de enteros a su consulta, los métodos `whereIntegerInRaw` o `whereIntegerNotInRaw` pueden usarse para reducir significativamente el uso de memoria.

**whereBetween / orWhereBetween**

El método `whereBetween` verifica que el valor de una columna esté entre dos valores:

    $users = DB::table('users')
               ->whereBetween('votes', [1, 100])
               ->get();

**whereNotBetween / orWhereNotBetween**

El método `whereNotBetween` verifica que el valor de una columna esté fuera de dos valores:

    $users = DB::table('users')
                        ->whereNotBetween('votes', [1, 100])
                        ->get();

**whereBetweenColumns / whereNotBetweenColumns / orWhereBetweenColumns / orWhereNotBetweenColumns**

El método `whereBetweenColumns` verifica que el valor de una columna esté entre los dos valores de dos columnas en la misma fila de la tabla:

    $patients = DB::table('patients')
                           ->whereBetweenColumns('weight', ['minimum_allowed_weight', 'maximum_allowed_weight'])
                           ->get();

El método `whereNotBetweenColumns` verifica que el valor de una columna esté fuera de los dos valores de dos columnas en la misma fila de la tabla:

    $patients = DB::table('patients')
                           ->whereNotBetweenColumns('weight', ['minimum_allowed_weight', 'maximum_allowed_weight'])
                           ->get();

**whereNull / whereNotNull / orWhereNull / orWhereNotNull**

El método `whereNull` verifica que el valor de la columna dada sea `NULL`:

    $users = DB::table('users')
                    ->whereNull('updated_at')
                    ->get();

El método `whereNotNull` verifica que el valor de la columna no sea `NULL`:

    $users = DB::table('users')
                    ->whereNotNull('updated_at')
                    ->get();

**whereDate / whereMonth / whereDay / whereYear / whereTime**

El método `whereDate` puede usarse para comparar el valor de una columna con una fecha:

    $users = DB::table('users')
                    ->whereDate('created_at', '2016-12-31')
                    ->get();

El método `whereMonth` puede usarse para comparar el valor de una columna con un mes específico:

    $users = DB::table('users')
                    ->whereMonth('created_at', '12')
                    ->get();

El método `whereDay` puede usarse para comparar el valor de una columna con un día específico del mes:

    $users = DB::table('users')
                    ->whereDay('created_at', '31')
                    ->get();

El método `whereYear` puede usarse para comparar el valor de una columna con un año específico:

    $users = DB::table('users')
                    ->whereYear('created_at', '2016')
                    ->get();

El método `whereTime` puede usarse para comparar el valor de una columna con un tiempo específico:

    $users = DB::table('users')
                    ->whereTime('created_at', '=', '11:20:45')
                    ->get();

**whereColumn / orWhereColumn**

El método `whereColumn` puede usarse para verificar que dos columnas sean iguales:

    $users = DB::table('users')
                    ->whereColumn('first_name', 'last_name')
                    ->get();

También puede pasar un operador de comparación al método `whereColumn`:

    $users = DB::table('users')
                    ->whereColumn('updated_at', '>', 'created_at')
                    ->get();

También puede pasar un array de comparaciones de columnas al método `whereColumn`. Estas condiciones se unirán utilizando el operador `and`:

    $users = DB::table('users')
                    ->whereColumn([
                        ['first_name', '=', 'last_name'],
                        ['updated_at', '>', 'created_at'],
                    ])->get();

<a name="logical-grouping"></a>
### Agrupación Lógica

A veces puede necesitar agrupar varias cláusulas "where" dentro de paréntesis para lograr la agrupación lógica deseada de su consulta. De hecho, generalmente debe agrupar siempre las llamadas al método `orWhere` entre paréntesis para evitar comportamientos inesperados en la consulta. Para lograr esto, puede pasar una función anónima al método `where`:

    $users = DB::table('users')
               ->where('name', '=', 'John')
               ->where(function (Builder $query) {
                   $query->where('votes', '>', 100)
                         ->orWhere('title', '=', 'Admin');
               })
               ->get();

Como puede ver, pasar una función anónima al método `where` instruye al constructor de consultas para comenzar un grupo de restricciones. La función anónima recibirá una instancia del constructor de consultas que puede usar para establecer las restricciones que deben estar contenidas dentro del grupo de paréntesis. El ejemplo anterior producirá el siguiente SQL:
```

```sql
select * from users where name = 'John' and (votes > 100 or title = 'Admin')
```

> [!WARNING]  
> Siempre debes agrupar las llamadas a `orWhere` para evitar comportamientos inesperados cuando se aplican scopes globales.

<a name="advanced-where-clauses"></a>
### Cláusulas Where Avanzadas

<a name="where-exists-clauses"></a>
### Cláusulas Where Exists

El método `whereExists` te permite escribir cláusulas SQL de "where exists". El método `whereExists` acepta una función anónima que recibirá una instancia de query builder, lo que te permite definir la consulta que debe colocarse dentro de la cláusula "exists":

    $users = DB::table('users')
               ->whereExists(function (Builder $query) {
                   $query->select(DB::raw(1))
                         ->from('orders')
                         ->whereColumn('orders.user_id', 'users.id');
               })
               ->get();

Alternativamente, puedes proporcionar un objeto de consulta al método `whereExists` en lugar de una función anónima:

    $orders = DB::table('orders')
                    ->select(DB::raw(1))
                    ->whereColumn('orders.user_id', 'users.id');

    $users = DB::table('users')
                        ->whereExists($orders)
                        ->get();

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

A veces, es posible que necesites construir una cláusula "where" que compare los resultados de una subconsulta con un valor dado. Puedes lograr esto pasando una función anónima y un valor al método `where`. Por ejemplo, la siguiente consulta recuperará todos los usuarios que tienen una "membresía" reciente de un tipo dado;

    use App\Models\User;
    use Illuminate\Database\Query\Builder;

    $users = User::where(function (Builder $query) {
        $query->select('type')
            ->from('membership')
            ->whereColumn('membership.user_id', 'users.id')
            ->orderByDesc('membership.start_date')
            ->limit(1);
    }, 'Pro')->get();

O, es posible que necesites construir una cláusula "where" que compare una columna con los resultados de una subconsulta. Puedes lograr esto pasando una columna, operador y función anónima al método `where`. Por ejemplo, la siguiente consulta recuperará todos los registros de ingresos donde el monto es menor que el promedio;

    use App\Models\Income;
    use Illuminate\Database\Query\Builder;

    $incomes = Income::where('amount', '<', function (Builder $query) {
        $query->selectRaw('avg(i.amount)')->from('incomes as i');
    })->get();

<a name="full-text-where-clauses"></a>
### Cláusulas Where de Texto Completo

> [!WARNING]  
> Las cláusulas where de texto completo son actualmente compatibles con MariaDB, MySQL y PostgreSQL.

Los métodos `whereFullText` y `orWhereFullText` pueden ser utilizados para agregar cláusulas "where" de texto completo a una consulta para columnas que tienen [índices de texto completo](/docs/{{version}}/migrations#available-index-types). Estos métodos serán transformados en el SQL apropiado para el sistema de base de datos subyacente por Laravel. Por ejemplo, se generará una cláusula `MATCH AGAINST` para aplicaciones que utilizan MariaDB o MySQL:

    $users = DB::table('users')
               ->whereFullText('bio', 'web developer')
               ->get();

<a name="ordering-grouping-limit-and-offset"></a>
## Ordenamiento, Agrupamiento, Límite y Desplazamiento

<a name="ordering"></a>
### Ordenamiento

<a name="orderby"></a>
#### El Método `orderBy`

El método `orderBy` te permite ordenar los resultados de la consulta por una columna dada. El primer argumento aceptado por el método `orderBy` debe ser la columna por la que deseas ordenar, mientras que el segundo argumento determina la dirección de la ordenación y puede ser `asc` o `desc`:

    $users = DB::table('users')
                    ->orderBy('name', 'desc')
                    ->get();

Para ordenar por múltiples columnas, simplemente puedes invocar `orderBy` tantas veces como sea necesario:

    $users = DB::table('users')
                    ->orderBy('name', 'desc')
                    ->orderBy('email', 'asc')
                    ->get();

<a name="latest-oldest"></a>
#### Los Métodos `latest` y `oldest`

Los métodos `latest` y `oldest` te permiten ordenar fácilmente los resultados por fecha. Por defecto, el resultado será ordenado por la columna `created_at` de la tabla. O, puedes pasar el nombre de la columna por la que deseas ordenar:

    $user = DB::table('users')
                    ->latest()
                    ->first();

<a name="random-ordering"></a>
#### Ordenamiento Aleatorio

El método `inRandomOrder` puede ser utilizado para ordenar los resultados de la consulta de manera aleatoria. Por ejemplo, puedes usar este método para obtener un usuario aleatorio:

    $randomUser = DB::table('users')
                    ->inRandomOrder()
                    ->first();

<a name="removing-existing-orderings"></a>
#### Eliminando Ordenamientos Existentes

El método `reorder` elimina todas las cláusulas "order by" que se han aplicado previamente a la consulta:

    $query = DB::table('users')->orderBy('name');

    $unorderedUsers = $query->reorder()->get();

Puedes pasar una columna y dirección al llamar al método `reorder` para eliminar todas las cláusulas "order by" existentes y aplicar un nuevo orden a la consulta:

    $query = DB::table('users')->orderBy('name');

    $usersOrderedByEmail = $query->reorder('email', 'desc')->get();

<a name="grouping"></a>
### Agrupamiento

<a name="groupby-having"></a>
#### Los Métodos `groupBy` y `having`

Como puedes esperar, los métodos `groupBy` y `having` pueden ser utilizados para agrupar los resultados de la consulta. La firma del método `having` es similar a la del método `where`:

    $users = DB::table('users')
                    ->groupBy('account_id')
                    ->having('account_id', '>', 100)
                    ->get();

Puedes usar el método `havingBetween` para filtrar los resultados dentro de un rango dado:

    $report = DB::table('orders')
                    ->selectRaw('count(id) as number_of_orders, customer_id')
                    ->groupBy('customer_id')
                    ->havingBetween('number_of_orders', [5, 15])
                    ->get();

Puedes pasar múltiples argumentos al método `groupBy` para agrupar por múltiples columnas:

    $users = DB::table('users')
                    ->groupBy('first_name', 'status')
                    ->having('account_id', '>', 100)
                    ->get();

Para construir declaraciones `having` más avanzadas, consulta el método [`havingRaw`](#raw-methods).

<a name="limit-and-offset"></a>
### Límite y Desplazamiento

<a name="skip-take"></a>
#### Los Métodos `skip` y `take`

Puedes usar los métodos `skip` y `take` para limitar el número de resultados devueltos de la consulta o para omitir un número dado de resultados en la consulta:

    $users = DB::table('users')->skip(10)->take(5)->get();

Alternativamente, puedes usar los métodos `limit` y `offset`. Estos métodos son funcionalmente equivalentes a los métodos `take` y `skip`, respectivamente:

    $users = DB::table('users')
                    ->offset(10)
                    ->limit(5)
                    ->get();

<a name="conditional-clauses"></a>
## Cláusulas Condicionales

A veces, es posible que desees que ciertas cláusulas de consulta se apliquen a una consulta en función de otra condición. Por ejemplo, es posible que solo desees aplicar una declaración `where` si un valor de entrada dado está presente en la solicitud HTTP entrante. Puedes lograr esto utilizando el método `when`:

    $role = $request->string('role');

    $users = DB::table('users')
                    ->when($role, function (Builder $query, string $role) {
                        $query->where('role_id', $role);
                    })
                    ->get();

El método `when` solo ejecuta la función anónima dada cuando el primer argumento es `true`. Si el primer argumento es `false`, la función anónima no se ejecutará. Así que, en el ejemplo anterior, la función anónima dada al método `when` solo se invocará si el campo `role` está presente en la solicitud entrante y evalúa a `true`.

Puedes pasar otra función anónima como el tercer argumento al método `when`. Esta función anónima solo se ejecutará si el primer argumento evalúa como `false`. Para ilustrar cómo se puede usar esta característica, la utilizaremos para configurar el ordenamiento predeterminado de una consulta:

    $sortByVotes = $request->boolean('sort_by_votes');

    $users = DB::table('users')
                    ->when($sortByVotes, function (Builder $query, bool $sortByVotes) {
                        $query->orderBy('votes');
                    }, function (Builder $query) {
                        $query->orderBy('name');
                    })
                    ->get();

<a name="insert-statements"></a>
## Declaraciones de Inserción

El constructor de consultas también proporciona un método `insert` que puede ser utilizado para insertar registros en la tabla de la base de datos. El método `insert` acepta un array de nombres de columnas y valores:

    DB::table('users')->insert([
        'email' => 'kayla@example.com',
        'votes' => 0
    ]);

Puedes insertar varios registros a la vez pasando un array de arrays. Cada array representa un registro que debe ser insertado en la tabla:

    DB::table('users')->insert([
        ['email' => 'picard@example.com', 'votes' => 0],
        ['email' => 'janeway@example.com', 'votes' => 0],
    ]);

El método `insertOrIgnore` ignorará errores mientras inserta registros en la base de datos. Al usar este método, debes tener en cuenta que los errores de registros duplicados serán ignorados y otros tipos de errores también pueden ser ignorados dependiendo del motor de base de datos. Por ejemplo, `insertOrIgnore` [eludirá el modo estricto de MySQL](https://dev.mysql.com/doc/refman/en/sql-mode.html#ignore-effect-on-execution):

    DB::table('users')->insertOrIgnore([
        ['id' => 1, 'email' => 'sisko@example.com'],
        ['id' => 2, 'email' => 'archer@example.com'],
    ]);

El método `insertUsing` insertará nuevos registros en la tabla mientras utiliza una subconsulta para determinar los datos que deben ser insertados:

    DB::table('pruned_users')->insertUsing([
        'id', 'name', 'email', 'email_verified_at'
    ], DB::table('users')->select(
        'id', 'name', 'email', 'email_verified_at'
    )->where('updated_at', '<=', now()->subMonth()));

<a name="auto-incrementing-ids"></a>
#### IDs de Auto-Incremento

Si la tabla tiene un id de auto-incremento, usa el método `insertGetId` para insertar un registro y luego recuperar el ID:

    $id = DB::table('users')->insertGetId(
        ['email' => 'john@example.com', 'votes' => 0]
    );

> [!WARNING]  
> Al usar PostgreSQL, el método `insertGetId` espera que la columna de auto-incremento se llame `id`. Si deseas recuperar el ID de una "secuencia" diferente, puedes pasar el nombre de la columna como segundo parámetro al método `insertGetId`.

<a name="upserts"></a>
### Upserts

El método `upsert` insertará registros que no existen y actualizará los registros que ya existen con nuevos valores que puedes especificar. El primer argumento del método consiste en los valores a insertar o actualizar, mientras que el segundo argumento enumera las columnas que identifican de manera única los registros dentro de la tabla asociada. El tercer y último argumento del método es un array de columnas que deben ser actualizadas si ya existe un registro coincidente en la base de datos:

    DB::table('flights')->upsert(
        [
            ['departure' => 'Oakland', 'destination' => 'San Diego', 'price' => 99],
            ['departure' => 'Chicago', 'destination' => 'New York', 'price' => 150]
        ],
        ['departure', 'destination'],
        ['price']
    );

En el ejemplo anterior, Laravel intentará insertar dos registros. Si ya existe un registro con los mismos valores de columna `departure` y `destination`, Laravel actualizará la columna `price` de ese registro.

> [!WARNING]  
> Todas las bases de datos excepto SQL Server requieren que las columnas en el segundo argumento del método `upsert` tengan un índice "primario" o "único". Además, los controladores de base de datos de MariaDB y MySQL ignoran el segundo argumento del método `upsert` y siempre utilizan los índices "primarios" y "únicos" de la tabla para detectar registros existentes.

<a name="update-statements"></a>
## Declaraciones de Actualización

Además de insertar registros en la base de datos, el constructor de consultas también puede actualizar registros existentes utilizando el método `update`. El método `update`, al igual que el método `insert`, acepta un array de pares de columnas y valores que indican las columnas a actualizar. El método `update` devuelve el número de filas afectadas. Puedes restringir la consulta `update` utilizando cláusulas `where`:

    $affected = DB::table('users')
                  ->where('id', 1)
                  ->update(['votes' => 1]);

<a name="update-or-insert"></a>
#### Actualizar o Insertar

A veces, es posible que desees actualizar un registro existente en la base de datos o crearlo si no existe un registro coincidente. En este escenario, se puede utilizar el método `updateOrInsert`. El método `updateOrInsert` acepta dos argumentos: un array de condiciones para encontrar el registro y un array de pares de columnas y valores que indican las columnas a actualizar.

El método `updateOrInsert` intentará localizar un registro de base de datos coincidente utilizando los pares de columnas y valores del primer argumento. Si el registro existe, se actualizará con los valores del segundo argumento. Si no se puede encontrar el registro, se insertará un nuevo registro con los atributos combinados de ambos argumentos:

    DB::table('users')
        ->updateOrInsert(
            ['email' => 'john@example.com', 'name' => 'John'],
            ['votes' => '2']
        );

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
### Actualizando Columnas JSON

Al actualizar una columna JSON, debes usar la sintaxis `->` para actualizar la clave apropiada en el objeto JSON. Esta operación es compatible con MariaDB 10.3+, MySQL 5.7+ y PostgreSQL 9.5+:

    $affected = DB::table('users')
                  ->where('id', 1)
                  ->update(['options->enabled' => true]);

<a name="increment-and-decrement"></a>
### Incrementar y Decrementar

El constructor de consultas también proporciona métodos convenientes para incrementar o decrementar el valor de una columna dada. Ambos métodos aceptan al menos un argumento: la columna a modificar. Se puede proporcionar un segundo argumento para especificar la cantidad por la cual se debe incrementar o decrementar la columna:

    DB::table('users')->increment('votes');

    DB::table('users')->increment('votes', 5);

    DB::table('users')->decrement('votes');

    DB::table('users')->decrement('votes', 5);

Si es necesario, también puedes especificar columnas adicionales para actualizar durante la operación de incremento o decremento:

    DB::table('users')->increment('votes', 1, ['name' => 'John']);

Además, puedes incrementar o decrementar múltiples columnas a la vez utilizando los métodos `incrementEach` y `decrementEach`:

    DB::table('users')->incrementEach([
        'votes' => 5,
        'balance' => 100,
    ]);

<a name="delete-statements"></a>
## Declaraciones de Eliminación

El método `delete` del constructor de consultas puede ser utilizado para eliminar registros de la tabla. El método `delete` devuelve el número de filas afectadas. Puedes restringir las declaraciones `delete` agregando cláusulas "where" antes de llamar al método `delete`:

    $deleted = DB::table('users')->delete();

    $deleted = DB::table('users')->where('votes', '>', 100)->delete();


Si deseas truncar una tabla completa, lo que eliminará todos los registros de la tabla y restablecerá el ID autoincremental a cero, puedes usar el método `truncate`:

    DB::table('users')->truncate();

<a name="table-truncation-and-postgresql"></a>
#### Truncamiento de Tablas y PostgreSQL

Al truncar una base de datos PostgreSQL, se aplicará el comportamiento `CASCADE`. Esto significa que todos los registros relacionados con claves foráneas en otras tablas también serán eliminados.

<a name="pessimistic-locking"></a>
## Bloqueo Pesimista

El generador de consultas también incluye algunas funciones para ayudarte a lograr "bloqueo pesimista" al ejecutar tus declaraciones `select`. Para ejecutar una declaración con un "bloqueo compartido", puedes llamar al método `sharedLock`. Un bloqueo compartido evita que las filas seleccionadas sean modificadas hasta que tu transacción sea confirmada:

    DB::table('users')
            ->where('votes', '>', 100)
            ->sharedLock()
            ->get();

Alternativamente, puedes usar el método `lockForUpdate`. Un bloqueo "para actualización" evita que los registros seleccionados sean modificados o seleccionados con otro bloqueo compartido:

    DB::table('users')
            ->where('votes', '>', 100)
            ->lockForUpdate()
            ->get();

<a name="debugging"></a>
## Depuración

Puedes usar los métodos `dd` y `dump` mientras construyes una consulta para volcar los enlaces de consulta actuales y SQL. El método `dd` mostrará la información de depuración y luego detendrá la ejecución de la solicitud. El método `dump` mostrará la información de depuración pero permitirá que la solicitud continúe ejecutándose:

    DB::table('users')->where('votes', '>', 100)->dd();

    DB::table('users')->where('votes', '>', 100)->dump();

Los métodos `dumpRawSql` y `ddRawSql` pueden ser invocados en una consulta para volcar el SQL de la consulta con todos los enlaces de parámetros debidamente sustituidos:

    DB::table('users')->where('votes', '>', 100)->dumpRawSql();

    DB::table('users')->where('votes', '>', 100)->ddRawSql();
