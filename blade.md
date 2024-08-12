# Plantillas Blade

- [Introducción](#introduction)
  - [Potenciando Blade con Livewire](#supercharging-blade-with-livewire)
- [Visualización de datos](#displaying-data)
  - [Codificación de entidades HTML](#html-entity-encoding)
  - [Blade y Frameworks JavaScript](#blade-and-javascript-frameworks)
- [Directivas Blade](#blade-directives)
  - [Sentencias If](#if-statements)
  - [Sentencias Switch](#switch-statements)
  - [Bucles](#loops)
  - [La Variable Loop](#the-loop-variable)
  - [Clases condicionales](#conditional-classes)
  - [Atributos Adicionales](#additional-attributes)
  - [Inclusión de subvistas](#including-subviews)
  - [La Directiva `@once`](#the-once-directive)
  - [PHP en crudo](#raw-php)
  - [Comentarios](#comments)
- [Componentes](#components)
  - [Renderizado de Componentes](#rendering-components)
  - [Pasando Datos a los Componentes](#passing-data-to-components)
  - [Atributos de Componentes](#component-attributes)
  - [Palabras clave reservadas](#reserved-keywords)
  - [Ranuras](#slots)
  - [Vistas de componentes en línea](#inline-component-views)
  - [Componentes dinámicos](#dynamic-components)
  - [Registro manual de componentes](#manually-registering-components)
- [Componentes anónimos](#anonymous-components)
  - [Componentes de índice anónimos](#anonymous-index-components)
  - [Propiedades de datos / Atributos](#data-properties-attributes)
  - [Acceso a Datos Padre](#accessing-parent-data)
  - [Rutas de Componentes Anónimos](#anonymous-component-paths)
- [Creación de diseños](#building-layouts)
  - [Diseños con componentes](#layouts-using-components)
  - [Diseños con Herencia de Plantillas](#layouts-using-template-inheritance)
- [Formularios](#forms)
  - [Campo CSRF](#csrf-field)
  - [Campo de método](#method-field)
  - [Errores de validación](#validation-errors)
- [Pilas](#stacks)
- [Inyección de Servicios](#service-injection)
- [Renderizado de Plantillas Inline Blade](#rendering-inline-blade-templates)
- [Renderizado de Fragmentos Blade](#rendering-blade-fragments)
- [Ampliación de Blade](#extending-blade)
  - [Manejadores de Eco Personalizados](#custom-echo-handlers)
  - [Sentencias If personalizadas](#custom-if-statements)

<a name="introduction"></a>
## Introducción

Blade es el sencillo pero potente motor de plantillas que se incluye con Laravel. A diferencia de otros motores de plantillas PHP, Blade no restringe el uso de código PHP plano en las plantillas. De hecho, todas las plantillas Blade se compilan en código PHP plano y se almacenan en caché hasta que se modifican, lo que significa que Blade añade esencialmente cero sobrecarga a su aplicación. Los archivos de plantillas Blade utilizan la extensión `.blade.php` y se almacenan normalmente en el directorio `resources/views`.

Las vistas Blade pueden ser devueltas desde rutas o controladores utilizando el helper `view`. Por supuesto, como se menciona en la documentación sobre [vistas/views](/docs/{{version}}/views), los datos pueden pasarse a la vista Blade utilizando el segundo argumento del helper de `view`:

    Route::get('/', function () {
        return view('greeting', ['name' => 'Finn']);
    });

<a name="supercharging-blade-with-livewire"></a>
### Potenciando Blade con Livewire

¿Quieres llevar tus plantillas Blade al siguiente nivel y construir interfaces dinámicas con facilidad? Echa un vistazo a [Laravel Livewire](https://laravel-livewire.com). Livewire le permite escribir componentes Blade mejorados con funcionalidades dinámicas que normalmente sólo serían posible usando frameworks frontend como React o Vue.

<a name="displaying-data"></a>
## Visualización de Datos

Puede mostrar los datos que se pasan a sus vistas Blade envolviendo la variable entre llaves. Por ejemplo, dada la siguiente ruta:

    Route::get('/', function () {
        return view('welcome', ['name' => 'Samantha']);
    });

Puede mostrar el contenido de la variable `name` de la siguiente manera:

```blade
Hello, {{ $name }}.
```

> **Nota**:  
> Las sentencias `{{ }}` de Blade se pasan automáticamente a través de la función `htmlspecialchars` de PHP para evitar ataques XSS.

No está limitado a mostrar el contenido de las variables pasadas a la vista. También puede mostrar de los resultados de cualquier función PHP. De hecho, puede poner cualquier código PHP que desee dentro de una sentencia echo de Blade:

```blade
The current UNIX timestamp is {{ time() }}.
```

<a name="html-entity-encoding"></a>
### Codificación de entidades HTML

Por defecto, Blade (y el helper de Laravel `e`) codificarán doblemente las entidades HTML. Si desea desactivar la doble codificación, llame al método `Blade::withoutDoubleEncoding` desde el método `boot` de su `AppServiceProvider`:

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\Blade;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Bootstrap any application services.
         *
         * @return void
         */
        public function boot()
        {
            Blade::withoutDoubleEncoding();
        }
    }

<a name="displaying-unescaped-data"></a>
#### Visualización de datos no codificados

Por defecto, las sentencias `{{ }}` de Blade se envían automáticamente a través de la función `htmlspecialchars` de PHP para evitar ataques XSS. Si no desea que sus datos sean escapados, puede utilizar la siguiente sintaxis:

```blade
Hello, {!! $name !!}.
```

> **Advertencia**  
> Tenga mucho cuidado cuando se muestre del contenido suministrado por los usuarios de su aplicación. Normalmente debe utilizar la sintaxis de doble llave escapada para evitar ataques XSS al mostrar datos proporcionados por el usuario.

<a name="blade-and-javascript-frameworks"></a>
### Blade y Frameworks JavaScript

Dado que muchos frameworks de JavaScript también utilizan llaves "curly" para indicar que una expresión determinada debe mostrarse en el navegador, puede utilizar el símbolo `@` para informar al motor de renderizado de Blade de que una expresión debe permanecer intacta. Por ejemplo:

```blade
<h1>Laravel</h1>

Hello, @{{ name }}.
```

En este ejemplo, el símbolo `@` será eliminado por Blade; sin embargo, la expresión `{{ name }}` permanecerá intacta, permitiendo que sea renderizada por su framework JavaScript.

El símbolo `@` también puede utilizarse para escapar de las directivas de Blade:

```blade
{{-- Blade template --}}
@@if()

<!-- HTML output -->
@if()
```

<a name="rendering-json"></a>
#### Procesamiento de JSON

A veces puede pasar un array a su vista con la intención de renderizarlo como JSON para inicializar una variable JavaScript. Por ejemplo:

```blade
<script>
    var app = <?php echo json_encode($array); ?>;
</script>
```

Sin embargo, en lugar de llamar manualmente a `json_encode`, puede usar la directiva de método `Illuminate\Support\Js::from`. El método `from` acepta los mismos argumentos que la función `json_encode` de PHP; sin embargo, se asegurará de que el JSON resultante se escape correctamente para su inclusión dentro de las comillas HTML. El método `from` devolverá una declaración JavaScript de cadena `JSON.parse` que convertirá el objeto o matriz dado en un objeto JavaScript válido:

```blade
<script>
    var app = {{ Illuminate\Support\Js::from($array) }};
</script>
```

Las últimas versiones del esqueleto de aplicaciones Laravel incluyen una facade `Js`, que proporciona un cómodo acceso a esta funcionalidad dentro de tus plantillas Blade:

```blade
<script>
    var app = {{ Js::from($array) }};
</script>
```

> **Advertencia**  
> Sólo debes utilizar el método `Js::from` para renderizar variables existentes como JSON. Las plantillas Blade se basan en expresiones regulares y los intentos de pasar una expresión compleja a la directiva pueden causar fallos inesperados.

<a name="the-at-verbatim-directive"></a>
#### La directiva `@verbatim`

Si está mostrando variables JavaScript en una gran parte de su plantilla, puede envolver el HTML en la directiva `@verbatim` para no tener que anteponer un símbolo `@` a cada sentencia echo de Blade:

```blade
@verbatim
    <div class="container">
        Hello, {{ name }}.
    </div>
@endverbatim
```

<a name="blade-directives"></a>
## Directivas Blade

Además de la herencia de plantillas y la visualización de datos, Blade también proporciona cómodos atajos para estructuras de control de PHP comunes, como sentencias condicionales y bucles. Estos atajos proporcionan una forma muy limpia y concisa de trabajar con estructuras de control de PHP, a la vez que resultan familiares a sus homólogos PHP.

<a name="if-statements"></a>
### Sentencias If

Puede construir sentencias `if` usando las directivas `@if`, `@elseif`, `@else` y `@endif`. Estas directivas funcionan de forma idéntica a sus equivalentes en PHP:

```blade
@if (count($records) === 1)
    I have one record!
@elseif (count($records) > 1)
    I have multiple records!
@else
    I don't have any records!
@endif
```

Para mayor comodidad, Blade también proporciona una directiva `@unless`:

```blade
@unless (Auth::check())
    You are not signed in.
@endunless
```

Además de las directivas condicionales ya discutidas, las directivas `@isset` y `@empty` pueden ser usadas como atajos para sus respectivas funciones PHP:

```blade
@isset($records)
    // $records is defined and is not null...
@endisset

@empty($records)
    // $records is "empty"...
@endempty
```

<a name="authentication-directives"></a>
#### Directivas de autenticación

Las directivas `@auth` y `@guest` pueden utilizarse para determinar rápidamente si el usuario actual está [autenticado](/docs/{{version}}/authentication) o es un invitado:

```blade
@auth
    // The user is authenticated...
@endauth

@guest
    // The user is not authenticated...
@endguest
```

Si es necesario, puede especificar la guarda de autenticación que debe comprobarse al usar las directivas `@auth` y `@guest`:

```blade
@auth('admin')
    // The user is authenticated...
@endauth

@guest('admin')
    // The user is not authenticated...
@endguest
```

<a name="environment-directives"></a>
#### Directivas de entorno

Puede comprobar si la aplicación se está ejecutando en el entorno de producción usando la directiva `@production`:

```blade
@production
    // Production specific content...
@endproduction
```

O puede determinar si la aplicación se está ejecutando en un entorno específico utilizando la directiva `@env`:

```blade
@env('staging')
    // The application is running in "staging"...
@endenv

@env(['staging', 'production'])
    // The application is running in "staging" or "production"...
@endenv
```

<a name="section-directives"></a>
#### Directivas de sección

Puede determinar si una sección de la herencia de la plantilla tiene contenido usando la directiva `@hasSection`:

```blade
@hasSection('navigation')
    <div class="pull-right">
        @yield('navigation')
    </div>

    <div class="clearfix"></div>
@endif
```

Puede utilizar la directiva `sectionMissing` para determinar si una sección no tiene contenido:

```blade
@sectionMissing('navigation')
    <div class="pull-right">
        @include('default-navigation')
    </div>
@endif
```

<a name="switch-statements"></a>
### Sentencias Switch

Las sentencias switch pueden construirse utilizando las directivas `@switch`, `@case`, `@break`, `@default` y `@endswitch`:

```blade
@switch($i)
    @case(1)
        First case...
        @break

    @case(2)
        Second case...
        @break

    @default
        Default case...
@endswitch
```

<a name="loops"></a>
### Bucles

Además de las sentencias condicionales, Blade proporciona directivas simples para trabajar con las estructuras de bucle de PHP. De nuevo, cada una de estas directivas funciona de forma idéntica a sus equivalentes en PHP:

```blade
@for ($i = 0; $i < 10; $i++)
    The current value is {{ $i }}
@endfor

@foreach ($users as $user)
    <p>This is user {{ $user->id }}</p>
@endforeach

@forelse ($users as $user)
    <li>{{ $user->name }}</li>
@empty
    <p>No users</p>
@endforelse

@while (true)
    <p>I'm looping forever.</p>
@endwhile
```

> **Nota**  
> Mientras se itera a través de un bucle `foreach`, se puede utilizar la [variable loop](#the-loop-variable) para obtener información valiosa sobre el bucle, como por ejemplo si se está en la primera o en la última iteración a través del bucle.

Cuando utilice bucles, también puede saltarse la iteración actual o finalizar el bucle utilizando las directivas `@continue` y `@break`:

```blade
@foreach ($users as $user)
    @if ($user->type == 1)
        @continue
    @endif

    <li>{{ $user->name }}</li>

    @if ($user->number == 5)
        @break
    @endif
@endforeach
```

También puede incluir la condición de continuación o ruptura dentro de la declaración de la directiva:

```blade
@foreach ($users as $user)
    @continue($user->type == 1)

    <li>{{ $user->name }}</li>

    @break($user->number == 5)
@endforeach
```

<a name="the-loop-variable"></a>
### La Variable Loop

Mientras itera a través de un bucle `foreach`, una variable `$loop` estará disponible dentro de su bucle. Esta variable proporciona acceso a información útil como el índice actual del bucle y si es la primera o la última iteración a través del bucle:

```blade
@foreach ($users as $user)
    @if ($loop->first)
        This is the first iteration.
    @endif

    @if ($loop->last)
        This is the last iteration.
    @endif

    <p>This is user {{ $user->id }}</p>
@endforeach
```

Si estás en un bucle anidado, puedes acceder a la variable `$loop` del bucle padre a través de la propiedad `parent`:

```blade
@foreach ($users as $user)
    @foreach ($user->posts as $post)
        @if ($loop->parent->first)
            This is the first iteration of the parent loop.
        @endif
    @endforeach
@endforeach
```

La variable `$loop` también contiene otras propiedades útiles:

| Propiedad          | Descripción                                                  |
| ------------------ | ------------------------------------------------------------ |
| `$loop->index`     | El índice de la iteración actual del bucle (comienza en 0).  |
| `$loop->iteration` | La iteración actual del bucle (comienza en 1).               |
| `$loop->remaining` | Las iteraciones restantes en el bucle.                       |
| `$loop->count`     | El número total de elementos del array que se está iterando. |
| `$loop->first`     | Si es la primera iteración del bucle.                        |
| `$loop->last`      | Si es la última iteración del bucle.                         |
| `$loop->even`      | Si es una iteración par del bucle.                           |
| `$loop->odd`       | Si es una iteración impar del bucle.                         |
| `$loop->depth`     | El nivel de anidamiento del bucle actual.                    |
| `$loop->parent`    | En un bucle anidado, la variable del bucle padre.            |

<a name="conditional-classes"></a>
### Clases condicionales

La directiva `@class` compila condicionalmente una cadena de clases CSS. La directiva acepta un array de clases donde la clave del array contiene la clase o clases que desea añadir, mientras que el valor es una expresión booleana. Si el elemento del array tiene una clave numérica, siempre se incluirá en la lista de clases renderizada:

```blade
@php
    $isActive = false;
    $hasError = true;
@endphp

<span @class([
    'p-4',
    'font-bold' => $isActive,
    'text-gray-500' => ! $isActive,
    'bg-red' => $hasError,
])></span>

<span class="p-4 text-gray-500 bg-red"></span>
```

<a name="additional-attributes"></a>
### Atributos Adicionales

Para mayor comodidad, puede utilizar la directiva `@checked` para indicar fácilmente si una entrada de casilla de verificación HTML está "marcada". Esta directiva mostrará `checked` si la condición proporcionada se evalúa como `true`:

```blade
<input type="checkbox"
        name="active"
        value="active"
        @checked(old('active', $user->active)) />
```

Del mismo modo, la directiva `@selected` puede utilizarse para indicar si una opción de selección debe estar marcada como "selected":

```blade
<select name="version">
    @foreach ($product->versions as $version)
        <option value="{{ $version }}" @selected(old('version') == $version)>
            {{ $version }}
        </option>
    @endforeach
</select>
```

Además, la directiva `@disabled` puede usarse para indicar si un elemento dado debe ser marcado como "disabled":

```blade
<button type="submit" @disabled($errors->isNotEmpty())>Submit</button>
```

Por otra parte, la directiva `@readonly` puede utilizarse para indicar si un elemento dado debe ser marcado como "readonly":

```blade
<input type="email"
        name="email"
        value="email@laravel.com"
        @readonly($user->isNotAdmin()) />
```

Además, la directiva `@required` puede utilizarse para indicar si un elemento dado debe ser marcado como "required":

```blade
<input type="text"
        name="title"
        value="title"
        @required($user->isAdmin()) />
```

<a name="including-subviews"></a>
### Inclusión de subvistas

> **Nota**  
> Aunque es libre de utilizar la directiva `@include`, [los componentes Blade](#components) proporcionan una funcionalidad similar y ofrecen varias ventajas sobre la directiva `@include`, como la vinculación de datos y atributos.

La directiva `@include` de Blade permite incluir una vista Blade dentro de otra vista. Todas las variables disponibles para la vista padre estarán disponibles para la vista incluida:

```blade
<div>
    @include('shared.errors')

    <form>
        <!-- Form Contents -->
    </form>
</div>
```

Aunque la vista incluida heredará todos los datos disponibles en la vista padre, también puede pasar una array de datos adicionales que se pondrán a disposición de la vista incluida:

```blade
@include('view.name', ['status' => 'complete'])
```

Si intentas incluir una vista que no existe, Laravel arrojará un error. Si quieres incluir una vista que puede o no estar presente, debes usar la directiva `@includeIf`:

```blade
@includeIf('view.name', ['status' => 'complete'])
```

Si quieres incluir una vista si una expresión booleana dada es `true` o `false`, puedes usar las directivas `@includeWhen` y `@includeUnless`:

```blade
@includeWhen($boolean, 'view.name', ['status' => 'complete'])

@includeUnless($boolean, 'view.name', ['status' => 'complete'])
```

Para incluir la primera vista que exista de un array de vistas dado, puede utilizar la directiva `includeFirst`:

```blade
@includeFirst(['custom.admin', 'admin'], ['status' => 'complete'])
```

> **Advertencia**  
> Evita utilizar las constantes `__DIR__` y `__FILE__` en tus vistas Blade, ya que harán referencia a la ubicación de la vista compilada en caché.

<a name="rendering-views-for-collections"></a>
#### Renderizado de vistas para colecciones

Puede combinar bucles e includes en una sola línea con la directiva `@each` de Blade:

```blade
@each('view.name', $jobs, 'job')
```

El primer argumento de la directiva `@each` es la vista a mostrar para cada elemento del array o colección. El segundo argumento es la array o colección sobre la que desea iterar, mientras que el tercer argumento es el nombre de la variable que se asignará a la iteración actual dentro de la vista. Así, por ejemplo, si estás iterando sobre un array de `jobs`, normalmente querrás acceder a cada trabajo como una variable de `job` dentro de la vista. La clave de la array para la iteración actual estará disponible como variable `key` dentro de la vista.

También puede pasar un cuarto argumento a la directiva `@each`. Este argumento determina la vista que se mostrará si la array dada está vacía.

```blade
@each('view.name', $jobs, 'job', 'view.empty')
```

> **Advertencia**  
> Las vistas renderizadas mediante `@each` no heredan las variables de la vista padre. Si la vista hija requiere estas variables, debe utilizar las directivas `@foreach` e `@include` en su lugar.

<a name="the-once-directive"></a>
### La Directiva `@once`

La directiva `@once` permite definir una parte de la plantilla que sólo se evaluará una vez por ciclo de renderizado. Esto puede ser útil para empujar una determinada pieza de JavaScript en la cabecera de la página utilizando [pilas](#stacks). Por ejemplo, si está renderizando un [componente](#components) determinado dentro de un bucle, puede que sólo desee insertar el JavaScript en la cabecera la primera vez que se renderice el componente:

```blade
@once
    @push('scripts')
        <script>
            // Your custom JavaScript...
        </script>
    @endpush
@endonce
```

Dado que la directiva `@once` se utiliza a menudo junto con las directivas `@push` o `@prepend`, las directivas `@pushOnce` y `@prependOnce` están disponibles para su conveniencia:

```blade
@pushOnce('scripts')
    <script>
        // Your custom JavaScript...
    </script>
@endPushOnce
```

<a name="raw-php"></a>
### PHP en crudo

En algunas situaciones, es útil incrustar código PHP en las vistas. Puede utilizar la directiva `@php` de Blade para ejecutar un bloque de PHP plano dentro de su plantilla:

```blade
@php
    $counter = 1;
@endphp
```

Si sólo necesita escribir una única sentencia PHP, puede incluir la sentencia dentro de la directiva `@php`:

```blade
@php($counter = 1)
```

<a name="comments"></a>
### Comentarios

Blade también le permite definir comentarios en sus vistas. Sin embargo, a diferencia de los comentarios HTML, los comentarios de Blade no se incluyen en el HTML devuelto por su aplicación:

```blade
{{-- This comment will not be present in the rendered HTML --}}
```

<a name="components"></a>
## Componentes

Los componentes y los slots proporcionan beneficios similares a las secciones, los layouts y los includes; sin embargo, algunos pueden encontrar el modelo mental de los componentes y los slots más fácil de entender. Existen dos enfoques para escribir componentes: componentes basados en clases y componentes anónimos.

Para crear un componente basado en clases, puede utilizar el comando `make:component` de Artisan. Para ilustrar el uso de componentes, crearemos un simple componente `Alert`. El comando `make:component` colocará el componente en el directorio `app/View/Components`:

```shell
php artisan make:component Alert
```

El comando `make:component` también creará una plantilla de vista para el componente. La vista se colocará en el directorio `resources/views/components`. Al escribir componentes para su propia aplicación, los componentes se descubren automáticamente en el directorio `app/View/Components` y en el directorio `resources/views/components`, por lo que no suele ser necesario registrar más componentes.

También puede crear componentes dentro de subdirectorios:

```shell
php artisan make:component Forms/Input
```

El comando anterior creará un componente `Input` en el directorio `app/View/Components/Forms` y la vista se colocará en el directorio `resources/views/components/forms`.

Si desea crear un componente anónimo (un componente con sólo una plantilla Blade y sin clase), puede utilizar el indicador `--view` al invocar el comando `make:component`:

```shell
php artisan make:component forms.input --view
```

El comando anterior creará un archivo Blade en `resources/views/components/forms/input.blade.php` que puede ser renderizado como un componente a través de `<x-forms.input />`.

<a name="manually-registering-package-components"></a>
#### Registro manual de componentes de paquetes

Al escribir componentes para su propia aplicación, los componentes se descubren automáticamente en el directorio `app/View/Components` y en el directorio `resources/views/components`.

Sin embargo, si está creando un paquete que utiliza componentes Blade, deberá registrar manualmente su clase de componente y su alias de etiqueta HTML. Normalmente, deberá registrar sus componentes en el método `boot` del proveedor de servicios de su paquete:

    use Illuminate\Support\Facades\Blade;

    /**
     * Bootstrap your package's services.
     */
    public function boot()
    {
        Blade::component('package-alert', Alert::class);
    }

Una vez registrado el componente, puede renderizarse utilizando su alias de etiqueta:

```blade
<x-package-alert/>
```

De manera alternativa, puede utilizar el método `componentNamespace` para autocargar las clases de componentes por convención. Por ejemplo, un paquete `Nightshade` puede tener componentes `Calendar` y `ColorPicker` que residan en el espacio de nombres `Package\Views\Components`:

    use Illuminate\Support\Facades\Blade;

    /**
     * Bootstrap your package's services.
     *
     * @return void
     */
    public function boot()
    {
        Blade::componentNamespace('Nightshade\\Views\\Components', 'nightshade');
    }

Esto permitirá el uso de componentes de paquete por su espacio de nombres de proveedor utilizando la sintaxis `package-name::`:

```blade
<x-nightshade::calendar />
<x-nightshade::color-picker />
```

Blade detectará automáticamente la clase vinculada a este componente usando el nombre del componente en pascal-case. También se admiten subdirectorios utilizando la notación "punto".

<a name="rendering-components"></a>
### Renderizado de Componentes

Para mostrar un componente, puede utilizar una etiqueta de componente Blade dentro de una de sus plantillas Blade. Las etiquetas de componente Blade comienzan con la cadena `x-` seguida del nombre en mayúsculas y minúsculas de la clase de componente:

```blade
<x-alert/>

<x-user-profile/>
```

Si la clase del componente está anidada a mayor profundidad dentro del directorio `app/View/Components`, puede utilizar el carácter `.` para indicar el anidamiento del directorio. Por ejemplo, si asumimos que un componente se encuentra en `app/View/Components/Inputs/Button.php`, podemos renderizarlo así:

```blade
<x-inputs.button/>
```

<a name="passing-data-to-components"></a>
### Pasando Datos a los Componentes

Puede pasar datos a los componentes Blade utilizando atributos HTML. Los valores primitivos codificados pueden pasarse al componente usando simples cadenas de atributos HTML. Las expresiones y variables PHP deben pasarse al componente mediante atributos que utilicen el carácter `:` como prefijo:

```blade
<x-alert type="error" :message="$message"/>
```

Debe definir todos los atributos de datos del componente en su constructor de clase. Todas las propiedades públicas de un componente estarán disponibles automáticamente para la vista del componente. No es necesario pasar los datos a la vista desde el método de `render` del componente:

    <?php

    namespace App\View\Components;

    use Illuminate\View\Component;

    class Alert extends Component
    {
        /**
         * The alert type.
         *
         * @var string
         */
        public $type;

        /**
         * The alert message.
         *
         * @var string
         */
        public $message;

        /**
         * Create the component instance.
         *
         * @param  string  $type
         * @param  string  $message
         * @return void
         */
        public function __construct($type, $message)
        {
            $this->type = $type;
            $this->message = $message;
        }

        /**
         * Get the view / contents that represent the component.
         *
         * @return \Illuminate\View\View|\Closure|string
         */
        public function render()
        {
            return view('components.alert');
        }
    }

Cuando su componente es renderizado, puede mostrar el contenido de las variables públicas de su componente haciendo eco de las variables por su nombre:

```blade
<div class="alert alert-{{ $type }}">
    {{ $message }}
</div>
```

<a name="casing"></a>
#### Casing

Los argumentos de los constructores de componentes deben especificarse utilizando `camelCase`, mientras que debe utilizarse `kebab-case` cuando se haga referencia a los nombres de los argumentos en los atributos HTML. Por ejemplo, dado el siguiente constructor de componente:

    /**
     * Create the component instance.
     *
     * @param  string  $alertType
     * @return void
     */
    public function __construct($alertType)
    {
        $this->alertType = $alertType;
    }

El argumento `$alertType` puede proporcionarse al componente de la siguiente manera:

```blade
<x-alert alert-type="danger" />
```

<a name="short-attribute-syntax"></a>
#### Sintaxis corta de atributos

Al pasar atributos a los componentes, también puede utilizar una sintaxis de "atributo corto". Esto suele ser conveniente, ya que los nombres de los atributos suelen coincidir con los nombres de las variables a las que corresponden:

```blade
{{-- Short attribute syntax... --}}
<x-profile :$userId :$name />

{{-- Is equivalent to... --}}
<x-profile :user-id="$userId" :name="$name" />
```

<a name="escaping-attribute-rendering"></a>
#### Cómo evitar el renderizado de atributos

Dado que algunos frameworks JavaScript como Alpine.js también utilizan atributos con prefijo de dos puntos, puede utilizar un prefijo de dos puntos dobles (`::`) para informar a Blade de que el atributo no es una expresión PHP. Por ejemplo, dado el siguiente componente

```blade
<x-button ::class="{ danger: isDeleting }">
    Submit
</x-button>
```

El siguiente HTML será renderizado por Blade:

```blade
<button :class="{ danger: isDeleting }">
    Submit
</button>
```

<a name="component-methods"></a>
#### Métodos del componente

Además de que las variables públicas estén disponibles para su plantilla de componentes, cualquier método público del componente puede ser invocado. Por ejemplo, imagine un componente que tiene un método `isSelected`:

    /**
     * Determine if the given option is the currently selected option.
     *
     * @param  string  $option
     * @return bool
     */
    public function isSelected($option)
    {
        return $option === $this->selected;
    }

Puede ejecutar este método desde su plantilla de componentes invocando la variable que coincida con el nombre del método:

```blade
<option {{ $isSelected($value) ? 'selected' : '' }} value="{{ $value }}">
    {{ $label }}
</option>
```

<a name="using-attributes-slots-within-component-class"></a>
#### Acceso a atributos y slots dentro de las clases de componentes

Los componentes Blade también le permiten acceder al nombre del componente, a los atributos y al slot dentro del método render de la clase. Sin embargo, para acceder a estos datos, debe devolver un closure desde el método de `render` de su componente. El closure recibirá un array `$data` como único argumento. Este array contendrá varios elementos que proporcionan información sobre el componente:

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|\Closure|string
     */
    public function render()
    {
        return function (array $data) {
            // $data['componentName'];
            // $data['attributes'];
            // $data['slot'];

            return '<div>Components content</div>';
        };
    }

El `componentName` es igual al nombre utilizado en la etiqueta HTML después del prefijo `x-`. Así, el `componentName` de `<x-alert />` será `alert`. El elemento `attributes` contendrá todos los atributos presentes en la etiqueta HTML. El elemento `slot` es una instancia `Illuminate\Support\HtmlString` con el contenido del slot del componente.

El closure debe devolver una cadena. Si la cadena devuelta corresponde a una vista existente, esa vista se renderizará; en caso contrario, la cadena devuelta se evaluará como una vista Blade en línea.

<a name="additional-dependencies"></a>
#### Dependencias adicionales

Si su componente requiere dependencias del [contenedor de servicios](/docs/{{version}}/container) de Laravel, puede enumerarlas antes de cualquiera de los atributos de datos del componente y serán inyectadas automáticamente por el contenedor:

```php
use App\Services\AlertCreator;

/**
 * Create the component instance.
 *
 * @param  \App\Services\AlertCreator  $creator
 * @param  string  $type
 * @param  string  $message
 * @return void
 */
public function __construct(AlertCreator $creator, $type, $message)
{
    $this->creator = $creator;
    $this->type = $type;
    $this->message = $message;
}
```

<a name="hiding-attributes-and-methods"></a>
#### Ocultar atributos / métodos

Si desea evitar que algunos métodos públicos o propiedades se expongan como variables a la plantilla de su componente, puede añadirlos a una propiedad `$except` array en su componente:

    <?php

    namespace App\View\Components;

    use Illuminate\View\Component;

    class Alert extends Component
    {
        /**
         * The alert type.
         *
         * @var string
         */
        public $type;

        /**
         * The properties / methods that should not be exposed to the component template.
         *
         * @var array
         */
        protected $except = ['type'];
    }

<a name="component-attributes"></a>
### Atributos de Componentes

Ya hemos examinado cómo pasar atributos de datos a un componente; sin embargo, a veces puede ser necesario especificar atributos HTML adicionales, como `class`, que no forman parte de los datos necesarios para que funcione un componente. Normalmente, querrá pasar estos atributos adicionales al elemento raíz de la plantilla del componente. Por ejemplo, imagine que queremos renderizar un componente de `alert` de la siguiente manera:

```blade
<x-alert type="error" :message="$message" class="mt-4"/>
```

Todos los atributos que no formen parte del constructor del componente se añadirán automáticamente a la "bolsa de atributos" del componente. Esta bolsa de atributos se pone automáticamente a disposición del componente a través de la variable `$attributes`. Todos los atributos pueden ser renderizados dentro del componente haciendo eco de esta variable:

```blade
<div {{ $attributes }}>
    <!-- Component content -->
</div>
```

> **Advertencia**  
> El uso de directivas como `@env` dentro de las etiquetas del componente no está soportado en este momento. Por ejemplo, `<x-alert :live="@env('production')"/>` no será compilado.

<a name="default-merged-attributes"></a>
#### Atributos por defecto / mergeados

A veces puede ser necesario especificar valores por defecto para los atributos o combinar valores adicionales en algunos de los atributos del componente. Para ello, puede utilizar el método de `merge` de la bolsa de atributos. Este método es especialmente útil para definir un conjunto de clases CSS predeterminadas que deben aplicarse siempre a un componente:

```blade
<div {{ $attributes->merge(['class' => 'alert alert-'.$type]) }}>
    {{ $message }}
</div>
```

Si suponemos que este componente se utiliza así:

```blade
<x-alert type="error" :message="$message" class="mb-4"/>
```

El HTML final renderizado del componente tendrá el siguiente aspecto:

```blade
<div class="alert alert-error mb-4">
    <!-- Contents of the $message variable -->
</div>
```

<a name="conditionally-merge-classes"></a>
#### Combinar clases condicionalmente

A veces puede que desee combinar clases si una condición dada es `true`. Puede hacerlo mediante el método `class`, que acepta un array de clases donde la clave array contiene la clase o clases que desea añadir, mientras que el valor es una expresión booleana. Si el elemento del array tiene una clave numérica, siempre se incluirá en la lista de clases renderizada:

```blade
<div {{ $attributes->class(['p-4', 'bg-red' => $hasError]) }}>
    {{ $message }}
</div>
```

Si necesita combinar otros atributos en su componente, puede encadenar el método `merge` con el método `class`:

```blade
<button {{ $attributes->class(['p-4'])->merge(['type' => 'button']) }}>
    {{ $slot }}
</button>
```

> **Nota**  
> Si necesita compilar condicionalmente clases en otros elementos HTML que no deben recibir atributos fusionados, puede utilizar la [directiva `@class`](#conditional-classes).

<a name="non-class-attribute-merging"></a>
#### combinación de atributos no de clase

Al combinar atributos que no son atributos `class`, los valores proporcionados al método `merge` se considerarán los valores "por defecto" del atributo. Sin embargo, a diferencia de los atributos `class`, estos atributos no se combinarán con valores de atributo inyectados. En su lugar, se sobrescribirán. Por ejemplo, la implementación de un componente `button` puede tener el siguiente aspecto:

```blade
<button {{ $attributes->merge(['type' => 'button']) }}>
    {{ $slot }}
</button>
```

Para renderizar el componente botón con un `type` personalizado, se puede especificar al consumir el componente. Si no se especifica ningún tipo, se utilizará el tipo `button`:

```blade
<x-button type="submit">
    Submit
</x-button>
```

El HTML renderizado del componente `button` en este ejemplo sería:

```blade
<button type="submit">
    Submit
</button>
```

Si desea que un atributo distinto a `class` tenga su valor por defecto y los valores inyectados unidos, puede utilizar el método `prepends`. En este ejemplo, el atributo `data-controller` siempre comenzará con `profile-controller` y cualquier valor adicional inyectado de `data-controller` se colocará después de este valor por defecto:

```blade
<div {{ $attributes->merge(['data-controller' => $attributes->prepends('profile-controller')]) }}>
    {{ $slot }}
</div>
```

<a name="filtering-attributes"></a>
#### Recuperación y filtrado de atributos

Puede filtrar atributos utilizando el método `filter`. Este método acepta un closure que debe devolver `true` si desea conservar el atributo en la bolsa de atributos:

```blade
{{ $attributes->filter(fn ($value, $key) => $key == 'foo') }}
```

Para mayor comodidad, puede utilizar el método `whereStartsWith` para recuperar todos los atributos cuyas claves empiecen por una cadena determinada:

```blade
{{ $attributes->whereStartsWith('wire:model') }}
```

Por el contrario, el método `whereDoesntStartWith` puede utilizarse para excluir todos los atributos cuyas claves empiecen por una cadena determinada:

```blade
{{ $attributes->whereDoesntStartWith('wire:model') }}
```

Utilizando el método `first`, puede obtener el primer atributo de una bolsa de atributos dada:

```blade
{{ $attributes->whereStartsWith('wire:model')->first() }}
```

Si desea comprobar si un atributo está presente en el componente, puede utilizar el método `has`. Este método acepta el nombre del atributo como único argumento y devuelve un booleano que indica si el atributo está presente o no:

```blade
@if ($attributes->has('class'))
    <div>Class attribute is present</div>
@endif
```

Puede recuperar el valor de un atributo específico utilizando el método `get`:

```blade
{{ $attributes->get('class') }}
```

<a name="reserved-keywords"></a>
### Palabras clave reservadas

Por defecto, algunas palabras clave están reservadas para el uso interno de Blade con el fin de renderizar componentes. Las siguientes palabras clave no pueden definirse como propiedades públicas o nombres de métodos dentro de sus componentes:

<div class="content-list" markdown="1">

- `data`
- `render`
- `resolveView`
- `shouldRender`
- `view`
- `withAttributes`
- `withName`

</div>

<a name="slots"></a>
### Slots

A menudo necesitará pasar contenido adicional a su componente a través de "slots". Los slots del componente se renderizan haciendo eco de la variable `$slot`. Para explorar este concepto, imaginemos que un componente `alert` tiene la siguiente forma:

```blade
<!-- /resources/views/components/alert.blade.php -->

<div class="alert alert-danger">
    {{ $slot }}
</div>
```

Podemos pasar contenido al `slot` inyectando contenido en el componente:

```blade
<x-alert>
    <strong>Whoops!</strong> Something went wrong!
</x-alert>
```

A veces un componente puede necesitar renderizar múltiples slots diferentes en diferentes ubicaciones dentro del componente. Modifiquemos nuestro componente de alerta para permitir la inyección de un slot de "título":

```blade
<!-- /resources/views/components/alert.blade.php -->

<span class="alert-title">{{ $title }}</span>

<div class="alert alert-danger">
    {{ $slot }}
</div>
```

Puedes definir el contenido del slot nombrado usando la etiqueta `x-slot`. Cualquier contenido que no esté dentro de una etiqueta `x-slot` se pasará al componente en la variable `$slot`:

```xml
<x-alert>
    <x-slot:title>
        Server Error
    </x-slot>

    <strong>Whoops!</strong> Something went wrong!
</x-alert>
```

<a name="scoped-slots"></a>
#### Scoped Slots

Si has utilizado un framework JavaScript como Vue, puede que estés familiarizado con los "scoped slots", que te permiten acceder a datos o métodos del componente dentro de tu slot. Puedes conseguir un comportamiento similar en Laravel definiendo métodos públicos o propiedades en tu componente y accediendo al componente dentro de tu slot a través de la variable `$component`. En este ejemplo, asumiremos que el componente `x-alert` tiene un método público `formatAlert` definido en su clase componente:

```blade
<x-alert>
    <x-slot:title>
        {{ $component->formatAlert('Server Error') }}
    </x-slot>

    <strong>Whoops!</strong> Something went wrong!
</x-alert>
```

<a name="slot-attributes"></a>
#### Atributos de los slots

Al igual que los componentes Blade, puede asignar [atributos](#component-attributes) adicionales a los slots, como nombres de clases CSS:

```xml
<x-card class="shadow-sm">
    <x-slot:heading class="font-bold">
        Heading
    </x-slot>

    Content

    <x-slot:footer class="text-sm">
        Footer
    </x-slot>
</x-card>
```

Para interactuar con los atributos de los slots, puede acceder a la propiedad `attributes` de la variable del slot. Para más información sobre cómo interactuar con los atributos, consulte la documentación sobre [atributos de componentes](#component-attributes):

```blade
@props([
    'heading',
    'footer',
])

<div {{ $attributes->class(['border']) }}>
    <h1 {{ $heading->attributes->class(['text-lg']) }}>
        {{ $heading }}
    </h1>

    {{ $slot }}

    <footer {{ $footer->attributes->class(['text-gray-700']) }}>
        {{ $footer }}
    </footer>
</div>
```

<a name="inline-component-views"></a>
### Vistas de componentes en línea

Para componentes muy pequeños, puede resultar engorroso gestionar tanto la clase del componente como la plantilla de vista del componente. Por esta razón, puede devolver el marcado del componente directamente desde el método `render`:

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|\Closure|string
     */
    public function render()
    {
        return <<<'blade'
            <div class="alert alert-danger">
                {{ $slot }}
            </div>
        blade;
    }

<a name="generating-inline-view-components"></a>
#### Generación de componentes de vista en línea

Para crear un componente que renderice una vista en línea, puede utilizar la opción `inline` al ejecutar el comando `make:component`:

```shell
php artisan make:component Alert --inline
```

<a name="dynamic-components"></a>
### Componentes dinámicos

A veces puede necesitar renderizar un componente pero no saber qué componente debe ser renderizado hasta el momento de la ejecución. En este caso, puedes usar el `dynamic-component` de Laravel para renderizar el componente basándote en un valor o variable en tiempo de ejecución:

```blade
<x-dynamic-component :component="$componentName" class="mt-4" />
```

<a name="manually-registering-components"></a>
### Registro manual de componentes

> **Advertencia**  
> La siguiente documentación sobre el registro manual de componentes es aplicable principalmente a aquellos que están escribiendo paquetes Laravel que incluyen componentes de vista. Si no estás escribiendo un paquete, esta parte de la documentación sobre componentes puede no ser relevante para ti.

Al escribir componentes para su propia aplicación, los componentes se descubren automáticamente en el directorio `app/View/Components` y en el directorio `resources/views/components`.

Sin embargo, si estás construyendo un paquete que utiliza componentes Blade o colocando componentes en directorios no convencionales, necesitarás registrar manualmente tu clase de componente y su alias de etiqueta HTML para que Laravel sepa dónde encontrar el componente. Por lo general, debe registrar sus componentes en el método de `boot` del proveedor de servicios de su paquete:

    use Illuminate\Support\Facades\Blade;
    use VendorPackage\View\Components\AlertComponent;

    /**
     * Bootstrap your package's services.
     *
     * @return void
     */
    public function boot()
    {
        Blade::component('package-alert', AlertComponent::class);
    }

Una vez que su componente ha sido registrado, puede ser renderizado usando su alias de etiqueta:

```blade
<x-package-alert/>
```

#### Autoloading Package Components

De manera alternativa, puede utilizar el método `componentNamespace` para autocargar clases de componentes por convención. Por ejemplo, un paquete `Nightshade` puede tener componentes `Calendar` y `ColorPicker` que residan dentro del espacio de nombres `Package\Views\Components`:

    use Illuminate\Support\Facades\Blade;

    /**
     * Bootstrap your package's services.
     *
     * @return void
     */
    public function boot()
    {
        Blade::componentNamespace('Nightshade\\Views\\Components', 'nightshade');
    }

Esto permitirá el uso de componentes de paquete por su namespace de proveedor utilizando la sintaxis `package-name::`:

```blade
<x-nightshade::calendar />
<x-nightshade::color-picker />
```

Blade detectará automáticamente la clase vinculada a este componente escribiendo el nombre del componente en pascal-case. También se admiten subdirectorios utilizando la notación "punto".

<a name="anonymous-components"></a>
## Componentes anónimos

De forma similar a los componentes en línea, los componentes anónimos proporcionan un mecanismo para gestionar un componente a través de un único archivo. Sin embargo, los componentes anónimos utilizan un único archivo de vista y no tienen una clase asociada. Para definir un componente anónimo, sólo necesita colocar una plantilla Blade dentro de su directorio `resources/views/components`. Por ejemplo, suponiendo que haya definido un componente en `resources/views/components/alert.blade.php`, puede simplemente renderizarlo así:

```blade
<x-alert/>
```

Puede utilizar el carácter `.` para indicar si un componente está anidado a mayor profundidad dentro del directorio `components`. Por ejemplo, asumiendo que el componente está definido en `resources/views/components/inputs/button.blade.`php, puede renderizarlo así:

```blade
<x-inputs.button/>
```

<a name="anonymous-index-components"></a>
### Componentes de índice anónimos

A veces, cuando un componente se compone de muchas plantillas Blade, es posible que desee agrupar las plantillas del componente dado dentro de un único directorio. Por ejemplo, imagine un componente "acordeón" con la siguiente estructura de directorios:

```none
/resources/views/components/accordion.blade.php
/resources/views/components/accordion/item.blade.php
```

Esta estructura de directorios le permite renderizar el componente acordeón y su elemento así:

```blade
<x-accordion>
    <x-accordion.item>
        ...
    </x-accordion.item>
</x-accordion>
```

Sin embargo, para renderizar el componente acordeón a través de `x-accordion`, nos vimos obligados a colocar la plantilla del componente acordeón "index" en el directorio `resources/views/components` en lugar de anidarla dentro del directorio `accordion` con las otras plantillas relacionadas con el acordeón.

Afortunadamente, Blade permite colocar un archivo  `index.blade.php` dentro del directorio de plantillas de un componente. Cuando exista una plantilla `index.blade.php` para el componente, se mostrará como el nodo "raíz" del componente. Por lo tanto, podemos seguir utilizando la misma sintaxis de Blade que en el ejemplo anterior; sin embargo, ajustaremos nuestra estructura de directorios de la siguiente manera:

```none
/resources/views/components/accordion/index.blade.php
/resources/views/components/accordion/item.blade.php
```

<a name="data-properties-attributes"></a>
### Propiedades de datos / Atributos

Dado que los componentes anónimos no tienen ninguna clase asociada, es posible que se pregunte cómo puede diferenciar qué datos deben pasarse al componente como variables y qué atributos deben colocarse en la [bolsa de atributos](#component-attributes) del componente.

Puede especificar qué atributos deben considerarse variables de datos utilizando la directiva `@props` en la parte superior de la plantilla Blade de su componente. Todos los demás atributos del componente estarán disponibles a través de la bolsa de atributos del componente. Si desea dar a una variable de datos un valor por defecto, puede especificar el nombre de la variable como clave del array y el valor por defecto como valor del array:

```blade
<!-- /resources/views/components/alert.blade.php -->

@props(['type' => 'info', 'message'])

<div {{ $attributes->merge(['class' => 'alert alert-'.$type]) }}>
    {{ $message }}
</div>
```

Dada la definición de componente anterior, podemos representar el componente así:

```blade
<x-alert type="error" :message="$message" class="mb-4"/>
```

<a name="accessing-parent-data"></a>
### Acceso a datos principales

A veces es posible que desee acceder a los datos de un componente padre dentro de un componente hijo. En estos casos, puede utilizar la directiva `@aware`. Por ejemplo, imaginemos que estamos construyendo un componente de menú complejo que consta de un padre `<x-menu>` y un hijo `<x-menu.item>:`

```blade
<x-menu color="purple">
    <x-menu.item>...</x-menu.item>
    <x-menu.item>...</x-menu.item>
</x-menu>
```

El componente `<x-menu>` puede tener una implementación como la siguiente:

```blade
<!-- /resources/views/components/menu/index.blade.php -->

@props(['color' => 'gray'])

<ul {{ $attributes->merge(['class' => 'bg-'.$color.'-200']) }}>
    {{ $slot }}
</ul>
```

Debido a que la prop de `color` sólo se pasó al padre (`<x-menu>`), no estará disponible dentro de `<x-menu.item>`. Sin embargo, si utilizamos la directiva `@aware`, podemos hacer que también esté disponible dentro de `<x-menu.item>`

```blade
<!-- /resources/views/components/menu/item.blade.php -->

@aware(['color' => 'gray'])

<li {{ $attributes->merge(['class' => 'text-'.$color.'-800']) }}>
    {{ $slot }}
</li>
```

> **Advertencia**  
> La directiva `@aware` no puede acceder a datos padre que no se hayan pasado explícitamente al componente padre mediante atributos HTML. La directiva `@aware` no puede acceder a valores `@props` predeterminados que no se hayan pasado explícitamente al componente padre.

<a name="anonymous-component-paths"></a>
### Rutas de componentes anónimos

Como se ha comentado anteriormente, los componentes anónimos se definen normalmente colocando una plantilla Blade en el directorio `resources/views/components`. Sin embargo, ocasionalmente puede querer registrar otras rutas de componentes anónimos con Laravel además de la ruta por defecto.

El método `anonymousComponentPath` acepta la "ruta" a la ubicación del componente anónimo como primer argumento y un "namespace" opcional bajo el que deben colocarse los componentes como segundo argumento. Normalmente, este método debería llamarse desde el método `boot` de uno de los [proveedores de servicios](/docs/{{version}}/providers) de su aplicación:

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Blade::anonymousComponentPath(__DIR__.'/../components');
    }

Cuando las rutas de los componentes se registran sin un prefijo especificado como en el ejemplo anterior, pueden ser renderizados también en sus componentes Blade sin un prefijo correspondiente. Por ejemplo, si un componente `panel.blade.php` existe en la ruta registrada arriba, puede ser renderizado así:

```blade
<x-panel />
```

Se pueden proporcionar "namespace" prefijados como segundo argumento del método `anonymousComponentPath`:

    Blade::anonymousComponentPath(__DIR__.'/../components', 'dashboard');

Cuando se proporciona un prefijo, los componentes dentro de ese "namespace" pueden ser renderizados anteponiendo el prefijo del namespace del componente al nombre del componente cuando el este es renderizado:

```blade
<x-dashboard::panel />
```

<a name="building-layouts"></a>
## Creación de diseños

<a name="layouts-using-components"></a>
### Layouts con componentes

La mayoría de las aplicaciones web mantienen el mismo diseño general en varias páginas. Sería increíblemente engorroso y difícil mantener nuestra aplicación si tuviéramos que repetir todo el diseño HTML en cada vista que creamos. Afortunadamente, es conveniente definir este diseño como un único [componente                     Blade](#components) y luego utilizarlo en toda nuestra aplicación.

<a name="defining-the-layout-component"></a>
#### Definición del componente de layout

Por ejemplo, imaginemos que estamos creando una aplicación de listas de tareas. Podríamos definir un componente de `layout` como el siguiente:

```blade
<!-- resources/views/components/layout.blade.php -->

<html>
    <head>
        <title>{{ $title ?? 'Todo Manager' }}</title>
    </head>
    <body>
        <h1>Todos</h1>
        <hr/>
        {{ $slot }}
    </body>
</html>
```

<a name="applying-the-layout-component"></a>
#### Aplicación del componente Layout

Una vez definido el componente de `layout`, podemos crear una vista Blade que utilice el componente. En este ejemplo, definiremos una vista simple que muestre nuestra lista de tareas:

```blade
<!-- resources/views/tasks.blade.php -->

<x-layout>
    @foreach ($tasks as $task)
        {{ $task }}
    @endforeach
</x-layout>
```

Recuerde que el contenido que se inyecte en un componente se suministrará a la variable predeterminada `$slot` dentro de nuestro componente de `layout`. Como habrá notado, nuestro `layout` también respeta un slot `$title` si se proporciona; de lo contrario, se muestra un título predeterminado. Podemos inyectar un título personalizado desde nuestra vista de lista de tareas utilizando la sintaxis de un slot estándar que se discute en la [documentación del componente](#components) :

```blade
<!-- resources/views/tasks.blade.php -->

<x-layout>
    <x-slot:title>
        Custom Title
    </x-slot>

    @foreach ($tasks as $task)
        {{ $task }}
    @endforeach
</x-layout>
```

Ahora que hemos definido nuestras vistas de diseño y de lista de tareas, sólo necesitamos devolver la vista `task` desde una ruta:

    use App\Models\Task;

    Route::get('/tasks', function () {
        return view('tasks', ['tasks' => Task::all()]);
    });

<a name="layouts-using-template-inheritance"></a>
### Diseños con Herencia de Plantillas

<a name="defining-a-layout"></a>
#### Definir un Layout

Los diseños también pueden crearse a través de la "herencia de plantillas". Esta era la forma principal de construir aplicaciones antes de la introducción de [los componentes](#components).

Para empezar, veamos un ejemplo sencillo. En primer lugar, examinaremos el diseño de una página. Dado que la mayoría de las aplicaciones web mantienen el mismo diseño general en varias páginas, es conveniente definir este diseño como una única vista Blade:

```blade
<!-- resources/views/layouts/app.blade.php -->

<html>
    <head>
        <title>App Name - @yield('title')</title>
    </head>
    <body>
        @section('sidebar')
            This is the master sidebar.
        @show

        <div class="container">
            @yield('content')
        </div>
    </body>
</html>
```

Como puede ver, este archivo contiene el típico marcado HTML. Sin embargo, tenga en cuenta las directivas `@section` y `@yield`. La directiva `@section`, como su nombre indica, define una sección de contenido, mientras que la directiva `@yield` se utiliza para mostrar el contenido de una sección determinada.

Ahora que hemos definido un layout para nuestra aplicación, vamos a definir una página hija que herede el diseño.

<a name="extending-a-layout"></a>
#### Extender un layout

Al definir una vista hija, utilice la directiva `@extends` Blade para especificar qué diseño debe "heredar" la vista hija. Las vistas que extienden un diseño Blade pueden inyectar contenido en las secciones del layout utilizando las directivas `@section`. Recuerde que, como se ha visto en el ejemplo anterior, el contenido de estas secciones se mostrará en el diseño mediante `@yield`:

```blade
<!-- resources/views/child.blade.php -->

@extends('layouts.app')

@section('title', 'Page Title')

@section('sidebar')
    @@parent

    <p>This is appended to the master sidebar.</p>
@endsection

@section('content')
    <p>This is my body content.</p>
@endsection
```

En este ejemplo, la sección `sidebar` utiliza la directiva `@@parent` para añadir (en lugar de sobrescribir) contenido a la barra lateral del diseño. La directiva `@@parent` será sustituida por el contenido del diseño cuando se muestre la vista.

> **Nota**  
> A diferencia del ejemplo anterior, esta sección`sidebar` termina con `@endsection` en lugar de `@show`. La directiva `@endsection` sólo definirá una sección, mientras que `@show` definirá y **mostrará inmediatamente** la sección.

La directiva `@yield` también acepta un valor por defecto como segundo parámetro. Este valor se mostrará si la sección que se muestra no está definida:

```blade
@yield('content', 'Default content')
```

<a name="forms"></a>
## Formularios

<a name="csrf-field"></a>
### Campo CSRF

Cada vez que defina un formulario HTML en su aplicación, debe incluir un campo de token CSRF oculto en el formulario para que [el middleware de protección CSRF](/docs/{{version}}/csrf) pueda validar la solicitud. Puede utilizar la directiva `@csrf` Blade para generar el campo token:

```blade
<form method="POST" action="/profile">
    @csrf

    ...
</form>
```

<a name="method-field"></a>
### Campo de método

Dado que los formularios HTML no pueden realizar peticiones `PUT`, `PATCH` o `DELETE`, tendrá que añadir un campo `_method` oculto para imitar estas acciones de222222s HTTP. La directiva `@method` de Blade puede crear este campo por usted:

```blade
<form action="/foo/bar" method="POST">
    @method('PUT')

    ...
</form>
```

<a name="validation-errors"></a>
### Errores de validación

La directiva `@error` puede utilizarse para comprobar rápidamente si existen [mensajes de error de validación](/docs/{{version}}/validation#quick-displaying-the-validation-errors) para un atributo determinado. Dentro de una directiva `@error`, puede hacer eco de la variable `$message` para mostrar el mensaje de error:

```blade
<!-- /resources/views/post/create.blade.php -->

<label for="title">Post Title</label>

<input id="title"
    type="text"
    class="@error('title') is-invalid @enderror">

@error('title')
    <div class="alert alert-danger">{{ $message }}</div>
@enderror
```

Dado que la directiva `@error` se compila como una sentencia "if", puede utilizar la directiva `@else` para mostrar el contenido cuando no haya ningún error para un atributo:

```blade
<!-- /resources/views/auth.blade.php -->

<label for="email">Email address</label>

<input id="email"
    type="email"
    class="@error('email') is-invalid @else is-valid @enderror">
```

Puede pasar [el nombre de una bolsa de errores específica](/docs/{{version}}/validation#named-error-bags) como segundo parámetro de la directiva `@error` para recuperar mensajes de error de validación en páginas que contengan varios formularios:

```blade
<!-- /resources/views/auth.blade.php -->

<label for="email">Email address</label>

<input id="email"
    type="email"
    class="@error('email', 'login') is-invalid @enderror">

@error('email', 'login')
    <div class="alert alert-danger">{{ $message }}</div>
@enderror
```

<a name="stacks"></a>
## Pilas

Blade te permite añadir contenido a pilas con nombre que pueden ser renderizadas en otro lugar en otra vista o layout. Esto puede ser particularmente útil para especificar cualquier librería JavaScript requerida por sus vistas hijas:

```blade
@push('scripts')
    <script src="/example.js"></script>
@endpush
```

Si desea añadir contenido a una pila si una expresión booleana dada se evalúa como `true`, puede utilizar la directiva `@pushIf`:

```blade
@pushIf($shouldPush, 'scripts')
    <script src="/example.js"></script>
@endPushIf
```

Puede añadir contenido a una pila tantas veces como sea necesario. Para mostrar el contenido completo de la pila, pase el nombre de la pila a la directiva `@stack`:

```blade
<head>
    <!-- Head Contents -->

    @stack('scripts')
</head>
```

Si desea añadir contenido al principio de una pila, utilice la directiva `@prepend`:

```blade
@push('scripts')
    This will be second...
@endpush

// Later...

@prepend('scripts')
    This will be first...
@endprepend
```

<a name="service-injection"></a>
## Inyección de Servicios

La directiva `@inject` puede utilizarse para recuperar un servicio del [contenedor de servicios de Laravel](/docs/{{version}}/container). El primer argumento que se pasa a `@inject` es el nombre de la variable en la que se colocará el servicio, mientras que el segundo argumento es el nombre de la clase o interfaz del servicio que se desea resolver:

```blade
@inject('metrics', 'App\Services\MetricsService')

<div>
    Monthly Revenue: {{ $metrics->monthlyRevenue() }}.
</div>
```

<a name="rendering-inline-blade-templates"></a>
## Renderizado de Plantillas Inline Blade

A veces puede que necesite transformar una cadena de plantilla Blade sin procesar en HTML válido. Para ello puede utilizar el método `render` proporcionado por la facade `Blade`. El método `render` acepta la cadena de la plantilla Blade y un array opcional de datos para proporcionar a la plantilla:

```php
use Illuminate\Support\Facades\Blade;

return Blade::render('Hello, {{ $name }}', ['name' => 'Julian Bashir']);
```

Laravel renderiza las plantillas Blade en línea escribiéndolas en el directorio `storage/framework/views`. Si quieres que Laravel elimine estos ficheros temporales después de renderizar la plantilla Blade, puedes proporcionar el argumento `deleteCachedView` al método:

```php
return Blade::render(
    'Hello, {{ $name }}',
    ['name' => 'Julian Bashir'],
    deleteCachedView: true
);
```

<a name="rendering-blade-fragments"></a>
## Renderizado de Fragmentos Blade

Al utilizar frameworks de frontend como [Turbo](https://turbo.hotwired.dev/) y [htmx](https://htmx.org/), puede que ocasionalmente necesite devolver sólo una parte de una plantilla Blade dentro de su respuesta HTTP. Los "fragmentos" de Blade le permiten hacer precisamente eso. Para empezar, coloque una parte de su plantilla Blade dentro de las directivas `@fragment` y `@endfragment`:

```blade
@fragment('user-list')
    <ul>
        @foreach ($users as $user)
            <li>{{ $user->name }}</li>
        @endforeach
    </ul>
@endfragment
```

A continuación, al renderizar la vista que utiliza esta plantilla, puede invocar el método `fragment` para especificar que sólo el fragmento especificado debe incluirse en la respuesta HTTP saliente:

```php
return view('dashboard', ['users' => $users])->fragment('user-list');
```

<a name="extending-blade"></a>
## Ampliación de Blade

Blade le permite definir sus propias directivas personalizadas utilizando el método `directive`. Cuando el compilador de Blade encuentre la directiva personalizada, llamará a la llamada de retorno proporcionada con la expresión que contiene la directiva.

El siguiente ejemplo crea una directiva `@datetime($var)` que formatea una `$var` dada, que debe ser una instancia de `DateTime`:

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\Blade;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Register any application services.
         *
         * @return void
         */
        public function register()
        {
            //
        }

        /**
         * Bootstrap any application services.
         *
         * @return void
         */
        public function boot()
        {
            Blade::directive('datetime', function ($expression) {
                return "<?php echo ($expression)->format('m/d/Y H:i'); ?>";
            });
        }
    }

Como puedes ver, encadenaremos el método `format` a cualquier expresión que se pase a la directiva. Así, en este ejemplo, el PHP final generado por esta directiva será:

    <?php echo ($var)->format('m/d/Y H:i'); ?>

> **Warning**  
> Después de actualizar la lógica de una directiva Blade, deberá eliminar todas las vistas Blade almacenadas en caché. Las vistas Blade almacenadas en caché pueden eliminarse utilizando el comando `view:clear` Artisan.

<a name="custom-echo-handlers"></a>
### Manejadores de Eco Personalizados

Si intenta hacer "eco" de un objeto utilizando Blade, se invocará al método `__toString` del objeto. El método [`__toString`](https://www.php.net/manual/en/language.oop5.magic.php#object.tostring) es uno de los "métodos mágicos" de PHP. Sin embargo, a veces puede que no tenga control sobre el método `__toString` de una clase dada, como cuando la clase con la que está interactuando pertenece a una librería de terceros.

En estos casos, Blade permite registrar un manejador de eco personalizado para ese tipo concreto de objeto. Para lograr esto, debes invocar el método `stringable` de Blade. El método `stringable` acepta un closure. Este closure debe indicar el tipo de objeto del que es responsable. Típicamente, el método `stringable` debería ser invocado dentro del método `boot` de la clase `AppServiceProvider` de su aplicación:

    use Illuminate\Support\Facades\Blade;
    use Money\Money;

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Blade::stringable(function (Money $money) {
            return $money->formatTo('en_GB');
        });
    }

Una vez que su manejador de eco personalizado ha sido definido, puede simplemente hacer eco del objeto en su plantilla Blade:

```blade
Cost: {{ $money }}
```

<a name="custom-if-statements"></a>
### Sentencias If personalizadas

Programar una directiva personalizada es a veces más complejo de lo necesario cuando se trata de definir sentencias condicionales simples y personalizadas. Por esa razón, Blade proporciona un método `Blade::if` que permite definir rápidamente directivas condicionales personalizadas utilizando closures. Por ejemplo, definamos una condicional personalizada que compruebe el "disco" configurado por defecto para la aplicación. Podemos hacer esto en el método `boot` de nuestro `AppServiceProvider`:

    use Illuminate\Support\Facades\Blade;

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Blade::if('disk', function ($value) {
            return config('filesystems.default') === $value;
        });
    }

Una vez definido el condicional personalizado, puede utilizarlo dentro de sus plantillas:

```blade
@disk('local')
    <!-- The application is using the local disk... -->
@elsedisk('s3')
    <!-- The application is using the s3 disk... -->
@else
    <!-- The application is using some other disk... -->
@enddisk

@unlessdisk('local')
    <!-- The application is not using the local disk... -->
@enddisk
```
