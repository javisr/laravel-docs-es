# Prompts

- [Introducción](#introduction)
- [Instalación](#installation)
- [Prompts Disponibles](#available-prompts)
    - [Texto](#text)
    - [Textarea](#textarea)
    - [Contraseña](#password)
    - [Confirmar](#confirm)
    - [Seleccionar](#select)
    - [Selección Múltiple](#multiselect)
    - [Sugerir](#suggest)
    - [Buscar](#search)
    - [Búsqueda Múltiple](#multisearch)
    - [Pausa](#pause)
- [Formularios](#forms)
- [Mensajes Informativos](#informational-messages)
- [Tablas](#tables)
- [Girar](#spin)
- [Barra de Progreso](#progress)
- [Consideraciones del Terminal](#terminal-considerations)
- [Entornos No Soportados y Alternativas](#fallbacks)

<a name="introduction"></a>
## Introducción

[Laravel Prompts](https://github.com/laravel/prompts) es un paquete de PHP para agregar formularios hermosos y fáciles de usar a tus aplicaciones de línea de comandos, con características similares a las de un navegador, incluyendo texto de marcador de posición y validación.

<img src="https://laravel.com/img/docs/prompts-example.png">

Laravel Prompts es perfecto para aceptar la entrada del usuario en tus [comandos de consola Artisan](/docs/{{version}}/artisan#writing-commands), pero también puede ser utilizado en cualquier proyecto de PHP en línea de comandos.

> [!NOTE]  
> Laravel Prompts es compatible con macOS, Linux y Windows con WSL. Para más información, consulta nuestra documentación sobre [entornos no soportados y alternativas](#fallbacks).

<a name="installation"></a>
## Instalación

Laravel Prompts ya está incluido en la última versión de Laravel.

Laravel Prompts también puede ser instalado en tus otros proyectos de PHP utilizando el gestor de paquetes Composer:

```shell
composer require laravel/prompts
```

<a name="available-prompts"></a>
## Prompts Disponibles

<a name="text"></a>
### Texto

La función `text` solicitará al usuario la pregunta dada, aceptará su entrada y luego la devolverá:

```php
use function Laravel\Prompts\text;

$name = text('¿Cuál es tu nombre?');
```

También puedes incluir texto de marcador de posición, un valor predeterminado y una pista informativa:

```php
$name = text(
    label: 'What is your name?',
    placeholder: 'E.g. Taylor Otwell',
    default: $user?->name,
    hint: 'This will be displayed on your profile.'
);
```

<a name="text-required"></a>
#### Valores Requeridos

Si requieres que se ingrese un valor, puedes pasar el argumento `required`:

```php
$name = text(
    label: 'What is your name?',
    required: true
);
```

Si deseas personalizar el mensaje de validación, también puedes pasar una cadena:

```php
$name = text(
    label: 'What is your name?',
    required: 'Your name is required.'
);
```

<a name="text-validation"></a>
#### Validación Adicional

Finalmente, si deseas realizar lógica de validación adicional, puedes pasar una función anónima al argumento `validate`:

```php
$name = text(
    label: 'What is your name?',
    validate: fn (string $value) => match (true) {
        strlen($value) < 3 => 'The name must be at least 3 characters.',
        strlen($value) > 255 => 'The name must not exceed 255 characters.',
        default => null
    }
);
```

La función anónima recibirá el valor que se ha ingresado y puede devolver un mensaje de error, o `null` si la validación pasa.

Alternativamente, puedes aprovechar el poder del [validador](/docs/{{version}}/validation) de Laravel. Para hacerlo, proporciona un array que contenga el nombre del atributo y las reglas de validación deseadas al argumento `validate`:

```php
$name = text(
    label: 'What is your name?',
    validate: ['name' => 'required|max:255|unique:users,name']
);
```

<a name="textarea"></a>
### Textarea

La función `textarea` solicitará al usuario la pregunta dada, aceptará su entrada a través de un área de texto de varias líneas y luego la devolverá:

```php
use function Laravel\Prompts\textarea;

$story = textarea('Cuéntame una historia.');
```

También puedes incluir texto de marcador de posición, un valor predeterminado y una pista informativa:

```php
$story = textarea(
    label: 'Tell me a story.',
    placeholder: 'This is a story about...',
    hint: 'This will be displayed on your profile.'
);
```

<a name="textarea-required"></a>
#### Valores Requeridos

Si requieres que se ingrese un valor, puedes pasar el argumento `required`:

```php
$story = textarea(
    label: 'Tell me a story.',
    required: true
);
```

Si deseas personalizar el mensaje de validación, también puedes pasar una cadena:

```php
$story = textarea(
    label: 'Tell me a story.',
    required: 'A story is required.'
);
```

<a name="textarea-validation"></a>
#### Validación Adicional

Finalmente, si deseas realizar lógica de validación adicional, puedes pasar una función anónima al argumento `validate`:

```php
$story = textarea(
    label: 'Tell me a story.',
    validate: fn (string $value) => match (true) {
        strlen($value) < 250 => 'The story must be at least 250 characters.',
        strlen($value) > 10000 => 'The story must not exceed 10,000 characters.',
        default => null
    }
);
```

La función anónima recibirá el valor que se ha ingresado y puede devolver un mensaje de error, o `null` si la validación pasa.

Alternativamente, puedes aprovechar el poder del [validador](/docs/{{version}}/validation) de Laravel. Para hacerlo, proporciona un array que contenga el nombre del atributo y las reglas de validación deseadas al argumento `validate`:

```php
$story = textarea(
    label: 'Tell me a story.',
    validate: ['story' => 'required|max:10000']
);
```

<a name="password"></a>
### Contraseña

La función `password` es similar a la función `text`, pero la entrada del usuario será enmascarada mientras escribe en la consola. Esto es útil cuando se solicita información sensible como contraseñas:

```php
use function Laravel\Prompts\password;

$password = password('¿Cuál es tu contraseña?');
```

También puedes incluir texto de marcador de posición y una pista informativa:

```php
$password = password(
    label: 'What is your password?',
    placeholder: 'password',
    hint: 'Minimum 8 characters.'
);
```

<a name="password-required"></a>
#### Valores Requeridos

Si requieres que se ingrese un valor, puedes pasar el argumento `required`:

```php
$password = password(
    label: 'What is your password?',
    required: true
);
```

Si deseas personalizar el mensaje de validación, también puedes pasar una cadena:

```php
$password = password(
    label: 'What is your password?',
    required: 'The password is required.'
);
```

<a name="password-validation"></a>
#### Validación Adicional

Finalmente, si deseas realizar lógica de validación adicional, puedes pasar una función anónima al argumento `validate`:

```php
$password = password(
    label: 'What is your password?',
    validate: fn (string $value) => match (true) {
        strlen($value) < 8 => 'The password must be at least 8 characters.',
        default => null
    }
);
```

La función anónima recibirá el valor que se ha ingresado y puede devolver un mensaje de error, o `null` si la validación pasa.

Alternativamente, puedes aprovechar el poder del [validador](/docs/{{version}}/validation) de Laravel. Para hacerlo, proporciona un array que contenga el nombre del atributo y las reglas de validación deseadas al argumento `validate`:

```php
$password = password(
    label: 'What is your password?',
    validate: ['password' => 'min:8']
);
```

<a name="confirm"></a>
### Confirmar

Si necesitas preguntar al usuario por una confirmación de "sí o no", puedes usar la función `confirm`. Los usuarios pueden usar las teclas de flecha o presionar `y` o `n` para seleccionar su respuesta. Esta función devolverá `true` o `false`.

```php
use function Laravel\Prompts\confirm;

$confirmed = confirm('¿Aceptas los términos?');
```

También puedes incluir un valor predeterminado, redacción personalizada para las etiquetas de "Sí" y "No", y una pista informativa:

```php
$confirmed = confirm(
    label: 'Do you accept the terms?',
    default: false,
    yes: 'I accept',
    no: 'I decline',
    hint: 'The terms must be accepted to continue.'
);
```

<a name="confirm-required"></a>
#### Requiriendo "Sí"

Si es necesario, puedes requerir que tus usuarios seleccionen "Sí" pasando el argumento `required`:

```php
$confirmed = confirm(
    label: 'Do you accept the terms?',
    required: true
);
```

Si deseas personalizar el mensaje de validación, también puedes pasar una cadena:

```php
$confirmed = confirm(
    label: 'Do you accept the terms?',
    required: 'You must accept the terms to continue.'
);
```

<a name="select"></a>
### Seleccionar

Si necesitas que el usuario seleccione de un conjunto predefinido de opciones, puedes usar la función `select`:

```php
use function Laravel\Prompts\select;

$role = select(
    'What role should the user have?',
    ['Member', 'Contributor', 'Owner'],
);
```

También puedes especificar la opción predeterminada y una pista informativa:

```php
$role = select(
    label: 'What role should the user have?',
    options: ['Member', 'Contributor', 'Owner'],
    default: 'Owner',
    hint: 'The role may be changed at any time.'
);
```

También puedes pasar un array asociativo al argumento `options` para que se devuelva la clave seleccionada en lugar de su valor:

```php
$role = select(
    label: 'What role should the user have?',
    options: [
        'member' => 'Member',
        'contributor' => 'Contributor',
        'owner' => 'Owner'
    ],
    default: 'owner'
);
```

Se mostrarán hasta cinco opciones antes de que la lista comience a desplazarse. Puedes personalizar esto pasando el argumento `scroll`:

```php
$role = select(
    label: 'Which category would you like to assign?',
    options: Category::pluck('name', 'id'),
    scroll: 10
);
```

<a name="select-validation"></a>
#### Validación

A diferencia de otras funciones de prompt, la función `select` no acepta el argumento `required` porque no es posible seleccionar nada. Sin embargo, puedes pasar una función anónima al argumento `validate` si necesitas presentar una opción pero evitar que sea seleccionada:

```php
$role = select(
    label: 'What role should the user have?',
    options: [
        'member' => 'Member',
        'contributor' => 'Contributor',
        'owner' => 'Owner'
    ],
    validate: fn (string $value) =>
        $value === 'owner' && User::where('role', 'owner')->exists()
            ? 'An owner already exists.'
            : null
);
```

Si el argumento `options` es un array asociativo, entonces la función anónima recibirá la clave seleccionada, de lo contrario, recibirá el valor seleccionado. La función anónima puede devolver un mensaje de error, o `null` si la validación pasa.

<a name="multiselect"></a>
### Selección Múltiple

Si necesitas que el usuario pueda seleccionar múltiples opciones, puedes usar la función `multiselect`:

```php
use function Laravel\Prompts\multiselect;

$permissions = multiselect(
    'What permissions should be assigned?',
    ['Read', 'Create', 'Update', 'Delete']
);
```

También puedes especificar opciones predeterminadas y una pista informativa:

```php
use function Laravel\Prompts\multiselect;

$permissions = multiselect(
    label: 'What permissions should be assigned?',
    options: ['Read', 'Create', 'Update', 'Delete'],
    default: ['Read', 'Create'],
    hint: 'Permissions may be updated at any time.'
);
```

También puedes pasar un array asociativo al argumento `options` para devolver las claves de las opciones seleccionadas en lugar de sus valores:

```
$permissions = multiselect(
    label: 'What permissions should be assigned?',
    options: [
        'read' => 'Read',
        'create' => 'Create',
        'update' => 'Update',
        'delete' => 'Delete'
    ],
    default: ['read', 'create']
);
```

Se mostrarán hasta cinco opciones antes de que la lista comience a desplazarse. Puedes personalizar esto pasando el argumento `scroll`:

```php
$categories = multiselect(
    label: 'What categories should be assigned?',
    options: Category::pluck('name', 'id'),
    scroll: 10
);
```

Puedes permitir que el usuario seleccione fácilmente todas las opciones a través del argumento `canSelectAll`:

$categories = multiselect(
    label: '¿Qué categorías deberían ser asignadas?',
    options: Category::pluck('name', 'id'),
    canSelectAll: true
);

<a name="multiselect-required"></a>
#### Requiriendo un Valor

Por defecto, el usuario puede seleccionar cero o más opciones. Puedes pasar el argumento `required` para hacer cumplir una o más opciones en su lugar:

```php
$categories = multiselect(
    label: 'What categories should be assigned?',
    options: Category::pluck('name', 'id'),
    required: true,
);
```

Si deseas personalizar el mensaje de validación, puedes proporcionar una cadena al argumento `required`:

```php
$categories = multiselect(
    label: 'What categories should be assigned?',
    options: Category::pluck('name', 'id'),
    required: 'You must select at least one category',
);
```

<a name="multiselect-validation"></a>
#### Validación

Puedes pasar una función anónima al argumento `validate` si necesitas presentar una opción pero evitar que sea seleccionada:

```
$permissions = multiselect(
    label: 'What permissions should the user have?',
    options: [
        'read' => 'Read',
        'create' => 'Create',
        'update' => 'Update',
        'delete' => 'Delete'
    ],
    validate: fn (array $values) => ! in_array('read', $values)
        ? 'All users require the read permission.'
        : null
);
```

Si el argumento `options` es un array asociativo, entonces la función anónima recibirá las claves seleccionadas, de lo contrario, recibirá los valores seleccionados. La función anónima puede devolver un mensaje de error, o `null` si la validación pasa.

<a name="suggest"></a>
### Sugerir

La función `suggest` puede ser utilizada para proporcionar autocompletado para opciones posibles. El usuario aún puede proporcionar cualquier respuesta, independientemente de las sugerencias de autocompletado:

```php
use function Laravel\Prompts\suggest;

$name = suggest('¿Cuál es tu nombre?', ['Taylor', 'Dayle']);
```

Alternativamente, puedes pasar una función anónima como segundo argumento a la función `suggest`. La función anónima será llamada cada vez que el usuario escriba un carácter de entrada. La función anónima debe aceptar un parámetro de tipo cadena que contenga la entrada del usuario hasta ahora y devolver un array de opciones para autocompletado:

```php
$name = suggest(
    'What is your name?',
    fn ($value) => collect(['Taylor', 'Dayle'])
        ->filter(fn ($name) => Str::contains($name, $value, ignoreCase: true))
)
```

También puedes incluir texto de marcador de posición, un valor predeterminado y una pista informativa:

```php
$name = suggest(
    label: 'What is your name?',
    options: ['Taylor', 'Dayle'],
    placeholder: 'E.g. Taylor',
    default: $user?->name,
    hint: 'This will be displayed on your profile.'
);
```

<a name="suggest-required"></a>
#### Valores Requeridos

Si requieres que se ingrese un valor, puedes pasar el argumento `required`:

```php
$name = suggest(
    label: 'What is your name?',
    options: ['Taylor', 'Dayle'],
    required: true
);
```

Si deseas personalizar el mensaje de validación, también puedes pasar una cadena:

```php
$name = suggest(
    label: 'What is your name?',
    options: ['Taylor', 'Dayle'],
    required: 'Your name is required.'
);
```

<a name="suggest-validation"></a>
#### Validación Adicional

Finalmente, si deseas realizar lógica de validación adicional, puedes pasar una función anónima al argumento `validate`:

```php
$name = suggest(
    label: 'What is your name?',
    options: ['Taylor', 'Dayle'],
    validate: fn (string $value) => match (true) {
        strlen($value) < 3 => 'The name must be at least 3 characters.',
        strlen($value) > 255 => 'The name must not exceed 255 characters.',
        default => null
    }
);
```

La función anónima recibirá el valor que se ha ingresado y puede devolver un mensaje de error, o `null` si la validación pasa.

Alternativamente, puedes aprovechar el poder del [validador](/docs/{{version}}/validation) de Laravel. Para hacerlo, proporciona un array que contenga el nombre del atributo y las reglas de validación deseadas al argumento `validate`:

```php
$name = suggest(
    label: 'What is your name?',
    options: ['Taylor', 'Dayle'],
    validate: ['name' => 'required|min:3|max:255']
);
```

<a name="search"></a>
### Buscar

Si tienes muchas opciones para que el usuario seleccione, la función `search` permite al usuario escribir una consulta de búsqueda para filtrar los resultados antes de usar las teclas de flecha para seleccionar una opción:

```php
use function Laravel\Prompts\search;

$id = search(
    'Search for the user that should receive the mail',
    fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : []
);
```

La función anónima recibirá el texto que ha sido escrito por el usuario hasta ahora y debe devolver un array de opciones. Si devuelves un array asociativo, entonces se devolverá la clave de la opción seleccionada, de lo contrario, se devolverá su valor.

También puedes incluir texto de marcador de posición y una pista informativa:

```php
$id = search(
    label: 'Search for the user that should receive the mail',
    placeholder: 'E.g. Taylor Otwell',
    options: fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    hint: 'The user will receive an email immediately.'
);
```

Se mostrarán hasta cinco opciones antes de que la lista comience a desplazarse. Puedes personalizar esto pasando el argumento `scroll`:

```php
$id = search(
    label: 'Search for the user that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    scroll: 10
);
```

<a name="search-validation"></a>
#### Validación

Si deseas realizar lógica de validación adicional, puedes pasar una función anónima al argumento `validate`:

```php
$id = search(
    label: 'Search for the user that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    validate: function (int|string $value) {
        $user = User::findOrFail($value);

        if ($user->opted_out) {
            return 'This user has opted-out of receiving mail.';
        }
    }
);
```

Si la función de `options` devuelve un array asociativo, entonces la función anónima recibirá la clave seleccionada, de lo contrario, recibirá el valor seleccionado. La función anónima puede devolver un mensaje de error, o `null` si la validación pasa.

<a name="multisearch"></a>
### Búsqueda Múltiple

Si tienes muchas opciones buscables y necesitas que el usuario pueda seleccionar múltiples elementos, la función `multisearch` permite al usuario escribir una consulta de búsqueda para filtrar los resultados antes de usar las teclas de flecha y la barra espaciadora para seleccionar opciones:

```php
use function Laravel\Prompts\multisearch;

$ids = multisearch(
    'Search for the users that should receive the mail',
    fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : []
);
```

La función anónima recibirá el texto que ha sido escrito por el usuario hasta ahora y debe devolver un array de opciones. Si devuelves un array asociativo, entonces se devolverán las claves de las opciones seleccionadas; de lo contrario, se devolverán sus valores.

También puedes incluir texto de marcador de posición y una pista informativa:

```php
$ids = multisearch(
    label: 'Search for the users that should receive the mail',
    placeholder: 'E.g. Taylor Otwell',
    options: fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    hint: 'The user will receive an email immediately.'
);
```

Se mostrarán hasta cinco opciones antes de que la lista comience a desplazarse. Puedes personalizar esto proporcionando el argumento `scroll`:

```php
$ids = multisearch(
    label: 'Search for the users that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    scroll: 10
);
```

<a name="multisearch-required"></a>
#### Requiriendo un Valor

Por defecto, el usuario puede seleccionar cero o más opciones. Puedes pasar el argumento `required` para hacer cumplir una o más opciones en su lugar:

```php
$ids = multisearch(
    'Search for the users that should receive the mail',
    fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    required: true,
);
```

Si deseas personalizar el mensaje de validación, también puedes proporcionar una cadena al argumento `required`:

```php
$ids = multisearch(
    'Search for the users that should receive the mail',
    fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    required: 'You must select at least one user.'
);
```

<a name="multisearch-validation"></a>
#### Validación

Si deseas realizar lógica de validación adicional, puedes pasar una función anónima al argumento `validate`:

```php
$ids = multisearch(
    label: 'Search for the users that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::where('name', 'like', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    validate: function (array $values) {
        $optedOut = User::where('name', 'like', '%a%')->findMany($values);

        if ($optedOut->isNotEmpty()) {
            return $optedOut->pluck('name')->join(', ', ', and ').' have opted out.';
        }
    }
);
```

Si la función de `options` devuelve un array asociativo, entonces la función anónima recibirá las claves seleccionadas; de lo contrario, recibirá los valores seleccionados. La función anónima puede devolver un mensaje de error, o `null` si la validación pasa.

<a name="pause"></a>
### Pausa

La función `pause` puede ser utilizada para mostrar texto informativo al usuario y esperar a que confirme su deseo de continuar presionando la tecla Enter / Return:

```php
use function Laravel\Prompts\pause;

pause('Presiona ENTER para continuar.');
```

<a name="forms"></a>
## Formularios

A menudo, tendrás múltiples prompts que se mostrarán en secuencia para recopilar información antes de realizar acciones adicionales. Puedes usar la función `form` para crear un conjunto agrupado de prompts que el usuario debe completar:

```php
use function Laravel\Prompts\form;

$responses = form()
    ->text('What is your name?', required: true)
    ->password('What is your password?', validate: ['password' => 'min:8'])
    ->confirm('Do you accept the terms?')
    ->submit();
```

El método `submit` devolverá un array indexado numéricamente que contiene todas las respuestas de los prompts del formulario. Sin embargo, puedes proporcionar un nombre para cada prompt a través del argumento `name`. Cuando se proporciona un nombre, la respuesta del prompt nombrado puede ser accedida a través de ese nombre:

```php
use App\Models\User;
use function Laravel\Prompts\form;

$responses = form()
    ->text('What is your name?', required: true, name: 'name')
    ->password(
        'What is your password?',
        validate: ['password' => 'min:8'],
        name: 'password',
    )
    ->confirm('Do you accept the terms?')
    ->submit();

User::create([
    'name' => $responses['name'],
    'password' => $responses['password']
]);
```

El beneficio principal de usar la función `form` es la capacidad del usuario para regresar a prompts anteriores en el formulario usando `CTRL + U`. Esto permite al usuario corregir errores o alterar selecciones sin necesidad de cancelar y reiniciar todo el formulario.

Si necesitas un control más granular sobre un prompt en un formulario, puedes invocar el método `add` en lugar de llamar a una de las funciones de prompt directamente. El método `add` recibe todas las respuestas anteriores proporcionadas por el usuario:

```php
use function Laravel\Prompts\form;
use function Laravel\Prompts\outro;

$responses = form()
    ->text('What is your name?', required: true, name: 'name')
    ->add(function ($responses) {
        return text("How old are you, {$responses['name']}?");
    }, name: 'age')
    ->submit();

outro("Your name is {$responses['name']} and you are {$responses['age']} years old.");
```

<a name="informational-messages"></a>
## Mensajes Informativos

Las funciones `note`, `info`, `warning`, `error` y `alert` pueden ser utilizadas para mostrar mensajes informativos:

```php
use function Laravel\Prompts\info;

info('Paquete instalado exitosamente.');
```

<a name="tables"></a>
## Tablas

La función `table` facilita la visualización de múltiples filas y columnas de datos. Todo lo que necesitas hacer es proporcionar los nombres de las columnas y los datos para la tabla:

```php
use function Laravel\Prompts\table;

table(
    ['Name', 'Email'],
    User::all(['name', 'email'])->toArray()
);
```

<a name="spin"></a>
## Girar

La función `spin` muestra un spinner junto con un mensaje opcional mientras se ejecuta un callback especificado. Sirve para indicar procesos en curso y devuelve los resultados del callback al finalizar:

```php
use function Laravel\Prompts\spin;

$response = spin(
    fn () => Http::get('http://example.com'),
    'Fetching response...'
);
```

> [!WARNING]  
> La función `spin` requiere la extensión `pcntl` de PHP para animar el spinner. Cuando esta extensión no está disponible, aparecerá una versión estática del spinner en su lugar.

<a name="progress"></a>
## Barras de Progreso

Para tareas de larga duración, puede ser útil mostrar una barra de progreso que informe a los usuarios cuán completa está la tarea. Usando la función `progress`, Laravel mostrará una barra de progreso y avanzará su progreso por cada iteración sobre un valor iterable dado:

```php
use function Laravel\Prompts\progress;

$users = progress(
    label: 'Updating users',
    steps: User::all(),
    callback: fn ($user) => $this->performTask($user),
);
```

La función `progress` actúa como una función de mapa y devolverá un array que contiene el valor de retorno de cada iteración de tu callback.

El callback también puede aceptar la instancia de `\Laravel\Prompts\Progress`, lo que te permite modificar la etiqueta y la pista en cada iteración:

```php
$users = progress(
    label: 'Updating users',
    steps: User::all(),
    callback: function ($user, $progress) {
        $progress
            ->label("Updating {$user->name}")
            ->hint("Created on {$user->created_at}");

        return $this->performTask($user);
    },
    hint: 'This may take some time.',
);
```

A veces, puede que necesites un control más manual sobre cómo se avanza una barra de progreso. Primero, define el número total de pasos por los que el proceso iterará. Luego, avanza la barra de progreso a través del método `advance` después de procesar cada elemento:

```php
$progress = progress(label: 'Updating users', steps: 10);

$users = User::all();

$progress->start();

foreach ($users as $user) {
    $this->performTask($user);

    $progress->advance();
}

$progress->finish();
```

<a name="terminal-considerations"></a>
## Consideraciones del Terminal

<a name="terminal-width"></a>
#### Ancho del Terminal

Si la longitud de cualquier etiqueta, opción o mensaje de validación excede el número de "columnas" en el terminal del usuario, se truncará automáticamente para ajustarse. Considera minimizar la longitud de estas cadenas si tus usuarios pueden estar usando terminales más estrechos. Una longitud máxima típicamente segura es de 74 caracteres para soportar un terminal de 80 caracteres.

<a name="terminal-height"></a>
#### Altura del Terminal

Para cualquier prompt que acepte el argumento `scroll`, el valor configurado se reducirá automáticamente para ajustarse a la altura del terminal del usuario, incluyendo espacio para un mensaje de validación.

<a name="fallbacks"></a>
## Entornos No Soportados y Alternativas

Laravel Prompts soporta macOS, Linux y Windows con WSL. Debido a las limitaciones en la versión de Windows de PHP, actualmente no es posible usar Laravel Prompts en Windows fuera de WSL.

Por esta razón, Laravel Prompts soporta recurrir a una implementación alternativa como el [Symfony Console Question Helper](https://symfony.com/doc/7.0/components/console/helpers/questionhelper.html).

> [!NOTE]  
> Al usar Laravel Prompts con el framework Laravel, se han configurado alternativas para cada prompt y se habilitarán automáticamente en entornos no soportados.

<a name="fallback-conditions"></a>
#### Condiciones de Alternativa

Si no estás usando Laravel o necesitas personalizar cuándo se utiliza el comportamiento de alternativa, puedes pasar un booleano al método estático `fallbackWhen` en la clase `Prompt`:

```php
use Laravel\Prompts\Prompt;

Prompt::fallbackWhen(
    ! $input->isInteractive() || windows_os() || app()->runningUnitTests()
);
```

<a name="fallback-behavior"></a>
#### Comportamiento de Alternativa

Si no estás usando Laravel o necesitas personalizar el comportamiento de alternativa, puedes pasar una función anónima al método estático `fallbackUsing` en cada clase de prompt:

```php
use Laravel\Prompts\TextPrompt;
use Symfony\Component\Console\Question\Question;
use Symfony\Component\Console\Style\SymfonyStyle;

TextPrompt::fallbackUsing(function (TextPrompt $prompt) use ($input, $output) {
    $question = (new Question($prompt->label, $prompt->default ?: null))
        ->setValidator(function ($answer) use ($prompt) {
            if ($prompt->required && $answer === null) {
                throw new \RuntimeException(is_string($prompt->required) ? $prompt->required : 'Required.');
            }

            if ($prompt->validate) {
                $error = ($prompt->validate)($answer ?? '');

                if ($error) {
                    throw new \RuntimeException($error);
                }
            }

            return $answer;
        });

    return (new SymfonyStyle($input, $output))
        ->askQuestion($question);
});
```

Las alternativas deben configurarse individualmente para cada clase de prompt. La función anónima recibirá una instancia de la clase de prompt y debe devolver un tipo apropiado para el prompt.
