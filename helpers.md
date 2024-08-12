# Funciones de Ayuda

- [Introducción](#introduction)
- [Métodos disponibles](#available-methods)
- [Otras utilidades](#other-utilities)
  - [Benchmarking](#benchmarking)
  - [Lottery](#lottery)

<a name="introduction"></a>
## Introducción

Laravel incluye una variedad de funciones PHP globales de "ayuda". Muchas de estas funciones son usadas por el propio framework; sin embargo, eres libre de usarlas en tus propias aplicaciones si las encuentras convenientes.

<a name="available-methods"></a>
## Métodos disponibles

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
### Matrices y objetos

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
[Arr::sortRecursive](#method-array-sort-recursive)
[Arr::toCssClasses](#method-array-to-css-classes)
[Arr::undot](#method-array-undot)
[Arr::where](#method-array-where)
[Arr::whereNotNull](#method-array-where-not-null)
[Arr::wrap](#method-array-wrap)
[data_fill](#method-data-fill)
[data_get](#method-data-get)
[data_set](#method-data-set)
[head](#method-head)
[last](#method-last)
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

<a name="strings-method-list"></a>
### Strings

<div class="collection-method-list" markdown="1">

[\__](#method-__)
[class_basename](#method-class-basename)
[e](#method-e)
[preg_replace_array](#method-preg-replace-array)
[Str::after](#method-str-after)
[Str::afterLast](#method-str-after-last)
[Str::ascii](#method-str-ascii)
[Str::before](#method-str-before)
[Str::beforeLast](#method-str-before-last)
[Str::between](#method-str-between)
[Str::betweenFirst](#method-str-between-first)
[Str::camel](#method-camel-case)
[Str::contains](#method-str-contains)
[Str::containsAll](#method-str-contains-all)
[Str::endsWith](#method-ends-with)
[Str::excerpt](#method-excerpt)
[Str::finish](#method-str-finish)
[Str::headline](#method-str-headline)
[Str::inlineMarkdown](#method-str-inline-markdown)
[Str::is](#method-str-is)
[Str::isAscii](#method-str-is-ascii)
[Str::isJson](#method-str-is-json)
[Str::isUlid](#method-str-is-ulid)
[Str::isUuid](#method-str-is-uuid)
[Str::kebab](#method-kebab-case)
[Str::lcfirst](#method-str-lcfirst)
[Str::length](#method-str-length)
[Str::limit](#method-str-limit)
[Str::lower](#method-str-lower)
[Str::markdown](#method-str-markdown)
[Str::mask](#method-str-mask)
[Str::orderedUuid](#method-str-ordered-uuid)
[Str::padBoth](#method-str-padboth)
[Str::padLeft](#method-str-padleft)
[Str::padRight](#method-str-padright)
[Str::plural](#method-str-plural)
[Str::pluralStudly](#method-str-plural-studly)
[Str::random](#method-str-random)
[Str::remove](#method-str-remove)
[Str::replace](#method-str-replace)
[Str::replaceArray](#method-str-replace-array)
[Str::replaceFirst](#method-str-replace-first)
[Str::replaceLast](#method-str-replace-last)
[Str::reverse](#method-str-reverse)
[Str::singular](#method-str-singular)
[Str::slug](#method-str-slug)
[Str::snake](#method-snake-case)
[Str::squish](#method-str-squish)
[Str::start](#method-str-start)
[Str::startsWith](#method-starts-with)
[Str::studly](#method-studly-case)
[Str::substr](#method-str-substr)
[Str::substrCount](#method-str-substrcount)
[Str::substrReplace](#method-str-substrreplace)
[Str::swap](#method-str-swap)
[Str::title](#method-title-case)
[Str::toHtmlString](#method-str-to-html-string)
[Str::ucfirst](#method-str-ucfirst)
[Str::ucsplit](#method-str-ucsplit)
[Str::upper](#method-str-upper)
[Str::ulid](#method-str-ulid)
[Str::uuid](#method-str-uuid)
[Str::wordCount](#method-str-word-count)
[Str::words](#method-str-words)
[str](#method-str)
[trans](#method-trans)
[trans_choice](#method-trans-choice)

</div>

<a name="fluent-strings-method-list"></a>
### Cadenas fluidas

<div class="collection-method-list" markdown="1">

[after](#method-fluent-str-after)
[afterLast](#method-fluent-str-after-last)
[append](#method-fluent-str-append)
[ascii](#method-fluent-str-ascii)
[basename](#method-fluent-str-basename)
[before](#method-fluent-str-before)
[beforeLast](#method-fluent-str-before-last)
[between](#method-fluent-str-between)
[betweenFirst](#method-fluent-str-between-first)
[camel](#method-fluent-str-camel)
[classBasename](#method-fluent-str-class-basename)
[contains](#method-fluent-str-contains)
[containsAll](#method-fluent-str-contains-all)
[dirname](#method-fluent-str-dirname)
[endsWith](#method-fluent-str-ends-with)
[excerpt](#method-fluent-str-excerpt)
[exactly](#method-fluent-str-exactly)
[explode](#method-fluent-str-explode)
[finish](#method-fluent-str-finish)
[headline](#method-fluent-str-headline)
[inlineMarkdown](#method-fluent-str-inline-markdown)
[is](#method-fluent-str-is)
[isAscii](#method-fluent-str-is-ascii)
[isEmpty](#method-fluent-str-is-empty)
[isNotEmpty](#method-fluent-str-is-not-empty)
[isJson](#method-fluent-str-is-json)
[isUlid](#method-fluent-str-is-ulid)
[isUuid](#method-fluent-str-is-uuid)
[kebab](#method-fluent-str-kebab)
[lcfirst](#method-fluent-str-lcfirst)
[length](#method-fluent-str-length)
[limit](#method-fluent-str-limit)
[lower](#method-fluent-str-lower)
[ltrim](#method-fluent-str-ltrim)
[markdown](#method-fluent-str-markdown)
[mask](#method-fluent-str-mask)
[match](#method-fluent-str-match)
[matchAll](#method-fluent-str-match-all)
[newLine](#method-fluent-str-new-line)
[padBoth](#method-fluent-str-padboth)
[padLeft](#method-fluent-str-padleft)
[padRight](#method-fluent-str-padright)
[pipe](#method-fluent-str-pipe)
[plural](#method-fluent-str-plural)
[prepend](#method-fluent-str-prepend)
[remove](#method-fluent-str-remove)
[replace](#method-fluent-str-replace)
[replaceArray](#method-fluent-str-replace-array)
[replaceFirst](#method-fluent-str-replace-first)
[replaceLast](#method-fluent-str-replace-last)
[replaceMatches](#method-fluent-str-replace-matches)
[rtrim](#method-fluent-str-rtrim)
[scan](#method-fluent-str-scan)
[singular](#method-fluent-str-singular)
[slug](#method-fluent-str-slug)
[snake](#method-fluent-str-snake)
[split](#method-fluent-str-split)
[squish](#method-fluent-str-squish)
[start](#method-fluent-str-start)
[startsWith](#method-fluent-str-starts-with)
[studly](#method-fluent-str-studly)
[substr](#method-fluent-str-substr)
[substrReplace](#method-fluent-str-substrreplace)
[swap](#method-fluent-str-swap)
[tap](#method-fluent-str-tap)
[test](#method-fluent-str-test)
[title](#method-fluent-str-title)
[trim](#method-fluent-str-trim)
[ucfirst](#method-fluent-str-ucfirst)
[ucsplit](#method-fluent-str-ucsplit)
[upper](#method-fluent-str-upper)
[when](#method-fluent-str-when)
[whenContains](#method-fluent-str-when-contains)
[whenContainsAll](#method-fluent-str-when-contains-all)
[whenEmpty](#method-fluent-str-when-empty)
[whenNotEmpty](#method-fluent-str-when-not-empty)
[whenStartsWith](#method-fluent-str-when-starts-with)
[whenEndsWith](#method-fluent-str-when-ends-with)
[whenExactly](#method-fluent-str-when-exactly)
[whenNotExactly](#method-fluent-str-when-not-exactly)
[whenIs](#method-fluent-str-when-is)
[whenIsAscii](#method-fluent-str-when-is-ascii)
[whenIsUlid](#method-fluent-str-when-is-ulid)
[whenIsUuid](#method-fluent-str-when-is-uuid)
[whenTest](#method-fluent-str-when-test)
[wordCount](#method-fluent-str-word-count)
[words](#method-fluent-str-words)

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
[cookie](#method-cookie)
[csrf_field](#method-csrf-field)
[csrf_token](#method-csrf-token)
[decrypt](#method-decrypt)
[dd](#method-dd)
[dispatch](#method-dispatch)
[dump](#method-dump)
[encrypt](#method-encrypt)
[env](#method-env)
[event](#method-event)
[fake](#method-fake)
[filled](#method-filled)
[info](#method-info)
[logger](#method-logger)
[method_field](#method-method-field)
[now](#method-now)
[old](#method-old)
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

<a name="method-listing"></a>
## Method Listing

<style>
    .collection-method code {
        font-size: 14px;
    }

    .collection-method:not(.first-collection-method) {
        margin-top: 50px;
    }
</style>

<a name="arrays"></a>
## Arrays & Objectos

<a name="method-array-accessible"></a>
#### `Arr::accessible()` {.collection-method .first-collection-method}

El método `Arr::accessible` determina si el valor dado es array accesible:

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

El método `Arr::add` añade un par clave / valor dado a un array si la clave dada no existe ya en el array o es `nula`:

    use Illuminate\Support\Arr;

    $array = Arr::add(['name' => 'Desk'], 'price', 100);

    // ['name' => 'Desk', 'price' => 100]

    $array = Arr::add(['name' => 'Desk', 'price' => null], 'price', 100);

    // ['name' => 'Desk', 'price' => 100]


<a name="method-array-collapse"></a>
#### `Arr::collapse()` {.collection-method}

El método `Arr::collapse` contrae un array de arrays en un único array:

    use Illuminate\Support\Arr;

    $array = Arr::collapse([[1, 2, 3], [4, 5, 6], [7, 8, 9]]);

    // [1, 2, 3, 4, 5, 6, 7, 8, 9]

<a name="method-array-crossjoin"></a>
#### `Arr::crossJoin()` {.collection-method}

El método `Arr::crossJoin` cruza lss arrays dadas, devolviendo un producto cartesiano con todas las permutaciones posibles:

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

El método `Arr::divide` devuelve dos arrays: una con las claves y otra con los valores de el array dado:

    use Illuminate\Support\Arr;

    [$keys, $values] = Arr::divide(['name' => 'Desk']);

    // $keys: ['name']

    // $values: ['Desk']

<a name="method-array-dot"></a>
#### `Arr::dot()` {.collection-method}

El método `Arr::dot` transforma un array multidimensional en un array de un solo nivel que utiliza la notación "dot" para indicar la profundidad:

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    $flattened = Arr::dot($array);

    // ['products.desk.price' => 100]

<a name="method-array-except"></a>
#### `Arr::except()` {.collection-method}

El método `Arr::except` elimina de un array los pares clave/valor dados:

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100];

    $filtered = Arr::except($array, ['price']);

    // ['name' => 'Desk']

<a name="method-array-exists"></a>
#### `Arr::exists()` {.collection-method}

El método `Arr::exists` comprueba que la clave dada existe en el array proporcionado:

    use Illuminate\Support\Arr;

    $array = ['name' => 'John Doe', 'age' => 17];

    $exists = Arr::exists($array, 'name');

    // true

    $exists = Arr::exists($array, 'salary');

    // false

<a name="method-array-first"></a>
#### `Arr::first()` {.collection-method}

El método `Arr::first` devuelve el primer elemento de un array que supera una condición dada:

    use Illuminate\Support\Arr;

    $array = [100, 200, 300];

    $first = Arr::first($array, function ($value, $key) {
        return $value >= 150;
    });

    // 200

También se puede pasar un valor por defecto como tercer parámetro del método. Este valor se devolverá si ningún valor supera la condición proporcionada:

    use Illuminate\Support\Arr;

    $first = Arr::first($array, $callback, $default);

<a name="method-array-flatten"></a>
#### `Arr::flatten()` {.collection-method}

El método `Arr::flatten` transforma un array multidimensional en un array de un solo nivel:

    use Illuminate\Support\Arr;

    $array = ['name' => 'Joe', 'languages' => ['PHP', 'Ruby']];

    $flattened = Arr::flatten($array);

    // ['Joe', 'PHP', 'Ruby']

<a name="method-array-forget"></a>
#### `Arr::forget()` {.collection-method}

El método `Arr::forget` elimina un par clave/valor dado de un array anidado en profundidad utilizando la notación "dot":

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    Arr::forget($array, 'products.desk');

    // ['products' => []]

<a name="method-array-get"></a>
#### `Arr::get()` {.collection-method}

El método `Arr::get` recupera un valor de un array anidado utilizando la notación "dot":

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    $price = Arr::get($array, 'products.desk.price');

    // 100

El método `Arr::get` también acepta un valor por defecto, que será devuelto si la clave especificada no está presente en el array:

    use Illuminate\Support\Arr;

    $discount = Arr::get($array, 'products.desk.discount', 0);

    // 0

<a name="method-array-has"></a>
#### `Arr::has()` {.collection-method}

El método `Arr::has` comprueba si uno o varios elementos existen en un array utilizando la notación "dot":

    use Illuminate\Support\Arr;

    $array = ['product' => ['name' => 'Desk', 'price' => 100]];

    $contains = Arr::has($array, 'product.name');

    // true

    $contains = Arr::has($array, ['product.price', 'product.discount']);

    // false

<a name="method-array-hasany"></a>
#### `Arr::hasAny()` {.collection-method}

El método `Arr::hasAny` comprueba si algún elemento de un conjunto dado existe en un array utilizando la notación "dot":

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

El método `Arr::isAssoc` devuelve `true` si el array dado es un array asociativo. Un array se considera "asociativo" si no tiene claves numéricas secuenciales que empiecen por cero:

    use Illuminate\Support\Arr;

    $isAssoc = Arr::isAssoc(['product' => ['name' => 'Desk', 'price' => 100]]);

    // true

    $isAssoc = Arr::isAssoc([1, 2, 3]);

    // false

<a name="method-array-islist"></a>
#### `Arr::isList()` {.collection-method}

El método `Arr::isList` devuelve `true` si las claves del array dado son enteros secuenciales empezando por cero:

    use Illuminate\Support\Arr;

    $isList = Arr::isList(['foo', 'bar', 'baz']);

    // true

    $isList = Arr::isList(['product' => ['name' => 'Desk', 'price' => 100]]);

    // false

<a name="method-array-join"></a>
#### `Arr::join()` {.collection-method}

El método `Arr::join` une los elementos de array en una cadena. Utilizando el segundo argumento de este método, también puede especificar la cadena de unión para el elemento final del array:

    use Illuminate\Support\Arr;

    $array = ['Tailwind', 'Alpine', 'Laravel', 'Livewire'];

    $joined = Arr::join($array, ', ');

    // Tailwind, Alpine, Laravel, Livewire

    $joined = Arr::join($array, ', ', ' and ');

    // Tailwind, Alpine, Laravel and Livewire

<a name="method-array-keyby"></a>
#### `Arr::keyBy()` {.collection-method}

El método `Arr::keyBy`  ordena el array por la clave dada. Si varios elementos tienen la misma clave, sólo el último aparecerá en el nuevo array:

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

El método `Arr::last` devuelve el último elemento de un array que pasa una condición dada:

    use Illuminate\Support\Arr;

    $array = [100, 200, 300, 110];

    $last = Arr::last($array, function ($value, $key) {
        return $value >= 150;
    });

    // 300

Se puede pasar un valor por defecto como tercer argumento del método. Este valor se devolverá si ningún valor supera la condición:

    use Illuminate\Support\Arr;

    $last = Arr::last($array, $callback, $default);

<a name="method-array-map"></a>
#### `Arr::map()` {.collection-method}

El método `Arr::map` recorre el array y pasa cada valor y clave al callback dado. El valor de array se sustituye por el valor devuelto por el callback:

    use Illuminate\Support\Arr;

    $array = ['first' => 'james', 'last' => 'kirk'];

    $mapped = Arr::map($array, function ($value, $key) {
        return ucfirst($value);
    });

    // ['first' => 'James', 'last' => 'Kirk']

<a name="method-array-only"></a>
#### `Arr::only()` {.collection-method}

El método `Arr::only` devuelve sólo los pares clave/valor especificados del array dado:

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100, 'orders' => 10];

    $slice = Arr::only($array, ['name', 'price']);

    // ['name' => 'Desk', 'price' => 100]

<a name="method-array-pluck"></a>
#### `Arr::pluck()` {.collection-method}

El método `Arr::pluck` recupera todos los valores de una clave dada de un array:

    use Illuminate\Support\Arr;

    $array = [
        ['developer' => ['id' => 1, 'name' => 'Taylor']],
        ['developer' => ['id' => 2, 'name' => 'Abigail']],
    ];

    $names = Arr::pluck($array, 'developer.name');

    // ['Taylor', 'Abigail']

También puede especificar cómo desea que sea la clave de la lista resultante:

    use Illuminate\Support\Arr;

    $names = Arr::pluck($array, 'developer.name', 'developer.id');

    // [1 => 'Taylor', 2 => 'Abigail']

<a name="method-array-prepend"></a>
#### `Arr::prepend()` {.collection-method}

El método `Arr::prepend` coloca un elemento al principio de un array:

    use Illuminate\Support\Arr;

    $array = ['one', 'two', 'three', 'four'];

    $array = Arr::prepend($array, 'zero');

    // ['zero', 'one', 'two', 'three', 'four']

Si es necesario, puede especificar la clave que se utilizará para el valor:

    use Illuminate\Support\Arr;

    $array = ['price' => 100];

    $array = Arr::prepend($array, 'Desk', 'name');

    // ['name' => 'Desk', 'price' => 100]

<a name="method-array-prependkeyswith"></a>
#### `Arr::prependKeysWith()` {.collection-method}

El método `Arr::prependKeysWith` antepone a todos los nombres de las claves de un array asociativo el prefijo dado:

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

El método `Arr::pull` devuelve y elimina un par clave/valor de un array:

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100];

    $name = Arr::pull($array, 'name');

    // $name: Desk

    // $array: ['price' => 100]

Se puede pasar un valor por defecto como tercer argumento del método. Este valor se devolverá si la clave no existe:

    use Illuminate\Support\Arr;

    $value = Arr::pull($array, $key, $default);

<a name="method-array-query"></a>
#### `Arr::query()` {.collection-method}

El método `Arr::query` convierte el array en una query string:

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

    // 4 - (retrieved randomly)

También puede especificar el número de elementos a devolver como segundo argumento opcional. Tenga en cuenta que este argumento devolverá un array incluso si sólo desea un elemento:

    use Illuminate\Support\Arr;

    $items = Arr::random($array, 2);

    // [2, 5] - (retrieved randomly)

<a name="method-array-set"></a>
#### `Arr::set()` {.collection-method}

El método `Arr::set` establece un valor dentro de un array anidado usando la notación "dot":

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    Arr::set($array, 'products.desk.price', 200);

    // ['products' => ['desk' => ['price' => 200]]]

<a name="method-array-shuffle"></a>
#### `Arr::shuffle()` {.collection-method}

El método `Arr::shuffle` mezcla aleatoriamente los elementos del array:

    use Illuminate\Support\Arr;

    $array = Arr::shuffle([1, 2, 3, 4, 5]);

    // [3, 2, 5, 1, 4] - (generated randomly)

<a name="method-array-sort"></a>
#### `Arr::sort()` {.collection-method}

El método `Arr::sort` ordena un array por sus valores:

    use Illuminate\Support\Arr;

    $array = ['Desk', 'Table', 'Chair'];

    $sorted = Arr::sort($array);

    // ['Chair', 'Desk', 'Table']

También puede ordenar el array por los resultados de un closure dado:

    use Illuminate\Support\Arr;

    $array = [
        ['name' => 'Desk'],
        ['name' => 'Table'],
        ['name' => 'Chair'],
    ];

    $sorted = array_values(Arr::sort($array, function ($value) {
        return $value['name'];
    }));

    /*
        [
            ['name' => 'Chair'],
            ['name' => 'Desk'],
            ['name' => 'Table'],
        ]
    */

<a name="method-array-sort-recursive"></a>
#### `Arr::sortRecursive()` {.collection-method}

El método `Arr::sortRecursive` ordena recursivamente un array utilizando la función `sort` para sub-arrays indexados numéricamente y la función `ksort` para sub-arrays asociativas:

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

<a name="method-array-to-css-classes"></a>
#### `Arr::toCssClasses()` {.collection-method}

El método `Arr::toCssClasses` compila condicionalmente una cadena de clases CSS. El método acepta un array de clases donde la clave del array contiene la clase o clases que desea añadir, mientras que el valor es una expresión booleana. Si el elemento array tiene una clave numérica, siempre se incluirá en la lista de clases renderizada:

    use Illuminate\Support\Arr;

    $isActive = false;
    $hasError = true;

    $array = ['p-4', 'font-bold' => $isActive, 'bg-red' => $hasError];

    $classes = Arr::toCssClasses($array);

    /*
        'p-4 bg-red'
    */

Este método potencia la funcionalidad de Laravel que permite [fusionar clases con la bolsa de atributos de un componente Blade](/docs/{{version}}/blade#conditionally-merge-classes), así como la [directiva de Blade](/docs/{{version}}/blade#conditional-classes) `@class`.

<a name="method-array-undot"></a>
#### `Arr::undot()` {.collection-method}

El método `Arr::undot` expande un array unidimensional que utiliza la notación "dot" a un array multidimensional:

    use Illuminate\Support\Arr;

    $array = [
        'user.name' => 'Kevin Malone',
        'user.occupation' => 'Accountant',
    ];

    $array = Arr::undot($array);

    // ['user' => ['name' => 'Kevin Malone', 'occupation' => 'Accountant']]

<a name="method-array-where"></a>
#### `Arr::where()` {.collection-method}

El método `Arr::where` filtra un array utilizando el closure dado:

    use Illuminate\Support\Arr;

    $array = [100, '200', 300, '400', 500];

    $filtered = Arr::where($array, function ($value, $key) {
        return is_string($value);
    });

    // [1 => '200', 3 => '400']

<a name="method-array-where-not-null"></a>
#### `Arr::whereNotNull()` {.collection-method}

El método `Arr::whereNotNull` elimina todos los valores `nulos` del array dado:

    use Illuminate\Support\Arr;

    $array = [0, null];

    $filtered = Arr::whereNotNull($array);

    // [0 => 0]

<a name="method-array-wrap"></a>
#### `Arr::wrap()` {.collection-method}

El método `Arr::wrap` envuelve el valor dado en un array. Si el valor dado ya es un array, se devolverá sin modificaciones:

    use Illuminate\Support\Arr;

    $string = 'Laravel';

    $array = Arr::wrap($string);

    // ['Laravel']

Si el valor dado es `nulo`, se devolverá un array vacío:

    use Illuminate\Support\Arr;

    $array = Arr::wrap(null);

    // []

<a name="method-data-fill"></a>
#### `data_fill()` {.collection-method}

La función `data_fill` establece un valor que falta dentro de un array u objeto anidado utilizando la notación "dot":

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_fill($data, 'products.desk.price', 200);

    // ['products' => ['desk' => ['price' => 100]]]

    data_fill($data, 'products.desk.discount', 10);

    // ['products' => ['desk' => ['price' => 100, 'discount' => 10]]]

Esta función también acepta asteriscos como comodines y rellenará el objetivo en consecuencia:

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

La función `data_get` recupera un valor de un array u objeto anidado utilizando la notación "dot":

    $data = ['products' => ['desk' => ['price' => 100]]];

    $price = data_get($data, 'products.desk.price');

    // 100

La función `data_get` también acepta un valor por defecto, que se devolverá si no se encuentra la clave especificada:

    $discount = data_get($data, 'products.desk.discount', 0);

    // 0

La función también acepta comodines utilizando asteriscos, que pueden apuntar a cualquier clave del array u objeto:

    $data = [
        'product-one' => ['name' => 'Desk 1', 'price' => 100],
        'product-two' => ['name' => 'Desk 2', 'price' => 150],
    ];

    data_get($data, '*.name');

    // ['Desk 1', 'Desk 2'];

<a name="method-data-set"></a>
#### `data_set()` {.collection-method}

La función `data_set` establece un valor dentro de un array u objeto anidado utilizando la notación "dot":

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_set($data, 'products.desk.price', 200);

    // ['products' => ['desk' => ['price' => 200]]]

Esta función también acepta comodines utilizando asteriscos y establecerá los valores en el objetivo en consecuencia:

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

Por defecto, los valores existentes se sobrescriben. Si sólo desea establecer un valor si no existe, puede pasar `false` como cuarto argumento a la función:

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_set($data, 'products.desk.price', 200, overwrite: false);

    // ['products' => ['desk' => ['price' => 100]]]

<a name="method-head"></a>
#### `head()` {.collection-method}

La función `head` devuelve el primer elemento de el array dado:

    $array = [100, 200, 300];

    $first = head($array);

    // 100

<a name="method-last"></a>
#### `last()` {.collection-method}

La función `last` devuelve el último elemento de el array dado:

    $array = [100, 200, 300];

    $last = last($array);

    // 300

<a name="paths"></a>
## Rutas

<a name="method-app-path"></a>
#### `app_path()` {.collection-method}

La función `app_path` devuelve la ruta completa al directorio de `aplicaciones` de su aplicación. También puede utilizar la función `app_path` para generar una ruta completa a un archivo relativo al directorio de la aplicación:

    $path = app_path();

    $path = app_path('Http/Controllers/Controller.php');

<a name="method-base-path"></a>
#### `base_path()` {.collection-method}

La función `base_path` devuelve la ruta completa al directorio raíz de la aplicación. También puede utilizar la función `base_path` para generar una ruta completa a un archivo dado relativo al directorio raíz del proyecto:

    $path = base_path();

    $path = base_path('vendor/bin');

<a name="method-config-path"></a>
#### `config_path()` {.collection-method}

La función `config_path` devuelve la ruta completa al directorio de `configuración` de su aplicación. También puede utilizar la función `config_path` para generar una ruta completa a un archivo determinado dentro del directorio de configuración de la aplicación:

    $path = config_path();

    $path = config_path('app.php');

<a name="method-database-path"></a>
#### `database_path()` {.collection-method}

La función `database_path` devuelve la ruta completa al directorio `database` de la aplicación. También puede utilizar la función `database_path` para generar una ruta completa a un archivo determinado dentro del directorio de la base de datos:

    $path = database_path();

    $path = database_path('factories/UserFactory.php');

<a name="method-lang-path"></a>
#### `lang_path()` {.collection-method}

La función `lang_path` devuelve la ruta completa al directorio `lang` de su aplicación. También puede utilizar la función `lang_path` para generar una ruta completa a un archivo determinado dentro del directorio:

    $path = lang_path();

    $path = lang_path('en/messages.php');

<a name="method-mix"></a>
#### `mix()` {.collection-method}

La función `mix` devuelve la ruta a un [archivo Mix versionado](/docs/{{version}}/mix):

    $path = mix('css/app.css');

<a name="method-public-path"></a>
#### `public_path()` {.collection-method}

La función `public_path` devuelve la ruta completa al directorio `public` de su aplicación. También puede utilizar la función `public_path` para generar una ruta completa a un archivo determinado dentro del directorio público:

    $path = public_path();

    $path = public_path('css/app.css');

<a name="method-resource-path"></a>
#### `resource_path()` {.collection-method}

La función `resource_path` devuelve la ruta completa al directorio `resources` de su aplicación. También puede utilizar la función `resource_path` para generar una ruta completa a un archivo determinado dentro del directorio de recursos:

    $path = resource_path();

    $path = resource_path('sass/app.scss');

<a name="method-storage-path"></a>
#### `storage_path()` {.collection-method}

La función `storage_path` devuelve la ruta completa al directorio `storage` su aplicación. También puede utilizar la función `storage_path` para generar una ruta completa a un archivo determinado dentro del directorio de almacenamiento:

    $path = storage_path();

    $path = storage_path('app/file.txt');

<a name="strings"></a>
## Strings

<a name="method-__"></a>
#### `__()` {.collection-method}

La función `__` traduce la cadena o clave de traducción dada utilizando sus [archivos de localización](/docs/{{version}}/localization):

    echo __('Welcome to our application');

    echo __('messages.welcome');

Si la cadena o clave de traducción especificada no existe, la función `__` devolverá el valor dado. Así, utilizando el ejemplo anterior, la función `__` devolvería`messages.welcome` si esa clave de traducción no existe.

<a name="method-class-basename"></a>
#### `class_basename()` {.collection-method}

La función `class_basename` devuelve el nombre de la clase dada sin el espacio de nombres de la clase:

    $class = class_basename('Foo\Bar\Baz');

    // Baz

<a name="method-e"></a>
#### `e()` {.collection-method}

La función `e` ejecuta la función `htmlspecialchars` de PHP con la opción `double_encode` activada defecto:

    echo e('<html>foo</html>');

    // &lt;html&gt;foo&lt;/html&gt;

<a name="method-preg-replace-array"></a>
#### `preg_replace_array()` {.collection-method}

La función `preg_replace_array` reemplaza un patrón dado en la cadena secuencialmente usando un array:

    $string = 'The event will take place between :start and :end';

    $replaced = preg_replace_array('/:[a-z_]+/', ['8:30', '9:00'], $string);

    // The event will take place between 8:30 and 9:00

<a name="method-str-after"></a>
#### `Str::after()` {.collection-method}

El método `Str::after` devuelve todo lo que hay después del valor dado en una cadena. Se devolverá la cadena completa si el valor no existe dentro de la cadena:

    use Illuminate\Support\Str;

    $slice = Str::after('This is my name', 'This is');

    // ' my name'

<a name="method-str-after-last"></a>
#### `Str::afterLast()` {.collection-method}

El método `Str::afterLast` devuelve todo lo que hay después de la última aparición del valor dado en una cadena. Se devolverá la cadena completa si el valor no existe dentro de la cadena:

    use Illuminate\Support\Str;

    $slice = Str::afterLast('App\Http\Controllers\Controller', '\\');

    // 'Controller'

<a name="method-str-ascii"></a>
#### `Str::ascii()` {.collection-method}

El método `Str::ascii` intentará transliterar la cadena a un valor ASCII:

    use Illuminate\Support\Str;

    $slice = Str::ascii('û');

    // 'u'

<a name="method-str-before"></a>
#### `Str::before()` {.collection-method}

El método `Str::before` devuelve todo lo anterior al valor dado en una cadena:

    use Illuminate\Support\Str;

    $slice = Str::before('This is my name', 'my name');

    // 'This is '

<a name="method-str-before-last"></a>
#### `Str::beforeLast()` {.collection-method}

El método `Str::beforeLast` devuelve todo lo que hay antes de la última aparición del valor dado en una cadena:

    use Illuminate\Support\Str;

    $slice = Str::beforeLast('This is my name', 'is');

    // 'This '

<a name="method-str-between"></a>
#### `Str::between()` {.collection-method}

El método `Str::between` devuelve la parte de una cadena comprendida entre dos valores:

    use Illuminate\Support\Str;

    $slice = Str::between('This is my name', 'This', 'name');

    // ' is my '

<a name="method-str-between-first"></a>
#### `Str::betweenFirst()` {.collection-method}

El método  `Str::betweenFirst` devuelve la porción más pequeña posible de una cadena entre dos valores:

    use Illuminate\Support\Str;

    $slice = Str::betweenFirst('[a] bc [d]', '[', ']');

    // 'a'

<a name="method-camel-case"></a>
#### `Str::camel()` {.collection-method}

El método `Str::camel` convierte la cadena dada a `camelCase`:

    use Illuminate\Support\Str;

    $converted = Str::camel('foo_bar');

    // fooBar

<a name="method-str-contains"></a>
#### `Str::contains()` {.collection-method}

El método `Str::contains` determina si la cadena dada contiene el valor dado. Este método distingue entre mayúsculas y minúsculas:

    use Illuminate\Support\Str;

    $contains = Str::contains('This is my name', 'my');

    // true

También puede pasar un array de valores para determinar si la cadena dada contiene alguno de los valores de el array:

    use Illuminate\Support\Str;

    $contains = Str::contains('This is my name', ['my', 'foo']);

    // true

<a name="method-str-contains-all"></a>
#### `Str::containsAll()` {.collection-method}

El método `Str::containsAll` determina si la cadena dada contiene todos los valores de un array dado:

    use Illuminate\Support\Str;

    $containsAll = Str::containsAll('This is my name', ['my', 'name']);

    // true

<a name="method-ends-with"></a>
#### `Str::endsWith()` {.collection-method}

El método `Str::endsWith` determina si la cadena dada termina con el valor dado:

    use Illuminate\Support\Str;

    $result = Str::endsWith('This is my name', 'name');

    // true


También puede pasar un array de valores para determinar si la cadena dada termina con cualquiera de los valores del array:

    use Illuminate\Support\Str;

    $result = Str::endsWith('This is my name', ['name', 'foo']);

    // true

    $result = Str::endsWith('This is my name', ['this', 'foo']);

    // false

<a name="method-excerpt"></a>
#### `Str::excerpt()` {.collection-method}

El método `Str::excerpt` extrae un fragmento de una cadena dada que coincide con la primera instancia de una frase dentro de esa cadena:

    use Illuminate\Support\Str;

    $excerpt = Str::excerpt('This is my name', 'my', [
        'radius' => 3
    ]);

    // '...is my na...'

La opción `radius`, que por defecto es `100`, permite definir el número de caracteres que deben aparecer a cada lado de la cadena truncada.

Además, puede utilizar la opción  `omission` para definir la cadena que se antepondrá y añadirá a la cadena truncada:

    use Illuminate\Support\Str;

    $excerpt = Str::excerpt('This is my name', 'name', [
        'radius' => 3,
        'omission' => '(...) '
    ]);

    // '(...) my name'

<a name="method-str-finish"></a>
#### `Str::finish()` {.collection-method}

El método `Str::finish` añade una única instancia del valor dado a una cadena si aún no termina con ese valor:

    use Illuminate\Support\Str;

    $adjusted = Str::finish('this/string', '/');

    // this/string/

    $adjusted = Str::finish('this/string/', '/');

    // this/string/

<a name="method-str-headline"></a>
#### `Str::headline()` {.collection-method}

El método `Str::headline` convierte cadenas delimitadas por mayúsculas, guiones o guiones bajos en una cadena delimitada por espacios con la primera letra de cada palabra en mayúscula:

    use Illuminate\Support\Str;

    $headline = Str::headline('steve_jobs');

    // Steve Jobs

    $headline = Str::headline('EmailNotificationSent');

    // Email Notification Sent

<a name="method-str-inline-markdown"></a>
#### `Str::inlineMarkdown()` {.collection-method}

El método `Str::inlineMarkdown` convierte Markdown (en su variante para GitHub) en HTML inline utilizando [CommonMark](https://commonmark.thephpleague.com/). Sin embargo, a diferencia del método `markdown`, no envuelve todo el HTML generado en un elemento a nivel de bloque:

    use Illuminate\Support\Str;

    $html = Str::inlineMarkdown('**Laravel**');

    // <strong>Laravel</strong>

<a name="method-str-is"></a>
#### `Str::is()` {.collection-method}

El método `Str::is`  determina si una cadena dada coincide con un patrón dado. Los asteriscos pueden utilizarse como comodines:

    use Illuminate\Support\Str;

    $matches = Str::is('foo*', 'foobar');

    // true

    $matches = Str::is('baz*', 'foobar');

    // false

<a name="method-str-is-ascii"></a>
#### `Str::isAscii()` {.collection-method}

El método `Str::isAscii` determina si una cadena dada es ASCII de 7 bits:

    use Illuminate\Support\Str;

    $isAscii = Str::isAscii('Taylor');

    // true

    $isAscii = Str::isAscii('ü');

    // false

<a name="method-str-is-json"></a>
#### `Str::isJson()` {.collection-method}

El método `Str::isJson` determina si la cadena dada es JSON válida:

    use Illuminate\Support\Str;

    $result = Str::isJson('[1,2,3]');

    // true

    $result = Str::isJson('{"first": "John", "last": "Doe"}');

    // true

    $result = Str::isJson('{first: "John", last: "Doe"}');

    // false

<a name="method-str-is-ulid"></a>
#### `Str::isUlid()` {.collection-method}

El método `Str::isUlid` determina si la cadena dada es un ULID válido:

    use Illuminate\Support\Str;

    $isUlid = Str::isUlid('01gd6r360bp37zj17nxb55yv40');

    // true

    $isUlid = Str::isUlid('laravel');

    // false

<a name="method-str-is-uuid"></a>
#### `Str::isUuid()` {.collection-method}

El método `Str::isUuid` determina si la cadena dada es un UUID válido:

    use Illuminate\Support\Str;

    $isUuid = Str::isUuid('a0a2a2d2-0b87-4a18-83f2-2529882be2de');

    // true

    $isUuid = Str::isUuid('laravel');

    // false

<a name="method-kebab-case"></a>
#### `Str::kebab()` {.collection-method}

El método `Str::kebab` convierte la cadena dada a `kebab-case`:

    use Illuminate\Support\Str;

    $converted = Str::kebab('fooBar');

    // foo-bar

<a name="method-str-lcfirst"></a>
#### `Str::lcfirst()` {.collection-method}

El método `Str::lcfirst` devuelve la cadena dada con el primer carácter en minúsculas:

    use Illuminate\Support\Str;

    $string = Str::lcfirst('Foo Bar');

    // foo Bar

<a name="method-str-length"></a>
#### `Str::length()` {.collection-method}

El método `Str::length` devuelve la longitud de la cadena dada:

    use Illuminate\Support\Str;

    $length = Str::length('Laravel');

    // 7

<a name="method-str-limit"></a>
#### `Str::limit()` {.collection-method}

El método `Str::limit` trunca la cadena dada hasta la longitud especificada:

    use Illuminate\Support\Str;

    $truncated = Str::limit('The quick brown fox jumps over the lazy dog', 20);

    // The quick brown fox...

Puede pasar un tercer argumento al método para cambiar la cadena que se añadirá al final de la cadena truncada:

    use Illuminate\Support\Str;

    $truncated = Str::limit('The quick brown fox jumps over the lazy dog', 20, ' (...)');

    // The quick brown fox (...)

<a name="method-str-lower"></a>
#### `Str::lower()` {.collection-method}

El método `Str::lower` convierte la cadena dada a minúsculas:

    use Illuminate\Support\Str;

    $converted = Str::lower('LARAVEL');

    // laravel

<a name="method-str-markdown"></a>
#### `Str::markdown()` {.collection-method}

El método `Str::markdown` convierte GitHub flavored Markdown en HTML utilizando [CommonMark](https://commonmark.thephpleague.com/):

    use Illuminate\Support\Str;

    $html = Str::markdown('# Laravel');

    // <h1>Laravel</h1>

    $html = Str::markdown('# Taylor <b>Otwell</b>', [
        'html_input' => 'strip',
    ]);

    // <h1>Taylor Otwell</h1>

<a name="method-str-mask"></a>
#### `Str::mask()` {.collection-method}

El método `Str::mask` enmascara una parte de una cadena con un carácter repetido, y puede utilizarse para ofuscar segmentos de cadenas como direcciones de correo electrónico y números de teléfono:

    use Illuminate\Support\Str;

    $string = Str::mask('taylor@example.com', '*', 3);

    // tay***************

Si es necesario, proporcione un número negativo como tercer argumento del método `mask`, que indicará al método que comience a enmascarar a la distancia dada del final de la cadena:

    $string = Str::mask('taylor@example.com', '*', -15, 3);

    // tay***@example.com

<a name="method-str-ordered-uuid"></a>
#### `Str::orderedUuid()` {.collection-method}

El método `Str::orderedUuid` genera un UUID "timestamp first" que puede almacenarse de forma eficiente en una columna indexada de la base de datos. Cada UUID que se genere utilizando este método se ordenará después de los UUID generados previamente utilizando el método:

    use Illuminate\Support\Str;

    return (string) Str::orderedUuid();

<a name="method-str-padboth"></a>
#### `Str::padBoth()` {.collection-method}

El método `Str::padBoth` envuelve la función `str_pad` de PHP, rellenando ambos lados de una cadena con otra cadena hasta que la cadena final alcanza la longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::padBoth('James', 10, '_');

    // '__James___'

    $padded = Str::padBoth('James', 10);

    // '  James   '

<a name="method-str-padleft"></a>
#### `Str::padLeft()` {.collection-method}

El método `Str::padLeft` envuelve la función `str_pad` de PHP, rellenando el lado izquierdo de una cadena con otra cadena hasta que la cadena final alcanza la longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::padLeft('James', 10, '-=');

    // '-=-=-James'

    $padded = Str::padLeft('James', 10);

    // '     James'

<a name="method-str-padright"></a>
#### `Str::padRight()` {.collection-method}

El método `Str::padRight` envuelve la función `str_pad` de PHP, rellenando el lado derecho de una cadena con otra cadena hasta que la cadena final alcanza la longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::padRight('James', 10, '-');

    // 'James-----'

    $padded = Str::padRight('James', 10);

    // 'James     '

<a name="method-str-plural"></a>
#### `Str::plural()` {.collection-method}

El método `Str::plural` convierte una cadena de palabras en singular a su forma plural. Esta función soporta [cualquiera de los lenguajes soportados por el pluralizador de Laravel](/docs/{{version}}/localization#pluralization-language):

    use Illuminate\Support\Str;

    $plural = Str::plural('car');

    // cars

    $plural = Str::plural('child');

    // children

Puede proporcionar un número entero como segundo argumento de la función para recuperar la forma singular o plural de la cadena:

    use Illuminate\Support\Str;

    $plural = Str::plural('child', 2);

    // children

    $singular = Str::plural('child', 1);

    // child

<a name="method-str-plural-studly"></a>
#### `Str::pluralStudly()` {.collection-method}

El método  `Str::pluralStudly` convierte una palabra singular formateada en mayúsculas a su forma plural. Esta función soporta [cualquiera de los lenguajes soportados por el pluralizador de Laravel](/docs/{{version}}/localization#pluralization-language):

    use Illuminate\Support\Str;

    $plural = Str::pluralStudly('VerifiedHuman');

    // VerifiedHumans

    $plural = Str::pluralStudly('UserFeedback');

    // UserFeedback

Puede proporcionar un número entero como segundo argumento de la función para recuperar la forma singular o plural de la cadena:

    use Illuminate\Support\Str;

    $plural = Str::pluralStudly('VerifiedHuman', 2);

    // VerifiedHumans

    $singular = Str::pluralStudly('VerifiedHuman', 1);

    // VerifiedHuman

<a name="method-str-random"></a>
#### `Str::random()` {.collection-method}

El método `Str::random` genera una cadena aleatoria de la longitud especificada. Esta función usa la función `random_bytes` de PHP:

    use Illuminate\Support\Str;

    $random = Str::random(40);

<a name="method-str-remove"></a>
#### `Str::remove()` {.collection-method}

El método `Str::remove` elimina el valor o array de valores dados de la cadena:

    use Illuminate\Support\Str;

    $string = 'Peter Piper picked a peck of pickled peppers.';

    $removed = Str::remove('e', $string);

    // Ptr Pipr pickd a pck of pickld ppprs.

También puede pasar `false` como tercer argumento al método `remove` para ignorar mayúsculas y minúsculas al eliminar cadenas.

<a name="method-str-replace"></a>
#### `Str::replace()` {.collection-method}

El método `Str::replace` sustituye una cadena dada dentro de la cadena:

    use Illuminate\Support\Str;

    $string = 'Laravel 8.x';

    $replaced = Str::replace('8.x', '9.x', $string);

    // Laravel 9.x

<a name="method-str-replace-array"></a>
#### `Str::replaceArray()` {.collection-method}

El método `Str::replaceArray` reemplaza un valor dado en la cadena secuencialmente usando un array:

    use Illuminate\Support\Str;

    $string = 'The event will take place between ? and ?';

    $replaced = Str::replaceArray('?', ['8:30', '9:00'], $string);

    // The event will take place between 8:30 and 9:00

<a name="method-str-replace-first"></a>
#### `Str::replaceFirst()` {.collection-method}

El método `Str::replaceFirst` reemplaza la primera aparición de un valor dado en una cadena:

    use Illuminate\Support\Str;

    $replaced = Str::replaceFirst('the', 'a', 'the quick brown fox jumps over the lazy dog');

    // a quick brown fox jumps over the lazy dog

<a name="method-str-replace-last"></a>
#### `Str::replaceLast()` {.collection-method}

El método `Str::replaceLast` reemplaza la última aparición de un valor dado en una cadena:

    use Illuminate\Support\Str;

    $replaced = Str::replaceLast('the', 'a', 'the quick brown fox jumps over the lazy dog');

    // the quick brown fox jumps over a lazy dog


<a name="method-str-reverse"></a>
#### `Str::reverse()` {.collection-method}

El método `Str::reverse` invierte la cadena dada:

    use Illuminate\Support\Str;

    $reversed = Str::reverse('Hello World');

    // dlroW olleH

<a name="method-str-singular"></a>
#### `Str::singular()` {.collection-method}

El método `Str::singular` convierte una cadena a su forma singular. Esta función soporta cualquiera de [los lenguajes soportados ](/docs/{{version}}/localization#pluralization-language) por el pluralizador de Laravel:

    use Illuminate\Support\Str;

    $singular = Str::singular('cars');

    // car

    $singular = Str::singular('children');

    // child

<a name="method-str-slug"></a>
#### `Str::slug()` {.collection-method}

El método `Str::slug` genera una URL amigable "slug" a partir de la cadena dada:

    use Illuminate\Support\Str;

    $slug = Str::slug('Laravel 5 Framework', '-');

    // laravel-5-framework

<a name="method-snake-case"></a>
#### `Str::snake()` {.collection-method}

El método `Str::snake` convierte la cadena dada a `snake_case`:

    use Illuminate\Support\Str;

    $converted = Str::snake('fooBar');

    // foo_bar

    $converted = Str::snake('fooBar', '-');

    // foo-bar

<a name="method-str-squish"></a>
#### `Str::squish()` {.collection-method}

El método `Str::squish` elimina todos los espacios en blanco extraños de una cadena, incluidos los espacios en blanco extraños entre palabras:

    use Illuminate\Support\Str;

    $string = Str::squish('    laravel    framework    ');

    // laravel framework

<a name="method-str-start"></a>
#### `Str::start()` {.collection-method}

El método `Str::start` añade una única instancia del valor dado a una cadena si no empieza ya con ese valor:

    use Illuminate\Support\Str;

    $adjusted = Str::start('this/string', '/');

    // /this/string

    $adjusted = Str::start('/this/string', '/');

    // /this/string

<a name="method-starts-with"></a>
#### `Str::startsWith()` {.collection-method}

El método `Str::startsWith` determina si la cadena dada comienza con el valor dado:

    use Illuminate\Support\Str;

    $result = Str::startsWith('This is my name', 'This');

    // true

Si se pasa un array de posibles valores, el método `startsWith` devolverá `true` si la cadena empieza por alguno de los valores dados:

    $result = Str::startsWith('This is my name', ['This', 'That', 'There']);

    // true

<a name="method-studly-case"></a>
#### `Str::studly()` {.collection-method}

El método `Str::studly` convierte la cadena dada a `StudlyCase`:

    use Illuminate\Support\Str;

    $converted = Str::studly('foo_bar');

    // FooBar

<a name="method-str-substr"></a>
#### `Str::substr()` {.collection-method}

El método `Str::substr` devuelve la parte de la cadena especificada por los parámetros start y length:

    use Illuminate\Support\Str;

    $converted = Str::substr('The Laravel Framework', 4, 7);

    // Laravel

<a name="method-str-substrcount"></a>
#### `Str::substrCount()` {.collection-method}

El método `Str::substrCount` devuelve el número de apariciones de un valor dado en la cadena dada:

    use Illuminate\Support\Str;

    $count = Str::substrCount('If you like ice cream, you will like snow cones.', 'like');

    // 2

<a name="method-str-substrreplace"></a>
#### `Str::substrReplace()` {.collection-method}

El método `Str::substrReplace` sustituye texto dentro de una parte de una cadena, empezando en la posición especificada por el tercer argumento y sustituyendo el número de caracteres especificado por el cuarto argumento. Pasando `0` al cuarto argumento del método se insertará la cadena en la posición especificada sin reemplazar ninguno de los caracteres existentes en la cadena:

    use Illuminate\Support\Str;

    $result = Str::substrReplace('1300', ':', 2);
    // 13:

    $result = Str::substrReplace('1300', ':', 2, 0);
    // 13:00

<a name="method-str-swap"></a>
#### `Str::swap()` {.collection-method}

El método `Str::swap` reemplaza múltiples valores en la cadena dada usando la función `strtr` de PHP:

    use Illuminate\Support\Str;

    $string = Str::swap([
        'Tacos' => 'Burritos',
        'great' => 'fantastic',
    ], 'Tacos are great!');

    // Burritos are fantastic!

<a name="method-title-case"></a>
#### `Str::title()` {.collection-method}

El método `Str::title` convierte la cadena dada a `Title Case`:

    use Illuminate\Support\Str;

    $converted = Str::title('a nice title uses the correct case');

    // A Nice Title Uses The Correct Case

<a name="method-str-to-html-string"></a>
#### `Str::toHtmlString()` {.collection-method}

El método `Str::toHtmlString` convierte la instancia de cadena en una instancia de `Illuminate\Support\HtmlString`, que puede mostrarse en plantillas Blade:

    use Illuminate\Support\Str;

    $htmlString = Str::of('Nuno Maduro')->toHtmlString();

<a name="method-str-ucfirst"></a>
#### `Str::ucfirst()` {.collection-method}

El método `Str::ucfirst` devuelve la cadena dada con el primer carácter en mayúsculas:

    use Illuminate\Support\Str;

    $string = Str::ucfirst('foo bar');

    // Foo bar

<a name="method-str-ucsplit"></a>
#### `Str::ucsplit()` {.collection-method}

El método `Str::ucsplit` divide la cadena dada en un array por caracteres en mayúsculas:

    use Illuminate\Support\Str;

    $segments = Str::ucsplit('FooBar');

    // [0 => 'Foo', 1 => 'Bar']

<a name="method-str-upper"></a>
#### `Str::upper()` {.collection-method}

El método `Str::upper` convierte la cadena dada a mayúsculas:

    use Illuminate\Support\Str;

    $string = Str::upper('laravel');

    // LARAVEL

<a name="method-str-ulid"></a>
#### `Str::ulid()` {.collection-method}

El método `Str::ulid` genera un ULID:

    use Illuminate\Support\Str;

    return (string) Str::ulid();

    // 01gd6r360bp37zj17nxb55yv40

<a name="method-str-uuid"></a>
#### `Str::uuid()` {.collection-method}

El método `Str::uuid` genera un UUID (versión 4):

    use Illuminate\Support\Str;

    return (string) Str::uuid();

<a name="method-str-word-count"></a>
#### `Str::wordCount()` {.collection-method}

El método `Str::wordCount` devuelve el número de palabras que contiene una cadena:

```php
use Illuminate\Support\Str;

Str::wordCount('Hello, world!'); // 2
```

<a name="method-str-words"></a>
#### `Str::words()` {.collection-method}

El método `Str::words` limita el número de palabras de una cadena. Puede pasarse una cadena adicional a este método a través de su tercer argumento para especificar qué cadena debe añadirse al final de la cadena truncada:

    use Illuminate\Support\Str;

    return Str::words('Perfectly balanced, as all things should be.', 3, ' >>>');

    // Perfectly balanced, as >>>

<a name="method-str"></a>
#### `str()` {.collection-method}

La función `str` devuelve una nueva instancia `Illuminate\Support\Stringable` de la cadena dada. Esta función es equivalente al método `Str::of`:

    $string = str('Taylor')->append(' Otwell');

    // 'Taylor Otwell'

Si no se proporciona ningún argumento a la función `str`, la función devuelve una instancia de `Illuminate\Support\Str`:

    $snake = str()->snake('FooBar');

    // 'foo_bar'

<a name="method-trans"></a>
#### `trans()` {.collection-method}

La función `trans` traduce la clave de traducción dada utilizando sus [archivos de localización](/docs/{{version}}/localization):

    echo trans('messages.welcome');

Si la clave de traducción especificada no existe, la función `trans` devolverá la clave dada. Así, utilizando el ejemplo anterior, la función `trans` devolvería `messages.welcome` si la clave de traducción no existe.

<a name="method-trans-choice"></a>
#### `trans_choice()` {.collection-method}

La función `trans_choice` traduce la clave de traducción dada con inflexión:

    echo trans_choice('messages.notifications', $unreadCount);

Si la clave de traducción especificada no existe, la función `trans_choice` devolverá la clave dada. Así, utilizando el ejemplo anterior, la función `trans_choice` devolvería `messages.notifications` si la clave de traducción no existe.

<a name="fluent-strings"></a>
## Fluent Strings

Las cadenas fluidas proporcionan una interfaz más fluida y orientada a objetos para trabajar con valores de cadena, lo que permite encadenar múltiples operaciones de cadena utilizando una sintaxis más legible en comparación con las operaciones de cadena tradicionales.

<a name="method-fluent-str-after"></a>
#### `after` {.collection-method}

El método `after` devuelve todo lo que hay después del valor dado en una cadena. Se devolverá la cadena completa si el valor no existe dentro de la cadena:

    use Illuminate\Support\Str;

    $slice = Str::of('This is my name')->after('This is');

    // ' my name'

<a name="method-fluent-str-after-last"></a>
#### `afterLast` {.collection-method}

El método `afterLast` devuelve todo lo que hay después de la última aparición del valor dado en una cadena. Se devolverá la cadena entera si el valor no existe dentro de la cadena:

    use Illuminate\Support\Str;

    $slice = Str::of('App\Http\Controllers\Controller')->afterLast('\\');

    // 'Controller'

<a name="method-fluent-str-append"></a>
#### `append` {.collection-method}

El método `append` añade los valores dados a la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('Taylor')->append(' Otwell');

    // 'Taylor Otwell'

<a name="method-fluent-str-ascii"></a>
#### `ascii` {.collection-method}

El método `ascii` intentará transcribir la cadena a un valor ASCII:

    use Illuminate\Support\Str;

    $string = Str::of('ü')->ascii();

    // 'u'

<a name="method-fluent-str-basename"></a>
#### `basename` {.collection-method}

El método `basename` devolverá el componente final del nombre de la cadena dada:

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz')->basename();

    // 'baz'

Si es necesario, puede proporcionar una "extensión" que se eliminará del componente final:

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz.jpg')->basename('.jpg');

    // 'baz'

<a name="method-fluent-str-before"></a>
#### `before` {.collection-method}

El método `before` devuelve todo lo que hay antes del valor dado en una cadena:

    use Illuminate\Support\Str;

    $slice = Str::of('This is my name')->before('my name');

    // 'This is '

<a name="method-fluent-str-before-last"></a>
#### `beforeLast` {.collection-method}

El método `beforeLast` devuelve todo lo que hay antes de la última aparición del valor dado en una cadena:

    use Illuminate\Support\Str;

    $slice = Str::of('This is my name')->beforeLast('is');

    // 'This '

<a name="method-fluent-str-between"></a>
#### `between` {.collection-method}

El método `between` devuelve la parte de una cadena comprendida entre dos valores:

    use Illuminate\Support\Str;

    $converted = Str::of('This is my name')->between('This', 'name');

    // ' is my '

<a name="method-fluent-str-between-first"></a>
#### `betweenFirst` {.collection-method}

El método `betweenFirst` devuelve la porción más pequeña posible de una cadena entre dos valores:

    use Illuminate\Support\Str;

    $converted = Str::of('[a] bc [d]')->betweenFirst('[', ']');

    // 'a'

<a name="method-fluent-str-camel"></a>
#### `camel` {.collection-method}

El método `camel` convierte la cadena dada a `camelCase`:

    use Illuminate\Support\Str;

    $converted = Str::of('foo_bar')->camel();

    // fooBar

<a name="method-fluent-str-class-basename"></a>
#### `classBasename` {.collection-method}

El método `classBasename` devuelve el nombre de la clase dada sin su espacio de nombres:

    use Illuminate\Support\Str;

    $class = Str::of('Foo\Bar\Baz')->classBasename();

    // Baz

<a name="method-fluent-str-contains"></a>
#### `contains` {.collection-method}

El método `contains` determina si la cadena dada contiene el valor dado. Este método distingue entre mayúsculas y minúsculas:

    use Illuminate\Support\Str;

    $contains = Str::of('This is my name')->contains('my');

    // true

También puede pasar un array de valores para determinar si la cadena dada contiene alguno de los valores de el array:

    use Illuminate\Support\Str;

    $contains = Str::of('This is my name')->contains(['my', 'foo']);

    // true

<a name="method-fluent-str-contains-all"></a>
#### `containsAll` {.collection-method}

El método `containsAll` determina si la cadena dada contiene todos los valores de el array dado:

    use Illuminate\Support\Str;

    $containsAll = Str::of('This is my name')->containsAll(['my', 'name']);

    // true

<a name="method-fluent-str-dirname"></a>
#### `dirname` {.collection-method}

El método `dirname` devuelve la parte del directorio padre de la cadena dada:

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz')->dirname();

    // '/foo/bar'

Si es necesario, puede especificar cuántos niveles de directorio desea recortar de la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz')->dirname(2);

    // '/foo'

<a name="method-fluent-str-excerpt"></a>
#### `excerpt` {.collection-method}

El método `excerpt` extrae un fragmento de la cadena que coincide con la primera instancia de una frase dentro de esa cadena:

    use Illuminate\Support\Str;

    $excerpt = Str::of('This is my name')->excerpt('my', [
        'radius' => 3
    ]);

    // '...is my na...'

La opción `radio`, que por defecto es `100`, le permite definir el número de caracteres que deben aparecer a cada lado de la cadena truncada.

Además, puede utilizar la opción de `omisión` para cambiar la cadena que se antepondrá y añadirá a la cadena truncada:

    use Illuminate\Support\Str;

    $excerpt = Str::of('This is my name')->excerpt('name', [
        'radius' => 3,
        'omission' => '(...) '
    ]);

    // '(...) my name'

<a name="method-fluent-str-ends-with"></a>
#### `endsWith` {.collection-method}

El método `endsWith` determina si la cadena dada termina con el valor dado:

    use Illuminate\Support\Str;

    $result = Str::of('This is my name')->endsWith('name');

    // true

También puede pasar un array de valores para determinar si la cadena dada termina con cualquiera de los valores de el array:

    use Illuminate\Support\Str;

    $result = Str::of('This is my name')->endsWith(['name', 'foo']);

    // true

    $result = Str::of('This is my name')->endsWith(['this', 'foo']);

    // false

<a name="method-fluent-str-exactly"></a>
#### `exactly` {.collection-method}

El método `exactly` determina si la cadena dada coincide exactamente con otra cadena:

    use Illuminate\Support\Str;

    $result = Str::of('Laravel')->exactly('Laravel');

    // true

<a name="method-fluent-str-explode"></a>
#### `explode` {.collection-method}

El método `explode` divide la cadena por el delimitador dado y devuelve una colección que contiene cada sección de la cadena dividida:

    use Illuminate\Support\Str;

    $collection = Str::of('foo bar baz')->explode(' ');

    // collect(['foo', 'bar', 'baz'])

<a name="method-fluent-str-finish"></a>
#### `finish` {.collection-method}

El método `finish` añade una única instancia del valor dado a una cadena si no termina ya con ese valor:

    use Illuminate\Support\Str;

    $adjusted = Str::of('this/string')->finish('/');

    // this/string/

    $adjusted = Str::of('this/string/')->finish('/');

    // this/string/

<a name="method-fluent-str-headline"></a>
#### `headline` {.collection-method}

El método `headline` convierte cadenas delimitadas por mayúsculas, guiones o guiones bajos en una cadena delimitada por espacios con la primera letra de cada palabra en mayúscula:

    use Illuminate\Support\Str;

    $headline = Str::of('taylor_otwell')->headline();

    // Taylor Otwell

    $headline = Str::of('EmailNotificationSent')->headline();

    // Email Notification Sent

<a name="method-fluent-str-inline-markdown"></a>
#### `inlineMarkdown` {.collection-method}

El método `inlineMarkdown` convierte Markdown (tipo GitHub) en HTML en línea utilizando [CommonMark](https://commonmark.thephpleague.com/). Sin embargo, a diferencia del método `markdown`, no envuelve todo el HTML generado en un elemento a nivel de bloque:

    use Illuminate\Support\Str;

    $html = Str::of('**Laravel**')->inlineMarkdown();

    // <strong>Laravel</strong>

<a name="method-fluent-str-is"></a>
#### `is` {.collection-method}

El método `is` determina si una cadena dada coincide con un patrón dado. Los asteriscos pueden utilizarse como comodines

    use Illuminate\Support\Str;

    $matches = Str::of('foobar')->is('foo*');

    // true

    $matches = Str::of('foobar')->is('baz*');

    // false

<a name="method-fluent-str-is-ascii"></a>
#### `isAscii` {.collection-method}

El método `isAscii` determina si una cadena dada es una cadena ASCII:

    use Illuminate\Support\Str;

    $result = Str::of('Taylor')->isAscii();

    // true

    $result = Str::of('ü')->isAscii();

    // false

<a name="method-fluent-str-is-empty"></a>
#### `isEmpty` {.collection-method}

El método `isEmpty` determina si la cadena dada está vacía:

    use Illuminate\Support\Str;

    $result = Str::of('  ')->trim()->isEmpty();

    // true

    $result = Str::of('Laravel')->trim()->isEmpty();

    // false

<a name="method-fluent-str-is-not-empty"></a>
#### `isNotEmpty` {.collection-method}

El método `isNotEmpty` determina si la cadena dada no está vacía:


    use Illuminate\Support\Str;

    $result = Str::of('  ')->trim()->isNotEmpty();

    // false

    $result = Str::of('Laravel')->trim()->isNotEmpty();

    // true

<a name="method-fluent-str-is-json"></a>
#### `isJson` {.collection-method}

El método `isJson` determina si una cadena dada es un JSON válido:

    use Illuminate\Support\Str;

    $result = Str::of('[1,2,3]')->isJson();

    // true

    $result = Str::of('{"first": "John", "last": "Doe"}')->isJson();

    // true

    $result = Str::of('{first: "John", last: "Doe"}')->isJson();

    // false

<a name="method-fluent-str-is-ulid"></a>
#### `isUlid` {.collection-method}

El método `isUlid` determina si una cadena dada es un ULID:

    use Illuminate\Support\Str;

    $result = Str::of('01gd6r360bp37zj17nxb55yv40')->isUlid();

    // true

    $result = Str::of('Taylor')->isUlid();

    // false

<a name="method-fluent-str-is-uuid"></a>
#### `isUuid` {.collection-method}

El método `isUuid` determina si una cadena dada es un UUID:

    use Illuminate\Support\Str;

    $result = Str::of('5ace9ab9-e9cf-4ec6-a19d-5881212a452c')->isUuid();

    // true

    $result = Str::of('Taylor')->isUuid();

    // false

<a name="method-fluent-str-kebab"></a>
#### `kebab` {.collection-method}

El método `kebab` convierte la cadena dada a `kebab-case`:

    use Illuminate\Support\Str;

    $converted = Str::of('fooBar')->kebab();

    // foo-bar

<a name="method-fluent-str-lcfirst"></a>
#### `lcfirst` {.collection-method}

El método `lcfirst` devuelve la cadena dada con el primer carácter en minúsculas:

    use Illuminate\Support\Str;

    $string = Str::of('Foo Bar')->lcfirst();

    // foo Bar


<a name="method-fluent-str-length"></a>
#### `length` {.collection-method}

El método `length` devuelve la longitud de la cadena dada:

    use Illuminate\Support\Str;

    $length = Str::of('Laravel')->length();

    // 7

<a name="method-fluent-str-limit"></a>
#### `limit` {.collection-method}

El método `limit` trunca la cadena dada hasta la longitud especificada:

    use Illuminate\Support\Str;

    $truncated = Str::of('The quick brown fox jumps over the lazy dog')->limit(20);

    // The quick brown fox...

También puede pasar un segundo argumento para cambiar la cadena que se añadirá al final de la cadena truncada:

    use Illuminate\Support\Str;

    $truncated = Str::of('The quick brown fox jumps over the lazy dog')->limit(20, ' (...)');

    // The quick brown fox (...)

<a name="method-fluent-str-lower"></a>
#### `lower` {.collection-method}

El método `lower` convierte la cadena dada a minúsculas:

    use Illuminate\Support\Str;

    $result = Str::of('LARAVEL')->lower();

    // 'laravel'

<a name="method-fluent-str-ltrim"></a>
#### `ltrim` {.collection-method}

El método `ltrim` recorta el lado izquierdo de la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('  Laravel  ')->ltrim();

    // 'Laravel  '

    $string = Str::of('/Laravel/')->ltrim('/');

    // 'Laravel/'

<a name="method-fluent-str-markdown"></a>
#### `markdown` {.collection-method}

El método `markdown` convierte Markdown (en su variante GitHub) en HTML:

    use Illuminate\Support\Str;

    $html = Str::of('# Laravel')->markdown();

    // <h1>Laravel</h1>

    $html = Str::of('# Taylor <b>Otwell</b>')->markdown([
        'html_input' => 'strip',
    ]);

    // <h1>Taylor Otwell</h1>

<a name="method-fluent-str-mask"></a>
#### `mask` {.collection-method}

El método `mask` enmascara una parte de una cadena con un carácter repetido, y puede utilizarse para ofuscar segmentos de cadenas como direcciones de correo electrónico y números de teléfono:

    use Illuminate\Support\Str;

    $string = Str::of('taylor@example.com')->mask('*', 3);

    // tay***************

Si es necesario, proporcione un número negativo como tercer argumento al método `mask`, que le indicará que comience a enmascarar a la distancia dada del final de la cadena:

    $string = Str::of('taylor@example.com')->mask('*', -15, 3);

    // tay***@example.com

<a name="method-fluent-str-match"></a>
#### `match` {.collection-method}

El método `match` devuelve la parte de una cadena que coincide con un patrón de expresión regular dado:

    use Illuminate\Support\Str;

    $result = Str::of('foo bar')->match('/bar/');

    // 'bar'

    $result = Str::of('foo bar')->match('/foo (.*)/');

    // 'bar'

<a name="method-fluent-str-match-all"></a>
#### `matchAll` {.collection-method}

El método `matchAll` devuelve una colección que contiene las partes de una cadena que coinciden con un patrón de expresión regular dado:

    use Illuminate\Support\Str;

    $result = Str::of('bar foo bar')->matchAll('/bar/');

    // collect(['bar', 'bar'])

Si especifica un grupo coincidente dentro de la expresión, Laravel devolverá una colección con las coincidencias de ese grupo:

    use Illuminate\Support\Str;

    $result = Str::of('bar fun bar fly')->matchAll('/f(\w*)/');

    // collect(['un', 'ly']);

Si no se encuentra ninguna coincidencia, se devolverá una colección vacía.

<a name="method-fluent-str-new-line"></a>
#### `newLine` {.collection-method}

El método `newLine` añade un carácter de "fin de línea" a una cadena:

    use Illuminate\Support\Str;

    $padded = Str::of('Laravel')->newLine()->append('Framework');

    // 'Laravel
    //  Framework'

<a name="method-fluent-str-padboth"></a>
#### `padBoth` {.collection-method}

El método `padBoth` envuelve la función `str_pad` de PHP, rellenando ambos lados de una cadena con otra cadena hasta que la cadena final alcanza la longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::of('James')->padBoth(10, '_');

    // '__James___'

    $padded = Str::of('James')->padBoth(10);

    // '  James   '

<a name="method-fluent-str-padleft"></a>
#### `padLeft` {.collection-method}

El método `padLeft` envuelve la función `str_pad` de PHP, rellenando el lado izquierdo de una cadena con otra cadena hasta que la cadena final alcanza la longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::of('James')->padLeft(10, '-=');

    // '-=-=-James'

    $padded = Str::of('James')->padLeft(10);

    // '     James'

<a name="method-fluent-str-padright"></a>
#### `padRight` {.collection-method}

El método `padRight` envuelve la función `str_pad` de PHP, rellenando el lado derecho de una cadena con otra cadena hasta que la cadena final alcance la longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::of('James')->padRight(10, '-');

    // 'James-----'

    $padded = Str::of('James')->padRight(10);

    // 'James     '

<a name="method-fluent-str-pipe"></a>
#### `pipe` {.collection-method}

El método `pipe` permite transformar la cadena pasando su valor actual a la llamada dada:

    use Illuminate\Support\Str;

    $hash = Str::of('Laravel')->pipe('md5')->prepend('Checksum: ');

    // 'Checksum: a5c95b86291ea299fcbe64458ed12702'

    $closure = Str::of('foo')->pipe(function ($str) {
        return 'bar';
    });

    // 'bar'

<a name="method-fluent-str-plural"></a>
#### `plural` {.collection-method}

El método `plural` convierte una cadena de palabras en singular a su forma plural. Esta función soporta [cualquiera de los lenguajes soportados por el pluralizador de Laravel](/docs/{{version}}/localization#pluralization-language):

    use Illuminate\Support\Str;

    $plural = Str::of('car')->plural();

    // cars

    $plural = Str::of('child')->plural();

    // children

Puede proporcionar un número entero como segundo argumento de la función para recuperar la forma singular o plural de la cadena:

    use Illuminate\Support\Str;

    $plural = Str::of('child')->plural(2);

    // children

    $plural = Str::of('child')->plural(1);

    // child

<a name="method-fluent-str-prepend"></a>
#### `prepend` {.collection-method}

El método `prepend` añade los valores dados a la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('Framework')->prepend('Laravel ');

    // Laravel Framework

<a name="method-fluent-str-remove"></a>
#### `remove` {.collection-method}

El método `remove` elimina el valor o el array de valores dados de la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('Arkansas is quite beautiful!')->remove('quite');

    // Arkansas is beautiful!

También puede pasar `false` como segundo parámetro para ignorar mayúsculas y minúsculas al eliminar cadenas.

<a name="method-fluent-str-replace"></a>
#### `replace` {.collection-method}

El método `replace` reemplaza una cadena dada dentro de la cadena:

    use Illuminate\Support\Str;

    $replaced = Str::of('Laravel 6.x')->replace('6.x', '7.x');

    // Laravel 7.x

<a name="method-fluent-str-replace-array"></a>
#### `replaceArray` {.collection-method}

El método `replaceArray` reemplaza un valor dado en la cadena secuencialmente usando un array:

    use Illuminate\Support\Str;

    $string = 'The event will take place between ? and ?';

    $replaced = Str::of($string)->replaceArray('?', ['8:30', '9:00']);

    // The event will take place between 8:30 and 9:00

<a name="method-fluent-str-replace-first"></a>
#### `replaceFirst` {.collection-method}

El método `replaceFirst` reemplaza la primera aparición de un valor dado en una cadena:

    use Illuminate\Support\Str;

    $replaced = Str::of('the quick brown fox jumps over the lazy dog')->replaceFirst('the', 'a');

    // a quick brown fox jumps over the lazy dog

<a name="method-fluent-str-replace-last"></a>
#### `replaceLast` {.collection-method}

El método `replaceLast` reemplaza la última aparición de un valor dado en una cadena:

    use Illuminate\Support\Str;

    $replaced = Str::of('the quick brown fox jumps over the lazy dog')->replaceLast('the', 'a');

    // the quick brown fox jumps over a lazy dog

<a name="method-fluent-str-replace-matches"></a>
#### `replaceMatches` {.collection-method}

El método `replaceMatches` sustituye todas las partes de una cadena que coincidan con un patrón por la cadena de sustitución dada:

    use Illuminate\Support\Str;

    $replaced = Str::of('(+1) 501-555-1000')->replaceMatches('/[^A-Za-z0-9]++/', '')

    // '15015551000'

El método `replaceMatches` también acepta un closure que será invocado con cada porción de la cadena que coincida con el patrón dado, permitiéndole realizar la lógica de reemplazo dentro del closure y devolver el valor reemplazado:

    use Illuminate\Support\Str;

    $replaced = Str::of('123')->replaceMatches('/\d/', function ($match) {
        return '['.$match[0].']';
    });

    // '[1][2][3]'

<a name="method-fluent-str-rtrim"></a>
#### `rtrim` {.collection-method}

El método `rtrim` recorta el lado derecho de la cadena dada:

    use Illuminate\Support\Str;

    $string = Str::of('  Laravel  ')->rtrim();

    // '  Laravel'

    $string = Str::of('/Laravel/')->rtrim('/');

    // '/Laravel'

<a name="method-fluent-str-scan"></a>
#### `scan` {.collection-method}

El método `scan` analiza la entrada de una cadena en una colección de acuerdo a un formato soportado por la [función PHP`sscanf`](https://www.php.net/manual/en/function.sscanf.php):

    use Illuminate\Support\Str;

    $collection = Str::of('filename.jpg')->scan('%[^.].%s');

    // collect(['filename', 'jpg'])

<a name="method-fluent-str-singular"></a>
#### `singular` {.collection-method}

El método `singular` convierte una cadena a su forma singular. Esta función soporta [cualquiera de los lenguajes soportados por el pluralizador de Laravel](/docs/{{version}}/localization#pluralization-language):

    use Illuminate\Support\Str;

    $singular = Str::of('cars')->singular();

    // car

    $singular = Str::of('children')->singular();

    // child

<a name="method-fluent-str-slug"></a>
#### `slug` {.collection-method}

El método `slug` genera una URL amigable "slug" a partir de la cadena dada:

    use Illuminate\Support\Str;

    $slug = Str::of('Laravel Framework')->slug('-');

    // laravel-framework

<a name="method-fluent-str-snake"></a>
#### `snake` {.collection-method}

El método `snake` convierte la cadena dada a `snake_case`:

    use Illuminate\Support\Str;

    $converted = Str::of('fooBar')->snake();

    // foo_bar

<a name="method-fluent-str-split"></a>
#### `split` {.collection-method}

El método `split` divide una cadena en una colección utilizando una expresión regular:

    use Illuminate\Support\Str;

    $segments = Str::of('one, two, three')->split('/[\s,]+/');

    // collect(["one", "two", "three"])

<a name="method-fluent-str-squish"></a>
#### `squish` {.collection-method}

El método `squish` elimina todos los espacios en blanco extraños de una cadena, incluidos los espacios en blanco extraños entre palabras:

    use Illuminate\Support\Str;

    $string = Str::of('    laravel    framework    ')->squish();

    // laravel framework

<a name="method-fluent-str-start"></a>
#### `start` {.collection-method}

El método `start` añade una única instancia del valor dado a una cadena si no empieza ya con ese valor:

    use Illuminate\Support\Str;

    $adjusted = Str::of('this/string')->start('/');

    // /this/string

    $adjusted = Str::of('/this/string')->start('/');

    // /this/string

<a name="method-fluent-str-starts-with"></a>
#### `startsWith` {.collection-method}

El método `startsWith` determina si la cadena dada empieza por el valor dado:

    use Illuminate\Support\Str;

    $result = Str::of('This is my name')->startsWith('This');

    // true

<a name="method-fluent-str-studly"></a>
#### `studly` {.collection-method}

El método `studly` convierte la cadena dada a `StudlyCase`:

    use Illuminate\Support\Str;

    $converted = Str::of('foo_bar')->studly();

    // FooBar

<a name="method-fluent-str-substr"></a>
#### `substr` {.collection-method}

El método `substr` devuelve la parte de la cadena especificada por los parámetros start y length dados:

    use Illuminate\Support\Str;

    $string = Str::of('Laravel Framework')->substr(8);

    // Framework

    $string = Str::of('Laravel Framework')->substr(8, 5);

    // Frame

<a name="method-fluent-str-substrreplace"></a>
#### `substrReplace` {.collection-method}

El método `substrReplace` sustituye texto dentro de una parte de una cadena, empezando en la posición especificada por el segundo argumento y sustituyendo el número de caracteres especificado por el tercer argumento. Si se pasa `0` al tercer argumento del método, se insertará la cadena en la posición especificada sin reemplazar ninguno de los caracteres existentes en la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('1300')->substrReplace(':', 2);

    // 13:

    $string = Str::of('The Framework')->substrReplace(' Laravel', 3, 0);

    // The Laravel Framework

<a name="method-fluent-str-swap"></a>
#### `swap` {.collection-method}

El método `swap` reemplaza múltiples valores en la cadena usando la función `strtr` de PHP:

    use Illuminate\Support\Str;

    $string = Str::of('Tacos are great!')
        ->swap([
            'Tacos' => 'Burritos',
            'great' => 'fantastic',
        ]);

    // Burritos are fantastic!

<a name="method-fluent-str-tap"></a>
#### `tap` {.collection-method}

El método `tap` pasa la cadena al closure dado, permitiéndole examinar e interactuar con la cadena sin afectar a la propia cadena. La cadena original es devuelta por el método `tap` independientemente de lo que sea devuelto por el closure:

    use Illuminate\Support\Str;

    $string = Str::of('Laravel')
        ->append(' Framework')
        ->tap(function ($string) {
            dump('String after append: '.$string);
        })
        ->upper();

    // LARAVEL FRAMEWORK

<a name="method-fluent-str-test"></a>
#### `test` {.collection-method}

El método `test` determina si una cadena coincide con el patrón de expresión regular dado:

    use Illuminate\Support\Str;

    $result = Str::of('Laravel Framework')->test('/Laravel/');

    // true

<a name="method-fluent-str-title"></a>
#### `title` {.collection-method}

El método `title` convierte la cadena dada a `Title Case`:

    use Illuminate\Support\Str;

    $converted = Str::of('a nice title uses the correct case')->title();

    // A Nice Title Uses The Correct Case

<a name="method-fluent-str-trim"></a>
#### `trim` {.collection-method}

El método `trim` recorta la cadena dada:

    use Illuminate\Support\Str;

    $string = Str::of('  Laravel  ')->trim();

    // 'Laravel'

    $string = Str::of('/Laravel/')->trim('/');

    // 'Laravel'

<a name="method-fluent-str-ucfirst"></a>
#### `ucfirst` {.collection-method}

El método `ucfirst` devuelve la cadena dada con el primer carácter en mayúscula:

    use Illuminate\Support\Str;

    $string = Str::of('foo bar')->ucfirst();

    // Foo bar

<a name="method-fluent-str-ucsplit"></a>
#### `ucsplit` {.collection-method}

El método `ucsplit` divide la cadena dada en una colección por caracteres en mayúsculas:

    use Illuminate\Support\Str;

    $string = Str::of('Foo Bar')->ucsplit();

    // collect(['Foo', 'Bar'])

<a name="method-fluent-str-upper"></a>
#### `upper` {.collection-method}

El método `upper` convierte la cadena dada a mayúsculas:

    use Illuminate\Support\Str;

    $adjusted = Str::of('laravel')->upper();

    // LARAVEL

<a name="method-fluent-str-when"></a>
#### `when` {.collection-method}

El método `when` invoca el closure dado si una condición dada es `true`. El closure recibirá la instancia de la cadena fluent:

    use Illuminate\Support\Str;

    $string = Str::of('Taylor')
                    ->when(true, function ($string) {
                        return $string->append(' Otwell');
                    });

    // 'Taylor Otwell'

Si es necesario, puede pasar otro closure como tercer parámetro al método `when`. Este closure se ejecutará si el parámetro de la condición se evalúa como `false`.

<a name="method-fluent-str-when-contains"></a>
#### `whenContains` {.collection-method}

El método `whenContains` invoca el closure dado si la cadena contiene el valor dado. El closure recibirá la instancia fluent string:

    use Illuminate\Support\Str;

    $string = Str::of('tony stark')
                ->whenContains('tony', function ($string) {
                    return $string->title();
                });

    // 'Tony Stark'

Si es necesario, puede pasar otro closure como tercer parámetro al método `when`. Este closure se ejecutará si la cadena no contiene el valor dado.

También puede pasar un array de valores para determinar si la cadena dada contiene alguno de los valores de el array:

    use Illuminate\Support\Str;

    $string = Str::of('tony stark')
                ->whenContains(['tony', 'hulk'], function ($string) {
                    return $string->title();
                });

    // Tony Stark

<a name="method-fluent-str-when-contains-all"></a>
#### `whenContainsAll` {.collection-method}

El método `whenContainsAll` invoca el closure dado si la cadena contiene todas las subcadenas dadas. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('tony stark')
                    ->whenContainsAll(['tony', 'stark'], function ($string) {
                        return $string->title();
                    });

    // 'Tony Stark'

Si es necesario, puede pasar otro closure como tercer parámetro al método `when`. Este closure se ejecutará si el parámetro de condición es `false`.

<a name="method-fluent-str-when-empty"></a>
#### `whenEmpty` {.collection-method}

El método `whenEmpty` invoca el closure dado si la cadena está vacía. Si el closure devuelve un valor, éste también será devuelto por el método `whenEmpty`. Si el closure no devuelve ningún valor, se devolverá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('  ')->whenEmpty(function ($string) {
        return $string->trim()->prepend('Laravel');
    });

    // 'Laravel'

<a name="method-fluent-str-when-not-empty"></a>
#### `whenNotEmpty` {.collection-method}

El método `whenNotEmpty` invoca el closure dado si la cadena no está vacía. Si el closure devuelve un valor, éste también será devuelto por el método `whenNotEmpty`. Si el closure no devuelve ningún valor, se devolverá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('Framework')->whenNotEmpty(function ($string) {
        return $string->prepend('Laravel ');
    });

    // 'Laravel Framework'

<a name="method-fluent-str-when-starts-with"></a>
#### `whenStartsWith` {.collection-method}

El método `whenStartsWith` invoca el closure dado si la cadena comienza con la subcadena dada. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('disney world')->whenStartsWith('disney', function ($string) {
        return $string->title();
    });

    // 'Disney World'

<a name="method-fluent-str-when-ends-with"></a>
#### `whenEndsWith` {.collection-method}

El método `whenEndsWith` invoca el closure dado si la cadena termina con la subcadena dada. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('disney world')->whenEndsWith('world', function ($string) {
        return $string->title();
    });

    // 'Disney World'

<a name="method-fluent-str-when-exactly"></a>
#### `whenExactly` {.collection-method}

El método `whenExactly` invoca el closure dado si la cadena coincide exactamente con la cadena dada. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('laravel')->whenExactly('laravel', function ($string) {
        return $string->title();
    });

    // 'Laravel'

<a name="method-fluent-str-when-not-exactly"></a>
#### `whenNotExactly` {.collection-method}

El método `whenNotExactly` invoca el closure dado si la cadena no coincide exactamente con la cadena dada. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('framework')->whenNotExactly('laravel', function ($string) {
        return $string->title();
    });

    // 'Framework'

<a name="method-fluent-str-when-is"></a>
#### `whenIs` {.collection-method}

El método `whenIs` invoca el closure dado si la cadena coincide con un patrón dado. Se pueden utilizar asteriscos como comodines. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('foo/bar')->whenIs('foo/*', function ($string) {
        return $string->append('/baz');
    });

    // 'foo/bar/baz'

<a name="method-fluent-str-when-is-ascii"></a>
#### `whenIsAscii` {.collection-method}

El método `whenIsAscii` invoca el closure dado si la cadena es ASCII de 7 bits. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('laravel')->whenIsAscii(function ($string) {
        return $string->title();
    });

    // 'Laravel'

<a name="method-fluent-str-when-is-ulid"></a>
#### `whenIsUlid` {.collection-method}

El método `whenIsUlid` invoca el closure dado si la cadena es un ULID válido. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('01gd6r360bp37zj17nxb55yv40')->whenIsUlid(function ($string) {
        return $string->substr(0, 8);
    });

    // '01gd6r36'

<a name="method-fluent-str-when-is-uuid"></a>
#### `whenIsUuid` {.collection-method}

El método `whenIsUuid` invoca el closure dado si la cadena es un UUID válido. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('a0a2a2d2-0b87-4a18-83f2-2529882be2de')->whenIsUuid(function ($string) {
        return $string->substr(0, 8);
    });

    // 'a0a2a2d2'

<a name="method-fluent-str-when-test"></a>
#### `whenTest` {.collection-method}

El método `whenTest` invoca el closure dado si la cadena coincide con la expresión regular dada. El closure recibirá la instancia de cadena fluida:

    use Illuminate\Support\Str;

    $string = Str::of('laravel framework')->whenTest('/laravel/', function ($string) {
        return $string->title();
    });

    // 'Laravel Framework'

<a name="method-fluent-str-word-count"></a>
#### `wordCount` {.collection-method}

El método `wordCount` devuelve el número de palabras que contiene una cadena:

```php
use Illuminate\Support\Str;

Str::of('Hello, world!')->wordCount(); // 2
```

<a name="method-fluent-str-words"></a>
#### `words` {.collection-method}

El método `words` limita el número de palabras de una cadena. Si es necesario, puede especificar una cadena adicional que se añadirá a la cadena truncada:

    use Illuminate\Support\Str;

    $string = Str::of('Perfectly balanced, as all things should be.')->words(3, ' >>>');

    // Perfectly balanced, as >>>

<a name="urls"></a>
## URLs

<a name="method-action"></a>
#### `action()` {.collection-method}

La función `action` genera una URL para la acción del controlador dada:

    use App\Http\Controllers\HomeController;

    $url = action([HomeController::class, 'index']);

Si el método acepta parámetros de ruta, puede pasarlos como segundo argumento al método:

    $url = action([UserController::class, 'profile'], ['id' => 1]);

<a name="method-asset"></a>
#### `asset()` {.collection-method}

La función `asset` genera una URL para un asset utilizando el esquema actual de la petición (HTTP o HTTPS):

    $url = asset('img/photo.jpg');

Puede configurar el host de la URL de asset estableciendo la variable `ASSET_URL` en su archivo `.env`. Esto puede ser útil si aloja sus activos en un servicio externo como Amazon S3 u otro CDN:

    // ASSET_URL=http://example.com/assets

    $url = asset('img/photo.jpg'); // http://example.com/assets/img/photo.jpg

<a name="method-route"></a>
#### `route()` {.collection-method}

La función `route` genera una URL para una [ruta](/docs/{{version}}/routing#named-routes) dada:

    $url = route('route.name');

Si la ruta acepta parámetros, puede pasarlos como segundo argumento a la función:

    $url = route('route.name', ['id' => 1]);

Por defecto, la función `route` genera una URL absoluta. Si desea generar una URL relativa, puede pasar `false` como tercer argumento a la función:

    $url = route('route.name', ['id' => 1], false);

<a name="method-secure-asset"></a>
#### `secure_asset()` {.collection-method}

La función `secure_asset` genera una URL para un activo utilizando HTTPS:

    $url = secure_asset('img/photo.jpg');

<a name="method-secure-url"></a>
#### `secure_url()` {.collection-method}

La función `secure_url` genera una URL HTTPS completa para la ruta indicada. Se pueden pasar segmentos de URL adicionales en el segundo argumento de la función:

    $url = secure_url('user/profile');

    $url = secure_url('user/profile', [1]);

<a name="method-to-route"></a>
#### `to_route()` {.collection-method}

La función `to_route` genera una [respuesta HTTP de redirección](/docs/{{version}}/responses#redirects) para una [ruta](/docs/{{version}}/routing#named-routes) determinada:

    return to_route('users.show', ['user' => 1]);

Si es necesario, puede pasar el código de estado HTTP que debe asignarse a la redirección y cualquier cabecera de respuesta adicional como tercer y cuarto argumento del método `to_route`:

    return to_route('users.show', ['user' => 1], 302, ['X-Framework' => 'Laravel']);

<a name="method-url"></a>
#### `url()` {.collection-method}

La función `url` genera una URL completa para la ruta dada:

    $url = url('user/profile');

    $url = url('user/profile', [1]);

Si no se proporciona ninguna ruta, se devuelve una instancia de `Illuminate\Routing\UrlGenerator`:

    $current = url()->current();

    $full = url()->full();

    $previous = url()->previous();

<a name="miscellaneous"></a>
## Varios

<a name="method-abort"></a>
#### `abort()` {.collection-method}

La función `abort` lanza [una excepción HTTP](/docs/{{version}}/errors#http-exceptions) que será procesada por el [gestor de excepciones](/docs/{{version}}/errors#the-exception-handler):

    abort(403);

También puede proporcionar el mensaje de la excepción y las cabeceras de respuesta HTTP personalizadas que deben enviarse al navegador:

    abort(403, 'Unauthorized.', $headers);

<a name="method-abort-if"></a>
#### `abort_if()` {.collection-method}

La función `abort_if` lanza una excepción HTTP si una expresión booleana dada se evalúa como `true`:

    abort_if(! Auth::user()->isAdmin(), 403);

Al igual que el método `abort`, también puede proporcionar el texto de respuesta de la excepción como tercer argumento y un array de cabeceras de respuesta personalizadas como cuarto argumento de la función.

<a name="method-abort-unless"></a>
#### `abort_unless()` {.collection-method}

La función `abort_unless` lanza una excepción HTTP si una expresión booleana dada se evalúa como `false`:

    abort_unless(Auth::user()->isAdmin(), 403);

Al igual que en el método `abort`, también puede proporcionar el texto de respuesta de la excepción como tercer argumento y un array de encabezados de respuesta personalizados como cuarto argumento de la función.

<a name="method-app"></a>
#### `app()` {.collection-method}

La función `app` devuelve la instancia del [contenedor de servicios](/docs/{{version}}/container):

    $container = app();

Puede pasar un nombre de clase o interfaz para resolverlo desde el contenedor:

    $api = app('HelpSpot\API');

<a name="method-auth"></a>
#### `auth()` {.collection-method}

La función `auth` devuelve una instancia [authenticator](/docs/{{version}}/authentication). Puede utilizarla como alternativa a la facade `Auth`:

    $user = auth()->user();

Si es necesario, puede especificar a qué instancia de `guard` desea acceder:

    $user = auth('admin')->user();

<a name="method-back"></a>
#### `back()` {.collection-method}

La función `back` genera una [respuesta HTTP de redirección](/docs/{{version}}/responses#redirects) a la ubicación anterior del usuario:

    return back($status = 302, $headers = [], $fallback = '/');

    return back();

<a name="method-bcrypt"></a>
#### `bcrypt()` {.collection-method}

La función `bcrypt` [realiza el hash](/docs/{{version}}/hashing) del valor dado utilizando Bcrypt. Puede utilizar esta función como alternativa a la facade `Hash`:

    $password = bcrypt('my-secret-password');

<a name="method-blank"></a>
#### `blank()` {.collection-method}

La función `blank` determina si el valor dado es "blank":

    blank('');
    blank('   ');
    blank(null);
    blank(collect());

    // true

    blank(0);
    blank(true);
    blank(false);

    // false

Para la inversa de `blank`, véase el método [`filled`](#method-filled).

<a name="method-broadcast"></a>
#### `broadcast()` {.collection-method}

La función `broadcast` [realiza el broadcast](/docs/{{version}}/broadcasting) del [evento](/docs/{{version}}/events) dado a sus oyentes:

    broadcast(new UserRegistered($user));

    broadcast(new UserRegistered($user))->toOthers();

<a name="method-cache"></a>
#### `cache()` {.collection-method}

La función `cache` puede utilizarse para obtener valores de la [cache](/docs/{{version}}/cache). Si la clave dada no existe en la cache, se devolverá un valor por defecto opcional:

    $value = cache('key');

    $value = cache('key', 'default');

Puede añadir elementos a la cache pasando un array de pares clave / valor a la función. También debe pasar el número de segundos o duración que el valor almacenado en caché debe considerarse válido:

    cache(['key' => 'value'], 300);

    cache(['key' => 'value'], now()->addSeconds(10));

<a name="method-class-uses-recursive"></a>
#### `class_uses_recursive()` {.collection-method}

La función `class_uses_recursive` devuelve todos los traits utilizados por una clase, incluyendo los traits utilizados por todas sus clases padre:

    $traits = class_uses_recursive(App\Models\User::class);

<a name="method-collect"></a>
#### `collect()` {.collection-method}

La función `collect` crea una instancia de [collection](/docs/{{version}}/collections) a partir del valor dado:

    $collection = collect(['taylor', 'abigail']);

<a name="method-config"></a>
#### `config()` {.collection-method}

La función `config` obtiene el valor de una variable de [configuración](/docs/{{version}}/configuration). Se puede acceder a los valores de configuración utilizando la sintaxis "dot", que incluye el nombre del archivo y la opción a la que se desea acceder. Se puede especificar un valor por defecto, que se devuelve si la opción de configuración no existe:

    $value = config('app.timezone');

    $value = config('app.timezone', $default);

Puede establecer variables de configuración en tiempo de ejecución pasando un array de pares clave / valor. Sin embargo, tenga en cuenta que esta función sólo afecta al valor de configuración para la solicitud actual y no actualiza sus valores de configuración reales:

    config(['app.debug' => true]);

<a name="method-cookie"></a>
#### `cookie()` {.collection-method}

La función `cookie` crea una nueva instancia de [cookie](/docs/{{version}}/requests#cookies):

    $cookie = cookie('name', 'value', $minutes);

<a name="method-csrf-field"></a>
#### `csrf_field()` {.collection-method}

La función `csrf_field` genera un campo de entrada `hidden` HTML que contiene el valor del token CSRF. Por ejemplo, utilizando [la sintaxis Blade](/docs/{{version}}/blade):

    {{ csrf_field() }}

<a name="method-csrf-token"></a>
#### `csrf_token()` {.collection-method}

La función `csrf_token` recupera el valor del token CSRF actual:

    $token = csrf_token();

<a name="method-decrypt"></a>
#### `decrypt()` {.collection-method}

La función `decrypt` [descifra](/docs/{{version}}/encryption) el valor dado. Puede utilizar esta función como alternativa a la facade `Crypt`:

    $password = decrypt($value);

<a name="method-dd"></a>
#### `dd()` {.collection-method}

La función `dd` vuelca las variables dadas y finaliza la ejecución del script:

    dd($value);

    dd($value1, $value2, $value3, ...);

Si no desea detener la ejecución de su script, utilice en su lugar la función [`dump`](#method-dump).

<a name="method-dispatch"></a>
#### `dispatch()` {.collection-method}

La función `dispatch` manda el [trabajo (job)](/docs/{{version}}/queues#creating-jobs) dado a la [cola de trabajos de Laravel](/docs/{{version}}/queues):

    dispatch(new App\Jobs\SendEmails);

<a name="method-dump"></a>
#### `dump()` {.collection-method}

La función `dump` vuelca las variables dadas:

    dump($value);

    dump($value1, $value2, $value3, ...);

Si desea detener la ejecución del script después de volcar las variables, utilice la función [`dd`](#method-dd) en su lugar.

<a name="method-encrypt"></a>
#### `encrypt()` {.collection-method}

La función `encrypt` [cifra](/docs/{{version}}/encryption) el valor dado. Puedes usar esta función como alternativa a la facade `Crypt`:

    $secret = encrypt('my-secret-value');

<a name="method-env"></a>
#### `env()` {.collection-method}

La función `env` recupera el valor de una [variable de entorno](/docs/{{version}}/configuration#environment-configuration) o devuelve un valor por defecto:

    $env = env('APP_ENV');

    $env = env('APP_ENV', 'production');

> **Advertencia**  
> Si ejecutas el comando `config:cache` durante tu proceso de despliegue, debes asegurarte de que sólo estás llamando a la función `env` desde dentro de tus archivos de configuración. Una vez que la configuración ha sido cacheada, el archivo `.env` no será cargado y todas las llamadas a la función `env` devolverán `null`.

<a name="method-event"></a>
#### `event()` {.collection-method}

La función `event` envía el [evento](/docs/{{version}}/events) dado a sus "oyentes":

    event(new UserRegistered($user));

<a name="method-fake"></a>
#### `fake()` {.collection-method}

La función `fake` resuelve un singleton [Faker](https://github.com/FakerPHP/Faker) del contenedor, lo que puede ser útil al crear datos falsos en `factories`, `seeders`, tests o prototipando vistas:

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

Por defecto, la función `fake` utilizará la opción de configuración `app.faker_locale` en su fichero de configuración `config/app.php`; sin embargo, también puede especificar la configuración regional pasándola a la función `fake`. Cada configuración regional resolverá un singleton individual:

    fake('nl_NL')->name()

<a name="method-filled"></a>
#### `filled()` {.collection-method}

La función `filled` determina si el valor dado no es "blank":

    filled(0);
    filled(true);
    filled(false);

    // true

    filled('');
    filled('   ');
    filled(null);
    filled(collect());

    // false

Para la inversa de `filled`, véase el método [`blank`](#method-blank).

<a name="method-info"></a>
#### `info()` {.collection-method}

La función `info` escribirá información en el [log](/docs/{{version}}/logging) de su aplicación:

    info('Some helpful information!');

También se puede pasar a la función un array de datos contextuales:

    info('User login attempt failed.', ['id' => $user->id]);

<a name="method-logger"></a>
#### `logger()` {.collection-method}

La función `logger` puede utilizarse para escribir un mensaje de nivel de `depuración` en el [log](/docs/{{version}}/logging):

    logger('Debug message');

También se puede pasar a la función un array de datos contextuales:

    logger('User has logged in.', ['id' => $user->id]);

Se devolverá una instancia de [logger](/docs/{{version}}/errors#logging) si no se pasa ningún valor a la función:

    logger()->error('You are not allowed here.');

<a name="method-method-field"></a>
#### `method_field()` {.collection-method}

La función `method_field` genera un campo de entrada `hidden` HTML que contiene el valor "para burlar" verbo HTTP del formulario. Por ejemplo, utilizando [la sintaxis de Blade](/docs/{{version}}/blade):

    <form method="POST">
        {{ method_field('DELETE') }}
    </form>

<a name="method-now"></a>
#### `now()` {.collection-method}

La función `now` crea una nueva instancia `Illuminate\Support\Carbon` para la hora actual:

    $now = now();

<a name="method-old"></a>
#### `old()` {.collection-method}

La función `old` [recupera](/docs/{{version}}/requests#retrieving-input) un valor de [entrada antiguo](/docs/{{version}}/requests#old-input) introducido en la sesión:

    $value = old('value');

    $value = old('value', 'default');

Dado que el "valor por defecto" proporcionado como segundo argumento a la función `old` es a menudo un atributo de un modelo Eloquent, Laravel le permite simplemente pasar todo el modelo Eloquent como segundo argumento a la función `old`. Al hacerlo, Laravel asumirá que el primer argumento proporcionado a la función `old` es el nombre del atributo de Eloquent que debe considerarse el "valor por defecto":

    {{ old('name', $user->name) }}

    // Is equivalent to...

    {{ old('name', $user) }}

<a name="method-optional"></a>
#### `optional()` {.collection-method}

La función `optional` acepta cualquier argumento y permite acceder a propiedades o llamar a métodos de ese objeto. Si el objeto dado es `null`, las propiedades y métodos devolverán `null` en lugar de provocar un error:

    return optional($user->address)->street;

    {!! old('name', optional($user)->name) !!}

La función `opcional` también acepta un closure como segundo argumento. El closure se invocará si el valor proporcionado como primer argumento no es nulo:

    return optional(User::find($id), function ($user) {
        return $user->name;
    });

<a name="method-policy"></a>
#### `policy()` {.collection-method}

El método `policy` recupera una instancia de [policy](/docs/{{version}}/authorization#creating-policies) para una clase dada:

    $policy = policy(App\Models\User::class);

<a name="method-redirect"></a>
#### `redirect()` {.collection-method}

La función `redirect` devuelve una [respuesta HTTP de redirección](/docs/{{version}}/responses#redirects), o devuelve la instancia del redirector si se llama sin argumentos:

    return redirect($to = null, $status = 302, $headers = [], $https = null);

    return redirect('/home');

    return redirect()->route('route.name');

<a name="method-report"></a>
#### `report()` {.collection-method}

La función `report` informará de una excepción utilizando su [gestor de excepciones](/docs/{{version}}/errors#the-exception-handler):

    report($e);

La función `report` también acepta una cadena como argumento. Cuando se da una cadena a la función, ésta creará una excepción con la cadena dada como mensaje:

    report('Something went wrong.');

<a name="method-report-if"></a>
#### `report_if()` {.collection-method}

La función `report_if` informará de una excepción utilizando su [gestor de excepciones](/docs/{{version}}/errors#the-exception-handler) si la condición dada es `true`:

    report_if($shouldReport, $e);

    report_if($shouldReport, 'Something went wrong.');

<a name="method-report-unless"></a>
#### `report_unless()` {.collection-method}

La función `report_unless` informará de una excepción utilizando su [gestor de excepciones](/docs/{{version}}/errors#the-exception-handler) si la condición dada es `false`:

    report_unless($reportingDisabled, $e);

    report_unless($reportingDisabled, 'Something went wrong.');

<a name="method-request"></a>
#### `request()` {.collection-method}

La función `request` devuelve la instancia de [request](/docs/{{version}}/requests) actual u obtiene el valor de un campo de entrada de la petición actual:

    $request = request();

    $value = request('key', $default);

<a name="method-rescue"></a>
#### `rescue()` {.collection-method}

La función `rescue` ejecuta el closure dado y captura cualquier excepción que ocurra durante su ejecución. Todas las excepciones capturadas serán enviadas a su [gestor de excepciones](/docs/{{version}}/errors#the-exception-handler); sin embargo, la petición continuará procesándose:

    return rescue(function () {
        return $this->method();
    });

También puede pasar un segundo argumento a la función de `rescue`. Este argumento será el valor "por defecto" que se devolverá si se produce una excepción durante la ejecución del closure:

    return rescue(function () {
        return $this->method();
    }, false);

    return rescue(function () {
        return $this->method();
    }, function () {
        return $this->failure();
    });

<a name="method-resolve"></a>
#### `resolve()` {.collection-method}

La función `resolve` resuelve un nombre de clase o interfaz dado a una instancia utilizando el [contenedor de servicios](/docs/{{version}}/container):

    $api = resolve('HelpSpot\API');

<a name="method-response"></a>
#### `response()` {.collection-method}

La función `response` crea una instancia de [response](/docs/{{version}}/responses) u obtiene una instancia de la fábrica de respuestas:

    return response('Hello World', 200, $headers);

    return response()->json(['foo' => 'bar'], 200, $headers);

<a name="method-retry"></a>
#### `retry()` {.collection-method}

La función `retry` intenta ejecutar la llamada de retorno dada hasta que se alcanza el umbral máximo de intentos dado. Si la llamada de retorno no lanza una excepción, se devolverá su valor. Si la llamada de retorno lanza una excepción, se reintentará automáticamente. Si se supera el número máximo de intentos, se lanzará la excepción:

    return retry(5, function () {
        // Attempt 5 times while resting 100ms between attempts...
    }, 100);

Si desea calcular manualmente el número de milisegundos que deben transcurrir entre los intentos, puede pasar un closure como tercer argumento a la función de `retry`:

    return retry(5, function () {
        // ...
    }, function ($attempt, $exception) {
        return $attempt * 100;
    });

Para mayor comodidad, puede proporcionar un array como primer argumento de la función `retry`. Esta array se utilizará para determinar cuántos milisegundos deben transcurrir entre los siguientes intentos:

    return retry([100, 200], function () {
        // Sleep for 100ms on first retry, 200ms on second retry...
    });

Para reintentar sólo bajo condiciones específicas, puedes pasar un closure como cuarto argumento a la función `retry`:

    return retry(5, function () {
        // ...
    }, 100, function ($exception) {
        return $exception instanceof RetryException;
    });

<a name="method-session"></a>
#### `session()` {.collection-method}

La función `session` puede utilizarse para obtener o establecer valores de [session](/docs/{{version}}/session):

    $value = session('key');

Puede establecer valores pasando un array de pares clave / valor a la función:

    session(['chairs' => 7, 'instruments' => 3]);

El almacén de sesiones se devolverá si no se pasa ningún valor a la función:

    $value = session()->get('key');

    session()->put('key', $value);

<a name="method-tap"></a>
#### `tap()` {.collection-method}

La función `tap` acepta dos argumentos: un `$valor` arbitrario y un closure. El `$valor` será pasado al closure y luego devuelto por la función `tap`. El valor de retorno del closure es irrelevante:

    $user = tap(User::first(), function ($user) {
        $user->name = 'taylor';

        $user->save();
    });

Si no se pasa ningún closure a la función `tap`, puede llamar a cualquier método con el `$valor` dado. El valor de retorno del método al que llame siempre será `$valor`, independientemente de lo que el método devuelva realmente en su definición. Por ejemplo, el método `update` de Eloquent normalmente devuelve un entero. Sin embargo, podemos forzar que el método devuelva el propio modelo encadenando la llamada al método `update` a través de la función `tap`:

    $user = tap($user)->update([
        'name' => $name,
        'email' => $email,
    ]);

Para añadir un método `tap` a una clase, puede añadir el trait `Illuminate\Support\Traits\Tappable` a la clase. El método `tap` de este trait acepta un closure como único argumento. La propia instancia del objeto se pasará al closure y luego será devuelta por el método `tap`:

    return $user->tap(function ($user) {
        //
    });

<a name="method-throw-if"></a>
#### `throw_if()` {.collection-method}

La función `throw_if` lanza la excepción dada si una expresión booleana dada se evalúa como `true`:

    throw_if(! Auth::user()->isAdmin(), AuthorizationException::class);

    throw_if(
        ! Auth::user()->isAdmin(),
        AuthorizationException::class,
        'You are not allowed to access this page.'
    );

<a name="method-throw-unless"></a>
#### `throw_unless()` {.collection-method}

La función `throw_unless` lanza la excepción dada si una expresión booleana dada es `false`:

    throw_unless(Auth::user()->isAdmin(), AuthorizationException::class);

    throw_unless(
        Auth::user()->isAdmin(),
        AuthorizationException::class,
        'You are not allowed to access this page.'
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

La función `transform` ejecuta un closure sobre un valor dado si el valor no es [blank](#method-blank) y luego devuelve el valor de retorno del closure:

    $callback = function ($value) {
        return $value * 2;
    };

    $result = transform(5, $callback);

    // 10

Se puede pasar un valor por defecto o un closure como tercer argumento de la función. Este valor se devolverá si el valor dado está vacío:

    $result = transform(null, $callback, 'The value is blank');

    // The value is blank

<a name="method-validator"></a>
#### `validator()` {.collection-method}

La función `validator` crea una nueva instancia de [validator](/docs/{{version}}/validation) con los argumentos dados. Se puede utilizar como alternativa a la facade `Validator`:

    $validator = validator($data, $rules, $messages);

<a name="method-value"></a>
#### `value()` {.collection-method}

La función `value` devuelve el valor que se le da. Sin embargo, si se pasa un closure a la función, el closure se ejecutará y se devolverá su valor:

    $result = value(true);

    // true

    $result = value(function () {
        return false;
    });

    // false

<a name="method-view"></a>
#### `view()` {.collection-method}

La función `view` recupera una instancia de [view](/docs/{{version}}/views):

    return view('auth.login');

<a name="method-with"></a>
#### `with()` {.collection-method}

La función `with` devuelve el valor que se le pasa. Si se pasa un closure como segundo argumento a la función, se ejecutará el closure y se devolverá su valor:

    $callback = function ($value) {
        return is_numeric($value) ? $value * 2 : 0;
    };

    $result = with(5, $callback);

    // 10

    $result = with(null, $callback);

    // 0

    $result = with(5, null);

    // 5

<a name="other-utilities"></a>
## Otras utilidades

<a name="benchmarking"></a>
### Benchmarking

A veces es posible que desee probar rápidamente el rendimiento de ciertas partes de su aplicación. En esas ocasiones, puedes utilizar la clase de soporte `Benchmark` para medir el número de milisegundos que tardan en completarse las llamadas de retorno dadas:

    <?php

    use App\Models\User;
    use Illuminate\Support\Benchmark;

    Benchmark::dd(fn () => User::find(1)); // 0.1 ms

    Benchmark::dd([
        'Scenario 1' => fn () => User::count(), // 0.5 ms
        'Scenario 2' => fn () => User::all()->count(), // 20.0 ms
    ]);

Por defecto, los callbacks dados se ejecutarán una vez (una iteración), y su duración se mostrará en el navegador / consola.

Para invocar una llamada de retorno más de una vez, puede especificar el número de iteraciones que la llamada de retorno debe ser invocada como segundo argumento del método. Cuando se ejecuta un callback más de una vez, la clase `Benchmark` devolverá la cantidad media de milisegundos que se tardó en ejecutar el callback en todas las iteraciones:

    Benchmark::dd(fn () => User::count(), iterations: 10); // 0.5 ms

<a name="lottery"></a>
### Lottery

La clase Lottery de Laravel puede utilizarse para ejecutar callbacks basados en un conjunto de probabilidades dadas. Esto puede ser particularmente útil cuando sólo se desea ejecutar código para un porcentaje de las peticiones entrantes:

    use Illuminate\Support\Lottery;

    Lottery::odds(1, 20)
        ->winner(fn () => $user->won())
        ->loser(fn () => $user->lost())
        ->choose();

Puede combinar la clase Lottery de Laravel con otras características de Laravel. Por ejemplo, es posible que sólo desee informar de un pequeño porcentaje de consultas lentas a su gestor de excepciones. Y, puesto que la clase Lottery es invocable, podemos pasar una instancia de la clase a cualquier método que acepte invocables:

    use Carbon\CarbonInterval;
    use Illuminate\Support\Facades\DB;
    use Illuminate\Support\Lottery;

    DB::whenQueryingForLongerThan(
        CarbonInterval::seconds(2),
        Lottery::odds(1, 100)->winner(fn () => report('Querying > 2 seconds.')),
    );

<a name="testing-lotteries"></a>
#### Testing Lottery

Laravel proporciona algunos métodos simples que te permiten probar fácilmente las invocaciones de lotería de tu aplicación:

    // Lottery will always win...
    Lottery::alwaysWin();

    // Lottery will always lose...
    Lottery::alwaysLose();

    // Lottery will win then lose, and finally return to normal behavior...
    Lottery::fix([true, false]);

    // Lottery will return to normal behavior...
    Lottery::determineResultsNormally();
