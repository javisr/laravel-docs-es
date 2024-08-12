# Cliente HTTP

- [Introducción](#introduction)
- [Realizar solicitudes](#making-requests)
  - [Datos de la solicitud](#request-data)
  - [Cabeceras](#headers)
  - [Autenticación](#authentication)
  - [Tiempo de espera](#timeout)
  - [Reintentos](#retries)
  - [Gestión de errores](#error-handling)
  - [Guzzle Middleware](#guzzle-middleware)
  - [Opciones de Guzzle](#guzzle-options)
- [Peticiones concurrentes](#concurrent-requests)
- [Macros](#macros)
- [Pruebas](#testing)
  - [Falsificación de respuestas](#faking-responses)
  - [Inspección de peticiones](#inspecting-requests)
  - [Prevención de Peticiones Perdidas](#preventing-stray-requests)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

Laravel proporciona una API alrededor del [cliente HTTP Guzzle](http://docs.guzzlephp.org/en/stable/), que te permite realizar rápidamente peticiones HTTP salientes para comunicarte con otras aplicaciones web. La envoltura de Laravel alrededor de Guzzle se centra en los casos de uso más comunes y en una maravillosa experiencia para el desarrollador.

Antes de empezar, debes asegurarte de que has instalado el paquete Guzzle como dependencia de tu aplicación. Por defecto, Laravel incluye automáticamente esta dependencia. Sin embargo, si previamente has eliminado el paquete, puedes instalarlo de nuevo a través de Composer:

```shell
composer require guzzlehttp/guzzle
```

<a name="making-requests"></a>
## Realización de solicitudes

Para realizar peticiones, puedes utilizar los métodos `head`, `get`, `post`, `put`, `patch` y `delete` proporcionados por la facade `Http`. Primero, examinemos cómo hacer una petición `GET` básica a otra URL:

    use Illuminate\Support\Facades\Http;

    $response = Http::get('http://example.com');

El método `get` devuelve una instancia de `Illuminate\Http\Client\Response`, que proporciona una variedad de métodos que se pueden utilizar para inspeccionar la respuesta:

    $response->body() : string;
    $response->json($key = null) : array|mixed;
    $response->object() : object;
    $response->collect($key = null) : Illuminate\Support\Collection;
    $response->status() : int;
    $response->ok() : bool;
    $response->successful() : bool;
    $response->redirect(): bool;
    $response->failed() : bool;
    $response->serverError() : bool;
    $response->clientError() : bool;
    $response->header($header) : string;
    $response->headers() : array;

El objeto `Illuminate\Http\Client\Response` también implementa la interfaz PHP `ArrayAccess`, lo que le permite acceder a los datos de respuesta JSON directamente en la respuesta:

    return Http::get('http://example.com/users/1')['name'];

<a name="dumping-requests"></a>
#### Volcado de peticiones

Si desea volcar la instancia de la petición saliente antes de que sea enviada y terminar la ejecución del script, puede añadir el método `dd` al principio de la definición de su petición:

    return Http::dd()->get('http://example.com');

<a name="request-data"></a>
### Datos de la solicitud

Por supuesto, es común cuando se hacen peticiones `POST`, `PUT`, y `PATCH` enviar datos adicionales con su petición, por lo que estos métodos aceptan un array de datos como segundo argumento. Por defecto, los datos se enviarán utilizando el tipo de contenido `application/json`:

    use Illuminate\Support\Facades\Http;

    $response = Http::post('http://example.com/users', [
        'name' => 'Steve',
        'role' => 'Network Administrator',
    ]);

<a name="get-request-query-parameters"></a>
#### Parámetros de consulta de la petición GET

Al realizar peticiones `GET`, puede añadir una cadena de consulta a la URL directamente o pasar un array de pares clave/valor como segundo argumento al método `get`:

    $response = Http::get('http://example.com/users', [
        'name' => 'Taylor',
        'page' => 1,
    ]);

<a name="sending-form-url-encoded-requests"></a>
#### Envío de solicitudes codificadas con URL de formulario

Si desea enviar datos utilizando el tipo de contenido `application/x-www-form-urlencoded`, debe llamar al método `asForm` antes de realizar la petición:

    $response = Http::asForm()->post('http://example.com/users', [
        'name' => 'Sara',
        'role' => 'Privacy Consultant',
    ]);

<a name="sending-a-raw-request-body"></a>
#### Envío de un cuerpo de solicitud sin procesar

Puede utilizar el método `withBody` si desea proporcionar un cuerpo de petición sin procesar al realizar una petición. El tipo de contenido puede ser proporcionado a través del segundo argumento del método:

    $response = Http::withBody(
        base64_encode($photo), 'image/jpeg'
    )->post('http://example.com/photo');

<a name="multi-part-requests"></a>
#### Peticiones Multi-Part

Si desea enviar archivos como peticiones multi-part, debe llamar al método `attach` antes de realizar la petición. Este método acepta el nombre del archivo y su contenido. Si es necesario, puede proporcionar un tercer argumento que se considerará el nombre del fichero:

    $response = Http::attach(
        'attachment', file_get_contents('photo.jpg'), 'photo.jpg'
    )->post('http://example.com/attachments');

En lugar de pasar el contenido en bruto de un archivo, puede pasar un recurso de flujo:

    $photo = fopen('photo.jpg', 'r');

    $response = Http::attach(
        'attachment', $photo, 'photo.jpg'
    )->post('http://example.com/attachments');

<a name="headers"></a>
### Cabeceras

Se pueden añadir cabeceras a las peticiones utilizando el método `withHeaders`. Este método `withHeaders` acepta un array de pares clave / valor:

    $response = Http::withHeaders([
        'X-First' => 'foo',
        'X-Second' => 'bar'
    ])->post('http://example.com/users', [
        'name' => 'Taylor',
    ]);

Puede utilizar el método `accept` para especificar el tipo de contenido que su aplicación espera como respuesta a su petición:

    $response = Http::accept('application/json')->get('http://example.com/users');

Para mayor comodidad, puede utilizar el método `acceptJson` para especificar rápidamente que su aplicación espera el tipo de contenido `application/json` en respuesta a su solicitud:

    $response = Http::acceptJson()->get('http://example.com/users');

<a name="authentication"></a>
### Autenticación

Puedes especificar credenciales de autenticación básica y digest usando los métodos `withBasicAuth` y `withDigestAuth`, respectivamente:

    // Basic authentication...
    $response = Http::withBasicAuth('taylor@laravel.com', 'secret')->post(/* ... */);

    // Digest authentication...
    $response = Http::withDigestAuth('taylor@laravel.com', 'secret')->post(/* ... */);

<a name="bearer-tokens"></a>
#### Bearer Tokens

Si desea añadir rápidamente un token "bearer" a la cabecera `Authorization` de la petición, puede utilizar el método `withToken`:

    $response = Http::withToken('token')->post(/* ... */);

<a name="timeout"></a>
### Tiempo de espera

El método `timeout` se puede utilizar para especificar el número máximo de segundos que se debe esperar para recibir una respuesta:

    $response = Http::timeout(3)->get(/* ... */);

Si se supera el tiempo de espera dado, se lanzará una instancia de `Illuminate\Http\Client\ConnectionException`.

Puede especificar el número máximo de segundos a esperar mientras intenta conectarse a un servidor utilizando el método `connectTimeout`:

    $response = Http::connectTimeout(3)->get(/* ... */);

<a name="retries"></a>
### Reintentos

Si desea que el cliente HTTP reintente automáticamente la petición si se produce un error en el cliente o en el servidor, puede utilizar el método `retry`. El método `retry` acepta el número máximo de veces que debe intentarse la petición y el número de milisegundos que Laravel debe esperar entre intentos:

    $response = Http::retry(3, 100)->post(/* ... */);

Si es necesario, puedes pasar un tercer argumento al método `retry`. El tercer argumento debe ser un callable que determine si los reintentos deben ser realmente intentados. Por ejemplo, puede que sólo desee reintentar la petición si la petición inicial encuentra una `ConnectionException`:

    $response = Http::retry(3, 100, function ($exception, $request) {
        return $exception instanceof ConnectionException;
    })->post(/* ... */);

Si un intento de petición falla, puede que desee realizar un cambio en la petición antes de que se realice un nuevo intento. Esto se puede conseguir modificando el argumento de petición proporcionado a la llamada al método `retry`. Por ejemplo, puede que quieras reintentar la petición con un nuevo token de autorización si el primer intento devolvió un error de autenticación:

    $response = Http::withToken($this->getToken())->retry(2, 0, function ($exception, $request) {
        if (! $exception instanceof RequestException || $exception->response->status() !== 401) {
            return false;
        }

        $request->withToken($this->getNewToken());

        return true;
    })->post(/* ... */);

Si todas las peticiones fallan, se lanzará una instancia de `Illuminate\Http\Client\RequestException`. Si desea desactivar este comportamiento, puede proporcionar un argumento `throw` con el valor `false`. Cuando se deshabilita, se devolverá la última respuesta recibida por el cliente después de que se hayan intentado todos los reintentos:

    $response = Http::retry(3, 100, throw: false)->post(/* ... */);

> **Advertencia**  
> Si todas las peticiones fallan debido a un problema de conexión, se lanzará una `excepción Illuminate\Http\Client\ConnectionException` incluso cuando el argumento `throw` tenga el valor `false`.

<a name="error-handling"></a>
### Manejo de Errores

A diferencia del comportamiento por defecto de Guzzle, la envoltura de cliente HTTP de Laravel no lanza excepciones en errores de cliente o servidor (respuestas con codigos `400` y `500`). Puedes determinar si uno de estos errores fue devuelto usando los métodos `successful`, `clientError`, o `serverError`:

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

<a name="throwing-exceptions"></a>
#### Lanzar excepciones

Si tiene una instancia de respuesta y desea lanzar una instancia de `Illuminate\Http\Client\RequestException` si el código de estado de la respuesta indica un error del cliente o del servidor, puede utilizar los métodos `throw` o `throwIf`:

    $response = Http::post(/* ... */);

    // Throw an exception if a client or server error occurred...
    $response->throw();

    // Throw an exception if an error occurred and the given condition is true...
    $response->throwIf($condition);

    // Throw an exception if an error occurred and the given closure resolves to true...
    $response->throwIf(fn ($response) => true);

    // Throw an exception if an error occurred and the given condition is false...
    $response->throwUnless($condition);

    // Throw an exception if an error occurred and the given closure resolves to false...
    $response->throwUnless(fn ($response) => false);

    return $response['user']['id'];

La instancia `Illuminate\Http\Client\RequestException` tiene una propiedad pública `$response` que le permitirá inspeccionar la respuesta devuelta.

El método `throw` devuelve la instancia de respuesta si no se ha producido ningún error, lo que permite encadenar otras operaciones con el método `throw`:

    return Http::post(/* ... */)->throw()->json();

Si desea realizar alguna lógica adicional antes de que se lance la excepción, puede pasar un closure al método `throw`. La excepción se lanzará automáticamente después de que se invoque el closure, por lo que no es necesario volver a lanzar la excepción desde dentro del closure:

    return Http::post(/* ... */)->throw(function ($response, $e) {
        //
    })->json();

<a name="guzzle-middleware"></a>
### Guzzle middleware

Dado que el cliente HTTP de Laravel se basa en Guzzle, usted puede sacar provecho del [Guzzle Middleware](https://docs.guzzlephp.org/en/stable/handlers-and-middleware.html) para manipular la solicitud saliente o inspeccionar la respuesta entrante. Para manipular la petición saliente, registra un middleware Guzzle a través del método `withMiddleware` en combinación con la factoría de middleware `mapRequest` de Guzzle:

    use GuzzleHttp\Middleware;
    use Illuminate\Support\Facades\Http;
    use Psr\Http\Message\RequestInterface;

    $response = Http::withMiddleware(
        Middleware::mapRequest(function (RequestInterface $request) {
            $request->withHeader('X-Example', 'Value');
            
            return $request;
        })
    )->get('http://example.com');

Del mismo modo, puedes inspeccionar la respuesta HTTP entrante registrando un middleware a través del método `withMiddleware` en combinación con la factoría de middleware `mapResponse` de Guzzle:

    use GuzzleHttp\Middleware;
    use Illuminate\Support\Facades\Http;
    use Psr\Http\Message\ResponseInterface;

    $response = Http::withMiddleware(
        Middleware::mapResponse(function (ResponseInterface $response) {
            $header = $response->getHeader('X-Example');

            // ...
            
            return $response;
        })
    )->get('http://example.com');

<a name="guzzle-options"></a>
### Opciones de Guzzle

Puede especificar [opciones de petición Guzzle](http://docs.guzzlephp.org/en/stable/request-options.html) adicionales usando el método `withOptions`. El método `withOptions` acepta un array de pares clave / valor:

    $response = Http::withOptions([
        'debug' => true,
    ])->get('http://example.com/users');

<a name="concurrent-requests"></a>
## Peticiones concurrentes

A veces, es posible que desees hacer varias peticiones HTTP simultáneamente. En otras palabras, quieres que varias peticiones se envíen al mismo tiempo en lugar de emitir las peticiones secuencialmente. Esto puede mejorar sustancialmente el rendimiento cuando se interactúa con APIs HTTP lentas.

Afortunadamente, puedes conseguirlo usando el método `pool`. El método `pool` acepta un closure que recibe una instancia `Illuminate\Http\Client\Pool`, lo que le permite agregar fácilmente las solicitudes al pool de solicitud para que sean despachadas:

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

Como puede ver, se puede acceder a cada instancia de respuesta basándose en el orden en que fue añadida al pool. Si lo desea, puede nombrar las peticiones utilizando el método `as`, que le permite acceder a las respuestas correspondientes por su nombre:

    use Illuminate\Http\Client\Pool;
    use Illuminate\Support\Facades\Http;

    $responses = Http::pool(fn (Pool $pool) => [
        $pool->as('first')->get('http://localhost/first'),
        $pool->as('second')->get('http://localhost/second'),
        $pool->as('third')->get('http://localhost/third'),
    ]);

    return $responses['first']->ok();

<a name="macros"></a>
## Macros

El cliente HTTP de Laravel permite definir "macros", que pueden servir como un mecanismo fluido y expresivo para configurar rutas de petición y cabeceras comunes al interactuar con servicios en toda la aplicación. Para empezar, puede definir la macro dentro del método `boot` de la clase `AppProviders\AppServiceProvider` de su aplicación:

```php
use Illuminate\Support\Facades\Http;

/**
 * Bootstrap any application services.
 *
 * @return void
 */
public function boot()
{
    Http::macro('github', function () {
        return Http::withHeaders([
            'X-Example' => 'example',
        ])->baseUrl('https://github.com');
    });
}
```

Una vez configurada tu macro, puedes invocarla desde cualquier parte de tu aplicación para crear una petición pendiente con la configuración especificada:

```php
$response = Http::github()->get('/');
```

<a name="testing"></a>
## Testing

Muchos servicios de Laravel proporcionan funcionalidades para ayudarte a escribir tests forma fácil y expresiva, y el cliente HTTP de Laravel no es una excepción. El método `fake` de la facade `Http` permite instruir al cliente HTTP para que devuelva respuestas stubbed / dummy cuando se realizan peticiones.

<a name="faking-responses"></a>
### Falsificación de respuestas

Por ejemplo, para indicar al cliente HTTP que devuelva respuestas vacías, con código de estado `200` para cada petición, puedes llamar al método `fake` sin argumentos:

    use Illuminate\Support\Facades\Http;

    Http::fake();

    $response = Http::post(/* ... */);

<a name="faking-specific-urls"></a>
#### Falsificación de URL específicas

De manera alternativa, puede pasar un array al método `fake`. Las claves del array deben representar los patrones de URL que desea falsificar y sus respuestas asociadas. El carácter `*` puede utilizarse como comodín. Cualquier petición realizada a una URL que no haya sido falsificada será ejecutada. Puede utilizar el método `response` de la facade `Http` para construir respuestas stub / falsas para estos endpoints:

    Http::fake([
        // Stub a JSON response for GitHub endpoints...
        'github.com/*' => Http::response(['foo' => 'bar'], 200, $headers),

        // Stub a string response for Google endpoints...
        'google.com/*' => Http::response('Hello World', 200, $headers),
    ]);

Si desea especificar un patrón de URL alternativa que sea usado en todas las URL no coincidentes, puede utilizar un único carácter `*`:

    Http::fake([
        // Stub a JSON response for GitHub endpoints...
        'github.com/*' => Http::response(['foo' => 'bar'], 200, ['Headers']),

        // Stub a string response for all other endpoints...
        '*' => Http::response('Hello World', 200, ['Headers']),
    ]);

<a name="faking-response-sequences"></a>
#### Falsificación de secuencias de respuesta

A veces puede que necesite especificar que una única URL devuelva una serie de respuestas falsas en un orden específico. Puede conseguirlo utilizando el método `Http::sequence` para construir las respuestas:

    Http::fake([
        // Stub a series of responses for GitHub endpoints...
        'github.com/*' => Http::sequence()
                                ->push('Hello World', 200)
                                ->push(['foo' => 'bar'], 200)
                                ->pushStatus(404),
    ]);

Cuando se hayan consumido todas las respuestas de una secuencia de respuesta, cualquier otra petición hará que la secuencia de respuesta lance una excepción. Si desea especificar una respuesta por defecto que debe ser devuelta cuando una secuencia está vacía, puede utilizar el método `whenEmpty`:

    Http::fake([
        // Stub a series of responses for GitHub endpoints...
        'github.com/*' => Http::sequence()
                                ->push('Hello World', 200)
                                ->push(['foo' => 'bar'], 200)
                                ->whenEmpty(Http::response()),
    ]);

Si desea falsificar una secuencia de respuestas pero no necesita especificar un patrón de URL concreto que deba falsificarse, puede utilizar el método `Http::fakeSequence`:

    Http::fakeSequence()
            ->push('Hello World', 200)
            ->whenEmpty(Http::response());

<a name="fake-callback"></a>
#### Fake Callback

Si necesita una lógica más complicada para determinar qué respuestas devolver para ciertos puntos finales, puede pasar un closure al método `false`. Este closure recibirá una instancia de `Illuminate\Http\Client\Request` y debe devolver una instancia de respuesta. Dentro de su closure, puede realizar cualquier lógica que sea necesaria para determinar qué tipo de respuesta devolver:

    use Illuminate\Http\Client\Request;

    Http::fake(function (Request $request) {
        return Http::response('Hello World', 200);
    });

<a name="preventing-stray-requests"></a>
### Prevención de Peticiones Perdidas

Si desea asegurarse de que todas las solicitudes enviadas a través del cliente HTTP han sido falsificadas a lo largo de su test individual o conjunto de test completo, puede llamar al método `preventStrayRequests`. Después de llamar a este método, cualquier petición que no tenga una respuesta falsa correspondiente lanzará una excepción en lugar de realizar la petición HTTP real:

    use Illuminate\Support\Facades\Http;

    Http::preventStrayRequests();

    Http::fake([
        'github.com/*' => Http::response('ok'),
    ]);

    // An "ok" response is returned...
    Http::get('https://github.com/laravel/framework');

    // An exception is thrown...
    Http::get('https://laravel.com');

<a name="inspecting-requests"></a>
### Inspección de peticiones

Cuando se falsifican respuestas, puede que ocasionalmente desee inspeccionar las peticiones que recibe el cliente para asegurarse de que su aplicación está enviando los datos o cabeceras correctos. Puede hacerlo llamando al método `Http::assertSent` después de llamar a `Http::fake`.

El método `assertSent` acepta un closure que recibirá una instancia `Illuminate\Http\Client\Request` y debe devolver un valor booleano que indica si la solicitud coincide con sus expectativas. Para que el test pase, se debe haber emitido al menos una solicitud que coincida con las expectativas dadas:

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

Si es necesario, puedes afirmar que una petición específica no fue enviada usando el método `assertNotSent`:

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

Puede utilizar el método `assertSentCount` para comprobar cuántas solicitudes se han "enviado" durante la test:

    Http::fake();

    Http::assertSentCount(5);

O puede utilizar el método `assertNothingSent` para afirmar que no se ha enviado ninguna petición durante la test:

    Http::fake();

    Http::assertNothingSent();

<a name="recording-requests-and-responses"></a>
#### Registro de Peticiones / Respuestas

Puede utilizar el método `recorded` para recopilar todas las solicitudes y sus correspondientes respuestas. El método `recorded` devuelve una colección de arrays que contiene instancias de `Illuminate\Http\Client\Request` y `Illuminate\Http\Client\Response`:

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

Además, el método `recorded` acepta un closure que recibirá una instancia de `Illuminate\Http\Client\Request` y `Illuminate\Http\Client\Response` y se puede utilizar para filtrar pares de solicitud / respuesta en función de sus expectativas:

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

Laravel dispara tres eventos durante el proceso de envío de peticiones HTTP. El evento `RequestSending` se dispara antes de que se envíe una petición, mientras que el evento `ResponseReceived` se dispara después de que se reciba una respuesta para una petición dada. El evento `ConnectionFailed` se dispara si no se recibe respuesta para una petición dada.

Los eventos `RequestSending` y `ConnectionFailed` contienen una propiedad pública `$request` que puede utilizar para inspeccionar la instancia `Illuminate\Http\Client\Request`. Del mismo modo, el evento `ResponseReceived` contiene una propiedad `$request`, así como una propiedad `$response` que se puede utilizar para inspeccionar la instancia `Illuminate\Http\Client\Response`. Puede registrar escuchadores de eventos para este evento en su proveedor de servicios `AppProviders\EventServiceProvider`:

    /**
     * The event listener mappings for the application.
     *
     * @var array
     */
    protected $listen = [
        'Illuminate\Http\Client\Events\RequestSending' => [
            'App\Listeners\LogRequestSending',
        ],
        'Illuminate\Http\Client\Events\ResponseReceived' => [
            'App\Listeners\LogResponseReceived',
        ],
        'Illuminate\Http\Client\Events\ConnectionFailed' => [
            'App\Listeners\LogConnectionFailed',
        ],
    ];
