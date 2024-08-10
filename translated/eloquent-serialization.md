# Eloquent: Serialización

- [Introducción](#introduction)
- [Serializando Modelos y Colecciones](#serializing-models-and-collections)
    - [Serializando a Arrays](#serializing-to-arrays)
    - [Serializando a JSON](#serializing-to-json)
- [Ocultando Atributos de JSON](#hiding-attributes-from-json)
- [Agregando Valores a JSON](#appending-values-to-json)
- [Serialización de Fechas](#date-serialization)

<a name="introduction"></a>
## Introducción

Cuando construyes APIs usando Laravel, a menudo necesitarás convertir tus modelos y relaciones a arrays o JSON. Eloquent incluye métodos convenientes para realizar estas conversiones, así como para controlar qué atributos se incluyen en la representación serializada de tus modelos.

> [!NOTE]  
> Para una forma aún más robusta de manejar la serialización JSON de modelos y colecciones de Eloquent, consulta la documentación sobre [recursos API de Eloquent](/docs/{{version}}/eloquent-resources).

<a name="serializing-models-and-collections"></a>
## Serializando Modelos y Colecciones

<a name="serializing-to-arrays"></a>
### Serializando a Arrays

Para convertir un modelo y sus [relaciones](/docs/{{version}}/eloquent-relationships) cargadas a un array, debes usar el método `toArray`. Este método es recursivo, por lo que todos los atributos y todas las relaciones (incluidas las relaciones de relaciones) se convertirán a arrays:

    use App\Models\User;

    $user = User::with('roles')->first();

    return $user->toArray();

El método `attributesToArray` puede ser utilizado para convertir los atributos de un modelo a un array, pero no sus relaciones:

    $user = User::first();

    return $user->attributesToArray();

También puedes convertir colecciones enteras de [modelos](/docs/{{version}}/eloquent-collections) a arrays llamando al método `toArray` en la instancia de la colección:

    $users = User::all();

    return $users->toArray();

<a name="serializing-to-json"></a>
### Serializando a JSON

Para convertir un modelo a JSON, debes usar el método `toJson`. Al igual que `toArray`, el método `toJson` es recursivo, por lo que todos los atributos y relaciones se convertirán a JSON. También puedes especificar cualquier opción de codificación JSON que sea [compatible con PHP](https://secure.php.net/manual/en/function.json-encode.php):

    use App\Models\User;

    $user = User::find(1);

    return $user->toJson();

    return $user->toJson(JSON_PRETTY_PRINT);

Alternativamente, puedes convertir un modelo o colección a una cadena, lo que llamará automáticamente al método `toJson` en el modelo o colección:

    return (string) User::find(1);

Dado que los modelos y colecciones se convierten a JSON cuando se convierten a una cadena, puedes devolver objetos Eloquent directamente desde las rutas o controladores de tu aplicación. Laravel serializará automáticamente tus modelos y colecciones Eloquent a JSON cuando se devuelvan desde rutas o controladores:

    Route::get('/users', function () {
        return User::all();
    });

<a name="relationships"></a>
#### Relaciones

Cuando un modelo Eloquent se convierte a JSON, sus relaciones cargadas se incluirán automáticamente como atributos en el objeto JSON. Además, aunque los métodos de relación de Eloquent se definen utilizando nombres de métodos en "camel case", el atributo JSON de una relación será "snake case".

<a name="hiding-attributes-from-json"></a>
## Ocultando Atributos de JSON

A veces puedes desear limitar los atributos, como contraseñas, que se incluyen en la representación de array o JSON de tu modelo. Para hacerlo, agrega una propiedad `$hidden` a tu modelo. Los atributos que se enumeran en el array de la propiedad `$hidden` no se incluirán en la representación serializada de tu modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Los atributos que deben estar ocultos para los arrays.
         *
         * @var array
         */
        protected $hidden = ['password'];
    }

> [!NOTE]  
> Para ocultar relaciones, agrega el nombre del método de la relación a la propiedad `$hidden` de tu modelo Eloquent.

Alternativamente, puedes usar la propiedad `visible` para definir una "lista de permitidos" de atributos que deben incluirse en la representación de array y JSON de tu modelo. Todos los atributos que no estén presentes en el array `$visible` estarán ocultos cuando el modelo se convierta a un array o JSON:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Los atributos que deben ser visibles en los arrays.
         *
         * @var array
         */
        protected $visible = ['first_name', 'last_name'];
    }

<a name="temporarily-modifying-attribute-visibility"></a>
#### Modificando Temporalmente la Visibilidad de Atributos

Si deseas hacer visibles algunos atributos que normalmente están ocultos en una instancia de modelo dada, puedes usar el método `makeVisible`. El método `makeVisible` devuelve la instancia del modelo:

    return $user->makeVisible('attribute')->toArray();

Del mismo modo, si deseas ocultar algunos atributos que normalmente son visibles, puedes usar el método `makeHidden`.

    return $user->makeHidden('attribute')->toArray();

Si deseas anular temporalmente todos los atributos visibles u ocultos, puedes usar los métodos `setVisible` y `setHidden` respectivamente:

    return $user->setVisible(['id', 'name'])->toArray();

    return $user->setHidden(['email', 'password', 'remember_token'])->toArray();

<a name="appending-values-to-json"></a>
## Agregando Valores a JSON

Ocasionalmente, al convertir modelos a arrays o JSON, puedes desear agregar atributos que no tienen una columna correspondiente en tu base de datos. Para hacerlo, primero define un [accesor](/docs/{{version}}/eloquent-mutators) para el valor:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Casts\Attribute;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Determina si el usuario es un administrador.
         */
        protected function isAdmin(): Attribute
        {
            return new Attribute(
                get: fn () => 'yes',
            );
        }
    }

Si deseas que el accesor siempre se agregue a las representaciones de array y JSON de tu modelo, puedes agregar el nombre del atributo a la propiedad `appends` de tu modelo. Ten en cuenta que los nombres de los atributos generalmente se hacen referencia utilizando su representación serializada en "snake case", aunque el método PHP del accesor se define utilizando "camel case":

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Los accesores que se agregarán a la forma de array del modelo.
         *
         * @var array
         */
        protected $appends = ['is_admin'];
    }

Una vez que el atributo se ha agregado a la lista `appends`, se incluirá en las representaciones de array y JSON del modelo. Los atributos en el array `appends` también respetarán la configuración de `visible` y `hidden` configurada en el modelo.

<a name="appending-at-run-time"></a>
#### Agregando en Tiempo de Ejecución

En tiempo de ejecución, puedes instruir a una instancia de modelo para que agregue atributos adicionales utilizando el método `append`. O, puedes usar el método `setAppends` para anular todo el array de propiedades agregadas para una instancia de modelo dada:

    return $user->append('is_admin')->toArray();

    return $user->setAppends(['is_admin'])->toArray();

<a name="date-serialization"></a>
## Serialización de Fechas

<a name="customizing-the-default-date-format"></a>
#### Personalizando el Formato de Fecha Predeterminado

Puedes personalizar el formato de serialización predeterminado sobrescribiendo el método `serializeDate`. Este método no afecta cómo se formatean tus fechas para el almacenamiento en la base de datos:

    /**
     * Preparar una fecha para la serialización de array / JSON.
     */
    protected function serializeDate(DateTimeInterface $date): string
    {
        return $date->format('Y-m-d');
    }

<a name="customizing-the-date-format-per-attribute"></a>
#### Personalizando el Formato de Fecha por Atributo

Puedes personalizar el formato de serialización de atributos de fecha individuales de Eloquent especificando el formato de fecha en las [declaraciones de cast](/docs/{{version}}/eloquent-mutators#attribute-casting) del modelo:

    protected function casts(): array
    {
        return [
            'birthday' => 'date:Y-m-d',
            'joined_at' => 'datetime:Y-m-d H:00',
        ];
    }
