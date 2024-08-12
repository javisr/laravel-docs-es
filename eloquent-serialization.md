# Eloquent: Serialización

- [Introducción](#introduction)
- [Serialización de modelos y colecciones](#serializing-models-and-collections)
  - [Serialización a arrays](#serializing-to-arrays)
  - [Serialización a JSON](#serializing-to-json)
- [Cómo ocultar atributos de JSON](#hiding-attributes-from-json)
- [Añadir valores a JSON](#appending-values-to-json)
- [Serialización de fechas](#date-serialization)

<a name="introduction"></a>
## Introducción

Cuando construyas APIs con Laravel, a menudo necesitarás convertir tus modelos y relaciones a arrays o JSON. Eloquent incluye métodos prácticos para realizar estas conversiones, así como para controlar qué atributos se incluyen en la representación serializada de tus modelos.

> **Nota**  
> Para manejar la serialización JSON de modelos y colecciones de Eloquent de una forma aún más robusta, consulta la documentación sobre [recursos de API de Eloquent](/docs/{{version}}/eloquent-resources).

<a name="serializing-models-and-collections"></a>
## Serialización de modelos y colecciones

<a name="serializing-to-arrays"></a>
### Serialización a arrays

Para convertir un modelo y sus [relaciones cargadas](/docs/{{version}}/eloquent-relationships) a un array, debes utilizar el método `toArray`. Este método es recursivo, por lo que todos los atributos y todas las relaciones (incluidas las relaciones de relaciones) se convertirán en arrays:

    use App\Models\User;

    $user = User::with('roles')->first();

    return $user->toArray();

El método `attributesToArray` puede utilizarse para convertir los atributos de un modelo en una array, pero no sus relaciones:

    $user = User::first();

    return $user->attributesToArray();

También puedes convertir [colecciones](/docs/{{version}}/eloquent-collections) enteras de modelos a arrays llamando al método `toArray` en la instancia de la colección:

    $users = User::all();

    return $users->toArray();

<a name="serializing-to-json"></a>
### Serialización a JSON

Para convertir un modelo a JSON, debe utilizar el método `toJson`. Al igual que `toArray`, el método `toJson` es recursivo, por lo que todos los atributos y relaciones se convertirán a JSON. También puede especificar cualquier opción de codificación JSON [soportada por PHP](https://secure.php.net/manual/en/function.json-encode.php):

    use App\Models\User;

    $user = User::find(1);

    return $user->toJson();

    return $user->toJson(JSON_PRETTY_PRINT);

De manera alternativa, puedes convertir un modelo o colección en una cadena. Esto llamará al método `toJson` en el modelo o colección:

    return (string) User::find(1);

Dado que los modelos y colecciones se convierten a JSON cuando se convierten a una cadena, puedes devolver objetos Eloquent directamente desde las rutas o controladores de tu aplicación. Laravel serializará automáticamente tus modelos y colecciones Eloquent a JSON cuando sean devueltos desde rutas o controladores:

    Route::get('users', function () {
        return User::all();
    });

<a name="relationships"></a>
#### Relaciones

Cuando un modelo Eloquent se convierte a JSON, sus relaciones cargadas se incluirán automáticamente como atributos en el objeto JSON. Además, aunque los métodos de relación Eloquent se definen utilizando nombres de método "camel case", el atributo JSON de una relación será "snake case".

<a name="hiding-attributes-from-json"></a>
## Ocultando Atributos de JSON

A veces es posible que desee limitar los atributos, tales como contraseñas, que se incluyen en la array de su modelo o representación JSON. Para ello, añada una propiedad `$hidden` a su modelo. Los atributos que aparezcan en el array de la propiedad `$hidden` no se incluirán en la representación serializada de tu modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The attributes that should be hidden for arrays.
         *
         * @var array
         */
        protected $hidden = ['password'];
    }

> **Nota**  
> Para ocultar relaciones, añada el nombre del método de la relación a la propiedad `$hidden` de su modelo Eloquent.

Como alternativa, puede utilizar la propiedad `visible` para definir una "lista permitida" de atributos que deben incluirse en la array de su modelo y en la representación JSON. Todos los atributos que no estén presentes en el array `$visible` se ocultarán cuando el modelo se convierta a array o JSON:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The attributes that should be visible in arrays.
         *
         * @var array
         */
        protected $visible = ['first_name', 'last_name'];
    }

<a name="temporarily-modifying-attribute-visibility"></a>
#### Modificación temporal de la visibilidad de los atributos

Si desea hacer visibles algunos atributos normalmente ocultos en una instancia de modelo determinada, puede utilizar el método `makeVisible`. El método `makeVisible` devuelve la instancia del modelo:

    return $user->makeVisible('attribute')->toArray();

Del mismo modo, si desea ocultar algunos atributos que suelen ser visibles, puede utilizar el método `makeHidden`.

    return $user->makeHidden('attribute')->toArray();

<a name="appending-values-to-json"></a>
## Añadir valores a JSON

Ocasionalmente, al convertir modelos a arrays o JSON, puede que desee añadir atributos que no tienen una columna correspondiente en su base de datos. Para ello, defina primero un [`accessor`](/docs/{{version}}/eloquent-mutators) para el valor:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Casts\Attribute;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Determine if the user is an administrator.
         *
         * @return \Illuminate\Database\Eloquent\Casts\Attribute
         */
        protected function isAdmin(): Attribute
        {
            return new Attribute(
                get: fn () => 'yes',
            );
        }
    }

Después de crear el accesor, añada el nombre del atributo a la propiedad `appends` de su modelo. Tenga en cuenta que los nombres de atributos son típicamente referenciados usando su representación serializada "snake case", aunque el método PHP del accesor esté definido usando "camel case":

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The accessors to append to the model's array form.
         *
         * @var array
         */
        protected $appends = ['is_admin'];
    }

Una vez añadido el atributo a la lista `appends`, se incluirá tanto en la array del modelo como en las representaciones JSON. Los atributos de la array `appends` también respetarán las opciones `visible` y `hidden` configuradas en el modelo.

<a name="appending-at-run-time"></a>
#### Añadir en tiempo de ejecución

En tiempo de ejecución, puedes ordenar a una instancia del modelo que añada atributos adicionales utilizando el método `append`. O bien, puede utilizar el método `setAppends` para anular toda la array de propiedades anexadas para una instancia de modelo determinada:

    return $user->append('is_admin')->toArray();

    return $user->setAppends(['is_admin'])->toArray();

<a name="date-serialization"></a>
## Serialización de fechas

<a name="customizing-the-default-date-format"></a>
#### Personalización del formato de fecha por defecto

Puede personalizar el formato de serialización por defecto modificando el método `serializeDate`. Este método no afecta a cómo se formatean las fechas para su almacenamiento en la base de datos:

    /**
     * Prepare a date for array / JSON serialization.
     *
     * @param  \DateTimeInterface  $date
     * @return string
     */
    protected function serializeDate(DateTimeInterface $date)
    {
        return $date->format('Y-m-d');
    }

<a name="customizing-the-date-format-per-attribute"></a>
#### Personalización del formato de fecha por atributo

Puede personalizar el formato de serialización de los atributos de fecha individuales de Eloquent especificando el formato de fecha en las [declaraciones cast](/docs/{{version}}/eloquent-mutators#attribute-casting) del modelo:

    protected $casts = [
        'birthday' => 'date:Y-m-d',
        'joined_at' => 'datetime:Y-m-d H:00',
    ];
