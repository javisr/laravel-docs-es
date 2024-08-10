# Pruebas HTTP

- [Introducción](#introduction)
- [Realizando Solicitudes](#making-requests)
    - [Personalizando Encabezados de Solicitud](#customizing-request-headers)
    - [Cookies](#cookies)
    - [Sesión / Autenticación](#session-and-authentication)
    - [Depuración de Respuestas](#debugging-responses)
    - [Manejo de Excepciones](#exception-handling)
- [Pruebas de APIs JSON](#testing-json-apis)
    - [Pruebas JSON Fluida](#fluent-json-testing)
- [Pruebas de Cargas de Archivos](#testing-file-uploads)
- [Pruebas de Vistas](#testing-views)
    - [Renderizando Blade y Componentes](#rendering-blade-and-components)
- [Aserciones Disponibles](#available-assertions)
    - [Aserciones de Respuesta](#response-assertions)
    - [Aserciones de Autenticación](#authentication-assertions)
    - [Aserciones de Validación](#validation-assertions)

<a name="introduction"></a>
## Introducción

Laravel proporciona una API muy fluida para realizar solicitudes HTTP a tu aplicación y examinar las respuestas. Por ejemplo, echa un vistazo a la prueba de características definida a continuación:

```php tab=Pest
<?php

test('the application returns a successful response', function () {
    $response = $this->get('/');

    $response->assertStatus(200);
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }
}
```

El método `get` realiza una solicitud `GET` a la aplicación, mientras que el método `assertStatus` afirma que la respuesta devuelta debe tener el código de estado HTTP dado. Además de esta simple aserción, Laravel también contiene una variedad de aserciones para inspeccionar los encabezados de respuesta, contenido, estructura JSON y más.

<a name="making-requests"></a>
## Realizando Solicitudes

Para realizar una solicitud a tu aplicación, puedes invocar los métodos `get`, `post`, `put`, `patch` o `delete` dentro de tu prueba. Estos métodos no emiten realmente una solicitud HTTP "real" a tu aplicación. En cambio, toda la solicitud de red se simula internamente.

En lugar de devolver una instancia de `Illuminate\Http\Response`, los métodos de solicitud de prueba devuelven una instancia de `Illuminate\Testing\TestResponse`, que proporciona una [variedad de aserciones útiles](#available-assertions) que te permiten inspeccionar las respuestas de tu aplicación:

```php tab=Pest
<?php

test('basic request', function () {
    $response = $this->get('/');

    $response->assertStatus(200);
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_a_basic_request(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }
}
```

En general, cada una de tus pruebas debería realizar solo una solicitud a tu aplicación. Puede ocurrir un comportamiento inesperado si se ejecutan múltiples solicitudes dentro de un solo método de prueba.

> [!NOTE]  
> Para mayor comodidad, el middleware CSRF se desactiva automáticamente al ejecutar pruebas.

<a name="customizing-request-headers"></a>
### Personalizando Encabezados de Solicitud

Puedes usar el método `withHeaders` para personalizar los encabezados de la solicitud antes de que se envíen a la aplicación. Este método te permite agregar cualquier encabezado personalizado que desees a la solicitud:

```php tab=Pest
<?php

test('interacting with headers', function () {
    $response = $this->withHeaders([
        'X-Header' => 'Value',
    ])->post('/user', ['name' => 'Sally']);

    $response->assertStatus(201);
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic functional test example.
     */
    public function test_interacting_with_headers(): void
    {
        $response = $this->withHeaders([
            'X-Header' => 'Value',
        ])->post('/user', ['name' => 'Sally']);

        $response->assertStatus(201);
    }
}
```

<a name="cookies"></a>
### Cookies

Puedes usar los métodos `withCookie` o `withCookies` para establecer valores de cookies antes de realizar una solicitud. El método `withCookie` acepta un nombre de cookie y un valor como sus dos argumentos, mientras que el método `withCookies` acepta un array de pares nombre / valor:

```php tab=Pest
<?php

test('interacting with cookies', function () {
    $response = $this->withCookie('color', 'blue')->get('/');

    $response = $this->withCookies([
        'color' => 'blue',
        'name' => 'Taylor',
    ])->get('/');

    //
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_interacting_with_cookies(): void
    {
        $response = $this->withCookie('color', 'blue')->get('/');

        $response = $this->withCookies([
            'color' => 'blue',
            'name' => 'Taylor',
        ])->get('/');

        //
    }
}
```

<a name="session-and-authentication"></a>
### Sesión / Autenticación

Laravel proporciona varios helpers para interactuar con la sesión durante las pruebas HTTP. Primero, puedes establecer los datos de la sesión a un array dado usando el método `withSession`. Esto es útil para cargar la sesión con datos antes de emitir una solicitud a tu aplicación:

```php tab=Pest
<?php

test('interacting with the session', function () {
    $response = $this->withSession(['banned' => false])->get('/');

    //
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_interacting_with_the_session(): void
    {
        $response = $this->withSession(['banned' => false])->get('/');

        //
    }
}
```

La sesión de Laravel se utiliza típicamente para mantener el estado del usuario actualmente autenticado. Por lo tanto, el método helper `actingAs` proporciona una forma simple de autenticar a un usuario dado como el usuario actual. Por ejemplo, podemos usar una [factory de modelo](/docs/{{version}}/eloquent-factories) para generar y autenticar a un usuario:

```php tab=Pest
<?php

use App\Models\User;

test('an action that requires authentication', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user)
                     ->withSession(['banned' => false])
                     ->get('/');

    //
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use App\Models\User;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_an_action_that_requires_authentication(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)
                         ->withSession(['banned' => false])
                         ->get('/');

        //
    }
}
```

También puedes especificar qué guardia debe usarse para autenticar al usuario dado pasando el nombre de la guardia como segundo argumento al método `actingAs`. La guardia que se proporciona al método `actingAs` también se convertirá en la guardia predeterminada durante la duración de la prueba:

    $this->actingAs($user, 'web')

<a name="debugging-responses"></a>
### Depuración de Respuestas

Después de realizar una solicitud de prueba a tu aplicación, los métodos `dump`, `dumpHeaders` y `dumpSession` pueden usarse para examinar y depurar el contenido de la respuesta:

```php tab=Pest
<?php

test('basic test', function () {
    $response = $this->get('/');

    $response->dumpHeaders();

    $response->dumpSession();

    $response->dump();
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_basic_test(): void
    {
        $response = $this->get('/');

        $response->dumpHeaders();

        $response->dumpSession();

        $response->dump();
    }
}
```

Alternativamente, puedes usar los métodos `dd`, `ddHeaders` y `ddSession` para volcar información sobre la respuesta y luego detener la ejecución:

```php tab=Pest
<?php

test('basic test', function () {
    $response = $this->get('/');

    $response->ddHeaders();

    $response->ddSession();

    $response->dd();
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_basic_test(): void
    {
        $response = $this->get('/');

        $response->ddHeaders();

        $response->ddSession();

        $response->dd();
    }
}
```

<a name="exception-handling"></a>
### Manejo de Excepciones

A veces, puede que necesites probar que tu aplicación está lanzando una excepción específica. Para lograr esto, puedes "fingir" el manejador de excepciones a través de la fachada `Exceptions`. Una vez que el manejador de excepciones ha sido fingido, puedes utilizar los métodos `assertReported` y `assertNotReported` para hacer aserciones contra excepciones que fueron lanzadas durante la solicitud:

```php tab=Pest
<?php

use App\Exceptions\InvalidOrderException;
use Illuminate\Support\Facades\Exceptions;

test('exception is thrown', function () {
    Exceptions::fake();

    $response = $this->get('/order/1');

    // Assert an exception was thrown...
    Exceptions::assertReported(InvalidOrderException::class);

    // Assert against the exception...
    Exceptions::assertReported(function (InvalidOrderException $e) {
        return $e->getMessage() === 'The order was invalid.';
    });
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use App\Exceptions\InvalidOrderException;
use Illuminate\Support\Facades\Exceptions;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_exception_is_thrown(): void
    {
        Exceptions::fake();

        $response = $this->get('/');

        // Assert an exception was thrown...
        Exceptions::assertReported(InvalidOrderException::class);

        // Assert against the exception...
        Exceptions::assertReported(function (InvalidOrderException $e) {
            return $e->getMessage() === 'The order was invalid.';
        });
    }
}
```

Los métodos `assertNotReported` y `assertNothingReported` pueden usarse para afirmar que una excepción dada no fue lanzada durante la solicitud o que no se lanzaron excepciones:

```php
Exceptions::assertNotReported(InvalidOrderException::class);

Exceptions::assertNothingReported();
```

Puedes desactivar completamente el manejo de excepciones para una solicitud dada invocando el método `withoutExceptionHandling` antes de realizar tu solicitud:

    $response = $this->withoutExceptionHandling()->get('/');

Además, si deseas asegurarte de que tu aplicación no esté utilizando características que han sido desaprobadas por el lenguaje PHP o las bibliotecas que tu aplicación está utilizando, puedes invocar el método `withoutDeprecationHandling` antes de realizar tu solicitud. Cuando el manejo de desaprobaciones está desactivado, las advertencias de desaprobación se convertirán en excepciones, lo que hará que tu prueba falle:

    $response = $this->withoutDeprecationHandling()->get('/');

El método `assertThrows` puede usarse para afirmar que el código dentro de una determinada función anónima lanza una excepción del tipo especificado:

```php
$this->assertThrows(
    fn () => (new ProcessOrder)->execute(),
    OrderInvalid::class
);
```

Si deseas inspeccionar y hacer aserciones contra la excepción que se lanza, puedes proporcionar una función anónima como segundo argumento al método `assertThrows`:

```php
$this->assertThrows(
    fn () => (new ProcessOrder)->execute(),
    fn (OrderInvalid $e) => $e->orderId() === 123;
);
```

<a name="testing-json-apis"></a>
## Pruebas de APIs JSON

Laravel también proporciona varios helpers para probar APIs JSON y sus respuestas. Por ejemplo, los métodos `json`, `getJson`, `postJson`, `putJson`, `patchJson`, `deleteJson` y `optionsJson` pueden usarse para emitir solicitudes JSON con varios verbos HTTP. También puedes pasar fácilmente datos y encabezados a estos métodos. Para comenzar, escribamos una prueba para realizar una solicitud `POST` a `/api/user` y afirmar que los datos JSON esperados fueron devueltos:

```php tab=Pest
<?php

test('making an api request', function () {
    $response = $this->postJson('/api/user', ['name' => 'Sally']);

    $response
        ->assertStatus(201)
        ->assertJson([
            'created' => true,
         ]);
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic functional test example.
     */
    public function test_making_an_api_request(): void
    {
        $response = $this->postJson('/api/user', ['name' => 'Sally']);

        $response
            ->assertStatus(201)
            ->assertJson([
                'created' => true,
            ]);
    }
}
```

Además, los datos de respuesta JSON pueden accederse como variables de array en la respuesta, lo que facilita la inspección de los valores individuales devueltos dentro de una respuesta JSON:

```php tab=Pest
expect($response['created'])->toBeTrue();
```

```php tab=PHPUnit
$this->assertTrue($response['created']);
```

> [!NOTE]  
> El método `assertJson` convierte la respuesta en un array y utiliza `PHPUnit::assertArraySubset` para verificar que el array dado exista dentro de la respuesta JSON devuelta por la aplicación. Así que, si hay otras propiedades en la respuesta JSON, esta prueba seguirá pasando siempre que el fragmento dado esté presente.

<a name="verifying-exact-match"></a>
#### Afirmando Coincidencias JSON Exactas

Como se mencionó anteriormente, el método `assertJson` puede usarse para afirmar que un fragmento de JSON existe dentro de la respuesta JSON. Si deseas verificar que un array dado **coincida exactamente** con el JSON devuelto por tu aplicación, debes usar el método `assertExactJson`:

```php tab=Pest
<?php

test('asserting an exact json match', function () {
    $response = $this->postJson('/user', ['name' => 'Sally']);

    $response
        ->assertStatus(201)
        ->assertExactJson([
            'created' => true,
        ]);
});

```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic functional test example.
     */
    public function test_asserting_an_exact_json_match(): void
    {
        $response = $this->postJson('/user', ['name' => 'Sally']);

        $response
            ->assertStatus(201)
            ->assertExactJson([
                'created' => true,
            ]);
    }
}
```

<a name="verifying-json-paths"></a>
#### Afirmando Rutas JSON

Si deseas verificar que la respuesta JSON contenga los datos dados en una ruta especificada, debes usar el método `assertJsonPath`:

```php tab=Pest
<?php

test('asserting a json path value', function () {
    $response = $this->postJson('/user', ['name' => 'Sally']);

    $response
        ->assertStatus(201)
        ->assertJsonPath('team.owner.name', 'Darian');
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic functional test example.
     */
    public function test_asserting_a_json_paths_value(): void
    {
        $response = $this->postJson('/user', ['name' => 'Sally']);

        $response
            ->assertStatus(201)
            ->assertJsonPath('team.owner.name', 'Darian');
    }
}
```

El método `assertJsonPath` también acepta una función anónima, que puede usarse para determinar dinámicamente si la aserción debe pasar:

    $response->assertJsonPath('team.owner.name', fn (string $name) => strlen($name) >= 3);

<a name="fluent-json-testing"></a>
### Pruebas JSON Fluida

Laravel también ofrece una forma hermosa de probar de manera fluida las respuestas JSON de tu aplicación. Para comenzar, pasa una función anónima al método `assertJson`. Esta función anónima será invocada con una instancia de `Illuminate\Testing\Fluent\AssertableJson` que puede usarse para hacer aserciones contra el JSON que fue devuelto por tu aplicación. El método `where` puede usarse para hacer aserciones contra un atributo particular del JSON, mientras que el método `missing` puede usarse para afirmar que un atributo particular falta en el JSON:

```php tab=Pest
use Illuminate\Testing\Fluent\AssertableJson;

test('fluent json', function () {
    $response = $this->getJson('/users/1');

    $response
        ->assertJson(fn (AssertableJson $json) =>
            $json->where('id', 1)
                 ->where('name', 'Victoria Faith')
                 ->where('email', fn (string $email) => str($email)->is('victoria@gmail.com'))
                 ->whereNot('status', 'pending')
                 ->missing('password')
                 ->etc()
        );
});
```

```php tab=PHPUnit
use Illuminate\Testing\Fluent\AssertableJson;

/**
 * A basic functional test example.
 */
public function test_fluent_json(): void
{
    $response = $this->getJson('/users/1');

    $response
        ->assertJson(fn (AssertableJson $json) =>
            $json->where('id', 1)
                 ->where('name', 'Victoria Faith')
                 ->where('email', fn (string $email) => str($email)->is('victoria@gmail.com'))
                 ->whereNot('status', 'pending')
                 ->missing('password')
                 ->etc()
        );
}
```

#### Entendiendo el Método `etc`

En el ejemplo anterior, es posible que hayas notado que invocamos el método `etc` al final de nuestra cadena de aserciones. Este método informa a Laravel que puede haber otros atributos presentes en el objeto JSON. Si no se utiliza el método `etc`, la prueba fallará si existen otros atributos contra los que no hiciste aserciones en el objeto JSON.

La intención detrás de este comportamiento es protegerte de exponer información sensible en tus respuestas JSON al obligarte a hacer una aserción explícita contra el atributo o permitir explícitamente atributos adicionales a través del método `etc`.

Sin embargo, debes tener en cuenta que no incluir el método `etc` en tu cadena de aserciones no garantiza que no se estén agregando atributos adicionales a los arrays que están anidados dentro de tu objeto JSON. El método `etc` solo asegura que no existan atributos adicionales en el nivel de anidación en el que se invoca el método `etc`.

<a name="asserting-json-attribute-presence-and-absence"></a>
#### Afirmando Presencia / Ausencia de Atributos

Para afirmar que un atributo está presente o ausente, puedes usar los métodos `has` y `missing`:

    $response->assertJson(fn (AssertableJson $json) =>
        $json->has('data')
             ->missing('message')
    );

Además, los métodos `hasAll` y `missingAll` permiten afirmar la presencia o ausencia de múltiples atributos simultáneamente:

    $response->assertJson(fn (AssertableJson $json) =>
        $json->hasAll(['status', 'data'])
             ->missingAll(['message', 'code'])
    );

Puedes usar el método `hasAny` para determinar si al menos uno de una lista dada de atributos está presente:

    $response->assertJson(fn (AssertableJson $json) =>
        $json->has('status')
             ->hasAny('data', 'message', 'code')
    );

<a name="asserting-against-json-collections"></a>
#### Afirmando Contra Colecciones JSON

A menudo, tu ruta devolverá una respuesta JSON que contiene múltiples elementos, como múltiples usuarios:

    Route::get('/users', function () {
        return User::all();
    });

En estas situaciones, podemos usar el método `has` del objeto JSON fluido para hacer aserciones contra los usuarios incluidos en la respuesta. Por ejemplo, afirmemos que la respuesta JSON contiene tres usuarios. A continuación, haremos algunas aserciones sobre el primer usuario en la colección usando el método `first`. El método `first` acepta una función anónima que recibe otro string JSON asertable que podemos usar para hacer aserciones sobre el primer objeto en la colección JSON:

    $response
        ->assertJson(fn (AssertableJson $json) =>
            $json->has(3)
                 ->first(fn (AssertableJson $json) =>
                    $json->where('id', 1)
                         ->where('name', 'Victoria Faith')
                         ->where('email', fn (string $email) => str($email)->is('victoria@gmail.com'))
                         ->missing('password')
                         ->etc()
                 )
        );

<a name="scoping-json-collection-assertions"></a>
#### Limitando Aserciones de Colección JSON

A veces, las rutas de tu aplicación devolverán colecciones JSON que están asignadas a claves nombradas:

    Route::get('/users', function () {
        return [
            'meta' => [...],
            'users' => User::all(),
        ];
    })

Al probar estas rutas, puedes usar el método `has` para afirmar contra el número de elementos en la colección. Además, puedes usar el método `has` para limitar una cadena de aserciones:

    $response
        ->assertJson(fn (AssertableJson $json) =>
            $json->has('meta')
                 ->has('users', 3)
                 ->has('users.0', fn (AssertableJson $json) =>
                    $json->where('id', 1)
                         ->where('name', 'Victoria Faith')
                         ->where('email', fn (string $email) => str($email)->is('victoria@gmail.com'))
                         ->missing('password')
                         ->etc()
                 )
        );

Sin embargo, en lugar de hacer dos llamadas separadas al método `has` para afirmar contra la colección `users`, puedes hacer una sola llamada que proporcione una función anónima como su tercer parámetro. Al hacerlo, la función anónima se invocará automáticamente y se limitará al primer elemento de la colección:

    $response
        ->assertJson(fn (AssertableJson $json) =>
            $json->has('meta')
                 ->has('users', 3, fn (AssertableJson $json) =>
                    $json->where('id', 1)
                         ->where('name', 'Victoria Faith')
                         ->where('email', fn (string $email) => str($email)->is('victoria@gmail.com'))
                         ->missing('password')
                         ->etc()
                 )
        );

<a name="asserting-json-types"></a>
#### Afirmando Tipos JSON

Es posible que solo desees afirmar que las propiedades en la respuesta JSON son de un cierto tipo. La clase `Illuminate\Testing\Fluent\AssertableJson` proporciona los métodos `whereType` y `whereAllType` para hacer precisamente eso:

    $response->assertJson(fn (AssertableJson $json) =>
        $json->whereType('id', 'integer')
             ->whereAllType([
                'users.0.name' => 'string',
                'meta' => 'array'
            ])
    );

Puedes especificar múltiples tipos usando el carácter `|`, o pasando un array de tipos como segundo parámetro al método `whereType`. La aserción será exitosa si el valor de respuesta es cualquiera de los tipos listados:

    $response->assertJson(fn (AssertableJson $json) =>
        $json->whereType('name', 'string|null')
             ->whereType('id', ['string', 'integer'])
    );

Los métodos `whereType` y `whereAllType` reconocen los siguientes tipos: `string`, `integer`, `double`, `boolean`, `array` y `null`.

<a name="testing-file-uploads"></a>
## Pruebas de Carga de Archivos

La clase `Illuminate\Http\UploadedFile` proporciona un método `fake` que se puede utilizar para generar archivos o imágenes de prueba. Esto, combinado con el método `fake` de la fachada `Storage`, simplifica enormemente la prueba de cargas de archivos. Por ejemplo, puedes combinar estas dos características para probar fácilmente un formulario de carga de avatar:

```php tab=Pest
<?php

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

test('avatars can be uploaded', function () {
    Storage::fake('avatars');

    $file = UploadedFile::fake()->image('avatar.jpg');

    $response = $this->post('/avatar', [
        'avatar' => $file,
    ]);

    Storage::disk('avatars')->assertExists($file->hashName());
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_avatars_can_be_uploaded(): void
    {
        Storage::fake('avatars');

        $file = UploadedFile::fake()->image('avatar.jpg');

        $response = $this->post('/avatar', [
            'avatar' => $file,
        ]);

        Storage::disk('avatars')->assertExists($file->hashName());
    }
}
```

Si deseas afirmar que un archivo dado no existe, puedes usar el método `assertMissing` proporcionado por la fachada `Storage`:

    Storage::fake('avatars');

    // ...

    Storage::disk('avatars')->assertMissing('missing.jpg');

<a name="fake-file-customization"></a>
#### Personalización de Archivos Falsos

Al crear archivos utilizando el método `fake` proporcionado por la clase `UploadedFile`, puedes especificar el ancho, la altura y el tamaño de la imagen (en kilobytes) para probar mejor las reglas de validación de tu aplicación:

    UploadedFile::fake()->image('avatar.jpg', $width, $height)->size(100);

Además de crear imágenes, puedes crear archivos de cualquier otro tipo utilizando el método `create`:

    UploadedFile::fake()->create('document.pdf', $sizeInKilobytes);

Si es necesario, puedes pasar un argumento `$mimeType` al método para definir explícitamente el tipo MIME que debe ser devuelto por el archivo:

    UploadedFile::fake()->create(
        'document.pdf', $sizeInKilobytes, 'application/pdf'
    );

<a name="testing-views"></a>
## Pruebas de Vistas

Laravel también te permite renderizar una vista sin realizar una solicitud HTTP simulada a la aplicación. Para lograr esto, puedes llamar al método `view` dentro de tu prueba. El método `view` acepta el nombre de la vista y un array opcional de datos. El método devuelve una instancia de `Illuminate\Testing\TestView`, que ofrece varios métodos para hacer afirmaciones sobre el contenido de la vista:

```php tab=Pest
<?php

test('a welcome view can be rendered', function () {
    $view = $this->view('welcome', ['name' => 'Taylor']);

    $view->assertSee('Taylor');
});
```

```php tab=PHPUnit
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_a_welcome_view_can_be_rendered(): void
    {
        $view = $this->view('welcome', ['name' => 'Taylor']);

        $view->assertSee('Taylor');
    }
}
```

La clase `TestView` proporciona los siguientes métodos de afirmación: `assertSee`, `assertSeeInOrder`, `assertSeeText`, `assertSeeTextInOrder`, `assertDontSee` y `assertDontSeeText`.

Si es necesario, puedes obtener el contenido de la vista renderizada en crudo convirtiendo la instancia de `TestView` a una cadena:

    $contents = (string) $this->view('welcome');

<a name="sharing-errors"></a>
#### Compartiendo Errores

Algunas vistas pueden depender de errores compartidos en el [conjunto de errores global proporcionado por Laravel](/docs/{{version}}/validation#quick-displaying-the-validation-errors). Para hidratar el conjunto de errores con mensajes de error, puedes usar el método `withViewErrors`:

    $view = $this->withViewErrors([
        'name' => ['Por favor proporciona un nombre válido.']
    ])->view('form');

    $view->assertSee('Por favor proporciona un nombre válido.');

<a name="rendering-blade-and-components"></a>
### Renderizando Blade y Componentes

Si es necesario, puedes usar el método `blade` para evaluar y renderizar una cadena [Blade](/docs/{{version}}/blade) en crudo. Al igual que el método `view`, el método `blade` devuelve una instancia de `Illuminate\Testing\TestView`:

    $view = $this->blade(
        '<x-component :name="$name" />',
        ['name' => 'Taylor']
    );

    $view->assertSee('Taylor');

Puedes usar el método `component` para evaluar y renderizar un [componente Blade](/docs/{{version}}/blade#components). El método `component` devuelve una instancia de `Illuminate\Testing\TestComponent`:

    $view = $this->component(Profile::class, ['name' => 'Taylor']);

    $view->assertSee('Taylor');

<a name="available-assertions"></a>
## Afirmaciones Disponibles

<a name="response-assertions"></a>
### Afirmaciones de Respuesta

La clase `Illuminate\Testing\TestResponse` de Laravel proporciona una variedad de métodos de afirmación personalizados que puedes utilizar al probar tu aplicación. Estas afirmaciones se pueden acceder en la respuesta que es devuelta por los métodos de prueba `json`, `get`, `post`, `put` y `delete`:

<style>
    .collection-method-list > p {
        columns: 14.4em 2; -moz-columns: 14.4em 2; -webkit-columns: 14.4em 2;
    }

    .collection-method-list a {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
</style>

<div class="collection-method-list" markdown="1">

[assertAccepted](#assert-accepted)
[assertBadRequest](#assert-bad-request)
[assertConflict](#assert-conflict)
[assertCookie](#assert-cookie)
[assertCookieExpired](#assert-cookie-expired)
[assertCookieNotExpired](#assert-cookie-not-expired)
[assertCookieMissing](#assert-cookie-missing)
[assertCreated](#assert-created)
[assertDontSee](#assert-dont-see)
[assertDontSeeText](#assert-dont-see-text)
[assertDownload](#assert-download)
[assertExactJson](#assert-exact-json)
[assertForbidden](#assert-forbidden)
[assertFound](#assert-found)
[assertGone](#assert-gone)
[assertHeader](#assert-header)
[assertHeaderMissing](#assert-header-missing)
[assertInternalServerError](#assert-internal-server-error)
[assertJson](#assert-json)
[assertJsonCount](#assert-json-count)
[assertJsonFragment](#assert-json-fragment)
[assertJsonIsArray](#assert-json-is-array)
[assertJsonIsObject](#assert-json-is-object)
[assertJsonMissing](#assert-json-missing)
[assertJsonMissingExact](#assert-json-missing-exact)
[assertJsonMissingValidationErrors](#assert-json-missing-validation-errors)
[assertJsonPath](#assert-json-path)
[assertJsonMissingPath](#assert-json-missing-path)
[assertJsonStructure](#assert-json-structure)
[assertJsonValidationErrors](#assert-json-validation-errors)
[assertJsonValidationErrorFor](#assert-json-validation-error-for)
[assertLocation](#assert-location)
[assertMethodNotAllowed](#assert-method-not-allowed)
[assertMovedPermanently](#assert-moved-permanently)
[assertContent](#assert-content)
[assertNoContent](#assert-no-content)
[assertStreamedContent](#assert-streamed-content)
[assertNotFound](#assert-not-found)
[assertOk](#assert-ok)
[assertPaymentRequired](#assert-payment-required)
[assertPlainCookie](#assert-plain-cookie)
[assertRedirect](#assert-redirect)
[assertRedirectContains](#assert-redirect-contains)
[assertRedirectToRoute](#assert-redirect-to-route)
[assertRedirectToSignedRoute](#assert-redirect-to-signed-route)
[assertRequestTimeout](#assert-request-timeout)
[assertSee](#assert-see)
[assertSeeInOrder](#assert-see-in-order)
[assertSeeText](#assert-see-text)
[assertSeeTextInOrder](#assert-see-text-in-order)
[assertServerError](#assert-server-error)
[assertServiceUnavailable](#assert-server-unavailable)
[assertSessionHas](#assert-session-has)
[assertSessionHasInput](#assert-session-has-input)
[assertSessionHasAll](#assert-session-has-all)
[assertSessionHasErrors](#assert-session-has-errors)
[assertSessionHasErrorsIn](#assert-session-has-errors-in)
[assertSessionHasNoErrors](#assert-session-has-no-errors)
[assertSessionDoesntHaveErrors](#assert-session-doesnt-have-errors)
[assertSessionMissing](#assert-session-missing)
[assertStatus](#assert-status)
[assertSuccessful](#assert-successful)
[assertTooManyRequests](#assert-too-many-requests)
[assertUnauthorized](#assert-unauthorized)
[assertUnprocessable](#assert-unprocessable)
[assertUnsupportedMediaType](#assert-unsupported-media-type)
[assertValid](#assert-valid)
[assertInvalid](#assert-invalid)
[assertViewHas](#assert-view-has)
[assertViewHasAll](#assert-view-has-all)
[assertViewIs](#assert-view-is)
[assertViewMissing](#assert-view-missing)

</div>

<a name="assert-bad-request"></a>
#### assertBadRequest

Afirmar que la respuesta tiene un código de estado HTTP de solicitud incorrecta (400):

    $response->assertBadRequest();

<a name="assert-accepted"></a>
#### assertAccepted

Afirmar que la respuesta tiene un código de estado HTTP aceptado (202):

    $response->assertAccepted();

<a name="assert-conflict"></a>
#### assertConflict

Afirmar que la respuesta tiene un código de estado HTTP de conflicto (409):

    $response->assertConflict();

<a name="assert-cookie"></a>
#### assertCookie

Afirmar que la respuesta contiene la cookie dada:

    $response->assertCookie($cookieName, $value = null);

<a name="assert-cookie-expired"></a>
#### assertCookieExpired

Afirmar que la respuesta contiene la cookie dada y que está expirada:

    $response->assertCookieExpired($cookieName);

<a name="assert-cookie-not-expired"></a>
#### assertCookieNotExpired

Afirmar que la respuesta contiene la cookie dada y que no está expirada:

    $response->assertCookieNotExpired($cookieName);

<a name="assert-cookie-missing"></a>
#### assertCookieMissing

Afirmar que la respuesta no contiene la cookie dada:

    $response->assertCookieMissing($cookieName);

<a name="assert-created"></a>
#### assertCreated

Afirmar que la respuesta tiene un código de estado HTTP 201:

    $response->assertCreated();

<a name="assert-dont-see"></a>
#### assertDontSee

Afirmar que la cadena dada no está contenida dentro de la respuesta devuelta por la aplicación. Esta afirmación escapará automáticamente la cadena dada a menos que pases un segundo argumento de `false`:

    $response->assertDontSee($value, $escaped = true);

<a name="assert-dont-see-text"></a>
#### assertDontSeeText

Afirmar que la cadena dada no está contenida dentro del texto de la respuesta. Esta afirmación escapará automáticamente la cadena dada a menos que pases un segundo argumento de `false`. Este método pasará el contenido de la respuesta a la función PHP `strip_tags` antes de hacer la afirmación:

    $response->assertDontSeeText($value, $escaped = true);

<a name="assert-download"></a>
#### assertDownload

Afirmar que la respuesta es una "descarga". Típicamente, esto significa que la ruta invocada que devolvió la respuesta devolvió una respuesta `Response::download`, `BinaryFileResponse` o `Storage::download`:

    $response->assertDownload();

Si lo deseas, puedes afirmar que el archivo descargable se le asignó un nombre de archivo dado:

    $response->assertDownload('image.jpg');

<a name="assert-exact-json"></a>
#### assertExactJson

Afirmar que la respuesta contiene una coincidencia exacta de los datos JSON dados:

    $response->assertExactJson(array $data);

<a name="assert-forbidden"></a>
#### assertForbidden

Afirmar que la respuesta tiene un código de estado HTTP prohibido (403):

    $response->assertForbidden();

<a name="assert-found"></a>
#### assertFound

Afirmar que la respuesta tiene un código de estado HTTP encontrado (302):

    $response->assertFound();

<a name="assert-gone"></a>
#### assertGone

Afirmar que la respuesta tiene un código de estado HTTP desaparecido (410):

    $response->assertGone();

<a name="assert-header"></a>
#### assertHeader

Afirmar que el encabezado y el valor dados están presentes en la respuesta:

    $response->assertHeader($headerName, $value = null);

<a name="assert-header-missing"></a>
#### assertHeaderMissing

Afirmar que el encabezado dado no está presente en la respuesta:

    $response->assertHeaderMissing($headerName);

<a name="assert-internal-server-error"></a>
#### assertInternalServerError

Afirmar que la respuesta tiene un código de estado HTTP de "Error Interno del Servidor" (500):

    $response->assertInternalServerError();

<a name="assert-json"></a>
#### assertJson

Afirmar que la respuesta contiene los datos JSON dados:

    $response->assertJson(array $data, $strict = false);

El método `assertJson` convierte la respuesta en un array y utiliza `PHPUnit::assertArraySubset` para verificar que el array dado exista dentro de la respuesta JSON devuelta por la aplicación. Por lo tanto, si hay otras propiedades en la respuesta JSON, esta prueba seguirá pasando siempre que el fragmento dado esté presente.

<a name="assert-json-count"></a>
#### assertJsonCount

Afirmar que la respuesta JSON tiene un array con el número esperado de elementos en la clave dada:

    $response->assertJsonCount($count, $key = null);

<a name="assert-json-fragment"></a>
#### assertJsonFragment

Afirmar que la respuesta contiene los datos JSON dados en cualquier parte de la respuesta:

    Route::get('/users', function () {
        return [
            'users' => [
                [
                    'name' => 'Taylor Otwell',
                ],
            ],
        ];
    });

    $response->assertJsonFragment(['name' => 'Taylor Otwell']);

<a name="assert-json-is-array"></a>
#### assertJsonIsArray

Afirmar que la respuesta JSON es un array:

    $response->assertJsonIsArray();

<a name="assert-json-is-object"></a>
#### assertJsonIsObject

Afirmar que la respuesta JSON es un objeto:

    $response->assertJsonIsObject();

<a name="assert-json-missing"></a>
#### assertJsonMissing

Afirmar que la respuesta no contiene los datos JSON dados:

    $response->assertJsonMissing(array $data);

<a name="assert-json-missing-exact"></a>
#### assertJsonMissingExact

Afirmar que la respuesta no contiene los datos JSON exactos:

    $response->assertJsonMissingExact(array $data);

<a name="assert-json-missing-validation-errors"></a>
#### assertJsonMissingValidationErrors

Afirmar que la respuesta no tiene errores de validación JSON para las claves dadas:

    $response->assertJsonMissingValidationErrors($keys);

> [!NOTE]  
> El método más genérico [assertValid](#assert-valid) puede ser utilizado para afirmar que una respuesta no tiene errores de validación que fueron devueltos como JSON **y** que no se mostraron errores en el almacenamiento de sesión.

<a name="assert-json-path"></a>
#### assertJsonPath

Afirmar que la respuesta contiene los datos dados en la ruta especificada:

    $response->assertJsonPath($path, $expectedValue);

Por ejemplo, si la siguiente respuesta JSON es devuelta por tu aplicación:

```json
{
    "user": {
        "name": "Steve Schoger"
    }
}
```

Puedes afirmar que la propiedad `name` del objeto `user` coincide con un valor dado de la siguiente manera:

    $response->assertJsonPath('user.name', 'Steve Schoger');

<a name="assert-json-missing-path"></a>
#### assertJsonMissingPath

Afirmar que la respuesta no contiene la ruta dada:

    $response->assertJsonMissingPath($path);

Por ejemplo, si la siguiente respuesta JSON es devuelta por tu aplicación:

```json
{
    "user": {
        "name": "Steve Schoger"
    }
}
```

Puedes afirmar que no contiene la propiedad `email` del objeto `user`:

    $response->assertJsonMissingPath('user.email');

<a name="assert-json-structure"></a>
#### assertJsonStructure

Afirmar que la respuesta tiene una estructura JSON dada:

    $response->assertJsonStructure(array $structure);

Por ejemplo, si la respuesta JSON devuelta por tu aplicación contiene los siguientes datos:

```json
{
    "user": {
        "name": "Steve Schoger"
    }
}
```

Puedes afirmar que la estructura JSON coincide con tus expectativas de la siguiente manera:

    $response->assertJsonStructure([
        'user' => [
            'name',
        ]
    ]);

A veces, las respuestas JSON devueltas por tu aplicación pueden contener arrays de objetos:

```json
{
    "user": [
        {
            "name": "Steve Schoger",
            "age": 55,
            "location": "Earth"
        },
        {
            "name": "Mary Schoger",
            "age": 60,
            "location": "Earth"
        }
    ]
}
```

En esta situación, puedes usar el carácter `*` para afirmar contra la estructura de todos los objetos en el array:

    $response->assertJsonStructure([
        'user' => [
            '*' => [
                 'name',
                 'age',
                 'location'
            ]
        ]
    ]);

<a name="assert-json-validation-errors"></a>
#### assertJsonValidationErrors

Afirmar que la respuesta tiene los errores de validación JSON dados para las claves dadas. Este método debe ser utilizado al afirmar contra respuestas donde los errores de validación son devueltos como una estructura JSON en lugar de ser mostrados en la sesión:

    $response->assertJsonValidationErrors(array $data, $responseKey = 'errors');

> [!NOTE]  
> El método más genérico [assertInvalid](#assert-invalid) puede ser utilizado para afirmar que una respuesta tiene errores de validación devueltos como JSON **o** que los errores fueron almacenados en la sesión.

<a name="assert-json-validation-error-for"></a>
#### assertJsonValidationErrorFor

Afirmar que la respuesta tiene errores de validación JSON para la clave dada:

    $response->assertJsonValidationErrorFor(string $key, $responseKey = 'errors');

<a name="assert-method-not-allowed"></a>
#### assertMethodNotAllowed

Afirmar que la respuesta tiene un código de estado HTTP de método no permitido (405):

    $response->assertMethodNotAllowed();

<a name="assert-moved-permanently"></a>
#### assertMovedPermanently

Afirmar que la respuesta tiene un código de estado HTTP de movido permanentemente (301):

    $response->assertMovedPermanently();

<a name="assert-location"></a>
#### assertLocation

Afirmar que la respuesta tiene el valor URI dado en el encabezado `Location`:

    $response->assertLocation($uri);

<a name="assert-content"></a>
#### assertContent

Afirmar que la cadena dada coincide con el contenido de la respuesta:

    $response->assertContent($value);

<a name="assert-no-content"></a>
#### assertNoContent

Afirmar que la respuesta tiene el código de estado HTTP dado y no tiene contenido:

    $response->assertNoContent($status = 204);

<a name="assert-streamed-content"></a>
#### assertStreamedContent

Afirmar que la cadena dada coincide con el contenido de la respuesta transmitida:

    $response->assertStreamedContent($value);

<a name="assert-not-found"></a>
#### assertNotFound

Afirmar que la respuesta tiene un código de estado HTTP de no encontrado (404):

    $response->assertNotFound();

<a name="assert-ok"></a>
#### assertOk

Afirmar que la respuesta tiene un código de estado HTTP 200:

    $response->assertOk();

<a name="assert-payment-required"></a>
#### assertPaymentRequired

Afirmar que la respuesta tiene un código de estado HTTP de pago requerido (402):

    $response->assertPaymentRequired();

<a name="assert-plain-cookie"></a>
#### assertPlainCookie

Afirmar que la respuesta contiene la cookie no encriptada dada:

    $response->assertPlainCookie($cookieName, $value = null);

<a name="assert-redirect"></a>
#### assertRedirect

Afirmar que la respuesta es una redirección a la URI dada:

    $response->assertRedirect($uri = null);

<a name="assert-redirect-contains"></a>
#### assertRedirectContains

Afirmar si la respuesta está redirigiendo a una URI que contiene la cadena dada:

    $response->assertRedirectContains($string);

<a name="assert-redirect-to-route"></a>
#### assertRedirectToRoute

Afirmar que la respuesta es una redirección a la [ruta nombrada](/docs/{{version}}/routing#named-routes) dada:

    $response->assertRedirectToRoute($name, $parameters = []);

<a name="assert-redirect-to-signed-route"></a>
#### assertRedirectToSignedRoute

Afirmar que la respuesta es una redirección a la [ruta firmada](/docs/{{version}}/urls#signed-urls) dada:

    $response->assertRedirectToSignedRoute($name = null, $parameters = []);

<a name="assert-request-timeout"></a>
#### assertRequestTimeout

Afirmar que la respuesta tiene un código de estado HTTP de tiempo de espera de solicitud (408):

    $response->assertRequestTimeout();

<a name="assert-see"></a>
#### assertSee

Afirmar que la cadena dada está contenida dentro de la respuesta. Esta afirmación escapará automáticamente la cadena dada a menos que pases un segundo argumento de `false`:

    $response->assertSee($value, $escaped = true);

<a name="assert-see-in-order"></a>
#### assertSeeInOrder

Afirmar que las cadenas dadas están contenidas en orden dentro de la respuesta. Esta afirmación escapará automáticamente las cadenas dadas a menos que pases un segundo argumento de `false`:

    $response->assertSeeInOrder(array $values, $escaped = true);

<a name="assert-see-text"></a>
#### assertSeeText

Afirmar que la cadena dada está contenida dentro del texto de la respuesta. Esta afirmación escapará automáticamente la cadena dada a menos que pases un segundo argumento de `false`. El contenido de la respuesta será pasado a la función `strip_tags` de PHP antes de que se realice la afirmación:

    $response->assertSeeText($value, $escaped = true);

<a name="assert-see-text-in-order"></a>
#### assertSeeTextInOrder

Afirmar que las cadenas dadas están contenidas en orden dentro del texto de la respuesta. Esta afirmación escapará automáticamente las cadenas dadas a menos que pases un segundo argumento de `false`. El contenido de la respuesta será pasado a la función `strip_tags` de PHP antes de que se realice la afirmación:

    $response->assertSeeTextInOrder(array $values, $escaped = true);

<a name="assert-server-error"></a>
#### assertServerError

Afirmar que la respuesta tiene un código de estado HTTP de error del servidor (>= 500 , < 600):

    $response->assertServerError();

<a name="assert-server-unavailable"></a>
#### assertServiceUnavailable

Afirmar que la respuesta tiene un código de estado HTTP de "Servicio no disponible" (503):

    $response->assertServiceUnavailable();

<a name="assert-session-has"></a>
#### assertSessionHas

Afirmar que la sesión contiene el dato dado:

    $response->assertSessionHas($key, $value = null);

Si es necesario, se puede proporcionar una función anónima como segundo argumento al método `assertSessionHas`. La afirmación pasará si la función anónima devuelve `true`:

    $response->assertSessionHas($key, function (User $value) {
        return $value->name === 'Taylor Otwell';
    });

<a name="assert-session-has-input"></a>
#### assertSessionHasInput

Afirmar que la sesión tiene un valor dado en el [array de entrada almacenado](/docs/{{version}}/responses#redirecting-with-flashed-session-data):

    $response->assertSessionHasInput($key, $value = null);

Si es necesario, se puede proporcionar una función anónima como segundo argumento al método `assertSessionHasInput`. La afirmación pasará si la función anónima devuelve `true`:

    use Illuminate\Support\Facades\Crypt;

    $response->assertSessionHasInput($key, function (string $value) {
        return Crypt::decryptString($value) === 'secret';
    });

<a name="assert-session-has-all"></a>
#### assertSessionHasAll

Afirmar que la sesión contiene un array dado de pares clave / valor:

    $response->assertSessionHasAll(array $data);

Por ejemplo, si la sesión de tu aplicación contiene las claves `name` y `status`, puedes afirmar que ambas existen y tienen los valores especificados así:

    $response->assertSessionHasAll([
        'name' => 'Taylor Otwell',
        'status' => 'active',
    ]);

<a name="assert-session-has-errors"></a>
#### assertSessionHasErrors

Afirmar que la sesión contiene un error para las claves dadas `$keys`. Si `$keys` es un array asociativo, afirmar que la sesión contiene un mensaje de error específico (valor) para cada campo (clave). Este método debe ser utilizado al probar rutas que almacenan errores de validación en la sesión en lugar de devolverlos como una estructura JSON:

    $response->assertSessionHasErrors(
        array $keys = [], $format = null, $errorBag = 'default'
    );

Por ejemplo, para afirmar que los campos `name` y `email` tienen mensajes de error de validación que fueron almacenados en la sesión, puedes invocar el método `assertSessionHasErrors` así:

    $response->assertSessionHasErrors(['name', 'email']);

O, puedes afirmar que un campo dado tiene un mensaje de error de validación particular:

    $response->assertSessionHasErrors([
        'name' => 'El nombre dado no es válido.'
    ]);

> [!NOTE]  
> El método más genérico [assertInvalid](#assert-invalid) puede ser utilizado para afirmar que una respuesta no tiene errores de validación que fueron devueltos como JSON **y** que no se almacenaron errores en la sesión.

<a name="assert-session-has-errors-in"></a>
#### assertSessionHasErrorsIn

Afirmar que la sesión contiene un error para las claves dadas `$keys` dentro de un [error bag](/docs/{{version}}/validation#named-error-bags) específico. Si `$keys` es un array asociativo, afirmar que la sesión contiene un mensaje de error específico (valor) para cada campo (clave), dentro del error bag:

    $response->assertSessionHasErrorsIn($errorBag, $keys = [], $format = null);

<a name="assert-session-has-no-errors"></a>
#### assertSessionHasNoErrors

Afirmar que la sesión no tiene errores de validación:

    $response->assertSessionHasNoErrors();

<a name="assert-session-doesnt-have-errors"></a>
#### assertSessionDoesntHaveErrors

Afirmar que la sesión no tiene errores de validación para las claves dadas:

    $response->assertSessionDoesntHaveErrors($keys = [], $format = null, $errorBag = 'default');

> [!NOTE]  
> El método más genérico [assertValid](#assert-valid) puede ser utilizado para afirmar que una respuesta no tiene errores de validación que fueron devueltos como JSON **y** que no se almacenaron errores en la sesión.

<a name="assert-session-missing"></a>
#### assertSessionMissing

Afirmar que la sesión no contiene la clave dada:

    $response->assertSessionMissing($key);

<a name="assert-status"></a>
#### assertStatus

Afirmar que la respuesta tiene un código de estado HTTP dado:

    $response->assertStatus($code);

<a name="assert-successful"></a>
#### assertSuccessful

Afirmar que la respuesta tiene un código de estado HTTP exitoso (>= 200 y < 300):

    $response->assertSuccessful();

<a name="assert-too-many-requests"></a>
#### assertTooManyRequests

Afirmar que la respuesta tiene un código de estado HTTP de demasiadas solicitudes (429):

    $response->assertTooManyRequests();

<a name="assert-unauthorized"></a>
#### assertUnauthorized

Afirmar que la respuesta tiene un código de estado HTTP no autorizado (401):

    $response->assertUnauthorized();

<a name="assert-unprocessable"></a>
#### assertUnprocessable

Afirmar que la respuesta tiene un código de estado HTTP de entidad no procesable (422):

    $response->assertUnprocessable();

<a name="assert-unsupported-media-type"></a>
#### assertUnsupportedMediaType

Afirmar que la respuesta tiene un código de estado HTTP de tipo de medio no soportado (415):

    $response->assertUnsupportedMediaType();

<a name="assert-valid"></a>
#### assertValid

Afirmar que la respuesta no tiene errores de validación para las claves dadas. Este método puede ser utilizado para afirmar respuestas donde los errores de validación son devueltos como una estructura JSON o donde los errores de validación han sido almacenados en la sesión:

    // Afirmar que no hay errores de validación presentes...
    $response->assertValid();

    // Afirmar que las claves dadas no tienen errores de validación...
    $response->assertValid(['name', 'email']);

<a name="assert-invalid"></a>
#### assertInvalid

Afirmar que la respuesta tiene errores de validación para las claves dadas. Este método puede ser utilizado para afirmar respuestas donde los errores de validación son devueltos como una estructura JSON o donde los errores de validación han sido almacenados en la sesión:

    $response->assertInvalid(['name', 'email']);

También puedes afirmar que una clave dada tiene un mensaje de error de validación particular. Al hacerlo, puedes proporcionar el mensaje completo o solo una pequeña parte del mensaje:

    $response->assertInvalid([
        'name' => 'El campo nombre es obligatorio.',
        'email' => 'dirección de correo electrónico válida',
    ]);
