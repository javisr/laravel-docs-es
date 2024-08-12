# Validación

- [Introducción](#introduction)
- [Inicio rápido de validación](#validation-quickstart)
  - [Definición de las rutas](#quick-defining-the-routes)
  - [Creación del controlador](#quick-creating-the-controller)
  - [Escritura de la lógica de validación](#quick-writing-the-validation-logic)
  - [Visualización de errores de validación](#quick-displaying-the-validation-errors)
  - [Repoblación de formularios](#repopulating-forms)
  - [Nota sobre los campos opcionales](#a-note-on-optional-fields)
  - [Formato de Respuesta a Errores de Validación](#validation-error-response-format)
- [Validación de Peticiones de Formulario](#form-request-validation)
  - [Creación de solicitudes de formulario](#creating-form-requests)
  - [Autorización de solicitudes de formulario](#authorizing-form-requests)
  - [Personalización de los Mensajes de Error](#customizing-the-error-messages)
  - [Preparación de la entrada para la validación](#preparing-input-for-validation)
- [Creación manual de validadores](#manually-creating-validators)
  - [Redirección Automática](#automatic-redirection)
  - [Bolsas de error con nombre](#named-error-bags)
  - [Personalización de los mensajes de error](#manual-customizing-the-error-messages)
  - [Hook de validación posterior](#after-validation-hook)
- [Trabajar con entradas validadas](#working-with-validated-input)
- [Trabajar con mensajes de error](#working-with-error-messages)
  - [Especificación de mensajes personalizados en archivos de idioma](#specifying-custom-messages-in-language-files)
  - [Especificación de atributos en archivos de idioma](#specifying-attribute-in-language-files)
  - [Especificación de valores en archivos de idioma](#specifying-values-in-language-files)
- [Reglas de validación disponibles](#available-validation-rules)
- [Adición Condicional de Reglas](#conditionally-adding-rules)
- [Validación de arrays](#validating-arrays)
  - [array-input">Validación de array anidados](<#validating-nested-\<glossary variable=>)
  - [Índices y posiciones de mensajes de error](#error-message-indexes-and-positions)
- [Validación de archivos](#validating-files)
- [Validación de contraseñas](#validating-passwords)
- [Reglas de validación personalizadas](#custom-validation-rules)
  - [Usando instancias de Rules](#using-rule-objects)
  - [Usando closures](#using-closures)
  - [Reglas implícitas](#implicit-rules)

<a name="introduction"></a>
## Introducción

Laravel proporciona varios enfoques diferentes para validar los datos entrantes de su aplicación. Lo más común es utilizar el método `validate` disponible en todas las peticiones HTTP entrantes. Sin embargo, vamos a discutir otros enfoques para la validación.

Laravel incluye una amplia variedad de reglas (rules) de validación que puedes aplicar a los datos, incluso proporciona la capacidad de validar si los valores son únicos en una tabla de base de datos dada. Cubriremos cada una de estas reglas de validación en detalle para que te familiarices con todas las características de validación de Laravel.

<a name="validation-quickstart"></a>
## Inicio rápido de validación

Para aprender sobre las poderosas características de validación de Laravel, veamos un ejemplo completo de validación de un formulario y cómo mostrar los mensajes de error al usuario. Al leer este resumen, serás capaz de obtener una idea general de cómo validar los datos de solicitud entrantes utilizando Laravel:

<a name="quick-defining-the-routes"></a>
### Definición de las rutas

En primer lugar, supongamos que tenemos las siguientes rutas definidas en nuestro archivo `routes/web.php`:

    use App\Http\Controllers\PostController;

    Route::get('/post/create', [PostController::class, 'create']);
    Route::post('/post', [PostController::class, 'store']);

La ruta `GET` mostrará un formulario para que el usuario cree una nueva entrada en el blog, mientras que la ruta `POST` almacenará la nueva entrada en la base de datos.

<a name="quick-defining-the-routes"></a>
### Creación del controlador

A continuación, vamos a echar un vistazo a un controlador simple que maneja las peticiones entrantes a estas rutas. Dejaremos el método `store` vacío por ahora:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Http\Request;

    class PostController extends Controller
    {
        /**
         * Show the form to create a new blog post.
         *
         * @return \Illuminate\View\View
         */
        public function create()
        {
            return view('post.create');
        }

        /**
         * Store a new blog post.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function store(Request $request)
        {
            // Validate and store the blog post...
        }
    }

<a name="quick-writing-the-validation-logic"></a>
### Escribiendo la lógica de validación

Ahora estamos listos para rellenar nuestro método `store` con la lógica para validar la nueva entrada del blog. Para ello, utilizaremos el método `validate` proporcionado por el objeto `Illuminate\Http\Request`. Si las reglas de validación pasan, el código seguirá ejecutándose de manera normal; sin embargo, si la validación falla, se lanzará una excepción `Illuminate\Validation\ValidationException` y se enviará automáticamente la respuesta de error adecuada al usuario.

Si la validación falla durante una solicitud HTTP tradicional, se generará una respuesta de redirección a la URL anterior. Si la petición entrante es una petición XHR, se devolverá una [respuesta JSON con los mensajes de error de validación](#validation-error-response-format).

Para entender mejor el método `validate`, volvamos al método `store`:

    /**
     * Store a new blog post.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|unique:posts|max:255',
            'body' => 'required',
        ]);

        // The blog post is valid...
    }

Como puede ver, las reglas de validación se pasan al método `validate`. No te preocupes - todas las reglas de validación disponibles están [documentadas](#available-validation-rules). De nuevo, si la validación falla, se generará automáticamente la respuesta adecuada. Si la validación pasa, nuestro controlador continuará ejecutándose de manera normal.

De manera alternativa, las reglas de validación pueden especificarse como arrays de reglas en lugar de una única cadena delimitada por `|`:

    $validatedData = $request->validate([
        'title' => ['required', 'unique:posts', 'max:255'],
        'body' => ['required'],
    ]);

Además, puedes utilizar el método `validateWithBag` para validar una petición y almacenar cualquier mensaje de error dentro de una [bolsa de error con nombre](#named-error-bags):

    $validatedData = $request->validateWithBag('post', [
        'title' => ['required', 'unique:posts', 'max:255'],
        'body' => ['required'],
    ]);

<a name="stopping-on-first-validation-failure"></a>
#### Parar al primer fallo de validación

A veces puede que desees detener la ejecución de reglas de validación en un atributo después del primer fallo de validación. Para ello, asigne la regla `bail` al atributo:

    $request->validate([
        'title' => 'bail|required|unique:posts|max:255',
        'body' => 'required',
    ]);

En este ejemplo, si falla la regla `unique` en el atributo `title`, no se comprobará la regla `max`. Las reglas se validarán en el orden en que se asignen.

<a name="a-note-on-nested-attributes"></a>
#### Nota sobre atributos anidados

Si la petición HTTP entrante contiene datos de campo "anidados", puede especificar estos campos en sus reglas de validación utilizando la sintaxis "dot":

    $request->validate([
        'title' => 'required|unique:posts|max:255',
        'author.name' => 'required',
        'author.description' => 'required',
    ]);

Por otro lado, si el nombre del campo contiene un punto literal, puede evitar explícitamente que se interprete como sintaxis de "punto" escapando del punto con una barra invertida:

    $request->validate([
        'title' => 'required|unique:posts|max:255',
        'v1\.0' => 'required',
    ]);

<a name="quick-displaying-the-validation-errors"></a>
### Mostrando los errores de validación

Entonces, ¿qué ocurre si los campos de la petición entrante no superan las reglas de validación? Como se mencionó anteriormente, Laravel redirigirá automáticamente al usuario a su ubicación anterior. Además, todos los errores de validación y de entrada de [la solicitud](/docs/{{version}}/requests#retrieving-old-input) se pasarán automáticamente [a la sesión](/docs/{{version}}/session#flash-data).

Una variable `$errors` es compartida con todas las vistas de tu aplicación por el middleware `Illuminate\View\middleware\ShareErrorsFromSession`, que es proporcionado por el grupo de middleware `web`. Cuando se aplica este middleware, una variable `$errors` estará siempre disponible en tus vistas, permitiéndote asumir convenientemente que la variable `$errors` está siempre definida y puede ser utilizada con seguridad. La variable `$errors` será una instancia de `Illuminate\Support\MessageBag`. Para más información sobre cómo trabajar con este objeto, consulte [su documentación](#working-with-error-messages).

Así, en nuestro ejemplo, el usuario será redirigido al método `create` de nuestro controlador cuando falle la validación, permitiéndonos mostrar los mensajes de error en la vista:

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

<a name="quick-displaying-the-validation-errors"></a>
#### Personalización de los mensajes de error

Cada una de las reglas de validación de Laravel tiene un mensaje de error que se encuentra en el fichero `lang/en/validation.php` de tu aplicación. Dentro de este archivo, encontrarás una entrada de traducción para cada regla de validación. Puede cambiar o modificar estos mensajes en función de las necesidades de su aplicación.

Además, puede copiar este archivo a otro directorio de idioma de traducción para traducir los mensajes para el idioma de su aplicación. Para aprender más sobre la localización de Laravel, consulta la [documentación sobre localización](/docs/{{version}}/localization).

<a name="quick-xhr-requests-and-validation"></a>
#### Peticiones XHR y validación

En este ejemplo, hemos utilizado un formulario tradicional para enviar datos a la aplicación. Sin embargo, muchas aplicaciones reciben peticiones XHR desde un frontend con JavaScript. Cuando se utiliza el método `validate` durante una petición XHR, Laravel no generará una respuesta de redirección. En su lugar, Laravel genera una [respuesta JSON que contiene todos los errores de validación](#validation-error-response-format). Esta respuesta JSON se enviará con un código de estado HTTP 422.

<a name="the-at-error-directive"></a>
#### La directiva `@error`

Puedes utilizar la directiva `@error`de [Blade](/docs/{{version}}/blade) para determinar rápidamente si existen mensajes de error de validación para un atributo dado. Dentro de una directiva `@error`, tienes la variable `$message` para mostrar el mensaje de error:

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

Si está utilizando ["bolsas de error con nombre"](#named-error-bags), puede pasar el nombre de la bolsa de error como segundo argumento a la directiva `@error`:

```blade
<input ... class="@error('title', 'post') is-invalid @enderror">
```

<a name="repopulating-forms"></a>
### Repoblación de formularios

Cuando Laravel genera una respuesta de redirección debido a un error de validación, el framework automáticamente [copiará todos los datos de entrada de la petición a la sesión](/docs/{{version}}/session#flash-data). Esto se hace para que pueda acceder de forma sencilla a los datos del formulario durante la siguiente solicitud y así volver a repoblar los campos que el usuario intentó enviar.

Para recuperar la entrada de la solicitud anterior, invoque el método `old` en una instancia de `Illuminate\Http\Request`. El método `old` extraerá los datos de entrada copiados previamente en la [sesión](/docs/{{version}}/session):

    $title = $request->old('title');

Laravel también proporciona un ayudante global `old`. Si está mostrando entradas antiguas dentro de una [plantilla Blade](/docs/{{version}}/blade), es más conveniente utilizar el helper `old` para repoblar el formulario. Si no existe ninguna entrada antigua para el campo dado, se devolverá `null`:

```blade
<input type="text" name="title" value="{{ old('title') }}">
```

<a name="a-note-on-optional-fields"></a>
### Nota sobre los campos opcionales

Por defecto, Laravel incluye los middleware `TrimStrings` y `ConvertEmptyStringsToNull` en la pila global de middleware de tu aplicación. Estos middleware son listados en la pila por la clase `App\Http\Kernel`. Debido a esto, a menudo necesitará marcar sus campos de petición "opcionales" como `nullable` si no quiere que el validador considere los valores `null` como inválidos. Por ejemplo:

    $request->validate([
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
        'publish_at' => 'nullable|date',
    ]);

En este ejemplo, estamos especificando que el campo `publish_at` puede ser `null` o una representación de fecha válida. Si no se añade el modificador `nullable` a la definición de la regla, el validador considerará `null` como una fecha inválida.

<a name="validation-error-response-format"></a>
### Formato de respuesta de error de validación

Cuando su aplicación lanza una excepción `Illuminate\Validation\ValidationException` y la solicitud HTTP entrante está esperando una respuesta JSON, Laravel formateará automáticamente los mensajes de error para usted y devolverá una respuesta HTTP `422 Unprocessable Entity`.

A continuación, puede revisar un ejemplo del formato de respuesta JSON para errores de validación. Tenga en cuenta que las claves de error anidadas se aplanan en formato de notación "punto":

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
## Validación de solicitudes de formulario

<a name="creating-form-requests"></a>
### Creación de peticiones de formulario

Para escenarios de validación más complejos, es posible que desee crear una "solicitud de formulario". Las peticiones de formulario (o `FormRequest`) son clases de petición personalizadas que encapsulan su propia lógica de validación y autorización. Para crear una clase de solicitud de formulario, puede utilizar el comando CLI de Artisan `make:request`:

```shell
php artisan make:request StorePostRequest
```

La clase de petición de formulario (`FormRequest`) generada se colocará en el directorio `app/Http/Requests` y extenderá a la clase `Illuminate\Foundation\Http\FormRequest`. Si este directorio no existe, se creará cuando ejecutes el comando `make:request`. Cada solicitud de formulario generada por Laravel tiene dos métodos: `authorize` y `rules`.

Como habrás adivinado, el método `authorize` se encarga de determinar si el usuario autenticado actualmente puede realizar la acción representada por la petición, mientras que el método `rules` devuelve las reglas de validación que deben aplicarse a los datos de la petición:

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    public function rules()
    {
        return [
            'title' => 'required|unique:posts|max:255',
            'body' => 'required',
        ];
    }

> **Nota**  
> Puedes añadir cualquier dependencia que necesites como parámetro del método de `rules`. Estas serán automáticamente resueltas a través del [contenedor de servicios](/docs/{{version}}/container) de Laravel.

¿Cómo se evalúan las reglas de validación? Todo lo que necesitas hacer es escribir la petición en el método de tu controlador. La petición entrante es validada antes de que el método del controlador sea llamado, lo que significa que no necesitas saturar tu controlador con ninguna lógica de validación:

    /**
     * Store a new blog post.
     *
     * @param  \App\Http\Requests\StorePostRequest  $request
     * @return Illuminate\Http\Response
     */
    public function store(StorePostRequest $request)
    {
        // The incoming request is valid...

        // Retrieve the validated input data...
        $validated = $request->validated();

        // Retrieve a portion of the validated input data...
        $validated = $request->safe()->only(['name', 'email']);
        $validated = $request->safe()->except(['name', 'email']);
    }

Si la validación falla, se generará una respuesta de redirección para enviar al usuario de vuelta a su ubicación anterior. Los errores también se mostrarán en la sesión para que estén disponibles para su visualización. Si la solicitud era una solicitud XHR, se devolverá al usuario una respuesta HTTP con un código de estado 422 que incluirá una [representación JSON de los errores de validación](#validation-error-response-format).

<a name="adding-after-hooks-to-form-requests"></a>
#### Usar el Hook de Validación Posterior en las Peticiones de Formulario

Si quieres utilizar el hook de validación posterior (hook `after`) en una petición de formulario, puedes utilizar el método `withValidator`. Este método recibe el validador desde el contendor de dependencias permitiéndote llamar a cualquiera de sus métodos antes de que las reglas de validación sean evaluadas. El hook `after` te permite ejecutar fácilmente validación adicional e incluso agregar más mensajes de error a la colección de mensajes :

    /**
     * Configure the validator instance.
     *
     * @param  \Illuminate\Validation\Validator  $validator
     * @return void
     */
    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            if ($this->somethingElseIsInvalid()) {
                $validator->errors()->add('field', 'Something is wrong with this field!');
            }
        });
    }


<a name="request-stopping-on-first-validation-rule-failure"></a>
#### Deteniendo el Atributo en el Primer Fallo de Validación

Añadiendo una propiedad `stopOnFirstFailure` a tu clase de validación, puedes informar al validador de que debe dejar de validar todos los atributos una vez que se ha producido un único fallo de validación:

    /**
     * Indicates if the validator should stop on the first rule failure.
     *
     * @var bool
     */
    protected $stopOnFirstFailure = true;

<a name="customizing-the-redirect-location"></a>
#### Personalizar la URL de la redirección

Como se ha comentado anteriormente, se generará una respuesta de redirección para devolver al usuario a su ubicación anterior cuando falle la validación de la solicitud del formulario. Sin embargo, puede personalizar este comportamiento. Para ello, defina una propiedad `$redirect` en su clase de validación:

    /**
     * The URI that users should be redirected to if validation fails.
     *
     * @var string
     */
    protected $redirect = '/dashboard';

O, si desea redirigir a los usuarios a una ruta con nombre, puede definir una propiedad `$redirectRoute` en su lugar:

    /**
     * The route that users should be redirected to if validation fails.
     *
     * @var string
     */
    protected $redirectRoute = 'dashboard';

<a name="authorizing-form-requests"></a>
### Autorizando Form Requests

La clase form requests también contiene un método `authorize`. Dentro de este método, puedes determinar si el usuario autenticado tiene realmente la autoridad para actualizar un recurso dado. Por ejemplo, puede determinar si un usuario es realmente el propietario de un comentario del blog que está intentando actualizar. Lo más probable es que interactúes con tus [gates y policies de autorización](/docs/{{version}}/authorization) dentro de este método:

    use App\Models\Comment;

    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        $comment = Comment::find($this->route('comment'));

        return $comment && $this->user()->can('update', $comment);
    }

Dado que todas las peticiones de formulario extienden de la clase base request de Laravel, podemos utilizar el método `user` para acceder al usuario autenticado en ese momento. Observe también la llamada al método `route` en el ejemplo anterior. Este método permite acceder a los parámetros URI definidos en la ruta a la que se llama, como el parámetro `{comment}` del ejemplo siguiente:

    Route::post('/comment/{comment}');

Por lo tanto, si su aplicación está aprovechando la [vinculación del modelo de ruta](/docs/{{version}}/routing#route-model-binding), su código puede ser aún más conciso accediendo al modelo resuelto como una propiedad de la solicitud:

    return $this->user()->can('update', $this->comment);

Si el método `authorize` devuelve `false`, se devolverá automáticamente una respuesta HTTP con un código de estado 403 y el método de su controlador no se ejecutará.

Si planea manejar la lógica de autorización para la solicitud en otra parte de su aplicación, puede simplemente devolver `true` desde el método `authorize`:

    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        return true;
    }

> **Nota**  
> Puedes añadir cualquier dependencia que necesites como parámetro del método de `authorize`. Se resolverán automáticamente a través del [contenedor de servicios](/docs/{{version}}/container) de Laravel.

<a name="customizing-the-error-messages"></a>
### Personalización de los mensajes de error

Puede personalizar los mensajes de error utilizados por el formulario de petición sobreescribiendo el método `messages`. Este método debe devolver un array de pares atributo / regla y sus correspondientes mensajes de error:

    /**
     * Get the error messages for the defined validation rules.
     *
     * @return array
     */
    public function messages()
    {
        return [
            'title.required' => 'A title is required',
            'body.required' => 'A message is required',
        ];
    }

<a name="customizing-the-validation-attributes"></a>
#### Personalizando los atributos de validación

Muchos de los mensajes de error de las reglas de validación de Laravel contienen un marcador de posición `:attribute`. Si desea que el marcador de posición `:attribute` de su mensaje de validación sea reemplazado por un nombre de atributo personalizado, puede especificar los nombres personalizados sobreescribiendo el método `attributes`. Este método debe devolver un array de pares atributo / nombre:

    /**
     * Get custom attributes for validator errors.
     *
     * @return array
     */
    public function attributes()
    {
        return [
            'email' => 'email address',
        ];
    }

<a name="preparing-input-for-validation"></a>
### Preparación de la entrada para la validación

Si necesitas preparar o limpiar cualquier dato de la petición antes de aplicar las reglas de validación, puedes utilizar el método `prepareForValidation`:

    use Illuminate\Support\Str;

    /**
     * Prepare the data for validation.
     *
     * @return void
     */
    protected function prepareForValidation()
    {
        $this->merge([
            'slug' => Str::slug($this->slug),
        ]);
    }

<a name="manually-creating-validators"></a>
## Creación manual de validadores

Si no quieres utilizar el método `validate` en la petición, puedes crear una instancia de validador manualmente utilizando la [facade](/docs/{{version}}/facades) `Validator`. El método `make` de la facade genera una nueva instancia de validador:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Validator;

    class PostController extends Controller
    {
        /**
         * Store a new blog post.
         *
         * @param  Request  $request
         * @return Response
         */
        public function store(Request $request)
        {
            $validator = Validator::make($request->all(), [
                'title' => 'required|unique:posts|max:255',
                'body' => 'required',
            ]);

            if ($validator->fails()) {
                return redirect('post/create')
                            ->withErrors($validator)
                            ->withInput();
            }

            // Retrieve the validated input...
            $validated = $validator->validated();

            // Retrieve a portion of the validated input...
            $validated = $validator->safe()->only(['name', 'email']);
            $validated = $validator->safe()->except(['name', 'email']);

            // Store the blog post...
        }
    }

El primer argumento pasado al método `make` son los datos bajo validación. El segundo argumento es un array de las reglas de validación que deben aplicarse a los datos.

Después de determinar si la validación de la petición ha fallado, puede utilizar el método `withErrors` para mostrar los mensajes de error en la sesión. Al usar este método, la variable `$errors` será automáticamente compartida con sus vistas después de la redirección, permitiendo que los muestre fácilmente al usuario. El método `withErrors` acepta un validador, un `MessageBag`, o un `array` PHP.

#### Parar al primer fallo de validación

El método `stopOnFirstFailure` informará al validador de que debe dejar de validar todos los atributos una vez que se haya producido un único fallo de validación:

    if ($validator->stopOnFirstFailure()->fails()) {
        // ...
    }

<a name="manually-creating-validators"></a>
### Redirección automática

Si quieres crear una instancia de validador manualmente pero aprovechar la redirección automática ofrecida por el método `validate` de la petición HTTP, puedes llamar al método `validate` en la instancia de validador. Si la validación falla, el usuario será redirigido automáticamente o, en el caso de una petición XHR, se [devolverá una respuesta JSON](#validation-error-response-format):

    Validator::make($request->all(), [
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
    ])->validate();

Puedes utilizar el método `validateWithBag` para almacenar los mensajes de error en una [bolsa de error](#named-error-bags) si la validación falla:

    Validator::make($request->all(), [
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
    ])->validateWithBag('post');

<a name="named-error-bags"></a>
### Bolsas de error con nombre

Si tiene múltiples formularios en una sola página, puede desear nombrar el `MessageBag` que contiene los errores de validación, permitiéndole recuperar los mensajes de error para un formulario específico. Para conseguirlo, pase un nombre como segundo argumento a `withErrors`:

    return redirect('register')->withErrors($validator, 'login');

Entonces puede acceder a la instancia `MessageBag` nombrada desde la variable `$errors`:

```blade
{{ $errors->login->first('email') }}
```

<a name="manual-customizing-the-error-messages"></a>
### Personalización de los mensajes de error

Si es necesario, puedes le puedes pasar tus propios mensajes de error a un validador, éste los utilizará en lugar de los que ofrece Laravel de manera predeterminada. Hay varias formas de especificar mensajes personalizados. En primer lugar, puedes pasar los mensajes personalizados como tercer argumento al método `Validator::make`:

    $validator = Validator::make($input, $rules, $messages = [
        'required' => 'The :attribute field is required.',
    ]);

En este ejemplo, el marcador de posición `:attribute` será reemplazado por el nombre real del campo bajo validación. También puede utilizar otros marcadores de posición en los mensajes de validación. Por ejemplo

    $messages = [
        'same' => 'The :attribute and :other must match.',
        'size' => 'The :attribute must be exactly :size.',
        'between' => 'The :attribute value :input is not between :min - :max.',
        'in' => 'The :attribute must be one of the following types: :values',
    ];

<a name="specifying-a-custom-message-for-a-given-attribute"></a>
#### Especificar un mensaje personalizado para un atributo determinado

A veces puede que desee especificar un mensaje de error personalizado sólo para un atributo específico. Para ello, utilice la notación "punto". Especifique primero el nombre del atributo, seguido de la regla:

    $messages = [
        'email.required' => 'We need to know your email address!',
    ];

<a name="specifying-custom-attribute-values"></a>
#### Especificar valores de atributo personalizados

Muchos de los mensajes de error incorporados en Laravel incluyen un marcador de posición `:attribute` que es reemplazado por el nombre del campo o atributo bajo validación. Para personalizar los valores utilizados para reemplazar estos marcadores de posición de campos específicos, puedes pasar un array de atributos personalizados como cuarto argumento al método `Validator::make`:

    $validator = Validator::make($input, $rules, $messages, [
        'email' => 'email address',
    ]);

<a name="after-validation-hook"></a>
### Hook de validación posterior

También puedes adjuntar callbacks para que se ejecuten una vez la validación se ha completado. Esto te permite realizar validaciones adicionales e incluso añadir más mensajes de error a la colección de mensajes. Para empezar, llama al método `after` en una instancia del validador:

    $validator = Validator::make(/* ... */);

    $validator->after(function ($validator) {
        if ($this->somethingElseIsInvalid()) {
            $validator->errors()->add(
                'field', 'Something is wrong with this field!'
            );
        }
    });

    if ($validator->fails()) {
        //
    }

<a name="working-with-validated-input"></a>
## Trabajar con datos validados

Después de validar los datos entrantes de la petición utilizando un formulario o una instancia de validador creada manualmente, puede que desee recuperar los datos entrantes de la petición que fueron validados. Esto se puede hacer de varias maneras. En primer lugar, puede llamar al método `validated` en una petición de formulario o instancia de validador. Este método devuelve un array de los datos que fueron validados:

    $validated = $request->validated();

    $validated = $validator->validated();

De manera alternativa, puede llamar al método `safe` en una petición de formulario o instancia de validador. Este método devuelve una instancia de `Illuminate\Support\ValidatedInput`. Este objeto expone los métodos `only`, `except` y `all` para recuperar un subconjunto de los datos validados o el array completo de datos validados:

    $validated = $request->safe()->only(['name', 'email']);

    $validated = $request->safe()->except(['name', 'email']);

    $validated = $request->safe()->all();

Además, se puede iterar sobre la instancia `Illuminate\Support\ValidatedInput` y acceder a ella como a un array:

    // Validated data may be iterated...
    foreach ($request->safe() as $key => $value) {
        //
    }

    // Validated data may be accessed as an array...
    $validated = $request->safe();

    $email = $validated['email'];

Si desea añadir campos adicionales a los datos validados, puede llamar al método `merge`:

    $validated = $request->safe()->merge(['name' => 'Taylor Otwell']);

Si desea recuperar los datos validados como una instancia de [colección](/docs/{{version}}/collections), puede llamar al método `collect`:

    $collection = $request->safe()->collect();

<a name="working-with-error-messages"></a>
## Trabajar con mensajes de error

Después de llamar al método `errors` en una instancia `Validator`, recibirá una instancia `Illuminate\Support\MessageBag`, que tiene una variedad de métodos convenientes para trabajar con mensajes de error. La variable `$errors` que se pone automáticamente a disposición de todas las vistas es también una instancia de la clase `MessageBag`.

<a name="retrieving-the-first-error-message-for-a-field"></a>
#### Cómo recuperar el primer mensaje de error de un campo

Para recuperar el primer mensaje de error de un campo determinado, utilice el método `first`:

    $errors = $validator->errors();

    echo $errors->first('email');

<a name="retrieving-all-error-messages-for-a-field"></a>
#### Obtener todos los mensajes de error de un campo

Si necesita recuperar array array con todos los mensajes de un campo determinado, utilice el método `get`:

    foreach ($errors->get('email') as $message) {
        //
    }

Si está validando un array de campos de formulario, puede recuperar todos los mensajes de cada uno de los elementos de array utilizando el carácter `*`:

    foreach ($errors->get('attachments.*') as $message) {
        //
    }

<a name="retrieving-all-error-messages-for-all-fields"></a>
#### Recuperación de todos los mensajes de error de todos los campos

Para recuperar array array de todos los mensajes de todos los campos, utilice el método `all`:

    foreach ($errors->all() as $message) {
        //
    }

<a name="determining-if-messages-exist-for-a-field"></a>
#### Determinar si existen mensajes para un campo

El método `has` puede utilizarse para determinar si existe algún mensaje de error para un campo dado:

    if ($errors->has('email')) {
        //
    }

<a name="specifying-custom-messages-in-language-files"></a>
### Especificación de mensajes personalizados en archivos de idioma

Cada una de las reglas de validación de Laravel tiene un mensaje de error que se encuentra en el fichero `lang/en/validation.php` de tu aplicación. Dentro de este archivo, encontrarás una entrada de traducción para cada regla de validación. Puede cambiar o modificar estos mensajes en función de las necesidades de su aplicación.

Además, puede copiar este archivo a otro directorio de idioma de traducción para traducir los mensajes para el idioma de su aplicación. Para aprender más sobre las traducciones de Laravel, consulta la [documentación disponible](/docs/{{version}}/localization).

<a name="custom-messages-for-specific-attributes"></a>
#### Mensajes personalizados para atributos específicos

Puede personalizar los mensajes de error utilizados para determinadas combinaciones de atributos y reglas en los archivos de idioma de validación de su aplicación. Para ello, añada sus mensajes personalizados a el array `personalizada` del archivo de idioma `lang/xx/validation.php` de su aplicación:

    'custom' => [
        'email' => [
            'required' => 'We need to know your email address!',
            'max' => 'Your email address is too long!'
        ],
    ],

<a name="specifying-attribute-in-language-files"></a>
### Especificación de atributos en ficheros de idioma

Muchos de los mensajes de error integrados en Laravel incluyen un marcador de posición `:attribute` que se sustituye por el nombre del campo o atributo que se está validando. Si desea que la parte de `:attribute` del mensaje de validación se sustituya por un valor personalizado, puede especificar el nombre del atributo personalizado en el array `attributes` del archivo de idioma `lang/xx/validation.` php:

    'attributes' => [
        'email' => 'email address',
    ],

<a name="specifying-values-in-language-files"></a>
### Especificación de valores en ficheros de idioma

Algunos de los mensajes de error de las reglas de validación de Laravel contienen un marcador de posición `:value` que se sustituye por el valor actual del atributo de la petición. Sin embargo, ocasionalmente puede necesitar que la parte `:value` de su mensaje de validación sea reemplazada por una representación personalizada del valor. Por ejemplo, considere la siguiente regla que especifica que se requiere un número de tarjeta de crédito si `payment_type` tiene el valor `cc`:

    Validator::make($request->all(), [
        'credit_card_number' => 'required_if:payment_type,cc'
    ]);

Si esta regla de validación falla, producirá el siguiente mensaje de error:

```none
The credit card number field is required when payment type is cc.
```

En lugar de mostrar `cc` como valor del tipo de pago, puede especificar una representación del valor más fácil de usar en su archivo de idioma `lang/xx/validation.` php definiendo un array `valores`:

    'values' => [
        'payment_type' => [
            'cc' => 'credit card'
        ],
    ],

Después de definir este valor, la regla de validación producirá el siguiente mensaje de error:

```none
The credit card number field is required when payment type is credit card.
```

<a name="available-validation-rules"></a>
## Reglas de validación disponibles

A continuación se muestra una lista de todas las reglas de validación disponibles y su función:

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
[File](#rule-file)
[Filled](#rule-filled)
[Greater Than](#rule-gt)
[Greater Than Or Equal](#rule-gte)
[Image (File)](#rule-image)
[In](#rule-in)
[In Array](#rule-in-array)
[Integer](#rule-integer)
[IP Address](#rule-ip)
[JSON](#rule-json)
[Less Than](#rule-lt)
[Less Than Or Equal](#rule-lte)
[Lowercase](#rule-lowercase)
[MAC Address](#rule-mac)
[Max](#rule-max)
[Max Digits](#rule-max-digits)
[MIME Types](#rule-mimetypes)
[MIME Type By File Extension](#rule-mimes)
[Min](#rule-min)
[Min Digits](#rule-min-digits)
[Multiple Of](#rule-multiple-of)
[Not In](#rule-not-in)
[Not Regex](#rule-not-regex)
[Nullable](#rule-nullable)
[Numeric](#rule-numeric)
[Password](#rule-password)
[Present](#rule-present)
[Prohibited](#rule-prohibited)
[Prohibited If](#rule-prohibited-if)
[Prohibited Unless](#rule-prohibited-unless)
[Prohibits](#rule-prohibits)
[Regular Expression](#rule-regex)
[Required](#rule-required)
[Required If](#rule-required-if)
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
#### accepted

El campo bajo validación debe ser `"yes"`, " `on`", `1`, o `true`. Esto es útil para validar la aceptación de los "Términos de Servicio" o campos similares.

<a name="rule-accepted-if"></a>
#### accepted_if:anotherfield,value,...

El campo bajo validación debe ser `"`yes", `"`on", `1`, o `true` si otro campo bajo validación es igual a un valor especificado. Esto es útil para validar la aceptación de las "Condiciones del servicio" o campos similares.

<a name="rule-active-url"></a>
#### active_url

El campo bajo validación debe tener un registro A o AAAA válido según la función PHP `dns_get_record`. El nombre de host de la URL proporcionada es extraído usando la función PHP `parse_url` antes de ser pasado a `dns_get_record`.

<a name="rule-after"></a>
#### after:_date_

El campo validado debe ser posterior a una fecha determinada. Las fechas se pasarán a la función `strtotime` de PHP para convertirlas en una instancia `DateTime` válida:

    'start_date' => 'required|date|after:tomorrow'

En lugar de pasar una cadena de fecha para ser evaluada por `strtotime`, puede especificar otro campo para comparar con la fecha:

    'finish_date' => 'required|date|after:start_date'

<a name="rule-after-or-equal"></a>
#### after\_or\_equal:_date_

El campo sometido a validación debe ser un valor posterior o igual a la fecha dada. Para más información, consulte la regla [after](#rule-after).

<a name="rule-alpha"></a>
#### alpha

El campo sometido a validación debe estar compuesto en su totalidad por caracteres alfabéticos.

<a name="rule-alpha-dash"></a>
#### alpha_dash

El campo bajo validación puede tener caracteres alfanuméricos, así como guiones y guiones bajos.

<a name="rule-alpha-num"></a>
#### alpha_num

El campo validado debe contener caracteres alfanuméricos en su totalidad.

<a name="rule-array"></a>
#### array

El campo validado debe ser una `array` PHP.

Cuando se proporcionan valores adicionales a la regla `array`, cada clave del array de entrada debe estar presente en la lista de valores proporcionados a la regla. En el siguiente ejemplo, la clave `admin` de el array de entrada no es válida, ya que no se encuentra en la lista de valores proporcionada a la regla de `array`:

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

En general, debe especificar siempre las claves del array que están permitidas en tu array.

<a name="rule-ascii"></a>
#### ascii

El campo validado debe contener caracteres ASCII de 7 bits.

<a name="rule-bail"></a>
#### bail

Detiene la ejecución de reglas de validación para el campo tras el primer fallo de validación.

Mientras que la regla `bail` sólo dejará de validar un campo específico cuando encuentre un fallo de validación, el método `stopOnFirstFailure` informará al validador de que debe dejar de validar todos los atributos una vez que se haya producido un único fallo de validación:

    if ($validator->stopOnFirstFailure()->fails()) {
        // ...
    }

<a name="rule-before"></a>
#### before:_date_

El campo validado debe ser un valor anterior a la fecha indicada. Las fechas se pasarán a la función `strtotime` de PHP para convertirlas en una instancia `DateTime` válida. Además, como en la regla [`after`](#rule-after), el nombre de otro campo bajo validación puede ser suministrado como valor de `date`.

<a name="rule-before-or-equal"></a>
#### before\_or\_equal:_date_

El campo bajo validación debe ser un valor anterior o igual a la fecha dada. Las fechas se pasarán a la función `strtotime` de PHP para convertirlas en una instancia `DateTime` válida. Además, como en la regla [`after`](#rule-after), el nombre de otro campo bajo validación puede ser suministrado como valor de `date`.

<a name="rule-between"></a>
#### between:_min_,_max_

El campo validado debe tener un tamaño comprendido entre el _min_ y el _max_ (ambos inclusive). Las cadenas, los números, las arrays y los archivos se evalúan del mismo modo que la regla [`size`](#rule-size).

<a name="rule-boolean"></a>
#### boolean

El campo validado debe poder convertirse en booleano. Las entradas aceptadas son `true`, `false`, `1`, `0`, `"1"` y `"0"`.

<a name="rule-confirmed"></a>
#### confirmed

El campo validado debe tener un campo coincidente de `{field}_confirmación`. Por ejemplo, si el campo validado es `password`, debe haber un campo `password_confirmation` coincidente en la entrada.

<a name="rule-current-password"></a>
#### current_password

El campo validado debe coincidir con la contraseña del usuario autenticado. Puede especificar un [guarda de autenticación](/docs/{{version}}/authentication) utilizando el primer parámetro de la regla:

    'password' => 'current_password:api'

<a name="rule-date"></a>
#### date

El campo validado debe ser una fecha válida, no relativa, según la función `strtotime` de PHP.

<a name="rule-date-equals"></a>
#### date_equals:_date_

El campo validado debe ser igual a la fecha indicada. Las fechas se pasarán a la función `strtotime` de PHP para convertirlas en una instancia `DateTime` válida.

<a name="rule-date-format"></a>
#### date_format:_format_,...

El campo validado debe coincidir con uno de los _formatos_ indicados. Al validar un campo, debe **utilizar** `date` o `date_format`, no ambos. Esta regla de validación soporta todos los formatos soportados por la clase [DateTime](https://www.php.net/manual/en/class.datetime.php) de PHP.

<a name="rule-decimal"></a>
#### decimal:_min_,_max_

El campo validado debe ser numérico y contener el número de decimales especificado:

    // Must have exactly two decimal places (9.99)...
    'price' => 'decimal:2'

    // Must have between 2 and 4 decimal places...
    'price' => 'decimal:2,4'

<a name="rule-declined"></a>
#### declined

El campo bajo validación debe ser `"no"`, `"off"`, `0`, o `false`.

<a name="rule-declined-if"></a>
#### declined_if:anotherfield,value,...

El campo bajo validación debe ser `"no"`, `"off"`, `0`, o `false` si otro campo bajo validación es igual a un valor especificado.

<a name="rule-different"></a>
#### different:_field_

El campo validado debe tener un valor distinto de _field_.

<a name="rule-digits"></a>
#### digits:_value_

El entero sometido a validación debe tener una longitud exacta de _value_.

<a name="rule-digits-between"></a>
#### digits_between:_min_,_max_

El entero validado debe tener una longitud comprendida entre el _min_ y el _max_ dados.

<a name="rule-dimensions"></a>
#### dimensions

El archivo validado debe ser una imagen que cumpla las restricciones de dimensión especificadas en los parámetros de la regla:

    'avatar' => 'dimensions:min_width=100,min_height=200'

Las restricciones disponibles son: _min\_width_, _max\_width_, _min\_height_, _max\_height_, _width_, _height_, _ratio_.

Una restricción de _ratio_ debe representarse como la anchura dividida por la altura. Puede especificarse mediante una fracción, como `3/2`, o un valor flotante, como `1,5`:

    'avatar' => 'dimensions:ratio=3/2'

Dado que esta regla requiere varios argumentos, puede utilizar el método `Rule::dimensions` para construir la regla de forma fluida: 

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'avatar' => [
            'required',
            Rule::dimensions()->maxWidth(1000)->maxHeight(500)->ratio(3 / 2),
        ],
    ]);

<a name="rule-distinct"></a>
#### distinct

Al validar arrays, el campo validado no debe tener valores duplicados:

    'foo.*.id' => 'distinct'

Distinct utiliza por defecto comparaciones no estrictas de variables. Para utilizar comparaciones estrictas, puede añadir el parámetro `strict` a la definición de la regla de validación:

    'foo.*.id' => 'distinct:strict'

Puede añadir `ignore_case` a los argumentos de la regla de validación para que la regla ignore las diferencias de mayúsculas y minúsculas:

    'foo.*.id' => 'distinct:ignore_case'

<a name="rule-doesnt-start-with"></a>
#### doesnt_start_with:_foo_,_bar_,...

El campo validado no debe comenzar con uno de los valores indicados.

<a name="rule-doesnt-end-with"></a>
#### doesnt_end_with:_foo_,_bar_,...

El campo validado no debe terminar con uno de los valores indicados.

<a name="rule-email"></a>
#### email

El campo validado debe tener formato de dirección de correo electrónico. Esta regla de validación utiliza el paquete [`egulias/email-validator`](https://github.com/egulias/EmailValidator) para validar la dirección de correo electrónico. Por defecto, se aplica el validador `RFCValidation`, pero también se pueden aplicar otros estilos de validación:

    'email' => 'email:rfc,dns'

El ejemplo anterior aplicará las validaciones `RFCValidation` y `DNSCheckValidation`. Aquí tienes una lista completa de los estilos de validación que puedes aplicar:

<div class="content-list" markdown="1">

- `rfc`: `RFCValidation`
- `strict`: `NoRFCWarningsValidation`
- `dns`: `DNSCheckValidation`
- `spoof`: `SpoofCheckValidation`
- `filter`: `FilterEmailValidation`
- `filter_unicode`: `FilterEmailValidation::unicode()`

</div>

El validador de `filter`, que utiliza la función `filter_var` de PHP, se incluye con Laravel y era el comportamiento de validación de correo electrónico predeterminado de Laravel antes de la versión 5.8 de Laravel.

> **Advertencia**  
> Los validadores `dns` y `spoof` requieren la extensión `intl` de PHP.

<a name="rule-ends-with"></a>
#### ends_with:_foo_,_bar_,...

El campo bajo validación debe terminar con uno de los valores dados.

<a name="rule-enum"></a>
#### enum

La regla `Enum` es una regla basada en clases que valida si el campo bajo validación contiene un valor enum válido. La regla `Enum` acepta el nombre del enum como único argumento constructor:

    use App\Enums\ServerStatus;
    use Illuminate\Validation\Rules\Enum;

    $request->validate([
        'status' => [new Enum(ServerStatus::class)],
    ]);

> **Advertencia**  
> Los Enums sólo están disponibles en PHP 8.1+.

<a name="rule-exclude"></a>
#### exclude

El campo bajo validación será excluido de los datos de la petición devueltos por los métodos `validate` y `validated`.

<a name="rule-exclude-if"></a>
#### exclude_if:_anotherfield_,_value_

El campo bajo validación será excluido de los datos de la petición devueltos por los métodos `validate` y `validated` si el campo _anotherfield_ es igual a _value_.

Si se requiere una lógica de exclusión condicional compleja, puede utilizar el método `Rule::excludeIf`. Este método acepta un booleano o un closure. Cuando se le da un closure, el closure debe devolver `true` o `false` para indicar si el campo bajo validación debe ser excluido:

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($request->all(), [
        'role_id' => Rule::excludeIf($request->user()->is_admin),
    ]);

    Validator::make($request->all(), [
        'role_id' => Rule::excludeIf(fn () => $request->user()->is_admin),
    ]);

<a name="rule-exclude-unless"></a>
#### exclude_unless:_anotherfield_,_value_

El campo validado se excluirá de los datos devueltos por los métodos `validate` y `validated` a menos que el campo de _anotherfield_ sea igual a _value_. Si _value_ es `null` (`exclude_unless:name,null`), el campo validado se excluirá a menos que el campo de comparación sea `null` o falte en los datos de la solicitud.

<a name="rule-exclude-with"></a>
#### exclude_with:_anotherfield_

El campo validado se excluirá de los datos devueltos por los métodos `validate` y `validated` si el campo _anotherfield_ está presente.

<a name="rule-exclude-without"></a>
#### exclude_without:_anotherfield_

El campo validado se excluirá de los datos devueltos por los métodos `validate` y `validated` si el campo _anotherfield_ no está presente.

<a name="rule-exists"></a>
#### exists:_table_,_column_

El campo validado debe existir en una tabla determinada de la base de datos.

<a name="basic-usage-of-exists-rule"></a>
#### Basic Usage Of Exists Rule

    'state' => 'exists:states'

Si no se especifica la opción de `column`, se utilizará el nombre del campo. Así, en este caso, la regla validará que la tabla de base de datos `states` contiene un registro con un valor de columna de `state` que coincide con el valor del atributo de `state` de la petición.

<a name="specifying-a-custom-column-name"></a>
#### Specifying A Custom Column Name

Puede especificar explícitamente el nombre de la columna de la base de datos que debe utilizar la regla de validación colocándolo después del nombre de la tabla de la base de datos:

    'state' => 'exists:states,abbreviation'

Ocasionalmente, puede que necesite especificar una conexión de base de datos específica que se utilizará para la consulta `exists`. Para ello, anteponga el nombre de la conexión al nombre de la tabla:

    'email' => 'exists:connection.staff,email'

En lugar de especificar directamente el nombre de la tabla, puede especificar el modelo de Eloquent que debe utilizarse para determinar el nombre de la tabla:

    'user_id' => 'exists:App\Models\User,id'

Si deseas personalizar la consulta ejecutada por la regla de validación, puedes utilizar la clase `Rule` para definir la regla de forma fluida. En este ejemplo, también especificaremos las reglas de validación como un array en lugar de utilizar el carácter `|` para delimitarlas:

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'email' => [
            'required',
            Rule::exists('staff')->where(function ($query) {
                return $query->where('account_id', 1);
            }),
        ],
    ]);

Puede especificar explícitamente el nombre de la columna de la base de datos que debe utilizar la regla `exists` generada por el método `Rule::exists` proporcionando el nombre de la columna como segundo argumento del método `exists`:

    'state' => Rule::exists('states', 'abbreviation'),

<a name="rule-file"></a>
#### file

El campo bajo validación debe ser un archivo cargado correctamente.

<a name="rule-filled"></a>
#### filled

El campo bajo validación no debe estar vacío cuando esté presente.

<a name="rule-gt"></a>
#### gt:_field_

El campo bajo validación debe ser mayor que el _field_ dado. Los dos campos deben ser del mismo tipo. Las cadenas, los números, las arrays y los archivos se evalúan utilizando las mismas convenciones que la regla [`size`](#rule-size).

<a name="rule-gte"></a>
#### gte:_field_

El campo validado debe ser mayor o igual que el _field_ dado. Los dos campos deben ser del mismo tipo. Las cadenas, los números, las arrays y los archivos se evalúan utilizando las mismas convenciones que la regla [`size`](#rule-size).

<a name="rule-image"></a>
#### image

El archivo validado debe ser una imagen (jpg, jpeg, png, bmp, gif, svg o webp).

<a name="rule-in"></a>
#### in:_foo_,_bar_,...

El campo validado debe estar incluido en la lista de valores dada. Dado que esta regla a menudo requiere `implode` un array, puede utilizarse el método `Rule::in` para construir la regla de forma fluida:

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'zones' => [
            'required',
            Rule::in(['first-zone', 'second-zone']),
        ],
    ]);

Cuando la regla `in` se combina con la regla de `array`, cada valor del array de entrada debe estar presente en la lista de valores proporcionada a la regla `in`. En el siguiente ejemplo, el código de aeropuerto `LAS` del array de entrada no es válido, ya que no figura en la lista de aeropuertos proporcionada a la regla `in`:

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

<a name="rule-in-array"></a>
#### in_array:_anotherfield_.*

El campo validado debe existir en los valores de _anotherfield_.

<a name="rule-integer"></a>
#### integer

El campo validado debe ser un número entero.

> **Advertencia**  
> Esta regla de validación no verifica que la entrada sea del tipo de variable "integer", sólo que la entrada sea de un tipo aceptado por la regla `FILTER_VALIDATE_INT` de PHP. Si necesita validar la entrada como un número, por favor use esta regla en combinación con [la regla de validación `numeric`](#rule-numeric).

<a name="rule-ip"></a>
#### ip

El campo validado debe ser una dirección IP.

<a name="ipv4"></a>
#### ipv4

El campo validado debe ser una dirección IPv4.

<a name="ipv6"></a>
#### ipv6

El campo validado debe ser una dirección IPv6.

<a name="rule-json"></a>
#### json

El campo validado debe ser una cadena JSON válida.

<a name="rule-lt"></a>
#### lt:_field_

El campo bajo validación debe ser menor que el _field_ dado. Los dos campos deben ser del mismo tipo. Las cadenas, los números, las arrays y los archivos se evalúan utilizando las mismas convenciones que la regla [`size`](#rule-size).

<a name="rule-lte"></a>
#### lte:_field_

El campo validado debe ser menor o igual que el _field_ dado. Los dos campos deben ser del mismo tipo. Las cadenas, los números, las arrays y los archivos se evalúan con las mismas convenciones que la regla [`size`](#rule-size).

<a name="rule-lowercase"></a>
#### lowercase

El campo validado debe estar en minúsculas.

<a name="rule-mac"></a>
#### mac_address

El campo validado debe ser una dirección MAC.

<a name="rule-max"></a>
#### max:_value_

El campo validado debe ser menor o igual que un _value_ máximo. Las cadenas, los números, las arrays y los archivos se evalúan del mismo modo que la regla [`size`](#rule-size).

<a name="rule-max-digits"></a>
#### max_digits:_value_

El número entero validado debe tener una longitud máxima de _value_.

<a name="rule-mimetypes"></a>
#### mimetypes:_text/plain_,...

El archivo validado debe corresponder a uno de los tipos MIME indicados:

    'video' => 'mimetypes:video/avi,video/mpeg,video/quicktime'

Para determinar el tipo MIME del archivo cargado, se leerá el contenido del archivo y el framework intentará adivinar el tipo MIME, que puede ser diferente del tipo MIME proporcionado por el cliente.

<a name="rule-mimes"></a>
#### mimes:_foo_,_bar_,...

El archivo validado debe tener un tipo MIME correspondiente a una de las extensiones de la lista.

<a name="basic-usage-of-mime-rule"></a>
#### Uso básico de la regla MIME

    'photo' => 'mimes:jpg,bmp,png'

Aunque sólo necesita especificar las extensiones, esta regla realmente valida el tipo MIME del archivo leyendo el contenido del archivo y adivinando su tipo MIME. Puede encontrar una lista completa de los tipos MIME y sus correspondientes extensiones en la siguiente ubicación:

[https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types](https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types)

<a name="rule-min"></a>
#### min:_value_

El campo validado debe tener un _value_ mínimo. Las cadenas, los números, las arrays y los archivos se evalúan de la misma forma que la regla [`size`](#rule-size).

<a name="rule-min-digits"></a>
#### min_digits:_value_

El entero sometido a validación debe tener una longitud mínima de _value_.

<a name="rule-multiple-of"></a>
#### multiple_of:_value_

El campo validado debe ser múltiplo de _value_.

> **Advertencia**  
> Se requiere la [extensión PHP `bcmath`](https://www.php.net/manual/en/book.bc.php) para utilizar la regla `multiple_of`.

<a name="rule-not-in"></a>
#### not_in:_foo_,_bar_,...

El campo validado no debe estar incluido en la lista de valores dada. Se puede utilizar el método `Rule::notIn` para construir la regla de forma fluida:

    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'toppings' => [
            'required',
            Rule::notIn(['sprinkles', 'cherries']),
        ],
    ]);

<a name="rule-not-regex"></a>
#### not_regex:_pattern_

El campo validado no debe coincidir con la expresión regular dada.

Internamente, esta regla utiliza la función `preg_match` de PHP. El patrón especificado debe obedecer el mismo formato requerido por `preg_match` y por lo tanto también incluir delimitadores válidos. Por ejemplo: `'email' => 'not_regex:/^.+$/i'`.

> **Advertencia**  
> Al utilizar los patrones `regex` / `not_regex`, puede ser necesario especificar las reglas de validación mediante un array en lugar de utilizar delimitadores `|`, especialmente si la expresión regular contiene un carácter `|`.

<a name="rule-nullable"></a>
#### nullable

El campo validado puede ser `null`.

<a name="rule-numeric"></a>
#### numeric

El campo validado debe ser [numeric](https://www.php.net/manual/en/function.is-numeric.php).

<a name="rule-password"></a>
#### password

El campo validado debe coincidir con la contraseña del usuario autenticado.

> **Advertencia**  
> Esta regla fue renombrada a `current_password` con la intención de eliminarla en Laravel 9. Por favor, utilice la regla Current Password en su lugar. Por favor, utilice la regla [current_password](#rule-current-password) en su lugar.

<a name="rule-present"></a>
#### present

El campo validado debe estar presente en los datos de entrada, pero puede estar vacío.

<a name="rule-prohibited"></a>
#### prohibited

El campo objeto de validación debe ser una cadena vacía o no estar presente.

<a name="rule-prohibited-if"></a>
#### prohibited_if:_anotherfield_,_value_,...

El campo validado debe ser una cadena vacía o no estar presente si el campo _anotherfield_ es igual a cualquier _value_.

Si se requiere una lógica de prohibición condicional compleja, puede utilizar el método `Rule::prohibitedIf`. Este método acepta un booleano o un closure. Cuando se le da un closure, el closure debe devolver `true` o `false` para indicar si el campo bajo validación debe ser prohibido:

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($request->all(), [
        'role_id' => Rule::prohibitedIf($request->user()->is_admin),
    ]);

    Validator::make($request->all(), [
        'role_id' => Rule::prohibitedIf(fn () => $request->user()->is_admin),
    ]);

<a name="rule-prohibited-unless"></a>
#### prohibited_unless:_anotherfield_,_value_,...

El campo objeto de validación debe ser una cadena vacía o no estar presente a menos que el campo _anotherfield_ sea igual a cualquier _value_.

<a name="rule-prohibits"></a>
#### prohibits:_anotherfield_,...

Si el campo validado está presente, no puede haber ningún campo en _anotherfield_, aunque esté vacío.

<a name="rule-regex"></a>
#### regex:_pattern_

El campo bajo validación debe coincidir con la expresión regular dada.

Internamente, esta regla utiliza la función `preg_match` de PHP. El patrón especificado debe obedecer el mismo formato requerido por `preg_match` y por lo tanto también incluir delimitadores válidos. Por ejemplo: `'email' => 'regex:/^.+@.+$/i'`.

> **Advertencia**  
> Al utilizar los patrones `regex` / `not_regex`, puede ser necesario especificar las reglas en un array en lugar de utilizar delimitadores `|`, especialmente si la expresión regular contiene un carácter `|`.

<a name="rule-required"></a>
#### required

El campo bajo validación debe estar presente en los datos de entrada y no vacío. Un campo se considera "vacío" si una de las siguientes condiciones es cierta:

<div class="content-list" markdown="1">

- El valor es `null`.
- El valor es una cadena vacía.
- El valor es un array vacío o un objeto `Countable` vacío.
- El valor es un archivo cargado sin ruta.

</div>

<a name="rule-required-if"></a>
#### required_if:_anotherfield_,_value_,...

El campo bajo validación debe estar presente y no vacío si el campo _anotherfield_ es igual a cualquier _value_.

Si desea construir una condición más compleja para la regla `required_if`, puede utilizar el método `Rule::requiredIf`. Este método acepta un booleano o un closure. Cuando se le pasa un closure, el closure debe devolver `true` o `false` para indicar si el campo bajo validación es requerido:

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($request->all(), [
        'role_id' => Rule::requiredIf($request->user()->is_admin),
    ]);

    Validator::make($request->all(), [
        'role_id' => Rule::requiredIf(fn () => $request->user()->is_admin),
    ]);

<a name="rule-required-unless"></a>
#### required_unless:_anotherfield_,_value_,...

El campo validado debe estar presente y no vacío a menos que el campo _anotherfield_ sea igual a cualquier _value_. Esto también significa que _anotherfield_ debe estar presente en los datos de la solicitud a menos que _value_ sea `null`. Si el _value_ es `null` (`required_unless:name,null`), el campo validado será obligatorio a menos que el campo de comparación sea `null` o no aparezca en los datos de la solicitud.

<a name="rule-required-with"></a>
#### required_with:_foo_,_bar_,...

El campo validado debe estar presente y no vacío _sólo si_ alguno de los otros campos especificados está presente y no vacío.

<a name="rule-required-with-all"></a>
#### required_with_all:_foo_,_bar_,...

El campo validado debe estar presente y no vacío _sólo si_ todos los demás campos especificados están presentes y no están vacíos.

<a name="rule-required-without"></a>
#### required_without:_foo_,_bar_,...

El campo validado debe estar presente y no vacío _sólo si_ alguno de los otros campos especificados está vacío o no está presente.

<a name="rule-required-without-all"></a>
#### required_without_all:_foo_,_bar_,...

El campo sometido a validación debe estar presente y no vacío _sólo_cuando_ todos los demás campos especificados estén vacíos o no estén presentes.

<a name="rule-required-array-keys"></a>
#### required_array_keys:_foo_,_bar_,...

El campo validado debe ser un array y contener al menos las claves especificadas.

<a name="rule-same"></a>
#### same:_field_

El _field_ especificado debe coincidir con el campo validado.

<a name="rule-size"></a>
#### size:_value_

El campo validado debe tener un tamaño que coincida con el _value_ indicado. Para los datos de cadena, el _value_ corresponde al número de caracteres. Para los datos numéricos, el _value_ corresponde a un valor entero dado (el atributo también debe tener la regla `numeric` o `integer` ). Para un array, el _tamaño_ corresponde al `count` del array. Para los ficheros, el _tamaño_ corresponde al tamaño del fichero en kilobytes. Veamos algunos ejemplos:

    // Validate that a string is exactly 12 characters long...
    'title' => 'size:12';

    // Validate that a provided integer equals 10...
    'seats' => 'integer|size:10';

    // Validate that an array has exactly 5 elements...
    'tags' => 'array|size:5';

    // Validate that an uploaded file is exactly 512 kilobytes...
    'image' => 'file|size:512';

<a name="rule-starts-with"></a>
#### starts_with:_foo_,_bar_,...

El campo validado debe comenzar por uno de los valores indicados.

<a name="rule-string"></a>
#### string

El campo validado debe ser una cadena. Si desea permitir que el campo también sea `null`, debe asignar la regla `nullable` al campo.

<a name="rule-timezone"></a>
#### timezone

El campo validado debe ser un identificador de zona horaria válido según la función PHP `timezone_identifiers_list`.

<a name="rule-unique"></a>
#### unique:_table_,_column_

El campo validado no debe existir en la tabla de base de datos indicada.

**Especificación de un nombre de tabla / columna personalizado:**

En lugar de especificar directamente el nombre de la tabla, puede especificar el modelo Eloquent que debe utilizarse para determinar el nombre de la tabla:

    'email' => 'unique:App\Models\User,email_address'

La opción `column` puede utilizarse para especificar la columna de base de datos correspondiente al campo. Si no se especifica la opción `column`, se utilizará el nombre del campo validado.

    'email' => 'unique:users,email_address'

**Especificar una conexión de base de datos personalizada**

Ocasionalmente, puede ser necesario establecer una conexión personalizada para las consultas a la base de datos realizadas por el Validador. Para ello, puede anteponer el nombre de la conexión al nombre de la tabla:

    'email' => 'unique:connection.users,email_address'

**Forzar una regla única para ignorar un ID dado:**

A veces, es posible que desee ignorar un ID dado durante la validación única. Por ejemplo, considere una pantalla de "actualización de perfil" que incluya el nombre, la dirección de correo electrónico y la ubicación del usuario. Probablemente querrá verificar que la dirección de correo electrónico es única. Sin embargo, si el usuario sólo cambia el campo del nombre y no el del correo electrónico, no querrá que se produzca un error de validación porque el usuario ya es el propietario de la dirección de correo electrónico en cuestión.

Para indicar al validador que ignore el ID del usuario, utilizaremos la clase `Rule` para definir la regla de forma fluida. En este ejemplo, también especificaremos las reglas de validación como un array en lugar de utilizar el carácter `|` para delimitar las reglas:

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'email' => [
            'required',
            Rule::unique('users')->ignore($user->id),
        ],
    ]);

> **Advertencia**  
> Nunca debes pasar ninguna entrada de solicitud controlada por el usuario al método `ignore`. En su lugar, sólo debes pasar un ID único generado por el sistema, como un ID auto-incrementado o UUID de una instancia de modelo de Eloquent. De lo contrario, tu aplicación será vulnerable a un ataque de inyección SQL.

En lugar de pasar el valor de la clave del modelo al método `ignore`, también puedes pasar la instancia completa del modelo. Laravel extraerá automáticamente la clave del modelo:

    Rule::unique('users')->ignore($user)

Si tu tabla utiliza un nombre de columna de clave primaria distinto de `id`, puedes especificar el nombre de la columna al llamar al método `ignore`:

    Rule::unique('users')->ignore($user->id, 'user_id')

Por defecto, la regla `unique` comprobará la unicidad de la columna que coincida con el nombre del atributo que se está validando. Sin embargo, puede pasar un nombre de columna diferente como segundo argumento al método `unique`:

    Rule::unique('users', 'email_address')->ignore($user->id),

**Adición de cláusulas Where adicionales:**

Puede especificar condiciones de consulta adicionales personalizando la consulta utilizando el método `where`. Por ejemplo, vamos a añadir una condición de consulta que sólo busque registros que tengan el valor `1` en la columna `account_id`:

    'email' => Rule::unique('users')->where(fn ($query) => $query->where('account_id', 1))

<a name="rule-uppercase"></a>
#### uppercase

El campo validado debe estar en mayúsculas.

<a name="rule-url"></a>
#### url

El campo validado debe ser una URL válida.
 
<a name="rule-ulid"></a>
#### ulid

El campo sometido a validación debe ser un [Identificador Único Universal Clasificable Lexicográficamente](https://github.com/ulid/spec) (ULID) válido.

<a name="rule-uuid"></a>
#### uuid

El campo validado debe ser un identificador único universal (UUID) RFC 4122 (versión 1, 3, 4 o 5) válido.

<a name="conditionally-adding-rules"></a>
## Reglas de adición condicional

<a name="skipping-validation-when-fields-have-certain-values"></a>
#### Omitir la validación cuando los campos tienen determinados valores

Puede que en ocasiones desee no validar un campo determinado si otro campo tiene un valor determinado. Puede conseguirlo utilizando la regla de validación `exclude_if`. En este ejemplo, los campos `appointment_date` y `doctor_name` no se validarán si el campo `has_appointment` tiene un valor `false`:

    use Illuminate\Support\Facades\Validator;

    $validator = Validator::make($data, [
        'has_appointment' => 'required|boolean',
        'appointment_date' => 'exclude_if:has_appointment,false|required|date',
        'doctor_name' => 'exclude_if:has_appointment,false|required|string',
    ]);

De manera alternativa, puede utilizar la regla `exclude_unless` para no validar un campo dado a menos que otro campo tenga un valor dado:

    $validator = Validator::make($data, [
        'has_appointment' => 'required|boolean',
        'appointment_date' => 'exclude_unless:has_appointment,true|required|date',
        'doctor_name' => 'exclude_unless:has_appointment,true|required|string',
    ]);

<a name="validating-when-present"></a>
#### Validación cuando está presente

En algunas situaciones, puede que desee ejecutar comprobaciones de validación en un campo **sólo** si dicho campo está presente en los datos que se están validando. Para conseguirlo rápidamente, añada la regla `sometimes` a su lista de reglas:

    $v = Validator::make($data, [
        'email' => 'sometimes|required|email',
    ]);

En el ejemplo anterior, el campo `email` sólo se validará si está presente en el array `$data`.

> **Nota**  
> Si está intentando validar un campo que debería estar siempre presente pero puede estar vacío, consulte [esta nota sobre campos opcionales](#a-note-on-optional-fields).

<a name="complex-conditional-validation"></a>
#### Validación condicional compleja

A veces puede que desee añadir reglas de validación basadas en una lógica condicional más compleja. Por ejemplo, puede que desee requerir un campo dado sólo si otro campo tiene un valor mayor que 100. O puede que necesite dos campos para validar un campo. O puede necesitar que dos campos tengan un valor determinado sólo cuando otro campo esté presente. Añadir estas reglas de validación no tiene por qué ser un engorro. Primero, crea una instancia de `Validator` con tus _reglas estáticas_ que nunca cambian:

    use Illuminate\Support\Facades\Validator;

    $validator = Validator::make($request->all(), [
        'email' => 'required|email',
        'games' => 'required|numeric',
    ]);

Supongamos que nuestra aplicación web es para coleccionistas de juegos. Si un coleccionista de juegos se registra en nuestra aplicación y posee más de 100 juegos, queremos que explique por qué posee tantos juegos. Por ejemplo, puede que tengan una tienda de reventa de juegos o que simplemente les guste coleccionarlos. Para añadir condicionalmente este requisito, podemos utilizar el método `sometimes` en la instancia `Validator`.

    $validator->sometimes('reason', 'required|max:500', function ($input) {
        return $input->games >= 100;
    });

El primer argumento que se pasa al método `sometimes` es el nombre del campo que estamos validando condicionalmente. El segundo argumento es una lista de las reglas que queremos añadir. Si el closure pasado como tercer argumento devuelve `true`, las reglas serán añadidas. Con este método es muy fácil crear validaciones condicionales complejas. Incluso puedes añadir validaciones condicionales para varios campos a la vez:

    $validator->sometimes(['reason', 'cost'], 'required', function ($input) {
        return $input->games >= 100;
    });

> **Nota**  
> El parámetro `$input` pasado a su closure será una instancia de `Illuminate\Support\Fluent` y puede ser usado para acceder a los datos de entrada y archivos bajo validación.

<a name="complex-conditional-array-validation"></a>
#### Validación condicional compleja de array

A veces puede querer validar un campo basándose en otro campo del mismo array anidado cuyo índice desconoce. En estas situaciones, puede permitir que su closure reciba un segundo argumento que será el elemento individual actual del array que se está validando:

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

    $validator->sometimes('channels.*.address', 'email', function ($input, $item) {
        return $item->type === 'email';
    });

    $validator->sometimes('channels.*.address', 'url', function ($input, $item) {
        return $item->type !== 'email';
    });

Al igual que el parámetro `$input` pasado al closure, el parámetro `$item` es una instancia de `Illuminate\Support\Fluent` cuando los datos del atributo son un array; en caso contrario, es una cadena.

<a name="validating-arrays"></a>
## Validación de arrays

Como se explica en [la documentación de la regla de validación de `array´](#rule-array), la regla de `array` acepta una lista de claves de array permitidas. Si hay claves adicionales dentro del array, la validación fallará:

    use Illuminate\Support\Facades\Validator;

    $input = [
        'user' => [
            'name' => 'Taylor Otwell',
            'username' => 'taylorotwell',
            'admin' => true,
        ],
    ];

    Validator::make($input, [
        'user' => 'array:username,locale',
    ]);

En general, siempre debes especificar las claves de array que pueden estar presentes en tu array. De lo contrario, los métodos `validate` y `validated` del validador devolverán todos los datos validados, incluyendo el array y todas sus claves, incluso si esas claves no fueron validadas por otras reglas de validación de array anidados.

<a name="validating-nested-array-input"></a>
### Validación datos de entrada basados en array anidados

La validación de campos de entrada de formularios basados en array anidados no tiene por qué ser un engorro. Puede utilizar la "notación por puntos" para validar atributos dentro de un array. Por ejemplo, si la petición HTTP entrante contiene un campo `photos[profile]`, puedes validarlo así:

    use Illuminate\Support\Facades\Validator;

    $validator = Validator::make($request->all(), [
        'photos.profile' => 'required|image',
    ]);

También puede validar cada elemento de un array. Por ejemplo, para validar que cada correo electrónico en un campo de entrada de array es único, puede hacer lo siguiente:

    $validator = Validator::make($request->all(), [
        'person.*.email' => 'email|unique:users',
        'person.*.first_name' => 'required_with:person.*.last_name',
    ]);

Del mismo modo, puede utilizar el carácter `*` al especificar [mensajes de validación personalizados en sus archivos de idioma](#custom-messages-for-specific-attributes), lo que facilita el uso de un único mensaje de validación para campos basados en array:

    'custom' => [
        'person.*.email' => [
            'unique' => 'Each person must have a unique email address',
        ]
    ],

<a name="accessing-nested-array-data"></a>
#### Acceso a datos en arrays anidados

A veces es necesario acceder al valor de un elemento de array anidado al asignar reglas de validación al atributo. Para ello puede utilizar el método `Rule::forEach`. El método `forEach` acepta un closure que se invocará para cada iteración del atributo del array que se está validando y recibirá el valor del atributo y el nombre explícito y completamente expandido del atributo. El closure debe devolver un array de reglas para asignar al elemento del array:

    use App\Rules\HasPermission;
    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    $validator = Validator::make($request->all(), [
        'companies.*.id' => Rule::forEach(function ($value, $attribute) {
            return [
                Rule::exists(Company::class, 'id'),
                new HasPermission('manage-company', $value),
            ];
        }),
    ]);

<a name="error-message-indexes-and-positions"></a>
### Índices y posiciones de mensajes de error

Al validar arrays, es posible que desee hacer referencia al índice o a la posición de un elemento concreto que no se ha validado en el mensaje de error que muestra la aplicación. Para ello, puede incluir los marcadores de posición `:index` y `:position` en su mensaje de validación [personalizado](#manual-customizing-the-error-messages):

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

En el ejemplo anterior, la validación fallará y el usuario recibirá el siguiente mensaje de error: _"Please describe photo #2."_

<a name="validating-files"></a>
## Validación de ficheros

Laravel proporciona una variedad de reglas de validación que pueden ser usadas para validar archivos subidos, tales como `mimes`, `image`, `min`, y `max`. Mientras que eres libre de especificar estas reglas individualmente al validar archivos, Laravel también ofrece un constructor de reglas de validación de archivos fluido que puedes encontrar conveniente:

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

Si tu aplicación acepta imágenes subidas por tus usuarios, puede utilizar el método constructor  `image` de la regla `File` para indicar que el archivo subido debe ser una imagen. Además, la regla de `dimensions` puede utilizarse para limitar las dimensiones de la imagen:

    use Illuminate\Support\Facades\Validator;
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

> **Nota**  
> Encontrará más información sobre la validación de las dimensiones de las imágenes en [la documentación de las reglas de dimensión](#rule-dimensions).

<a name="validating-files-file-types"></a>
#### Tipos de archivo

Aunque sólo es necesario especificar las extensiones cuando se invoca el método `types`, este método en realidad valida el tipo MIME del archivo leyendo el contenido del archivo y adivinando su tipo MIME. Puede encontrar una lista completa de los tipos MIME y sus correspondientes extensiones en la siguiente dirección:

[https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types](https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types)

<a name="validating-passwords"></a>
## Validación de contraseñas

Para asegurarse de que las contraseñas tienen un nivel adecuado de complejidad, puede utilizar el objeto de regla `Password` de Laravel:

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rules\Password;

    $validator = Validator::make($request->all(), [
        'password' => ['required', 'confirmed', Password::min(8)],
    ]);

El objeto de regla `Password` le permite personalizar fácilmente los requisitos de complejidad de la contraseña para su aplicación, como especificar que las contraseñas requieren al menos una letra, número, símbolo o caracteres con mayúsculas y minúsculas mixtas:

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

Además, puede asegurarse de que una contraseña no se ha visto comprometida en una filtración pública de datos de contraseñas utilizando el método `no comprometido`:

    Password::min(8)->uncompromised()

Internamente, el objeto de regla `Password` utiliza el modelo [k-Anonymity](https://en.wikipedia.org/wiki/K-anonymity) para determinar si se ha filtrado una contraseña a través del servicio [haveibeenpwned.com](https://haveibeenpwned.com) sin sacrificar la privacidad o seguridad del usuario.

Por defecto, si una contraseña aparece al menos una vez en una filtración de datos, se considerará comprometida. Puede personalizar este umbral utilizando el primer argumento del método `uncompromised`:

    // Ensure the password appears less than 3 times in the same data leak...
    Password::min(8)->uncompromised(3);

Por supuesto, puede encadenar todos los métodos de los ejemplos anteriores:

    Password::min(8)
        ->letters()
        ->mixedCase()
        ->numbers()
        ->symbols()
        ->uncompromised()

<a name="defining-default-password-rules"></a>
#### Definición de reglas de contraseña por defecto

Puede resultarle conveniente especificar las reglas de validación por defecto para las contraseñas en una única ubicación de su aplicación. Puede hacerlo fácilmente utilizando el método `Password::defaults`, que acepta un closure. El closure dado al método `defaults` debe devolver la configuración por defecto de la regla Password. Típicamente, la regla `defaults` debería ser llamada dentro del método `boot` de uno de los proveedores de servicio de su aplicación:

```php
use Illuminate\Validation\Rules\Password;

/**
 * Bootstrap any application services.
 *
 * @return void
 */
public function boot()
{
    Password::defaults(function () {
        $rule = Password::min(8);

        return $this->app->isProduction()
                    ? $rule->mixedCase()->uncompromised()
                    : $rule;
    });
}
```

Entonces, cuando quiera aplicar las reglas por defecto a una contraseña en particular que esté siendo validada, puede invocar el método `defaults` sin argumentos:

    'password' => ['required', Password::defaults()],

Ocasionalmente, puedes querer adjuntar reglas de validación adicionales a tus reglas de validación de contraseñas por defecto. Para ello puede utilizar el método `rules`:

    use App\Rules\ZxcvbnRule;

    Password::defaults(function () {
        $rule = Password::min(8)->rules([new ZxcvbnRule]);

        // ...
    });

<a name="custom-validation-rules"></a>
## Reglas de Validación Personalizadas

<a name="using-rule-objects"></a>
### Uso de Objetos Regla

Laravel proporciona una variedad de reglas de validación útiles; sin embargo, es posible que desee especificar algunas propias. Un método para registrar reglas de validación personalizadas es el uso de objetos regla. Para generar un nuevo objeto regla, puedes utilizar el comando `make:rule` Artisan. Usemos este comando para generar una regla que verifique que una cadena está en mayúsculas. Laravel colocará la nueva regla en el directorio `app/Rules`. Si este directorio no existe, Laravel lo creará cuando ejecutes el comando Artisan para crear tu regla:

```shell
php artisan make:rule Uppercase --invokable
```

Una vez creada la regla, estamos listos para definir su comportamiento. Un objeto regla contiene un único método: `__invoke`. Este método recibe el nombre del atributo, su valor, y un callback que debe ser invocado en caso de fallo con el mensaje de error de validación:

    <?php

    namespace App\Rules;

    use Illuminate\Contracts\Validation\InvokableRule;

    class Uppercase implements InvokableRule
    {
        /**
         * Run the validation rule.
         *
         * @param  string  $attribute
         * @param  mixed  $value
         * @param  \Closure  $fail
         * @return void
         */
        public function __invoke($attribute, $value, $fail)
        {
            if (strtoupper($value) !== $value) {
                $fail('The :attribute must be uppercase.');
            }
        }
    }

Una vez que la regla ha sido definida, puede adjuntarla a un validador pasando una instancia del objeto regla con sus otras reglas de validación:

    use App\Rules\Uppercase;

    $request->validate([
        'name' => ['required', 'string', new Uppercase],
    ]);

#### Traducción de mensajes de validación

En lugar de proporcionar un mensaje de error literal al closure `$fail`, también puede proporcionar una [clave de cadena de traducción](/docs/{{version}}/localization) e indicar a Laravel que traduzca el mensaje de error:

    if (strtoupper($value) !== $value) {
        $fail('validation.uppercase')->translate();
    }

Si es necesario, puede proporcionar marcadores de sustitución y el idioma preferido como primer y segundo argumento del método `translate`:

    $fail('validation.location')->translate([
        'value' => $this->value,
    ], 'fr')

#### Acceso a datos adicionales

Si su clase de regla de validación personalizada necesita acceder a todos los demás datos sometidos a validación, su clase de regla puede implementar la interfaz `Illuminate\Contracts\Validation\DataAwareRule`. Esta interfaz requiere que su clase defina un método `setData`. Este método será invocado automáticamente por Laravel (antes de proceder a la validación) con todos los datos bajo validación:

    <?php

    namespace App\Rules;

    use Illuminate\Contracts\Validation\DataAwareRule;
    use Illuminate\Contracts\Validation\InvokableRule;

    class Uppercase implements DataAwareRule, InvokableRule
    {
        /**
         * All of the data under validation.
         *
         * @var array
         */
        protected $data = [];

        // ...

        /**
         * Set the data under validation.
         *
         * @param  array  $data
         * @return $this
         */
        public function setData($data)
        {
            $this->data = $data;

            return $this;
        }
    }

O, si tu regla de validación requiere acceso a la instancia del validador que realiza la validación, puedes implementar la interfaz `ValidatorAwareRule`:

    <?php

    namespace App\Rules;

    use Illuminate\Contracts\Validation\InvokableRule;
    use Illuminate\Contracts\Validation\ValidatorAwareRule;

    class Uppercase implements InvokableRule, ValidatorAwareRule
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
         *
         * @param  \Illuminate\Validation\Validator  $validator
         * @return $this
         */
        public function setValidator($validator)
        {
            $this->validator = $validator;

            return $this;
        }
    }

<a name="using-closures"></a>
### Uso de closures

Si sólo necesitas la funcionalidad de una regla personalizada una vez a lo largo de tu aplicación, puedes utilizar un closure en lugar de un objeto regla. El closure recibe el nombre del atributo, el valor del atributo y un callback `$fail` que debe ser llamado si la validación falla:

    use Illuminate\Support\Facades\Validator;

    $validator = Validator::make($request->all(), [
        'title' => [
            'required',
            'max:255',
            function ($attribute, $value, $fail) {
                if ($value === 'foo') {
                    $fail('The '.$attribute.' is invalid.');
                }
            },
        ],
    ]);

<a name="implicit-rules"></a>
### Reglas implícitas

Por defecto, cuando un atributo que está siendo validado no está presente o contiene una cadena vacía, las reglas de validación normales, incluyendo las reglas personalizadas, no se ejecutan. Por ejemplo, la regla [`unique`](#rule-unique) no se ejecutará con una cadena vacía:

    use Illuminate\Support\Facades\Validator;

    $rules = ['name' => 'unique:users,name'];

    $input = ['name' => ''];

    Validator::make($input, $rules)->passes(); // true

Para que una regla personalizada se ejecute incluso cuando un atributo está vacío, la regla debe implicar que el atributo es requerido. Para generar rápidamente un nuevo objeto de regla implícito, puede utilizar el comando `make:rule` de Artisan con la opción `--implicit`:

```shell
php artisan make:rule Uppercase --invokable --implicit
```

> **Advertencia**  
> Una regla "implícita" sólo _implica_ que el atributo es obligatorio. La invalidación real de un atributo vacío o ausente depende de usted.
