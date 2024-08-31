# Ayudantes

- [Introducción](#introduction)
- [Métodos Disponibles](#available-methods)
- [Otras Utilidades](#other-utilities)
  - [Benchmarking](#benchmarking)
  - [Fechas](#dates)
  - [Lotería](#lottery)
  - [Pipeline](#pipeline)
  - [Sleep](#sleep)

<a name="introduction"></a>
## Introducción

Laravel incluye una variedad de funciones PHP "helper" globales. Muchas de estas funciones son utilizadas por el propio framework; sin embargo, puedes usarlas en tus propias aplicaciones si te resultan convenientes.

<a name="available-methods"></a>
## Métodos Disponibles

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
</style>

<a name="arrays-and-objects-method-list"></a>
### Arrays y Objetos

<div class="collection-method-list" markdown="1">

[Arr::accessible](#method-array-accessible)
[Arr::add](#method-array-add)
[Arr::collapse](#method-array-collapse)
[Arr::crossJoin](#method-array-crossjoin)
[Arr::divide](#method-array-divide)
[Arr::dot](#method-array-dot)
[Arr::except](#method-array-except)
[Arr::exists](#method-array-exists)
[Arr::first](#method-array-first)
[Arr::flatten](#method-array-flatten)
[Arr::forget](#method-array-forget)
[Arr::get](#method-array-get)
[Arr::has](#method-array-has)
[Arr::hasAny](#method-array-hasany)
[Arr::isAssoc](#method-array-isassoc)
[Arr::isList](#method-array-islist)
[Arr::join](#method-array-join)
[Arr::keyBy](#method-array-keyby)
[Arr::last](#method-array-last)
[Arr::map](#method-array-map)
[Arr::mapSpread](#method-array-map-spread)
[Arr::mapWithKeys](#method-array-map-with-keys)
[Arr::only](#method-array-only)
[Arr::pluck](#method-array-pluck)
[Arr::prepend](#method-array-prepend)
[Arr::prependKeysWith](#method-array-prependkeyswith)
[Arr::pull](#method-array-pull)
[Arr::query](#method-array-query)
[Arr::random](#method-array-random)
[Arr::set](#method-array-set)
[Arr::shuffle](#method-array-shuffle)
[Arr::sort](#method-array-sort)
[Arr::sortDesc](#method-array-sort-desc)
[Arr::sortRecursive](#method-array-sort-recursive)
[Arr::take](#method-array-take)
[Arr::toCssClasses](#method-array-to-css-classes)
[Arr::toCssStyles](#method-array-to-css-styles)
[Arr::undot](#method-array-undot)
[Arr::where](#method-array-where)
[Arr::whereNotNull](#method-array-where-not-null)
[Arr::wrap](#method-array-wrap)
[data_fill](#method-data-fill)
[data_get](#method-data-get)
[data_set](#method-data-set)
[data_forget](#method-data-forget)
[head](#method-head)
[last](#method-last)

</div>

<a name="numbers-method-list"></a>
### Números

<div class="collection-method-list" markdown="1">

[Number::abbreviate](#method-number-abbreviate)
[Number::clamp](#method-number-clamp)
[Number::currency](#method-number-currency)
[Number::fileSize](#method-number-file-size)
[Number::forHumans](#method-number-for-humans)
[Number::format](#method-number-format)
[Number::ordinal](#method-number-ordinal)
[Number::pairs](#method-number-pairs)
[Number::percentage](#method-number-percentage)
[Number::spell](#method-number-spell)
[Number::trim](#method-number-trim)
[Number::useLocale](#method-number-use-locale)
[Number::withLocale](#method-number-with-locale)

</div>

<a name="paths-method-list"></a>
### Rutas

<div class="collection-method-list" markdown="1">

[app_path](#method-app-path)
[base_path](#method-base-path)
[config_path](#method-config-path)
[database_path](#method-database-path)
[lang_path](#method-lang-path)
[mix](#method-mix)
[public_path](#method-public-path)
[resource_path](#method-resource-path)
[storage_path](#method-storage-path)

</div>

<a name="urls-method-list"></a>
### URLs

<div class="collection-method-list" markdown="1">

[action](#method-action)
[asset](#method-asset)
[route](#method-route)
[secure_asset](#method-secure-asset)
[secure_url](#method-secure-url)
[to_route](#method-to-route)
[url](#method-url)

</div>

<a name="miscellaneous-method-list"></a>
### Varios

<div class="collection-method-list" markdown="1">

[abort](#method-abort)
[abort_if](#method-abort-if)
[abort_unless](#method-abort-unless)
[app](#method-app)
[auth](#method-auth)
[back](#method-back)
[bcrypt](#method-bcrypt)
[blank](#method-blank)
[broadcast](#method-broadcast)
[cache](#method-cache)
[class_uses_recursive](#method-class-uses-recursive)
[collect](#method-collect)
[config](#method-config)
[context](#method-context)
[cookie](#method-cookie)
[csrf_field](#method-csrf-field)
[csrf_token](#method-csrf-token)
[decrypt](#method-decrypt)
[dd](#method-dd)
[dispatch](#method-dispatch)
[dispatch_sync](#method-dispatch-sync)
[dump](#method-dump)
[encrypt](#method-encrypt)
[env](#method-env)
[event](#method-event)
[fake](#method-fake)
[filled](#method-filled)
[info](#method-info)
[literal](#method-literal)
[logger](#method-logger)
[method_field](#method-method-field)
[now](#method-now)
[old](#method-old)
[once](#method-once)
[optional](#method-optional)
[policy](#method-policy)
[redirect](#method-redirect)
[report](#method-report)
[report_if](#method-report-if)
[report_unless](#method-report-unless)
[request](#method-request)
[rescue](#method-rescue)
[resolve](#method-resolve)
[response](#method-response)
[retry](#method-retry)
[session](#method-session)
[tap](#method-tap)
[throw_if](#method-throw-if)
[throw_unless](#method-throw-unless)
[today](#method-today)
[trait_uses_recursive](#method-trait-uses-recursive)
[transform](#method-transform)
[validator](#method-validator)
[value](#method-value)
[view](#method-view)
[with](#method-with)

</div>

<a name="arrays"></a>
## Arrays y Objetos


<a name="method-array-accessible"></a>
#### `Arr::accessible()` {.collection-method .first-collection-method}

El método `Arr::accessible` determina si el valor dado es accesible como un array:


```php
use Illuminate\Support\Arr;
use Illuminate\Support\Collection;

$isAccessible = Arr::accessible(['a' => 1, 'b' => 2]);

// true

$isAccessible = Arr::accessible(new Collection);

// true

$isAccessible = Arr::accessible('abc');

// false

$isAccessible = Arr::accessible(new stdClass);

// false
```

<a name="method-array-add"></a>
#### `Arr::add()` {.collection-method}


El método `Arr::add` añade un par clave / valor dado a un array si la clave dada no existe ya en el array o está configurada en `null`:


```php
use Illuminate\Support\Arr;

$array = Arr::add(['name' => 'Desk'], 'price', 100);

// ['name' => 'Desk', 'price' => 100]

$array = Arr::add(['name' => 'Desk', 'price' => null], 'price', 100);

// ['name' => 'Desk', 'price' => 100]
```

<a name="method-array-collapse"></a>
#### `Arr::collapse()` {.collection-method}


El método `Arr::collapse` colapsa un array de arrays en un solo array:


```php
use Illuminate\Support\Arr;

$array = Arr::collapse([[1, 2, 3], [4, 5, 6], [7, 8, 9]]);

// [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

<a name="method-array-crossjoin"></a>
#### `Arr::crossJoin()` {.collection-method}


El método `Arr::crossJoin` une en cruz los arrays dados, devolviendo un producto cartesiano con todas las posibles permutaciones:


```php
use Illuminate\Support\Arr;

$matrix = Arr::crossJoin([1, 2], ['a', 'b']);

/*
    [
        [1, 'a'],
        [1, 'b'],
        [2, 'a'],
        [2, 'b'],
    ]
*/

$matrix = Arr::crossJoin([1, 2], ['a', 'b'], ['I', 'II']);

/*
    [
        [1, 'a', 'I'],
        [1, 'a', 'II'],
        [1, 'b', 'I'],
        [1, 'b', 'II'],
        [2, 'a', 'I'],
        [2, 'a', 'II'],
        [2, 'b', 'I'],
        [2, 'b', 'II'],
    ]
*/
```

<a name="method-array-divide"></a>
#### `Arr::divide()` {.collection-method}


El método `Arr::divide` devuelve dos arreglos: uno que contiene las claves y el otro que contiene los valores del arreglo dado:


```php
use Illuminate\Support\Arr;

[$keys, $values] = Arr::divide(['name' => 'Desk']);

// $keys: ['name']

// $values: ['Desk']
```

<a name="method-array-dot"></a>
#### `Arr::dot()` {.collection-method}


El método `Arr::dot` aplana un array multidimensional en un array de un solo nivel que utiliza notación de "punto" para indicar la profundidad:


```php
use Illuminate\Support\Arr;

$array = ['products' => ['desk' => ['price' => 100]]];

$flattened = Arr::dot($array);

// ['products.desk.price' => 100]
```

<a name="method-array-except"></a>
#### `Arr::except()` {.collection-method}


El método `Arr::except` elimina los pares clave / valor dados de un array:


```php
use Illuminate\Support\Arr;

$array = ['name' => 'Desk', 'price' => 100];

$filtered = Arr::except($array, ['price']);

// ['name' => 'Desk']
```

<a name="method-array-exists"></a>
#### `Arr::exists()` {.collection-method}


El método `Arr::exists` verifica que la clave dada exista en el array proporcionado:


```php
use Illuminate\Support\Arr;

$array = ['name' => 'John Doe', 'age' => 17];

$exists = Arr::exists($array, 'name');

// true

$exists = Arr::exists($array, 'salary');

// false
```

<a name="method-array-first"></a>
#### `Arr::first()` {.collection-method}


El método `Arr::first` devuelve el primer elemento de un array pasando una prueba de verdad dada:


```php
use Illuminate\Support\Arr;

$array = [100, 200, 300];

$first = Arr::first($array, function (int $value, int $key) {
    return $value >= 150;
});

// 200
```
Un valor por defecto también se puede pasar como el tercer parámetro al método. Este valor se devolverá si no se pasa ningún valor que supere la prueba de veracidad:


```php
use Illuminate\Support\Arr;

$first = Arr::first($array, $callback, $default);
```

<a name="method-array-flatten"></a>
#### `Arr::flatten()` {.collection-method}


El método `Arr::flatten` aplana un array multidimensional en un array de un solo nivel:


```php
use Illuminate\Support\Arr;

$array = ['name' => 'Joe', 'languages' => ['PHP', 'Ruby']];

$flattened = Arr::flatten($array);

// ['Joe', 'PHP', 'Ruby']
```

<a name="method-array-forget"></a>
#### `Arr::forget()` {.collection-method}


El método `Arr::forget` elimina un par de clave / valor dado de un array profundamente anidado utilizando notación "dot":


```php
use Illuminate\Support\Arr;

$array = ['products' => ['desk' => ['price' => 100]]];

Arr::forget($array, 'products.desk');

// ['products' => []]
```

<a name="method-array-get"></a>
#### `Arr::get()` {.collection-method}


El método `Arr::get` recupera un valor de un array anidado profundamente utilizando notación de "punto":


```php
use Illuminate\Support\Arr;

$array = ['products' => ['desk' => ['price' => 100]]];

$price = Arr::get($array, 'products.desk.price');

// 100
```
El método `Arr::get` también acepta un valor predeterminado, que se devolverá si la clave especificada no está presente en el array:


```php
use Illuminate\Support\Arr;

$discount = Arr::get($array, 'products.desk.discount', 0);

// 0
```

<a name="method-array-has"></a>
#### `Arr::has()` {.collection-method}


El método `Arr::has` verifica si un elemento o elementos dados existen en un array utilizando notación "dot":


```php
use Illuminate\Support\Arr;

$array = ['product' => ['name' => 'Desk', 'price' => 100]];

$contains = Arr::has($array, 'product.name');

// true

$contains = Arr::has($array, ['product.price', 'product.discount']);

// false
```

<a name="method-array-hasany"></a>
#### `Arr::hasAny()` {.collection-method}


El método `Arr::hasAny` verifica si algún elemento en un conjunto dado existe en un array utilizando notación "dot":


```php
use Illuminate\Support\Arr;

$array = ['product' => ['name' => 'Desk', 'price' => 100]];

$contains = Arr::hasAny($array, 'product.name');

// true

$contains = Arr::hasAny($array, ['product.name', 'product.discount']);

// true

$contains = Arr::hasAny($array, ['category', 'product.discount']);

// false
```

<a name="method-array-isassoc"></a>
#### `Arr::isAssoc()` {.collection-method}


El método `Arr::isAssoc` devuelve `true` si el array dado es un array asociativo. Se considera que un array es "asociativo" si no tiene claves numéricas secuenciales que comiencen en cero:


```php
use Illuminate\Support\Arr;

$isAssoc = Arr::isAssoc(['product' => ['name' => 'Desk', 'price' => 100]]);

// true

$isAssoc = Arr::isAssoc([1, 2, 3]);

// false
```

<a name="method-array-islist"></a>
#### `Arr::isList()` {.collection-method}


El método `Arr::isList` devuelve `true` si las claves del array dado son enteros secuenciales que comienzan desde cero:


```php
use Illuminate\Support\Arr;

$isList = Arr::isList(['foo', 'bar', 'baz']);

// true

$isList = Arr::isList(['product' => ['name' => 'Desk', 'price' => 100]]);

// false
```

<a name="method-array-join"></a>
#### `Arr::join()` {.collection-method}


El método `Arr::join` une los elementos del array con una cadena. Usando el segundo argumento de este método, también puedes especificar la cadena de unión para el elemento final del array:


```php
use Illuminate\Support\Arr;

$array = ['Tailwind', 'Alpine', 'Laravel', 'Livewire'];

$joined = Arr::join($array, ', ');

// Tailwind, Alpine, Laravel, Livewire

$joined = Arr::join($array, ', ', ' and ');

// Tailwind, Alpine, Laravel and Livewire
```

<a name="method-array-keyby"></a>
#### `Arr::keyBy()` {.collection-method}


El método `Arr::keyBy` indexa el array por la clave dada. Si varios elementos tienen la misma clave, solo el último aparecerá en el nuevo array:


```php
use Illuminate\Support\Arr;

$array = [
    ['product_id' => 'prod-100', 'name' => 'Desk'],
    ['product_id' => 'prod-200', 'name' => 'Chair'],
];

$keyed = Arr::keyBy($array, 'product_id');

/*
    [
        'prod-100' => ['product_id' => 'prod-100', 'name' => 'Desk'],
        'prod-200' => ['product_id' => 'prod-200', 'name' => 'Chair'],
    ]
*/
```

<a name="method-array-last"></a>
#### `Arr::last()` {.collection-method}


El método `Arr::last` devuelve el último elemento de un array pasando una prueba de verdad dada:


```php
use Illuminate\Support\Arr;

$array = [100, 200, 300, 110];

$last = Arr::last($array, function (int $value, int $key) {
    return $value >= 150;
});

// 300
```
Un valor por defecto puede pasarse como el tercer argumento al método. Este valor se devolverá si no se pasa ningún valor que supere la prueba de verdad:


```php
use Illuminate\Support\Arr;

$last = Arr::last($array, $callback, $default);
```

<a name="method-array-map"></a>
#### `Arr::map()` {.collection-method}


El método `Arr::map` itera a través del array y pasa cada valor y clave al callback dado. El valor del array es reemplazado por el valor devuelto por el callback:


```php
use Illuminate\Support\Arr;

$array = ['first' => 'james', 'last' => 'kirk'];

$mapped = Arr::map($array, function (string $value, string $key) {
    return ucfirst($value);
});

// ['first' => 'James', 'last' => 'Kirk']
```

<a name="method-array-map-spread"></a>
#### `Arr::mapSpread()` {.collection-method}


El método `Arr::mapSpread` itera sobre el array, pasando el valor de cada elemento anidado a la `función anónima` dada. La `función anónima` puede modificar el elemento y devolverlo, formando así un nuevo array de elementos modificados:


```php
use Illuminate\Support\Arr;

$array = [
    [0, 1],
    [2, 3],
    [4, 5],
    [6, 7],
    [8, 9],
];

$mapped = Arr::mapSpread($array, function (int $even, int $odd) {
    return $even + $odd;
});

/*
    [1, 5, 9, 13, 17]
*/
```

<a name="method-array-map-with-keys"></a>
#### `Arr::mapWithKeys()` {.collection-method}


El método `Arr::mapWithKeys` itera a través del array y pasa cada valor al callback dado. El callback debe devolver un array asociativo que contenga un solo par clave / valor:


```php
use Illuminate\Support\Arr;

$array = [
    [
        'name' => 'John',
        'department' => 'Sales',
        'email' => 'john@example.com',
    ],
    [
        'name' => 'Jane',
        'department' => 'Marketing',
        'email' => 'jane@example.com',
    ]
];

$mapped = Arr::mapWithKeys($array, function (array $item, int $key) {
    return [$item['email'] => $item['name']];
});

/*
    [
        'john@example.com' => 'John',
        'jane@example.com' => 'Jane',
    ]
*/
```

<a name="method-array-only"></a>
#### `Arr::only()` {.collection-method}


El método `Arr::only` devuelve solo los pares de clave / valor especificados del array dado:


```php
use Illuminate\Support\Arr;

$array = ['name' => 'Desk', 'price' => 100, 'orders' => 10];

$slice = Arr::only($array, ['name', 'price']);

// ['name' => 'Desk', 'price' => 100]
```

<a name="method-array-pluck"></a>
#### `Arr::pluck()` {.collection-method}


El método `Arr::pluck` obtiene todos los valores para una clave dada de un array:


```php
use Illuminate\Support\Arr;

$array = [
    ['developer' => ['id' => 1, 'name' => 'Taylor']],
    ['developer' => ['id' => 2, 'name' => 'Abigail']],
];

$names = Arr::pluck($array, 'developer.name');

// ['Taylor', 'Abigail']
```
También puedes especificar cómo deseas que se genere la lista resultante:


```php
use Illuminate\Support\Arr;

$names = Arr::pluck($array, 'developer.name', 'developer.id');

// [1 => 'Taylor', 2 => 'Abigail']
```

<a name="method-array-prepend"></a>
#### `Arr::prepend()` {.collection-method}


El método `Arr::prepend` añadirá un elemento al inicio de un array:


```php
use Illuminate\Support\Arr;

$array = ['one', 'two', 'three', 'four'];

$array = Arr::prepend($array, 'zero');

// ['zero', 'one', 'two', 'three', 'four']
```
Si es necesario, puedes especificar la clave que se debe usar para el valor:


```php
use Illuminate\Support\Arr;

$array = ['price' => 100];

$array = Arr::prepend($array, 'Desk', 'name');

// ['name' => 'Desk', 'price' => 100]
```

<a name="method-array-prependkeyswith"></a>
#### `Arr::prependKeysWith()` {.collection-method}


El `Arr::prependKeysWith` añade el prefijo dado a todos los nombres de clave de un array asociativo:


```php
use Illuminate\Support\Arr;

$array = [
    'name' => 'Desk',
    'price' => 100,
];

$keyed = Arr::prependKeysWith($array, 'product.');

/*
    [
        'product.name' => 'Desk',
        'product.price' => 100,
    ]
*/
```

<a name="method-array-pull"></a>
#### `Arr::pull()` {.collection-method}


El método `Arr::pull` devuelve y elimina un par clave / valor de un array:


```php
use Illuminate\Support\Arr;

$array = ['name' => 'Desk', 'price' => 100];

$name = Arr::pull($array, 'name');

// $name: Desk

// $array: ['price' => 100]
```
Se puede pasar un valor predeterminado como tercer argumento al método. Este valor se devolverá si la clave no existe:


```php
use Illuminate\Support\Arr;

$value = Arr::pull($array, $key, $default);
```

<a name="method-array-query"></a>
#### `Arr::query()` {.collection-method}


El método `Arr::query` convierte el array en una cadena de consulta:


```php
use Illuminate\Support\Arr;

$array = [
    'name' => 'Taylor',
    'order' => [
        'column' => 'created_at',
        'direction' => 'desc'
    ]
];

Arr::query($array);

// name=Taylor&order[column]=created_at&order[direction]=desc
```

<a name="method-array-random"></a>
#### `Arr::random()` {.collection-method}


El método `Arr::random` devuelve un valor aleatorio de un array:


```php
use Illuminate\Support\Arr;

$array = [1, 2, 3, 4, 5];

$random = Arr::random($array);

// 4 - (retrieved randomly)
```
También puedes especificar el número de elementos a devolver como un segundo argumento opcional. Ten en cuenta que proporcionar este argumento devolverá un array incluso si solo se desea un elemento:


```php
use Illuminate\Support\Arr;

$items = Arr::random($array, 2);

// [2, 5] - (retrieved randomly)
```

<a name="method-array-set"></a>
#### `Arr::set()` {.collection-method}


El método `Arr::set` establece un valor dentro de un array profundamente anidado utilizando notación "dot":


```php
use Illuminate\Support\Arr;

$array = ['products' => ['desk' => ['price' => 100]]];

Arr::set($array, 'products.desk.price', 200);

// ['products' => ['desk' => ['price' => 200]]]
```

<a name="method-array-shuffle"></a>
#### `Arr::shuffle()` {.collection-method}


El método `Arr::shuffle` reorganiza aleatoriamente los elementos en el array:


```php
use Illuminate\Support\Arr;

$array = Arr::shuffle([1, 2, 3, 4, 5]);

// [3, 2, 5, 1, 4] - (generated randomly)
```

<a name="method-array-sort"></a>
#### `Arr::sort()` {.collection-method}


El método `Arr::sort` ordena un array por sus valores:


```php
use Illuminate\Support\Arr;

$array = ['Desk', 'Table', 'Chair'];

$sorted = Arr::sort($array);

// ['Chair', 'Desk', 'Table']
```


```php
use Illuminate\Support\Arr;

$array = [
    ['name' => 'Desk'],
    ['name' => 'Table'],
    ['name' => 'Chair'],
];

$sorted = array_values(Arr::sort($array, function (array $value) {
    return $value['name'];
}));

/*
    [
        ['name' => 'Chair'],
        ['name' => 'Desk'],
        ['name' => 'Table'],
    ]
*/
```

<a name="method-array-sort-desc"></a>
#### `Arr::sortDesc()` {.collection-method}


El método `Arr::sortDesc` ordena un array en orden descendente por sus valores:


```php
use Illuminate\Support\Arr;

$array = ['Desk', 'Table', 'Chair'];

$sorted = Arr::sortDesc($array);

// ['Table', 'Desk', 'Chair']
```
También puedes ordenar el array por los resultados de una `función anónima` dada:


```php
use Illuminate\Support\Arr;

$array = [
    ['name' => 'Desk'],
    ['name' => 'Table'],
    ['name' => 'Chair'],
];

$sorted = array_values(Arr::sortDesc($array, function (array $value) {
    return $value['name'];
}));

/*
    [
        ['name' => 'Table'],
        ['name' => 'Desk'],
        ['name' => 'Chair'],
    ]
*/
```

<a name="method-array-sort-recursive"></a>
#### `Arr::sortRecursive()` {.collection-method}


El método `Arr::sortRecursive` ordena un array de manera recursiva utilizando la función `sort` para sub-arrays indexados numéricamente y la función `ksort` para sub-arrays asociativos:


```php
use Illuminate\Support\Arr;

$array = [
    ['Roman', 'Taylor', 'Li'],
    ['PHP', 'Ruby', 'JavaScript'],
    ['one' => 1, 'two' => 2, 'three' => 3],
];

$sorted = Arr::sortRecursive($array);

/*
    [
        ['JavaScript', 'PHP', 'Ruby'],
        ['one' => 1, 'three' => 3, 'two' => 2],
        ['Li', 'Roman', 'Taylor'],
    ]
*/
```
Si deseas que los resultados se ordenen en orden descendente, puedes usar el método `Arr::sortRecursiveDesc`.


```php
$sorted = Arr::sortRecursiveDesc($array);
```

<a name="method-array-take"></a>
#### `Arr::take()` {.collection-method}


El método `Arr::take` devuelve un nuevo array con el número especificado de elementos:


```php
use Illuminate\Support\Arr;

$array = [0, 1, 2, 3, 4, 5];

$chunk = Arr::take($array, 3);

// [0, 1, 2]
```
También puedes pasar un número entero negativo para tomar el número especificado de elementos desde el final del array:


```php
$array = [0, 1, 2, 3, 4, 5];

$chunk = Arr::take($array, -2);

// [4, 5]
```

<a name="method-array-to-css-classes"></a>
#### `Arr::toCssClasses()` {.collection-method}


El método `Arr::toCssClasses` compila condicionalmente una cadena de clases CSS. El método acepta un array de clases donde la clave del array contiene la clase o las clases que deseas añadir, mientras que el valor es una expresión booleana. Si el elemento del array tiene una clave numérica, siempre se incluirá en la lista de clases renderizadas:


```php
use Illuminate\Support\Arr;

$isActive = false;
$hasError = true;

$array = ['p-4', 'font-bold' => $isActive, 'bg-red' => $hasError];

$classes = Arr::toCssClasses($array);

/*
    'p-4 bg-red'
*/
```

<a name="method-array-to-css-styles"></a>
#### `Arr::toCssStyles()` {.collection-method}


El método `Arr::toCssStyles` compila condicionalmente una cadena de estilos CSS. El método acepta un array de clases donde la clave del array contiene la o las clases que deseas agregar, mientras que el valor es una expresión booleana. Si el elemento del array tiene una clave numérica, siempre se incluirá en la lista de clases renderizadas:


```php
use Illuminate\Support\Arr;

$hasColor = true;

$array = ['background-color: blue', 'color: blue' => $hasColor];

$classes = Arr::toCssStyles($array);

/*
    'background-color: blue; color: blue;'
*/

```
Este método potencia la funcionalidad de Laravel, permitiendo [fusionar clases con el bolso de atributos de un componente Blade](/docs/%7B%7Bversion%7D%7D/blade#conditionally-merge-classes) así como la directiva `@class` [Blade](/docs/%7B%7Bversion%7D%7D/blade#conditional-classes).

<a name="method-array-undot"></a>
#### `Arr::undot()` {.collection-method}


El método `Arr::undot` expande un array unidimensional que utiliza notación "dot" en un array multidimensional:


```php
use Illuminate\Support\Arr;

$array = [
    'user.name' => 'Kevin Malone',
    'user.occupation' => 'Accountant',
];

$array = Arr::undot($array);

// ['user' => ['name' => 'Kevin Malone', 'occupation' => 'Accountant']]
```

<a name="method-array-where"></a>
#### `Arr::where()` {.collection-method}


El método `Arr::where` filtra un array utilizando la `función anónima` dada:


```php
use Illuminate\Support\Arr;

$array = [100, '200', 300, '400', 500];

$filtered = Arr::where($array, function (string|int $value, int $key) {
    return is_string($value);
});

// [1 => '200', 3 => '400']
```

<a name="method-array-where-not-null"></a>
#### `Arr::whereNotNull()` {.collection-method}


El método `Arr::whereNotNull` elimina todos los valores `null` del array dado:


```php
use Illuminate\Support\Arr;

$array = [0, null];

$filtered = Arr::whereNotNull($array);

// [0 => 0]
```

<a name="method-array-wrap"></a>
#### `Arr::wrap()` {.collection-method}


El método `Arr::wrap` envuelve el valor dado en un array. Si el valor dado ya es un array, se devolverá sin modificación:


```php
use Illuminate\Support\Arr;

$string = 'Laravel';

$array = Arr::wrap($string);

// ['Laravel']
```
Si el valor dado es `null`, se devolverá un array vacío:


```php
use Illuminate\Support\Arr;

$array = Arr::wrap(null);

// []
```

<a name="method-data-fill"></a>
#### `data_fill()` {.collection-method}


La función `data_fill` establece un valor faltante dentro de un array o objeto anidado utilizando la notación de "punto":


```php
$data = ['products' => ['desk' => ['price' => 100]]];

data_fill($data, 'products.desk.price', 200);

// ['products' => ['desk' => ['price' => 100]]]

data_fill($data, 'products.desk.discount', 10);

// ['products' => ['desk' => ['price' => 100, 'discount' => 10]]]
```
Esta función también acepta asteriscos como comodines y llenará el objetivo en consecuencia:


```php
$data = [
    'products' => [
        ['name' => 'Desk 1', 'price' => 100],
        ['name' => 'Desk 2'],
    ],
];

data_fill($data, 'products.*.price', 200);

/*
    [
        'products' => [
            ['name' => 'Desk 1', 'price' => 100],
            ['name' => 'Desk 2', 'price' => 200],
        ],
    ]
*/
```

<a name="method-data-get"></a>
#### `data_get()` {.collection-method}


La función `data_get` recupera un valor de un array o objeto anidado utilizando notación de "punto":


```php
$data = ['products' => ['desk' => ['price' => 100]]];

$price = data_get($data, 'products.desk.price');

// 100
```
La función `data_get` también acepta un valor predeterminado, que se devolverá si la clave especificada no se encuentra:


```php
$discount = data_get($data, 'products.desk.discount', 0);

// 0
```
La función también acepta comodines utilizando asteriscos, que pueden apuntar a cualquier clave del array o del objeto:


```php
$data = [
    'product-one' => ['name' => 'Desk 1', 'price' => 100],
    'product-two' => ['name' => 'Desk 2', 'price' => 150],
];

data_get($data, '*.name');

// ['Desk 1', 'Desk 2'];
```
Los marcadores de posición `{first}` y `{last}` pueden usarse para recuperar los primeros o últimos elementos de un array:


```php
$flight = [
    'segments' => [
        ['from' => 'LHR', 'departure' => '9:00', 'to' => 'IST', 'arrival' => '15:00'],
        ['from' => 'IST', 'departure' => '16:00', 'to' => 'PKX', 'arrival' => '20:00'],
    ],
];

data_get($flight, 'segments.{first}.arrival');

// 15:00
```

<a name="method-data-set"></a>
#### `data_set()` {.collection-method}


La función `data_set` establece un valor dentro de un array o objeto anidado utilizando notación de "punto":


```php
$data = ['products' => ['desk' => ['price' => 100]]];

data_set($data, 'products.desk.price', 200);

// ['products' => ['desk' => ['price' => 200]]]
```
Esta función también acepta comodines utilizando asteriscos y establecerá los valores en el objetivo de acuerdo con ello:


```php
$data = [
    'products' => [
        ['name' => 'Desk 1', 'price' => 100],
        ['name' => 'Desk 2', 'price' => 150],
    ],
];

data_set($data, 'products.*.price', 200);

/*
    [
        'products' => [
            ['name' => 'Desk 1', 'price' => 200],
            ['name' => 'Desk 2', 'price' => 200],
        ],
    ]
*/
```
Por defecto, cualquier valor existente se sobrescribe. Si deseas establecer un valor solo si no existe, puedes pasar `false` como cuarto argumento a la función:


```php
$data = ['products' => ['desk' => ['price' => 100]]];

data_set($data, 'products.desk.price', 200, overwrite: false);

// ['products' => ['desk' => ['price' => 100]]]
```

<a name="method-data-forget"></a>
#### `data_forget()` {.collection-method}


La función `data_forget` elimina un valor dentro de un array o objeto anidado utilizando notación "dot":


```php
$data = ['products' => ['desk' => ['price' => 100]]];

data_forget($data, 'products.desk.price');

// ['products' => ['desk' => []]]
```
Esta función también acepta comodines utilizando asteriscos y eliminará los valores en el objetivo según corresponda:


```php
$data = [
    'products' => [
        ['name' => 'Desk 1', 'price' => 100],
        ['name' => 'Desk 2', 'price' => 150],
    ],
];

data_forget($data, 'products.*.price');

/*
    [
        'products' => [
            ['name' => 'Desk 1'],
            ['name' => 'Desk 2'],
        ],
    ]
*/
```

<a name="method-head"></a>
#### `head()` {.collection-method}


La función `head` devuelve el primer elemento en el array dado:


```php
$array = [100, 200, 300];

$first = head($array);

// 100
```

<a name="method-last"></a>
#### `last()` {.collection-method}


La función `last` devuelve el último elemento en el array dado:


```php
$array = [100, 200, 300];

$last = last($array);

// 300
```

<a name="numbers"></a>
## Números


<a name="method-number-abbreviate"></a>
#### `Number::abbreviate()` {.collection-method}


El método `Number::abbreviate` devuelve el formato legible por humanos del valor numérico proporcionado, con una abreviatura para las unidades:


```php
use Illuminate\Support\Number;

$number = Number::abbreviate(1000);

// 1K

$number = Number::abbreviate(489939);

// 490K

$number = Number::abbreviate(1230000, precision: 2);

// 1.23M
```

<a name="method-number-clamp"></a>
#### `Number::clamp()` {.collection-method}


El método `Number::clamp` asegura que un número dado se mantenga dentro de un rango especificado. Si el número es menor que el mínimo, se devuelve el valor mínimo. Si el número es mayor que el máximo, se devuelve el valor máximo:


```php
use Illuminate\Support\Number;

$number = Number::clamp(105, min: 10, max: 100);

// 100

$number = Number::clamp(5, min: 10, max: 100);

// 10

$number = Number::clamp(10, min: 10, max: 100);

// 10

$number = Number::clamp(20, min: 10, max: 100);

// 20
```

<a name="method-number-currency"></a>
#### `Number::currency()` {.collection-method}


El método `Number::currency` devuelve la representación de la moneda del valor dado como una cadena:


```php
use Illuminate\Support\Number;

$currency = Number::currency(1000);

// $1,000.00

$currency = Number::currency(1000, in: 'EUR');

// €1,000.00

$currency = Number::currency(1000, in: 'EUR', locale: 'de');

// 1.000,00 €
```

<a name="method-number-file-size"></a>
#### `Number::fileSize()` {.collection-method}


El método `Number::fileSize` devuelve la representación del tamaño del archivo del valor de byte dado como una cadena:


```php
use Illuminate\Support\Number;

$size = Number::fileSize(1024);

// 1 KB

$size = Number::fileSize(1024 * 1024);

// 1 MB

$size = Number::fileSize(1024, precision: 2);

// 1.00 KB
```

<a name="method-number-for-humans"></a>
#### `Number::forHumans()` {.collection-method}


El método `Number::forHumans` devuelve el formato legible por humanos del valor numérico proporcionado:


```php
use Illuminate\Support\Number;

$number = Number::forHumans(1000);

// 1 thousand

$number = Number::forHumans(489939);

// 490 thousand

$number = Number::forHumans(1230000, precision: 2);

// 1.23 million
```

<a name="method-number-format"></a>
#### `Number::format()` {.collection-method}


El método `Number::format` formatea el número dado en una cadena específica de la localidad:


```php
use Illuminate\Support\Number;

$number = Number::format(100000);

// 100,000

$number = Number::format(100000, precision: 2);

// 100,000.00

$number = Number::format(100000.123, maxPrecision: 2);

// 100,000.12

$number = Number::format(100000, locale: 'de');

// 100.000
```

<a name="method-number-ordinal"></a>
#### `Number::ordinal()` {.collection-method}


El método `Number::ordinal` devuelve la representación ordinal de un número:


```php
use Illuminate\Support\Number;

$number = Number::ordinal(1);

// 1st

$number = Number::ordinal(2);

// 2nd

$number = Number::ordinal(21);

// 21st
```

<a name="method-number-pairs"></a>
#### `Number::pairs()` {.collection-method}


El método `Number::pairs` genera un array de pares de números (subrangos) basado en un rango especificado y un valor de paso. Este método puede ser útil para dividir un rango más grande de números en subrangos más pequeños y manejables para cosas como paginación o procesamiento por lotes. El método `pairs` devuelve un array de arrays, donde cada array interno representa un par (subrango) de números:


```php
use Illuminate\Support\Number;

$result = Number::pairs(25, 10);

// [[1, 10], [11, 20], [21, 25]]

$result = Number::pairs(25, 10, offset: 0);

// [[0, 10], [10, 20], [20, 25]]

```

<a name="method-number-percentage"></a>
#### `Number::percentage()` {.collection-method}


El método `Number::percentage` devuelve la representación porcentual del valor dado como una cadena:


```php
use Illuminate\Support\Number;

$percentage = Number::percentage(10);

// 10%

$percentage = Number::percentage(10, precision: 2);

// 10.00%

$percentage = Number::percentage(10.123, maxPrecision: 2);

// 10.12%

$percentage = Number::percentage(10, precision: 2, locale: 'de');

// 10,00%
```

<a name="method-number-spell"></a>
#### `Number::spell()` {.collection-method}


El método `Number::spell` transforma el número dado en una cadena de palabras:


```php
use Illuminate\Support\Number;

$number = Number::spell(102);

// one hundred and two

$number = Number::spell(88, locale: 'fr');

// quatre-vingt-huit
```
El argumento `after` te permite especificar un valor después del cual todos los números deben escribirse con palabras:


```php
$number = Number::spell(10, after: 10);

// 10

$number = Number::spell(11, after: 10);

// eleven
```
El argumento `until` te permite especificar un valor antes del cual todos los números deben ser escritos con palabras:


```php
$number = Number::spell(5, until: 10);

// five

$number = Number::spell(10, until: 10);

// 10
```

<a name="method-number-trim"></a>
#### `Number::trim()` {.collection-method}


El método `Number::trim` elimina cualquier dígito cero final después del punto decimal del número dado:


```php
use Illuminate\Support\Number;

$number = Number::trim(12.0);

// 12

$number = Number::trim(12.30);

// 12.3
```

<a name="method-number-use-locale"></a>
#### `Number::useLocale()` {.collection-method}


El método `Number::useLocale` establece el locale de número predeterminado a nivel global, lo que afecta cómo se formatean los números y la moneda en las invocaciones posteriores a los métodos de la clase `Number`:


```php
use Illuminate\Support\Number;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Number::useLocale('de');
}
```

<a name="method-number-with-locale"></a>
#### `Number::withLocale()` {.collection-method}


El método `Number::withLocale` ejecuta la `función anónima` dada utilizando la configuración regional especificada y luego restaura la configuración regional original después de que se haya ejecutado la función callback:


```php
use Illuminate\Support\Number;

$number = Number::withLocale('de', function () {
    return Number::format(1500);
});
```

<a name="paths"></a>
## Rutas


<a name="method-app-path"></a>
#### `app_path()` {.collection-method}


La función `app_path` devuelve la ruta completamente calificada al directorio `app` de tu aplicación. También puedes usar la función `app_path` para generar una ruta completamente calificada a un archivo en relación con el directorio de la aplicación:


```php
$path = app_path();

$path = app_path('Http/Controllers/Controller.php');
```

<a name="method-base-path"></a>
#### `base_path()` {.collection-method}


La función `base_path` devuelve la ruta completamente calificada al directorio raíz de tu aplicación. También puedes usar la función `base_path` para generar una ruta completamente calificada a un archivo dado en relación con el directorio raíz del proyecto:


```php
$path = base_path();

$path = base_path('vendor/bin');
```

<a name="method-config-path"></a>
#### `config_path()` {.collection-method}


La función `config_path` devuelve la ruta completamente calificada al directorio `config` de tu aplicación. También puedes usar la función `config_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio de configuración de la aplicación:


```php
$path = config_path();

$path = config_path('app.php');
```

<a name="method-database-path"></a>
#### `database_path()` {.collection-method}


La función `database_path` devuelve la ruta completamente cualificada al directorio `database` de tu aplicación. También puedes usar la función `database_path` para generar una ruta completamente cualificada a un archivo dado dentro del directorio de la base de datos:


```php
$path = database_path();

$path = database_path('factories/UserFactory.php');
```

<a name="method-lang-path"></a>
#### `lang_path()` {.collection-method}


La función `lang_path` devuelve la ruta completamente calificada al directorio `lang` de tu aplicación. También puedes usar la función `lang_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio:


```php
$path = lang_path();

$path = lang_path('en/messages.php');
```
> [!NOTA]
Por defecto, el esqueleto de la aplicación Laravel no incluye el directorio `lang`. Si deseas personalizar los archivos de idioma de Laravel, puedes publicarlos a través del comando Artisan `lang:publish`.

<a name="method-mix"></a>
#### `mix()` {.collection-method}


La función `mix` devuelve la ruta a un [archivo Mix versionado](/docs/%7B%7Bversion%7D%7D/mix):


```php
$path = mix('css/app.css');
```

<a name="method-public-path"></a>
#### `public_path()` {.collection-method}


La función `public_path` devuelve la ruta completamente calificada al directorio `public` de tu aplicación. También puedes usar la función `public_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio público:


```php
$path = public_path();

$path = public_path('css/app.css');
```

<a name="method-resource-path"></a>
#### `resource_path()` {.collection-method}


La función `resource_path` devuelve la ruta completamente cualificada al directorio `resources` de tu aplicación. También puedes usar la función `resource_path` para generar una ruta completamente cualificada a un archivo dado dentro del directorio de recursos:


```php
$path = resource_path();

$path = resource_path('sass/app.scss');
```

<a name="method-storage-path"></a>
#### `storage_path()` {.collection-method}


La función `storage_path` devuelve la ruta completamente calificada al directorio `storage` de tu aplicación. También puedes usar la función `storage_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio de almacenamiento:


```php
$path = storage_path();

$path = storage_path('app/file.txt');
```

<a name="urls"></a>
## URLs


<a name="method-action"></a>
#### `action()` {.collection-method}


La función `action` genera una URL para la acción del controlador dada:


```php
use App\Http\Controllers\HomeController;

$url = action([HomeController::class, 'index']);
```
Si el método acepta parámetros de ruta, puedes pasarlos como segundo argumento al método:


```php
$url = action([UserController::class, 'profile'], ['id' => 1]);
```

<a name="method-asset"></a>
#### `asset()` {.collection-method}


La función `asset` genera una URL para un recurso utilizando el esquema actual de la solicitud (HTTP o HTTPS):


```php
$url = asset('img/photo.jpg');
```
Puedes configurar el host de la URL de los activos configurando la variable `ASSET_URL` en tu archivo `.env`. Esto puede ser útil si alojas tus activos en un servicio externo como Amazon S3 o otro CDN:


```php
// ASSET_URL=http://example.com/assets

$url = asset('img/photo.jpg'); // http://example.com/assets/img/photo.jpg
```

<a name="method-route"></a>
#### `route()` {.collection-method}


La función `route` genera una URL para una ruta [nombrada](/docs/%7B%7Bversion%7D%7D/routing#named-routes) dada:


```php
$url = route('route.name');
```
Si la ruta acepta parámetros, puedes pasarlos como segundo argumento a la función:


```php
$url = route('route.name', ['id' => 1]);
```
Por defecto, la función `route` genera una URL absoluta. Si deseas generar una URL relativa, puedes pasar `false` como el tercer argumento a la función:


```php
$url = route('route.name', ['id' => 1], false);
```

<a name="method-secure-asset"></a>
#### `secure_asset()` {.collection-method}


La función `secure_asset` genera una URL para un recurso utilizando HTTPS:


```php
$url = secure_asset('img/photo.jpg');
```

<a name="method-secure-url"></a>
#### `secure_url()` {.collection-method}


La función `secure_url` genera una URL HTTPS completamente cualificada al camino dado. Se pueden pasar segmentos de URL adicionales en el segundo argumento de la función:


```php
$url = secure_url('user/profile');

$url = secure_url('user/profile', [1]);
```

<a name="method-to-route"></a>
#### `to_route()` {.collection-method}


La función `to_route` genera una [respuesta HTTP de redireccionamiento](/docs/%7B%7Bversion%7D%7D/responses#redirects) para una [ruta nombrada dada](/docs/%7B%7Bversion%7D%7D/routing#named-routes):


```php
return to_route('users.show', ['user' => 1]);
```
Si es necesario, puedes pasar el código de estado HTTP que se debe asignar a la redirección y cualquier encabezado de respuesta adicional como el tercer y cuarto argumento al método `to_route`:


```php
return to_route('users.show', ['user' => 1], 302, ['X-Framework' => 'Laravel']);
```

<a name="method-url"></a>
#### `url()` {.collection-method}


La función `url` genera una URL completamente calificada al camino dado:


```php
$url = url('user/profile');

$url = url('user/profile', [1]);
```
Si no se proporciona ninguna ruta, se devuelve una instancia de `Illuminate\Routing\UrlGenerator`:


```php
$current = url()->current();

$full = url()->full();

$previous = url()->previous();
```

<a name="miscellaneous"></a>
## Varios


<a name="method-abort"></a>
#### `abort()` {.collection-method}


La función `abort` lanza [una excepción HTTP](/docs/%7B%7Bversion%7D%7D/errors#http-exceptions) que será procesada por el [manejador de excepciones](/docs/%7B%7Bversion%7D%7D/errors#handling-exceptions):


```php
abort(403);
```
También puedes proporcionar el mensaje de la excepción y los encabezados de respuesta HTTP personalizados que se deben enviar al navegador:


```php
abort(403, 'Unauthorized.', $headers);
```

<a name="method-abort-if"></a>
#### `abort_if()` {.collection-method}


La función `abort_if` lanza una excepción HTTP si una expresión booleana dada evalúa a `true`:


```php
abort_if(! Auth::user()->isAdmin(), 403);
```

<a name="method-abort-unless"></a>
#### `abort_unless()` {.collection-method}


La función `abort_unless` lanza una excepción HTTP si una expresión booleana dada evalúa a `false`:


```php
abort_unless(Auth::user()->isAdmin(), 403);
```
Al igual que el método `abort`, también puedes proporcionar el texto de respuesta de la excepción como el tercer argumento y un array de encabezados de respuesta personalizados como el cuarto argumento a la función.

<a name="method-app"></a>
#### `app()` {.collection-method}


La función `app` devuelve la instancia del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container):


```php
$container = app();
```
Puedes pasar un nombre de clase o interfaz para resolverlo desde el contenedor:


```php
$api = app('HelpSpot\API');
```

<a name="method-auth"></a>
#### `auth()` {.collection-method}


La función `auth` devuelve una instancia de [authenticator](/docs/%7B%7Bversion%7D%7D/authentication). Puedes usarla como una alternativa a la fachada `Auth`:


```php
$user = auth()->user();
```
Si es necesario, puedes especificar qué instancia de guardia te gustaría acceder:


```php
$user = auth('admin')->user();
```

<a name="method-back"></a>
#### `back()` {.collection-method}


La función `back` genera una [respuesta HTTP de redireccionamiento](/docs/%7B%7Bversion%7D%7D/responses#redirects) a la ubicación anterior del usuario:


```php
return back($status = 302, $headers = [], $fallback = '/');

return back();
```

<a name="method-bcrypt"></a>
#### `bcrypt()` {.collection-method}


La función `bcrypt` [hashes](/docs/%7B%7Bversion%7D%7D/hashing) el valor dado utilizando Bcrypt. Puedes usar esta función como una alternativa a la facade `Hash`:


```php
$password = bcrypt('my-secret-password');
```

<a name="method-blank"></a>
#### `blank()` {.collection-method}


La función `blank` determina si el valor dado está "en blanco":


```php
blank('');
blank('   ');
blank(null);
blank(collect());

// true

blank(0);
blank(true);
blank(false);

// false
```
Para la inversa de `blank`, consulta el método [`filled`](#method-filled).

<a name="method-broadcast"></a>
#### `broadcast()` {.collection-method}


La función `broadcast` [transmite](/docs/%7B%7Bversion%7D%7D/broadcasting) el [evento](/docs/%7B%7Bversion%7D%7D/events) dado a sus oyentes:


```php
broadcast(new UserRegistered($user));

broadcast(new UserRegistered($user))->toOthers();
```

<a name="method-cache"></a>
#### `cache()` {.collection-method}


La función `cache` se puede utilizar para obtener valores de la [caché](/docs/%7B%7Bversion%7D%7D/cache). Si la clave dada no existe en la caché, se devolverá un valor predeterminado opcional:


```php
$value = cache('key');

$value = cache('key', 'default');
```
Puedes añadir elementos a la caché pasando un array de pares clave / valor a la función. También debes pasar el número de segundos o la duración durante la cual se debe considerar válido el valor en caché:


```php
cache(['key' => 'value'], 300);

cache(['key' => 'value'], now()->addSeconds(10));
```

<a name="method-class-uses-recursive"></a>
#### `class_uses_recursive()` {.collection-method}


La función `class_uses_recursive` devuelve todos los traits utilizados por una clase, incluyendo los traits utilizados por todas sus clases padre:


```php
$traits = class_uses_recursive(App\Models\User::class);
```

<a name="method-collect"></a>
#### `collect()` {.collection-method}


La función `collect` crea una instancia de [colección](/docs/%7B%7Bversion%7D%7D/collections) a partir del valor dado:


```php
$collection = collect(['taylor', 'abigail']);
```

<a name="method-config"></a>
#### `config()` {.collection-method}


La función `config` obtiene el valor de una variable de [configuración](/docs/%7B%7Bversion%7D%7D/configuration). Los valores de configuración se pueden acceder utilizando la sintaxis "dot", que incluye el nombre del archivo y la opción que deseas acceder. Se puede especificar un valor predeterminado y se devuelve si la opción de configuración no existe:


```php
$value = config('app.timezone');

$value = config('app.timezone', $default);
```
Puedes establecer variables de configuración en tiempo de ejecución pasando un array de pares clave / valor. Sin embargo, ten en cuenta que esta función solo afecta el valor de configuración para la solicitud actual y no actualiza tus valores de configuración reales:


```php
config(['app.debug' => true]);
```

<a name="method-context"></a>
#### `context()` {.collection-method}


La función `context` obtiene el valor del [contexto actual](/docs/%7B%7Bversion%7D%7D/context). Se puede especificar un valor predeterminado que se devolverá si la clave del contexto no existe:


```php
$value = context('trace_id');

$value = context('trace_id', $default);
```
Puedes establecer valores de contexto pasando un array de pares clave / valor:


```php
use Illuminate\Support\Str;

context(['trace_id' => Str::uuid()->toString()]);
```

<a name="method-cookie"></a>
#### `cookie()` {.collection-method}


La función `cookie` crea una nueva instancia de [cookie](/docs/%7B%7Bversion%7D%7D/requests#cookies):


```php
$cookie = cookie('name', 'value', $minutes);
```

<a name="method-csrf-field"></a>
#### `csrf_field()` {.collection-method}


La función `csrf_field` genera un campo de entrada `hidden` HTML que contiene el valor del token CSRF. Por ejemplo, utilizando [la sintaxis de Blade](/docs/%7B%7Bversion%7D%7D/blade):


```php
{{ csrf_field() }}
```

<a name="method-csrf-token"></a>
#### `csrf_token()` {.collection-method}


La función `csrf_token` recupera el valor del token CSRF actual:


```php
$token = csrf_token();
```

<a name="method-decrypt"></a>
#### `decrypt()` {.collection-method}


La función `decrypt` [descifra](/docs/%7B%7Bversion%7D%7D/encryption) el valor dado. Puedes usar esta función como una alternativa a la fachada `Crypt`:


```php
$password = decrypt($value);
```

<a name="method-dd"></a>
#### `dd()` {.collection-method}


La función `dd` imprime las variables dadas y finaliza la ejecución del script:


```php
dd($value);

dd($value1, $value2, $value3, ...);
```
Si no deseas detener la ejecución de tu script, utiliza la función [`dump`](#method-dump) en su lugar.

<a name="method-dispatch"></a>
#### `dispatch()` {.collection-method}


La función `dispatch` coloca el [trabajo](/docs/%7B%7Bversion%7D%7D/queues#creating-jobs) dado en la [cola de trabajos](/docs/%7B%7Bversion%7D%7D/queues) de Laravel:


```php
dispatch(new App\Jobs\SendEmails);
```

<a name="method-dispatch-sync"></a>
#### `dispatch_sync()` {.collection-method}


La función `dispatch_sync` envía el trabajo dado a la cola [sync](/docs/%7B%7Bversion%7D%7D/queues#synchronous-dispatching) para que se procese inmediatamente:


```php
dispatch_sync(new App\Jobs\SendEmails);
```

<a name="method-dump"></a>
#### `dump()` {.collection-method}


La función `dump` muestra las variables dadas:


```php
dump($value);

dump($value1, $value2, $value3, ...);
```
Si deseas detener la ejecución del script después de volcar las variables, utiliza la función [`dd`](#method-dd).

<a name="method-encrypt"></a>
#### `encrypt()` {.collection-method}


La función `encrypt` [encripta](/docs/%7B%7Bversion%7D%7D/encryption) el valor dado. Puedes usar esta función como una alternativa a la fachada `Crypt`:


```php
$secret = encrypt('my-secret-value');
```

<a name="method-env"></a>
#### `env()` {.collection-method}


La función `env` recupera el valor de una [variable de entorno](/docs/%7B%7Bversion%7D%7D/configuration#environment-configuration) o devuelve un valor predeterminado:


```php
$env = env('APP_ENV');

$env = env('APP_ENV', 'production');
```
> [!WARNING]
Si ejecutas el comando `config:cache` durante tu proceso de despliegue, debes asegurarte de que solo estás llamando a la función `env` desde dentro de tus archivos de configuración. Una vez que la configuración ha sido almacenada en caché, el archivo `.env` no se cargará y todas las llamadas a la función `env` devolverán `null`.

<a name="method-event"></a>
#### `event()` {.collection-method}


La función `event` despacha el [evento](/docs/%7B%7Bversion%7D%7D/events) dado a sus oyentes:


```php
event(new UserRegistered($user));
```

<a name="method-fake"></a>
#### `fake()` {.collection-method}


La función `fake` resuelve un singleton de [Faker](https://github.com/FakerPHP/Faker) desde el contenedor, lo que puede ser útil al crear datos falsos en fábricas de modelos, sembrado de bases de datos, pruebas y prototipado de vistas:


```blade
@for($i = 0; $i < 10; $i++)
    <dl>
        <dt>Name</dt>
        <dd>{{ fake()->name() }}</dd>

        <dt>Email</dt>
        <dd>{{ fake()->unique()->safeEmail() }}</dd>
    </dl>
@endfor

```
Por defecto, la función `fake` utilizará la opción de configuración `app.faker_locale` en tu configuración `config/app.php`. Típicamente, esta opción de configuración se establece a través de la variable de entorno `APP_FAKER_LOCALE`. También puedes especificar la configuración regional pasándola a la función `fake`. Cada configuración regional resolverá un singleton individual:


```php
fake('nl_NL')->name()
```

<a name="method-filled"></a>
#### `filled()` {.collection-method}


La función `filled` determina si el valor dado no está "en blanco":


```php
filled(0);
filled(true);
filled(false);

// true

filled('');
filled('   ');
filled(null);
filled(collect());

// false
```
Para la inversa de `filled`, consulta el método [`blank`](#method-blank).

<a name="method-info"></a>
#### `info()` {.collection-method}


La función `info` escribirá información en el [registro](/docs/%7B%7Bversion%7D%7D/logging) de tu aplicación:


```php
info('Some helpful information!');
```


```php
info('User login attempt failed.', ['id' => $user->id]);
```

<a name="method-literal"></a>
#### `literal()` {.collection-method}


La función `literal` crea una nueva instancia de [stdClass](https://www.php.net/manual/en/class.stdclass.php) con los argumentos nombrados dados como propiedades:


```php
$obj = literal(
    name: 'Joe',
    languages: ['PHP', 'Ruby'],
);

$obj->name; // 'Joe'
$obj->languages; // ['PHP', 'Ruby']
```

<a name="method-logger"></a>
#### `logger()` {.collection-method}


La función `logger` se puede usar para escribir un mensaje de nivel `debug` en el [registro](/docs/%7B%7Bversion%7D%7D/logging):


```php
logger('Debug message');
```
También se puede pasar un array de datos contextuales a la función:


```php
logger('User has logged in.', ['id' => $user->id]);
```
Se devolverá una instancia de [logger](/docs/%7B%7Bversion%7D%7D/logging) si no se pasa ningún valor a la función:


```php
logger()->error('You are not allowed here.');
```

<a name="method-method-field"></a>
#### `method_field()` {.collection-method}


La función `method_field` genera un campo de entrada `hidden` HTML que contiene el valor simulado del verbo HTTP del formulario. Por ejemplo, usando [sintaxis Blade](/docs/%7B%7Bversion%7D%7D/blade):


```php
<form method="POST">
    {{ method_field('DELETE') }}
</form>
```

<a name="method-now"></a>
#### `now()` {.collection-method}


La función `now` crea una nueva instancia de `Illuminate\Support\Carbon` para la hora actual:


```php
$now = now();
```

<a name="method-old"></a>
#### `old()` {.collection-method}


La función `old` [recupera](/docs/%7B%7Bversion%7D%7D/requests#retrieving-input) un valor de [entrada antigua](/docs/%7B%7Bversion%7D%7D/requests#old-input) guardado en la sesión:


```php
$value = old('value');

$value = old('value', 'default');
```
Dado que el "valor predeterminado" proporcionado como el segundo argumento a la función `old` es a menudo un atributo de un modelo Eloquent, Laravel te permite simplemente pasar todo el modelo Eloquent como el segundo argumento a la función `old`. Al hacerlo, Laravel asumirá que el primer argumento proporcionado a la función `old` es el nombre del atributo Eloquent que se debe considerar el "valor predeterminado":


```php
{{ old('name', $user->name) }}

// Is equivalent to...

{{ old('name', $user) }}
```

<a name="method-once"></a>
#### `once()` {.collection-method}


La función `once` ejecuta el callback dado y almacena en caché el resultado en memoria durante la duración de la solicitud. Cualquier llamada posterior a la función `once` con el mismo callback devolverá el resultado en caché previamente:


```php
function random(): int
{
    return once(function () {
        return random_int(1, 1000);
    });
}

random(); // 123
random(); // 123 (cached result)
random(); // 123 (cached result)
```
Cuando se ejecuta la función `once` desde dentro de una instancia de objeto, el resultado en caché será único para esa instancia de objeto:


```php
<?php

class NumberService
{
    public function all(): array
    {
        return once(fn () => [1, 2, 3]);
    }
}

$service = new NumberService;

$service->all();
$service->all(); // (cached result)

$secondService = new NumberService;

$secondService->all();
$secondService->all(); // (cached result)

```

<a name="method-optional"></a>
#### `optional()` {.collection-method}


La función `optional` acepta cualquier argumento y te permite acceder a propiedades o llamar a métodos en ese objeto. Si el objeto dado es `null`, las propiedades y métodos devolverán `null` en lugar de causar un error:


```php
return optional($user->address)->street;

{!! old('name', optional($user)->name) !!}
```
La función `optional` también acepta una `función anónima` como segundo argumento. La `función anónima` se invocará si el valor proporcionado como primer argumento no es nulo:


```php
return optional(User::find($id), function (User $user) {
    return $user->name;
});
```

<a name="method-policy"></a>
#### `policy()` {.collection-method}


El método `policy` obtiene una instancia de [policy](/docs/%7B%7Bversion%7D%7D/authorization#creating-policies) para una clase dada:


```php
$policy = policy(App\Models\User::class);
```

<a name="method-redirect"></a>
#### `redirect()` {.collection-method}


La función `redirect` devuelve una [respuesta HTTP de redireccionamiento](/docs/%7B%7Bversion%7D%7D/responses#redirects), o devuelve la instancia del redireccionador si se llama sin argumentos:


```php
return redirect($to = null, $status = 302, $headers = [], $https = null);

return redirect('/home');

return redirect()->route('route.name');
```

<a name="method-report"></a>
#### `report()` {.collection-method}


La función `report` informará de una excepción utilizando tu [manejador de excepciones](/docs/%7B%7Bversion%7D%7D/errors#handling-exceptions):


```php
report($e);
```
La función `report` también acepta una cadena como argumento. Cuando se le da una cadena a la función, la función creará una excepción con la cadena dada como su mensaje:


```php
report('Something went wrong.');
```

<a name="method-report-if"></a>
#### `report_if()` {.collection-method}


La función `report_if` informará de una excepción utilizando tu [manejador de excepciones](/docs/%7B%7Bversion%7D%7D/errors#handling-exceptions) si la condición dada es `true`:


```php
report_if($shouldReport, $e);

report_if($shouldReport, 'Something went wrong.');
```

<a name="method-report-unless"></a>
#### `report_unless()` {.collection-method}


La función `report_unless` informará de una excepción utilizando tu [manejador de excepciones](/docs/%7B%7Bversion%7D%7D/errors#handling-exceptions) si la condición dada es `false`:


```php
report_unless($reportingDisabled, $e);

report_unless($reportingDisabled, 'Something went wrong.');
```

<a name="method-request"></a>
#### `request()` {.collection-method}


La función `request` devuelve la instancia de la [solicitud](/docs/%7B%7Bversion%7D%7D/requests) actual o obtiene el valor de un campo de entrada de la solicitud actual:


```php
$request = request();

$value = request('key', $default);
```

<a name="method-rescue"></a>
#### `rescue()` {.collection-method}


La función `rescue` ejecuta la `función anónima` dada y captura cualquier excepción que ocurra durante su ejecución. Todas las excepciones que se capturan se enviarán a tu [manejador de excepciones](/docs/%7B%7Bversion%7D%7D/errors#handling-exceptions); sin embargo, la solicitud continuará procesándose:


```php
return rescue(function () {
    return $this->method();
});
```
También puedes pasar un segundo argumento a la función `rescue`. Este argumento será el valor "predeterminado" que se debe devolver si ocurre una excepción mientras se ejecuta la `función anónima`:


```php
return rescue(function () {
    return $this->method();
}, false);

return rescue(function () {
    return $this->method();
}, function () {
    return $this->failure();
});
```
Se puede proporcionar un argumento `report` a la función `rescue` para determinar si la excepción debe ser reportada a través de la función `report`:


```php
return rescue(function () {
    return $this->method();
}, report: function (Throwable $throwable) {
    return $throwable instanceof InvalidArgumentException;
});
```

<a name="method-resolve"></a>
#### `resolve()` {.collection-method}


La función `resolve` resuelve un nombre de clase o interfaz dado a una instancia utilizando el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container):


```php
$api = resolve('HelpSpot\API');
```

<a name="method-response"></a>
#### `response()` {.collection-method}


La función `response` crea una instancia de [respuesta](/docs/%7B%7Bversion%7D%7D/responses) o obtiene una instancia de la fábrica de respuestas:


```php
return response('Hello World', 200, $headers);

return response()->json(['foo' => 'bar'], 200, $headers);
```

<a name="method-retry"></a>
#### `retry()` {.collection-method}


La función `retry` intenta ejecutar el callback dado hasta que se alcance el umbral máximo de intentos dado. Si el callback no lanza una excepción, se devolverá su valor de retorno. Si el callback lanza una excepción, se intentará automáticamente de nuevo. Si se supera el conteo máximo de intentos, se lanzará la excepción:


```php
return retry(5, function () {
    // Attempt 5 times while resting 100ms between attempts...
}, 100);
```
Si deseas calcular manualmente el número de milisegundos para dormir entre intentos, puedes pasar una `función anónima` como tercer argumento a la función `retry`:


```php
use Exception;

return retry(5, function () {
    // ...
}, function (int $attempt, Exception $exception) {
    return $attempt * 100;
});
```
Para mayor comodidad, puedes proporcionar un array como primer argumento a la función `retry`. Este array se utilizará para determinar cuántos milisegundos esperar entre intentos sucesivos:


```php
return retry([100, 200], function () {
    // Sleep for 100ms on first retry, 200ms on second retry...
});
```
Para reintentar solo bajo condiciones específicas, puedes pasar una `función anónima` como cuarto argumento a la función `retry`:


```php
use Exception;

return retry(5, function () {
    // ...
}, 100, function (Exception $exception) {
    return $exception instanceof RetryException;
});
```

<a name="method-session"></a>
#### `session()` {.collection-method}


La función `session` se puede usar para obtener o establecer valores de [sesión](/docs/%7B%7Bversion%7D%7D/session):


```php
$value = session('key');
```
Puedes establecer valores pasando un array de pares clave / valor a la función:


```php
session(['chairs' => 7, 'instruments' => 3]);
```
Se devolverá el almacenamiento de sesiones si no se pasa ningún valor a la función:


```php
$value = session()->get('key');

session()->put('key', $value);
```

<a name="method-tap"></a>
#### `tap()` {.collection-method}


La función `tap` acepta dos argumentos: un `$value` arbitrario y una función anónima. El `$value` se pasará a la función anónima y luego será devuelto por la función `tap`. El valor de retorno de la función anónima es irrelevante:


```php
$user = tap(User::first(), function (User $user) {
    $user->name = 'taylor';

    $user->save();
});
```
Si no se pasa ninguna `función anónima` a la función `tap`, puedes llamar a cualquier método en el `$value` dado. El valor de retorno del método que llames será siempre `$value`, sin importar lo que devuelva realmente el método en su definición. Por ejemplo, el método `update` de Eloquent típicamente devuelve un entero. Sin embargo, podemos forzar al método a devolver el modelo en sí mismo encadenando la llamada al método `update` a través de la función `tap`:


```php
$user = tap($user)->update([
    'name' => $name,
    'email' => $email,
]);
```
Para añadir un método `tap` a una clase, puedes añadir el trait `Illuminate\Support\Traits\Tappable` a la clase. El método `tap` de este trait acepta una función anónima como su único argumento. La instancia del objeto en sí se pasará a la función anónima y luego será devuelta por el método `tap`:


```php
return $user->tap(function (User $user) {
    // ...
});
```

<a name="method-throw-if"></a>
#### `throw_if()` {.collection-method}


La función `throw_if` lanza la excepción dada si una expresión booleana dada evalúa a `true`:


```php
throw_if(! Auth::user()->isAdmin(), AuthorizationException::class);

throw_if(
    ! Auth::user()->isAdmin(),
    AuthorizationException::class,
    'You are not allowed to access this page.'
);
```

<a name="method-throw-unless"></a>
#### `throw_unless()` {.collection-method}


La función `throw_unless` lanza la excepción dada si una expresión boolean a dada evalúa a `false`:


```php
throw_unless(Auth::user()->isAdmin(), AuthorizationException::class);

throw_unless(
    Auth::user()->isAdmin(),
    AuthorizationException::class,
    'You are not allowed to access this page.'
);
```

<a name="method-today"></a>
#### `today()` {.collection-method}


La función `today` crea una nueva instancia de `Illuminate\Support\Carbon` para la fecha actual:


```php
$today = today();
```

<a name="method-trait-uses-recursive"></a>
#### `trait_uses_recursive()` {.collection-method}


La función `trait_uses_recursive` devuelve todos los traits utilizados por un trait:


```php
$traits = trait_uses_recursive(\Illuminate\Notifications\Notifiable::class);
```

<a name="method-transform"></a>
#### `transform()` {.collection-method}


La función `transform` ejecuta una función anónima en un valor dado si el valor no está [en blanco](#method-blank) y luego devuelve el valor de retorno de la función anónima:


```php
$callback = function (int $value) {
    return $value * 2;
};

$result = transform(5, $callback);

// 10
```
Se puede pasar un valor predeterminado o una función anónima como el tercer argumento a la función. Este valor se devolverá si el valor dado está en blanco:


```php
$result = transform(null, $callback, 'The value is blank');

// The value is blank
```

<a name="method-validator"></a>
#### `validator()` {.collection-method}


La función `validator` crea una nueva instancia de [validator](/docs/%7B%7Bversion%7D%7D/validation) con los argumentos dados. Puedes usarla como una alternativa a la fachada `Validator`:


```php
$validator = validator($data, $rules, $messages);
```

<a name="method-value"></a>
#### `value()` {.collection-method}


La función `value` devuelve el valor que se le da. Sin embargo, si pasas una función anónima a la función, se ejecutará la función anónima y se devolverá su valor de retorno:


```php
$result = value(true);

// true

$result = value(function () {
    return false;
});

// false
```
Se pueden pasar argumentos adicionales a la función `value`. Si el primer argumento es una función anónima, entonces los parámetros adicionales se pasarán a la función anónima como argumentos; de lo contrario, serán ignorados:


```php
$result = value(function (string $name) {
    return $name;
}, 'Taylor');

// 'Taylor'
```

<a name="method-view"></a>
#### `view()` {.collection-method}


La función `view` recupera una instancia de [vista](/docs/%7B%7Bversion%7D%7D/views):


```php
return view('auth.login');
```

<a name="method-with"></a>
#### `with()` {.collection-method}


La función `with` devuelve el valor que se le da. Si se pasa una función anónima como segundo argumento a la función, se ejecutará la función anónima y se devolverá su valor de retorno:


```php
$callback = function (mixed $value) {
    return is_numeric($value) ? $value * 2 : 0;
};

$result = with(5, $callback);

// 10

$result = with(null, $callback);

// 0

$result = with(5, null);

// 5
```

<a name="other-utilities"></a>
## Otras Utilidades


<a name="benchmarking"></a>
### Benchmarking

A veces es posible que desees probar rápidamente el rendimiento de ciertas partes de tu aplicación. En esas ocasiones, puedes utilizar la clase de soporte `Benchmark` para medir la cantidad de milisegundos que tardan en completarse los callbacks dados:


```php
<?php

use App\Models\User;
use Illuminate\Support\Benchmark;

Benchmark::dd(fn () => User::find(1)); // 0.1 ms

Benchmark::dd([
    'Scenario 1' => fn () => User::count(), // 0.5 ms
    'Scenario 2' => fn () => User::all()->count(), // 20.0 ms
]);
```
Por defecto, los callbacks dados se ejecutarán una vez (una iteración), y su duración se mostrará en el navegador / consola.
Para invocar un callback más de una vez, puedes especificar el número de iteraciones que se debe invocar el callback como el segundo argumento al método. Al ejecutar un callback más de una vez, la clase `Benchmark` devolverá la cantidad media de milisegundos que tomó ejecutar el callback a través de todas las iteraciones:


```php
Benchmark::dd(fn () => User::count(), iterations: 10); // 0.5 ms
```
A veces, es posible que desees medir el rendimiento de una callback mientras aún obtienes el valor devuelto por la callback. El método `value` devolverá una tupla que contiene el valor devuelto por la callback y la cantidad de milisegundos que tardó en ejecutarse la callback:


```php
[$count, $duration] = Benchmark::value(fn () => User::count());
```

<a name="dates"></a>
### Fechas

Laravel incluye [Carbon](https://carbon.nesbot.com/docs/), una poderosa biblioteca de manipulación de fechas y horas. Para crear una nueva instancia de `Carbon`, puedes invocar la función `now`. Esta función está disponible globalmente en tu aplicación Laravel:


```php
$now = now();

```
O también puedes crear una nueva instancia de `Carbon` utilizando la clase `Illuminate\Support\Carbon`:


```php
use Illuminate\Support\Carbon;

$now = Carbon::now();

```
Para una discusión exhaustiva sobre Carbon y sus características, consulta la [documentación oficial de Carbon](https://carbon.nesbot.com/docs/).

<a name="lottery"></a>
### Lotería

La clase de lotería de Laravel se puede usar para ejecutar callbacks basados en un conjunto de probabilidades dadas. Esto puede ser especialmente útil cuando solo deseas ejecutar código para un porcentaje de tus solicitudes entrantes:


```php
use Illuminate\Support\Lottery;

Lottery::odds(1, 20)
    ->winner(fn () => $user->won())
    ->loser(fn () => $user->lost())
    ->choose();
```
Puedes combinar la clase de lotería de Laravel con otras características de Laravel. Por ejemplo, es posible que desees informar solo un pequeño porcentaje de las consultas lentas a tu manejador de excepciones. Y, dado que la clase de lotería es callable, podemos pasar una instancia de la clase a cualquier método que acepte callables:


```php
use Carbon\CarbonInterval;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Lottery;

DB::whenQueryingForLongerThan(
    CarbonInterval::seconds(2),
    Lottery::odds(1, 100)->winner(fn () => report('Querying > 2 seconds.')),
);
```

<a name="testing-lotteries"></a>
#### Pruebas de Loterías

Laravel ofrece algunos métodos simples que te permiten probar fácilmente las invocaciones de lotería de tu aplicación:


```php
// Lottery will always win...
Lottery::alwaysWin();

// Lottery will always lose...
Lottery::alwaysLose();

// Lottery will win then lose, and finally return to normal behavior...
Lottery::fix([true, false]);

// Lottery will return to normal behavior...
Lottery::determineResultsNormally();
```

<a name="pipeline"></a>
### Pipeline

La fachada `Pipeline` de Laravel proporciona una forma conveniente de "enviar" una entrada dada a través de una serie de clases invocables, funciones anónimas o llamados, dando a cada clase la oportunidad de inspeccionar o modificar la entrada e invocar el siguiente callable en el pipeline:


```php
use Closure;
use App\Models\User;
use Illuminate\Support\Facades\Pipeline;

$user = Pipeline::send($user)
            ->through([
                function (User $user, Closure $next) {
                    // ...

                    return $next($user);
                },
                function (User $user, Closure $next) {
                    // ...

                    return $next($user);
                },
            ])
            ->then(fn (User $user) => $user);

```
Como puedes ver, a cada clase invocable o `función anónima` en la tubería se le proporcionan la entrada y una `función anónima` `$next`. Invocar la `función anónima` `$next` invocará el siguiente callable en la tubería. Como habrás notado, esto es muy similar a [middleware](/docs/%7B%7Bversion%7D%7D/middleware).
Cuando el último callable en el pipeline invoca la función anónima `$next`, el callable proporcionado al método `then` será invocado. Típicamente, este callable simplemente devolverá la entrada dada.
Por supuesto, como se discutió anteriormente, no estás limitado a proporcionar funciones anónimas a tu pipeline. También puedes proporcionar clases invocables. Si se proporciona un nombre de clase, la clase se instanciará a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel, lo que permite que las dependencias se inyecten en la clase invocable:


```php
$user = Pipeline::send($user)
            ->through([
                GenerateProfilePhoto::class,
                ActivateSubscription::class,
                SendWelcomeEmail::class,
            ])
            ->then(fn (User $user) => $user);

```

<a name="sleep"></a>
### Sueño

La clase `Sleep` de Laravel es un contenedor ligero alrededor de las funciones `sleep` y `usleep` nativas de PHP, ofreciendo una mayor facilidad de prueba mientras expone una API amigable para desarrolladores para trabajar con tiempo:


```php
use Illuminate\Support\Sleep;

$waiting = true;

while ($waiting) {
    Sleep::for(1)->second();

    $waiting = /* ... */;
}
```
La clase `Sleep` ofrece una variedad de métodos que te permiten trabajar con diferentes unidades de tiempo:


```php
// Pause execution for 90 seconds...
Sleep::for(1.5)->minutes();

// Pause execution for 2 seconds...
Sleep::for(2)->seconds();

// Pause execution for 500 milliseconds...
Sleep::for(500)->milliseconds();

// Pause execution for 5,000 microseconds...
Sleep::for(5000)->microseconds();

// Pause execution until a given time...
Sleep::until(now()->addMinute());

// Alias of PHP's native "sleep" function...
Sleep::sleep(2);

// Alias of PHP's native "usleep" function...
Sleep::usleep(5000);
```
Para combinar unidades de tiempo de manera sencilla, puedes usar el método `and`:


```php
Sleep::for(1)->second()->and(10)->milliseconds();
```

<a name="testing-sleep"></a>
#### Pruebas de Sueño

Al probar código que utiliza la clase `Sleep` o las funciones de suspensión nativas de PHP, tu prueba pausará la ejecución. Como puedes imaginar, esto hace que tu suite de pruebas sea significativamente más lenta. Por ejemplo, imagina que estás probando el siguiente código:


```php
$waiting = /* ... */;

$seconds = 1;

while ($waiting) {
    Sleep::for($seconds++)->seconds();

    $waiting = /* ... */;
}
```
Típicamente, probar este código llevaría *al menos* un segundo. Afortunadamente, la clase `Sleep` nos permite "simular" el sueño para que nuestra suite de pruebas se mantenga rápida:


```php
it('waits until ready', function () {
    Sleep::fake();

    // ...
});

```


```php
public function test_it_waits_until_ready()
{
    Sleep::fake();

    // ...
}

```
Al simular la clase `Sleep`, se evita la pausa de ejecución real, lo que conduce a una prueba sustancialmente más rápida.
Una vez que la clase `Sleep` ha sido simulada, es posible hacer afirmaciones contra los "sueños" esperados que deberían haber ocurrido. Para ilustrar esto, imaginemos que estamos probando un código que pausa la ejecución tres veces, con cada pausa aumentando en un segundo. Usando el método `assertSequence`, podemos afirmar que nuestro código "durmió" por la cantidad de tiempo adecuada mientras mantenemos nuestra prueba rápida:


```php
it('checks if ready three times', function () {
    Sleep::fake();

    // ...

    Sleep::assertSequence([
        Sleep::for(1)->second(),
        Sleep::for(2)->seconds(),
        Sleep::for(3)->seconds(),
    ]);
}

```


```php
public function test_it_checks_if_ready_three_times()
{
    Sleep::fake();

    // ...

    Sleep::assertSequence([
        Sleep::for(1)->second(),
        Sleep::for(2)->seconds(),
        Sleep::for(3)->seconds(),
    ]);
}

```
Por supuesto, la clase `Sleep` ofrece una variedad de otras afirmaciones que puedes usar al realizar pruebas:


```php
use Carbon\CarbonInterval as Duration;
use Illuminate\Support\Sleep;

// Assert that sleep was called 3 times...
Sleep::assertSleptTimes(3);

// Assert against the duration of sleep...
Sleep::assertSlept(function (Duration $duration): bool {
    return /* ... */;
}, times: 1);

// Assert that the Sleep class was never invoked...
Sleep::assertNeverSlept();

// Assert that, even if Sleep was called, no execution paused occurred...
Sleep::assertInsomniac();
```
A veces puede ser útil realizar una acción siempre que ocurra un sueño simulado en el código de tu aplicación. Para lograr esto, puedes proporcionar un callback al método `whenFakingSleep`. En el siguiente ejemplo, usamos los [ayudantes de manipulación de tiempo](/docs/%7B%7Bversion%7D%7D/mocking#interacting-with-time) de Laravel para avanzar el tiempo instantáneamente por la duración de cada sueño:


```php
use Carbon\CarbonInterval as Duration;

$this->freezeTime();

Sleep::fake();

Sleep::whenFakingSleep(function (Duration $duration) {
    // Progress time when faking sleep...
    $this->travel($duration->totalMilliseconds)->milliseconds();
});

```
A medida que el tiempo de progreso es un requisito común, el método `fake` acepta un argumento `syncWithCarbon` para mantener Carbon en sincronía cuando se hace una pausa dentro de una prueba:


```php
Sleep::fake(syncWithCarbon: true);

$start = now();

Sleep::for(1)->second();

$start->diffForHumans(); // 1 second ago

```
Laravel utiliza la clase `Sleep` internamente siempre que pausa la ejecución. Por ejemplo, el helper [`retry`](#method-retry) utiliza la clase `Sleep` al hacer una pausa, lo que permite una mejor capacidad de prueba al usar ese helper.