# Cliente HTTP

- [Cliente HTTP](#cliente-http)
  - [Introducción](#introducción)
  - [Realizando Solicitudes](#realizando-solicitudes)
      - [Plantillas URI](#plantillas-uri)
      - [Volcando Solicitudes](#volcando-solicitudes)
    - [Datos de Solicitud](#datos-de-solicitud)
      - [Parámetros de Consulta de Solicitud GET](#parámetros-de-consulta-de-solicitud-get)
      - [Enviando Solicitudes Codificadas en URL de Formulario](#enviando-solicitudes-codificadas-en-url-de-formulario)
      - [Enviando un Cuerpo de Solicitud en Crudo](#enviando-un-cuerpo-de-solicitud-en-crudo)
      - [Solicitudes Multi-Partes](#solicitudes-multi-partes)
    - [Encabezados](#encabezados)
    - [Autenticación](#autenticación)
      - [Tokens Bearer](#tokens-bearer)
    - [Tiempo de Espera](#tiempo-de-espera)
    - [Reintentos](#reintentos)
    - [Manejo de Errores](#manejo-de-errores)
      - [Lanzando Excepciones](#lanzando-excepciones)
    - [Middleware de Guzzle](#middleware-de-guzzle)
    - [Opciones de Guzzle](#opciones-de-guzzle)
      - [Opciones Globales](#opciones-globales)
  - [Solicitudes Concurrentes](#solicitudes-concurrentes)
      - [Personalizando Solicitudes Concurrentes](#personalizando-solicitudes-concurrentes)
  - [Macros](#macros)
  - [Pruebas](#pruebas)
    - [Simulando Respuestas](#simulando-respuestas)
      - [Simulando URLs Específicas](#simulando-urls-específicas)
      - [Simulando Secuencias de Respuestas](#simulando-secuencias-de-respuestas)
      - [Simulación de Callback](#simulación-de-callback)
    - [Previniendo Solicitudes Errantes](#previniendo-solicitudes-errantes)
    - [Inspeccionando Solicitudes](#inspeccionando-solicitudes)
      - [Grabando Solicitudes / Respuestas](#grabando-solicitudes--respuestas)
  - [Eventos](#eventos)

<a name="introduction"></a>
## Introducción

Laravel proporciona una API expresiva y mínima alrededor del [cliente HTTP Guzzle](http://docs.guzzlephp.org/en/stable/), permitiéndote realizar rápidamente solicitudes HTTP salientes para comunicarte con otras aplicaciones web. El envoltorio de Laravel alrededor de Guzzle se centra en sus casos de uso más comunes y en una maravillosa experiencia para el desarrollador.

<a name="making-requests"></a>
## Realizando Solicitudes

Para realizar solicitudes, puedes usar los métodos `head`, `get`, `post`, `put`, `patch` y `delete` proporcionados por el facade `Http`. Primero, examinemos cómo hacer una solicitud básica `GET` a otra URL:

    use Illuminate\Support\Facades\Http;

    $response = Http::get('http://example.com');

El método `get` devuelve una instancia de `Illuminate\Http\Client\Response`, que proporciona una variedad de métodos que pueden ser utilizados para inspeccionar la respuesta:

    $response->body() : string;
    $response->json($key = null, $default = null) : mixed;
    $response->object() : object;
    $response->collect($key = null) : Illuminate\Support\Collection;
    $response->status() : int;
    $response->successful() : bool;
    $response->redirect(): bool;
    $response->failed() : bool;
    $response->clientError() : bool;
    $response->header($header) : string;
    $response->headers() : array;

El objeto `Illuminate\Http\Client\Response` también implementa la interfaz PHP `ArrayAccess`, permitiéndote acceder a los datos de respuesta JSON directamente en la respuesta:

    return Http::get('http://example.com/users/1')['name'];

Además de los métodos de respuesta listados anteriormente, los siguientes métodos pueden ser utilizados para determinar si la respuesta tiene un código de estado dado:

    $response->ok() : bool;                  // 200 OK
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

<a name="uri-templates"></a>
#### Plantillas URI

El cliente HTTP también te permite construir URLs de solicitud utilizando la [especificación de plantilla URI](https://www.rfc-editor.org/rfc/rfc6570). Para definir los parámetros de URL que pueden ser expandibles por tu plantilla URI, puedes usar el método `withUrlParameters`:

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

Si deseas volcar la instancia de solicitud saliente antes de que se envíe y terminar la ejecución del script, puedes agregar el método `dd` al principio de tu definición de solicitud:

    return Http::dd()->get('http://example.com');

<a name="request-data"></a>
### Datos de Solicitud

Por supuesto, es común al realizar solicitudes `POST`, `PUT` y `PATCH` enviar datos adicionales con tu solicitud, por lo que estos métodos aceptan un array de datos como su segundo argumento. Por defecto, los datos se enviarán utilizando el tipo de contenido `application/json`:

    use Illuminate\Support\Facades\Http;

    $response = Http::post('http://example.com/users', [
        'name' => 'Steve',
        'role' => 'Network Administrator',
    ]);

<a name="get-request-query-parameters"></a>
#### Parámetros de Consulta de Solicitud GET

Al realizar solicitudes `GET`, puedes agregar una cadena de consulta a la URL directamente o pasar un array de pares clave / valor como el segundo argumento al método `get`:

    $response = Http::get('http://example.com/users', [
        'name' => 'Taylor',
        'page' => 1,
    ]);

Alternativamente, se puede usar el método `withQueryParameters`:

    Http::retry(3, 100)->withQueryParameters([
        'name' => 'Taylor',
        'page' => 1,
    ])->get('http://example.com/users')

<a name="sending-form-url-encoded-requests"></a>
#### Enviando Solicitudes Codificadas en URL de Formulario

Si deseas enviar datos utilizando el tipo de contenido `application/x-www-form-urlencoded`, debes llamar al método `asForm` antes de realizar tu solicitud:

    $response = Http::asForm()->post('http://example.com/users', [
        'name' => 'Sara',
        'role' => 'Privacy Consultant',
    ]);

<a name="sending-a-raw-request-body"></a>
#### Enviando un Cuerpo de Solicitud en Crudo

Puedes usar el método `withBody` si deseas proporcionar un cuerpo de solicitud en crudo al realizar una solicitud. El tipo de contenido puede ser proporcionado a través del segundo argumento del método:

    $response = Http::withBody(
        base64_encode($photo), 'image/jpeg'
    )->post('http://example.com/photo');

<a name="multi-part-requests"></a>
#### Solicitudes Multi-Partes

Si deseas enviar archivos como solicitudes multi-partes, debes llamar al método `attach` antes de realizar tu solicitud. Este método acepta el nombre del archivo y su contenido. Si es necesario, puedes proporcionar un tercer argumento que se considerará el nombre del archivo, mientras que un cuarto argumento puede ser utilizado para proporcionar encabezados asociados con el archivo:

    $response = Http::attach(
        'attachment', file_get_contents('photo.jpg'), 'photo.jpg', ['Content-Type' => 'image/jpeg']
    )->post('http://example.com/attachments');

En lugar de pasar el contenido en crudo de un archivo, puedes pasar un recurso de flujo:

    $photo = fopen('photo.jpg', 'r');

    $response = Http::attach(
        'attachment', $photo, 'photo.jpg'
    )->post('http://example.com/attachments');

<a name="headers"></a>
### Encabezados

Los encabezados pueden ser añadidos a las solicitudes utilizando el método `withHeaders`. Este método `withHeaders` acepta un array de pares clave / valor:

    $response = Http::withHeaders([
        'X-First' => 'foo',
        'X-Second' => 'bar'
    ])->post('http://example.com/users', [
        'name' => 'Taylor',
    ]);

Puedes usar el método `accept` para especificar el tipo de contenido que tu aplicación espera en respuesta a tu solicitud:

    $response = Http::accept('application/json')->get('http://example.com/users');

Para conveniencia, puedes usar el método `acceptJson` para especificar rápidamente que tu aplicación espera el tipo de contenido `application/json` en respuesta a tu solicitud:

    $response = Http::acceptJson()->get('http://example.com/users');

El método `withHeaders` fusiona nuevos encabezados en los encabezados existentes de la solicitud. Si es necesario, puedes reemplazar todos los encabezados completamente utilizando el método `replaceHeaders`:

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

Puedes especificar credenciales de autenticación básica y digest utilizando los métodos `withBasicAuth` y `withDigestAuth`, respectivamente:

    // Autenticación básica...
    $response = Http::withBasicAuth('taylor@laravel.com', 'secret')->post(/* ... */);

    // Autenticación digest...
    $response = Http::withDigestAuth('taylor@laravel.com', 'secret')->post(/* ... */);

<a name="bearer-tokens"></a>
#### Tokens Bearer

Si deseas agregar rápidamente un token bearer al encabezado `Authorization` de la solicitud, puedes usar el método `withToken`:

    $response = Http::withToken('token')->post(/* ... */);

<a name="timeout"></a>
### Tiempo de Espera

El método `timeout` puede ser utilizado para especificar el número máximo de segundos a esperar por una respuesta. Por defecto, el cliente HTTP tendrá un tiempo de espera después de 30 segundos:

    $response = Http::timeout(3)->get(/* ... */);

Si se excede el tiempo de espera dado, se lanzará una instancia de `Illuminate\Http\Client\ConnectionException`.

Puedes especificar el número máximo de segundos a esperar mientras intentas conectarte a un servidor utilizando el método `connectTimeout`:

    $response = Http::connectTimeout(3)->get(/* ... */);

<a name="retries"></a>
### Reintentos

Si deseas que el cliente HTTP intente automáticamente la solicitud si ocurre un error de cliente o servidor, puedes usar el método `retry`. El método `retry` acepta el número máximo de veces que se debe intentar la solicitud y el número de milisegundos que Laravel debe esperar entre intentos:

    $response = Http::retry(3, 100)->post(/* ... */);

Si deseas calcular manualmente el número de milisegundos para dormir entre intentos, puedes pasar una función anónima como el segundo argumento al método `retry`:

    use Exception;

    $response = Http::retry(3, function (int $attempt, Exception $exception) {
        return $attempt * 100;
    })->post(/* ... */);

Para conveniencia, también puedes proporcionar un array como el primer argumento al método `retry`. Este array se utilizará para determinar cuántos milisegundos dormir entre intentos subsecuentes:

    $response = Http::retry([100, 200])->post(/* ... */);

Si es necesario, puedes pasar un tercer argumento al método `retry`. El tercer argumento debe ser un callable que determina si los reintentos deben ser realmente intentados. Por ejemplo, puedes desear solo reintentar la solicitud si la solicitud inicial encuentra una `ConnectionException`:

    use Exception;
    use Illuminate\Http\Client\PendingRequest;

    $response = Http::retry(3, 100, function (Exception $exception, PendingRequest $request) {
        return $exception instanceof ConnectionException;
    })->post(/* ... */);

Si un intento de solicitud falla, puedes desear hacer un cambio en la solicitud antes de que se realice un nuevo intento. Puedes lograr esto modificando el argumento de solicitud proporcionado al callable que proporcionaste al método `retry`. Por ejemplo, podrías querer reintentar la solicitud con un nuevo token de autorización si el primer intento devolvió un error de autenticación:

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

Si todas las solicitudes fallan, se lanzará una instancia de `Illuminate\Http\Client\RequestException`. Si deseas deshabilitar este comportamiento, puedes proporcionar un argumento `throw` con un valor de `false`. Cuando está deshabilitado, la última respuesta recibida por el cliente será devuelta después de que se hayan intentado todos los reintentos:

    $response = Http::retry(3, 100, throw: false)->post(/* ... */);

> [!WARNING]  
> Si todas las solicitudes fallan debido a un problema de conexión, una `Illuminate\Http\Client\ConnectionException` aún será lanzada incluso cuando el argumento `throw` esté configurado en `false`.

<a name="error-handling"></a>
### Manejo de Errores

A diferencia del comportamiento predeterminado de Guzzle, el envoltorio del cliente HTTP de Laravel no lanza excepciones en errores de cliente o servidor (respuestas de nivel `400` y `500` de los servidores). Puedes determinar si uno de estos errores fue devuelto utilizando los métodos `successful`, `clientError` o `serverError`:

    // Determina si el código de estado es >= 200 y < 300...
    $response->successful();

    // Determina si el código de estado es >= 400...
    $response->failed();

    // Determina si la respuesta tiene un código de estado de nivel 400...
    $response->clientError();

    // Determina si la respuesta tiene un código de estado de nivel 500...
    $response->serverError();

    // Ejecuta inmediatamente el callback dado si hubo un error de cliente o servidor...
    $response->onError(callable $callback);

<a name="throwing-exceptions"></a>
#### Lanzando Excepciones

Si tienes una instancia de respuesta y deseas lanzar una instancia de `Illuminate\Http\Client\RequestException` si el código de estado de la respuesta indica un error de cliente o servidor, puedes usar los métodos `throw` o `throwIf`:

    use Illuminate\Http\Client\Response;

    $response = Http::post(/* ... */);

    // Lanza una excepción si ocurrió un error de cliente o servidor...
    $response->throw();

    // Lanza una excepción si ocurrió un error y la condición dada es verdadera...
    $response->throwIf($condition);

    // Lanza una excepción si ocurrió un error y la función anónima dada resuelve a verdadero...
    $response->throwIf(fn (Response $response) => true);

    // Lanza una excepción si ocurrió un error y la condición dada es falsa...
    $response->throwUnless($condition);

    // Lanza una excepción si ocurrió un error y la función anónima dada resuelve a falso...
    $response->throwUnless(fn (Response $response) => false);

    // Lanza una excepción si la respuesta tiene un código de estado específico...
    $response->throwIfStatus(403);

    // Lanza una excepción a menos que la respuesta tenga un código de estado específico...
    $response->throwUnlessStatus(200);

    return $response['user']['id'];

La instancia de `Illuminate\Http\Client\RequestException` tiene una propiedad pública `$response` que te permitirá inspeccionar la respuesta devuelta.

El método `throw` devuelve la instancia de respuesta si no ocurrió ningún error, permitiéndote encadenar otras operaciones al método `throw`:

    return Http::post(/* ... */)->throw()->json();

Si deseas realizar alguna lógica adicional antes de que se lance la excepción, puedes pasar una función anónima al método `throw`. La excepción se lanzará automáticamente después de que se invoque la función anónima, por lo que no necesitas volver a lanzar la excepción desde dentro de la función anónima:

    use Illuminate\Http\Client\Response;
    use Illuminate\Http\Client\RequestException;

    return Http::post(/* ... */)->throw(function (Response $response, RequestException $e) {
        // ...
    })->json();

<a name="guzzle-middleware"></a>
### Middleware de Guzzle

Dado que el cliente HTTP de Laravel está impulsado por Guzzle, puedes aprovechar el [Middleware de Guzzle](https://docs.guzzlephp.org/en/stable/handlers-and-middleware.html) para manipular la solicitud saliente o inspeccionar la respuesta entrante. Para manipular la solicitud saliente, registra un middleware de Guzzle a través del método `withRequestMiddleware`:

    use Illuminate\Support\Facades\Http;
    use Psr\Http\Message\RequestInterface;

    $response = Http::withRequestMiddleware(
        function (RequestInterface $request) {
            return $request->withHeader('X-Example', 'Value');
        }
    )->get('http://example.com');

Del mismo modo, puedes inspeccionar la respuesta HTTP entrante registrando un middleware a través del método `withResponseMiddleware`:

    use Illuminate\Support\Facades\Http;
    use Psr\Http\Message\ResponseInterface;

```php
$response = Http::withResponseMiddleware(
    function (ResponseInterface $response) {
        $header = $response->getHeader('X-Example');

        // ...

        return $response;
    }
)->get('http://example.com');

<a name="global-middleware"></a>
#### Middleware Global

A veces, es posible que desees registrar un middleware que se aplique a cada solicitud saliente y respuesta entrante. Para lograr esto, puedes usar los métodos `globalRequestMiddleware` y `globalResponseMiddleware`. Típicamente, estos métodos deben ser invocados en el método `boot` del `AppServiceProvider` de tu aplicación:

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

Puedes especificar opciones adicionales de [solicitud de Guzzle](http://docs.guzzlephp.org/en/stable/request-options.html) para una solicitud saliente utilizando el método `withOptions`. El método `withOptions` acepta un array de pares clave / valor:

$response = Http::withOptions([
    'debug' => true,
])->get('http://example.com/users');

<a name="global-options"></a>
#### Opciones Globales

Para configurar opciones predeterminadas para cada solicitud saliente, puedes utilizar el método `globalOptions`. Típicamente, este método debe ser invocado desde el método `boot` del `AppServiceProvider` de tu aplicación:

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

A veces, es posible que desees realizar múltiples solicitudes HTTP de manera concurrente. En otras palabras, deseas que varias solicitudes se envíen al mismo tiempo en lugar de emitir las solicitudes secuencialmente. Esto puede llevar a mejoras sustanciales en el rendimiento al interactuar con APIs HTTP lentas.

Afortunadamente, puedes lograr esto utilizando el método `pool`. El método `pool` acepta una función anónima que recibe una instancia de `Illuminate\Http\Client\Pool`, lo que te permite agregar fácilmente solicitudes al grupo de solicitudes para su envío:

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

Como puedes ver, cada instancia de respuesta se puede acceder según el orden en que se agregó al grupo. Si lo deseas, puedes nombrar las solicitudes utilizando el método `as`, lo que te permite acceder a las respuestas correspondientes por nombre:

use Illuminate\Http\Client\Pool;
use Illuminate\Support\Facades\Http;

$responses = Http::pool(fn (Pool $pool) => [
    $pool->as('first')->get('http://localhost/first'),
    $pool->as('second')->get('http://localhost/second'),
    $pool->as('third')->get('http://localhost/third'),
]);

return $responses['first']->ok();

<a name="customizing-concurrent-requests"></a>
#### Personalizando Solicitudes Concurrentes

El método `pool` no se puede encadenar con otros métodos del cliente HTTP, como los métodos `withHeaders` o `middleware`. Si deseas aplicar encabezados personalizados o middleware a las solicitudes agrupadas, debes configurar esas opciones en cada solicitud en el grupo:

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

El cliente HTTP de Laravel te permite definir "macros", que pueden servir como un mecanismo fluido y expresivo para configurar rutas y encabezados de solicitud comunes al interactuar con servicios en toda tu aplicación. Para comenzar, puedes definir la macro dentro del método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

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

Una vez que tu macro ha sido configurada, puedes invocarla desde cualquier parte de tu aplicación para crear una solicitud pendiente con la configuración especificada:

```php
$response = Http::github()->get('/');
```

<a name="testing"></a>
## Pruebas

Muchos servicios de Laravel proporcionan funcionalidad para ayudarte a escribir pruebas de manera fácil y expresiva, y el cliente HTTP de Laravel no es una excepción. El método `fake` del facade `Http` te permite instruir al cliente HTTP para que devuelva respuestas simuladas / ficticias cuando se realizan solicitudes.

<a name="faking-responses"></a>
### Simulando Respuestas

Por ejemplo, para instruir al cliente HTTP para que devuelva respuestas vacías con un código de estado `200` para cada solicitud, puedes llamar al método `fake` sin argumentos:

use Illuminate\Support\Facades\Http;

Http::fake();

$response = Http::post(/* ... */);

<a name="faking-specific-urls"></a>
#### Simulando URLs Específicas

Alternativamente, puedes pasar un array al método `fake`. Las claves del array deben representar patrones de URL que deseas simular y sus respuestas asociadas. El carácter `*` puede ser utilizado como un carácter comodín. Cualquier solicitud realizada a URLs que no han sido simuladas se ejecutará realmente. Puedes usar el método `response` del facade `Http` para construir respuestas simuladas / ficticias para estos endpoints:

Http::fake([
    // Simular una respuesta JSON para endpoints de GitHub...
    'github.com/*' => Http::response(['foo' => 'bar'], 200, $headers),

    // Simular una respuesta de cadena para endpoints de Google...
    'google.com/*' => Http::response('Hello World', 200, $headers),
]);

Si deseas especificar un patrón de URL de respaldo que simule todas las URLs no coincidentes, puedes usar un único carácter `*`:

Http::fake([
    // Simular una respuesta JSON para endpoints de GitHub...
    'github.com/*' => Http::response(['foo' => 'bar'], 200, ['Headers']),

    // Simular una respuesta de cadena para todos los demás endpoints...
    '*' => Http::response('Hello World', 200, ['Headers']),
]);

<a name="faking-response-sequences"></a>
#### Simulando Secuencias de Respuestas

A veces, es posible que necesites especificar que una única URL debe devolver una serie de respuestas simuladas en un orden específico. Puedes lograr esto utilizando el método `Http::sequence` para construir las respuestas:

Http::fake([
    // Simular una serie de respuestas para endpoints de GitHub...
    'github.com/*' => Http::sequence()
                            ->push('Hello World', 200)
                            ->push(['foo' => 'bar'], 200)
                            ->pushStatus(404),
]);

Cuando todas las respuestas en una secuencia de respuestas han sido consumidas, cualquier solicitud adicional hará que la secuencia de respuestas lance una excepción. Si deseas especificar una respuesta predeterminada que debe ser devuelta cuando una secuencia esté vacía, puedes usar el método `whenEmpty`:

Http::fake([
    // Simular una serie de respuestas para endpoints de GitHub...
    'github.com/*' => Http::sequence()
                            ->push('Hello World', 200)
                            ->push(['foo' => 'bar'], 200)
                            ->whenEmpty(Http::response()),
]);

Si deseas simular una secuencia de respuestas pero no necesitas especificar un patrón de URL específico que deba ser simulado, puedes usar el método `Http::fakeSequence`:

Http::fakeSequence()
        ->push('Hello World', 200)
        ->whenEmpty(Http::response());

<a name="fake-callback"></a>
#### Simulación de Callback

Si necesitas una lógica más complicada para determinar qué respuestas devolver para ciertos endpoints, puedes pasar una función anónima al método `fake`. Esta función anónima recibirá una instancia de `Illuminate\Http\Client\Request` y debe devolver una instancia de respuesta. Dentro de tu función anónima, puedes realizar la lógica necesaria para determinar qué tipo de respuesta devolver:

use Illuminate\Http\Client\Request;

Http::fake(function (Request $request) {
    return Http::response('Hello World', 200);
});

<a name="preventing-stray-requests"></a>
### Previniendo Solicitudes Errantes

Si deseas asegurarte de que todas las solicitudes enviadas a través del cliente HTTP han sido simuladas durante tu prueba individual o suite de pruebas completa, puedes llamar al método `preventStrayRequests`. Después de llamar a este método, cualquier solicitud que no tenga una respuesta simulada correspondiente lanzará una excepción en lugar de realizar la solicitud HTTP real:

use Illuminate\Support\Facades\Http;

Http::preventStrayRequests();

Http::fake([
    'github.com/*' => Http::response('ok'),
]);

// Se devuelve una respuesta "ok"...
Http::get('https://github.com/laravel/framework');

// Se lanza una excepción...
Http::get('https://laravel.com');

<a name="inspecting-requests"></a>
### Inspeccionando Solicitudes

Al simular respuestas, a veces es posible que desees inspeccionar las solicitudes que el cliente recibe para asegurarte de que tu aplicación está enviando los datos o encabezados correctos. Puedes lograr esto llamando al método `Http::assertSent` después de llamar a `Http::fake`.

El método `assertSent` acepta una función anónima que recibirá una instancia de `Illuminate\Http\Client\Request` y debe devolver un valor booleano que indique si la solicitud coincide con tus expectativas. Para que la prueba pase, al menos una solicitud debe haber sido emitida coincidiendo con las expectativas dadas:

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

Si es necesario, puedes afirmar que una solicitud específica no fue enviada utilizando el método `assertNotSent`:

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

Puedes usar el método `assertSentCount` para afirmar cuántas solicitudes fueron "enviadas" durante la prueba:

Http::fake();

Http::assertSentCount(5);

O, puedes usar el método `assertNothingSent` para afirmar que no se enviaron solicitudes durante la prueba:

Http::fake();

Http::assertNothingSent();

<a name="recording-requests-and-responses"></a>
#### Grabando Solicitudes / Respuestas

Puedes usar el método `recorded` para recopilar todas las solicitudes y sus respuestas correspondientes. El método `recorded` devuelve una colección de arrays que contiene instancias de `Illuminate\Http\Client\Request` y `Illuminate\Http\Client\Response`:

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

Además, el método `recorded` acepta una función anónima que recibirá una instancia de `Illuminate\Http\Client\Request` y `Illuminate\Http\Client\Response` y puede ser utilizada para filtrar pares de solicitud / respuesta según tus expectativas:

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

Laravel dispara tres eventos durante el proceso de envío de solicitudes HTTP. El evento `RequestSending` se dispara antes de que se envíe una solicitud, mientras que el evento `ResponseReceived` se dispara después de que se recibe una respuesta para una solicitud dada. El evento `ConnectionFailed` se dispara si no se recibe respuesta para una solicitud dada.

Los eventos `RequestSending` y `ConnectionFailed` contienen una propiedad pública `$request` que puedes usar para inspeccionar la instancia de `Illuminate\Http\Client\Request`. Asimismo, el evento `ResponseReceived` contiene una propiedad `$request` así como una propiedad `$response` que puede ser utilizada para inspeccionar la instancia de `Illuminate\Http\Client\Response`. Puedes crear [listeners de eventos](/docs/{{version}}/events) para estos eventos dentro de tu aplicación:

use Illuminate\Http\Client\Events\RequestSending;

class LogRequest
{
    /**
     * Manejar el evento dado.
     */
    public function handle(RequestSending $event): void
    {
        // $event->request ...
    }
}
```
