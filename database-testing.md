# Pruebas de Base de Datos

- [Introducción](#introduction)
  - [Restableciendo la Base de Datos Después de Cada Prueba](#resetting-the-database-after-each-test)
- [Fábricas de Modelos](#model-factories)
- [Ejecutando Seeders](#running-seeders)
- [Aserciones Disponibles](#available-assertions)

<a name="introduction"></a>
## Introducción

Laravel ofrece una variedad de herramientas y afirmaciones útiles para facilitar la prueba de tus aplicaciones impulsadas por base de datos. Además, las fábricas de modelos y los sembradores de Laravel hacen que sea muy fácil crear registros de base de datos de prueba utilizando los modelos Eloquent y las relaciones de tu aplicación. Discutiremos todas estas poderosas características en la siguiente documentación.

<a name="resetting-the-database-after-each-test"></a>
### Restableciendo la Base de Datos Después de Cada Prueba

Antes de avanzar mucho más, hablemos sobre cómo restablecer tu base de datos después de cada una de tus pruebas para que los datos de una prueba anterior no interfieran con las pruebas posteriores. El trait `Illuminate\Foundation\Testing\RefreshDatabase` incluido en Laravel se encargará de esto por ti. Simplemente usa el trait en tu clase de prueba:


```php
<?php

use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('basic example', function () {
    $response = $this->get('/');

    // ...
});

```


```php
<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    use RefreshDatabase;

    /**
     * A basic functional test example.
     */
    public function test_basic_example(): void
    {
        $response = $this->get('/');

        // ...
    }
}

```
El trait `Illuminate\Foundation\Testing\RefreshDatabase` no migra tu base de datos si tu esquema está actualizado. En su lugar, solo ejecutará la prueba dentro de una transacción de base de datos. Por lo tanto, cualquier registro añadido a la base de datos por casos de prueba que no utilicen este trait puede seguir existiendo en la base de datos.
Si deseas restablecer completamente la base de datos, puedes usar los rasgos `Illuminate\Foundation\Testing\DatabaseMigrations` o `Illuminate\Foundation\Testing\DatabaseTruncation`. Sin embargo, ambas opciones son significativamente más lentas que el rasgo `RefreshDatabase`.

<a name="model-factories"></a>
## Fábricas de Modelos

Al probar, es posible que necesites insertar algunos registros en tu base de datos antes de ejecutar tu prueba. En lugar de especificar manualmente el valor de cada columna cuando creas estos datos de prueba, Laravel te permite definir un conjunto de atributos predeterminados para cada uno de tus [modelos Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent) usando [fábricas de modelos](/docs/%7B%7Bversion%7D%7D/eloquent-factories).
Para obtener más información sobre cómo crear y utilizar fábricas de modelos para crear modelos, consulta la [documentación completa sobre fábricas de modelos](/docs/%7B%7Bversion%7D%7D/eloquent-factories). Una vez que hayas definido una fábrica de modelo, puedes utilizar la fábrica dentro de tu prueba para crear modelos:


```php
use App\Models\User;

test('models can be instantiated', function () {
    $user = User::factory()->create();

    // ...
});

```


```php
use App\Models\User;

public function test_models_can_be_instantiated(): void
{
    $user = User::factory()->create();

    // ...
}

```

<a name="running-seeders"></a>
## Ejecutando Seeders

Si deseas usar [seeders de base de datos](/docs/%7B%7Bversion%7D%7D/seeding) para poblar tu base de datos durante una prueba de función, puedes invocar el método `seed`. Por defecto, el método `seed` ejecutará el `DatabaseSeeder`, que debería ejecutar todos tus otros seeders. Alternativamente, puedes pasar un nombre de clase de seeder específico al método `seed`:


```php
<?php

use Database\Seeders\OrderStatusSeeder;
use Database\Seeders\TransactionStatusSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('orders can be created', function () {
    // Run the DatabaseSeeder...
    $this->seed();

    // Run a specific seeder...
    $this->seed(OrderStatusSeeder::class);

    // ...

    // Run an array of specific seeders...
    $this->seed([
        OrderStatusSeeder::class,
        TransactionStatusSeeder::class,
        // ...
    ]);
});

```


```php
<?php

namespace Tests\Feature;

use Database\Seeders\OrderStatusSeeder;
use Database\Seeders\TransactionStatusSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test creating a new order.
     */
    public function test_orders_can_be_created(): void
    {
        // Run the DatabaseSeeder...
        $this->seed();

        // Run a specific seeder...
        $this->seed(OrderStatusSeeder::class);

        // ...

        // Run an array of specific seeders...
        $this->seed([
            OrderStatusSeeder::class,
            TransactionStatusSeeder::class,
            // ...
        ]);
    }
}

```
Alternativamente, puedes instruir a Laravel para que siembre automáticamente la base de datos antes de cada prueba que utilice el trait `RefreshDatabase`. Puedes lograr esto definiendo una propiedad `$seed` en tu clase de prueba base:


```php
<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    /**
     * Indicates whether the default seeder should run before each test.
     *
     * @var bool
     */
    protected $seed = true;
}
```
Cuando la propiedad `$seed` es `true`, la prueba ejecutará la clase `Database\Seeders\DatabaseSeeder` antes de cada prueba que utilice el rasgo `RefreshDatabase`. Sin embargo, puedes especificar un seeder específico que se debe ejecutar definiendo una propiedad `$seeder` en tu clase de prueba:


```php
use Database\Seeders\OrderStatusSeeder;

/**
 * Run a specific seeder before each test.
 *
 * @var string
 */
protected $seeder = OrderStatusSeeder::class;
```

<a name="available-assertions"></a>
## Afirmaciones Disponibles

Laravel proporciona varias aserciones de base de datos para tus pruebas de características con [Pest](https://pestphp.com) o [PHPUnit](https://phpunit.de). Discutiremos cada una de estas aserciones a continuación.

<a name="assert-database-count"></a>
#### assertDatabaseCount

Afirmar que una tabla en la base de datos contiene el número dado de registros:


```php
$this->assertDatabaseCount('users', 5);
```

<a name="assert-database-has"></a>
#### assertDatabaseHas

Asegúrate de que una tabla en la base de datos contenga registros que coincidan con las restricciones de consulta de clave / valor dadas:


```php
$this->assertDatabaseHas('users', [
    'email' => 'sally@example.com',
]);
```

<a name="assert-database-missing"></a>
#### assertDatabaseMissing

Asegúrate de que una tabla en la base de datos no contenga registros que coincidan con las restricciones de consulta de clave / valor dadas:


```php
$this->assertDatabaseMissing('users', [
    'email' => 'sally@example.com',
]);
```

<a name="assert-deleted"></a>
#### assertSoftDeleted

El método `assertSoftDeleted` se puede utilizar para afirmar que un modelo Eloquent dado ha sido "eliminado suavemente":


```php
$this->assertSoftDeleted($user);
```

<a name="assert-not-deleted"></a>
#### assertNotSoftDeleted

El método `assertNotSoftDeleted` se puede utilizar para afirmar que un modelo Eloquent dado no ha sido "eliminado suavemente":


```php
$this->assertNotSoftDeleted($user);
```

<a name="assert-model-exists"></a>
#### assertModelExists

Asegúrate de que un modelo dado exista en la base de datos:


```php
use App\Models\User;

$user = User::factory()->create();

$this->assertModelExists($user);
```

<a name="assert-model-missing"></a>
#### assertModelMissing

Asegúrate de que un modelo dado no existe en la base de datos:


```php
use App\Models\User;

$user = User::factory()->create();

$user->delete();

$this->assertModelMissing($user);
```

<a name="expects-database-query-count"></a>
#### expectsDatabaseQueryCount

El método `expectsDatabaseQueryCount` puede invocarse al comienzo de tu prueba para especificar el número total de consultas a la base de datos que esperas que se ejecuten durante la prueba. Si el número real de consultas ejecutadas no coincide exactamente con esta expectativa, la prueba fallará:


```php
$this->expectsDatabaseQueryCount(5);

// Test...
```