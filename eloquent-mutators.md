# Eloquent: Mutadores y Casting

- [Introducción](#introduction)
- [Accesores y Mutadores](#accessors-and-mutators)
  - [Definición de un Accesor](#defining-an-accessor)
  - [Definición de un Mutador](#defining-a-mutator)
- [Casteo de Atributos](#attribute-casting)
  - [Casteo de Array y JSON](#array-and-json-casting)
  - [Casteo de Fecha](#date-casting)
  - [Casteo de Enum](#enum-casting)
  - [Casteo Encriptado](#encrypted-casting)
  - [Casteo de Tiempo de Consulta](#query-time-casting)
- [Casts Personalizados](#custom-casts)
  - [Casteo de Valor Objeto](#value-object-casting)
  - [Serialización de Array / JSON](#array-json-serialization)
  - [Casteo Inbound](#inbound-casting)
  - [Parámetros de Casteo](#cast-parameters)
  - [Castables](#castables)

<a name="introduction"></a>
## Introducción

Los accesores, mutadores y el casting de atributos te permiten transformar los valores de los atributos de Eloquent cuando los recuperas o los estableces en instancias de modelo. Por ejemplo, es posible que desees usar el [encriptador de Laravel](/docs/%7B%7Bversion%7D%7D/encryption) para encriptar un valor mientras se almacena en la base de datos, y luego desencriptar automáticamente el atributo cuando lo accedes en un modelo Eloquent. O, es posible que desees convertir una cadena JSON que se almacena en tu base de datos a un array cuando se accede a través de tu modelo Eloquent.

<a name="accessors-and-mutators"></a>
## Accesores y Mutadores


<a name="defining-an-accessor"></a>
### Definiendo un Accesor

Un accessor transforma un valor de atributo de Eloquent cuando se accede a él. Para definir un accessor, crea un método protegido en tu modelo para representar el atributo accesible. Este nombre de método debe corresponder a la representación en "camel case" del verdadero atributo del modelo subyacente / columna de base de datos cuando sea aplicable.
En este ejemplo, definiremos un accesor para el atributo `first_name`. El accesor será llamado automáticamente por Eloquent al intentar recuperar el valor del atributo `first_name`. Todos los métodos de acceso / mutador de atributos deben declarar un tipo de retorno de `Illuminate\Database\Eloquent\Casts\Attribute`:


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * Get the user's first name.
     */
    protected function firstName(): Attribute
    {
        return Attribute::make(
            get: fn (string $value) => ucfirst($value),
        );
    }
}
```
Todos los métodos de acceso devuelven una instancia de `Attribute` que define cómo se accederá al atributo y, opcionalmente, cómo se mutará. En este ejemplo, solo estamos definiendo cómo se accederá al atributo. Para hacerlo, suministramos el argumento `get` al constructor de la clase `Attribute`.
Como puedes ver, el valor original de la columna se pasa al accessor, lo que te permite manipular y devolver el valor. Para acceder al valor del accessor, simplemente puedes acceder al atributo `first_name` en una instancia del modelo:


```php
use App\Models\User;

$user = User::find(1);

$firstName = $user->first_name;
```
> [!NOTA]
Si deseas que estos valores calculados se añadan a las representaciones de array / JSON de tu modelo, [necesitarás añadirlos](/docs/%7B%7Bversion%7D%7D/eloquent-serialization#appending-values-to-json).

<a name="building-value-objects-from-multiple-attributes"></a>
#### Construyendo Objetos de Valor a Partir de Múltiples Atributos

A veces, tu accesor puede necesitar transformar múltiples atributos del modelo en un solo "objeto de valor". Para hacerlo, tu cierre `get` puede aceptar un segundo argumento de `$attributes`, que se proporcionará automáticamente al cierre y contendrá un array con todos los atributos actuales del modelo:


```php
use App\Support\Address;
use Illuminate\Database\Eloquent\Casts\Attribute;

/**
 * Interact with the user's address.
 */
protected function address(): Attribute
{
    return Attribute::make(
        get: fn (mixed $value, array $attributes) => new Address(
            $attributes['address_line_one'],
            $attributes['address_line_two'],
        ),
    );
}

```

<a name="accessor-caching"></a>
#### Caché de Accesores

Al devolver objetos de valor desde accesores, cualquier cambio realizado en el objeto de valor se sincronizará automáticamente de vuelta al modelo antes de que se guarde el modelo. Esto es posible porque Eloquent retiene las instancias devueltas por los accesores, de modo que puede devolver la misma instancia cada vez que se invoca el accessor:


```php
use App\Models\User;

$user = User::find(1);

$user->address->lineOne = 'Updated Address Line 1 Value';
$user->address->lineTwo = 'Updated Address Line 2 Value';

$user->save();
```
Sin embargo, a veces es posible que desees habilitar la caché para valores primitivos como cadenas y booleanos, especialmente si son computacionalmente intensivos. Para lograr esto, puedes invocar el método `shouldCache` al definir tu accesor:


```php
protected function hash(): Attribute
{
    return Attribute::make(
        get: fn (string $value) => bcrypt(gzuncompress($value)),
    )->shouldCache();
}

```
Si deseas desactivar el comportamiento de almacenamiento en caché de objetos de los atributos, puedes invocar el método `withoutObjectCaching` al definir el atributo:


```php
/**
 * Interact with the user's address.
 */
protected function address(): Attribute
{
    return Attribute::make(
        get: fn (mixed $value, array $attributes) => new Address(
            $attributes['address_line_one'],
            $attributes['address_line_two'],
        ),
    )->withoutObjectCaching();
}

```

<a name="defining-a-mutator"></a>
### Definiendo un Mutador

Un mutador transforma el valor de un atributo Eloquent cuando se establece. Para definir un mutador, puedes proporcionar el argumento `set` al definir tu atributo. Definamos un mutador para el atributo `first_name`. Este mutador se llamará automáticamente cuando intentemos establecer el valor del atributo `first_name` en el modelo:


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * Interact with the user's first name.
     */
    protected function firstName(): Attribute
    {
        return Attribute::make(
            get: fn (string $value) => ucfirst($value),
            set: fn (string $value) => strtolower($value),
        );
    }
}
```
La `función anónima` de mutador recibirá el valor que se está configurando en el atributo, lo que te permitirá manipular el valor y devolver el valor manipulado. Para usar nuestro mutador, solo necesitamos establecer el atributo `first_name` en un modelo Eloquent:


```php
use App\Models\User;

$user = User::find(1);

$user->first_name = 'Sally';
```
En este ejemplo, el callback `set` se llamará con el valor `Sally`. El mutador aplicará then la función `strtolower` al nombre y establecerá su valor resultante en el array interno `$attributes` del modelo.

<a name="mutating-multiple-attributes"></a>
#### Mutando Múltiples Atributos

A veces tu mutador puede necesitar establecer múltiples atributos en el modelo subyacente. Para hacerlo, puedes devolver un array desde la `función anónima` `set`. Cada clave en el array debe corresponder con un atributo subyacente / columna de base de datos asociada con el modelo:


```php
use App\Support\Address;
use Illuminate\Database\Eloquent\Casts\Attribute;

/**
 * Interact with the user's address.
 */
protected function address(): Attribute
{
    return Attribute::make(
        get: fn (mixed $value, array $attributes) => new Address(
            $attributes['address_line_one'],
            $attributes['address_line_two'],
        ),
        set: fn (Address $value) => [
            'address_line_one' => $value->lineOne,
            'address_line_two' => $value->lineTwo,
        ],
    );
}

```

<a name="attribute-casting"></a>
## Conversión de Atributos

El casting de atributos proporciona una funcionalidad similar a los accessors y mutators sin requerir que definas métodos adicionales en tu modelo. En su lugar, el método `casts` de tu modelo ofrece una forma conveniente de convertir atributos a tipos de datos comunes.
El método `casts` debe devolver un array donde la clave es el nombre del atributo que se está convirtiendo y el valor es el tipo al que deseas convertir la columna. Los tipos de conversión soportados son:
<div class="content-list" markdown="1">

- `array`
- `AsStringable::class`
- `boolean`
- `collection`
- `date`
- `datetime`
- `immutable_date`
- `immutable_datetime`
- 
<code>decimal:<precision></code>

- `double`
- `encrypted`
- `encrypted:array`
- `encrypted:collection`
- `encrypted:object`
- `float`
- `hashed`
- `integer`
- `object`
- `real`
- `string`
- `timestamp`
</div>
Para demostrar el casting de atributos, vamos a convertir el atributo `is_admin`, que se almacena en nuestra base de datos como un entero (`0` o `1`), a un valor booleano:


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_admin' => 'boolean',
        ];
    }
}
```
Después de definir el elenco, el atributo `is_admin` siempre se convertirá a un booleano cuando accedas a él, incluso si el valor subyacente se almacena en la base de datos como un entero:


```php
$user = App\Models\User::find(1);

if ($user->is_admin) {
    // ...
}
```
Si necesitas agregar un nuevo cast temporal en tiempo de ejecución, puedes usar el método `mergeCasts`. Estas definiciones de cast se añadirán a cualquiera de los casts ya definidos en el modelo:


```php
$user->mergeCasts([
    'is_admin' => 'integer',
    'options' => 'object',
]);
```
> [!WARNING]
Los atributos que son `null` no serán convertidos. Además, nunca debes definir un cast (o un atributo) que tenga el mismo nombre que una relación o asignar un cast a la clave principal del modelo.

<a name="stringable-casting"></a>
#### Casting de Stringable

Puedes usar la clase de casteo `Illuminate\Database\Eloquent\Casts\AsStringable` para convertir un atributo de modelo a un objeto `Illuminate\Support\Stringable` [fluente](/docs/%7B%7Bversion%7D%7D/strings#fluent-strings-method-list):


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\AsStringable;
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'directory' => AsStringable::class,
        ];
    }
}
```

<a name="array-and-json-casting"></a>
### Conversión de Array y JSON

El cast `array` es especialmente útil cuando se trabaja con columnas que se almacenan como JSON serializado. Por ejemplo, si tu base de datos tiene un tipo de campo `JSON` o `TEXT` que contiene JSON serializado, agregar el cast `array` a ese atributo deserializará automáticamente el atributo a un array de PHP cuando lo accedas en tu modelo Eloquent:


```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'options' => 'array',
        ];
    }
}
```
Una vez que el cast esté definido, puedes acceder al atributo `options` y se deserializará automáticamente de JSON a un array de PHP. Cuando establezcas el valor del atributo `options`, el array dado se serializará automáticamente de nuevo en JSON para su almacenamiento:


```php
use App\Models\User;

$user = User::find(1);

$options = $user->options;

$options['key'] = 'value';

$user->options = $options;

$user->save();
```
Para actualizar un solo campo de un atributo JSON con una sintaxis más concisa, puedes [hacer que el atributo sea asignable en masa](/docs/%7B%7Bversion%7D%7D/eloquent#mass-assignment-json-columns) y usar el operador `->` al llamar al método `update`:


```php
$user = User::find(1);

$user->update(['options->key' => 'value']);
```

<a name="array-object-and-collection-casting"></a>
#### Casting de Objetos de Array y Colección

Aunque el cast `array` estándar es suficiente para muchas aplicaciones, tiene algunas desventajas. Dado que el cast `array` devuelve un tipo primitivo, no es posible modificar un desplazamiento del array directamente. Por ejemplo, el siguiente código provocará un error de PHP:


```php
$user = User::find(1);

$user->options['key'] = $value;
```
Para resolver esto, Laravel ofrece un cast `AsArrayObject` que convierte tu atributo JSON a una clase [ArrayObject](https://www.php.net/manual/en/class.arrayobject.php). Esta función se implementa utilizando la [implementación de cast personalizados](#custom-casts) de Laravel, que permite a Laravel almacenar en caché y transformar de manera inteligente el objeto mutado, de modo que se puedan modificar desplazamientos individuales sin provocar un error de PHP. Para usar el cast `AsArrayObject`, simplemente asígnalo a un atributo:


```php
use Illuminate\Database\Eloquent\Casts\AsArrayObject;

/**
 * Get the attributes that should be cast.
 *
 * @return array<string, string>
 */
protected function casts(): array
{
    return [
        'options' => AsArrayObject::class,
    ];
}
```
Del mismo modo, Laravel ofrece un casting `AsCollection` que convierte tu atributo JSON en una instancia de la [Collection](/docs/%7B%7Bversion%7D%7D/collections) de Laravel:


```php
use Illuminate\Database\Eloquent\Casts\AsCollection;

/**
 * Get the attributes that should be cast.
 *
 * @return array<string, string>
 */
protected function casts(): array
{
    return [
        'options' => AsCollection::class,
    ];
}
```
Si deseas que el cast `AsCollection` instancie una clase de colección personalizada en lugar de la clase de colección base de Laravel, puedes proporcionar el nombre de la clase de colección como argumento del cast:


```php
use App\Collections\OptionCollection;
use Illuminate\Database\Eloquent\Casts\AsCollection;

/**
 * Get the attributes that should be cast.
 *
 * @return array<string, string>
 */
protected function casts(): array
{
    return [
        'options' => AsCollection::using(OptionCollection::class),
    ];
}
```

<a name="date-casting"></a>
### Conversión de Fechas

Por defecto, Eloquent convertirá las columnas `created_at` y `updated_at` en instancias de [Carbon](https://github.com/briannesbitt/Carbon), que extiende la clase `DateTime` de PHP y proporciona una variedad de métodos útiles. Puedes convertir atributos de fecha adicionales definiendo conversiones de fecha adicionales dentro del método `casts` de tu modelo. Típicamente, las fechas deben ser convertidas utilizando los tipos de cast `datetime` o `immutable_datetime`.
Al definir un cast de `date` o `datetime`, también puedes especificar el formato de la fecha. Este formato se utilizará cuando el [modelo sea serializado a un array o JSON](/docs/%7B%7Bversion%7D%7D/eloquent-serialization):


```php
/**
 * Get the attributes that should be cast.
 *
 * @return array<string, string>
 */
protected function casts(): array
{
    return [
        'created_at' => 'datetime:Y-m-d',
    ];
}
```
Cuando una columna se convierte a una fecha, puedes establecer el valor del atributo del modelo correspondiente a un timestamp UNIX, cadena de fecha (`Y-m-d`), cadena de fecha-hora o una instancia de `DateTime` / `Carbon`. El valor de la fecha se convertirá y almacenará correctamente en tu base de datos.
Puedes personalizar el formato de serialización predeterminado para todas las fechas de tu modelo definiendo un método `serializeDate` en tu modelo. Este método no afecta cómo se formatean tus fechas para el almacenamiento en la base de datos:


```php
/**
 * Prepare a date for array / JSON serialization.
 */
protected function serializeDate(DateTimeInterface $date): string
{
    return $date->format('Y-m-d');
}
```
Para especificar el formato que se debe usar al almacenar las fechas de un modelo en tu base de datos, debes definir una propiedad `$dateFormat` en tu modelo:


```php
/**
 * The storage format of the model's date columns.
 *
 * @var string
 */
protected $dateFormat = 'U';
```

<a name="date-casting-and-timezones"></a>
#### Conversión de Fechas, Serialización y Zonas Horarias

Por defecto, los casts `date` y `datetime` serializarán las fechas a una cadena de fecha ISO-8601 en UTC (`YYYY-MM-DDTHH:MM:SS.uuuuuuZ`), sin importar la zona horaria especificada en la opción de configuración `timezone` de tu aplicación. Se te recomienda encarecidamente que siempre uses este formato de serialización, así como almacenar las fechas de tu aplicación en la zona horaria UTC no cambiando la opción de configuración `timezone` de tu aplicación de su valor predeterminado `UTC`. Usar consistentemente la zona horaria UTC en toda tu aplicación proporcionará el máximo nivel de interoperabilidad con otras bibliotecas de manipulación de fechas escritas en PHP y JavaScript.
Si se aplica un formato personalizado a el cast `date` o `datetime`, como `datetime:Y-m-d H:i:s`, se utilizará la zona horaria interna de la instancia de Carbon durante la serialización de la fecha. Típicamente, esta será la zona horaria especificada en la opción de configuración `timezone` de tu aplicación.

<a name="enum-casting"></a>
### Casting de Enum

Eloquent también te permite convertir los valores de tus atributos a [Enums](https://www.php.net/manual/en/language.enumerations.backed.php) de PHP. Para lograr esto, puedes especificar el atributo y el enum que deseas convertir en el método `casts` de tu modelo:


```php
use App\Enums\ServerStatus;

/**
 * Get the attributes that should be cast.
 *
 * @return array<string, string>
 */
protected function casts(): array
{
    return [
        'status' => ServerStatus::class,
    ];
}
```
Una vez que hayas definido el cast en tu modelo, el atributo especificado se convertirá automáticamente a y desde un enum cuando interactúes con el atributo:


```php
if ($server->status == ServerStatus::Provisioned) {
    $server->status = ServerStatus::Ready;

    $server->save();
}
```

<a name="casting-arrays-of-enums"></a>
#### Castiendo Arrays de Enums

A veces es posible que necesites que tu modelo almacene un array de valores enum dentro de una sola columna. Para lograr esto, puedes utilizar los casts `AsEnumArrayObject` o `AsEnumCollection` proporcionados por Laravel:


```php
use App\Enums\ServerStatus;
use Illuminate\Database\Eloquent\Casts\AsEnumCollection;

/**
 * Get the attributes that should be cast.
 *
 * @return array<string, string>
 */
protected function casts(): array
{
    return [
        'statuses' => AsEnumCollection::of(ServerStatus::class),
    ];
}
```

<a name="encrypted-casting"></a>
### Encriptación de Casting

El cast `encrypted` cifrará el valor del atributo de un modelo utilizando las funciones de [cifrado](/docs/%7B%7Bversion%7D%7D/encryption) integradas de Laravel. Además, los casts `encrypted:array`, `encrypted:collection`, `encrypted:object`, `AsEncryptedArrayObject` y `AsEncryptedCollection` funcionan como sus contrapartes no cifradas; sin embargo, como podrías esperar, el valor subyacente se cifra cuando se almacena en tu base de datos.
Dado que la longitud final del texto encriptado no es predecible y es más larga que su contraparte de texto plano, asegúrate de que la columna de la base de datos asociada sea de tipo `TEXT` o mayor. Además, dado que los valores están encriptados en la base de datos, no podrás consultar o buscar valores de atributos encriptados.

<a name="key-rotation"></a>
#### Rotación de Claves

Como sabes, Laravel encripta cadenas utilizando el valor de configuración `key` especificado en el archivo de configuración `app` de tu aplicación. Típicamente, este valor corresponde al valor de la variable de entorno `APP_KEY`. Si necesitas rotar la clave de encriptación de tu aplicación, deberás volver a encriptar manualmente tus atributos encriptados utilizando la nueva clave.

<a name="query-time-casting"></a>
### Conversión de Tiempo de Consulta

A veces es posible que necesites aplicar conversiones mientras ejecutas una consulta, como al seleccionar un valor en bruto de una tabla. Por ejemplo, considera la siguiente consulta:


```php
use App\Models\Post;
use App\Models\User;

$users = User::select([
    'users.*',
    'last_posted_at' => Post::selectRaw('MAX(created_at)')
            ->whereColumn('user_id', 'users.id')
])->get();
```
El atributo `last_posted_at` en los resultados de esta consulta será una simple cadena. Sería maravilloso si pudiéramos aplicar un casting `datetime` a este atributo al ejecutar la consulta. Afortunadamente, podemos lograr esto utilizando el método `withCasts`:


```php
$users = User::select([
    'users.*',
    'last_posted_at' => Post::selectRaw('MAX(created_at)')
            ->whereColumn('user_id', 'users.id')
])->withCasts([
    'last_posted_at' => 'datetime'
])->get();
```

<a name="custom-casts"></a>
## Casts Personalizados

Laravel tiene una variedad de tipos de cast integrados y útiles; sin embargo, es posible que ocasionalmente necesites definir tus propios tipos de cast. Para crear un cast, ejecuta el comando Artisan `make:cast`. La nueva clase de cast se colocará en tu directorio `app/Casts`:


```shell
php artisan make:cast Json

```
Todas las clases de casting personalizadas implementan la interfaz `CastsAttributes`. Las clases que implementan esta interfaz deben definir un método `get` y un método `set`. El método `get` es responsable de transformar un valor en bruto de la base de datos en un valor de tipo casteado, mientras que el método `set` debe transformar un valor casteado en un valor en bruto que se puede almacenar en la base de datos. Como ejemplo, reimplementaremos el tipo de casteo `json` incorporado como un tipo de casteo personalizado:


```php
<?php

namespace App\Casts;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;

class Json implements CastsAttributes
{
    /**
     * Cast the given value.
     *
     * @param  array<string, mixed>  $attributes
     * @return array<string, mixed>
     */
    public function get(Model $model, string $key, mixed $value, array $attributes): array
    {
        return json_decode($value, true);
    }

    /**
     * Prepare the given value for storage.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function set(Model $model, string $key, mixed $value, array $attributes): string
    {
        return json_encode($value);
    }
}
```
Una vez que hayas definido un tipo de conversión personalizado, puedes adjuntarlo a un atributo del modelo utilizando su nombre de clase:


```php
<?php

namespace App\Models;

use App\Casts\Json;
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'options' => Json::class,
        ];
    }
}
```

<a name="value-object-casting"></a>
### Casting de Objetos de Valor

No estás limitado a convertir valores a tipos primitivos. También puedes convertir valores a objetos. Definir conversiones personalizadas que conviertan valores a objetos es muy similar a la conversión a tipos primitivos; sin embargo, el método `set` debe devolver un array de pares clave / valor que se utilizarán para establecer valores en bruto y almacenables en el modelo.
Como ejemplo, definiremos una clase de conversión personalizada que convierta múltiples valores del modelo en un solo objeto de valor `Address`. Supondremos que el valor `Address` tiene dos propiedades públicas: `lineOne` y `lineTwo`:


```php
<?php

namespace App\Casts;

use App\ValueObjects\Address as AddressValueObject;
use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;
use InvalidArgumentException;

class Address implements CastsAttributes
{
    /**
     * Cast the given value.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function get(Model $model, string $key, mixed $value, array $attributes): AddressValueObject
    {
        return new AddressValueObject(
            $attributes['address_line_one'],
            $attributes['address_line_two']
        );
    }

    /**
     * Prepare the given value for storage.
     *
     * @param  array<string, mixed>  $attributes
     * @return array<string, string>
     */
    public function set(Model $model, string $key, mixed $value, array $attributes): array
    {
        if (! $value instanceof AddressValueObject) {
            throw new InvalidArgumentException('The given value is not an Address instance.');
        }

        return [
            'address_line_one' => $value->lineOne,
            'address_line_two' => $value->lineTwo,
        ];
    }
}
```
Al realizar la conversión a objetos de valor, cualquier cambio realizado en el objeto de valor se sincronizará automáticamente con el modelo antes de que se guarde el modelo:


```php
use App\Models\User;

$user = User::find(1);

$user->address->lineOne = 'Updated Address Value';

$user->save();
```
> [!NOTA]
Si planeas serializar tus modelos Eloquent que contienen objetos de valor a JSON o arreglos, debes implementar las interfaces `Illuminate\Contracts\Support\Arrayable` y `JsonSerializable` en el objeto de valor.

<a name="value-object-caching"></a>
#### Caché de Objetos de Valor

Cuando se resuelven los atributos que están casteados a objetos de valor, Eloquent los almacena en caché. Por lo tanto, se devolverá la misma instancia de objeto si se accede al atributo nuevamente.
Si deseas desactivar el comportamiento de almacenamiento en caché de objetos de las clases de casteo personalizadas, puedes declarar una propiedad pública `withoutObjectCaching` en tu clase de casteo personalizado:


```php
class Address implements CastsAttributes
{
    public bool $withoutObjectCaching = true;

    // ...
}

```

<a name="array-json-serialization"></a>
### Serialización de Array / JSON

Cuando un modelo Eloquent se convierte a un array o JSON utilizando los métodos `toArray` y `toJson`, tus objetos de valor de casting personalizados se serializarán típicamente, siempre que implementen las interfaces `Illuminate\Contracts\Support\Arrayable` y `JsonSerializable`. Sin embargo, al usar objetos de valor proporcionados por bibliotecas de terceros, es posible que no tengas la capacidad de agregar estas interfaces al objeto.
Por lo tanto, puedes especificar que tu clase de casteo personalizada será responsable de serializar el objeto de valor. Para hacerlo, tu clase de casteo personalizada debe implementar la interfaz `Illuminate\Contracts\Database\Eloquent\SerializesCastableAttributes`. Esta interfaz establece que tu clase debe contener un método `serialize` que debe devolver la forma serializada de tu objeto de valor:


```php
/**
 * Get the serialized representation of the value.
 *
 * @param  array<string, mixed>  $attributes
 */
public function serialize(Model $model, string $key, mixed $value, array $attributes): string
{
    return (string) $value;
}
```

<a name="inbound-casting"></a>
### Proyección Entrante

Ocasionalmente, es posible que necesites escribir una clase de casteo personalizada que solo transforme los valores que se están configurando en el modelo y no realice ninguna operación cuando se recuperan atributos del modelo.
Solo los casts personalizados de entrada deben implementar la interfaz `CastsInboundAttributes`, que solo requiere que se defina un método `set`. El comando Artisan `make:cast` se puede invocar con la opción `--inbound` para generar una clase de cast solo de entrada:


```shell
php artisan make:cast Hash --inbound

```
Un ejemplo clásico de un cast solo de entrada es un cast de "hashing". Por ejemplo, podemos definir un cast que hashea los valores de entrada a través de un algoritmo dado:


```php
<?php

namespace App\Casts;

use Illuminate\Contracts\Database\Eloquent\CastsInboundAttributes;
use Illuminate\Database\Eloquent\Model;

class Hash implements CastsInboundAttributes
{
    /**
     * Create a new cast class instance.
     */
    public function __construct(
        protected string|null $algorithm = null,
    ) {}

    /**
     * Prepare the given value for storage.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function set(Model $model, string $key, mixed $value, array $attributes): string
    {
        return is_null($this->algorithm)
                    ? bcrypt($value)
                    : hash($this->algorithm, $value);
    }
}
```

<a name="cast-parameters"></a>
### Parámetros de Casting

Al adjuntar un tipo personalizado a un modelo, los parámetros del tipo pueden especificarse separándolos del nombre de la clase utilizando un carácter `:` y delimitando múltiples parámetros con comas. Los parámetros se pasarán al constructor de la clase de tipo:


```php
/**
 * Get the attributes that should be cast.
 *
 * @return array<string, string>
 */
protected function casts(): array
{
    return [
        'secret' => Hash::class.':sha256',
    ];
}
```

<a name="castables"></a>
### Castables

Puede que desees permitir que los objetos de valor de tu aplicación definan sus propias clases de cast personalizadas. En lugar de adjuntar la clase de cast personalizada a tu modelo, también puedes adjuntar una clase de objeto de valor que implemente la interfaz `Illuminate\Contracts\Database\Eloquent\Castable`:


```php
use App\ValueObjects\Address;

protected function casts(): array
{
    return [
        'address' => Address::class,
    ];
}
```
Los objetos que implementan la interfaz `Castable` deben definir un método `castUsing` que devuelva el nombre de la clase del clasificador personalizado que es responsable de convertir hacia y desde la clase `Castable`:


```php
<?php

namespace App\ValueObjects;

use Illuminate\Contracts\Database\Eloquent\Castable;
use App\Casts\Address as AddressCast;

class Address implements Castable
{
    /**
     * Get the name of the caster class to use when casting from / to this cast target.
     *
     * @param  array<string, mixed>  $arguments
     */
    public static function castUsing(array $arguments): string
    {
        return AddressCast::class;
    }
}
```
Al utilizar clases `Castable`, aún puedes proporcionar argumentos en la definición del método `casts`. Los argumentos se pasarán al método `castUsing`:


```php
use App\ValueObjects\Address;

protected function casts(): array
{
    return [
        'address' => Address::class.':argument',
    ];
}
```

<a name="anonymous-cast-classes"></a>
#### Castables y Clases de Cast Anónimas

Al combinar "castables" con las [clases anónimas](https://www.php.net/manual/en/language.oop5.anonymous.php) de PHP, puedes definir un objeto de valor y su lógica de casting como un solo objeto castable. Para lograr esto, devuelve una clase anónima del método `castUsing` de tu objeto de valor. La clase anónima debe implementar la interfaz `CastsAttributes`:


```php
<?php

namespace App\ValueObjects;

use Illuminate\Contracts\Database\Eloquent\Castable;
use Illuminate\Contracts\Database\Eloquent\CastsAttributes;

class Address implements Castable
{
    // ...

    /**
     * Get the caster class to use when casting from / to this cast target.
     *
     * @param  array<string, mixed>  $arguments
     */
    public static function castUsing(array $arguments): CastsAttributes
    {
        return new class implements CastsAttributes
        {
            public function get(Model $model, string $key, mixed $value, array $attributes): Address
            {
                return new Address(
                    $attributes['address_line_one'],
                    $attributes['address_line_two']
                );
            }

            public function set(Model $model, string $key, mixed $value, array $attributes): array
            {
                return [
                    'address_line_one' => $value->lineOne,
                    'address_line_two' => $value->lineTwo,
                ];
            }
        };
    }
}
```