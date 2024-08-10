# Eloquent: API Resources

- [Introducción](#introduction)
- [Generando Recursos](#generating-resources)
- [Descripción General del Concepto](#concept-overview)
    - [Colecciones de Recursos](#resource-collections)
- [Escribiendo Recursos](#writing-resources)
    - [Envoltura de Datos](#data-wrapping)
    - [Paginación](#pagination)
    - [Atributos Condicionales](#conditional-attributes)
    - [Relaciones Condicionales](#conditional-relationships)
    - [Añadiendo Metatatos](#adding-meta-data)
- [Respuestas de Recursos](#resource-responses)

<a name="introduction"></a>
## Introducción

Cuando construyes una API, es posible que necesites una capa de transformación que se sitúe entre tus modelos Eloquent y las respuestas JSON que realmente se devuelven a los usuarios de tu aplicación. Por ejemplo, es posible que desees mostrar ciertos atributos para un subconjunto de usuarios y no para otros, o que desees incluir siempre ciertas relaciones en la representación JSON de tus modelos. Las clases de recursos de Eloquent te permiten transformar de manera expresiva y sencilla tus modelos y colecciones de modelos en JSON.

Por supuesto, siempre puedes convertir modelos o colecciones Eloquent a JSON utilizando sus métodos `toJson`; sin embargo, los recursos Eloquent proporcionan un control más granular y robusto sobre la serialización JSON de tus modelos y sus relaciones.

<a name="generating-resources"></a>
## Generando Recursos

Para generar una clase de recurso, puedes usar el comando Artisan `make:resource`. Por defecto, los recursos se colocarán en el directorio `app/Http/Resources` de tu aplicación. Los recursos extienden la clase `Illuminate\Http\Resources\Json\JsonResource`:

```shell
php artisan make:resource UserResource
```

<a name="generating-resource-collections"></a>
#### Colecciones de Recursos

Además de generar recursos que transforman modelos individuales, puedes generar recursos que son responsables de transformar colecciones de modelos. Esto permite que tus respuestas JSON incluyan enlaces y otra información meta que es relevante para toda una colección de un recurso dado.

Para crear una colección de recursos, debes usar la bandera `--collection` al crear el recurso. O, incluir la palabra `Collection` en el nombre del recurso indicará a Laravel que debe crear un recurso de colección. Los recursos de colección extienden la clase `Illuminate\Http\Resources\Json\ResourceCollection`:

```shell
php artisan make:resource User --collection

php artisan make:resource UserCollection
```

<a name="concept-overview"></a>
## Descripción General del Concepto

> [!NOTE]  
> Esta es una descripción general de alto nivel de los recursos y colecciones de recursos. Se te anima encarecidamente a leer las otras secciones de esta documentación para obtener una comprensión más profunda de la personalización y el poder que te ofrecen los recursos.

Antes de sumergirnos en todas las opciones disponibles para ti al escribir recursos, primero echemos un vistazo de alto nivel a cómo se utilizan los recursos dentro de Laravel. Una clase de recurso representa un solo modelo que necesita ser transformado en una estructura JSON. Por ejemplo, aquí hay una simple clase de recurso `UserResource`:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Request;
    use Illuminate\Http\Resources\Json\JsonResource;

    class UserResource extends JsonResource
    {
        /**
         * Transformar el recurso en un array.
         *
         * @return array<string, mixed>
         */
        public function toArray(Request $request): array
        {
            return [
                'id' => $this->id,
                'name' => $this->name,
                'email' => $this->email,
                'created_at' => $this->created_at,
                'updated_at' => $this->updated_at,
            ];
        }
    }

Cada clase de recurso define un método `toArray` que devuelve el array de atributos que deben ser convertidos a JSON cuando el recurso se devuelve como respuesta de una ruta o método de controlador.

Ten en cuenta que podemos acceder a las propiedades del modelo directamente desde la variable `$this`. Esto se debe a que una clase de recurso automáticamente proxy el acceso a propiedades y métodos hacia el modelo subyacente para un acceso conveniente. Una vez que el recurso está definido, puede ser devuelto desde una ruta o controlador. El recurso acepta la instancia del modelo subyacente a través de su constructor:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/user/{id}', function (string $id) {
        return new UserResource(User::findOrFail($id));
    });

<a name="resource-collections"></a>
### Colecciones de Recursos

Si estás devolviendo una colección de recursos o una respuesta paginada, debes usar el método `collection` proporcionado por tu clase de recurso al crear la instancia del recurso en tu ruta o controlador:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/users', function () {
        return UserResource::collection(User::all());
    });

Ten en cuenta que esto no permite la adición de datos meta personalizados que puedan necesitar ser devueltos con tu colección. Si deseas personalizar la respuesta de la colección de recursos, puedes crear un recurso dedicado para representar la colección:

```shell
php artisan make:resource UserCollection
```

Una vez que se ha generado la clase de colección de recursos, puedes definir fácilmente cualquier dato meta que deba incluirse con la respuesta:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Request;
    use Illuminate\Http\Resources\Json\ResourceCollection;

    class UserCollection extends ResourceCollection
    {
        /**
         * Transformar la colección de recursos en un array.
         *
         * @return array<int|string, mixed>
         */
        public function toArray(Request $request): array
        {
            return [
                'data' => $this->collection,
                'links' => [
                    'self' => 'link-value',
                ],
            ];
        }
    }

Después de definir tu colección de recursos, puede ser devuelta desde una ruta o controlador:

    use App\Http\Resources\UserCollection;
    use App\Models\User;

    Route::get('/users', function () {
        return new UserCollection(User::all());
    });

<a name="preserving-collection-keys"></a>
#### Preservando Claves de Colección

Al devolver una colección de recursos desde una ruta, Laravel restablece las claves de la colección para que estén en orden numérico. Sin embargo, puedes agregar una propiedad `preserveKeys` a tu clase de recurso indicando si las claves originales de una colección deben ser preservadas:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\JsonResource;

    class UserResource extends JsonResource
    {
        /**
         * Indica si las claves de la colección del recurso deben ser preservadas.
         *
         * @var bool
         */
        public $preserveKeys = true;
    }

Cuando la propiedad `preserveKeys` se establece en `true`, las claves de la colección se preservarán cuando la colección se devuelva desde una ruta o controlador:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/users', function () {
        return UserResource::collection(User::all()->keyBy->id);
    });

<a name="customizing-the-underlying-resource-class"></a>
#### Personalizando la Clase de Recurso Subyacente

Típicamente, la propiedad `$this->collection` de una colección de recursos se llena automáticamente con el resultado de mapear cada elemento de la colección a su clase de recurso singular. Se asume que la clase de recurso singular es el nombre de la clase de la colección sin la porción `Collection` al final del nombre de la clase. Además, dependiendo de tu preferencia personal, la clase de recurso singular puede o no estar sufijada con `Resource`.

Por ejemplo, `UserCollection` intentará mapear las instancias de usuario dadas en el recurso `UserResource`. Para personalizar este comportamiento, puedes sobrescribir la propiedad `$collects` de tu colección de recursos:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\ResourceCollection;

    class UserCollection extends ResourceCollection
    {
        /**
         * El recurso que esta colección recoge.
         *
         * @var string
         */
        public $collects = Member::class;
    }

<a name="writing-resources"></a>
## Escribiendo Recursos

> [!NOTE]  
> Si no has leído la [descripción general del concepto](#concept-overview), se te anima encarecidamente a hacerlo antes de continuar con esta documentación.

Los recursos solo necesitan transformar un modelo dado en un array. Así que, cada recurso contiene un método `toArray` que traduce los atributos de tu modelo en un array amigable para la API que puede ser devuelto desde las rutas o controladores de tu aplicación:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Request;
    use Illuminate\Http\Resources\Json\JsonResource;

    class UserResource extends JsonResource
    {
        /**
         * Transformar el recurso en un array.
         *
         * @return array<string, mixed>
         */
        public function toArray(Request $request): array
        {
            return [
                'id' => $this->id,
                'name' => $this->name,
                'email' => $this->email,
                'created_at' => $this->created_at,
                'updated_at' => $this->updated_at,
            ];
        }
    }

Una vez que un recurso ha sido definido, puede ser devuelto directamente desde una ruta o controlador:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/user/{id}', function (string $id) {
        return new UserResource(User::findOrFail($id));
    });

<a name="relationships"></a>
#### Relaciones

Si deseas incluir recursos relacionados en tu respuesta, puedes agregarlos al array devuelto por el método `toArray` de tu recurso. En este ejemplo, utilizaremos el método `collection` del recurso `PostResource` para agregar las publicaciones del blog del usuario a la respuesta del recurso:

    use App\Http\Resources\PostResource;
    use Illuminate\Http\Request;

    /**
     * Transformar el recurso en un array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'posts' => PostResource::collection($this->posts),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

> [!NOTE]  
> Si deseas incluir relaciones solo cuando ya han sido cargadas, consulta la documentación sobre [relaciones condicionales](#conditional-relationships).

<a name="writing-resource-collections"></a>
#### Colecciones de Recursos

Mientras que los recursos transforman un solo modelo en un array, las colecciones de recursos transforman una colección de modelos en un array. Sin embargo, no es absolutamente necesario definir una clase de colección de recursos para cada uno de tus modelos, ya que todos los recursos proporcionan un método `collection` para generar una colección de recursos "ad-hoc" sobre la marcha:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/users', function () {
        return UserResource::collection(User::all());
    });

Sin embargo, si necesitas personalizar los datos meta devueltos con la colección, es necesario definir tu propia colección de recursos:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Request;
    use Illuminate\Http\Resources\Json\ResourceCollection;

    class UserCollection extends ResourceCollection
    {
        /**
         * Transformar la colección de recursos en un array.
         *
         * @return array<string, mixed>
         */
        public function toArray(Request $request): array
        {
            return [
                'data' => $this->collection,
                'links' => [
                    'self' => 'link-value',
                ],
            ];
        }
    }

Al igual que los recursos singulares, las colecciones de recursos pueden ser devueltas directamente desde rutas o controladores:

    use App\Http\Resources\UserCollection;
    use App\Models\User;

    Route::get('/users', function () {
        return new UserCollection(User::all());
    });

<a name="data-wrapping"></a>
### Envoltura de Datos

Por defecto, tu recurso más externo está envuelto en una clave `data` cuando la respuesta del recurso se convierte a JSON. Así que, por ejemplo, una respuesta típica de colección de recursos se ve como sigue:

```json
{
    "data": [
        {
            "id": 1,
            "name": "Eladio Schroeder Sr.",
            "email": "therese28@example.com"
        },
        {
            "id": 2,
            "name": "Liliana Mayert",
            "email": "evandervort@example.com"
        }
    ]
}
```

Si deseas deshabilitar la envoltura del recurso más externo, debes invocar el método `withoutWrapping` en la clase base `Illuminate\Http\Resources\Json\JsonResource`. Típicamente, debes llamar a este método desde tu `AppServiceProvider` u otro [proveedor de servicios](/docs/{{version}}/providers) que se carga en cada solicitud a tu aplicación:

    <?php

    namespace App\Providers;

    use Illuminate\Http\Resources\Json\JsonResource;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Registrar cualquier servicio de la aplicación.
         */
        public function register(): void
        {
            // ...
        }

        /**
         * Inicializar cualquier servicio de la aplicación.
         */
        public function boot(): void
        {
            JsonResource::withoutWrapping();
        }
    }

> [!WARNING]  
> El método `withoutWrapping` solo afecta la respuesta más externa y no eliminará las claves `data` que agregues manualmente a tus propias colecciones de recursos.

<a name="wrapping-nested-resources"></a>
#### Envoltura de Recursos Anidados

Tienes total libertad para determinar cómo se envuelven las relaciones de tu recurso. Si deseas que todas las colecciones de recursos estén envueltas en una clave `data`, independientemente de su anidamiento, debes definir una clase de colección de recursos para cada recurso y devolver la colección dentro de una clave `data`.

Es posible que te preguntes si esto causará que tu recurso más externo esté envuelto en dos claves `data`. No te preocupes, Laravel nunca permitirá que tus recursos sean accidentalmente envueltos dos veces, por lo que no tienes que preocuparte por el nivel de anidamiento de la colección de recursos que estás transformando:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\ResourceCollection;

    class CommentsCollection extends ResourceCollection
    {
        /**
         * Transformar la colección de recursos en un array.
         *
         * @return array<string, mixed>
         */
        public function toArray(Request $request): array
        {
            return ['data' => $this->collection];
        }
    }

<a name="data-wrapping-and-pagination"></a>
#### Envoltura de Datos y Paginación

Al devolver colecciones paginadas a través de una respuesta de recurso, Laravel envolverá tus datos de recurso en una clave `data` incluso si se ha llamado al método `withoutWrapping`. Esto se debe a que las respuestas paginadas siempre contienen claves `meta` y `links` con información sobre el estado del paginador:

```json
{
    "data": [
        {
            "id": 1,
            "name": "Eladio Schroeder Sr.",
            "email": "therese28@example.com"
        },
        {
            "id": 2,
            "name": "Liliana Mayert",
            "email": "evandervort@example.com"
        }
    ],
    "links":{
        "first": "http://example.com/users?page=1",
        "last": "http://example.com/users?page=1",
        "prev": null,
        "next": null
    },
    "meta":{
        "current_page": 1,
        "from": 1,
        "last_page": 1,
        "path": "http://example.com/users",
        "per_page": 15,
        "to": 10,
        "total": 10
    }
}
```

<a name="pagination"></a>
### Paginación

Puedes pasar una instancia de paginador de Laravel al método `collection` de un recurso o a una colección de recursos personalizada:

    use App\Http\Resources\UserCollection;
    use App\Models\User;

    Route::get('/users', function () {
        return new UserCollection(User::paginate());
    });

Las respuestas paginadas siempre contienen las claves `meta` y `links` con información sobre el estado del paginador:

```json
{
    "data": [
        {
            "id": 1,
            "name": "Eladio Schroeder Sr.",
            "email": "therese28@example.com"
        },
        {
            "id": 2,
            "name": "Liliana Mayert",
            "email": "evandervort@example.com"
        }
    ],
    "links":{
        "first": "http://example.com/users?page=1",
        "last": "http://example.com/users?page=1",
        "prev": null,
        "next": null
    },
    "meta":{
        "current_page": 1,
        "from": 1,
        "last_page": 1,
        "path": "http://example.com/users",
        "per_page": 15,
        "to": 10,
        "total": 10
    }
}
```

<a name="customizing-the-pagination-information"></a>
#### Personalizando la Información de Paginación

Si deseas personalizar la información incluida en las claves `links` o `meta` de la respuesta de paginación, puedes definir un método `paginationInformation` en el recurso. Este método recibirá los datos `$paginated` y el array de información `$default`, que es un array que contiene las claves `links` y `meta`:

    /**
     * Personaliza la información de paginación para el recurso.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  array $paginated
     * @param  array $default
     * @return array
     */
    public function paginationInformation($request, $paginated, $default)
    {
        $default['links']['custom'] = 'https://example.com';

        return $default;
    }

<a name="conditional-attributes"></a>
### Atributos Condicionales

A veces, es posible que desees incluir un atributo en una respuesta de recurso solo si se cumple una determinada condición. Por ejemplo, es posible que desees incluir un valor solo si el usuario actual es un "administrador". Laravel proporciona una variedad de métodos auxiliares para ayudarte en esta situación. El método `when` se puede usar para agregar condicionalmente un atributo a una respuesta de recurso:

    /**
     * Transforma el recurso en un array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'secret' => $this->when($request->user()->isAdmin(), 'secret-value'),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

En este ejemplo, la clave `secret` solo se devolverá en la respuesta final del recurso si el método `isAdmin` del usuario autenticado devuelve `true`. Si el método devuelve `false`, la clave `secret` se eliminará de la respuesta del recurso antes de enviarla al cliente. El método `when` te permite definir expresivamente tus recursos sin recurrir a declaraciones condicionales al construir el array.

El método `when` también acepta una función anónima como su segundo argumento, lo que te permite calcular el valor resultante solo si la condición dada es `true`:

    'secret' => $this->when($request->user()->isAdmin(), function () {
        return 'secret-value';
    }),

El método `whenHas` se puede usar para incluir un atributo si realmente está presente en el modelo subyacente:

    'name' => $this->whenHas('name'),

Además, el método `whenNotNull` se puede usar para incluir un atributo en la respuesta del recurso si el atributo no es nulo:

    'name' => $this->whenNotNull($this->name),

<a name="merging-conditional-attributes"></a>
#### Fusionando Atributos Condicionales

A veces, puedes tener varios atributos que solo deben incluirse en la respuesta del recurso según la misma condición. En este caso, puedes usar el método `mergeWhen` para incluir los atributos en la respuesta solo cuando la condición dada sea `true`:

    /**
     * Transforma el recurso en un array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            $this->mergeWhen($request->user()->isAdmin(), [
                'first-secret' => 'value',
                'second-secret' => 'value',
            ]),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

Nuevamente, si la condición dada es `false`, estos atributos se eliminarán de la respuesta del recurso antes de enviarla al cliente.

> [!WARNING]  
> El método `mergeWhen` no debe usarse dentro de arrays que mezclan claves de tipo string y numéricas. Además, no debe usarse dentro de arrays con claves numéricas que no estén ordenadas secuencialmente.

<a name="conditional-relationships"></a>
### Relaciones Condicionales

Además de cargar atributos condicionalmente, puedes incluir condicionalmente relaciones en tus respuestas de recurso según si la relación ya ha sido cargada en el modelo. Esto permite que tu controlador decida qué relaciones deben cargarse en el modelo y tu recurso puede incluirlas fácilmente solo cuando realmente han sido cargadas. En última instancia, esto facilita evitar problemas de consulta "N+1" dentro de tus recursos.

El método `whenLoaded` se puede usar para cargar condicionalmente una relación. Para evitar cargar relaciones innecesariamente, este método acepta el nombre de la relación en lugar de la relación misma:

    use App\Http\Resources\PostResource;

    /**
     * Transforma el recurso en un array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'posts' => PostResource::collection($this->whenLoaded('posts')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

En este ejemplo, si la relación no ha sido cargada, la clave `posts` se eliminará de la respuesta del recurso antes de enviarla al cliente.

<a name="conditional-relationship-counts"></a>
#### Contadores de Relaciones Condicionales

Además de incluir relaciones condicionalmente, puedes incluir condicionalmente "contadores" de relaciones en tus respuestas de recurso según si el conteo de la relación ha sido cargado en el modelo:

    new UserResource($user->loadCount('posts'));

El método `whenCounted` se puede usar para incluir condicionalmente el conteo de una relación en tu respuesta de recurso. Este método evita incluir innecesariamente el atributo si el conteo de las relaciones no está presente:

    /**
     * Transforma el recurso en un array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'posts_count' => $this->whenCounted('posts'),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

En este ejemplo, si el conteo de la relación `posts` no ha sido cargado, la clave `posts_count` se eliminará de la respuesta del recurso antes de enviarla al cliente.

Otros tipos de agregados, como `avg`, `sum`, `min` y `max` también pueden ser cargados condicionalmente utilizando el método `whenAggregated`:

```php
'words_avg' => $this->whenAggregated('posts', 'words', 'avg'),
'words_sum' => $this->whenAggregated('posts', 'words', 'sum'),
'words_min' => $this->whenAggregated('posts', 'words', 'min'),
'words_max' => $this->whenAggregated('posts', 'words', 'max'),
```

<a name="conditional-pivot-information"></a>
#### Información Condicional de Pivot

Además de incluir condicionalmente información de relaciones en tus respuestas de recurso, puedes incluir condicionalmente datos de las tablas intermedias de relaciones muchos a muchos utilizando el método `whenPivotLoaded`. El método `whenPivotLoaded` acepta el nombre de la tabla pivot como su primer argumento. El segundo argumento debe ser una función anónima que devuelve el valor que se devolverá si la información del pivot está disponible en el modelo:

    /**
     * Transforma el recurso en un array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'expires_at' => $this->whenPivotLoaded('role_user', function () {
                return $this->pivot->expires_at;
            }),
        ];
    }

Si tu relación está utilizando un [modelo de tabla intermedia personalizado](/docs/{{version}}/eloquent-relationships#defining-custom-intermediate-table-models), puedes pasar una instancia del modelo de tabla intermedia como el primer argumento al método `whenPivotLoaded`:

    'expires_at' => $this->whenPivotLoaded(new Membership, function () {
        return $this->pivot->expires_at;
    }),

Si tu tabla intermedia está utilizando un accesor diferente a `pivot`, puedes usar el método `whenPivotLoadedAs`:

    /**
     * Transforma el recurso en un array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'expires_at' => $this->whenPivotLoadedAs('subscription', 'role_user', function () {
                return $this->subscription->expires_at;
            }),
        ];
    }

<a name="adding-meta-data"></a>
### Agregando Meta Datos

Algunos estándares de API JSON requieren la adición de meta datos a tus respuestas de recursos y colecciones de recursos. Esto a menudo incluye cosas como `links` al recurso o recursos relacionados, o meta datos sobre el recurso en sí. Si necesitas devolver meta datos adicionales sobre un recurso, inclúyelos en tu método `toArray`. Por ejemplo, podrías incluir información de `link` al transformar una colección de recursos:

    /**
     * Transforma el recurso en un array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'data' => $this->collection,
            'links' => [
                'self' => 'link-value',
            ],
        ];
    }

Al devolver meta datos adicionales de tus recursos, nunca tienes que preocuparte por sobrescribir accidentalmente las claves `links` o `meta` que Laravel agrega automáticamente al devolver respuestas paginadas. Cualquier `links` adicional que definas se fusionará con los enlaces proporcionados por el paginador.

<a name="top-level-meta-data"></a>
#### Meta Datos de Nivel Superior

A veces, es posible que desees incluir solo ciertos meta datos con una respuesta de recurso si el recurso es el recurso más externo que se está devolviendo. Típicamente, esto incluye información meta sobre la respuesta en su conjunto. Para definir estos meta datos, agrega un método `with` a tu clase de recurso. Este método debe devolver un array de meta datos que se incluirán con la respuesta del recurso solo cuando el recurso sea el más externo que se está transformando:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\ResourceCollection;

    class UserCollection extends ResourceCollection
    {
        /**
         * Transforma la colección de recursos en un array.
         *
         * @return array<string, mixed>
         */
        public function toArray(Request $request): array
        {
            return parent::toArray($request);
        }

        /**
         * Obtiene datos adicionales que deben ser devueltos con el array de recursos.
         *
         * @return array<string, mixed>
         */
        public function with(Request $request): array
        {
            return [
                'meta' => [
                    'key' => 'value',
                ],
            ];
        }
    }

<a name="adding-meta-data-when-constructing-resources"></a>
#### Agregando Meta Datos al Construir Recursos

También puedes agregar datos de nivel superior al construir instancias de recursos en tu ruta o controlador. El método `additional`, que está disponible en todos los recursos, acepta un array de datos que deben ser añadidos a la respuesta del recurso:

    return (new UserCollection(User::all()->load('roles')))
                    ->additional(['meta' => [
                        'key' => 'value',
                    ]]);

<a name="resource-responses"></a>
## Respuestas de Recursos

Como ya has leído, los recursos pueden ser devueltos directamente desde rutas y controladores:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/user/{id}', function (string $id) {
        return new UserResource(User::findOrFail($id));
    });

Sin embargo, a veces es posible que necesites personalizar la respuesta HTTP saliente antes de que se envíe al cliente. Hay dos formas de lograr esto. Primero, puedes encadenar el método `response` al recurso. Este método devolverá una instancia de `Illuminate\Http\JsonResponse`, dándote control total sobre los encabezados de la respuesta:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/user', function () {
        return (new UserResource(User::find(1)))
                    ->response()
                    ->header('X-Value', 'True');
    });

Alternativamente, puedes definir un método `withResponse` dentro del recurso mismo. Este método se llamará cuando el recurso se devuelva como el recurso más externo en una respuesta:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\JsonResponse;
    use Illuminate\Http\Request;
    use Illuminate\Http\Resources\Json\JsonResource;

    class UserResource extends JsonResource
    {
        /**
         * Transforma el recurso en un array.
         *
         * @return array<string, mixed>
         */
        public function toArray(Request $request): array
        {
            return [
                'id' => $this->id,
            ];
        }

        /**
         * Personaliza la respuesta saliente para el recurso.
         */
        public function withResponse(Request $request, JsonResponse $response): void
        {
            $response->header('X-Value', 'True');
        }
    }
