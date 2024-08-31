# Pruebas HTTP

- [Introducción](#introduction)
- [Haciendo Solicitudes](#making-requests)
  - [Personalizando Encabezados de Solicitud](#customizing-request-headers)
  - [Cookies](#cookies)
  - [Sesión / Autenticación](#session-and-authentication)
  - [Depurando Respuestas](#debugging-responses)
  - [Manejo de Excepciones](#exception-handling)
- [Probando APIs JSON](#testing-json-apis)
  - [Pruebas JSON Fluentes](#fluent-json-testing)
- [Probando Cargas de Archivos](#testing-file-uploads)
- [Probando Vistas](#testing-views)
  - [Renderizando Blade y Componentes](#rendering-blade-and-components)
- [Aserciones Disponibles](#available-assertions)
  - [Aserciones de Respuesta](#response-assertions)
  - [Aserciones de Autenticación](#authentication-assertions)
  - [Aserciones de Validación](#validation-assertions)

<a name="introduction"></a>
## Introducción

Laravel ofrece una API muy fluida para realizar solicitudes HTTP a tu aplicación y examinar las respuestas. Por ejemplo, echa un vistazo a la prueba de características definida a continuación:


```php
<?php

test('the application returns a successful response', function () {
    $response = $this->get('/');

    $response->assertStatus(200);
});

```


```php
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
El método `get` realiza una solicitud `GET` a la aplicación, mientras que el método `assertStatus` afirma que la respuesta devuelta debe tener el código de estado HTTP dado. Además de esta afirmación simple, Laravel también contiene una variedad de afirmaciones para inspeccionar los encabezados de respuesta, el contenido, la estructura JSON y más.

<a name="making-requests"></a>
## Haciendo Solicitudes

Para realizar una solicitud a tu aplicación, puedes invocar los métodos `get`, `post`, `put`, `patch` o `delete` dentro de tu prueba. Estos métodos no emiten en realidad una solicitud HTTP "real" a tu aplicación. En su lugar, toda la solicitud de red se simula internamente.
En lugar de devolver una instancia de `Illuminate\Http\Response`, los métodos de solicitud de prueba devuelven una instancia de `Illuminate\Testing\TestResponse`, que proporciona una [variedad de afirmaciones útiles](#available-assertions) que te permiten inspeccionar las respuestas de tu aplicación:


```php
<?php

test('basic request', function () {
    $response = $this->get('/');

    $response->assertStatus(200);
});

```


```php
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
En general, cada una de tus pruebas solo debería hacer una solicitud a tu aplicación. Pueden ocurrir comportamientos inesperados si se ejecutan múltiples solicitudes dentro de un solo método de prueba.
> [!NOTA]
Para mayor comodidad, el middleware CSRF se desactiva automáticamente al ejecutar pruebas.

<a name="customizing-request-headers"></a>
### Personalizando Encabezados de Solicitud

Puedes usar el método `withHeaders` para personalizar los encabezados de la solicitud antes de que se envíe a la aplicación. Este método te permite agregar cualquier encabezado personalizado que desees a la solicitud:


```php
<?php

test('interacting with headers', function () {
    $response = $this->withHeaders([
        'X-Header' => 'Value',
    ])->post('/user', ['name' => 'Sally']);

    $response->assertStatus(201);
});

```


```php
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

Puedes usar los métodos `withCookie` o `withCookies` para establecer los valores de las cookies antes de realizar una solicitud. El método `withCookie` acepta un nombre de cookie y un valor como sus dos argumentos, mientras que el método `withCookies` acepta un array de pares nombre / valor:


```php
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


```php
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

Laravel proporciona varios ayudantes para interactuar con la sesión durante las pruebas HTTP. Primero, puedes establecer los datos de la sesión en un array dado utilizando el método `withSession`. Esto es útil para cargar la sesión con datos antes de realizar una solicitud a tu aplicación:


```php
<?php

test('interacting with the session', function () {
    $response = $this->withSession(['banned' => false])->get('/');

    //
});

```


```php
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
La sesión de Laravel se utiliza típicamente para mantener el estado del usuario actualmente autenticado. Por lo tanto, el método auxiliar `actingAs` proporciona una forma sencilla de autenticar a un usuario dado como el usuario actual. Por ejemplo, podemos usar una [factoría de modelo](/docs/%7B%7Bversion%7D%7D/eloquent-factories) para generar y autenticar a un usuario:


```php
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


```php
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
También puedes especificar qué guardia debe usarse para autenticar al usuario dado pasando el nombre del guardia como segundo argumento al método `actingAs`. La guardia que se proporciona al método `actingAs` también se convertirá en la guardia predeterminada durante la duración de la prueba:


```php
$this->actingAs($user, 'web')
```

<a name="debugging-responses"></a>
### Depuración de Respuestas

Después de realizar una solicitud de prueba a tu aplicación, se pueden usar los métodos `dump`, `dumpHeaders` y `dumpSession` para examinar y depurar el contenido de la respuesta:


```php
<?php

test('basic test', function () {
    $response = $this->get('/');

    $response->dumpHeaders();

    $response->dumpSession();

    $response->dump();
});

```


```php
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


```php
<?php

test('basic test', function () {
    $response = $this->get('/');

    $response->ddHeaders();

    $response->ddSession();

    $response->dd();
});

```


```php
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

A veces es posible que necesites comprobar que tu aplicación está lanzando una excepción específica. Para lograr esto, puedes "simular" el manejador de excepciones a través de la facade `Exceptions`. Una vez que se haya simulado el manejador de excepciones, puedes utilizar los métodos `assertReported` y `assertNotReported` para hacer afirmaciones sobre las excepciones que se lanzaron durante la solicitud:


```php
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


```php
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
Los métodos `assertNotReported` y `assertNothingReported` se pueden utilizar para afirmar que no se lanzó una excepción dada durante la solicitud o que no se lanzaron excepciones:


```php
Exceptions::assertNotReported(InvalidOrderException::class);

Exceptions::assertNothingReported();

```
Puedes desactivar completamente el manejo de excepciones para una solicitud dada invocando el método `withoutExceptionHandling` antes de realizar tu solicitud:


```php
$response = $this->withoutExceptionHandling()->get('/');
```
Además, si deseas asegurarte de que tu aplicación no esté utilizando características que han sido desaprobadas por el lenguaje PHP o las bibliotecas que está utilizando tu aplicación, puedes invocar el método `withoutDeprecationHandling` antes de realizar tu solicitud. Cuando el manejo de desaprobaciones está desactivado, las advertencias de desaprobación se convertirán en excepciones, lo que provocará que tu prueba falle:


```php
$response = $this->withoutDeprecationHandling()->get('/');
```
El método `assertThrows` se puede utilizar para afirmar que el código dentro de una `función anónima` dada lanza una excepción del tipo especificado:


```php
$this->assertThrows(
    fn () => (new ProcessOrder)->execute(),
    OrderInvalid::class
);

```
Si deseas inspeccionar y hacer afirmaciones sobre la excepción que se lanza, puedes proporcionar una función anónima como segundo argumento al método `assertThrows`:


```php
$this->assertThrows(
    fn () => (new ProcessOrder)->execute(),
    fn (OrderInvalid $e) => $e->orderId() === 123;
);

```

<a name="testing-json-apis"></a>
## Probando APIs JSON

Laravel también proporciona varios helpers para probar APIs JSON y sus respuestas. Por ejemplo, se pueden usar los métodos `json`, `getJson`, `postJson`, `putJson`, `patchJson`, `deleteJson` y `optionsJson` para emitir solicitudes JSON con varios verbos HTTP. También puedes pasar fácilmente datos y encabezados a estos métodos. Para empezar, escribamos una prueba para hacer una solicitud `POST` a `/api/user` y afirmar que se devolvió los datos JSON esperados:


```php
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


```php
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
Además, los datos de respuesta JSON pueden ser accedidos como variables de array en la respuesta, lo que te permite inspeccionar los valores individuales devueltos dentro de una respuesta JSON:


```php
expect($response['created'])->toBeTrue();

```


```php
$this->assertTrue($response['created']);

```
> [!NOTA]
El método `assertJson` convierte la respuesta a un array para verificar que el array dado existe dentro de la respuesta JSON devuelta por la aplicación. Así que, si hay otras propiedades en la respuesta JSON, esta prueba seguirá siendo válida siempre y cuando el fragmento dado esté presente.

<a name="verifying-exact-match"></a>
#### Aserción de Coincidencias JSON Exactas

Como se mencionó anteriormente, el método `assertJson` se puede utilizar para afirmar que un fragmento de JSON existe dentro de la respuesta JSON. Si deseas verificar que un array dado **coincide exactamente** con el JSON devuelto por tu aplicación, debes usar el método `assertExactJson`:


```php
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


```php
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
#### Afirmando sobre rutas JSON

Si deseas verificar que la respuesta JSON contenga los datos dados en una ruta especificada, deberías usar el método `assertJsonPath`:


```php
<?php

test('asserting a json path value', function () {
    $response = $this->postJson('/user', ['name' => 'Sally']);

    $response
        ->assertStatus(201)
        ->assertJsonPath('team.owner.name', 'Darian');
});

```


```php
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
El método `assertJsonPath` también acepta una `función anónima`, que se puede usar para determinar dinámicamente si la aserción debe pasar:


```php
$response->assertJsonPath('team.owner.name', fn (string $name) => strlen($name) >= 3);
```

<a name="fluent-json-testing"></a>
### Pruebas de JSON Fluente

Laravel también ofrece una manera hermosa de probar de forma fluida las respuestas JSON de tu aplicación. Para comenzar, pasa una función anónima al método `assertJson`. Esta función anónima se invocará con una instancia de `Illuminate\Testing\Fluent\AssertableJson`, que se puede usar para hacer afirmaciones contra el JSON que fue devuelto por tu aplicación. El método `where` se puede usar para hacer afirmaciones contra un atributo particular del JSON, mientras que el método `missing` se puede usar para afirmar que un atributo particular falta en el JSON:


```php
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


```php
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
#### Comprendiendo el Método `etc`

En el ejemplo anterior, es posible que hayas notado que invocamos el método `etc` al final de nuestra cadena de afirmaciones. Este método informa a Laravel que puede haber otros atributos presentes en el objeto JSON. Si no se utiliza el método `etc`, la prueba fallará si existen otros atributos contra los que no hiciste afirmaciones en el objeto JSON.
La intención detrás de este comportamiento es protegerte de exponer información sensible en tus respuestas JSON de manera involuntaria, obligándote a realizar una afirmación explícita sobre el atributo o a permitir explícitamente atributos adicionales a través del método `etc`.
Sin embargo, debes tener en cuenta que no incluir el método `etc` en tu cadena de aserciones no garantiza que no se estén añadiendo atributos adicionales a los arrays que están anidados dentro de tu objeto JSON. El método `etc` solo asegura que no existan atributos adicionales en el nivel de anidación en el que se invoca el método `etc`.

<a name="asserting-json-attribute-presence-and-absence"></a>
#### Afirmando la Presencia / Ausencia de Atributos

Para afirmar que un atributo está presente o ausente, puedes usar los métodos `has` y `missing`:


```php
$response->assertJson(fn (AssertableJson $json) =>
    $json->has('data')
         ->missing('message')
);
```
Además, los métodos `hasAll` y `missingAll` permiten afirmar la presencia o ausencia de múltiples atributos simultáneamente:


```php
$response->assertJson(fn (AssertableJson $json) =>
    $json->hasAll(['status', 'data'])
         ->missingAll(['message', 'code'])
);
```
Puedes usar el método `hasAny` para determinar si al menos uno de una lista dada de atributos está presente:


```php
$response->assertJson(fn (AssertableJson $json) =>
    $json->has('status')
         ->hasAny('data', 'message', 'code')
);
```

<a name="asserting-against-json-collections"></a>
#### Afirmando Contra Colecciones JSON

A menudo, tu ruta devolverá una respuesta JSON que contiene múltiples elementos, como múltiples usuarios:


```php
Route::get('/users', function () {
    return User::all();
});
```
En estas situaciones, podemos usar el método `has` del objeto JSON fluente para hacer afirmaciones sobre los usuarios incluidos en la respuesta. Por ejemplo, afirmemos que la respuesta JSON contiene tres usuarios. A continuación, haremos algunas afirmaciones sobre el primer usuario en la colección utilizando el método `first`. El método `first` acepta una función anónima que recibe otra cadena JSON afirmable que podemos usar para hacer afirmaciones sobre el primer objeto en la colección JSON:


```php
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
```

<a name="scoping-json-collection-assertions"></a>
#### Afirmaciones de Colección JSON con Alcance

A veces, las rutas de tu aplicación devolverán colecciones JSON que tienen claves con nombre asignadas:


```php
Route::get('/users', function () {
    return [
        'meta' => [...],
        'users' => User::all(),
    ];
})
```
Al probar estas rutas, puedes usar el método `has` para afirmar la cantidad de elementos en la colección. Además, puedes usar el método `has` para limitar una cadena de afirmaciones:


```php
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
```
Sin embargo, en lugar de hacer dos llamadas separadas al método `has` para afirmar contra la colección `users`, puedes hacer una sola llamada que proporcione una función anónima como su tercer parámetro. Al hacerlo, la función anónima se invocará automáticamente y se establecerá en el primer elemento de la colección:


```php
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
```

<a name="asserting-json-types"></a>
#### Afirmando Tipos JSON

Puede que solo quieras afirmar que las propiedades en la respuesta JSON son de un cierto tipo. La clase `Illuminate\Testing\Fluent\AssertableJson` proporciona los métodos `whereType` y `whereAllType` para hacer precisamente eso:


```php
$response->assertJson(fn (AssertableJson $json) =>
    $json->whereType('id', 'integer')
         ->whereAllType([
            'users.0.name' => 'string',
            'meta' => 'array'
        ])
);
```
Puedes especificar múltiples tipos utilizando el carácter `|`, o pasando un array de tipos como segundo parámetro al método `whereType`. La afirmación tendrá éxito si el valor de respuesta es cualquiera de los tipos listados:


```php
$response->assertJson(fn (AssertableJson $json) =>
    $json->whereType('name', 'string|null')
         ->whereType('id', ['string', 'integer'])
);
```
Los métodos `whereType` y `whereAllType` reconocen los siguientes tipos: `string`, `integer`, `double`, `boolean`, `array` y `null`.

<a name="testing-file-uploads"></a>
## Prueba de Cargas de Archivos

La clase `Illuminate\Http\UploadedFile` proporciona un método `fake` que se puede usar para generar archivos o imágenes de prueba. Esto, combinado con el método `fake` de la fachada `Storage`, simplifica en gran medida las pruebas de cargas de archivos. Por ejemplo, puedes combinar estas dos características para probar fácilmente un formulario de carga de avatar:


```php
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


```php
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


```php
Storage::fake('avatars');

// ...

Storage::disk('avatars')->assertMissing('missing.jpg');
```

<a name="fake-file-customization"></a>
#### Personalización de Archivo Falso

Al crear archivos utilizando el método `fake` proporcionado por la clase `UploadedFile`, puedes especificar el ancho, alto y tamaño de la imagen (en kilobytes) para probar mejor las reglas de validación de tu aplicación:


```php
UploadedFile::fake()->image('avatar.jpg', $width, $height)->size(100);
```
Además de crear imágenes, puedes crear archivos de cualquier otro tipo utilizando el método `create`:


```php
UploadedFile::fake()->create('document.pdf', $sizeInKilobytes);
```
Si es necesario, puedes pasar un argumento `$mimeType` al método para definir explícitamente el tipo MIME que debe devolver el archivo:


```php
UploadedFile::fake()->create(
    'document.pdf', $sizeInKilobytes, 'application/pdf'
);
```

<a name="testing-views"></a>
## Probando Vistas

Laravel también te permite renderizar una vista sin realizar una solicitud HTTP simulada a la aplicación. Para lograr esto, puedes llamar al método `view` dentro de tu prueba. El método `view` acepta el nombre de la vista y un array opcional de datos. El método devuelve una instancia de `Illuminate\Testing\TestView`, que ofrece varios métodos para hacer afirmaciones de manera conveniente sobre el contenido de la vista:


```php
<?php

test('a welcome view can be rendered', function () {
    $view = $this->view('welcome', ['name' => 'Taylor']);

    $view->assertSee('Taylor');
});

```


```php
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
La clase `TestView` proporciona los siguientes métodos de aserción: `assertSee`, `assertSeeInOrder`, `assertSeeText`, `assertSeeTextInOrder`, `assertDontSee` y `assertDontSeeText`.
Si es necesario, puedes obtener el contenido de la vista renderizada en bruto convirtiendo la instancia de `TestView` a una cadena:


```php
$contents = (string) $this->view('welcome');
```

<a name="sharing-errors"></a>
#### Compartiendo Errores

Algunas vistas pueden depender de errores compartidos en el [banco de errores global proporcionado por Laravel](/docs/%7B%7Bversion%7D%7D/validation#quick-displaying-the-validation-errors). Para llenar el banco de errores con mensajes de error, puedes usar el método `withViewErrors`:


```php
$view = $this->withViewErrors([
    'name' => ['Please provide a valid name.']
])->view('form');

$view->assertSee('Please provide a valid name.');
```

<a name="rendering-blade-and-components"></a>
### Renderizando Blade y Componentes

Si es necesario, puedes usar el método `blade` para evaluar y renderizar una cadena en bruto [Blade](/docs/%7B%7Bversion%7D%7D/blade). Al igual que el método `view`, el método `blade` devuelve una instancia de `Illuminate\Testing\TestView`:


```php
$view = $this->blade(
    '<x-component :name="$name" />',
    ['name' => 'Taylor']
);

$view->assertSee('Taylor');
```
Puedes usar el método `component` para evaluar y renderizar un [componente Blade](/docs/%7B%7Bversion%7D%7D/blade#components). El método `component` devuelve una instancia de `Illuminate\Testing\TestComponent`:


```php
$view = $this->component(Profile::class, ['name' => 'Taylor']);

$view->assertSee('Taylor');
```

<a name="available-assertions"></a>
## Afirmaciones Disponibles


<a name="response-assertions"></a>
### Afirmaciones de Respuesta

La clase `Illuminate\Testing\TestResponse` de Laravel proporciona una variedad de métodos de aserción personalizados que puedes utilizar al probar tu aplicación. Estas aserciones se pueden acceder en la respuesta que devuelve los métodos de prueba `json`, `get`, `post`, `put` y `delete`:
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
[assertExactJsonStructure](#assert-exact-json-structure)
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

Afirma que la respuesta tiene un código de estado HTTP de mala solicitud (400):


```php
$response->assertBadRequest();
```

<a name="assert-accepted"></a>
#### assertAccepted

Afirmar que la respuesta tiene un código de estado HTTP aceptado (202):


```php
$response->assertAccepted();
```

<a name="assert-conflict"></a>
#### assertConflict

Asegúrate de que la respuesta tenga un código de estado HTTP de conflicto (409):


```php
$response->assertConflict();
```

<a name="assert-cookie"></a>
#### assertCookie

Asegúrate de que la respuesta contenga la cookie dada:


```php
$response->assertCookie($cookieName, $value = null);
```

<a name="assert-cookie-expired"></a>
#### assertCookieExpired

Asegúrate de que la respuesta contenga la cookie dada y que esté expirada:


```php
$response->assertCookieExpired($cookieName);
```

<a name="assert-cookie-not-expired"></a>
#### assertCookieNotExpired

Asegúrate de que la respuesta contenga la cookie dada y no esté caducada:


```php
$response->assertCookieNotExpired($cookieName);
```

<a name="assert-cookie-missing"></a>
#### assertCookieMissing

Asegúrate de que la respuesta no contenga la cookie dada:


```php
$response->assertCookieMissing($cookieName);
```

<a name="assert-created"></a>
#### assertCreated

Asegúrate de que la respuesta tenga un código de estado HTTP 201:


```php
$response->assertCreated();
```

<a name="assert-dont-see"></a>
#### assertDontSee

Asegúrate de que la cadena dada no esté contenida dentro de la respuesta devuelta por la aplicación. Esta afirmación escapará automáticamente la cadena dada a menos que pases un segundo argumento `false`:


```php
$response->assertDontSee($value, $escaped = true);
```

<a name="assert-dont-see-text"></a>
#### assertDontSeeText

Asegúrate de que la cadena dada no esté contenida dentro del texto de respuesta. Esta afirmación escapará automáticamente la cadena dada a menos que pases un segundo argumento de `false`. Este método pasará el contenido de la respuesta a la función `strip_tags` de PHP antes de hacer la afirmación:


```php
$response->assertDontSeeText($value, $escaped = true);
```

<a name="assert-download"></a>
#### assertDownload

Asegúrate de que la respuesta sea una "descarga". Típicamente, esto significa que la ruta invocada que devolvió la respuesta devolvió una respuesta `Response::download`, `BinaryFileResponse` o `Storage::download`:


```php
$response->assertDownload();
```
Si lo deseas, puedes afirmar que el archivo descargable fue asignado a un nombre de archivo dado:


```php
$response->assertDownload('image.jpg');
```

<a name="assert-exact-json"></a>
#### assertExactJson

Asegúrate de que la respuesta contenga una coincidencia exacta con los datos JSON dados:


```php
$response->assertExactJson(array $data);
```

<a name="assert-exact-json-structure"></a>
#### assertExactJsonStructure

Asegúrate de que la respuesta contenga una coincidencia exacta con la estructura JSON dada:


```php
$response->assertExactJsonStructure(array $data);
```
Este método es una variante más estricta de [assertJsonStructure](#assert-json-structure). En contraste con `assertJsonStructure`, este método fallará si la respuesta contiene cualquier clave que no esté incluida explícitamente en la estructura JSON esperada.

<a name="assert-forbidden"></a>
#### assertForbidden

Asegúrate de que la respuesta tenga un código de estado HTTP prohibido (403):


```php
$response->assertForbidden();
```

<a name="assert-found"></a>
#### assertFound

Asegúrate de que la respuesta tenga un código de estado HTTP encontrado (302):


```php
$response->assertFound();
```

<a name="assert-gone"></a>
#### assertGone

Asegúrate de que la respuesta tenga un código de estado HTTP gone (410):


```php
$response->assertGone();
```

<a name="assert-header"></a>
#### assertHeader

Asegúrate de que el encabezado y el valor dados estén presentes en la respuesta:


```php
$response->assertHeader($headerName, $value = null);
```

<a name="assert-header-missing"></a>
#### assertHeaderMissing

Asegúrate de que el encabezado dado no esté presente en la respuesta:


```php
$response->assertHeaderMissing($headerName);
```

<a name="assert-internal-server-error"></a>
#### assertInternalServerError

Asegúrate de que la respuesta tenga un código de estado HTTP "Error Interno del Servidor" (500):


```php
$response->assertInternalServerError();
```

<a name="assert-json"></a>
#### assertJson

Asegúrate de que la respuesta contenga los datos JSON dados:


```php
$response->assertJson(array $data, $strict = false);
```
El método `assertJson` convierte la respuesta a un array para verificar que el array dado existe dentro de la respuesta JSON devuelta por la aplicación. Así que, si hay otras propiedades en la respuesta JSON, esta prueba seguirá pasando siempre que el fragmento dado esté presente.

<a name="assert-json-count"></a>
#### assertJsonCount

Asegúrate de que el JSON de respuesta tenga un array con el número esperado de elementos en la clave dada:


```php
$response->assertJsonCount($count, $key = null);
```

<a name="assert-json-fragment"></a>
#### assertJsonFragment

Asegúrate de que la respuesta contenga los datos JSON dados en cualquier parte de la respuesta:


```php
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
```

<a name="assert-json-is-array"></a>
#### assertJsonIsArray

Afirma que el JSON de respuesta es un array:


```php
$response->assertJsonIsArray();
```

<a name="assert-json-is-object"></a>
#### assertJsonIsObject

Asegúrate de que el JSON de respuesta sea un objeto:


```php
$response->assertJsonIsObject();
```

<a name="assert-json-missing"></a>
#### assertJsonMissing

Asegúrate de que la respuesta no contenga los datos JSON dados:


```php
$response->assertJsonMissing(array $data);
```

<a name="assert-json-missing-exact"></a>
#### assertJsonMissingExact

Asegúrate de que la respuesta no contenga los datos JSON exactos:


```php
$response->assertJsonMissingExact(array $data);
```

<a name="assert-json-missing-validation-errors"></a>
#### assertJsonMissingValidationErrors

Asegúrate de que la respuesta no tenga errores de validación JSON para las claves dadas:


```php
$response->assertJsonMissingValidationErrors($keys);
```

<a name="assert-json-path"></a>
#### assertJsonPath

Afirma que la respuesta contiene los datos dados en la ruta especificada:


```php
$response->assertJsonPath($path, $expectedValue);
```
Puedes afirmar que la propiedad `name` del objeto `user` coincide con un valor dado de la siguiente manera:


```php
$response->assertJsonPath('user.name', 'Steve Schoger');
```

<a name="assert-json-missing-path"></a>
#### assertJsonMissingPath

Asegúrate de que la respuesta no contenga la ruta dada:


```php
$response->assertJsonMissingPath($path);
```
Por ejemplo, si la siguiente respuesta JSON es devuelta por tu aplicación:
Puedes afirmar que no contiene la propiedad `email` del objeto `user`:


```php
$response->assertJsonMissingPath('user.email');
```

<a name="assert-json-structure"></a>
#### assertJsonStructure

Asegúrate de que la respuesta tenga una estructura JSON dada:


```php
$response->assertJsonStructure(array $structure);
```
Por ejemplo, si la respuesta JSON devuelta por tu aplicación contiene los siguientes datos:


```json
{
    "user": {
        "name": "Steve Schoger"
    }
}

```
Puedes afirmar que la estructura JSON coincide con tus expectativas de la siguiente manera:


```php
$response->assertJsonStructure([
    'user' => [
        'name',
    ]
]);
```
A veces, las respuestas JSON devueltas por su aplicación pueden contener arrays de objetos:


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
En esta situación, puedes usar el carácter `*` para hacer afirmaciones sobre la estructura de todos los objetos en el array:


```php
$response->assertJsonStructure([
    'user' => [
        '*' => [
             'name',
             'age',
             'location'
        ]
    ]
]);
```

<a name="assert-json-validation-errors"></a>
#### assertJsonValidationErrors

Asegúrate de que la respuesta tenga los errores de validación JSON dados para las claves dadas. Este método debe usarse al afirmar en contra de respuestas donde los errores de validación se devuelven como una estructura JSON en lugar de ser almacenados en la sesión:


```php
$response->assertJsonValidationErrors(array $data, $responseKey = 'errors');
```

<a name="assert-json-validation-error-for"></a>
#### assertJsonValidationErrorFor

Asegúrate de que la respuesta tenga errores de validación JSON para la clave dada:


```php
$response->assertJsonValidationErrorFor(string $key, $responseKey = 'errors');
```

<a name="assert-method-not-allowed"></a>
#### assertMethodNotAllowed

Aserta que la respuesta tiene un código de estado HTTP método no permitido (405):


```php
$response->assertMethodNotAllowed();
```

<a name="assert-moved-permanently"></a>
#### assertMovedPermanently

Asegúrate de que la respuesta tenga un código de estado HTTP movido permanentemente (301):


```php
$response->assertMovedPermanently();
```

<a name="assert-location"></a>
#### assertLocation

Asegúrate de que la respuesta tenga el valor de URI dado en el encabezado `Location`:


```php
$response->assertLocation($uri);
```

<a name="assert-content"></a>
#### assertContent

Afirma que la cadena dada coincide con el contenido de la respuesta:


```php
$response->assertContent($value);
```

<a name="assert-no-content"></a>
#### assertNoContent

Afirmar que la respuesta tiene el código de estado HTTP dado y sin contenido:


```php
$response->assertNoContent($status = 204);
```

<a name="assert-streamed-content"></a>
#### assertStreamedContent

Afirmar que la cadena dada coincide con el contenido de la respuesta en streaming:


```php
$response->assertStreamedContent($value);
```

<a name="assert-not-found"></a>
#### assertNotFound

Asegúrate de que la respuesta tenga un código de estado HTTP no encontrado (404):


```php
$response->assertNotFound();
```

<a name="assert-ok"></a>
#### assertOk

Asegúrate de que la respuesta tenga un código de estado HTTP 200:


```php
$response->assertOk();
```

<a name="assert-payment-required"></a>
#### assertPaymentRequired

Asegúrate de que la respuesta tenga un código de estado HTTP de pago requerido (402):


```php
$response->assertPaymentRequired();
```

<a name="assert-plain-cookie"></a>
#### assertPlainCookie

Asegúrate de que la respuesta contenga la cookie no encriptada dada:


```php
$response->assertPlainCookie($cookieName, $value = null);
```

<a name="assert-redirect"></a>
#### assertRedirect

Asegúrate de que la respuesta sea una redirección a la URI dada:


```php
$response->assertRedirect($uri = null);
```

<a name="assert-redirect-contains"></a>
#### assertRedirectContains

Verifica si la respuesta está redirigiendo a una URI que contiene la cadena dada:


```php
$response->assertRedirectContains($string);
```

<a name="assert-redirect-to-route"></a>
#### assertRedirectToRoute

Asegúrate de que la respuesta sea una redirección a la [ruta nombrada](/docs/%7B%7Bversion%7D%7D/routing#named-routes) dada:


```php
$response->assertRedirectToRoute($name, $parameters = []);
```

<a name="assert-redirect-to-signed-route"></a>
#### assertRedirectToSignedRoute

Asegúrate de que la respuesta sea una redirección a la [ruta firmada](/docs/%7B%7Bversion%7D%7D/urls#signed-urls) dada:


```php
$response->assertRedirectToSignedRoute($name = null, $parameters = []);
```

<a name="assert-request-timeout"></a>
#### assertRequestTimeout

Asegúrate de que la respuesta tenga un código de estado HTTP de tiempo de espera de solicitud (408):


```php
$response->assertRequestTimeout();
```

<a name="assert-see"></a>
#### assertSee

Asegúrate de que la cadena dada esté contenida dentro de la respuesta. Esta aserción escapará automáticamente la cadena dada a menos que pases un segundo argumento de `false`:


```php
$response->assertSee($value, $escaped = true);
```

<a name="assert-see-in-order"></a>
#### assertSeeInOrder

Asegúrate de que las cadenas dadas estén contenidas en orden dentro de la respuesta. Esta afirmación escapará automáticamente las cadenas dadas a menos que pases un segundo argumento de `false`:


```php
$response->assertSeeInOrder(array $values, $escaped = true);
```

<a name="assert-see-text"></a>
#### assertSeeText

Asegúrate de que la cadena dada esté contenida dentro del texto de respuesta. Esta afirmación escapará automáticamente la cadena dada a menos que pases un segundo argumento de `false`. El contenido de la respuesta se pasará a la función `strip_tags` de PHP antes de que se realice la afirmación:


```php
$response->assertSeeText($value, $escaped = true);
```

<a name="assert-see-text-in-order"></a>
#### assertSeeTextInOrder

Asegúrate de que las cadenas dadas estén contenidas en orden dentro del texto de respuesta. Esta afirmación escapará automáticamente las cadenas dadas a menos que pases un segundo argumento de `false`. El contenido de la respuesta se pasará a la función `strip_tags` de PHP antes de que se realice la afirmación:


```php
$response->assertSeeTextInOrder(array $values, $escaped = true);
```

<a name="assert-server-error"></a>
#### assertServerError

Asegúrate de que la respuesta tenga un código de estado HTTP de error del servidor (>= 500, < 600):


```php
$response->assertServerError();
```

<a name="assert-server-unavailable"></a>
#### assertServiceUnavailable

Asegúrate de que la respuesta tenga un código de estado HTTP "Servicio No Disponible" (503):


```php
$response->assertServiceUnavailable();
```

<a name="assert-session-has"></a>
#### assertSessionHas

Afirmar que la sesión contiene la pieza de datos dada:


```php
$response->assertSessionHas($key, $value = null);
```
Si es necesario, se puede proporcionar una `función anónima` como segundo argumento al método `assertSessionHas`. La afirmación pasará si la `función anónima` devuelve `true`:


```php
$response->assertSessionHas($key, function (User $value) {
    return $value->name === 'Taylor Otwell';
});
```

<a name="assert-session-has-input"></a>
#### assertSessionHasInput

Asegúrate de que la sesión tenga un valor dado en el [array de entrada almacenada](/docs/%7B%7Bversion%7D%7D/responses#redirecting-with-flashed-session-data):


```php
$response->assertSessionHasInput($key, $value = null);
```
Si es necesario, se puede proporcionar una `función anónima` como segundo argumento al método `assertSessionHasInput`. La afirmación pasará si la `función anónima` devuelve `true`:


```php
use Illuminate\Support\Facades\Crypt;

$response->assertSessionHasInput($key, function (string $value) {
    return Crypt::decryptString($value) === 'secret';
});
```

<a name="assert-session-has-all"></a>
#### assertSessionHasAll

Asegúrate de que la sesión contenga un array dado de parejas clave / valor:


```php
$response->assertSessionHasAll(array $data);
```
Por ejemplo, si la sesión de tu aplicación contiene las claves `name` y `status`, puedes afirmar que ambas existen y tienen los valores especificados de la siguiente manera:


```php
$response->assertSessionHasAll([
    'name' => 'Taylor Otwell',
    'status' => 'active',
]);
```

<a name="assert-session-has-errors"></a>
#### assertSessionHasErrors

Asegúrate de que la sesión contenga un error para las `$keys` dadas. Si `$keys` es un array asociativo, verifica que la sesión contenga un mensaje de error específico (valor) para cada campo (clave). Este método debe usarse al probar rutas que envían errores de validación a la sesión en lugar de devolverlos como una estructura JSON:


```php
$response->assertSessionHasErrors(
    array $keys = [], $format = null, $errorBag = 'default'
);
```
Por ejemplo, para afirmar que los campos `name` y `email` tienen mensajes de error de validación que se han registrado en la sesión, puedes invocar el método `assertSessionHasErrors` de la siguiente manera:


```php
$response->assertSessionHasErrors(['name', 'email']);
```
O bien, puedes afirmar que un campo dado tiene un mensaje de error de validación particular:


```php
$response->assertSessionHasErrors([
    'name' => 'The given name was invalid.'
]);
```
> [!NOTE]
Se puede usar el método más genérico [assertInvalid](#assert-invalid) para afirmar que una respuesta tiene errores de validación devueltos como JSON **o** que los errores fueron almacenados en la sesión.

<a name="assert-session-has-errors-in"></a>
#### assertSessionHasErrorsIn

Asegúrate de que la sesión contenga un error para las `$keys` dadas dentro de un [conjunto de errores](/docs/%7B%7Bversion%7D%7D/validation#named-error-bags) específico. Si `$keys` es un array asociativo, asegúrate de que la sesión contenga un mensaje de error específico (valor) para cada campo (clave), dentro del conjunto de errores:


```php
$response->assertSessionHasErrorsIn($errorBag, $keys = [], $format = null);
```

<a name="assert-session-has-no-errors"></a>
#### assertSessionHasNoErrors

Asegúrate de que la sesión no tenga errores de validación:


```php
$response->assertSessionHasNoErrors();
```

<a name="assert-session-doesnt-have-errors"></a>
#### assertSessionDoesntHaveErrors

Asegúrate de que la sesión no tenga errores de validación para las claves dadas:


```php
$response->assertSessionDoesntHaveErrors($keys = [], $format = null, $errorBag = 'default');
```
> [!NOTA]
Se puede utilizar el método más genérico [assertValid](#assert-valid) para afirmar que una respuesta no tiene errores de validación que fueron devueltos como JSON **y** que no se han almacenado errores en el almacenamiento de sesiones.

<a name="assert-session-missing"></a>
#### assertSessionMissing

Asegúrate de que la sesión no contenga la clave dada:


```php
$response->assertSessionMissing($key);
```

<a name="assert-status"></a>
#### assertStatus

Asegúrate de que la respuesta tenga un código de estado HTTP dado:


```php
$response->assertStatus($code);
```

<a name="assert-successful"></a>
#### assertSuccessful

Asegúrate de que la respuesta tenga un código de estado HTTP exitoso (>= 200 y < 300):


```php
$response->assertSuccessful();
```

<a name="assert-too-many-requests"></a>
#### assertTooManyRequests

Asegúrate de que la respuesta tenga un código de estado HTTP de demasiadas solicitudes (429):


```php
$response->assertTooManyRequests();
```

<a name="assert-unauthorized"></a>
#### assertUnauthorized

Asegúrate de que la respuesta tenga un código de estado HTTP no autorizado (401):


```php
$response->assertUnauthorized();
```

<a name="assert-unprocessable"></a>
#### assertUnprocessable

Asegúrate de que la respuesta tenga un código de estado HTTP de entidad no procesable (422):


```php
$response->assertUnprocessable();
```

<a name="assert-unsupported-media-type"></a>
#### assertUnsupportedMediaType

Afirmar que la respuesta tiene un código de estado HTTP de tipo de medio no soportado (415):


```php
$response->assertUnsupportedMediaType();
```

<a name="assert-valid"></a>

<a name="assert-invalid"></a>

<a name="assert-view-has"></a>
#### assertViewHas

Afirmar que la vista de respuesta contiene un elemento de datos dado:


```php
$response->assertViewHas($key, $value = null);
```
Pasar una `función anónima` como segundo argumento al método `assertViewHas` te permitirá inspeccionar y hacer afirmaciones sobre un elemento particular de los datos de la vista:


```php
$response->assertViewHas('user', function (User $user) {
    return $user->name === 'Taylor';
});
```
Además, los datos de la vista pueden ser accedidos como variables de array en la respuesta, lo que te permite inspeccionarlos de manera conveniente:


```php
expect($response['name'])->toBe('Taylor');

```


```php
$this->assertEquals('Taylor', $response['name']);

```

<a name="assert-view-has-all"></a>
#### assertViewHasAll

Asegúrate de que la vista de respuesta tenga una lista dada de datos:


```php
$response->assertViewHasAll(array $data);
```
Este método se puede utilizar para afirmar que la vista simplemente contiene datos que coinciden con las claves dadas:


```php
$response->assertViewHasAll([
    'name',
    'email',
]);
```
O, puedes afirmar que los datos de la vista están presentes y tienen valores específicos:


```php
$response->assertViewHasAll([
    'name' => 'Taylor Otwell',
    'email' => 'taylor@example.com,',
]);
```

<a name="assert-view-is"></a>
#### assertViewIs

Asegúrate de que la vista dada fue devuelta por la ruta:


```php
$response->assertViewIs($value);
```

<a name="assert-view-missing"></a>
#### assertViewMissing

Asegúrate de que la clave de datos dada no se haya hecho disponible para la vista devuelta en la respuesta de la aplicación:


```php
$response->assertViewMissing($key);
```

<a name="authentication-assertions"></a>
### Aserciones de Autenticación

Laravel también ofrece una variedad de afirmaciones relacionadas con la autenticación que puedes utilizar en las pruebas de características de tu aplicación. Ten en cuenta que estos métodos se invocan en la clase de prueba misma y no en la instancia `Illuminate\Testing\TestResponse` devuelta por métodos como `get` y `post`.

<a name="assert-authenticated"></a>
#### assertAuthenticated

Asegura que un usuario esté autenticado:


```php
$this->assertAuthenticated($guard = null);
```

<a name="assert-guest"></a>
#### assertGuest

Asegúrate de que un usuario no esté autenticado:


```php
$this->assertGuest($guard = null);
```

<a name="assert-authenticated-as"></a>
#### assertAuthenticatedAs

Asegúrate de que un usuario específico esté autenticado:


```php
$this->assertAuthenticatedAs($user, $guard = null);
```

<a name="validation-assertions"></a>
## Aserciones de Validación

Laravel ofrece dos afirmaciones relacionadas con la validación que puedes usar para asegurarte de que los datos proporcionados en tu solicitud eran válidos o inválidos.

<a name="validation-assert-valid"></a>
#### assertValid

Asegúrate de que la respuesta no tenga errores de validación para las claves dadas. Este método se puede usar para confirmar respuestas donde los errores de validación se devuelven como una estructura JSON o donde los errores de validación se han almacenado en la sesión:


```php
// Assert that no validation errors are present...
$response->assertValid();

// Assert that the given keys do not have validation errors...
$response->assertValid(['name', 'email']);
```

<a name="validation-assert-invalid"></a>
#### assertInvalid

Asegúrate de que la respuesta tenga errores de validación para las claves dadas. Este método se puede usar para afirmar contra respuestas donde los errores de validación se devuelven como una estructura JSON o donde los errores de validación se han almacenado en la sesión:


```php
$response->assertInvalid(['name', 'email']);
```
También puedes afirmar que una clave dada tiene un mensaje de error de validación particular. Al hacerlo, puedes proporcionar el mensaje completo o solo una pequeña porción del mensaje:


```php
$response->assertInvalid([
    'name' => 'The name field is required.',
    'email' => 'valid email address',
]);
```