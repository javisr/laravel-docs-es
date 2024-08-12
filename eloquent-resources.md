# Eloquent: Recursos API

- [Introducción](#introduction)
- [Generación de recursos](#generating-resources)
- [Resumen de conceptos](#concept-overview)
  - [Colecciones de recursos](#resource-collections)
- [Escritura de recursos](#writing-resources)
  - [Envoltura de datos](#data-wrapping)
  - [Paginación](#pagination)
  - [Atributos Condicionales](#conditional-attributes)
  - [Relaciones condicionales](#conditional-relationships)
  - [Añadir metadatos](#adding-meta-data)
- [Respuestas de Recursos](#resource-responses)

<a name="introduction"></a>
## Introducción

Al crear una API, es posible que necesites una capa de transformación que se sitúe entre tus modelos de Eloquent y las respuestas JSON que se devuelven realmente a los usuarios de tu aplicación. Por ejemplo, puede que desees mostrar ciertos atributos a un subconjunto de usuarios y no a otros, o puede que quieras incluir siempre ciertas relaciones en la representación JSON de tus modelos. Las clases de recursos de Eloquent te permiten transformar de forma expresiva y sencilla tus modelos y colecciones de modelos en JSON.

Por supuesto, siempre puedes convertir modelos o colecciones de Eloquent a JSON utilizando sus métodos `toJson`; sin embargo, los recursos de Eloquent proporcionan un control más granular y robusto sobre la serialización JSON de tus modelos y sus relaciones.

<a name="generating-resources"></a>
## Generación de recursos

Para generar una clase de recurso, puede utilizar el comando `make:resource` de Artisan. Por defecto, los recursos se colocarán en el directorio `app/Http/Resources` de tu aplicación. Los recursos extienden la clase `Illuminate\Http\Resources\Json\JsonResource`:

```shell
php artisan make:resource UserResource
```

<a name="generating-resource-collections"></a>
#### Colecciones de recursos

Además de generar recursos que transformen modelos individuales, puedes generar recursos que se encarguen de transformar colecciones de modelos. Esto permite que tus respuestas JSON incluyan enlaces y otra meta información que sea relevante para toda una colección de un recurso dado.

Para crear una colección de recursos, debe utilizar el indicador `--collection` al crear el recurso. O, incluyendo la palabra `Collection` en el nombre del recurso indicará a Laravel que debe crear un recurso de colección. Los recursos de colección extienden la clase `Illuminate\Http\Resources\Json\ResourceCollection`:

```shell
php artisan make:resource User --collection

php artisan make:resource UserCollection
```

<a name="concept-overview"></a>
## Concepto

> **Nota**  
> Esta es una descripción general de alto nivel de los recursos y las colecciones de recursos. Le recomendamos encarecidamente que lea las demás secciones de esta documentación para comprender mejor la personalización y la potencia que le ofrecen los recursos.

Antes de sumergirnos en todas las opciones disponibles al escribir recursos, echemos un vistazo de alto nivel a cómo se utilizan los recursos dentro de Laravel. Una clase recurso representa un único modelo que necesita ser transformado en una estructura JSON. Por ejemplo, aquí tiene la siguiente clase de recurso `UserResource`:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\JsonResource;

    class UserResource extends JsonResource
    {
        /**
         * Transform the resource into an array.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return array
         */
        public function toArray($request)
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

Cada clase resource define un método `toArray` que devuelve el array de atributos que deben ser convertidos a JSON cuando el recurso es devuelto como respuesta desde un método de ruta o controlador.

Observa que podemos acceder a las propiedades del modelo directamente desde la variable `$this`. Esto se debe a que una clase de recurso hace de proxy y automáticamente accede las propiedades y métodos del modelo subyacente. Una vez definido el recurso, puede ser devuelto desde una ruta o controlador. El recurso acepta la instancia del modelo subyacente a través de su constructor:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/user/{id}', function ($id) {
        return new UserResource(User::findOrFail($id));
    });

<a name="resource-collections"></a>
### Colecciones de recursos

Si está devolviendo una colección de recursos o una respuesta paginada, debe utilizar el método de `collection` al crear la instancia del recurso en su ruta o controlador:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/users', function () {
        return UserResource::collection(User::all());
    });

Tenga en cuenta que esto no permite ninguna adición de metadatos personalizados que puedan necesitar ser devueltos con su colección. Si desea personalizar la respuesta de la colección de recursos, puede crear un recurso dedicado para representar la colección:

```shell
php artisan make:resource UserCollection
```

Una vez generada la clase de la colección de recursos, puede definir fácilmente cualquier metadato que deba incluirse en la respuesta:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\ResourceCollection;

    class UserCollection extends ResourceCollection
    {
        /**
         * Transform the resource collection into an array.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return array
         */
        public function toArray($request)
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
#### Conservación de las claves de la colección

Cuando se devuelve una colección de recursos desde una ruta, Laravel restablece las claves de la colección para que estén en orden numérico. Sin embargo, puedes añadir una propiedad `preserveKeys` a tu clase resource indicando si las claves originales de una colección deben ser preservadas:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\JsonResource;

    class UserResource extends JsonResource
    {
        /**
         * Indicates if the resource's collection keys should be preserved.
         *
         * @var bool
         */
        public $preserveKeys = true;
    }

Cuando la propiedad `preserveKeys` está establecida a `true`, las claves de la colección serán preservadas cuando la colección sea devuelta desde una ruta o controlador:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/users', function () {
        return UserResource::collection(User::all()->keyBy->id);
    });

<a name="customizing-the-underlying-resource-class"></a>
#### Personalización de la clase de recurso subyacente

Normalmente, la propiedad `$this->collection` de una colección de recursos se rellena automáticamente con el resultado de asignar cada elemento de la colección a su clase de recurso singular. Se supone que la clase de recurso singular es el nombre de clase de la colección sin la parte final `Collection`. Además, dependiendo de sus preferencias personales, la clase de recurso singular puede o no tener el sufijo `Resource`.

Por ejemplo, `UserCollection` intentará asignar las instancias de usuario dadas al recurso `UserResource`. Para personalizar este comportamiento, puede sobreescribir la propiedad `$collects` de su colección de recursos:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\ResourceCollection;

    class UserCollection extends ResourceCollection
    {
        /**
         * The resource that this resource collects.
         *
         * @var string
         */
        public $collects = Member::class;
    }

<a name="writing-resources"></a>
## Escritura de recursos

> **Nota**  
> Si no has leído la [descripción general del concepto](#concept-overview), te recomendamos que lo hagas antes de continuar con esta documentación.

En esencia, los recursos son simples. Sólo necesitan transformar un modelo dado en un array. Así, cada recurso contiene un método `toArray` que traduce los atributos de tu modelo en un array amigable con la API que puede ser devuelto desde las rutas o controladores de tu aplicación:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\JsonResource;

    class UserResource extends JsonResource
    {
        /**
         * Transform the resource into an array.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return array
         */
        public function toArray($request)
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

Una vez definido un recurso, puede ser devuelto directamente desde una ruta o controlador:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/user/{id}', function ($id) {
        return new UserResource(User::findOrFail($id));
    });

<a name="relationships"></a>
#### Relaciones

Si quieres incluir recursos relacionados en tu respuesta, puedes añadirlos al array devuelto por el método `toArray` de tu recurso. En este ejemplo, utilizaremos el método `collection` del recurso `PostResource` para añadir las entradas del blog del usuario a la respuesta del recurso:

    use App\Http\Resources\PostResource;

    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
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

> **Nota**  
> Si desea incluir relaciones sólo cuando ya se han cargado, consulte la documentación sobre [relaciones condicionales](#conditional-relationships).

<a name="writing-resource-collections"></a>
#### Colecciones de recursos

Mientras que los recursos transforman un único modelo en una array, las colecciones de recursos transforman una colección de modelos en una array. Sin embargo, no es absolutamente necesario definir una clase de colección de recursos para cada uno de sus modelos, ya que todos los recursos proporcionan un método de `colección` para generar una colección de recursos "ad-hoc" sobre la marcha:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/users', function () {
        return UserResource::collection(User::all());
    });

Sin embargo, si necesita personalizar los metadatos devueltos con la colección, es necesario definir su propia colección de recursos:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\ResourceCollection;

    class UserCollection extends ResourceCollection
    {
        /**
         * Transform the resource collection into an array.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return array
         */
        public function toArray($request)
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
### Envoltura de datos

Por defecto, su recurso más externo se envuelve en una clave de `data` cuando la respuesta del recurso se convierte a JSON. Así, por ejemplo, una respuesta de colección de recursos típica tiene el siguiente aspecto:

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

Si desea utilizar una clave personalizada en lugar de `data`, puede definir un atributo `$wrap` en la clase de recurso:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\JsonResource;

    class UserResource extends JsonResource
    {
        /**
         * The "data" wrapper that should be applied.
         *
         * @var string|null
         */
        public static $wrap = 'user';
    }

Si desea desactivar la envoltura del recurso más externo, debe invocar el método `withoutWrapping` en la clase base `Illuminate\Http\Resources\Json\JsonResource`. Normalmente, debe llamar a este método desde su `AppServiceProvider` u otro [proveedor de servicios](/docs/{{version}}/providers) que se cargue en cada solicitud a su aplicación:

    <?php

    namespace App\Providers;

    use Illuminate\Http\Resources\Json\JsonResource;
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
            JsonResource::withoutWrapping();
        }
    }

> **Advertencia**  
> El método `withoutWrapping` sólo afecta a la respuesta más externa y no eliminará las claves `data` que añadas manualmente a tus propias colecciones de recursos.

<a name="wrapping-nested-resources"></a>
#### Envoltura de recursos anidados

Tienes total libertad para determinar cómo se envuelven las relaciones de tus recursos. Si desea que todas las colecciones de recursos se envuelvan en una clave `data`, independientemente de su anidamiento, debe definir una clase de colección de recursos para cada recurso y devolver la colección dentro de una clave `data`.

Puede que te preguntes si esto hará que tu recurso más externo esté envuelto en dos claves `data`. No te preocupes, Laravel nunca dejará que tus recursos se envuelvan dos veces accidentalmente, así que no tienes que preocuparte por el nivel de anidamiento de la colección de recursos que estás transformando:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\ResourceCollection;

    class CommentsCollection extends ResourceCollection
    {
        /**
         * Transform the resource collection into an array.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return array
         */
        public function toArray($request)
        {
            return ['data' => $this->collection];
        }
    }

<a name="data-wrapping-and-pagination"></a>
#### Envoltura de datos y paginación

Cuando se devuelven colecciones paginadas a través de una respuesta de recurso, Laravel envolverá los datos de tu recurso en una clave `data` incluso si se ha llamado al método `withoutWrapping`. Esto se debe a que las respuestas paginadas siempre contienen claves `meta` y `links` con información sobre el estado del paginador:

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
        "first": "http://example.com/pagination?page=1",
        "last": "http://example.com/pagination?page=1",
        "prev": null,
        "next": null
    },
    "meta":{
        "current_page": 1,
        "from": 1,
        "last_page": 1,
        "path": "http://example.com/pagination",
        "per_page": 15,
        "to": 10,
        "total": 10
    }
}
```

<a name="pagination"></a>
### Paginación

Puedes pasar una instancia del paginador Laravel al método `collection` de un recurso o a una colección de recursos personalizada:

    use App\Http\Resources\UserCollection;
    use App\Models\User;

    Route::get('/users', function () {
        return new UserCollection(User::paginate());
    });

Las respuestas paginadas siempre contienen claves `meta` y `links` con información sobre el estado del paginador:

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
        "first": "http://example.com/pagination?page=1",
        "last": "http://example.com/pagination?page=1",
        "prev": null,
        "next": null
    },
    "meta":{
        "current_page": 1,
        "from": 1,
        "last_page": 1,
        "path": "http://example.com/pagination",
        "per_page": 15,
        "to": 10,
        "total": 10
    }
}
```

<a name="conditional-attributes"></a>
### Atributos condicionales

A veces es posible que desee incluir un atributo en la respuesta de un recurso sólo si se cumple una condición determinada. Por ejemplo, es posible que sólo desee incluir un valor si el usuario actual es un "administrador". Laravel proporciona una variedad de métodos de ayuda para ayudarle en esta situación. El método `when` puede utilizarse para añadir condicionalmente un atributo a la respuesta de un recurso:

    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
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

En este ejemplo, la clave `secret` sólo se devolverá en la respuesta final del recurso si el método `isAdmin` del usuario autenticado devuelve `true`. Si el método devuelve `false`, la clave `secret` se eliminará de la respuesta del recurso antes de que se envíe al cliente. El método `when` permite definir de forma expresa los recursos sin recurrir a sentencias condicionales al construir el array.

El método `when` también acepta un closure como segundo argumento, lo que le permite calcular el valor resultante sólo si la condición dada es `true`:

    'secret' => $this->when($request->user()->isAdmin(), function () {
        return 'secret-value';
    }),

Además, el método `whenNotNull` puede utilizarse para incluir un atributo en la respuesta del recurso si el atributo no es nulo:

    'name' => $this->whenNotNull($this->name),

<a name="merging-conditional-attributes"></a>
#### Fusión de atributos condicionales

A veces puede haber varios atributos que sólo deben incluirse en la respuesta de recurso basándose en la misma condición. En este caso, puede utilizar el método `mergeWhen` para incluir los atributos en la respuesta sólo cuando la condición dada sea `true`:

    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
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

De nuevo, si la condición dada es `falsa`, estos atributos serán eliminados de la respuesta del recurso antes de ser enviada al cliente.

> **Advertencia**  
> El método `mergeWhen` no debe utilizarse en matrices que mezclen claves numéricas y de cadena. Además, no debe utilizarse en matrices con claves numéricas que no estén ordenadas secuencialmente.

<a name="conditional-relationships"></a>
### Relaciones condicionales

Además de cargar atributos condicionalmente, puedes incluir relaciones condicionalmente en tus respuestas de recursos basándote en si la relación ya ha sido cargada en el modelo. Esto permite a tu controlador decidir qué relaciones deben cargarse en el modelo y tu recurso puede incluirlas fácilmente sólo cuando se hayan cargado realmente. En última instancia, esto hace que sea más fácil evitar "N + 1" problemas de consulta dentro de sus recursos.

El método `whenLoaded` puede utilizarse para cargar condicionalmente una relación. Para evitar cargar relaciones innecesariamente, este método acepta el nombre de la relación en lugar de la relación en sí:

    use App\Http\Resources\PostResource;

    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
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

En este ejemplo, si la relación no se ha cargado, la clave `posts` se eliminará de la respuesta del recurso antes de que se envíe al cliente.

<a name="conditional-relationship-counts"></a>
#### Recuentos condicionales de relaciones

Además de incluir relaciones condicionalmente, puede incluir "recuentos" de relaciones condicionalmente en las respuestas de sus recursos basándose en si el recuento de la relación se ha cargado en el modelo:

    new UserResource($user->loadCount('posts'));

El método `whenCounted` puede utilizarse para incluir condicionalmente el recuento de una relación en la respuesta del recurso. Este método evita incluir innecesariamente el atributo si el recuento de relaciones no está presente:

    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
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

En este ejemplo, si el recuento de la relación `posts` no se ha cargado, la clave `posts_count` se eliminará de la respuesta del recurso antes de que se envíe al cliente.

<a name="conditional-pivot-information"></a>
#### Información pivotante condicional

Además de incluir condicionalmente información de relaciones en las respuestas de recursos, puede incluir condicionalmente datos de las tablas intermedias de relaciones de muchos a muchos utilizando el método `whenPivotLoaded`. El método `whenPivotLoaded` acepta el nombre de la tabla pivotante como primer argumento. El segundo argumento debe ser un closure que devuelva el valor a devolver si la información pivotante está disponible en el modelo:

    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'expires_at' => $this->whenPivotLoaded('role_user', function () {
                return $this->pivot->expires_at;
            }),
        ];
    }

Si su relación utiliza un [modelo de tabla intermedia personalizado](/docs/{{version}}/eloquent-relationships#defining-custom-intermediate-table-models), puede pasar una instancia del modelo de tabla intermedia como primer argumento al método `whenPivotLoaded`:

    'expires_at' => $this->whenPivotLoaded(new Membership, function () {
        return $this->pivot->expires_at;
    }),

Si la tabla intermedia utiliza un accesor distinto de `pivot`, puede utilizar el método `whenPivotLoadedAs`:

    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
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
### Añadir metadatos

Algunos estándares de la API JSON requieren que se añadan metadatos a las respuestas de recursos y colecciones de recursos. Esto a menudo incluye cosas como `links` al recurso o a recursos relacionados, o metadatos sobre el propio recurso. Si necesitas devolver metadatos adicionales sobre un recurso, inclúyelos en tu método `toArray`. Por ejemplo, puedes incluir información sobre `links` al transformar una colección de recursos:

    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
    {
        return [
            'data' => $this->collection,
            'links' => [
                'self' => 'link-value',
            ],
        ];
    }

Cuando devuelvas metadatos adicionales de tus recursos, nunca tendrás que preocuparte de sobreescribir accidentalmente los `links` o los `meta` que Laravel añade automáticamente cuando devuelve respuestas paginadas. Cualquier `links` adicional que defina se fusionará con los enlaces proporcionados por el paginador.

<a name="top-level-meta-data"></a>
#### Metadatos de nivel superior

A veces es posible que sólo desee incluir ciertos metadatos con una respuesta de recurso si el recurso es el recurso más externo que se devuelve. Normalmente, esto incluye metadatos sobre la respuesta en su conjunto. Para definir estos metadatos, añada un método `with` a su clase de recurso. Este método debe devolver una array de metadatos que se incluirán en la respuesta de recurso sólo cuando el recurso sea el recurso más externo que se transforma:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\ResourceCollection;

    class UserCollection extends ResourceCollection
    {
        /**
         * Transform the resource collection into an array.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return array
         */
        public function toArray($request)
        {
            return parent::toArray($request);
        }

        /**
         * Get additional data that should be returned with the resource array.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return array
         */
        public function with($request)
        {
            return [
                'meta' => [
                    'key' => 'value',
                ],
            ];
        }
    }

<a name="adding-meta-data-when-constructing-resources"></a>
#### Añadir metadatos al construir recursos

También puede añadir datos de nivel superior al construir instancias de recursos en su ruta o controlador. El método `additional`, disponible en todos los recursos, acepta un array de datos que deben añadirse a la respuesta del recurso:

    return (new UserCollection(User::all()->load('roles')))
                    ->additional(['meta' => [
                        'key' => 'value',
                    ]]);

<a name="resource-responses"></a>
## Respuestas de recursos

Como ya has leído, los recursos pueden ser devueltos directamente desde rutas y controladores:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/user/{id}', function ($id) {
        return new UserResource(User::findOrFail($id));
    });

