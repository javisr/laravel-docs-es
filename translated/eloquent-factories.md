# Eloquent: Factories

- [Introducción](#introduction)
- [Definiendo Factories de Modelos](#defining-model-factories)
    - [Generando Factories](#generating-factories)
    - [Estados de Factory](#factory-states)
    - [Callbacks de Factory](#factory-callbacks)
- [Creando Modelos Usando Factories](#creating-models-using-factories)
    - [Instanciando Modelos](#instantiating-models)
    - [Persistiendo Modelos](#persisting-models)
    - [Secuencias](#sequences)
- [Relaciones de Factory](#factory-relationships)
    - [Relaciones Has Many](#has-many-relationships)
    - [Relaciones Belongs To](#belongs-to-relationships)
    - [Relaciones Many to Many](#many-to-many-relationships)
    - [Relaciones Polimórficas](#polymorphic-relationships)
    - [Definiendo Relaciones Dentro de Factories](#defining-relationships-within-factories)
    - [Reciclaje de un Modelo Existente para Relaciones](#recycling-an-existing-model-for-relationships)

<a name="introduction"></a>
## Introducción

Cuando pruebas tu aplicación o llenas tu base de datos, puede que necesites insertar algunos registros en tu base de datos. En lugar de especificar manualmente el valor de cada columna, Laravel te permite definir un conjunto de atributos predeterminados para cada uno de tus [modelos Eloquent](/docs/{{version}}/eloquent) usando factories de modelos.

Para ver un ejemplo de cómo escribir una factory, echa un vistazo al archivo `database/factories/UserFactory.php` en tu aplicación. Esta factory está incluida con todas las nuevas aplicaciones de Laravel y contiene la siguiente definición de factory:

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
         * La contraseña actual que está siendo utilizada por la factory.
         */
        protected static ?string $password;

        /**
         * Define el estado predeterminado del modelo.
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
         * Indica que la dirección de correo electrónico del modelo debe estar sin verificar.
         */
        public function unverified(): static
        {
            return $this->state(fn (array $attributes) => [
                'email_verified_at' => null,
            ]);
        }
    }

Como puedes ver, en su forma más básica, las factories son clases que extienden la clase base de factory de Laravel y definen un método `definition`. El método `definition` devuelve el conjunto predeterminado de valores de atributos que deben aplicarse al crear un modelo usando la factory.

A través del helper `fake`, las factories tienen acceso a la biblioteca PHP [Faker](https://github.com/FakerPHP/Faker), que te permite generar convenientemente varios tipos de datos aleatorios para pruebas y llenado.

> [!NOTE]  
> Puedes cambiar la configuración regional de Faker de tu aplicación actualizando la opción `faker_locale` en tu archivo de configuración `config/app.php`.

<a name="defining-model-factories"></a>
## Definiendo Factories de Modelos

<a name="generating-factories"></a>
### Generando Factories

Para crear una factory, ejecuta el comando [Artisan](/docs/{{version}}/artisan) `make:factory`:

```shell
php artisan make:factory PostFactory
```

La nueva clase de factory se colocará en tu directorio `database/factories`.

<a name="factory-and-model-discovery-conventions"></a>
#### Convenciones de Descubrimiento de Modelos y Factories

Una vez que hayas definido tus factories, puedes usar el método estático `factory` proporcionado a tus modelos por el trait `Illuminate\Database\Eloquent\Factories\HasFactory` para instanciar una instancia de factory para ese modelo.

El método `factory` del trait `HasFactory` usará convenciones para determinar la factory adecuada para el modelo al que se le asigna el trait. Específicamente, el método buscará una factory en el espacio de nombres `Database\Factories` que tenga un nombre de clase que coincida con el nombre del modelo y esté sufijado con `Factory`. Si estas convenciones no se aplican a tu aplicación o factory en particular, puedes sobrescribir el método `newFactory` en tu modelo para devolver una instancia de la factory correspondiente del modelo directamente:

    use Illuminate\Database\Eloquent\Factories\Factory;
    use Database\Factories\Administration\FlightFactory;

    /**
     * Crea una nueva instancia de factory para el modelo.
     */
    protected static function newFactory(): Factory
    {
        return FlightFactory::new();
    }

Luego, define una propiedad `model` en la factory correspondiente:

    use App\Administration\Flight;
    use Illuminate\Database\Eloquent\Factories\Factory;

    class FlightFactory extends Factory
    {
        /**
         * El nombre del modelo correspondiente a la factory.
         *
         * @var class-string<\Illuminate\Database\Eloquent\Model>
         */
        protected $model = Flight::class;
    }

<a name="factory-states"></a>
### Estados de Factory

Los métodos de manipulación de estado te permiten definir modificaciones discretas que pueden aplicarse a tus factories de modelos en cualquier combinación. Por ejemplo, tu factory `Database\Factories\UserFactory` podría contener un método de estado `suspended` que modifica uno de sus valores de atributo predeterminados.

Los métodos de transformación de estado típicamente llaman al método `state` proporcionado por la clase base de factory de Laravel. El método `state` acepta una función anónima que recibirá el array de atributos en bruto definidos para la factory y debería devolver un array de atributos a modificar:

    use Illuminate\Database\Eloquent\Factories\Factory;

    /**
     * Indica que el usuario está suspendido.
     */
    public function suspended(): Factory
    {
        return $this->state(function (array $attributes) {
            return [
                'account_status' => 'suspended',
            ];
        });
    }

<a name="trashed-state"></a>
#### Estado "Trashed"

Si tu modelo Eloquent puede ser [soft deleted](/docs/{{version}}/eloquent#soft-deleting), puedes invocar el método de estado incorporado `trashed` para indicar que el modelo creado ya debería estar "soft deleted". No necesitas definir manualmente el estado `trashed`, ya que está automáticamente disponible para todas las factories:

    use App\Models\User;

    $user = User::factory()->trashed()->create();

<a name="factory-callbacks"></a>
### Callbacks de Factory

Los callbacks de factory se registran usando los métodos `afterMaking` y `afterCreating` y te permiten realizar tareas adicionales después de hacer o crear un modelo. Debes registrar estos callbacks definiendo un método `configure` en tu clase de factory. Este método será llamado automáticamente por Laravel cuando se instancie la factory:

    namespace Database\Factories;

    use App\Models\User;
    use Illuminate\Database\Eloquent\Factories\Factory;

    class UserFactory extends Factory
    {
        /**
         * Configura la factory del modelo.
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

También puedes registrar callbacks de factory dentro de métodos de estado para realizar tareas adicionales que son específicas para un estado dado:

    use App\Models\User;
    use Illuminate\Database\Eloquent\Factories\Factory;

    /**
     * Indica que el usuario está suspendido.
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

<a name="creating-models-using-factories"></a>
## Creando Modelos Usando Factories

<a name="instantiating-models"></a>
### Instanciando Modelos

Una vez que hayas definido tus factories, puedes usar el método estático `factory` proporcionado a tus modelos por el trait `Illuminate\Database\Eloquent\Factories\HasFactory` para instanciar una instancia de factory para ese modelo. Veamos algunos ejemplos de creación de modelos. Primero, usaremos el método `make` para crear modelos sin persistirlos en la base de datos:

    use App\Models\User;

    $user = User::factory()->make();

Puedes crear una colección de muchos modelos usando el método `count`:

    $users = User::factory()->count(3)->make();

<a name="applying-states"></a>
#### Aplicando Estados

También puedes aplicar cualquiera de tus [estados](#factory-states) a los modelos. Si deseas aplicar múltiples transformaciones de estado a los modelos, simplemente puedes llamar a los métodos de transformación de estado directamente:

    $users = User::factory()->count(5)->suspended()->make();

<a name="overriding-attributes"></a>
#### Sobrescribiendo Atributos

Si deseas sobrescribir algunos de los valores predeterminados de tus modelos, puedes pasar un array de valores al método `make`. Solo los atributos especificados serán reemplazados mientras que el resto de los atributos permanecerán establecidos en sus valores predeterminados según lo especificado por la factory:

    $user = User::factory()->make([
        'name' => 'Abigail Otwell',
    ]);

Alternativamente, el método `state` puede ser llamado directamente en la instancia de factory para realizar una transformación de estado en línea:

    $user = User::factory()->state([
        'name' => 'Abigail Otwell',
    ])->make();

> [!NOTE]  
> La [protección contra asignación masiva](/docs/{{version}}/eloquent#mass-assignment) está automáticamente deshabilitada al crear modelos usando factories.

<a name="persisting-models"></a>
### Persistiendo Modelos

El método `create` instancia instancias de modelo y las persiste en la base de datos usando el método `save` de Eloquent:

    use App\Models\User;

    // Crea una única instancia de App\Models\User...
    $user = User::factory()->create();

    // Crea tres instancias de App\Models\User...
    $users = User::factory()->count(3)->create();

Puedes sobrescribir los atributos de modelo predeterminados de la factory pasando un array de atributos al método `create`:

    $user = User::factory()->create([
        'name' => 'Abigail',
    ]);

<a name="sequences"></a>
### Secuencias

A veces puedes desear alternar el valor de un atributo de modelo dado para cada modelo creado. Puedes lograr esto definiendo una transformación de estado como una secuencia. Por ejemplo, puedes desear alternar el valor de una columna `admin` entre `Y` y `N` para cada usuario creado:

    use App\Models\User;
    use Illuminate\Database\Eloquent\Factories\Sequence;

    $users = User::factory()
                    ->count(10)
                    ->state(new Sequence(
                        ['admin' => 'Y'],
                        ['admin' => 'N'],
                    ))
                    ->create();

En este ejemplo, se crearán cinco usuarios con un valor de `admin` de `Y` y cinco usuarios se crearán con un valor de `admin` de `N`.

Si es necesario, puedes incluir una función anónima como un valor de secuencia. La función anónima será invocada cada vez que la secuencia necesite un nuevo valor:

    use Illuminate\Database\Eloquent\Factories\Sequence;

    $users = User::factory()
                    ->count(10)
                    ->state(new Sequence(
                        fn (Sequence $sequence) => ['role' => UserRoles::all()->random()],
                    ))
                    ->create();

Dentro de una función anónima de secuencia, puedes acceder a las propiedades `$index` o `$count` en la instancia de secuencia que se inyecta en la función anónima. La propiedad `$index` contiene el número de iteraciones a través de la secuencia que han ocurrido hasta ahora, mientras que la propiedad `$count` contiene el número total de veces que se invocará la secuencia:

    $users = User::factory()
                    ->count(10)
                    ->sequence(fn (Sequence $sequence) => ['name' => 'Name '.$sequence->index])
                    ->create();

Para conveniencia, las secuencias también pueden aplicarse usando el método `sequence`, que simplemente invoca el método `state` internamente. El método `sequence` acepta una función anónima o arrays de atributos secuenciados:

    $users = User::factory()
                    ->count(2)
                    ->sequence(
                        ['name' => 'First User'],
                        ['name' => 'Second User'],
                    )
                    ->create();

<a name="factory-relationships"></a>
## Relaciones de Factory

<a name="has-many-relationships"></a>
### Relaciones Has Many

A continuación, exploremos la construcción de relaciones de modelos Eloquent usando los métodos de factory fluidos de Laravel. Primero, asumamos que nuestra aplicación tiene un modelo `App\Models\User` y un modelo `App\Models\Post`. Además, asumamos que el modelo `User` define una relación `hasMany` con `Post`. Podemos crear un usuario que tenga tres publicaciones usando el método `has` proporcionado por las factories de Laravel. El método `has` acepta una instancia de factory:

    use App\Models\Post;
    use App\Models\User;

    $user = User::factory()
                ->has(Post::factory()->count(3))
                ->create();

Por convención, al pasar un modelo `Post` al método `has`, Laravel asumirá que el modelo `User` debe tener un método `posts` que define la relación. Si es necesario, puedes especificar explícitamente el nombre de la relación que te gustaría manipular:

    $user = User::factory()
                ->has(Post::factory()->count(3), 'posts')
                ->create();

Por supuesto, puedes realizar manipulaciones de estado en los modelos relacionados. Además, puedes pasar una transformación de estado basada en una función anónima si tu cambio de estado requiere acceso al modelo padre:

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
#### Usando Métodos Mágicos

Para conveniencia, puedes usar los métodos de relación de factory mágicos de Laravel para construir relaciones. Por ejemplo, el siguiente ejemplo usará la convención para determinar que los modelos relacionados deben ser creados a través de un método de relación `posts` en el modelo `User`:

    $user = User::factory()
                ->hasPosts(3)
                ->create();

Al usar métodos mágicos para crear relaciones de factory, puedes pasar un array de atributos para sobrescribir en los modelos relacionados:

    $user = User::factory()
                ->hasPosts(3, [
                    'published' => false,
                ])
                ->create();

Puedes proporcionar una transformación de estado basada en una función anónima si tu cambio de estado requiere acceso al modelo padre:

    $user = User::factory()
                ->hasPosts(3, function (array $attributes, User $user) {
                    return ['user_type' => $user->type];
                })
                ->create();

<a name="belongs-to-relationships"></a>
### Relaciones "Belongs To"

Ahora que hemos explorado cómo construir relaciones "has many" utilizando factories, exploremos la inversa de la relación. El método `for` puede ser utilizado para definir el modelo padre al que pertenecen los modelos creados por la factory. Por ejemplo, podemos crear tres instancias del modelo `App\Models\Post` que pertenecen a un solo usuario:

    use App\Models\Post;
    use App\Models\User;

    $posts = Post::factory()
                ->count(3)
                ->for(User::factory()->state([
                    'name' => 'Jessica Archer',
                ]))
                ->create();

Si ya tienes una instancia de modelo padre que debería estar asociada con los modelos que estás creando, puedes pasar la instancia del modelo al método `for`:

    $user = User::factory()->create();

    $posts = Post::factory()
                ->count(3)
                ->for($user)
                ->create();

<a name="belongs-to-relationships-using-magic-methods"></a>
#### Usando Métodos Mágicos

Para mayor comodidad, puedes usar los métodos mágicos de relación de factory de Laravel para definir relaciones "belongs to". Por ejemplo, el siguiente ejemplo utilizará la convención para determinar que las tres publicaciones deberían pertenecer a la relación `user` en el modelo `Post`:

    $posts = Post::factory()
                ->count(3)
                ->forUser([
                    'name' => 'Jessica Archer',
                ])
                ->create();

<a name="many-to-many-relationships"></a>
### Relaciones Muchos a Muchos

Al igual que las [relaciones has many](#has-many-relationships), las relaciones "many to many" pueden ser creadas utilizando el método `has`:

    use App\Models\Role;
    use App\Models\User;

    $user = User::factory()
                ->has(Role::factory()->count(3))
                ->create();

<a name="pivot-table-attributes"></a>
#### Atributos de la Tabla Pivot

Si necesitas definir atributos que deberían ser establecidos en la tabla pivot / intermedia que vincula los modelos, puedes usar el método `hasAttached`. Este método acepta un array de nombres y valores de atributos de la tabla pivot como su segundo argumento:

    use App\Models\Role;
    use App\Models\User;

    $user = User::factory()
                ->hasAttached(
                    Role::factory()->count(3),
                    ['active' => true]
                )
                ->create();

Puedes proporcionar una transformación de estado basada en una función anónima si tu cambio de estado requiere acceso al modelo relacionado:

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

Si ya tienes instancias de modelo que te gustaría adjuntar a los modelos que estás creando, puedes pasar las instancias de modelo al método `hasAttached`. En este ejemplo, los mismos tres roles serán adjuntados a los tres usuarios:

    $roles = Role::factory()->count(3)->create();

    $user = User::factory()
                ->count(3)
                ->hasAttached($roles, ['active' => true])
                ->create();

<a name="many-to-many-relationships-using-magic-methods"></a>
#### Usando Métodos Mágicos

Para mayor comodidad, puedes usar los métodos mágicos de relación de factory de Laravel para definir relaciones muchos a muchos. Por ejemplo, el siguiente ejemplo utilizará la convención para determinar que los modelos relacionados deberían ser creados a través de un método de relación `roles` en el modelo `User`:

    $user = User::factory()
                ->hasRoles(1, [
                    'name' => 'Editor'
                ])
                ->create();

<a name="polymorphic-relationships"></a>
### Relaciones Polimórficas

[Las relaciones polimórficas](/docs/{{version}}/eloquent-relationships#polymorphic-relationships) también pueden ser creadas utilizando factories. Las relaciones polimórficas "morph many" se crean de la misma manera que las típicas relaciones "has many". Por ejemplo, si un modelo `App\Models\Post` tiene una relación `morphMany` con un modelo `App\Models\Comment`:

    use App\Models\Post;

    $post = Post::factory()->hasComments(3)->create();

<a name="morph-to-relationships"></a>
#### Relaciones Morph To

No se pueden usar métodos mágicos para crear relaciones `morphTo`. En su lugar, el método `for` debe ser utilizado directamente y el nombre de la relación debe ser proporcionado explícitamente. Por ejemplo, imagina que el modelo `Comment` tiene un método `commentable` que define una relación `morphTo`. En esta situación, podemos crear tres comentarios que pertenecen a una sola publicación utilizando el método `for` directamente:

    $comments = Comment::factory()->count(3)->for(
        Post::factory(), 'commentable'
    )->create();

<a name="polymorphic-many-to-many-relationships"></a>
#### Relaciones Polimórficas Muchos a Muchos

Las relaciones polimórficas "many to many" (`morphToMany` / `morphedByMany`) pueden ser creadas de la misma manera que las relaciones "many to many" no polimórficas:

    use App\Models\Tag;
    use App\Models\Video;

    $videos = Video::factory()
                ->hasAttached(
                    Tag::factory()->count(3),
                    ['public' => true]
                )
                ->create();

Por supuesto, el método mágico `has` también puede ser utilizado para crear relaciones polimórficas "many to many":

    $videos = Video::factory()
                ->hasTags(3, ['public' => true])
                ->create();

<a name="defining-relationships-within-factories"></a>
### Definiendo Relaciones Dentro de Factories

Para definir una relación dentro de tu factory de modelo, normalmente asignarás una nueva instancia de factory a la clave foránea de la relación. Esto se hace normalmente para las relaciones "inversas" como `belongsTo` y `morphTo`. Por ejemplo, si deseas crear un nuevo usuario al crear una publicación, puedes hacer lo siguiente:

    use App\Models\User;

    /**
     * Define el estado predeterminado del modelo.
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

Si las columnas de la relación dependen de la factory que la define, puedes asignar una función anónima a un atributo. La función anónima recibirá el array de atributos evaluados de la factory:

    /**
     * Define el estado predeterminado del modelo.
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

<a name="recycling-an-existing-model-for-relationships"></a>
### Reciclaje de un Modelo Existente para Relaciones

Si tienes modelos que comparten una relación común con otro modelo, puedes usar el método `recycle` para asegurar que una sola instancia del modelo relacionado sea reciclada para todas las relaciones creadas por la factory.

Por ejemplo, imagina que tienes modelos `Airline`, `Flight` y `Ticket`, donde el ticket pertenece a una aerolínea y un vuelo, y el vuelo también pertenece a una aerolínea. Al crear tickets, probablemente querrás la misma aerolínea tanto para el ticket como para el vuelo, por lo que puedes pasar una instancia de aerolínea al método `recycle`:

    Ticket::factory()
        ->recycle(Airline::factory()->create())
        ->create();

Puedes encontrar el método `recycle` particularmente útil si tienes modelos que pertenecen a un usuario o equipo común.

El método `recycle` también acepta una colección de modelos existentes. Cuando se proporciona una colección al método `recycle`, se elegirá un modelo aleatorio de la colección cuando la factory necesite un modelo de ese tipo:

    Ticket::factory()
        ->recycle($airlines)
        ->create();
