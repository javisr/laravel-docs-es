# Base de datos: Siembra

- [Introducción](#introduction)
- [Escribiendo Seeders](#writing-seeders)
    - [Usando Model Factories](#using-model-factories)
    - [Llamando Seeders Adicionales](#calling-additional-seeders)
    - [Silenciando Eventos de Modelos](#muting-model-events)
- [Ejecutando Seeders](#running-seeders)

<a name="introduction"></a>
## Introducción

Laravel incluye la capacidad de sembrar tu base de datos con datos utilizando clases de siembra. Todas las clases de siembra se almacenan en el directorio `database/seeders`. Por defecto, se define una clase `DatabaseSeeder` para ti. Desde esta clase, puedes usar el método `call` para ejecutar otras clases de siembra, lo que te permite controlar el orden de siembra.

> [!NOTE]  
> La [protección contra asignación masiva](/docs/{{version}}/eloquent#mass-assignment) se desactiva automáticamente durante la siembra de la base de datos.

<a name="writing-seeders"></a>
## Escribiendo Seeders

Para generar un seeder, ejecuta el comando [Artisan make:seeder](/docs/{{version}}/artisan). Todos los seeders generados por el framework se colocarán en el directorio `database/seeders`:

```shell
php artisan make:seeder UserSeeder
```

Una clase de seeder solo contiene un método por defecto: `run`. Este método se llama cuando se ejecuta el comando [Artisan db:seed](/docs/{{version}}/artisan). Dentro del método `run`, puedes insertar datos en tu base de datos como desees. Puedes usar el [query builder](/docs/{{version}}/queries) para insertar datos manualmente o puedes usar [Eloquent model factories](/docs/{{version}}/eloquent-factories).

Como ejemplo, modifiquemos la clase `DatabaseSeeder` por defecto y agreguemos una declaración de inserción en la base de datos al método `run`:

    <?php

    namespace Database\Seeders;

    use Illuminate\Database\Seeder;
    use Illuminate\Support\Facades\DB;
    use Illuminate\Support\Facades\Hash;
    use Illuminate\Support\Str;

    class DatabaseSeeder extends Seeder
    {
        /**
         * Ejecutar los seeders de la base de datos.
         */
        public function run(): void
        {
            DB::table('users')->insert([
                'name' => Str::random(10),
                'email' => Str::random(10).'@example.com',
                'password' => Hash::make('password'),
            ]);
        }
    }

> [!NOTE]  
> Puedes indicar cualquier dependencia que necesites dentro de la firma del método `run`. Se resolverán automáticamente a través del [contenedor de servicios](/docs/{{version}}/container) de Laravel.

<a name="using-model-factories"></a>
### Usando Model Factories

Por supuesto, especificar manualmente los atributos para cada siembra de modelo es engorroso. En su lugar, puedes usar [model factories](/docs/{{version}}/eloquent-factories) para generar convenientemente grandes cantidades de registros en la base de datos. Primero, revisa la [documentación de model factory](/docs/{{version}}/eloquent-factories) para aprender cómo definir tus factories.

Por ejemplo, vamos a crear 50 usuarios que cada uno tiene una publicación relacionada:

    use App\Models\User;

    /**
     * Ejecutar los seeders de la base de datos.
     */
    public function run(): void
    {
        User::factory()
                ->count(50)
                ->hasPosts(1)
                ->create();
    }

<a name="calling-additional-seeders"></a>
### Llamando Seeders Adicionales

Dentro de la clase `DatabaseSeeder`, puedes usar el método `call` para ejecutar clases de siembra adicionales. Usar el método `call` te permite dividir la siembra de tu base de datos en múltiples archivos para que ninguna clase de seeder se vuelva demasiado grande. El método `call` acepta un array de clases de seeder que deben ser ejecutadas:

    /**
     * Ejecutar los seeders de la base de datos.
     */
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            PostSeeder::class,
            CommentSeeder::class,
        ]);
    }

<a name="muting-model-events"></a>
### Silenciando Eventos de Modelos

Mientras ejecutas las siembras, es posible que desees evitar que los modelos despachen eventos. Puedes lograr esto usando el trait `WithoutModelEvents`. Cuando se usa, el trait `WithoutModelEvents` asegura que no se despachen eventos de modelo, incluso si se ejecutan clases de siembra adicionales a través del método `call`:

    <?php

    namespace Database\Seeders;

    use Illuminate\Database\Seeder;
    use Illuminate\Database\Console\Seeds\WithoutModelEvents;

    class DatabaseSeeder extends Seeder
    {
        use WithoutModelEvents;

        /**
         * Ejecutar los seeders de la base de datos.
         */
        public function run(): void
        {
            $this->call([
                UserSeeder::class,
            ]);
        }
    }

<a name="running-seeders"></a>
## Ejecutando Seeders

Puedes ejecutar el comando Artisan `db:seed` para sembrar tu base de datos. Por defecto, el comando `db:seed` ejecuta la clase `Database\Seeders\DatabaseSeeder`, que a su vez puede invocar otras clases de siembra. Sin embargo, puedes usar la opción `--class` para especificar una clase de seeder específica para ejecutar individualmente:

```shell
php artisan db:seed

php artisan db:seed --class=UserSeeder
```

También puedes sembrar tu base de datos usando el comando `migrate:fresh` en combinación con la opción `--seed`, que eliminará todas las tablas y volverá a ejecutar todas tus migraciones. Este comando es útil para reconstruir completamente tu base de datos. La opción `--seeder` puede usarse para especificar un seeder específico para ejecutar:

```shell
php artisan migrate:fresh --seed

php artisan migrate:fresh --seed --seeder=UserSeeder
```

<a name="forcing-seeding-production"></a>
#### Forzando a los Seeders a Ejecutarse en Producción

Algunas operaciones de siembra pueden hacer que alteres o pierdas datos. Para protegerte de ejecutar comandos de siembra contra tu base de datos de producción, se te pedirá confirmación antes de que se ejecuten los seeders en el entorno `production`. Para forzar a los seeders a ejecutarse sin un aviso, usa la bandera `--force`:

```shell
php artisan db:seed --force
```
