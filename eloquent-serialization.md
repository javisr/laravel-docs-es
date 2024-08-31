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

Al construir APIs utilizando Laravel, a menudo necesitarás convertir tus modelos y relaciones a arrays o JSON. Eloquent incluye métodos convenientes para realizar estas conversiones, así como para controlar qué atributos se incluyen en la representación serializada de tus modelos.
> [!NOTE]
Para una manera aún más robusta de manejar la serialización JSON de modelos y colecciones de Eloquent, consulta la documentación sobre [recursos API de Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent-resources).

<a name="serializing-models-and-collections"></a>
## Serializando Modelos y Colecciones


<a name="serializing-to-arrays"></a>
### Serializando a Arrays

Para convertir un modelo y sus [relaciones](/docs/%7B%7Bversion%7D%7D/eloquent-relationships) cargadas a un array, debes usar el método `toArray`. Este método es recursivo, por lo que todos los atributos y todas las relaciones (incluidas las relaciones de relaciones) se convertirán a arrays:


```php
use App\Models\User;

$user = User::with('roles')->first();

return $user->toArray();
```
El método `attributesToArray` se puede utilizar para convertir los atributos de un modelo a un array, pero no sus relaciones:


```php
$user = User::first();

return $user->attributesToArray();
```
También puedes convertir colecciones enteras de modelos a arrays llamando al método `toArray` en la instancia de la colección:


```php
$users = User::all();

return $users->toArray();
```

<a name="serializing-to-json"></a>
### Serializando a JSON

Para convertir un modelo a JSON, debes usar el método `toJson`. Al igual que `toArray`, el método `toJson` es recursivo, por lo que todos los atributos y relaciones se convertirán a JSON. También puedes especificar cualquier opción de codificación JSON que sea [compatible con PHP](https://secure.php.net/manual/en/function.json-encode.php):


```php
use App\Models\User;

$user = User::find(1);

return $user->toJson();

return $user->toJson(JSON_PRETTY_PRINT);
```
Alternativamente, puedes convertir un modelo o una colección a una cadena, lo que llamará automáticamente al método `toJson` en el modelo o la colección:


```php
return (string) User::find(1);
```
Dado que los modelos y colecciones se convierten a JSON cuando se convierten a una cadena, puedes devolver objetos Eloquent directamente desde las rutas o controladores de tu aplicación. Laravel serializará automáticamente tus modelos y colecciones Eloquent a JSON cuando se devuelvan desde rutas o controladores:


```php
Route::get('/users', function () {
    return User::all();
});
```

<a name="relationships"></a>
#### Relaciones

Cuando un modelo Eloquent se convierte a JSON, sus relaciones cargadas se incluirán automáticamente como atributos en el objeto JSON. Además, aunque los métodos de relación de Eloquent se definen utilizando nombres de método en "camel case", el atributo JSON de una relación será "snake case".

<a name="hiding-attributes-from-json"></a>
## Ocultando Atributos de JSON

A veces es posible que desees limitar los atributos, como contraseñas, que se incluyen en la representación de array o JSON de tu modelo. Para hacer esto, añade una propiedad `$hidden` a tu modelo. Los atributos que se enumeran en el array de la propiedad `$hidden` no se incluirán en la representación serializada de tu modelo:


```php
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
```
> [!NOTA]
Para ocultar relaciones, añade el nombre del método de la relación a la propiedad `$hidden` de tu modelo Eloquent.
Alternativamente, puedes usar la propiedad `visible` para definir una "lista de permitidos" de atributos que deberían incluirse en la representación de array y JSON de tu modelo. Todos los atributos que no estén presentes en el array `$visible` serán ocultos cuando el modelo se convierta en un array o JSON:


```php
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
```

<a name="temporarily-modifying-attribute-visibility"></a>
#### Modificando Temporalmente la Visibilidad de Atributos

Si deseas hacer que algunos atributos típicamente ocultos sean visibles en una instancia de modelo dada, puedes usar el método `makeVisible`. El método `makeVisible` devuelve la instancia del modelo:


```php
return $user->makeVisible('attribute')->toArray();
```
Del mismo modo, si deseas ocultar algunos atributos que suelen ser visibles, puedes usar el método `makeHidden`.


```php
return $user->makeHidden('attribute')->toArray();
```
Si deseas anular temporalmente todos los atributos visibles u ocultos, puedes usar los métodos `setVisible` y `setHidden` respectivamente:


```php
return $user->setVisible(['id', 'name'])->toArray();

return $user->setHidden(['email', 'password', 'remember_token'])->toArray();
```

<a name="appending-values-to-json"></a>
## Añadiendo Valores a JSON

Ocasionalmente, al convertir modelos a arrays o JSON, es posible que desees añadir atributos que no tienen una columna correspondiente en tu base de datos. Para hacerlo, primero define un [accesor](/docs/%7B%7Bversion%7D%7D/eloquent-mutators) para el valor:


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * Determine if the user is an administrator.
     */
    protected function isAdmin(): Attribute
    {
        return new Attribute(
            get: fn () => 'yes',
        );
    }
}
```
Si deseas que el accessor siempre se añada a las representaciones de array y JSON de tu modelo, puedes añadir el nombre del atributo a la propiedad `appends` de tu modelo. Ten en cuenta que los nombres de los atributos se suelen referenciar utilizando su representación serializada en "snake case", aunque el método PHP del accessor se defina utilizando "camel case":


```php
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
```
Una vez que el atributo se haya añadido a la lista `appends`, se incluirá tanto en las representaciones de array como de JSON del modelo. Los atributos en el array `appends` también respetarán las configuraciones `visible` y `hidden` configuradas en el modelo.

<a name="appending-at-run-time"></a>
#### Añadiendo en Tiempo de Ejecución

En tiempo de ejecución, puedes indicarle a una instancia de modelo que agregue atributos adicionales utilizando el método `append`. O, puedes usar el método `setAppends` para sobreescribir todo el array de propiedades añadidas para una instancia de modelo dada:


```php
return $user->append('is_admin')->toArray();

return $user->setAppends(['is_admin'])->toArray();
```

<a name="date-serialization"></a>
## Serialización de Fechas


<a name="customizing-the-default-date-format"></a>
#### Personalizando el Formato de Fecha Predeterminado

Puedes personalizar el formato de serialización predeterminado sobrescribiendo el método `serializeDate`. Este método no afecta cómo se formatean tus fechas para almacenarse en la base de datos:


```php
/**
 * Prepare a date for array / JSON serialization.
 */
protected function serializeDate(DateTimeInterface $date): string
{
    return $date->format('Y-m-d');
}
```

<a name="customizing-the-date-format-per-attribute"></a>
#### Personalizando el Formato de Fecha por Atributo

Puedes personalizar el formato de serialización de atributos de fecha individuales de Eloquent especificando el formato de fecha en las [declaraciones de casting](/docs/%7B%7Bversion%7D%7D/eloquent-mutators#attribute-casting) del modelo:


```php
protected function casts(): array
{
    return [
        'birthday' => 'date:Y-m-d',
        'joined_at' => 'datetime:Y-m-d H:00',
    ];
}
```