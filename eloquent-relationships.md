# Eloquent: Relaciones

- [Eloquent: Relaciones](#eloquent-relaciones)
  - [Introducción](#introducción)
  - [Definiendo Relaciones](#definiendo-relaciones)
    - [Uno a Uno](#uno-a-uno)
      - [Definiendo el Inverso de la Relación](#definiendo-el-inverso-de-la-relación)
    - [Uno a Muchos](#uno-a-muchos)
    - [Uno a Muchos (Inverso) / Pertenece a](#uno-a-muchos-inverso--pertenece-a)
      - [Modelos Predeterminados](#modelos-predeterminados)
      - [Consultando Relaciones Pertenece a](#consultando-relaciones-pertenece-a)
    - [Tiene Uno de Muchos](#tiene-uno-de-muchos)
      - [Convertir Relaciones "Muchas" a Relaciones "Una"](#convertir-relaciones-muchas-a-relaciones-una)
      - [Relaciones Avanzadas "Tiene Una de Muchas"](#relaciones-avanzadas-tiene-una-de-muchas)
    - [Tiene Una a Través](#tiene-una-a-través)
      - [Convenciones de Clave](#convenciones-de-clave)
    - [Tiene Muchas a Través](#tiene-muchas-a-través)
      - [Convenciones de Clave](#convenciones-de-clave-1)
  - [Relaciones Muchos a Muchos](#relaciones-muchos-a-muchos)
      - [Estructura de la Tabla](#estructura-de-la-tabla)
      - [Estructura del Modelo](#estructura-del-modelo)
      - [Definiendo la Inversa de la Relación](#definiendo-la-inversa-de-la-relación)
    - [Recuperando Columnas de la Tabla Intermedia](#recuperando-columnas-de-la-tabla-intermedia)
      - [Personalizando el Nombre del Atributo `pivot`](#personalizando-el-nombre-del-atributo-pivot)
    - [Filtrando Consultas a través de Columnas de la Tabla Intermedia](#filtrando-consultas-a-través-de-columnas-de-la-tabla-intermedia)
    - [Ordenando Consultas a través de Columnas de la Tabla Intermedia](#ordenando-consultas-a-través-de-columnas-de-la-tabla-intermedia)
    - [Definiendo Modelos de Tabla Intermedia Personalizados](#definiendo-modelos-de-tabla-intermedia-personalizados)
      - [Modelos Pivot Personalizados e IDs Autoincrementales](#modelos-pivot-personalizados-e-ids-autoincrementales)
  - [Relaciones Polimórficas](#relaciones-polimórficas)
    - [Uno a Uno (Polimórfico)](#uno-a-uno-polimórfico)
      - [Estructura de la Tabla](#estructura-de-la-tabla-1)
      - [Estructura del Modelo](#estructura-del-modelo-1)
      - [Recuperando la Relación](#recuperando-la-relación)
      - [Convenciones de Clave](#convenciones-de-clave-2)
    - [Uno a Muchos (Polimórfico)](#uno-a-muchos-polimórfico)
      - [Estructura de la Tabla](#estructura-de-la-tabla-2)
      - [Estructura del Modelo](#estructura-del-modelo-2)
      - [Recuperando la Relación](#recuperando-la-relación-1)
    - [Uno de Muchos (Polimórfico)](#uno-de-muchos-polimórfico)
    - [Muchos a Muchos (Polimórfico)](#muchos-a-muchos-polimórfico)
      - [Estructura de la Tabla](#estructura-de-la-tabla-3)
      - [Estructura del Modelo](#estructura-del-modelo-3)
      - [Definiendo la Inversa de la Relación](#definiendo-la-inversa-de-la-relación-1)
      - [Recuperando la Relación](#recuperando-la-relación-2)
    - [Tipos Polimórficos Personalizados](#tipos-polimórficos-personalizados)
    - [Relaciones Dinámicas](#relaciones-dinámicas)
  - [Consultando Relaciones](#consultando-relaciones)
      - [Encadenando Cláusulas `orWhere` Después de Relaciones](#encadenando-cláusulas-orwhere-después-de-relaciones)
    - [Métodos de Relación vs. Propiedades Dinámicas](#métodos-de-relación-vs-propiedades-dinámicas)
    - [Consultando la Existencia de Relaciones](#consultando-la-existencia-de-relaciones)
      - [Consultas de Existencia de Relaciones en Línea](#consultas-de-existencia-de-relaciones-en-línea)
    - [Consultando la Ausencia de Relaciones](#consultando-la-ausencia-de-relaciones)
    - [Consultando Relaciones Morph To](#consultando-relaciones-morph-to)
      - [Consultando Todos los Modelos Relacionados](#consultando-todos-los-modelos-relacionados)
  - [Agregando Modelos Relacionados](#agregando-modelos-relacionados)
    - [Contando Modelos Relacionados](#contando-modelos-relacionados)
      - [Carga de Conteo Diferido](#carga-de-conteo-diferido)
      - [Conteo de Relaciones y Declaraciones de Selección Personalizadas](#conteo-de-relaciones-y-declaraciones-de-selección-personalizadas)
    - [Otras Funciones Agregadas](#otras-funciones-agregadas)
    - [Conteo de Modelos Relacionados en Relaciones Morph To](#conteo-de-modelos-relacionados-en-relaciones-morph-to)
      - [Carga de Conteo Diferido](#carga-de-conteo-diferido-1)
  - [Carga Ansiosa](#carga-ansiosa)
      - [Carga Ansiosa de Múltiples Relaciones](#carga-ansiosa-de-múltiples-relaciones)
      - [Carga Ansiosa Anidada](#carga-ansiosa-anidada)
      - [Carga Ansiosa Anidada de Relaciones `morphTo`](#carga-ansiosa-anidada-de-relaciones-morphto)
      - [Carga Ansiosa de Columnas Específicas](#carga-ansiosa-de-columnas-específicas)
      - [Carga Ansiosa por Defecto](#carga-ansiosa-por-defecto)
    - [Restringiendo Cargas Ansiosas](#restringiendo-cargas-ansiosas)
      - [Restringiendo la Carga Ansiosa de Relaciones `morphTo`](#restringiendo-la-carga-ansiosa-de-relaciones-morphto)
      - [Restringiendo Cargas Ansiosas con Existencia de Relaciones](#restringiendo-cargas-ansiosas-con-existencia-de-relaciones)
    - [Carga Ansiosa Perezosa](#carga-ansiosa-perezosa)
      - [Carga Ansiosa Perezosa Anidada y `morphTo`](#carga-ansiosa-perezosa-anidada-y-morphto)
    - [Previniendo la Carga Perezosa](#previniendo-la-carga-perezosa)
  - [Insertando y Actualizando Modelos Relacionados](#insertando-y-actualizando-modelos-relacionados)
    - [El Método `save`](#el-método-save)
      - [Guardando Recursivamente Modelos y Relaciones](#guardando-recursivamente-modelos-y-relaciones)
    - [El Método `create`](#el-método-create)
    - [Relaciones Pertenecen a](#relaciones-pertenecen-a)
    - [Relaciones Muchos a Muchos](#relaciones-muchos-a-muchos-1)
      - [Adjuntando / Desadjuntando](#adjuntando--desadjuntando)
      - [Sincronizando Asociaciones](#sincronizando-asociaciones)
      - [Alternando Asociaciones](#alternando-asociaciones)
      - [Actualizando un Registro en la Tabla Intermedia](#actualizando-un-registro-en-la-tabla-intermedia)
  - [Actualizando Timestamps del Padre](#actualizando-timestamps-del-padre)

<a name="introduction"></a>
## Introducción

Las tablas de la base de datos a menudo están relacionadas entre sí. Por ejemplo, una publicación de blog puede tener muchos comentarios o un pedido podría estar relacionado con el usuario que lo realizó. Eloquent facilita la gestión y el trabajo con estas relaciones, y admite una variedad de relaciones comunes:

<div class="content-list" markdown="1">

- [Uno a Uno](#one-to-one)
- [Uno a Muchos](#one-to-many)
- [Muchos a Muchos](#many-to-many)
- [Tiene Uno a Través](#has-one-through)
- [Tiene Muchos a Través](#has-many-through)
- [Uno a Uno (Polimórfico)](#one-to-one-polymorphic-relations)
- [Uno a Muchos (Polimórfico)](#one-to-many-polymorphic-relations)
- [Muchos a Muchos (Polimórfico)](#many-to-many-polymorphic-relations)

</div>

<a name="defining-relationships"></a>
## Definiendo Relaciones

Las relaciones de Eloquent se definen como métodos en tus clases de modelo de Eloquent. Dado que las relaciones también sirven como potentes [constructores de consultas](/docs/{{version}}/queries), definir relaciones como métodos proporciona potentes capacidades de encadenamiento de métodos y consultas. Por ejemplo, podemos encadenar restricciones de consulta adicionales en esta relación `posts`:

    $user->posts()->where('active', 1)->get();

Pero, antes de profundizar demasiado en el uso de relaciones, aprendamos cómo definir cada tipo de relación admitida por Eloquent.

<a name="one-to-one"></a>
### Uno a Uno

Una relación uno a uno es un tipo muy básico de relación de base de datos. Por ejemplo, un modelo `User` podría estar asociado con un modelo `Phone`. Para definir esta relación, colocaremos un método `phone` en el modelo `User`. El método `phone` debe llamar al método `hasOne` y devolver su resultado. El método `hasOne` está disponible para tu modelo a través de la clase base `Illuminate\Database\Eloquent\Model`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\HasOne;

    class User extends Model
    {
        /**
         * Obtener el teléfono asociado con el usuario.
         */
        public function phone(): HasOne
        {
            return $this->hasOne(Phone::class);
        }
    }

El primer argumento pasado al método `hasOne` es el nombre de la clase del modelo relacionado. Una vez que la relación está definida, podemos recuperar el registro relacionado utilizando las propiedades dinámicas de Eloquent. Las propiedades dinámicas te permiten acceder a los métodos de relación como si fueran propiedades definidas en el modelo:

    $phone = User::find(1)->phone;

Eloquent determina la clave foránea de la relación en función del nombre del modelo padre. En este caso, se asume automáticamente que el modelo `Phone` tiene una clave foránea `user_id`. Si deseas anular esta convención, puedes pasar un segundo argumento al método `hasOne`:

    return $this->hasOne(Phone::class, 'foreign_key');

Además, Eloquent asume que la clave foránea debe tener un valor que coincida con la columna de clave primaria del padre. En otras palabras, Eloquent buscará el valor de la columna `id` del usuario en la columna `user_id` del registro `Phone`. Si deseas que la relación use un valor de clave primaria diferente a `id` o a la propiedad `$primaryKey` de tu modelo, puedes pasar un tercer argumento al método `hasOne`:

    return $this->hasOne(Phone::class, 'foreign_key', 'local_key');

<a name="one-to-one-defining-the-inverse-of-the-relationship"></a>
#### Definiendo el Inverso de la Relación

Así que podemos acceder al modelo `Phone` desde nuestro modelo `User`. A continuación, definamos una relación en el modelo `Phone` que nos permita acceder al usuario que posee el teléfono. Podemos definir el inverso de una relación `hasOne` utilizando el método `belongsTo`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsTo;

    class Phone extends Model
    {
        /**
         * Obtener el usuario que posee el teléfono.
         */
        public function user(): BelongsTo
        {
            return $this->belongsTo(User::class);
        }
    }

Al invocar el método `user`, Eloquent intentará encontrar un modelo `User` que tenga un `id` que coincida con la columna `user_id` en el modelo `Phone`.

Eloquent determina el nombre de la clave foránea examinando el nombre del método de relación y añadiendo `_id` al final del nombre del método. Así que, en este caso, Eloquent asume que el modelo `Phone` tiene una columna `user_id`. Sin embargo, si la clave foránea en el modelo `Phone` no es `user_id`, puedes pasar un nombre de clave personalizado como segundo argumento al método `belongsTo`:

    /**
     * Obtener el usuario que posee el teléfono.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'foreign_key');
    }

Si el modelo padre no usa `id` como su clave primaria, o deseas encontrar el modelo asociado utilizando una columna diferente, puedes pasar un tercer argumento al método `belongsTo` especificando la clave personalizada de la tabla del padre:

    /**
     * Obtener el usuario que posee el teléfono.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'foreign_key', 'owner_key');
    }

<a name="one-to-many"></a>
### Uno a Muchos

Una relación uno a muchos se utiliza para definir relaciones donde un solo modelo es el padre de uno o más modelos hijos. Por ejemplo, una publicación de blog puede tener un número infinito de comentarios. Al igual que todas las demás relaciones de Eloquent, las relaciones uno a muchos se definen definiendo un método en tu modelo de Eloquent:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\HasMany;

    class Post extends Model
    {
        /**
         * Obtener los comentarios para la publicación del blog.
         */
        public function comments(): HasMany
        {
            return $this->hasMany(Comment::class);
        }
    }

Recuerda, Eloquent determinará automáticamente la columna de clave foránea adecuada para el modelo `Comment`. Por convención, Eloquent tomará el nombre del modelo padre en "snake case" y le añadirá `_id`. Así que, en este ejemplo, Eloquent asumirá que la columna de clave foránea en el modelo `Comment` es `post_id`.

Una vez que se ha definido el método de relación, podemos acceder a la [colección](/docs/{{version}}/eloquent-collections) de comentarios relacionados accediendo a la propiedad `comments`. Recuerda, dado que Eloquent proporciona "propiedades de relación dinámicas", podemos acceder a los métodos de relación como si estuvieran definidos como propiedades en el modelo:

    use App\Models\Post;

    $comments = Post::find(1)->comments;

    foreach ($comments as $comment) {
        // ...
    }

Dado que todas las relaciones también sirven como constructores de consultas, puedes agregar más restricciones a la consulta de relación llamando al método `comments` y continuando a encadenar condiciones a la consulta:

    $comment = Post::find(1)->comments()
                        ->where('title', 'foo')
                        ->first();

Al igual que el método `hasOne`, también puedes anular las claves foránea y local pasando argumentos adicionales al método `hasMany`:

    return $this->hasMany(Comment::class, 'foreign_key');

    return $this->hasMany(Comment::class, 'foreign_key', 'local_key');

<a name="one-to-many-inverse"></a>
### Uno a Muchos (Inverso) / Pertenece a

Ahora que podemos acceder a todos los comentarios de una publicación, definamos una relación para permitir que un comentario acceda a su publicación padre. Para definir el inverso de una relación `hasMany`, define un método de relación en el modelo hijo que llame al método `belongsTo`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsTo;

    class Comment extends Model
    {
        /**
         * Obtener la publicación que posee el comentario.
         */
        public function post(): BelongsTo
        {
            return $this->belongsTo(Post::class);
        }
    }

Una vez que se ha definido la relación, podemos recuperar la publicación padre de un comentario accediendo a la propiedad "dinámica" de relación `post`:

    use App\Models\Comment;

    $comment = Comment::find(1);

    return $comment->post->title;

En el ejemplo anterior, Eloquent intentará encontrar un modelo `Post` que tenga un `id` que coincida con la columna `post_id` en el modelo `Comment`.

Eloquent determina el nombre de la clave foránea predeterminada examinando el nombre del método de relación y añadiendo un `_` seguido del nombre de la columna de clave primaria del modelo padre. Así que, en este ejemplo, Eloquent asumirá que la clave foránea del modelo `Post` en la tabla `comments` es `post_id`.

Sin embargo, si la clave foránea para tu relación no sigue estas convenciones, puedes pasar un nombre de clave foránea personalizado como segundo argumento al método `belongsTo`:

    /**
     * Obtener la publicación que posee el comentario.
     */
    public function post(): BelongsTo
    {
        return $this->belongsTo(Post::class, 'foreign_key');
    }

Si tu modelo padre no usa `id` como su clave primaria, o deseas encontrar el modelo asociado utilizando una columna diferente, puedes pasar un tercer argumento al método `belongsTo` especificando la clave personalizada de tu tabla padre:

    /**
     * Obtener la publicación que posee el comentario.
     */
    public function post(): BelongsTo
    {
        return $this->belongsTo(Post::class, 'foreign_key', 'owner_key');
    }

<a name="default-models"></a>
#### Modelos Predeterminados

Las relaciones `belongsTo`, `hasOne`, `hasOneThrough` y `morphOne` te permiten definir un modelo predeterminado que se devolverá si la relación dada es `null`. Este patrón a menudo se denomina [patrón de objeto nulo](https://en.wikipedia.org/wiki/Null_Object_pattern) y puede ayudar a eliminar verificaciones condicionales en tu código. En el siguiente ejemplo, la relación `user` devolverá un modelo vacío `App\Models\User` si no hay ningún usuario adjunto al modelo `Post`:

    /**
     * Obtener el autor de la publicación.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class)->withDefault();
    }

Para poblar el modelo predeterminado con atributos, puedes pasar un array o una función anónima al método `withDefault`:

    /**
     * Obtener el autor de la publicación.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class)->withDefault([
            'name' => 'Autor Invitado',
        ]);
    }

    /**
     * Obtener el autor de la publicación.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class)->withDefault(function (User $user, Post $post) {
            $user->name = 'Autor Invitado';
        });
    }

<a name="querying-belongs-to-relationships"></a>
#### Consultando Relaciones Pertenece a

Al consultar los hijos de una relación "pertenece a", puedes construir manualmente la cláusula `where` para recuperar los modelos Eloquent correspondientes:

    use App\Models\Post;

    $posts = Post::where('user_id', $user->id)->get();

Sin embargo, puede que encuentres más conveniente usar el método `whereBelongsTo`, que determinará automáticamente la relación y la clave foránea adecuadas para el modelo dado:

    $posts = Post::whereBelongsTo($user)->get();

También puedes proporcionar una [colección](/docs/{{version}}/eloquent-collections) al método `whereBelongsTo`. Al hacerlo, Laravel recuperará modelos que pertenecen a cualquiera de los modelos padre dentro de la colección:

    $users = User::where('vip', true)->get();

    $posts = Post::whereBelongsTo($users)->get();

Por defecto, Laravel determinará la relación asociada con el modelo dado en función del nombre de la clase del modelo; sin embargo, puedes especificar el nombre de la relación manualmente proporcionándolo como segundo argumento al método `whereBelongsTo`:

    $posts = Post::whereBelongsTo($user, 'author')->get();

<a name="has-one-of-many"></a>
### Tiene Uno de Muchos

A veces un modelo puede tener muchos modelos relacionados, pero deseas recuperar fácilmente el modelo relacionado "más reciente" o "más antiguo" de la relación. Por ejemplo, un modelo `User` puede estar relacionado con muchos modelos `Order`, pero deseas definir una forma conveniente de interactuar con el pedido más reciente que el usuario ha realizado. Puedes lograr esto utilizando el tipo de relación `hasOne` combinado con los métodos `ofMany`:

```php
/**
 * Get the user's most recent order.
 */
public function latestOrder(): HasOne
{
    return $this->hasOne(Order::class)->latestOfMany();
}
```

Del mismo modo, puedes definir un método para recuperar el modelo relacionado "más antiguo", o primero, de una relación:

```php
/**
 * Get the user's oldest order.
 */
public function oldestOrder(): HasOne
{
    return $this->hasOne(Order::class)->oldestOfMany();
}
```

Por defecto, los métodos `latestOfMany` y `oldestOfMany` recuperarán el modelo relacionado más reciente o más antiguo en función de la clave primaria del modelo, que debe ser ordenable. Sin embargo, a veces puedes desear recuperar un solo modelo de una relación más grande utilizando un criterio de ordenación diferente.

Por ejemplo, utilizando el método `ofMany`, puedes recuperar el pedido más caro del usuario. El método `ofMany` acepta la columna ordenable como su primer argumento y qué función agregada (`min` o `max`) aplicar al consultar el modelo relacionado:

```php
/**
 * Get the user's largest order.
 */
public function largestOrder(): HasOne
{
    return $this->hasOne(Order::class)->ofMany('price', 'max');
}
```

> [!WARNING]  
> Debido a que PostgreSQL no admite la ejecución de la función `MAX` contra columnas UUID, actualmente no es posible utilizar relaciones de uno a muchos en combinación con columnas UUID de PostgreSQL.

<a name="converting-many-relationships-to-has-one-relationships"></a>
#### Convertir Relaciones "Muchas" a Relaciones "Una"

A menudo, al recuperar un solo modelo utilizando los métodos `latestOfMany`, `oldestOfMany` o `ofMany`, ya tienes una relación "tiene muchas" definida para el mismo modelo. Para mayor comodidad, Laravel te permite convertir fácilmente esta relación en una relación "tiene una" invocando el método `one` en la relación:

```php
/**
 * Get the user's orders.
 */
public function orders(): HasMany
{
    return $this->hasMany(Order::class);
}

/**
 * Get the user's largest order.
 */
public function largestOrder(): HasOne
{
    return $this->orders()->one()->ofMany('price', 'max');
}
```

<a name="advanced-has-one-of-many-relationships"></a>
#### Relaciones Avanzadas "Tiene Una de Muchas"

Es posible construir relaciones "tiene una de muchas" más avanzadas. Por ejemplo, un modelo `Product` puede tener muchos modelos `Price` asociados que se mantienen en el sistema incluso después de que se publique un nuevo precio. Además, los nuevos datos de precios para el producto pueden publicarse con anticipación para que entren en vigor en una fecha futura a través de una columna `published_at`.

Entonces, en resumen, necesitamos recuperar el último precio publicado donde la fecha de publicación no esté en el futuro. Además, si dos precios tienen la misma fecha de publicación, preferiremos el precio con el mayor ID. Para lograr esto, debemos pasar un array al método `ofMany` que contenga las columnas ordenables que determinan el último precio. Además, se proporcionará una función anónima como segundo argumento al método `ofMany`. Esta función anónima será responsable de agregar restricciones adicionales de fecha de publicación a la consulta de la relación:

```php
/**
 * Get the current pricing for the product.
 */
public function currentPricing(): HasOne
{
    return $this->hasOne(Price::class)->ofMany([
        'published_at' => 'max',
        'id' => 'max',
    ], function (Builder $query) {
        $query->where('published_at', '<', now());
    });
}
```

<a name="has-one-through"></a>
### Tiene Una a Través

La relación "tiene una a través" define una relación uno a uno con otro modelo. Sin embargo, esta relación indica que el modelo que declara puede coincidir con una instancia de otro modelo al proceder _a través_ de un tercer modelo.

Por ejemplo, en una aplicación de taller de reparación de vehículos, cada modelo `Mechanic` puede estar asociado con un modelo `Car`, y cada modelo `Car` puede estar asociado con un modelo `Owner`. Mientras que el mecánico y el propietario no tienen una relación directa dentro de la base de datos, el mecánico puede acceder al propietario _a través_ del modelo `Car`. Veamos las tablas necesarias para definir esta relación:

    mechanics
        id - integer
        name - string

    cars
        id - integer
        model - string
        mechanic_id - integer

    owners
        id - integer
        name - string
        car_id - integer

Ahora que hemos examinado la estructura de la tabla para la relación, definamos la relación en el modelo `Mechanic`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\HasOneThrough;

    class Mechanic extends Model
    {
        /**
         * Obtener el propietario del coche.
         */
        public function carOwner(): HasOneThrough
        {
            return $this->hasOneThrough(Owner::class, Car::class);
        }
    }

El primer argumento pasado al método `hasOneThrough` es el nombre del modelo final al que deseamos acceder, mientras que el segundo argumento es el nombre del modelo intermedio.

O, si las relaciones relevantes ya se han definido en todos los modelos involucrados en la relación, puedes definir de manera fluida una relación "tiene una a través" invocando el método `through` y suministrando los nombres de esas relaciones. Por ejemplo, si el modelo `Mechanic` tiene una relación `cars` y el modelo `Car` tiene una relación `owner`, puedes definir una relación "tiene una a través" que conecte el mecánico y el propietario así:

```php
// String based syntax...
return $this->through('cars')->has('owner');

// Dynamic syntax...
return $this->throughCars()->hasOwner();
```

<a name="has-one-through-key-conventions"></a>
#### Convenciones de Clave

Se utilizarán las convenciones típicas de claves foráneas de Eloquent al realizar las consultas de la relación. Si deseas personalizar las claves de la relación, puedes pasarlas como el tercer y cuarto argumento al método `hasOneThrough`. El tercer argumento es el nombre de la clave foránea en el modelo intermedio. El cuarto argumento es el nombre de la clave foránea en el modelo final. El quinto argumento es la clave local, mientras que el sexto argumento es la clave local del modelo intermedio:

    class Mechanic extends Model
    {
        /**
         * Obtener el propietario del coche.
         */
        public function carOwner(): HasOneThrough
        {
            return $this->hasOneThrough(
                Owner::class,
                Car::class,
                'mechanic_id', // Clave foránea en la tabla cars...
                'car_id', // Clave foránea en la tabla owners...
                'id', // Clave local en la tabla mechanics...
                'id' // Clave local en la tabla cars...
            );
        }
    }

O, como se discutió anteriormente, si las relaciones relevantes ya se han definido en todos los modelos involucrados en la relación, puedes definir de manera fluida una relación "tiene una a través" invocando el método `through` y suministrando los nombres de esas relaciones. Este enfoque ofrece la ventaja de reutilizar las convenciones de clave ya definidas en las relaciones existentes:

```php
// String based syntax...
return $this->through('cars')->has('owner');

// Dynamic syntax...
return $this->throughCars()->hasOwner();
```

<a name="has-many-through"></a>
### Tiene Muchas a Través

La relación "tiene muchas a través" proporciona una forma conveniente de acceder a relaciones distantes a través de una relación intermedia. Por ejemplo, supongamos que estamos construyendo una plataforma de implementación como [Laravel Vapor](https://vapor.laravel.com). Un modelo `Project` podría acceder a muchos modelos `Deployment` a través de un modelo intermedio `Environment`. Usando este ejemplo, podrías reunir fácilmente todas las implementaciones para un proyecto dado. Veamos las tablas requeridas para definir esta relación:

    projects
        id - integer
        name - string

    environments
        id - integer
        project_id - integer
        name - string

    deployments
        id - integer
        environment_id - integer
        commit_hash - string

Ahora que hemos examinado la estructura de la tabla para la relación, definamos la relación en el modelo `Project`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\HasManyThrough;

    class Project extends Model
    {
        /**
         * Obtener todas las implementaciones para el proyecto.
         */
        public function deployments(): HasManyThrough
        {
            return $this->hasManyThrough(Deployment::class, Environment::class);
        }
    }

El primer argumento pasado al método `hasManyThrough` es el nombre del modelo final al que deseamos acceder, mientras que el segundo argumento es el nombre del modelo intermedio.

O, si las relaciones relevantes ya se han definido en todos los modelos involucrados en la relación, puedes definir de manera fluida una relación "tiene muchas a través" invocando el método `through` y suministrando los nombres de esas relaciones. Por ejemplo, si el modelo `Project` tiene una relación `environments` y el modelo `Environment` tiene una relación `deployments`, puedes definir una relación "tiene muchas a través" que conecte el proyecto y las implementaciones así:

```php
// String based syntax...
return $this->through('environments')->has('deployments');

// Dynamic syntax...
return $this->throughEnvironments()->hasDeployments();
```

Aunque la tabla del modelo `Deployment` no contiene una columna `project_id`, la relación `hasManyThrough` proporciona acceso a las implementaciones de un proyecto a través de `$project->deployments`. Para recuperar estos modelos, Eloquent inspecciona la columna `project_id` en la tabla del modelo intermedio `Environment`. Después de encontrar los IDs de entorno relevantes, se utilizan para consultar la tabla del modelo `Deployment`.

<a name="has-many-through-key-conventions"></a>
#### Convenciones de Clave

Se utilizarán las convenciones típicas de claves foráneas de Eloquent al realizar las consultas de la relación. Si deseas personalizar las claves de la relación, puedes pasarlas como el tercer y cuarto argumento al método `hasManyThrough`. El tercer argumento es el nombre de la clave foránea en el modelo intermedio. El cuarto argumento es el nombre de la clave foránea en el modelo final. El quinto argumento es la clave local, mientras que el sexto argumento es la clave local del modelo intermedio:

    class Project extends Model
    {
        public function deployments(): HasManyThrough
        {
            return $this->hasManyThrough(
                Deployment::class,
                Environment::class,
                'project_id', // Clave foránea en la tabla environments...
                'environment_id', // Clave foránea en la tabla deployments...
                'id', // Clave local en la tabla projects...
                'id' // Clave local en la tabla environments...
            );
        }
    }

O, como se discutió anteriormente, si las relaciones relevantes ya se han definido en todos los modelos involucrados en la relación, puedes definir de manera fluida una relación "tiene muchas a través" invocando el método `through` y suministrando los nombres de esas relaciones. Este enfoque ofrece la ventaja de reutilizar las convenciones de clave ya definidas en las relaciones existentes:

```php
// String based syntax...
return $this->through('environments')->has('deployments');

// Dynamic syntax...
return $this->throughEnvironments()->hasDeployments();
```

<a name="many-to-many"></a>
## Relaciones Muchos a Muchos

Las relaciones muchos a muchos son ligeramente más complicadas que las relaciones `hasOne` y `hasMany`. Un ejemplo de una relación muchos a muchos es un usuario que tiene muchos roles y esos roles también son compartidos por otros usuarios en la aplicación. Por ejemplo, un usuario puede ser asignado al rol de "Autor" y "Editor"; sin embargo, esos roles también pueden ser asignados a otros usuarios. Así, un usuario tiene muchos roles y un rol tiene muchos usuarios.

<a name="many-to-many-table-structure"></a>
#### Estructura de la Tabla

Para definir esta relación, se necesitan tres tablas de base de datos: `users`, `roles` y `role_user`. La tabla `role_user` se deriva del orden alfabético de los nombres de los modelos relacionados y contiene columnas `user_id` y `role_id`. Esta tabla se utiliza como una tabla intermedia que vincula a los usuarios y roles.

Recuerda, dado que un rol puede pertenecer a muchos usuarios, no podemos simplemente colocar una columna `user_id` en la tabla `roles`. Esto significaría que un rol solo podría pertenecer a un solo usuario. Para proporcionar soporte para que los roles sean asignados a múltiples usuarios, se necesita la tabla `role_user`. Podemos resumir la estructura de la tabla de la relación así:

    users
        id - integer
        name - string

    roles
        id - integer
        name - string

    role_user
        user_id - integer
        role_id - integer

<a name="many-to-many-model-structure"></a>
#### Estructura del Modelo

Las relaciones muchos a muchos se definen escribiendo un método que devuelve el resultado del método `belongsToMany`. El método `belongsToMany` es proporcionado por la clase base `Illuminate\Database\Eloquent\Model` que es utilizada por todos los modelos Eloquent de tu aplicación. Por ejemplo, definamos un método `roles` en nuestro modelo `User`. El primer argumento pasado a este método es el nombre de la clase del modelo relacionado:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsToMany;

    class User extends Model
    {
        /**
         * Los roles que pertenecen al usuario.
         */
        public function roles(): BelongsToMany
        {
            return $this->belongsToMany(Role::class);
        }
    }

Una vez que la relación está definida, puedes acceder a los roles del usuario utilizando la propiedad dinámica de relación `roles`:

    use App\Models\User;

    $user = User::find(1);

    foreach ($user->roles as $role) {
        // ...
    }

Dado que todas las relaciones también sirven como constructores de consultas, puedes agregar más restricciones a la consulta de la relación llamando al método `roles` y continuando a encadenar condiciones en la consulta:

    $roles = User::find(1)->roles()->orderBy('name')->get();

Para determinar el nombre de la tabla de la tabla intermedia de la relación, Eloquent unirá los dos nombres de modelos relacionados en orden alfabético. Sin embargo, eres libre de anular esta convención. Puedes hacerlo pasando un segundo argumento al método `belongsToMany`:

    return $this->belongsToMany(Role::class, 'role_user');

Además de personalizar el nombre de la tabla intermedia, también puedes personalizar los nombres de las columnas de las claves en la tabla pasando argumentos adicionales al método `belongsToMany`. El tercer argumento es el nombre de la clave foránea del modelo en el que estás definiendo la relación, mientras que el cuarto argumento es el nombre de la clave foránea del modelo al que te estás uniendo:

    return $this->belongsToMany(Role::class, 'role_user', 'user_id', 'role_id');

<a name="many-to-many-defining-the-inverse-of-the-relationship"></a>
#### Definiendo la Inversa de la Relación

Para definir la "inversa" de una relación muchos a muchos, debes definir un método en el modelo relacionado que también devuelva el resultado del método `belongsToMany`. Para completar nuestro ejemplo de usuario / rol, definamos el método `users` en el modelo `Role`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsToMany;

    class Role extends Model
    {
        /**
         * Los usuarios que pertenecen al rol.
         */
        public function users(): BelongsToMany
        {
            return $this->belongsToMany(User::class);
        }
    }

Como puedes ver, la relación se define exactamente igual que su contraparte en el modelo `User`, con la excepción de hacer referencia al modelo `App\Models\User`. Dado que estamos reutilizando el método `belongsToMany`, todas las opciones habituales de personalización de tablas y claves están disponibles al definir la "inversa" de las relaciones muchos a muchos.

<a name="retrieving-intermediate-table-columns"></a>
### Recuperando Columnas de la Tabla Intermedia

Como ya has aprendido, trabajar con relaciones muchos a muchos requiere la presencia de una tabla intermedia. Eloquent proporciona algunas formas muy útiles de interactuar con esta tabla. Por ejemplo, supongamos que nuestro modelo `User` tiene muchos modelos `Role` a los que está relacionado. Después de acceder a esta relación, podemos acceder a la tabla intermedia utilizando el atributo `pivot` en los modelos:

    use App\Models\User;

    $user = User::find(1);

    foreach ($user->roles as $role) {
        echo $role->pivot->created_at;
    }

Ten en cuenta que cada modelo `Role` que recuperamos se asigna automáticamente un atributo `pivot`. Este atributo contiene un modelo que representa la tabla intermedia.

Por defecto, solo las claves del modelo estarán presentes en el modelo `pivot`. Si tu tabla intermedia contiene atributos adicionales, debes especificarlos al definir la relación:

    return $this->belongsToMany(Role::class)->withPivot('active', 'created_by');

Si deseas que tu tabla intermedia tenga marcas de tiempo `created_at` y `updated_at` que sean mantenidas automáticamente por Eloquent, llama al método `withTimestamps` al definir la relación:

    return $this->belongsToMany(Role::class)->withTimestamps();

> [!WARNING]  
> Las tablas intermedias que utilizan las marcas de tiempo mantenidas automáticamente por Eloquent deben tener tanto columnas de marca de tiempo `created_at` como `updated_at`.

<a name="customizing-the-pivot-attribute-name"></a>
#### Personalizando el Nombre del Atributo `pivot`

Como se mencionó anteriormente, los atributos de la tabla intermedia pueden ser accedidos en los modelos a través del atributo `pivot`. Sin embargo, tienes la libertad de personalizar el nombre de este atributo para reflejar mejor su propósito dentro de tu aplicación.

Por ejemplo, si tu aplicación contiene usuarios que pueden suscribirse a podcasts, probablemente tengas una relación de muchos a muchos entre usuarios y podcasts. Si este es el caso, es posible que desees renombrar el atributo de tu tabla intermedia a `subscription` en lugar de `pivot`. Esto se puede hacer utilizando el método `as` al definir la relación:

    return $this->belongsToMany(Podcast::class)
                    ->as('subscription')
                    ->withTimestamps();

Una vez que se ha especificado el atributo de la tabla intermedia personalizado, puedes acceder a los datos de la tabla intermedia utilizando el nombre personalizado:

    $users = User::with('podcasts')->get();

    foreach ($users->flatMap->podcasts as $podcast) {
        echo $podcast->subscription->created_at;
    }

<a name="filtering-queries-via-intermediate-table-columns"></a>
### Filtrando Consultas a través de Columnas de la Tabla Intermedia

También puedes filtrar los resultados devueltos por las consultas de relación `belongsToMany` utilizando los métodos `wherePivot`, `wherePivotIn`, `wherePivotNotIn`, `wherePivotBetween`, `wherePivotNotBetween`, `wherePivotNull` y `wherePivotNotNull` al definir la relación:

    return $this->belongsToMany(Role::class)
                    ->wherePivot('approved', 1);

    return $this->belongsToMany(Role::class)
                    ->wherePivotIn('priority', [1, 2]);

    return $this->belongsToMany(Role::class)
                    ->wherePivotNotIn('priority', [1, 2]);

    return $this->belongsToMany(Podcast::class)
                    ->as('subscriptions')
                    ->wherePivotBetween('created_at', ['2020-01-01 00:00:00', '2020-12-31 00:00:00']);

    return $this->belongsToMany(Podcast::class)
                    ->as('subscriptions')
                    ->wherePivotNotBetween('created_at', ['2020-01-01 00:00:00', '2020-12-31 00:00:00']);

    return $this->belongsToMany(Podcast::class)
                    ->as('subscriptions')
                    ->wherePivotNull('expired_at');

    return $this->belongsToMany(Podcast::class)
                    ->as('subscriptions')
                    ->wherePivotNotNull('expired_at');

<a name="ordering-queries-via-intermediate-table-columns"></a>
### Ordenando Consultas a través de Columnas de la Tabla Intermedia

Puedes ordenar los resultados devueltos por las consultas de relación `belongsToMany` utilizando el método `orderByPivot`. En el siguiente ejemplo, recuperaremos todas las insignias más recientes para el usuario:

    return $this->belongsToMany(Badge::class)
                    ->where('rank', 'gold')
                    ->orderByPivot('created_at', 'desc');

<a name="defining-custom-intermediate-table-models"></a>
### Definiendo Modelos de Tabla Intermedia Personalizados

Si deseas definir un modelo personalizado para representar la tabla intermedia de tu relación de muchos a muchos, puedes llamar al método `using` al definir la relación. Los modelos pivot personalizados te dan la oportunidad de definir un comportamiento adicional en el modelo pivot, como métodos y casts.

Los modelos pivot personalizados de muchos a muchos deben extender la clase `Illuminate\Database\Eloquent\Relations\Pivot`, mientras que los modelos pivot polimórficos personalizados de muchos a muchos deben extender la clase `Illuminate\Database\Eloquent\Relations\MorphPivot`. Por ejemplo, podemos definir un modelo `Role` que utiliza un modelo pivot personalizado `RoleUser`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsToMany;

    class Role extends Model
    {
        /**
         * Los usuarios que pertenecen al rol.
         */
        public function users(): BelongsToMany
        {
            return $this->belongsToMany(User::class)->using(RoleUser::class);
        }
    }

Al definir el modelo `RoleUser`, debes extender la clase `Illuminate\Database\Eloquent\Relations\Pivot`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Relations\Pivot;

    class RoleUser extends Pivot
    {
        // ...
    }

> [!WARNING]  
> Los modelos pivot no pueden usar el trait `SoftDeletes`. Si necesitas eliminar registros pivot de forma suave, considera convertir tu modelo pivot en un modelo Eloquent real.

<a name="custom-pivot-models-and-incrementing-ids"></a>
#### Modelos Pivot Personalizados e IDs Autoincrementales

Si has definido una relación de muchos a muchos que utiliza un modelo pivot personalizado, y ese modelo pivot tiene una clave primaria autoincremental, debes asegurarte de que tu clase de modelo pivot personalizada defina una propiedad `incrementing` que esté establecida en `true`.

    /**
     * Indica si los IDs son autoincrementales.
     *
     * @var bool
     */
    public $incrementing = true;

<a name="polymorphic-relationships"></a>
## Relaciones Polimórficas

Una relación polimórfica permite que el modelo hijo pertenezca a más de un tipo de modelo utilizando una sola asociación. Por ejemplo, imagina que estás construyendo una aplicación que permite a los usuarios compartir publicaciones de blog y videos. En tal aplicación, un modelo `Comment` podría pertenecer tanto a los modelos `Post` como `Video`.

<a name="one-to-one-polymorphic-relations"></a>
### Uno a Uno (Polimórfico)

<a name="one-to-one-polymorphic-table-structure"></a>
#### Estructura de la Tabla

Una relación polimórfica uno a uno es similar a una relación típica uno a uno; sin embargo, el modelo hijo puede pertenecer a más de un tipo de modelo utilizando una sola asociación. Por ejemplo, una publicación de blog `Post` y un `User` pueden compartir una relación polimórfica con un modelo `Image`. Usar una relación polimórfica uno a uno te permite tener una sola tabla de imágenes únicas que pueden estar asociadas con publicaciones y usuarios. Primero, examinemos la estructura de la tabla:

    posts
        id - integer
        name - string

    users
        id - integer
        name - string

    images
        id - integer
        url - string
        imageable_id - integer
        imageable_type - string

Nota las columnas `imageable_id` y `imageable_type` en la tabla `images`. La columna `imageable_id` contendrá el valor ID de la publicación o usuario, mientras que la columna `imageable_type` contendrá el nombre de la clase del modelo padre. La columna `imageable_type` es utilizada por Eloquent para determinar qué "tipo" de modelo padre devolver al acceder a la relación `imageable`. En este caso, la columna contendría ya sea `App\Models\Post` o `App\Models\User`.

<a name="one-to-one-polymorphic-model-structure"></a>
#### Estructura del Modelo

A continuación, examinemos las definiciones de modelo necesarias para construir esta relación:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphTo;

    class Image extends Model
    {
        /**
         * Obtiene el modelo padre imageable (usuario o publicación).
         */
        public function imageable(): MorphTo
        {
            return $this->morphTo();
        }
    }

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphOne;

    class Post extends Model
    {
        /**
         * Obtiene la imagen de la publicación.
         */
        public function image(): MorphOne
        {
            return $this->morphOne(Image::class, 'imageable');
        }
    }

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphOne;

    class User extends Model
    {
        /**
         * Obtiene la imagen del usuario.
         */
        public function image(): MorphOne
        {
            return $this->morphOne(Image::class, 'imageable');
        }
    }

<a name="one-to-one-polymorphic-retrieving-the-relationship"></a>
#### Recuperando la Relación

Una vez que tu tabla de base de datos y modelos están definidos, puedes acceder a las relaciones a través de tus modelos. Por ejemplo, para recuperar la imagen de una publicación, podemos acceder a la propiedad dinámica de relación `image`:

    use App\Models\Post;

    $post = Post::find(1);

    $image = $post->image;

Puedes recuperar el padre del modelo polimórfico accediendo al nombre del método que realiza la llamada a `morphTo`. En este caso, ese es el método `imageable` en el modelo `Image`. Así que, accederemos a ese método como una propiedad dinámica de relación:

    use App\Models\Image;

    $image = Image::find(1);

    $imageable = $image->imageable;

La relación `imageable` en el modelo `Image` devolverá ya sea una instancia de `Post` o `User`, dependiendo de qué tipo de modelo posee la imagen.

<a name="morph-one-to-one-key-conventions"></a>
#### Convenciones de Clave

Si es necesario, puedes especificar el nombre de las columnas "id" y "type" utilizadas por tu modelo hijo polimórfico. Si lo haces, asegúrate de que siempre pases el nombre de la relación como el primer argumento al método `morphTo`. Típicamente, este valor debería coincidir con el nombre del método, por lo que puedes usar la constante `__FUNCTION__` de PHP:

    /**
     * Obtiene el modelo al que pertenece la imagen.
     */
    public function imageable(): MorphTo
    {
        return $this->morphTo(__FUNCTION__, 'imageable_type', 'imageable_id');
    }

<a name="one-to-many-polymorphic-relations"></a>
### Uno a Muchos (Polimórfico)

<a name="one-to-many-polymorphic-table-structure"></a>
#### Estructura de la Tabla

Una relación polimórfica uno a muchos es similar a una relación típica uno a muchos; sin embargo, el modelo hijo puede pertenecer a más de un tipo de modelo utilizando una sola asociación. Por ejemplo, imagina que los usuarios de tu aplicación pueden "comentar" en publicaciones y videos. Usando relaciones polimórficas, puedes usar una sola tabla `comments` para contener comentarios tanto para publicaciones como para videos. Primero, examinemos la estructura de la tabla requerida para construir esta relación:

    posts
        id - integer
        title - string
        body - text

    videos
        id - integer
        title - string
        url - string

    comments
        id - integer
        body - text
        commentable_id - integer
        commentable_type - string

<a name="one-to-many-polymorphic-model-structure"></a>
#### Estructura del Modelo

A continuación, examinemos las definiciones de modelo necesarias para construir esta relación:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphTo;

    class Comment extends Model
    {
        /**
         * Obtiene el modelo padre commentable (publicación o video).
         */
        public function commentable(): MorphTo
        {
            return $this->morphTo();
        }
    }

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphMany;

    class Post extends Model
    {
        /**
         * Obtiene todos los comentarios de la publicación.
         */
        public function comments(): MorphMany
        {
            return $this->morphMany(Comment::class, 'commentable');
        }
    }

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphMany;

    class Video extends Model
    {
        /**
         * Obtiene todos los comentarios del video.
         */
        public function comments(): MorphMany
        {
            return $this->morphMany(Comment::class, 'commentable');
        }
    }

<a name="one-to-many-polymorphic-retrieving-the-relationship"></a>
#### Recuperando la Relación

Una vez que tu tabla de base de datos y modelos están definidos, puedes acceder a las relaciones a través de las propiedades dinámicas de relación de tu modelo. Por ejemplo, para acceder a todos los comentarios de una publicación, podemos usar la propiedad dinámica `comments`:

    use App\Models\Post;

    $post = Post::find(1);

    foreach ($post->comments as $comment) {
        // ...
    }

También puedes recuperar el padre de un modelo hijo polimórfico accediendo al nombre del método que realiza la llamada a `morphTo`. En este caso, ese es el método `commentable` en el modelo `Comment`. Así que, accederemos a ese método como una propiedad dinámica de relación para acceder al modelo padre del comentario:

    use App\Models\Comment;

    $comment = Comment::find(1);

    $commentable = $comment->commentable;

La relación `commentable` en el modelo `Comment` devolverá ya sea una instancia de `Post` o `Video`, dependiendo de qué tipo de modelo es el padre del comentario.

<a name="one-of-many-polymorphic-relations"></a>
### Uno de Muchos (Polimórfico)

A veces un modelo puede tener muchos modelos relacionados, pero deseas recuperar fácilmente el modelo relacionado "más reciente" o "más antiguo" de la relación. Por ejemplo, un modelo `User` puede estar relacionado con muchos modelos `Image`, pero deseas definir una forma conveniente de interactuar con la imagen más reciente que el usuario ha subido. Puedes lograr esto utilizando el tipo de relación `morphOne` combinado con los métodos `ofMany`:

```php
/**
 * Get the user's most recent image.
 */
public function latestImage(): MorphOne
{
    return $this->morphOne(Image::class, 'imageable')->latestOfMany();
}
```

Del mismo modo, puedes definir un método para recuperar el modelo relacionado "más antiguo", o primero, de una relación:

```php
/**
 * Get the user's oldest image.
 */
public function oldestImage(): MorphOne
{
    return $this->morphOne(Image::class, 'imageable')->oldestOfMany();
}
```

Por defecto, los métodos `latestOfMany` y `oldestOfMany` recuperarán el modelo relacionado más reciente o más antiguo basado en la clave primaria del modelo, que debe ser ordenable. Sin embargo, a veces puedes desear recuperar un solo modelo de una relación más grande utilizando un criterio de ordenación diferente.

Por ejemplo, utilizando el método `ofMany`, puedes recuperar la imagen "más gustada" del usuario. El método `ofMany` acepta la columna ordenable como su primer argumento y qué función de agregado (`min` o `max`) aplicar al consultar el modelo relacionado:

```php
/**
 * Get the user's most popular image.
 */
public function bestImage(): MorphOne
{
    return $this->morphOne(Image::class, 'imageable')->ofMany('likes', 'max');
}
```

> [!NOTE]  
> Es posible construir relaciones "uno de muchos" más avanzadas. Para más información, consulta la [documentación sobre has one of many](#advanced-has-one-of-many-relationships).

<a name="many-to-many-polymorphic-relations"></a>
### Muchos a Muchos (Polimórfico)

<a name="many-to-many-polymorphic-table-structure"></a>
#### Estructura de la Tabla

Las relaciones polimórficas de muchos a muchos son ligeramente más complicadas que las relaciones "morph one" y "morph many". Por ejemplo, un modelo `Post` y un modelo `Video` podrían compartir una relación polimórfica con un modelo `Tag`. Usar una relación polimórfica de muchos a muchos en esta situación permitiría a tu aplicación tener una sola tabla de etiquetas únicas que pueden estar asociadas con publicaciones o videos. Primero, examinemos la estructura de la tabla requerida para construir esta relación:

    posts
        id - integer
        name - string

    videos
        id - integer
        name - string

    tags
        id - integer
        name - string

    taggables
        tag_id - integer
        taggable_id - integer
        taggable_type - string

> [!NOTE]  
> Antes de profundizar en las relaciones polimórficas de muchos a muchos, puede ser beneficioso leer la documentación sobre relaciones típicas de [muchos a muchos](#many-to-many).

<a name="many-to-many-polymorphic-model-structure"></a>
#### Estructura del Modelo

A continuación, estamos listos para definir las relaciones en los modelos. Los modelos `Post` y `Video` contendrán un método `tags` que llama al método `morphToMany` proporcionado por la clase base del modelo Eloquent.

El método `morphToMany` acepta el nombre del modelo relacionado así como el "nombre de la relación". Basado en el nombre que asignamos a nuestro nombre de tabla intermedia y las claves que contiene, nos referiremos a la relación como "taggable":

```php
    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphToMany;

    class Post extends Model
    {
        /**
         * Obtener todas las etiquetas para la publicación.
         */
        public function tags(): MorphToMany
        {
            return $this->morphToMany(Tag::class, 'taggable');
        }
    }
```

<a name="many-to-many-polymorphic-defining-the-inverse-of-the-relationship"></a>
#### Definiendo la Inversa de la Relación

A continuación, en el modelo `Tag`, debes definir un método para cada uno de sus posibles modelos padre. Así que, en este ejemplo, definiremos un método `posts` y un método `videos`. Ambos métodos deben devolver el resultado del método `morphedByMany`.

El método `morphedByMany` acepta el nombre del modelo relacionado así como el "nombre de la relación". Basándonos en el nombre que asignamos a nuestro nombre de tabla intermedia y las claves que contiene, nos referiremos a la relación como "taggable":

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphToMany;

    class Tag extends Model
    {
        /**
         * Obtener todas las publicaciones que tienen esta etiqueta asignada.
         */
        public function posts(): MorphToMany
        {
            return $this->morphedByMany(Post::class, 'taggable');
        }

        /**
         * Obtener todos los videos que tienen esta etiqueta asignada.
         */
        public function videos(): MorphToMany
        {
            return $this->morphedByMany(Video::class, 'taggable');
        }
    }

<a name="many-to-many-polymorphic-retrieving-the-relationship"></a>
#### Recuperando la Relación

Una vez que tu tabla de base de datos y los modelos estén definidos, puedes acceder a las relaciones a través de tus modelos. Por ejemplo, para acceder a todas las etiquetas de una publicación, puedes usar la propiedad dinámica de relación `tags`:

    use App\Models\Post;

    $post = Post::find(1);

    foreach ($post->tags as $tag) {
        // ...
    }

Puedes recuperar el padre de una relación polimórfica desde el modelo hijo polimórfico accediendo al nombre del método que realiza la llamada a `morphedByMany`. En este caso, esos son los métodos `posts` o `videos` en el modelo `Tag`:

    use App\Models\Tag;

    $tag = Tag::find(1);

    foreach ($tag->posts as $post) {
        // ...
    }

    foreach ($tag->videos as $video) {
        // ...
    }

<a name="custom-polymorphic-types"></a>
### Tipos Polimórficos Personalizados

Por defecto, Laravel usará el nombre de clase completamente calificado para almacenar el "tipo" del modelo relacionado. Por ejemplo, dado el ejemplo de relación uno a muchos anterior donde un modelo `Comment` puede pertenecer a un modelo `Post` o a un modelo `Video`, el `commentable_type` por defecto sería `App\Models\Post` o `App\Models\Video`, respectivamente. Sin embargo, es posible que desees desacoplar estos valores de la estructura interna de tu aplicación.

Por ejemplo, en lugar de usar los nombres de los modelos como "tipo", podemos usar cadenas simples como `post` y `video`. Al hacerlo, los valores de la columna "tipo" polimórfica en nuestra base de datos seguirán siendo válidos incluso si los modelos son renombrados:

    use Illuminate\Database\Eloquent\Relations\Relation;

    Relation::enforceMorphMap([
        'post' => 'App\Models\Post',
        'video' => 'App\Models\Video',
    ]);

Puedes llamar al método `enforceMorphMap` en el método `boot` de tu clase `App\Providers\AppServiceProvider` o crear un proveedor de servicios separado si lo deseas.

Puedes determinar el alias de morfismo de un modelo dado en tiempo de ejecución utilizando el método `getMorphClass` del modelo. Por el contrario, puedes determinar el nombre de clase completamente calificado asociado con un alias de morfismo utilizando el método `Relation::getMorphedModel`:

    use Illuminate\Database\Eloquent\Relations\Relation;

    $alias = $post->getMorphClass();

    $class = Relation::getMorphedModel($alias);

> [!WARNING]  
> Al agregar un "mapa de morfismo" a tu aplicación existente, cada valor de columna `*_type` morfable en tu base de datos que aún contenga una clase completamente calificada deberá ser convertido a su nombre de "mapa".

<a name="dynamic-relationships"></a>
### Relaciones Dinámicas

Puedes usar el método `resolveRelationUsing` para definir relaciones entre modelos Eloquent en tiempo de ejecución. Aunque no se recomienda típicamente para el desarrollo normal de aplicaciones, esto puede ser útil ocasionalmente al desarrollar paquetes de Laravel.

El método `resolveRelationUsing` acepta el nombre de la relación deseada como su primer argumento. El segundo argumento pasado al método debe ser una función anónima que acepte la instancia del modelo y devuelva una definición de relación Eloquent válida. Típicamente, debes configurar relaciones dinámicas dentro del método boot de un [proveedor de servicios](/docs/{{version}}/providers):

    use App\Models\Order;
    use App\Models\Customer;

    Order::resolveRelationUsing('customer', function (Order $orderModel) {
        return $orderModel->belongsTo(Customer::class, 'customer_id');
    });

> [!WARNING]  
> Al definir relaciones dinámicas, siempre proporciona argumentos de nombre de clave explícitos a los métodos de relación Eloquent.

<a name="querying-relations"></a>
## Consultando Relaciones

Dado que todas las relaciones Eloquent se definen a través de métodos, puedes llamar a esos métodos para obtener una instancia de la relación sin ejecutar realmente una consulta para cargar los modelos relacionados. Además, todos los tipos de relaciones Eloquent también sirven como [constructores de consultas](/docs/{{version}}/queries), lo que te permite seguir encadenando restricciones a la consulta de relación antes de finalmente ejecutar la consulta SQL contra tu base de datos.

Por ejemplo, imagina una aplicación de blog en la que un modelo `User` tiene muchos modelos `Post` asociados:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\HasMany;

    class User extends Model
    {
        /**
         * Obtener todas las publicaciones para el usuario.
         */
        public function posts(): HasMany
        {
            return $this->hasMany(Post::class);
        }
    }

Puedes consultar la relación `posts` y agregar restricciones adicionales a la relación de la siguiente manera:

    use App\Models\User;

    $user = User::find(1);

    $user->posts()->where('active', 1)->get();

Puedes usar cualquiera de los métodos del [constructor de consultas](/docs/{{version}}/queries) de Laravel en la relación, así que asegúrate de explorar la documentación del constructor de consultas para aprender sobre todos los métodos que están disponibles para ti.

<a name="chaining-orwhere-clauses-after-relationships"></a>
#### Encadenando Cláusulas `orWhere` Después de Relaciones

Como se demostró en el ejemplo anterior, eres libre de agregar restricciones adicionales a las relaciones al consultarlas. Sin embargo, ten cuidado al encadenar cláusulas `orWhere` a una relación, ya que las cláusulas `orWhere` se agruparán lógicamente al mismo nivel que la restricción de relación:

    $user->posts()
            ->where('active', 1)
            ->orWhere('votes', '>=', 100)
            ->get();

El ejemplo anterior generará el siguiente SQL. Como puedes ver, la cláusula `or` instruye a la consulta para devolver _cualquier_ publicación con más de 100 votos. La consulta ya no está restringida a un usuario específico:

```sql
select *
from posts
where user_id = ? and active = 1 or votes >= 100
```

En la mayoría de las situaciones, debes usar [grupos lógicos](/docs/{{version}}/queries#logical-grouping) para agrupar las verificaciones condicionales entre paréntesis:

    use Illuminate\Database\Eloquent\Builder;

    $user->posts()
            ->where(function (Builder $query) {
                return $query->where('active', 1)
                             ->orWhere('votes', '>=', 100);
            })
            ->get();

El ejemplo anterior producirá el siguiente SQL. Ten en cuenta que el agrupamiento lógico ha agrupado correctamente las restricciones y la consulta sigue restringida a un usuario específico:

```sql
select *
from posts
where user_id = ? and (active = 1 or votes >= 100)
```

<a name="relationship-methods-vs-dynamic-properties"></a>
### Métodos de Relación vs. Propiedades Dinámicas

Si no necesitas agregar restricciones adicionales a una consulta de relación Eloquent, puedes acceder a la relación como si fuera una propiedad. Por ejemplo, continuando con nuestros modelos de ejemplo `User` y `Post`, podemos acceder a todas las publicaciones de un usuario de la siguiente manera:

    use App\Models\User;

    $user = User::find(1);

    foreach ($user->posts as $post) {
        // ...
    }

Las propiedades de relación dinámicas realizan "carga perezosa", lo que significa que solo cargarán sus datos de relación cuando realmente las accedas. Debido a esto, los desarrolladores a menudo utilizan [carga ansiosa](#eager-loading) para precargar relaciones que saben que se accederán después de cargar el modelo. La carga ansiosa proporciona una reducción significativa en las consultas SQL que deben ejecutarse para cargar las relaciones de un modelo.

<a name="querying-relationship-existence"></a>
### Consultando la Existencia de Relaciones

Al recuperar registros de modelo, es posible que desees limitar tus resultados en función de la existencia de una relación. Por ejemplo, imagina que deseas recuperar todas las publicaciones de blog que tienen al menos un comentario. Para hacerlo, puedes pasar el nombre de la relación a los métodos `has` y `orHas`:

    use App\Models\Post;

    // Recuperar todas las publicaciones que tienen al menos un comentario...
    $posts = Post::has('comments')->get();

También puedes especificar un operador y un valor de conteo para personalizar aún más la consulta:

    // Recuperar todas las publicaciones que tienen tres o más comentarios...
    $posts = Post::has('comments', '>=', 3)->get();

Las declaraciones `has` anidadas pueden construirse utilizando la notación "punto". Por ejemplo, puedes recuperar todas las publicaciones que tienen al menos un comentario que tiene al menos una imagen:

    // Recuperar publicaciones que tienen al menos un comentario con imágenes...
    $posts = Post::has('comments.images')->get();

Si necesitas aún más poder, puedes usar los métodos `whereHas` y `orWhereHas` para definir restricciones de consulta adicionales en tus consultas `has`, como inspeccionar el contenido de un comentario:

    use Illuminate\Database\Eloquent\Builder;

    // Recuperar publicaciones con al menos un comentario que contenga palabras como code%...
    $posts = Post::whereHas('comments', function (Builder $query) {
        $query->where('content', 'like', 'code%');
    })->get();

    // Recuperar publicaciones con al menos diez comentarios que contengan palabras como code%...
    $posts = Post::whereHas('comments', function (Builder $query) {
        $query->where('content', 'like', 'code%');
    }, '>=', 10)->get();

> [!WARNING]  
> Eloquent no admite actualmente la consulta de existencia de relaciones a través de bases de datos. Las relaciones deben existir dentro de la misma base de datos.

<a name="inline-relationship-existence-queries"></a>
#### Consultas de Existencia de Relaciones en Línea

Si deseas consultar la existencia de una relación con una sola condición simple donde se adjunta a la consulta de relación, puede que te resulte más conveniente usar los métodos `whereRelation`, `orWhereRelation`, `whereMorphRelation` y `orWhereMorphRelation`. Por ejemplo, podemos consultar todas las publicaciones que tienen comentarios no aprobados:

    use App\Models\Post;

    $posts = Post::whereRelation('comments', 'is_approved', false)->get();

Por supuesto, al igual que las llamadas al método `where` del constructor de consultas, también puedes especificar un operador:

    $posts = Post::whereRelation(
        'comments', 'created_at', '>=', now()->subHour()
    )->get();

<a name="querying-relationship-absence"></a>
### Consultando la Ausencia de Relaciones

Al recuperar registros de modelo, es posible que desees limitar tus resultados en función de la ausencia de una relación. Por ejemplo, imagina que deseas recuperar todas las publicaciones de blog que **no** tienen comentarios. Para hacerlo, puedes pasar el nombre de la relación a los métodos `doesntHave` y `orDoesntHave`:

    use App\Models\Post;

    $posts = Post::doesntHave('comments')->get();

Si necesitas aún más poder, puedes usar los métodos `whereDoesntHave` y `orWhereDoesntHave` para agregar restricciones de consulta adicionales a tus consultas `doesntHave`, como inspeccionar el contenido de un comentario:

    use Illuminate\Database\Eloquent\Builder;

    $posts = Post::whereDoesntHave('comments', function (Builder $query) {
        $query->where('content', 'like', 'code%');
    })->get();

Puedes usar la notación "punto" para ejecutar una consulta contra una relación anidada. Por ejemplo, la siguiente consulta recuperará todas las publicaciones que no tienen comentarios; sin embargo, las publicaciones que tienen comentarios de autores que no están prohibidos se incluirán en los resultados:

    use Illuminate\Database\Eloquent\Builder;

    $posts = Post::whereDoesntHave('comments.author', function (Builder $query) {
        $query->where('banned', 0);
    })->get();

<a name="querying-morph-to-relationships"></a>
### Consultando Relaciones Morph To

Para consultar la existencia de relaciones "morph to", puedes usar los métodos `whereHasMorph` y `whereDoesntHaveMorph`. Estos métodos aceptan el nombre de la relación como su primer argumento. A continuación, los métodos aceptan los nombres de los modelos relacionados que deseas incluir en la consulta. Finalmente, puedes proporcionar una función anónima que personalice la consulta de relación:

    use App\Models\Comment;
    use App\Models\Post;
    use App\Models\Video;
    use Illuminate\Database\Eloquent\Builder;

    // Recuperar comentarios asociados a publicaciones o videos con un título como code%...
    $comments = Comment::whereHasMorph(
        'commentable',
        [Post::class, Video::class],
        function (Builder $query) {
            $query->where('title', 'like', 'code%');
        }
    )->get();

    // Recuperar comentarios asociados a publicaciones con un título que no sea como code%...
    $comments = Comment::whereDoesntHaveMorph(
        'commentable',
        Post::class,
        function (Builder $query) {
            $query->where('title', 'like', 'code%');
        }
    )->get();

Ocasionalmente, es posible que necesites agregar restricciones de consulta basadas en el "tipo" del modelo polimórfico relacionado. La función anónima pasada al método `whereHasMorph` puede recibir un valor `$type` como su segundo argumento. Este argumento te permite inspeccionar el "tipo" de la consulta que se está construyendo:

    use Illuminate\Database\Eloquent\Builder;

    $comments = Comment::whereHasMorph(
        'commentable',
        [Post::class, Video::class],
        function (Builder $query, string $type) {
            $column = $type === Post::class ? 'content' : 'title';

            $query->where($column, 'like', 'code%');
        }
    )->get();

<a name="querying-all-morph-to-related-models"></a>
#### Consultando Todos los Modelos Relacionados

En lugar de pasar un array de posibles modelos polimórficos, puedes proporcionar `*` como un valor comodín. Esto instruirá a Laravel a recuperar todos los tipos polimórficos posibles de la base de datos. Laravel ejecutará una consulta adicional para realizar esta operación:

    use Illuminate\Database\Eloquent\Builder;

    $comments = Comment::whereHasMorph('commentable', '*', function (Builder $query) {
        $query->where('title', 'like', 'foo%');
    })->get();

<a name="aggregating-related-models"></a>
## Agregando Modelos Relacionados

<a name="counting-related-models"></a>
### Contando Modelos Relacionados

A veces, es posible que desees contar el número de modelos relacionados para una relación dada sin cargar realmente los modelos. Para lograr esto, puedes usar el método `withCount`. El método `withCount` colocará un atributo `{relation}_count` en los modelos resultantes:


```php
    use App\Models\Post;

    $posts = Post::withCount('comments')->get();

    foreach ($posts as $post) {
        echo $post->comments_count;
    }
```

Al pasar un array al método `withCount`, puedes agregar los "contadores" para múltiples relaciones, así como agregar restricciones adicionales a las consultas:

    use Illuminate\Database\Eloquent\Builder;

    $posts = Post::withCount(['votes', 'comments' => function (Builder $query) {
        $query->where('content', 'like', 'code%');
    }])->get();

    echo $posts[0]->votes_count;
    echo $posts[0]->comments_count;

También puedes alias el resultado del conteo de la relación, permitiendo múltiples conteos en la misma relación:

    use Illuminate\Database\Eloquent\Builder;

    $posts = Post::withCount([
        'comments',
        'comments as pending_comments_count' => function (Builder $query) {
            $query->where('approved', false);
        },
    ])->get();

    echo $posts[0]->comments_count;
    echo $posts[0]->pending_comments_count;

<a name="deferred-count-loading"></a>
#### Carga de Conteo Diferido

Usando el método `loadCount`, puedes cargar un conteo de relación después de que el modelo padre ya ha sido recuperado:

    $book = Book::first();

    $book->loadCount('genres');

Si necesitas establecer restricciones adicionales en la consulta de conteo, puedes pasar un array indexado por las relaciones que deseas contar. Los valores del array deben ser funciones anónimas que reciben la instancia del constructor de consultas:

    $book->loadCount(['reviews' => function (Builder $query) {
        $query->where('rating', 5);
    }])

<a name="relationship-counting-and-custom-select-statements"></a>
#### Conteo de Relaciones y Declaraciones de Selección Personalizadas

Si estás combinando `withCount` con una declaración `select`, asegúrate de llamar a `withCount` después del método `select`:

    $posts = Post::select(['title', 'body'])
                    ->withCount('comments')
                    ->get();

<a name="other-aggregate-functions"></a>
### Otras Funciones Agregadas

Además del método `withCount`, Eloquent proporciona métodos `withMin`, `withMax`, `withAvg`, `withSum` y `withExists`. Estos métodos colocarán un atributo `{relation}_{function}_{column}` en tus modelos resultantes:

    use App\Models\Post;

    $posts = Post::withSum('comments', 'votes')->get();

    foreach ($posts as $post) {
        echo $post->comments_sum_votes;
    }

Si deseas acceder al resultado de la función agregada usando otro nombre, puedes especificar tu propio alias:

    $posts = Post::withSum('comments as total_comments', 'votes')->get();

    foreach ($posts as $post) {
        echo $post->total_comments;
    }

Al igual que el método `loadCount`, también están disponibles versiones diferidas de estos métodos. Estas operaciones agregadas adicionales pueden realizarse en modelos Eloquent que ya han sido recuperados:

    $post = Post::first();

    $post->loadSum('comments', 'votes');

Si estás combinando estos métodos agregados con una declaración `select`, asegúrate de llamar a los métodos agregados después del método `select`:

    $posts = Post::select(['title', 'body'])
                    ->withExists('comments')
                    ->get();

<a name="counting-related-models-on-morph-to-relationships"></a>
### Conteo de Modelos Relacionados en Relaciones Morph To

Si deseas cargar ansiosamente una relación "morph to", así como los conteos de modelos relacionados para las diversas entidades que pueden ser devueltas por esa relación, puedes utilizar el método `with` en combinación con el método `morphWithCount` de la relación `morphTo`.

En este ejemplo, supongamos que los modelos `Photo` y `Post` pueden crear modelos `ActivityFeed`. Supondremos que el modelo `ActivityFeed` define una relación "morph to" llamada `parentable` que nos permite recuperar el modelo padre `Photo` o `Post` para una instancia dada de `ActivityFeed`. Además, supongamos que los modelos `Photo` "tienen muchos" modelos `Tag` y los modelos `Post` "tienen muchos" modelos `Comment`.

Ahora, imaginemos que queremos recuperar instancias de `ActivityFeed` y cargar ansiosamente los modelos padres `parentable` para cada instancia de `ActivityFeed`. Además, queremos recuperar el número de etiquetas que están asociadas con cada foto padre y el número de comentarios que están asociados con cada publicación padre:

    use Illuminate\Database\Eloquent\Relations\MorphTo;

    $activities = ActivityFeed::with([
        'parentable' => function (MorphTo $morphTo) {
            $morphTo->morphWithCount([
                Photo::class => ['tags'],
                Post::class => ['comments'],
            ]);
        }])->get();

<a name="morph-to-deferred-count-loading"></a>
#### Carga de Conteo Diferido

Supongamos que ya hemos recuperado un conjunto de modelos `ActivityFeed` y ahora nos gustaría cargar los conteos de relaciones anidadas para los diversos modelos `parentable` asociados con los feeds de actividad. Puedes usar el método `loadMorphCount` para lograr esto:

    $activities = ActivityFeed::with('parentable')->get();

    $activities->loadMorphCount('parentable', [
        Photo::class => ['tags'],
        Post::class => ['comments'],
    ]);

<a name="eager-loading"></a>
## Carga Ansiosa

Al acceder a las relaciones Eloquent como propiedades, los modelos relacionados son "cargados de manera perezosa". Esto significa que los datos de la relación no se cargan realmente hasta que accedes primero a la propiedad. Sin embargo, Eloquent puede "cargar ansiosamente" relaciones en el momento en que consultas el modelo padre. La carga ansiosa alivia el problema de consulta "N + 1". Para ilustrar el problema de consulta N + 1, considera un modelo `Book` que "pertenece a" un modelo `Author`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsTo;

    class Book extends Model
    {
        /**
         * Obtiene el autor que escribió el libro.
         */
        public function author(): BelongsTo
        {
            return $this->belongsTo(Author::class);
        }
    }

Ahora, recuperemos todos los libros y sus autores:

    use App\Models\Book;

    $books = Book::all();

    foreach ($books as $book) {
        echo $book->author->name;
    }

Este bucle ejecutará una consulta para recuperar todos los libros dentro de la tabla de la base de datos, luego otra consulta para cada libro con el fin de recuperar el autor del libro. Así que, si tenemos 25 libros, el código anterior ejecutaría 26 consultas: una para el libro original y 25 consultas adicionales para recuperar el autor de cada libro.

Afortunadamente, podemos usar la carga ansiosa para reducir esta operación a solo dos consultas. Al construir una consulta, puedes especificar qué relaciones deben ser cargadas ansiosamente usando el método `with`:

    $books = Book::with('author')->get();

    foreach ($books as $book) {
        echo $book->author->name;
    }

Para esta operación, solo se ejecutarán dos consultas: una consulta para recuperar todos los libros y una consulta para recuperar todos los autores de todos los libros:

```sql
select * from books

select * from authors where id in (1, 2, 3, 4, 5, ...)
```

<a name="eager-loading-multiple-relationships"></a>
#### Carga Ansiosa de Múltiples Relaciones

A veces es posible que necesites cargar ansiosamente varias relaciones diferentes. Para hacerlo, simplemente pasa un array de relaciones al método `with`:

    $books = Book::with(['author', 'publisher'])->get();

<a name="nested-eager-loading"></a>
#### Carga Ansiosa Anidada

Para cargar ansiosamente las relaciones de una relación, puedes usar la sintaxis de "punto". Por ejemplo, carguemos ansiosamente todos los autores del libro y todos los contactos personales del autor:

    $books = Book::with('author.contacts')->get();

Alternativamente, puedes especificar relaciones anidadas cargadas ansiosamente proporcionando un array anidado al método `with`, lo cual puede ser conveniente al cargar ansiosamente múltiples relaciones anidadas:

    $books = Book::with([
        'author' => [
            'contacts',
            'publisher',
        ],
    ])->get();

<a name="nested-eager-loading-morphto-relationships"></a>
#### Carga Ansiosa Anidada de Relaciones `morphTo`

Si deseas cargar ansiosamente una relación `morphTo`, así como relaciones anidadas en las diversas entidades que pueden ser devueltas por esa relación, puedes usar el método `with` en combinación con el método `morphTo` de la relación. Para ayudar a ilustrar este método, consideremos el siguiente modelo:

    <?php

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphTo;

    class ActivityFeed extends Model
    {
        /**
         * Obtiene el padre del registro de feed de actividad.
         */
        public function parentable(): MorphTo
        {
            return $this->morphTo();
        }
    }

En este ejemplo, supongamos que los modelos `Event`, `Photo` y `Post` pueden crear modelos `ActivityFeed`. Además, supongamos que los modelos `Event` pertenecen a un modelo `Calendar`, los modelos `Photo` están asociados con modelos `Tag`, y los modelos `Post` pertenecen a un modelo `Author`.

Usando estas definiciones de modelo y relaciones, podemos recuperar instancias del modelo `ActivityFeed` y cargar ansiosamente todos los modelos `parentable` y sus respectivas relaciones anidadas:

    use Illuminate\Database\Eloquent\Relations\MorphTo;

    $activities = ActivityFeed::query()
        ->with(['parentable' => function (MorphTo $morphTo) {
            $morphTo->morphWith([
                Event::class => ['calendar'],
                Photo::class => ['tags'],
                Post::class => ['author'],
            ]);
        }])->get();

<a name="eager-loading-specific-columns"></a>
#### Carga Ansiosa de Columnas Específicas

Es posible que no siempre necesites cada columna de las relaciones que estás recuperando. Por esta razón, Eloquent te permite especificar qué columnas de la relación te gustaría recuperar:

    $books = Book::with('author:id,name,book_id')->get();

> [!WARNING]  
> Al usar esta función, siempre debes incluir la columna `id` y cualquier columna de clave foránea relevante en la lista de columnas que deseas recuperar.

<a name="eager-loading-by-default"></a>
#### Carga Ansiosa por Defecto

A veces es posible que desees cargar siempre algunas relaciones al recuperar un modelo. Para lograr esto, puedes definir una propiedad `$with` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsTo;

    class Book extends Model
    {
        /**
         * Las relaciones que siempre deben ser cargadas.
         *
         * @var array
         */
        protected $with = ['author'];

        /**
         * Obtiene el autor que escribió el libro.
         */
        public function author(): BelongsTo
        {
            return $this->belongsTo(Author::class);
        }

        /**
         * Obtiene el género del libro.
         */
        public function genre(): BelongsTo
        {
            return $this->belongsTo(Genre::class);
        }
    }

Si deseas eliminar un elemento de la propiedad `$with` para una sola consulta, puedes usar el método `without`:

    $books = Book::without('author')->get();

Si deseas sobrescribir todos los elementos dentro de la propiedad `$with` para una sola consulta, puedes usar el método `withOnly`:

    $books = Book::withOnly('genre')->get();

<a name="constraining-eager-loads"></a>
### Restringiendo Cargas Ansiosas

A veces es posible que desees cargar ansiosamente una relación pero también especificar condiciones de consulta adicionales para la consulta de carga ansiosa. Puedes lograr esto pasando un array de relaciones al método `with` donde la clave del array es un nombre de relación y el valor del array es una función anónima que agrega restricciones adicionales a la consulta de carga ansiosa:

    use App\Models\User;
    use Illuminate\Contracts\Database\Eloquent\Builder;

    $users = User::with(['posts' => function (Builder $query) {
        $query->where('title', 'like', '%code%');
    }])->get();

En este ejemplo, Eloquent solo cargará ansiosamente las publicaciones donde la columna `title` de la publicación contenga la palabra `code`. Puedes llamar a otros métodos del [constructor de consultas](/docs/{{version}}/queries) para personalizar aún más la operación de carga ansiosa:

    $users = User::with(['posts' => function (Builder $query) {
        $query->orderBy('created_at', 'desc');
    }])->get();

<a name="constraining-eager-loading-of-morph-to-relationships"></a>
#### Restringiendo la Carga Ansiosa de Relaciones `morphTo`

Si estás cargando ansiosamente una relación `morphTo`, Eloquent ejecutará múltiples consultas para obtener cada tipo de modelo relacionado. Puedes agregar restricciones adicionales a cada una de estas consultas usando el método `constrain` de la relación `MorphTo`:

    use Illuminate\Database\Eloquent\Relations\MorphTo;

    $comments = Comment::with(['commentable' => function (MorphTo $morphTo) {
        $morphTo->constrain([
            Post::class => function ($query) {
                $query->whereNull('hidden_at');
            },
            Video::class => function ($query) {
                $query->where('type', 'educational');
            },
        ]);
    }])->get();

En este ejemplo, Eloquent solo cargará ansiosamente publicaciones que no han sido ocultadas y videos que tienen un valor de `type` de "educational".

<a name="constraining-eager-loads-with-relationship-existence"></a>
#### Restringiendo Cargas Ansiosas con Existencia de Relaciones

A veces puedes encontrarte necesitando verificar la existencia de una relación mientras cargas simultáneamente la relación basada en las mismas condiciones. Por ejemplo, es posible que desees recuperar solo modelos `User` que tengan modelos `Post` hijos que coincidan con una condición de consulta dada mientras también cargas ansiosamente las publicaciones coincidentes. Puedes lograr esto usando el método `withWhereHas`:

    use App\Models\User;

    $users = User::withWhereHas('posts', function ($query) {
        $query->where('featured', true);
    })->get();

<a name="lazy-eager-loading"></a>
### Carga Ansiosa Perezosa

A veces es posible que necesites cargar ansiosamente una relación después de que el modelo padre ya ha sido recuperado. Por ejemplo, esto puede ser útil si necesitas decidir dinámicamente si cargar modelos relacionados:

    use App\Models\Book;

    $books = Book::all();

    if ($someCondition) {
        $books->load('author', 'publisher');
    }

Si necesitas establecer restricciones adicionales en la consulta de carga ansiosa, puedes pasar un array indexado por las relaciones que deseas cargar. Los valores del array deben ser instancias de funciones anónimas que reciben la instancia de la consulta:

    $author->load(['books' => function (Builder $query) {
        $query->orderBy('published_date', 'asc');
    }]);

Para cargar una relación solo cuando no se ha cargado ya, usa el método `loadMissing`:

    $book->loadMissing('author');

<a name="nested-lazy-eager-loading-morphto"></a>
#### Carga Ansiosa Perezosa Anidada y `morphTo`

Si deseas cargar ansiosamente una relación `morphTo`, así como relaciones anidadas en las diversas entidades que pueden ser devueltas por esa relación, puedes usar el método `loadMorph`.

Este método acepta el nombre de la relación `morphTo` como su primer argumento, y un array de pares modelo / relación como su segundo argumento. Para ayudar a ilustrar este método, consideremos el siguiente modelo:

    <?php

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\MorphTo;

    class ActivityFeed extends Model
    {
        /**
         * Obtiene el padre del registro de feed de actividad.
         */
        public function parentable(): MorphTo
        {
            return $this->morphTo();
        }
    }


En este ejemplo, supongamos que los modelos `Event`, `Photo` y `Post` pueden crear modelos `ActivityFeed`. Además, supongamos que los modelos `Event` pertenecen a un modelo `Calendar`, los modelos `Photo` están asociados con modelos `Tag`, y los modelos `Post` pertenecen a un modelo `Author`.

Usando estas definiciones de modelo y relaciones, podemos recuperar instancias del modelo `ActivityFeed` y cargar de manera anticipada todos los modelos `parentable` y sus respectivas relaciones anidadas:

    $activities = ActivityFeed::with('parentable')
        ->get()
        ->loadMorph('parentable', [
            Event::class => ['calendar'],
            Photo::class => ['tags'],
            Post::class => ['author'],
        ]);

<a name="preventing-lazy-loading"></a>
### Previniendo la Carga Perezosa

Como se discutió anteriormente, la carga anticipada de relaciones puede proporcionar beneficios significativos de rendimiento a su aplicación. Por lo tanto, si lo desea, puede instruir a Laravel para que siempre prevenga la carga perezosa de relaciones. Para lograr esto, puede invocar el método `preventLazyLoading` ofrecido por la clase base del modelo Eloquent. Normalmente, debe llamar a este método dentro del método `boot` de la clase `AppServiceProvider` de su aplicación.

El método `preventLazyLoading` acepta un argumento booleano opcional que indica si se debe prevenir la carga perezosa. Por ejemplo, puede desear deshabilitar la carga perezosa solo en entornos no de producción para que su entorno de producción continúe funcionando normalmente incluso si una relación cargada perezosamente está accidentalmente presente en el código de producción:

```php
use Illuminate\Database\Eloquent\Model;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Model::preventLazyLoading(! $this->app->isProduction());
}
```

Después de prevenir la carga perezosa, Eloquent lanzará una excepción `Illuminate\Database\LazyLoadingViolationException` cuando su aplicación intente cargar perezosamente cualquier relación Eloquent.

Puede personalizar el comportamiento de las violaciones de carga perezosa utilizando el método `handleLazyLoadingViolationsUsing`. Por ejemplo, utilizando este método, puede instruir a las violaciones de carga perezosa para que solo se registren en lugar de interrumpir la ejecución de la aplicación con excepciones:

```php
Model::handleLazyLoadingViolationUsing(function (Model $model, string $relation) {
    $class = $model::class;

    info("Attempted to lazy load [{$relation}] on model [{$class}].");
});
```

<a name="inserting-and-updating-related-models"></a>
## Insertando y Actualizando Modelos Relacionados

<a name="the-save-method"></a>
### El Método `save`

Eloquent proporciona métodos convenientes para agregar nuevos modelos a las relaciones. Por ejemplo, tal vez necesite agregar un nuevo comentario a un post. En lugar de establecer manualmente el atributo `post_id` en el modelo `Comment`, puede insertar el comentario utilizando el método `save` de la relación:

    use App\Models\Comment;
    use App\Models\Post;

    $comment = new Comment(['message' => 'Un nuevo comentario.']);

    $post = Post::find(1);

    $post->comments()->save($comment);

Tenga en cuenta que no accedimos a la relación `comments` como una propiedad dinámica. En su lugar, llamamos al método `comments` para obtener una instancia de la relación. El método `save` agregará automáticamente el valor apropiado de `post_id` al nuevo modelo `Comment`.

Si necesita guardar múltiples modelos relacionados, puede usar el método `saveMany`:

    $post = Post::find(1);

    $post->comments()->saveMany([
        new Comment(['message' => 'Un nuevo comentario.']),
        new Comment(['message' => 'Otro nuevo comentario.']),
    ]);

Los métodos `save` y `saveMany` persistirán las instancias de modelo dadas, pero no agregarán los nuevos modelos persistidos a ninguna relación en memoria que ya esté cargada en el modelo padre. Si planea acceder a la relación después de usar los métodos `save` o `saveMany`, puede desear usar el método `refresh` para recargar el modelo y sus relaciones:

    $post->comments()->save($comment);

    $post->refresh();

    // Todos los comentarios, incluido el nuevo comentario guardado...
    $post->comments;

<a name="the-push-method"></a>
#### Guardando Recursivamente Modelos y Relaciones

Si desea `save` su modelo y todas sus relaciones asociadas, puede usar el método `push`. En este ejemplo, el modelo `Post` se guardará junto con sus comentarios y los autores de los comentarios:

    $post = Post::find(1);

    $post->comments[0]->message = 'Mensaje';
    $post->comments[0]->author->name = 'Nombre del Autor';

    $post->push();

El método `pushQuietly` puede usarse para guardar un modelo y sus relaciones asociadas sin generar ningún evento:

    $post->pushQuietly();

<a name="the-create-method"></a>
### El Método `create`

Además de los métodos `save` y `saveMany`, también puede usar el método `create`, que acepta un array de atributos, crea un modelo e inserta en la base de datos. La diferencia entre `save` y `create` es que `save` acepta una instancia completa de modelo Eloquent mientras que `create` acepta un `array` PHP simple. El modelo recién creado será devuelto por el método `create`:

    use App\Models\Post;

    $post = Post::find(1);

    $comment = $post->comments()->create([
        'message' => 'Un nuevo comentario.',
    ]);

Puede usar el método `createMany` para crear múltiples modelos relacionados:

    $post = Post::find(1);

    $post->comments()->createMany([
        ['message' => 'Un nuevo comentario.'],
        ['message' => 'Otro nuevo comentario.'],
    ]);

Los métodos `createQuietly` y `createManyQuietly` pueden usarse para crear un modelo(s) sin despachar ningún evento:

    $user = User::find(1);

    $user->posts()->createQuietly([
        'title' => 'Título del post.',
    ]);

    $user->posts()->createManyQuietly([
        ['title' => 'Primer post.'],
        ['title' => 'Segundo post.'],
    ]);

También puede usar los métodos `findOrNew`, `firstOrNew`, `firstOrCreate` y `updateOrCreate` para [crear y actualizar modelos en relaciones](/docs/{{version}}/eloquent#upserts).

> [!NOTE]  
> Antes de usar el método `create`, asegúrese de revisar la documentación sobre [asignación masiva](/docs/{{version}}/eloquent#mass-assignment).

<a name="updating-belongs-to-relationships"></a>
### Relaciones Pertenecen a

Si desea asignar un modelo hijo a un nuevo modelo padre, puede usar el método `associate`. En este ejemplo, el modelo `User` define una relación `belongsTo` con el modelo `Account`. Este método `associate` establecerá la clave foránea en el modelo hijo:

    use App\Models\Account;

    $account = Account::find(10);

    $user->account()->associate($account);

    $user->save();

Para eliminar un modelo padre de un modelo hijo, puede usar el método `dissociate`. Este método establecerá la clave foránea de la relación en `null`:

    $user->account()->dissociate();

    $user->save();

<a name="updating-many-to-many-relationships"></a>
### Relaciones Muchos a Muchos

<a name="attaching-detaching"></a>
#### Adjuntando / Desadjuntando

Eloquent también proporciona métodos para hacer que trabajar con relaciones muchos a muchos sea más conveniente. Por ejemplo, imaginemos que un usuario puede tener muchos roles y un rol puede tener muchos usuarios. Puede usar el método `attach` para adjuntar un rol a un usuario insertando un registro en la tabla intermedia de la relación:

    use App\Models\User;

    $user = User::find(1);

    $user->roles()->attach($roleId);

Al adjuntar una relación a un modelo, también puede pasar un array de datos adicionales para ser insertados en la tabla intermedia:

    $user->roles()->attach($roleId, ['expires' => $expires]);

A veces puede ser necesario eliminar un rol de un usuario. Para eliminar un registro de relación muchos a muchos, use el método `detach`. El método `detach` eliminará el registro apropiado de la tabla intermedia; sin embargo, ambos modelos permanecerán en la base de datos:

    // Desadjuntar un solo rol del usuario...
    $user->roles()->detach($roleId);

    // Desadjuntar todos los roles del usuario...
    $user->roles()->detach();

Para conveniencia, `attach` y `detach` también aceptan arrays de IDs como entrada:

    $user = User::find(1);

    $user->roles()->detach([1, 2, 3]);

    $user->roles()->attach([
        1 => ['expires' => $expires],
        2 => ['expires' => $expires],
    ]);

<a name="syncing-associations"></a>
#### Sincronizando Asociaciones

También puede usar el método `sync` para construir asociaciones muchos a muchos. El método `sync` acepta un array de IDs para colocar en la tabla intermedia. Cualquier ID que no esté en el array dado será eliminado de la tabla intermedia. Así que, después de que esta operación se complete, solo los IDs en el array dado existirán en la tabla intermedia:

    $user->roles()->sync([1, 2, 3]);

También puede pasar valores adicionales de la tabla intermedia con los IDs:

    $user->roles()->sync([1 => ['expires' => true], 2, 3]);

Si desea insertar los mismos valores de tabla intermedia con cada uno de los IDs de modelo sincronizados, puede usar el método `syncWithPivotValues`:

    $user->roles()->syncWithPivotValues([1, 2, 3], ['active' => true]);

Si no desea desadjuntar IDs existentes que faltan en el array dado, puede usar el método `syncWithoutDetaching`:

    $user->roles()->syncWithoutDetaching([1, 2, 3]);

<a name="toggling-associations"></a>
#### Alternando Asociaciones

La relación muchos a muchos también proporciona un método `toggle` que "cambia" el estado de adjunto de los IDs de modelo relacionados dados. Si el ID dado está actualmente adjunto, será desajuntado. Asimismo, si actualmente está desajuntado, será adjuntado:

    $user->roles()->toggle([1, 2, 3]);

También puede pasar valores adicionales de tabla intermedia con los IDs:

    $user->roles()->toggle([
        1 => ['expires' => true],
        2 => ['expires' => true],
    ]);

<a name="updating-a-record-on-the-intermediate-table"></a>
#### Actualizando un Registro en la Tabla Intermedia

Si necesita actualizar una fila existente en la tabla intermedia de su relación, puede usar el método `updateExistingPivot`. Este método acepta la clave foránea del registro intermedio y un array de atributos para actualizar:

    $user = User::find(1);

    $user->roles()->updateExistingPivot($roleId, [
        'active' => false,
    ]);

<a name="touching-parent-timestamps"></a>
## Actualizando Timestamps del Padre

Cuando un modelo define una relación `belongsTo` o `belongsToMany` con otro modelo, como un `Comment` que pertenece a un `Post`, a veces es útil actualizar el timestamp del padre cuando se actualiza el modelo hijo.

Por ejemplo, cuando se actualiza un modelo `Comment`, puede querer automáticamente "tocar" el timestamp `updated_at` del `Post` propietario para que se establezca en la fecha y hora actuales. Para lograr esto, puede agregar una propiedad `touches` a su modelo hijo que contenga los nombres de las relaciones que deberían tener sus timestamps `updated_at` actualizados cuando se actualiza el modelo hijo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsTo;

    class Comment extends Model
    {
        /**
         * Todas las relaciones que deben ser tocadas.
         *
         * @var array
         */
        protected $touches = ['post'];

        /**
         * Obtener el post al que pertenece el comentario.
         */
        public function post(): BelongsTo
        {
            return $this->belongsTo(Post::class);
        }
    }

> [!WARNING]  
> Los timestamps del modelo padre solo se actualizarán si el modelo hijo se actualiza utilizando el método `save` de Eloquent.
