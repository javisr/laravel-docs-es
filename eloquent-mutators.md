# Eloquent: Mutadores y Casting

- [Introducción](#introduction)
- [Accesores y Mutadores](#accessors-and-mutators)
    - [Definiendo un Accesor](#defining-an-accessor)
    - [Definiendo un Mutador](#defining-a-mutator)
- [Casting de Atributos](#attribute-casting)
    - [Casting de Array y JSON](#array-and-json-casting)
    - [Casting de Fecha](#date-casting)
    - [Casting de Enum](#enum-casting)
    - [Casting Encriptado](#encrypted-casting)
    - [Casting de Tiempo de Consulta](#query-time-casting)
- [Casts Personalizados](#custom-casts)
    - [Casting de Objeto de Valor](#value-object-casting)
    - [Serialización de Array / JSON](#array-json-serialization)
    - [Casting Inbound](#inbound-casting)
    - [Parámetros de Casting](#cast-parameters)
    - [Castables](#castables)

<a name="introduction"></a>
## Introducción

Los accesores, mutadores y el casting de atributos te permiten transformar los valores de los atributos de Eloquent cuando los recuperas o los estableces en instancias de modelo. Por ejemplo, es posible que desees utilizar el [encriptador de Laravel](/docs/{{version}}/encryption) para encriptar un valor mientras se almacena en la base de datos, y luego desencriptar automáticamente el atributo cuando lo accedes en un modelo Eloquent. O, es posible que desees convertir una cadena JSON que se almacena en tu base de datos a un array cuando se accede a través de tu modelo Eloquent.

<a name="accessors-and-mutators"></a>
## Accesores y Mutadores

<a name="defining-an-accessor"></a>
### Definiendo un Accesor

Un accesor transforma un valor de atributo de Eloquent cuando se accede a él. Para definir un accesor, crea un método protegido en tu modelo para representar el atributo accesible. Este nombre de método debe corresponder a la representación en "camel case" del verdadero atributo subyacente del modelo / columna de base de datos cuando sea aplicable.

En este ejemplo, definiremos un accesor para el atributo `first_name`. El accesor será llamado automáticamente por Eloquent cuando intente recuperar el valor del atributo `first_name`. Todos los métodos de accesor / mutador de atributos deben declarar un tipo de retorno de `Illuminate\Database\Eloquent\Casts\Attribute`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Casts\Attribute;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Obtener el primer nombre del usuario.
         */
        protected function firstName(): Attribute
        {
            return Attribute::make(
                get: fn (string $value) => ucfirst($value),
            );
        }
    }

Todos los métodos de accesor devuelven una instancia de `Attribute` que define cómo se accederá al atributo y, opcionalmente, se mutará. En este ejemplo, solo estamos definiendo cómo se accederá al atributo. Para hacerlo, suministramos el argumento `get` al constructor de la clase `Attribute`.

Como puedes ver, el valor original de la columna se pasa al accesor, lo que te permite manipular y devolver el valor. Para acceder al valor del accesor, simplemente puedes acceder al atributo `first_name` en una instancia de modelo:

    use App\Models\User;

    $user = User::find(1);

    $firstName = $user->first_name;

> [!NOTE]  
> Si deseas que estos valores computados se agreguen a las representaciones de array / JSON de tu modelo, [deberás agregarlos](/docs/{{version}}/eloquent-serialization#appending-values-to-json).

<a name="building-value-objects-from-multiple-attributes"></a>
#### Construyendo Objetos de Valor a Partir de Múltiples Atributos

A veces, tu accesor puede necesitar transformar múltiples atributos del modelo en un único "objeto de valor". Para hacerlo, tu función anónima `get` puede aceptar un segundo argumento de `$attributes`, que será suministrado automáticamente a la función anónima y contendrá un array de todos los atributos actuales del modelo:

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

Al devolver objetos de valor desde accesores, cualquier cambio realizado en el objeto de valor se sincronizará automáticamente de nuevo al modelo antes de que se guarde el modelo. Esto es posible porque Eloquent retiene instancias devueltas por accesores para que pueda devolver la misma instancia cada vez que se invoca el accesor:

    use App\Models\User;

    $user = User::find(1);

    $user->address->lineOne = 'Valor de Línea de Dirección Actualizada 1';
    $user->address->lineTwo = 'Valor de Línea de Dirección Actualizada 2';

    $user->save();

Sin embargo, a veces es posible que desees habilitar la caché para valores primitivos como cadenas y booleanos, particularmente si son computacionalmente intensivos. Para lograr esto, puedes invocar el método `shouldCache` al definir tu accesor:

```php
protected function hash(): Attribute
{
    return Attribute::make(
        get: fn (string $value) => bcrypt(gzuncompress($value)),
    )->shouldCache();
}
```

Si deseas deshabilitar el comportamiento de caché de objetos de los atributos, puedes invocar el método `withoutObjectCaching` al definir el atributo:

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

Un mutador transforma un valor de atributo de Eloquent cuando se establece. Para definir un mutador, puedes proporcionar el argumento `set` al definir tu atributo. Definamos un mutador para el atributo `first_name`. Este mutador será llamado automáticamente cuando intentemos establecer el valor del atributo `first_name` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Casts\Attribute;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Interactuar con el primer nombre del usuario.
         */
        protected function firstName(): Attribute
        {
            return Attribute::make(
                get: fn (string $value) => ucfirst($value),
                set: fn (string $value) => strtolower($value),
            );
        }
    }

La función anónima del mutador recibirá el valor que se está estableciendo en el atributo, lo que te permitirá manipular el valor y devolver el valor manipulado. Para usar nuestro mutador, solo necesitamos establecer el atributo `first_name` en un modelo Eloquent:

    use App\Models\User;

    $user = User::find(1);

    $user->first_name = 'Sally';

En este ejemplo, la función de retorno `set` será llamada con el valor `Sally`. El mutador luego aplicará la función `strtolower` al nombre y establecerá su valor resultante en el array interno `$attributes` del modelo.

<a name="mutating-multiple-attributes"></a>
#### Mutando Múltiples Atributos

A veces, tu mutador puede necesitar establecer múltiples atributos en el modelo subyacente. Para hacerlo, puedes devolver un array desde la función anónima `set`. Cada clave en el array debe corresponder a un atributo subyacente / columna de base de datos asociada con el modelo:

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
## Casting de Atributos

El casting de atributos proporciona funcionalidad similar a los accesores y mutadores sin requerir que definas métodos adicionales en tu modelo. En su lugar, el método `casts` de tu modelo proporciona una forma conveniente de convertir atributos a tipos de datos comunes.

El método `casts` debe devolver un array donde la clave es el nombre del atributo que se va a castar y el valor es el tipo al que deseas castar la columna. Los tipos de cast soportados son:

<div class="content-list" markdown="1">

- `array`
- `AsStringable::class`
- `boolean`
- `collection`
- `date`
- `datetime`
- `immutable_date`
- `immutable_datetime`
- <code>decimal:&lt;precision&gt;</code>
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

Para demostrar el casting de atributos, vamos a castar el atributo `is_admin`, que se almacena en nuestra base de datos como un entero (`0` o `1`) a un valor booleano:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Obtener los atributos que deben ser casteados.
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

Después de definir el cast, el atributo `is_admin` siempre será casteado a un booleano cuando lo accedas, incluso si el valor subyacente se almacena en la base de datos como un entero:

    $user = App\Models\User::find(1);

    if ($user->is_admin) {
        // ...
    }

Si necesitas agregar un nuevo cast temporal en tiempo de ejecución, puedes usar el método `mergeCasts`. Estas definiciones de cast se agregarán a cualquiera de los casts ya definidos en el modelo:

    $user->mergeCasts([
        'is_admin' => 'integer',
        'options' => 'object',
    ]);

> [!WARNING]  
> Los atributos que son `null` no serán casteados. Además, nunca debes definir un cast (o un atributo) que tenga el mismo nombre que una relación o asignar un cast a la clave primaria del modelo.

<a name="stringable-casting"></a>
#### Casting Stringable

Puedes usar la clase de cast `Illuminate\Database\Eloquent\Casts\AsStringable` para castar un atributo de modelo a un [objeto `Illuminate\Support\Stringable` fluido](/docs/{{version}}/strings#fluent-strings-method-list):

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Casts\AsStringable;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Obtener los atributos que deben ser casteados.
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

<a name="array-and-json-casting"></a>
### Casting de Array y JSON

El cast `array` es particularmente útil cuando se trabaja con columnas que se almacenan como JSON serializado. Por ejemplo, si tu base de datos tiene un tipo de campo `JSON` o `TEXT` que contiene JSON serializado, agregar el cast `array` a ese atributo deserializará automáticamente el atributo a un array de PHP cuando lo accedas en tu modelo Eloquent:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Obtener los atributos que deben ser casteados.
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

Una vez que el cast está definido, puedes acceder al atributo `options` y se deserializará automáticamente de JSON a un array de PHP. Cuando establezcas el valor del atributo `options`, el array dado se serializará automáticamente de nuevo a JSON para su almacenamiento:

    use App\Models\User;

    $user = User::find(1);

    $options = $user->options;

    $options['key'] = 'value';

    $user->options = $options;

    $user->save();

Para actualizar un solo campo de un atributo JSON con una sintaxis más concisa, puedes [hacer que el atributo sea asignable en masa](/docs/{{version}}/eloquent#mass-assignment-json-columns) y usar el operador `->` al llamar al método `update`:

    $user = User::find(1);

    $user->update(['options->key' => 'value']);

<a name="array-object-and-collection-casting"></a>
#### Casting de Objeto Array y Colección

Aunque el cast estándar `array` es suficiente para muchas aplicaciones, tiene algunas desventajas. Dado que el cast `array` devuelve un tipo primitivo, no es posible mutar un offset del array directamente. Por ejemplo, el siguiente código provocará un error de PHP:

    $user = User::find(1);

    $user->options['key'] = $value;

Para resolver esto, Laravel ofrece un cast `AsArrayObject` que convierte tu atributo JSON en una clase [ArrayObject](https://www.php.net/manual/en/class.arrayobject.php). Esta característica se implementa utilizando la implementación de [cast personalizado](#custom-casts) de Laravel, que permite a Laravel almacenar en caché y transformar inteligentemente el objeto mutado de tal manera que los offsets individuales puedan ser modificados sin provocar un error de PHP. Para usar el cast `AsArrayObject`, simplemente asígnalo a un atributo:

    use Illuminate\Database\Eloquent\Casts\AsArrayObject;

    /**
     * Obtener los atributos que deben ser casteados.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'options' => AsArrayObject::class,
        ];
    }

De manera similar, Laravel ofrece un cast `AsCollection` que convierte tu atributo JSON en una instancia de [Collection](/docs/{{version}}/collections) de Laravel:

    use Illuminate\Database\Eloquent\Casts\AsCollection;

    /**
     * Obtener los atributos que deben ser casteados.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'options' => AsCollection::class,
        ];
    }

Si deseas que el cast `AsCollection` instancie una clase de colección personalizada en lugar de la clase de colección base de Laravel, puedes proporcionar el nombre de la clase de colección como un argumento de cast:

    use App\Collections\OptionCollection;
    use Illuminate\Database\Eloquent\Casts\AsCollection;

    /**
     * Obtener los atributos que deben ser casteados.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'options' => AsCollection::using(OptionCollection::class),
        ];
    }

<a name="date-casting"></a>
### Casting de Fecha

Por defecto, Eloquent convertirá las columnas `created_at` y `updated_at` en instancias de [Carbon](https://github.com/briannesbitt/Carbon), que extiende la clase PHP `DateTime` y proporciona una variedad de métodos útiles. Puedes castar atributos de fecha adicionales definiendo casts de fecha adicionales dentro del método `casts` de tu modelo. Típicamente, las fechas deben ser casteadas usando los tipos de cast `datetime` o `immutable_datetime`.

Al definir un cast `date` o `datetime`, también puedes especificar el formato de la fecha. Este formato se utilizará cuando el [modelo se serialice a un array o JSON](/docs/{{version}}/eloquent-serialization):

    /**
     * Obtener los atributos que deben ser casteados.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'created_at' => 'datetime:Y-m-d',
        ];
    }

Cuando una columna se convierte en una fecha, puedes establecer el valor correspondiente del atributo del modelo a un timestamp UNIX, cadena de fecha (`Y-m-d`), cadena de fecha-hora, o una instancia de `DateTime` / `Carbon`. El valor de la fecha se convertirá y almacenará correctamente en tu base de datos.

Puedes personalizar el formato de serialización predeterminado para todas las fechas de tu modelo definiendo un método `serializeDate` en tu modelo. Este método no afecta cómo se formatean tus fechas para el almacenamiento en la base de datos:

    /**
     * Preparar una fecha para la serialización a array / JSON.
     */
    protected function serializeDate(DateTimeInterface $date): string
    {
        return $date->format('Y-m-d');
    }

Para especificar el formato que se debe utilizar al almacenar realmente las fechas de un modelo dentro de tu base de datos, debes definir una propiedad `$dateFormat` en tu modelo:

    /**
     * El formato de almacenamiento de las columnas de fecha del modelo.
     *
     * @var string
     */
    protected $dateFormat = 'U';

<a name="date-casting-and-timezones"></a>
#### Casting de Fecha, Serialización y Zonas Horarias

Por defecto, los casts `date` y `datetime` serializarán las fechas a una cadena de fecha ISO-8601 UTC (`YYYY-MM-DDTHH:MM:SS.uuuuuuZ`), independientemente de la zona horaria especificada en la opción de configuración `timezone` de tu aplicación. Se te recomienda encarecidamente que siempre uses este formato de serialización, así como almacenar las fechas de tu aplicación en la zona horaria UTC al no cambiar la opción de configuración `timezone` de tu aplicación de su valor predeterminado `UTC`. Usar consistentemente la zona horaria UTC en toda tu aplicación proporcionará el máximo nivel de interoperabilidad con otras bibliotecas de manipulación de fechas escritas en PHP y JavaScript.

Si se aplica un formato personalizado al cast de `date` o `datetime`, como `datetime:Y-m-d H:i:s`, se utilizará la zona horaria interna de la instancia de Carbon durante la serialización de la fecha. Típicamente, esta será la zona horaria especificada en la opción de configuración `timezone` de tu aplicación.

<a name="enum-casting"></a>
### Casting de Enum

Eloquent también te permite convertir los valores de tus atributos a [Enums](https://www.php.net/manual/en/language.enumerations.backed.php) de PHP. Para lograr esto, puedes especificar el atributo y el enum que deseas convertir en el método `casts` de tu modelo:

    use App\Enums\ServerStatus;

    /**
     * Obtener los atributos que deben ser convertidos.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => ServerStatus::class,
        ];
    }

Una vez que hayas definido el cast en tu modelo, el atributo especificado se convertirá automáticamente hacia y desde un enum cuando interactúes con el atributo:

    if ($server->status == ServerStatus::Provisioned) {
        $server->status = ServerStatus::Ready;

        $server->save();
    }

<a name="casting-arrays-of-enums"></a>
#### Casting de Arreglos de Enums

A veces, es posible que necesites que tu modelo almacene un arreglo de valores de enum dentro de una sola columna. Para lograr esto, puedes utilizar los casts `AsEnumArrayObject` o `AsEnumCollection` proporcionados por Laravel:

    use App\Enums\ServerStatus;
    use Illuminate\Database\Eloquent\Casts\AsEnumCollection;

    /**
     * Obtener los atributos que deben ser convertidos.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'statuses' => AsEnumCollection::of(ServerStatus::class),
        ];
    }

<a name="encrypted-casting"></a>
### Casting Encriptado

El cast `encrypted` encriptará el valor del atributo de un modelo utilizando las características de [encriptación](/docs/{{version}}/encryption) integradas de Laravel. Además, los casts `encrypted:array`, `encrypted:collection`, `encrypted:object`, `AsEncryptedArrayObject` y `AsEncryptedCollection` funcionan como sus contrapartes no encriptadas; sin embargo, como puedes esperar, el valor subyacente está encriptado cuando se almacena en tu base de datos.

Dado que la longitud final del texto encriptado no es predecible y es más larga que su contraparte en texto plano, asegúrate de que la columna de base de datos asociada sea de tipo `TEXT` o mayor. Además, dado que los valores están encriptados en la base de datos, no podrás consultar o buscar valores de atributos encriptados.

<a name="key-rotation"></a>
#### Rotación de Claves

Como sabes, Laravel encripta cadenas utilizando el valor de configuración `key` especificado en el archivo de configuración `app` de tu aplicación. Típicamente, este valor corresponde al valor de la variable de entorno `APP_KEY`. Si necesitas rotar la clave de encriptación de tu aplicación, deberás re-encriptar manualmente tus atributos encriptados utilizando la nueva clave.

<a name="query-time-casting"></a>
### Casting de Tiempo de Consulta

A veces, es posible que necesites aplicar casts mientras ejecutas una consulta, como al seleccionar un valor bruto de una tabla. Por ejemplo, considera la siguiente consulta:

    use App\Models\Post;
    use App\Models\User;

    $users = User::select([
        'users.*',
        'last_posted_at' => Post::selectRaw('MAX(created_at)')
                ->whereColumn('user_id', 'users.id')
    ])->get();

El atributo `last_posted_at` en los resultados de esta consulta será una simple cadena. Sería maravilloso si pudiéramos aplicar un cast de `datetime` a este atributo al ejecutar la consulta. Afortunadamente, podemos lograr esto utilizando el método `withCasts`:

    $users = User::select([
        'users.*',
        'last_posted_at' => Post::selectRaw('MAX(created_at)')
                ->whereColumn('user_id', 'users.id')
    ])->withCasts([
        'last_posted_at' => 'datetime'
    ])->get();

<a name="custom-casts"></a>
## Casts Personalizados

Laravel tiene una variedad de tipos de cast integrados y útiles; sin embargo, ocasionalmente es posible que necesites definir tus propios tipos de cast. Para crear un cast, ejecuta el comando Artisan `make:cast`. La nueva clase de cast se colocará en tu directorio `app/Casts`:

```shell
php artisan make:cast Json
```

Todas las clases de cast personalizadas implementan la interfaz `CastsAttributes`. Las clases que implementan esta interfaz deben definir un método `get` y un método `set`. El método `get` es responsable de transformar un valor bruto de la base de datos en un valor convertido, mientras que el método `set` debe transformar un valor convertido en un valor bruto que se puede almacenar en la base de datos. Como ejemplo, volveremos a implementar el tipo de cast `json` integrado como un tipo de cast personalizado:

    <?php

    namespace App\Casts;

    use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
    use Illuminate\Database\Eloquent\Model;

    class Json implements CastsAttributes
    {
        /**
         * Convertir el valor dado.
         *
         * @param  array<string, mixed>  $attributes
         * @return array<string, mixed>
         */
        public function get(Model $model, string $key, mixed $value, array $attributes): array
        {
            return json_decode($value, true);
        }

        /**
         * Preparar el valor dado para almacenamiento.
         *
         * @param  array<string, mixed>  $attributes
         */
        public function set(Model $model, string $key, mixed $value, array $attributes): string
        {
            return json_encode($value);
        }
    }

Una vez que hayas definido un tipo de cast personalizado, puedes adjuntarlo a un atributo del modelo utilizando su nombre de clase:

    <?php

    namespace App\Models;

    use App\Casts\Json;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Obtener los atributos que deben ser convertidos.
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

<a name="value-object-casting"></a>
### Casting de Objetos de Valor

No estás limitado a convertir valores a tipos primitivos. También puedes convertir valores a objetos. Definir casts personalizados que conviertan valores a objetos es muy similar a convertir a tipos primitivos; sin embargo, el método `set` debe devolver un arreglo de pares clave/valor que se utilizarán para establecer valores brutos y almacenables en el modelo.

Como ejemplo, definiremos una clase de cast personalizada que convierte múltiples valores del modelo en un único objeto de valor `Address`. Supondremos que el objeto de valor `Address` tiene dos propiedades públicas: `lineOne` y `lineTwo`:

    <?php

    namespace App\Casts;

    use App\ValueObjects\Address as AddressValueObject;
    use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
    use Illuminate\Database\Eloquent\Model;
    use InvalidArgumentException;

    class Address implements CastsAttributes
    {
        /**
         * Convertir el valor dado.
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
         * Preparar el valor dado para almacenamiento.
         *
         * @param  array<string, mixed>  $attributes
         * @return array<string, string>
         */
        public function set(Model $model, string $key, mixed $value, array $attributes): array
        {
            if (! $value instanceof AddressValueObject) {
                throw new InvalidArgumentException('El valor dado no es una instancia de Address.');
            }

            return [
                'address_line_one' => $value->lineOne,
                'address_line_two' => $value->lineTwo,
            ];
        }
    }

Al convertir a objetos de valor, cualquier cambio realizado en el objeto de valor se sincronizará automáticamente de nuevo en el modelo antes de que se guarde el modelo:

    use App\Models\User;

    $user = User::find(1);

    $user->address->lineOne = 'Valor de Dirección Actualizado';

    $user->save();

> [!NOTE]  
> Si planeas serializar tus modelos Eloquent que contienen objetos de valor a JSON o arreglos, debes implementar las interfaces `Illuminate\Contracts\Support\Arrayable` y `JsonSerializable` en el objeto de valor.

<a name="value-object-caching"></a>
#### Caché de Objetos de Valor

Cuando se resuelven atributos que están convertidos a objetos de valor, son almacenados en caché por Eloquent. Por lo tanto, se devolverá la misma instancia de objeto si se accede al atributo nuevamente.

Si deseas deshabilitar el comportamiento de caché de objetos de las clases de cast personalizadas, puedes declarar una propiedad pública `withoutObjectCaching` en tu clase de cast personalizada:

```php
class Address implements CastsAttributes
{
    public bool $withoutObjectCaching = true;

    // ...
}
```

<a name="array-json-serialization"></a>
### Serialización de Arreglos / JSON

Cuando un modelo Eloquent se convierte en un arreglo o JSON utilizando los métodos `toArray` y `toJson`, tus objetos de valor de cast personalizados generalmente se serializarán siempre que implementen las interfaces `Illuminate\Contracts\Support\Arrayable` y `JsonSerializable`. Sin embargo, al usar objetos de valor proporcionados por bibliotecas de terceros, es posible que no tengas la capacidad de agregar estas interfaces al objeto.

Por lo tanto, puedes especificar que tu clase de cast personalizada será responsable de serializar el objeto de valor. Para hacerlo, tu clase de cast personalizada debe implementar la interfaz `Illuminate\Contracts\Database\Eloquent\SerializesCastableAttributes`. Esta interfaz establece que tu clase debe contener un método `serialize` que debe devolver la forma serializada de tu objeto de valor:

    /**
     * Obtener la representación serializada del valor.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function serialize(Model $model, string $key, mixed $value, array $attributes): string
    {
        return (string) $value;
    }

<a name="inbound-casting"></a>
### Casting de Entrada

Ocasionalmente, es posible que necesites escribir una clase de cast personalizada que solo transforme los valores que se están estableciendo en el modelo y no realice ninguna operación cuando se recuperan atributos del modelo.

Los casts personalizados solo de entrada deben implementar la interfaz `CastsInboundAttributes`, que solo requiere que se defina un método `set`. El comando Artisan `make:cast` puede invocarse con la opción `--inbound` para generar una clase de cast solo de entrada:

```shell
php artisan make:cast Hash --inbound
```

Un ejemplo clásico de un cast solo de entrada es un cast de "hashing". Por ejemplo, podemos definir un cast que hashea los valores de entrada a través de un algoritmo dado:

    <?php

    namespace App\Casts;

    use Illuminate\Contracts\Database\Eloquent\CastsInboundAttributes;
    use Illuminate\Database\Eloquent\Model;

    class Hash implements CastsInboundAttributes
    {
        /**
         * Crear una nueva instancia de clase de cast.
         */
        public function __construct(
            protected string|null $algorithm = null,
        ) {}

        /**
         * Preparar el valor dado para almacenamiento.
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

<a name="cast-parameters"></a>
### Parámetros de Cast

Al adjuntar un cast personalizado a un modelo, se pueden especificar parámetros de cast separándolos del nombre de la clase utilizando un carácter `:` y delimitando múltiples parámetros con comas. Los parámetros se pasarán al constructor de la clase de cast:

    /**
     * Obtener los atributos que deben ser convertidos.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'secret' => Hash::class.':sha256',
        ];
    }

<a name="castables"></a>
### Castables

Es posible que desees permitir que los objetos de valor de tu aplicación definan sus propias clases de cast personalizadas. En lugar de adjuntar la clase de cast personalizada a tu modelo, puedes adjuntar una clase de objeto de valor que implemente la interfaz `Illuminate\Contracts\Database\Eloquent\Castable`:

    use App\ValueObjects\Address;

    protected function casts(): array
    {
        return [
            'address' => Address::class,
        ];
    }

Los objetos que implementan la interfaz `Castable` deben definir un método `castUsing` que devuelva el nombre de la clase de caster personalizada que es responsable de convertir hacia y desde la clase `Castable`:

    <?php

    namespace App\ValueObjects;

    use Illuminate\Contracts\Database\Eloquent\Castable;
    use App\Casts\Address as AddressCast;

    class Address implements Castable
    {
        /**
         * Obtener el nombre de la clase de caster que se utilizará al convertir desde/hacia este objetivo de cast.
         *
         * @param  array<string, mixed>  $arguments
         */
        public static function castUsing(array $arguments): string
        {
            return AddressCast::class;
        }
    }

Al usar clases `Castable`, aún puedes proporcionar argumentos en la definición del método `casts`. Los argumentos se pasarán al método `castUsing`:

    use App\ValueObjects\Address;

    protected function casts(): array
    {
        return [
            'address' => Address::class.':argument',
        ];
    }

<a name="anonymous-cast-classes"></a>
#### Castables y Clases de Cast Anónimas

Al combinar "castables" con las [clases anónimas](https://www.php.net/manual/en/language.oop5.anonymous.php) de PHP, puedes definir un objeto de valor y su lógica de casting como un solo objeto castable. Para lograr esto, devuelve una clase anónima desde el método `castUsing` de tu objeto de valor. La clase anónima debe implementar la interfaz `CastsAttributes`:

    <?php

    namespace App\ValueObjects;

    use Illuminate\Contracts\Database\Eloquent\Castable;
    use Illuminate\Contracts\Database\Eloquent\CastsAttributes;

    class Address implements Castable
    {
        // ...

        /**
         * Obtener la clase caster que se utilizará al convertir desde/hacia este objetivo de cast.
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
