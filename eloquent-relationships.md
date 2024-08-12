# Eloquent: Relaciones

- [Introducción](#introduction)
- [Definir las relaciones](#defining-relationships)
  - [Uno a uno](#one-to-one)
  - [Uno a muchos](#one-to-many)
  - [Uno a muchos (inverso) / Pertenece a](#one-to-many-inverse)
  - [Tiene Uno De Muchos](#has-one-of-many)
  - [Tiene uno a través de](#has-one-through)
  - [Tiene muchos a través de](#has-many-through)
- [Relaciones de muchos a muchos](#many-to-many)
  - [Recuperación de Columnas de Tablas Intermedias](#retrieving-intermediate-table-columns)
  - [Filtrado de consultas mediante columnas de tablas intermedias](#filtering-queries-via-intermediate-table-columns)
  - [Ordenación de Consultas mediante Columnas de Tablas Intermedias](#ordering-queries-via-intermediate-table-columns)
  - [Definición de Modelos Personalizados de Tablas Intermedias](#defining-custom-intermediate-table-models)
- [Relaciones Polimórficas](#polymorphic-relationships)
  - [Uno a Uno](#one-to-one-polymorphic-relations)
  - [Uno a muchos](#one-to-many-polymorphic-relations)
  - [Uno De Muchos](#one-of-many-polymorphic-relations)
  - [De Muchos a Muchos](#many-to-many-polymorphic-relations)
  - [Tipos polimórficos personalizados](#custom-polymorphic-types)
- [Relaciones Dinámicas](#dynamic-relationships)
- [Consulta de Relaciones](#querying-relations)
  - [Métodos de Relación vs. Propiedades Dinámicas](#relationship-methods-vs-dynamic-properties)
  - [Consulta de la Existencia de Relaciones](#querying-relationship-existence)
  - [Consulta de Ausencia de Relación](#querying-relationship-absence)
  - [Consulta de Relaciones Morph To](#querying-morph-to-relationships)
- [Agregación de modelos relacionados](#aggregating-related-models)
  - [Recuento de modelos relacionados](#counting-related-models)
  - [Otras funciones de agregación](#other-aggregate-functions)
  - [Recuento de modelos relacionados en relaciones Morph To](#counting-related-models-on-morph-to-relationships)
- [Carga rápida](#eager-loading)
  - [Restricción de la carga rápida](#constraining-eager-loads)
  - [Carga perezosa](#lazy-eager-loading)
  - [Prevención de la carga lenta](#preventing-lazy-loading)
- [Inserción y actualización de modelos relacionados](#inserting-and-updating-related-models)
  - [El método `save`](#the-save-method)
  - [Método de `creación`](#the-create-method)
  - [Relaciones de Pertenencia](#updating-belongs-to-relationships)
  - [Relaciones de muchos a muchos](#updating-many-to-many-relationships)
- [Tocar marcas de tiempo de padres](#touching-parent-timestamps)

<a name="introduction"></a>
## Introducción

Las tablas de una base de datos suelen estar relacionadas entre sí. Por ejemplo, una entrada de blog puede tener muchos comentarios o un pedido puede estar relacionado con el usuario que lo realizó. Eloquent facilita la gestión y el trabajo con estas relaciones, y soporta una gran variedad de relaciones comunes:

<div class="content-list" markdown="1">

- [Uno a uno - One To One](#one-to-one)
- [Uno a muchos - One To Many](#one-to-many)
- [Muchos a muchos - Many To Many](#many-to-many)
- [Tiene uno a través de - Has One Through](#has-one-through)
- [Tiene muchos a través de - Has Many Through](#has-many-through)
- [Uno a uno (polimórfico) - One To One (Polymorphic)](#one-to-one-polymorphic-relations)
- [De uno a muchos (polimórfico) - One To Many (Polymorphic)](#one-to-many-polymorphic-relations)
- [Muchos a muchos (polimórfico) - Many To Many (Polymorphic)](#many-to-many-polymorphic-relations)

</div>

<a name="defining-relationships"></a>
## Definición de relaciones

Las relaciones Eloquent se definen como métodos en sus clases modelo Eloquent. Dado que las relaciones también sirven como [constructores de consultas](/docs/{{version}}/queries), definir relaciones como métodos proporciona una gran capacidad de encadenamiento de métodos y consultas. Por ejemplo, podemos encadenar restricciones de consulta adicionales en esta relación `posts`:

    $user->posts()->where('active', 1)->get();

Pero, antes de sumergirnos demasiado en el uso de las relaciones, aprendamos a definir cada tipo de relación soportada por Eloquent.

<a name="one-to-one"></a>
### Uno a uno - One To One

Una relación uno a uno es un tipo muy básico de relación de base de datos. Por ejemplo, un modelo de `User` puede estar asociado a un modelo de `Phone`. Para definir esta relación, colocaremos un método `phone` en el modelo `User`. El método `phone` debe llamar al método `hasOne` y devolver su resultado. El método `hasOne` está disponible para su modelo a través de la clase base `Illuminate\Database\Eloquent\Model` del modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Get the phone associated with the user.
         */
        public function phone()
        {
            return $this->hasOne(Phone::class);
        }
    }

El primer argumento que se pasa al método `hasOne` es el nombre de la clase modelo relacionada. Una vez definida la relación, podemos recuperar el registro relacionado utilizando las propiedades dinámicas de Eloquent. Las propiedades dinámicas permiten acceder a los métodos de relación como si fueran propiedades definidas en el modelo:

    $phone = User::find(1)->phone;

Eloquent determina la clave externa de la relación basándose en el nombre del modelo padre. En este caso, se asume automáticamente que el modelo `Phone` tiene una clave externa `user_id`. Si desea sobreescribir esta convención, puede pasar un segundo argumento al método `hasOne`:

    return $this->hasOne(Phone::class, 'foreign_key');

Además, Eloquent asume que la clave externa debe tener un valor que coincida con la columna de clave primaria del padre. En otras palabras, Eloquent buscará el valor de la columna `id` del usuario en la columna `user_id` del registro `Phone`. Si desea que la relación utilice un valor de clave primaria distinto de `id` o de la propiedad `$primaryKey` de su modelo, puede pasar un tercer argumento al método `hasOne`:

    return $this->hasOne(Phone::class, 'foreign_key', 'local_key');

<a name="one-to-one-defining-the-inverse-of-the-relationship"></a>
#### Definición de la relación inversa

Así, podemos acceder al modelo `Phone` desde nuestro modelo `User`. A continuación, vamos a definir una relación en el modelo `Phone` que nos permitirá acceder al usuario propietario del teléfono. Podemos definir la inversa de una relación `hasOne` utilizando el método `belongsTo`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Phone extends Model
    {
        /**
         * Get the user that owns the phone.
         */
        public function user()
        {
            return $this->belongsTo(User::class);
        }
    }

Al invocar el método `user`, Eloquent intentará encontrar un modelo `User` que tenga un `id` que coincida con la columna `user_id` del modelo `Phone`.

Eloquent determina el nombre de la clave externa examinando el nombre del método de relación y añadiendo `_id` como sufijo al nombre del método. Así, en este caso, Eloquent asume que el modelo `Phone` tiene una columna `user_id`. Sin embargo, si la clave externa del modelo `Phone` no es `user_id`, puede pasar un nombre de clave personalizado como segundo argumento del método `belongsTo`:

    /**
     * Get the user that owns the phone.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'foreign_key');
    }

Si el modelo padre no utiliza `id` como clave principal, o desea encontrar el modelo asociado utilizando una columna diferente, puede pasar un tercer argumento al método `belongsTo` especificando la clave personalizada de la tabla padre:

    /**
     * Get the user that owns the phone.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'foreign_key', 'owner_key');
    }

<a name="one-to-many"></a>
### Uno a muchos - One To Many

Una relación uno a muchos se utiliza para definir relaciones en las que un único modelo es el padre de uno o más modelos hijos. Por ejemplo, una entrada de blog puede tener un número infinito de comentarios. Al igual que el resto de relaciones de Eloquent, las relaciones uno a muchos se definen definiendo un método en el modelo de Eloquent:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Post extends Model
    {
        /**
         * Get the comments for the blog post.
         */
        public function comments()
        {
            return $this->hasMany(Comment::class);
        }
    }

Recuerde que Eloquent determinará automáticamente la columna de clave externa adecuada para el modelo `Comment`. Por convención, Eloquent tomará el nombre "snake case" del modelo padre y le añadirá el sufijo `_id`. Así, en este ejemplo, Eloquent asumirá que la columna de clave externa del modelo `Comment` es `post_id`.

Una vez definido el método de relación, podemos acceder a la [colección](/docs/{{version}}/eloquent-collections) de comentarios relacionados accediendo a la propiedad `comments`. Recuerda que, como Eloquent proporciona "propiedades de relación dinámicas", podemos acceder a los métodos de relación como si estuvieran definidos como propiedades en el modelo:

    use App\Models\Post;

    $comments = Post::find(1)->comments;

    foreach ($comments as $comment) {
        //
    }

Puesto que todas las relaciones sirven también como constructores de consultas, puede añadir más restricciones a la consulta de la relación llamando al método `comments` y continuando la cadena de condiciones en la consulta:

    $comment = Post::find(1)->comments()
                        ->where('title', 'foo')
                        ->first();

Al igual que con el método `hasOne`, también puedes sobreescribir las claves externas y locales pasando argumentos adicionales al método `hasMany`:

    return $this->hasMany(Comment::class, 'foreign_key');

    return $this->hasMany(Comment::class, 'foreign_key', 'local_key');

<a name="one-to-many-inverse"></a>
### Uno a muchos (inverso) / Pertenece a

Ahora que podemos acceder a todos los comentarios de una entrada, definamos una relación que permita a un comentario acceder a su entrada padre. Para definir la inversa de una relación `hasMany`, define un método de relación en el modelo hijo que llame al método `belongsTo`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Comment extends Model
    {
        /**
         * Get the post that owns the comment.
         */
        public function post()
        {
            return $this->belongsTo(Post::class);
        }
    }

Una vez definida la relación, podemos recuperar el post padre de un comentario accediendo a la "propiedad de relación dinámica" `post`:

    use App\Models\Comment;

    $comment = Comment::find(1);

    return $comment->post->title;

En el ejemplo anterior, Eloquent intentará encontrar un modelo `Post` que tenga un `id` que coincida con la columna `post_id` del modelo `Comment`.

Eloquent determina el nombre de la clave externa por defecto examinando el nombre del método de relación y añadiendo al nombre del método el sufijo `_` seguido del nombre de la columna de clave primaria del modelo padre. Así, en este ejemplo, Eloquent asumirá que la clave externa del modelo `Post` en la tabla de `comments` es `post_id`.

Sin embargo, si la clave externa de su relación no sigue estas convenciones, puede pasar un nombre de clave externa personalizado como segundo argumento del método `belongsTo`:

    /**
     * Get the post that owns the comment.
     */
    public function post()
    {
        return $this->belongsTo(Post::class, 'foreign_key');
    }

Si su modelo padre no utiliza `id` como clave principal, o desea encontrar el modelo asociado utilizando una columna diferente, puede pasar un tercer argumento al método `belongsTo` especificando la clave personalizada de su tabla padre:

    /**
     * Get the post that owns the comment.
     */
    public function post()
    {
        return $this->belongsTo(Post::class, 'foreign_key', 'owner_key');
    }

<a name="default-models"></a>
#### Modelos por defecto

Las relaciones `belongsTo`, `hasOne`, `hasOneThrough` y `morphOne` permiten definir un modelo predeterminado que se devolverá si la relación dada es `null`. Este patrón se conoce a menudo como [patrón de objeto null](https://en.wikipedia.org/wiki/Null_Object_pattern) y puede ayudar a eliminar comprobaciones condicionales en el código. En el siguiente ejemplo, la relación `user` devolverá un modelo `App\Models\User` vacío si no hay ningún usuario adjunto al modelo `Post`:

    /**
     * Get the author of the post.
     */
    public function user()
    {
        return $this->belongsTo(User::class)->withDefault();
    }

Para rellenar el modelo por defecto con atributos, puede pasar un array o closure al método `withDefault`:

    /**
     * Get the author of the post.
     */
    public function user()
    {
        return $this->belongsTo(User::class)->withDefault([
            'name' => 'Guest Author',
        ]);
    }

    /**
     * Get the author of the post.
     */
    public function user()
    {
        return $this->belongsTo(User::class)->withDefault(function ($user, $post) {
            $user->name = 'Guest Author';
        });
    }

<a name="querying-belongs-to-relationships"></a>
#### Consulta de relaciones belongsTo

Cuando consultes por los hijos de una relación "belongs to", puedes construir manualmente la cláusula `where` para recuperar los modelos Eloquent correspondientes:

    use App\Models\Post;

    $posts = Post::where('user_id', $user->id)->get();

Sin embargo, puede que le resulte más cómodo utilizar el método `whereBelongsTo`, que determinará automáticamente la relación adecuada y la clave externa para el modelo dado:

    $posts = Post::whereBelongsTo($user)->get();

También puedes proporcionar una [colección](/docs/{{version}}/eloquent-collections) al método `whereBelongsTo`. Al hacerlo, Laravel recuperará los modelos que pertenezcan a cualquiera de los modelos padre dentro de la colección:

    $users = User::where('vip', true)->get();

    $posts = Post::whereBelongsTo($users)->get();

Por defecto, Laravel determinará la relación asociada con el modelo dado basándose en el nombre de la clase del modelo; sin embargo, puedes especificar el nombre de la relación manualmente proporcionándolo como segundo argumento al método `whereBelongsTo`:

    $posts = Post::whereBelongsTo($user, 'author')->get();

<a name="has-one-of-many"></a>
### Tiene Uno De Muchos

A veces un modelo puede tener muchos modelos relacionados, pero se desea recuperar fácilmente el modelo "más reciente" o "más antiguo" de la relación. Por ejemplo, un modelo de `User` puede estar relacionado con muchos modelos de `Order`, pero usted quiere definir una manera conveniente de interactuar con el pedido más reciente que el usuario ha realizado. Para ello puede utilizar el tipo de relación `hasOne` combinado con los métodos `ofMany`:

```php
/**
 * Get the user's most recent order.
 */
public function latestOrder()
{
    return $this->hasOne(Order::class)->latestOfMany();
}
```

Del mismo modo, puede definir un método para recuperar el modelo "más antiguo", o el primer modelo relacionado de una relación:

```php
/**
 * Get the user's oldest order.
 */
public function oldestOrder()
{
    return $this->hasOne(Order::class)->oldestOfMany();
}
```

Por defecto, los métodos `latestOfMany` y `oldestOfMany` recuperarán el modelo relacionado más reciente o más antiguo basándose en la clave primaria del modelo, que debe ser ordenable. Sin embargo, a veces es posible que desee recuperar un único modelo de una relación más amplia utilizando un criterio de ordenación diferente.

Por ejemplo, utilizando el método `ofMany`, puede recuperar el pedido más caro del usuario. El método `ofMany` acepta la columna ordenable como primer argumento y qué función agregada (`min` o `max`) aplicar al consultar el modelo relacionado:

```php
/**
 * Get the user's largest order.
 */
public function largestOrder()
{
    return $this->hasOne(Order::class)->ofMany('price', 'max');
}
```

> **Advertencia**  
> Debido a que PostgreSQL no soporta la ejecución de la función `MAX` contra columnas UUID, actualmente no es posible utilizar relaciones uno-de-muchos en combinación con columnas UUID de PostgreSQL.

<a name="advanced-has-one-of-many-relationships"></a>
#### Relaciones "Tiene Una De Muchas" Avanzadas

Es posible construir relaciones "tiene uno de muchos" más avanzadas. Por ejemplo, un modelo de `Product` puede tener muchos modelos de `Price` asociados que se conservan en el sistema incluso después de que se publiquen nuevos precios. Además, los nuevos datos de precios para el producto pueden publicarse por adelantado para que entren en vigor en una fecha futura a través de una columna `published_at`.

Así que, en resumen, necesitamos recuperar el último precio publicado cuando la fecha de publicación no esté en el futuro. Además, si dos precios tienen la misma fecha de publicación, preferiremos el precio con el mayor ID. Para ello, debemos pasar un array al método `ofMany` que contenga las columnas ordenables que determinan el último precio. Además, se proporcionará un closure como segundo argumento al método `ofMany`. Este closure se encargará de añadir restricciones adicionales de fecha de publicación a la consulta de relación:

```php
/**
 * Get the current pricing for the product.
 */
public function currentPricing()
{
    return $this->hasOne(Price::class)->ofMany([
        'published_at' => 'max',
        'id' => 'max',
    ], function ($query) {
        $query->where('published_at', '<', now());
    });
}
```

<a name="has-one-through"></a>
### Tiene uno a través de - Has One Through

La relación "has-one-through" define una relación de uno a uno con otro modelo. Sin embargo, esta relación indica que el modelo declarante puede emparejarse con una instancia de otro modelo _pasando por_ un tercer modelo.

Por ejemplo, en una aplicación de taller de reparación de vehículos, cada modelo de `Mechanic` puede estar asociado a un modelo de `Car`, y cada modelo de `Car` puede estar asociado a un modelo de `Owner`. Aunque el mecánico y el propietario no tienen una relación directa dentro de la base de datos, el mecánico puede acceder al propietario _a través_ del modelo `Car`. Veamos las tablas necesarias para definir esta relación:

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

Ahora que hemos examinado la estructura de tablas para la relación, definamos la relación en el modelo `Mechanic`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Mechanic extends Model
    {
        /**
         * Get the car's owner.
         */
        public function carOwner()
        {
            return $this->hasOneThrough(Owner::class, Car::class);
        }
    }

El primer argumento pasado al método `hasOneThrough` es el nombre del modelo final al que deseamos acceder, mientras que el segundo argumento es el nombre del modelo intermedio.

<a name="has-one-through-key-conventions"></a>
#### Convenciones clave

Al realizar las consultas de la relación se utilizarán las convenciones típicas de Eloquent para claves externas. Si desea personalizar las claves de la relación, puede pasarlas como tercer y cuarto argumento al método `hasOneThrough`. El tercer argumento es el nombre de la clave ajena en el modelo intermedio. El cuarto argumento es el nombre de la clave externa en el modelo final. El quinto argumento es la clave local, mientras que el sexto argumento es la clave local del modelo intermedio:

    class Mechanic extends Model
    {
        /**
         * Get the car's owner.
         */
        public function carOwner()
        {
            return $this->hasOneThrough(
                Owner::class,
                Car::class,
                'mechanic_id', // Foreign key on the cars table...
                'car_id', // Foreign key on the owners table...
                'id', // Local key on the mechanics table...
                'id' // Local key on the cars table...
            );
        }
    }

<a name="has-many-through"></a>
### Tiene muchos a través de - Has Many Through

La relación "has-many-through" proporciona una forma cómoda de acceder a relaciones distantes a través de una relación intermedia. Por ejemplo, supongamos que estamos construyendo una plataforma de despliegue como [Laravel Vapor](https://vapor.laravel.com). Un modelo de `Project` podría acceder a muchos modelos de `Deployment` a través de un modelo intermedio de `Environment`. Usando este ejemplo, podrías reunir fácilmente todos los despliegues para un proyecto dado. Veamos las tablas necesarias para definir esta relación:

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

    class Project extends Model
    {
        /**
         * Get all of the deployments for the project.
         */
        public function deployments()
        {
            return $this->hasManyThrough(Deployment::class, Environment::class);
        }
    }

El primer argumento pasado al método `hasManyThrough` es el nombre del modelo final al que deseamos acceder, mientras que el segundo argumento es el nombre del modelo intermedio.

Aunque la tabla del modelo `Deployment` no contiene una columna `project_id`, la relación `hasManyThrough` proporciona acceso a los despliegues de un proyecto a través de `$project->deployments`. Para recuperar estos modelos, Eloquent inspecciona la columna `project_id` en la tabla intermedia del modelo `Environment`. Después de encontrar los IDs de entorno relevantes, se utilizan para consultar la tabla del modelo `Deployment`.

<a name="has-many-through-key-conventions"></a>
#### Convenciones sobre claves

Se utilizarán las convenciones típicas de claves externas de Eloquent al realizar las consultas de la relación. Si desea personalizar las claves de la relación, puede pasarlas como tercer y cuarto argumento al método `hasManyThrough`. El tercer argumento es el nombre de la clave ajena en el modelo intermedio. El cuarto argumento es el nombre de la clave externa en el modelo final. El quinto argumento es la clave local, mientras que el sexto argumento es la clave local del modelo intermedio:

    class Project extends Model
    {
        public function deployments()
        {
            return $this->hasManyThrough(
                Deployment::class,
                Environment::class,
                'project_id', // Foreign key on the environments table...
                'environment_id', // Foreign key on the deployments table...
                'id', // Local key on the projects table...
                'id' // Local key on the environments table...
            );
        }
    }

<a name="many-to-many"></a>
## Relaciones de Muchos a Muchos - Many To Many

Las relaciones many-to-many son ligeramente más complicadas que las relaciones `hasOne` y `hasMany`. Un ejemplo de una relación muchos-a-muchos es un usuario que tiene muchos roles y esos roles también son compartidos por otros usuarios en la aplicación. Por ejemplo, a un usuario se le puede asignar el rol de "Autor" y "Editor"; sin embargo, esos roles también pueden ser asignados a otros usuarios. Así, un usuario tiene muchos roles y un rol tiene muchos usuarios.

<a name="many-to-many-table-structure"></a>
#### Estructura de la tabla

Para definir esta relación, se necesitan tres tablas de base de datos: `users`, `roles` y `role_user`. La tabla `role_user` se deriva del orden alfabético de los nombres de los modelos relacionados y contiene las columnas `user_id` y `role_id`. Esta tabla se utiliza como tabla intermedia que vincula los usuarios y los roles.

Recuerde que, dado que un rol puede pertenecer a muchos usuarios, no podemos simplemente colocar una columna `user_id` en la tabla `roles`. Esto significaría que un rol sólo podría pertenecer a un único usuario. Para dar soporte a roles asignados a múltiples usuarios, se necesita la tabla `role_user`. Podemos resumir la estructura de tablas de la relación de la siguiente manera:

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
#### Estructura del modelo

Las relaciones muchos-a-muchos se definen escribiendo un método que devuelva el resultado del método `belongsToMany`. El método `belongsToMany` es proporcionado por la clase base `Illuminate\Database\Eloquent\Model` que es utilizada por todos los modelos Eloquent de su aplicación. Por ejemplo, definamos un método `roles` en nuestro modelo `User`. El primer argumento pasado a este método es el nombre de la clase modelo relacionada:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The roles that belong to the user.
         */
        public function roles()
        {
            return $this->belongsToMany(Role::class);
        }
    }

Una vez definida la relación, puede acceder a los roles del usuario utilizando la propiedad de relación dinámica `roles`:

    use App\Models\User;

    $user = User::find(1);

    foreach ($user->roles as $role) {
        //
    }

Dado que todas las relaciones también sirven como constructores de consultas, puede añadir más restricciones a la consulta de la relación llamando al método `roles` y continuando encadenando condiciones a la consulta:

    $roles = User::find(1)->roles()->orderBy('name')->get();

Para determinar el nombre de tabla de la tabla intermedia de la relación, Eloquent unirá los dos nombres de modelos relacionados en orden alfabético. Sin embargo, puede sobreescribir esta convención. Puede hacerlo pasando un segundo argumento al método `belongsToMany`:

    return $this->belongsToMany(Role::class, 'role_user');

Además de personalizar el nombre de la tabla intermedia, también puede personalizar los nombres de las columnas de las claves de la tabla pasando argumentos adicionales al método `belongsToMany`. El tercer argumento es el nombre de la clave externa del modelo en el que se está definiendo la relación, mientras que el cuarto argumento es el nombre de la clave externa del modelo al que se está uniendo:

    return $this->belongsToMany(Role::class, 'role_user', 'user_id', 'role_id');

<a name="many-to-many-defining-the-inverse-of-the-relationship"></a>
#### Definición de la relación inversa

Para definir la "inversa" de una relación `muchos-a-muchos`, debes definir un método en el modelo relacionado que también devuelva el resultado del método `belongsToMany`. Para completar nuestro ejemplo usuario / rol, definamos el método `users` en el modelo `Role`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Role extends Model
    {
        /**
         * The users that belong to the role.
         */
        public function users()
        {
            return $this->belongsToMany(User::class);
        }
    }

Como se puede ver, la relación se define exactamente igual que su contraparte en el modelo `User` con la excepción de hacer referencia al modelo `App\Models\User`. Dado que estamos reutilizando el método `belongsToMany`, todas las opciones habituales de personalización de tablas y claves están disponibles al definir la "inversa" de las relaciones muchos-a-muchos.

<a name="retrieving-intermediate-table-columns"></a>
### Recuperación de Columnas de Tablas Intermedias

Como ya ha aprendido, trabajar con relaciones muchos-a-muchos requiere la presencia de una tabla intermedia. Eloquent proporciona algunas formas muy útiles de interactuar con esta tabla. Por ejemplo, supongamos que nuestro modelo `User` tiene muchos modelos `Role` con los que está relacionado. Después de acceder a esta relación, podemos acceder a la tabla intermedia utilizando el atributo `pivot` de los modelos:

    use App\Models\User;

    $user = User::find(1);

    foreach ($user->roles as $role) {
        echo $role->pivot->created_at;
    }

Observe que a cada modelo de `Role` que recuperamos se le asigna automáticamente un atributo `pivot`. Este atributo contiene un modelo que representa la tabla intermedia.

Por defecto, sólo las claves del modelo estarán presentes en el modelo `pivot`. Si su tabla intermedia contiene atributos adicionales, deberá especificarlos al definir la relación:

    return $this->belongsToMany(Role::class)->withPivot('active', 'created_by');

Si desea que su tabla intermedia tenga fechas de `creación (created_at)` y `actualización (updated_at)` mantenidas automáticamente por Eloquent, llame al método `withTimestamps` cuando defina la relación:

    return $this->belongsToMany(Role::class)->withTimestamps();

> **Advertencia**  
> Las tablas intermedias que utilizan las marcas de tiempo mantenidas automáticamente por Eloquent deben tener columnas de marca de tiempo `created_at` y `updated_at`.

<a name="customizing-the-pivot-attribute-name"></a>
#### Personalización del nombre del atributo `pivot`

Como se ha indicado anteriormente, se puede acceder a los atributos de la tabla intermedia en los modelos a través del atributo `pivot`. Sin embargo, puedes personalizar el nombre de este atributo para que refleje mejor su propósito dentro de tu aplicación.

Por ejemplo, si su aplicación contiene usuarios que pueden suscribirse a podcasts, es probable que tenga una relación de muchos a muchos entre usuarios y podcasts. Si este es el caso, es posible que desee cambiar el nombre de su atributo de tabla intermedia a `subscription` en lugar de `pivot`. Para ello, utilice el método `as` al definir la relación:

    return $this->belongsToMany(Podcast::class)
                    ->as('subscription')
                    ->withTimestamps();

Una vez especificado el atributo personalizado de la tabla intermedia, puede acceder a los datos de la tabla intermedia utilizando el nombre personalizado:

    $users = User::with('podcasts')->get();

    foreach ($users->flatMap->podcasts as $podcast) {
        echo $podcast->subscription->created_at;
    }

<a name="filtering-queries-via-intermediate-table-columns"></a>
### Filtrado de consultas mediante columnas de tablas intermedias

También puede filtrar los resultados devueltos por las consultas de relación `belongsToMany` utilizando los métodos `wherePivot`, `wherePivotIn`, `wherePivotNotIn`, `wherePivotBetween`, `wherePivotNotBetween`, `wherePivotNull` y `wherePivotNotNull` al definir la relación:

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
### Ordenación de Consultas mediante Columnas de Tablas Intermedias

Puede ordenar los resultados devueltos por las consultas de relación `belongsToMany` utilizando el método `orderByPivot`. En el siguiente ejemplo, recuperaremos todas las últimas insignias (Badges) del usuario:

    return $this->belongsToMany(Badge::class)
                    ->where('rank', 'gold')
                    ->orderByPivot('created_at', 'desc');

<a name="defining-custom-intermediate-table-models"></a>
### Definición de Modelos Personalizados de Tablas Intermedias

Si desea definir un modelo personalizado para representar la tabla intermedia de su relación muchos-a-muchos, puede llamar al método `using` cuando defina la relación. Los modelos pivotantes personalizados te dan la oportunidad de definir comportamientos adicionales en el modelo pivotante, como métodos y lanzamientos.

Los modelos pivotantes personalizados de muchos a muchos deben extender la clase `Illuminate\Database\Eloquent\Relations\Pivot`, mientras que los modelos pivotantes polimórficos personalizados de muchos a muchos deben extender la clase `Illuminate\Database\Eloquent\Relations\MorphPivot`. Por ejemplo, podemos definir un modelo `Role` que utilice un modelo pivot personalizado `RoleUser`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Role extends Model
    {
        /**
         * The users that belong to the role.
         */
        public function users()
        {
            return $this->belongsToMany(User::class)->using(RoleUser::class);
        }
    }

Al definir el modelo `RoleUser`, debe extender la clase `Illuminate\Database\Eloquent\Relations\Pivot`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Relations\Pivot;

    class RoleUser extends Pivot
    {
        //
    }

> **Advertencia**  
> Los modelos pivotantes no pueden utilizar el trait `SoftDeletes`. Si necesita borrar suavemente registros pivotantes, considere convertir su modelo pivotante en un modelo real de Eloquent.

<a name="custom-pivot-models-and-incrementing-ids"></a>
#### Modelos dinámicos personalizados e incremento de ID

Si ha definido una relación de muchos a muchos que utiliza un modelo pivotante personalizado, y ese modelo pivotante tiene una clave primaria autoincrementable, debe asegurarse de que su clase de modelo pivotante personalizado define una propiedad `incrementing` que se establece en `true`.

    /**
     * Indicates if the IDs are auto-incrementing.
     *
     * @var bool
     */
    public $incrementing = true;

<a name="polymorphic-relationships"></a>
## Relaciones polimórficas

Una relación polimórfica permite que el modelo hijo pertenezca a más de un tipo de modelo utilizando una única asociación. Por ejemplo, imagine que está creando una aplicación que permite a los usuarios compartir entradas de blog y vídeos. En una aplicación de este tipo, un modelo `Comment` podría pertenecer a los modelos `Post` y `Video`.

<a name="one-to-one-polymorphic-relations"></a>
### Uno a uno (polimórfico) - One To One (Polymorphic)

<a name="one-to-one-polymorphic-table-structure"></a>
#### Estructura de la tabla

Una relación polimórfica uno a uno es similar a una típica relación uno a uno; sin embargo, el modelo hijo puede pertenecer a más de un tipo de modelo utilizando una única asociación. Por ejemplo, una `entrada de` blog y un `usuario` pueden compartir una relación polimórfica con un modelo de `imagen`. El uso de una relación polimórfica uno a uno le permite tener una única tabla de imágenes únicas que pueden estar asociadas con entradas y usuarios. Primero, examinemos la estructura de la tabla:

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

Observe las columnas `imageable_id` e `imageable_type` en la tabla `images`. La columna `imageable_id` contendrá el valor ID de la entrada o del usuario, mientras que la columna `imageable_type` contendrá el nombre de la clase del modelo padre. Eloquent utiliza la columna `imageable_type` para determinar qué "tipo" de modelo padre debe devolverse al acceder a la relación `imageable`. En este caso, la columna contendría `App\Models\Post` o `App\Models\User`.

<a name="one-to-one-polymorphic-model-structure"></a>
#### Estructura del modelo

A continuación, examinemos las definiciones de modelo necesarias para construir esta relación:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Image extends Model
    {
        /**
         * Get the parent imageable model (user or post).
         */
        public function imageable()
        {
            return $this->morphTo();
        }
    }

    class Post extends Model
    {
        /**
         * Get the post's image.
         */
        public function image()
        {
            return $this->morphOne(Image::class, 'imageable');
        }
    }

    class User extends Model
    {
        /**
         * Get the user's image.
         */
        public function image()
        {
            return $this->morphOne(Image::class, 'imageable');
        }
    }

<a name="one-to-one-polymorphic-retrieving-the-relationship"></a>
#### Recuperación de la relación

Una vez definidos la tabla y los modelos de la base de datos, puede acceder a las relaciones a través de los modelos. Por ejemplo, para recuperar la imagen de una entrada, podemos acceder a la propiedad de relación dinámica `imagen`:

    use App\Models\Post;

    $post = Post::find(1);

    $image = $post->image;

Puede recuperar el padre del modelo polimórfico accediendo al nombre del método que realiza la llamada a `morphTo`. En este caso, es el método `imageable` del modelo `Image`. Por lo tanto, accederemos a ese método como una propiedad de relación dinámica:

    use App\Models\Image;

    $image = Image::find(1);

    $imageable = $image->imageable;

La relación `imageable` en el modelo `Image` devolverá una instancia `Post` o `User`, dependiendo del tipo de modelo al que pertenezca la imagen.

<a name="morph-one-to-one-key-conventions"></a>
#### Convenciones sobre claves

Si es necesario, puede especificar el nombre de las columnas "id" y "type" utilizadas por su modelo hijo polimórfico. Si lo hace, asegúrese de pasar siempre el nombre de la relación como primer argumento al método `morphTo`. Normalmente, este valor debe coincidir con el nombre del método, por lo que puede utilizar la constante `__FUNCTION__` de PHP:

    /**
     * Get the model that the image belongs to.
     */
    public function imageable()
    {
        return $this->morphTo(__FUNCTION__, 'imageable_type', 'imageable_id');
    }

<a name="one-to-many-polymorphic-relations"></a>
### De uno a muchos (polimórfico) - One To Many (Polymorphic)

<a name="one-to-many-polymorphic-table-structure"></a>
#### Estructura de la tabla

Una relación polimórfica uno-a-muchos es similar a una típica relación uno-a-muchos; sin embargo, el modelo hijo puede pertenecer a más de un tipo de modelo utilizando una única asociación. Por ejemplo, imagine que los usuarios de su aplicación pueden "comentar" entradas y vídeos. Utilizando relaciones polimórficas, puede utilizar una única tabla de `comments` para contener los comentarios tanto de las entradas como de los vídeos. En primer lugar, examinemos la estructura de tablas necesaria para construir esta relación:

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
#### Estructura del modelo

A continuación, vamos a examinar las definiciones del modelo necesarias para construir esta relación:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Comment extends Model
    {
        /**
         * Get the parent commentable model (post or video).
         */
        public function commentable()
        {
            return $this->morphTo();
        }
    }

    class Post extends Model
    {
        /**
         * Get all of the post's comments.
         */
        public function comments()
        {
            return $this->morphMany(Comment::class, 'commentable');
        }
    }

    class Video extends Model
    {
        /**
         * Get all of the video's comments.
         */
        public function comments()
        {
            return $this->morphMany(Comment::class, 'commentable');
        }
    }

<a name="one-to-many-polymorphic-retrieving-the-relationship"></a>
#### Recuperación de la relación

Una vez definidos la tabla de base de datos y los modelos, puede acceder a las relaciones a través de las propiedades de relación dinámica del modelo. Por ejemplo, para acceder a todos los comentarios de una entrada, podemos utilizar la propiedad dinámica `comments`:

    use App\Models\Post;

    $post = Post::find(1);

    foreach ($post->comments as $comment) {
        //
    }

También puede recuperar el padre de un modelo hijo polimórfico accediendo al nombre del método que realiza la llamada a `morphTo`. En este caso, es el método `commentable` del modelo `Comment`. Por lo tanto, accederemos a ese método como una propiedad de relación dinámica para acceder al modelo padre del comentario:

    use App\Models\Comment;

    $comment = Comment::find(1);

    $commentable = $comment->commentable;

La relación `commentable` en el modelo `Comment` devolverá una instancia `Post` o `Video`, dependiendo de qué tipo de modelo sea el padre del comentario.

<a name="one-of-many-polymorphic-relations"></a>
### Uno de muchos (polimórfico) - One Of Many (Polymorphic)

A veces, un modelo puede tener muchos modelos relacionados y, sin embargo, se desea recuperar fácilmente el modelo relacionado "más reciente" o "más antiguo" de la relación. Por ejemplo, un modelo de `User` puede estar relacionado con muchos modelos de `Imagen`, pero usted quiere interactuar con la imagen más reciente que el usuario haya subido. Para ello puede utilizar el tipo de relación `morphOne` combinado con los métodos `ofMany`:

```php
/**
 * Get the user's most recent image.
 */
public function latestImage()
{
    return $this->morphOne(Image::class, 'imageable')->latestOfMany();
}
```

Del mismo modo, puede definir un método para recuperar el modelo "más antiguo", o el primer modelo relacionado de una relación:

```php
/**
 * Get the user's oldest image.
 */
public function oldestImage()
{
    return $this->morphOne(Image::class, 'imageable')->oldestOfMany();
}
```

Por defecto, los métodos `latestOfMany` y `oldestOfMany` recuperarán el modelo relacionado más reciente o más antiguo basándose en la clave primaria del modelo, que debe ser ordenable. Sin embargo, a veces es posible que desee recuperar un único modelo de una relación más amplia utilizando un criterio de ordenación diferente.

Por ejemplo, utilizando el método `ofMany`, puede recuperar la imagen que más le ha gustado al usuario. El método `ofMany` acepta la columna ordenable como primer argumento y la función agregada (`min` o `max`) que se debe aplicar al consultar el modelo relacionado:

```php
/**
 * Get the user's most popular image.
 */
public function bestImage()
{
    return $this->morphOne(Image::class, 'imageable')->ofMany('likes', 'max');
}
```

> **Nota**  
> Es posible construir relaciones "uno de muchos" más avanzadas. Para más información, consulte la [documentación has one of many](#advanced-has-one-of-many-relationships).

<a name="many-to-many-polymorphic-relations"></a>
### Muchos a muchos (polimórfico) - Many To Many (Polymorphic)

<a name="many-to-many-polymorphic-table-structure"></a>
#### Estructura de la tabla

Las relaciones polimórficas de muchos a muchos son ligeramente más complicadas que las relaciones "morph one" y "morph many". Por ejemplo, un modelo `Post` y un modelo `Video` podrían compartir una relación polimórfica con un modelo `Tag`. El uso de una relación polimórfica de muchos a muchos en esta situación permitiría a su aplicación tener una única tabla de etiquetas únicas que pueden estar asociadas con publicaciones o vídeos. En primer lugar, examinemos la estructura de tabla necesaria para crear esta relación:

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

> **Nota**  
> Antes de sumergirse en las relaciones polimórficas de muchos a muchos, puede que le resulte útil leer la documentación sobre las [relaciones normales de muchos a muchos](#many-to-many).

<a name="many-to-many-polymorphic-model-structure"></a>
#### Estructura del modelo

A continuación, estamos listos para definir las relaciones en los modelos. Los modelos `Post` y `Video` contendrán ambos un método `tags` que llama al método `morphToMany` proporcionado por la clase modelo base de Eloquent.

El método `morphToMany` acepta el nombre del modelo relacionado así como el "nombre de la relación". Basándonos en el nombre que asignamos al nombre de nuestra tabla intermedia y a las claves que contiene, nos referiremos a la relación como "taggable":

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Post extends Model
    {
        /**
         * Get all of the tags for the post.
         */
        public function tags()
        {
            return $this->morphToMany(Tag::class, 'taggable');
        }
    }

<a name="many-to-many-polymorphic-defining-the-inverse-of-the-relationship"></a>
#### Definición de la relación inversa

A continuación, en el modelo `Tag`, deberás definir un método para cada uno de sus posibles modelos padre. Así, en este ejemplo, definiremos un método `posts` y un método `videos`. Ambos métodos deben devolver el resultado del método `morphedByMany`.

El método `morphedByMany` acepta el nombre del modelo relacionado así como el "nombre de la relación". En base al nombre que asignamos a nuestra tabla intermedia y a las claves que contiene, nos referiremos a la relación como "taggable":

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Tag extends Model
    {
        /**
         * Get all of the posts that are assigned this tag.
         */
        public function posts()
        {
            return $this->morphedByMany(Post::class, 'taggable');
        }

        /**
         * Get all of the videos that are assigned this tag.
         */
        public function videos()
        {
            return $this->morphedByMany(Video::class, 'taggable');
        }
    }

<a name="many-to-many-polymorphic-retrieving-the-relationship"></a>
#### Recuperación de la relación

Una vez que la tabla de base de datos y los modelos están definidos, puede acceder a las relaciones a través de sus modelos. Por ejemplo, para acceder a todas las etiquetas de una entrada, puede utilizar la propiedad de relación dinámica `tags`:

    use App\Models\Post;

    $post = Post::find(1);

    foreach ($post->tags as $tag) {
        //
    }

Puede recuperar el padre de una relación polimórfica desde el modelo polimórfico hijo accediendo al nombre del método que realiza la llamada a `morphedByMany`. En este caso, se trata de los métodos `posts` o `videos` del modelo `Tag`:

    use App\Models\Tag;

    $tag = Tag::find(1);

    foreach ($tag->posts as $post) {
        //
    }

    foreach ($tag->videos as $video) {
        //
    }

<a name="custom-polymorphic-types"></a>
### Tipos Polimórficos Personalizados

Por defecto, Laravel utilizará el nombre completo de la clase para almacenar el "tipo" del modelo relacionado. Por ejemplo, dado el ejemplo de relación uno-a-muchos anterior, donde un modelo de `Comment` puede pertenecer a un modelo de `Post` o de `Video`, el `commentable_type` por defecto sería `App\Models\Post` o `App\Models\Video`, respectivamente. Sin embargo, puede que desee desacoplar estos valores de la estructura interna de su aplicación.

Por ejemplo, en lugar de utilizar los nombres de los modelos como el "tipo", podemos utilizar cadenas simples como `post` y `video`. De este modo, los valores polimórficos de la columna "tipo" de nuestra base de datos seguirán siendo válidos aunque se cambie el nombre de los modelos:

    use Illuminate\Database\Eloquent\Relations\Relation;

    Relation::enforceMorphMap([
        'post' => 'App\Models\Post',
        'video' => 'App\Models\Video',
    ]);

Puede llamar al método `enforceMorphMap` en el método `boot` de su clase `App\Providers\AppServiceProvider` o crear un proveedor de servicios independiente si lo desea.

Puede determinar el alias morph de un modelo dado en tiempo de ejecución utilizando el método `getMorphClass` del modelo. A la inversa, puedes determinar el nombre de clase completo asociado a un alias morph utilizando el método `Relation::getMorphedModel`:

    use Illuminate\Database\Eloquent\Relations\Relation;

    $alias = $post->getMorphClass();

    $class = Relation::getMorphedModel($alias);

> **Advertencia**  
> Cuando añada un "morph map" a su aplicación existente, cada valor de columna morphable `*_type` en su base de datos que todavía contenga una clase completamente cualificada necesitará ser convertida a su nombre "map".

<a name="dynamic-relationships"></a>
### Relaciones Dinámicas

Puede utilizar el método `resolveRelationUsing` para definir relaciones entre modelos Eloquent en tiempo de ejecución. Aunque no se suele recomendar para el desarrollo normal de aplicaciones, esto puede ser útil ocasionalmente al desarrollar paquetes Laravel.

El método `resolveRelationUsing` acepta el nombre de la relación deseada como primer argumento. El segundo argumento que se pasa al método debe ser un closure que acepte la instancia del modelo y devuelva una definición de relación válida de Eloquent. Normalmente, las relaciones dinámicas se configuran en el método `boot` de un [proveedor de servicios](/docs/{{version}}/providers):

    use App\Models\Order;
    use App\Models\Customer;

    Order::resolveRelationUsing('customer', function ($orderModel) {
        return $orderModel->belongsTo(Customer::class, 'customer_id');
    });

> **Advertencia**  
> Cuando definas relaciones dinámicas, proporciona siempre argumentos explícitos de nombre de clave a los métodos de relación de Eloquent.

<a name="querying-relations"></a>
## Consulta de Relaciones

Dado que todas las relaciones de Eloquent se definen mediante métodos, puede llamar a esos métodos para obtener una instancia de la relación sin ejecutar realmente una consulta para cargar los modelos relacionados. Además, todos los tipos de relaciones Eloquent también sirven como [constructores de consultas](/docs/{{version}}/queries), lo que le permite seguir encadenando restricciones a la consulta de relación antes de ejecutar finalmente la consulta SQL contra su base de datos.

Por ejemplo, imagina una aplicación de blog en la que un modelo `User` tiene muchos modelos `Post` asociados:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Get all of the posts for the user.
         */
        public function posts()
        {
            return $this->hasMany(Post::class);
        }
    }

Puede consultar la relación `posts` y añadir restricciones adicionales a la relación de esta forma:

    use App\Models\User;

    $user = User::find(1);

    $user->posts()->where('active', 1)->get();

Puedes utilizar cualquiera de los métodos del [constructor del consultas de Laravel](/docs/{{version}}/queries) en la relación, así que asegúrate de explorar la documentación del constructor de consultas para conocer todos los métodos disponibles.

<a name="chaining-orwhere-clauses-after-relationships"></a>
#### Encadenamiento de cláusulas `orWhere` tras relaciones

Como se muestra en el ejemplo anterior, puede añadir restricciones adicionales a las relaciones cuando las consulte. Sin embargo, tenga cuidado al encadenar cláusulas `orWhere` en una relación, ya que las cláusulas `orWhere` se agruparán lógicamente en el mismo nivel que la restricción de relación:

    $user->posts()
            ->where('active', 1)
            ->orWhere('votes', '>=', 100)
            ->get();

El ejemplo anterior generará el siguiente SQL. Como puede ver, la cláusula `or` indica a la consulta que devuelva _cualquier_ usuario con más de 100 votos. La consulta ya no está restringida a un usuario específico:

```sql
select *
from posts
where user_id = ? and active = 1 or votes >= 100
```

En la mayoría de las situaciones, debería utilizar [grupos lógicos](/docs/{{version}}/queries#logical-grouping) para agrupar las comprobaciones condicionales entre paréntesis:

    use Illuminate\Database\Eloquent\Builder;

    $user->posts()
            ->where(function (Builder $query) {
                return $query->where('active', 1)
                             ->orWhere('votes', '>=', 100);
            })
            ->get();

El ejemplo anterior generará el siguiente SQL. Observe que la agrupación lógica ha agrupado correctamente las restricciones y la consulta sigue estando restringida a un usuario específico:

```sql
select *
from posts
where user_id = ? and (active = 1 or votes >= 100)
```

<a name="relationship-methods-vs-dynamic-properties"></a>
### Métodos de Relación vs. Propiedades Dinámicas

Si no necesita añadir restricciones adicionales a una consulta de relación de Eloquent, puede acceder a la relación como si fuera una propiedad. Por ejemplo, si seguimos utilizando nuestros modelos de ejemplo `User` y `Post`, podemos acceder a todas las publicaciones de un usuario de la siguiente manera:

    use App\Models\User;

    $user = User::find(1);

    foreach ($user->posts as $post) {
        //
    }

Las propiedades de relación dinámicas realizan una "carga perezosa", lo que significa que sólo cargarán sus datos de relación cuando realmente acceda a ellos. Por este motivo, los desarrolladores suelen utilizar la [precarga](#eager-loading) de las relaciones a las que saben que se accederá después de cargar el modelo. La carga anticipada reduce significativamente las consultas SQL que deben ejecutarse para cargar las relaciones de un modelo.

<a name="querying-relationship-existence"></a>
### Consulta de la Existencia de Relaciones

Al recuperar registros del modelo, puede que desee limitar los resultados en función de la existencia de una relación. Por ejemplo, imagine que desea recuperar todas las entradas del blog que tengan al menos un comentario. Para ello, puede pasar el nombre de la relación a los métodos `has` y `orHas`:

    use App\Models\Post;

    // Retrieve all posts that have at least one comment...
    $posts = Post::has('comments')->get();

También puede especificar un operador y un valor de recuento para personalizar aún más la consulta:

    // Retrieve all posts that have three or more comments...
    $posts = Post::has('comments', '>=', 3)->get();

Las sentencias `has` anidadas pueden construirse utilizando la notación "punto". Por ejemplo, puede recuperar todas las entradas que tengan al menos un comentario con al menos una imagen:

    // Retrieve posts that have at least one comment with images...
    $posts = Post::has('comments.images')->get();

Si necesitas aún más potencia, puedes utilizar los métodos `whereHas` y `orWhereHas` para definir restricciones de consulta adicionales en tus consultas `has`, como inspeccionar el contenido de un comentario:

    use Illuminate\Database\Eloquent\Builder;

    // Retrieve posts with at least one comment containing words like code%...
    $posts = Post::whereHas('comments', function (Builder $query) {
        $query->where('content', 'like', 'code%');
    })->get();

    // Retrieve posts with at least ten comments containing words like code%...
    $posts = Post::whereHas('comments', function (Builder $query) {
        $query->where('content', 'like', 'code%');
    }, '>=', 10)->get();

> **Advertencia**  
> Eloquent no admite actualmente consultas sobre la existencia de relaciones entre bases de datos. Las relaciones deben existir dentro de la misma base de datos.

<a name="inline-relationship-existence-queries"></a>
#### Consultas de existencia de relaciones en línea

Si desea consultar la existencia de una relación con una única y sencilla condición where adjunta a la consulta de relación, puede que le resulte más cómodo utilizar los métodos `whereRelation`, `orWhereRelation`, `whereMorphRelation` y `orWhereMorphRelation`. Por ejemplo, podemos consultar todas las entradas que tienen comentarios no aprobados:

    use App\Models\Post;

    $posts = Post::whereRelation('comments', 'is_approved', false)->get();

Por supuesto, al igual que las llamadas al método `where` del constructor de consultas, también puede especificar un operador:

    $posts = Post::whereRelation(
        'comments', 'created_at', '>=', now()->subHour()
    )->get();

<a name="querying-relationship-absence"></a>
### Consulta de Ausencia de Relación

Al recuperar registros modelo, puede que desee limitar sus resultados basándose en la ausencia de una relación. Por ejemplo, imagine que desea recuperar todas las entradas de blog que **no** tienen comentarios. Para ello, puede pasar el nombre de la relación a los métodos `doesntHave` y `orDoesntHave`:

    use App\Models\Post;

    $posts = Post::doesntHave('comments')->get();

Si necesita aún más potencia, puede utilizar los métodos `whereDoesntHave` y `orWhereDoesntHave` para añadir restricciones de consulta adicionales a sus consultas `doesntHave`, como inspeccionar el contenido de un comentario:

    use Illuminate\Database\Eloquent\Builder;

    $posts = Post::whereDoesntHave('comments', function (Builder $query) {
        $query->where('content', 'like', 'code%');
    })->get();

Puede utilizar la notación "punto" para ejecutar una consulta sobre una relación anidada. Por ejemplo, la siguiente consulta recuperará todas las entradas que no tengan comentarios; sin embargo, las entradas que tengan comentarios de autores que no estén vetados se incluirán en los resultados:

    use Illuminate\Database\Eloquent\Builder;

    $posts = Post::whereDoesntHave('comments.author', function (Builder $query) {
        $query->where('banned', 0);
    })->get();

<a name="querying-morph-to-relationships"></a>
### Consulta de Relaciones Morph To

Para consultar la existencia de relaciones "morph to", puede utilizar los métodos `whereHasMorph` y `whereDoesntHaveMorph`. Estos métodos aceptan el nombre de la relación como primer argumento. A continuación, los métodos aceptan los nombres de los modelos relacionados que desea incluir en la consulta. Por último, puede proporcionar un closure que personalice la consulta de la relación:

    use App\Models\Comment;
    use App\Models\Post;
    use App\Models\Video;
    use Illuminate\Database\Eloquent\Builder;

    // Retrieve comments associated to posts or videos with a title like code%...
    $comments = Comment::whereHasMorph(
        'commentable',
        [Post::class, Video::class],
        function (Builder $query) {
            $query->where('title', 'like', 'code%');
        }
    )->get();

    // Retrieve comments associated to posts with a title not like code%...
    $comments = Comment::whereDoesntHaveMorph(
        'commentable',
        Post::class,
        function (Builder $query) {
            $query->where('title', 'like', 'code%');
        }
    )->get();

En ocasiones puede ser necesario añadir restricciones de consulta basadas en el "tipo" del modelo polimórfico relacionado. El closure pasado al método `whereHasMorph` puede recibir un valor `$type` como segundo argumento. Este argumento permite inspeccionar el "tipo" de la consulta que se está construyendo:

    use Illuminate\Database\Eloquent\Builder;

    $comments = Comment::whereHasMorph(
        'commentable',
        [Post::class, Video::class],
        function (Builder $query, $type) {
            $column = $type === Post::class ? 'content' : 'title';

            $query->where($column, 'like', 'code%');
        }
    )->get();

<a name="querying-all-morph-to-related-models"></a>
#### Consulta de todos los modelos relacionados

En lugar de pasar un array de posibles modelos polimórficos, puede proporcionar `*` como valor comodín. Esto le indicará a Laravel que recupere todos los tipos polimórficos posibles de la base de datos. Laravel ejecutará una consulta adicional para realizar esta operación:

    use Illuminate\Database\Eloquent\Builder;

    $comments = Comment::whereHasMorph('commentable', '*', function (Builder $query) {
        $query->where('title', 'like', 'foo%');
    })->get();

<a name="aggregating-related-models"></a>
## Agregación de modelos relacionados

<a name="counting-related-models"></a>
### Recuento de modelos relacionados

A veces es posible que desee contar el número de modelos relacionados para una relación dada sin cargar realmente los modelos. Para ello, puede utilizar el método `withCount`. El método `withCount` colocará un atributo `{relation}_count` en los modelos resultantes:

    use App\Models\Post;

    $posts = Post::withCount('comments')->get();

    foreach ($posts as $post) {
        echo $post->comments_count;
    }

Al pasar un array al método `withCount`, puede añadir los "recuentos" de múltiples relaciones, así como añadir restricciones adicionales a las consultas:

    use Illuminate\Database\Eloquent\Builder;

    $posts = Post::withCount(['votes', 'comments' => function (Builder $query) {
        $query->where('content', 'like', 'code%');
    }])->get();

    echo $posts[0]->votes_count;
    echo $posts[0]->comments_count;

También puede poner un alias al resultado del recuento de la relación, permitiendo múltiples recuentos en la misma relación:

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
#### Carga de recuento diferida

Utilizando el método `loadCount`, puede cargar un recuento de relaciones después de que el modelo padre haya sido recuperado:

    $book = Book::first();

    $book->loadCount('genres');

Si necesita establecer restricciones adicionales en la consulta de recuento, puede pasar un array con las claves de las relaciones que desea contar. Los valores array deben ser closures que reciban la instancia del constructor de consultas:

    $book->loadCount(['reviews' => function ($query) {
        $query->where('rating', 5);
    }])

<a name="relationship-counting-and-custom-select-statements"></a>
#### Recuento de relaciones y sentencias select personalizadas

Si combina `withCount` con una sentencia `select`, asegúrese de llamar a `withCount` después del método `select`:

    $posts = Post::select(['title', 'body'])
                    ->withCount('comments')
                    ->get();

<a name="other-aggregate-functions"></a>
### Otras funciones de agregación

Además del método `withCount`, Eloquent proporciona los métodos `withMin`, `withMax`, `withAvg`, `withSum` y `withExists`. Estos métodos colocarán un atributo `{relation}_{function}_{column}` en los modelos resultantes:

    use App\Models\Post;

    $posts = Post::withSum('comments', 'votes')->get();

    foreach ($posts as $post) {
        echo $post->comments_sum_votes;
    }

Si desea acceder al resultado de la función agregada utilizando otro nombre, puede especificar su propio alias:

    $posts = Post::withSum('comments as total_comments', 'votes')->get();

    foreach ($posts as $post) {
        echo $post->total_comments;
    }

Al igual que el método `loadCount`, también existen versiones diferidas de estos métodos. Estas operaciones agregadas adicionales pueden realizarse sobre modelos Eloquent que ya han sido recuperados:

    $post = Post::first();

    $post->loadSum('comments', 'votes');

Si combina estos métodos agregados con una sentencia `select`, asegúrese de llamar a los métodos agregados después del método `select`:

    $posts = Post::select(['title', 'body'])
                    ->withExists('comments')
                    ->get();

<a name="counting-related-models-on-morph-to-relationships"></a>
### Recuento de modelos relacionados en relaciones Morph To

Si desea pre-cargar una relación "morph to", así como los recuentos de modelos relacionados para las diversas entidades que pueden ser devueltas por esa relación, puede utilizar el método `with` en combinación con el método `morphWithCount` de la relación `morphTo`.

En este ejemplo, vamos a suponer que los modelos `Photo` y `Post` pueden crear modelos `ActivityFeed`. Asumiremos que el modelo `ActivityFeed` define una relación "morph to" llamada `parentable` que nos permite recuperar el modelo padre `Photo` o `Post` para una instancia `ActivityFeed` dada. Adicionalmente, asumiremos que los modelos `Photo` "tienen muchos" modelos `Tag` y los modelos `Post` "tienen muchos" modelos `Comment`.

Ahora, imaginemos que queremos recuperar instancias de `ActivityFeed` y precargar los modelos `parentable` de cada instancia de `ActivityFeed`. Además, queremos recuperar el número de etiquetas que están asociadas con cada foto padre y el número de comentarios que están asociados con cada post padre:

    use Illuminate\Database\Eloquent\Relations\MorphTo;

    $activities = ActivityFeed::with([
        'parentable' => function (MorphTo $morphTo) {
            $morphTo->morphWithCount([
                Photo::class => ['tags'],
                Post::class => ['comments'],
            ]);
        }])->get();

<a name="morph-to-deferred-count-loading"></a>
#### Carga de recuentos diferidos

Supongamos que ya hemos recuperado un conjunto de modelos `ActivityFeed` y ahora queremos cargar los recuentos de relaciones anidadas para los distintos modelos `parentables` asociados a los activity feeds. Puede utilizar el método `loadMorphCount` para lograr esto:

    $activities = ActivityFeed::with('parentable')->get();

    $activities->loadMorphCount('parentable', [
        Photo::class => ['tags'],
        Post::class => ['comments'],
    ]);

<a name="eager-loading"></a>
## Pre Carga (Eager Loading)

Cuando se accede a las relaciones de Eloquent como propiedades, los modelos relacionados son "cargados perezosamente". Esto significa que los datos de la relación no se cargan hasta que se accede por primera vez a la propiedad. Sin embargo, Eloquent puede precargar las relaciones en el momento en que se consulta el modelo padre. La carga rápida alivia el problema de las consultas "N + 1". Para ilustrar el problema de consulta N + 1, considere un modelo `Book` que "pertenece a" un modelo `Autor`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Book extends Model
    {
        /**
         * Get the author that wrote the book.
         */
        public function author()
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

Este bucle ejecutará una consulta para recuperar todos los libros dentro de la tabla de la base de datos, luego otra consulta para cada libro con el fin de recuperar el autor del libro. Así, si tenemos 25 libros, el código anterior ejecutaría 26 consultas: una para el libro original, y 25 consultas adicionales para recuperar el autor de cada libro.

Afortunadamente, podemos utilizar la precarga para reducir esta operación a sólo dos consultas. Al crear una consulta, puede especificar qué relaciones deben cargarse mediante el método `with`:

    $books = Book::with('author')->get();

    foreach ($books as $book) {
        echo $book->author->name;
    }

Para esta operación, sólo se ejecutarán dos consultas: una para obtener todos los libros y otra para obtener todos los autores de todos los libros:

```sql
select * from books

select * from authors where id in (1, 2, 3, 4, 5, ...)
```

<a name="eager-loading-multiple-relationships"></a>
#### Carga rápida de múltiples relaciones

A veces puede ser necesario cargar varias relaciones. Para ello, basta con pasar un array de relaciones al método `with`:

    $books = Book::with(['author', 'publisher'])->get();

<a name="nested-eager-loading"></a>
#### Precarga anidada

Para precargar las relaciones de una relación, puede utilizar la sintaxis "punto". Por ejemplo, precarguemos todos los autores del libro y todos los contactos personales del autor:

    $books = Book::with('author.contacts')->get();

De manera alternativa, puedes especificar relaciones anidadas de carga rápida proporcionando un array anidado al método `with`, lo que puede ser conveniente cuando se cargan múltiples relaciones anidadas:

    $books = Book::with([
        'author' => [
            'contacts',
            'publisher',
        ],
    ])->get();

<a name="nested-eager-loading-morphto-relationships"></a>
#### Precarga anidada de relaciones `morphTo`

Si desea precargar una relación `morphTo`, así como relaciones anidadas en varias entidades que pueden ser devueltas por esa relación, puede utilizar el método `with` en combinación con el método `morphWith` de la relación `morphTo`. Para ayudar a ilustrar este método, consideremos el siguiente modelo:

    <?php

    use Illuminate\Database\Eloquent\Model;

    class ActivityFeed extends Model
    {
        /**
         * Get the parent of the activity feed record.
         */
        public function parentable()
        {
            return $this->morphTo();
        }
    }

En este ejemplo, asumamos que los modelos `Event`, `Photo` y `Post` pueden crear modelos `ActivityFeed`. Además, supongamos que los modelos de `Event` pertenecen a un modelo de `Calendar`, los modelos de `Foto` están asociados a modelos de `Tag` y los modelos de `Post` pertenecen a un modelo de `Author`.

Usando estas definiciones de modelo y relaciones, podemos recuperar instancias del modelo `ActivityFeed` y cargar todos los modelos `parentables` y sus respectivas relaciones anidadas:

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
#### Carga de Columnas Específicas

Puede que no siempre necesite todas las columnas de las relaciones que está recuperando. Por este motivo, Eloquent le permite especificar qué columnas de la relación desea recuperar:

    $books = Book::with('author:id,name,book_id')->get();

> **Advertencia**  
> Al utilizar esta función, debe incluir siempre la columna `id` y cualquier columna de clave externa relevante en la lista de columnas que desea recuperar.

<a name="eager-loading-by-default"></a>
#### Precarga por defecto

A veces es posible que desee cargar siempre algunas relaciones al recuperar un modelo. Para ello, puede definir una propiedad `$with` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Book extends Model
    {
        /**
         * The relationships that should always be loaded.
         *
         * @var array
         */
        protected $with = ['author'];

        /**
         * Get the author that wrote the book.
         */
        public function author()
        {
            return $this->belongsTo(Author::class);
        }

        /**
         * Get the genre of the book.
         */
        public function genre()
        {
            return $this->belongsTo(Genre::class);
        }
    }

Si desea eliminar un elemento de la propiedad `$with` para una sola consulta, puede utilizar el método `without`:

    $books = Book::without('author')->get();

Si desea sobreescribir todos los elementos de la propiedad `$with` para una sola consulta, puede utilizar el método `withOnly`:

    $books = Book::withOnly('genre')->get();

<a name="constraining-eager-loads"></a>
### Restricciones de la precarga

A veces puede que desee precargar una relación pero también especificar condiciones adicionales para la consulta. Puede conseguirlo pasando un array de relaciones al método `with` donde la clave array es el nombre de la relación y el valor del array es un closure que añade restricciones adicionales a la consulta de carga rápida:

    use App\Models\User;

    $users = User::with(['posts' => function ($query) {
        $query->where('title', 'like', '%code%');
    }])->get();

En este ejemplo, Eloquent sólo cargará las entradas cuyo `title` contenga la palabra `code`. Puede llamar a otros métodos [del generador de consultas](/docs/{{version}}/queries) para personalizar aún más la operación de carga rápida:

    $users = User::with(['posts' => function ($query) {
        $query->orderBy('created_at', 'desc');
    }])->get();

> **Advertencia**  
> Los métodos de construcción de consultas `limit` y `take` no pueden utilizarse cuando se restringen cargas ansiosas.

<a name="constraining-eager-loading-of-morph-to-relationships"></a>
#### Restricción de la carga dinámica de relaciones `morphTo`

Si está realizando una carga rápida de una relación `morphTo`, Eloquent ejecutará varias consultas para obtener cada tipo de modelo relacionado. Puede añadir restricciones adicionales a cada una de estas consultas utilizando el método `constrain` de la relación `MorphTo`:

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Database\Eloquent\Relations\MorphTo;

    $comments = Comment::with(['commentable' => function (MorphTo $morphTo) {
        $morphTo->constrain([
            Post::class => function (Builder $query) {
                $query->whereNull('hidden_at');
            },
            Video::class => function (Builder $query) {
                $query->where('type', 'educational');
            },
        ]);
    }])->get();

En este ejemplo, Eloquent sólo precargará las entradas que no se hayan ocultado y los vídeos que tengan un valor de `type` "educativo".

<a name="constraining-eager-loads-with-relationship-existence"></a>
#### Restricción de cargas ansiosas con existencia de relación

Es posible que a veces necesite comprobar la existencia de una relación y, al mismo tiempo, cargar la relación basándose en las mismas condiciones. Por ejemplo, es posible que desee recuperar sólo los modelos de `User` que tienen modelos de `Post` secundarios que coincidan con una condición de consulta determinada y, al mismo tiempo, cargar las entradas que coincidan. Para ello puede utilizar el método `withWhereHas`:

    use App\Models\User;

    $users = User::withWhereHas('posts', function ($query) {
        $query->where('featured', true);
    })->get();

<a name="lazy-eager-loading"></a>
### Carga Perezosa (Lazy Eager Loading)

A veces puede ser necesario cargar una relación después de que el modelo padre haya sido recuperado. Por ejemplo, esto puede ser útil si necesita decidir dinámicamente si cargar modelos relacionados:

    use App\Models\Book;

    $books = Book::all();

    if ($someCondition) {
        $books->load('author', 'publisher');
    }

Si necesita establecer restricciones adicionales en la consulta de carga rápida, puede pasar un array con las claves de las relaciones que desea cargar. Los valores array deben ser instancias de closure que reciban la instancia de consulta:

    $author->load(['books' => function ($query) {
        $query->orderBy('published_date', 'asc');
    }]);

Para cargar una relación sólo cuando aún no se ha cargado, utilice el método `loadMissing`:

    $book->loadMissing('author');

<a name="nested-lazy-eager-loading-morphto"></a>
#### Carga Perezosa Anidada (Nested Lazy Eager Loading) & `morphTo`

Si desea cargar  una relación `morphTo`, así como relaciones anidadas en las distintas entidades que pueden ser devueltas por esa relación, puede utilizar el método `loadMorph`.

Este método acepta el nombre de la relación `morphTo` como primer argumento, y un array de pares modelo / relación como segundo argumento. Para ayudar a ilustrar este método, consideremos el siguiente modelo:

    <?php

    use Illuminate\Database\Eloquent\Model;

    class ActivityFeed extends Model
    {
        /**
         * Get the parent of the activity feed record.
         */
        public function parentable()
        {
            return $this->morphTo();
        }
    }

En este ejemplo, supongamos que los modelos de `Event`, `Photo` y `Post` pueden crear modelos `ActivityFeed`. Además, supongamos que los modelos `Event` pertenecen a un modelo `Calendar`, los modelos `Foto` están asociados a modelos `Tag` y los modelos `Post` pertenecen a un modelo `Author`.

Usando estas definiciones de modelo y relaciones, podemos recuperar instancias del modelo `ActivityFeed` y cargar todos los modelos `parentables` y sus respectivas relaciones anidadas:

    $activities = ActivityFeed::with('parentable')
        ->get()
        ->loadMorph('parentable', [
            Event::class => ['calendar'],
            Photo::class => ['tags'],
            Post::class => ['author'],
        ]);

<a name="preventing-lazy-loading"></a>
### Prevención de la carga lenta

Como se ha comentado anteriormente, la precarga de relaciones a menudo proporciona importantes beneficios de rendimiento a su aplicación. Por lo tanto, si lo desea, puede instruir a Laravel para evitar siempre la carga perezosa de las relaciones. Para ello, puede invocar el método `preventLazyLoading` que ofrece la clase modelo base de Eloquent. Por lo general, deberías llamar a este método dentro del método `boot` de la clase `AppServiceProvider` de tu aplicación.

El método `preventLazyLoading` acepta un argumento booleano opcional que indica si se debe evitar la carga perezosa. Por ejemplo, usted puede desear deshabilitar la carga perezosa solamente en entornos de no-producción para que su entorno de producción continúe funcionando incluso si una relación cargada perezosa está accidentalmente presente en el código de producción:

```php
use Illuminate\Database\Eloquent\Model;

/**
 * Bootstrap any application services.
 *
 * @return void
 */
public function boot()
{
    Model::preventLazyLoading(! $this->app->isProduction());
}
```

Después de evitar la carga perezosa, Eloquent lanzará una excepción `Illuminate\Database\LazyLoadingViolationException` cuando su aplicación intente realizar una carga perezosa de cualquier relación de Eloquent.

Puedes personalizar el comportamiento de las violaciones de carga perezosa utilizando el método `handleLazyLoadingViolationsUsing`. Por ejemplo, utilizando este método, puedes indicar a las violaciones de carga perezosa que sólo se registren en lugar de interrumpir la ejecución de la aplicación con excepciones:

```php
Model::handleLazyLoadingViolationUsing(function ($model, $relation) {
    $class = get_class($model);

    info("Attempted to lazy load [{$relation}] on model [{$class}].");
});
```

<a name="inserting-and-updating-related-models"></a>
## Inserción y actualización de modelos relacionados

<a name="the-save-method"></a>
### El método `save`

Eloquent proporciona métodos convenientes para añadir nuevos modelos a las relaciones. Por ejemplo, quizás necesites añadir un nuevo comentario a un post. En lugar de establecer manualmente el atributo `post_id` en el modelo `Comment` puedes insertar el comentario utilizando el método `save` de la relación:

    use App\Models\Comment;
    use App\Models\Post;

    $comment = new Comment(['message' => 'A new comment.']);

    $post = Post::find(1);

    $post->comments()->save($comment);

Observe que no hemos accedido a la relación `comments` como una propiedad dinámica. En su lugar, hemos llamado al método `comments` para obtener una instancia de la relación. El método `save` añadirá automáticamente el valor `post_id` apropiado al nuevo modelo `Comment`.

Si necesita guardar múltiples modelos relacionados, puede utilizar el método `saveMany`:

    $post = Post::find(1);

    $post->comments()->saveMany([
        new Comment(['message' => 'A new comment.']),
        new Comment(['message' => 'Another new comment.']),
    ]);

Los métodos `save` y `saveMany` persistirán las instancias de modelo dadas, pero no añadirán los nuevos modelos persistidos a ninguna relación en memoria que ya esté cargada en el modelo padre. Si planea acceder a la relación después de utilizar los métodos `save` o `saveMany`, puede utilizar el método `refresh` para recargar el modelo y sus relaciones:

    $post->comments()->save($comment);

    $post->refresh();

    // All comments, including the newly saved comment...
    $post->comments;

<a name="the-push-method"></a>
#### Guardar recursivamente modelos y relaciones

Si desea `guardar` su modelo y todas sus relaciones asociadas, puede utilizar el método `push`. En este ejemplo, el modelo `Post` se guardará así como sus comentarios y los autores de los comentarios:

    $post = Post::find(1);

    $post->comments[0]->message = 'Message';
    $post->comments[0]->author->name = 'Author Name';

    $post->push();

<a name="the-create-method"></a>
### Método de `creación`

Además de los métodos `save` y `saveMany`, también puedes utilizar el método `create`, que acepta un array de atributos, crea un modelo y lo inserta en la base de datos. La diferencia entre `save` y `create` es que `save` acepta una instancia completa del modelo Eloquent mientras que `create` acepta un `array` PHP plano. El modelo recién creado será devuelto por el método `create`:

    use App\Models\Post;

    $post = Post::find(1);

    $comment = $post->comments()->create([
        'message' => 'A new comment.',
    ]);

Puede utilizar el método `createMany` para crear múltiples modelos relacionados:

    $post = Post::find(1);

    $post->comments()->createMany([
        ['message' => 'A new comment.'],
        ['message' => 'Another new comment.'],
    ]);

También puede utilizar los métodos `findOrNew`, `firstOrNew`, `firstOrCreate` y `updateOrCreate` para [crear y actualizar modelos de relaciones](/docs/{{version}}/eloquent#upserts).

> **Nota**  
> Antes de utilizar el método `create`, asegúrese de revisar la documentación de [asignación masiva](/docs/{{version}}/eloquent#mass-assignment).

<a name="updating-belongs-to-relationships"></a>
### Relaciones de Pertenencia

Si desea asignar un modelo hijo a un nuevo modelo padre, puede utilizar el método `associate`. En este ejemplo, el modelo `User` define una relación `belongsTo` con el modelo `Account`. Este método `associate` establecerá la clave externa en el modelo hijo:

    use App\Models\Account;

    $account = Account::find(10);

    $user->account()->associate($account);

    $user->save();

Para eliminar un modelo padre de un modelo hijo, puede utilizar el método `dissociate`. Este método establecerá la clave externa de la relación en `null`:

    $user->account()->dissociate();

    $user->save();

<a name="updating-many-to-many-relationships"></a>
### Relaciones de muchos a muchos

<a name="attaching-detaching"></a>
#### Acoplar / Desacoplar

Eloquent también proporciona métodos para hacer más cómodo el trabajo con relaciones de muchos a muchos. Por ejemplo, imaginemos que un usuario puede tener muchos roles y un rol puede tener muchos usuarios. Puedes utilizar el método `attach` para adjuntar un rol a un usuario insertando un registro en la tabla intermedia de la relación:

    use App\Models\User;

    $user = User::find(1);

    $user->roles()->attach($roleId);

Cuando se adjunta una relación a un modelo, también se puede pasar un array de datos adicionales a insertar en la tabla intermedia:

    $user->roles()->attach($roleId, ['expires' => $expires]);

A veces puede ser necesario eliminar un rol de un usuario. Para eliminar un registro de una relación muchos a muchos, utilice el método `detach`. El método `detach` eliminará el registro correspondiente de la tabla intermedia; sin embargo, ambos modelos permanecerán en la base de datos:

    // Detach a single role from the user...
    $user->roles()->detach($roleId);

    // Detach all roles from the user...
    $user->roles()->detach();

Para mayor comodidad, `attach` y `detach` también aceptan matrices de IDs como entrada:

    $user = User::find(1);

    $user->roles()->detach([1, 2, 3]);

    $user->roles()->attach([
        1 => ['expires' => $expires],
        2 => ['expires' => $expires],
    ]);

<a name="syncing-associations"></a>
#### Sincronización de asociaciones

También puede utilizar el método `sync` para construir asociaciones de muchos a muchos. El método `sync` acepta una array de IDs para colocar en la tabla intermedia. Cualquier ID que no esté en el array dado será eliminado de la tabla intermedia. Por lo tanto, una vez completada esta operación, sólo existirán en la tabla intermedia los IDs de la array dada:

    $user->roles()->sync([1, 2, 3]);

También puede pasar valores adicionales de la tabla intermedia con los ID:

    $user->roles()->sync([1 => ['expires' => true], 2, 3]);

Si desea insertar los mismos valores de tabla intermedia con cada uno de los IDs de modelo sincronizados, puede utilizar el método `syncWithPivotValues`:

    $user->roles()->syncWithPivotValues([1, 2, 3], ['active' => true]);

Si no desea separar los ID existentes que faltan en la array dada, puede utilizar el método `syncWithoutDetaching`:

    $user->roles()->syncWithoutDetaching([1, 2, 3]);

<a name="toggling-associations"></a>
#### Conmutación de asociaciones

La relación muchos-a-muchos también proporciona un método `toggle` que "alterna" el estado de vinculación de los IDs de modelo relacionados dados. Si el ID en cuestión está actualmente vinculado, se desvinculará. Del mismo modo, si está desvinculado, se vinculará:

    $user->roles()->toggle([1, 2, 3]);

También puede pasar valores adicionales de la tabla intermedia con los ID:

    $user->roles()->toggle([
        1 => ['expires' => true],
        2 => ['expires' => true],
    ]);

<a name="updating-a-record-on-the-intermediate-table"></a>
#### Actualización de un registro en la tabla intermedia

Si necesita actualizar una fila existente en la tabla intermedia de su relación, puede utilizar el método `updateExistingPivot`. Este método acepta la clave externa del registro intermedio y una array de atributos para actualizar:

    $user = User::find(1);

    $user->roles()->updateExistingPivot($roleId, [
        'active' => false,
    ]);

<a name="touching-parent-timestamps"></a>
## Tocar marcas de tiempo de los padres

Cuando un modelo define una relación `belongsTo` o `belongsToMany` con otro modelo, como un `Comment` que pertenece a un `Post`, a veces es útil actualizar la marca de tiempo del modelo padre cuando se actualiza el modelo hijo.

Por ejemplo, cuando se actualiza un modelo de `Comment`, es posible que desee "tocar" automáticamente la marca de tiempo `updated_at` de la `Post` para que se ajuste a la fecha y hora actuales. Para ello, puede añadir una propiedad `touches` a su modelo hijo que contenga los nombres de las relaciones cuyas marcas de tiempo `updated_at` deben actualizarse cuando se actualice el modelo hijo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class Comment extends Model
    {
        /**
         * All of the relationships to be touched.
         *
         * @var array
         */
        protected $touches = ['post'];

        /**
         * Get the post that the comment belongs to.
         */
        public function post()
        {
            return $this->belongsTo(Post::class);
        }
    }

> **Advertencia**  
> Las marcas de tiempo del modelo padre sólo se actualizarán si el modelo hijo se actualiza utilizando el método `save` de Eloquent.
