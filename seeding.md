# Base de datos: Población

- [Introducción](#introduction)
- [Escribiendo Seeders](#writing-seeders)
  - [Usando Factories de Modelos](#using-model-factories)
  - [Llamando Seeders Adicionales](#calling-additional-seeders)
  - [Silenciando Eventos de Modelos](#muting-model-events)
- [Ejecutando Seeders](#running-seeders)

<a name="introduction"></a>
## Introducción

Laravel incluye la capacidad de llenar tu base de datos con datos utilizando clases de seed. Todas las clases de seed se almacenan en el directorio `database/seeders`. Por defecto, se define una clase `DatabaseSeeder` para ti. Desde esta clase, puedes usar el método `call` para ejecutar otras clases de seed, lo que te permite controlar el orden de llenado.
> [!NOTE]
[La protección contra la asignación masiva](/docs/%7B%7Bversion%7D%7D/eloquent#mass-assignment) se desactiva automáticamente durante la siembra de la base de datos.

<a name="writing-seeders"></a>
## Escribiendo Seeders

Para generar un seeder, ejecuta el comando `make:seeder` [Artisan](/docs/%7B%7Bversion%7D%7D/artisan). Todos los seeders generados por el framework se colocarán en el directorio `database/seeders`:


```shell
php artisan make:seeder UserSeeder

```
Una clase de seeder solo contiene un método por defecto: `run`. Este método se llama cuando se ejecuta el comando [db:seed](/docs/%7B%7Bversion%7D%7D/artisan) de Artisan. Dentro del método `run`, puedes insertar datos en tu base de datos como desees. Puedes usar el [query builder](/docs/%7B%7Bversion%7D%7D/queries) para insertar datos manualmente o puedes usar [factory de modelos Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent-factories).
Como ejemplo, vamos a modificar la clase `DatabaseSeeder` predeterminada y añadir una declaración de inserción en la base de datos al método `run`:


```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Run the database seeders.
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
```
> [!NOTA]
Puedes indicar cualquier dependencia que necesites dentro de la firma del método `run`. Se resolverán automáticamente a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel.

<a name="using-model-factories"></a>
### Usando Factories de Modelos

Por supuesto, especificar manualmente los atributos para cada siembra de modelo es engorroso. En su lugar, puedes usar [fábricas de modelos](/docs/%7B%7Bversion%7D%7D/eloquent-factories) para generar convenientemente grandes cantidades de registros de base de datos. Primero, revisa la [documentación de fábricas de modelos](/docs/%7B%7Bversion%7D%7D/eloquent-factories) para aprender a definir tus fábricas.
Por ejemplo, vamos a crear 50 usuarios que cada uno tiene una publicación relacionada:


```php
use App\Models\User;

/**
 * Run the database seeders.
 */
public function run(): void
{
    User::factory()
            ->count(50)
            ->hasPosts(1)
            ->create();
}
```

<a name="calling-additional-seeders"></a>
### Llamando a Seeders Adicionales

Dentro de la clase `DatabaseSeeder`, puedes usar el método `call` para ejecutar clases de siembra adicionales. Usar el método `call` te permite dividir la siembra de tu base de datos en múltiples archivos para que ninguna clase de sembrador se vuelva demasiado grande. El método `call` acepta un array de clases de sembrador que deben ser ejecutadas:


```php
/**
 * Run the database seeders.
 */
public function run(): void
{
    $this->call([
        UserSeeder::class,
        PostSeeder::class,
        CommentSeeder::class,
    ]);
}
```

<a name="muting-model-events"></a>
### Silenciando Eventos de Modelo

Mientras ejecutas las semillas, puede que desees prevenir que los modelos despachen eventos. Puedes lograr esto utilizando el trait `WithoutModelEvents`. Cuando se utiliza, el trait `WithoutModelEvents` asegura que no se despachen eventos de modelo, incluso si se ejecutan clases de semillas adicionales a través del método `call`:


```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Run the database seeders.
     */
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
        ]);
    }
}
```

<a name="running-seeders"></a>
## Ejecutando Seeders

Puedes ejecutar el comando Artisan `db:seed` para sembrar tu base de datos. Por defecto, el comando `db:seed` ejecuta la clase `Database\Seeders\DatabaseSeeder`, que a su vez puede invocar otras clases de siembra. Sin embargo, puedes usar la opción `--class` para especificar una clase de sembrador específica para ejecutar de forma individual:


```shell
php artisan db:seed

php artisan db:seed --class=UserSeeder

```
También puedes sembrar tu base de datos utilizando el comando `migrate:fresh` en combinación con la opción `--seed`, que eliminará todas las tablas y volverá a ejecutar todas tus migraciones. Este comando es útil para reconstruir completamente tu base de datos. La opción `--seeder` se puede usar para especificar un sembrador específico a ejecutar:


```shell
php artisan migrate:fresh --seed

php artisan migrate:fresh --seed --seeder=UserSeeder

```

<a name="forcing-seeding-production"></a>
#### Forzar la Ejecución de Seeders en Producción

Algunas operaciones de siembra pueden hacer que alteres o pierdas datos. Para protegerte de ejecutar comandos de siembra contra tu base de datos de producción, se te pedirá confirmación antes de que se ejecuten los seeders en el entorno `production`. Para forzar a que los seeders se ejecuten sin un aviso, utiliza el flag `--force`:


```shell
php artisan db:seed --force

```