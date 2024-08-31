# Eloquent: Factories

- [Introducción](#introduction)
- [Definiendo Fábricas de Modelos](#defining-model-factories)
  - [Generando Fábricas](#generating-factories)
  - [Estados de Fábrica](#factory-states)
  - [Callbacks de Fábrica](#factory-callbacks)
- [Creando Modelos Usando Fábricas](#creating-models-using-factories)
  - [Instanciando Modelos](#instantiating-models)
  - [Persistiendo Modelos](#persisting-models)
  - [Secuencias](#sequences)
- [Relaciones de Fábrica](#factory-relationships)
  - [Relaciones Has Many](#has-many-relationships)
  - [Relaciones Belongs To](#belongs-to-relationships)
  - [Relaciones Many to Many](#many-to-many-relationships)
  - [Relaciones Polimórficas](#polymorphic-relationships)
  - [Definiendo Relaciones Dentro de Fábricas](#defining-relationships-within-factories)
  - [Reciclando un Modelo Existente para Relaciones](#recycling-an-existing-model-for-relationships)

<a name="introduction"></a>
## Introducción

Al probar tu aplicación o poblar tu base de datos, es posible que necesites insertar algunos registros en tu base de datos. En lugar de especificar manualmente el valor de cada columna, Laravel te permite definir un conjunto de atributos predeterminados para cada uno de tus [modelos Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent) utilizando fábricas de modelos.
Para ver un ejemplo de cómo escribir una fábrica, echa un vistazo al archivo `database/factories/UserFactory.php` en tu aplicación. Esta fábrica se incluye con todas las nuevas aplicaciones Laravel y contiene la siguiente definición de fábrica:


```php
namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'remember_token' => Str::random(10),
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
```
Como puedes ver, en su forma más básica, las fábricas son clases que extienden la clase base de fábrica de Laravel y definen un método `definition`. El método `definition` devuelve el conjunto de valores de atributo predeterminados que deben aplicarse al crear un modelo utilizando la fábrica.
A través del helper `fake`, las fábricas tienen acceso a la biblioteca PHP [Faker](https://github.com/FakerPHP/Faker), que te permite generar de manera conveniente varios tipos de datos aleatorios para pruebas y llenado de bases de datos.
> [!NOTE]
Puedes cambiar la configuración regional de Faker de tu aplicación actualizando la opción `faker_locale` en tu archivo de configuración `config/app.php`.

<a name="defining-model-factories"></a>
## Definiendo Fábricas de Modelos


<a name="generating-factories"></a>
### Generando Fábricas

Para crear una fábrica, ejecuta el comando `make:factory` [Artisan](/docs/%7B%7Bversion%7D%7D/artisan):


```shell
php artisan make:factory PostFactory

```
La nueva clase de fábrica se colocará en tu directorio `database/factories`.

<a name="factory-and-model-discovery-conventions"></a>
#### Convenciones de Descubrimiento de Modelos y Fábricas

Una vez que hayas definido tus fábricas, puedes usar el método estático `factory` que proporcionan tus modelos a través del rasgo `Illuminate\Database\Eloquent\Factories\HasFactory` para instanciar una instancia de la fábrica para ese modelo.
El método `factory` del rasgo `HasFactory` utilizará convenciones para determinar la fábrica adecuada para el modelo al que se le asigna el rasgo. Específicamente, el método buscará una fábrica en el espacio de nombres `Database\Factories` que tenga un nombre de clase que coincida con el nombre del modelo y esté con el sufijo `Factory`. Si estas convenciones no se aplican a su aplicación o fábrica en particular, puede sobrescribir el método `newFactory` en su modelo para devolver una instancia de la fábrica correspondiente del modelo directamente:


```php
use Illuminate\Database\Eloquent\Factories\Factory;
use Database\Factories\Administration\FlightFactory;

/**
 * Create a new factory instance for the model.
 */
protected static function newFactory(): Factory
{
    return FlightFactory::new();
}
```
Luego, define una propiedad `model` en la fábrica correspondiente:


```php
use App\Administration\Flight;
use Illuminate\Database\Eloquent\Factories\Factory;

class FlightFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var class-string<\Illuminate\Database\Eloquent\Model>
     */
    protected $model = Flight::class;
}
```

<a name="factory-states"></a>
### Estados de fábrica

Los métodos de manipulación del estado te permiten definir modificaciones discretas que se pueden aplicar a tus fábricas de modelos en cualquier combinación. Por ejemplo, tu fábrica `Database\Factories\UserFactory` podría contener un método de estado `suspended` que modifica uno de sus valores de atributo predeterminados.
Los métodos de transformación de estado típicamente llaman al método `state` proporcionado por la clase base de factory de Laravel. El método `state` acepta una función anónima que recibirá el array de atributos en bruto definidos para la factory y debe devolver un array de atributos a modificar:


```php
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Indicate that the user is suspended.
 */
public function suspended(): Factory
{
    return $this->state(function (array $attributes) {
        return [
            'account_status' => 'suspended',
        ];
    });
}
```

<a name="trashed-state"></a>
#### Estado "Trashed"

Si tu modelo Eloquent puede ser [eliminado suavemente](/docs/%7B%7Bversion%7D%7D/eloquent#soft-deleting), puedes invocar el método de estado `trashed` incorporado para indicar que el modelo creado debería estar ya "eliminado suavemente". No necesitas definir manualmente el estado `trashed`, ya que está disponible automáticamente en todas las fábricas:


```php
use App\Models\User;

$user = User::factory()->trashed()->create();
```

<a name="factory-callbacks"></a>
### Callbacks de Factory

Los callbacks de Factory se registran utilizando los métodos `afterMaking` y `afterCreating` y te permiten realizar tareas adicionales después de crear o fabricar un modelo. Debes registrar estos callbacks definiendo un método `configure` en tu clase de factory. Este método será llamado automáticamente por Laravel cuando se instancie el factory:


```php
namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class UserFactory extends Factory
{
    /**
     * Configure the model factory.
     */
    public function configure(): static
    {
        return $this->afterMaking(function (User $user) {
            // ...
        })->afterCreating(function (User $user) {
            // ...
        });
    }

    // ...
}
```
También puedes registrar callbacks de fábrica dentro de métodos de estado para realizar tareas adicionales que sean específicas de un estado dado:


```php
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Indicate that the user is suspended.
 */
public function suspended(): Factory
{
    return $this->state(function (array $attributes) {
        return [
            'account_status' => 'suspended',
        ];
    })->afterMaking(function (User $user) {
        // ...
    })->afterCreating(function (User $user) {
        // ...
    });
}
```

<a name="creating-models-using-factories"></a>
## Creando Modelos Usando Fábricas


<a name="instantiating-models"></a>
### Instanciando Modelos

Una vez que hayas definido tus fábricas, puedes usar el método estático `factory` que proporcionan tus modelos mediante el trait `Illuminate\Database\Eloquent\Factories\HasFactory` para instanciar una instancia de fábrica para ese modelo. Veamos algunos ejemplos de creación de modelos. Primero, utilizaremos el método `make` para crear modelos sin persistirlos en la base de datos:


```php
use App\Models\User;

$user = User::factory()->make();
```
Puedes crear una colección de muchos modelos utilizando el método `count`:


```php
$users = User::factory()->count(3)->make();
```

<a name="applying-states"></a>
#### Aplicando Estados

También puedes aplicar cualquiera de tus [estados](#factory-states) a los modelos. Si deseas aplicar múltiples transformaciones de estado a los modelos, puedes simplemente llamar a los métodos de transformación de estado directamente:


```php
$users = User::factory()->count(5)->suspended()->make();
```

<a name="overriding-attributes"></a>
#### Sobrescribiendo Atributos

Si deseas anular algunos de los valores predeterminados de tus modelos, puedes pasar un array de valores al método `make`. Solo los atributos especificados serán reemplazados mientras que el resto de los atributos permanecerán configurados en sus valores predeterminados según lo especificado por la fábrica:


```php
$user = User::factory()->make([
    'name' => 'Abigail Otwell',
]);
```
Alternativamente, el método `state` puede llamarse directamente en la instancia de la fábrica para realizar una transformación de estado en línea:


```php
$user = User::factory()->state([
    'name' => 'Abigail Otwell',
])->make();
```
> [!NOTE]
[La protección contra la asignación masiva](/docs/%7B%7Bversion%7D%7D/eloquent#mass-assignment) se desactiva automáticamente al crear modelos utilizando fábricas.

<a name="persisting-models"></a>
### Persistiendo Modelos

El método `create` instancia instancias del modelo y las persiste en la base de datos utilizando el método `save` de Eloquent:


```php
use App\Models\User;

// Create a single App\Models\User instance...
$user = User::factory()->create();

// Create three App\Models\User instances...
$users = User::factory()->count(3)->create();
```
Puedes anular los atributos de modelo predeterminados de la fábrica pasando un array de atributos al método `create`:


```php
$user = User::factory()->create([
    'name' => 'Abigail',
]);
```

<a name="sequences"></a>
### Secuencias

A veces es posible que desees alternar el valor de un atributo de modelo dado para cada modelo creado. Puedes lograr esto definiendo una transformación de estado como una secuencia. Por ejemplo, es posible que desees alternar el valor de una columna `admin` entre `Y` y `N` para cada usuario creado:


```php
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Sequence;

$users = User::factory()
                ->count(10)
                ->state(new Sequence(
                    ['admin' => 'Y'],
                    ['admin' => 'N'],
                ))
                ->create();
```
En este ejemplo, se crearán cinco usuarios con un valor `admin` de `Y` y se crearán cinco usuarios con un valor `admin` de `N`.
Si es necesario, puedes incluir una `función anónima` como un valor de secuencia. La `función anónima` se invocará cada vez que la secuencia necesite un nuevo valor:


```php
use Illuminate\Database\Eloquent\Factories\Sequence;

$users = User::factory()
                ->count(10)
                ->state(new Sequence(
                    fn (Sequence $sequence) => ['role' => UserRoles::all()->random()],
                ))
                ->create();
```
Dentro de una `función anónima` de secuencia, puedes acceder a las propiedades `$index` o `$count` en la instancia de la secuencia que se inyecta en la `función anónima`. La propiedad `$index` contiene el número de iteraciones a través de la secuencia que han ocurrido hasta ahora, mientras que la propiedad `$count` contiene el número total de veces que se invocará la secuencia:


```php
$users = User::factory()
                ->count(10)
                ->sequence(fn (Sequence $sequence) => ['name' => 'Name '.$sequence->index])
                ->create();
```
Para conveniencia, las secuencias también se pueden aplicar utilizando el método `sequence`, que simplemente invoca el método `state` internamente. El método `sequence` acepta una función anónima o arreglos de atributos secuenciados:


```php
$users = User::factory()
                ->count(2)
                ->sequence(
                    ['name' => 'First User'],
                    ['name' => 'Second User'],
                )
                ->create();
```

<a name="factory-relationships"></a>
## Relaciones de Factory


<a name="has-many-relationships"></a>
### Relaciones de Has Many

A continuación, exploremos la construcción de relaciones de modelo Eloquent utilizando los métodos de fábrica fluentes de Laravel. Primero, supongamos que nuestra aplicación tiene un modelo `App\Models\User` y un modelo `App\Models\Post`. Además, supongamos que el modelo `User` define una relación `hasMany` con `Post`. Podemos crear un usuario que tenga tres publicaciones utilizando el método `has` proporcionado por las fábricas de Laravel. El método `has` acepta una instancia de fábrica:


```php
use App\Models\Post;
use App\Models\User;

$user = User::factory()
            ->has(Post::factory()->count(3))
            ->create();
```
Por convención, al pasar un modelo `Post` al método `has`, Laravel asumirá que el modelo `User` debe tener un método `posts` que defina la relación. Si es necesario, puedes especificar explícitamente el nombre de la relación que te gustaría manipular:


```php
$user = User::factory()
            ->has(Post::factory()->count(3), 'posts')
            ->create();
```
Por supuesto, puedes realizar manipulaciones de estado en los modelos relacionados. Además, puedes pasar una transformación de estado basada en una función anónima si tu cambio de estado requiere acceso al modelo padre:


```php
$user = User::factory()
            ->has(
                Post::factory()
                        ->count(3)
                        ->state(function (array $attributes, User $user) {
                            return ['user_type' => $user->type];
                        })
            )
            ->create();
```

<a name="has-many-relationships-using-magic-methods"></a>
Para mayor comodidad, puedes usar los métodos de relación mágicos de la fábrica de Laravel para construir relaciones. Por ejemplo, el siguiente ejemplo utilizará la convención para determinar que los modelos relacionados deben ser creados a través de un método de relación `posts` en el modelo `User`:


```php
$user = User::factory()
            ->hasPosts(3)
            ->create();
```
Al usar métodos mágicos para crear relaciones de fábrica, puedes pasar un array de atributos para sobrescribir en los modelos relacionados:


```php
$user = User::factory()
            ->hasPosts(3, [
                'published' => false,
            ])
            ->create();
```
Puedes proporcionar una transformación de estado basada en una `función anónima` si tu cambio de estado requiere acceso al modelo padre:


```php
$user = User::factory()
            ->hasPosts(3, function (array $attributes, User $user) {
                return ['user_type' => $user->type];
            })
            ->create();
```

<a name="belongs-to-relationships"></a>
### Relaciones de Pertenencia

Ahora que hemos explorado cómo construir relaciones "tiene muchos" utilizando fábricas, exploremos la inversa de la relación. El método `for` se puede usar para definir el modelo padre al que pertenecen los modelos creados por la fábrica. Por ejemplo, podemos crear tres instancias del modelo `App\Models\Post` que pertenecen a un solo usuario:


```php
use App\Models\Post;
use App\Models\User;

$posts = Post::factory()
            ->count(3)
            ->for(User::factory()->state([
                'name' => 'Jessica Archer',
            ]))
            ->create();
```
Si ya tienes una instancia de modelo padre que debería estar asociada con los modelos que estás creando, puedes pasar la instancia del modelo al método `for`:


```php
$user = User::factory()->create();

$posts = Post::factory()
            ->count(3)
            ->for($user)
            ->create();
```

<a name="belongs-to-relationships-using-magic-methods"></a>
Para mayor comodidad, puedes usar los métodos de relación mágica de la fábrica de Laravel para definir relaciones de "pertenece a". Por ejemplo, el siguiente ejemplo usará la convención para determinar que las tres publicaciones deben pertenecer a la relación `user` en el modelo `Post`:


```php
$posts = Post::factory()
            ->count(3)
            ->forUser([
                'name' => 'Jessica Archer',
            ])
            ->create();
```

<a name="many-to-many-relationships"></a>
### Relaciones Many to Many

Al igual que las [relaciones uno a muchos](#has-many-relationships), las relaciones "muchos a muchos" pueden crearse utilizando el método `has`:


```php
use App\Models\Role;
use App\Models\User;

$user = User::factory()
            ->has(Role::factory()->count(3))
            ->create();
```

<a name="pivot-table-attributes"></a>
#### Atributos de la Tabla Pivot

Si necesitas definir atributos que deben establecerse en la tabla intermedia / pivot que vincula los modelos, puedes usar el método `hasAttached`. Este método acepta un array de nombres y valores de atributos de la tabla pivot como su segundo argumento:


```php
use App\Models\Role;
use App\Models\User;

$user = User::factory()
            ->hasAttached(
                Role::factory()->count(3),
                ['active' => true]
            )
            ->create();
```
Puedes proporcionar una transformación de estado basada en una función anónima si el cambio de estado requiere acceso al modelo relacionado:


```php
$user = User::factory()
            ->hasAttached(
                Role::factory()
                    ->count(3)
                    ->state(function (array $attributes, User $user) {
                        return ['name' => $user->name.' Role'];
                    }),
                ['active' => true]
            )
            ->create();
```
Si ya tienes instancias de modelo que te gustaría adjuntar a los modelos que estás creando, puedes pasar las instancias del modelo al método `hasAttached`. En este ejemplo, los mismos tres roles se adjuntarán a los tres usuarios:


```php
$roles = Role::factory()->count(3)->create();

$user = User::factory()
            ->count(3)
            ->hasAttached($roles, ['active' => true])
            ->create();
```

<a name="many-to-many-relationships-using-magic-methods"></a>
#### Usando Métodos Mágicos

Para conveniencia, puedes usar los métodos de relación mágicos de la fábrica de Laravel para definir relaciones muchos a muchos. Por ejemplo, el siguiente ejemplo utilizará la convención para determinar que los modelos relacionados deben ser creados a través de un método de relación `roles` en el modelo `User`:


```php
$user = User::factory()
            ->hasRoles(1, [
                'name' => 'Editor'
            ])
            ->create();
```

<a name="polymorphic-relationships"></a>
### Relaciones Polimórficas

[Las relaciones polimórficas](/docs/%7B%7Bversion%7D%7D/eloquent-relationships#polymorphic-relationships) también pueden ser creadas utilizando fábricas. Las relaciones polimórficas "morph many" se crean de la misma manera que las típicas relaciones "has many". Por ejemplo, si un modelo `App\Models\Post` tiene una relación `morphMany` con un modelo `App\Models\Comment`:


```php
use App\Models\Post;

$post = Post::factory()->hasComments(3)->create();
```

<a name="morph-to-relationships"></a>
#### Relaciones Morph To

Los métodos mágicos no pueden utilizarse para crear relaciones `morphTo`. En su lugar, se debe usar el método `for` directamente y el nombre de la relación debe ser proporcionado explícitamente. Por ejemplo, imagina que el modelo `Comment` tiene un método `commentable` que define una relación `morphTo`. En esta situación, podemos crear tres comentarios que pertenecen a una sola publicación utilizando el método `for` directamente:


```php
$comments = Comment::factory()->count(3)->for(
    Post::factory(), 'commentable'
)->create();
```

<a name="polymorphic-many-to-many-relationships"></a>
#### Relaciones Polimórficas Muchos a Muchos

Las relaciones polimórficas "muchos a muchos" (`morphToMany` / `morphedByMany`) se pueden crear de la misma manera que las relaciones "muchos a muchos" no polimórficas:


```php
use App\Models\Tag;
use App\Models\Video;

$videos = Video::factory()
            ->hasAttached(
                Tag::factory()->count(3),
                ['public' => true]
            )
            ->create();
```
Por supuesto, el mágico método `has` también se puede utilizar para crear relaciones polimórficas de "muchos a muchos":


```php
$videos = Video::factory()
            ->hasTags(3, ['public' => true])
            ->create();
```

<a name="defining-relationships-within-factories"></a>
### Definiendo Relaciones Dentro de Factories

Para definir una relación dentro de tu fábrica de modelos, normalmente asignarás una nueva instancia de fábrica a la clave foránea de la relación. Esto se hace normalmente para las relaciones "inversas" como las relaciones `belongsTo` y `morphTo`. Por ejemplo, si deseas crear un nuevo usuario al crear una publicación, puedes hacer lo siguiente:


```php
use App\Models\User;

/**
 * Define the model's default state.
 *
 * @return array<string, mixed>
 */
public function definition(): array
{
    return [
        'user_id' => User::factory(),
        'title' => fake()->title(),
        'content' => fake()->paragraph(),
    ];
}
```
Si las columnas de la relación dependen de la fábrica que la define, puedes asignar una función anónima a un atributo. La función anónima recibirá el array de atributos evaluados de la fábrica:


```php
/**
 * Define the model's default state.
 *
 * @return array<string, mixed>
 */
public function definition(): array
{
    return [
        'user_id' => User::factory(),
        'user_type' => function (array $attributes) {
            return User::find($attributes['user_id'])->type;
        },
        'title' => fake()->title(),
        'content' => fake()->paragraph(),
    ];
}
```

<a name="recycling-an-existing-model-for-relationships"></a>
### Reciclando un Modelo Existente para Relaciones

Si tienes modelos que comparten una relación común con otro modelo, puedes usar el método `recycle` para asegurar que una sola instancia del modelo relacionado se reutilice para todas las relaciones creadas por la fábrica.
Por ejemplo, imagina que tienes los modelos `Airline`, `Flight` y `Ticket`, donde el ticket pertenece a una aerolínea y un vuelo, y el vuelo también pertenece a una aerolínea. Al crear boletos, probablemente querrás la misma aerolínea tanto para el boleto como para el vuelo, así que puedes pasar una instancia de la aerolínea al método `recycle`:


```php
Ticket::factory()
    ->recycle(Airline::factory()->create())
    ->create();
```
Es posible que encuentres especialmente útil el método `recycle` si tienes modelos que pertenecen a un usuario o equipo común.
El método `recycle` también acepta una colección de modelos existentes. Cuando se proporciona una colección al método `recycle`, se elegirá un modelo al azar de la colección cuando la fábrica necesite un modelo de ese tipo:


```php
Ticket::factory()
    ->recycle($airlines)
    ->create();
```