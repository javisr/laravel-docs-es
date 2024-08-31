# Cliente HTTP

- [Introducción](#introducción)
- [Haciendo Solicitudes](#haciendo-solicitudes)
  - [Datos de Solicitud](#datos-de-solicitud)
  - [Encabezados](#encabezados)
  - [Autenticación](#autenticación)
  - [Tiempo de Espera](#tiempo-de-espera)
  - [Reintentos](#reintentos)
  - [Manejo de Errores](#manejo-de-errores)
  - [Middleware de Guzzle](#middleware-de-guzzle)
  - [Opciones de Guzzle](#opciones-de-guzzle)
- [Solicitudes Concurrentes](#solicitudes-concurrentes)
- [Macros](#macros)
- [Pruebas](#pruebas)
  - [Simulando Respuestas](#simulando-respuestas)
  - [Inspeccionando Solicitudes](#inspeccionando-solicitudes)
  - [Previniendo Solicitudes Aisladas](#previniendo-solicitudes-aisladas)
- [Eventos](#eventos)

<a name="introduction"></a>
## Introducción

Laravel ofrece una API minimal y expresiva alrededor del [cliente HTTP Guzzle](http://docs.guzzlephp.org/en/stable/), lo que te permite realizar rápidamente solicitudes HTTP salientes para comunicarte con otras aplicaciones web. El envoltorio de Laravel alrededor de Guzzle se centra en sus casos de uso más comunes y en una experiencia de desarrollo maravillosa.

<a name="making-requests"></a>
## Haciendo Solicitudes

Para realizar solicitudes, puedes usar los métodos `head`, `get`, `post`, `put`, `patch` y `delete` proporcionados por la fachada `Http`. Primero, examinemos cómo hacer una solicitud básica `GET` a otra URL:


```php
use Illuminate\Support\Facades\Http;

$response = Http::get('http://example.com');
```
El método `get` devuelve una instancia de `Illuminate\Http\Client\Response`, que ofrece una variedad de métodos que se pueden usar para inspeccionar la respuesta:


```php
$response->body() : string;
$response->json($key = null, $default = null) : mixed;
$response->object() : object;
$response->collect($key = null) : Illuminate\Support\Collection;
$response->resource() : resource;
$response->status() : int;
$response->successful() : bool;
$response->redirect(): bool;
$response->failed() : bool;
$response->clientError() : bool;
$response->header($header) : string;
$response->headers() : array;
```
El objeto `Illuminate\Http\Client\Response` también implementa la interfaz `ArrayAccess` de PHP, lo que te permite acceder a los datos de respuesta JSON directamente en la respuesta:


```php
return Http::get('http://example.com/users/1')['name'];
```
Además de los métodos de respuesta mencionados anteriormente, se pueden usar los siguientes métodos para determinar si la respuesta tiene un código de estado dado:


```php
$response->ok() : bool;              // 200 OK
$response->created() : bool;             // 201 Created
$response->accepted() : bool;            // 202 Accepted
$response->noContent() : bool;           // 204 No Content
$response->movedPermanently() : bool;    // 301 Moved Permanently
$response->found() : bool;               // 302 Found
$response->badRequest() : bool;          // 400 Bad Request
$response->unauthorized() : bool;        // 401 Unauthorized
$response->paymentRequired() : bool;     // 402 Payment Required
$response->forbidden() : bool;           // 403 Forbidden
$response->notFound() : bool;            // 404 Not Found
$response->requestTimeout() : bool;      // 408 Request Timeout
$response->conflict() : bool;            // 409 Conflict
$response->unprocessableEntity() : bool; // 422 Unprocessable Entity
$response->tooManyRequests() : bool;     // 429 Too Many Requests
$response->serverError() : bool;         // 500 Internal Server Error
```

<a name="uri-templates"></a>
#### Plantillas URI

El cliente HTTP también te permite construir las URL de solicitud utilizando la [especificación de plantilla URI](https://www.rfc-editor.org/rfc/rfc6570). Para definir los parámetros de URL que pueden ser expandidos por tu plantilla URI, puedes usar el método `withUrlParameters`:


```php
Http::withUrlParameters([
    'endpoint' => 'https://laravel.com',
    'page' => 'docs',
    'version' => '11.x',
    'topic' => 'validation',
])->get('{+endpoint}/{page}/{version}/{topic}');

```

<a name="dumping-requests"></a>
#### Volcando Solicitudes

Si deseas ver la instancia de la solicitud saliente antes de que se envíe y terminar la ejecución del script, puedes añadir el método `dd` al principio de la definición de tu solicitud:


```php
return Http::dd()->get('http://example.com');
```

<a name="request-data"></a>
### Solicitar Datos

Por supuesto, es común al realizar solicitudes `POST`, `PUT` y `PATCH` enviar datos adicionales con tu solicitud, por lo que estos métodos aceptan un array de datos como su segundo argumento. Por defecto, los datos se enviarán utilizando el tipo de contenido `application/json`:


```php
use Illuminate\Support\Facades\Http;

$response = Http::post('http://example.com/users', [
    'name' => 'Steve',
    'role' => 'Network Administrator',
]);
```

<a name="get-request-query-parameters"></a>
#### Parámetros de Consulta de Solicitud GET

Al realizar solicitudes `GET`, puedes añadir una cadena de consulta a la URL directamente o pasar un array de pares clave / valor como segundo argumento al método `get`:


```php
$response = Http::get('http://example.com/users', [
    'name' => 'Taylor',
    'page' => 1,
]);
```
Alternativamente, se puede usar el método `withQueryParameters`:


```php
Http::retry(3, 100)->withQueryParameters([
    'name' => 'Taylor',
    'page' => 1,
])->get('http://example.com/users')
```

<a name="sending-form-url-encoded-requests"></a>
#### Enviando Solicitudes Codificadas en URL de Formularios

Si deseas enviar datos utilizando el tipo de contenido `application/x-www-form-urlencoded`, debes llamar al método `asForm` antes de hacer tu solicitud:


```php
$response = Http::asForm()->post('http://example.com/users', [
    'name' => 'Sara',
    'role' => 'Privacy Consultant',
]);
```

<a name="sending-a-raw-request-body"></a>
#### Enviando un Cuerpo de Solicitud en Crudo

Puedes usar el método `withBody` si deseas proporcionar un cuerpo de solicitud en crudo al realizar una solicitud. El tipo de contenido se puede proporcionar a través del segundo argumento del método:


```php
$response = Http::withBody(
    base64_encode($photo), 'image/jpeg'
)->post('http://example.com/photo');
```

<a name="multi-part-requests"></a>
#### Solicitudes de Múltiples Partes

Si deseas enviar archivos como solicitudes multipart, debes llamar al método `attach` antes de realizar tu solicitud. Este método acepta el nombre del archivo y su contenido. Si es necesario, puedes proporcionar un tercer argumento que se considerará el nombre del archivo, mientras que un cuarto argumento se puede usar para proporcionar encabezados asociados con el archivo:


```php
$response = Http::attach(
    'attachment', file_get_contents('photo.jpg'), 'photo.jpg', ['Content-Type' => 'image/jpeg']
)->post('http://example.com/attachments');
```
En lugar de pasar el contenido en bruto de un archivo, puedes pasar un recurso de flujo:


```php
$photo = fopen('photo.jpg', 'r');

$response = Http::attach(
    'attachment', $photo, 'photo.jpg'
)->post('http://example.com/attachments');
```

<a name="headers"></a>
### Encabezados

Se pueden agregar encabezados a las solicitudes utilizando el método `withHeaders`. Este método `withHeaders` acepta un array de pares clave / valor:


```php
$response = Http::withHeaders([
    'X-First' => 'foo',
    'X-Second' => 'bar'
])->post('http://example.com/users', [
    'name' => 'Taylor',
]);
```
Puedes usar el método `accept` para especificar el tipo de contenido que tu aplicación espera como respuesta a tu solicitud:


```php
$response = Http::accept('application/json')->get('http://example.com/users');
```
Para mayor comodidad, puedes usar el método `acceptJson` para especificar rápidamente que tu aplicación espera el tipo de contenido `application/json` en respuesta a tu solicitud:


```php
$response = Http::acceptJson()->get('http://example.com/users');
```
El método `withHeaders` fusiona nuevos encabezados en los encabezados existentes de la solicitud. Si es necesario, puedes reemplazar todos los encabezados por completo utilizando el método `replaceHeaders`:


```php
$response = Http::withHeaders([
    'X-Original' => 'foo',
])->replaceHeaders([
    'X-Replacement' => 'bar',
])->post('http://example.com/users', [
    'name' => 'Taylor',
]);

```

<a name="authentication"></a>
### Autenticación

Puedes especificar credenciales de autenticación básica y digest usando los métodos `withBasicAuth` y `withDigestAuth`, respectivamente:


```php
// Basic authentication...
$response = Http::withBasicAuth('taylor@laravel.com', 'secret')->post(/* ... */);

// Digest authentication...
$response = Http::withDigestAuth('taylor@laravel.com', 'secret')->post(/* ... */);
```

<a name="bearer-tokens"></a>
#### Tokens de Portador

Si deseas añadir rápidamente un token de portador al encabezado `Authorization` de la solicitud, puedes usar el método `withToken`:


```php
$response = Http::withToken('token')->post(/* ... */);
```

<a name="timeout"></a>
### Tiempo de espera

El método `timeout` se puede utilizar para especificar el número máximo de segundos a esperar por una respuesta. Por defecto, el cliente HTTP hará timeout después de 30 segundos:


```php
$response = Http::timeout(3)->get(/* ... */);
```
Si se excede el tiempo de espera dado, se lanzará una instancia de `Illuminate\Http\Client\ConnectionException`.
Puedes especificar el número máximo de segundos que esperar mientras intentas conectarte a un servidor utilizando el método `connectTimeout`:


```php
$response = Http::connectTimeout(3)->get(/* ... */);
```

<a name="retries"></a>
### Reintentos

Si deseas que el cliente HTTP intente automáticamente la solicitud de nuevo si ocurre un error del cliente o del servidor, puedes usar el método `retry`. El método `retry` acepta el número máximo de intentos que se deben realizar y la cantidad de milisegundos que Laravel debe esperar entre intentos:


```php
$response = Http::retry(3, 100)->post(/* ... */);
```
Si deseas calcular manualmente el número de milisegundos para dormir entre intentos, puedes pasar una `función anónima` como segundo argumento al método `retry`:


```php
use Exception;

$response = Http::retry(3, function (int $attempt, Exception $exception) {
    return $attempt * 100;
})->post(/* ... */);
```
Para mayor comodidad, también puedes proporcionar un array como primer argumento al método `retry`. Este array se utilizará para determinar cuántos milisegundos esperar entre los intentos posteriores:


```php
$response = Http::retry([100, 200])->post(/* ... */);
```
Si es necesario, puedes pasar un tercer argumento al método `retry`. El tercer argumento debe ser un callable que determine si realmente se deben intentar los reintentos. Por ejemplo, es posible que desees volver a intentar la solicitud solo si la solicitud inicial encuentra una `ConnectionException`:


```php
use Exception;
use Illuminate\Http\Client\PendingRequest;

$response = Http::retry(3, 100, function (Exception $exception, PendingRequest $request) {
    return $exception instanceof ConnectionException;
})->post(/* ... */);
```
Si un intento de solicitud falla, es posible que desees hacer un cambio en la solicitud antes de que se realice un nuevo intento. Puedes lograr esto modificando el argumento de la solicitud que se proporciona al callable que proporcionaste al método `retry`. Por ejemplo, es posible que desees volver a intentar la solicitud con un nuevo token de autorización si el primer intento devolvió un error de autenticación:


```php
use Exception;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Http\Client\RequestException;

$response = Http::withToken($this->getToken())->retry(2, 0, function (Exception $exception, PendingRequest $request) {
    if (! $exception instanceof RequestException || $exception->response->status() !== 401) {
        return false;
    }

    $request->withToken($this->getNewToken());

    return true;
})->post(/* ... */);
```
Si todas las solicitudes fallan, se lanzará una instancia de `Illuminate\Http\Client\RequestException`. Si deseas desactivar este comportamiento, puedes proporcionar un argumento `throw` con un valor de `false`. Cuando esté desactivado, se devolverá la última respuesta recibida por el cliente después de que se hayan intentado todos los reintentos:


```php
$response = Http::retry(3, 100, throw: false)->post(/* ... */);
```
> [!WARNING]
Si todas las solicitudes fallan debido a un problema de conexión, todavía se lanzará una `Illuminate\Http\Client\ConnectionException` incluso cuando el argumento `throw` esté configurado en `false`.

<a name="error-handling"></a>
### Manejo de Errores

A diferencia del comportamiento predeterminado de Guzzle, el wrapper del cliente HTTP de Laravel no lanza excepciones en errores de cliente o servidor (respuestas de nivel `400` y `500` de los servidores). Puedes determinar si se devolvió uno de estos errores utilizando los métodos `successful`, `clientError` o `serverError`:


```php
// Determine if the status code is >= 200 and < 300...
$response->successful();

// Determine if the status code is >= 400...
$response->failed();

// Determine if the response has a 400 level status code...
$response->clientError();

// Determine if the response has a 500 level status code...
$response->serverError();

// Immediately execute the given callback if there was a client or server error...
$response->onError(callable $callback);
```

<a name="throwing-exceptions"></a>
#### Lanzando Excepciones

Si tienes una instancia de respuesta y te gustaría lanzar una instancia de `Illuminate\Http\Client\RequestException` si el código de estado de respuesta indica un error de cliente o servidor, puedes usar los métodos `throw` o `throwIf`:


```php
use Illuminate\Http\Client\Response;

$response = Http::post(/* ... */);

// Throw an exception if a client or server error occurred...
$response->throw();

// Throw an exception if an error occurred and the given condition is true...
$response->throwIf($condition);

// Throw an exception if an error occurred and the given closure resolves to true...
$response->throwIf(fn (Response $response) => true);

// Throw an exception if an error occurred and the given condition is false...
$response->throwUnless($condition);

// Throw an exception if an error occurred and the given closure resolves to false...
$response->throwUnless(fn (Response $response) => false);

// Throw an exception if the response has a specific status code...
$response->throwIfStatus(403);

// Throw an exception unless the response has a specific status code...
$response->throwUnlessStatus(200);

return $response['user']['id'];
```
La instancia `Illuminate\Http\Client\RequestException` tiene una propiedad pública `$response` que te permitirá inspeccionar la respuesta devuelta.
El método `throw` devuelve la instancia de respuesta si no ocurrió ningún error, lo que te permite encadenar otras operaciones al método `throw`:


```php
return Http::post(/* ... */)->throw()->json();
```
Si deseas realizar alguna lógica adicional antes de que se lance la excepción, puedes pasar una función anónima al método `throw`. La excepción se lanzará automáticamente después de que se invoque la función anónima, por lo que no necesitas volver a lanzar la excepción desde dentro de la función anónima:


```php
use Illuminate\Http\Client\Response;
use Illuminate\Http\Client\RequestException;

return Http::post(/* ... */)->throw(function (Response $response, RequestException $e) {
    // ...
})->json();
```

<a name="guzzle-middleware"></a>
### Middleware de Guzzle

Dado que el cliente HTTP de Laravel está impulsado por Guzzle, puedes aprovechar el [Middleware de Guzzle](https://docs.guzzlephp.org/en/stable/handlers-and-middleware.html) para manipular la solicitud saliente o inspeccionar la respuesta entrante. Para manipular la solicitud saliente, registra un middleware de Guzzle a través del método `withRequestMiddleware`:


```php
use Illuminate\Support\Facades\Http;
use Psr\Http\Message\RequestInterface;

$response = Http::withRequestMiddleware(
    function (RequestInterface $request) {
        return $request->withHeader('X-Example', 'Value');
    }
)->get('http://example.com');
```
Del mismo modo, puedes inspeccionar la respuesta HTTP entrante registrando un middleware a través del método `withResponseMiddleware`:


```php
use Illuminate\Support\Facades\Http;
use Psr\Http\Message\ResponseInterface;

$response = Http::withResponseMiddleware(
    function (ResponseInterface $response) {
        $header = $response->getHeader('X-Example');

        // ...

        return $response;
    }
)->get('http://example.com');
```

<a name="global-middleware"></a>
#### Middleware Global

A veces, es posible que desees registrar un middleware que se aplique a cada solicitud saliente y respuesta entrante. Para lograr esto, puedes usar los métodos `globalRequestMiddleware` y `globalResponseMiddleware`. Típicamente, estos métodos deben invocarse en el método `boot` del `AppServiceProvider` de tu aplicación:


```php
use Illuminate\Support\Facades\Http;

Http::globalRequestMiddleware(fn ($request) => $request->withHeader(
    'User-Agent', 'Example Application/1.0'
));

Http::globalResponseMiddleware(fn ($response) => $response->withHeader(
    'X-Finished-At', now()->toDateTimeString()
));

```

<a name="guzzle-options"></a>
### Opciones de Guzzle

Puedes especificar opciones de [solicitud adicionales de Guzzle](http://docs.guzzlephp.org/en/stable/request-options.html) para una solicitud saliente utilizando el método `withOptions`. El método `withOptions` acepta un array de pares clave / valor:


```php
$response = Http::withOptions([
    'debug' => true,
])->get('http://example.com/users');
```

<a name="global-options"></a>
#### Opciones Globales

Para configurar opciones predeterminadas para cada solicitud saliente, puedes utilizar el método `globalOptions`. Típicamente, este método debe invocarse desde el método `boot` del `AppServiceProvider` de tu aplicación:


```php
use Illuminate\Support\Facades\Http;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Http::globalOptions([
        'allow_redirects' => false,
    ]);
}

```

<a name="concurrent-requests"></a>
## Solicitudes Concurrentes

A veces, es posible que desees realizar múltiples solicitudes HTTP de forma concurrente. En otras palabras, deseas que varias solicitudes se despachen al mismo tiempo en lugar de emitir las solicitudes de forma secuencial. Esto puede llevar a mejoras de rendimiento sustanciales al interactuar con API HTTP lentas.
Afortunadamente, puedes lograr esto utilizando el método `pool`. El método `pool` acepta una función anónima que recibe una instancia de `Illuminate\Http\Client\Pool`, lo que te permite agregar fácilmente solicitudes al pool de solicitudes para su despacho:


```php
use Illuminate\Http\Client\Pool;
use Illuminate\Support\Facades\Http;

$responses = Http::pool(fn (Pool $pool) => [
    $pool->get('http://localhost/first'),
    $pool->get('http://localhost/second'),
    $pool->get('http://localhost/third'),
]);

return $responses[0]->ok() &&
       $responses[1]->ok() &&
       $responses[2]->ok();
```
Como puedes ver, cada instancia de respuesta se puede acceder según el orden en que se añadió al grupo. Si lo deseas, puedes nombrar las solicitudes utilizando el método `as`, lo que te permite acceder a las respuestas correspondientes por nombre:


```php
use Illuminate\Http\Client\Pool;
use Illuminate\Support\Facades\Http;

$responses = Http::pool(fn (Pool $pool) => [
    $pool->as('first')->get('http://localhost/first'),
    $pool->as('second')->get('http://localhost/second'),
    $pool->as('third')->get('http://localhost/third'),
]);

return $responses['first']->ok();
```

<a name="customizing-concurrent-requests"></a>
#### Personalizando Solicitudes Concurrentes

El método `pool` no se puede encadenar con otros métodos del cliente HTTP, como los métodos `withHeaders` o `middleware`. Si deseas aplicar encabezados personalizados o middleware a las solicitudes agrupadas, debes configurar esas opciones en cada solicitud dentro del grupo:


```php
use Illuminate\Http\Client\Pool;
use Illuminate\Support\Facades\Http;

$headers = [
    'X-Example' => 'example',
];

$responses = Http::pool(fn (Pool $pool) => [
    $pool->withHeaders($headers)->get('http://laravel.test/test'),
    $pool->withHeaders($headers)->get('http://laravel.test/test'),
    $pool->withHeaders($headers)->get('http://laravel.test/test'),
]);

```

<a name="macros"></a>
## Macros

El cliente HTTP de Laravel te permite definir "macros", que pueden servir como un mecanismo fluido y expresivo para configurar rutas de solicitud y encabezados comunes al interactuar con servicios a lo largo de tu aplicación. Para empezar, puedes definir la macro dentro del método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:


```php
use Illuminate\Support\Facades\Http;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Http::macro('github', function () {
        return Http::withHeaders([
            'X-Example' => 'example',
        ])->baseUrl('https://github.com');
    });
}

```
Una vez que tu macro haya sido configurado, puedes invocarla desde cualquier lugar en tu aplicación para crear una solicitud pendiente con la configuración especificada:


```php
$response = Http::github()->get('/');

```

<a name="testing"></a>
## Pruebas

Muchos servicios de Laravel proporcionan funcionalidad para ayudarte a escribir pruebas de manera fácil y expresiva, y el cliente HTTP de Laravel no es una excepción. El método `fake` de la fachada `Http` te permite indicar al cliente HTTP que devuelva respuestas simuladas / dummy cuando se realizan solicitudes.

<a name="faking-responses"></a>
### Fingiendo Respuestas

Por ejemplo, para instruir al cliente HTTP a que devuelva respuestas de código de estado `200` vacías para cada solicitud, puedes llamar al método `fake` sin argumentos:


```php
use Illuminate\Support\Facades\Http;

Http::fake();

$response = Http::post(/* ... */);
```

<a name="faking-specific-urls"></a>
#### Falsificando URLs Específicas

Alternativamente, puedes pasar un array al método `fake`. Las claves del array deben representar los patrones de URL que deseas simular y sus respuestas asociadas. Se puede usar el carácter `*` como un carácter comodín. Cualquier solicitud realizada a URL que no hayan sido simuladas se ejecutará realmente. Puedes usar el método `response` de la fachada `Http` para construir respuestas simuladas / falsas para estos endpoints:


```php
Http::fake([
    // Stub a JSON response for GitHub endpoints...
    'github.com/*' => Http::response(['foo' => 'bar'], 200, $headers),

    // Stub a string response for Google endpoints...
    'google.com/*' => Http::response('Hello World', 200, $headers),
]);
```
Si deseas especificar un patrón de URL de respaldo que sustituya todas las URL no coincidentes, puedes usar un solo carácter `*`:


```php
Http::fake([
    // Stub a JSON response for GitHub endpoints...
    'github.com/*' => Http::response(['foo' => 'bar'], 200, ['Headers']),

    // Stub a string response for all other endpoints...
    '*' => Http::response('Hello World', 200, ['Headers']),
]);
```

<a name="faking-response-sequences"></a>
#### Simulando Secuencias de Respuesta

A veces es posible que necesites especificar que una sola URL debe devolver una serie de respuestas falsas en un orden específico. Puedes lograr esto utilizando el método `Http::sequence` para construir las respuestas:


```php
Http::fake([
    // Stub a series of responses for GitHub endpoints...
    'github.com/*' => Http::sequence()
                            ->push('Hello World', 200)
                            ->push(['foo' => 'bar'], 200)
                            ->pushStatus(404),
]);
```
Cuando se hayan consumido todas las respuestas en una secuencia de respuestas, cualquier solicitud adicional provocará que la secuencia de respuestas lance una excepción. Si deseas especificar una respuesta predeterminada que se debe devolver cuando una secuencia está vacía, puedes usar el método `whenEmpty`:


```php
Http::fake([
    // Stub a series of responses for GitHub endpoints...
    'github.com/*' => Http::sequence()
                            ->push('Hello World', 200)
                            ->push(['foo' => 'bar'], 200)
                            ->whenEmpty(Http::response()),
]);
```
Si deseas simular una secuencia de respuestas pero no necesitas especificar un patrón de URL específico que deba ser simulado, puedes usar el método `Http::fakeSequence`:


```php
Http::fakeSequence()
        ->push('Hello World', 200)
        ->whenEmpty(Http::response());
```

<a name="fake-callback"></a>
#### Callback Falso

Si necesitas lógica más complicada para determinar qué respuestas devolver para ciertos endpoints, puedes pasar una función anónima al método `fake`. Esta función anónima recibirá una instancia de `Illuminate\Http\Client\Request` y debe devolver una instancia de respuesta. Dentro de tu función anónima, puedes realizar la lógica que sea necesaria para determinar qué tipo de respuesta devolver:


```php
use Illuminate\Http\Client\Request;

Http::fake(function (Request $request) {
    return Http::response('Hello World', 200);
});
```

<a name="preventing-stray-requests"></a>
### Prevención de Solicitudes Errantes

Si deseas asegurarte de que todas las solicitudes enviadas a través del cliente HTTP hayan sido simuladas durante tu prueba individual o suite de pruebas completa, puedes llamar al método `preventStrayRequests`. Después de llamar a este método, cualquier solicitud que no tenga una respuesta simulada correspondiente generará una excepción en lugar de realizar la solicitud HTTP real:


```php
use Illuminate\Support\Facades\Http;

Http::preventStrayRequests();

Http::fake([
    'github.com/*' => Http::response('ok'),
]);

// An "ok" response is returned...
Http::get('https://github.com/laravel/framework');

// An exception is thrown...
Http::get('https://laravel.com');
```

<a name="inspecting-requests"></a>
### Inspeccionando Solicitudes

Al simular respuestas, es posible que desees inspeccionar las solicitudes que recibe el cliente para asegurarte de que tu aplicación esté enviando los datos o encabezados correctos. Puedes lograr esto llamando al método `Http::assertSent` después de llamar a `Http::fake`.
El método `assertSent` acepta una `función anónima` que recibirá una instancia de `Illuminate\Http\Client\Request` y debe devolver un valor booleano que indique si la solicitud coincide con tus expectativas. Para que la prueba pase, al menos una solicitud debe haberse emitido que coincida con las expectativas dadas:


```php
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;

Http::fake();

Http::withHeaders([
    'X-First' => 'foo',
])->post('http://example.com/users', [
    'name' => 'Taylor',
    'role' => 'Developer',
]);

Http::assertSent(function (Request $request) {
    return $request->hasHeader('X-First', 'foo') &&
           $request->url() == 'http://example.com/users' &&
           $request['name'] == 'Taylor' &&
           $request['role'] == 'Developer';
});
```
Si es necesario, puedes afirmar que una solicitud específica no fue enviada utilizando el método `assertNotSent`:


```php
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;

Http::fake();

Http::post('http://example.com/users', [
    'name' => 'Taylor',
    'role' => 'Developer',
]);

Http::assertNotSent(function (Request $request) {
    return $request->url() === 'http://example.com/posts';
});
```
Puedes utilizar el método `assertSentCount` para comprobar cuántas solicitudes fueron "enviadas" durante la prueba:


```php
Http::fake();

Http::assertSentCount(5);
```
O, también puedes usar el método `assertNothingSent` para afirmar que no se enviaron solicitudes durante la prueba:


```php
Http::fake();

Http::assertNothingSent();
```

<a name="recording-requests-and-responses"></a>
#### Grabando Solicitudes / Respuestas

Puedes usar el método `recorded` para recopilar todas las solicitudes y sus correspondientes respuestas. El método `recorded` devuelve una colección de arreglos que contiene instancias de `Illuminate\Http\Client\Request` y `Illuminate\Http\Client\Response`:


```php
Http::fake([
    'https://laravel.com' => Http::response(status: 500),
    'https://nova.laravel.com/' => Http::response(),
]);

Http::get('https://laravel.com');
Http::get('https://nova.laravel.com/');

$recorded = Http::recorded();

[$request, $response] = $recorded[0];

```
Además, el método `recorded` acepta una función anónima que recibirá una instancia de `Illuminate\Http\Client\Request` y `Illuminate\Http\Client\Response` y se puede usar para filtrar pares de solicitudes / respuestas según tus expectativas:


```php
use Illuminate\Http\Client\Request;
use Illuminate\Http\Client\Response;

Http::fake([
    'https://laravel.com' => Http::response(status: 500),
    'https://nova.laravel.com/' => Http::response(),
]);

Http::get('https://laravel.com');
Http::get('https://nova.laravel.com/');

$recorded = Http::recorded(function (Request $request, Response $response) {
    return $request->url() !== 'https://laravel.com' &&
           $response->successful();
});

```

<a name="events"></a>
## Eventos

Laravel dispara tres eventos durante el proceso de envío de solicitudes HTTP. El evento `RequestSending` se activa antes de que se envíe una solicitud, mientras que el evento `ResponseReceived` se activa después de que se recibe una respuesta para una solicitud dada. El evento `ConnectionFailed` se activa si no se recibe ninguna respuesta para una solicitud dada.
Los eventos `RequestSending` y `ConnectionFailed` contienen ambos una propiedad pública `$request` que puedes usar para inspeccionar la instancia de `Illuminate\Http\Client\Request`. Del mismo modo, el evento `ResponseReceived` contiene una propiedad `$request` así como una propiedad `$response` que se puede usar para inspeccionar la instancia de `Illuminate\Http\Client\Response`. Puedes crear [oyentes de eventos](/docs/%7B%7Bversion%7D%7D/events) para estos eventos dentro de tu aplicación:


```php
use Illuminate\Http\Client\Events\RequestSending;

class LogRequest
{
    /**
     * Handle the given event.
     */
    public function handle(RequestSending $event): void
    {
        // $event->request ...
    }
}
```