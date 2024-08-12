# Eloquent: Mutadores y Casting

- [Introducción](#introduction)
- [Accesores y Mutadores](#accessors-and-`mutator`s)
  - [Definición de un `accessor`](#defining-an-accessor)
  - [Definición de un `mutator`](#defining-a-mutator)
- [Atributo Casting](#attribute-casting)
  - [Casting de array y JSON](#array-and-json-casting)
  - [Casting de fechas](#date-casting)
  - [Casting de Enum](#enum-casting)
  - [Casting cifrado](#encrypted-casting)
  - [Casting en tiempo de consulta](#query-time-casting)
- [Conversiones personalizadas](#custom-casts)
  - [Conversión de objetos de valor](#value-object-casting)
  - [array-json-serialization">Serializaciónarray / JSON](<#\<glossary variable=>)
  - [Conversión entrante](#inbound-casting)
  - [Parámetros de conversión](#cast-parameters)
  - [Castables](#castables)

<a name="introduction"></a>
## Introducción

Los `accessors`, `mutators` y `attribute casting` te permiten transformar los valores de los atributos de Eloquent cuando los recuperas o los estableces en las instancias del modelo. Por ejemplo, es posible que desees utilizar el [cifrador de Laravel](/docs/{{version}}/encryption) para cifrar un valor mientras se almacena en la base de datos y, a continuación, descifrar automáticamente el atributo cuando accedas a él en un modelo Eloquent. O bien, es posible que desee convertir una cadena JSON que se almacena en la base de datos a una array cuando se accede a través de su modelo Eloquent.

<a name="accessors-and-mutators"></a>
## Accessors y Mutators

<a name="defining-an-accessor"></a>
### Definición de un Accessor

Un accessor transforma un valor de atributo Eloquent cuando se accede a él. Para definir un accessor, crea un método protegido en tu modelo para representar el atributo accesible. Este nombre de método debe corresponder a la representación "camel case" del verdadero atributo subyacente del modelo / columna de la base de datos cuando sea aplicable.

En este ejemplo, definiremos un `accessor` para el atributo `first_name`. Eloquent llamará automáticamente al `accessor` cuando se intente recuperar el valor del atributo `first_name`. Todos los métodos `accessor` / `mutator` de atributos deben declarar un type-hint de retorno `Illuminate\Database\Eloquent\Casts\Attribute`:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Casts\Attribute;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Get the user's first name.
         *
         * @return \Illuminate\Database\Eloquent\Casts\Attribute
         */
        protected function firstName(): Attribute
        {
            return Attribute::make(
                get: fn ($value) => ucfirst($value),
            );
        }
    }

Todos los métodos `accessors` devuelven una instancia de `Attribute` que define cómo se accederá al atributo y, opcionalmente, cómo se mutará. En este ejemplo, sólo estamos definiendo cómo se accederá al atributo. Para ello, proporcionamos el argumento `get` al constructor de la clase `Attribute`.

Como puedes ver, el valor original de la columna se pasa al `accessor`, permitiendo manipular y devolver el valor. Para acceder al valor del `accessor`, basta con acceder al atributo `first_name` de una instancia del modelo:

    use App\Models\User;

    $user = User::find(1);

    $firstName = $user->first_name;

> **Nota**  
> Si desea que estos valores calculados se añadan a las representaciones de array / JSON de su modelo, [tendrá que añadirlos](/docs/{{version}}/eloquent-serialization#appending-values-to-json).

<a name="building-value-objects-from-multiple-attributes"></a>
#### Creación de Value Objects a partir de múltiples atributos

En ocasiones, es posible que el `accessor` deba transformar varios atributos del modelo en un único "Value Objects". Para ello, el closure `get` puede aceptar un segundo argumento `$attributes`, que se suministrará automáticamente al closure y contendrá el array de todos los atributos actuales del modelo:

```php
use App\Support\Address;
use Illuminate\Database\Eloquent\Casts\Attribute;

/**
 * Interact with the user's address.
 *
 * @return  \Illuminate\Database\Eloquent\Casts\Attribute
 */
protected function address(): Attribute
{
    return Attribute::make(
        get: fn ($value, $attributes) => new Address(
            $attributes['address_line_one'],
            $attributes['address_line_two'],
        ),
    );
}
```

<a name="accessor-caching"></a>
#### Almacenamiento en caché del `accessor`

Cuando se devuelven objetos de valor desde `accessor`, cualquier cambio realizado en el objeto de valor se sincronizará automáticamente con el modelo antes de que éste se guarde. Esto es posible porque Eloquent retiene las instancias devueltas por los `accessors` para que pueda devolver la misma instancia cada vez que se invoque al `accessor`:

    use App\Models\User;

    $user = User::find(1);

    $user->address->lineOne = 'Updated Address Line 1 Value';
    $user->address->lineTwo = 'Updated Address Line 2 Value';

    $user->save();

Sin embargo, puede que a veces desees habilitar el almacenamiento en caché para valores primitivos como cadenas y booleanos, particularmente si son computacionalmente intensos. Para conseguirlo, puedes invocar el método `shouldCache` al definir tu accessor:

```php
protected function hash(): Attribute
{
    return Attribute::make(
        get: fn ($value) => bcrypt(gzuncompress($value)),
    )->shouldCache();
}
```

Si desea desactivar el comportamiento de caché de objetos de los atributos, puede invocar el método `withoutObjectCaching` al definir el atributo:

```php
/**
 * Interact with the user's address.
 *
 * @return  \Illuminate\Database\Eloquent\Casts\Attribute
 */
protected function address(): Attribute
{
    return Attribute::make(
        get: fn ($value, $attributes) => new Address(
            $attributes['address_line_one'],
            $attributes['address_line_two'],
        ),
    )->withoutObjectCaching();
}
```

<a name="defining-a-mutator"></a>
### Definición de un `mutator`

Un `mutator` transforma el valor de un atributo Eloquent cuando se establece. Para definir un `mutator`, puedes proporcionar el argumento `set` al definir tu atributo. Definamos un `mutator` para el atributo `first_name`. Este `mutator` será llamado automáticamente cuando intentemos establecer el valor del atributo `first_name` en el modelo:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Casts\Attribute;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * Interact with the user's first name.
         *
         * @return \Illuminate\Database\Eloquent\Casts\Attribute
         */
        protected function firstName(): Attribute
        {
            return Attribute::make(
                get: fn ($value) => ucfirst($value),
                set: fn ($value) => strtolower($value),
            );
        }
    }

El `mutator` closure recibirá el valor que se está estableciendo en el atributo, lo que le permite manipular el valor y devolver el valor manipulado. Para utilizar nuestro `mutator`, sólo tenemos que establecer el atributo `first_name` en un modelo Eloquent:

    use App\Models\User;

    $user = User::find(1);

    $user->first_name = 'Sally';

En este ejemplo, el callback `set` será llamado con el valor `Sally`. A continuación, el `mutator` aplicará la función `strtolower` al nombre y establecerá el valor resultante en la array interna `$attributes` del modelo.

<a name="mutating-multiple-attributes"></a>
#### Mutar múltiples atributos

A veces el `mutator` puede necesitar establecer múltiples atributos en el modelo subyacente. Para ello, puede devolver un array desde el closure `set`. Cada clave de la array debe corresponderse con un atributo subyacente / columna de base de datos asociada con el modelo:

```php
use App\Support\Address;
use Illuminate\Database\Eloquent\Casts\Attribute;

/**
 * Interact with the user's address.
 *
 * @return  \Illuminate\Database\Eloquent\Casts\Attribute
 */
protected function address(): Attribute
{
    return Attribute::make(
        get: fn ($value, $attributes) => new Address(
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

El casting de atributos proporciona una funcionalidad similar a la de los `accessors` y `mutators` sin necesidad de definir métodos adicionales en el modelo. En su lugar, la propiedad `$casts` de tu modelo proporciona un método para convertir atributos a tipos de datos comunes.

La propiedad `$casts` debe ser un array en el que la clave es el nombre del atributo a convertir y el valor es el tipo al que se desea convertir la columna. Los tipos de conversión soportados son

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
- `integer`
- `object`
- `real`
- `string`
- `timestamp`

</div>

Para demostrar la conversión de atributos, vamos a convertir el atributo `is_admin`, que se almacena en nuestra base de datos como un entero`(0` o `1`), en un valor booleano:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The attributes that should be cast.
         *
         * @var array
         */
        protected $casts = [
            'is_admin' => 'boolean',
        ];
    }

Después de definir la conversión, el atributo `is_admin` siempre se convertirá en booleano cuando acceda a él, incluso si el valor subyacente se almacena en la base de datos como un número entero:

    $user = App\Models\User::find(1);

    if ($user->is_admin) {
        //
    }

Si necesita añadir un nuevo cast temporal en tiempo de ejecución, puede utilizar el método `mergeCasts`. Estas definiciones de cast se añadirán a cualquiera de los cast ya definidos en el modelo:

    $user->mergeCasts([
        'is_admin' => 'integer',
        'options' => 'object',
    ]);

> **Advertencia**  
> Los atributos `null` no serán transformados. Además, nunca debes definir un cast (o un atributo) que tenga el mismo nombre que una relación.

<a name="stringable-casting"></a>
#### Casting de cadenas

Puedes usar la clase `Illuminate\Database\Eloquent\Casts\AsStringable` para castear un atributo del modelo a un [objeto fluent `Illuminate\Support\Stringable`](/docs/{{version}}/helpers#fluent-strings-method-list):

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Casts\AsStringable;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The attributes that should be cast.
         *
         * @var array
         */
        protected $casts = [
            'directory' => AsStringable::class,
        ];
    }

<a name="array-and-json-casting"></a>
### Casting de array y JSON

El cast de `array` es especialmente útil cuando se trabaja con columnas que se almacenan como JSON serializado. Por ejemplo, si su base de datos tiene un tipo de campo `JSON` o `TEXT` que contiene un JSON serializado, añadir el cast de `array` a ese atributo deserializará automáticamente el atributo a un array PHP cuando acceda a él en su modelo Eloquent:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The attributes that should be cast.
         *
         * @var array
         */
        protected $casts = [
            'options' => 'array',
        ];
    }

Una vez definido el cast, puedes acceder al atributo `options` y automáticamente será deserializado de JSON a un array PHP. Cuando establezcas el valor del atributo `options`, el array dado será automáticamente serializado de nuevo a JSON para su almacenamiento:

    use App\Models\User;

    $user = User::find(1);

    $options = $user->options;

    $options['key'] = 'value';

    $user->options = $options;

    $user->save();

Para actualizar un solo campo de un atributo JSON con una sintaxis más breve, puede usar el operador `->` cuando llame al método `update`:

    $user = User::find(1);

    $user->update(['options->key' => 'value']);

<a name="array-object-and-collection-casting"></a>
#### Casting de Array Object & Collection 

Aunque la conversión estándar de `array` es suficiente para muchas aplicaciones, tiene algunas desventajas. Dado que el `array` cast devuelve un tipo primitivo, no es posible mutar un offset del array directamente. Por ejemplo, el siguiente código provocará un error PHP:

    $user = User::find(1);

    $user->options['key'] = $value;

Para resolver esto, Laravel ofrece un cast `AsArrayObject` que transforma su atributo JSON a una clase [ArrayObject](https://www.php.net/manual/en/class.arrayobject.php). Esta característica se implementa utilizando la implementación [personalizada](#custom-casts) de Laravel, que permite a Laravel cachear de forma inteligente y transformar el objeto mutado de tal manera que los desplazamientos individuales pueden ser modificados sin desencadenar un error de PHP. Para utilizar `AsArrayObject`, basta con asignarlo a un atributo:

    use Illuminate\Database\Eloquent\Casts\AsArrayObject;

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'options' => AsArrayObject::class,
    ];

Del mismo modo, Laravel ofrece una función `AsCollection` que convierte el atributo JSON en una instancia de Laravel [Collection](/docs/{{version}}/collections):

    use Illuminate\Database\Eloquent\Casts\AsCollection;

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'options' => AsCollection::class,
    ];

<a name="date-casting"></a>
### Casting de fechas

Por defecto, Eloquent convierte las columnas `created_at` y `updated_at` en instancias de [Carbon](https://github.com/briannesbitt/Carbon), que extiende la clase `DateTime` de PHP y proporciona una serie de métodos útiles. Puede convertir atributos de fecha adicionales definiendo conversiones de fecha adicionales en la array propiedades `$casts` de su modelo. Normalmente, las fechas deben ser convertidas utilizando los tipos `datetime` o `immutable_datetime`.

Cuando se define un cast `date` or `datetime`, también se puede especificar el formato de la fecha. Este formato se utilizará cuando el [modelo se serialice en una array o JSON](/docs/{{version}}/eloquent-serialization):

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'created_at' => 'datetime:Y-m-d',
    ];

Cuando una columna es moldeada como una fecha, puede establecer el valor del atributo del modelo correspondiente a una marca de tiempo UNIX, cadena de fecha (`Y-m-d`), cadena de fecha-hora, o una instancia `DateTime` / `Carbon`. El valor de la fecha se convertirá correctamente y se almacenará en su base de datos.

Puede personalizar el formato de serialización predeterminado para todas las fechas de su modelo definiendo un método `serializeDate` en su modelo. Este método no afecta a cómo se formatean las fechas para su almacenamiento en la base de datos:

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

Para especificar el formato que se debe utilizar cuando se almacenan las fechas de un modelo en la base de datos, debe definir una propiedad `$dateFormat` en el modelo:

    /**
     * The storage format of the model's date columns.
     *
     * @var string
     */
    protected $dateFormat = 'U';

<a name="date-casting-and-timezones"></a>
#### Asignación de fechas, serialización y zonas horarias

Por defecto, las conversiones `date` y `datetime` serializarán las fechas a una cadena de fecha UTC ISO-8601 (`1986-05-28T21:05:54.000000Z`), independientemente de la zona horaria especificada en la opción de configuración de `timezone` de su aplicación. Se recomienda encarecidamente utilizar siempre este formato de serialización, así como almacenar las fechas de la aplicación en la zona horaria UTC sin cambiar la opción de configuración de `timezone` de la aplicación de su valor `UTC` predeterminado. El uso consistente de la zona horaria UTC en toda la aplicación proporcionará el máximo nivel de interoperabilidad con otras bibliotecas de manipulación de fechas escritas en PHP y JavaScript.

Si se aplica un formato personalizado al `date` o al cast `datetime`, como `datetime:Y-m-d H:i:s`, se utilizará la zona horaria interna de la instancia Carbon durante la serialización de la fecha. Normalmente, será la zona horaria especificada en la opción de configuración de `timezone` de la aplicación.

<a name="enum-casting"></a>
### Casting de Enum

> **Advertencia**:  
> Enum casting sólo está disponible para PHP 8.1+.

Eloquent también permite convertir los valores de los atributos a [Enums de PHP](https://www.php.net/manual/en/language.enumerations.backed.php). Para ello, puede especificar el atributo y el enum que desea convertir en la propiedad `$casts` su modelo:

    use App\Enums\ServerStatus;

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'status' => ServerStatus::class,
    ];

Una vez que haya definido el cast en su modelo, el atributo especificado será automáticamente transformado a y desde un enum cuando interactúe con el atributo:

    if ($server->status == ServerStatus::Provisioned) {
        $server->status = ServerStatus::Ready;

        $server->save();
    }

<a name="encrypted-casting"></a>
### Casting cifrado

El cast `encrypted` encriptará el valor del atributo de un modelo usando las características de [encriptación](/docs/{{version}}/encryption) de Laravel. Además, los cast `encrypted:array`, `encrypted:collection`, `encrypted:object`, `AsEncryptedArrayObject` y `AsEncryptedCollection`  funcionan como sus homólogos no encriptados; sin embargo, como es de esperar, el valor subyacente se encripta cuando se almacena en la base de datos.

Como la longitud final del texto encriptado no es predecible y es más largo que su contraparte de texto plano, asegúrese de que la columna de base de datos asociada es de tipo `TEXT` o mayor. Además, como los valores están encriptados en la base de datos, no podrá consultar o buscar valores de atributos encriptados.

<a name="key-rotation"></a>
#### Rotación de claves

Como ya sabrás, Laravel encripta cadenas utilizando el valor de configuración de `clave` especificado en el fichero de configuración de tu `aplicación`. Típicamente, este valor corresponde al valor de la variable de entorno `APP_KEY`. Si necesitas rotar la clave de encriptación de tu aplicación, necesitarás re-encriptar manualmente tus atributos encriptados usando la nueva clave.

<a name="query-time-casting"></a>
### Casting en tiempo de consulta

A veces puede que necesites aplicar cast mientras ejecutas una consulta, como cuando seleccionas un valor sin procesar de una tabla. Por ejemplo, considere la siguiente consulta:

    use App\Models\Post;
    use App\Models\User;

    $users = User::select([
        'users.*',
        'last_posted_at' => Post::selectRaw('MAX(created_at)')
                ->whereColumn('user_id', 'users.id')
    ])->get();

El atributo `last_posted_at` en los resultados de esta consulta será una cadena simple. Sería estupendo poder aplicar un cast `datetime` a este atributo al ejecutar la consulta. Afortunadamente, podemos conseguirlo utilizando el método `withCasts`:

    $users = User::select([
        'users.*',
        'last_posted_at' => Post::selectRaw('MAX(created_at)')
                ->whereColumn('user_id', 'users.id')
    ])->withCasts([
        'last_posted_at' => 'datetime'
    ])->get();

<a name="custom-casts"></a>
## Conversiones personalizadas

Laravel dispone de una gran variedad de tipos cast incorporados; sin embargo, puede que en ocasiones necesites definir tus propios tipos cast. Para crear un cast, ejecuta el comando `make:cast` Artisan. La nueva clase cast será colocada en tu directorio `app/Casts`:

```shell
php artisan make:cast Json
```

Todas las clases de cast personalizadas implementan la interfaz `CastsAttributes`. Las clases que implementan esta interfaz deben definir un método `get` y un método `set`. El método `get` es responsable de transformar un valor "crudo" procedente de la base de datos en un valor con el cast aplicado, mientras que el método `set` debe transformar un valor  con el cast aplicado en un valor "crudo" que pueda ser almacenado en la base de datos. Como ejemplo, reimplementaremos el tipo cast `json` incorporado como un tipo cast personalizado:

    <?php

    namespace App\Casts;

    use Illuminate\Contracts\Database\Eloquent\CastsAttributes;

    class Json implements CastsAttributes
    {
        /**
         * Cast the given value.
         *
         * @param  \Illuminate\Database\Eloquent\Model  $model
         * @param  string  $key
         * @param  mixed  $value
         * @param  array  $attributes
         * @return array
         */
        public function get($model, $key, $value, $attributes)
        {
            return json_decode($value, true);
        }

        /**
         * Prepare the given value for storage.
         *
         * @param  \Illuminate\Database\Eloquent\Model  $model
         * @param  string  $key
         * @param  array  $value
         * @param  array  $attributes
         * @return string
         */
        public function set($model, $key, $value, $attributes)
        {
            return json_encode($value);
        }
    }

Una vez definido un tipo cast personalizado, puede adjuntarlo a un atributo del modelo utilizando su nombre de clase:

    <?php

    namespace App\Models;

    use App\Casts\Json;
    use Illuminate\Database\Eloquent\Model;

    class User extends Model
    {
        /**
         * The attributes that should be cast.
         *
         * @var array
         */
        protected $casts = [
            'options' => Json::class,
        ];
    }

<a name="value-object-casting"></a>
### Conversión de Value Objects

No está limitado a convertir valores en tipos primitivos. También puede convertir valores en los objetos. La definición de conversiones personalizadas que convierten valores a objetos es muy similar a la conversión a tipos primitivos; sin embargo, el método `set` debe devolver un array de pares clave/valor que se usarán para establecer valores almacenables sin procesar en el modelo.

Como ejemplo, definiremos una clase de conversión personalizada que convierte múltiples valores del modelo en un único objeto de valor `Address`. Asumiremos que el valor `Address` tiene dos propiedades públicas: `lineOne` y `lineTwo`:

    <?php

    namespace App\Casts;

    use App\ValueObjects\Address as AddressValueObject;
    use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
    use InvalidArgumentException;

    class Address implements CastsAttributes
    {
        /**
         * Cast the given value.
         *
         * @param  \Illuminate\Database\Eloquent\Model  $model
         * @param  string  $key
         * @param  mixed  $value
         * @param  array  $attributes
         * @return \App\ValueObjects\Address
         */
        public function get($model, $key, $value, $attributes)
        {
            return new AddressValueObject(
                $attributes['address_line_one'],
                $attributes['address_line_two']
            );
        }

        /**
         * Prepare the given value for storage.
         *
         * @param  \Illuminate\Database\Eloquent\Model  $model
         * @param  string  $key
         * @param  \App\ValueObjects\Address  $value
         * @param  array  $attributes
         * @return array
         */
        public function set($model, $key, $value, $attributes)
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

Al convertir a "value objects", cualquier cambio realizado en el "value object" se sincronizará automáticamente con el modelo antes de que se guarde el modelo.:

    use App\Models\User;

    $user = User::find(1);

    $user->address->lineOne = 'Updated Address Value';

    $user->save();

> **Nota**  
> Si planea serializar sus modelos Eloquent que contienen value objects a JSON o arrays, debe implementar las interfaces `Illuminate\Contracts\Support\Arrayable` y `JsonSerializable` en el value object.

<a name="array-json-serialization"></a>
### Serializaciónarray / JSON

Cuando un modelo de Eloquent se convierte en un array o JSON utilizando los métodos `toArray` y `toJson`, sus `value objects` de conversión personalizados normalmente se serializarán siempre y cuando implementen las interfaces `Illuminate\Contracts\Support\Arrayable` y `JsonSerializable`. Sin embargo, al usar value objects proporcionados por bibliotecas de terceros, es posible que no pueda agregar estas interfaces al objeto.

Por lo tanto, puede especificar que su clase personalizada sea responsable de serializar el objeto de valor. Para ello, su clase de cast personalizada debe implementar la interfaz `Illuminate\Contracts\Database\Eloquent\SerializesCastableAttributes`. Esta interfaz establece que su clase debe contener un método de `serialización` que debe devolver la forma serializada de su objeto de valor:

    /**
     * Get the serialized representation of the value.
     *
     * @param  \Illuminate\Database\Eloquent\Model  $model
     * @param  string  $key
     * @param  mixed  $value
     * @param  array  $attributes
     * @return mixed
     */
    public function serialize($model, string $key, $value, array $attributes)
    {
        return (string) $value;
    }

<a name="inbound-casting"></a>
### Conversión entrante

Ocasionalmente, puede que necesites escribir una clase de conversión personalizada que sólo transforme los valores que se están estableciendo en el modelo y no realice ninguna operación cuando los atributos se están recuperando del modelo.

Los cast personalizados "sólo entrantes" deben implementar la interfaz `CastsInboundAttributes`, que sólo requiere que se defina un método `set`. El comando `make:cast` de Artisan puede ser invocado con la opción `--inbound` para generar una clase cast sólo de entrada:

```shell
php artisan make:cast Hash --inbound
```

Un ejemplo clásico de un cast sólo entrante es un cast "hashing". Por ejemplo, podemos definir un cast que aplique un hash los valores de entrada a través de un algoritmo dado:

    <?php

    namespace App\Casts;

    use Illuminate\Contracts\Database\Eloquent\CastsInboundAttributes;

    class Hash implements CastsInboundAttributes
    {
        /**
         * The hashing algorithm.
         *
         * @var string
         */
        protected $algorithm;

        /**
         * Create a new cast class instance.
         *
         * @param  string|null  $algorithm
         * @return void
         */
        public function __construct($algorithm = null)
        {
            $this->algorithm = $algorithm;
        }

        /**
         * Prepare the given value for storage.
         *
         * @param  \Illuminate\Database\Eloquent\Model  $model
         * @param  string  $key
         * @param  array  $value
         * @param  array  $attributes
         * @return string
         */
        public function set($model, $key, $value, $attributes)
        {
            return is_null($this->algorithm)
                        ? bcrypt($value)
                        : hash($this->algorithm, $value);
        }
    }

<a name="cast-parameters"></a>
### Parámetros de conversión

Cuando se adjunta un cast personalizado a un modelo, los parámetros del cast pueden especificarse separándolos del nombre de la clase utilizando un carácter `:` y delimitando con comas los parámetros múltiples. Los parámetros se pasarán al constructor de la clase cast:

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'secret' => Hash::class.':sha256',
    ];

<a name="castables"></a>
### Castables

Es posible que desee permitir que los objetos de valor de su aplicación definan sus propias clases cast personalizadas. En lugar de adjuntar la clase de cast personalizada a su modelo, puede adjuntar una clase de un value object que implemente la interfaz `Illuminate\Contracts\Database\Eloquent\Castable`:

    use App\Models\Address;

    protected $casts = [
        'address' => Address::class,
    ];

Los objetos que implementan la interfaz `Castable` deben definir un método `castUsing` que devuelva el nombre de clase de la clase del caster personalizado que es responsable del casting hacia y desde la clase `Castable`:

    <?php

    namespace App\Models;

    use Illuminate\Contracts\Database\Eloquent\Castable;
    use App\Casts\Address as AddressCast;

    class Address implements Castable
    {
        /**
         * Get the name of the caster class to use when casting from / to this cast target.
         *
         * @param  array  $arguments
         * @return string
         */
        public static function castUsing(array $arguments)
        {
            return AddressCast::class;
        }
    }

Cuando se utilizan clases `Castable`, aún se pueden proporcionar argumentos en la definición de `$casts`. Los argumentos serán pasados al método `castUsing`:

    use App\Models\Address;

    protected $casts = [
        'address' => Address::class.':argument',
    ];

<a name="anonymous-cast-classes"></a>
#### Castables y Clases Cast Anónimas

Combinando "castables" con las [clases anónimas](https://www.php.net/manual/en/language.oop5.anonymous.php) de PHP, puede definir un objeto de valor y su lógica de casteo como un único objeto castable. Para conseguir esto, devuelva una clase anónima desde el método `castUsing` de su objeto valor. La clase anónima debe implementar la interfaz `CastsAttributes`:

    <?php

    namespace App\Models;

    use Illuminate\Contracts\Database\Eloquent\Castable;
    use Illuminate\Contracts\Database\Eloquent\CastsAttributes;

    class Address implements Castable
    {
        // ...

        /**
         * Get the caster class to use when casting from / to this cast target.
         *
         * @param  array  $arguments
         * @return object|string
         */
        public static function castUsing(array $arguments)
        {
            return new class implements CastsAttributes
            {
                public function get($model, $key, $value, $attributes)
                {
                    return new Address(
                        $attributes['address_line_one'],
                        $attributes['address_line_two']
                    );
                }

                public function set($model, $key, $value, $attributes)
                {
                    return [
                        'address_line_one' => $value->lineOne,
                        'address_line_two' => $value->lineTwo,
                    ];
                }
            };
        }
    }
