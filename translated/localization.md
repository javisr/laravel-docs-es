# Localización

- [Introducción](#introduction)
    - [Publicación de los Archivos de Idioma](#publishing-the-language-files)
    - [Configurando la Configuración Regional](#configuring-the-locale)
    - [Lenguaje de Pluralización](#pluralization-language)
- [Definiendo Cadenas de Traducción](#defining-translation-strings)
    - [Usando Claves Cortas](#using-short-keys)
    - [Usando Cadenas de Traducción como Claves](#using-translation-strings-as-keys)
- [Recuperando Cadenas de Traducción](#retrieving-translation-strings)
    - [Reemplazando Parámetros en Cadenas de Traducción](#replacing-parameters-in-translation-strings)
    - [Pluralización](#pluralization)
- [Sobrescribiendo Archivos de Idioma de Paquetes](#overriding-package-language-files)

<a name="introduction"></a>
## Introducción

> [!NOTE]  
> Por defecto, el esqueleto de la aplicación Laravel no incluye el directorio `lang`. Si deseas personalizar los archivos de idioma de Laravel, puedes publicarlos a través del comando Artisan `lang:publish`.

Las características de localización de Laravel proporcionan una forma conveniente de recuperar cadenas en varios idiomas, lo que te permite soportar fácilmente múltiples idiomas dentro de tu aplicación.

Laravel proporciona dos formas de gestionar cadenas de traducción. Primero, las cadenas de idioma pueden almacenarse en archivos dentro del directorio `lang` de la aplicación. Dentro de este directorio, puede haber subdirectorios para cada idioma soportado por la aplicación. Este es el enfoque que Laravel utiliza para gestionar cadenas de traducción para características integradas de Laravel, como los mensajes de error de validación:

    /lang
        /en
            messages.php
        /es
            messages.php

O, las cadenas de traducción pueden definirse dentro de archivos JSON que se colocan dentro del directorio `lang`. Al tomar este enfoque, cada idioma soportado por tu aplicación tendría un archivo JSON correspondiente dentro de este directorio. Este enfoque se recomienda para aplicaciones que tienen un gran número de cadenas traducibles:

    /lang
        en.json
        es.json

Discutiremos cada enfoque para gestionar cadenas de traducción dentro de esta documentación.

<a name="publishing-the-language-files"></a>
### Publicación de los Archivos de Idioma

Por defecto, el esqueleto de la aplicación Laravel no incluye el directorio `lang`. Si deseas personalizar los archivos de idioma de Laravel o crear los tuyos propios, debes crear el directorio `lang` a través del comando Artisan `lang:publish`. El comando `lang:publish` creará el directorio `lang` en tu aplicación y publicará el conjunto predeterminado de archivos de idioma utilizados por Laravel:

```shell
php artisan lang:publish
```

<a name="configuring-the-locale"></a>
### Configurando la Configuración Regional

El idioma predeterminado para tu aplicación se almacena en la opción de configuración `locale` del archivo de configuración `config/app.php`, que generalmente se establece utilizando la variable de entorno `APP_LOCALE`. Eres libre de modificar este valor para adaptarlo a las necesidades de tu aplicación.

También puedes configurar un "idioma de respaldo", que se utilizará cuando el idioma predeterminado no contenga una cadena de traducción dada. Al igual que el idioma predeterminado, el idioma de respaldo también se configura en el archivo de configuración `config/app.php`, y su valor generalmente se establece utilizando la variable de entorno `APP_FALLBACK_LOCALE`.

Puedes modificar el idioma predeterminado para una sola solicitud HTTP en tiempo de ejecución utilizando el método `setLocale` proporcionado por el facade `App`:

    use Illuminate\Support\Facades\App;

    Route::get('/greeting/{locale}', function (string $locale) {
        if (! in_array($locale, ['en', 'es', 'fr'])) {
            abort(400);
        }

        App::setLocale($locale);

        // ...
    });

<a name="determining-the-current-locale"></a>
#### Determinando la Configuración Regional Actual

Puedes usar los métodos `currentLocale` e `isLocale` en el facade `App` para determinar la configuración regional actual o verificar si la configuración regional es un valor dado:

    use Illuminate\Support\Facades\App;

    $locale = App::currentLocale();

    if (App::isLocale('en')) {
        // ...
    }

<a name="pluralization-language"></a>
### Lenguaje de Pluralización

Puedes instruir al "pluralizador" de Laravel, que es utilizado por Eloquent y otras partes del framework para convertir cadenas singulares en cadenas plurales, para que use un idioma diferente al inglés. Esto se puede lograr invocando el método `useLanguage` dentro del método `boot` de uno de los proveedores de servicios de tu aplicación. Los idiomas actualmente soportados por el pluralizador son: `french`, `norwegian-bokmal`, `portuguese`, `spanish`, y `turkish`:

    use Illuminate\Support\Pluralizer;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Pluralizer::useLanguage('spanish');

        // ...
    }

> [!WARNING]  
> Si personalizas el idioma del pluralizador, debes definir explícitamente los [nombres de tabla](/docs/{{version}}/eloquent#table-names) de tu modelo Eloquent.

<a name="defining-translation-strings"></a>
## Definiendo Cadenas de Traducción

<a name="using-short-keys"></a>
### Usando Claves Cortas

Típicamente, las cadenas de traducción se almacenan en archivos dentro del directorio `lang`. Dentro de este directorio, debería haber un subdirectorio para cada idioma soportado por tu aplicación. Este es el enfoque que Laravel utiliza para gestionar cadenas de traducción para características integradas de Laravel, como los mensajes de error de validación:

    /lang
        /en
            messages.php
        /es
            messages.php

Todos los archivos de idioma devuelven un array de cadenas con claves. Por ejemplo:

    <?php

    // lang/en/messages.php

    return [
        'welcome' => 'Welcome to our application!',
    ];

> [!WARNING]  
> Para idiomas que difieren por territorio, debes nombrar los directorios de idioma de acuerdo con el ISO 15897. Por ejemplo, "en_GB" debe usarse para el inglés británico en lugar de "en-gb".

<a name="using-translation-strings-as-keys"></a>
### Usando Cadenas de Traducción como Claves

Para aplicaciones con un gran número de cadenas traducibles, definir cada cadena con una "clave corta" puede volverse confuso al referenciar las claves en tus vistas y es engorroso inventar continuamente claves para cada cadena de traducción soportada por tu aplicación.

Por esta razón, Laravel también proporciona soporte para definir cadenas de traducción utilizando la "traducción predeterminada" de la cadena como clave. Los archivos de idioma que utilizan cadenas de traducción como claves se almacenan como archivos JSON en el directorio `lang`. Por ejemplo, si tu aplicación tiene una traducción al español, deberías crear un archivo `lang/es.json`:

```json
{
    "I love programming.": "Me encanta programar."
}
```

#### Conflictos de Clave / Archivo

No debes definir claves de cadenas de traducción que entren en conflicto con otros nombres de archivos de traducción. Por ejemplo, traducir `__('Action')` para la configuración regional "NL" mientras existe un archivo `nl/action.php` pero no existe un archivo `nl.json` resultará en que el traductor devuelva todo el contenido de `nl/action.php`.

<a name="retrieving-translation-strings"></a>
## Recuperando Cadenas de Traducción

Puedes recuperar cadenas de traducción de tus archivos de idioma utilizando la función auxiliar `__`. Si estás utilizando "claves cortas" para definir tus cadenas de traducción, debes pasar el archivo que contiene la clave y la clave misma a la función `__` utilizando la sintaxis "punto". Por ejemplo, recuperemos la cadena de traducción `welcome` del archivo de idioma `lang/en/messages.php`:

    echo __('messages.welcome');

Si la cadena de traducción especificada no existe, la función `__` devolverá la clave de la cadena de traducción. Así que, usando el ejemplo anterior, la función `__` devolvería `messages.welcome` si la cadena de traducción no existe.

Si estás utilizando tus [cadenas de traducción predeterminadas como tus claves de traducción](#using-translation-strings-as-keys), debes pasar la traducción predeterminada de tu cadena a la función `__`:

    echo __('I love programming.');

Nuevamente, si la cadena de traducción no existe, la función `__` devolverá la clave de la cadena de traducción que se le dio.

Si estás utilizando el [motor de plantillas Blade](/docs/{{version}}/blade), puedes usar la sintaxis de eco `{{ }}` para mostrar la cadena de traducción:

    {{ __('messages.welcome') }}

<a name="replacing-parameters-in-translation-strings"></a>
### Reemplazando Parámetros en Cadenas de Traducción

Si lo deseas, puedes definir marcadores de posición en tus cadenas de traducción. Todos los marcadores de posición están precedidos por un `:`. Por ejemplo, puedes definir un mensaje de bienvenida con un marcador de posición de nombre:

    'welcome' => 'Welcome, :name',

Para reemplazar los marcadores de posición al recuperar una cadena de traducción, puedes pasar un array de reemplazos como el segundo argumento a la función `__`:

    echo __('messages.welcome', ['name' => 'dayle']);

Si tu marcador de posición contiene todas las letras en mayúsculas, o solo tiene su primera letra en mayúscula, el valor traducido se capitalizará en consecuencia:

    'welcome' => 'Welcome, :NAME', // Welcome, DAYLE
    'goodbye' => 'Goodbye, :Name', // Goodbye, Dayle

<a name="object-replacement-formatting"></a>
#### Formateo de Reemplazo de Objetos

Si intentas proporcionar un objeto como un marcador de posición de traducción, se invocará el método `__toString` del objeto. El método [`__toString`](https://www.php.net/manual/en/language.oop5.magic.php#object.tostring) es uno de los "métodos mágicos" integrados de PHP. Sin embargo, a veces puede que no tengas control sobre el método `__toString` de una clase dada, como cuando la clase con la que estás interactuando pertenece a una biblioteca de terceros.

En estos casos, Laravel te permite registrar un controlador de formateo personalizado para ese tipo particular de objeto. Para lograr esto, debes invocar el método `stringable` del traductor. El método `stringable` acepta una función anónima, que debe indicar el tipo de objeto que es responsable de formatear. Típicamente, el método `stringable` debe invocarse dentro del método `boot` de la clase `AppServiceProvider` de tu aplicación:

    use Illuminate\Support\Facades\Lang;
    use Money\Money;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Lang::stringable(function (Money $money) {
            return $money->formatTo('en_GB');
        });
    }

<a name="pluralization"></a>
### Pluralización

La pluralización es un problema complejo, ya que diferentes idiomas tienen una variedad de reglas complejas para la pluralización; sin embargo, Laravel puede ayudarte a traducir cadenas de manera diferente según las reglas de pluralización que definas. Usando un carácter `|`, puedes distinguir entre formas singulares y plurales de una cadena:

    'apples' => 'There is one apple|There are many apples',

Por supuesto, la pluralización también es compatible al usar [cadenas de traducción como claves](#using-translation-strings-as-keys):

```json
{
    "There is one apple|There are many apples": "Hay una manzana|Hay muchas manzanas"
}
```

Incluso puedes crear reglas de pluralización más complejas que especifiquen cadenas de traducción para múltiples rangos de valores:

    'apples' => '{0} There are none|[1,19] There are some|[20,*] There are many',

Después de definir una cadena de traducción que tiene opciones de pluralización, puedes usar la función `trans_choice` para recuperar la línea para un "conteo" dado. En este ejemplo, dado que el conteo es mayor que uno, se devuelve la forma plural de la cadena de traducción:

    echo trans_choice('messages.apples', 10);

También puedes definir atributos de marcador de posición en cadenas de pluralización. Estos marcadores de posición pueden ser reemplazados pasando un array como el tercer argumento a la función `trans_choice`:

    'minutes_ago' => '{1} :value minute ago|[2,*] :value minutes ago',

    echo trans_choice('time.minutes_ago', 5, ['value' => 5]);

Si deseas mostrar el valor entero que se pasó a la función `trans_choice`, puedes usar el marcador de posición incorporado `:count`:

    'apples' => '{0} There are none|{1} There is one|[2,*] There are :count',

<a name="overriding-package-language-files"></a>
## Sobrescribiendo Archivos de Idioma de Paquetes

Algunos paquetes pueden incluir sus propios archivos de idioma. En lugar de cambiar los archivos centrales del paquete para ajustar estas líneas, puedes sobrescribirlos colocando archivos en el directorio `lang/vendor/{package}/{locale}`.

Así que, por ejemplo, si necesitas sobrescribir las cadenas de traducción en inglés en `messages.php` para un paquete llamado `skyrim/hearthfire`, deberías colocar un archivo de idioma en: `lang/vendor/hearthfire/en/messages.php`. Dentro de este archivo, solo debes definir las cadenas de traducción que deseas sobrescribir. Cualquier cadena de traducción que no sobrescribas seguirá siendo cargada desde los archivos de idioma originales del paquete.
