# Laravel Cashier (Paddle)

- [Introducción](#introduction)
- [Actualizando Cashier](#upgrading-cashier)
- [Instalación](#installation)
    - [Paddle Sandbox](#paddle-sandbox)
- [Configuración](#configuration)
    - [Modelo Facturable](#billable-model)
    - [Claves API](#api-keys)
    - [Paddle JS](#paddle-js)
    - [Configuración de Moneda](#currency-configuration)
    - [Sobrescribiendo Modelos Predeterminados](#overriding-default-models)
- [Guía Rápida](#quickstart)
    - [Venta de Productos](#quickstart-selling-products)
    - [Venta de Suscripciones](#quickstart-selling-subscriptions)
- [Sesiones de Pago](#checkout-sessions)
    - [Pago Superpuesto](#overlay-checkout)
    - [Pago en Línea](#inline-checkout)
    - [Pagos de Invitados](#guest-checkouts)
- [Vistas Previas de Precios](#price-previews)
    - [Vistas Previas de Precios para Clientes](#customer-price-previews)
    - [Descuentos](#price-discounts)
- [Clientes](#customers)
    - [Valores Predeterminados de Clientes](#customer-defaults)
    - [Recuperando Clientes](#retrieving-customers)
    - [Creando Clientes](#creating-customers)
- [Suscripciones](#subscriptions)
    - [Creando Suscripciones](#creating-subscriptions)
    - [Verificando el Estado de la Suscripción](#checking-subscription-status)
    - [Cargos Únicos de Suscripción](#subscription-single-charges)
    - [Actualizando Información de Pago](#updating-payment-information)
    - [Cambiando Planes](#changing-plans)
    - [Cantidad de Suscripciones](#subscription-quantity)
    - [Suscripciones con Múltiples Productos](#subscriptions-with-multiple-products)
    - [Múltiples Suscripciones](#multiple-subscriptions)
    - [Pausando Suscripciones](#pausing-subscriptions)
    - [Cancelando Suscripciones](#canceling-subscriptions)
- [Pruebas de Suscripción](#subscription-trials)
    - [Con Método de Pago por Adelantado](#with-payment-method-up-front)
    - [Sin Método de Pago por Adelantado](#without-payment-method-up-front)
    - [Extender o Activar una Prueba](#extend-or-activate-a-trial)
- [Manejo de Webhooks de Paddle](#handling-paddle-webhooks)
    - [Definiendo Controladores de Eventos de Webhook](#defining-webhook-event-handlers)
    - [Verificando Firmas de Webhook](#verifying-webhook-signatures)
- [Cargos Únicos](#single-charges)
    - [Cobrando por Productos](#charging-for-products)
    - [Reembolsando Transacciones](#refunding-transactions)
    - [Acreditando Transacciones](#crediting-transactions)
- [Transacciones](#transactions)
    - [Pagos Pasados y Futuros](#past-and-upcoming-payments)
- [Pruebas](#testing)

<a name="introduction"></a>
## Introducción

> [!WARNING]  
> Esta documentación es para la integración de Cashier Paddle 2.x con Paddle Billing. Si aún estás utilizando Paddle Classic, deberías usar [Cashier Paddle 1.x](https://github.com/laravel/cashier-paddle/tree/1.x).

[Laravel Cashier Paddle](https://github.com/laravel/cashier-paddle) proporciona una interfaz expresiva y fluida para los servicios de facturación por suscripción de [Paddle](https://paddle.com). Maneja casi todo el código de facturación por suscripción que temías. Además de la gestión básica de suscripciones, Cashier puede manejar: intercambio de suscripciones, "cantidades" de suscripción, pausas de suscripción, períodos de gracia para cancelaciones y más.

Antes de profundizar en Cashier Paddle, te recomendamos que también revises las [guías de conceptos](https://developer.paddle.com/concepts/overview) y la [documentación de la API](https://developer.paddle.com/api-reference/overview) de Paddle.

<a name="upgrading-cashier"></a>
## Actualizando Cashier

Al actualizar a una nueva versión de Cashier, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/cashier-paddle/blob/master/UPGRADE.md).

<a name="installation"></a>
## Instalación

Primero, instala el paquete Cashier para Paddle utilizando el gestor de paquetes Composer:

```shell
composer require laravel/cashier-paddle
```

A continuación, deberías publicar los archivos de migración de Cashier utilizando el comando Artisan `vendor:publish`:

```shell
php artisan vendor:publish --tag="cashier-migrations"
```

Luego, deberías ejecutar las migraciones de la base de datos de tu aplicación. Las migraciones de Cashier crearán una nueva tabla `customers`. Además, se crearán nuevas tablas `subscriptions` y `subscription_items` para almacenar todas las suscripciones de tus clientes. Por último, se creará una nueva tabla `transactions` para almacenar todas las transacciones de Paddle asociadas con tus clientes:

```shell
php artisan migrate
```

> [!WARNING]  
> Para asegurar que Cashier maneje correctamente todos los eventos de Paddle, recuerda [configurar el manejo de webhooks de Cashier](#handling-paddle-webhooks).

<a name="paddle-sandbox"></a>
### Paddle Sandbox

Durante el desarrollo local y en staging, deberías [registrar una cuenta de Paddle Sandbox](https://sandbox-login.paddle.com/signup). Esta cuenta te dará un entorno aislado para probar y desarrollar tus aplicaciones sin realizar pagos reales. Puedes usar los [números de tarjeta de prueba](https://developer.paddle.com/concepts/payment-methods/credit-debit-card) de Paddle para simular varios escenarios de pago.

Al usar el entorno Paddle Sandbox, deberías establecer la variable de entorno `PADDLE_SANDBOX` en `true` dentro del archivo `.env` de tu aplicación:

```ini
PADDLE_SANDBOX=true
```

Después de haber terminado de desarrollar tu aplicación, puedes [solicitar una cuenta de vendedor de Paddle](https://paddle.com). Antes de que tu aplicación se coloque en producción, Paddle necesitará aprobar el dominio de tu aplicación.

<a name="configuration"></a>
## Configuración

<a name="billable-model"></a>
### Modelo Facturable

Antes de usar Cashier, debes agregar el trait `Billable` a la definición de tu modelo de usuario. Este trait proporciona varios métodos que te permiten realizar tareas de facturación comunes, como crear suscripciones y actualizar información del método de pago:

    use Laravel\Paddle\Billable;

    class User extends Authenticatable
    {
        use Billable;
    }

Si tienes entidades facturables que no son usuarios, también puedes agregar el trait a esas clases:

    use Illuminate\Database\Eloquent\Model;
    use Laravel\Paddle\Billable;

    class Team extends Model
    {
        use Billable;
    }

<a name="api-keys"></a>
### Claves API

A continuación, deberías configurar tus claves de Paddle en el archivo `.env` de tu aplicación. Puedes recuperar tus claves API de Paddle desde el panel de control de Paddle:

```ini
PADDLE_CLIENT_SIDE_TOKEN=your-paddle-client-side-token
PADDLE_API_KEY=your-paddle-api-key
PADDLE_RETAIN_KEY=your-paddle-retain-key
PADDLE_WEBHOOK_SECRET="your-paddle-webhook-secret"
PADDLE_SANDBOX=true
```

La variable de entorno `PADDLE_SANDBOX` debe establecerse en `true` cuando estés utilizando [el entorno Sandbox de Paddle](#paddle-sandbox). La variable `PADDLE_SANDBOX` debe establecerse en `false` si estás implementando tu aplicación en producción y estás utilizando el entorno de vendedor en vivo de Paddle.

La `PADDLE_RETAIN_KEY` es opcional y solo debe establecerse si estás utilizando Paddle con [Retain](https://developer.paddle.com/paddlejs/retain).

<a name="paddle-js"></a>
### Paddle JS

Paddle se basa en su propia biblioteca de JavaScript para iniciar el widget de pago de Paddle. Puedes cargar la biblioteca de JavaScript colocando la directiva Blade `@paddleJS` justo antes de la etiqueta de cierre `</head>` de la plantilla de tu aplicación:

```blade
<head>
    ...

    @paddleJS
</head>
```

<a name="currency-configuration"></a>
### Configuración de Moneda

Puedes especificar un locale que se utilizará al formatear valores monetarios para su visualización en facturas. Internamente, Cashier utiliza la clase `NumberFormatter` de [PHP](https://www.php.net/manual/en/class.numberformatter.php) para establecer el locale de la moneda:

```ini
CASHIER_CURRENCY_LOCALE=nl_BE
```

> [!WARNING]  
> Para utilizar locales diferentes a `en`, asegúrate de que la extensión `ext-intl` de PHP esté instalada y configurada en tu servidor.

<a name="overriding-default-models"></a>
### Sobrescribiendo Modelos Predeterminados

Eres libre de extender los modelos utilizados internamente por Cashier definiendo tu propio modelo y extendiendo el modelo correspondiente de Cashier:

    use Laravel\Paddle\Subscription as CashierSubscription;

    class Subscription extends CashierSubscription
    {
        // ...
    }

Después de definir tu modelo, puedes instruir a Cashier para que use tu modelo personalizado a través de la clase `Laravel\Paddle\Cashier`. Típicamente, deberías informar a Cashier sobre tus modelos personalizados en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

    use App\Models\Cashier\Subscription;
    use App\Models\Cashier\Transaction;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Cashier::useSubscriptionModel(Subscription::class);
        Cashier::useTransactionModel(Transaction::class);
    }

<a name="quickstart"></a>
## Guía Rápida

<a name="quickstart-selling-products"></a>
### Venta de Productos

> [!NOTE]  
> Antes de utilizar Paddle Checkout, deberías definir Productos con precios fijos en tu panel de Paddle. Además, deberías [configurar el manejo de webhooks de Paddle](#handling-paddle-webhooks).

Ofrecer facturación de productos y suscripciones a través de tu aplicación puede ser intimidante. Sin embargo, gracias a Cashier y [el Pago Superpuesto de Paddle](https://www.paddle.com/billing/checkout), puedes construir fácilmente integraciones de pago modernas y robustas.

Para cobrar a los clientes por productos no recurrentes y de cargo único, utilizaremos Cashier para cobrar a los clientes con el Pago Superpuesto de Paddle, donde proporcionarán sus detalles de pago y confirmarán su compra. Una vez que se haya realizado el pago a través del Pago Superpuesto, el cliente será redirigido a una URL de éxito de tu elección dentro de tu aplicación:

    use Illuminate\Http\Request;

    Route::get('/buy', function (Request $request) {
        $checkout = $request->user()->checkout('pri_deluxe_album')
            ->returnTo(route('dashboard'));

        return view('buy', ['checkout' => $checkout]);
    })->name('checkout');

Como puedes ver en el ejemplo anterior, utilizaremos el método `checkout` proporcionado por Cashier para crear un objeto de pago que presente al cliente el Pago Superpuesto de Paddle para un "identificador de precio" dado. Al usar Paddle, "precios" se refiere a [precios definidos para productos específicos](https://developer.paddle.com/build/products/create-products-prices).

Si es necesario, el método `checkout` creará automáticamente un cliente en Paddle y conectará ese registro de cliente de Paddle al usuario correspondiente en la base de datos de tu aplicación. Después de completar la sesión de pago, el cliente será redirigido a una página de éxito dedicada donde puedes mostrar un mensaje informativo al cliente.

En la vista `buy`, incluiremos un botón para mostrar el Pago Superpuesto. El componente Blade `paddle-button` está incluido con Cashier Paddle; sin embargo, también puedes [renderizar manualmente un pago superpuesto](#manually-rendering-an-overlay-checkout):

```html
<x-paddle-button :checkout="$checkout" class="px-8 py-4">
    Comprar Producto
</x-paddle-button>
```

<a name="providing-meta-data-to-paddle-checkout"></a>
#### Proporcionando Metadatos a Paddle Checkout

Al vender productos, es común hacer un seguimiento de los pedidos completados y los productos comprados a través de modelos `Cart` y `Order` definidos por tu propia aplicación. Al redirigir a los clientes al Pago Superpuesto de Paddle para completar una compra, es posible que necesites proporcionar un identificador de pedido existente para que puedas asociar la compra completada con el pedido correspondiente cuando el cliente sea redirigido de regreso a tu aplicación.

Para lograr esto, puedes proporcionar un array de datos personalizados al método `checkout`. Imaginemos que se crea un `Order` pendiente dentro de nuestra aplicación cuando un usuario comienza el proceso de pago. Recuerda, los modelos `Cart` y `Order` en este ejemplo son ilustrativos y no son proporcionados por Cashier. Eres libre de implementar estos conceptos según las necesidades de tu propia aplicación:

    use App\Models\Cart;
    use App\Models\Order;
    use Illuminate\Http\Request;

    Route::get('/cart/{cart}/checkout', function (Request $request, Cart $cart) {
        $order = Order::create([
            'cart_id' => $cart->id,
            'price_ids' => $cart->price_ids,
            'status' => 'incomplete',
        ]);

        $checkout = $request->user()->checkout($order->price_ids)
            ->customData(['order_id' => $order->id]);

        return view('billing', ['checkout' => $checkout]);
    })->name('checkout');

Como puedes ver en el ejemplo anterior, cuando un usuario comienza el proceso de pago, proporcionaremos todos los identificadores de precio de Paddle asociados con el carrito/pedido al método `checkout`. Por supuesto, tu aplicación es responsable de asociar estos elementos con el "carrito de compras" o pedido a medida que un cliente los agrega. También proporcionamos el ID del pedido al Pago Superpuesto de Paddle a través del método `customData`.

Por supuesto, es probable que desees marcar el pedido como "completo" una vez que el cliente haya terminado el proceso de pago. Para lograr esto, puedes escuchar los webhooks enviados por Paddle y generados a través de eventos por Cashier para almacenar la información del pedido en tu base de datos.

Para comenzar, escucha el evento `TransactionCompleted` enviado por Cashier. Típicamente, deberías registrar el listener del evento en el método `boot` de tu `AppServiceProvider` de la aplicación:

    use App\Listeners\CompleteOrder;
    use Illuminate\Support\Facades\Event;
    use Laravel\Paddle\Events\TransactionCompleted;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Event::listen(TransactionCompleted::class, CompleteOrder::class);
    }

En este ejemplo, el listener `CompleteOrder` podría verse como lo siguiente:

    namespace App\Listeners;

    use App\Models\Order;
    use Laravel\Cashier\Cashier;
    use Laravel\Cashier\Events\TransactionCompleted;

    class CompleteOrder
    {
        /**
         * Handle the incoming Cashier webhook event.
         */
        public function handle(TransactionCompleted $event): void
        {
            $orderId = $event->payload['data']['custom_data']['order_id'] ?? null;

            $order = Order::findOrFail($orderId);

            $order->update(['status' => 'completed']);
        }
    }

Por favor, consulta la documentación de Paddle para obtener más información sobre los [datos contenidos en el evento `transaction.completed`](https://developer.paddle.com/webhooks/transactions/transaction-completed).

<a name="quickstart-selling-subscriptions"></a>
### Venta de Suscripciones

> [!NOTE]  
> Antes de utilizar Paddle Checkout, deberías definir Productos con precios fijos en tu panel de Paddle. Además, deberías [configurar el manejo de webhooks de Paddle](#handling-paddle-webhooks).

Ofrecer facturación de productos y suscripciones a través de tu aplicación puede ser intimidante. Sin embargo, gracias a Cashier y [el Pago Superpuesto de Paddle](https://www.paddle.com/billing/checkout), puedes construir fácilmente integraciones de pago modernas y robustas.

Para aprender cómo vender suscripciones utilizando Cashier y el Pago Superpuesto de Paddle, consideremos el escenario simple de un servicio de suscripción con un plan mensual (`price_basic_monthly`) y uno anual (`price_basic_yearly`). Estos dos precios podrían agruparse bajo un producto "Básico" (`pro_basic`) en nuestro panel de Paddle. Además, nuestro servicio de suscripción podría ofrecer un plan Experto como `pro_expert`.

Primero, descubramos cómo un cliente puede suscribirse a nuestros servicios. Por supuesto, puedes imaginar que el cliente podría hacer clic en un botón de "suscribirse" para el plan Básico en la página de precios de nuestra aplicación. Este botón invocará un Pago Superpuesto de Paddle para su plan elegido. Para comenzar, iniciemos una sesión de pago a través del método `checkout`:

```markdown
    use Illuminate\Http\Request;

    Route::get('/subscribe', function (Request $request) {
        $checkout = $request->user()->checkout('price_basic_monthly')
            ->returnTo(route('dashboard'));

        return view('subscribe', ['checkout' => $checkout]);
    })->name('subscribe');

En la vista `subscribe`, incluiremos un botón para mostrar la superposición de Checkout. El componente Blade `paddle-button` se incluye con Cashier Paddle; sin embargo, también puedes [renderizar manualmente un checkout en superposición](#manually-rendering-an-overlay-checkout):

```html
<x-paddle-button :checkout="$checkout" class="px-8 py-4">
    Suscribirse
</x-paddle-button>
```

Ahora, cuando se haga clic en el botón Suscribirse, el cliente podrá ingresar sus detalles de pago e iniciar su suscripción. Para saber cuándo ha comenzado realmente su suscripción (ya que algunos métodos de pago requieren unos segundos para procesarse), también deberías [configurar el manejo de webhooks de Cashier](#handling-paddle-webhooks).

Ahora que los clientes pueden iniciar suscripciones, necesitamos restringir ciertas partes de nuestra aplicación para que solo los usuarios suscritos puedan acceder a ellas. Por supuesto, siempre podemos determinar el estado actual de la suscripción de un usuario a través del método `subscribed` proporcionado por el rasgo `Billable` de Cashier:

```blade
@if ($user->subscribed())
    <p>Estás suscrito.</p>
@endif
```

Incluso podemos determinar fácilmente si un usuario está suscrito a un producto o precio específico:

```blade
@if ($user->subscribedToProduct('pro_basic'))
    <p>You are subscribed to our Basic product.</p>
@endif

@if ($user->subscribedToPrice('price_basic_monthly'))
    <p>You are subscribed to our monthly Basic plan.</p>
@endif
```

<a name="quickstart-building-a-subscribed-middleware"></a>
#### Creando un Middleware de Suscripción

Por conveniencia, es posible que desees crear un [middleware](/docs/{{version}}/middleware) que determine si la solicitud entrante proviene de un usuario suscrito. Una vez que este middleware ha sido definido, puedes asignarlo fácilmente a una ruta para evitar que los usuarios que no están suscritos accedan a la ruta:

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Symfony\Component\HttpFoundation\Response;

    class Subscribed
    {
        /**
         * Manejar una solicitud entrante.
         */
        public function handle(Request $request, Closure $next): Response
        {
            if (! $request->user()?->subscribed()) {
                // Redirigir al usuario a la página de facturación y pedirle que se suscriba...
                return redirect('/subscribe');
            }

            return $next($request);
        }
    }

Una vez que el middleware ha sido definido, puedes asignarlo a una ruta:

    use App\Http\Middleware\Subscribed;

    Route::get('/dashboard', function () {
        // ...
    })->middleware([Subscribed::class]);

<a name="quickstart-allowing-customers-to-manage-their-billing-plan"></a>
#### Permitiendo a los Clientes Gestionar Su Plan de Facturación

Por supuesto, los clientes pueden querer cambiar su plan de suscripción a otro producto o "nivel". En nuestro ejemplo anterior, querríamos permitir que el cliente cambie su plan de una suscripción mensual a una suscripción anual. Para esto, necesitarás implementar algo como un botón que conduzca a la siguiente ruta:

    use Illuminate\Http\Request;

    Route::put('/subscription/{price}/swap', function (Request $request, $price) {
        $user->subscription()->swap($price); // Con "$price" siendo "price_basic_yearly" para este ejemplo.

        return redirect()->route('dashboard');
    })->name('subscription.swap');

Además de cambiar de planes, también necesitarás permitir que tus clientes cancelen su suscripción. Al igual que al cambiar de planes, proporciona un botón que conduzca a la siguiente ruta:

    use Illuminate\Http\Request;

    Route::put('/subscription/cancel', function (Request $request, $price) {
        $user->subscription()->cancel();

        return redirect()->route('dashboard');
    })->name('subscription.cancel');

Y ahora tu suscripción se cancelará al final de su período de facturación.

> [!NOTE]  
> Siempre que hayas configurado el manejo de webhooks de Cashier, Cashier mantendrá automáticamente las tablas de base de datos relacionadas con Cashier de tu aplicación sincronizadas al inspeccionar los webhooks entrantes de Paddle. Así que, por ejemplo, cuando canceles la suscripción de un cliente a través del panel de control de Paddle, Cashier recibirá el webhook correspondiente y marcará la suscripción como "cancelada" en la base de datos de tu aplicación.

<a name="checkout-sessions"></a>
## Sesiones de Checkout

La mayoría de las operaciones para facturar a los clientes se realizan utilizando "checkouts" a través del [widget de superposición de Checkout](https://developer.paddle.com/build/checkout/build-overlay-checkout) de Paddle o utilizando [checkout en línea](https://developer.paddle.com/build/checkout/build-branded-inline-checkout).

Antes de procesar los pagos de checkout utilizando Paddle, debes definir el [enlace de pago predeterminado](https://developer.paddle.com/build/transactions/default-payment-link#set-default-link) de tu aplicación en el panel de configuración de checkout de Paddle.

<a name="overlay-checkout"></a>
### Checkout en Superposición

Antes de mostrar el widget de superposición de Checkout, debes generar una sesión de checkout utilizando Cashier. Una sesión de checkout informará al widget de checkout sobre la operación de facturación que debe realizarse:

    use Illuminate\Http\Request;

    Route::get('/buy', function (Request $request) {
        $checkout = $user->checkout('pri_34567')
            ->returnTo(route('dashboard'));

        return view('billing', ['checkout' => $checkout]);
    });

Cashier incluye un componente Blade `paddle-button` [Blade component](/docs/{{version}}/blade#components). Puedes pasar la sesión de checkout a este componente como una "prop". Luego, cuando se haga clic en este botón, se mostrará el widget de checkout de Paddle:

```html
<x-paddle-button :checkout="$checkout" class="px-8 py-4">
    Suscribirse
</x-paddle-button>
```

Por defecto, esto mostrará el widget utilizando el estilo predeterminado de Paddle. Puedes personalizar el widget agregando [atributos compatibles con Paddle](https://developer.paddle.com/paddlejs/html-data-attributes) como el atributo `data-theme='light'` al componente:

```html
<x-paddle-button :url="$payLink" class="px-8 py-4" data-theme="light">
    Suscribirse
</x-paddle-button>
```

El widget de checkout de Paddle es asincrónico. Una vez que el usuario crea una suscripción dentro del widget, Paddle enviará a tu aplicación un webhook para que puedas actualizar correctamente el estado de la suscripción en la base de datos de tu aplicación. Por lo tanto, es importante que configures correctamente [los webhooks](#handling-paddle-webhooks) para acomodar los cambios de estado de Paddle.

> [!WARNING]  
> Después de un cambio de estado de suscripción, el retraso para recibir el webhook correspondiente es típicamente mínimo, pero debes tener esto en cuenta en tu aplicación considerando que la suscripción de tu usuario podría no estar inmediatamente disponible después de completar el checkout.

<a name="manually-rendering-an-overlay-checkout"></a>
#### Renderizando Manualmente un Checkout en Superposición

También puedes renderizar manualmente un checkout en superposición sin usar los componentes Blade integrados de Laravel. Para comenzar, genera la sesión de checkout [como se demostró en ejemplos anteriores](#overlay-checkout):

    use Illuminate\Http\Request;

    Route::get('/buy', function (Request $request) {
        $checkout = $user->checkout('pri_34567')
            ->returnTo(route('dashboard'));

        return view('billing', ['checkout' => $checkout]);
    });

A continuación, puedes usar Paddle.js para inicializar el checkout. En este ejemplo, crearemos un enlace que se le asigne la clase `paddle_button`. Paddle.js detectará esta clase y mostrará el checkout en superposición cuando se haga clic en el enlace:

```blade
<?php
$items = $checkout->getItems();
$customer = $checkout->getCustomer();
$custom = $checkout->getCustomData();
?>

<a
    href='#!'
    class='paddle_button'
    data-items='{!! json_encode($items) !!}'
    @if ($customer) data-customer-id='{{ $customer->paddle_id }}' @endif
    @if ($custom) data-custom-data='{{ json_encode($custom) }}' @endif
    @if ($returnUrl = $checkout->getReturnUrl()) data-success-url='{{ $returnUrl }}' @endif
>
    Buy Product
</a>
```

<a name="inline-checkout"></a>
### Checkout en Línea

Si no deseas utilizar el widget de checkout de estilo "superposición" de Paddle, Paddle también proporciona la opción de mostrar el widget en línea. Si bien este enfoque no te permite ajustar ninguno de los campos HTML del checkout, te permite incrustar el widget dentro de tu aplicación.

Para facilitarte el inicio con el checkout en línea, Cashier incluye un componente Blade `paddle-checkout`. Para comenzar, debes [generar una sesión de checkout](#overlay-checkout):

    use Illuminate\Http\Request;

    Route::get('/buy', function (Request $request) {
        $checkout = $user->checkout('pri_34567')
            ->returnTo(route('dashboard'));

        return view('billing', ['checkout' => $checkout]);
    });

Luego, puedes pasar la sesión de checkout al atributo `checkout` del componente:

```blade
<x-paddle-checkout :checkout="$checkout" class="w-full" />
```

Para ajustar la altura del componente de checkout en línea, puedes pasar el atributo `height` al componente Blade:

```blade
<x-paddle-checkout :checkout="$checkout" class="w-full" height="500" />
```

Consulta la [guía de Paddle sobre Checkout en Línea](https://developer.paddle.com/build/checkout/build-branded-inline-checkout) y [configuraciones de checkout disponibles](https://developer.paddle.com/build/checkout/set-up-checkout-default-settings) para más detalles sobre las opciones de personalización del checkout en línea.

<a name="manually-rendering-an-inline-checkout"></a>
#### Renderizando Manualmente un Checkout en Línea

También puedes renderizar manualmente un checkout en línea sin usar los componentes Blade integrados de Laravel. Para comenzar, genera la sesión de checkout [como se demostró en ejemplos anteriores](#inline-checkout):

    use Illuminate\Http\Request;

    Route::get('/buy', function (Request $request) {
        $checkout = $user->checkout('pri_34567')
            ->returnTo(route('dashboard'));

        return view('billing', ['checkout' => $checkout]);
    });

A continuación, puedes usar Paddle.js para inicializar el checkout. En este ejemplo, demostraremos esto usando [Alpine.js](https://github.com/alpinejs/alpine); sin embargo, puedes modificar este ejemplo para tu propia pila frontend:

```blade
<?php
$options = $checkout->options();

$options['settings']['frameTarget'] = 'paddle-checkout';
$options['settings']['frameInitialHeight'] = 366;
?>

<div class="paddle-checkout" x-data="{}" x-init="
    Paddle.Checkout.open(@json($options));
">
</div>
```

<a name="guest-checkouts"></a>
### Checkouts de Invitados

A veces, es posible que necesites crear una sesión de checkout para usuarios que no necesitan una cuenta con tu aplicación. Para hacerlo, puedes usar el método `guest`:

    use Illuminate\Http\Request;
    use Laravel\Paddle\Checkout;

    Route::get('/buy', function (Request $request) {
        $checkout = Checkout::guest('pri_34567')
            ->returnTo(route('home'));

        return view('billing', ['checkout' => $checkout]);
    });

Luego, puedes proporcionar la sesión de checkout a los componentes Blade de [botón Paddle](#overlay-checkout) o [checkout en línea](#inline-checkout).

<a name="price-previews"></a>
## Previews de Precios

Paddle te permite personalizar precios por moneda, permitiéndote configurar diferentes precios para diferentes países. Cashier Paddle te permite recuperar todos estos precios utilizando el método `previewPrices`. Este método acepta los ID de precios para los que deseas recuperar precios:

    use Laravel\Paddle\Cashier;

    $prices = Cashier::previewPrices(['pri_123', 'pri_456']);

La moneda se determinará en función de la dirección IP de la solicitud; sin embargo, puedes proporcionar opcionalmente un país específico para recuperar precios:

    use Laravel\Paddle\Cashier;

    $prices = Cashier::previewPrices(['pri_123', 'pri_456'], ['address' => [
        'country_code' => 'BE',
        'postal_code' => '1234',
    ]]);

Después de recuperar los precios, puedes mostrarlos como desees:

```blade
<ul>
    @foreach ($prices as $price)
        <li>{{ $price->product['name'] }} - {{ $price->total() }}</li>
    @endforeach
</ul>
```

También puedes mostrar el precio subtotal y el monto del impuesto por separado:

```blade
<ul>
    @foreach ($prices as $price)
        <li>{{ $price->product['name'] }} - {{ $price->subtotal() }} (+ {{ $price->tax() }} tax)</li>
    @endforeach
</ul>
```

Para más información, [consulta la documentación de la API de Paddle sobre previews de precios](https://developer.paddle.com/api-reference/pricing-preview/preview-prices).

<a name="customer-price-previews"></a>
### Previews de Precios para Clientes

Si un usuario ya es cliente y deseas mostrar los precios que se aplican a ese cliente, puedes hacerlo recuperando los precios directamente de la instancia del cliente:

    use App\Models\User;

    $prices = User::find(1)->previewPrices(['pri_123', 'pri_456']);

Internamente, Cashier utilizará el ID de cliente del usuario para recuperar los precios en su moneda. Así que, por ejemplo, un usuario que vive en los Estados Unidos verá precios en dólares estadounidenses, mientras que un usuario en Bélgica verá precios en euros. Si no se puede encontrar una moneda coincidente, se utilizará la moneda predeterminada del producto. Puedes personalizar todos los precios de un producto o plan de suscripción en el panel de control de Paddle.

<a name="price-discounts"></a>
### Descuentos

También puedes optar por mostrar precios después de un descuento. Al llamar al método `previewPrices`, proporcionas el ID de descuento a través de la opción `discount_id`:

    use Laravel\Paddle\Cashier;

    $prices = Cashier::previewPrices(['pri_123', 'pri_456'], [
        'discount_id' => 'dsc_123'
    ]);

Luego, muestra los precios calculados:

```blade
<ul>
    @foreach ($prices as $price)
        <li>{{ $price->product['name'] }} - {{ $price->total() }}</li>
    @endforeach
</ul>
```

<a name="customers"></a>
## Clientes

<a name="customer-defaults"></a>
### Valores Predeterminados de Clientes

Cashier te permite definir algunos valores predeterminados útiles para tus clientes al crear sesiones de checkout. Establecer estos valores predeterminados te permite completar automáticamente la dirección de correo electrónico y el nombre de un cliente para que puedan pasar inmediatamente a la parte de pago del widget de checkout. Puedes establecer estos valores predeterminados sobrescribiendo los siguientes métodos en tu modelo facturable:

    /**
     * Obtener el nombre del cliente para asociarlo con Paddle.
     */
    public function paddleName(): string|null
    {
        return $this->name;
    }

    /**
     * Obtener la dirección de correo electrónico del cliente para asociarla con Paddle.
     */
    public function paddleEmail(): string|null
    {
        return $this->email;
    }

Estos valores predeterminados se utilizarán para cada acción en Cashier que genere una [sesión de checkout](#checkout-sessions).

<a name="retrieving-customers"></a>
### Recuperando Clientes

Puedes recuperar un cliente por su ID de Cliente de Paddle utilizando el método `Cashier::findBillable`. Este método devolverá una instancia del modelo facturable:

    use Laravel\Cashier\Cashier;

    $user = Cashier::findBillable($customerId);

<a name="creating-customers"></a>
### Creando Clientes

Ocasionalmente, es posible que desees crear un cliente de Paddle sin comenzar una suscripción. Puedes lograr esto utilizando el método `createAsCustomer`:

    $customer = $user->createAsCustomer();

Se devuelve una instancia de `Laravel\Paddle\Customer`. Una vez que el cliente ha sido creado en Paddle, puedes comenzar una suscripción en una fecha posterior. Puedes proporcionar un array opcional `$options` para pasar cualquier [parámetro de creación de cliente adicional que sea compatible con la API de Paddle](https://developer.paddle.com/api-reference/customers/create-customer):

    $customer = $user->createAsCustomer($options);

<a name="subscriptions"></a>
## Suscripciones

<a name="creating-subscriptions"></a>
### Creando Suscripciones

Para crear una suscripción, primero recupera una instancia de tu modelo facturable de tu base de datos, que típicamente será una instancia de `App\Models\User`. Una vez que hayas recuperado la instancia del modelo, puedes usar el método `subscribe` para crear la sesión de checkout del modelo:

    use Illuminate\Http\Request;

    Route::get('/user/subscribe', function (Request $request) {
        $checkout = $request->user()->subscribe($premium = 12345, 'default')
            ->returnTo(route('home'));

        return view('billing', ['checkout' => $checkout]);
    });

El primer argumento dado al método `subscribe` es el precio específico al que el usuario se está suscribiendo. Este valor debe corresponder al identificador del precio en Paddle. El método `returnTo` acepta una URL a la que tu usuario será redirigido después de completar con éxito el checkout. El segundo argumento pasado al método `subscribe` debe ser el "tipo" interno de la suscripción. Si tu aplicación solo ofrece una única suscripción, podrías llamarlo `default` o `primary`. Este tipo de suscripción es solo para uso interno de la aplicación y no está destinado a ser mostrado a los usuarios. Además, no debe contener espacios y nunca debe cambiarse después de crear la suscripción.
```

También puede proporcionar un array de metadatos personalizados sobre la suscripción utilizando el método `customData`:

    $checkout = $request->user()->subscribe($premium = 12345, 'default')
        ->customData(['key' => 'value'])
        ->returnTo(route('home'));

Una vez que se ha creado una sesión de pago de suscripción, la sesión de pago puede ser proporcionada al componente [Blade](#overlay-checkout) `paddle-button` que se incluye con Cashier Paddle:

```blade
<x-paddle-button :checkout="$checkout" class="px-8 py-4">
    Suscribirse
</x-paddle-button>
```

Después de que el usuario haya terminado su pago, se enviará un webhook `subscription_created` desde Paddle. Cashier recibirá este webhook y configurará la suscripción para su cliente. Para asegurarse de que todos los webhooks se reciban y manejen correctamente en su aplicación, asegúrese de haber [configurado el manejo de webhooks](#handling-paddle-webhooks).

<a name="checking-subscription-status"></a>
### Comprobando el Estado de la Suscripción

Una vez que un usuario está suscrito a su aplicación, puede verificar su estado de suscripción utilizando una variedad de métodos convenientes. Primero, el método `subscribed` devuelve `true` si el usuario tiene una suscripción válida, incluso si la suscripción está actualmente dentro de su período de prueba:

    if ($user->subscribed()) {
        // ...
    }

Si su aplicación ofrece múltiples suscripciones, puede especificar la suscripción al invocar el método `subscribed`:

    if ($user->subscribed('default')) {
        // ...
    }

El método `subscribed` también es un gran candidato para un [middleware de ruta](/docs/{{version}}/middleware), lo que le permite filtrar el acceso a rutas y controladores según el estado de suscripción del usuario:

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Symfony\Component\HttpFoundation\Response;

    class EnsureUserIsSubscribed
    {
        /**
         * Manejar una solicitud entrante.
         *
         * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
         */
        public function handle(Request $request, Closure $next): Response
        {
            if ($request->user() && ! $request->user()->subscribed()) {
                // Este usuario no es un cliente que paga...
                return redirect('/billing');
            }

            return $next($request);
        }
    }

Si desea determinar si un usuario todavía está dentro de su período de prueba, puede usar el método `onTrial`. Este método puede ser útil para determinar si debe mostrar una advertencia al usuario de que todavía está en su período de prueba:

    if ($user->subscription()->onTrial()) {
        // ...
    }

El método `subscribedToPrice` puede usarse para determinar si el usuario está suscrito a un plan dado basado en un ID de precio de Paddle dado. En este ejemplo, determinaremos si la suscripción `default` del usuario está activamente suscrita al precio mensual:

    if ($user->subscribedToPrice($monthly = 'pri_123', 'default')) {
        // ...
    }

El método `recurring` puede usarse para determinar si el usuario está actualmente en una suscripción activa y ya no está dentro de su período de prueba o en un período de gracia:

    if ($user->subscription()->recurring()) {
        // ...
    }

<a name="canceled-subscription-status"></a>
#### Estado de Suscripción Cancelada

Para determinar si el usuario fue una vez un suscriptor activo pero ha cancelado su suscripción, puede usar el método `canceled`:

    if ($user->subscription()->canceled()) {
        // ...
    }

También puede determinar si un usuario ha cancelado su suscripción, pero aún está en su "período de gracia" hasta que la suscripción expire por completo. Por ejemplo, si un usuario cancela una suscripción el 5 de marzo que originalmente estaba programada para expirar el 10 de marzo, el usuario está en su "período de gracia" hasta el 10 de marzo. Además, el método `subscribed` seguirá devolviendo `true` durante este tiempo:

    if ($user->subscription()->onGracePeriod()) {
        // ...
    }

<a name="past-due-status"></a>
#### Estado de Vencimiento

Si un pago falla para una suscripción, se marcará como `past_due`. Cuando su suscripción está en este estado, no estará activa hasta que el cliente haya actualizado su información de pago. Puede determinar si una suscripción está vencida utilizando el método `pastDue` en la instancia de suscripción:

    if ($user->subscription()->pastDue()) {
        // ...
    }

Cuando una suscripción está vencida, debe instruir al usuario para que [actualice su información de pago](#updating-payment-information).

Si desea que las suscripciones se consideren válidas cuando están `past_due`, puede usar el método `keepPastDueSubscriptionsActive` proporcionado por Cashier. Típicamente, este método debe ser llamado en el método `register` de su `AppServiceProvider`:

    use Laravel\Paddle\Cashier;

    /**
     * Registrar cualquier servicio de la aplicación.
     */
    public function register(): void
    {
        Cashier::keepPastDueSubscriptionsActive();
    }

> [!WARNING]  
> Cuando una suscripción está en un estado `past_due`, no se puede cambiar hasta que se haya actualizado la información de pago. Por lo tanto, los métodos `swap` y `updateQuantity` lanzarán una excepción cuando la suscripción esté en un estado `past_due`.

<a name="subscription-scopes"></a>
#### Alcances de Suscripción

La mayoría de los estados de suscripción también están disponibles como alcances de consulta para que pueda consultar fácilmente su base de datos en busca de suscripciones que estén en un estado dado:

    // Obtener todas las suscripciones válidas...
    $subscriptions = Subscription::query()->valid()->get();

    // Obtener todas las suscripciones canceladas para un usuario...
    $subscriptions = $user->subscriptions()->canceled()->get();

Una lista completa de los alcances disponibles se encuentra a continuación:

    Subscription::query()->valid();
    Subscription::query()->onTrial();
    Subscription::query()->expiredTrial();
    Subscription::query()->notOnTrial();
    Subscription::query()->active();
    Subscription::query()->recurring();
    Subscription::query()->pastDue();
    Subscription::query()->paused();
    Subscription::query()->notPaused();
    Subscription::query()->onPausedGracePeriod();
    Subscription::query()->notOnPausedGracePeriod();
    Subscription::query()->canceled();
    Subscription::query()->notCanceled();
    Subscription::query()->onGracePeriod();
    Subscription::query()->notOnGracePeriod();

<a name="subscription-single-charges"></a>
### Cargos Únicos de Suscripción

Los cargos únicos de suscripción le permiten cobrar a los suscriptores con un cargo único además de sus suscripciones. Debe proporcionar uno o varios ID de precio al invocar el método `charge`:

    // Cargar un precio único...
    $response = $user->subscription()->charge('pri_123');

    // Cargar múltiples precios a la vez...
    $response = $user->subscription()->charge(['pri_123', 'pri_456']);

El método `charge` no cobrará realmente al cliente hasta el próximo intervalo de facturación de su suscripción. Si desea facturar al cliente de inmediato, puede usar el método `chargeAndInvoice` en su lugar:

    $response = $user->subscription()->chargeAndInvoice('pri_123');

<a name="updating-payment-information"></a>
### Actualizando la Información de Pago

Paddle siempre guarda un método de pago por suscripción. Si desea actualizar el método de pago predeterminado para una suscripción, debe redirigir a su cliente a la página de actualización de método de pago alojada por Paddle utilizando el método `redirectToUpdatePaymentMethod` en el modelo de suscripción:

    use Illuminate\Http\Request;

    Route::get('/update-payment-method', function (Request $request) {
        $user = $request->user();

        return $user->subscription()->redirectToUpdatePaymentMethod();
    });

Cuando un usuario ha terminado de actualizar su información, un webhook `subscription_updated` será enviado por Paddle y los detalles de la suscripción se actualizarán en la base de datos de su aplicación.

<a name="changing-plans"></a>
### Cambiando Planes

Después de que un usuario se haya suscrito a su aplicación, puede querer cambiar a un nuevo plan de suscripción. Para actualizar el plan de suscripción de un usuario, debe pasar el identificador del precio de Paddle al método `swap` de la suscripción:

    use App\Models\User;

    $user = User::find(1);

    $user->subscription()->swap($premium = 'pri_456');

Si desea cambiar de planes y facturar al usuario de inmediato en lugar de esperar su próximo ciclo de facturación, puede usar el método `swapAndInvoice`:

    $user = User::find(1);

    $user->subscription()->swapAndInvoice($premium = 'pri_456');

<a name="prorations"></a>
#### Prorrateos

Por defecto, Paddle prorratea los cargos al cambiar entre planes. El método `noProrate` puede usarse para actualizar las suscripciones sin prorratear los cargos:

    $user->subscription('default')->noProrate()->swap($premium = 'pri_456');

Si desea desactivar el prorrateo y facturar a los clientes de inmediato, puede usar el método `swapAndInvoice` en combinación con `noProrate`:

    $user->subscription('default')->noProrate()->swapAndInvoice($premium = 'pri_456');

O, para no cobrar a su cliente por un cambio de suscripción, puede utilizar el método `doNotBill`:

    $user->subscription('default')->doNotBill()->swap($premium = 'pri_456');

Para obtener más información sobre las políticas de prorrateo de Paddle, consulte la [documentación de prorrateo](https://developer.paddle.com/concepts/subscriptions/proration).

<a name="subscription-quantity"></a>
### Cantidad de Suscripción

A veces, las suscripciones se ven afectadas por la "cantidad". Por ejemplo, una aplicación de gestión de proyectos podría cobrar $10 por mes por proyecto. Para incrementar o decrementar fácilmente la cantidad de su suscripción, use los métodos `incrementQuantity` y `decrementQuantity`:

    $user = User::find(1);

    $user->subscription()->incrementQuantity();

    // Agregar cinco a la cantidad actual de la suscripción...
    $user->subscription()->incrementQuantity(5);

    $user->subscription()->decrementQuantity();

    // Restar cinco de la cantidad actual de la suscripción...
    $user->subscription()->decrementQuantity(5);

Alternativamente, puede establecer una cantidad específica utilizando el método `updateQuantity`:

    $user->subscription()->updateQuantity(10);

El método `noProrate` puede usarse para actualizar la cantidad de la suscripción sin prorratear los cargos:

    $user->subscription()->noProrate()->updateQuantity(10);

<a name="quantities-for-subscription-with-multiple-products"></a>
#### Cantidades para Suscripciones con Múltiples Productos

Si su suscripción es una [suscripción con múltiples productos](#subscriptions-with-multiple-products), debe pasar el ID del precio cuya cantidad desea incrementar o decrementar como segundo argumento a los métodos de incremento / decremento:

    $user->subscription()->incrementQuantity(1, 'price_chat');

<a name="subscriptions-with-multiple-products"></a>
### Suscripciones con Múltiples Productos

[La suscripción con múltiples productos](https://developer.paddle.com/build/subscriptions/add-remove-products-prices-addons) le permite asignar múltiples productos de facturación a una sola suscripción. Por ejemplo, imagine que está construyendo una aplicación de "mesa de ayuda" de servicio al cliente que tiene un precio base de suscripción de $10 por mes, pero ofrece un producto adicional de chat en vivo por $15 adicionales por mes.

Al crear sesiones de pago de suscripción, puede especificar múltiples productos para una suscripción dada pasando un array de precios como primer argumento al método `subscribe`:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $checkout = $request->user()->subscribe([
            'price_monthly',
            'price_chat',
        ]);

        return view('billing', ['checkout' => $checkout]);
    });

En el ejemplo anterior, el cliente tendrá dos precios adjuntos a su suscripción `default`. Ambos precios se cobrarán en sus respectivos intervalos de facturación. Si es necesario, puede pasar un array asociativo de pares clave / valor para indicar una cantidad específica para cada precio:

    $user = User::find(1);

    $checkout = $user->subscribe('default', ['price_monthly', 'price_chat' => 5]);

Si desea agregar otro precio a una suscripción existente, debe usar el método `swap` de la suscripción. Al invocar el método `swap`, también debe incluir los precios y cantidades actuales de la suscripción:

    $user = User::find(1);

    $user->subscription()->swap(['price_chat', 'price_original' => 2]);

El ejemplo anterior agregará el nuevo precio, pero el cliente no será facturado por él hasta su próximo ciclo de facturación. Si desea facturar al cliente de inmediato, puede usar el método `swapAndInvoice`:

    $user->subscription()->swapAndInvoice(['price_chat', 'price_original' => 2]);

Puede eliminar precios de las suscripciones utilizando el método `swap` y omitiendo el precio que desea eliminar:

    $user->subscription()->swap(['price_original' => 2]);

> [!WARNING]  
> No puede eliminar el último precio de una suscripción. En su lugar, simplemente debe cancelar la suscripción.

<a name="multiple-subscriptions"></a>
### Múltiples Suscripciones

Paddle permite a sus clientes tener múltiples suscripciones simultáneamente. Por ejemplo, puede tener un gimnasio que ofrece una suscripción de natación y una suscripción de levantamiento de pesas, y cada suscripción puede tener diferentes precios. Por supuesto, los clientes deberían poder suscribirse a uno o ambos planes.

Cuando su aplicación crea suscripciones, puede proporcionar el tipo de suscripción al método `subscribe` como segundo argumento. El tipo puede ser cualquier cadena que represente el tipo de suscripción que el usuario está iniciando:

    use Illuminate\Http\Request;

    Route::post('/swimming/subscribe', function (Request $request) {
        $checkout = $request->user()->subscribe($swimmingMonthly = 'pri_123', 'swimming');

        return view('billing', ['checkout' => $checkout]);
    });

En este ejemplo, iniciamos una suscripción mensual de natación para el cliente. Sin embargo, puede querer cambiar a una suscripción anual en un momento posterior. Al ajustar la suscripción del cliente, simplemente podemos cambiar el precio en la suscripción `swimming`:

    $user->subscription('swimming')->swap($swimmingYearly = 'pri_456');

Por supuesto, también puede cancelar la suscripción por completo:

    $user->subscription('swimming')->cancel();

<a name="pausing-subscriptions"></a>
### Pausando Suscripciones

Para pausar una suscripción, llame al método `pause` en la suscripción del usuario:

    $user->subscription()->pause();

Cuando una suscripción está pausada, Cashier establecerá automáticamente la columna `paused_at` en su base de datos. Esta columna se utiliza para determinar cuándo el método `paused` debe comenzar a devolver `true`. Por ejemplo, si un cliente pausa una suscripción el 1 de marzo, pero la suscripción no estaba programada para renovarse hasta el 5 de marzo, el método `paused` seguirá devolviendo `false` hasta el 5 de marzo. Esto se debe a que generalmente se permite a un usuario continuar utilizando una aplicación hasta el final de su ciclo de facturación.

Por defecto, la pausa ocurre en el siguiente intervalo de facturación para que el cliente pueda usar el resto del período por el que pagó. Si desea pausar una suscripción de inmediato, puede usar el método `pauseNow`:

    $user->subscription()->pauseNow();

Usando el método `pauseUntil`, puede pausar la suscripción hasta un momento específico:

```markdown
    $user->subscription()->pauseUntil(now()->addMonth());

O, puede usar el método `pauseNowUntil` para pausar inmediatamente la suscripción hasta un momento dado:

    $user->subscription()->pauseNowUntil(now()->addMonth());

Puede determinar si un usuario ha pausado su suscripción pero aún está en su "período de gracia" utilizando el método `onPausedGracePeriod`:

    if ($user->subscription()->onPausedGracePeriod()) {
        // ...
    }

Para reanudar una suscripción pausada, puede invocar el método `resume` en la suscripción:

    $user->subscription()->resume();

> [!WARNING]  
> No se puede modificar una suscripción mientras está pausada. Si desea cambiar a un plan diferente o actualizar cantidades, primero debe reanudar la suscripción.

<a name="canceling-subscriptions"></a>
### Cancelando Suscripciones

Para cancelar una suscripción, llame al método `cancel` en la suscripción del usuario:

    $user->subscription()->cancel();

Cuando se cancela una suscripción, Cashier establecerá automáticamente la columna `ends_at` en su base de datos. Esta columna se utiliza para determinar cuándo el método `subscribed` debe comenzar a devolver `false`. Por ejemplo, si un cliente cancela una suscripción el 1 de marzo, pero la suscripción no estaba programada para finalizar hasta el 5 de marzo, el método `subscribed` seguirá devolviendo `true` hasta el 5 de marzo. Esto se hace porque generalmente se permite a un usuario continuar utilizando una aplicación hasta el final de su ciclo de facturación.

Puede determinar si un usuario ha cancelado su suscripción pero aún está en su "período de gracia" utilizando el método `onGracePeriod`:

    if ($user->subscription()->onGracePeriod()) {
        // ...
    }

Si desea cancelar una suscripción de inmediato, puede llamar al método `cancelNow` en la suscripción:

    $user->subscription()->cancelNow();

Para detener que una suscripción en su período de gracia se cancele, puede invocar el método `stopCancelation`:

    $user->subscription()->stopCancelation();

> [!WARNING]  
> Las suscripciones de Paddle no se pueden reanudar después de la cancelación. Si su cliente desea reanudar su suscripción, deberá crear una nueva suscripción.

<a name="subscription-trials"></a>
## Pruebas de Suscripción

<a name="with-payment-method-up-front"></a>
### Con Método de Pago por Adelantado

Si desea ofrecer períodos de prueba a sus clientes mientras aún recopila información del método de pago por adelantado, debe establecer un tiempo de prueba en el panel de control de Paddle en el precio al que su cliente se está suscribiendo. Luego, inicie la sesión de pago como de costumbre:

    use Illuminate\Http\Request;

    Route::get('/user/subscribe', function (Request $request) {
        $checkout = $request->user()->subscribe('pri_monthly')
                    ->returnTo(route('home'));

        return view('billing', ['checkout' => $checkout]);
    });

Cuando su aplicación recibe el evento `subscription_created`, Cashier establecerá la fecha de finalización del período de prueba en el registro de suscripción dentro de la base de datos de su aplicación, así como instruir a Paddle para no comenzar a facturar al cliente hasta después de esta fecha.

> [!WARNING]  
> Si la suscripción del cliente no se cancela antes de la fecha de finalización del período de prueba, se le cobrará tan pronto como expire el período de prueba, por lo que debe asegurarse de notificar a sus usuarios sobre la fecha de finalización de su prueba.

Puede determinar si el usuario está dentro de su período de prueba utilizando el método `onTrial` de la instancia de usuario o el método `onTrial` de la instancia de suscripción. Los dos ejemplos a continuación son equivalentes:

    if ($user->onTrial()) {
        // ...
    }

    if ($user->subscription()->onTrial()) {
        // ...
    }
Para determinar si un período de prueba existente ha expirado, puede usar los métodos `hasExpiredTrial`:

    if ($user->hasExpiredTrial()) {
        // ...
    }

    if ($user->subscription()->hasExpiredTrial()) {
        // ...
    }

Para determinar si un usuario está en prueba para un tipo de suscripción específico, puede proporcionar el tipo a los métodos `onTrial` o `hasExpiredTrial`:

    if ($user->onTrial('default')) {
        // ...
    }

    if ($user->hasExpiredTrial('default')) {
        // ...
    }

<a name="without-payment-method-up-front"></a>
### Sin Método de Pago por Adelantado

Si desea ofrecer períodos de prueba sin recopilar la información del método de pago del usuario por adelantado, puede establecer la columna `trial_ends_at` en el registro del cliente asociado a su usuario a la fecha de finalización de prueba deseada. Esto se hace típicamente durante el registro del usuario:

    use App\Models\User;

    $user = User::create([
        // ...
    ]);

    $user->createAsCustomer([
        'trial_ends_at' => now()->addDays(10)
    ]);

Cashier se refiere a este tipo de prueba como una "prueba genérica", ya que no está asociada a ninguna suscripción existente. El método `onTrial` en la instancia de `User` devolverá `true` si la fecha actual no ha pasado el valor de `trial_ends_at`:

    if ($user->onTrial()) {
        // El usuario está dentro de su período de prueba...
    }

Una vez que esté listo para crear una suscripción real para el usuario, puede usar el método `subscribe` como de costumbre:

    use Illuminate\Http\Request;

    Route::get('/user/subscribe', function (Request $request) {
        $checkout = $user->subscribe('pri_monthly')
            ->returnTo(route('home'));

        return view('billing', ['checkout' => $checkout]);
    });

Para recuperar la fecha de finalización del período de prueba del usuario, puede usar el método `trialEndsAt`. Este método devolverá una instancia de fecha Carbon si un usuario está en un período de prueba o `null` si no lo está. También puede pasar un parámetro opcional de tipo de suscripción si desea obtener la fecha de finalización del período de prueba para una suscripción específica que no sea la predeterminada:

    if ($user->onTrial('default')) {
        $trialEndsAt = $user->trialEndsAt();
    }

Puede usar el método `onGenericTrial` si desea saber específicamente que el usuario está dentro de su período de prueba "genérico" y no ha creado una suscripción real aún:

    if ($user->onGenericTrial()) {
        // El usuario está dentro de su período de prueba "genérico"...
    }

<a name="extend-or-activate-a-trial"></a>
### Extender o Activar un Período de Prueba

Puede extender un período de prueba existente en una suscripción invocando el método `extendTrial` y especificando el momento en que debe finalizar el período de prueba:

    $user->subscription()->extendTrial(now()->addDays(5));

O, puede activar inmediatamente una suscripción finalizando su período de prueba llamando al método `activate` en la suscripción:

    $user->subscription()->activate();

<a name="handling-paddle-webhooks"></a>
## Manejo de Webhooks de Paddle

Paddle puede notificar a su aplicación sobre una variedad de eventos a través de webhooks. Por defecto, una ruta que apunta al controlador de webhooks de Cashier está registrada por el proveedor de servicios de Cashier. Este controlador manejará todas las solicitudes de webhook entrantes.

Por defecto, este controlador manejará automáticamente la cancelación de suscripciones que tienen demasiados cargos fallidos, actualizaciones de suscripción y cambios en el método de pago; sin embargo, como pronto descubriremos, puede extender este controlador para manejar cualquier evento de webhook de Paddle que desee.

Para asegurarse de que su aplicación pueda manejar webhooks de Paddle, asegúrese de [configurar la URL del webhook en el panel de control de Paddle](https://vendors.paddle.com/alerts-webhooks). Por defecto, el controlador de webhooks de Cashier responde a la ruta de URL `/paddle/webhook`. La lista completa de todos los webhooks que debe habilitar en el panel de control de Paddle son:

- Cliente Actualizado
- Transacción Completada
- Transacción Actualizada
- Suscripción Creada
- Suscripción Actualizada
- Suscripción Pausada
- Suscripción Cancelada

> [!WARNING]  
> Asegúrese de proteger las solicitudes entrantes con la [verificación de firma de webhook](/docs/{{version}}/cashier-paddle#verifying-webhook-signatures) incluida en Cashier.

<a name="webhooks-csrf-protection"></a>
#### Webhooks y Protección CSRF

Dado que los webhooks de Paddle necesitan eludir la [protección CSRF](/docs/{{version}}/csrf) de Laravel, debe asegurarse de que Laravel no intente verificar el token CSRF para los webhooks de Paddle entrantes. Para lograr esto, debe excluir `paddle/*` de la protección CSRF en el archivo `bootstrap/app.php` de su aplicación:

    ->withMiddleware(function (Middleware $middleware) {
        $middleware->validateCsrfTokens(except: [
            'paddle/*',
        ]);
    })

<a name="webhooks-local-development"></a>
#### Webhooks y Desarrollo Local

Para que Paddle pueda enviar webhooks a su aplicación durante el desarrollo local, necesitará exponer su aplicación a través de un servicio de compartición de sitios como [Ngrok](https://ngrok.com/) o [Expose](https://expose.dev/docs/introduction). Si está desarrollando su aplicación localmente utilizando [Laravel Sail](/docs/{{version}}/sail), puede usar el [comando de compartición de sitios](/docs/{{version}}/sail#sharing-your-site) de Sail.

<a name="defining-webhook-event-handlers"></a>
### Definiendo Controladores de Eventos de Webhook

Cashier maneja automáticamente la cancelación de suscripciones en cargos fallidos y otros webhooks comunes de Paddle. Sin embargo, si tiene eventos de webhook adicionales que le gustaría manejar, puede hacerlo escuchando los siguientes eventos que son despachados por Cashier:

- `Laravel\Paddle\Events\WebhookReceived`
- `Laravel\Paddle\Events\WebhookHandled`

Ambos eventos contienen la carga útil completa del webhook de Paddle. Por ejemplo, si desea manejar el webhook `transaction.billed`, puede registrar un [escuchador](/docs/{{version}}/events#defining-listeners) que manejará el evento:

    <?php

    namespace App\Listeners;

    use Laravel\Paddle\Events\WebhookReceived;

    class PaddleEventListener
    {
        /**
         * Manejar webhooks de Paddle recibidos.
         */
        public function handle(WebhookReceived $event): void
        {
            if ($event->payload['event_type'] === 'transaction.billed') {
                // Manejar el evento entrante...
            }
        }
    }

Cashier también emite eventos dedicados al tipo de webhook recibido. Además de la carga útil completa de Paddle, también contienen los modelos relevantes que se utilizaron para procesar el webhook, como el modelo facturable, la suscripción o el recibo:

<div class="content-list" markdown="1">

- `Laravel\Paddle\Events\CustomerUpdated`
- `Laravel\Paddle\Events\TransactionCompleted`
- `Laravel\Paddle\Events\TransactionUpdated`
- `Laravel\Paddle\Events\SubscriptionCreated`
- `Laravel\Paddle\Events\SubscriptionUpdated`
- `Laravel\Paddle\Events\SubscriptionPaused`
- `Laravel\Paddle\Events\SubscriptionCanceled`

</div>

También puede anular la ruta de webhook incorporada predeterminada definiendo la variable de entorno `CASHIER_WEBHOOK` en el archivo `.env` de su aplicación. Este valor debe ser la URL completa de su ruta de webhook y debe coincidir con la URL establecida en su panel de control de Paddle:

```ini
CASHIER_WEBHOOK=https://example.com/my-paddle-webhook-url
```

<a name="verifying-webhook-signatures"></a>
### Verificando Firmas de Webhook

Para asegurar sus webhooks, puede usar [las firmas de webhook de Paddle](https://developer.paddle.com/webhook-reference/verifying-webhooks). Para su conveniencia, Cashier incluye automáticamente un middleware que valida que la solicitud de webhook de Paddle entrante sea válida.

Para habilitar la verificación de webhook, asegúrese de que la variable de entorno `PADDLE_WEBHOOK_SECRET` esté definida en el archivo `.env` de su aplicación. El secreto del webhook se puede recuperar del panel de control de su cuenta de Paddle.

<a name="single-charges"></a>
## Cargos Únicos

<a name="charging-for-products"></a>
### Cobrando por Productos

Si desea iniciar una compra de producto para un cliente, puede usar el método `checkout` en una instancia de modelo facturable para generar una sesión de pago para la compra. El método `checkout` acepta uno o varios ID de precio. Si es necesario, se puede usar un array asociativo para proporcionar la cantidad del producto que se está comprando:

    use Illuminate\Http\Request;

    Route::get('/buy', function (Request $request) {
        $checkout = $request->user()->checkout(['pri_tshirt', 'pri_socks' => 5]);

        return view('buy', ['checkout' => $checkout]);
    });

Después de generar la sesión de pago, puede usar el componente [Blade `paddle-button`](#overlay-checkout) proporcionado por Cashier para permitir que el usuario vea el widget de pago de Paddle y complete la compra:

```blade
<x-paddle-button :checkout="$checkout" class="px-8 py-4">
    Comprar
</x-paddle-button>
```

Una sesión de pago tiene un método `customData`, que le permite pasar cualquier dato personalizado que desee a la creación de la transacción subyacente. Consulte [la documentación de Paddle](https://developer.paddle.com/build/transactions/custom-data) para obtener más información sobre las opciones disponibles al pasar datos personalizados:

    $checkout = $user->checkout('pri_tshirt')
        ->customData([
            'custom_option' => $value,
        ]);

<a name="refunding-transactions"></a>
### Reembolsando Transacciones

Reembolsar transacciones devolverá la cantidad reembolsada al método de pago de su cliente que se utilizó en el momento de la compra. Si necesita reembolsar una compra de Paddle, puede usar el método `refund` en un modelo `Cashier\Paddle\Transaction`. Este método acepta un motivo como primer argumento, uno o más ID de precio para reembolsar con cantidades opcionales como un array asociativo. Puede recuperar las transacciones para un modelo facturable dado utilizando el método `transactions`.

Por ejemplo, imaginemos que queremos reembolsar una transacción específica por los precios `pri_123` y `pri_456`. Queremos reembolsar completamente `pri_123`, pero solo reembolsar dos dólares por `pri_456`:

    use App\Models\User;

    $user = User::find(1);

    $transaction = $user->transactions()->first();

    $response = $transaction->refund('Cargo accidental', [
        'pri_123', // Reembolsar completamente este precio...
        'pri_456' => 200, // Solo reembolsar parcialmente este precio...
    ]);

El ejemplo anterior reembolsa elementos de línea específicos en una transacción. Si desea reembolsar toda la transacción, simplemente proporcione un motivo:

    $response = $transaction->refund('Cargo accidental');

Para obtener más información sobre reembolsos, consulte [la documentación de reembolsos de Paddle](https://developer.paddle.com/build/transactions/create-transaction-adjustments).

> [!WARNING]  
> Los reembolsos siempre deben ser aprobados por Paddle antes de ser procesados completamente.

<a name="crediting-transactions"></a>
### Acreditando Transacciones

Al igual que con los reembolsos, también puede acreditar transacciones. Acreditar transacciones añadirá fondos al saldo del cliente para que puedan ser utilizados para futuras compras. Acreditar transacciones solo se puede hacer para transacciones recolectadas manualmente y no para transacciones recolectadas automáticamente (como suscripciones) ya que Paddle maneja los créditos de suscripción automáticamente:

    $transaction = $user->transactions()->first();

    // Acreditar un elemento de línea específico completamente...
    $response = $transaction->credit('Compensación', 'pri_123');

Para más información, [vea la documentación de Paddle sobre acreditación](https://developer.paddle.com/build/transactions/create-transaction-adjustments).

> [!WARNING]  
> Los créditos solo se pueden aplicar a transacciones recolectadas manualmente. Las transacciones recolectadas automáticamente son acreditadas por Paddle.

<a name="transactions"></a>
## Transacciones

Puede recuperar fácilmente un array de las transacciones de un modelo facturable a través de la propiedad `transactions`:

    use App\Models\User;

    $user = User::find(1);

    $transactions = $user->transactions;

Las transacciones representan pagos por sus productos y compras y están acompañadas de facturas. Solo se almacenan en la base de datos de su aplicación las transacciones completadas.
```

Cuando listes las transacciones de un cliente, puedes usar los métodos de la instancia de transacción para mostrar la información de pago relevante. Por ejemplo, puedes desear listar cada transacción en una tabla, permitiendo al usuario descargar fácilmente cualquiera de las facturas:

```html
<table>
    @foreach ($transactions as $transaction)
        <tr>
            <td>{{ $transaction->billed_at->toFormattedDateString() }}</td>
            <td>{{ $transaction->total() }}</td>
            <td>{{ $transaction->tax() }}</td>
            <td><a href="{{ route('download-invoice', $transaction->id) }}" target="_blank">Download</a></td>
        </tr>
    @endforeach
</table>
```

La ruta `download-invoice` puede verse como la siguiente:

    use Illuminate\Http\Request;
    use Laravel\Cashier\Transaction;

    Route::get('/download-invoice/{transaction}', function (Request $request, Transaction $transaction) {
        return $transaction->redirectToInvoicePdf();
    })->name('download-invoice');

<a name="past-and-upcoming-payments"></a>
### Pagos Pasados y Futuros

Puedes usar los métodos `lastPayment` y `nextPayment` para recuperar y mostrar los pagos pasados o futuros de un cliente para suscripciones recurrentes:

    use App\Models\User;

    $user = User::find(1);

    $subscription = $user->subscription();

    $lastPayment = $subscription->lastPayment();
    $nextPayment = $subscription->nextPayment();

Ambos métodos devolverán una instancia de `Laravel\Paddle\Payment`; sin embargo, `lastPayment` devolverá `null` cuando las transacciones no hayan sido sincronizadas por webhooks aún, mientras que `nextPayment` devolverá `null` cuando el ciclo de facturación haya terminado (como cuando una suscripción ha sido cancelada):

```blade
Next payment: {{ $nextPayment->amount() }} due on {{ $nextPayment->date()->format('d/m/Y') }}
```

<a name="testing"></a>
## Pruebas

Mientras pruebas, debes probar manualmente tu flujo de facturación para asegurarte de que tu integración funcione como se espera.

Para pruebas automatizadas, incluyendo aquellas ejecutadas dentro de un entorno CI, puedes usar [Laravel's HTTP Client](/docs/{{version}}/http-client#testing) para simular llamadas HTTP realizadas a Paddle. Aunque esto no prueba las respuestas reales de Paddle, proporciona una forma de probar tu aplicación sin llamar realmente a la API de Paddle.
