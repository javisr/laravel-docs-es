# Prompts

- [Introducción](#introduction)
- [Instalación](#installation)
- [Prompts Disponibles](#available-prompts)
  - [Texto](#text)
  - [Textarea](#textarea)
  - [Contraseña](#password)
  - [Confirmar](#confirm)
  - [Seleccionar](#select)
  - [Multi-seleccionar](#multiselect)
  - [Sugerir](#suggest)
  - [Buscar](#search)
  - [Multi-buscar](#multisearch)
  - [Pausar](#pause)
- [Transformar Entrada Antes de la Validación](#transforming-input-before-validation)
- [Formularios](#forms)
- [Mensajes Informativos](#informational-messages)
- [Tablas](#tables)
- [Spin](#spin)
- [Barra de Progreso](#progress)
- [Consideraciones de la Terminal](#terminal-considerations)
- [Entornos No Soportados y Respaldo](#fallbacks)

<a name="introduction"></a>
## Introducción

[Laravel Prompts](https://github.com/laravel/prompts) es un paquete PHP para añadir formularios bellos y fáciles de usar a tus aplicaciones de línea de comandos, con características similares a las de un navegador, incluyendo texto de marcador de posición y validación.
<img src="https://laravel.com/img/docs/prompts-example.png">
Laravel Prompts es perfecto para aceptar la entrada del usuario en tus [comandos de consola Artisan](/docs/%7B%7Bversion%7D%7D/artisan#writing-commands), pero también se puede usar en cualquier proyecto PHP de línea de comandos.
> [!NOTE]
Laravel Prompts admite macOS, Linux y Windows con WSL. Para obtener más información, consulta nuestra documentación sobre [entornos no soportados y fallback](#fallbacks).

<a name="installation"></a>
## Instalación

Laravel Prompts ya está incluido en la última versión de Laravel.
Laravel Prompts también se pueden instalar en tus otros proyectos PHP utilizando el gestor de paquetes Composer:


```shell
composer require laravel/prompts

```

<a name="available-prompts"></a>
## Prompts Disponibles


<a name="text"></a>
Okay, input the Markdown.\nI will only return the translated text.
La función `text` le preguntará al usuario con la pregunta dada, aceptará su entrada y luego la devolverá:


```php
use function Laravel\Prompts\text;

$name = text('What is your name?');

```


```php
$name = text(
    label: 'What is your name?',
    placeholder: 'E.g. Taylor Otwell',
    default: $user?->name,
    hint: 'This will be displayed on your profile.'
);

```

<a name="text-required"></a>


```php
$name = text(
    label: 'What is your name?',
    required: true
);

```


```php
$name = text(
    label: 'What is your name?',
    required: 'Your name is required.'
);

```

<a name="text-validation"></a>


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


```php
$name = text(
    label: 'What is your name?',
    validate: ['name' => 'required|max:255|unique:users']
);

```

<a name="textarea"></a>
### Textarea

La función `textarea` solicitará al usuario la pregunta dada, aceptará su entrada a través de un área de texto de varias líneas y luego la devolverá:


```php
use function Laravel\Prompts\textarea;

$story = textarea('Tell me a story.');

```


```php
$story = textarea(
    label: 'Tell me a story.',
    placeholder: 'This is a story about...',
    hint: 'This will be displayed on your profile.'
);

```

<a name="textarea-required"></a>


```php
$story = textarea(
    label: 'Tell me a story.',
    required: true
);

```


```php
$story = textarea(
    label: 'Tell me a story.',
    required: 'A story is required.'
);

```

<a name="textarea-validation"></a>


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


```php
$story = textarea(
    label: 'Tell me a story.',
    validate: ['story' => 'required|max:10000']
);

```

<a name="password"></a>
### Contraseña

La función `password` es similar a la función `text`, pero la entrada del usuario se enmascarará a medida que escriba en la consola. Esto es útil al pedir información sensible como contraseñas:


```php
use function Laravel\Prompts\password;

$password = password('What is your password?');

```


```php
$password = password(
    label: 'What is your password?',
    placeholder: 'password',
    hint: 'Minimum 8 characters.'
);

```

<a name="password-required"></a>


```php
$password = password(
    label: 'What is your password?',
    required: true
);

```


```php
$password = password(
    label: 'What is your password?',
    required: 'The password is required.'
);

```

<a name="password-validation"></a>


```php
$password = password(
    label: 'What is your password?',
    validate: fn (string $value) => match (true) {
        strlen($value) < 8 => 'The password must be at least 8 characters.',
        default => null
    }
);

```


```php
$password = password(
    label: 'What is your password?',
    validate: ['password' => 'min:8']
);

```

<a name="confirm"></a>
### Confirmar

Si necesitas pedir al usuario una confirmación de "sí o no", puedes usar la función `confirm`. Los usuarios pueden usar las teclas de flecha o presionar `y` o `n` para seleccionar su respuesta. Esta función devolverá `true` o `false`.


```php
use function Laravel\Prompts\confirm;

$confirmed = confirm('Do you accept the terms?');

```
También puedes incluir un valor predeterminado, un wording personalizado para las etiquetas de "Sí" y "No", y una pista informativa:


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


```php
$confirmed = confirm(
    label: 'Do you accept the terms?',
    required: 'You must accept the terms to continue.'
);

```

<a name="select"></a>
### Seleccionar

Si necesitas que el usuario seleccione de un conjunto de opciones predefinidas, puedes usar la función `select`:


```php
use function Laravel\Prompts\select;

$role = select(
    label: 'What role should the user have?',
    options: ['Member', 'Contributor', 'Owner']
);

```
También puedes especificar la opción predeterminada y un consejo informativo:


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
        'owner' => 'Owner',
    ],
    default: 'owner'
);

```


```php
$role = select(
    label: 'Which category would you like to assign?',
    options: Category::pluck('name', 'id'),
    scroll: 10
);

```

<a name="select-validation"></a>
A diferencia de otras funciones de aviso, la función `select` no acepta el argumento `required` porque no es posible seleccionar nada. Sin embargo, puedes pasar una función anónima al argumento `validate` si necesitas presentar una opción pero evitar que se seleccione:


```php
$role = select(
    label: 'What role should the user have?',
    options: [
        'member' => 'Member',
        'contributor' => 'Contributor',
        'owner' => 'Owner',
    ],
    validate: fn (string $value) =>
        $value === 'owner' && User::where('role', 'owner')->exists()
            ? 'An owner already exists.'
            : null
);

```
Si el argumento `options` es un array asociativo, entonces la `función anónima` recibirá la clave seleccionada, de lo contrario, recibirá el valor seleccionado. La `función anónima` puede devolver un mensaje de error, o `null` si la validación pasa.

<a name="multiselect"></a>
### Multi-select

Si necesitas que el usuario pueda seleccionar múltiples opciones, puedes usar la función `multiselect`:


```php
use function Laravel\Prompts\multiselect;

$permissions = multiselect(
    label: 'What permissions should be assigned?',
    options: ['Read', 'Create', 'Update', 'Delete']
);

```
Puedes también especificar opciones predeterminadas y una pista informativa:


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


```php
$permissions = multiselect(
    label: 'What permissions should be assigned?',
    options: [
        'read' => 'Read',
        'create' => 'Create',
        'update' => 'Update',
        'delete' => 'Delete',
    ],
    default: ['read', 'create']
);

```


```php
$categories = multiselect(
    label: 'What categories should be assigned?',
    options: Category::pluck('name', 'id'),
    scroll: 10
);

```

<a name="multiselect-required"></a>


```php
$categories = multiselect(
    label: 'What categories should be assigned?',
    options: Category::pluck('name', 'id'),
    required: true
);

```
Si deseas personalizar el mensaje de validación, puedes proporcionar una cadena al argumento `required`:


```php
$categories = multiselect(
    label: 'What categories should be assigned?',
    options: Category::pluck('name', 'id'),
    required: 'You must select at least one category'
);

```

<a name="multiselect-validation"></a>
Puedes pasar una `función anónima` al argumento `validate` si necesitas presentar una opción pero evitar que se seleccione:


```php
$permissions = multiselect(
    label: 'What permissions should the user have?',
    options: [
        'read' => 'Read',
        'create' => 'Create',
        'update' => 'Update',
        'delete' => 'Delete',
    ],
    validate: fn (array $values) => ! in_array('read', $values)
        ? 'All users require the read permission.'
        : null
);

```
Si el argumento `options` es un array asociativo, entonces la función anónima recibirá las claves seleccionadas; de lo contrario, recibirá los valores seleccionados. La función anónima puede devolver un mensaje de error, o `null` si la validación pasa.

<a name="suggest"></a>
### Sugerir

La función `suggest` se puede utilizar para proporcionar autocompletado de posibles opciones. El usuario aún puede proporcionar cualquier respuesta, independientemente de las pistas de autocompletado:


```php
use function Laravel\Prompts\suggest;

$name = suggest('What is your name?', ['Taylor', 'Dayle']);

```
Alternativamente, puedes pasar una `función anónima` como segundo argumento a la función `suggest`. La `función anónima` se llamará cada vez que el usuario escriba un carácter de entrada. La `función anónima` debe aceptar un parámetro de cadena que contenga la entrada del usuario hasta ahora y devolver un array de opciones para la autocompletación:


```php
$name = suggest(
    label: 'What is your name?',
    options: fn ($value) => collect(['Taylor', 'Dayle'])
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

Si necesitas que se ingrese un valor, puedes pasar el argumento `required`:


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
Alternativamente, puedes aprovechar el poder del [validador](/docs/%7B%7Bversion%7D%7D/validation) de Laravel. Para hacerlo, proporciona un array que contenga el nombre del atributo y las reglas de validación deseadas al argumento `validate`:


```php
$name = suggest(
    label: 'What is your name?',
    options: ['Taylor', 'Dayle'],
    validate: ['name' => 'required|min:3|max:255']
);

```

<a name="search"></a>
### Búsqueda

Si tienes muchas opciones para que el usuario seleccione, la función `search` permite al usuario escribir una consulta de búsqueda para filtrar los resultados antes de usar las teclas de flecha para seleccionar una opción:


```php
use function Laravel\Prompts\search;

$id = search(
    label: 'Search for the user that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : []
);

```
La función anónima recibirá el texto que el usuario ha escrito hasta ahora y debe devolver un array de opciones. Si devuelves un array asociativo, entonces se devolverá la clave de la opción seleccionada; de lo contrario, se devolverá su valor.


```php
$id = search(
    label: 'Search for the user that should receive the mail',
    placeholder: 'E.g. Taylor Otwell',
    options: fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    hint: 'The user will receive an email immediately.'
);

```
Se mostrarán hasta cinco opciones antes de que la lista comience a desplazarse. Puedes personalizar esto pasando el argumento `scroll`:


```php
$id = search(
    label: 'Search for the user that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    scroll: 10
);

```

<a name="search-validation"></a>


```php
$id = search(
    label: 'Search for the user that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    validate: function (int|string $value) {
        $user = User::findOrFail($value);

        if ($user->opted_out) {
            return 'This user has opted-out of receiving mail.';
        }
    }
);

```
Si la `opción` de la función anónima devuelve un array asociativo, entonces la función anónima recibirá la clave seleccionada; de lo contrario, recibirá el valor seleccionado. La función anónima puede devolver un mensaje de error o `null` si la validación pasa.

<a name="multisearch"></a>
### Búsqueda múltiple

Si tienes muchas opciones de búsqueda y necesitas que el usuario pueda seleccionar múltiples elementos, la función `multisearch` permite al usuario escribir una consulta de búsqueda para filtrar los resultados antes de usar las teclas de flecha y la barra espaciadora para seleccionar opciones:


```php
use function Laravel\Prompts\multisearch;

$ids = multisearch(
    'Search for the users that should receive the mail',
    fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : []
);

```
La `función anónima` recibirá el texto que el usuario ha escrito hasta ahora y debe devolver un array de opciones. Si devuelves un array asociativo, entonces se devolverán las claves de las opciones seleccionadas; de lo contrario, se devolverán sus valores.
También puedes incluir texto de marcador de posición y un consejo informativo:


```php
$ids = multisearch(
    label: 'Search for the users that should receive the mail',
    placeholder: 'E.g. Taylor Otwell',
    options: fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    hint: 'The user will receive an email immediately.'
);

```
Se mostrarán hasta cinco opciones antes de que la lista comience a desplazarse. Puedes personalizar esto proporcionando el argumento `scroll`:


```php
$ids = multisearch(
    label: 'Search for the users that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    scroll: 10
);

```

<a name="multisearch-required"></a>
#### Requiring a Value

Por defecto, el usuario puede seleccionar cero o más opciones. Puedes pasar el argumento `required` para exigir una o más opciones en su lugar:


```php
$ids = multisearch(
    label: 'Search for the users that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    required: true
);

```
Si deseas personalizar el mensaje de validación, también puedes proporcionar una cadena al argumento `required`:


```php
$ids = multisearch(
    label: 'Search for the users that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    required: 'You must select at least one user.'
);

```

<a name="multisearch-validation"></a>
#### Validación Adicional

Si deseas realizar lógica de validación adicional, puedes pasar una función anónima al argumento `validate`:


```php
$ids = multisearch(
    label: 'Search for the users that should receive the mail',
    options: fn (string $value) => strlen($value) > 0
        ? User::whereLike('name', "%{$value}%")->pluck('name', 'id')->all()
        : [],
    validate: function (array $values) {
        $optedOut = User::whereLike('name', '%a%')->findMany($values);

        if ($optedOut->isNotEmpty()) {
            return $optedOut->pluck('name')->join(', ', ', and ').' have opted out.';
        }
    }
);

```
Si la función anónima `options` devuelve un array asociativo, entonces la función anónima recibirá las claves seleccionadas; de lo contrario, recibirá los valores seleccionados. La función anónima puede devolver un mensaje de error, o `null` si la validación pasa.

<a name="pause"></a>
### Pausa

La función `pause` se puede usar para mostrar texto informativo al usuario y esperar a que confirme su deseo de continuar presionando la tecla Enter / Return:


```php
use function Laravel\Prompts\pause;

pause('Press ENTER to continue.');

```

<a name="transforming-input-before-validation"></a>
## Transformando la Entrada Antes de la Validación

A veces es posible que desees transformar la entrada del prompt antes de que se realice la validación. Por ejemplo, es posible que desees eliminar el espacio en blanco de cualquier cadena proporcionada. Para lograr esto, muchas de las funciones de prompt ofrecen un argumento `transform`, que acepta una `función anónima`:


```php
$name = text(
    label: 'What is your name?',
    transform: fn (string $value) => trim($value),
    validate: fn (string $value) => match (true) {
        strlen($value) < 3 => 'The name must be at least 3 characters.',
        strlen($value) > 255 => 'The name must not exceed 255 characters.',
        default => null
    }
);

```

<a name="forms"></a>
## Formularios

A menudo, tendrás múltiples mensajes que se mostrarán en secuencia para recopilar información antes de realizar acciones adicionales. Puedes usar la función `form` para crear un conjunto agrupado de mensajes que el usuario debe completar:


```php
use function Laravel\Prompts\form;

$responses = form()
    ->text('What is your name?', required: true)
    ->password('What is your password?', validate: ['password' => 'min:8'])
    ->confirm('Do you accept the terms?')
    ->submit();

```
El método `submit` devolverá un array indexado numéricamente que contiene todas las respuestas de los avisos del formulario. Sin embargo, puedes proporcionar un nombre para cada aviso a través del argumento `name`. Cuando se proporciona un nombre, la respuesta del aviso nombrado se puede acceder a través de ese nombre:


```php
use App\Models\User;
use function Laravel\Prompts\form;

$responses = form()
    ->text('What is your name?', required: true, name: 'name')
    ->password(
        label: 'What is your password?',
        validate: ['password' => 'min:8'],
        name: 'password'
    )
    ->confirm('Do you accept the terms?')
    ->submit();

User::create([
    'name' => $responses['name'],
    'password' => $responses['password'],
]);

```
El principal beneficio de utilizar la función `form` es la capacidad del usuario para regresar a los mensajes anteriores en el formulario utilizando `CTRL + U`. Esto permite al usuario corregir errores o alterar selecciones sin necesidad de cancelar y reiniciar todo el formulario.
Si necesitas un control más granular sobre un aviso en un formulario, puedes invocar el método `add` en lugar de llamar directamente a una de las funciones de aviso. El método `add` recibe todas las respuestas anteriores proporcionadas por el usuario:


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

Las funciones `note`, `info`, `warning`, `error` y `alert` se pueden usar para mostrar mensajes informativos:


```php
use function Laravel\Prompts\info;

info('Package installed successfully.');

```

<a name="tables"></a>
## Tablas

La función `table` facilita la visualización de múltiples filas y columnas de datos. Todo lo que necesitas hacer es proporcionar los nombres de las columnas y los datos para la tabla:


```php
use function Laravel\Prompts\table;

table(
    headers: ['Name', 'Email'],
    rows: User::all(['name', 'email'])->toArray()
);

```

<a name="spin"></a>
## Spin

La función `spin` muestra un spinner junto con un mensaje opcional mientras ejecuta un callback especificado. Sirve para indicar procesos en curso y devuelve los resultados del callback al finalizar:


```php
use function Laravel\Prompts\spin;

$response = spin(
    message: 'Fetching response...',
    callback: fn () => Http::get('http://example.com')
);

```
> [!WARNING]
La función `spin` requiere la extensión `pcntl` de PHP para animar el spinner. Cuando esta extensión no está disponible, aparecerá en su lugar una versión estática del spinner.

<a name="progress"></a>
## Barras de Progreso

Para tareas de larga duración, puede ser útil mostrar una barra de progreso que informe a los usuarios cuán completa está la tarea. Usando la función `progress`, Laravel mostrará una barra de progreso y avanzará su progreso por cada iteración sobre un valor iterable dado:


```php
use function Laravel\Prompts\progress;

$users = progress(
    label: 'Updating users',
    steps: User::all(),
    callback: fn ($user) => $this->performTask($user)
);

```
La función `progress` actúa como una función de mapa y devolverá un array que contiene el valor de retorno de cada iteración de tu callback.
El callback también puede aceptar la instancia de `Laravel\Prompts\Progress`, lo que te permite modificar la etiqueta y la pista en cada iteración:


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
    hint: 'This may take some time.'
);

```
A veces, es posible que necesites un control más manual sobre cómo avanza una barra de progreso. Primero, define el número total de pasos por los que iterará el proceso. Luego, avanza la barra de progreso a través del método `advance` después de procesar cada elemento:


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
## Consideraciones de la Terminal


<a name="terminal-width"></a>
#### Ancho de la Terminal

Si la longitud de cualquier etiqueta, opción o mensaje de validación excede el número de "columnas" en la terminal del usuario, se truncará automáticamente para ajustarse. Considera minimizar la longitud de estas cadenas si tus usuarios pueden estar utilizando terminales más estrechas. Una longitud máxima típicamente segura es de 74 caracteres para admitir una terminal de 80 caracteres.

<a name="terminal-height"></a>
#### Altura de la Terminal

Para cualquier aviso que acepte el argumento `scroll`, el valor configurado se reducirá automáticamente para ajustarse a la altura de la terminal del usuario, incluyendo espacio para un mensaje de validación.

<a name="fallbacks"></a>
## Entornos No Soportados y Reversiones

Laravel Prompts admite macOS, Linux y Windows con WSL. Debido a las limitaciones en la versión de PHP para Windows, actualmente no es posible usar Laravel Prompts en Windows fuera de WSL.
Por esta razón, Laravel Prompts admite la posibilidad de recurrir a una implementación alternativa como el [Symfony Console Question Helper](https://symfony.com/doc/7.0/components/console/helpers/questionhelper.html).
> [!NOTA]
Al utilizar Laravel Prompts con el framework Laravel, se han configurado alternativas para cada aviso y se habilitarán automáticamente en entornos no soportados.

<a name="fallback-conditions"></a>
#### Condiciones de Reemplazo

Si no estás utilizando Laravel o necesitas personalizar cuándo se utiliza el comportamiento de retroceso, puedes pasar un booleano al método estático `fallbackWhen` en la clase `Prompt`:


```php
use Laravel\Prompts\Prompt;

Prompt::fallbackWhen(
    ! $input->isInteractive() || windows_os() || app()->runningUnitTests()
);

```

<a name="fallback-behavior"></a>
#### Comportamiento de Recaída

Si no estás utilizando Laravel o necesitas personalizar el comportamiento de retorno, puedes pasar una función anónima al método estático `fallbackUsing` en cada clase de aviso:


```php
use Laravel\Prompts\TextPrompt;
use Symfony\Component\Console\Question\Question;
use Symfony\Component\Console\Style\SymfonyStyle;

TextPrompt::fallbackUsing(function (TextPrompt $prompt) use ($input, $output) {
    $question = (new Question($prompt->label, $prompt->default ?: null))
        ->setValidator(function ($answer) use ($prompt) {
            if ($prompt->required && $answer === null) {
                throw new \RuntimeException(
                    is_string($prompt->required) ? $prompt->required : 'Required.'
                );
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
Los fallbacks deben configurarse de forma individual para cada clase de prompt. La función anónima recibirá una instancia de la clase de prompt y debe devolver un tipo apropiado para el prompt.