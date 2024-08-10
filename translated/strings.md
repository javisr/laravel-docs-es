# Cadenas

- [Introducción](#introducción)
- [Métodos Disponibles](#métodos-disponibles)

<a name="introducción"></a>
## Introducción

Laravel incluye una variedad de funciones para manipular valores de cadena. Muchas de estas funciones son utilizadas por el propio framework; sin embargo, eres libre de usarlas en tus propias aplicaciones si las encuentras convenientes.

<a name="métodos-disponibles"></a>
## Métodos Disponibles

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

<a name="lista-de-métodos-de-cadenas"></a>
### Cadenas

<div class="collection-method-list" markdown="1">

[\__](#method-__)
[class_basename](#method-class-basename)
[e](#method-e)
[preg_replace_array](#method-preg-replace-array)
[Str::after](#method-str-after)
[Str::afterLast](#method-str-after-last)
[Str::apa](#method-str-apa)
[Str::ascii](#method-str-ascii)
[Str::before](#method-str-before)
[Str::beforeLast](#method-str-before-last)
[Str::between](#method-str-between)
[Str::betweenFirst](#method-str-between-first)
[Str::camel](#method-camel-case)
[Str::charAt](#method-char-at)
[Str::chopStart](#method-str-chop-start)
[Str::chopEnd](#method-str-chop-end)
[Str::contains](#method-str-contains)
[Str::containsAll](#method-str-contains-all)
[Str::endsWith](#method-ends-with)
[Str::excerpt](#method-excerpt)
[Str::finish](#method-str-finish)
[Str::headline](#method-str-headline)
[Str::inlineMarkdown](#method-str-inline-markdown)
[Str::is](#method-str-is)
[Str::isAscii](#method-str-is-ascii)
[Str::isJson](#method-str-is-json)
[Str::isUlid](#method-str-is-ulid)
[Str::isUrl](#method-str-is-url)
[Str::isUuid](#method-str-is-uuid)
[Str::kebab](#method-kebab-case)
[Str::lcfirst](#method-str-lcfirst)
[Str::length](#method-str-length)
[Str::limit](#method-str-limit)
[Str::lower](#method-str-lower)
[Str::markdown](#method-str-markdown)
[Str::mask](#method-str-mask)
[Str::orderedUuid](#method-str-ordered-uuid)
[Str::padBoth](#method-str-padboth)
[Str::padLeft](#method-str-padleft)
[Str::padRight](#method-str-padright)
[Str::password](#method-str-password)
[Str::plural](#method-str-plural)
[Str::pluralStudly](#method-str-plural-studly)
[Str::position](#method-str-position)
[Str::random](#method-str-random)
[Str::remove](#method-str-remove)
[Str::repeat](#method-str-repeat)
[Str::replace](#method-str-replace)
[Str::replaceArray](#method-str-replace-array)
[Str::replaceFirst](#method-str-replace-first)
[Str::replaceLast](#method-str-replace-last)
[Str::replaceMatches](#method-str-replace-matches)
[Str::replaceStart](#method-str-replace-start)
[Str::replaceEnd](#method-str-replace-end)
[Str::reverse](#method-str-reverse)
[Str::singular](#method-str-singular)
[Str::slug](#method-str-slug)
[Str::snake](#method-snake-case)
[Str::squish](#method-str-squish)
[Str::start](#method-str-start)
[Str::startsWith](#method-starts-with)
[Str::studly](#method-studly-case)
[Str::substr](#method-str-substr)
[Str::substrCount](#method-str-substrcount)
[Str::substrReplace](#method-str-substrreplace)
[Str::swap](#method-str-swap)
[Str::take](#method-take)
[Str::title](#method-title-case)
[Str::toBase64](#method-str-to-base64)
[Str::toHtmlString](#method-str-to-html-string)
[Str::trim](#method-str-trim)
[Str::ltrim](#method-str-ltrim)
[Str::rtrim](#method-str-rtrim)
[Str::ucfirst](#method-str-ucfirst)
[Str::ucsplit](#method-str-ucsplit)
[Str::upper](#method-str-upper)
[Str::ulid](#method-str-ulid)
[Str::unwrap](#method-str-unwrap)
[Str::uuid](#method-str-uuid)
[Str::wordCount](#method-str-word-count)
[Str::wordWrap](#method-str-word-wrap)
[Str::words](#method-str-words)
[Str::wrap](#method-str-wrap)
[str](#method-str)
[trans](#method-trans)
[trans_choice](#method-trans-choice)

</div>

<a name="lista-de-métodos-de-cadenas-fluentes"></a>
### Cadenas Fluentes

<div class="collection-method-list" markdown="1">

[after](#method-fluent-str-after)
[afterLast](#method-fluent-str-after-last)
[apa](#method-fluent-str-apa)
[append](#method-fluent-str-append)
[ascii](#method-fluent-str-ascii)
[basename](#method-fluent-str-basename)
[before](#method-fluent-str-before)
[beforeLast](#method-fluent-str-before-last)
[between](#method-fluent-str-between)
[betweenFirst](#method-fluent-str-between-first)
[camel](#method-fluent-str-camel)
[charAt](#method-fluent-str-char-at)
[classBasename](#method-fluent-str-class-basename)
[chopStart](#method-fluent-str-chop-start)
[chopEnd](#method-fluent-str-chop-end)
[contains](#method-fluent-str-contains)
[containsAll](#method-fluent-str-contains-all)
[dirname](#method-fluent-str-dirname)
[endsWith](#method-fluent-str-ends-with)
[excerpt](#method-fluent-str-excerpt)
[exactly](#method-fluent-str-exactly)
[explode](#method-fluent-str-explode)
[finish](#method-fluent-str-finish)
[headline](#method-fluent-str-headline)
[inlineMarkdown](#method-fluent-str-inline-markdown)
[is](#method-fluent-str-is)
[isAscii](#method-fluent-str-is-ascii)
[isEmpty](#method-fluent-str-is-empty)
[isNotEmpty](#method-fluent-str-is-not-empty)
[isJson](#method-fluent-str-is-json)
[isUlid](#method-fluent-str-is-ulid)
[isUrl](#method-fluent-str-is-url)
[isUuid](#method-fluent-str-is-uuid)
[kebab](#method-fluent-str-kebab)
[lcfirst](#method-fluent-str-lcfirst)
[length](#method-fluent-str-length)
[limit](#method-fluent-str-limit)
[lower](#method-fluent-str-lower)
[markdown](#method-fluent-str-markdown)
[mask](#method-fluent-str-mask)
[match](#method-fluent-str-match)
[matchAll](#method-fluent-str-match-all)
[isMatch](#method-fluent-str-is-match)
[newLine](#method-fluent-str-new-line)
[padBoth](#method-fluent-str-padboth)
[padLeft](#method-fluent-str-padleft)
[padRight](#method-fluent-str-padright)
[pipe](#method-fluent-str-pipe)
[plural](#method-fluent-str-plural)
[position](#method-fluent-str-position)
[prepend](#method-fluent-str-prepend)
[remove](#method-fluent-str-remove)
[repeat](#method-fluent-str-repeat)
[replace](#method-fluent-str-replace)
[replaceArray](#method-fluent-str-replace-array)
[replaceFirst](#method-fluent-str-replace-first)
[replaceLast](#method-fluent-str-replace-last)
[replaceMatches](#method-fluent-str-replace-matches)
[replaceStart](#method-fluent-str-replace-start)
[replaceEnd](#method-fluent-str-replace-end)
[scan](#method-fluent-str-scan)
[singular](#method-fluent-str-singular)
[slug](#method-fluent-str-slug)
[snake](#method-fluent-str-snake)
[split](#method-fluent-str-split)
[squish](#method-fluent-str-squish)
[start](#method-fluent-str-start)
[startsWith](#method-fluent-str-starts-with)
[stripTags](#method-fluent-str-strip-tags)
[studly](#method-fluent-str-studly)
[substr](#method-fluent-str-substr)
[substrReplace](#method-fluent-str-substrreplace)
[swap](#method-fluent-str-swap)
[take](#method-fluent-str-take)
[tap](#method-fluent-str-tap)
[test](#method-fluent-str-test)
[title](#method-fluent-str-title)
[toBase64](#method-fluent-str-to-base64)
[trim](#method-fluent-str-trim)
[ltrim](#method-fluent-str-ltrim)
[rtrim](#method-fluent-str-rtrim)
[ucfirst](#method-fluent-str-ucfirst)
[ucsplit](#method-fluent-str-ucsplit)
[unwrap](#method-fluent-str-unwrap)
[upper](#method-fluent-str-upper)
[when](#method-fluent-str-when)
[whenContains](#method-fluent-str-when-contains)
[whenContainsAll](#method-fluent-str-when-contains-all)
[whenEmpty](#method-fluent-str-when-empty)
[whenNotEmpty](#method-fluent-str-when-not-empty)
[whenStartsWith](#method-fluent-str-when-starts-with)
[whenEndsWith](#method-fluent-str-when-ends-with)
[whenExactly](#method-fluent-str-when-exactly)
[whenNotExactly](#method-fluent-str-when-not-exactly)
[whenIs](#method-fluent-str-when-is)
[whenIsAscii](#method-fluent-str-when-is-ascii)
[whenIsUlid](#method-fluent-str-when-is-ulid)
[whenIsUuid](#method-fluent-str-when-is-uuid)
[whenTest](#method-fluent-str-when-test)
[wordCount](#method-fluent-str-word-count)
[words](#method-fluent-str-words)

</div>

<a name="cadenas"></a>
## Cadenas

<a name="method-__"></a>
#### `__()` {.collection-method}

La función `__` traduce la cadena de traducción dada o la clave de traducción utilizando tus [archivos de idioma](/docs/{{version}}/localization):

    echo __('Welcome to our application');

    echo __('messages.welcome');

Si la cadena de traducción o la clave especificada no existen, la función `__` devolverá el valor dado. Así, usando el ejemplo anterior, la función `__` devolvería `messages.welcome` si esa clave de traducción no existe.

<a name="method-class-basename"></a>
#### `class_basename()` {.collection-method}

La función `class_basename` devuelve el nombre de la clase de la clase dada con el espacio de nombres de la clase eliminado:

    $class = class_basename('Foo\Bar\Baz');

    // Baz

<a name="method-e"></a>
#### `e()` {.collection-method}

La función `e` ejecuta la función `htmlspecialchars` de PHP con la opción `double_encode` configurada en `true` por defecto:

    echo e('<html>foo</html>');

    // &lt;html&gt;foo&lt;/html&gt;

<a name="method-preg-replace-array"></a>
#### `preg_replace_array()` {.collection-method}

La función `preg_replace_array` reemplaza un patrón dado en la cadena secuencialmente utilizando un array:

    $string = 'The event will take place between :start and :end';

    $replaced = preg_replace_array('/:[a-z_]+/', ['8:30', '9:00'], $string);

    // The event will take place between 8:30 and 9:00

<a name="method-str-after"></a>
#### `Str::after()` {.collection-method}

El método `Str::after` devuelve todo después del valor dado en una cadena. Se devolverá la cadena completa si el valor no existe dentro de la cadena:

    use Illuminate\Support\Str;

    $slice = Str::after('This is my name', 'This is');

    // ' my name'

<a name="method-str-after-last"></a>
#### `Str::afterLast()` {.collection-method}

El método `Str::afterLast` devuelve todo después de la última ocurrencia del valor dado en una cadena. Se devolverá la cadena completa si el valor no existe dentro de la cadena:

    use Illuminate\Support\Str;

    $slice = Str::afterLast('App\Http\Controllers\Controller', '\\');

    // 'Controller'

<a name="method-str-apa"></a>
#### `Str::apa()` {.collection-method}

El método `Str::apa` convierte la cadena dada a mayúsculas siguiendo las [directrices de APA](https://apastyle.apa.org/style-grammar-guidelines/capitalization/title-case):

    use Illuminate\Support\Str;

    $title = Str::apa('Creating A Project');

    // 'Creating a Project'

<a name="method-str-ascii"></a>
#### `Str::ascii()` {.collection-method}

El método `Str::ascii` intentará transliterar la cadena a un valor ASCII:

    use Illuminate\Support\Str;

    $slice = Str::ascii('û');

    // 'u'

<a name="method-str-before"></a>
#### `Str::before()` {.collection-method}

El método `Str::before` devuelve todo antes del valor dado en una cadena:

    use Illuminate\Support\Str;

    $slice = Str::before('This is my name', 'my name');

    // 'This is '

<a name="method-str-before-last"></a>
#### `Str::beforeLast()` {.collection-method}

El método `Str::beforeLast` devuelve todo antes de la última ocurrencia del valor dado en una cadena:

    use Illuminate\Support\Str;

    $slice = Str::beforeLast('This is my name', 'is');

    // 'This '

<a name="method-str-between"></a>
#### `Str::between()` {.collection-method}

El método `Str::between` devuelve la porción de una cadena entre dos valores:

    use Illuminate\Support\Str;

    $slice = Str::between('This is my name', 'This', 'name');

    // ' is my '

<a name="method-str-between-first"></a>
#### `Str::betweenFirst()` {.collection-method}

El método `Str::betweenFirst` devuelve la porción más pequeña posible de una cadena entre dos valores:

    use Illuminate\Support\Str;

    $slice = Str::betweenFirst('[a] bc [d]', '[', ']');

    // 'a'

<a name="method-camel-case"></a>
#### `Str::camel()` {.collection-method}

El método `Str::camel` convierte la cadena dada a `camelCase`:

    use Illuminate\Support\Str;

    $converted = Str::camel('foo_bar');

    // 'fooBar'

<a name="method-char-at"></a>

#### `Str::charAt()` {.collection-method}

El método `Str::charAt` devuelve el carácter en el índice especificado. Si el índice está fuera de límites, se devuelve `false`:

    use Illuminate\Support\Str;

    $character = Str::charAt('This is my name.', 6);

    // 's'

<a name="method-str-chop-start"></a>
#### `Str::chopStart()` {.collection-method}

El método `Str::chopStart` elimina la primera ocurrencia del valor dado solo si el valor aparece al inicio de la cadena:

    use Illuminate\Support\Str;

    $url = Str::chopStart('https://laravel.com', 'https://');

    // 'laravel.com'

También puedes pasar un array como segundo argumento. Si la cadena comienza con cualquiera de los valores en el array, entonces ese valor será eliminado de la cadena:

    use Illuminate\Support\Str;

    $url = Str::chopStart('http://laravel.com', ['https://', 'http://']);

    // 'laravel.com'

<a name="method-str-chop-end"></a>
#### `Str::chopEnd()` {.collection-method}

El método `Str::chopEnd` elimina la última ocurrencia del valor dado solo si el valor aparece al final de la cadena:

    use Illuminate\Support\Str;

    $url = Str::chopEnd('app/Models/Photograph.php', '.php');

    // 'app/Models/Photograph'

También puedes pasar un array como segundo argumento. Si la cadena termina con cualquiera de los valores en el array, entonces ese valor será eliminado de la cadena:

    use Illuminate\Support\Str;

    $url = Str::chopEnd('laravel.com/index.php', ['/index.html', '/index.php']);

    // 'laravel.com'

<a name="method-str-contains"></a>
#### `Str::contains()` {.collection-method}

El método `Str::contains` determina si la cadena dada contiene el valor dado. Este método es sensible a mayúsculas y minúsculas:

    use Illuminate\Support\Str;

    $contains = Str::contains('This is my name', 'my');

    // true

También puedes pasar un array de valores para determinar si la cadena dada contiene cualquiera de los valores en el array:

    use Illuminate\Support\Str;

    $contains = Str::contains('This is my name', ['my', 'foo']);

    // true

<a name="method-str-contains-all"></a>
#### `Str::containsAll()` {.collection-method}

El método `Str::containsAll` determina si la cadena dada contiene todos los valores en un array dado:

    use Illuminate\Support\Str;

    $containsAll = Str::containsAll('This is my name', ['my', 'name']);

    // true

<a name="method-ends-with"></a>
#### `Str::endsWith()` {.collection-method}

El método `Str::endsWith` determina si la cadena dada termina con el valor dado:

    use Illuminate\Support\Str;

    $result = Str::endsWith('This is my name', 'name');

    // true


También puedes pasar un array de valores para determinar si la cadena dada termina con cualquiera de los valores en el array:

    use Illuminate\Support\Str;

    $result = Str::endsWith('This is my name', ['name', 'foo']);

    // true

    $result = Str::endsWith('This is my name', ['this', 'foo']);

    // false

<a name="method-excerpt"></a>
#### `Str::excerpt()` {.collection-method}

El método `Str::excerpt` extrae un extracto de una cadena dada que coincide con la primera instancia de una frase dentro de esa cadena:

    use Illuminate\Support\Str;

    $excerpt = Str::excerpt('This is my name', 'my', [
        'radius' => 3
    ]);

    // '...is my na...'

La opción `radius`, que por defecto es `100`, te permite definir el número de caracteres que deben aparecer en cada lado de la cadena truncada.

Además, puedes usar la opción `omission` para definir la cadena que se añadirá al principio y al final de la cadena truncada:

    use Illuminate\Support\Str;

    $excerpt = Str::excerpt('This is my name', 'name', [
        'radius' => 3,
        'omission' => '(...) '
    ]);

    // '(...) my name'

<a name="method-str-finish"></a>
#### `Str::finish()` {.collection-method}

El método `Str::finish` añade una única instancia del valor dado a una cadena si no termina ya con ese valor:

    use Illuminate\Support\Str;

    $adjusted = Str::finish('this/string', '/');

    // this/string/

    $adjusted = Str::finish('this/string/', '/');

    // this/string/

<a name="method-str-headline"></a>
#### `Str::headline()` {.collection-method}

El método `Str::headline` convierte cadenas delimitadas por mayúsculas, guiones o guiones bajos en una cadena delimitada por espacios con la primera letra de cada palabra en mayúscula:

    use Illuminate\Support\Str;

    $headline = Str::headline('steve_jobs');

    // Steve Jobs

    $headline = Str::headline('EmailNotificationSent');

    // Email Notification Sent

<a name="method-str-inline-markdown"></a>
#### `Str::inlineMarkdown()` {.collection-method}

El método `Str::inlineMarkdown` convierte Markdown con sabor a GitHub en HTML en línea utilizando [CommonMark](https://commonmark.thephpleague.com/). Sin embargo, a diferencia del método `markdown`, no envuelve todo el HTML generado en un elemento de bloque:

    use Illuminate\Support\Str;

    $html = Str::inlineMarkdown('**Laravel**');

    // <strong>Laravel</strong>

#### Seguridad de Markdown

Por defecto, Markdown admite HTML sin procesar, lo que expondrá vulnerabilidades de Cross-Site Scripting (XSS) cuando se use con entrada de usuario sin procesar. Según la [documentación de seguridad de CommonMark](https://commonmark.thephpleague.com/security/), puedes usar la opción `html_input` para escapar o eliminar HTML sin procesar, y la opción `allow_unsafe_links` para especificar si se deben permitir enlaces inseguros. Si necesitas permitir algo de HTML sin procesar, debes pasar tu Markdown compilado a través de un HTML Purifier:

    use Illuminate\Support\Str;

    Str::inlineMarkdown('Inject: <script>alert("Hello XSS!");</script>', [
        'html_input' => 'strip',
        'allow_unsafe_links' => false,
    ]);

    // Inject: alert(&quot;Hello XSS!&quot;);

<a name="method-str-is"></a>
#### `Str::is()` {.collection-method}

El método `Str::is` determina si una cadena dada coincide con un patrón dado. Se pueden usar asteriscos como valores comodín:

    use Illuminate\Support\Str;

    $matches = Str::is('foo*', 'foobar');

    // true

    $matches = Str::is('baz*', 'foobar');

    // false

<a name="method-str-is-ascii"></a>
#### `Str::isAscii()` {.collection-method}

El método `Str::isAscii` determina si una cadena dada es ASCII de 7 bits:

    use Illuminate\Support\Str;

    $isAscii = Str::isAscii('Taylor');

    // true

    $isAscii = Str::isAscii('ü');

    // false

<a name="method-str-is-json"></a>
#### `Str::isJson()` {.collection-method}

El método `Str::isJson` determina si la cadena dada es un JSON válido:

    use Illuminate\Support\Str;

    $result = Str::isJson('[1,2,3]');

    // true

    $result = Str::isJson('{"first": "John", "last": "Doe"}');

    // true

    $result = Str::isJson('{first: "John", last: "Doe"}');

    // false

<a name="method-str-is-url"></a>
#### `Str::isUrl()` {.collection-method}

El método `Str::isUrl` determina si la cadena dada es una URL válida:

    use Illuminate\Support\Str;

    $isUrl = Str::isUrl('http://example.com');

    // true

    $isUrl = Str::isUrl('laravel');

    // false

El método `isUrl` considera una amplia gama de protocolos como válidos. Sin embargo, puedes especificar los protocolos que deben considerarse válidos proporcionándolos al método `isUrl`:

    $isUrl = Str::isUrl('http://example.com', ['http', 'https']);

<a name="method-str-is-ulid"></a>
#### `Str::isUlid()` {.collection-method}

El método `Str::isUlid` determina si la cadena dada es un ULID válido:

    use Illuminate\Support\Str;

    $isUlid = Str::isUlid('01gd6r360bp37zj17nxb55yv40');

    // true

    $isUlid = Str::isUlid('laravel');

    // false

<a name="method-str-is-uuid"></a>
#### `Str::isUuid()` {.collection-method}

El método `Str::isUuid` determina si la cadena dada es un UUID válido:

    use Illuminate\Support\Str;

    $isUuid = Str::isUuid('a0a2a2d2-0b87-4a18-83f2-2529882be2de');

    // true

    $isUuid = Str::isUuid('laravel');

    // false

<a name="method-kebab-case"></a>
#### `Str::kebab()` {.collection-method}

El método `Str::kebab` convierte la cadena dada a `kebab-case`:

    use Illuminate\Support\Str;

    $converted = Str::kebab('fooBar');

    // foo-bar

<a name="method-str-lcfirst"></a>
#### `Str::lcfirst()` {.collection-method}

El método `Str::lcfirst` devuelve la cadena dada con el primer carácter en minúscula:

    use Illuminate\Support\Str;

    $string = Str::lcfirst('Foo Bar');

    // foo Bar

<a name="method-str-length"></a>
#### `Str::length()` {.collection-method}

El método `Str::length` devuelve la longitud de la cadena dada:

    use Illuminate\Support\Str;

    $length = Str::length('Laravel');

    // 7

<a name="method-str-limit"></a>
#### `Str::limit()` {.collection-method}

El método `Str::limit` trunca la cadena dada a la longitud especificada:

    use Illuminate\Support\Str;

    $truncated = Str::limit('The quick brown fox jumps over the lazy dog', 20);

    // The quick brown fox...

Puedes pasar un tercer argumento al método para cambiar la cadena que se añadirá al final de la cadena truncada:

    $truncated = Str::limit('The quick brown fox jumps over the lazy dog', 20, ' (...)');

    // The quick brown fox (...)

Si deseas preservar palabras completas al truncar la cadena, puedes utilizar el argumento `preserveWords`. Cuando este argumento es `true`, la cadena se truncará al límite de la palabra completa más cercana:

    $truncated = Str::limit('The quick brown fox', 12, preserveWords: true);

    // The quick...

<a name="method-str-lower"></a>
#### `Str::lower()` {.collection-method}

El método `Str::lower` convierte la cadena dada a minúsculas:

    use Illuminate\Support\Str;

    $converted = Str::lower('LARAVEL');

    // laravel

<a name="method-str-markdown"></a>
#### `Str::markdown()` {.collection-method}

El método `Str::markdown` convierte Markdown con sabor a GitHub en HTML utilizando [CommonMark](https://commonmark.thephpleague.com/):

    use Illuminate\Support\Str;

    $html = Str::markdown('# Laravel');

    // <h1>Laravel</h1>

    $html = Str::markdown('# Taylor <b>Otwell</b>', [
        'html_input' => 'strip',
    ]);

    // <h1>Taylor Otwell</h1>

#### Seguridad de Markdown

Por defecto, Markdown admite HTML sin procesar, lo que expondrá vulnerabilidades de Cross-Site Scripting (XSS) cuando se use con entrada de usuario sin procesar. Según la [documentación de seguridad de CommonMark](https://commonmark.thephpleague.com/security/), puedes usar la opción `html_input` para escapar o eliminar HTML sin procesar, y la opción `allow_unsafe_links` para especificar si se deben permitir enlaces inseguros. Si necesitas permitir algo de HTML sin procesar, debes pasar tu Markdown compilado a través de un HTML Purifier:

    use Illuminate\Support\Str;

    Str::markdown('Inject: <script>alert("Hello XSS!");</script>', [
        'html_input' => 'strip',
        'allow_unsafe_links' => false,
    ]);

    // <p>Inject: alert(&quot;Hello XSS!&quot;);</p>

<a name="method-str-mask"></a>
#### `Str::mask()` {.collection-method}

El método `Str::mask` enmascara una porción de una cadena con un carácter repetido y puede usarse para ofuscar segmentos de cadenas como direcciones de correo electrónico y números de teléfono:

    use Illuminate\Support\Str;

    $string = Str::mask('taylor@example.com', '*', 3);

    // tay***************

Si es necesario, puedes proporcionar un número negativo como tercer argumento al método `mask`, lo que indicará al método que comience a enmascarar a la distancia dada desde el final de la cadena:

    $string = Str::mask('taylor@example.com', '*', -15, 3);

    // tay***@example.com

<a name="method-str-ordered-uuid"></a>
#### `Str::orderedUuid()` {.collection-method}

El método `Str::orderedUuid` genera un UUID "timestamp first" que puede almacenarse de manera eficiente en una columna de base de datos indexada. Cada UUID que se genera utilizando este método se ordenará después de los UUID generados previamente utilizando el método:

    use Illuminate\Support\Str;

    return (string) Str::orderedUuid();

<a name="method-str-padboth"></a>
#### `Str::padBoth()` {.collection-method}

El método `Str::padBoth` envuelve la función `str_pad` de PHP, rellenando ambos lados de una cadena con otra cadena hasta que la cadena final alcance una longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::padBoth('James', 10, '_');

    // '__James___'

    $padded = Str::padBoth('James', 10);

    // '  James   '

<a name="method-str-padleft"></a>
#### `Str::padLeft()` {.collection-method}

El método `Str::padLeft` envuelve la función `str_pad` de PHP, rellenando el lado izquierdo de una cadena con otra cadena hasta que la cadena final alcance una longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::padLeft('James', 10, '-=');

    // '-=-=-James'

    $padded = Str::padLeft('James', 10);

    // '     James'

<a name="method-str-padright"></a>
#### `Str::padRight()` {.collection-method}

El método `Str::padRight` envuelve la función `str_pad` de PHP, rellenando el lado derecho de una cadena con otra cadena hasta que la cadena final alcance una longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::padRight('James', 10, '-');

    // 'James-----'

    $padded = Str::padRight('James', 10);

    // 'James     '

<a name="method-str-password"></a>
#### `Str::password()` {.collection-method}

El método `Str::password` puede usarse para generar una contraseña segura y aleatoria de una longitud dada. La contraseña consistirá en una combinación de letras, números, símbolos y espacios. Por defecto, las contraseñas tienen 32 caracteres de longitud:

    use Illuminate\Support\Str;

    $password = Str::password();

    // 'EbJo2vE-AS:U,$%_gkrV4n,q~1xy/-_4'

    $password = Str::password(12);

    // 'qwuar>#V|i]N'

<a name="method-str-plural"></a>
#### `Str::plural()` {.collection-method}

El método `Str::plural` convierte una cadena de palabra singular a su forma plural. Esta función admite [cualquiera de los idiomas soportados por el pluralizador de Laravel](/docs/{{version}}/localization#pluralization-language):

    use Illuminate\Support\Str;

    $plural = Str::plural('car');

    // cars

    $plural = Str::plural('child');

    // children

Puedes proporcionar un entero como segundo argumento a la función para recuperar la forma singular o plural de la cadena:

    use Illuminate\Support\Str;

    $plural = Str::plural('child', 2);

    // children

    $singular = Str::plural('child', 1);

    // child

<a name="method-str-plural-studly"></a>
#### `Str::pluralStudly()` {.collection-method}

El método `Str::pluralStudly` convierte una cadena de palabra singular formateada en mayúsculas a su forma plural. Esta función admite [cualquiera de los idiomas soportados por el pluralizador de Laravel](/docs/{{version}}/localization#pluralization-language):

    use Illuminate\Support\Str;

    $plural = Str::pluralStudly('VerifiedHuman');

    // VerifiedHumans

    $plural = Str::pluralStudly('UserFeedback');

    // UserFeedback

Puedes proporcionar un entero como segundo argumento a la función para recuperar la forma singular o plural de la cadena:

    use Illuminate\Support\Str;

    $plural = Str::pluralStudly('VerifiedHuman', 2);

    // VerifiedHumans

    $singular = Str::pluralStudly('VerifiedHuman', 1);

    // VerifiedHuman

<a name="method-str-position"></a>
#### `Str::position()` {.collection-method}

El método `Str::position` devuelve la posición de la primera ocurrencia de una subcadena en una cadena. Si la subcadena no existe en la cadena dada, se devuelve `false`:

    use Illuminate\Support\Str;

    $position = Str::position('Hello, World!', 'Hello');

    // 0

    $position = Str::position('Hello, World!', 'W');

    // 7

<a name="method-str-random"></a>
#### `Str::random()` {.collection-method}

El método `Str::random` genera una cadena aleatoria de la longitud especificada. Esta función utiliza la función `random_bytes` de PHP:

    use Illuminate\Support\Str;

    $random = Str::random(40);

Durante las pruebas, puede ser útil "fingir" el valor que se devuelve mediante el método `Str::random`. Para lograr esto, puedes usar el método `createRandomStringsUsing`:

    Str::createRandomStringsUsing(function () {
        return 'fake-random-string';
    });

Para instruir al método `random` a que vuelva a generar cadenas aleatorias normalmente, puedes invocar el método `createRandomStringsNormally`:

    Str::createRandomStringsNormally();

<a name="method-str-remove"></a>
#### `Str::remove()` {.collection-method}

El método `Str::remove` elimina el valor dado o el array de valores de la cadena:

    use Illuminate\Support\Str;

    $string = 'Peter Piper picked a peck of pickled peppers.';

    $removed = Str::remove('e', $string);

    // Ptr Pipr pickd a pck of pickld ppprs.

También puedes pasar `false` como tercer argumento al método `remove` para ignorar mayúsculas y minúsculas al eliminar cadenas.

<a name="method-str-repeat"></a>
#### `Str::repeat()` {.collection-method}

El método `Str::repeat` repite la cadena dada:

```php
use Illuminate\Support\Str;

$string = 'a';

$repeat = Str::repeat($string, 5);

// aaaaa
```

<a name="method-str-replace"></a>
#### `Str::replace()` {.collection-method}

El método `Str::replace` reemplaza una cadena dada dentro de la cadena:

    use Illuminate\Support\Str;

    $string = 'Laravel 10.x';

    $replaced = Str::replace('10.x', '11.x', $string);

    // Laravel 11.x

El método `replace` también acepta un argumento `caseSensitive`. Por defecto, el método `replace` es sensible a mayúsculas y minúsculas:

    Str::replace('Framework', 'Laravel', caseSensitive: false);

<a name="method-str-replace-array"></a>
#### `Str::replaceArray()` {.collection-method}

El método `Str::replaceArray` reemplaza un valor dado en la cadena secuencialmente utilizando un array:

    use Illuminate\Support\Str;

    $string = 'The event will take place between ? and ?';

    $replaced = Str::replaceArray('?', ['8:30', '9:00'], $string);

    // The event will take place between 8:30 and 9:00

<a name="method-str-replace-first"></a>
#### `Str::replaceFirst()` {.collection-method}

El método `Str::replaceFirst` reemplaza la primera ocurrencia de un valor dado en una cadena:

    use Illuminate\Support\Str;

    $replaced = Str::replaceFirst('the', 'a', 'the quick brown fox jumps over the lazy dog');

    // a quick brown fox jumps over the lazy dog

<a name="method-str-replace-last"></a>
#### `Str::replaceLast()` {.collection-method}

El método `Str::replaceLast` reemplaza la última ocurrencia de un valor dado en una cadena:

    use Illuminate\Support\Str;

    $replaced = Str::replaceLast('the', 'a', 'the quick brown fox jumps over the lazy dog');

    // the quick brown fox jumps over a lazy dog

<a name="method-str-replace-matches"></a>
#### `Str::replaceMatches()` {.collection-method}

El método `Str::replaceMatches` reemplaza todas las porciones de una cadena que coinciden con un patrón con la cadena de reemplazo dada:

```php
    use Illuminate\Support\Str;

    $replaced = Str::replaceMatches(
        pattern: '/[^A-Za-z0-9]++/',
        replace: '',
        subject: '(+1) 501-555-1000'
    )

    // '15015551000'

El método `replaceMatches` también acepta una función anónima que será invocada con cada porción de la cadena que coincida con el patrón dado, lo que te permite realizar la lógica de reemplazo dentro de la función anónima y devolver el valor reemplazado:

    use Illuminate\Support\Str;

    $replaced = Str::replaceMatches('/\d/', function (array $matches) {
        return '['.$matches[0].']';
    }, '123');

    // '[1][2][3]'

<a name="method-str-replace-start"></a>
#### `Str::replaceStart()` {.collection-method}

El método `Str::replaceStart` reemplaza la primera ocurrencia del valor dado solo si el valor aparece al inicio de la cadena:

    use Illuminate\Support\Str;

    $replaced = Str::replaceStart('Hello', 'Laravel', 'Hello World');

    // Laravel World

    $replaced = Str::replaceStart('World', 'Laravel', 'Hello World');

    // Hello World

<a name="method-str-replace-end"></a>
#### `Str::replaceEnd()` {.collection-method}

El método `Str::replaceEnd` reemplaza la última ocurrencia del valor dado solo si el valor aparece al final de la cadena:

    use Illuminate\Support\Str;

    $replaced = Str::replaceEnd('World', 'Laravel', 'Hello World');

    // Hello Laravel

    $replaced = Str::replaceEnd('Hello', 'Laravel', 'Hello World');

    // Hello World

<a name="method-str-reverse"></a>
#### `Str::reverse()` {.collection-method}

El método `Str::reverse` invierte la cadena dada:

    use Illuminate\Support\Str;

    $reversed = Str::reverse('Hello World');

    // dlroW olleH

<a name="method-str-singular"></a>
#### `Str::singular()` {.collection-method}

El método `Str::singular` convierte una cadena a su forma singular. Esta función soporta [cualquiera de los idiomas soportados por el pluralizador de Laravel](/docs/{{version}}/localization#pluralization-language):

    use Illuminate\Support\Str;

    $singular = Str::singular('cars');

    // car

    $singular = Str::singular('children');

    // child

<a name="method-str-slug"></a>
#### `Str::slug()` {.collection-method}

El método `Str::slug` genera un "slug" amigable con URL a partir de la cadena dada:

    use Illuminate\Support\Str;

    $slug = Str::slug('Laravel 5 Framework', '-');

    // laravel-5-framework

<a name="method-snake-case"></a>
#### `Str::snake()` {.collection-method}

El método `Str::snake` convierte la cadena dada a `snake_case`:

    use Illuminate\Support\Str;

    $converted = Str::snake('fooBar');

    // foo_bar

    $converted = Str::snake('fooBar', '-');

    // foo-bar

<a name="method-str-squish"></a>
#### `Str::squish()` {.collection-method}

El método `Str::squish` elimina todos los espacios en blanco superfluos de una cadena, incluidos los espacios en blanco entre palabras:

    use Illuminate\Support\Str;

    $string = Str::squish('    laravel    framework    ');

    // laravel framework

<a name="method-str-start"></a>
#### `Str::start()` {.collection-method}

El método `Str::start` agrega una única instancia del valor dado a una cadena si no comienza ya con ese valor:

    use Illuminate\Support\Str;

    $adjusted = Str::start('this/string', '/');

    // /this/string

    $adjusted = Str::start('/this/string', '/');

    // /this/string

<a name="method-starts-with"></a>
#### `Str::startsWith()` {.collection-method}

El método `Str::startsWith` determina si la cadena dada comienza con el valor dado:

    use Illuminate\Support\Str;

    $result = Str::startsWith('This is my name', 'This');

    // true

Si se pasa un array de valores posibles, el método `startsWith` devolverá `true` si la cadena comienza con cualquiera de los valores dados:

    $result = Str::startsWith('This is my name', ['This', 'That', 'There']);

    // true

<a name="method-studly-case"></a>
#### `Str::studly()` {.collection-method}

El método `Str::studly` convierte la cadena dada a `StudlyCase`:

    use Illuminate\Support\Str;

    $converted = Str::studly('foo_bar');

    // FooBar

<a name="method-str-substr"></a>
#### `Str::substr()` {.collection-method}

El método `Str::substr` devuelve la porción de la cadena especificada por los parámetros de inicio y longitud:

    use Illuminate\Support\Str;

    $converted = Str::substr('The Laravel Framework', 4, 7);

    // Laravel

<a name="method-str-substrcount"></a>
#### `Str::substrCount()` {.collection-method}

El método `Str::substrCount` devuelve el número de ocurrencias de un valor dado en la cadena dada:

    use Illuminate\Support\Str;

    $count = Str::substrCount('If you like ice cream, you will like snow cones.', 'like');

    // 2

<a name="method-str-substrreplace"></a>
#### `Str::substrReplace()` {.collection-method}

El método `Str::substrReplace` reemplaza texto dentro de una porción de una cadena, comenzando en la posición especificada por el tercer argumento y reemplazando el número de caracteres especificado por el cuarto argumento. Pasar `0` al cuarto argumento del método insertará la cadena en la posición especificada sin reemplazar ninguno de los caracteres existentes en la cadena:

    use Illuminate\Support\Str;

    $result = Str::substrReplace('1300', ':', 2);
    // 13:

    $result = Str::substrReplace('1300', ':', 2, 0);
    // 13:00

<a name="method-str-swap"></a>
#### `Str::swap()` {.collection-method}

El método `Str::swap` reemplaza múltiples valores en la cadena dada utilizando la función `strtr` de PHP:

    use Illuminate\Support\Str;

    $string = Str::swap([
        'Tacos' => 'Burritos',
        'great' => 'fantastic',
    ], 'Tacos are great!');

    // Burritos are fantastic!

<a name="method-take"></a>
#### `Str::take()` {.collection-method}

El método `Str::take` devuelve un número especificado de caracteres desde el principio de una cadena:

    use Illuminate\Support\Str;

    $taken = Str::take('Build something amazing!', 5);

    // Build

<a name="method-title-case"></a>
#### `Str::title()` {.collection-method}

El método `Str::title` convierte la cadena dada a `Title Case`:

    use Illuminate\Support\Str;

    $converted = Str::title('a nice title uses the correct case');

    // A Nice Title Uses The Correct Case

<a name="method-str-to-base64"></a>
#### `Str::toBase64()` {.collection-method}

El método `Str::toBase64` convierte la cadena dada a Base64:

    use Illuminate\Support\Str;

    $base64 = Str::toBase64('Laravel');

    // TGFyYXZlbA==

<a name="method-str-to-html-string"></a>
#### `Str::toHtmlString()` {.collection-method}

El método `Str::toHtmlString` convierte la instancia de cadena en una instancia de `Illuminate\Support\HtmlString`, que puede ser mostrada en plantillas Blade:

    use Illuminate\Support\Str;

    $htmlString = Str::of('Nuno Maduro')->toHtmlString();

<a name="method-str-trim"></a>
#### `Str::trim()` {.collection-method}

El método `Str::trim` elimina espacios en blanco (u otros caracteres) del principio y del final de la cadena dada. A diferencia de la función `trim` nativa de PHP, el método `Str::trim` también elimina caracteres de espacio en blanco unicode:

    use Illuminate\Support\Str;

    $string = Str::trim(' foo bar ');

    // 'foo bar'

<a name="method-str-ltrim"></a>
#### `Str::ltrim()` {.collection-method}

El método `Str::ltrim` elimina espacios en blanco (u otros caracteres) del principio de la cadena dada. A diferencia de la función `ltrim` nativa de PHP, el método `Str::ltrim` también elimina caracteres de espacio en blanco unicode:

    use Illuminate\Support\Str;

    $string = Str::ltrim('  foo bar  ');

    // 'foo bar  '

<a name="method-str-rtrim"></a>
#### `Str::rtrim()` {.collection-method}

El método `Str::rtrim` elimina espacios en blanco (u otros caracteres) del final de la cadena dada. A diferencia de la función `rtrim` nativa de PHP, el método `Str::rtrim` también elimina caracteres de espacio en blanco unicode:

    use Illuminate\Support\Str;

    $string = Str::rtrim('  foo bar  ');

    // '  foo bar'

<a name="method-str-ucfirst"></a>
#### `Str::ucfirst()` {.collection-method}

El método `Str::ucfirst` devuelve la cadena dada con el primer carácter en mayúscula:

    use Illuminate\Support\Str;

    $string = Str::ucfirst('foo bar');

    // Foo bar

<a name="method-str-ucsplit"></a>
#### `Str::ucsplit()` {.collection-method}

El método `Str::ucsplit` divide la cadena dada en un array por caracteres en mayúscula:

    use Illuminate\Support\Str;

    $segments = Str::ucsplit('FooBar');

    // [0 => 'Foo', 1 => 'Bar']

<a name="method-str-upper"></a>
#### `Str::upper()` {.collection-method}

El método `Str::upper` convierte la cadena dada a mayúsculas:

    use Illuminate\Support\Str;

    $string = Str::upper('laravel');

    // LARAVEL

<a name="method-str-ulid"></a>
#### `Str::ulid()` {.collection-method}

El método `Str::ulid` genera un ULID, que es un identificador único compacto y ordenado por tiempo:

    use Illuminate\Support\Str;

    return (string) Str::ulid();

    // 01gd6r360bp37zj17nxb55yv40

Si deseas recuperar una instancia de fecha `Illuminate\Support\Carbon` que represente la fecha y hora en que se creó un ULID dado, puedes usar el método `createFromId` proporcionado por la integración de Carbon de Laravel:

```php
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

$date = Carbon::createFromId((string) Str::ulid());
```

Durante las pruebas, puede ser útil "falsificar" el valor que se devuelve por el método `Str::ulid`. Para lograr esto, puedes usar el método `createUlidsUsing`:

    use Symfony\Component\Uid\Ulid;

    Str::createUlidsUsing(function () {
        return new Ulid('01HRDBNHHCKNW2AK4Z29SN82T9');
    });

Para instruir al método `ulid` a que vuelva a generar ULIDs normalmente, puedes invocar el método `createUlidsNormally`:

    Str::createUlidsNormally();

<a name="method-str-unwrap"></a>
#### `Str::unwrap()` {.collection-method}

El método `Str::unwrap` elimina las cadenas especificadas del principio y del final de una cadena dada:

    use Illuminate\Support\Str;

    Str::unwrap('-Laravel-', '-');

    // Laravel

    Str::unwrap('{framework: "Laravel"}', '{', '}');

    // framework: "Laravel"

<a name="method-str-uuid"></a>
#### `Str::uuid()` {.collection-method}

El método `Str::uuid` genera un UUID (versión 4):

    use Illuminate\Support\Str;

    return (string) Str::uuid();

Durante las pruebas, puede ser útil "falsificar" el valor que se devuelve por el método `Str::uuid`. Para lograr esto, puedes usar el método `createUuidsUsing`:

    use Ramsey\Uuid\Uuid;

    Str::createUuidsUsing(function () {
        return Uuid::fromString('eadbfeac-5258-45c2-bab7-ccb9b5ef74f9');
    });

Para instruir al método `uuid` a que vuelva a generar UUIDs normalmente, puedes invocar el método `createUuidsNormally`:

    Str::createUuidsNormally();

<a name="method-str-word-count"></a>
#### `Str::wordCount()` {.collection-method}

El método `Str::wordCount` devuelve el número de palabras que contiene una cadena:

```php
use Illuminate\Support\Str;

Str::wordCount('Hello, world!'); // 2
```

<a name="method-str-word-wrap"></a>
#### `Str::wordWrap()` {.collection-method}

El método `Str::wordWrap` envuelve una cadena a un número dado de caracteres:

    use Illuminate\Support\Str;

    $text = "The quick brown fox jumped over the lazy dog."

    Str::wordWrap($text, characters: 20, break: "<br />\n");

    /*
    The quick brown fox<br />
    jumped over the lazy<br />
    dog.
    */

<a name="method-str-words"></a>
#### `Str::words()` {.collection-method}

El método `Str::words` limita el número de palabras en una cadena. Se puede pasar una cadena adicional a este método a través de su tercer argumento para especificar qué cadena debe ser añadida al final de la cadena truncada:

    use Illuminate\Support\Str;

    return Str::words('Perfectly balanced, as all things should be.', 3, ' >>>');

    // Perfectly balanced, as >>>

<a name="method-str-wrap"></a>
#### `Str::wrap()` {.collection-method}

El método `Str::wrap` envuelve la cadena dada con una cadena adicional o un par de cadenas:

    use Illuminate\Support\Str;

    Str::wrap('Laravel', '"');

    // "Laravel"

    Str::wrap('is', before: 'This ', after: ' Laravel!');

    // This is Laravel!

<a name="method-str"></a>
#### `str()` {.collection-method}

La función `str` devuelve una nueva instancia de `Illuminate\Support\Stringable` de la cadena dada. Esta función es equivalente al método `Str::of`:

    $string = str('Taylor')->append(' Otwell');

    // 'Taylor Otwell'

Si no se proporciona ningún argumento a la función `str`, la función devuelve una instancia de `Illuminate\Support\Str`:

    $snake = str()->snake('FooBar');

    // 'foo_bar'

<a name="method-trans"></a>
#### `trans()` {.collection-method}

La función `trans` traduce la clave de traducción dada utilizando tus [archivos de idioma](/docs/{{version}}/localization):

    echo trans('messages.welcome');

Si la clave de traducción especificada no existe, la función `trans` devolverá la clave dada. Así, usando el ejemplo anterior, la función `trans` devolvería `messages.welcome` si la clave de traducción no existe.

<a name="method-trans-choice"></a>
#### `trans_choice()` {.collection-method}

La función `trans_choice` traduce la clave de traducción dada con inflexión:

    echo trans_choice('messages.notifications', $unreadCount);

Si la clave de traducción especificada no existe, la función `trans_choice` devolverá la clave dada. Así, usando el ejemplo anterior, la función `trans_choice` devolvería `messages.notifications` si la clave de traducción no existe.

<a name="fluent-strings"></a>
## Fluent Strings

Las cadenas fluidas proporcionan una interfaz más fluida y orientada a objetos para trabajar con valores de cadena, lo que te permite encadenar múltiples operaciones de cadena juntas utilizando una sintaxis más legible en comparación con las operaciones de cadena tradicionales.

<a name="method-fluent-str-after"></a>
#### `after` {.collection-method}

El método `after` devuelve todo después del valor dado en una cadena. Se devolverá la cadena completa si el valor no existe dentro de la cadena:

    use Illuminate\Support\Str;

    $slice = Str::of('This is my name')->after('This is');

    // ' my name'

<a name="method-fluent-str-after-last"></a>
#### `afterLast` {.collection-method}

El método `afterLast` devuelve todo después de la última ocurrencia del valor dado en una cadena. Se devolverá la cadena completa si el valor no existe dentro de la cadena:

    use Illuminate\Support\Str;

    $slice = Str::of('App\Http\Controllers\Controller')->afterLast('\\');

    // 'Controller'

<a name="method-fluent-str-apa"></a>
#### `apa` {.collection-method}

El método `apa` convierte la cadena dada a mayúsculas siguiendo las [directrices de APA](https://apastyle.apa.org/style-grammar-guidelines/capitalization/title-case):

    use Illuminate\Support\Str;

    $converted = Str::of('a nice title uses the correct case')->apa();

    // A Nice Title Uses the Correct Case

<a name="method-fluent-str-append"></a>
#### `append` {.collection-method}

El método `append` añade los valores dados a la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('Taylor')->append(' Otwell');

    // 'Taylor Otwell'

<a name="method-fluent-str-ascii"></a>
#### `ascii` {.collection-method}

El método `ascii` intentará transliterar la cadena a un valor ASCII:

    use Illuminate\Support\Str;

    $string = Str::of('ü')->ascii();

    // 'u'

<a name="method-fluent-str-basename"></a>
#### `basename` {.collection-method}
```

El método `basename` devolverá el componente de nombre final de la cadena dada:

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz')->basename();

    // 'baz'

Si es necesario, puede proporcionar una "extensión" que se eliminará del componente final:

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz.jpg')->basename('.jpg');

    // 'baz'

<a name="method-fluent-str-before"></a>
#### `before` {.collection-method}

El método `before` devuelve todo lo que está antes del valor dado en una cadena:

    use Illuminate\Support\Str;

    $slice = Str::of('This is my name')->before('my name');

    // 'This is '

<a name="method-fluent-str-before-last"></a>
#### `beforeLast` {.collection-method}

El método `beforeLast` devuelve todo lo que está antes de la última ocurrencia del valor dado en una cadena:

    use Illuminate\Support\Str;

    $slice = Str::of('This is my name')->beforeLast('is');

    // 'This '

<a name="method-fluent-str-between"></a>
#### `between` {.collection-method}

El método `between` devuelve la porción de una cadena entre dos valores:

    use Illuminate\Support\Str;

    $converted = Str::of('This is my name')->between('This', 'name');

    // ' is my '

<a name="method-fluent-str-between-first"></a>
#### `betweenFirst` {.collection-method}

El método `betweenFirst` devuelve la porción más pequeña posible de una cadena entre dos valores:

    use Illuminate\Support\Str;

    $converted = Str::of('[a] bc [d]')->betweenFirst('[', ']');

    // 'a'

<a name="method-fluent-str-camel"></a>
#### `camel` {.collection-method}

El método `camel` convierte la cadena dada a `camelCase`:

    use Illuminate\Support\Str;

    $converted = Str::of('foo_bar')->camel();

    // 'fooBar'

<a name="method-fluent-str-char-at"></a>
#### `charAt` {.collection-method}

El método `charAt` devuelve el carácter en el índice especificado. Si el índice está fuera de límites, se devuelve `false`:

    use Illuminate\Support\Str;

    $character = Str::of('This is my name.')->charAt(6);

    // 's'

<a name="method-fluent-str-class-basename"></a>
#### `classBasename` {.collection-method}

El método `classBasename` devuelve el nombre de la clase de la clase dada con el espacio de nombres de la clase eliminado:

    use Illuminate\Support\Str;

    $class = Str::of('Foo\Bar\Baz')->classBasename();

    // 'Baz'

<a name="method-fluent-str-chop-start"></a>
#### `chopStart` {.collection-method}

El método `chopStart` elimina la primera ocurrencia del valor dado solo si el valor aparece al inicio de la cadena:

    use Illuminate\Support\Str;

    $url = Str::of('https://laravel.com')->chopStart('https://');

    // 'laravel.com'

También puede pasar un array. Si la cadena comienza con cualquiera de los valores en el array, entonces ese valor se eliminará de la cadena:

    use Illuminate\Support\Str;

    $url = Str::of('http://laravel.com')->chopStart(['https://', 'http://']);

    // 'laravel.com'

<a name="method-fluent-str-chop-end"></a>
#### `chopEnd` {.collection-method}

El método `chopEnd` elimina la última ocurrencia del valor dado solo si el valor aparece al final de la cadena:

    use Illuminate\Support\Str;

    $url = Str::of('https://laravel.com')->chopEnd('.com');

    // 'https://laravel'

También puede pasar un array. Si la cadena termina con cualquiera de los valores en el array, entonces ese valor se eliminará de la cadena:

    use Illuminate\Support\Str;

    $url = Str::of('http://laravel.com')->chopEnd(['.com', '.io']);

    // 'http://laravel'

<a name="method-fluent-str-contains"></a>
#### `contains` {.collection-method}

El método `contains` determina si la cadena dada contiene el valor dado. Este método es sensible a mayúsculas y minúsculas:

    use Illuminate\Support\Str;

    $contains = Str::of('This is my name')->contains('my');

    // true

También puede pasar un array de valores para determinar si la cadena dada contiene cualquiera de los valores en el array:

    use Illuminate\Support\Str;

    $contains = Str::of('This is my name')->contains(['my', 'foo']);

    // true

<a name="method-fluent-str-contains-all"></a>
#### `containsAll` {.collection-method}

El método `containsAll` determina si la cadena dada contiene todos los valores en el array dado:

    use Illuminate\Support\Str;

    $containsAll = Str::of('This is my name')->containsAll(['my', 'name']);

    // true

<a name="method-fluent-str-dirname"></a>
#### `dirname` {.collection-method}

El método `dirname` devuelve la porción del directorio padre de la cadena dada:

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz')->dirname();

    // '/foo/bar'

Si es necesario, puede especificar cuántos niveles de directorio desea recortar de la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz')->dirname(2);

    // '/foo'

<a name="method-fluent-str-excerpt"></a>
#### `excerpt` {.collection-method}

El método `excerpt` extrae un extracto de la cadena que coincide con la primera instancia de una frase dentro de esa cadena:

    use Illuminate\Support\Str;

    $excerpt = Str::of('This is my name')->excerpt('my', [
        'radius' => 3
    ]);

    // '...is my na...'

La opción `radius`, que por defecto es `100`, le permite definir el número de caracteres que deben aparecer a cada lado de la cadena truncada.

Además, puede usar la opción `omission` para cambiar la cadena que se agregará al principio y al final de la cadena truncada:

    use Illuminate\Support\Str;

    $excerpt = Str::of('This is my name')->excerpt('name', [
        'radius' => 3,
        'omission' => '(...) '
    ]);

    // '(...) my name'

<a name="method-fluent-str-ends-with"></a>
#### `endsWith` {.collection-method}

El método `endsWith` determina si la cadena dada termina con el valor dado:

    use Illuminate\Support\Str;

    $result = Str::of('This is my name')->endsWith('name');

    // true

También puede pasar un array de valores para determinar si la cadena dada termina con cualquiera de los valores en el array:

    use Illuminate\Support\Str;

    $result = Str::of('This is my name')->endsWith(['name', 'foo']);

    // true

    $result = Str::of('This is my name')->endsWith(['this', 'foo']);

    // false

<a name="method-fluent-str-exactly"></a>
#### `exactly` {.collection-method}

El método `exactly` determina si la cadena dada es una coincidencia exacta con otra cadena:

    use Illuminate\Support\Str;

    $result = Str::of('Laravel')->exactly('Laravel');

    // true

<a name="method-fluent-str-explode"></a>
#### `explode` {.collection-method}

El método `explode` divide la cadena por el delimitador dado y devuelve una colección que contiene cada sección de la cadena dividida:

    use Illuminate\Support\Str;

    $collection = Str::of('foo bar baz')->explode(' ');

    // collect(['foo', 'bar', 'baz'])

<a name="method-fluent-str-finish"></a>
#### `finish` {.collection-method}

El método `finish` agrega una única instancia del valor dado a una cadena si no termina ya con ese valor:

    use Illuminate\Support\Str;

    $adjusted = Str::of('this/string')->finish('/');

    // this/string/

    $adjusted = Str::of('this/string/')->finish('/');

    // this/string/

<a name="method-fluent-str-headline"></a>
#### `headline` {.collection-method}

El método `headline` convertirá cadenas delimitadas por mayúsculas, guiones o guiones bajos en una cadena delimitada por espacios con la primera letra de cada palabra en mayúscula:

    use Illuminate\Support\Str;

    $headline = Str::of('taylor_otwell')->headline();

    // Taylor Otwell

    $headline = Str::of('EmailNotificationSent')->headline();

    // Email Notification Sent

<a name="method-fluent-str-inline-markdown"></a>
#### `inlineMarkdown` {.collection-method}

El método `inlineMarkdown` convierte Markdown con sabor a GitHub en HTML en línea usando [CommonMark](https://commonmark.thephpleague.com/). Sin embargo, a diferencia del método `markdown`, no envuelve todo el HTML generado en un elemento de bloque:

    use Illuminate\Support\Str;

    $html = Str::of('**Laravel**')->inlineMarkdown();

    // <strong>Laravel</strong>

#### Seguridad de Markdown

Por defecto, Markdown admite HTML sin procesar, lo que expondrá vulnerabilidades de Cross-Site Scripting (XSS) cuando se use con entrada de usuario sin procesar. Según la [documentación de seguridad de CommonMark](https://commonmark.thephpleague.com/security/), puede usar la opción `html_input` para escapar o eliminar HTML sin procesar, y la opción `allow_unsafe_links` para especificar si se deben permitir enlaces inseguros. Si necesita permitir algo de HTML sin procesar, debe pasar su Markdown compilado a través de un Purificador de HTML:

    use Illuminate\Support\Str;

    Str::of('Inject: <script>alert("Hello XSS!");</script>')->inlineMarkdown([
        'html_input' => 'strip',
        'allow_unsafe_links' => false,
    ]);

    // Inject: alert(&quot;Hello XSS!&quot;);

<a name="method-fluent-str-is"></a>
#### `is` {.collection-method}

El método `is` determina si una cadena dada coincide con un patrón dado. Se pueden usar asteriscos como valores comodín

    use Illuminate\Support\Str;

    $matches = Str::of('foobar')->is('foo*');

    // true

    $matches = Str::of('foobar')->is('baz*');

    // false

<a name="method-fluent-str-is-ascii"></a>
#### `isAscii` {.collection-method}

El método `isAscii` determina si una cadena dada es una cadena ASCII:

    use Illuminate\Support\Str;

    $result = Str::of('Taylor')->isAscii();

    // true

    $result = Str::of('ü')->isAscii();

    // false

<a name="method-fluent-str-is-empty"></a>
#### `isEmpty` {.collection-method}

El método `isEmpty` determina si la cadena dada está vacía:

    use Illuminate\Support\Str;

    $result = Str::of('  ')->trim()->isEmpty();

    // true

    $result = Str::of('Laravel')->trim()->isEmpty();

    // false

<a name="method-fluent-str-is-not-empty"></a>
#### `isNotEmpty` {.collection-method}

El método `isNotEmpty` determina si la cadena dada no está vacía:

    use Illuminate\Support\Str;

    $result = Str::of('  ')->trim()->isNotEmpty();

    // false

    $result = Str::of('Laravel')->trim()->isNotEmpty();

    // true

<a name="method-fluent-str-is-json"></a>
#### `isJson` {.collection-method}

El método `isJson` determina si una cadena dada es un JSON válido:

    use Illuminate\Support\Str;

    $result = Str::of('[1,2,3]')->isJson();

    // true

    $result = Str::of('{"first": "John", "last": "Doe"}')->isJson();

    // true

    $result = Str::of('{first: "John", last: "Doe"}')->isJson();

    // false

<a name="method-fluent-str-is-ulid"></a>
#### `isUlid` {.collection-method}

El método `isUlid` determina si una cadena dada es un ULID:

    use Illuminate\Support\Str;

    $result = Str::of('01gd6r360bp37zj17nxb55yv40')->isUlid();

    // true

    $result = Str::of('Taylor')->isUlid();

    // false

<a name="method-fluent-str-is-url"></a>
#### `isUrl` {.collection-method}

El método `isUrl` determina si una cadena dada es una URL:

    use Illuminate\Support\Str;

    $result = Str::of('http://example.com')->isUrl();

    // true

    $result = Str::of('Taylor')->isUrl();

    // false

El método `isUrl` considera una amplia gama de protocolos como válidos. Sin embargo, puede especificar los protocolos que deben considerarse válidos proporcionándolos al método `isUrl`:

    $result = Str::of('http://example.com')->isUrl(['http', 'https']);

<a name="method-fluent-str-is-uuid"></a>
#### `isUuid` {.collection-method}

El método `isUuid` determina si una cadena dada es un UUID:

    use Illuminate\Support\Str;

    $result = Str::of('5ace9ab9-e9cf-4ec6-a19d-5881212a452c')->isUuid();

    // true

    $result = Str::of('Taylor')->isUuid();

    // false

<a name="method-fluent-str-kebab"></a>
#### `kebab` {.collection-method}

El método `kebab` convierte la cadena dada a `kebab-case`:

    use Illuminate\Support\Str;

    $converted = Str::of('fooBar')->kebab();

    // foo-bar

<a name="method-fluent-str-lcfirst"></a>
#### `lcfirst` {.collection-method}

El método `lcfirst` devuelve la cadena dada con el primer carácter en minúscula:

    use Illuminate\Support\Str;

    $string = Str::of('Foo Bar')->lcfirst();

    // foo Bar


<a name="method-fluent-str-length"></a>
#### `length` {.collection-method}

El método `length` devuelve la longitud de la cadena dada:

    use Illuminate\Support\Str;

    $length = Str::of('Laravel')->length();

    // 7

<a name="method-fluent-str-limit"></a>
#### `limit` {.collection-method}

El método `limit` trunca la cadena dada a la longitud especificada:

    use Illuminate\Support\Str;

    $truncated = Str::of('The quick brown fox jumps over the lazy dog')->limit(20);

    // The quick brown fox...

También puede pasar un segundo argumento para cambiar la cadena que se agregará al final de la cadena truncada:

    $truncated = Str::of('The quick brown fox jumps over the lazy dog')->limit(20, ' (...)');

    // The quick brown fox (...)

Si desea preservar palabras completas al truncar la cadena, puede utilizar el argumento `preserveWords`. Cuando este argumento es `true`, la cadena se truncará al límite de la palabra completa más cercana:

    $truncated = Str::of('The quick brown fox')->limit(12, preserveWords: true);

    // The quick...

<a name="method-fluent-str-lower"></a>
#### `lower` {.collection-method}

El método `lower` convierte la cadena dada a minúsculas:

    use Illuminate\Support\Str;

    $result = Str::of('LARAVEL')->lower();

    // 'laravel'

<a name="method-fluent-str-markdown"></a>
#### `markdown` {.collection-method}

El método `markdown` convierte Markdown con sabor a GitHub en HTML:

    use Illuminate\Support\Str;

    $html = Str::of('# Laravel')->markdown();

    // <h1>Laravel</h1>

    $html = Str::of('# Taylor <b>Otwell</b>')->markdown([
        'html_input' => 'strip',
    ]);

    // <h1>Taylor Otwell</h1>

#### Seguridad de Markdown

Por defecto, Markdown admite HTML sin procesar, lo que expondrá vulnerabilidades de Cross-Site Scripting (XSS) cuando se use con entrada de usuario sin procesar. Según la [documentación de seguridad de CommonMark](https://commonmark.thephpleague.com/security/), puede usar la opción `html_input` para escapar o eliminar HTML sin procesar, y la opción `allow_unsafe_links` para especificar si se deben permitir enlaces inseguros. Si necesita permitir algo de HTML sin procesar, debe pasar su Markdown compilado a través de un Purificador de HTML:

    use Illuminate\Support\Str;

    Str::of('Inject: <script>alert("Hello XSS!");</script>')->markdown([
        'html_input' => 'strip',
        'allow_unsafe_links' => false,
    ]);

    // <p>Inject: alert(&quot;Hello XSS!&quot;);</p>

<a name="method-fluent-str-mask"></a>
#### `mask` {.collection-method}

El método `mask` enmascara una porción de una cadena con un carácter repetido, y puede usarse para ofuscar segmentos de cadenas como direcciones de correo electrónico y números de teléfono:

    use Illuminate\Support\Str;

    $string = Str::of('taylor@example.com')->mask('*', 3);

    // tay***************

Si es necesario, puede proporcionar números negativos como el tercer o cuarto argumento al método `mask`, lo que indicará al método que comience a enmascarar a la distancia dada desde el final de la cadena:

    $string = Str::of('taylor@example.com')->mask('*', -15, 3);

    // tay***@example.com

    $string = Str::of('taylor@example.com')->mask('*', 4, -4);

    // tayl**********.com

<a name="method-fluent-str-match"></a>
#### `match` {.collection-method}

El método `match` devolverá la porción de una cadena que coincide con un patrón de expresión regular dado:

    use Illuminate\Support\Str;

    $result = Str::of('foo bar')->match('/bar/');

    // 'bar'

    $result = Str::of('foo bar')->match('/foo (.*)/');

    // 'bar'

<a name="method-fluent-str-match-all"></a>
#### `matchAll` {.collection-method}

El método `matchAll` devolverá una colección que contiene las porciones de una cadena que coinciden con un patrón de expresión regular dado:

    use Illuminate\Support\Str;

    $result = Str::of('bar foo bar')->matchAll('/bar/');

    // collect(['bar', 'bar'])

Si especificas un grupo de coincidencia dentro de la expresión, Laravel devolverá una colección de las coincidencias del primer grupo de coincidencia:

    use Illuminate\Support\Str;

    $result = Str::of('bar fun bar fly')->matchAll('/f(\w*)/');

    // collect(['un', 'ly']);

Si no se encuentran coincidencias, se devolverá una colección vacía.

<a name="method-fluent-str-is-match"></a>
#### `isMatch` {.collection-method}

El método `isMatch` devolverá `true` si la cadena coincide con una expresión regular dada:

    use Illuminate\Support\Str;

    $result = Str::of('foo bar')->isMatch('/foo (.*)/');

    // true

    $result = Str::of('laravel')->isMatch('/foo (.*)/');

    // false

<a name="method-fluent-str-new-line"></a>
#### `newLine` {.collection-method}

El método `newLine` agrega un carácter de "fin de línea" a una cadena:

    use Illuminate\Support\Str;

    $padded = Str::of('Laravel')->newLine()->append('Framework');

    // 'Laravel
    //  Framework'

<a name="method-fluent-str-padboth"></a>
#### `padBoth` {.collection-method}

El método `padBoth` envuelve la función `str_pad` de PHP, rellenando ambos lados de una cadena con otra cadena hasta que la cadena final alcance la longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::of('James')->padBoth(10, '_');

    // '__James___'

    $padded = Str::of('James')->padBoth(10);

    // '  James   '

<a name="method-fluent-str-padleft"></a>
#### `padLeft` {.collection-method}

El método `padLeft` envuelve la función `str_pad` de PHP, rellenando el lado izquierdo de una cadena con otra cadena hasta que la cadena final alcance la longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::of('James')->padLeft(10, '-=');

    // '-=-=-James'

    $padded = Str::of('James')->padLeft(10);

    // '     James'

<a name="method-fluent-str-padright"></a>
#### `padRight` {.collection-method}

El método `padRight` envuelve la función `str_pad` de PHP, rellenando el lado derecho de una cadena con otra cadena hasta que la cadena final alcance la longitud deseada:

    use Illuminate\Support\Str;

    $padded = Str::of('James')->padRight(10, '-');

    // 'James-----'

    $padded = Str::of('James')->padRight(10);

    // 'James     '

<a name="method-fluent-str-pipe"></a>
#### `pipe` {.collection-method}

El método `pipe` te permite transformar la cadena pasando su valor actual al callable dado:

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $hash = Str::of('Laravel')->pipe('md5')->prepend('Checksum: ');

    // 'Checksum: a5c95b86291ea299fcbe64458ed12702'

    $closure = Str::of('foo')->pipe(function (Stringable $str) {
        return 'bar';
    });

    // 'bar'

<a name="method-fluent-str-plural"></a>
#### `plural` {.collection-method}

El método `plural` convierte una cadena de palabra singular a su forma plural. Esta función admite [cualquiera de los idiomas soportados por el pluralizador de Laravel](/docs/{{version}}/localization#pluralization-language):

    use Illuminate\Support\Str;

    $plural = Str::of('car')->plural();

    // cars

    $plural = Str::of('child')->plural();

    // children

Puedes proporcionar un entero como segundo argumento a la función para recuperar la forma singular o plural de la cadena:

    use Illuminate\Support\Str;

    $plural = Str::of('child')->plural(2);

    // children

    $plural = Str::of('child')->plural(1);

    // child

<a name="method-fluent-str-position"></a>
#### `position` {.collection-method}

El método `position` devuelve la posición de la primera ocurrencia de una subcadena en una cadena. Si la subcadena no existe dentro de la cadena, se devuelve `false`:

    use Illuminate\Support\Str;

    $position = Str::of('Hello, World!')->position('Hello');

    // 0

    $position = Str::of('Hello, World!')->position('W');

    // 7

<a name="method-fluent-str-prepend"></a>
#### `prepend` {.collection-method}

El método `prepend` antepone los valores dados a la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('Framework')->prepend('Laravel ');

    // Laravel Framework

<a name="method-fluent-str-remove"></a>
#### `remove` {.collection-method}

El método `remove` elimina el valor dado o el array de valores de la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('Arkansas is quite beautiful!')->remove('quite');

    // Arkansas is beautiful!

También puedes pasar `false` como segundo parámetro para ignorar mayúsculas y minúsculas al eliminar cadenas.

<a name="method-fluent-str-repeat"></a>
#### `repeat` {.collection-method}

El método `repeat` repite la cadena dada:

```php
use Illuminate\Support\Str;

$repeated = Str::of('a')->repeat(5);

// aaaaa
```

<a name="method-fluent-str-replace"></a>
#### `replace` {.collection-method}

El método `replace` reemplaza una cadena dada dentro de la cadena:

    use Illuminate\Support\Str;

    $replaced = Str::of('Laravel 6.x')->replace('6.x', '7.x');

    // Laravel 7.x

El método `replace` también acepta un argumento `caseSensitive`. Por defecto, el método `replace` es sensible a mayúsculas y minúsculas:

    $replaced = Str::of('macOS 13.x')->replace(
        'macOS', 'iOS', caseSensitive: false
    );

<a name="method-fluent-str-replace-array"></a>
#### `replaceArray` {.collection-method}

El método `replaceArray` reemplaza un valor dado en la cadena secuencialmente utilizando un array:

    use Illuminate\Support\Str;

    $string = 'The event will take place between ? and ?';

    $replaced = Str::of($string)->replaceArray('?', ['8:30', '9:00']);

    // The event will take place between 8:30 and 9:00

<a name="method-fluent-str-replace-first"></a>
#### `replaceFirst` {.collection-method}

El método `replaceFirst` reemplaza la primera ocurrencia de un valor dado en una cadena:

    use Illuminate\Support\Str;

    $replaced = Str::of('the quick brown fox jumps over the lazy dog')->replaceFirst('the', 'a');

    // a quick brown fox jumps over the lazy dog

<a name="method-fluent-str-replace-last"></a>
#### `replaceLast` {.collection-method}

El método `replaceLast` reemplaza la última ocurrencia de un valor dado en una cadena:

    use Illuminate\Support\Str;

    $replaced = Str::of('the quick brown fox jumps over the lazy dog')->replaceLast('the', 'a');

    // the quick brown fox jumps over a lazy dog

<a name="method-fluent-str-replace-matches"></a>
#### `replaceMatches` {.collection-method}

El método `replaceMatches` reemplaza todas las porciones de una cadena que coinciden con un patrón con la cadena de reemplazo dada:

    use Illuminate\Support\Str;

    $replaced = Str::of('(+1) 501-555-1000')->replaceMatches('/[^A-Za-z0-9]++/', '')

    // '15015551000'

El método `replaceMatches` también acepta una función anónima que será invocada con cada porción de la cadena que coincida con el patrón dado, permitiéndote realizar la lógica de reemplazo dentro de la función anónima y devolver el valor reemplazado:

    use Illuminate\Support\Str;

    $replaced = Str::of('123')->replaceMatches('/\d/', function (array $matches) {
        return '['.$matches[0].']';
    });

    // '[1][2][3]'

<a name="method-fluent-str-replace-start"></a>
#### `replaceStart` {.collection-method}

El método `replaceStart` reemplaza la primera ocurrencia del valor dado solo si el valor aparece al inicio de la cadena:

    use Illuminate\Support\Str;

    $replaced = Str::of('Hello World')->replaceStart('Hello', 'Laravel');

    // Laravel World

    $replaced = Str::of('Hello World')->replaceStart('World', 'Laravel');

    // Hello World

<a name="method-fluent-str-replace-end"></a>
#### `replaceEnd` {.collection-method}

El método `replaceEnd` reemplaza la última ocurrencia del valor dado solo si el valor aparece al final de la cadena:

    use Illuminate\Support\Str;

    $replaced = Str::of('Hello World')->replaceEnd('World', 'Laravel');

    // Hello Laravel

    $replaced = Str::of('Hello World')->replaceEnd('Hello', 'Laravel');

    // Hello World

<a name="method-fluent-str-scan"></a>
#### `scan` {.collection-method}

El método `scan` analiza la entrada de una cadena en una colección de acuerdo con un formato soportado por la función [`sscanf` de PHP](https://www.php.net/manual/en/function.sscanf.php):

    use Illuminate\Support\Str;

    $collection = Str::of('filename.jpg')->scan('%[^.].%s');

    // collect(['filename', 'jpg'])

<a name="method-fluent-str-singular"></a>
#### `singular` {.collection-method}

El método `singular` convierte una cadena a su forma singular. Esta función admite [cualquiera de los idiomas soportados por el pluralizador de Laravel](/docs/{{version}}/localization#pluralization-language):

    use Illuminate\Support\Str;

    $singular = Str::of('cars')->singular();

    // car

    $singular = Str::of('children')->singular();

    // child

<a name="method-fluent-str-slug"></a>
#### `slug` {.collection-method}

El método `slug` genera un "slug" amigable con URL a partir de la cadena dada:

    use Illuminate\Support\Str;

    $slug = Str::of('Laravel Framework')->slug('-');

    // laravel-framework

<a name="method-fluent-str-snake"></a>
#### `snake` {.collection-method}

El método `snake` convierte la cadena dada a `snake_case`:

    use Illuminate\Support\Str;

    $converted = Str::of('fooBar')->snake();

    // foo_bar

<a name="method-fluent-str-split"></a>
#### `split` {.collection-method}

El método `split` divide una cadena en una colección utilizando una expresión regular:

    use Illuminate\Support\Str;

    $segments = Str::of('one, two, three')->split('/[\s,]+/');

    // collect(["one", "two", "three"])

<a name="method-fluent-str-squish"></a>
#### `squish` {.collection-method}

El método `squish` elimina todos los espacios en blanco superfluos de una cadena, incluidos los espacios en blanco superfluos entre palabras:

    use Illuminate\Support\Str;

    $string = Str::of('    laravel    framework    ')->squish();

    // laravel framework

<a name="method-fluent-str-start"></a>
#### `start` {.collection-method}

El método `start` agrega una única instancia del valor dado a una cadena si no comienza ya con ese valor:

    use Illuminate\Support\Str;

    $adjusted = Str::of('this/string')->start('/');

    // /this/string

    $adjusted = Str::of('/this/string')->start('/');

    // /this/string

<a name="method-fluent-str-starts-with"></a>
#### `startsWith` {.collection-method}

El método `startsWith` determina si la cadena dada comienza con el valor dado:

    use Illuminate\Support\Str;

    $result = Str::of('This is my name')->startsWith('This');

    // true

<a name="method-fluent-str-strip-tags"></a>
#### `stripTags` {.collection-method}

El método `stripTags` elimina todas las etiquetas HTML y PHP de una cadena:

    use Illuminate\Support\Str;

    $result = Str::of('<a href="https://laravel.com">Taylor <b>Otwell</b></a>')->stripTags();

    // Taylor Otwell

    $result = Str::of('<a href="https://laravel.com">Taylor <b>Otwell</b></a>')->stripTags('<b>');

    // Taylor <b>Otwell</b>

<a name="method-fluent-str-studly"></a>
#### `studly` {.collection-method}

El método `studly` convierte la cadena dada a `StudlyCase`:

    use Illuminate\Support\Str;

    $converted = Str::of('foo_bar')->studly();

    // FooBar

<a name="method-fluent-str-substr"></a>
#### `substr` {.collection-method}

El método `substr` devuelve la porción de la cadena especificada por los parámetros de inicio y longitud dados:

    use Illuminate\Support\Str;

    $string = Str::of('Laravel Framework')->substr(8);

    // Framework

    $string = Str::of('Laravel Framework')->substr(8, 5);

    // Frame

<a name="method-fluent-str-substrreplace"></a>
#### `substrReplace` {.collection-method}

El método `substrReplace` reemplaza texto dentro de una porción de una cadena, comenzando en la posición especificada por el segundo argumento y reemplazando el número de caracteres especificado por el tercer argumento. Pasar `0` al tercer argumento del método insertará la cadena en la posición especificada sin reemplazar ninguno de los caracteres existentes en la cadena:

    use Illuminate\Support\Str;

    $string = Str::of('1300')->substrReplace(':', 2);

    // 13:

    $string = Str::of('The Framework')->substrReplace(' Laravel', 3, 0);

    // The Laravel Framework

<a name="method-fluent-str-swap"></a>
#### `swap` {.collection-method}

El método `swap` reemplaza múltiples valores en la cadena utilizando la función `strtr` de PHP:

    use Illuminate\Support\Str;

    $string = Str::of('Tacos are great!')
        ->swap([
            'Tacos' => 'Burritos',
            'great' => 'fantastic',
        ]);

    // Burritos are fantastic!

<a name="method-fluent-str-take"></a>
#### `take` {.collection-method}

El método `take` devuelve un número especificado de caracteres desde el principio de la cadena:

    use Illuminate\Support\Str;

    $taken = Str::of('Build something amazing!')->take(5);

    // Build

<a name="method-fluent-str-tap"></a>
#### `tap` {.collection-method}

El método `tap` pasa la cadena a la función anónima dada, permitiéndote examinar e interactuar con la cadena sin afectar la cadena misma. La cadena original es devuelta por el método `tap` independientemente de lo que devuelva la función anónima:

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('Laravel')
        ->append(' Framework')
        ->tap(function (Stringable $string) {
            dump('String after append: '.$string);
        })
        ->upper();

    // LARAVEL FRAMEWORK

<a name="method-fluent-str-test"></a>
#### `test` {.collection-method}

El método `test` determina si una cadena coincide con el patrón de expresión regular dado:

    use Illuminate\Support\Str;

    $result = Str::of('Laravel Framework')->test('/Laravel/');

    // true

<a name="method-fluent-str-title"></a>
#### `title` {.collection-method}

El método `title` convierte la cadena dada a `Title Case`:

    use Illuminate\Support\Str;

    $converted = Str::of('a nice title uses the correct case')->title();

    // A Nice Title Uses The Correct Case

<a name="method-fluent-str-to-base64"></a>
#### `toBase64()` {.collection-method}

El método `toBase64` convierte la cadena dada a Base64:

    use Illuminate\Support\Str;

    $base64 = Str::of('Laravel')->toBase64();

    // TGFyYXZlbA==

<a name="method-fluent-str-trim"></a>
#### `trim` {.collection-method}

El método `trim` recorta la cadena dada. A diferencia de la función `trim` nativa de PHP, el método `trim` de Laravel también elimina caracteres de espacio en blanco unicode:

    use Illuminate\Support\Str;

    $string = Str::of('  Laravel  ')->trim();

    // 'Laravel'

    $string = Str::of('/Laravel/')->trim('/');

    // 'Laravel'

<a name="method-fluent-str-ltrim"></a>
#### `ltrim` {.collection-method}

El método `ltrim` recorta el lado izquierdo de la cadena. A diferencia de la función `ltrim` nativa de PHP, el método `ltrim` de Laravel también elimina caracteres de espacio en blanco unicode:

    use Illuminate\Support\Str;

```php
$string = Str::of('  Laravel  ')->ltrim();

// 'Laravel  '

$string = Str::of('/Laravel/')->ltrim('/');

// 'Laravel/'

<a name="method-fluent-str-rtrim"></a>
#### `rtrim` {.collection-method}

El método `rtrim` recorta el lado derecho de la cadena dada. A diferencia de la función nativa `rtrim` de PHP, el método `rtrim` de Laravel también elimina los caracteres de espacio en blanco unicode:

```php
use Illuminate\Support\Str;

$string = Str::of('  Laravel  ')->rtrim();

// '  Laravel'

$string = Str::of('/Laravel/')->rtrim('/');

// '/Laravel'
```

<a name="method-fluent-str-ucfirst"></a>
#### `ucfirst` {.collection-method}

El método `ucfirst` devuelve la cadena dada con el primer carácter en mayúscula:

```php
use Illuminate\Support\Str;

$string = Str::of('foo bar')->ucfirst();

// Foo bar
```

<a name="method-fluent-str-ucsplit"></a>
#### `ucsplit` {.collection-method}

El método `ucsplit` divide la cadena dada en una colección por caracteres en mayúscula:

```php
use Illuminate\Support\Str;

$string = Str::of('Foo Bar')->ucsplit();

// collect(['Foo', 'Bar'])
```

<a name="method-fluent-str-unwrap"></a>
#### `unwrap` {.collection-method}

El método `unwrap` elimina las cadenas especificadas del principio y del final de una cadena dada:

```php
use Illuminate\Support\Str;

Str::of('-Laravel-')->unwrap('-');

// Laravel

Str::of('{framework: "Laravel"}')->unwrap('{', '}');

// framework: "Laravel"
```

<a name="method-fluent-str-upper"></a>
#### `upper` {.collection-method}

El método `upper` convierte la cadena dada a mayúsculas:

```php
use Illuminate\Support\Str;

$adjusted = Str::of('laravel')->upper();

// LARAVEL
```

<a name="method-fluent-str-when"></a>
#### `when` {.collection-method}

El método `when` invoca la función anónima dada si una condición dada es `true`. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('Taylor')
                ->when(true, function (Stringable $string) {
                    return $string->append(' Otwell');
                });

// 'Taylor Otwell'
```

Si es necesario, puedes pasar otra función anónima como el tercer parámetro al método `when`. Esta función anónima se ejecutará si el parámetro de condición evalúa a `false`.

<a name="method-fluent-str-when-contains"></a>
#### `whenContains` {.collection-method}

El método `whenContains` invoca la función anónima dada si la cadena contiene el valor dado. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('tony stark')
            ->whenContains('tony', function (Stringable $string) {
                return $string->title();
            });

// 'Tony Stark'
```

Si es necesario, puedes pasar otra función anónima como el tercer parámetro al método `when`. Esta función anónima se ejecutará si la cadena no contiene el valor dado.

También puedes pasar un array de valores para determinar si la cadena dada contiene alguno de los valores en el array:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('tony stark')
            ->whenContains(['tony', 'hulk'], function (Stringable $string) {
                return $string->title();
            });

// Tony Stark
```

<a name="method-fluent-str-when-contains-all"></a>
#### `whenContainsAll` {.collection-method}

El método `whenContainsAll` invoca la función anónima dada si la cadena contiene todas las subcadenas dadas. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('tony stark')
                ->whenContainsAll(['tony', 'stark'], function (Stringable $string) {
                    return $string->title();
                });

// 'Tony Stark'
```

Si es necesario, puedes pasar otra función anónima como el tercer parámetro al método `when`. Esta función anónima se ejecutará si el parámetro de condición evalúa a `false`.

<a name="method-fluent-str-when-empty"></a>
#### `whenEmpty` {.collection-method}

El método `whenEmpty` invoca la función anónima dada si la cadena está vacía. Si la función anónima devuelve un valor, ese valor también será devuelto por el método `whenEmpty`. Si la función anónima no devuelve un valor, se devolverá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('  ')->whenEmpty(function (Stringable $string) {
    return $string->trim()->prepend('Laravel');
});

// 'Laravel'
```

<a name="method-fluent-str-when-not-empty"></a>
#### `whenNotEmpty` {.collection-method}

El método `whenNotEmpty` invoca la función anónima dada si la cadena no está vacía. Si la función anónima devuelve un valor, ese valor también será devuelto por el método `whenNotEmpty`. Si la función anónima no devuelve un valor, se devolverá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('Framework')->whenNotEmpty(function (Stringable $string) {
    return $string->prepend('Laravel ');
});

// 'Laravel Framework'
```

<a name="method-fluent-str-when-starts-with"></a>
#### `whenStartsWith` {.collection-method}

El método `whenStartsWith` invoca la función anónima dada si la cadena comienza con la subcadena dada. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('disney world')->whenStartsWith('disney', function (Stringable $string) {
    return $string->title();
});

// 'Disney World'
```

<a name="method-fluent-str-when-ends-with"></a>
#### `whenEndsWith` {.collection-method}

El método `whenEndsWith` invoca la función anónima dada si la cadena termina con la subcadena dada. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('disney world')->whenEndsWith('world', function (Stringable $string) {
    return $string->title();
});

// 'Disney World'
```

<a name="method-fluent-str-when-exactly"></a>
#### `whenExactly` {.collection-method}

El método `whenExactly` invoca la función anónima dada si la cadena coincide exactamente con la cadena dada. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('laravel')->whenExactly('laravel', function (Stringable $string) {
    return $string->title();
});

// 'Laravel'
```

<a name="method-fluent-str-when-not-exactly"></a>
#### `whenNotExactly` {.collection-method}

El método `whenNotExactly` invoca la función anónima dada si la cadena no coincide exactamente con la cadena dada. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('framework')->whenNotExactly('laravel', function (Stringable $string) {
    return $string->title();
});

// 'Framework'
```

<a name="method-fluent-str-when-is"></a>
#### `whenIs` {.collection-method}

El método `whenIs` invoca la función anónima dada si la cadena coincide con un patrón dado. Se pueden usar asteriscos como valores comodín. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('foo/bar')->whenIs('foo/*', function (Stringable $string) {
    return $string->append('/baz');
});

// 'foo/bar/baz'
```

<a name="method-fluent-str-when-is-ascii"></a>
#### `whenIsAscii` {.collection-method}

El método `whenIsAscii` invoca la función anónima dada si la cadena es ASCII de 7 bits. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('laravel')->whenIsAscii(function (Stringable $string) {
    return $string->title();
});

// 'Laravel'
```

<a name="method-fluent-str-when-is-ulid"></a>
#### `whenIsUlid` {.collection-method}

El método `whenIsUlid` invoca la función anónima dada si la cadena es un ULID válido. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;

$string = Str::of('01gd6r360bp37zj17nxb55yv40')->whenIsUlid(function (Stringable $string) {
    return $string->substr(0, 8);
});

// '01gd6r36'
```

<a name="method-fluent-str-when-is-uuid"></a>
#### `whenIsUuid` {.collection-method}

El método `whenIsUuid` invoca la función anónima dada si la cadena es un UUID válido. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('a0a2a2d2-0b87-4a18-83f2-2529882be2de')->whenIsUuid(function (Stringable $string) {
    return $string->substr(0, 8);
});

// 'a0a2a2d2'
```

<a name="method-fluent-str-when-test"></a>
#### `whenTest` {.collection-method}

El método `whenTest` invoca la función anónima dada si la cadena coincide con la expresión regular dada. La función anónima recibirá la instancia de la cadena fluida:

```php
use Illuminate\Support\Str;
use Illuminate\Support\Stringable;

$string = Str::of('laravel framework')->whenTest('/laravel/', function (Stringable $string) {
    return $string->title();
});

// 'Laravel Framework'
```

<a name="method-fluent-str-word-count"></a>
#### `wordCount` {.collection-method}

El método `wordCount` devuelve el número de palabras que contiene una cadena:

```php
use Illuminate\Support\Str;

Str::of('Hello, world!')->wordCount(); // 2
```

<a name="method-fluent-str-words"></a>
#### `words` {.collection-method}

El método `words` limita el número de palabras en una cadena. Si es necesario, puedes especificar una cadena adicional que se añadirá a la cadena truncada:

```php
use Illuminate\Support\Str;

$string = Str::of('Perfectly balanced, as all things should be.')->words(3, ' >>>');

// Perfectly balanced, as >>>
```
