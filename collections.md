# Colecciones

- [Introducción](#introduction)
  - [Creación de colecciones](#creating-collections)
  - [Extender colecciones](#extending-collections)
- [Métodos disponibles](#available-methods)
- [Mensajes de Orden Superior](#higher-order-messages)
- [Colecciones lazy](#lazy-collections)
  - [Introducción](#lazy-collection-introduction)
  - [Creación de colecciones lazy](#creating-lazy-collections)
  - [La Interfaz Enumerable](#the-enumerable-contract)
  - [Métodos de colección lazy](#lazy-collection-methods)

<a name="introduction"></a>
## Introducción

La clase `Illuminate\Support\Collection` proporciona una envoltura fluida para trabajar con arrays de datos. Por ejemplo, echa un vistazo al siguiente código. Utilizaremos el ayudante `collect` para crear una nueva instancia de la colección a partir de la array, ejecutar la función `strtoupper` en cada elemento y, a continuación, eliminar todos los elementos vacíos:

    $collection = collect(['taylor', 'abigail', null])->map(function ($name) {
        return strtoupper($name);
    })->reject(function ($name) {
        return empty($name);
    });

Como puedes ver, la clase `Collection` te permite encadenar sus métodos para realizar mapeos y reducciones fluidas del array subyacente. En general, las colecciones son inmutables, lo que significa que cada método `Collection` devuelve una instancia `Collection` completamente nueva.

<a name="creating-collections"></a>
### Creación de colecciones

Como se mencionó anteriormente, la función de ayuda `collect` devuelve una nueva instancia `Illuminate\Support\Collection` para el array dado. Por lo tanto, la creación de una colección es tan simple como:

    $collection = collect([1, 2, 3]);

> **Nota**  
> Los resultados de las consultas de [Eloquent](/docs/{{version}}/eloquent) siempre se devuelven como instancias de `Collection`.

<a name="extending-collections"></a>
### Extender colecciones

Las colecciones son "macroables", lo que permite añadir métodos adicionales a la clase `Collection` en tiempo de ejecución. El método `macro` de la clase `Illuminate\Support\Collection` acepta un closure que se ejecutará cuando se llame a su macro. El closure de la macro puede acceder a otros métodos de la colección a través de `$this`, como si fuera un método real de la clase collection. Por ejemplo, el siguiente código añade un método `toUpper` a la clase `Collection`:

    use Illuminate\Support\Collection;
    use Illuminate\Support\Str;

    Collection::macro('toUpper', function () {
        return $this->map(function ($value) {
            return Str::upper($value);
        });
    });

    $collection = collect(['first', 'second']);

    $upper = $collection->toUpper();

    // ['FIRST', 'SECOND']

Normalmente, los macros de colección se declaran en el método de `boot` del [proveedor de servicios](/docs/{{version}}/providers).

<a name="macro-arguments"></a>
#### Argumentos de las macros

Si es necesario, puede definir macros que acepten argumentos adicionales:

    use Illuminate\Support\Collection;
    use Illuminate\Support\Facades\Lang;

    Collection::macro('toLocale', function ($locale) {
        return $this->map(function ($value) use ($locale) {
            return Lang::get($value, [], $locale);
        });
    });

    $collection = collect(['first', 'second']);

    $translated = $collection->toLocale('es');

<a name="available-methods"></a>
## Métodos disponibles

Durante la mayor parte de la documentación restante sobre colecciones, hablaremos sobre cada método disponible en la clase `Collection`. Recuerde que todos estos métodos pueden encadenarse para manipular con fluidez el array subyacente. Además, casi todos los métodos devuelven una nueva instancia de `Collection`, lo que permite conservar la copia original de la colección:

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

<div class="collection-method-list" markdown="1">

[all](#method-all)
[average](#method-average)
[avg](#method-avg)
[chunk](#method-chunk)
[chunkWhile](#method-chunkwhile)
[collapse](#method-collapse)
[collect](#method-collect)
[combine](#method-combine)
[concat](#method-concat)
[contains](#method-contains)
[containsOneItem](#method-containsoneitem)
[containsStrict](#method-containsstrict)
[count](#method-count)
[countBy](#method-countBy)
[crossJoin](#method-crossjoin)
[dd](#method-dd)
[diff](#method-diff)
[diffAssoc](#method-diffassoc)
[diffKeys](#method-diffkeys)
[doesntContain](#method-doesntcontain)
[dump](#method-dump)
[duplicates](#method-duplicates)
[duplicatesStrict](#method-duplicatesstrict)
[each](#method-each)
[eachSpread](#method-eachspread)
[every](#method-every)
[except](#method-except)
[filter](#method-filter)
[first](#method-first)
[firstOrFail](#method-first-or-fail)
[firstWhere](#method-first-where)
[flatMap](#method-flatmap)
[flatten](#method-flatten)
[flip](#method-flip)
[forget](#method-forget)
[forPage](#method-forpage)
[get](#method-get)
[groupBy](#method-groupby)
[has](#method-has)
[hasAny](#method-hasany)
[implode](#method-implode)
[intersect](#method-intersect)
[intersectByKeys](#method-intersectbykeys)
[isEmpty](#method-isempty)
[isNotEmpty](#method-isnotempty)
[join](#method-join)
[keyBy](#method-keyby)
[keys](#method-keys)
[last](#method-last)
[lazy](#method-lazy)
[macro](#method-macro)
[make](#method-make)
[map](#method-map)
[mapInto](#method-mapinto)
[mapSpread](#method-mapspread)
[mapToGroups](#method-maptogroups)
[mapWithKeys](#method-mapwithkeys)
[max](#method-max)
[median](#method-median)
[merge](#method-merge)
[mergeRecursive](#method-mergerecursive)
[min](#method-min)
[mode](#method-mode)
[nth](#method-nth)
[only](#method-only)
[pad](#method-pad)
[partition](#method-partition)
[pipe](#method-pipe)
[pipeInto](#method-pipeinto)
[pipeThrough](#method-pipethrough)
[pluck](#method-pluck)
[pop](#method-pop)
[prepend](#method-prepend)
[pull](#method-pull)
[push](#method-push)
[put](#method-put)
[random](#method-random)
[range](#method-range)
[reduce](#method-reduce)
[reduceSpread](#method-reduce-spread)
[reject](#method-reject)
[replace](#method-replace)
[replaceRecursive](#method-replacerecursive)
[reverse](#method-reverse)
[search](#method-search)
[shift](#method-shift)
[shuffle](#method-shuffle)
[skip](#method-skip)
[skipUntil](#method-skipuntil)
[skipWhile](#method-skipwhile)
[slice](#method-slice)
[sliding](#method-sliding)
[sole](#method-sole)
[some](#method-some)
[sort](#method-sort)
[sortBy](#method-sortby)
[sortByDesc](#method-sortbydesc)
[sortDesc](#method-sortdesc)
[sortKeys](#method-sortkeys)
[sortKeysDesc](#method-sortkeysdesc)
[sortKeysUsing](#method-sortkeysusing)
[splice](#method-splice)
[split](#method-split)
[splitIn](#method-splitin)
[sum](#method-sum)
[take](#method-take)
[takeUntil](#method-takeuntil)
[takeWhile](#method-takewhile)
[tap](#method-tap)
[times](#method-times)
[toArray](#method-toarray)
[toJson](#method-tojson)
[transform](#method-transform)
[undot](#method-undot)
[union](#method-union)
[unique](#method-unique)
[uniqueStrict](#method-uniquestrict)
[unless](#method-unless)
[unlessEmpty](#method-unlessempty)
[unlessNotEmpty](#method-unlessnotempty)
[unwrap](#method-unwrap)
[value](#method-value)
[values](#method-values)
[when](#method-when)
[whenEmpty](#method-whenempty)
[whenNotEmpty](#method-whennotempty)
[where](#method-where)
[whereStrict](#method-wherestrict)
[whereBetween](#method-wherebetween)
[whereIn](#method-wherein)
[whereInStrict](#method-whereinstrict)
[whereInstanceOf](#method-whereinstanceof)
[whereNotBetween](#method-wherenotbetween)
[whereNotIn](#method-wherenotin)
[whereNotInStrict](#method-wherenotinstrict)
[whereNotNull](#method-wherenotnull)
[whereNull](#method-wherenull)
[wrap](#method-wrap)
[zip](#method-zip)

</div>

<a name="method-listing"></a>
## Listado de métodos

<style>
    .collection-method code {
        font-size: 14px;
    }

    .collection-method:not(.first-collection-method) {
        margin-top: 50px;
    }
</style>

<a name="method-all"></a>
#### `all()` {.collection-method .first-collection-method}

El método `all` devuelve el array subyacente representado por la colección:

    collect([1, 2, 3])->all();

    // [1, 2, 3]

<a name="method-average"></a>
#### `average()` {.collection-method}

Alias para el método [`avg`](#method-avg).

<a name="method-avg"></a>
#### `avg()` {.collection-method}

El método `avg` devuelve el [valor medio](https://en.wikipedia.org/wiki/Average) de una clave dada:

    $average = collect([
        ['foo' => 10],
        ['foo' => 10],
        ['foo' => 20],
        ['foo' => 40]
    ])->avg('foo');

    // 20

    $average = collect([1, 1, 2, 4])->avg();

    // 2

<a name="method-chunk"></a>
#### `chunk()` {.collection-method}

El método `chunk` divide la colección en varias colecciones más pequeñas de un tamaño determinado:

    $collection = collect([1, 2, 3, 4, 5, 6, 7]);

    $chunks = $collection->chunk(4);

    $chunks->all();

    // [[1, 2, 3, 4], [5, 6, 7]]

Este método es especialmente útil en [vistas](/docs/{{version}}/views) cuando se trabaja con un sistema de rejilla como [Bootstrap](https://getbootstrap.com/docs/4.1/layout/grid/). Por ejemplo, imagina que tienes una colección de modelos [Eloquent](/docs/{{version}}/eloquent) que quieres mostrar en una rejilla:

```blade
@foreach ($products->chunk(3) as $chunk)
    <div class="row">
        @foreach ($chunk as $product)
            <div class="col-xs-4">{{ $product->name }}</div>
        @endforeach
    </div>
@endforeach
```

<a name="method-chunkwhile"></a>
#### `chunkWhile()` {.collection-method}

El método `chunkWhile` divide la colección en múltiples colecciones más pequeñas basándose en la evaluación de un callback dado. La variable `$chunk` pasada al closure puede utilizarse para inspeccionar el elemento anterior:

    $collection = collect(str_split('AABBCCCD'));

    $chunks = $collection->chunkWhile(function ($value, $key, $chunk) {
        return $value === $chunk->last();
    });

    $chunks->all();

    // [['A', 'A'], ['B', 'B'], ['C', 'C', 'C'], ['D']]

<a name="method-collapse"></a>
#### `collapse()` {.collection-method}

El método `collapse` colapsa una colección de arrays en una única colección plana:

    $collection = collect([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
    ]);

    $collapsed = $collection->collapse();

    $collapsed->all();

    // [1, 2, 3, 4, 5, 6, 7, 8, 9]

<a name="method-collect"></a>
#### `collect()` {.collection-method}

El método `collect` devuelve una nueva instancia de `Collection` con los elementos que contiene:

    $collectionA = collect([1, 2, 3]);

    $collectionB = $collectionA->collect();

    $collectionB->all();

    // [1, 2, 3]

El método `collect` es útil principalmente para convertir [colecciones lazy](#lazy-collections) en instancias estándar de `Collection`:

    $lazyCollection = LazyCollection::make(function () {
        yield 1;
        yield 2;
        yield 3;
    });

    $collection = $lazyCollection->collect();

    get_class($collection);

    // 'Illuminate\Support\Collection'

    $collection->all();

    // [1, 2, 3]

> **Nota**  
> El método `collect` es especialmente útil cuando se tiene una instancia de `Enumerable` y se necesita una instancia de colección (no lazy). Dado que `collect()` forma parte del contrato de `Enumerable`, puedes utilizarlo de forma segura para obtener una instancia de `Collection`.

<a name="method-combine"></a>
#### `combine()` {.collection-method}

El método `combine` combina los valores de la colección, como claves, con los valores de otro array o colección:

    $collection = collect(['name', 'age']);

    $combined = $collection->combine(['George', 29]);

    $combined->all();

    // ['name' => 'George', 'age' => 29]

<a name="method-concat"></a>
#### `concat()` {.collection-method}

El método `concat` añade los valores del `array` o colección dada al final de otra colección:

    $collection = collect(['John Doe']);

    $concatenated = $collection->concat(['Jane Doe'])->concat(['name' => 'Johnny Doe']);

    $concatenated->all();

    // ['John Doe', 'Jane Doe', 'Johnny Doe']

El método `concat` reindexa numéricamente las claves de los elementos concatenados en la colección original. Para mantener las claves en colecciones asociativas, consulte el método [merge](#method-merge).

<a name="method-contains"></a>
#### `contains()` {.collection-method}

El método `contains` determina si la colección contiene un elemento dado. Puede pasar un closure al método `contains` para determinar si existe un elemento en la colección que coincida con una test verdad dada:

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->contains(function ($value, $key) {
        return $value > 5;
    });

    // false

De manera alternativa, puede pasar una cadena al método `contains` para determinar si la colección contiene un valor de elemento dado:

    $collection = collect(['name' => 'Desk', 'price' => 100]);

    $collection->contains('Desk');

    // true

    $collection->contains('New York');

    // false

También puede pasar un par clave/valor al método `contains`, que determinará si el par dado existe en la colección:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
    ]);

    $collection->contains('product', 'Bookcase');

    // false

El método `contains` utiliza comparaciones "flexibles" (loose) para comprobar los valores de los elementos, lo que significa que una cadena con un valor entero se considerará igual a un entero del mismo valor. Utilice el método [`containsStrict`](#method-containsstrict) para filtrar utilizando comparaciones "estrictas".

Para la inversa de `contains`, consulte el método [doesntContain](#method-doesntcontain).

<a name="method-containsoneitem"></a>
#### `containsOneItem()` {.collection-method}

El método `containsOneItem` determina si la colección contiene un único elemento:

    collect([])->containsOneItem();

    // false

    collect(['1'])->containsOneItem();

    // true

    collect(['1', '2'])->containsOneItem();

    // false

<a name="method-containsstrict"></a>
#### `containsStrict()` {.collection-method}

Este método tiene la misma firma que el método [`contains`](#method-contains); sin embargo, todos los valores se comparan utilizando comparaciones "estrictas".

> **Nota**  
> El comportamiento de este método se modifica al utilizar [Colecciones Eloquent](/docs/{{version}}/eloquent-collections#method-contains).

<a name="method-count"></a>
#### `count()` {.collection-method}

El método `count` devuelve el número total de elementos de la colección:

    $collection = collect([1, 2, 3, 4]);

    $collection->count();

    // 4

<a name="method-countBy"></a>
#### `countBy()` {.collection-method}

El método `countBy` cuenta las apariciones de valores en la colección. Por defecto, el método cuenta las ocurrencias de cada elemento, permitiendo contar ciertos "tipos" de elementos en la colección:

    $collection = collect([1, 2, 2, 2, 3]);

    $counted = $collection->countBy();

    $counted->all();

    // [1 => 1, 2 => 3, 3 => 1]

Puede pasar un closure al método `countBy` para contar todos los elementos según un valor personalizado:

    $collection = collect(['alice@gmail.com', 'bob@yahoo.com', 'carlos@gmail.com']);

    $counted = $collection->countBy(function ($email) {
        return substr(strrchr($email, "@"), 1);
    });

    $counted->all();

    // ['gmail.com' => 2, 'yahoo.com' => 1]

<a name="method-crossjoin"></a>
#### `crossJoin()` {.collection-method}

El método `crossJoin` cruza los valores de la colección con los arrays o colecciones dados, devolviendo un producto cartesiano con todas las permutaciones posibles:

    $collection = collect([1, 2]);

    $matrix = $collection->crossJoin(['a', 'b']);

    $matrix->all();

    /*
        [
            [1, 'a'],
            [1, 'b'],
            [2, 'a'],
            [2, 'b'],
        ]
    */

    $collection = collect([1, 2]);

    $matrix = $collection->crossJoin(['a', 'b'], ['I', 'II']);

    $matrix->all();

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

<a name="method-dd"></a>
#### `dd()` {.collection-method}

El método `dd` vuelca los elementos de la colección y finaliza la ejecución del script:

    $collection = collect(['John Doe', 'Jane Doe']);

    $collection->dd();

    /*
        Collection {
            #items: array:2 [
                0 => "John Doe"
                1 => "Jane Doe"
            ]
        }
    */

Si no desea detener la ejecución del script, utilice en su lugar el método [`dump`](#method-dump).

<a name="method-diff"></a>
#### `diff()` {.collection-method}

El método `diff` compara la colección contra otra colección o un `array` PHP basado en sus valores. Este método devolverá los valores de la colección original que no estén presentes en la colección dada:

    $collection = collect([1, 2, 3, 4, 5]);

    $diff = $collection->diff([2, 4, 6, 8]);

    $diff->all();

    // [1, 3, 5]

> **Nota**  
> El comportamiento de este método se modifica al utilizar [Colecciones Eloquent](/docs/{{version}}/eloquent-collections#method-diff).

<a name="method-diffassoc"></a>
#### `diffAssoc()` {.collection-method}

El método `diffAssoc` compara la colección contra otra colección o un `array` PHP basado en sus claves y valores. Este método devolverá los pares clave / valor de la colección original que no están presentes en la colección dada:

    $collection = collect([
        'color' => 'orange',
        'type' => 'fruit',
        'remain' => 6,
    ]);

    $diff = $collection->diffAssoc([
        'color' => 'yellow',
        'type' => 'fruit',
        'remain' => 3,
        'used' => 6,
    ]);

    $diff->all();

    // ['color' => 'orange', 'remain' => 6]

<a name="method-diffkeys"></a>
#### `diffKeys()` {.collection-method}

El método `diffKeys` compara la colección contra otra colección o un `array` PHP basado en sus claves. Este método devolverá los pares clave / valor de la colección original que no estén presentes en la colección dada:

    $collection = collect([
        'one' => 10,
        'two' => 20,
        'three' => 30,
        'four' => 40,
        'five' => 50,
    ]);

    $diff = $collection->diffKeys([
        'two' => 2,
        'four' => 4,
        'six' => 6,
        'eight' => 8,
    ]);

    $diff->all();

    // ['one' => 10, 'three' => 30, 'five' => 50]

<a name="method-doesntcontain"></a>
#### `doesntContain()` {.collection-method}

El método `doesntContain` determina si la colección no contiene un elemento dado. Puede pasar un closure al método `doesntContain` para determinar si un elemento que coincida con una condición dada no existe en la colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->doesntContain(function ($value, $key) {
        return $value < 5;
    });

    // false

De manera alternativa, puede pasar una cadena al método `doesntContain` para determinar si la colección no contiene un valor de elemento dado:

    $collection = collect(['name' => 'Desk', 'price' => 100]);

    $collection->doesntContain('Table');

    // true

    $collection->doesntContain('Desk');

    // false

También puede pasar un par clave/valor al método `doesntContain`, que determinará si el par dado no existe en la colección:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
    ]);

    $collection->doesntContain('product', 'Bookcase');

    // true

El método `doesntContain` utiliza comparaciones "flexibles" (loose) al comprobar los valores de los elementos, lo que significa que una cadena con un valor entero se considerará igual a un entero del mismo valor.

<a name="method-dump"></a>
#### `dump()` {.collection-method}

El método `dump` vuelca los elementos de la colección:

    $collection = collect(['John Doe', 'Jane Doe']);

    $collection->dump();

    /*
        Collection {
            #items: array:2 [
                0 => "John Doe"
                1 => "Jane Doe"
            ]
        }
    */

Si desea detener la ejecución del script después de volcar la colección, utilice en su lugar el método [`dd`](#method-dd).

<a name="method-duplicates"></a>
#### `duplicates()` {.collection-method}

El método `duplicates` recupera y devuelve los valores duplicados de la colección:

    $collection = collect(['a', 'b', 'a', 'c', 'b']);

    $collection->duplicates();

    // [2 => 'a', 4 => 'b']

Si la colección contiene arrays u objetos, puede pasar la clave de los atributos que desea comprobar si tienen valores duplicados:

    $employees = collect([
        ['email' => 'abigail@example.com', 'position' => 'Developer'],
        ['email' => 'james@example.com', 'position' => 'Designer'],
        ['email' => 'victoria@example.com', 'position' => 'Developer'],
    ]);

    $employees->duplicates('position');

    // [2 => 'Developer']

<a name="method-duplicatesstrict"></a>
#### `duplicatesStrict()` {.collection-method}

Este método tiene la misma firma que el método [`duplicates`](#method-duplicates); sin embargo, todos los valores se comparan utilizando comparaciones "estrictas".

<a name="method-each"></a>
#### `each()` {.collection-method}

El método `each` itera sobre los elementos de la colección y pasa cada elemento a un closure:

    $collection->each(function ($item, $key) {
        //
    });

Si quieres dejar de iterar sobre los elementos, puedes devolver `false` desde tu closure:

    $collection->each(function ($item, $key) {
        if (/* condition */) {
            return false;
        }
    });

<a name="method-eachspread"></a>
#### `eachSpread()` {.collection-method}

El método `eachSpread` itera sobre los ítems de la colección, pasando el valor de cada ítem anidado al callback dado:

    $collection = collect([['John Doe', 35], ['Jane Doe', 33]]);

    $collection->eachSpread(function ($name, $age) {
        //
    });

Puede detener la iteración a través de los elementos devolviendo `false` desde el callback:

    $collection->eachSpread(function ($name, $age) {
        return false;
    });

<a name="method-every"></a>
#### `every()` {.collection-method}

El método `every` puede utilizarse para verificar que todos los elementos de una colección superan una condición determinada:

    collect([1, 2, 3, 4])->every(function ($value, $key) {
        return $value > 2;
    });

    // false

Si la colección está vacía, el método `every` devolverá true:

    $collection = collect([]);

    $collection->every(function ($value, $key) {
        return $value > 2;
    });

    // true

<a name="method-except"></a>
#### `except()` {.collection-method}

El método `except` devuelve todos los elementos de la colección excepto aquellos con las claves especificadas:

    $collection = collect(['product_id' => 1, 'price' => 100, 'discount' => false]);

    $filtered = $collection->except(['price', 'discount']);

    $filtered->all();

    // ['product_id' => 1]

Para la inversa de `except`, Laravel ofrece el método [only](#method-only).

> **Nota**  
> El comportamiento de este método se modifica cuando se utiliza [Colecciones Eloquent](/docs/{{version}}/eloquent-collections#method-except).

<a name="method-filter"></a>
#### `filter()` {.collection-method}

El método `filter` filtra la colección utilizando el callback proporcionado, manteniendo sólo aquellos elementos que pasan una condición determinada:

    $collection = collect([1, 2, 3, 4]);

    $filtered = $collection->filter(function ($value, $key) {
        return $value > 2;
    });

    $filtered->all();

    // [3, 4]

Si no se proporciona ningún callback, se eliminarán todas las entradas de la colección que sean equivalentes a `false`:

    $collection = collect([1, 2, 3, null, false, '', 0, []]);

    $collection->filter()->all();

    // [1, 2, 3]

Para la inversa de `filter`, véase el método [reject](#method-reject).

<a name="method-first"></a>
#### `first()` {.collection-method}

El método `first` devuelve el primer elemento de la colección que supera una condición dada:

    collect([1, 2, 3, 4])->first(function ($value, $key) {
        return $value > 2;
    });

    // 3

También puede llamar al método `first` sin argumentos para obtener el primer elemento de la colección. Si la colección está vacía, se devuelve `null`:

    collect([1, 2, 3, 4])->first();

    // 1

<a name="method-first-or-fail"></a>
#### `firstOrFail()` {.collection-method}

El método `firstOrFail` es idéntico al método `first`; sin embargo, si no se encuentra ningún resultado, se lanzará una excepción `Illuminate\Support\ItemNotFoundException`:

    collect([1, 2, 3, 4])->firstOrFail(function ($value, $key) {
        return $value > 5;
    });

    // Throws ItemNotFoundException...

También puede llamar al método `firstOrFail` sin argumentos para obtener el primer elemento de la colección. Si la colección está vacía, se lanzará una excepción `Illuminate\Support\ItemNotFoundException`:

    collect([])->firstOrFail();

    // Throws ItemNotFoundException...

<a name="method-first-where"></a>
#### `firstWhere()` {.collection-method}

El método `firstWhere` devuelve el primer elemento de la colección con el par clave / valor dado:

    $collection = collect([
        ['name' => 'Regena', 'age' => null],
        ['name' => 'Linda', 'age' => 14],
        ['name' => 'Diego', 'age' => 23],
        ['name' => 'Linda', 'age' => 84],
    ]);

    $collection->firstWhere('name', 'Linda');

    // ['name' => 'Linda', 'age' => 14]

También puede llamar al método `firstWhere` con un operador de comparación:

    $collection->firstWhere('age', '>=', 18);

    // ['name' => 'Diego', 'age' => 23]

Al igual que el método [where](#method-where), puede pasar un argumento al método `firstWhere`. En este caso, el método `firstWhere` devolverá el primer elemento cuyo valor de clave sea "verdadero":

    $collection->firstWhere('age');

    // ['name' => 'Linda', 'age' => 14]

<a name="method-flatmap"></a>
#### `flatMap()` {.collection-method}

El método `flatMap` aplana una colección multidimensional en una colección de una sola dimensión. Para ello recorre la colección y pasa cada valor al closure dado. El closure es libre de modificar el elemento y devolverlo, formando así una nueva colección de elementos modificados. Finalmente, el array es apanado en un nivel obteniendo una colección de una sola dimensión:

    $collection = collect([
        ['name' => 'Sally'],
        ['school' => 'Arkansas'],
        ['age' => 28]
    ]);

    $flattened = $collection->flatMap(function ($values) {
        return array_map('strtoupper', $values);
    });

    $flattened->all();

    // ['name' => 'SALLY', 'school' => 'ARKANSAS', 'age' => '28'];

<a name="method-flatten"></a>
#### `flatten()` {.collection-method}

El método `flatten` aplana una colección multidimensional en una colección de una sola dimensión:

    $collection = collect([
        'name' => 'taylor',
        'languages' => [
            'php', 'javascript'
        ]
    ]);

    $flattened = $collection->flatten();

    $flattened->all();

    // ['taylor', 'php', 'javascript'];

Si es necesario, puede pasar al método `flatten` un de argumento «profundidad»:

    $collection = collect([
        'Apple' => [
            [
                'name' => 'iPhone 6S',
                'brand' => 'Apple'
            ],
        ],
        'Samsung' => [
            [
                'name' => 'Galaxy S7',
                'brand' => 'Samsung'
            ],
        ],
    ]);

    $products = $collection->flatten(1);

    $products->values()->all();

    /*
        [
            ['name' => 'iPhone 6S', 'brand' => 'Apple'],
            ['name' => 'Galaxy S7', 'brand' => 'Samsung'],
        ]
    */

En este ejemplo, si se hubiera llamado a `flatten` sin indicar la profundidad, también se habrían aplanado los arrays anidadas, lo que habría dado como resultado `['iPhone 6S', 'Apple', 'Galaxy S7', 'Samsung']`. Proporcionar una profundidad permite especificar el número de niveles en que se aplanarán los arrays anidadas.

<a name="method-flip"></a>
#### `flip()` {.collection-method}

El método `flip` intercambia las claves de la colección con sus valores correspondientes:

    $collection = collect(['name' => 'taylor', 'framework' => 'laravel']);

    $flipped = $collection->flip();

    $flipped->all();

    // ['taylor' => 'name', 'laravel' => 'framework']

<a name="method-forget"></a>
#### `forget()` {.collection-method}

El método `forget` elimina un elemento de la colección especificado mediante clave:

    $collection = collect(['name' => 'taylor', 'framework' => 'laravel']);

    $collection->forget('name');

    $collection->all();

    // ['framework' => 'laravel']

> **Aviso**  
> A diferencia de la mayoría de métodos de colección, `forget` no devuelve una nueva colección modificada, sino que modifica la colección sobre la que se llama.

<a name="method-forpage"></a>
#### `forPage()` {.collection-method}

El método `forPage` devuelve una nueva colección que contiene los elementos que estarían presentes en un número de página dado. El método acepta el número de página como primer argumento y el número de elementos a mostrar por página como segundo argumento:

    $collection = collect([1, 2, 3, 4, 5, 6, 7, 8, 9]);

    $chunk = $collection->forPage(2, 3);

    $chunk->all();

    // [4, 5, 6]

<a name="method-get"></a>
#### `get()` {.collection-method}

El método `get` devuelve el elemento en una clave dada. Si la clave no existe, devuelve `null`:

    $collection = collect(['name' => 'taylor', 'framework' => 'laravel']);

    $value = $collection->get('name');

    // taylor

Opcionalmente, puede pasar un valor por defecto como segundo argumento:

    $collection = collect(['name' => 'taylor', 'framework' => 'laravel']);

    $value = $collection->get('age', 34);

    // 34

Incluso puede pasar un callback como valor por defecto del método. Si la clave especificada no existe, se devolverá el resultado de el callback:

    $collection->get('email', function () {
        return 'taylor@example.com';
    });

    // taylor@example.com

<a name="method-groupby"></a>
#### `groupBy()` {.collection-method}

El método `groupBy` agrupa los elementos de la colección por una clave dada:

    $collection = collect([
        ['account_id' => 'account-x10', 'product' => 'Chair'],
        ['account_id' => 'account-x10', 'product' => 'Bookcase'],
        ['account_id' => 'account-x11', 'product' => 'Desk'],
    ]);

    $grouped = $collection->groupBy('account_id');

    $grouped->all();

    /*
        [
            'account-x10' => [
                ['account_id' => 'account-x10', 'product' => 'Chair'],
                ['account_id' => 'account-x10', 'product' => 'Bookcase'],
            ],
            'account-x11' => [
                ['account_id' => 'account-x11', 'product' => 'Desk'],
            ],
        ]
    */

En lugar de pasar una cadena `clave`, puede pasar un callback. El callback debe devolver el valor por el que se desea clasificar el grupo:

    $grouped = $collection->groupBy(function ($item, $key) {
        return substr($item['account_id'], -3);
    });

    $grouped->all();

    /*
        [
            'x10' => [
                ['account_id' => 'account-x10', 'product' => 'Chair'],
                ['account_id' => 'account-x10', 'product' => 'Bookcase'],
            ],
            'x11' => [
                ['account_id' => 'account-x11', 'product' => 'Desk'],
            ],
        ]
    */

Se pueden pasar varios criterios de agrupación como una array. Cada elemento del array se aplicará al nivel correspondiente dentro de un array multidimensional:

    $data = new Collection([
        10 => ['user' => 1, 'skill' => 1, 'roles' => ['Role_1', 'Role_3']],
        20 => ['user' => 2, 'skill' => 1, 'roles' => ['Role_1', 'Role_2']],
        30 => ['user' => 3, 'skill' => 2, 'roles' => ['Role_1']],
        40 => ['user' => 4, 'skill' => 2, 'roles' => ['Role_2']],
    ]);

    $result = $data->groupBy(['skill', function ($item) {
        return $item['roles'];
    }], preserveKeys: true);

    /*
    [
        1 => [
            'Role_1' => [
                10 => ['user' => 1, 'skill' => 1, 'roles' => ['Role_1', 'Role_3']],
                20 => ['user' => 2, 'skill' => 1, 'roles' => ['Role_1', 'Role_2']],
            ],
            'Role_2' => [
                20 => ['user' => 2, 'skill' => 1, 'roles' => ['Role_1', 'Role_2']],
            ],
            'Role_3' => [
                10 => ['user' => 1, 'skill' => 1, 'roles' => ['Role_1', 'Role_3']],
            ],
        ],
        2 => [
            'Role_1' => [
                30 => ['user' => 3, 'skill' => 2, 'roles' => ['Role_1']],
            ],
            'Role_2' => [
                40 => ['user' => 4, 'skill' => 2, 'roles' => ['Role_2']],
            ],
        ],
    ];
    */

<a name="method-has"></a>
#### `has()` {.collection-method}

El método `has` determina si una clave dada existe en la colección:

    $collection = collect(['account_id' => 1, 'product' => 'Desk', 'amount' => 5]);

    $collection->has('product');

    // true

    $collection->has(['product', 'amount']);

    // true

    $collection->has(['amount', 'price']);

    // false

<a name="method-hasany"></a>
#### `hasAny()` {.collection-method}

El método `hasAny` determina si alguna de las claves dadas existe en la colección:

    $collection = collect(['account_id' => 1, 'product' => 'Desk', 'amount' => 5]);

    $collection->hasAny(['product', 'price']);

    // true

    $collection->hasAny(['name', 'price']);

    // false

<a name="method-implode"></a>
#### `implode()` {.collection-method}

El método `implode` une los elementos de una colección. Sus argumentos dependen del tipo de elementos de la colección. Si la colección contiene arrays u objetos, debe pasar la clave de los atributos que desea unir y la cadena de "union" que desea colocar entre los valores:

    $collection = collect([
        ['account_id' => 1, 'product' => 'Desk'],
        ['account_id' => 2, 'product' => 'Chair'],
    ]);

    $collection->implode('product', ', ');

    // Desk, Chair

Si la colección contiene cadenas simples o valores numéricos, deberá pasar la cadena de "union" como único argumento del método:

    collect([1, 2, 3, 4, 5])->implode('-');

    // '1-2-3-4-5'

Puede pasar un closure al método `implode` si desea dar formato a los valores que se implosionan:

    $collection->implode(function ($item, $key) {
        return strtoupper($item['product']);
    }, ', ');

    // DESK, CHAIR

<a name="method-intersect"></a>
#### `intersect()` {.collection-method}

El método `intersect` elimina cualquier valor de la colección original que no esté presente en el `array` o colección dada. La colección resultante conservará las claves de la colección original:

    $collection = collect(['Desk', 'Sofa', 'Chair']);

    $intersect = $collection->intersect(['Desk', 'Chair', 'Bookcase']);

    $intersect->all();

    // [0 => 'Desk', 2 => 'Chair']

> **Nota**  
> El comportamiento de este método se modifica al utilizar [Colecciones Eloquent](/docs/{{version}}/eloquent-collections#method-intersect).

<a name="method-intersectbykeys"></a>
#### `intersectByKeys()` {.collection-method}

El método `intersectByKeys` elimina las claves y sus valores correspondientes de la colección original que no están presentes en el `array` o colección dada:

    $collection = collect([
        'serial' => 'UX301', 'type' => 'screen', 'year' => 2009,
    ]);

    $intersect = $collection->intersectByKeys([
        'reference' => 'UX404', 'type' => 'tab', 'year' => 2011,
    ]);

    $intersect->all();

    // ['type' => 'screen', 'year' => 2009]

<a name="method-isempty"></a>
#### `isEmpty()` {.collection-method}

El método `isEmpty` devuelve `true` si la colección está vacía; en caso contrario, devuelve `false`:

    collect([])->isEmpty();

    // true

<a name="method-isnotempty"></a>
#### `isNotEmpty()` {.collection-method}

El método `isNotEmpty` devuelve `true` si la colección no está vacía; en caso contrario, devuelve `false`:

    collect([])->isNotEmpty();

    // false

<a name="method-join"></a>
#### `join()` {.collection-method}

El método `join` une los valores de la colección con una cadena. Mediante el segundo argumento de este método, también puede especificar cómo debe añadirse el elemento final a la cadena:

    collect(['a', 'b', 'c'])->join(', '); // 'a, b, c'
    collect(['a', 'b', 'c'])->join(', ', ', and '); // 'a, b, and c'
    collect(['a', 'b'])->join(', ', ' and '); // 'a and b'
    collect(['a'])->join(', ', ' and '); // 'a'
    collect([])->join(', ', ' and '); // ''

<a name="method-keyby"></a>
#### `keyBy()` {.collection-method}

El método `keyBy` ordena la colección por la clave dada. Si varios elementos tienen la misma clave, sólo el último aparecerá en la nueva colección:

    $collection = collect([
        ['product_id' => 'prod-100', 'name' => 'Desk'],
        ['product_id' => 'prod-200', 'name' => 'Chair'],
    ]);

    $keyed = $collection->keyBy('product_id');

    $keyed->all();

    /*
        [
            'prod-100' => ['product_id' => 'prod-100', 'name' => 'Desk'],
            'prod-200' => ['product_id' => 'prod-200', 'name' => 'Chair'],
        ]
    */

También puede pasar un callback al método. El callback debe devolver el valor por el que se codificará la colección:

    $keyed = $collection->keyBy(function ($item, $key) {
        return strtoupper($item['product_id']);
    });

    $keyed->all();

    /*
        [
            'PROD-100' => ['product_id' => 'prod-100', 'name' => 'Desk'],
            'PROD-200' => ['product_id' => 'prod-200', 'name' => 'Chair'],
        ]
    */

<a name="method-keys"></a>
#### `keys()` {.collection-method}

El método `keys` devuelve todas las claves de la colección:

    $collection = collect([
        'prod-100' => ['product_id' => 'prod-100', 'name' => 'Desk'],
        'prod-200' => ['product_id' => 'prod-200', 'name' => 'Chair'],
    ]);

    $keys = $collection->keys();

    $keys->all();

    // ['prod-100', 'prod-200']

<a name="method-last"></a>
#### `last()` {.collection-method}

El método `last` devuelve el último elemento de la colección que supera una test determinada:

    collect([1, 2, 3, 4])->last(function ($value, $key) {
        return $value < 3;
    });

    // 2

También puede llamar al método `last` sin argumentos para obtener el último elemento de la colección. Si la colección está vacía, se devuelve `null`:

    collect([1, 2, 3, 4])->last();

    // 4

<a name="method-lazy"></a>
#### `lazy()` {.collection-method}

El método `lazy` devuelve una nueva instancia de [`LazyCollection`](#lazy-collections) a partir del array de elementos subyacente:

    $lazyCollection = collect([1, 2, 3, 4])->lazy();

    get_class($lazyCollection);

    // Illuminate\Support\LazyCollection

    $lazyCollection->all();

    // [1, 2, 3, 4]

Esto es especialmente útil cuando necesitas realizar transformaciones en una `Collection` enorme que contiene muchos elementos:

    $count = $hugeCollection
        ->lazy()
        ->where('country', 'FR')
        ->where('balance', '>', '100')
        ->count();

Al convertir la colección en una `LazyCollection`, evitamos tener que asignar una tonelada de memoria adicional. Aunque la colección original sigue manteniendo _sus_ valores en memoria, los filtros posteriores no lo harán. Por lo tanto, prácticamente no se asignará memoria adicional al filtrar los resultados de la colección.

<a name="method-macro"></a>
#### `macro()` {.collection-method}

El método estático `macro`  permite añadir métodos a la clase `Collection` en tiempo de ejecución. Consulte la documentación sobre la [extensión de colecciones](#extending-collections) para obtener más información.

<a name="method-make"></a>
#### `make()` {.collection-method}

El método estático `make` crea una nueva instancia de colección. Consulte la sección [Creación de colecciones](#creating-collections).

<a name="method-map"></a>
#### `map()` {.collection-method}

El método `map` recorre la colección y pasa cada valor al callback dado. El callback es libre de modificar el elemento y devolverlo, formando así una nueva colección de elementos modificados:

    $collection = collect([1, 2, 3, 4, 5]);

    $multiplied = $collection->map(function ($item, $key) {
        return $item * 2;
    });

    $multiplied->all();

    // [2, 4, 6, 8, 10]

> **Advertencia**  
> Como la mayoría de los métodos de colección, `map` devuelve una nueva instancia de colección; no modifica la colección a la que se llama. Si desea transformar la colección original, utilice el método [`transform`](#method-transform).

<a name="method-mapinto"></a>
#### `mapInto()` {.collection-method}

El método `mapInto` itera sobre la colección, creando una nueva instancia de la clase dada al pasar el valor al constructor:

    class Currency
    {
        /**
         * Create a new currency instance.
         *
         * @param  string  $code
         * @return void
         */
        function __construct(string $code)
        {
            $this->code = $code;
        }
    }

    $collection = collect(['USD', 'EUR', 'GBP']);

    $currencies = $collection->mapInto(Currency::class);

    $currencies->all();

    // [Currency('USD'), Currency('EUR'), Currency('GBP')]

<a name="method-mapspread"></a>
#### `mapSpread()` {.collection-method}

El método `mapSpread` recorre los elementos de la colección, pasando el valor de cada elemento anidado al closure dado. El closure es libre de modificar el elemento y devolverlo, formando así una nueva colección de elementos modificados:

    $collection = collect([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

    $chunks = $collection->chunk(2);

    $sequence = $chunks->mapSpread(function ($even, $odd) {
        return $even + $odd;
    });

    $sequence->all();

    // [1, 5, 9, 13, 17]

<a name="method-maptogroups"></a>
#### `mapToGroups()` {.collection-method}

El método `mapToGroups` agrupa los elementos de la colección según el closure dado. El closure debe devolver un array asociativo que contenga un único par clave/valor, formando así una nueva colección de valores agrupados:

    $collection = collect([
        [
            'name' => 'John Doe',
            'department' => 'Sales',
        ],
        [
            'name' => 'Jane Doe',
            'department' => 'Sales',
        ],
        [
            'name' => 'Johnny Doe',
            'department' => 'Marketing',
        ]
    ]);

    $grouped = $collection->mapToGroups(function ($item, $key) {
        return [$item['department'] => $item['name']];
    });

    $grouped->all();

    /*
        [
            'Sales' => ['John Doe', 'Jane Doe'],
            'Marketing' => ['Johnny Doe'],
        ]
    */

    $grouped->get('Sales')->all();

    // ['John Doe', 'Jane Doe']

<a name="method-mapwithkeys"></a>
#### `mapWithKeys()` {.collection-method}

El método `mapWithKeys` recorre la colección y pasa cada valor al callback dado. El callback debe devolver un array asociativo que contenga un único par clave/valor:

    $collection = collect([
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
    ]);

    $keyed = $collection->mapWithKeys(function ($item, $key) {
        return [$item['email'] => $item['name']];
    });

    $keyed->all();

    /*
        [
            'john@example.com' => 'John',
            'jane@example.com' => 'Jane',
        ]
    */

<a name="method-max"></a>
#### `max()` {.collection-method}

El método `max` devuelve el valor máximo de una clave dada:

    $max = collect([
        ['foo' => 10],
        ['foo' => 20]
    ])->max('foo');

    // 20

    $max = collect([1, 2, 3, 4, 5])->max();

    // 5

<a name="method-median"></a>
#### `median()` {.collection-method}

El método `median` devuelve la [mediana](https://en.wikipedia.org/wiki/Median) de una clave dada:

    $median = collect([
        ['foo' => 10],
        ['foo' => 10],
        ['foo' => 20],
        ['foo' => 40]
    ])->median('foo');

    // 15

    $median = collect([1, 1, 2, 4])->median();

    // 1.5

<a name="method-merge"></a>
#### `merge()` {.collection-method}

El método `merge` fusiona el array o colección dada con la colección original. Si una clave de cadena de los elementos dados coincide con una clave de cadena de la colección original, el valor del elemento dado sobrescribirá el valor de la colección original:

    $collection = collect(['product_id' => 1, 'price' => 100]);

    $merged = $collection->merge(['price' => 200, 'discount' => false]);

    $merged->all();

    // ['product_id' => 1, 'price' => 200, 'discount' => false]

Si las claves de los elementos dados son numéricas, los valores se añadirán al final de la colección:

    $collection = collect(['Desk', 'Chair']);

    $merged = $collection->merge(['Bookcase', 'Door']);

    $merged->all();

    // ['Desk', 'Chair', 'Bookcase', 'Door']

<a name="method-mergerecursive"></a>
#### `mergeRecursive()` {.collection-method}

El método `mergeRecursive` fusiona el array o colección dada recursivamente con la colección original. Si una clave de cadena de los elementos dados coincide con una clave de cadena de la colección original, los valores de estas claves se combinan en una array, y esto se hace de forma recursiva:

    $collection = collect(['product_id' => 1, 'price' => 100]);

    $merged = $collection->mergeRecursive([
        'product_id' => 2,
        'price' => 200,
        'discount' => false
    ]);

    $merged->all();

    // ['product_id' => [1, 2], 'price' => [100, 200], 'discount' => false]

<a name="method-min"></a>
#### `min()` {.collection-method}

El método `min` devuelve el valor mínimo de una clave dada:

    $min = collect([['foo' => 10], ['foo' => 20]])->min('foo');

    // 10

    $min = collect([1, 2, 3, 4, 5])->min();

    // 1

<a name="method-mode"></a>
#### `mode()` {.collection-method}

El método `mode` devuelve el [valor de moda](https://en.wikipedia.org/wiki/Mode_(statistics)) de una clave dada:

    $mode = collect([
        ['foo' => 10],
        ['foo' => 10],
        ['foo' => 20],
        ['foo' => 40]
    ])->mode('foo');

    // [10]

    $mode = collect([1, 1, 2, 4])->mode();

    // [1]

    $mode = collect([1, 1, 2, 2])->mode();

    // [1, 2]

<a name="method-nth"></a>
#### `nth()` {.collection-method}

El método `nth` crea una nueva colección formada por cada n-ésimo elemento:

    $collection = collect(['a', 'b', 'c', 'd', 'e', 'f']);

    $collection->nth(4);

    // ['a', 'e']

Opcionalmente puede pasar un desplazamiento inicial como segundo argumento:

    $collection->nth(4, 1);

    // ['b', 'f']

<a name="method-only"></a>
#### `only()` {.collection-method}

El método `only` devuelve los elementos de la colección con las claves especificadas:

    $collection = collect([
        'product_id' => 1,
        'name' => 'Desk',
        'price' => 100,
        'discount' => false
    ]);

    $filtered = $collection->only(['product_id', 'name']);

    $filtered->all();

    // ['product_id' => 1, 'name' => 'Desk']

Para la inversa de `only`, véase el método [except](#method-except).

> **Nota**  
> El comportamiento de este método se modifica al utilizar [Colecciones Eloquent](/docs/{{version}}/eloquent-collections#method-only).

<a name="method-pad"></a>
#### `pad()` {.collection-method}

El método `pad` rellenará el array con el valor dado hasta que el array alcance el tamaño especificado. Este método se comporta como la función [array_pad](https://secure.php.net/manual/en/function.array-pad.php) de PHP.

Para rellenar hacia la izquierda, debe especificar un tamaño negativo. No se realizará ningún relleno si el valor absoluto del tamaño dado es menor o igual que la longitud de la array:

    $collection = collect(['A', 'B', 'C']);

    $filtered = $collection->pad(5, 0);

    $filtered->all();

    // ['A', 'B', 'C', 0, 0]

    $filtered = $collection->pad(-5, 0);

    $filtered->all();

    // [0, 0, 'A', 'B', 'C']

<a name="method-partition"></a>
#### `partition()` {.collection-method}

El método de `partición` puede combinarse con la desestructuración de array PHP para separar los elementos que pasan una test verdad dada de los que no:

    $collection = collect([1, 2, 3, 4, 5, 6]);

    [$underThree, $equalOrAboveThree] = $collection->partition(function ($i) {
        return $i < 3;
    });

    $underThree->all();

    // [1, 2]

    $equalOrAboveThree->all();

    // [3, 4, 5, 6]

<a name="method-pipe"></a>
#### `pipe()` {.collection-method}

El método `pipe` pasa la colección al closure dado y devuelve el resultado del closure ejecutado:

    $collection = collect([1, 2, 3]);

    $piped = $collection->pipe(function ($collection) {
        return $collection->sum();
    });

    // 6

<a name="method-pipeinto"></a>
#### `pipeInto()` {.collection-method}

El método `pipeInto` crea una nueva instancia de la clase dada y pasa la colección al constructor:

    class ResourceCollection
    {
        /**
         * The Collection instance.
         */
        public $collection;

        /**
         * Create a new ResourceCollection instance.
         *
         * @param  Collection  $collection
         * @return void
         */
        public function __construct(Collection $collection)
        {
            $this->collection = $collection;
        }
    }

    $collection = collect([1, 2, 3]);

    $resource = $collection->pipeInto(ResourceCollection::class);

    $resource->collection->all();

    // [1, 2, 3]

<a name="method-pipethrough"></a>
#### `pipeThrough()` {.collection-method}

El método `pipeThrough` pasa la colección al array de closures dado y devuelve el resultado de los closures ejecutados:

    $collection = collect([1, 2, 3]);

    $result = $collection->pipeThrough([
        function ($collection) {
            return $collection->merge([4, 5]);
        },
        function ($collection) {
            return $collection->sum();
        },
    ]);

    // 15

<a name="method-pluck"></a>
#### `pluck()` {.collection-method}

El método `pluck` recupera todos los valores de una clave dada:

    $collection = collect([
        ['product_id' => 'prod-100', 'name' => 'Desk'],
        ['product_id' => 'prod-200', 'name' => 'Chair'],
    ]);

    $plucked = $collection->pluck('name');

    $plucked->all();

    // ['Desk', 'Chair']

También puede especificar cómo desea que se clasifique la colección resultante:

    $plucked = $collection->pluck('name', 'product_id');

    $plucked->all();

    // ['prod-100' => 'Desk', 'prod-200' => 'Chair']

El método `pluck` también soporta la recuperación de valores anidados usando la notación "dot":

    $collection = collect([
        [
            'name' => 'Laracon',
            'speakers' => [
                'first_day' => ['Rosa', 'Judith'],
            ],
        ],
        [
            'name' => 'VueConf',
            'speakers' => [
                'first_day' => ['Abigail', 'Joey'],
            ],
        ],
    ]);

    $plucked = $collection->pluck('speakers.first_day');

    $plucked->all();

    // [['Rosa', 'Judith'], ['Abigail', 'Joey']]

Si existen claves duplicadas, el último elemento que coincida se insertará en la colección obtenida:

    $collection = collect([
        ['brand' => 'Tesla',  'color' => 'red'],
        ['brand' => 'Pagani', 'color' => 'white'],
        ['brand' => 'Tesla',  'color' => 'black'],
        ['brand' => 'Pagani', 'color' => 'orange'],
    ]);

    $plucked = $collection->pluck('color', 'brand');

    $plucked->all();

    // ['Tesla' => 'black', 'Pagani' => 'orange']

<a name="method-pop"></a>
#### `pop()` {.collection-method}

El método `pop` elimina y devuelve el último elemento de la colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->pop();

    // 5

    $collection->all();

    // [1, 2, 3, 4]

Puede pasar un entero al método `pop` para eliminar y devolver varios elementos del final de una colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->pop(3);

    // collect([5, 4, 3])

    $collection->all();

    // [1, 2]

<a name="method-prepend"></a>
#### `prepend()` {.collection-method}

El método `prepend` añade un elemento al principio de la colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->prepend(0);

    $collection->all();

    // [0, 1, 2, 3, 4, 5]

También puede pasar un segundo argumento para especificar la clave del elemento añadido:

    $collection = collect(['one' => 1, 'two' => 2]);

    $collection->prepend(0, 'zero');

    $collection->all();

    // ['zero' => 0, 'one' => 1, 'two' => 2]

<a name="method-pull"></a>
#### `pull()` {.collection-method}

El método `pull` elimina y devuelve un elemento de la colección por su clave:

    $collection = collect(['product_id' => 'prod-100', 'name' => 'Desk']);

    $collection->pull('name');

    // 'Desk'

    $collection->all();

    // ['product_id' => 'prod-100']

<a name="method-push"></a>
#### `push()` {.collection-method}

El método `push` añade un elemento al final de la colección:

    $collection = collect([1, 2, 3, 4]);

    $collection->push(5);

    $collection->all();

    // [1, 2, 3, 4, 5]

<a name="method-put"></a>
#### `put()` {.collection-method}

El método `put` establece la clave y el valor dados en la colección:

    $collection = collect(['product_id' => 1, 'name' => 'Desk']);

    $collection->put('price', 100);

    $collection->all();

    // ['product_id' => 1, 'name' => 'Desk', 'price' => 100]

<a name="method-random"></a>
#### `random()` {.collection-method}

El método `random` devuelve un elemento aleatorio de la colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->random();

    // 4 - (retrieved randomly)

Puede pasar un número entero a `random` para especificar cuántos elementos desea obtener aleatoriamente. Siempre se devuelve una colección de elementos cuando se pasa explícitamente el número de elementos que se desea recibir:

    $random = $collection->random(3);

    $random->all();

    // [2, 4, 5] - (retrieved randomly)

Si la instancia de la colección tiene menos elementos de los solicitados, el método `random` lanzará una `InvalidArgumentException`.

El método `random` también acepta un closure, que recibirá la instancia de colección actual:

    $random = $collection->random(fn ($items) => min(10, count($items)));

    $random->all();

    // [1, 2, 3, 4, 5] - (retrieved randomly)

<a name="method-range"></a>
#### `range()` {.collection-method}

El método `range` devuelve una colección que contiene enteros entre el rango especificado:

    $collection = collect()->range(3, 6);

    $collection->all();

    // [3, 4, 5, 6]

<a name="method-reduce"></a>
#### `reduce()` {.collection-method}

El método `reduce` reduce la colección a un único valor, pasando el resultado de cada iteración a la iteración siguiente:

    $collection = collect([1, 2, 3]);

    $total = $collection->reduce(function ($carry, $item) {
        return $carry + $item;
    });

    // 6

El valor de `$carry` en la primera iteración es `nulo`; sin embargo, puede especificar su valor inicial pasando un segundo argumento a `reduce`:

    $collection->reduce(function ($carry, $item) {
        return $carry + $item;
    }, 4);

    // 10

El método `reduce` también pasa claves de array en colecciones asociativas al callback dado:

    $collection = collect([
        'usd' => 1400,
        'gbp' => 1200,
        'eur' => 1000,
    ]);

    $ratio = [
        'usd' => 1,
        'gbp' => 1.37,
        'eur' => 1.22,
    ];

    $collection->reduce(function ($carry, $value, $key) use ($ratio) {
        return $carry + ($value * $ratio[$key]);
    });

    // 4264

<a name="method-reduce-spread"></a>
#### `reduceSpread()` {.collection-method}

El método `reduceSpread` reduce la colección a un array de valores, pasando los resultados de cada iteración a la iteración siguiente. Este método es similar al método `reduce`; sin embargo, puede aceptar múltiples valores iniciales:

    [$creditsRemaining, $batch] = Image::where('status', 'unprocessed')
        ->get()
        ->reduceSpread(function ($creditsRemaining, $batch, $image) {
            if ($creditsRemaining >= $image->creditsRequired()) {
                $batch->push($image);

                $creditsRemaining -= $image->creditsRequired();
            }

            return [$creditsRemaining, $batch];
        }, $creditsAvailable, collect());

<a name="method-reject"></a>
#### `reject()` {.collection-method}

El método `reject` filtra la colección utilizando el closure dado. El closure debe devolver `true` si el elemento debe ser eliminado de la colección resultante:

    $collection = collect([1, 2, 3, 4]);

    $filtered = $collection->reject(function ($value, $key) {
        return $value > 2;
    });

    $filtered->all();

    // [1, 2]

Para la inversa del método `reject`, véase el método [`filtrar`](#method-filter).

<a name="method-replace"></a>
#### `replace()` {.collection-method}

El método `replace` se comporta de forma similar a `merge`; sin embargo, además de sobrescribir los elementos coincidentes que tengan claves de cadena, el método `replace` también sobrescribirá los elementos de la colección que tengan claves numéricas coincidentes:

    $collection = collect(['Taylor', 'Abigail', 'James']);

    $replaced = $collection->replace([1 => 'Victoria', 3 => 'Finn']);

    $replaced->all();

    // ['Taylor', 'Victoria', 'James', 'Finn']

<a name="method-replacerecursive"></a>
#### `replaceRecursive()` {.collection-method}

Este método funciona como `replace`, pero también recorre los sub arrays y aplica el mismo proceso de sustitución a los valores internos:

    $collection = collect([
        'Taylor',
        'Abigail',
        [
            'James',
            'Victoria',
            'Finn'
        ]
    ]);

    $replaced = $collection->replaceRecursive([
        'Charlie',
        2 => [1 => 'King']
    ]);

    $replaced->all();

    // ['Charlie', 'Abigail', ['James', 'King', 'Finn']]

<a name="method-reverse"></a>
#### `reverse()` {.collection-method}

El método `reverse` invierte el orden de los elementos de la colección, conservando las claves originales:

    $collection = collect(['a', 'b', 'c', 'd', 'e']);

    $reversed = $collection->reverse();

    $reversed->all();

    /*
        [
            4 => 'e',
            3 => 'd',
            2 => 'c',
            1 => 'b',
            0 => 'a',
        ]
    */

<a name="method-search"></a>
#### `search()` {.collection-method}

El método `search` busca en la colección el valor dado y devuelve su clave si lo encuentra. Si no lo encuentra, devuelve `false`:

    $collection = collect([2, 4, 6, 8]);

    $collection->search(4);

    // 1

La búsqueda se realiza utilizando una comparación "flexible" (loose), lo que significa que una cadena con un valor entero se considerará igual a un entero del mismo valor. Para utilizar una comparación "estricta", pase `true` como segundo argumento al método:

    collect([2, 4, 6, 8])->search('4', $strict = true);

    // false

De manera alternativa, puede proporcionar su propio closure para buscar el primer elemento que pase una condición dada:

    collect([2, 4, 6, 8])->search(function ($item, $key) {
        return $item > 5;
    });

    // 2

<a name="method-shift"></a>
#### `shift()` {.collection-method}

El método `shift` elimina y devuelve el primer elemento de la colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->shift();

    // 1

    $collection->all();

    // [2, 3, 4, 5]

Puede pasar un entero al método `shift` para eliminar y devolver múltiples elementos desde el principio de una colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->shift(3);

    // collect([1, 2, 3])

    $collection->all();

    // [4, 5]

<a name="method-shuffle"></a>
#### `shuffle()` {.collection-method}

El método `shuffle` mezcla aleatoriamente los elementos de la colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $shuffled = $collection->shuffle();

    $shuffled->all();

    // [3, 2, 5, 1, 4] - (generated randomly)

<a name="method-skip"></a>
#### `skip()` {.collection-method}

El método `skip` devuelve una nueva colección, con el número dado de elementos eliminados del principio de la colección:

    $collection = collect([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    $collection = $collection->skip(4);

    $collection->all();

    // [5, 6, 7, 8, 9, 10]

<a name="method-skipuntil"></a>
#### `skipUntil()` {.collection-method}

El método `skipUntil` omite elementos de la colección hasta que el callback devuelve `true` y, a continuación, devuelve los elementos restantes de la colección como una nueva instancia de la colección:

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->skipUntil(function ($item) {
        return $item >= 3;
    });

    $subset->all();

    // [3, 4]

También puede pasar un valor simple al método `skipUntil` para saltar todos los elementos hasta que se encuentre el valor dado:

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->skipUntil(3);

    $subset->all();

    // [3, 4]

> **Advertencia**  
> Si el valor dado no se encuentra o el callback nunca devuelve `true`, el método `skipUntil` devolverá una colección vacía.

<a name="method-skipwhile"></a>
#### `skipWhile()` {.collection-method}

El método `skipWhile` omite elementos de la colección mientras el callback devuelve `true` y devuelve los elementos restantes de la colección como una nueva colección:

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->skipWhile(function ($item) {
        return $item <= 3;
    });

    $subset->all();

    // [4]

> **Advertencia**  
> Si el callback nunca devuelve `false`, el método `skipWhile` devolverá una colección vacía.

<a name="method-slice"></a>
#### `slice()` {.collection-method}

El método `slice` devuelve una porción de la colección a partir del índice dado:

    $collection = collect([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    $slice = $collection->slice(4);

    $slice->all();

    // [5, 6, 7, 8, 9, 10]

Si desea limitar el tamaño de la porción devuelta, pase el tamaño deseado como segundo argumento al método:

    $slice = $collection->slice(4, 2);

    $slice->all();

    // [5, 6]

La porción devuelta conservará las claves por defecto. Si no desea conservar las claves originales, puede utilizar el método [`values`](#method-values) para reindexarlas.

<a name="method-sliding"></a>
#### `sliding()` {.collection-method}

El método `sliding` devuelve una nueva colección de trozos que representan una vista de "ventana deslizante" de los elementos de la colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $chunks = $collection->sliding(2);

    $chunks->toArray();

    // [[1, 2], [2, 3], [3, 4], [4, 5]]

Esto es especialmente útil junto con el método [`eachSpread`](#method-eachspread):

    $transactions->sliding(2)->eachSpread(function ($previous, $current) {
        $current->total = $previous->total + $current->amount;
    });

Puede pasar opcionalmente un segundo valor "step", que determina la distancia entre el primer elemento de cada chunk:

    $collection = collect([1, 2, 3, 4, 5]);

    $chunks = $collection->sliding(3, step: 2);

    $chunks->toArray();

    // [[1, 2, 3], [3, 4, 5]]

<a name="method-sole"></a>
#### `sole()` {.collection-method}

El método `sole` devuelve el primer elemento de la colección que supera una condición dada, pero sólo si la condición coincide exactamente con un elemento y no varios:

    collect([1, 2, 3, 4])->sole(function ($value, $key) {
        return $value === 2;
    });

    // 2

También puede pasar un par clave/valor al método `sole`, que devolverá el primer elemento de la colección que coincida con el par dado, pero sólo si coincide exactamente un elemento:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
    ]);

    $collection->sole('product', 'Chair');

    // ['product' => 'Chair', 'price' => 100]

De manera alternativa, también puede llamar al método `sole` sin ningún argumento para obtener el primer elemento de la colección si sólo hay un elemento:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
    ]);

    $collection->sole();

    // ['product' => 'Desk', 'price' => 200]

Si no hay elementos en la colección que deban ser devueltos por el método `sole`, se lanzará una excepción `\Illuminate\Collections\ItemNotFoundException`. Si hay más de un elemento que debe ser devuelto, se lanzará una excepción de tipo `\Illuminate\Collections\MultipleItemsFoundException`.

<a name="method-some"></a>
#### `some()` {.collection-method}

Alias del método [`contains`](#method-contains).

<a name="method-sort"></a>
#### `sort()` {.collection-method}

El método `sort` ordena la colección. La colección ordenada mantiene las claves originales array, por lo que en el siguiente ejemplo utilizaremos el método [`values`](#method-values) para restablecer las claves a índices numerados consecutivamente:

    $collection = collect([5, 3, 1, 2, 4]);

    $sorted = $collection->sort();

    $sorted->values()->all();

    // [1, 2, 3, 4, 5]

Si sus necesidades de ordenación son más avanzadas, puede pasar un callback para `ordenar` con su propio algoritmo. Consulte la documentación de PHP sobre [`uasort`](https://secure.php.net/manual/en/function.uasort.php#refsect1-function.uasort-parameters), que es lo que utiliza internamente el método `sort` de la colección.

> **Nota**  
> Si necesita ordenar una colección de arrays u objetos anidados, vea los métodos [`sortBy`](#method-sortby) y [`sortByDesc`](#method-sortbydesc).

<a name="method-sortby"></a>
#### `sortBy()` {.collection-method}

El método `sortBy` ordena la colección por la clave dada. La colección ordenada conserva las claves originales array, por lo que en el siguiente ejemplo utilizaremos el método [`values`](#method-values) para restablecer las claves a índices numerados consecutivamente:

    $collection = collect([
        ['name' => 'Desk', 'price' => 200],
        ['name' => 'Chair', 'price' => 100],
        ['name' => 'Bookcase', 'price' => 150],
    ]);

    $sorted = $collection->sortBy('price');

    $sorted->values()->all();

    /*
        [
            ['name' => 'Chair', 'price' => 100],
            ['name' => 'Bookcase', 'price' => 150],
            ['name' => 'Desk', 'price' => 200],
        ]
    */

El método `sortBy` acepta [sort flags](https://www.php.net/manual/en/function.sort.php) como segundo argumento:

    $collection = collect([
        ['title' => 'Item 1'],
        ['title' => 'Item 12'],
        ['title' => 'Item 3'],
    ]);

    $sorted = $collection->sortBy('title', SORT_NATURAL);

    $sorted->values()->all();

    /*
        [
            ['title' => 'Item 1'],
            ['title' => 'Item 3'],
            ['title' => 'Item 12'],
        ]
    */

De manera alternativa, puede pasar su propio closure para determinar cómo ordenar los valores de la colección:

    $collection = collect([
        ['name' => 'Desk', 'colors' => ['Black', 'Mahogany']],
        ['name' => 'Chair', 'colors' => ['Black']],
        ['name' => 'Bookcase', 'colors' => ['Red', 'Beige', 'Brown']],
    ]);

    $sorted = $collection->sortBy(function ($product, $key) {
        return count($product['colors']);
    });

    $sorted->values()->all();

    /*
        [
            ['name' => 'Chair', 'colors' => ['Black']],
            ['name' => 'Desk', 'colors' => ['Black', 'Mahogany']],
            ['name' => 'Bookcase', 'colors' => ['Red', 'Beige', 'Brown']],
        ]
    */

Si quieres ordenar tu colección por múltiples atributos, puedes pasar un array de operaciones de ordenación al método `sortBy`. Cada operación de ordenación debe ser un array formado por el atributo por el que se desea ordenar y la dirección de la ordenación deseada:

    $collection = collect([
        ['name' => 'Taylor Otwell', 'age' => 34],
        ['name' => 'Abigail Otwell', 'age' => 30],
        ['name' => 'Taylor Otwell', 'age' => 36],
        ['name' => 'Abigail Otwell', 'age' => 32],
    ]);

    $sorted = $collection->sortBy([
        ['name', 'asc'],
        ['age', 'desc'],
    ]);

    $sorted->values()->all();

    /*
        [
            ['name' => 'Abigail Otwell', 'age' => 32],
            ['name' => 'Abigail Otwell', 'age' => 30],
            ['name' => 'Taylor Otwell', 'age' => 36],
            ['name' => 'Taylor Otwell', 'age' => 34],
        ]
    */

Al ordenar una colección por varios atributos, también puede proporcionar closures que definan cada operación de ordenación:

    $collection = collect([
        ['name' => 'Taylor Otwell', 'age' => 34],
        ['name' => 'Abigail Otwell', 'age' => 30],
        ['name' => 'Taylor Otwell', 'age' => 36],
        ['name' => 'Abigail Otwell', 'age' => 32],
    ]);

    $sorted = $collection->sortBy([
        fn ($a, $b) => $a['name'] <=> $b['name'],
        fn ($a, $b) => $b['age'] <=> $a['age'],
    ]);

    $sorted->values()->all();

    /*
        [
            ['name' => 'Abigail Otwell', 'age' => 32],
            ['name' => 'Abigail Otwell', 'age' => 30],
            ['name' => 'Taylor Otwell', 'age' => 36],
            ['name' => 'Taylor Otwell', 'age' => 34],
        ]
    */

<a name="method-sortbydesc"></a>
#### `sortByDesc()` {.collection-method}

Este método tiene la misma firma que el método [`sortBy`](#method-sortby), pero ordenará la colección en el orden opuesto.

<a name="method-sortdesc"></a>
#### `sortDesc()` {.collection-method}

Este método ordenará la colección en el orden inverso al del método [`sort`](#method-sort):

    $collection = collect([5, 3, 1, 2, 4]);

    $sorted = $collection->sortDesc();

    $sorted->values()->all();

    // [5, 4, 3, 2, 1]

A diferencia de `sort`, no puede pasar un closure a `sortDesc`. En su lugar, debe utilizar el método [`sort`](#method-sort) e invertir su comparación.

<a name="method-sortkeys"></a>
#### `sortKeys()` {.collection-method}

El método `sortKeys` ordena la colección por las claves del array asociativo subyacente:

    $collection = collect([
        'id' => 22345,
        'first' => 'John',
        'last' => 'Doe',
    ]);

    $sorted = $collection->sortKeys();

    $sorted->all();

    /*
        [
            'first' => 'John',
            'id' => 22345,
            'last' => 'Doe',
        ]
    */

<a name="method-sortkeysdesc"></a>
#### `sortKeysDesc()` {.collection-method}

Este método tiene la misma firma que el método [`sortKeys`](#method-sortkeys), pero ordenará la colección en el orden opuesto.

<a name="method-sortkeysusing"></a>
#### `sortKeysUsing()` {.collection-method}

El método `sortKeysUsing` ordena la colección por las claves del array asociativo subyacente utilizando un callback:

    $collection = collect([
        'ID' => 22345,
        'first' => 'John',
        'last' => 'Doe',
    ]);

    $sorted = $collection->sortKeysUsing('strnatcasecmp');

    $sorted->all();

    /*
        [
            'first' => 'John',
            'ID' => 22345,
            'last' => 'Doe',
        ]
    */

El callback debe ser una función de comparación que devuelva un entero menor, igual o mayor que cero. Para más información, consulte la documentación de PHP sobre [`uksort`](https://www.php.net/manual/en/function.uksort.php#refsect1-function.uksort-parameters), que es la función PHP que el método `sortKeysUsing` utiliza internamente.

<a name="method-splice"></a>
#### `splice()` {.collection-method}

El método `splice` elimina y devuelve una porción de elementos a partir del índice especificado:

    $collection = collect([1, 2, 3, 4, 5]);

    $chunk = $collection->splice(2);

    $chunk->all();

    // [3, 4, 5]

    $collection->all();

    // [1, 2]

Puede pasar un segundo argumento para limitar el tamaño de la colección resultante:

    $collection = collect([1, 2, 3, 4, 5]);

    $chunk = $collection->splice(2, 1);

    $chunk->all();

    // [3]

    $collection->all();

    // [1, 2, 4, 5]

Además, puede pasar un tercer argumento que contenga los nuevos elementos que sustituirán a los elementos eliminados de la colección:

    $collection = collect([1, 2, 3, 4, 5]);

    $chunk = $collection->splice(2, 1, [10, 11]);

    $chunk->all();

    // [3]

    $collection->all();

    // [1, 2, 10, 11, 4, 5]

<a name="method-split"></a>
#### `split()` {.collection-method}

El método `split` divide una colección en el número de grupos dado:

    $collection = collect([1, 2, 3, 4, 5]);

    $groups = $collection->split(3);

    $groups->all();

    // [[1, 2], [3, 4], [5]]

<a name="method-splitin"></a>
#### `splitIn()` {.collection-method}

El método `splitIn` divide una colección en el número dado de grupos, llenando completamente los grupos no terminales antes de asignar el resto al grupo final:

    $collection = collect([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    $groups = $collection->splitIn(3);

    $groups->all();

    // [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10]]

<a name="method-sum"></a>
#### `sum()` {.collection-method}

El método `sum` devuelve la suma de todos los elementos de la colección:

    collect([1, 2, 3, 4, 5])->sum();

    // 15

Si la colección contiene arrays u objetos anidados, debe pasar una clave que se utilizará para determinar qué valores sumar:

    $collection = collect([
        ['name' => 'JavaScript: The Good Parts', 'pages' => 176],
        ['name' => 'JavaScript: The Definitive Guide', 'pages' => 1096],
    ]);

    $collection->sum('pages');

    // 1272

Además, puede pasar su propio closure para determinar qué valores de la colección sumar:

    $collection = collect([
        ['name' => 'Chair', 'colors' => ['Black']],
        ['name' => 'Desk', 'colors' => ['Black', 'Mahogany']],
        ['name' => 'Bookcase', 'colors' => ['Red', 'Beige', 'Brown']],
    ]);

    $collection->sum(function ($product) {
        return count($product['colors']);
    });

    // 6

<a name="method-take"></a>
#### `take()` {.collection-method}

El método `take` devuelve una nueva colección con el número de elementos especificado:

    $collection = collect([0, 1, 2, 3, 4, 5]);

    $chunk = $collection->take(3);

    $chunk->all();

    // [0, 1, 2]

También puede pasar un número entero negativo para tomar el número especificado de elementos desde el final de la colección:

    $collection = collect([0, 1, 2, 3, 4, 5]);

    $chunk = $collection->take(-2);

    $chunk->all();

    // [4, 5]

<a name="method-takeuntil"></a>
#### `takeUntil()` {.collection-method}

El método `takeUntil` devuelve los elementos de la colección hasta que el callback devuelve `true`:

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->takeUntil(function ($item) {
        return $item >= 3;
    });

    $subset->all();

    // [1, 2]

También puede pasar un valor simple al método `takeUntil` para obtener los elementos hasta que se encuentre el valor dado:

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->takeUntil(3);

    $subset->all();

    // [1, 2]

> **Advertencia**  
> Si no se encuentra el valor dado o el callback nunca devuelve `true`, el método `takeUntil` devolverá todos los elementos de la colección.

<a name="method-takewhile"></a>
#### `takeWhile()` {.collection-method}

El método `takeWhile` devuelve los elementos de la colección hasta que el callback dado devuelva `false`:

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->takeWhile(function ($item) {
        return $item < 3;
    });

    $subset->all();

    // [1, 2]

> **Advertencia**  
> Si el callback nunca devuelve `false`, el método `takeWhile` devolverá todos los elementos de la colección.

<a name="method-tap"></a>
#### `tap()` {.collection-method}

El método `tap` pasa la colección al callback dado, permitiéndole "pinchar" la colección en un punto específico y hacer algo con los elementos sin afectar a la colección en sí. El método `tap` devuelve la colección:

    collect([2, 4, 3, 1, 5])
        ->sort()
        ->tap(function ($collection) {
            Log::debug('Values after sorting', $collection->values()->all());
        })
        ->shift();

    // 1

<a name="method-times"></a>
#### `times()` {.collection-method}

El método estático `times` crea una nueva colección invocando el closure dado un número especificado de veces:

    $collection = Collection::times(10, function ($number) {
        return $number * 9;
    });

    $collection->all();

    // [9, 18, 27, 36, 45, 54, 63, 72, 81, 90]

<a name="method-toarray"></a>
#### `toArray()` {.collection-method}

El método `toArray` convierte la colección en un `array` PHP plano. Si los valores de la colección son modelos [Eloquent](/docs/{{version}}/eloquent), los modelos también se convertirán en array:

    $collection = collect(['name' => 'Desk', 'price' => 200]);

    $collection->toArray();

    /*
        [
            ['name' => 'Desk', 'price' => 200],
        ]
    */

> **Advertencia**  
> `toArray` también convierte todos los objetos anidados de la colección que son una instancia de `Arrayable` a un array. Si quieres obtener el array en bruto subyacente en la colección, utiliza el método [`all`](#method-all) en su lugar.

<a name="method-tojson"></a>
#### `toJson()` {.collection-method}

El método `toJson` convierte la colección en una cadena serializada JSON:

    $collection = collect(['name' => 'Desk', 'price' => 200]);

    $collection->toJson();

    // '{"name":"Desk", "price":200}'

<a name="method-transform"></a>
#### `transform()` {.collection-method}

El método `transform` itera sobre la colección y llama al callback dado con cada elemento de la colección. Los elementos de la colección serán reemplazados por los valores devueltos por el callback:

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->transform(function ($item, $key) {
        return $item * 2;
    });

    $collection->all();

    // [2, 4, 6, 8, 10]

> **Advertencia**  
> A diferencia de la mayoría de los otros métodos de colección, `transform` modifica la propia colección. Si desea crear una nueva colección, utilice el método [`map`](#method-map).

<a name="method-undot"></a>
#### `undot()` {.collection-method}

El método `undot` expande una colección unidimensional que utiliza la notación "dot" a una colección multidimensional:

    $person = collect([
        'name.first_name' => 'Marie',
        'name.last_name' => 'Valentine',
        'address.line_1' => '2992 Eagle Drive',
        'address.line_2' => '',
        'address.suburb' => 'Detroit',
        'address.state' => 'MI',
        'address.postcode' => '48219'
    ]);

    $person = $person->undot();

    $person->toArray();

    /*
        [
            "name" => [
                "first_name" => "Marie",
                "last_name" => "Valentine",
            ],
            "address" => [
                "line_1" => "2992 Eagle Drive",
                "line_2" => "",
                "suburb" => "Detroit",
                "state" => "MI",
                "postcode" => "48219",
            ],
        ]
    */

<a name="method-union"></a>
#### `union()` {.collection-method}

El método `union` añade el array dado a la colección. Si el array dado contiene claves que ya están en la colección original, se preferirán los valores de la colección original:

    $collection = collect([1 => ['a'], 2 => ['b']]);

    $union = $collection->union([3 => ['c'], 1 => ['d']]);

    $union->all();

    // [1 => ['a'], 2 => ['b'], 3 => ['c']]

<a name="method-unique"></a>
#### `unique()` {.collection-method}

El método `unique` devuelve todos los elementos únicos de la colección. La colección devuelta conserva las claves originales del array, por lo que en el siguiente ejemplo utilizaremos el método [`values`](#method-values) para restablecer las claves a índices numerados consecutivamente:

    $collection = collect([1, 1, 2, 2, 3, 4, 2]);

    $unique = $collection->unique();

    $unique->values()->all();

    // [1, 2, 3, 4]

Cuando se trata de arrays u objetos anidados, puede especificar la clave utilizada para determinar la unicidad:

    $collection = collect([
        ['name' => 'iPhone 6', 'brand' => 'Apple', 'type' => 'phone'],
        ['name' => 'iPhone 5', 'brand' => 'Apple', 'type' => 'phone'],
        ['name' => 'Apple Watch', 'brand' => 'Apple', 'type' => 'watch'],
        ['name' => 'Galaxy S6', 'brand' => 'Samsung', 'type' => 'phone'],
        ['name' => 'Galaxy Gear', 'brand' => 'Samsung', 'type' => 'watch'],
    ]);

    $unique = $collection->unique('brand');

    $unique->values()->all();

    /*
        [
            ['name' => 'iPhone 6', 'brand' => 'Apple', 'type' => 'phone'],
            ['name' => 'Galaxy S6', 'brand' => 'Samsung', 'type' => 'phone'],
        ]
    */

Por último, también puede pasar su propio closure al método `unique` para especificar qué valor debe determinar la unicidad de un elemento:

    $unique = $collection->unique(function ($item) {
        return $item['brand'].$item['type'];
    });

    $unique->values()->all();

    /*
        [
            ['name' => 'iPhone 6', 'brand' => 'Apple', 'type' => 'phone'],
            ['name' => 'Apple Watch', 'brand' => 'Apple', 'type' => 'watch'],
            ['name' => 'Galaxy S6', 'brand' => 'Samsung', 'type' => 'phone'],
            ['name' => 'Galaxy Gear', 'brand' => 'Samsung', 'type' => 'watch'],
        ]
    */

El método `unique` utiliza comparaciones "flexibles" (loose) al comprobar los valores de los elementos, lo que significa que una cadena con un valor entero se considerará igual a un entero del mismo valor. Utilice el método [`uniqueStrict`](#method-uniquestrict) para filtrar utilizando comparaciones "estrictas".

> **Nota**  
> El comportamiento de este método se modifica al utilizar [Colecciones Eloquent](/docs/{{version}}/eloquent-collections#method-unique).

<a name="method-uniquestrict"></a>
#### `uniqueStrict()` {.collection-method}

Este método tiene la misma firma que el método [`unique`](#method-unique); sin embargo, todos los valores se comparan utilizando comparaciones "estrictas".

<a name="method-unless"></a>
#### `unless()` {.collection-method}

El método `unless` ejecutará el callback dado a menos que el primer argumento dado al método se evalúe como `true`:

    $collection = collect([1, 2, 3]);

    $collection->unless(true, function ($collection) {
        return $collection->push(4);
    });

    $collection->unless(false, function ($collection) {
        return $collection->push(5);
    });

    $collection->all();

    // [1, 2, 3, 5]

Se puede pasar una segunda llamada de retorno al método `unless`. La segunda llamada de retorno se ejecutará cuando el primer argumento dado al método `unless` sea `true`:

    $collection = collect([1, 2, 3]);

    $collection->unless(true, function ($collection) {
        return $collection->push(4);
    }, function ($collection) {
        return $collection->push(5);
    });

    $collection->all();

    // [1, 2, 3, 5]

Para la inversa de `unless`, véase el método [`when`](#method-when).

<a name="method-unlessempty"></a>
#### `unlessEmpty()` {.collection-method}

Alias del método [`whenNotEmpty`](#method-whennotempty).

<a name="method-unlessnotempty"></a>
#### `unlessNotEmpty()` {.collection-method}

Alias del método [`whenEmpty`](#method-whenempty).

<a name="method-unwrap"></a>
#### `unwrap()` {.collection-method}

El método estático `unwrap` devuelve los elementos subyacentes de la colección a partir del valor dado cuando es aplicable:

    Collection::unwrap(collect('John Doe'));

    // ['John Doe']

    Collection::unwrap(['John Doe']);

    // ['John Doe']

    Collection::unwrap('John Doe');

    // 'John Doe'

<a name="method-value"></a>
#### `value()` {.collection-method}

El método `value` recupera un valor dado del primer elemento de la colección:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Speaker', 'price' => 400],
    ]);

    $value = $collection->value('price');

    // 200

<a name="method-values"></a>
#### `values()` {.collection-method}

El método `values` devuelve una nueva colección con las claves restablecidas a enteros consecutivos:

    $collection = collect([
        10 => ['product' => 'Desk', 'price' => 200],
        11 => ['product' => 'Desk', 'price' => 200],
    ]);

    $values = $collection->values();

    $values->all();

    /*
        [
            0 => ['product' => 'Desk', 'price' => 200],
            1 => ['product' => 'Desk', 'price' => 200],
        ]
    */

<a name="method-when"></a>
#### `when()` {.collection-method}

El método `when` ejecutará el callback dado cuando el primer argumento dado al método se evalúe como `true`. La instancia de la colección y el primer argumento dado al método `when` se proporcionarán al closure:

    $collection = collect([1, 2, 3]);

    $collection->when(true, function ($collection, $value) {
        return $collection->push(4);
    });

    $collection->when(false, function ($collection, $value) {
        return $collection->push(5);
    });

    $collection->all();

    // [1, 2, 3, 4]

Se puede pasar una segunda llamada de retorno al método `when`. La segunda llamada de retorno se ejecutará cuando el primer argumento dado al método `when` sea `falso`:

    $collection = collect([1, 2, 3]);

    $collection->when(false, function ($collection, $value) {
        return $collection->push(4);
    }, function ($collection) {
        return $collection->push(5);
    });

    $collection->all();

    // [1, 2, 3, 5]

Para la inversa de `when`, véase el método [`unless`](#method-unless).

<a name="method-whenempty"></a>
#### `whenEmpty()` {.collection-method}

El método `whenEmpty` ejecutará el callback dado cuando la colección esté vacía:

    $collection = collect(['Michael', 'Tom']);

    $collection->whenEmpty(function ($collection) {
        return $collection->push('Adam');
    });

    $collection->all();

    // ['Michael', 'Tom']


    $collection = collect();

    $collection->whenEmpty(function ($collection) {
        return $collection->push('Adam');
    });

    $collection->all();

    // ['Adam']

Se puede pasar un segundo closure al método `whenEmpty` que se ejecutará cuando la colección no esté vacía:

    $collection = collect(['Michael', 'Tom']);

    $collection->whenEmpty(function ($collection) {
        return $collection->push('Adam');
    }, function ($collection) {
        return $collection->push('Taylor');
    });

    $collection->all();

    // ['Michael', 'Tom', 'Taylor']

Para la inversa de `whenEmpty`, consulte el método [`whenNotEmpty`](#method-whennotempty).

<a name="method-whennotempty"></a>
#### `whenNotEmpty()` {.collection-method}

El método `whenNotEmpty` ejecutará el callback dado cuando la colección no esté vacía:

    $collection = collect(['michael', 'tom']);

    $collection->whenNotEmpty(function ($collection) {
        return $collection->push('adam');
    });

    $collection->all();

    // ['michael', 'tom', 'adam']


    $collection = collect();

    $collection->whenNotEmpty(function ($collection) {
        return $collection->push('adam');
    });

    $collection->all();

    // []

Se puede pasar un segundo closure al método `whenNotEmpty` que se ejecutará cuando la colección esté vacía:

    $collection = collect();

    $collection->whenNotEmpty(function ($collection) {
        return $collection->push('adam');
    }, function ($collection) {
        return $collection->push('taylor');
    });

    $collection->all();

    // ['taylor']

Para la inversa de `whenNotEmpty`, véase el método [`whenEmpty`](#method-whenempty).

<a name="method-where"></a>
#### `where()` {.collection-method}

El método `where` filtra la colección por un par clave/valor dado:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->where('price', 100);

    $filtered->all();

    /*
        [
            ['product' => 'Chair', 'price' => 100],
            ['product' => 'Door', 'price' => 100],
        ]
    */

El método `where` utiliza comparaciones "flexibles" (loose) al comprobar los valores de los elementos, lo que significa que una cadena con un valor entero se considerará igual a un entero del mismo valor. Utilice el método [`whereStrict`](#method-wherestrict) para filtrar utilizando comparaciones "estrictas".

Opcionalmente, puede pasar un operador de comparación como segundo parámetro. Los operadores admitidos son: '===', '!==', '!=', '==', '=', '<>', '>', '<', '>=' y '<=':

    $collection = collect([
        ['name' => 'Jim', 'deleted_at' => '2019-01-01 00:00:00'],
        ['name' => 'Sally', 'deleted_at' => '2019-01-02 00:00:00'],
        ['name' => 'Sue', 'deleted_at' => null],
    ]);

    $filtered = $collection->where('deleted_at', '!=', null);

    $filtered->all();

    /*
        [
            ['name' => 'Jim', 'deleted_at' => '2019-01-01 00:00:00'],
            ['name' => 'Sally', 'deleted_at' => '2019-01-02 00:00:00'],
        ]
    */

<a name="method-wherestrict"></a>
#### `whereStrict()` {.collection-method}

Este método tiene la misma firma que el método [`where`](#method-where); sin embargo, todos los valores se comparan utilizando comparaciones "estrictas".

<a name="method-wherebetween"></a>
#### `whereBetween()` {.collection-method}

El método `whereBetween` filtra la colección determinando si el valor de un elemento especificado se encuentra dentro de un rango determinado:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 80],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Pencil', 'price' => 30],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->whereBetween('price', [100, 200]);

    $filtered->all();

    /*
        [
            ['product' => 'Desk', 'price' => 200],
            ['product' => 'Bookcase', 'price' => 150],
            ['product' => 'Door', 'price' => 100],
        ]
    */

<a name="method-wherein"></a>
#### `whereIn()` {.collection-method}

El método `whereIn` elimina los elementos de la colección que no tienen un valor de elemento especificado que esté contenido en el array dado:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->whereIn('price', [150, 200]);

    $filtered->all();

    /*
        [
            ['product' => 'Desk', 'price' => 200],
            ['product' => 'Bookcase', 'price' => 150],
        ]
    */

El método `whereIn` utiliza comparaciones "flexibles" (loose) al comprobar los valores de los elementos, lo que significa que una cadena con un valor entero se considerará igual a un entero del mismo valor. Utilice el método [`whereInStrict`](#method-whereinstrict) para filtrar utilizando comparaciones "estrictas".

<a name="method-whereinstrict"></a>
#### `whereInStrict()` {.collection-method}

Este método tiene la misma firma que el método [`whereIn`](#method-wherein); sin embargo, todos los valores se comparan utilizando comparaciones "estrictas".

<a name="method-whereinstanceof"></a>
#### `whereInstanceOf()` {.collection-method}

El método `whereInstanceOf` filtra la colección por un tipo de clase determinado:

    use App\Models\User;
    use App\Models\Post;

    $collection = collect([
        new User,
        new User,
        new Post,
    ]);

    $filtered = $collection->whereInstanceOf(User::class);

    $filtered->all();

    // [App\Models\User, App\Models\User]

<a name="method-wherenotbetween"></a>
#### `whereNotBetween()` {.collection-method}

El método `whereNotBetween` filtra la colección determinando si el valor de un elemento especificado está fuera de un rango dado:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 80],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Pencil', 'price' => 30],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->whereNotBetween('price', [100, 200]);

    $filtered->all();

    /*
        [
            ['product' => 'Chair', 'price' => 80],
            ['product' => 'Pencil', 'price' => 30],
        ]
    */

<a name="method-wherenotin"></a>
#### `whereNotIn()` {.collection-method}

El método `whereNotIn` elimina los elementos de la colección que tienen un valor de elemento especificado que está contenido dentro de el array dado:

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->whereNotIn('price', [150, 200]);

    $filtered->all();

    /*
        [
            ['product' => 'Chair', 'price' => 100],
            ['product' => 'Door', 'price' => 100],
        ]
    */

El método `whereNotIn` utiliza comparaciones "flexibles" (loose) al comprobar los valores de los elementos, lo que significa que una cadena con un valor entero se considerará igual a un entero del mismo valor. Utilice el método [`whereNotInStrict`](#method-wherenotinstrict) para filtrar utilizando comparaciones "estrictas".

<a name="method-wherenotinstrict"></a>
#### `whereNotInStrict()` {.collection-method}

Este método tiene la misma firma que el método [`whereNotIn`](#method-wherenotin); sin embargo, todos los valores se comparan utilizando comparaciones "estrictas".

<a name="method-wherenotnull"></a>
#### `whereNotNull()` {.collection-method}

El método `whereNotNull` devuelve los elementos de la colección cuya clave no sea `null`:

    $collection = collect([
        ['name' => 'Desk'],
        ['name' => null],
        ['name' => 'Bookcase'],
    ]);

    $filtered = $collection->whereNotNull('name');

    $filtered->all();

    /*
        [
            ['name' => 'Desk'],
            ['name' => 'Bookcase'],
        ]
    */

<a name="method-wherenull"></a>
#### `whereNull()` {.collection-method}

El método `whereNull` devuelve los elementos de la colección cuya clave es `null`:

    $collection = collect([
        ['name' => 'Desk'],
        ['name' => null],
        ['name' => 'Bookcase'],
    ]);

    $filtered = $collection->whereNull('name');

    $filtered->all();

    /*
        [
            ['name' => null],
        ]
    */


<a name="method-wrap"></a>
#### `wrap()` {.collection-method}

El método estático `wrap` envuelve el valor dado en una colección cuando es aplicable:

    use Illuminate\Support\Collection;

    $collection = Collection::wrap('John Doe');

    $collection->all();

    // ['John Doe']

    $collection = Collection::wrap(['John Doe']);

    $collection->all();

    // ['John Doe']

    $collection = Collection::wrap(collect('John Doe'));

    $collection->all();

    // ['John Doe']

<a name="method-zip"></a>
#### `zip()` {.collection-method}

El método `zip` fusiona los valores de el array dado con los valores de la colección original en su índice correspondiente:

    $collection = collect(['Chair', 'Desk']);

    $zipped = $collection->zip([100, 200]);

    $zipped->all();

    // [['Chair', 100], ['Desk', 200]]

<a name="higher-order-messages"></a>
## Mensajes de orden superior

Las colecciones también admiten "mensajes de orden superior", que son atajos para realizar acciones comunes en las colecciones. Los métodos de colección que proporcionan mensajes de orden superior son: [`average`](#method-average), [`avg`](#method-avg), [`contains`](#method-contains), [`each`](#method-each), [`every`](#method-every), [`filter`](#method-filter), [`first`](#method-first), [`flatMap`](#method-flatmap), [`groupBy`](#method-groupby), [`keyBy`](#method-keyby), [`map`](#method-map), [`max`](#method-max), [`min`](#method-min), [`partition`](#method-partition), [`reject`](#method-reject), [`skipUntil`](#method-skipuntil), [`skipWhile`](#method-skipwhile), [`some`](#method-some), [`sortBy`](#method-sortby), [`sortByDesc`](#method-sortbydesc), [`sum`](#method-sum), [`takeUntil`](#method-takeuntil), [`takeWhile`](#method-takewhile) y [`unique`](#method-unique).

Se puede acceder a cada mensaje de orden superior como una propiedad dinámica de una instancia de colección. Por ejemplo, utilicemos el mensaje de orden superior `each` para llamar a un método en cada objeto de una colección:

    use App\Models\User;

    $users = User::where('votes', '>', 500)->get();

    $users->each->markAsVip();

Del mismo modo, podemos utilizar el mensaje de orden superior `sum` para reunir el número total de "votos" de una colección de usuarios:

    $users = User::where('group', 'Development')->get();

    return $users->sum->votes;

<a name="lazy-collections"></a>
## Colecciones Lazy

<a name="lazy-collection-introduction"></a>
### Introducción

> **Advertencia**  
> Antes de aprender más sobre las colecciones lazy de Laravel, tómate un tiempo para familiarizarte con [los generadores de PHP](https://www.php.net/manual/en/language.generators.overview.php).

Para complementar la ya poderosa clase `Collection`, la clase `LazyCollection` aprovecha los [generadores](https://www.php.net/manual/en/language.generators.overview.php) de PHP para permitirte trabajar con conjuntos de datos muy grandes manteniendo bajo el uso de memoria.

Por ejemplo, imagina que tu aplicación necesita procesar un archivo de registro de varios gigabytes aprovechando los métodos de colección de Laravel para analizar los registros. En lugar de leer todo el archivo en memoria a la vez, se pueden utilizar las colecciones lazy para mantener sólo una pequeña parte del archivo en memoria en un momento dado:

    use App\Models\LogEntry;
    use Illuminate\Support\LazyCollection;

    LazyCollection::make(function () {
        $handle = fopen('log.txt', 'r');

        while (($line = fgets($handle)) !== false) {
            yield $line;
        }
    })->chunk(4)->map(function ($lines) {
        return LogEntry::fromLines($lines);
    })->each(function (LogEntry $logEntry) {
        // Process the log entry...
    });

O, imagina que necesitas iterar a través de 10.000 modelos de Eloquent. Si utilizas las colecciones tradicionales de Laravel, los 10.000 modelos de Eloquent deben cargarse en memoria al mismo tiempo:

    use App\Models\User;

    $users = User::all()->filter(function ($user) {
        return $user->id > 500;
    });

Sin embargo, el método `cursor` del constructor de consultas devuelve una instancia de `LazyCollection`. Esto permite ejecutar una única consulta a la base de datos, pero también mantener un único modelo Eloquent cargado en memoria cada vez. En este ejemplo, el callback de `filter` no se ejecuta hasta que iteramos sobre cada usuario individualmente, lo que permite una reducción drástica del uso de memoria:

    use App\Models\User;

    $users = User::cursor()->filter(function ($user) {
        return $user->id > 500;
    });

    foreach ($users as $user) {
        echo $user->id;
    }

<a name="creating-lazy-collections"></a>
### Creación de colecciones lazy

Para crear una instancia de colección lazy, debe pasar una función generadora de PHP al método `make` de la colección:

    use Illuminate\Support\LazyCollection;

    LazyCollection::make(function () {
        $handle = fopen('log.txt', 'r');

        while (($line = fgets($handle)) !== false) {
            yield $line;
        }
    });

<a name="the-enumerable-contract"></a>
### La Interfaz Enumerable

Casi todos los métodos disponibles en la clase `Collection` también están disponibles en la clase `LazyCollection`. Ambas clases implementan el contrato `Illuminate\Support\Enumerable`, que define los siguientes métodos:

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

<div class="collection-method-list" markdown="1">

[all](#method-all)
[average](#method-average)
[avg](#method-avg)
[chunk](#method-chunk)
[chunkWhile](#method-chunkwhile)
[collapse](#method-collapse)
[collect](#method-collect)
[combine](#method-combine)
[concat](#method-concat)
[contains](#method-contains)
[containsStrict](#method-containsstrict)
[count](#method-count)
[countBy](#method-countBy)
[crossJoin](#method-crossjoin)
[dd](#method-dd)
[diff](#method-diff)
[diffAssoc](#method-diffassoc)
[diffKeys](#method-diffkeys)
[dump](#method-dump)
[duplicates](#method-duplicates)
[duplicatesStrict](#method-duplicatesstrict)
[each](#method-each)
[eachSpread](#method-eachspread)
[every](#method-every)
[except](#method-except)
[filter](#method-filter)
[first](#method-first)
[firstOrFail](#method-first-or-fail)
[firstWhere](#method-first-where)
[flatMap](#method-flatmap)
[flatten](#method-flatten)
[flip](#method-flip)
[forPage](#method-forpage)
[get](#method-get)
[groupBy](#method-groupby)
[has](#method-has)
[implode](#method-implode)
[intersect](#method-intersect)
[intersectByKeys](#method-intersectbykeys)
[isEmpty](#method-isempty)
[isNotEmpty](#method-isnotempty)
[join](#method-join)
[keyBy](#method-keyby)
[keys](#method-keys)
[last](#method-last)
[macro](#method-macro)
[make](#method-make)
[map](#method-map)
[mapInto](#method-mapinto)
[mapSpread](#method-mapspread)
[mapToGroups](#method-maptogroups)
[mapWithKeys](#method-mapwithkeys)
[max](#method-max)
[median](#method-median)
[merge](#method-merge)
[mergeRecursive](#method-mergerecursive)
[min](#method-min)
[mode](#method-mode)
[nth](#method-nth)
[only](#method-only)
[pad](#method-pad)
[partition](#method-partition)
[pipe](#method-pipe)
[pluck](#method-pluck)
[random](#method-random)
[reduce](#method-reduce)
[reject](#method-reject)
[replace](#method-replace)
[replaceRecursive](#method-replacerecursive)
[reverse](#method-reverse)
[search](#method-search)
[shuffle](#method-shuffle)
[skip](#method-skip)
[slice](#method-slice)
[sole](#method-sole)
[some](#method-some)
[sort](#method-sort)
[sortBy](#method-sortby)
[sortByDesc](#method-sortbydesc)
[sortKeys](#method-sortkeys)
[sortKeysDesc](#method-sortkeysdesc)
[split](#method-split)
[sum](#method-sum)
[take](#method-take)
[tap](#method-tap)
[times](#method-times)
[toArray](#method-toarray)
[toJson](#method-tojson)
[union](#method-union)
[unique](#method-unique)
[uniqueStrict](#method-uniquestrict)
[unless](#method-unless)
[unlessEmpty](#method-unlessempty)
[unlessNotEmpty](#method-unlessnotempty)
[unwrap](#method-unwrap)
[values](#method-values)
[when](#method-when)
[whenEmpty](#method-whenempty)
[whenNotEmpty](#method-whennotempty)
[where](#method-where)
[whereStrict](#method-wherestrict)
[whereBetween](#method-wherebetween)
[whereIn](#method-wherein)
[whereInStrict](#method-whereinstrict)
[whereInstanceOf](#method-whereinstanceof)
[whereNotBetween](#method-wherenotbetween)
[whereNotIn](#method-wherenotin)
[whereNotInStrict](#method-wherenotinstrict)
[wrap](#method-wrap)
[zip](#method-zip)

</div>

> **Advertencia**  
> Los métodos que mutan la colección (como `shift`, `pop`, `prepend` etc.) **no** están disponibles en la clase `LazyCollection`.

<a name="lazy-collection-methods"></a>
### Métodos de Lazy Collection

Además de los métodos definidos en el contrato `Enumerable`, la clase `LazyCollection` contiene los siguientes métodos:

<a name="method-takeUntilTimeout"></a>
#### `takeUntilTimeout()` {.collection-method}

El método `takeUntilTimeout` devuelve una nueva colección lazy que enumerará valores hasta el tiempo especificado. Pasado ese tiempo, la colección dejará de enumerar:

    $lazyCollection = LazyCollection::times(INF)
        ->takeUntilTimeout(now()->addMinute());

    $lazyCollection->each(function ($number) {
        dump($number);

        sleep(1);
    });

    // 1
    // 2
    // ...
    // 58
    // 59

Para ilustrar el uso de este método, imagine una aplicación que envía facturas desde la base de datos utilizando un cursor. Se podría definir una [tarea programada](/docs/{{version}}/scheduling) que se ejecute cada 15 minutos y que sólo procese las facturas durante un máximo de 14 minutos:

    use App\Models\Invoice;
    use Illuminate\Support\Carbon;

    Invoice::pending()->cursor()
        ->takeUntilTimeout(
            Carbon::createFromTimestamp(LARAVEL_START)->add(14, 'minutes')
        )
        ->each(fn ($invoice) => $invoice->submit());

<a name="method-tapEach"></a>
#### `tapEach()` {.collection-method}

Mientras que el método `each` llama inmediatamente al callback dado para cada elemento de la colección, el método `tapEach` sólo llama al callback dado a medida que los elementos se van extrayendo de la lista uno a uno:

    // Nothing has been dumped so far...
    $lazyCollection = LazyCollection::times(INF)->tapEach(function ($value) {
        dump($value);
    });

    // Three items are dumped...
    $array = $lazyCollection->take(3)->all();

    // 1
    // 2
    // 3

<a name="method-remember"></a>
#### `remember()` {.collection-method}

El método `remember` devuelve una nueva colección lazy que recordará cualquier valor que ya haya sido enumerado y no lo recuperará de nuevo en enumeraciones posteriores de la colección:

    // No query has been executed yet...
    $users = User::cursor()->remember();

    // The query is executed...
    // The first 5 users are hydrated from the database...
    $users->take(5)->all();

    // First 5 users come from the collection's cache...
    // The rest are hydrated from the database...
    $users->take(20)->all();
