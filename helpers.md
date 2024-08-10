# Helpers

- [Introducción](#introduction)
- [Métodos Disponibles](#available-methods)
- [Otras Utilidades](#other-utilities)
    - [Benchmarking](#benchmarking)
    - [Fechas](#dates)
    - [Lotería](#lottery)
    - [Pipeline](#pipeline)
    - [Dormir](#sleep)

<a name="introduction"></a>
## Introducción

Laravel incluye una variedad de funciones PHP globales "helper". Muchas de estas funciones son utilizadas por el propio framework; sin embargo, eres libre de usarlas en tus propias aplicaciones si las encuentras convenientes.

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
### Arrays & Objects

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
[Arr::sortRecursiveDesc](#method-array-sort-recursive-desc)
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
### Numbers

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
[Number::useLocale](#method-number-use-locale)
[Number::withLocale](#method-number-with-locale)

</div>


<a name="paths-method-list"></a>
### Paths

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
### Miscellaneous

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
## Arrays & Objects

<a name="method-array-accessible"></a>
#### `Arr::accessible()` {.collection-method .first-collection-method}

El método `Arr::accessible` determina si el valor dado es accesible como array:

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

<a name="method-array-add"></a>
#### `Arr::add()` {.collection-method}

El método `Arr::add` agrega un par clave / valor dado a un array si la clave dada no existe ya en el array o está establecida en `null`:

    use Illuminate\Support\Arr;

    $array = Arr::add(['name' => 'Desk'], 'price', 100);

    // ['name' => 'Desk', 'price' => 100]

    $array = Arr::add(['name' => 'Desk', 'price' => null], 'price', 100);

    // ['name' => 'Desk', 'price' => 100]


<a name="method-array-collapse"></a>
#### `Arr::collapse()` {.collection-method}

El método `Arr::collapse` colapsa un array de arrays en un solo array:

    use Illuminate\Support\Arr;

    $array = Arr::collapse([[1, 2, 3], [4, 5, 6], [7, 8, 9]]);

    // [1, 2, 3, 4, 5, 6, 7, 8, 9]

<a name="method-array-crossjoin"></a>
#### `Arr::crossJoin()` {.collection-method}

El método `Arr::crossJoin` realiza un cruce de los arrays dados, devolviendo un producto cartesiano con todas las permutaciones posibles:

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

<a name="method-array-divide"></a>
#### `Arr::divide()` {.collection-method}

El método `Arr::divide` devuelve dos arrays: uno que contiene las claves y el otro que contiene los valores del array dado:

    use Illuminate\Support\Arr;

    [$keys, $values] = Arr::divide(['name' => 'Desk']);

    // $keys: ['name']

    // $values: ['Desk']

<a name="method-array-dot"></a>
#### `Arr::dot()` {.collection-method}

El método `Arr::dot` aplana un array multidimensional en un array de un solo nivel que utiliza la notación "dot" para indicar la profundidad:

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    $flattened = Arr::dot($array);

    // ['products.desk.price' => 100]

<a name="method-array-except"></a>
#### `Arr::except()` {.collection-method}

El método `Arr::except` elimina los pares clave / valor dados de un array:

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100];

    $filtered = Arr::except($array, ['price']);

    // ['name' => 'Desk']

<a name="method-array-exists"></a>
#### `Arr::exists()` {.collection-method}

El método `Arr::exists` verifica que la clave dada exista en el array proporcionado:

    use Illuminate\Support\Arr;

    $array = ['name' => 'John Doe', 'age' => 17];

    $exists = Arr::exists($array, 'name');

    // true

    $exists = Arr::exists($array, 'salary');

    // false

<a name="method-array-first"></a>
#### `Arr::first()` {.collection-method}

El método `Arr::first` devuelve el primer elemento de un array que pasa una prueba de verdad dada:

    use Illuminate\Support\Arr;

    $array = [100, 200, 300];

    $first = Arr::first($array, function (int $value, int $key) {
        return $value >= 150;
    });

    // 200

También se puede pasar un valor predeterminado como tercer parámetro al método. Este valor se devolverá si ningún valor pasa la prueba de verdad:

    use Illuminate\Support\Arr;

    $first = Arr::first($array, $callback, $default);

<a name="method-array-flatten"></a>
#### `Arr::flatten()` {.collection-method}

El método `Arr::flatten` aplana un array multidimensional en un array de un solo nivel:

    use Illuminate\Support\Arr;

    $array = ['name' => 'Joe', 'languages' => ['PHP', 'Ruby']];

    $flattened = Arr::flatten($array);

    // ['Joe', 'PHP', 'Ruby']

<a name="method-array-forget"></a>
#### `Arr::forget()` {.collection-method}

El método `Arr::forget` elimina un par clave / valor dado de un array profundamente anidado utilizando la notación "dot":

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    Arr::forget($array, 'products.desk');

    // ['products' => []]

<a name="method-array-get"></a>
#### `Arr::get()` {.collection-method}

El método `Arr::get` recupera un valor de un array profundamente anidado utilizando la notación "dot":

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    $price = Arr::get($array, 'products.desk.price');

    // 100

El método `Arr::get` también acepta un valor predeterminado, que se devolverá si la clave especificada no está presente en el array:

    use Illuminate\Support\Arr;

    $discount = Arr::get($array, 'products.desk.discount', 0);

    // 0

<a name="method-array-has"></a>
#### `Arr::has()` {.collection-method}

El método `Arr::has` verifica si un elemento o elementos dados existen en un array utilizando la notación "dot":

    use Illuminate\Support\Arr;

    $array = ['product' => ['name' => 'Desk', 'price' => 100]];

    $contains = Arr::has($array, 'product.name');

    // true

    $contains = Arr::has($array, ['product.price', 'product.discount']);

    // false

<a name="method-array-hasany"></a>
#### `Arr::hasAny()` {.collection-method}

El método `Arr::hasAny` verifica si algún elemento en un conjunto dado existe en un array utilizando la notación "dot":

    use Illuminate\Support\Arr;

    $array = ['product' => ['name' => 'Desk', 'price' => 100]];

    $contains = Arr::hasAny($array, 'product.name');

    // true

    $contains = Arr::hasAny($array, ['product.name', 'product.discount']);

    // true

    $contains = Arr::hasAny($array, ['category', 'product.discount']);

    // false

<a name="method-array-isassoc"></a>
#### `Arr::isAssoc()` {.collection-method}

El método `Arr::isAssoc` devuelve `true` si el array dado es un array asociativo. Un array se considera "asociativo" si no tiene claves numéricas secuenciales que comiencen desde cero:

    use Illuminate\Support\Arr;

    $isAssoc = Arr::isAssoc(['product' => ['name' => 'Desk', 'price' => 100]]);

    // true

    $isAssoc = Arr::isAssoc([1, 2, 3]);

    // false

<a name="method-array-islist"></a>
#### `Arr::isList()` {.collection-method}

El método `Arr::isList` devuelve `true` si las claves del array dado son enteros secuenciales que comienzan desde cero:

    use Illuminate\Support\Arr;

    $isList = Arr::isList(['foo', 'bar', 'baz']);

    // true

    $isList = Arr::isList(['product' => ['name' => 'Desk', 'price' => 100]]);

    // false

<a name="method-array-join"></a>
#### `Arr::join()` {.collection-method}

El método `Arr::join` une los elementos del array con una cadena. Usando el segundo argumento de este método, también puedes especificar la cadena de unión para el último elemento del array:

    use Illuminate\Support\Arr;

    $array = ['Tailwind', 'Alpine', 'Laravel', 'Livewire'];

    $joined = Arr::join($array, ', ');

    // Tailwind, Alpine, Laravel, Livewire

    $joined = Arr::join($array, ', ', ' and ');

    // Tailwind, Alpine, Laravel and Livewire

<a name="method-array-keyby"></a>
#### `Arr::keyBy()` {.collection-method}

El método `Arr::keyBy` asigna las claves del array por la clave dada. Si múltiples elementos tienen la misma clave, solo el último aparecerá en el nuevo array:

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

<a name="method-array-last"></a>
#### `Arr::last()` {.collection-method}

El método `Arr::last` devuelve el último elemento de un array que pasa una prueba de verdad dada:

    use Illuminate\Support\Arr;

    $array = [100, 200, 300, 110];

    $last = Arr::last($array, function (int $value, int $key) {
        return $value >= 150;
    });

    // 300

Un valor predeterminado puede ser pasado como el tercer argumento al método. Este valor se devolverá si ningún valor pasa la prueba de verdad:

    use Illuminate\Support\Arr;

    $last = Arr::last($array, $callback, $default);

<a name="method-array-map"></a>
#### `Arr::map()` {.collection-method}

El método `Arr::map` itera a través del array y pasa cada valor y clave al callback dado. El valor del array es reemplazado por el valor devuelto por el callback:

    use Illuminate\Support\Arr;

    $array = ['first' => 'james', 'last' => 'kirk'];

    $mapped = Arr::map($array, function (string $value, string $key) {
        return ucfirst($value);
    });

    // ['first' => 'James', 'last' => 'Kirk']

<a name="method-array-map-spread"></a>
#### `Arr::mapSpread()` {.collection-method}

El método `Arr::mapSpread` itera sobre el array, pasando cada valor de elemento anidado a la función anónima dada. La función anónima puede modificar el elemento y devolverlo, formando así un nuevo array de elementos modificados:

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

<a name="method-array-map-with-keys"></a>
#### `Arr::mapWithKeys()` {.collection-method}

El método `Arr::mapWithKeys` itera a través del array y pasa cada valor a la función de callback dada. La función de callback debe devolver un array asociativo que contenga un solo par clave / valor:

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

<a name="method-array-only"></a>
#### `Arr::only()` {.collection-method}

El método `Arr::only` devuelve solo los pares clave / valor especificados del array dado:

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100, 'orders' => 10];

    $slice = Arr::only($array, ['name', 'price']);

    // ['name' => 'Desk', 'price' => 100]

<a name="method-array-pluck"></a>
#### `Arr::pluck()` {.collection-method}

El método `Arr::pluck` recupera todos los valores para una clave dada de un array:

    use Illuminate\Support\Arr;

    $array = [
        ['developer' => ['id' => 1, 'name' => 'Taylor']],
        ['developer' => ['id' => 2, 'name' => 'Abigail']],
    ];

    $names = Arr::pluck($array, 'developer.name');

    // ['Taylor', 'Abigail']

También puedes especificar cómo deseas que se clave la lista resultante:

    use Illuminate\Support\Arr;

    $names = Arr::pluck($array, 'developer.name', 'developer.id');

    // [1 => 'Taylor', 2 => 'Abigail']

<a name="method-array-prepend"></a>
#### `Arr::prepend()` {.collection-method}

El método `Arr::prepend` añadirá un elemento al principio de un array:

    use Illuminate\Support\Arr;

    $array = ['one', 'two', 'three', 'four'];

    $array = Arr::prepend($array, 'zero');

    // ['zero', 'one', 'two', 'three', 'four']

Si es necesario, puedes especificar la clave que se debe usar para el valor:

    use Illuminate\Support\Arr;

    $array = ['price' => 100];

    $array = Arr::prepend($array, 'Desk', 'name');

    // ['name' => 'Desk', 'price' => 100]

<a name="method-array-prependkeyswith"></a>
#### `Arr::prependKeysWith()` {.collection-method}

El método `Arr::prependKeysWith` antepone todos los nombres de clave de un array asociativo con el prefijo dado:

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

<a name="method-array-pull"></a>
#### `Arr::pull()` {.collection-method}

El método `Arr::pull` devuelve y elimina un par clave / valor de un array:

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100];

    $name = Arr::pull($array, 'name');

    // $name: Desk

    // $array: ['price' => 100]

Se puede pasar un valor predeterminado como tercer argumento al método. Este valor se devolverá si la clave no existe:

    use Illuminate\Support\Arr;

    $value = Arr::pull($array, $key, $default);

<a name="method-array-query"></a>
#### `Arr::query()` {.collection-method}

El método `Arr::query` convierte el array en una cadena de consulta:

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

<a name="method-array-random"></a>
#### `Arr::random()` {.collection-method}

El método `Arr::random` devuelve un valor aleatorio de un array:

    use Illuminate\Support\Arr;

    $array = [1, 2, 3, 4, 5];

    $random = Arr::random($array);

    // 4 - (recuperado aleatoriamente)

También puedes especificar el número de elementos a devolver como un segundo argumento opcional. Ten en cuenta que proporcionar este argumento devolverá un array incluso si solo se desea un elemento:

    use Illuminate\Support\Arr;

    $items = Arr::random($array, 2);

    // [2, 5] - (recuperado aleatoriamente)

<a name="method-array-set"></a>
#### `Arr::set()` {.collection-method}

El método `Arr::set` establece un valor dentro de un array profundamente anidado utilizando la notación "punto":

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    Arr::set($array, 'products.desk.price', 200);

    // ['products' => ['desk' => ['price' => 200]]]

<a name="method-array-shuffle"></a>
#### `Arr::shuffle()` {.collection-method}

El método `Arr::shuffle` mezcla aleatoriamente los elementos en el array:

    use Illuminate\Support\Arr;

    $array = Arr::shuffle([1, 2, 3, 4, 5]);

    // [3, 2, 5, 1, 4] - (generado aleatoriamente)

<a name="method-array-sort"></a>
#### `Arr::sort()` {.collection-method}

El método `Arr::sort` ordena un array por sus valores:

    use Illuminate\Support\Arr;

    $array = ['Desk', 'Table', 'Chair'];

    $sorted = Arr::sort($array);

    // ['Chair', 'Desk', 'Table']

También puedes ordenar el array por los resultados de una función anónima dada:

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

<a name="method-array-sort-desc"></a>
#### `Arr::sortDesc()` {.collection-method}

El método `Arr::sortDesc` ordena un array en orden descendente por sus valores:

    use Illuminate\Support\Arr;

    $array = ['Desk', 'Table', 'Chair'];

    $sorted = Arr::sortDesc($array);

    // ['Table', 'Desk', 'Chair']

También puedes ordenar el array por los resultados de una función anónima dada:

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

<a name="method-array-sort-recursive"></a>
#### `Arr::sortRecursive()` {.collection-method}

El método `Arr::sortRecursive` ordena recursivamente un array utilizando la función `sort` para sub-arrays indexados numéricamente y la función `ksort` para sub-arrays asociativos:

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

Si deseas que los resultados se ordenen en orden descendente, puedes usar el método `Arr::sortRecursiveDesc`.

    $sorted = Arr::sortRecursiveDesc($array);

<a name="method-array-take"></a>
#### `Arr::take()` {.collection-method}

El método `Arr::take` devuelve un nuevo array con el número especificado de elementos:

    use Illuminate\Support\Arr;

    $array = [0, 1, 2, 3, 4, 5];

    $chunk = Arr::take($array, 3);

    // [0, 1, 2]

También puedes pasar un entero negativo para tomar el número especificado de elementos desde el final del array:

    $array = [0, 1, 2, 3, 4, 5];

    $chunk = Arr::take($array, -2);

    // [4, 5]

<a name="method-array-to-css-classes"></a>
#### `Arr::toCssClasses()` {.collection-method}

El método `Arr::toCssClasses` compila condicionalmente una cadena de clase CSS. El método acepta un array de clases donde la clave del array contiene la clase o clases que deseas agregar, mientras que el valor es una expresión booleana. Si el elemento del array tiene una clave numérica, siempre se incluirá en la lista de clases renderizadas:

    use Illuminate\Support\Arr;

    $isActive = false;
    $hasError = true;

    $array = ['p-4', 'font-bold' => $isActive, 'bg-red' => $hasError];

    $classes = Arr::toCssClasses($array);

    /*
        'p-4 bg-red'
    */

<a name="method-array-to-css-styles"></a>
#### `Arr::toCssStyles()` {.collection-method}

El método `Arr::toCssStyles` compila condicionalmente una cadena de estilo CSS. El método acepta un array de clases donde la clave del array contiene la clase o clases que deseas agregar, mientras que el valor es una expresión booleana. Si el elemento del array tiene una clave numérica, siempre se incluirá en la lista de clases renderizadas:

```php
use Illuminate\Support\Arr;

$hasColor = true;

$array = ['background-color: blue', 'color: blue' => $hasColor];

$classes = Arr::toCssStyles($array);

/*
    'background-color: blue; color: blue;'
*/
```

Este método potencia la funcionalidad de Laravel que permite [fusionar clases con la bolsa de atributos de un componente Blade](/docs/{{version}}/blade#conditionally-merge-classes) así como la directiva `@class` [Blade](/docs/{{version}}/blade#conditional-classes).

<a name="method-array-undot"></a>
#### `Arr::undot()` {.collection-method}

El método `Arr::undot` expande un array unidimensional que utiliza la notación "punto" en un array multidimensional:

    use Illuminate\Support\Arr;

    $array = [
        'user.name' => 'Kevin Malone',
        'user.occupation' => 'Accountant',
    ];

    $array = Arr::undot($array);

    // ['user' => ['name' => 'Kevin Malone', 'occupation' => 'Accountant']]

<a name="method-array-where"></a>
#### `Arr::where()` {.collection-method}

El método `Arr::where` filtra un array utilizando la función anónima dada:

    use Illuminate\Support\Arr;

    $array = [100, '200', 300, '400', 500];

    $filtered = Arr::where($array, function (string|int $value, int $key) {
        return is_string($value);
    });

    // [1 => '200', 3 => '400']

<a name="method-array-where-not-null"></a>
#### `Arr::whereNotNull()` {.collection-method}

El método `Arr::whereNotNull` elimina todos los valores `null` del array dado:

    use Illuminate\Support\Arr;

    $array = [0, null];

    $filtered = Arr::whereNotNull($array);

    // [0 => 0]

<a name="method-array-wrap"></a>
#### `Arr::wrap()` {.collection-method}

El método `Arr::wrap` envuelve el valor dado en un array. Si el valor dado ya es un array, se devolverá sin modificación:

    use Illuminate\Support\Arr;

    $string = 'Laravel';

    $array = Arr::wrap($string);

    // ['Laravel']

Si el valor dado es `null`, se devolverá un array vacío:

    use Illuminate\Support\Arr;

    $array = Arr::wrap(null);

    // []

<a name="method-data-fill"></a>
#### `data_fill()` {.collection-method}

La función `data_fill` establece un valor faltante dentro de un array o objeto anidado utilizando la notación "punto":

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_fill($data, 'products.desk.price', 200);

    // ['products' => ['desk' => ['price' => 100]]]

    data_fill($data, 'products.desk.discount', 10);

    // ['products' => ['desk' => ['price' => 100, 'discount' => 10]]]

Esta función también acepta asteriscos como comodines y llenará el objetivo en consecuencia:

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

<a name="method-data-get"></a>
#### `data_get()` {.collection-method}

La función `data_get` recupera un valor de un array o objeto anidado utilizando la notación "punto":

    $data = ['products' => ['desk' => ['price' => 100]]];

    $price = data_get($data, 'products.desk.price');

    // 100

La función `data_get` también acepta un valor predeterminado, que se devolverá si la clave especificada no se encuentra:

    $discount = data_get($data, 'products.desk.discount', 0);

    // 0

La función también acepta comodines utilizando asteriscos, que pueden dirigirse a cualquier clave del array o objeto:

    $data = [
        'product-one' => ['name' => 'Desk 1', 'price' => 100],
        'product-two' => ['name' => 'Desk 2', 'price' => 150],
    ];

    data_get($data, '*.name');

    // ['Desk 1', 'Desk 2'];

Los marcadores de posición `{first}` y `{last}` pueden usarse para recuperar los primeros o últimos elementos en un array:

    $flight = [
        'segments' => [
            ['from' => 'LHR', 'departure' => '9:00', 'to' => 'IST', 'arrival' => '15:00'],
            ['from' => 'IST', 'departure' => '16:00', 'to' => 'PKX', 'arrival' => '20:00'],
        ],
    ];

    data_get($flight, 'segments.{first}.arrival');

    // 15:00

<a name="method-data-set"></a>
#### `data_set()` {.collection-method}

La función `data_set` establece un valor dentro de un array o objeto anidado utilizando la notación "punto":

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_set($data, 'products.desk.price', 200);

    // ['products' => ['desk' => ['price' => 200]]]

Esta función también acepta comodines utilizando asteriscos y establecerá valores en el objetivo en consecuencia:

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

Por defecto, se sobrescriben los valores existentes. Si deseas establecer un valor solo si no existe, puedes pasar `false` como cuarto argumento a la función:

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_set($data, 'products.desk.price', 200, overwrite: false);

    // ['products' => ['desk' => ['price' => 100]]]

<a name="method-data-forget"></a>
#### `data_forget()` {.collection-method}

La función `data_forget` elimina un valor dentro de un array o objeto anidado utilizando la notación "punto":

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_forget($data, 'products.desk.price');

    // ['products' => ['desk' => []]]

Esta función también acepta comodines utilizando asteriscos y eliminará valores en el objetivo en consecuencia:

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

<a name="method-head"></a>
#### `head()` {.collection-method}

La función `head` devuelve el primer elemento en el array dado:

    $array = [100, 200, 300];

    $first = head($array);

    // 100

<a name="method-last"></a>
#### `last()` {.collection-method}

La función `last` devuelve el último elemento en el array dado:

    $array = [100, 200, 300];

    $last = last($array);

    // 300

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

    use Illuminate\Support\Number;

    $number = Number::clamp(105, min: 10, max: 100);

    // 100

    $number = Number::clamp(5, min: 10, max: 100);

    // 10

    $number = Number::clamp(10, min: 10, max: 100);

    // 10

    $number = Number::clamp(20, min: 10, max: 100);

    // 20

<a name="method-number-currency"></a>
#### `Number::currency()` {.collection-method}

El método `Number::currency` devuelve la representación de moneda del valor dado como una cadena:

    use Illuminate\Support\Number;

    $currency = Number::currency(1000);

    // $1,000.00

    $currency = Number::currency(1000, in: 'EUR');

    // €1,000.00

    $currency = Number::currency(1000, in: 'EUR', locale: 'de');

    // 1.000,00 €

<a name="method-number-file-size"></a>
#### `Number::fileSize()` {.collection-method}

El método `Number::fileSize` devuelve la representación del tamaño del archivo del valor en bytes dado como una cadena:

    use Illuminate\Support\Number;

    $size = Number::fileSize(1024);

    // 1 KB

    $size = Number::fileSize(1024 * 1024);

    // 1 MB

    $size = Number::fileSize(1024, precision: 2);

    // 1.00 KB

<a name="method-number-for-humans"></a>
#### `Number::forHumans()` {.collection-method}

El método `Number::forHumans` devuelve el formato legible por humanos del valor numérico proporcionado:

    use Illuminate\Support\Number;

    $number = Number::forHumans(1000);

    // 1 mil

    $number = Number::forHumans(489939);

    // 490 mil

    $number = Number::forHumans(1230000, precision: 2);

    // 1.23 millón

<a name="method-number-format"></a>
#### `Number::format()` {.collection-method}

El método `Number::format` formatea el número dado en una cadena específica de la localidad:

    use Illuminate\Support\Number;

    $number = Number::format(100000);

    // 100,000

    $number = Number::format(100000, precision: 2);

    // 100,000.00

    $number = Number::format(100000.123, maxPrecision: 2);

    // 100,000.12

    $number = Number::format(100000, locale: 'de');

    // 100.000

<a name="method-number-ordinal"></a>
#### `Number::ordinal()` {.collection-method}

El método `Number::ordinal` devuelve la representación ordinal de un número:

    use Illuminate\Support\Number;

    $number = Number::ordinal(1);

    // 1º

    $number = Number::ordinal(2);

    // 2º

    $number = Number::ordinal(21);

    // 21º

<a name="method-number-pairs"></a>
#### `Number::pairs()` {.collection-method}

El método `Number::pairs` genera un array de pares de números (sub-rangos) basado en un rango y un valor de paso especificados. Este método puede ser útil para dividir un rango más grande de números en sub-rangos más pequeños y manejables para cosas como la paginación o el procesamiento por lotes. El método `pairs` devuelve un array de arrays, donde cada array interno representa un par (sub-rango) de números:

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

    use Illuminate\Support\Number;

    $percentage = Number::percentage(10);

    // 10%

    $percentage = Number::percentage(10, precision: 2);

    // 10.00%

    $percentage = Number::percentage(10.123, maxPrecision: 2);

    // 10.12%

    $percentage = Number::percentage(10, precision: 2, locale: 'de');

    // 10,00%

<a name="method-number-spell"></a>
#### `Number::spell()` {.collection-method}

El método `Number::spell` transforma el número dado en una cadena de palabras:

    use Illuminate\Support\Number;

    $number = Number::spell(102);

    // ciento dos

    $number = Number::spell(88, locale: 'fr');

    // quatre-vingt-huit


El argumento `after` te permite especificar un valor después del cual todos los números deben ser escritos:

    $number = Number::spell(10, after: 10);

    // 10

    $number = Number::spell(11, after: 10);

    // once

El argumento `until` te permite especificar un valor antes del cual todos los números deben ser escritos:

    $number = Number::spell(5, until: 10);

    // cinco

    $number = Number::spell(10, until: 10);

    // 10

<a name="method-number-use-locale"></a>
#### `Number::useLocale()` {.collection-method}

El método `Number::useLocale` establece la configuración regional de números predeterminada globalmente, lo que afecta cómo se formatean los números y la moneda en las invocaciones posteriores a los métodos de la clase `Number`:

    use Illuminate\Support\Number;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Number::useLocale('de');
    }

<a name="method-number-with-locale"></a>
#### `Number::withLocale()` {.collection-method}

El método `Number::withLocale` ejecuta la función anónima dada utilizando la configuración regional especificada y luego restaura la configuración regional original después de que se haya ejecutado la devolución de llamada:

    use Illuminate\Support\Number;

    $number = Number::withLocale('de', function () {
        return Number::format(1500);
    });

<a name="paths"></a>
## Paths

<a name="method-app-path"></a>
#### `app_path()` {.collection-method}

La función `app_path` devuelve la ruta completamente calificada a tu directorio `app` de la aplicación. También puedes usar la función `app_path` para generar una ruta completamente calificada a un archivo relativo al directorio de la aplicación:

    $path = app_path();

    $path = app_path('Http/Controllers/Controller.php');

<a name="method-base-path"></a>
#### `base_path()` {.collection-method}

La función `base_path` devuelve la ruta completamente calificada a la raíz de tu aplicación. También puedes usar la función `base_path` para generar una ruta completamente calificada a un archivo dado relativo al directorio raíz del proyecto:

    $path = base_path();

    $path = base_path('vendor/bin');

<a name="method-config-path"></a>
#### `config_path()` {.collection-method}

La función `config_path` devuelve la ruta completamente calificada a tu directorio `config` de la aplicación. También puedes usar la función `config_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio de configuración de la aplicación:

    $path = config_path();

    $path = config_path('app.php');

<a name="method-database-path"></a>
#### `database_path()` {.collection-method}

La función `database_path` devuelve la ruta completamente calificada a tu directorio `database` de la aplicación. También puedes usar la función `database_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio de la base de datos:

    $path = database_path();

    $path = database_path('factories/UserFactory.php');

<a name="method-lang-path"></a>
#### `lang_path()` {.collection-method}

La función `lang_path` devuelve la ruta completamente calificada a tu directorio `lang` de la aplicación. También puedes usar la función `lang_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio:

    $path = lang_path();

    $path = lang_path('en/messages.php');

> [!NOTE]  
> Por defecto, el esqueleto de la aplicación Laravel no incluye el directorio `lang`. Si deseas personalizar los archivos de idioma de Laravel, puedes publicarlos a través del comando Artisan `lang:publish`.

<a name="method-mix"></a>
#### `mix()` {.collection-method}

La función `mix` devuelve la ruta a un [archivo Mix versionado](/docs/{{version}}/mix):

    $path = mix('css/app.css');

<a name="method-public-path"></a>
#### `public_path()` {.collection-method}

La función `public_path` devuelve la ruta completamente calificada a tu directorio `public` de la aplicación. También puedes usar la función `public_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio público:

    $path = public_path();

    $path = public_path('css/app.css');

<a name="method-resource-path"></a>
#### `resource_path()` {.collection-method}

La función `resource_path` devuelve la ruta completamente calificada a tu directorio `resources` de la aplicación. También puedes usar la función `resource_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio de recursos:

    $path = resource_path();

    $path = resource_path('sass/app.scss');

<a name="method-storage-path"></a>
#### `storage_path()` {.collection-method}

La función `storage_path` devuelve la ruta completamente calificada a tu directorio `storage` de la aplicación. También puedes usar la función `storage_path` para generar una ruta completamente calificada a un archivo dado dentro del directorio de almacenamiento:

    $path = storage_path();

    $path = storage_path('app/file.txt');

<a name="urls"></a>
## URLs

<a name="method-action"></a>
#### `action()` {.collection-method}

La función `action` genera una URL para la acción del controlador dada:

    use App\Http\Controllers\HomeController;

    $url = action([HomeController::class, 'index']);

Si el método acepta parámetros de ruta, puedes pasarlos como el segundo argumento al método:

    $url = action([UserController::class, 'profile'], ['id' => 1]);

<a name="method-asset"></a>
#### `asset()` {.collection-method}

La función `asset` genera una URL para un recurso utilizando el esquema actual de la solicitud (HTTP o HTTPS):

    $url = asset('img/photo.jpg');

Puedes configurar el host de la URL del recurso estableciendo la variable `ASSET_URL` en tu archivo `.env`. Esto puede ser útil si alojas tus recursos en un servicio externo como Amazon S3 o en otro CDN:

    // ASSET_URL=http://example.com/assets

    $url = asset('img/photo.jpg'); // http://example.com/assets/img/photo.jpg

<a name="method-route"></a>
#### `route()` {.collection-method}

La función `route` genera una URL para una [ruta nombrada](/docs/{{version}}/routing#named-routes):

    $url = route('route.name');

Si la ruta acepta parámetros, puedes pasarlos como el segundo argumento a la función:

    $url = route('route.name', ['id' => 1]);

Por defecto, la función `route` genera una URL absoluta. Si deseas generar una URL relativa, puedes pasar `false` como el tercer argumento a la función:

    $url = route('route.name', ['id' => 1], false);

<a name="method-secure-asset"></a>
#### `secure_asset()` {.collection-method}

La función `secure_asset` genera una URL para un recurso utilizando HTTPS:

    $url = secure_asset('img/photo.jpg');

<a name="method-secure-url"></a>
#### `secure_url()` {.collection-method}

La función `secure_url` genera una URL HTTPS completamente calificada para la ruta dada. Se pueden pasar segmentos adicionales de URL como el segundo argumento de la función:

    $url = secure_url('user/profile');

    $url = secure_url('user/profile', [1]);

<a name="method-to-route"></a>
#### `to_route()` {.collection-method}

La función `to_route` genera una [respuesta HTTP de redirección](/docs/{{version}}/responses#redirects) para una [ruta nombrada](/docs/{{version}}/routing#named-routes):

    return to_route('users.show', ['user' => 1]);

Si es necesario, puedes pasar el código de estado HTTP que se debe asignar a la redirección y cualquier encabezado de respuesta adicional como el tercer y cuarto argumento al método `to_route`:

    return to_route('users.show', ['user' => 1], 302, ['X-Framework' => 'Laravel']);

<a name="method-url"></a>
#### `url()` {.collection-method}

La función `url` genera una URL completamente calificada para la ruta dada:

    $url = url('user/profile');

    $url = url('user/profile', [1]);

Si no se proporciona ninguna ruta, se devuelve una instancia de `Illuminate\Routing\UrlGenerator`:

    $current = url()->current();

    $full = url()->full();

    $previous = url()->previous();

<a name="miscellaneous"></a>
## Miscellaneous

<a name="method-abort"></a>
#### `abort()` {.collection-method}

La función `abort` lanza [una excepción HTTP](/docs/{{version}}/errors#http-exceptions) que será renderizada por el [manejador de excepciones](/docs/{{version}}/errors#the-exception-handler):

    abort(403);

También puedes proporcionar el mensaje de la excepción y los encabezados de respuesta HTTP personalizados que deben enviarse al navegador:

    abort(403, 'Unauthorized.', $headers);

<a name="method-abort-if"></a>
#### `abort_if()` {.collection-method}

La función `abort_if` lanza una excepción HTTP si una expresión booleana dada evalúa a `true`:

    abort_if(! Auth::user()->isAdmin(), 403);

Al igual que el método `abort`, también puedes proporcionar el texto de respuesta de la excepción como el tercer argumento y un array de encabezados de respuesta personalizados como el cuarto argumento a la función.

<a name="method-abort-unless"></a>
#### `abort_unless()` {.collection-method}

La función `abort_unless` lanza una excepción HTTP si una expresión booleana dada evalúa a `false`:

    abort_unless(Auth::user()->isAdmin(), 403);

Al igual que el método `abort`, también puedes proporcionar el texto de respuesta de la excepción como el tercer argumento y un array de encabezados de respuesta personalizados como el cuarto argumento a la función.

<a name="method-app"></a>
#### `app()` {.collection-method}

La función `app` devuelve la instancia del [contenedor de servicios](/docs/{{version}}/container):

    $container = app();

Puedes pasar un nombre de clase o interfaz para resolverlo desde el contenedor:

    $api = app('HelpSpot\API');

<a name="method-auth"></a>
#### `auth()` {.collection-method}

La función `auth` devuelve una instancia de [autenticador](/docs/{{version}}/authentication). Puedes usarla como una alternativa a la fachada `Auth`:

    $user = auth()->user();

Si es necesario, puedes especificar qué instancia de guard deseas acceder:

    $user = auth('admin')->user();

<a name="method-back"></a>
#### `back()` {.collection-method}

La función `back` genera una [respuesta HTTP de redirección](/docs/{{version}}/responses#redirects) a la ubicación anterior del usuario:

    return back($status = 302, $headers = [], $fallback = '/');

    return back();

<a name="method-bcrypt"></a>
#### `bcrypt()` {.collection-method}

La función `bcrypt` [hashes](/docs/{{version}}/hashing) el valor dado utilizando Bcrypt. Puedes usar esta función como una alternativa a la fachada `Hash`:

    $password = bcrypt('my-secret-password');

<a name="method-blank"></a>
#### `blank()` {.collection-method}

La función `blank` determina si el valor dado es "vacío":

    blank('');
    blank('   ');
    blank(null);
    blank(collect());

    // true

    blank(0);
    blank(true);
    blank(false);

    // false

Para la inversa de `blank`, consulta el método [`filled`](#method-filled).

<a name="method-broadcast"></a>
#### `broadcast()` {.collection-method}

La función `broadcast` [broadcasts](/docs/{{version}}/broadcasting) el [evento](/docs/{{version}}/events) dado a sus oyentes:

    broadcast(new UserRegistered($user));

    broadcast(new UserRegistered($user))->toOthers();
    
<a name="method-cache"></a>
#### `cache()` {.collection-method}

La función `cache` puede ser utilizada para obtener valores de la [cache](/docs/{{version}}/cache). Si la clave dada no existe en la cache, se devolverá un valor predeterminado opcional:

    $value = cache('key');

    $value = cache('key', 'default');

Puedes agregar elementos a la cache pasando un array de pares clave / valor a la función. También debes pasar el número de segundos o la duración que el valor en cache debe considerarse válido:
```

```php
    cache(['key' => 'value'], 300);

    cache(['key' => 'value'], now()->addSeconds(10));
```

<a name="method-class-uses-recursive"></a>
#### `class_uses_recursive()` {.collection-method}

La función `class_uses_recursive` devuelve todos los traits utilizados por una clase, incluidos los traits utilizados por todas sus clases padre:

    $traits = class_uses_recursive(App\Models\User::class);

<a name="method-collect"></a>
#### `collect()` {.collection-method}

La función `collect` crea una instancia de [colección](/docs/{{version}}/collections) a partir del valor dado:

    $collection = collect(['taylor', 'abigail']);

<a name="method-config"></a>
#### `config()` {.collection-method}

La función `config` obtiene el valor de una variable de [configuración](/docs/{{version}}/configuration). Los valores de configuración se pueden acceder utilizando la sintaxis de "punto", que incluye el nombre del archivo y la opción que deseas acceder. Se puede especificar un valor predeterminado y se devuelve si la opción de configuración no existe:

    $value = config('app.timezone');

    $value = config('app.timezone', $default);

Puedes establecer variables de configuración en tiempo de ejecución pasando un array de pares clave / valor. Sin embargo, ten en cuenta que esta función solo afecta el valor de configuración para la solicitud actual y no actualiza tus valores de configuración reales:

    config(['app.debug' => true]);

<a name="method-context"></a>
#### `context()` {.collection-method}

La función `context` obtiene el valor del [contexto actual](/docs/{{version}}/context). Se puede especificar un valor predeterminado y se devuelve si la clave del contexto no existe:

    $value = context('trace_id');

    $value = context('trace_id', $default);

Puedes establecer valores de contexto pasando un array de pares clave / valor:

    use Illuminate\Support\Str;

    context(['trace_id' => Str::uuid()->toString()]);

<a name="method-cookie"></a>
#### `cookie()` {.collection-method}

La función `cookie` crea una nueva instancia de [cookie](/docs/{{version}}/requests#cookies):

    $cookie = cookie('name', 'value', $minutes);

<a name="method-csrf-field"></a>
#### `csrf_field()` {.collection-method}

La función `csrf_field` genera un campo de entrada HTML `hidden` que contiene el valor del token CSRF. Por ejemplo, usando [sintaxis de Blade](/docs/{{version}}/blade):

    {{ csrf_field() }}

<a name="method-csrf-token"></a>
#### `csrf_token()` {.collection-method}

La función `csrf_token` recupera el valor del token CSRF actual:

    $token = csrf_token();

<a name="method-decrypt"></a>
#### `decrypt()` {.collection-method}

La función `decrypt` [desencripta](/docs/{{version}}/encryption) el valor dado. Puedes usar esta función como una alternativa a la fachada `Crypt`:

    $password = decrypt($value);

<a name="method-dd"></a>
#### `dd()` {.collection-method}

La función `dd` muestra las variables dadas y finaliza la ejecución del script:

    dd($value);

    dd($value1, $value2, $value3, ...);

Si no deseas detener la ejecución de tu script, usa la función [`dump`](#method-dump) en su lugar.

<a name="method-dispatch"></a>
#### `dispatch()` {.collection-method}

La función `dispatch` envía el [trabajo](/docs/{{version}}/queues#creating-jobs) dado a la [cola de trabajos](/docs/{{version}}/queues) de Laravel:

    dispatch(new App\Jobs\SendEmails);

<a name="method-dispatch-sync"></a>
#### `dispatch_sync()` {.collection-method}

La función `dispatch_sync` envía el trabajo dado a la cola [sync](/docs/{{version}}/queues#synchronous-dispatching) para que se procese de inmediato:

    dispatch_sync(new App\Jobs\SendEmails);

<a name="method-dump"></a>
#### `dump()` {.collection-method}

La función `dump` muestra las variables dadas:

    dump($value);

    dump($value1, $value2, $value3, ...);

Si deseas detener la ejecución del script después de mostrar las variables, usa la función [`dd`](#method-dd) en su lugar.

<a name="method-encrypt"></a>
#### `encrypt()` {.collection-method}

La función `encrypt` [encripta](/docs/{{version}}/encryption) el valor dado. Puedes usar esta función como una alternativa a la fachada `Crypt`:

    $secret = encrypt('my-secret-value');

<a name="method-env"></a>
#### `env()` {.collection-method}

La función `env` recupera el valor de una [variable de entorno](/docs/{{version}}/configuration#environment-configuration) o devuelve un valor predeterminado:

    $env = env('APP_ENV');

    $env = env('APP_ENV', 'production');

> [!WARNING]  
> Si ejecutas el comando `config:cache` durante tu proceso de despliegue, debes asegurarte de que solo estás llamando a la función `env` desde dentro de tus archivos de configuración. Una vez que la configuración ha sido almacenada en caché, el archivo `.env` no se cargará y todas las llamadas a la función `env` devolverán `null`.

<a name="method-event"></a>
#### `event()` {.collection-method}

La función `event` despacha el [evento](/docs/{{version}}/events) dado a sus oyentes:

    event(new UserRegistered($user));

<a name="method-fake"></a>
#### `fake()` {.collection-method}

La función `fake` resuelve un singleton de [Faker](https://github.com/FakerPHP/Faker) del contenedor, lo que puede ser útil al crear datos falsos en factories de modelos, siembra de bases de datos, pruebas y prototipado de vistas:

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

    fake('nl_NL')->name()

<a name="method-filled"></a>
#### `filled()` {.collection-method}

La función `filled` determina si el valor dado no está "vacío":

    filled(0);
    filled(true);
    filled(false);

    // true

    filled('');
    filled('   ');
    filled(null);
    filled(collect());

    // false

Para el inverso de `filled`, consulta el método [`blank`](#method-blank).

<a name="method-info"></a>
#### `info()` {.collection-method}

La función `info` escribirá información en el [registro](/docs/{{version}}/logging) de tu aplicación:

    info('¡Alguna información útil!');

También se puede pasar un array de datos contextuales a la función:

    info('El intento de inicio de sesión del usuario falló.', ['id' => $user->id]);

<a name="method-literal"></a>
#### `literal()` {.collection-method}

La función `literal` crea una nueva instancia de [stdClass](https://www.php.net/manual/en/class.stdclass.php) con los argumentos nombrados dados como propiedades:

    $obj = literal(
        name: 'Joe',
        languages: ['PHP', 'Ruby'],
    );

    $obj->name; // 'Joe'
    $obj->languages; // ['PHP', 'Ruby']

<a name="method-logger"></a>
#### `logger()` {.collection-method}

La función `logger` se puede usar para escribir un mensaje de nivel `debug` en el [registro](/docs/{{version}}/logging):

    logger('Mensaje de depuración');

También se puede pasar un array de datos contextuales a la función:

    logger('El usuario ha iniciado sesión.', ['id' => $user->id]);

Se devolverá una instancia de [logger](/docs/{{version}}/errors#logging) si no se pasa ningún valor a la función:

    logger()->error('No tienes permiso para estar aquí.');

<a name="method-method-field"></a>
#### `method_field()` {.collection-method}

La función `method_field` genera un campo de entrada HTML `hidden` que contiene el valor simulado del verbo HTTP del formulario. Por ejemplo, usando [sintaxis de Blade](/docs/{{version}}/blade):

    <form method="POST">
        {{ method_field('DELETE') }}
    </form>

<a name="method-now"></a>
#### `now()` {.collection-method}

La función `now` crea una nueva instancia de `Illuminate\Support\Carbon` para la hora actual:

    $now = now();

<a name="method-old"></a>
#### `old()` {.collection-method}

La función `old` [recupera](/docs/{{version}}/requests#retrieving-input) un valor de [entrada antigua](/docs/{{version}}/requests#old-input) que se ha almacenado en la sesión:

    $value = old('value');

    $value = old('value', 'default');

Dado que el "valor predeterminado" proporcionado como segundo argumento a la función `old` es a menudo un atributo de un modelo Eloquent, Laravel te permite simplemente pasar el modelo Eloquent completo como segundo argumento a la función `old`. Al hacerlo, Laravel asumirá que el primer argumento proporcionado a la función `old` es el nombre del atributo Eloquent que debe considerarse como el "valor predeterminado":

    {{ old('name', $user->name) }}

    // Es equivalente a...

    {{ old('name', $user) }}

<a name="method-once"></a>
#### `once()` {.collection-method}

La función `once` ejecuta el callback dado y almacena el resultado en memoria durante la duración de la solicitud. Cualquier llamada subsiguiente a la función `once` con el mismo callback devolverá el resultado almacenado previamente:

    function random(): int
    {
        return once(function () {
            return random_int(1, 1000);
        });
    }

    random(); // 123
    random(); // 123 (resultado en caché)
    random(); // 123 (resultado en caché)

Cuando la función `once` se ejecuta desde dentro de una instancia de objeto, el resultado en caché será único para esa instancia de objeto:

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

    return optional($user->address)->street;

    {!! old('name', optional($user)->name) !!}

La función `optional` también acepta una función anónima como su segundo argumento. La función anónima se invocará si el valor proporcionado como primer argumento no es nulo:

    return optional(User::find($id), function (User $user) {
        return $user->name;
    });

<a name="method-policy"></a>
#### `policy()` {.collection-method}

El método `policy` recupera una instancia de [policy](/docs/{{version}}/authorization#creating-policies) para una clase dada:

    $policy = policy(App\Models\User::class);

<a name="method-redirect"></a>
#### `redirect()` {.collection-method}

La función `redirect` devuelve una [respuesta HTTP de redirección](/docs/{{version}}/responses#redirects), o devuelve la instancia de redirección si se llama sin argumentos:

    return redirect($to = null, $status = 302, $headers = [], $https = null);

    return redirect('/home');

    return redirect()->route('route.name');

<a name="method-report"></a>
#### `report()` {.collection-method}

La función `report` informará una excepción utilizando tu [manejador de excepciones](/docs/{{version}}/errors#the-exception-handler):

    report($e);

La función `report` también acepta una cadena como argumento. Cuando se le da una cadena a la función, esta creará una excepción con la cadena dada como su mensaje:

    report('Algo salió mal.');

<a name="method-report-if"></a>
#### `report_if()` {.collection-method}

La función `report_if` informará una excepción utilizando tu [manejador de excepciones](/docs/{{version}}/errors#the-exception-handler) si la condición dada es `true`:

    report_if($shouldReport, $e);

    report_if($shouldReport, 'Algo salió mal.');

<a name="method-report-unless"></a>
#### `report_unless()` {.collection-method}

La función `report_unless` informará una excepción utilizando tu [manejador de excepciones](/docs/{{version}}/errors#the-exception-handler) si la condición dada es `false`:

    report_unless($reportingDisabled, $e);

    report_unless($reportingDisabled, 'Algo salió mal.');

<a name="method-request"></a>
#### `request()` {.collection-method}

La función `request` devuelve la instancia de la [solicitud](/docs/{{version}}/requests) actual o obtiene el valor de un campo de entrada de la solicitud actual:

    $request = request();

    $value = request('key', $default);

<a name="method-rescue"></a>
#### `rescue()` {.collection-method}

La función `rescue` ejecuta la función anónima dada y captura cualquier excepción que ocurra durante su ejecución. Todas las excepciones que se capturan se enviarán a tu [manejador de excepciones](/docs/{{version}}/errors#the-exception-handler); sin embargo, la solicitud continuará procesándose:

    return rescue(function () {
        return $this->method();
    });

También puedes pasar un segundo argumento a la función `rescue`. Este argumento será el valor "predeterminado" que se debe devolver si ocurre una excepción mientras se ejecuta la función anónima:

    return rescue(function () {
        return $this->method();
    }, false);

    return rescue(function () {
        return $this->method();
    }, function () {
        return $this->failure();
    });

Se puede proporcionar un argumento `report` a la función `rescue` para determinar si la excepción debe ser informada a través de la función `report`:

    return rescue(function () {
        return $this->method();
    }, report: function (Throwable $throwable) {
        return $throwable instanceof InvalidArgumentException;
    });

<a name="method-resolve"></a>
#### `resolve()` {.collection-method}

La función `resolve` resuelve un nombre de clase o interfaz dado a una instancia utilizando el [contenedor de servicios](/docs/{{version}}/container):

    $api = resolve('HelpSpot\API');

<a name="method-response"></a>
#### `response()` {.collection-method}

La función `response` crea una instancia de [respuesta](/docs/{{version}}/responses) o obtiene una instancia de la fábrica de respuestas:

    return response('Hello World', 200, $headers);

    return response()->json(['foo' => 'bar'], 200, $headers);

<a name="method-retry"></a>
#### `retry()` {.collection-method}

La función `retry` intenta ejecutar el callback dado hasta que se alcance el umbral máximo de intentos. Si el callback no lanza una excepción, su valor de retorno será devuelto. Si el callback lanza una excepción, se volverá a intentar automáticamente. Si se excede el conteo máximo de intentos, se lanzará la excepción:

    return retry(5, function () {
        // Intentar 5 veces mientras se descansa 100ms entre intentos...
    }, 100);

Si deseas calcular manualmente el número de milisegundos para dormir entre intentos, puedes pasar una función anónima como tercer argumento a la función `retry`:

    use Exception;

    return retry(5, function () {
        // ...
    }, function (int $attempt, Exception $exception) {
        return $attempt * 100;
    });

Para conveniencia, puedes proporcionar un array como primer argumento a la función `retry`. Este array se utilizará para determinar cuántos milisegundos dormir entre intentos subsiguientes:

    return retry([100, 200], function () {
        // Dormir 100ms en el primer reintento, 200ms en el segundo reintento...
    });

Para solo reintentar bajo condiciones específicas, puedes pasar una función anónima como cuarto argumento a la función `retry`:

    use Exception;

    return retry(5, function () {
        // ...
    }, 100, function (Exception $exception) {
        return $exception instanceof RetryException;
    });

<a name="method-session"></a>
#### `session()` {.collection-method}

La función `session` se puede usar para obtener o establecer valores de [sesión](/docs/{{version}}/session):

    $value = session('key');

Puedes establecer valores pasando un array de pares clave / valor a la función:

    session(['chairs' => 7, 'instruments' => 3]);

Se devolverá el almacenamiento de sesión si no se pasa ningún valor a la función:

    $value = session()->get('key');

    session()->put('key', $value);

<a name="method-tap"></a>
#### `tap()` {.collection-method}

La función `tap` acepta dos argumentos: un `$value` arbitrario y una función anónima. El `$value` se pasará a la función anónima y luego será devuelto por la función `tap`. El valor de retorno de la función anónima es irrelevante:

    $user = tap(User::first(), function (User $user) {
        $user->name = 'taylor';

        $user->save();
    });

Si no se pasa ninguna función anónima a la función `tap`, puedes llamar a cualquier método en el `$value` dado. El valor de retorno del método que llames siempre será `$value`, independientemente de lo que el método realmente devuelva en su definición. Por ejemplo, el método `update` de Eloquent típicamente devuelve un entero. Sin embargo, podemos forzar al método a devolver el modelo en sí encadenando la llamada al método `update` a través de la función `tap`:

    $user = tap($user)->update([
        'name' => $name,
        'email' => $email,
    ]);

Para agregar un método `tap` a una clase, puedes agregar el trait `Illuminate\Support\Traits\Tappable` a la clase. El método `tap` de este trait acepta una Closure como su único argumento. La instancia del objeto en sí se pasará a la Closure y luego será devuelta por el método `tap`:

    return $user->tap(function (User $user) {
        // ...
    });

<a name="method-throw-if"></a>
#### `throw_if()` {.collection-method}

La función `throw_if` lanza la excepción dada si una expresión booleana dada evalúa a `true`:

    throw_if(! Auth::user()->isAdmin(), AuthorizationException::class);

    throw_if(
        ! Auth::user()->isAdmin(),
        AuthorizationException::class,
        'No tienes permiso para acceder a esta página.'
    );

<a name="method-throw-unless"></a>
#### `throw_unless()` {.collection-method}

La función `throw_unless` lanza la excepción dada si una expresión booleana dada evalúa a `false`:

    throw_unless(Auth::user()->isAdmin(), AuthorizationException::class);

    throw_unless(
        Auth::user()->isAdmin(),
        AuthorizationException::class,
        'No tienes permiso para acceder a esta página.'
    );

<a name="method-today"></a>
#### `today()` {.collection-method}

La función `today` crea una nueva instancia de `Illuminate\Support\Carbon` para la fecha actual:

    $today = today();

<a name="method-trait-uses-recursive"></a>
#### `trait_uses_recursive()` {.collection-method}

La función `trait_uses_recursive` devuelve todos los traits utilizados por un trait:

    $traits = trait_uses_recursive(\Illuminate\Notifications\Notifiable::class);

<a name="method-transform"></a>
#### `transform()` {.collection-method}

La función `transform` ejecuta una función anónima en un valor dado si el valor no está [en blanco](#method-blank) y luego devuelve el valor de retorno de la función anónima:

    $callback = function (int $value) {
        return $value * 2;
    };

    $result = transform(5, $callback);

    // 10

Un valor predeterminado o una función anónima pueden pasarse como el tercer argumento a la función. Este valor será devuelto si el valor dado está en blanco:

    $result = transform(null, $callback, 'El valor está en blanco');

    // El valor está en blanco

<a name="method-validator"></a>
#### `validator()` {.collection-method}

La función `validator` crea una nueva instancia de [validator](/docs/{{version}}/validation) con los argumentos dados. Puedes usarlo como una alternativa a la fachada `Validator`:

    $validator = validator($data, $rules, $messages);

<a name="method-value"></a>
#### `value()` {.collection-method}

La función `value` devuelve el valor que se le da. Sin embargo, si pasas una función anónima a la función, la función anónima se ejecutará y su valor devuelto será devuelto:

    $result = value(true);

    // true

    $result = value(function () {
        return false;
    });

    // false

Se pueden pasar argumentos adicionales a la función `value`. Si el primer argumento es una función anónima, entonces los parámetros adicionales se pasarán a la función anónima como argumentos, de lo contrario, serán ignorados:

    $result = value(function (string $name) {
        return $name;
    }, 'Taylor');

    // 'Taylor'

<a name="method-view"></a>
#### `view()` {.collection-method}

La función `view` recupera una instancia de [view](/docs/{{version}}/views):

    return view('auth.login');

<a name="method-with"></a>
#### `with()` {.collection-method}

La función `with` devuelve el valor que se le da. Si se pasa una función anónima como el segundo argumento a la función, la función anónima se ejecutará y su valor devuelto será devuelto:

    $callback = function (mixed $value) {
        return is_numeric($value) ? $value * 2 : 0;
    };

    $result = with(5, $callback);

    // 10

    $result = with(null, $callback);

    // 0

    $result = with(5, null);

    // 5

<a name="other-utilities"></a>
## Otras Utilidades

<a name="benchmarking"></a>
### Benchmarking

A veces, puedes desear probar rápidamente el rendimiento de ciertas partes de tu aplicación. En esas ocasiones, puedes utilizar la clase de soporte `Benchmark` para medir el número de milisegundos que tardan en completarse los callbacks dados:

    <?php

    use App\Models\User;
    use Illuminate\Support\Benchmark;

    Benchmark::dd(fn () => User::find(1)); // 0.1 ms

    Benchmark::dd([
        'Escenario 1' => fn () => User::count(), // 0.5 ms
        'Escenario 2' => fn () => User::all()->count(), // 20.0 ms
    ]);

Por defecto, los callbacks dados se ejecutarán una vez (una iteración), y su duración se mostrará en el navegador / consola.

Para invocar un callback más de una vez, puedes especificar el número de iteraciones que el callback debe invocarse como el segundo argumento al método. Al ejecutar un callback más de una vez, la clase `Benchmark` devolverá la cantidad promedio de milisegundos que tardó en ejecutar el callback en todas las iteraciones:

    Benchmark::dd(fn () => User::count(), iterations: 10); // 0.5 ms

A veces, puedes querer medir el tiempo de ejecución de un callback mientras aún obtienes el valor devuelto por el callback. El método `value` devolverá una tupla que contiene el valor devuelto por el callback y la cantidad de milisegundos que tardó en ejecutar el callback:

    [$count, $duration] = Benchmark::value(fn () => User::count());

<a name="dates"></a>
### Fechas

Laravel incluye [Carbon](https://carbon.nesbot.com/docs/), una poderosa biblioteca de manipulación de fechas y horas. Para crear una nueva instancia de `Carbon`, puedes invocar la función `now`. Esta función está disponible globalmente dentro de tu aplicación Laravel:

```php
$now = now();
```

O, puedes crear una nueva instancia de `Carbon` utilizando la clase `Illuminate\Support\Carbon`:

```php
use Illuminate\Support\Carbon;

$now = Carbon::now();
```

Para una discusión exhaustiva sobre Carbon y sus características, consulta la [documentación oficial de Carbon](https://carbon.nesbot.com/docs/).

<a name="lottery"></a>
### Lotería

La clase de lotería de Laravel puede ser utilizada para ejecutar callbacks basados en un conjunto de probabilidades dadas. Esto puede ser particularmente útil cuando solo deseas ejecutar código para un porcentaje de tus solicitudes entrantes:

    use Illuminate\Support\Lottery;

    Lottery::odds(1, 20)
        ->winner(fn () => $user->won())
        ->loser(fn () => $user->lost())
        ->choose();

Puedes combinar la clase de lotería de Laravel con otras características de Laravel. Por ejemplo, puedes desear informar solo un pequeño porcentaje de consultas lentas a tu manejador de excepciones. Y, dado que la clase de lotería es invocable, podemos pasar una instancia de la clase a cualquier método que acepte invocables:

    use Carbon\CarbonInterval;
    use Illuminate\Support\Facades\DB;
    use Illuminate\Support\Lottery;

    DB::whenQueryingForLongerThan(
        CarbonInterval::seconds(2),
        Lottery::odds(1, 100)->winner(fn () => report('Consultando > 2 segundos.')),
    );

<a name="testing-lotteries"></a>
#### Pruebas de Loterías

Laravel proporciona algunos métodos simples para permitirte probar fácilmente las invocaciones de lotería de tu aplicación:

    // La lotería siempre ganará...
    Lottery::alwaysWin();

    // La lotería siempre perderá...
    Lottery::alwaysLose();

    // La lotería ganará y luego perderá, y finalmente volverá al comportamiento normal...
    Lottery::fix([true, false]);

    // La lotería volverá al comportamiento normal...
    Lottery::determineResultsNormally();

<a name="pipeline"></a>
### Pipeline

La fachada `Pipeline` de Laravel proporciona una forma conveniente de "canalizar" una entrada dada a través de una serie de clases invocables, funciones anónimas o invocables, dando a cada clase la oportunidad de inspeccionar o modificar la entrada e invocar el siguiente invocable en el pipeline:

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

Como puedes ver, cada clase invocable o función anónima en el pipeline recibe la entrada y una función anónima `$next`. Invocar la función anónima `$next` invocará el siguiente invocable en el pipeline. Como habrás notado, esto es muy similar a [middleware](/docs/{{version}}/middleware).

Cuando el último invocable en el pipeline invoca la función anónima `$next`, el invocable proporcionado al método `then` será invocado. Típicamente, este invocable simplemente devolverá la entrada dada.

Por supuesto, como se discutió anteriormente, no estás limitado a proporcionar funciones anónimas a tu pipeline. También puedes proporcionar clases invocables. Si se proporciona un nombre de clase, la clase será instanciada a través del [contenedor de servicios](/docs/{{version}}/container) de Laravel, permitiendo que las dependencias sean inyectadas en la clase invocable:

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
### Dormir

La clase `Sleep` de Laravel es un envoltorio ligero alrededor de las funciones nativas `sleep` y `usleep` de PHP, ofreciendo una mayor capacidad de prueba mientras también expone una API amigable para desarrolladores para trabajar con el tiempo:

    use Illuminate\Support\Sleep;

    $waiting = true;

    while ($waiting) {
        Sleep::for(1)->second();

        $waiting = /* ... */;
    }

La clase `Sleep` ofrece una variedad de métodos que te permiten trabajar con diferentes unidades de tiempo:

    // Pausar la ejecución durante 90 segundos...
    Sleep::for(1.5)->minutes();

    // Pausar la ejecución durante 2 segundos...
    Sleep::for(2)->seconds();

    // Pausar la ejecución durante 500 milisegundos...
    Sleep::for(500)->milliseconds();

    // Pausar la ejecución durante 5,000 microsegundos...
    Sleep::for(5000)->microseconds();

    // Pausar la ejecución hasta un tiempo dado...
    Sleep::until(now()->addMinute());

    // Alias de la función nativa "sleep" de PHP...
    Sleep::sleep(2);

    // Alias de la función nativa "usleep" de PHP...
    Sleep::usleep(5000);

Para combinar fácilmente unidades de tiempo, puedes usar el método `and`:

    Sleep::for(1)->second()->and(10)->milliseconds();

<a name="testing-sleep"></a>
#### Pruebas de Dormir

Al probar código que utiliza la clase `Sleep` o las funciones de sueño nativas de PHP, tu prueba pausará la ejecución. Como puedes imaginar, esto hace que tu suite de pruebas sea significativamente más lenta. Por ejemplo, imagina que estás probando el siguiente código:

    $waiting = /* ... */;

    $seconds = 1;

    while ($waiting) {
        Sleep::for($seconds++)->seconds();

        $waiting = /* ... */;
    }

Típicamente, probar este código tomaría _al menos_ un segundo. Afortunadamente, la clase `Sleep` nos permite "fingir" dormir para que nuestra suite de pruebas se mantenga rápida:

```php tab=Pest
it('waits until ready', function () {
    Sleep::fake();

    // ...
});
```

```php tab=PHPUnit
public function test_it_waits_until_ready()
{
    Sleep::fake();

    // ...
}
```

Al fingir la clase `Sleep`, la pausa de ejecución real se omite, lo que lleva a una prueba sustancialmente más rápida.

Una vez que la clase `Sleep` ha sido fingida, es posible hacer afirmaciones sobre los "sueños" esperados que deberían haber ocurrido. Para ilustrar esto, imaginemos que estamos probando código que pausa la ejecución tres veces, con cada pausa aumentando en un segundo. Usando el método `assertSequence`, podemos afirmar que nuestro código "durmió" por la cantidad adecuada de tiempo mientras mantenemos nuestra prueba rápida:

```php tab=Pest
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

```php tab=PHPUnit
public function test_it_checks_if_ready_four_times()
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

Por supuesto, la clase `Sleep` ofrece una variedad de otras afirmaciones que puedes usar al probar:

    use Carbon\CarbonInterval as Duration;
    use Illuminate\Support\Sleep;

    // Afirmar que dormir fue llamado 3 veces...
    Sleep::assertSleptTimes(3);

    // Afirmar contra la duración del sueño...
    Sleep::assertSlept(function (Duration $duration): bool {
        return /* ... */;
    }, times: 1);

    // Afirmar que la clase Sleep nunca fue invocada...
    Sleep::assertNeverSlept();

    // Afirmar que, incluso si Sleep fue llamado, no ocurrió ninguna pausa de ejecución...
    Sleep::assertInsomniac();

A veces puede ser útil realizar una acción cada vez que ocurre un sueño falso en tu código de aplicación. Para lograr esto, puedes proporcionar un callback al método `whenFakingSleep`. En el siguiente ejemplo, usamos los [ayudantes de manipulación de tiempo](/docs/{{version}}/mocking#interacting-with-time) de Laravel para avanzar instantáneamente el tiempo por la duración de cada sueño:

```php
use Carbon\CarbonInterval as Duration;

$this->freezeTime();

Sleep::fake();

Sleep::whenFakingSleep(function (Duration $duration) {
    // Progress time when faking sleep...
    $this->travel($duration->totalMilliseconds)->milliseconds();
});
```

A medida que avanzar en el tiempo es un requisito común, el método `fake` acepta un argumento `syncWithCarbon` para mantener a Carbon sincronizado cuando se duerme dentro de una prueba:

```php
Sleep::fake(syncWithCarbon: true);

$start = now();

Sleep::for(1)->second();

$start->diffForHumans(); // 1 second ago
```

Laravel utiliza la clase `Sleep` internamente cada vez que está pausando la ejecución. Por ejemplo, el ayudante [`retry`](#method-retry) utiliza la clase `Sleep` cuando duerme, lo que permite una mejor capacidad de prueba al usar ese ayudante.
