# Eloquent: Factorias

- [Introducción](#introduction)
- [Definición de factorias modelo](#defining-model-factories)
  - [Generación de factorias](#generating-factories)
  - [Estados de Factoría](#factory-states)
  - [Callbacks de Factorías](#factory-callbacks)
- [Creación de modelos mediante factorias](#creating-models-using-factories)
  - [Instanciación de modelos](#instantiating-models)
  - [Persistencia de modelos](#persisting-models)
  - [Secuencias](#sequences)
- [Relaciones de Factoría](#factory-relationships)
  - [Relaciones "Tiene Muchos" - Has Many Relationships](#has-many-relationships)
  - [Relaciones "Pertenece a" - Belongs To Relationships](#belongs-to-relationships)
  - [Relaciones "de muchos a muchos" - Many To Many Relationships](#many-to-many-relationships)
  - [Relaciones polimórficas - Polymorphic Relationships](#polymorphic-relationships)
  - [Definición de relaciones dentro de las factorias](#defining-relationships-within-factories)
  - [Reciclaje de un Modelo Existente de Relaciones](#recycling-an-existing-model-for-relationships)

<a name="introduction"></a>
## Introducción

Cuando esté probando su aplicación o sembrando su base de datos, puede que necesite insertar algunos registros en su base de datos. En lugar de especificar manualmente el valor de cada columna, Laravel te permite definir un conjunto de atributos por defecto para cada uno de tus [modelos Eloquent](/docs/{{version}}/eloquent) utilizando factorias de modelos.

Para ver un ejemplo de cómo escribir una factoría, echa un vistazo al fichero `database/factories/UserFactory.php` de tu aplicación. Esta factoría se incluye con todas las nuevas aplicaciones Laravel y contiene la siguiente definición de factoría:

    namespace Database\Factories;

    use Illuminate\Database\Eloquent\Factories\Factory;
    use Illuminate\Support\Str;

    class UserFactory extends Factory
    {
        /**
         * Define the model's default state.
         *
         * @return array
         */
        public function definition()
        {
            return [
                'name' => fake()->name(),
                'email' => fake()->unique()->safeEmail(),
                'email_verified_at' => now(),
                'password' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
                'remember_token' => Str::random(10),
            ];
        }
    }

Como puedes ver, en su forma más básica, las factorías son clases que extienden la clase base `Factory` de Laravel y definen un método `definition`. El método `definition` devuelve el conjunto predeterminado de valores de atributo que deben aplicarse al crear un modelo utilizando la factoría.

A través del ayudante `fake`, las factorias tienen acceso a la librería [Faker](https://github.com/FakerPHP/Faker) PHP, que te permite generar varios tipos de datos aleatorios para pruebas y siembra.

> **Nota**  
> Puedes establecer el idioma que Faker usará en tu aplicación añadiendo una opción `faker_locale` a tu fichero de configuración `config/app.php`.

<a name="defining-model-factories"></a>
## Definición de factorias de modelos

<a name="generating-factories"></a>
### Generación de factorias

Para crear una factoría, ejecuta el [comando](/docs/{{version}}/artisan) `make:factory` [Artisan](/docs/{{version}}/artisan):

```shell
php artisan make:factory PostFactory
```

La nueva clase de factoría se colocará en su directorio `database/factories`.

<a name="factory-and-model-discovery-conventions"></a>
#### Convenciones de descubrimiento de modelos y factorias

Una vez que haya definido sus factorias, puede utilizar el método estático `factory` proporcionado a sus modelos por el trait `Illuminate\Database\Eloquent\Factories\HasFactory` con el fin de crear una instancia de factoría para ese modelo.

El método de `factory` del trait `HasFactory` utilizará convenciones para determinar la factoría adecuada para el modelo en el que se está usando. En concreto, el método buscará una factoría en el namespace `Database\Factories` que tenga un nombre de clase que coincida con el nombre del modelo y que tenga el sufijo `Factory`. Si estas convenciones no se aplican a su aplicación o factoría en particular, puede sobrescribir el método `newFactory` en su modelo para devolver directamente una instancia de la factoría correspondiente del modelo:

    use Database\Factories\Administration\FlightFactory;

    /**
     * Create a new factory instance for the model.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    protected static function newFactory()
    {
        return FlightFactory::new();
    }

A continuación, defina una propiedad `$model` en la factoría correspondiente:

    use App\Administration\Flight;
    use Illuminate\Database\Eloquent\Factories\Factory;

    class FlightFactory extends Factory
    {
        /**
         * The name of the factory's corresponding model.
         *
         * @var string
         */
        protected $model = Flight::class;
    }

<a name="factory-states"></a>
### Estados de Factoría

Los métodos de manipulación de estado le permiten definir modificaciones que se pueden aplicar a sus factorias de modelos. Por ejemplo, su factoría `Database\Factories\UserFactory` podría contener un método de estado `suspended` que modifique uno de sus valores de atributo por defecto.

Los métodos de transformación de estado suelen llamar al método `state` proporcionado por la clase factoría base de Laravel. El método `state` acepta un closure que recibirá el array de atributos raw definidos para la factoría y debería devolver un array de atributos a modificar:

    /**
     * Indicate that the user is suspended.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function suspended()
    {
        return $this->state(function (array $attributes) {
            return [
                'account_status' => 'suspended',
            ];
        });
    }

#### Estado "Trashed"

Si tu modelo Eloquent puede ser [borrado mediante "soft delete"](/docs/{{version}}/eloquent#soft-deleting), puedes invocar el método de estado `"trashed"` incorporado para indicar que el modelo creado ya debe estar marcado como "soft deleted". No es necesario definir manualmente el estado `"trashed"`, ya que está disponible automáticamente para todas las factorias:

    use App\Models\User;

    $user = User::factory()->trashed()->create();

<a name="factory-callbacks"></a>
### Callbacks de Factorías

Los callbacks de factorías se registran usando los métodos `afterMaking` y `afterCreating` y permiten realizar tareas adicionales después de crear un modelo. Debes registrar estos callbacks definiendo un método `configure` en tu clase factoría. Este método será llamado automáticamente por Laravel cuando la factoría sea instanciada:

    namespace Database\Factories;

    use App\Models\User;
    use Illuminate\Database\Eloquent\Factories\Factory;
    use Illuminate\Support\Str;

    class UserFactory extends Factory
    {
        /**
         * Configure the model factory.
         *
         * @return $this
         */
        public function configure()
        {
            return $this->afterMaking(function (User $user) {
                //
            })->afterCreating(function (User $user) {
                //
            });
        }

        // ...
    }

<a name="creating-models-using-factories"></a>
## Creación de modelos mediante factorias

<a name="instantiating-models"></a>
### Instanciación de modelos

Una vez que haya definido sus factorias, puede utilizar el método estático `factory` proporcionado a sus modelos por el trait `Illuminate\Database\Eloquent\Factories\HasFactory` con el fin de crear una instancia de factoría para ese modelo. Veamos algunos ejemplos de creación de modelos. En primer lugar, vamos a utilizar el método `make` para crear modelos sin guardarlos en la base de datos:

    use App\Models\User;

    $user = User::factory()->make();

Puedes crear una colección de muchos modelos usando el método `count`:

    $users = User::factory()->count(3)->make();

<a name="applying-states"></a>
#### Aplicando Estados

También puedes aplicar cualquiera de tus [estados](#factory-states) a los modelos. Si desea aplicar múltiples transformaciones de estado a los modelos, puede simplemente llamar directamente a los métodos de transformación de estado:

    $users = User::factory()->count(5)->suspended()->make();

<a name="overriding-attributes"></a>
#### Sobreescribiendo Atributos

Si quieres sobreescribir algunos de los valores por defecto de tus modelos, puedes pasar un array de valores al método `make`. Sólo los atributos especificados serán reemplazados mientras que el resto de los atributos permanecerán con sus valores por defecto especificados por la factoría:

    $user = User::factory()->make([
        'name' => 'Abigail Otwell',
    ]);

De manera alternativa, el método `state` puede ser llamado directamente en la instancia de la factoría para realizar una transformación de estado en línea:

    $user = User::factory()->state([
        'name' => 'Abigail Otwell',
    ])->make();

> **Nota**  
> [La protección de asignación masiva](/docs/{{version}}/eloquent#mass-assignment) se desactiva automáticamente al crear modelos utilizando factorias.

<a name="persisting-models"></a>
### Persistencia de modelos

El método `create` crea instancias del modelo y las guarda en la base de datos utilizando el método `save` de Eloquent:

    use App\Models\User;

    // Create a single App\Models\User instance...
    $user = User::factory()->create();

    // Create three App\Models\User instances...
    $users = User::factory()->count(3)->create();

Puedes sobreescribir los atributos de modelo por defecto de la factoría pasando un array de atributos al método `create`:

    $user = User::factory()->create([
        'name' => 'Abigail',
    ]);

<a name="sequences"></a>
### Secuencias

A veces puede que desee alternar el valor de un atributo de modelo dado para cada modelo creado. Esto se consigue definiendo una transformación de estado como una secuencia. Por ejemplo, puede que desee alternar el valor de una columna `admin` entre `Y` y `N` para cada usuario creado:

    use App\Models\User;
    use Illuminate\Database\Eloquent\Factories\Sequence;

    $users = User::factory()
                    ->count(10)
                    ->state(new Sequence(
                        ['admin' => 'Y'],
                        ['admin' => 'N'],
                    ))
                    ->create();

En este ejemplo, cinco usuarios serán creados con un valor `admin` de `Y` y cinco usuarios serán creados con un valor `admin` de `N`.

Si es necesario, puede incluir un closure como valor de secuencia. El closure se invocará cada vez que la secuencia necesite un nuevo valor:

    $users = User::factory()
                    ->count(10)
                    ->state(new Sequence(
                        fn ($sequence) => ['role' => UserRoles::all()->random()],
                    ))
                    ->create();

Dentro del closure, puede acceder a las propiedades `$index` o `$count` de la instancia de secuencia donde este es inyectado. La propiedad `$index` contiene el número de iteraciones a través de la secuencia que se han producido hasta el momento, mientras que la propiedad `$count` contiene el número total de veces que la secuencia será invocada:

    $users = User::factory()
                    ->count(10)
                    ->sequence(fn ($sequence) => ['name' => 'Name '.$sequence->index])
                    ->create();

<a name="factory-relationships"></a>
## Relaciones de Factoría

<a name="has-many-relationships"></a>
### Relaciones "Tiene Muchos" - Has Many Relationships

A continuación, vamos a explorar la construcción de relaciones entre modelos Eloquent utilizando los métodos fluidos de las factorías de Laravel. En primer lugar, vamos a suponer que nuestra aplicación tiene un modelo `App\Models\User` y un modelo `App\Models\Post`. Además, supongamos que el modelo `User` define una relación `hasMany` con `Post`. Podemos crear un usuario que tenga tres posts utilizando el método `has` proporcionado por las factorías de Laravel. El método `has` acepta una instancia de factoría:

    use App\Models\Post;
    use App\Models\User;

    $user = User::factory()
                ->has(Post::factory()->count(3))
                ->create();

Por convención, al pasar un modelo `Post` al método `has`, Laravel asumirá que el modelo `User` debe tener un método `posts` que defina la relación. Si es necesario, puede especificar explícitamente el nombre de la relación que desea manipular:

    $user = User::factory()
                ->has(Post::factory()->count(3), 'posts')
                ->create();

Por supuesto, puedes realizar manipulaciones de estado en los modelos relacionados. Además, puedes pasar una transformación de estado basada en un closure si tu cambio de estado requiere acceso al modelo padre:

    $user = User::factory()
                ->has(
                    Post::factory()
                            ->count(3)
                            ->state(function (array $attributes, User $user) {
                                return ['user_type' => $user->type];
                            })
                )
                ->create();

<a name="has-many-relationships-using-magic-methods"></a>
#### Uso de métodos mágicos

Por conveniencia, puedes usar los métodos mágicos de relación de Laravel para construir relaciones. Por ejemplo, el siguiente ejemplo utilizará la convención para determinar que los modelos relacionados deben ser creados a través de un método de relación `posts` en el modelo `User`:

    $user = User::factory()
                ->hasPosts(3)
                ->create();

Cuando se utilizan métodos mágicos para crear relaciones de factoría, puede pasar una array de atributos que seran sobreescritos en los modelos relacionados:

    $user = User::factory()
                ->hasPosts(3, [
                    'published' => false,
                ])
                ->create();

Puedes proporcionar una transformación de estado basada en un closure si tu cambio de estado requiere acceso al modelo padre:

    $user = User::factory()
                ->hasPosts(3, function (array $attributes, User $user) {
                    return ['user_type' => $user->type];
                })
                ->create();

<a name="belongs-to-relationships"></a>
### Relaciones "Pertenece a" - Belongs To Relationships


Ahora que hemos explorado cómo construir relaciones "has many" usando factorias, exploremos la inversa de la relación. El método `for` puede usarse para definir el modelo padre al que pertenecen los modelos creados por la factoría. Por ejemplo, podemos crear tres instancias del modelo `App\Models\Post` que pertenecen a un único usuario:

    use App\Models\Post;
    use App\Models\User;

    $posts = Post::factory()
                ->count(3)
                ->for(User::factory()->state([
                    'name' => 'Jessica Archer',
                ]))
                ->create();

Si ya tiene una instancia del modelo padre que debería estar asociada con los modelos que está creando, puede pasar la instancia del modelo al método `for`:

    $user = User::factory()->create();

    $posts = Post::factory()
                ->count(3)
                ->for($user)
                ->create();

<a name="belongs-to-relationships-using-magic-methods"></a>
#### Uso de métodos mágicos

Para mayor comodidad, puedes utilizar los métodos mágicos de relación de factoría de Laravel para definir las relaciones "belongs to". Por ejemplo, el siguiente ejemplo utilizará la convención para determinar que los tres posts deben pertenecer a la relación `user` en el modelo `Post`:

    $posts = Post::factory()
                ->count(3)
                ->forUser([
                    'name' => 'Jessica Archer',
                ])
                ->create();

<a name="many-to-many-relationships"></a>
### Relaciones "de muchos a muchos" - Many To Many Relationships

Al igual que las [relaciones has many](#has-many-relationships), las relaciones "many to many" pueden crearse utilizando el método `has`:

    use App\Models\Role;
    use App\Models\User;

    $user = User::factory()
                ->has(Role::factory()->count(3))
                ->create();

<a name="pivot-table-attributes"></a>
#### Atributos de la tabla dinámica

Si necesita definir los atributos que deben establecerse en la tabla pivotante / intermedia que vincula los modelos, puede utilizar el método `hasAttached`. Este método acepta una array de nombres y valores de atributos de tabla dinámica como segundo argumento:

    use App\Models\Role;
    use App\Models\User;

    $user = User::factory()
                ->hasAttached(
                    Role::factory()->count(3),
                    ['active' => true]
                )
                ->create();

Puede proporcionar una transformación de estado basada en el closure si su cambio de estado requiere el acceso al modelo relacionado:

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

Si ya dispone de instancias de modelo que desea adjuntar a los modelos que está creando, puede pasar las instancias de modelo al método `hasAttached`. En este ejemplo, los mismos tres roles se adjuntarán a los tres usuarios:

    $roles = Role::factory()->count(3)->create();

    $user = User::factory()
                ->count(3)
                ->hasAttached($roles, ['active' => true])
                ->create();

<a name="many-to-many-relationships-using-magic-methods"></a>
#### Uso de métodos mágicos

Por conveniencia, puedes usar los métodos de relación de la factoría mágica de Laravel para definir relaciones de muchos a muchos. Por ejemplo, el siguiente ejemplo utilizará la convención para determinar que los modelos relacionados deben ser creados a través de un método de relación `roles` en el modelo `User`:

    $user = User::factory()
                ->hasRoles(1, [
                    'name' => 'Editor'
                ])
                ->create();

<a name="polymorphic-relationships"></a>
### Relaciones polimórficas - Polymorphic Relationships

Las [relaciones polimórficas](/docs/{{version}}/eloquent-relationships#polymorphic-relationships) también pueden crearse utilizando factorias. Las relaciones polimórficas "morph many" se crean de la misma manera que las relaciones típicas "has many". Por ejemplo, si un modelo `App\Models\Post` tiene una relación `morphMany` con un modelo `App\Models\Comment`:

    use App\Models\Post;

    $post = Post::factory()->hasComments(3)->create();

<a name="morph-to-relationships"></a>
#### Morph To Relationships

No se pueden utilizar métodos mágicos para crear relaciones `morphTo`. En su lugar, se debe utilizar directamente el método `for` y proporcionar explícitamente el nombre de la relación. Por ejemplo, imagine que el modelo `Comment` tiene un método `commentable` que define una relación `morphTo`. En esta situación, podemos crear tres comentarios que pertenezcan a una única entrada utilizando directamente el método `for`:

    $comments = Comment::factory()->count(3)->for(
        Post::factory(), 'commentable'
    )->create();

<a name="polymorphic-many-to-many-relationships"></a>
#### Relaciones polimórficas Many To Many

Las relaciones polimórficas "muchos a muchos"`(morphToMany` / `morphedByMany`) pueden crearse igual que las relaciones no polimórficas "muchos a muchos":

    use App\Models\Tag;
    use App\Models\Video;

    $videos = Video::factory()
                ->hasAttached(
                    Tag::factory()->count(3),
                    ['public' => true]
                )
                ->create();

Por supuesto, el método mágico `has` también puede utilizarse para crear relaciones polimórficas "muchos a muchos":

    $videos = Video::factory()
                ->hasTags(3, ['public' => true])
                ->create();

<a name="defining-relationships-within-factories"></a>
### Definición de relaciones dentro de las factorias

Para definir una relación dentro de su factoría de modelos, normalmente asignará una nueva instancia de factoría a la clave externa de la relación. Esto se hace normalmente para las relaciones "inversas" como las relaciones `belongsTo` y `morphTo`. Por ejemplo, si desea crear un nuevo usuario al crear una entrada, puede hacer lo siguiente:

    use App\Models\User;

    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        return [
            'user_id' => User::factory(),
            'title' => fake()->title(),
            'content' => fake()->paragraph(),
        ];
    }

Si las columnas de la relación dependen de la factoría que la define puedes asignar un closure a un atributo. El closure recibirá el array atributos evaluados de la factoría:

    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
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

<a name="recycling-an-existing-model-for-relationships"></a>
### Reciclaje de un modelo existente de relaciones

Si tienes modelos que comparten una relación común con otro modelo, puedes utilizar el método `recycle` para asegurarte de que una única instancia del modelo relacionado se recicla para todas las relaciones creadas por la factoría.

Por ejemplo, imagine que tiene modelos `Aerolínea`, `Vuelo` y `Billete`, donde el billete pertenece a una aerolínea y a un vuelo, y el vuelo también pertenece a una aerolínea. Al crear billetes, probablemente querrá la misma aerolínea tanto para el billete como para el vuelo, por lo que puede pasar una instancia de aerolínea al método `recycle`:

    Ticket::factory()
        ->recycle(Airline::factory()->create())
        ->create();

El método `recycle` puede resultarle especialmente útil si tiene modelos que pertenecen a un usuario o equipo común.

El método `recycle` también acepta una colección de modelos existentes. Cuando se proporciona una colección al método `recycle`, se elegirá un modelo aleatorio de la colección cuando la factoría necesite un modelo de ese tipo:

    Ticket::factory()
        ->recycle($airlines)
        ->create();