Sin embargo, a veces puede que necesite personalizar la respuesta HTTP saliente antes de que se envíe al cliente. Hay dos formas de hacerlo. En primer lugar, puede encadenar el método de `response` en el recurso. Este método devolverá una instancia `Illuminate\Http\JsonResponse`, dándole un control total sobre las cabeceras de la respuesta:

    use App\Http\Resources\UserResource;
    use App\Models\User;

    Route::get('/user', function () {
        return (new UserResource(User::find(1)))
                    ->response()
                    ->header('X-Value', 'True');
    });

De manera alternativa, puede definir un método `withResponse` dentro del propio recurso. Este método será llamado cuando el recurso sea devuelto como el recurso más externo en una respuesta:

    <?php

    namespace App\Http\Resources;

    use Illuminate\Http\Resources\Json\JsonResource;

    class UserResource extends JsonResource
    {
        /**
         * Transform the resource into an array.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return array
         */
        public function toArray($request)
        {
            return [
                'id' => $this->id,
            ];
        }

        /**
         * Customize the outgoing response for the resource.
         *
         * @param  \Illuminate\Http\Request  $request
         * @param  \Illuminate\Http\Response  $response
         * @return void
         */
        public function withResponse($request, $response)
        {
            $response->header('X-Value', 'True');
        }
    }
