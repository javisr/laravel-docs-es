# Eloquent: Collections

- [Introducción](#introduction)
- [Métodos Disponibles](#available-methods)
- [Colecciones Personalizadas](#custom-collections)

<a name="introduction"></a>
## Introducción

Todos los métodos de Eloquent que devuelven más de un resultado de modelo devolverán instancias de la clase `Illuminate\Database\Eloquent\Collection`, incluyendo resultados recuperados a través del método `get` o accedidos a través de una relación. El objeto de colección Eloquent extiende la [colección base]( /docs/%7B%7Bversion%7D%7D/collections) de Laravel, por lo que hereda de forma natural docenas de métodos utilizados para trabajar de manera fluida con el array subyacente de modelos Eloquent. Asegúrate de revisar la documentación de colecciones de Laravel para aprender todo sobre estos métodos útiles.
Todas las colecciones también sirven como iteradores, lo que te permite recorrerlas como si fueran arrays PHP simples:


```php
use App\Models\User;

$users = User::where('active', 1)->get();

foreach ($users as $user) {
    echo $user->name;
}
```
Sin embargo, como se mencionó anteriormente, las colecciones son mucho más poderosas que los arrays y exponen una variedad de operaciones de map / reduce que se pueden encadenar utilizando una interfaz intuitiva. Por ejemplo, podemos eliminar todos los modelos inactivos y luego recopilar el primer nombre de cada usuario restante:


```php
$names = User::all()->reject(function (User $user) {
    return $user->active === false;
})->map(function (User $user) {
    return $user->name;
});
```

<a name="eloquent-collection-conversion"></a>
#### Conversión de Colección Eloquent

Mientras que la mayoría de los métodos de colección de Eloquent devuelven una nueva instancia de una colección de Eloquent, los métodos `collapse`, `flatten`, `flip`, `keys`, `pluck` y `zip` devuelven una instancia de una [colección base](/docs/%7B%7Bversion%7D%7D/collections). Del mismo modo, si una operación `map` devuelve una colección que no contiene ningún modelo de Eloquent, se convertirá en una instancia de colección base.

<a name="available-methods"></a>
## Métodos Disponibles

Todas las colecciones Eloquent extienden el objeto de colección base [Laravel](/docs/%7B%7Bversion%7D%7D/collections#available-methods); por lo tanto, heredan todos los poderosos métodos proporcionados por la clase de colección base.
Además, la clase `Illuminate\Database\Eloquent\Collection` ofrece un conjunto ampliado de métodos para ayudar con la gestión de tus colecciones de modelos. La mayoría de los métodos devuelven instancias de `Illuminate\Database\Eloquent\Collection`; sin embargo, algunos métodos, como `modelKeys`, devuelven una instancia de `Illuminate\Support\Collection`.
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

El método `append` se puede utilizar para indicar que un atributo debe ser [añadido](/docs/%7B%7Bversion%7D%7D/eloquent-serialization#appending-values-to-json) para cada modelo en la colección. Este método acepta un array de atributos o un solo atributo:


```php
$users->append('team');

$users->append(['team', 'is_admin']);
```

<a name="method-contains"></a>
#### `contains($key, $operator = null, $value = null)` {.collection-method}


El método `contains` se puede utilizar para determinar si una instancia de modelo dada está contenida en la colección. Este método acepta una clave primaria o una instancia de modelo:


```php
$users->contains(1);

$users->contains(User::find(1));
```

<a name="method-diff"></a>
#### `diff($items)` {.collection-method}


El método `diff` devuelve todos los modelos que no están presentes en la colección dada:


```php
use App\Models\User;

$users = $users->diff(User::whereIn('id', [1, 2, 3])->get());
```

<a name="method-except"></a>
#### `except($keys)` {.collection-method}


El método `except` devuelve todos los modelos que no tienen las claves primarias dadas:


```php
$users = $users->except([1, 2, 3]);
```

<a name="method-find"></a>
#### `find($key)` {.collection-method}


El método `find` devuelve el modelo que tiene una clave primaria que coincide con la clave dada. Si `$key` es una instancia de modelo, `find` intentará devolver un modelo que coincida con la clave primaria. Si `$key` es un array de claves, `find` devolverá todos los modelos que tienen una clave primaria en el array dado:


```php
$users = User::all();

$user = $users->find(1);
```

<a name="method-fresh"></a>
#### `fresh($with = [])` {.collection-method}


El método `fresh` recupera una instancia actualizada de cada modelo en la colección desde la base de datos. Además, se cargarán de forma anticipada las relaciones especificadas:


```php
$users = $users->fresh();

$users = $users->fresh('comments');
```

<a name="method-intersect"></a>
#### `intersect($items)` {.collection-method}


El método `intersect` devuelve todos los modelos que también están presentes en la colección dada:


```php
use App\Models\User;

$users = $users->intersect(User::whereIn('id', [1, 2, 3])->get());
```

<a name="method-load"></a>
#### `load($relations)` {.collection-method}


El método `load` carga de manera anticipada las relaciones dadas para todos los modelos en la colección:


```php
$users->load(['comments', 'posts']);

$users->load('comments.author');

$users->load(['comments', 'posts' => fn ($query) => $query->where('active', 1)]);
```

<a name="method-loadMissing"></a>
#### `loadMissing($relations)` {.collection-method}


El método `loadMissing` carga de forma anticipada las relaciones dadas para todos los modelos en la colección si las relaciones no están ya cargadas:


```php
$users->loadMissing(['comments', 'posts']);

$users->loadMissing('comments.author');

$users->loadMissing(['comments', 'posts' => fn ($query) => $query->where('active', 1)]);
```

<a name="method-modelKeys"></a>
#### `modelKeys()` {.collection-method}


El método `modelKeys` devuelve las claves primarias para todos los modelos en la colección:


```php
$users->modelKeys();

// [1, 2, 3, 4, 5]
```

<a name="method-makeVisible"></a>
#### `makeVisible($attributes)` {.collection-method}


El método `makeVisible` [hace que los atributos sean visibles](/docs/%7B%7Bversion%7D%7D/eloquent-serialization#hiding-attributes-from-json) que normalmente están "ocultos" en cada modelo de la colección:


```php
$users = $users->makeVisible(['address', 'phone_number']);
```

<a name="method-makeHidden"></a>
#### `makeHidden($attributes)` {.collection-method}


El método `makeHidden` [oculta atributos](/docs/%7B%7Bversion%7D%7D/eloquent-serialization#hiding-attributes-from-json) que son típicamente "visibles" en cada modelo de la colección:


```php
$users = $users->makeHidden(['address', 'phone_number']);
```

<a name="method-only"></a>
#### `only($keys)` {.collection-method}


El método `only` devuelve todos los modelos que tienen las claves primarias dadas:


```php
$users = $users->only([1, 2, 3]);
```

<a name="method-setVisible"></a>
#### `setVisible($attributes)` {.collection-method}


El método `setVisible` [sobrescribe temporalmente](/docs/%7B%7Bversion%7D%7D/eloquent-serialization#temporarily-modifying-attribute-visibility) todos los atributos visibles en cada modelo de la colección:


```php
$users = $users->setVisible(['id', 'name']);
```

<a name="method-setHidden"></a>
#### `setHidden($attributes)` {.collection-method}


El método `setHidden` [sobrescribe temporalmente](/docs/%7B%7Bversion%7D%7D/eloquent-serialization#temporarily-modifying-attribute-visibility) todos los atributos ocultos en cada modelo de la colección:


```php
$users = $users->setHidden(['email', 'password', 'remember_token']);
```

<a name="method-toquery"></a>
#### `toQuery()` {.collection-method}


El método `toQuery` devuelve una instancia del constructor de consultas Eloquent que contiene una restricción `whereIn` en las claves primarias del modelo de colección:


```php
use App\Models\User;

$users = User::where('status', 'VIP')->get();

$users->toQuery()->update([
    'status' => 'Administrator',
]);
```

<a name="method-unique"></a>
#### `unique($key = null, $strict = false)` {.collection-method}


El método `unique` devuelve todos los modelos únicos en la colección. Cualquier modelo con la misma clave primaria que otro modelo en la colección es eliminado:


```php
$users = $users->unique();
```

<a name="custom-collections"></a>
## Colecciones Personalizadas

Si deseas usar un objeto `Collection` personalizado al interactuar con un modelo dado, puedes definir un método `newCollection` en tu modelo:


```php
<?php

namespace App\Models;

use App\Support\UserCollection;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * Create a new Eloquent Collection instance.
     *
     * @param  array<int, \Illuminate\Database\Eloquent\Model>  $models
     * @return \Illuminate\Database\Eloquent\Collection<int, \Illuminate\Database\Eloquent\Model>
     */
    public function newCollection(array $models = []): Collection
    {
        return new UserCollection($models);
    }
}
```
Una vez que hayas definido un método `newCollection`, recibirás una instancia de tu colección personalizada cada vez que Eloquent normalmente devolvería una instancia de `Illuminate\Database\Eloquent\Collection`. Si te gustaría usar una colección personalizada para cada modelo en tu aplicación, debes definir el método `newCollection` en una clase de modelo base que sea extendida por todos los modelos de tu aplicación.