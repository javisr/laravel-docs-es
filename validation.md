# Validación

- [Introducción](#introduction)
- [Inicio Rápido de Validación](#validation-quickstart)
  - [Definiendo las Rutas](#quick-defining-the-routes)
  - [Creando el Controlador](#quick-creating-the-controller)
  - [Escribiendo la Lógica de Validación](#quick-writing-the-validation-logic)
  - [Mostrando los Errores de Validación](#quick-displaying-the-validation-errors)
  - [Repoblando Formularios](#repopulating-forms)
  - [Una Nota sobre Campos Opcionales](#a-note-on-optional-fields)
  - [Formato de Respuesta de Error de Validación](#validation-error-response-format)
- [Validación de Solicitudes de Formulario](#form-request-validation)
  - [Creando Solicitudes de Formulario](#creating-form-requests)
  - [Autorizando Solicitudes de Formulario](#authorizing-form-requests)
  - [Personalizando los Mensajes de Error](#customizing-the-error-messages)
  - [Preparando la Entrada para Validación](#preparing-input-for-validation)
- [Creando Validadores Manualmente](#manually-creating-validators)
  - [Redirección Automática](#automatic-redirection)
  - [Bolsas de Error Nombradas](#named-error-bags)
  - [Personalizando los Mensajes de Error](#manual-customizing-the-error-messages)
  - [Realizando Validación Adicional](#performing-additional-validation)
- [Trabajando con Entrada Validada](#working-with-validated-input)
- [Trabajando con Mensajes de Error](#working-with-error-messages)
  - [Especificando Mensajes Personalizados en Archivos de Idioma](#specifying-custom-messages-in-language-files)
  - [Especificando Atributos en Archivos de Idioma](#specifying-attribute-in-language-files)
  - [Especificando Valores en Archivos de Idioma](#specifying-values-in-language-files)
- [Reglas de Validación Disponibles](#available-validation-rules)
- [Agregando Reglas Condicionalmente](#conditionally-adding-rules)
- [Validando Arrays](#validating-arrays)
  - [Validando Entrada de Array Anidado](#validating-nested-array-input)
  - [Índices y Posiciones de Mensajes de Error](#error-message-indexes-and-positions)
- [Validando Archivos](#validating-files)
- [Validando Contraseñas](#validating-passwords)
- [Reglas de Validación Personalizadas](#custom-validation-rules)
  - [Usando Objetos de Regla](#using-rule-objects)
  - [Usando Funciones Anónimas](#using-closures)
  - [Reglas Implícitas](#implicit-rules)

<a name="introduction"></a>
## Introducción

Laravel ofrece varias formas diferentes de validar los datos entrantes de tu aplicación. Lo más común es usar el método `validate` disponible en todas las solicitudes HTTP entrantes. Sin embargo, también discutiremos otros enfoques para la validación.
Laravel incluye una amplia variedad de reglas de validación convenientes que puedes aplicar a los datos, incluso proporcionando la capacidad de validar si los valores son únicos en una tabla de base de datos dada. Cubriremos cada una de estas reglas de validación en detalle para que estés familiarizado con todas las características de validación de Laravel.

<a name="validation-quickstart"></a>
## Inicio Rápido de Validación

Para aprender sobre las potentes características de validación de Laravel, veamos un ejemplo completo de validación de un formulario y la visualización de los mensajes de error de vuelta al usuario. Al leer esta visión general, podrás obtener una buena comprensión general de cómo validar los datos de solicitud entrantes utilizando Laravel:

<a name="quick-defining-the-routes"></a>
### Definiendo las Rutas

Primero, asumamos que tenemos las siguientes rutas definidas en nuestro archivo `routes/web.php`:


```php
use App\Http\Controllers\PostController;

Route::get('/post/create', [PostController::class, 'create']);
Route::post('/post', [PostController::class, 'store']);
```
La ruta `GET` mostrará un formulario para que el usuario cree una nueva entrada de blog, mientras que la ruta `POST` almacenará la nueva entrada de blog en la base de datos.

<a name="quick-creating-the-controller"></a>
### Creando el Controlador

A continuación, echemos un vistazo a un controlador simple que maneja las solicitudes entrantes a estas rutas. Dejaremos el método `store` vacío por ahora:


```
<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PostController extends Controller
{
    /**
     * Show the form to create a new blog post.
     */
    public function create(): View
    {
        return view('post.create');
    }

    /**
     * Store a new blog post.
     */
    public function store(Request $request): RedirectResponse
    {
        // Validate and store the blog post...

        $post = /** ... */

        return to_route('post.show', ['post' => $post->id]);
    }
}
```

<a name="quick-writing-the-validation-logic"></a>
### Escribiendo la Lógica de Validación

Ahora estamos listos para llenar nuestro método `store` con la lógica para validar la nueva entrada del blog. Para hacer esto, utilizaremos el método `validate` proporcionado por el objeto `Illuminate\Http\Request`. Si las reglas de validación pasan, tu código continuará ejecutándose normalmente; sin embargo, si la validación falla, se lanzará una excepción `Illuminate\Validation\ValidationException` y se enviará automáticamente la respuesta de error adecuada al usuario.
Si la validación falla durante una solicitud HTTP tradicional, se generará una respuesta de redirección a la URL anterior. Si la solicitud entrante es una solicitud XHR, se devolverá una [respuesta JSON que contiene los mensajes de error de validación](#validation-error-response-format).
Para obtener una mejor comprensión del método `validate`, volvamos al método `store`:


```php
/**
 * Store a new blog post.
 */
public function store(Request $request): RedirectResponse
{
    $validated = $request->validate([
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
    ]);

    // The blog post is valid...

    return redirect('/posts');
}
```
Como puedes ver, las reglas de validación se pasan al método `validate`. No te preocupes: todas las reglas de validación disponibles están [documentadas](#available-validation-rules). Nuevamente, si la validación falla, la respuesta adecuada se generará automáticamente. Si la validación pasa, nuestro controlador continuará ejecutándose de manera normal.
Alternativamente, las reglas de validación pueden especificarse como arreglos de reglas en lugar de una sola cadena delimitada por `|`:


```php
$validatedData = $request->validate([
    'title' => ['required', 'unique:posts', 'max:255'],
    'body' => ['required'],
]);
```
Además, puedes usar el método `validateWithBag` para validar una solicitud y almacenar cualquier mensaje de error dentro de un [saco de errores nombrado](#named-error-bags):


```php
$validatedData = $request->validateWithBag('post', [
    'title' => ['required', 'unique:posts', 'max:255'],
    'body' => ['required'],
]);
```

<a name="stopping-on-first-validation-failure"></a>
A veces es posible que desees detener la ejecución de las reglas de validación en un atributo después del primer fallo de validación. Para hacerlo, asigna la regla `bail` al atributo:


```php
$request->validate([
    'title' => 'bail|required|unique:posts|max:255',
    'body' => 'required',
]);
```
En este ejemplo, si la regla `unique` en el atributo `title` falla, la regla `max` no será verificada. Las reglas se validarán en el orden en que se asignan.

<a name="a-note-on-nested-attributes"></a>
#### Una Nota sobre Atributos Anidados

Si la solicitud HTTP entrante contiene datos de campo "anidados", puedes especificar estos campos en tus reglas de validación utilizando la sintaxis de "punto":


```php
$request->validate([
    'title' => 'required|unique:posts|max:255',
    'author.name' => 'required',
    'author.description' => 'required',
]);
```
Por otro lado, si el nombre de tu campo contiene un punto literal, puedes prevenir explícitamente que esto se interprete como sintaxis de "punto" escapando el punto con una barra invertida:


```php
$request->validate([
    'title' => 'required|unique:posts|max:255',
    'v1\.0' => 'required',
]);
```

<a name="quick-displaying-the-validation-errors"></a>
### Mostrando los Errores de Validación

Entonces, ¿qué sucede si los campos de la solicitud entrante no pasan las reglas de validación dadas? Como se mencionó anteriormente, Laravel redirigirá automáticamente al usuario de vuelta a su ubicación anterior. Además, todos los errores de validación y [la entrada de la solicitud](/docs/%7B%7Bversion%7D%7D/requests#retrieving-old-input) se [flashearán automáticamente a la sesión](/docs/%7B%7Bversion%7D%7D/session#flash-data).
Una variable `$errors` se comparte con todas las vistas de tu aplicación mediante el middleware `Illuminate\View\Middleware\ShareErrorsFromSession`, que es proporcionado por el grupo de middleware `web`. Cuando se aplica este middleware, una variable `$errors` siempre estará disponible en tus vistas, lo que te permite suponer cómodamente que la variable `$errors` siempre está definida y se puede usar de manera segura. La variable `$errors` será una instancia de `Illuminate\Support\MessageBag`. Para obtener más información sobre cómo trabajar con este objeto, [consulta su documentación](#working-with-error-messages).
Entonces, en nuestro ejemplo, el usuario será redirigido al método `create` de nuestro controlador cuando la validación falle, lo que nos permitirá mostrar los mensajes de error en la vista:


```blade
<!-- /resources/views/post/create.blade.php -->

<h1>Create Post</h1>

@if ($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif

<!-- Create Post Form -->

```

<a name="quick-customizing-the-error-messages"></a>
#### Personalizando los Mensajes de Error


<a name="quick-xhr-requests-and-validation"></a>
#### Solicitudes XHR y Validación

En este ejemplo, usamos un formulario tradicional para enviar datos a la aplicación. Sin embargo, muchas aplicaciones reciben solicitudes XHR de un frontend potenciado por JavaScript. Al usar el método `validate` durante una solicitud XHR, Laravel no generará una respuesta de redirección. En su lugar, Laravel genera una [respuesta JSON que contiene todos los errores de validación](#validation-error-response-format). Esta respuesta JSON se enviará con un código de estado HTTP 422.

<a name="the-at-error-directive"></a>
#### La Directiva `@error`

Puedes usar la directiva `@error` [Blade](/docs/%7B%7Bversion%7D%7D/blade) para determinar rápidamente si existen mensajes de error de validación para un atributo dado. Dentro de una directiva `@error`, puedes mostrar la variable `$message` para mostrar el mensaje de error:


```blade
<!-- /resources/views/post/create.blade.php -->

<label for="title">Post Title</label>

<input id="title"
    type="text"
    name="title"
    class="@error('title') is-invalid @enderror">

@error('title')
    <div class="alert alert-danger">{{ $message }}</div>
@enderror

```
Si estás utilizando [bandas de errores nombradas](#named-error-bags), puedes pasar el nombre de la banda de errores como segundo argumento a la directiva `@error`:


```blade
<input ... class="@error('title', 'post') is-invalid @enderror">

```

<a name="repopulating-forms"></a>
### Rellenando Formularios

Cuando Laravel genera una respuesta de redirección debido a un error de validación, el framework automáticamente [flashea toda la entrada de la solicitud a la sesión](/docs/%7B%7Bversion%7D%7D/session#flash-data). Esto se hace para que puedas acceder a la entrada de manera conveniente durante la siguiente solicitud y volver a llenar el formulario que el usuario intentó enviar.
Para recuperar la entrada pasada del request anterior, invoca el método `old` en una instancia de `Illuminate\Http\Request`. El método `old` extraerá los datos de entrada que se enviaron previamente desde la [sesión](/docs/%7B%7Bversion%7D%7D/session):


```php
$title = $request->old('title');
```
Laravel también proporciona un helper global `old`. Si estás mostrando entrada anterior dentro de una [plantilla Blade](/docs/%7B%7Bversion%7D%7D/blade), es más conveniente usar el helper `old` para rellenar de nuevo el formulario. Si no existe entrada anterior para el campo dado, se devolverá `null`:


```blade
<input type="text" name="title" value="{{ old('title') }}">

```

<a name="a-note-on-optional-fields"></a>
### Una Nota sobre Campos Opcionales

Por defecto, Laravel incluye el middleware `TrimStrings` y `ConvertEmptyStringsToNull` en la pila de middleware global de tu aplicación. Debido a esto, a menudo necesitarás marcar tus campos de solicitud "opcionales" como `nullable` si no deseas que el validador considere los valores `null` como inválidos. Por ejemplo:


```php
$request->validate([
    'title' => 'required|unique:posts|max:255',
    'body' => 'required',
    'publish_at' => 'nullable|date',
]);
```
En este ejemplo, estamos especificando que el campo `publish_at` puede ser `null` o una representación de fecha válida. Si el modificador `nullable` no se añade a la definición de la regla, el validador consideraría `null` como una fecha inválida.

<a name="validation-error-response-format"></a>
### Formato de respuesta de error de validación

Cuando tu aplicación lanza una excepción `Illuminate\Validation\ValidationException` y la solicitud HTTP entrante espera una respuesta JSON, Laravel formateará automáticamente los mensajes de error por ti y devolverá una respuesta HTTP `422 Unprocessable Entity`.
A continuación, puedes revisar un ejemplo del formato de respuesta JSON para errores de validación. Ten en cuenta que las claves de error anidadas se simplifican en formato de "notación de punto":


```json
{
    "message": "The team name must be a string. (and 4 more errors)",
    "errors": {
        "team_name": [
            "The team name must be a string.",
            "The team name must be at least 1 characters."
        ],
        "authorization.role": [
            "The selected authorization.role is invalid."
        ],
        "users.0.email": [
            "The users.0.email field is required."
        ],
        "users.2.email": [
            "The users.2.email must be a valid email address."
        ]
    }
}

```

<a name="form-request-validation"></a>
## Validación de Solicitudes de Formulario


<a name="creating-form-requests"></a>
### Creando Solicitudes de Formulario

Para escenarios de validación más complejos, es posible que desees crear una "solicitud de formulario". Las solicitudes de formulario son clases de solicitud personalizadas que encapsulan su propia lógica de validación y autorización. Para crear una clase de solicitud de formulario, puedes usar el comando CLI Artisan `make:request`:


```shell
php artisan make:request StorePostRequest

```
La clase de solicitud de formulario generada se colocará en el directorio `app/Http/Requests`. Si este directorio no existe, se creará cuando ejecutes el comando `make:request`. Cada solicitud de formulario generada por Laravel tiene dos métodos: `authorize` y `rules`.
Como puedes suponer, el método `authorize` es responsable de determinar si el usuario autenticado actualmente puede realizar la acción representada por la solicitud, mientras que el método `rules` devuelve las reglas de validación que deben aplicarse a los datos de la solicitud:


```php
/**
 * Get the validation rules that apply to the request.
 *
 * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
 */
public function rules(): array
{
    return [
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
    ];
}
```
> [!NOTA]
Puedes indicar cualquier dependencia que necesites dentro de la firma del método `rules`. Se resolverán automáticamente a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel.
Entonces, ¿cómo se evalúan las reglas de validación? Todo lo que necesitas hacer es indicar el tipo de la solicitud en el método de tu controlador. La solicitud del formulario entrante se valida antes de que se llame al método del controlador, lo que significa que no necesitas saturar tu controlador con ninguna lógica de validación:


```php
/**
 * Store a new blog post.
 */
public function store(StorePostRequest $request): RedirectResponse
{
    // The incoming request is valid...

    // Retrieve the validated input data...
    $validated = $request->validated();

    // Retrieve a portion of the validated input data...
    $validated = $request->safe()->only(['name', 'email']);
    $validated = $request->safe()->except(['name', 'email']);

    // Store the blog post...

    return redirect('/posts');
}
```
Si la validación falla, se generará una respuesta de redirección para enviar al usuario de vuelta a su ubicación anterior. Los errores también se guardarán en la sesión para que estén disponibles para su visualización. Si la solicitud fue una solicitud XHR, se devolverá una respuesta HTTP con un código de estado 422 al usuario, incluyendo una [representación JSON de los errores de validación](#validation-error-response-format).
> [!NOTA]
¿Necesitas añadir validación de solicitudes de formulario en tiempo real a tu frontend Laravel impulsado por Inertia? Echa un vistazo a [Laravel Precognition](/docs/%7B%7Bversion%7D%7D/precognition).

<a name="performing-additional-validation-on-form-requests"></a>
#### Realizando Validación Adicional

A veces necesitas realizar validaciones adicionales después de que tu validación inicial se haya completado. Puedes lograr esto utilizando el método `after` de la solicitud del formulario.
El método `after` debería devolver un array de llamadas o funciones anónimas que se invocarán una vez que la validación esté completa. Las llamadas dadas recibirán una instancia de `Illuminate\Validation\Validator`, lo que te permitirá agregar mensajes de error adicionales si es necesario:


```php
use Illuminate\Validation\Validator;

/**
 * Get the "after" validation callables for the request.
 */
public function after(): array
{
    return [
        function (Validator $validator) {
            if ($this->somethingElseIsInvalid()) {
                $validator->errors()->add(
                    'field',
                    'Something is wrong with this field!'
                );
            }
        }
    ];
}
```
Como se mencionó, el array devuelto por el método `after` también puede contener clases invocables. El método `__invoke` de estas clases recibirá una instancia de `Illuminate\Validation\Validator`:


```php
use App\Validation\ValidateShippingTime;
use App\Validation\ValidateUserStatus;
use Illuminate\Validation\Validator;

/**
 * Get the "after" validation callables for the request.
 */
public function after(): array
{
    return [
        new ValidateUserStatus,
        new ValidateShippingTime,
        function (Validator $validator) {
            //
        }
    ];
}

```

<a name="request-stopping-on-first-validation-rule-failure"></a>
#### Deteniéndose en el Primer Fallo de Validación

Al agregar una propiedad `stopOnFirstFailure` a tu clase de solicitud, puedes informar al validador que debe dejar de validar todos los atributos una vez que haya ocurrido un solo fallo de validación:


```php
/**
 * Indicates if the validator should stop on the first rule failure.
 *
 * @var bool
 */
protected $stopOnFirstFailure = true;
```

<a name="customizing-the-redirect-location"></a>
#### Personalizando la Ubicación de Redirección

Como se discutió anteriormente, se generará una respuesta de redirección para enviar al usuario de vuelta a su ubicación anterior cuando falle la validación de la solicitud del formulario. Sin embargo, puedes personalizar este comportamiento. Para hacerlo, define una propiedad `$redirect` en tu solicitud de formulario:


```php
/**
 * The URI that users should be redirected to if validation fails.
 *
 * @var string
 */
protected $redirect = '/dashboard';
```
O, si deseas redirigir a los usuarios a una ruta nombrada, puedes definir una propiedad `$redirectRoute` en su lugar:


```php
/**
 * The route that users should be redirected to if validation fails.
 *
 * @var string
 */
protected $redirectRoute = 'dashboard';
```

<a name="authorizing-form-requests"></a>
### Autorizando Solicitudes de Formulario

La clase de solicitud del formulario también contiene un método `authorize`. Dentro de este método, puedes determinar si el usuario autenticado tiene realmente la autoridad para actualizar un recurso dado. Por ejemplo, puedes determinar si un usuario realmente posee un comentario de blog que está intentando actualizar. Lo más probable es que interactúes con tus [puertas y políticas de autorización](/docs/%7B%7Bversion%7D%7D/authorization) dentro de este método:


```php
use App\Models\Comment;

/**
 * Determine if the user is authorized to make this request.
 */
public function authorize(): bool
{
    $comment = Comment::find($this->route('comment'));

    return $comment && $this->user()->can('update', $comment);
}
```
Dado que todas las solicitudes de formularios extienden la clase de solicitud base de Laravel, podemos usar el método `user` para acceder al usuario autenticado actualmente. Además, nota la llamada al método `route` en el ejemplo anterior. Este método te otorga acceso a los parámetros URI definidos en la ruta que se está llamando, como el parámetro `{comment}` en el ejemplo a continuación:


```php
Route::post('/comment/{comment}');
```
Por lo tanto, si tu aplicación está aprovechando el [enlace de modelo de ruta](/docs/%7B%7Bversion%7D%7D/routing#route-model-binding), tu código puede ser aún más conciso accediendo al modelo resuelto como una propiedad de la solicitud:


```php
return $this->user()->can('update', $this->comment);
```
Si el método `authorize` devuelve `false`, se devolverá automáticamente una respuesta HTTP con un código de estado 403 y tu método del controlador no se ejecutará.
Si planeas manejar la lógica de autorización para la solicitud en otra parte de tu aplicación, puedes eliminar el método `authorize` por completo, o simplemente devolver `true`:


```php
/**
 * Determine if the user is authorized to make this request.
 */
public function authorize(): bool
{
    return true;
}
```
> [!NOTE]
Puedes indicar cualquier dependencia que necesites dentro de la firma del método `authorize`. Se resolverán automáticamente a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel.

<a name="customizing-the-error-messages"></a>
Puedes personalizar los mensajes de error utilizados por la solicitud de formulario sobrescribiendo el método `messages`. Este método debe devolver un array de pares atributo / regla y sus mensajes de error correspondientes:


```php
/**
 * Get the error messages for the defined validation rules.
 *
 * @return array<string, string>
 */
public function messages(): array
{
    return [
        'title.required' => 'A title is required',
        'body.required' => 'A message is required',
    ];
}
```

<a name="customizing-the-validation-attributes"></a>
#### Personalizando los Atributos de Validación

Muchos de los mensajes de error de reglas de validación integradas de Laravel contienen un marcador de posición `:attribute`. Si deseas que el marcador de posición `:attribute` de tu mensaje de validación sea reemplazado por un nombre de atributo personalizado, puedes especificar los nombres personalizados sobrescribiendo el método `attributes`. Este método debe devolver un array de pares atributo / nombre:


```php
/**
 * Get custom attributes for validator errors.
 *
 * @return array<string, string>
 */
public function attributes(): array
{
    return [
        'email' => 'email address',
    ];
}
```

<a name="preparing-input-for-validation"></a>
### Preparando la Entrada para la Validación

Si necesitas preparar o sanear cualquier dato de la solicitud antes de aplicar tus reglas de validación, puedes usar el método `prepareForValidation`:


```php
use Illuminate\Support\Str;

/**
 * Prepare the data for validation.
 */
protected function prepareForValidation(): void
{
    $this->merge([
        'slug' => Str::slug($this->slug),
    ]);
}
```
Del mismo modo, si necesitas normalizar cualquier dato de solicitud después de que la validación esté completa, puedes usar el método `passedValidation`:


```php
/**
 * Handle a passed validation attempt.
 */
protected function passedValidation(): void
{
    $this->replace(['name' => 'Taylor']);
}
```

<a name="manually-creating-validators"></a>
## Creando Validadores Manualmente

Si no deseas usar el método `validate` en la solicitud, puedes crear una instancia de validador manualmente utilizando la `facade` [Validator](/docs/%7B%7Bversion%7D%7D/facades). El método `make` en la facade genera una nueva instancia de validador:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PostController extends Controller
{
    /**
     * Store a new blog post.
     */
    public function store(Request $request): RedirectResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|unique:posts|max:255',
            'body' => 'required',
        ]);

        if ($validator->fails()) {
            return redirect('/post/create')
                        ->withErrors($validator)
                        ->withInput();
        }

        // Retrieve the validated input...
        $validated = $validator->validated();

        // Retrieve a portion of the validated input...
        $validated = $validator->safe()->only(['name', 'email']);
        $validated = $validator->safe()->except(['name', 'email']);

        // Store the blog post...

        return redirect('/posts');
    }
}
```
El primer argumento pasado al método `make` es los datos bajo validación. El segundo argumento es un array de las reglas de validación que se deben aplicar a los datos.
Después de determinar si la validación de la solicitud ha fallado, puedes usar el método `withErrors` para almacenar los mensajes de error en la sesión. Al usar este método, la variable `$errors` se compartirá automáticamente con tus vistas después de la redirección, lo que te permitirá mostrarlas fácilmente al usuario. El método `withErrors` acepta un validador, un `MessageBag` o un `array` de PHP.
#### Detenerse en el Primer Error de Validación

El método `stopOnFirstFailure` informará al validador que debe dejar de validar todos los atributos una vez que haya ocurrido un solo fallo de validación:

<a name="automatic-redirection"></a>
### Redirección Automática

Si deseas crear una instancia de validador de forma manual pero aún aprovechar la redirección automática que ofrece el método `validate` de la solicitud HTTP, puedes llamar al método `validate` en una instancia de validador existente. Si la validación falla, el usuario será redirigido automáticamente o, en el caso de una solicitud XHR, se devolverá una [respuesta JSON](#validation-error-response-format):


```php
Validator::make($request->all(), [
    'title' => 'required|unique:posts|max:255',
    'body' => 'required',
])->validate();
```
Puedes usar el método `validateWithBag` para almacenar los mensajes de error en un [bolsa de errores nombrada](#named-error-bags) si la validación falla:


```php
Validator::make($request->all(), [
    'title' => 'required|unique:posts|max:255',
    'body' => 'required',
])->validateWithBag('post');
```

<a name="named-error-bags"></a>
### Bolsas de Errores Nombradas

Si tienes múltiples formularios en una sola página, es posible que desees nombrar el `MessageBag` que contiene los errores de validación, lo que te permitirá recuperar los mensajes de error para un formulario específico. Para lograr esto, pasa un nombre como segundo argumento a `withErrors`:


```php
return redirect('/register')->withErrors($validator, 'login');
```
Entonces puedes acceder a la instancia `MessageBag` nombrada desde la variable `$errors`:


```blade
{{ $errors->login->first('email') }}

```

<a name="manual-customizing-the-error-messages"></a>
### Personalizando los Mensajes de Error

Si es necesario, puedes proporcionar mensajes de error personalizados que una instancia de validador debería usar en lugar de los mensajes de error predeterminados proporcionados por Laravel. Hay varias formas de especificar mensajes personalizados. Primero, puedes pasar los mensajes personalizados como el tercer argumento al método `Validator::make`:


```php
$validator = Validator::make($input, $rules, $messages = [
    'required' => 'The :attribute field is required.',
]);
```
En este ejemplo, el marcador de posición `:attribute` será reemplazado por el nombre real del campo que se está validando. También puedes utilizar otros marcadores de posición en los mensajes de validación. Por ejemplo:


```php
$messages = [
    'same' => 'The :attribute and :other must match.',
    'size' => 'The :attribute must be exactly :size.',
    'between' => 'The :attribute value :input is not between :min - :max.',
    'in' => 'The :attribute must be one of the following types: :values',
];
```

<a name="specifying-a-custom-message-for-a-given-attribute"></a>
#### Especificando un Mensaje Personalizado para un Atributo Dado

A veces es posible que desees especificar un mensaje de error personalizado solo para un atributo específico. Puedes hacerlo utilizando la notación "punto". Especifica el nombre del atributo primero, seguido de la regla:


```php
$messages = [
    'email.required' => 'We need to know your email address!',
];
```

<a name="specifying-custom-attribute-values"></a>
#### Especificando Valores de Atributos Personalizados

Muchos de los mensajes de error incorporados de Laravel incluyen un marcador de posición `:attribute` que se reemplaza con el nombre del campo o atributo bajo validación. Para personalizar los valores utilizados para reemplazar estos marcadores de posición para campos específicos, puedes pasar un array de atributos personalizados como cuarto argumento al método `Validator::make`:


```php
$validator = Validator::make($input, $rules, $messages, [
    'email' => 'email address',
]);
```

<a name="performing-additional-validation"></a>
### Realizando Validaciones Adicionales

A veces necesitas realizar validaciones adicionales después de que tu validación inicial esté completa. Puedes lograr esto utilizando el método `after` del validador. El método `after` acepta una función anónima o un array de funciones invocables que se llamarán después de que la validación esté completa. Los callable dados recibirán una instancia de `Illuminate\Validation\Validator`, lo que te permitirá generar mensajes de error adicionales si es necesario:


```php
use Illuminate\Support\Facades\Validator;

$validator = Validator::make(/* ... */);

$validator->after(function ($validator) {
    if ($this->somethingElseIsInvalid()) {
        $validator->errors()->add(
            'field', 'Something is wrong with this field!'
        );
    }
});

if ($validator->fails()) {
    // ...
}
```
Como se mencionó, el método `after` también acepta un array de callable, lo cual es particularmente conveniente si tu lógica de "validación posterior" está encapsulada en clases invocables, que recibirán una instancia de `Illuminate\Validation\Validator` a través de su método `__invoke`:


```php
use App\Validation\ValidateShippingTime;
use App\Validation\ValidateUserStatus;

$validator->after([
    new ValidateUserStatus,
    new ValidateShippingTime,
    function ($validator) {
        // ...
    },
]);

```

<a name="working-with-validated-input"></a>
## Trabajando con Entrada Validada

Después de validar los datos de solicitud entrantes utilizando una solicitud de formulario o una instancia de validador creada manualmente, es posible que desees recuperar los datos de solicitud entrantes que realmente fueron validados. Esto se puede lograr de varias maneras. Primero, puedes llamar al método `validated` en una solicitud de formulario o en una instancia de validador. Este método devuelve un array de los datos que fueron validados:


```php
$validated = $request->validated();

$validated = $validator->validated();
```
Alternativamente, puedes llamar al método `safe` en una instancia de solicitud de formulario o validador. Este método devuelve una instancia de `Illuminate\Support\ValidatedInput`. Este objeto expone métodos `only`, `except` y `all` para recuperar un subconjunto de los datos validados o el array completo de datos validados:


```php
$validated = $request->safe()->only(['name', 'email']);

$validated = $request->safe()->except(['name', 'email']);

$validated = $request->safe()->all();
```
Además, la instancia `Illuminate\Support\ValidatedInput` se puede iterar y acceder como un array:


```php
// Validated data may be iterated...
foreach ($request->safe() as $key => $value) {
    // ...
}

// Validated data may be accessed as an array...
$validated = $request->safe();

$email = $validated['email'];
```
Si deseas añadir campos adicionales a los datos validados, puedes llamar al método `merge`:


```php
$validated = $request->safe()->merge(['name' => 'Taylor Otwell']);
```
Si deseas recuperar los datos validados como una instancia de [colección](/docs/%7B%7Bversion%7D%7D/collections), puedes llamar al método `collect`:


```php
$collection = $request->safe()->collect();
```

<a name="working-with-error-messages"></a>
## Trabajando con Mensajes de Error

Después de llamar al método `errors` en una instancia de `Validator`, recibirás una instancia de `Illuminate\Support\MessageBag`, que tiene una variedad de métodos convenientes para trabajar con mensajes de error. La variable `$errors` que se pone automáticamente a disposición de todas las vistas también es una instancia de la clase `MessageBag`.

<a name="retrieving-the-first-error-message-for-a-field"></a>
#### Recuperando el Primer Mensaje de Error para un Campo

Para recuperar el primer mensaje de error para un campo dado, utiliza el método `first`:


```php
$errors = $validator->errors();

echo $errors->first('email');
```

<a name="retrieving-all-error-messages-for-a-field"></a>
#### Recuperando Todos los Mensajes de Error para un Campo

Si necesitas recuperar un array con todos los mensajes para un campo dado, utiliza el método `get`:


```php
foreach ($errors->get('email') as $message) {
    // ...
}
```
Si estás validando un campo de formulario de array, puedes recuperar todos los mensajes para cada uno de los elementos del array usando el carácter `*`:


```php
foreach ($errors->get('attachments.*') as $message) {
    // ...
}
```

<a name="retrieving-all-error-messages-for-all-fields"></a>
#### Recuperando Todos los Mensajes de Error para Todos los Campos

Para recuperar un array de todos los mensajes para todos los campos, utiliza el método `all`:


```php
foreach ($errors->all() as $message) {
    // ...
}
```

<a name="determining-if-messages-exist-for-a-field"></a>
#### Determinando si Existen Mensajes para un Campo

El método `has` se puede utilizar para determinar si existen mensajes de error para un campo dado:


```php
if ($errors->has('email')) {
    // ...
}
```

<a name="specifying-custom-messages-in-language-files"></a>
### Especificando Mensajes Personalizados en Archivos de Idioma

Las reglas de validación integradas de Laravel tienen cada una un mensaje de error que se encuentra en el archivo `lang/en/validation.php` de tu aplicación. Si tu aplicación no tiene un directorio `lang`, puedes instruir a Laravel para que lo cree utilizando el comando Artisan `lang:publish`.
Dentro del archivo `lang/en/validation.php`, encontrarás una entrada de traducción para cada regla de validación. Puedes cambiar o modificar estos mensajes según las necesidades de tu aplicación.
Además, puedes copiar este archivo a otro directorio de idioma para traducir los mensajes para el idioma de tu aplicación. Para obtener más información sobre la localización de Laravel, consulta la [documentación completa de localización](/docs/%7B%7Bversion%7D%7D/localization).

<a name="custom-messages-for-specific-attributes"></a>
#### Mensajes Personalizados para Atributos Específicos

Puedes personalizar los mensajes de error utilizados para combinaciones específicas de atributo y regla dentro de los archivos de idioma de validación de tu aplicación. Para hacerlo, añade tus personalizaciones de mensajes al array `custom` del archivo de idioma `lang/xx/validation.php` de tu aplicación:


```php
'custom' => [
    'email' => [
        'required' => 'We need to know your email address!',
        'max' => 'Your email address is too long!'
    ],
],
```

<a name="specifying-attribute-in-language-files"></a>
### Especificando Atributos en Archivos de Idioma

Muchos de los mensajes de error integrados de Laravel incluyen un marcador de posición `:attribute` que se reemplaza con el nombre del campo o atributo bajo validación. Si deseas que la porción `:attribute` de tu mensaje de validación sea reemplazada por un valor personalizado, puedes especificar el nombre del atributo personalizado en el array `attributes` de tu archivo de idioma `lang/xx/validation.php`:


```php
'attributes' => [
    'email' => 'email address',
],
```

<a name="specifying-values-in-language-files"></a>
### Especificando Valores en Archivos de Idioma

Algunos de los mensajes de error de las reglas de validación integradas de Laravel contienen un marcador de posición `:value` que se reemplaza con el valor actual del atributo de la solicitud. Sin embargo, es posible que ocasionalmente necesites que la parte `:value` de tu mensaje de validación se reemplace con una representación personalizada del valor. Por ejemplo, considera la siguiente regla que especifica que se requiere un número de tarjeta de crédito si el `payment_type` tiene un valor de `cc`:


```php
Validator::make($request->all(), [
    'credit_card_number' => 'required_if:payment_type,cc'
]);
```
Si esta regla de validación falla, producirá el siguiente mensaje de error:


```none
The credit card number field is required when payment type is cc.

```
En lugar de mostrar `cc` como el valor del tipo de pago, puedes especificar una representación de valor más amigable para el usuario en tu archivo de idioma `lang/xx/validation.php` definiendo un array `values`:


```php
'values' => [
    'payment_type' => [
        'cc' => 'credit card'
    ],
],
```
> [!WARNING]
Por defecto, el esqueleto de la aplicación Laravel no incluye el directorio `lang`. Si deseas personalizar los archivos de idioma de Laravel, puedes publicarlos mediante el comando Artisan `lang:publish`.
Después de definir este valor, la regla de validación producirá el siguiente mensaje de error:


```none
The credit card number field is required when payment type is credit card.

```

<a name="available-validation-rules"></a>
## Reglas de Validación Disponibles

A continuación, se muestra una lista de todas las reglas de validación disponibles y su función:
<style>
    .collection-method-list > p {
        columns: 10.8em 3; -moz-columns: 10.8em 3; -webkit-columns: 10.8em 3;
    }

    .collection-method-list a {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
</style>
<div class="collection-method-list" markdown="1">

[Accepted](#rule-accepted)
[Accepted If](#rule-accepted-if)
[Active URL](#rule-active-url)
[After (Date)](#rule-after)
[After Or Equal (Date)](#rule-after-or-equal)
[Alpha](#rule-alpha)
[Alpha Dash](#rule-alpha-dash)
[Alpha Numeric](#rule-alpha-num)
[Array](#rule-array)
[Ascii](#rule-ascii)
[Bail](#rule-bail)
[Before (Date)](#rule-before)
[Before Or Equal (Date)](#rule-before-or-equal)
[Between](#rule-between)
[Boolean](#rule-boolean)
[Confirmed](#rule-confirmed)
[Contains](#rule-contains)
[Current Password](#rule-current-password)
[Date](#rule-date)
[Date Equals](#rule-date-equals)
[Date Format](#rule-date-format)
[Decimal](#rule-decimal)
[Declined](#rule-declined)
[Declined If](#rule-declined-if)
[Different](#rule-different)
[Digits](#rule-digits)
[Digits Between](#rule-digits-between)
[Dimensions (Image Files)](#rule-dimensions)
[Distinct](#rule-distinct)
[Doesnt Start With](#rule-doesnt-start-with)
[Doesnt End With](#rule-doesnt-end-with)
[Email](#rule-email)
[Ends With](#rule-ends-with)
[Enum](#rule-enum)
[Exclude](#rule-exclude)
[Exclude If](#rule-exclude-if)
[Exclude Unless](#rule-exclude-unless)
[Exclude With](#rule-exclude-with)
[Exclude Without](#rule-exclude-without)
[Exists (Database)](#rule-exists)
[Extensions](#rule-extensions)
[File](#rule-file)
[Filled](#rule-filled)
[Greater Than](#rule-gt)
[Greater Than Or Equal](#rule-gte)
[Hex Color](#rule-hex-color)
[Image (File)](#rule-image)
[In](#rule-in)
[In Array](#rule-in-array)
[Integer](#rule-integer)
[IP Address](#rule-ip)
[JSON](#rule-json)
[Less Than](#rule-lt)
[Less Than Or Equal](#rule-lte)
[List](#rule-list)
[Lowercase](#rule-lowercase)
[MAC Address](#rule-mac)
[Max](#rule-max)
[Max Digits](#rule-max-digits)
[MIME Types](#rule-mimetypes)
[MIME Type By File Extension](#rule-mimes)
[Min](#rule-min)
[Min Digits](#rule-min-digits)
[Missing](#rule-missing)
[Missing If](#rule-missing-if)
[Missing Unless](#rule-missing-unless)
[Missing With](#rule-missing-with)
[Missing With All](#rule-missing-with-all)
[Multiple Of](#rule-multiple-of)
[Not In](#rule-not-in)
[Not Regex](#rule-not-regex)
[Nullable](#rule-nullable)
[Numeric](#rule-numeric)
[Present](#rule-present)
[Present If](#rule-present-if)
[Present Unless](#rule-present-unless)
[Present With](#rule-present-with)
[Present With All](#rule-present-with-all)
[Prohibited](#rule-prohibited)
[Prohibited If](#rule-prohibited-if)
[Prohibited Unless](#rule-prohibited-unless)
[Prohibits](#rule-prohibits)
[Regular Expression](#rule-regex)
[Required](#rule-required)
[Required If](#rule-required-if)
[Required If Accepted](#rule-required-if-accepted)
[Required If Declined](#rule-required-if-declined)
[Required Unless](#rule-required-unless)
[Required With](#rule-required-with)
[Required With All](#rule-required-with-all)
[Required Without](#rule-required-without)
[Required Without All](#rule-required-without-all)
[Required Array Keys](#rule-required-array-keys)
[Same](#rule-same)
[Size](#rule-size)
[Sometimes](#validating-when-present)
[Starts With](#rule-starts-with)
[String](#rule-string)
[Timezone](#rule-timezone)
[Unique (Database)](#rule-unique)
[Uppercase](#rule-uppercase)
[URL](#rule-url)
[ULID](#rule-ulid)
[UUID](#rule-uuid)

</div>

<a name="rule-accepted"></a>
#### aceptado

El campo bajo validación debe ser `"yes"`, `"on"`, `1`, `"1"`, `true` o `"true"`. Esto es útil para validar la aceptación de "Términos de Servicio" o campos similares.

<a name="rule-accepted-if"></a>
#### accepted_if:anotherfield,value,...

El campo bajo validación debe ser `"yes"`, `"on"`, `1`, `"1"`, `true` o `"true"` si otro campo bajo validación es igual a un valor especificado. Esto es útil para validar la aceptación de "Términos de Servicio" o campos similares.

<a name="rule-active-url"></a>
#### active_url

El campo bajo validación debe tener un registro A o AAAA válido según la función `dns_get_record` de PHP. El nombre de host de la URL proporcionada se extrae utilizando la función `parse_url` de PHP antes de ser pasado a `dns_get_record`.

<a name="rule-after"></a>
#### after:*date*

El campo bajo validación debe ser un valor después de una fecha dada. Las fechas se pasarán a la función `strtotime` de PHP para ser convertidas en una instancia válida de `DateTime`:


```php
'start_date' => 'required|date|after:tomorrow'
```
En lugar de pasar una cadena de fecha para que sea evaluada por `strtotime`, puedes especificar otro campo para comparar con la fecha:


```php
'finish_date' => 'required|date|after:start_date'
```

<a name="rule-after-or-equal"></a>
#### after_or_equal:*date*

El campo bajo validación debe ser un valor posterior o igual a la fecha dada. Para obtener más información, consulta la regla [after](#rule-after).

<a name="rule-alpha"></a>
#### alpha

El campo bajo validación debe contener exclusivamente caracteres alfabéticos Unicode en [`\p{L}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AL%3A%5D&g=&i=) y [`\p{M}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AM%3A%5D&g=&i=).


```php
'username' => 'alpha:ascii',

```

<a name="rule-alpha-dash"></a>
#### alpha_dash

El campo bajo validación debe contener únicamente caracteres alfanuméricos Unicode, que incluyen [`\p{L}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AL%3A%5D&g=&i=), [`\p{M}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AM%3A%5D&g=&i=), [`\p{N}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AN%3A%5D&g=&i=), así como guiones ASCII (`-`) y guiones bajos ASCII (`_`).


```php
'username' => 'alpha_dash:ascii',

```

<a name="rule-alpha-num"></a>
#### alpha_num

El campo bajo validación debe contener totalmente caracteres alfanuméricos Unicode en [`\p{L}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AL%3A%5D&g=&i=), [`\p{M}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AM%3A%5D&g=&i=) y [`\p{N}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AN%3A%5D&g=&i=).
Para restringir esta regla de validación a caracteres en el rango ASCII (`a-z` y `A-Z`), puedes proporcionar la opción `ascii` a la regla de validación:


```php
'username' => 'alpha_num:ascii',

```

<a name="rule-array"></a>
#### array

El campo bajo validación debe ser un `array` de PHP.
Cuando se proporcionan valores adicionales a la regla `array`, cada clave en el array de entrada debe estar presente dentro de la lista de valores proporcionados a la regla. En el siguiente ejemplo, la clave `admin` en el array de entrada es inválida ya que no está contenida en la lista de valores proporcionados a la regla `array`:
En general, siempre debes especificar las claves del array que se pueden presentar dentro de tu array.

<a name="rule-ascii"></a>
#### ascii

El campo bajo validación debe ser completamente caracteres ASCII de 7 bits.

<a name="rule-bail"></a>
#### baila

Deja de ejecutar reglas de validación para el campo después del primer fallo de validación.
Mientras que la regla `bail` solo detendrá la validación de un campo específico cuando encuentre un fallo de validación, el método `stopOnFirstFailure` informará al validador que debe detener la validación de todos los atributos una vez que se haya producido un solo fallo de validación:


```php
if ($validator->stopOnFirstFailure()->fails()) {
    // ...
}
```

<a name="rule-before"></a>
#### antes:*date*

El campo bajo validación debe ser un valor que preceda a la fecha dada. Las fechas se pasarán a la función `strtotime` de PHP para ser convertidas en una instancia válida de `DateTime`. Además, al igual que la regla [`after`](#rule-after), se puede suministrar el nombre de otro campo bajo validación como el valor de `date`.

<a name="rule-before-or-equal"></a>
#### before_or_equal:*date*

El campo bajo validación debe ser un valor anterior o igual a la fecha dada. Las fechas se pasarán a la función `strtotime` de PHP para ser convertidas en una instancia de `DateTime` válida. Además, al igual que la regla [`after`](#rule-after), se puede proporcionar el nombre de otro campo bajo validación como el valor de `date`.

<a name="rule-between"></a>
#### entre:*min*,*max*

El campo bajo validación debe tener un tamaño entre el *min* y el *max* dados (inclusive). Las cadenas, numéricos, arreglos y archivos se evalúan de la misma manera que la regla [`size`](#rule-size).

<a name="rule-boolean"></a>
#### booleano

El campo bajo validación debe poder ser convertido a un booleano. Las entradas aceptadas son `true`, `false`, `1`, `0`, `"1"` y `"0"`.

<a name="rule-confirmed"></a>
#### confirmado

El campo bajo validación debe tener un campo correspondiente de `{field}_confirmation`. Por ejemplo, si el campo bajo validación es `password`, debe haber un campo `password_confirmation` correspondiente en la entrada.

<a name="rule-contains"></a>
#### contiene:*foo*,*bar*,...

El campo bajo validación debe ser un array que contenga todos los valores de parámetro dados.

<a name="rule-current-password"></a>
#### current_password

El campo que está bajo validación debe coincidir con la contraseña del usuario autenticado. Puedes especificar un [guardia de autenticación](/docs/%7B%7Bversion%7D%7D/authentication) utilizando el primer parámetro de la regla:


```php
'password' => 'current_password:api'
```

<a name="rule-date"></a>
#### fecha

El campo bajo validación debe ser una fecha válida y no relativa según la función `strtotime` de PHP.

<a name="rule-date-equals"></a>
#### date_equals:*date*

El campo bajo validación debe ser igual a la fecha dada. Las fechas se pasarán a la función `strtotime` de PHP para ser convertidas en una instancia válida de `DateTime`.

<a name="rule-date-format"></a>
#### date_format:*format*,...

El campo bajo validación debe coincidir con uno de los *formatos* dados. Debes usar **ya sea** `date` o `date_format` al validar un campo, no ambos. Esta regla de validación admite todos los formatos que son compatibles con la clase [DateTime](https://www.php.net/manual/en/class.datetime.php) de PHP.

<a name="rule-decimal"></a>
#### decimal:*min*,*max*

El campo bajo validación debe ser numérico y debe contener el número especificado de lugares decimales:


```php
// Must have exactly two decimal places (9.99)...
'price' => 'decimal:2'

// Must have between 2 and 4 decimal places...
'price' => 'decimal:2,4'
```

<a name="rule-declined"></a>
#### declinado

El campo bajo validación debe ser `"no"`, `"off"`, `0`, `"0"`, `false` o `"false"`.

<a name="rule-declined-if"></a>
#### declined_if:anotherfield,value,...

El campo bajo validación debe ser `"no"`, `"off"`, `0`, `"0"`, `false` o `"false"` si otro campo bajo validación es igual a un valor especificado.

<a name="rule-different"></a>
#### diferente:*field*

El campo bajo validación debe tener un valor diferente al de *field*.

<a name="rule-digits"></a>
#### digits:*value*

El entero bajo validación debe tener una longitud exacta de *value*.

<a name="rule-digits-between"></a>
#### digits_between:*min*,*max*

La validación de entero debe tener una longitud entre el *min* y el *max* dados.

<a name="rule-dimensions"></a>
#### dimensiones

El archivo bajo validación debe ser una imagen que cumpla con las restricciones de dimensión especificadas por los parámetros de la regla:


```php
'avatar' => 'dimensions:min_width=100,min_height=200'
```
Los constraints disponibles son: *min_width*, *max_width*, *min_height*, *max_height*, *width*, *height*, *ratio*.
Una restricción de *ratio* debe representarse como ancho dividido por alto. Esto se puede especificar ya sea mediante una fracción como `3/2` o un flotante como `1.5`:


```php
'avatar' => 'dimensions:ratio=3/2'
```
Dado que esta regla requiere varios argumentos, puedes usar el método `Rule::dimensions` para construir la regla de forma fluida:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

Validator::make($data, [
    'avatar' => [
        'required',
        Rule::dimensions()->maxWidth(1000)->maxHeight(500)->ratio(3 / 2),
    ],
]);
```

<a name="rule-distinct"></a>
#### distinto

Al validar arrays, el campo bajo validación no debe tener valores duplicados:


```php
'foo.*.id' => 'distinct'
```
Distinct utiliza comparaciones de variables sueltas por defecto. Para usar comparaciones estrictas, puedes añadir el parámetro `strict` a la definición de tu regla de validación:


```php
'foo.*.id' => 'distinct:strict'
```
Puedes añadir `ignore_case` a los argumentos de la regla de validación para hacer que la regla ignore las diferencias de capitalización:


```php
'foo.*.id' => 'distinct:ignore_case'
```

<a name="rule-doesnt-start-with"></a>
#### no_empieza_con:*foo*,*bar*,...

El campo bajo validación no debe comenzar con uno de los valores dados.

<a name="rule-doesnt-end-with"></a>
#### no_termina_con:*foo*,*bar*,...

El campo bajo validación no debe terminar con uno de los valores dados.

<a name="rule-email"></a>
#### correo electrónico

El campo bajo validación debe estar formateado como una dirección de correo electrónico. Esta regla de validación utiliza el paquete [`egulias/email-validator`](https://github.com/egulias/EmailValidator) para validar la dirección de correo electrónico. Por defecto, se aplica el validador `RFCValidation`, pero también puedes aplicar otros estilos de validación:


```php
'email' => 'email:rfc,dns'
```
El ejemplo anterior aplicará las validaciones `RFCValidation` y `DNSCheckValidation`. Aquí tienes una lista completa de los estilos de validación que puedes aplicar:
<div class="content-list" markdown="1">

- `rfc`: `RFCValidation`
- `strict`: `NoRFCWarningsValidation`
- `dns`: `DNSCheckValidation`
- `spoof`: `SpoofCheckValidation`
- `filter`: `FilterEmailValidation`
- `filter_unicode`: `FilterEmailValidation::unicode()`
</div>
El validador `filter`, que utiliza la función `filter_var` de PHP, viene incluido con Laravel y era el comportamiento de validación de correo electrónico predeterminado de Laravel antes de la versión 5.8.
> [!WARNING]
Los validadores `dns` y `spoof` requieren la extensión PHP `intl`.

<a name="rule-ends-with"></a>
#### ends_with:*foo*,*bar*,...

El campo bajo validación debe terminar con uno de los valores dados.

<a name="rule-enum"></a>
#### enum

La regla `Enum` es una regla basada en clases que valida si el campo bajo validación contiene un valor enum válido. La regla `Enum` acepta el nombre del enum como su único argumento de constructor. Al validar valores primitivos, se debe proporcionar un Enum respaldado a la regla `Enum`:


```php
use App\Enums\ServerStatus;
use Illuminate\Validation\Rule;

$request->validate([
    'status' => [Rule::enum(ServerStatus::class)],
]);
```
Los métodos `only` y `except` de la regla `Enum` pueden usarse para limitar cuáles casos de enum deben considerarse válidos:


```php
Rule::enum(ServerStatus::class)
    ->only([ServerStatus::Pending, ServerStatus::Active]);

Rule::enum(ServerStatus::class)
    ->except([ServerStatus::Pending, ServerStatus::Active]);
```
El método `when` se puede utilizar para modificar condicionalmente la regla `Enum`:


```php
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

Rule::enum(ServerStatus::class)
    ->when(
        Auth::user()->isAdmin(),
        fn ($rule) => $rule->only(...),
        fn ($rule) => $rule->only(...),
    );

```

<a name="rule-exclude"></a>
#### excluir

El campo bajo validación será excluido de los datos de solicitud devueltos por los métodos `validate` y `validated`.

<a name="rule-exclude-if"></a>
#### exclude_if:*anotherfield*,*value*

El campo bajo validación será excluido de los datos de solicitud devueltos por los métodos `validate` y `validated` si el campo *anotherfield* es igual a *value*.
Si se requiere una lógica de exclusión condicional compleja, puedes utilizar el método `Rule::excludeIf`. Este método acepta un booleano o una `función anónima`. Cuando se le da una `función anónima`, la `función anónima` debe devolver `true` o `false` para indicar si el campo bajo validación debe ser excluido:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

Validator::make($request->all(), [
    'role_id' => Rule::excludeIf($request->user()->is_admin),
]);

Validator::make($request->all(), [
    'role_id' => Rule::excludeIf(fn () => $request->user()->is_admin),
]);
```

<a name="rule-exclude-unless"></a>
#### exclude_unless:*anotherfield*,*value*

El campo bajo validación será excluido de los datos de la solicitud devueltos por los métodos `validate` y `validated` a menos que el campo de *anotherfield* sea igual a *value*. Si *value* es `null` (`exclude_unless:name,null`), el campo bajo validación será excluido a menos que el campo de comparación sea `null` o el campo de comparación esté ausente de los datos de la solicitud.

<a name="rule-exclude-with"></a>
#### exclude_with:*anotherfield*

El campo bajo validación será excluido de los datos de solicitud devueltos por los métodos `validate` y `validated` si el campo *anotherfield* está presente.

<a name="rule-exclude-without"></a>
#### exclude_without:*anotherfield*

El campo que se está validando será excluido de los datos de solicitud devueltos por los métodos `validate` y `validated` si el campo *anotherfield* no está presente.

<a name="rule-exists"></a>
#### exists:*table*,*column*

El campo bajo validación debe existir en una tabla de base de datos dada.

<a name="basic-usage-of-exists-rule"></a>
#### Uso Básico de la Regla Exists



```php
'state' => 'exists:states'
```
Si la opción `column` no se especifica, se utilizará el nombre del campo. Así que, en este caso, la regla validará que la tabla de base de datos `states` contenga un registro con un valor de columna `state` que coincida con el valor del atributo `state` de la solicitud.

<a name="specifying-a-custom-column-name"></a>
#### Especificando un Nombre de Columna Personalizado

Puedes especificar explícitamente el nombre de la columna de la base de datos que debe ser utilizada por la regla de validación colocándola después del nombre de la tabla de la base de datos:


```php
'state' => 'exists:states,abbreviation'
```
Ocasionalmente, es posible que necesites especificar una conexión de base de datos específica que se utilizará para la consulta `exists`. Puedes lograr esto añadiendo el nombre de la conexión al inicio del nombre de la tabla:


```php
'email' => 'exists:connection.staff,email'
```


```php
'user_id' => 'exists:App\Models\User,id'
```
Si deseas personalizar la consulta ejecutada por la regla de validación, puedes usar la clase `Rule` para definir la regla de manera fluida. En este ejemplo, también especificaremos las reglas de validación como un array en lugar de usar el carácter `|` para delimitarlas:


```php
use Illuminate\Database\Query\Builder;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

Validator::make($data, [
    'email' => [
        'required',
        Rule::exists('staff')->where(function (Builder $query) {
            return $query->where('account_id', 1);
        }),
    ],
]);
```
Puedes especificar explícitamente el nombre de la columna de la base de datos que debe ser utilizada por la regla `exists` generada por el método `Rule::exists` proporcionando el nombre de la columna como el segundo argumento al método `exists`:


```php
'state' => Rule::exists('states', 'abbreviation'),
```

<a name="rule-extensions"></a>
#### extensiones:*foo*,*bar*,...

El archivo en validación debe tener una extensión asignada por el usuario que corresponda a una de las extensiones enumeradas:


```php
'photo' => ['required', 'extensions:jpg,png'],
```
> [!WARNING]
Nunca debes confiar en validar un archivo solo por su extensión asignada por el usuario. Esta regla debe usarse típicamente siempre en combinación con las reglas [`mimes`](#rule-mimes) o [`mimetypes`](#rule-mimetypes).

<a name="rule-file"></a>
#### archivo

El campo bajo validación debe ser un archivo que se haya subido con éxito.

<a name="rule-filled"></a>
#### lleno

El campo bajo validación no debe estar vacío cuando está presente.

<a name="rule-gt"></a>
#### gt:*field*

El campo bajo validación debe ser mayor que el *campo* o *valor* dado. Los dos campos deben ser del mismo tipo. Cadenas, numéricos, arrays y archivos se evalúan utilizando las mismas convenciones que la regla [`size`](#rule-size).

<a name="rule-gte"></a>
#### gte:*field*

El campo que está siendo validado debe ser mayor o igual al *campo* o *valor* dado. Los dos campos deben ser del mismo tipo. Cadenas, numéricos, arrays y archivos se evalúan utilizando las mismas convenciones que la regla [`size`](#rule-size).

<a name="rule-hex-color"></a>
#### hex_color

El campo bajo validación debe contener un valor de color válido en formato [hexadecimal](https://developer.mozilla.org/en-US/docs/Web/CSS/hex-color).

<a name="rule-image"></a>
#### imagen

El archivo bajo validación debe ser una imagen (jpg, jpeg, png, bmp, gif, svg o webp).

<a name="rule-in"></a>
#### in:*foo*,*bar*,...

El campo bajo validación debe estar incluido en la lista dada de valores. Dado que esta regla a menudo requiere que `implode` un array, se puede usar el método `Rule::in` para construir la regla de forma fluida:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

Validator::make($data, [
    'zones' => [
        'required',
        Rule::in(['first-zone', 'second-zone']),
    ],
]);
```
Cuando la regla `in` se combina con la regla `array`, cada valor en el array de entrada debe estar presente dentro de la lista de valores proporcionados a la regla `in`. En el siguiente ejemplo, el código de aeropuerto `LAS` en el array de entrada es inválido ya que no está contenido en la lista de aeropuertos proporcionada a la regla `in`:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

$input = [
    'airports' => ['NYC', 'LAS'],
];

Validator::make($input, [
    'airports' => [
        'required',
        'array',
    ],
    'airports.*' => Rule::in(['NYC', 'LIT']),
]);
```

<a name="rule-in-array"></a>
#### in_array:*anotherfield*.

El campo bajo validación debe existir en los valores de *anotherfield*.

<a name="rule-integer"></a>
#### integer

El campo bajo validación debe ser un número entero.
> [!WARNING]
Esta regla de validación no verifica que la entrada sea del tipo de variable "entero", solo que la entrada sea de un tipo aceptado por la regla `FILTER_VALIDATE_INT` de PHP. Si necesitas validar la entrada como un número, por favor utiliza esta regla en combinación con [la regla de validación `numeric`](#rule-numeric).

<a name="rule-ip"></a>
#### ip

El campo bajo validación debe ser una dirección IP.

<a name="ipv4"></a>
#### ipv4

El campo bajo validación debe ser una dirección IPv4.

<a name="ipv6"></a>
#### ipv6

El campo que se está validando debe ser una dirección IPv6.

<a name="rule-json"></a>
#### json

El campo bajo validación debe ser una cadena JSON válida.

<a name="rule-lt"></a>
#### lt:*field*

El campo bajo validación debe ser menor que el *campo* dado. Los dos campos deben ser del mismo tipo. Cadenas, numéricos, arrays y archivos se evalúan utilizando las mismas convenciones que la regla [`size`](#rule-size).

<a name="rule-lte"></a>
#### lte:*field*

El campo bajo validación debe ser menor o igual al *campo* dado. Los dos campos deben ser del mismo tipo. Cadenas, numéricos, arrays y archivos se evalúan utilizando las mismas convenciones que la regla [`size`](#rule-size).

<a name="rule-lowercase"></a>
#### minúsculas

El campo bajo validación debe estar en minúsculas.

<a name="rule-list"></a>
#### lista

El campo bajo validación debe ser un array que sea una lista. Se considera que un array es una lista si sus claves consisten en números consecutivos del 0 a `count($array) - 1`.

<a name="rule-mac"></a>
#### mac_address

El campo bajo validación debe ser una dirección MAC.

<a name="rule-max"></a>
#### max:*valor*

El campo bajo validación debe ser menor o igual a un *valor* máximo. Las cadenas, números, arrays y archivos se evalúan de la misma manera que la regla [`size`](#rule-size).

<a name="rule-max-digits"></a>
#### max_digits:*value*

El entero bajo validación debe tener una longitud máxima de *value*.

<a name="rule-mimetypes"></a>
#### mimetypes:*text/plain*,...

El archivo bajo validación debe coincidir con uno de los tipos MIME dados:


```php
'video' => 'mimetypes:video/avi,video/mpeg,video/quicktime'
```
Para determinar el tipo MIME del archivo cargado, se leerán los contenidos del archivo y el framework intentará adivinar el tipo MIME, que puede ser diferente del tipo MIME proporcionado por el cliente.

<a name="rule-mimes"></a>
#### mimes:*foo*,*bar*,...

El archivo bajo validación debe tener un tipo MIME que corresponda a una de las extensiones listadas:


```php
'photo' => 'mimes:jpg,bmp,png'
```
Aunque solo necesitas especificar las extensiones, esta regla en realidad valida el tipo MIME del archivo leyendo el contenido del archivo y adivinando su tipo MIME. Una lista completa de tipos MIME y sus extensiones correspondientes se puede encontrar en la siguiente ubicación:

<a name="mime-types-and-extensions"></a>
#### Tipos MIME y Extensiones

Esta regla de validación no verifica la concordancia entre el tipo MIME y la extensión que el usuario asignó al archivo. Por ejemplo, la regla de validación `mimes:png` consideraría un archivo que contiene contenido PNG válido como una imagen PNG válida, even si el archivo se llama `photo.txt`. Si deseas validar la extensión asignada por el usuario del archivo, puedes usar la regla [`extensions`](#rule-extensions).

<a name="rule-min"></a>
#### min:*value*

El campo bajo validación debe tener un *valor* mínimo. Las cadenas, numéricos, arrays y archivos se evalúan de la misma manera que la regla [`size`](#rule-size).

<a name="rule-min-digits"></a>
#### min_digits:*value*

El entero bajo validación debe tener una longitud mínima de *value*.

<a name="rule-multiple-of"></a>
#### multiple_of:*value*

El campo bajo validación debe ser un múltiplo de *value*.

<a name="rule-missing"></a>
#### faltante

El campo bajo validación no debe estar presente en los datos de entrada.

<a name="rule-missing-if"></a>
#### missing_if:*anotherfield*,*value*,...

El campo bajo validación no debe estar presente si el campo *anotherfield* es igual a cualquier *value*.

<a name="rule-missing-unless"></a>
#### missing_unless:*anotherfield*,*value*

El campo bajo validación no debe estar presente a menos que el campo *anotherfield* sea igual a cualquier *value*.

<a name="rule-missing-with"></a>
#### missing_with:*foo*,*bar*,...

El campo bajo validación no debe estar presente *solo si* cualquiera de los otros campos especificados está presente.

<a name="rule-missing-with-all"></a>
#### missing_with_all:*foo*,*bar*,...

El campo bajo validación no debe estar presente *solo si* todos los otros campos especificados están presentes.

<a name="rule-not-in"></a>
#### not_in:*foo*,*bar*,...

El campo bajo validación no debe incluirse en la lista dada de valores. Se puede usar el método `Rule::notIn` para construir la regla de manera fluida:


```php
use Illuminate\Validation\Rule;

Validator::make($data, [
    'toppings' => [
        'required',
        Rule::notIn(['sprinkles', 'cherries']),
    ],
]);
```

<a name="rule-not-regex"></a>
#### not_regex:*pattern*

El campo bajo validación no debe coincidir con la expresión regular dada.
Internamente, esta regla utiliza la función `preg_match` de PHP. El patrón especificado debe obedecer el mismo formato requerido por `preg_match` y, por lo tanto, también debe incluir delimitadores válidos. Por ejemplo: `'email' => 'not_regex:/^.+$/i'`.
> [!WARNING]
Al usar los patrones `regex` / `not_regex`, puede ser necesario especificar tus reglas de validación utilizando un array en lugar de usar delimitadores `|`, especialmente si la expresión regular contiene un carácter `|`.

<a name="rule-nullable"></a>
#### nullable

El campo bajo validación puede ser `null`.

<a name="rule-numeric"></a>
#### numérico

El campo bajo validación debe ser [numérico](https://www.php.net/manual/en/function.is-numeric.php).

<a name="rule-present"></a>
#### presente

El campo bajo validación debe existir en los datos de entrada.

<a name="rule-present-if"></a>
#### present_if:*anotherfield*,*value*,...

El campo bajo validación debe estar presente si el campo *anotherfield* es igual a cualquier *value*.

<a name="rule-present-unless"></a>
#### present_unless:*anotherfield*,*value*

El campo bajo validación debe estar presente a menos que el campo *anotherfield* sea igual a cualquier *value*.

<a name="rule-present-with"></a>
#### present_with:*foo*,*bar*,...

El campo bajo validación debe estar presente *solo si* cualquiera de los otros campos especificados está presente.

<a name="rule-present-with-all"></a>
#### present_with_all:*foo*,*bar*,...

El campo bajo validación debe estar presente *solo si* todos los otros campos especificados están presentes.

<a name="rule-prohibited"></a>
#### prohibido

El campo bajo validación debe estar ausente o vacío. Un campo está "vacío" si cumple con uno de los siguientes criterios:
<div class="content-list" markdown="1">

</div>

<a name="rule-prohibited-if"></a>
#### prohibited_if:*anotherfield*,*value*,...

El campo bajo validación debe estar ausente o vacío si el campo *anotherfield* es igual a cualquier *value*. Un campo está "vacío" si cumple con uno de los siguientes criterios:
<div class="content-list" markdown="1">

</div>
Si se requiere lógica de prohibición condicional compleja, puedes utilizar el método `Rule::prohibitedIf`. Este método acepta un booleano o una función anónima. Cuando se le da una función anónima, esta debe devolver `true` o `false` para indicar si el campo bajo validación debe ser prohibido:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

Validator::make($request->all(), [
    'role_id' => Rule::prohibitedIf($request->user()->is_admin),
]);

Validator::make($request->all(), [
    'role_id' => Rule::prohibitedIf(fn () => $request->user()->is_admin),
]);
```

<a name="rule-prohibited-unless"></a>
#### prohibited_unless:*anotherfield*,*value*,...

El campo bajo validación debe estar ausente o vacío a menos que el campo *anotherfield* sea igual a cualquier *value*. Un campo está "vacío" si cumple con uno de los siguientes criterios:
<div class="content-list" markdown="1">

</div>

<a name="rule-prohibits"></a>
#### prohíbe:*anotherfield*,...

Si el campo bajo validación no está faltando o vacío, todos los campos en *anotherfield* deben estar faltando o vacíos. Un campo está "vacío" si cumple con uno de los siguientes criterios:
<div class="content-list" markdown="1">

- The value is `null`.
- The value is an empty string.
- The value is an empty array or empty `Countable` object.
- The value is an uploaded file with an empty path.
</div>

<a name="rule-regex"></a>
#### regex:*pattern*

El campo bajo validación debe coincidir con la expresión regular dada.
Internamente, esta regla utiliza la función `preg_match` de PHP. El patrón especificado debe obedecer el mismo formato requerido por `preg_match` y, por lo tanto, también incluir delimitadores válidos. Por ejemplo: `'email' => 'regex:/^.+@.+$/i'`.
> [!WARNING]
Al usar los patrones `regex` / `not_regex`, puede ser necesario especificar reglas en un array en lugar de usar delimitadores `|`, especialmente si la expresión regular contiene un carácter `|`.

<a name="rule-required"></a>
#### requerido

El campo bajo validación debe estar presente en los datos de entrada y no estar vacío. Un campo está "vacío" si cumple con uno de los siguientes criterios:
<div class="content-list" markdown="1">

- The value is `null`.
- The value is an empty string.
- The value is an empty array or empty `Countable` object.
- The value is an uploaded file with no path.
</div>

<a name="rule-required-if"></a>
#### required_if:*anotherfield*,*value*,...

El campo bajo validación debe estar presente y no estar vacío si el campo *anotherfield* es igual a cualquier *value*.
Si deseas construir una condición más compleja para la regla `required_if`, puedes usar el método `Rule::requiredIf`. Este método acepta un booleano o una `función anónima`. Cuando se pasa una `función anónima`, esta debe devolver `true` o `false` para indicar si el campo bajo validación es requerido:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

Validator::make($request->all(), [
    'role_id' => Rule::requiredIf($request->user()->is_admin),
]);

Validator::make($request->all(), [
    'role_id' => Rule::requiredIf(fn () => $request->user()->is_admin),
]);
```

<a name="rule-required-if-accepted"></a>
#### required_if_accepted:*anotherfield*,...

El campo bajo validación debe estar presente y no estar vacío si el campo *anotherfield* es igual a `"yes"`, `"on"`, `1`, `"1"`, `true` o `"true"`.

<a name="rule-required-if-declined"></a>
#### required_if_declined:*anotherfield*,...

El campo bajo validación debe estar presente y no estar vacío si el campo *anotherfield* es igual a `"no"`, `"off"`, `0`, `"0"`, `false` o `"false"`.

<a name="rule-required-unless"></a>
#### required_unless:*anotherfield*,*value*,...

El campo bajo validación debe estar presente y no estar vacío a menos que el campo *anotherfield* sea igual a cualquier *value*. Esto también significa que *anotherfield* debe estar presente en los datos de la solicitud a menos que *value* sea `null`. Si *value* es `null` (`required_unless:name,null`), el campo bajo validación será obligatorio a menos que el campo de comparación sea `null` o el campo de comparación falte en los datos de la solicitud.

<a name="rule-required-with"></a>
#### required_with:*foo*,*bar*,...

El campo bajo validación debe estar presente y no estar vacío *solo si* cualquiera de los otros campos especificados está presente y no está vacío.

<a name="rule-required-with-all"></a>
#### required_with_all:*foo*,*bar*,...

El campo bajo validación debe estar presente y no estar vacío *solo si* todos los otros campos especificados están presentes y no están vacíos.

<a name="rule-required-without"></a>
#### required_without:*foo*,*bar*,...

El campo bajo validación debe estar presente y no estar vacío *solo cuando* cualquiera de los otros campos especificados esté vacío o no presente.

<a name="rule-required-without-all"></a>
#### required_without_all:*foo*,*bar*,...

El campo bajo validación debe estar presente y no estar vacío *solo cuando* todos los demás campos especificados estén vacíos o no estén presentes.

<a name="rule-required-array-keys"></a>
#### required_array_keys:*foo*,*bar*,...

El campo bajo validación debe ser un array y debe contener al menos las claves especificadas.

<a name="rule-same"></a>
#### mismo:*field*

El *campo* dado debe coincidir con el campo bajo validación.

<a name="rule-size"></a>
#### size:*value*

El campo bajo validación debe tener un tamaño que coincida con el *valor* dado. Para datos de cadena, *valor* corresponde al número de caracteres. Para datos numéricos, *valor* corresponde a un valor entero dado (el atributo también debe tener la regla `numeric` o `integer`). Para un array, *size* corresponde al `count` del array. Para archivos, *size* corresponde al tamaño del archivo en kilobytes. Veamos algunos ejemplos:


```php
// Validate that a string is exactly 12 characters long...
'title' => 'size:12';

// Validate that a provided integer equals 10...
'seats' => 'integer|size:10';

// Validate that an array has exactly 5 elements...
'tags' => 'array|size:5';

// Validate that an uploaded file is exactly 512 kilobytes...
'image' => 'file|size:512';
```

<a name="rule-starts-with"></a>
#### starts_with:*foo*,*bar*,...

El campo bajo validación debe comenzar con uno de los valores dados.

<a name="rule-string"></a>
#### string

El campo bajo validación debe ser una cadena. Si deseas permitir que el campo también sea `null`, debes asignar la regla `nullable` al campo.

<a name="rule-timezone"></a>
#### timezone

El campo bajo validación debe ser un identificador de zona horaria válido según el método `DateTimeZone::listIdentifiers`.
Los argumentos [aceptados por el método `DateTimeZone::listIdentifiers`](https://www.php.net/manual/en/datetimezone.listidentifiers.php) también pueden ser proporcionados a esta regla de validación:


```php
'timezone' => 'required|timezone:all';

'timezone' => 'required|timezone:Africa';

'timezone' => 'required|timezone:per_country,US';
```

<a name="rule-unique"></a>
#### unique:*table*,*column*

El campo bajo validación no debe existir dentro de la tabla de base de datos dada.
**Especificando un Nombre de Tabla / Columna Personalizado:**
En lugar de especificar el nombre de la tabla directamente, puedes especificar el modelo Eloquent que se debe utilizar para determinar el nombre de la tabla:


```php
'email' => 'unique:App\Models\User,email_address'
```
La opción `column` puede utilizarse para especificar la columna de base de datos correspondiente del campo. Si la opción `column` no se especifica, se usará el nombre del campo bajo validación.


```php
'email' => 'unique:users,email_address'
```
**Especificando una Conexión de Base de Datos Personalizada**
Ocasionalmente, es posible que necesites establecer una conexión personalizada para las consultas de base de datos realizadas por el Validador. Para lograr esto, puedes preceder el nombre de la conexión al nombre de la tabla:


```php
'email' => 'unique:connection.users,email_address'
```
**Forzando una Regla Única para Ignorar un ID Dado:**
A veces, es posible que desees ignorar un ID dado durante la validación única. Por ejemplo, considera una pantalla de "actualizar perfil" que incluye el nombre del usuario, la dirección de correo electrónico y la ubicación. Probablemente querrás verificar que la dirección de correo electrónico sea única. Sin embargo, si el usuario solo cambia el campo del nombre y no el campo de correo electrónico, no quieres que se genere un error de validación porque el usuario ya es el propietario de la dirección de correo electrónico en cuestión.
Para instruir al validador a que ignore el ID del usuario, utilizaremos la clase `Rule` para definir la regla de manera fluida. En este ejemplo, también especificaremos las reglas de validación como un array en lugar de usar el carácter `|` para delimitar las reglas:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

Validator::make($data, [
    'email' => [
        'required',
        Rule::unique('users')->ignore($user->id),
    ],
]);
```
> [!WARNING]
Nunca debes pasar ninguna entrada de solicitud controlada por el usuario al método `ignore`. En su lugar, solo debes pasar un ID único generado por el sistema, como un ID autoincremental o un UUID de una instancia del modelo Eloquent. De lo contrario, tu aplicación será vulnerable a un ataque de inyección SQL.
En lugar de pasar el valor de la clave del modelo al método `ignore`, también puedes pasar la instancia completa del modelo. Laravel extraerá automáticamente la clave del modelo:


```php
Rule::unique('users')->ignore($user)
```
Si tu tabla utiliza un nombre de columna de clave primaria diferente a `id`, puedes especificar el nombre de la columna al llamar al método `ignore`:


```php
Rule::unique('users')->ignore($user->id, 'user_id')
```
Por defecto, la regla `unique` verificará la unicidad de la columna que coincide con el nombre del atributo que se está validando. Sin embargo, puedes pasar un nombre de columna diferente como segundo argumento al método `unique`:


```php
Rule::unique('users', 'email_address')->ignore($user->id)
```
**Agregando Cláusulas Where Adicionales:**
Puedes especificar condiciones de consulta adicionales personalizando la consulta utilizando el método `where`. Por ejemplo, añadamos una condición de consulta que limite la búsqueda solo a los registros que tienen un valor de columna `account_id` de `1`:


```php
'email' => Rule::unique('users')->where(fn (Builder $query) => $query->where('account_id', 1))
```

<a name="rule-uppercase"></a>
#### mayúsculas

El campo bajo validación debe estar en mayúsculas.

<a name="rule-url"></a>
#### url

El campo que se está validando debe ser una URL válida.
Si deseas especificar los protocolos de URL que deben considerarse válidos, puedes pasar los protocolos como parámetros de regla de validación:


```php
'url' => 'url:http,https',

'game' => 'url:minecraft,steam',

```

<a name="rule-ulid"></a>
#### ulid

El campo bajo validación debe ser un [Identificador Único Universally Sortable](https://github.com/ulid/spec) (ULID) válido.

<a name="rule-uuid"></a>
#### uuid

El campo que se está validando debe ser un identificador único universal (UUID) válido según RFC 4122 (versión 1, 3, 4 o 5).

<a name="conditionally-adding-rules"></a>
## Agregar Reglas Condicionalmente


<a name="skipping-validation-when-fields-have-certain-values"></a>
#### Saltando la Validación Cuando los Campos Tienen Ciertos Valores

Es posible que desees no validar ocasionalmente un campo dado si otro campo tiene un valor dado. Puedes lograr esto usando la regla de validación `exclude_if`. En este ejemplo, los campos `appointment_date` y `doctor_name` no serán validados si el campo `has_appointment` tiene un valor de `false`:


```php
use Illuminate\Support\Facades\Validator;

$validator = Validator::make($data, [
    'has_appointment' => 'required|boolean',
    'appointment_date' => 'exclude_if:has_appointment,false|required|date',
    'doctor_name' => 'exclude_if:has_appointment,false|required|string',
]);
```
Alternativamente, puedes usar la regla `exclude_unless` para no validar un campo dado a menos que otro campo tenga un valor dado:


```php
$validator = Validator::make($data, [
    'has_appointment' => 'required|boolean',
    'appointment_date' => 'exclude_unless:has_appointment,true|required|date',
    'doctor_name' => 'exclude_unless:has_appointment,true|required|string',
]);
```

<a name="validating-when-present"></a>
#### Validando Cuando Está Presente

En algunas situaciones, es posible que desees realizar comprobaciones de validación en un campo **solo** si ese campo está presente en los datos que se están validando. Para lograr esto rápidamente, añade la regla `sometimes` a tu lista de reglas:


```php
$validator = Validator::make($data, [
    'email' => 'sometimes|required|email',
]);
```
En el ejemplo anterior, el campo `email` solo se validará si está presente en el array `$data`.
> [!NOTA]
Si estás intentando validar un campo que siempre debe estar presente pero puede estar vacío, consulta [esta nota sobre campos opcionales](#a-note-on-optional-fields).

<a name="complex-conditional-validation"></a>
#### Validación Condicional Compleja

A veces es posible que desees agregar reglas de validación basadas en una lógica condicional más compleja. Por ejemplo, es posible que desees requerir un campo dado solo si otro campo tiene un valor mayor que 100. O, es posible que necesites que dos campos tengan un valor dado solo cuando otro campo esté presente. Agregar estas reglas de validación no tiene por qué ser un dolor. Primero, crea una instancia de `Validator` con tus *reglas estáticas* que nunca cambian:


```php
use Illuminate\Support\Facades\Validator;

$validator = Validator::make($request->all(), [
    'email' => 'required|email',
    'games' => 'required|numeric',
]);
```
Supongamos que nuestra aplicación web es para coleccionistas de juegos. Si un coleccionista de juegos se registra en nuestra aplicación y posee más de 100 juegos, queremos que explique por qué posee tantos juegos. Por ejemplo, quizás dirige una tienda de reventa de juegos, o tal vez simplemente disfruta coleccionando juegos. Para añadir este requisito de manera condicional, podemos usar el método `sometimes` en la instancia de `Validator`.


```php
use Illuminate\Support\Fluent;

$validator->sometimes('reason', 'required|max:500', function (Fluent $input) {
    return $input->games >= 100;
});
```
El primer argumento pasado al método `sometimes` es el nombre del campo que estamos validando de forma condicional. El segundo argumento es una lista de las reglas que queremos agregar. Si la función anónima pasada como el tercer argumento devuelve `true`, se agregarán las reglas. Este método facilita la construcción de validaciones condicionales complejas. Incluso puedes agregar validaciones condicionales para varios campos a la vez:


```php
$validator->sometimes(['reason', 'cost'], 'required', function (Fluent $input) {
    return $input->games >= 100;
});
```
> [!NOTE]
El parámetro `$input` pasado a tu `función anónima` será una instancia de `Illuminate\Support\Fluent` y se puede usar para acceder a tu entrada y archivos bajo validación.

<a name="complex-conditional-array-validation"></a>
#### Validación de Array Condicional Compleja

A veces es posible que desees validar un campo en función de otro campo en el mismo array anidado cuyo índice no conoces. En estas situaciones, puedes permitir que tu función anónima reciba un segundo argumento, que será el elemento individual actual en el array que se está validando:


```php
$input = [
    'channels' => [
        [
            'type' => 'email',
            'address' => 'abigail@example.com',
        ],
        [
            'type' => 'url',
            'address' => 'https://example.com',
        ],
    ],
];

$validator->sometimes('channels.*.address', 'email', function (Fluent $input, Fluent $item) {
    return $item->type === 'email';
});

$validator->sometimes('channels.*.address', 'url', function (Fluent $input, Fluent $item) {
    return $item->type !== 'email';
});
```
Al igual que el parámetro `$input` pasado a la `función anónima`, el parámetro `$item` es una instancia de `Illuminate\Support\Fluent` cuando los datos del atributo son un array; de lo contrario, es una cadena.

<a name="validating-arrays"></a>
## Validando Arrays

Como se discutió en la [documentación de la regla de validación `array`](#rule-array), la regla `array` acepta una lista de claves de array permitidas. Si se presentan claves adicionales dentro del array, la validación fallará:


```php
use Illuminate\Support\Facades\Validator;

$input = [
    'user' => [
        'name' => 'Taylor Otwell',
        'username' => 'taylorotwell',
        'admin' => true,
    ],
];

Validator::make($input, [
    'user' => 'array:name,username',
]);
```
En general, siempre debes especificar las claves del array que se permiten dentro de tu array. De lo contrario, los métodos `validate` y `validated` del validador devolverán todos los datos validados, incluyendo el array y todas sus claves, incluso si esas claves no fueron validadas por otras reglas de validación de arrays anidados.

<a name="validating-nested-array-input"></a>
### Validando la Entrada de Array Anidado

Validar campos de entrada de formulario basados en arrays anidados no tiene por qué ser complicado. Puedes usar "notación de punto" para validar atributos dentro de un array. Por ejemplo, si la solicitud HTTP entrante contiene un campo `photos[profile]`, puedes validarlo así:


```php
use Illuminate\Support\Facades\Validator;

$validator = Validator::make($request->all(), [
    'photos.profile' => 'required|image',
]);
```
También puedes validar cada elemento de un array. Por ejemplo, para validar que cada correo electrónico en un campo de entrada de array dado sea único, puedes hacer lo siguiente:


```php
$validator = Validator::make($request->all(), [
    'person.*.email' => 'email|unique:users',
    'person.*.first_name' => 'required_with:person.*.last_name',
]);
```
Asimismo, puedes usar el carácter `*` al especificar [mensajes de validación personalizados en tus archivos de idioma](#custom-messages-for-specific-attributes), facilitando el uso de un solo mensaje de validación para campos basados en arrays:


```php
'custom' => [
    'person.*.email' => [
        'unique' => 'Each person must have a unique email address',
    ]
],
```

<a name="accessing-nested-array-data"></a>
#### Accediendo a Datos de Array Anidado

A veces es posible que necesites acceder al valor de un elemento de array anidado dado al asignar reglas de validación al atributo. Puedes lograr esto utilizando el método `Rule::forEach`. El método `forEach` acepta una función anónima que se invocará en cada iteración del atributo de array bajo validación y recibirá el valor del atributo y el nombre del atributo explícito y completamente expandido. La función anónima debe devolver un array de reglas para asignar al elemento del array:


```php
use App\Rules\HasPermission;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

$validator = Validator::make($request->all(), [
    'companies.*.id' => Rule::forEach(function (string|null $value, string $attribute) {
        return [
            Rule::exists(Company::class, 'id'),
            new HasPermission('manage-company', $value),
        ];
    }),
]);
```

<a name="error-message-indexes-and-positions"></a>
### Índices y Posiciones de Mensajes de Error

Al validar arrays, es posible que desees hacer referencia al índice o posición de un elemento particular que no pasó la validación dentro del mensaje de error que muestra tu aplicación. Para lograr esto, puedes incluir los marcadores de posición `:index` (comienza desde `0`) y `:position` (comienza desde `1`) dentro de tu [mensaje de validación personalizado](#manual-customizing-the-error-messages):


```php
use Illuminate\Support\Facades\Validator;

$input = [
    'photos' => [
        [
            'name' => 'BeachVacation.jpg',
            'description' => 'A photo of my beach vacation!',
        ],
        [
            'name' => 'GrandCanyon.jpg',
            'description' => '',
        ],
    ],
];

Validator::validate($input, [
    'photos.*.description' => 'required',
], [
    'photos.*.description.required' => 'Please describe photo #:position.',
]);
```
Dado el ejemplo anterior, la validación fallará y al usuario se le presentará el siguiente error: *"Por favor describe la foto #2."*
Si es necesario, puedes hacer referencia a índices y posiciones más profundamente anidados a través de `second-index`, `second-position`, `third-index`, `third-position`, etc.


```php
'photos.*.attributes.*.string' => 'Invalid attribute for photo #:second-position.',
```

<a name="validating-files"></a>
## Validando Archivos

Laravel ofrece una variedad de reglas de validación que se pueden usar para validar archivos subidos, como `mimes`, `image`, `min` y `max`. Si bien puedes especificar estas reglas individualmente al validar archivos, Laravel también ofrece un constructor de reglas de validación de archivos fluido que te puede resultar conveniente:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\File;

Validator::validate($input, [
    'attachment' => [
        'required',
        File::types(['mp3', 'wav'])
            ->min(1024)
            ->max(12 * 1024),
    ],
]);
```
Si tu aplicación acepta imágenes subidas por tus usuarios, puedes usar el método constructor `image` de la regla `File` para indicar que el archivo subido debe ser una imagen. Además, se puede usar la regla `dimensions` para limitar las dimensiones de la imagen:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\File;

Validator::validate($input, [
    'photo' => [
        'required',
        File::image()
            ->min(1024)
            ->max(12 * 1024)
            ->dimensions(Rule::dimensions()->maxWidth(1000)->maxHeight(500)),
    ],
]);
```
> [!NOTA]
Más información sobre la validación de dimensiones de imagen se puede encontrar en la [documentación de la regla de dimensiones](#rule-dimensions).

<a name="validating-files-file-sizes"></a>
#### Tamaños de archivos

Para mayor comodidad, los tamaños de archivo mínimos y máximos pueden especificarse como una cadena con un sufijo que indique las unidades de tamaño de archivo. Se admiten los sufijos `kb`, `mb`, `gb` y `tb`:


```php
File::image()
    ->min('1kb')
    ->max('10mb')

```

<a name="validating-files-file-types"></a>
#### Tipos de Archivo

Aunque solo necesitas especificar las extensiones al invocar el método `types`, este método en realidad valida el tipo MIME del archivo leyendo el contenido del archivo y adivinando su tipo MIME. Se puede encontrar una lista completa de tipos MIME y sus correspondientes extensiones en la siguiente ubicación:
[https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types](https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types)

<a name="validating-passwords"></a>
## Validando Contraseñas

Para asegurar que las contraseñas tengan un nivel de complejidad adecuado, puedes usar el objeto de regla `Password` de Laravel:


```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\Password;

$validator = Validator::make($request->all(), [
    'password' => ['required', 'confirmed', Password::min(8)],
]);
```
El objeto de regla `Password` te permite personalizar fácilmente los requisitos de complejidad de la contraseña para tu aplicación, como especificar que las contraseñas requieren al menos una letra, un número, un símbolo o caracteres con mayúsculas y minúsculas:


```php
// Require at least 8 characters...
Password::min(8)

// Require at least one letter...
Password::min(8)->letters()

// Require at least one uppercase and one lowercase letter...
Password::min(8)->mixedCase()

// Require at least one number...
Password::min(8)->numbers()

// Require at least one symbol...
Password::min(8)->symbols()
```
Además, puedes asegurarte de que una contraseña no ha sido comprometida en una filtración de datos de contraseñas públicas utilizando el método `uncompromised`:


```php
Password::min(8)->uncompromised()
```
Internamente, el objeto de regla `Password` utiliza el modelo de [k-Anonimato](https://es.wikipedia.org/wiki/K-anonimato) para determinar si una contraseña ha sido filtrada a través del servicio [haveibeenpwned.com](https://haveibeenpwned.com) sin sacrificar la privacidad o seguridad del usuario.
Por defecto, si una contraseña aparece al menos una vez en una filtración de datos, se considerará comprometida. Puedes personalizar este umbral utilizando el primer argumento del método `uncompromised`:


```php
// Ensure the password appears less than 3 times in the same data leak...
Password::min(8)->uncompromised(3);
```
Por supuesto, puedes encadenar todos los métodos en los ejemplos anteriores:


```php
Password::min(8)
    ->letters()
    ->mixedCase()
    ->numbers()
    ->symbols()
    ->uncompromised()
```

<a name="defining-default-password-rules"></a>
#### Definiendo Reglas de Contraseña por Defecto

Puede que te resulte conveniente especificar las reglas de validación predeterminadas para las contraseñas en una sola ubicación de tu aplicación. Puedes lograr esto fácilmente utilizando el método `Password::defaults`, que acepta una función anónima. La función anónima dada al método `defaults` debe devolver la configuración predeterminada de la regla de Contraseña. Típicamente, la regla `defaults` debe ser llamada dentro del método `boot` de uno de los proveedores de servicios de tu aplicación:


```php
use Illuminate\Validation\Rules\Password;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Password::defaults(function () {
        $rule = Password::min(8);

        return $this->app->isProduction()
                    ? $rule->mixedCase()->uncompromised()
                    : $rule;
    });
}

```
Entonces, cuando desees aplicar las reglas predeterminadas a una contraseña particular que está siendo validada, puedes invocar el método `defaults` sin argumentos:


```php
'password' => ['required', Password::defaults()],
```
Ocasionalmente, es posible que desees agregar reglas de validación adicionales a tus reglas de validación de contraseña predeterminadas. Puedes usar el método `rules` para lograr esto:


```php
use App\Rules\ZxcvbnRule;

Password::defaults(function () {
    $rule = Password::min(8)->rules([new ZxcvbnRule]);

    // ...
});
```

<a name="custom-validation-rules"></a>
## Reglas de Validación Personalizadas


<a name="using-rule-objects"></a>
### Usando Objetos de Regla

Laravel ofrece una variedad de reglas de validación útiles; sin embargo, es posible que desees especificar algunas de las tuyas. Un método para registrar reglas de validación personalizadas es utilizando objetos de regla. Para generar un nuevo objeto de regla, puedes usar el comando Artisan `make:rule`. Usemos este comando para generar una regla que verifique que una cadena esté en mayúsculas. Laravel colocará la nueva regla en el directorio `app/Rules`. Si este directorio no existe, Laravel lo creará cuando ejecutes el comando Artisan para crear tu regla:


```shell
php artisan make:rule Uppercase

```
Una vez que se haya creado la regla, estamos listos para definir su comportamiento. Un objeto de regla contiene un único método: `validate`. Este método recibe el nombre del atributo, su valor y un callback que debe invocarse en caso de fallo con el mensaje de error de validación:


```php
<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class Uppercase implements ValidationRule
{
    /**
     * Run the validation rule.
     */
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (strtoupper($value) !== $value) {
            $fail('The :attribute must be uppercase.');
        }
    }
}
```
Una vez que se ha definido la regla, puedes adjuntarla a un validador pasando una instancia del objeto de regla junto con tus otras reglas de validación:


```php
use App\Rules\Uppercase;

$request->validate([
    'name' => ['required', 'string', new Uppercase],
]);
```
#### Traduciendo Mensajes de Validación

En lugar de proporcionar un mensaje de error literal a la función anónima `$fail`, también puedes proporcionar una [clave de cadena de traducción](/docs/%7B%7Bversion%7D%7D/localization) e instruir a Laravel para que traduzca el mensaje de error:


```php
if (strtoupper($value) !== $value) {
    $fail('validation.uppercase')->translate();
}
```
Si es necesario, puedes proporcionar reemplazos de marcador de posición y el idioma preferido como el primer y segundo argumento al método `translate`:


```php
$fail('validation.location')->translate([
    'value' => $this->value,
], 'fr')
```
#### Accediendo a Datos Adicionales

Si la clase de regla de validación personalizada necesita acceder a todos los otros datos que están siendo validados, tu clase de regla puede implementar la interfaz `Illuminate\Contracts\Validation\DataAwareRule`. Esta interfaz requiere que tu clase defina un método `setData`. Este método será invocado automáticamente por Laravel (antes de que se realice la validación) con todos los datos bajo validación:


```php
<?php

namespace App\Rules;

use Illuminate\Contracts\Validation\DataAwareRule;
use Illuminate\Contracts\Validation\ValidationRule;

class Uppercase implements DataAwareRule, ValidationRule
{
    /**
     * All of the data under validation.
     *
     * @var array<string, mixed>
     */
    protected $data = [];

    // ...

    /**
     * Set the data under validation.
     *
     * @param  array<string, mixed>  $data
     */
    public function setData(array $data): static
    {
        $this->data = $data;

        return $this;
    }
}
```
O, si tu regla de validación requiere acceso a la instancia del validador que está realizando la validación, puedes implementar la interfaz `ValidatorAwareRule`:


```php
<?php

namespace App\Rules;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Contracts\Validation\ValidatorAwareRule;
use Illuminate\Validation\Validator;

class Uppercase implements ValidationRule, ValidatorAwareRule
{
    /**
     * The validator instance.
     *
     * @var \Illuminate\Validation\Validator
     */
    protected $validator;

    // ...

    /**
     * Set the current validator.
     */
    public function setValidator(Validator $validator): static
    {
        $this->validator = $validator;

        return $this;
    }
}
```

<a name="using-closures"></a>
### Usando Funciones Anónimas

Si solo necesitas la funcionalidad de una regla personalizada una vez en toda tu aplicación, puedes usar una función anónima en lugar de un objeto de regla. La función anónima recibe el nombre del atributo, el valor del atributo y un callback `$fail` que debe ser llamado si la validación falla:


```php
use Illuminate\Support\Facades\Validator;
use Closure;

$validator = Validator::make($request->all(), [
    'title' => [
        'required',
        'max:255',
        function (string $attribute, mixed $value, Closure $fail) {
            if ($value === 'foo') {
                $fail("The {$attribute} is invalid.");
            }
        },
    ],
]);
```

<a name="implicit-rules"></a>
### Reglas Implícitas

Por defecto, cuando un atributo que se está validando no está presente o contiene una cadena vacía, las reglas de validación normales, incluidas las reglas personalizadas, no se ejecutan. Por ejemplo, la regla [`unique`](#rule-unique) no se aplicará a una cadena vacía:


```php
use Illuminate\Support\Facades\Validator;

$rules = ['name' => 'unique:users,name'];

$input = ['name' => ''];

Validator::make($input, $rules)->passes(); // true
```
Para que una regla personalizada se ejecute incluso cuando un atributo está vacío, la regla debe implicar que el atributo es obligatorio. Para generar rápidamente un nuevo objeto de regla implícita, puedes usar el comando Artisan `make:rule` con la opción `--implicit`:


```shell
php artisan make:rule Uppercase --implicit

```
> [!WARNING]
Una regla "implícita" solo *implica* que el atributo es obligatorio. Si realmente invalida un atributo faltante o vacío depende de ti.