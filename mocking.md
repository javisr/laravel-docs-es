# Simulación (Mocking)

- [Introducción](#introduction)
- [Simulación de Objetos](#mocking-objects)
- [Simulación de Facades](#mocking-facades)
  - [Espías de Facade](#facade-spies)
- [Interacción con el Tiempo](#interacting-with-time)

<a name="introduction"></a>
## Introducción

Al probar aplicaciones Laravel, es posible que desees "simular" ciertos aspectos de tu aplicación para que no se ejecuten realmente durante una prueba dada. Por ejemplo, al probar un controlador que despacha un evento, es posible que desees simular los oyentes de eventos para que no se ejecuten realmente durante la prueba. Esto te permite probar solo la respuesta HTTP del controlador sin preocuparte por la ejecución de los oyentes de eventos, ya que los oyentes de eventos se pueden probar en su propio caso de prueba.
Laravel proporciona métodos útiles para simular eventos, trabajos y otras fachadas de forma predeterminada. Estos helpers principalmente ofrecen una capa de conveniencia sobre Mockery para que no tengas que realizar llamadas a métodos complicadas de Mockery manualmente.

<a name="mocking-objects"></a>
## Simulando Objetos

Al simular un objeto que se va a inyectar en tu aplicación a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel, necesitarás vincular tu instancia simulada en el contenedor como un enlace de `instancia`. Esto indicará al contenedor que use tu instancia simulada del objeto en lugar de construir el objeto por sí mismo:


```php
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


```php
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
Para hacer esto más conveniente, puedes usar el método `mock` que proporciona la clase base de casos de prueba de Laravel. Por ejemplo, el siguiente ejemplo es equivalente al ejemplo anterior:


```php
use App\Service;
use Mockery\MockInterface;

$mock = $this->mock(Service::class, function (MockInterface $mock) {
    $mock->shouldReceive('process')->once();
});
```
Puedes usar el método `partialMock` cuando solo necesitas simular algunos métodos de un objeto. Los métodos que no están simulados se ejecutarán normalmente cuando se llamen:


```php
use App\Service;
use Mockery\MockInterface;

$mock = $this->partialMock(Service::class, function (MockInterface $mock) {
    $mock->shouldReceive('process')->once();
});
```
De manera similar, si deseas [espiar](http://docs.mockery.io/en/latest/reference/spies.html) un objeto, la clase base de casos de prueba de Laravel ofrece un método `spy` como un envoltorio conveniente alrededor del método `Mockery::spy`. Los spies son similares a los mocks; sin embargo, los spies registran cualquier interacción entre el spy y el código que se está probando, lo que te permite hacer afirmaciones después de que se ejecute el código:


```php
use App\Service;

$spy = $this->spy(Service::class);

// ...

$spy->shouldHaveReceived('process');
```

<a name="mocking-facades"></a>
## Simulando Facades

A diferencia de las llamadas a métodos estáticos tradicionales, [facades](/docs/%7B%7Bversion%7D%7D/facades) (incluyendo [real-time facades](/docs/%7B%7Bversion%7D%7D/facades#real-time-facades)) pueden ser simuladas. Esto proporciona una gran ventaja sobre los métodos estáticos tradicionales y te otorga la misma capacidad de prueba que tendrías si estuvieras usando inyección de dependencias tradicional. Al probar, a menudo querrás simular una llamada a un facade de Laravel que ocurre en uno de tus controladores. Por ejemplo, considera la siguiente acción de controlador:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Cache;

class UserController extends Controller
{
    /**
     * Retrieve a list of all users of the application.
     */
    public function index(): array
    {
        $value = Cache::get('key');

        return [
            // ...
        ];
    }
}
```
Podemos simular la llamada a la facade `Cache` utilizando el método `shouldReceive`, que devolverá una instancia de un mock de [Mockery](https://github.com/padraic/mockery). Dado que las facades son en realidad resueltas y gestionadas por el [contenedor de servicios]( /docs/%7B%7Bversion%7D%7D/container) de Laravel, tienen mucha más capacidad de prueba que una clase estática típica. Por ejemplo, simulamos nuestra llamada al método `get` de la facade `Cache`:


```php
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


```php
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
No debes simular la `facade` `Request`. En su lugar, pasa la entrada que deseas en los [métodos de prueba HTTP](/docs/%7B%7Bversion%7D%7D/http-tests) como `get` y `post` al ejecutar tu prueba. Del mismo modo, en lugar de simular la `facade` `Config`, llama al método `Config::set` en tus pruebas.

<a name="facade-spies"></a>
### Espías de Facade

Si deseas [espiar](http://docs.mockery.io/en/latest/reference/spies.html) en una fachada, puedes llamar al método `spy` en la fachada correspondiente. Los espías son similares a los mocks; sin embargo, los espías registran cualquier interacción entre el espía y el código que se está probando, lo que te permite hacer afirmaciones después de que se ejecute el código:


```php
<?php

use Illuminate\Support\Facades\Cache;

test('values are be stored in cache', function () {
    Cache::spy();

    $response = $this->get('/');

    $response->assertStatus(200);

    Cache::shouldHaveReceived('put')->once()->with('name', 'Taylor', 10);
});

```


```php
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
## Interactuando Con el Tiempo

Al probar, es posible que ocasionalmente necesites modificar el tiempo devuelto por ayudantes como `now` o `Illuminate\Support\Carbon::now()`. Afortunadamente, la clase base de prueba de características de Laravel incluye ayudantes que te permiten manipular el tiempo actual:


```php
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


```php
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
También puedes proporcionar una `función anónima` a los varios métodos de viaje en el tiempo. La `función anónima` se invocará con el tiempo congelado en el momento especificado. Una vez que se haya ejecutado la `función anónima`, el tiempo reanudará su curso normal:


```php
$this->travel(5)->days(function () {
    // Test something five days into the future...
});

$this->travelTo(now()->subDays(10), function () {
    // Test something during a given moment...
});
```
El método `freezeTime` se puede utilizar para congelar el tiempo actual. De manera similar, el método `freezeSecond` congelará el tiempo actual, pero al inicio del segundo actual:


```php
use Illuminate\Support\Carbon;

// Freeze time and resume normal time after executing closure...
$this->freezeTime(function (Carbon $time) {
    // ...
});

// Freeze time at the current second and resume normal time after executing closure...
$this->freezeSecond(function (Carbon $time) {
    // ...
})
```
Como era de esperar, todos los métodos discutidos anteriormente son principalmente útiles para probar el comportamiento de aplicaciones sensibles al tiempo, como bloquear publicaciones inactivas en un foro de discusión:


```php
use App\Models\Thread;

test('forum threads lock after one week of inactivity', function () {
    $thread = Thread::factory()->create();

    $this->travel(1)->week();

    expect($thread->isLockedByInactivity())->toBeTrue();
});

```


```php
use App\Models\Thread;

public function test_forum_threads_lock_after_one_week_of_inactivity()
{
    $thread = Thread::factory()->create();

    $this->travel(1)->week();

    $this->assertTrue($thread->isLockedByInactivity());
}

```