# Eloquent: Colecciones

- [Introducción](#introduction)
- [Métodos Disponibles](#available-methods)
- [Colecciones Personalizadas](#custom-collections)

<a name="introduction"></a>
## Introducción

Todos los métodos de Eloquent que devuelven más de un resultado de modelo devolverán instancias de la clase `Illuminate\Database\Eloquent\Collection`, incluidos los resultados recuperados a través del método `get` o accedidos a través de una relación. El objeto de colección de Eloquent extiende la [colección base](/docs/{{version}}/collections) de Laravel, por lo que hereda naturalmente docenas de métodos utilizados para trabajar de manera fluida con el array subyacente de modelos de Eloquent. ¡Asegúrate de revisar la documentación de colecciones de Laravel para aprender todo sobre estos métodos útiles!

Todas las colecciones también sirven como iteradores, lo que te permite recorrerlas como si fueran simples arrays de PHP:

    use App\Models\User;

    $users = User::where('active', 1)->get();

    foreach ($users as $user) {
        echo $user->name;
    }

Sin embargo, como se mencionó anteriormente, las colecciones son mucho más poderosas que los arrays y exponen una variedad de operaciones de map / reduce que pueden encadenarse utilizando una interfaz intuitiva. Por ejemplo, podemos eliminar todos los modelos inactivos y luego recopilar el nombre de cada usuario restante:

    $names = User::all()->reject(function (User $user) {
        return $user->active === false;
    })->map(function (User $user) {
        return $user->name;
    });

<a name="eloquent-collection-conversion"></a>
#### Conversión de Colección Eloquent

Mientras que la mayoría de los métodos de colección de Eloquent devuelven una nueva instancia de una colección de Eloquent, los métodos `collapse`, `flatten`, `flip`, `keys`, `pluck` y `zip` devuelven una instancia de [colección base](/docs/{{version}}/collections). Asimismo, si una operación `map` devuelve una colección que no contiene ningún modelo de Eloquent, se convertirá en una instancia de colección base.

<a name="available-methods"></a>
## Métodos Disponibles

Todas las colecciones de Eloquent extienden el objeto de [colección base de Laravel](/docs/{{version}}/collections#available-methods); por lo tanto, heredan todos los poderosos métodos proporcionados por la clase de colección base.

Además, la clase `Illuminate\Database\Eloquent\Collection` proporciona un superconjunto de métodos para ayudar a gestionar tus colecciones de modelos. La mayoría de los métodos devuelven instancias de `Illuminate\Database\Eloquent\Collection`; sin embargo, algunos métodos, como `modelKeys`, devuelven una instancia de `Illuminate\Support\Collection`.

<style>
    .collection-method-list > p {
        columns: 14.4em 1; -moz-columns: 14.4em 1; -webkit-columns: 14.4em 1;
    }

    .collection-method-list a {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .collection-method code {
        font-size: 14px;
    }

    .collection-method:not(.first-collection-method) {
        margin-top: 50px;
    }
</style>

<div class="collection-method-list" markdown="1">

[append](#method-append)
[contains](#method-contains)
[diff](#method-diff)
[except](#method-except)
[find](#method-find)
[fresh](#method-fresh)
[intersect](#method-intersect)
[load](#method-load)
[loadMissing](#method-loadMissing)
[modelKeys](#method-modelKeys)
[makeVisible](#method-makeVisible)
[makeHidden](#method-makeHidden)
[only](#method-only)
[setVisible](#method-setVisible)
[setHidden](#method-setHidden)
[toQuery](#method-toquery)
[unique](#method-unique)

</div>

<a name="method-append"></a>
#### `append($attributes)` {.collection-method .first-collection-method}

El método `append` puede ser utilizado para indicar que un atributo debe ser [agregado](/docs/{{version}}/eloquent-serialization#appending-values-to-json) para cada modelo en la colección. Este método acepta un array de atributos o un solo atributo:

    $users->append('team');

    $users->append(['team', 'is_admin']);

<a name="method-contains"></a>
#### `contains($key, $operator = null, $value = null)` {.collection-method}

El método `contains` puede ser utilizado para determinar si una instancia de modelo dada está contenida en la colección. Este método acepta una clave primaria o una instancia de modelo:

    $users->contains(1);

    $users->contains(User::find(1));

<a name="method-diff"></a>
#### `diff($items)` {.collection-method}

El método `diff` devuelve todos los modelos que no están presentes en la colección dada:

    use App\Models\User;

    $users = $users->diff(User::whereIn('id', [1, 2, 3])->get());

<a name="method-except"></a>
#### `except($keys)` {.collection-method}

El método `except` devuelve todos los modelos que no tienen las claves primarias dadas:

    $users = $users->except([1, 2, 3]);

<a name="method-find"></a>
#### `find($key)` {.collection-method}

El método `find` devuelve el modelo que tiene una clave primaria que coincide con la clave dada. Si `$key` es una instancia de modelo, `find` intentará devolver un modelo que coincida con la clave primaria. Si `$key` es un array de claves, `find` devolverá todos los modelos que tienen una clave primaria en el array dado:

    $users = User::all();

    $user = $users->find(1);

<a name="method-fresh"></a>
#### `fresh($with = [])` {.collection-method}

El método `fresh` recupera una nueva instancia de cada modelo en la colección desde la base de datos. Además, cualquier relación especificada será cargada de manera anticipada:

    $users = $users->fresh();

    $users = $users->fresh('comments');

<a name="method-intersect"></a>
#### `intersect($items)` {.collection-method}

El método `intersect` devuelve todos los modelos que también están presentes en la colección dada:

    use App\Models\User;

    $users = $users->intersect(User::whereIn('id', [1, 2, 3])->get());

<a name="method-load"></a>
#### `load($relations)` {.collection-method}

El método `load` carga de manera anticipada las relaciones dadas para todos los modelos en la colección:

    $users->load(['comments', 'posts']);

    $users->load('comments.author');

    $users->load(['comments', 'posts' => fn ($query) => $query->where('active', 1)]);

<a name="method-loadMissing"></a>
#### `loadMissing($relations)` {.collection-method}

El método `loadMissing` carga de manera anticipada las relaciones dadas para todos los modelos en la colección si las relaciones no están ya cargadas:

    $users->loadMissing(['comments', 'posts']);

    $users->loadMissing('comments.author');

    $users->loadMissing(['comments', 'posts' => fn ($query) => $query->where('active', 1)]);

<a name="method-modelKeys"></a>
#### `modelKeys()` {.collection-method}

El método `modelKeys` devuelve las claves primarias para todos los modelos en la colección:

    $users->modelKeys();

    // [1, 2, 3, 4, 5]

<a name="method-makeVisible"></a>
#### `makeVisible($attributes)` {.collection-method}

El método `makeVisible` [hace visibles los atributos](/docs/{{version}}/eloquent-serialization#hiding-attributes-from-json) que normalmente están "ocultos" en cada modelo de la colección:

    $users = $users->makeVisible(['address', 'phone_number']);

<a name="method-makeHidden"></a>
#### `makeHidden($attributes)` {.collection-method}

El método `makeHidden` [oculta atributos](/docs/{{version}}/eloquent-serialization#hiding-attributes-from-json) que normalmente están "visibles" en cada modelo de la colección:

    $users = $users->makeHidden(['address', 'phone_number']);

<a name="method-only"></a>
#### `only($keys)` {.collection-method}

El método `only` devuelve todos los modelos que tienen las claves primarias dadas:

    $users = $users->only([1, 2, 3]);

<a name="method-setVisible"></a>
#### `setVisible($attributes)` {.collection-method}

El método `setVisible` [sobrescribe temporalmente](/docs/{{version}}/eloquent-serialization#temporarily-modifying-attribute-visibility) todos los atributos visibles en cada modelo de la colección:

    $users = $users->setVisible(['id', 'name']);

<a name="method-setHidden"></a>
#### `setHidden($attributes)` {.collection-method}

El método `setHidden` [sobrescribe temporalmente](/docs/{{version}}/eloquent-serialization#temporarily-modifying-attribute-visibility) todos los atributos ocultos en cada modelo de la colección:

    $users = $users->setHidden(['email', 'password', 'remember_token']);

<a name="method-toquery"></a>
#### `toQuery()` {.collection-method}

El método `toQuery` devuelve una instancia de constructor de consultas de Eloquent que contiene una restricción `whereIn` sobre las claves primarias del modelo de la colección:

    use App\Models\User;

    $users = User::where('status', 'VIP')->get();

    $users->toQuery()->update([
        'status' => 'Administrator',
    ]);

<a name="method-unique"></a>
#### `unique($key = null, $strict = false)` {.collection-method}

El método `unique` devuelve todos los modelos únicos en la colección. Cualquier modelo con la misma clave primaria que otro modelo en la colección es eliminado:

    $users = $users->unique();

<a name="custom-collections"></a>
## Colecciones Personalizadas

Si deseas utilizar un objeto `Collection` personalizado al interactuar con un modelo dado, puedes definir un método `newCollection` en tu modelo:

    <?php

    namespace App\Models;

    use App\Support\UserCollection;
    use Illuminate\Database\Eloquent\Collection;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Crear una nueva instancia de Colección Eloquent.
         *
         * @param  array<int, \Illuminate\Database\Eloquent\Model>  $models
         * @return \Illuminate\Database\Eloquent\Collection<int, \Illuminate\Database\Eloquent\Model>
         */
        public function newCollection(array $models = []): Collection
        {
            return new UserCollection($models);
        }
    }

Una vez que hayas definido un método `newCollection`, recibirás una instancia de tu colección personalizada cada vez que Eloquent normalmente devolvería una instancia de `Illuminate\Database\Eloquent\Collection`. Si deseas utilizar una colección personalizada para cada modelo en tu aplicación, debes definir el método `newCollection` en una clase de modelo base que sea extendida por todos los modelos de tu aplicación.
