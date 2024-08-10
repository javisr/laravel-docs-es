# Respuestas HTTP

- [Creando Respuestas](#creating-responses)
    - [Adjuntando Encabezados a las Respuestas](#attaching-headers-to-responses)
    - [Adjuntando Cookies a las Respuestas](#attaching-cookies-to-responses)
    - [Cookies y Encriptación](#cookies-and-encryption)
- [Redirecciones](#redirects)
    - [Redirigiendo a Rutas Nombradas](#redirecting-named-routes)
    - [Redirigiendo a Acciones de Controlador](#redirecting-controller-actions)
    - [Redirigiendo a Dominios Externos](#redirecting-external-domains)
    - [Redirigiendo con Datos de Sesión Flasheados](#redirecting-with-flashed-session-data)
- [Otros Tipos de Respuesta](#other-response-types)
    - [Respuestas de Vista](#view-responses)
    - [Respuestas JSON](#json-responses)
    - [Descargas de Archivos](#file-downloads)
    - [Respuestas de Archivos](#file-responses)
- [Macros de Respuesta](#response-macros)

<a name="creating-responses"></a>
## Creando Respuestas

<a name="strings-arrays"></a>
#### Cadenas y Arreglos

Todas las rutas y controladores deben devolver una respuesta que se enviará de vuelta al navegador del usuario. Laravel proporciona varias formas diferentes de devolver respuestas. La respuesta más básica es devolver una cadena desde una ruta o controlador. El marco convertirá automáticamente la cadena en una respuesta HTTP completa:

    Route::get('/', function () {
        return 'Hello World';
    });

Además de devolver cadenas desde tus rutas y controladores, también puedes devolver arreglos. El marco convertirá automáticamente el arreglo en una respuesta JSON:

    Route::get('/', function () {
        return [1, 2, 3];
    });

> [!NOTE]  
> ¿Sabías que también puedes devolver [colecciones Eloquent](/docs/{{version}}/eloquent-collections) desde tus rutas o controladores? Se convertirán automáticamente en JSON. ¡Inténtalo!

<a name="response-objects"></a>
#### Objetos de Respuesta

Típicamente, no solo estarás devolviendo cadenas o arreglos simples desde las acciones de tu ruta. En su lugar, estarás devolviendo instancias completas de `Illuminate\Http\Response` o [vistas](/docs/{{version}}/views).

Devolver una instancia completa de `Response` te permite personalizar el código de estado HTTP y los encabezados de la respuesta. Una instancia de `Response` hereda de la clase `Symfony\Component\HttpFoundation\Response`, que proporciona una variedad de métodos para construir respuestas HTTP:

    Route::get('/home', function () {
        return response('Hello World', 200)
                      ->header('Content-Type', 'text/plain');
    });

<a name="eloquent-models-and-collections"></a>
#### Modelos y Colecciones Eloquent

También puedes devolver modelos y colecciones de [Eloquent ORM](/docs/{{version}}/eloquent) directamente desde tus rutas y controladores. Cuando lo haces, Laravel convertirá automáticamente los modelos y colecciones en respuestas JSON respetando los [atributos ocultos del modelo](/docs/{{version}}/eloquent-serialization#hiding-attributes-from-json):

    use App\Models\User;

    Route::get('/user/{user}', function (User $user) {
        return $user;
    });

<a name="attaching-headers-to-responses"></a>
### Adjuntando Encabezados a las Respuestas

Ten en cuenta que la mayoría de los métodos de respuesta son encadenables, lo que permite la construcción fluida de instancias de respuesta. Por ejemplo, puedes usar el método `header` para agregar una serie de encabezados a la respuesta antes de enviarla de vuelta al usuario:

    return response($content)
                ->header('Content-Type', $type)
                ->header('X-Header-One', 'Header Value')
                ->header('X-Header-Two', 'Header Value');

O, puedes usar el método `withHeaders` para especificar un arreglo de encabezados que se agregarán a la respuesta:

    return response($content)
                ->withHeaders([
                    'Content-Type' => $type,
                    'X-Header-One' => 'Header Value',
                    'X-Header-Two' => 'Header Value',
                ]);

<a name="cache-control-middleware"></a>
#### Middleware de Control de Caché

Laravel incluye un middleware `cache.headers`, que puede ser utilizado para establecer rápidamente el encabezado `Cache-Control` para un grupo de rutas. Las directivas deben proporcionarse utilizando el equivalente en "snake case" de la directiva de control de caché correspondiente y deben estar separadas por un punto y coma. Si `etag` se especifica en la lista de directivas, un hash MD5 del contenido de la respuesta se establecerá automáticamente como el identificador ETag:

    Route::middleware('cache.headers:public;max_age=2628000;etag')->group(function () {
        Route::get('/privacy', function () {
            // ...
        });

        Route::get('/terms', function () {
            // ...
        });
    });

<a name="attaching-cookies-to-responses"></a>
### Adjuntando Cookies a las Respuestas

Puedes adjuntar una cookie a una instancia saliente de `Illuminate\Http\Response` usando el método `cookie`. Debes pasar el nombre, valor y el número de minutos que la cookie debe considerarse válida a este método:

    return response('Hello World')->cookie(
        'name', 'value', $minutes
    );

El método `cookie` también acepta algunos argumentos más que se utilizan con menos frecuencia. Generalmente, estos argumentos tienen el mismo propósito y significado que los argumentos que se darían al método nativo de PHP [setcookie](https://secure.php.net/manual/en/function.setcookie.php):

    return response('Hello World')->cookie(
        'name', 'value', $minutes, $path, $domain, $secure, $httpOnly
    );

Si deseas asegurarte de que una cookie se envíe con la respuesta saliente pero aún no tienes una instancia de esa respuesta, puedes usar la fachada `Cookie` para "enviar" cookies para adjuntarlas a la respuesta cuando se envíe. El método `queue` acepta los argumentos necesarios para crear una instancia de cookie. Estas cookies se adjuntarán a la respuesta saliente antes de que se envíe al navegador:

    use Illuminate\Support\Facades\Cookie;

    Cookie::queue('name', 'value', $minutes);

<a name="generating-cookie-instances"></a>
#### Generando Instancias de Cookie

Si deseas generar una instancia de `Symfony\Component\HttpFoundation\Cookie` que se pueda adjuntar a una instancia de respuesta en un momento posterior, puedes usar el helper global `cookie`. Esta cookie no se enviará de vuelta al cliente a menos que se adjunte a una instancia de respuesta:

    $cookie = cookie('name', 'value', $minutes);

    return response('Hello World')->cookie($cookie);

<a name="expiring-cookies-early"></a>
#### Expirando Cookies Temprano

Puedes eliminar una cookie expirándola a través del método `withoutCookie` de una respuesta saliente:

    return response('Hello World')->withoutCookie('name');

Si aún no tienes una instancia de la respuesta saliente, puedes usar el método `expire` de la fachada `Cookie` para expirar una cookie:

    Cookie::expire('name');

<a name="cookies-and-encryption"></a>
### Cookies y Encriptación

Por defecto, gracias al middleware `Illuminate\Cookie\Middleware\EncryptCookies`, todas las cookies generadas por Laravel están encriptadas y firmadas para que no puedan ser modificadas o leídas por el cliente. Si deseas desactivar la encriptación para un subconjunto de cookies generadas por tu aplicación, puedes usar el método `encryptCookies` en el archivo `bootstrap/app.php` de tu aplicación:

    ->withMiddleware(function (Middleware $middleware) {
        $middleware->encryptCookies(except: [
            'cookie_name',
        ]);
    })

<a name="redirects"></a>
## Redirecciones

Las respuestas de redirección son instancias de la clase `Illuminate\Http\RedirectResponse`, y contienen los encabezados adecuados necesarios para redirigir al usuario a otra URL. Hay varias formas de generar una instancia de `RedirectResponse`. El método más simple es usar el helper global `redirect`:

    Route::get('/dashboard', function () {
        return redirect('/home/dashboard');
    });

A veces, puedes desear redirigir al usuario a su ubicación anterior, como cuando un formulario enviado es inválido. Puedes hacerlo usando la función helper global `back`. Dado que esta función utiliza la [sesión](/docs/{{version}}/session), asegúrate de que la ruta que llama a la función `back` esté utilizando el grupo de middleware `web`:

    Route::post('/user/profile', function () {
        // Validar la solicitud...

        return back()->withInput();
    });

<a name="redirecting-named-routes"></a>
### Redirigiendo a Rutas Nombradas

Cuando llamas al helper `redirect` sin parámetros, se devuelve una instancia de `Illuminate\Routing\Redirector`, lo que te permite llamar a cualquier método en la instancia de `Redirector`. Por ejemplo, para generar una `RedirectResponse` a una ruta nombrada, puedes usar el método `route`:

    return redirect()->route('login');

Si tu ruta tiene parámetros, puedes pasarlos como el segundo argumento al método `route`:

    // Para una ruta con la siguiente URI: /profile/{id}

    return redirect()->route('profile', ['id' => 1]);

<a name="populating-parameters-via-eloquent-models"></a>
#### Población de Parámetros a través de Modelos Eloquent

Si estás redirigiendo a una ruta con un parámetro "ID" que se está poblando desde un modelo Eloquent, puedes pasar el modelo en sí. El ID se extraerá automáticamente:

    // Para una ruta con la siguiente URI: /profile/{id}

    return redirect()->route('profile', [$user]);

Si deseas personalizar el valor que se coloca en el parámetro de la ruta, puedes especificar la columna en la definición del parámetro de la ruta (`/profile/{id:slug}`) o puedes sobrescribir el método `getRouteKey` en tu modelo Eloquent:

    /**
     * Obtener el valor de la clave de ruta del modelo.
     */
    public function getRouteKey(): mixed
    {
        return $this->slug;
    }

<a name="redirecting-controller-actions"></a>
### Redirigiendo a Acciones de Controlador

También puedes generar redirecciones a [acciones de controlador](/docs/{{version}}/controllers). Para hacerlo, pasa el nombre del controlador y la acción al método `action`:

    use App\Http\Controllers\UserController;

    return redirect()->action([UserController::class, 'index']);

Si tu ruta de controlador requiere parámetros, puedes pasarlos como el segundo argumento al método `action`:

    return redirect()->action(
        [UserController::class, 'profile'], ['id' => 1]
    );

<a name="redirecting-external-domains"></a>
### Redirigiendo a Dominios Externos

A veces, puedes necesitar redirigir a un dominio fuera de tu aplicación. Puedes hacerlo llamando al método `away`, que crea una `RedirectResponse` sin ninguna codificación de URL adicional, validación o verificación:

    return redirect()->away('https://www.google.com');

<a name="redirecting-with-flashed-session-data"></a>
### Redirigiendo Con Datos de Sesión Flasheados

Redirigir a una nueva URL y [flashear datos a la sesión](/docs/{{version}}/session#flash-data) generalmente se hace al mismo tiempo. Típicamente, esto se hace después de realizar exitosamente una acción cuando flasheas un mensaje de éxito a la sesión. Para conveniencia, puedes crear una instancia de `RedirectResponse` y flashear datos a la sesión en una sola cadena de métodos fluida:

    Route::post('/user/profile', function () {
        // ...

        return redirect('/dashboard')->with('status', 'Profile updated!');
    });

Después de que el usuario es redirigido, puedes mostrar el mensaje flasheado desde la [sesión](/docs/{{version}}/session). Por ejemplo, usando [sintaxis Blade](/docs/{{version}}/blade):

    @if (session('status'))
        <div class="alert alert-success">
            {{ session('status') }}
        </div>
    @endif

<a name="redirecting-with-input"></a>
#### Redirigiendo Con Entrada

Puedes usar el método `withInput` proporcionado por la instancia de `RedirectResponse` para flashear los datos de entrada de la solicitud actual a la sesión antes de redirigir al usuario a una nueva ubicación. Esto se hace típicamente si el usuario ha encontrado un error de validación. Una vez que la entrada ha sido flasheada a la sesión, puedes [recuperarla](/docs/{{version}}/requests#retrieving-old-input) fácilmente durante la siguiente solicitud para repoblar el formulario:

    return back()->withInput();

<a name="other-response-types"></a>
## Otros Tipos de Respuesta

El helper `response` puede ser utilizado para generar otros tipos de instancias de respuesta. Cuando se llama al helper `response` sin argumentos, se devuelve una implementación del contrato `Illuminate\Contracts\Routing\ResponseFactory` [contract](/docs/{{version}}/contracts). Este contrato proporciona varios métodos útiles para generar respuestas.

<a name="view-responses"></a>
### Respuestas de Vista

Si necesitas control sobre el estado y los encabezados de la respuesta pero también necesitas devolver una [vista](/docs/{{version}}/views) como el contenido de la respuesta, debes usar el método `view`:

    return response()
                ->view('hello', $data, 200)
                ->header('Content-Type', $type);

Por supuesto, si no necesitas pasar un código de estado HTTP personalizado o encabezados personalizados, puedes usar la función helper global `view`.

<a name="json-responses"></a>
### Respuestas JSON

El método `json` establecerá automáticamente el encabezado `Content-Type` en `application/json`, así como convertir el arreglo dado a JSON usando la función PHP `json_encode`:

    return response()->json([
        'name' => 'Abigail',
        'state' => 'CA',
    ]);

Si deseas crear una respuesta JSONP, puedes usar el método `json` en combinación con el método `withCallback`:

    return response()
                ->json(['name' => 'Abigail', 'state' => 'CA'])
                ->withCallback($request->input('callback'));

<a name="file-downloads"></a>
### Descargas de Archivos

El método `download` puede ser utilizado para generar una respuesta que fuerce al navegador del usuario a descargar el archivo en la ruta dada. El método `download` acepta un nombre de archivo como el segundo argumento al método, que determinará el nombre de archivo que verá el usuario al descargar el archivo. Finalmente, puedes pasar un arreglo de encabezados HTTP como el tercer argumento al método:

    return response()->download($pathToFile);

    return response()->download($pathToFile, $name, $headers);

> [!WARNING]  
> Symfony HttpFoundation, que gestiona las descargas de archivos, requiere que el archivo que se está descargando tenga un nombre de archivo ASCII.

<a name="streamed-downloads"></a>
#### Descargas Transmitidas

A veces puedes desear convertir la respuesta de cadena de una operación dada en una respuesta descargable sin tener que escribir el contenido de la operación en el disco. Puedes usar el método `streamDownload` en este escenario. Este método acepta un callback, un nombre de archivo y un arreglo opcional de encabezados como sus argumentos:

    use App\Services\GitHub;

    return response()->streamDownload(function () {
        echo GitHub::api('repo')
                    ->contents()
                    ->readme('laravel', 'laravel')['contents'];
    }, 'laravel-readme.md');

<a name="file-responses"></a>
### Respuestas de Archivos

El método `file` puede ser utilizado para mostrar un archivo, como una imagen o PDF, directamente en el navegador del usuario en lugar de iniciar una descarga. Este método acepta la ruta absoluta al archivo como su primer argumento y un arreglo de encabezados como su segundo argumento:

    return response()->file($pathToFile);

    return response()->file($pathToFile, $headers);

<a name="response-macros"></a>
## Macros de Respuesta

Si deseas definir una respuesta personalizada que puedas reutilizar en varias de tus rutas y controladores, puedes usar el método `macro` en la fachada `Response`. Típicamente, debes llamar a este método desde el método `boot` de uno de los [proveedores de servicios](/docs/{{version}}/providers) de tu aplicación, como el proveedor de servicios `App\Providers\AppServiceProvider`:

```php
    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\Response;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Bootstrap any application services.
         */
        public function boot(): void
        {
            Response::macro('caps', function (string $value) {
                return Response::make(strtoupper($value));
            });
        }
    }

La función `macro` acepta un nombre como su primer argumento y una función anónima como su segundo argumento. La función anónima de la macro se ejecutará al llamar al nombre de la macro desde una implementación de `ResponseFactory` o el helper `response`:

    return response()->caps('foo');
```
