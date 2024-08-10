# Simulación

- [Introducción](#introduction)
- [Simulación de Objetos](#mocking-objects)
- [Simulación de Facades](#mocking-facades)
    - [Espías de Facade](#facade-spies)
- [Interacción con el Tiempo](#interacting-with-time)

<a name="introduction"></a>
## Introducción

Al probar aplicaciones de Laravel, es posible que desees "simular" ciertos aspectos de tu aplicación para que no se ejecuten realmente durante una prueba dada. Por ejemplo, al probar un controlador que despacha un evento, es posible que desees simular los oyentes de eventos para que no se ejecuten realmente durante la prueba. Esto te permite probar solo la respuesta HTTP del controlador sin preocuparte por la ejecución de los oyentes de eventos, ya que los oyentes de eventos pueden ser probados en su propio caso de prueba.

Laravel proporciona métodos útiles para simular eventos, trabajos y otras facades de forma predeterminada. Estos ayudantes proporcionan principalmente una capa de conveniencia sobre Mockery para que no tengas que realizar manualmente llamadas complicadas a los métodos de Mockery.

<a name="mocking-objects"></a>
## Simulación de Objetos

Al simular un objeto que se va a inyectar en tu aplicación a través del [contenedor de servicios](/docs/{{version}}/container) de Laravel, necesitarás vincular tu instancia simulada en el contenedor como una vinculación de `instance`. Esto indicará al contenedor que use tu instancia simulada del objeto en lugar de construir el objeto en sí:

```php tab=Pest
use App\Service;
use Mockery;
use Mockery\MockInterface;

test('something can be mocked', function () {
    $this->instance(
        Service::class,
        Mockery::mock(Service::class, function (MockInterface $mock) {
            $mock->shouldReceive('process')->once();
        })
    );
});
```

```php tab=PHPUnit
use App\Service;
use Mockery;
use Mockery\MockInterface;

public function test_something_can_be_mocked(): void
{
    $this->instance(
        Service::class,
        Mockery::mock(Service::class, function (MockInterface $mock) {
            $mock->shouldReceive('process')->once();
        })
    );
}
```

Para hacer esto más conveniente, puedes usar el método `mock` que proporciona la clase base de caso de prueba de Laravel. Por ejemplo, el siguiente ejemplo es equivalente al ejemplo anterior:

    use App\Service;
    use Mockery\MockInterface;

    $mock = $this->mock(Service::class, function (MockInterface $mock) {
        $mock->shouldReceive('process')->once();
    });

Puedes usar el método `partialMock` cuando solo necesitas simular algunos métodos de un objeto. Los métodos que no se simulan se ejecutarán normalmente cuando se llamen:

    use App\Service;
    use Mockery\MockInterface;

    $mock = $this->partialMock(Service::class, function (MockInterface $mock) {
        $mock->shouldReceive('process')->once();
    });

De manera similar, si deseas [espiar](http://docs.mockery.io/en/latest/reference/spies.html) un objeto, la clase base de caso de prueba de Laravel ofrece un método `spy` como un envoltorio conveniente alrededor del método `Mockery::spy`. Los espías son similares a los mocks; sin embargo, los espías registran cualquier interacción entre el espía y el código que se está probando, lo que te permite hacer afirmaciones después de que se ejecute el código:

    use App\Service;

    $spy = $this->spy(Service::class);

    // ...

    $spy->shouldHaveReceived('process');

<a name="mocking-facades"></a>
## Simulación de Facades

A diferencia de las llamadas a métodos estáticos tradicionales, las [facades](/docs/{{version}}/facades) (incluidas las [facades en tiempo real](/docs/{{version}}/facades#real-time-facades)) pueden ser simuladas. Esto proporciona una gran ventaja sobre los métodos estáticos tradicionales y te otorga la misma capacidad de prueba que tendrías si estuvieras utilizando inyección de dependencias tradicional. Al probar, a menudo querrás simular una llamada a una facade de Laravel que ocurre en uno de tus controladores. Por ejemplo, considera la siguiente acción del controlador:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Support\Facades\Cache;

    class UserController extends Controller
    {
        /**
         * Recuperar una lista de todos los usuarios de la aplicación.
         */
        public function index(): array
        {
            $value = Cache::get('key');

            return [
                // ...
            ];
        }
    }

Podemos simular la llamada a la facade `Cache` utilizando el método `shouldReceive`, que devolverá una instancia de un [Mockery](https://github.com/padraic/mockery) mock. Dado que las facades son realmente resueltas y gestionadas por el [contenedor de servicios](/docs/{{version}}/container) de Laravel, tienen mucha más capacidad de prueba que una clase estática típica. Por ejemplo, simulemos nuestra llamada al método `get` de la facade `Cache`:

```php tab=Pest
<?php

use Illuminate\Support\Facades\Cache;

test('get index', function () {
    Cache::shouldReceive('get')
                ->once()
                ->with('key')
                ->andReturn('value');

    $response = $this->get('/users');

    // ...
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class UserControllerTest extends TestCase
{
    public function test_get_index(): void
    {
        Cache::shouldReceive('get')
                    ->once()
                    ->with('key')
                    ->andReturn('value');

        $response = $this->get('/users');

        // ...
    }
}
```

> [!WARNING]  
> No debes simular la facade `Request`. En su lugar, pasa la entrada que desees a los [métodos de prueba HTTP](/docs/{{version}}/http-tests) como `get` y `post` al ejecutar tu prueba. Del mismo modo, en lugar de simular la facade `Config`, llama al método `Config::set` en tus pruebas.

<a name="facade-spies"></a>
### Espías de Facade

Si deseas [espiar](http://docs.mockery.io/en/latest/reference/spies.html) una facade, puedes llamar al método `spy` en la facade correspondiente. Los espías son similares a los mocks; sin embargo, los espías registran cualquier interacción entre el espía y el código que se está probando, lo que te permite hacer afirmaciones después de que se ejecute el código:

```php tab=Pest
<?php

use Illuminate\Support\Facades\Cache;

test('values are be stored in cache', function () {
    Cache::spy();

    $response = $this->get('/');

    $response->assertStatus(200);

    Cache::shouldHaveReceived('put')->once()->with('name', 'Taylor', 10);
});
```

```php tab=PHPUnit
use Illuminate\Support\Facades\Cache;

public function test_values_are_be_stored_in_cache(): void
{
    Cache::spy();

    $response = $this->get('/');

    $response->assertStatus(200);

    Cache::shouldHaveReceived('put')->once()->with('name', 'Taylor', 10);
}
```

<a name="interacting-with-time"></a>
## Interacción con el Tiempo

Al probar, es posible que ocasionalmente necesites modificar el tiempo devuelto por ayudantes como `now` o `Illuminate\Support\Carbon::now()`. Afortunadamente, la clase base de prueba de características de Laravel incluye ayudantes que te permiten manipular el tiempo actual:

```php tab=Pest
test('time can be manipulated', function () {
    // Travel into the future...
    $this->travel(5)->milliseconds();
    $this->travel(5)->seconds();
    $this->travel(5)->minutes();
    $this->travel(5)->hours();
    $this->travel(5)->days();
    $this->travel(5)->weeks();
    $this->travel(5)->years();

    // Travel into the past...
    $this->travel(-5)->hours();

    // Travel to an explicit time...
    $this->travelTo(now()->subHours(6));

    // Return back to the present time...
    $this->travelBack();
});
```

```php tab=PHPUnit
public function test_time_can_be_manipulated(): void
{
    // Travel into the future...
    $this->travel(5)->milliseconds();
    $this->travel(5)->seconds();
    $this->travel(5)->minutes();
    $this->travel(5)->hours();
    $this->travel(5)->days();
    $this->travel(5)->weeks();
    $this->travel(5)->years();

    // Travel into the past...
    $this->travel(-5)->hours();

    // Travel to an explicit time...
    $this->travelTo(now()->subHours(6));

    // Return back to the present time...
    $this->travelBack();
}
```

También puedes proporcionar una función anónima a los diversos métodos de viaje en el tiempo. La función anónima se invocará con el tiempo congelado en el momento especificado. Una vez que la función anónima se haya ejecutado, el tiempo se reanudará como de costumbre:

    $this->travel(5)->days(function () {
        // Probar algo cinco días en el futuro...
    });

    $this->travelTo(now()->subDays(10), function () {
        // Probar algo durante un momento dado...
    });

El método `freezeTime` puede ser utilizado para congelar el tiempo actual. De manera similar, el método `freezeSecond` congelará el tiempo actual pero al inicio del segundo actual:

    use Illuminate\Support\Carbon;

    // Congelar el tiempo y reanudar el tiempo normal después de ejecutar la función anónima...
    $this->freezeTime(function (Carbon $time) {
        // ...
    });

    // Congelar el tiempo en el segundo actual y reanudar el tiempo normal después de ejecutar la función anónima...
    $this->freezeSecond(function (Carbon $time) {
        // ...
    })

Como cabría esperar, todos los métodos discutidos anteriormente son principalmente útiles para probar el comportamiento de la aplicación sensible al tiempo, como bloquear publicaciones inactivas en un foro de discusión:

```php tab=Pest
use App\Models\Thread;

test('forum threads lock after one week of inactivity', function () {
    $thread = Thread::factory()->create();

    $this->travel(1)->week();

    expect($thread->isLockedByInactivity())->toBeTrue();
});
```

```php tab=PHPUnit
use App\Models\Thread;

public function test_forum_threads_lock_after_one_week_of_inactivity()
{
    $thread = Thread::factory()->create();

    $this->travel(1)->week();

    $this->assertTrue($thread->isLockedByInactivity());
}
```
