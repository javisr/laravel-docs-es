# Laravel Cashier (Stripe)

- [Laravel Cashier (Stripe)](#laravel-cashier-stripe)
  - [Introducción](#introducción)
  - [Actualizando Cashier](#actualizando-cashier)
  - [Instalación](#instalación)
  - [Configuración](#configuración)
    - [Modelo Facturable](#modelo-facturable)
    - [Claves API](#claves-api)
    - [Configuración de Moneda](#configuración-de-moneda)
    - [Configuración de Impuestos](#configuración-de-impuestos)
    - [Registro](#registro)
    - [Uso de Modelos Personalizados](#uso-de-modelos-personalizados)
  - [Guía Rápida](#guía-rápida)
    - [Venta de Productos](#venta-de-productos)
      - [Proporcionando Meta Datos a Stripe Checkout](#proporcionando-meta-datos-a-stripe-checkout)
    - [Venta de Suscripciones](#venta-de-suscripciones)
      - [Creando un Middleware de Suscripción](#creando-un-middleware-de-suscripción)
      - [Permitiendo a los Clientes Gestionar Su Plan de Facturación](#permitiendo-a-los-clientes-gestionar-su-plan-de-facturación)
  - [Clientes](#clientes)
    - [Recuperando Clientes](#recuperando-clientes)
    - [Creando Clientes](#creando-clientes)
    - [Actualizando Clientes](#actualizando-clientes)
    - [Saldos](#saldos)
    - [IDs de Impuestos](#ids-de-impuestos)
    - [Sincronizando Datos de Clientes con Stripe](#sincronizando-datos-de-clientes-con-stripe)
    - [Portal de Facturación](#portal-de-facturación)
  - [Métodos de Pago](#métodos-de-pago)
    - [Almacenando Métodos de Pago](#almacenando-métodos-de-pago)
      - [Métodos de Pago para Suscripciones](#métodos-de-pago-para-suscripciones)
      - [Métodos de Pago para Cargos Únicos](#métodos-de-pago-para-cargos-únicos)
    - [Recuperando Métodos de Pago](#recuperando-métodos-de-pago)
    - [Presencia del Método de Pago](#presencia-del-método-de-pago)
    - [Actualizando el Método de Pago Predeterminado](#actualizando-el-método-de-pago-predeterminado)
    - [Agregando Métodos de Pago](#agregando-métodos-de-pago)
    - [Eliminando Métodos de Pago](#eliminando-métodos-de-pago)
  - [Suscripciones](#suscripciones)
    - [Creando Suscripciones](#creando-suscripciones)
      - [Recolección de Pagos Recurrentes a través de Correos Electrónicos de Factura](#recolección-de-pagos-recurrentes-a-través-de-correos-electrónicos-de-factura)
      - [Cantidades](#cantidades)
      - [Detalles Adicionales](#detalles-adicionales)
      - [Cupones](#cupones)
      - [Agregando Suscripciones](#agregando-suscripciones)
      - [Creando Suscripciones Desde el Panel de Control de Stripe](#creando-suscripciones-desde-el-panel-de-control-de-stripe)
    - [Comprobando el Estado de la Suscripción](#comprobando-el-estado-de-la-suscripción)
      - [Estado de Suscripción Cancelada](#estado-de-suscripción-cancelada)
      - [Estado Incompleto y Vencido](#estado-incompleto-y-vencido)
      - [Alcances de Suscripción](#alcances-de-suscripción)
    - [Cambiando Precios](#cambiando-precios)
      - [Prorrateos](#prorrateos)
    - [Cantidad de Suscripción](#cantidad-de-suscripción)
      - [Cantidades para Suscripciones con Múltiples Productos](#cantidades-para-suscripciones-con-múltiples-productos)
    - [Suscripciones con Múltiples Productos](#suscripciones-con-múltiples-productos)
      - [Cambiando Precios](#cambiando-precios-1)
      - [Prorrateo](#prorrateo)
      - [Cantidades](#cantidades-1)
      - [Elementos de Suscripción](#elementos-de-suscripción)
    - [Múltiples Suscripciones](#múltiples-suscripciones)
    - [Facturación Medida](#facturación-medida)
      - [Reportando Uso](#reportando-uso)
      - [Recuperando Registros de Uso](#recuperando-registros-de-uso)
    - [Impuestos de Suscripción](#impuestos-de-suscripción)
      - [Sincronizando Tasas de Impuestos](#sincronizando-tasas-de-impuestos)
      - [Exención de Impuestos](#exención-de-impuestos)
    - [Fecha Ancla de Suscripción](#fecha-ancla-de-suscripción)
    - [Cancelando Suscripciones](#cancelando-suscripciones)
    - [Reanudando Suscripciones](#reanudando-suscripciones)
  - [Pruebas de Suscripción](#pruebas-de-suscripción)
    - [Con Método de Pago por Adelantado](#con-método-de-pago-por-adelantado)
      - [Definiendo Días de Prueba en Stripe / Cashier](#definiendo-días-de-prueba-en-stripe--cashier)
    - [Sin Método de Pago por Adelantado](#sin-método-de-pago-por-adelantado)
      - [Webhooks y Protección CSRF](#webhooks-y-protección-csrf)
    - [Definiendo Manejadores de Eventos de Webhook](#definiendo-manejadores-de-eventos-de-webhook)
    - [Verificando Firmas de Webhook](#verificando-firmas-de-webhook)
  - [Cargos Únicos](#cargos-únicos)
    - [Cargo Simple](#cargo-simple)
    - [Cargo con Factura](#cargo-con-factura)
    - [Creando Intenciones de Pago](#creando-intenciones-de-pago)
    - [Reembolsando Cargos](#reembolsando-cargos)
  - [Facturas](#facturas)
    - [Recuperando Facturas](#recuperando-facturas)
      - [Mostrando Información de la Factura](#mostrando-información-de-la-factura)
    - [Facturas Próximas](#facturas-próximas)
    - [Previsualizando Facturas de Suscripción](#previsualizando-facturas-de-suscripción)
    - [Generando PDFs de Factura](#generando-pdfs-de-factura)
      - [Renderizador de Factura Personalizado](#renderizador-de-factura-personalizado)
  - [Checkout](#checkout)
    - [Product Checkouts](#product-checkouts)
      - [Promotion Codes](#promotion-codes)
    - [Single Charge Checkouts](#single-charge-checkouts)
    - [Subscription Checkouts](#subscription-checkouts)
      - [Stripe Checkout and Trial Periods](#stripe-checkout-and-trial-periods)
      - [Subscriptions and Webhooks](#subscriptions-and-webhooks)
    - [Collecting Tax IDs](#collecting-tax-ids)
    - [Guest Checkouts](#guest-checkouts)
  - [Handling Failed Payments](#handling-failed-payments)
    - [Confirming Payments](#confirming-payments)
  - [Strong Customer Authentication](#strong-customer-authentication)
    - [Payments Requiring Additional Confirmation](#payments-requiring-additional-confirmation)
      - [Estado Incompleto y Vencido](#estado-incompleto-y-vencido-1)
    - [Notificaciones de Pago Fuera de Sesión](#notificaciones-de-pago-fuera-de-sesión)
  - [Stripe SDK](#stripe-sdk)
  - [Pruebas](#pruebas)

<a name="introduction"></a>
## Introducción

[Laravel Cashier Stripe](https://github.com/laravel/cashier-stripe) proporciona una interfaz expresiva y fluida para los servicios de facturación de suscripciones de [Stripe](https://stripe.com). Maneja casi todo el código de facturación de suscripciones que temes tener que escribir. Además de la gestión básica de suscripciones, Cashier puede manejar cupones, intercambio de suscripciones, "cantidades" de suscripción, períodos de gracia para cancelaciones e incluso generar PDFs de facturas.

<a name="upgrading-cashier"></a>
## Actualizando Cashier

Al actualizar a una nueva versión de Cashier, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/cashier-stripe/blob/master/UPGRADE.md).

> [!WARNING]  
> Para prevenir cambios que rompan la compatibilidad, Cashier utiliza una versión fija de la API de Stripe. Cashier 15 utiliza la versión de la API de Stripe `2023-10-16`. La versión de la API de Stripe se actualizará en lanzamientos menores para aprovechar nuevas características y mejoras de Stripe.

<a name="installation"></a>
## Instalación

Primero, instala el paquete Cashier para Stripe usando el gestor de paquetes Composer:

```shell
composer require laravel/cashier
```

Después de instalar el paquete, publica las migraciones de Cashier usando el comando Artisan `vendor:publish`:

```shell
php artisan vendor:publish --tag="cashier-migrations"
```

Luego, migra tu base de datos:

```shell
php artisan migrate
```

Las migraciones de Cashier agregarán varias columnas a tu tabla `users`. También crearán una nueva tabla `subscriptions` para contener todas las suscripciones de tus clientes y una tabla `subscription_items` para suscripciones con múltiples precios.

Si lo deseas, también puedes publicar el archivo de configuración de Cashier usando el comando Artisan `vendor:publish`:

```shell
php artisan vendor:publish --tag="cashier-config"
```

Por último, para asegurarte de que Cashier maneje correctamente todos los eventos de Stripe, recuerda [configurar el manejo de webhooks de Cashier](#handling-stripe-webhooks).

> [!WARNING]  
> Stripe recomienda que cualquier columna utilizada para almacenar identificadores de Stripe sea sensible a mayúsculas y minúsculas. Por lo tanto, debes asegurarte de que la colación de la columna `stripe_id` esté configurada como `utf8_bin` al usar MySQL. Más información sobre esto se puede encontrar en la [documentación de Stripe](https://stripe.com/docs/upgrades#what-changes-does-stripe-consider-to-be-backwards-compatible).

<a name="configuration"></a>
## Configuración

<a name="billable-model"></a>
### Modelo Facturable

Antes de usar Cashier, agrega el trait `Billable` a la definición de tu modelo facturable. Típicamente, este será el modelo `App\Models\User`. Este trait proporciona varios métodos que te permiten realizar tareas de facturación comunes, como crear suscripciones, aplicar cupones y actualizar la información del método de pago:

    use Laravel\Cashier\Billable;

    class User extends Authenticatable
    {
        use Billable;
    }

Cashier asume que tu modelo facturable será la clase `App\Models\User` que se incluye con Laravel. Si deseas cambiar esto, puedes especificar un modelo diferente a través del método `useCustomerModel`. Este método debería ser llamado típicamente en el método `boot` de tu clase `AppServiceProvider`:

    use App\Models\Cashier\User;
    use Laravel\Cashier\Cashier;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Cashier::useCustomerModel(User::class);
    }

> [!WARNING]  
> Si estás usando un modelo diferente al modelo `App\Models\User` proporcionado por Laravel, necesitarás publicar y alterar las [migraciones de Cashier](#installation) proporcionadas para que coincidan con el nombre de la tabla de tu modelo alternativo.

<a name="api-keys"></a>
### Claves API

A continuación, debes configurar tus claves API de Stripe en el archivo `.env` de tu aplicación. Puedes recuperar tus claves API de Stripe desde el panel de control de Stripe:

```ini
STRIPE_KEY=your-stripe-key
STRIPE_SECRET=your-stripe-secret
STRIPE_WEBHOOK_SECRET=your-stripe-webhook-secret
```

> [!WARNING]  
> Debes asegurarte de que la variable de entorno `STRIPE_WEBHOOK_SECRET` esté definida en el archivo `.env` de tu aplicación, ya que esta variable se utiliza para asegurar que los webhooks entrantes sean realmente de Stripe.

<a name="currency-configuration"></a>
### Configuración de Moneda

La moneda predeterminada de Cashier es el Dólar Estadounidense (USD). Puedes cambiar la moneda predeterminada configurando la variable de entorno `CASHIER_CURRENCY` dentro del archivo `.env` de tu aplicación:

```ini
CASHIER_CURRENCY=eur
```

Además de configurar la moneda de Cashier, también puedes especificar un locale que se utilizará al formatear valores monetarios para su visualización en facturas. Internamente, Cashier utiliza la [clase `NumberFormatter` de PHP](https://www.php.net/manual/en/class.numberformatter.php) para establecer el locale de la moneda:

```ini
CASHIER_CURRENCY_LOCALE=nl_BE
```

> [!WARNING]  
> Para usar locales diferentes a `en`, asegúrate de que la extensión PHP `ext-intl` esté instalada y configurada en tu servidor.

<a name="tax-configuration"></a>
### Configuración de Impuestos

Gracias a [Stripe Tax](https://stripe.com/tax), es posible calcular automáticamente los impuestos para todas las facturas generadas por Stripe. Puedes habilitar el cálculo automático de impuestos invocando el método `calculateTaxes` en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

    use Laravel\Cashier\Cashier;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Cashier::calculateTaxes();
    }

Una vez que se ha habilitado el cálculo de impuestos, cualquier nueva suscripción y cualquier factura única que se genere recibirán el cálculo automático de impuestos.

Para que esta función funcione correctamente, los detalles de facturación de tu cliente, como el nombre del cliente, la dirección y el ID de impuestos, deben estar sincronizados con Stripe. Puedes usar los métodos de [sincronización de datos de clientes](#syncing-customer-data-with-stripe) y [ID de Impuestos](#tax-ids) que ofrece Cashier para lograr esto.

<a name="logging"></a>
### Registro

Cashier te permite especificar el canal de registro que se utilizará al registrar errores fatales de Stripe. Puedes especificar el canal de registro definiendo la variable de entorno `CASHIER_LOGGER` dentro del archivo `.env` de tu aplicación:

```ini
CASHIER_LOGGER=stack
```

Las excepciones que se generen por llamadas a la API de Stripe se registrarán a través del canal de registro predeterminado de tu aplicación.

<a name="using-custom-models"></a>
### Uso de Modelos Personalizados

Eres libre de extender los modelos utilizados internamente por Cashier definiendo tu propio modelo y extendiendo el modelo correspondiente de Cashier:

    use Laravel\Cashier\Subscription as CashierSubscription;

    class Subscription extends CashierSubscription
    {
        // ...
    }

Después de definir tu modelo, puedes instruir a Cashier para que use tu modelo personalizado a través de la clase `Laravel\Cashier\Cashier`. Típicamente, deberías informar a Cashier sobre tus modelos personalizados en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

    use App\Models\Cashier\Subscription;
    use App\Models\Cashier\SubscriptionItem;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Cashier::useSubscriptionModel(Subscription::class);
        Cashier::useSubscriptionItemModel(SubscriptionItem::class);
    }

<a name="quickstart"></a>
## Guía Rápida

<a name="quickstart-selling-products"></a>
### Venta de Productos

> [!NOTE]  
> Antes de utilizar Stripe Checkout, debes definir Productos con precios fijos en tu panel de Stripe. Además, debes [configurar el manejo de webhooks de Cashier](#handling-stripe-webhooks).

Ofrecer facturación de productos y suscripciones a través de tu aplicación puede ser intimidante. Sin embargo, gracias a Cashier y [Stripe Checkout](https://stripe.com/payments/checkout), puedes construir fácilmente integraciones de pago modernas y robustas.

Para cobrar a los clientes por productos no recurrentes y de cargo único, utilizaremos Cashier para dirigir a los clientes a Stripe Checkout, donde proporcionarán sus detalles de pago y confirmarán su compra. Una vez que se haya realizado el pago a través de Checkout, el cliente será redirigido a una URL de éxito de tu elección dentro de tu aplicación:

    use Illuminate\Http\Request;

    Route::get('/checkout', function (Request $request) {
        $stripePriceId = 'price_deluxe_album';

        $quantity = 1;

        return $request->user()->checkout([$stripePriceId => $quantity], [
            'success_url' => route('checkout-success'),
            'cancel_url' => route('checkout-cancel'),
        ]);
    })->name('checkout');

    Route::view('/checkout/success', 'checkout.success')->name('checkout-success');
    Route::view('/checkout/cancel', 'checkout.cancel')->name('checkout-cancel');

Como puedes ver en el ejemplo anterior, utilizaremos el método `checkout` proporcionado por Cashier para redirigir al cliente a Stripe Checkout para un "identificador de precio" dado. Al usar Stripe, "precios" se refiere a [precios definidos para productos específicos](https://stripe.com/docs/products-prices/how-products-and-prices-work).

Si es necesario, el método `checkout` creará automáticamente un cliente en Stripe y conectará ese registro de cliente de Stripe al usuario correspondiente en la base de datos de tu aplicación. Después de completar la sesión de checkout, el cliente será redirigido a una página de éxito o cancelación dedicada donde podrás mostrar un mensaje informativo al cliente.

<a name="providing-meta-data-to-stripe-checkout"></a>
#### Proporcionando Meta Datos a Stripe Checkout

Al vender productos, es común hacer un seguimiento de los pedidos completados y los productos comprados a través de modelos `Cart` y `Order` definidos por tu propia aplicación. Al redirigir a los clientes a Stripe Checkout para completar una compra, es posible que necesites proporcionar un identificador de pedido existente para que puedas asociar la compra completada con el pedido correspondiente cuando el cliente sea redirigido de vuelta a tu aplicación.

Para lograr esto, puedes proporcionar un array de `metadata` al método `checkout`. Imaginemos que se crea un `Order` pendiente dentro de nuestra aplicación cuando un usuario comienza el proceso de checkout. Recuerda, los modelos `Cart` y `Order` en este ejemplo son ilustrativos y no son proporcionados por Cashier. Eres libre de implementar estos conceptos según las necesidades de tu propia aplicación:

    use App\Models\Cart;
    use App\Models\Order;
    use Illuminate\Http\Request;

    Route::get('/cart/{cart}/checkout', function (Request $request, Cart $cart) {
        $order = Order::create([
            'cart_id' => $cart->id,
            'price_ids' => $cart->price_ids,
            'status' => 'incomplete',
        ]);

        return $request->user()->checkout($order->price_ids, [
            'success_url' => route('checkout-success').'?session_id={CHECKOUT_SESSION_ID}',
            'cancel_url' => route('checkout-cancel'),
            'metadata' => ['order_id' => $order->id],
        ]);
    })->name('checkout');

Como puedes ver en el ejemplo anterior, cuando un usuario comienza el proceso de checkout, proporcionaremos todos los identificadores de precios de Stripe asociados al carrito / pedido al método `checkout`. Por supuesto, tu aplicación es responsable de asociar estos elementos con el "carrito de compras" o pedido a medida que el cliente los agrega. También proporcionamos el ID del pedido a la sesión de Checkout de Stripe a través del array `metadata`. Finalmente, hemos agregado la variable de plantilla `CHECKOUT_SESSION_ID` a la ruta de éxito de Checkout. Cuando Stripe redirija a los clientes de vuelta a tu aplicación, esta variable de plantilla se poblará automáticamente con el ID de sesión de Checkout.

A continuación, construyamos la ruta de éxito de Checkout. Esta es la ruta a la que los usuarios serán redirigidos después de que su compra se haya completado a través de Stripe Checkout. Dentro de esta ruta, podemos recuperar el ID de sesión de Checkout de Stripe y la instancia de Checkout de Stripe asociada para acceder a nuestros metadatos proporcionados y actualizar el pedido de nuestro cliente en consecuencia:

```php
    use App\Models\Order;
    use Illuminate\Http\Request;
    use Laravel\Cashier\Cashier;

    Route::get('/checkout/success', function (Request $request) {
        $sessionId = $request->get('session_id');

        if ($sessionId === null) {
            return;
        }

        $session = Cashier::stripe()->checkout->sessions->retrieve($sessionId);

        if ($session->payment_status !== 'paid') {
            return;
        }

        $orderId = $session['metadata']['order_id'] ?? null;

        $order = Order::findOrFail($orderId);

        $order->update(['status' => 'completed']);

        return view('checkout-success', ['order' => $order]);
    })->name('checkout-success');
```

Por favor, consulta la documentación de Stripe para más información sobre los [datos contenidos en el objeto de sesión de Checkout](https://stripe.com/docs/api/checkout/sessions/object).

<a name="quickstart-selling-subscriptions"></a>
### Venta de Suscripciones

> [!NOTE]  
> Antes de utilizar Stripe Checkout, debes definir Productos con precios fijos en tu panel de control de Stripe. Además, debes [configurar el manejo de webhooks de Cashier](#handling-stripe-webhooks).

Ofrecer facturación de productos y suscripciones a través de tu aplicación puede ser intimidante. Sin embargo, gracias a Cashier y [Stripe Checkout](https://stripe.com/payments/checkout), puedes construir fácilmente integraciones de pago modernas y robustas.

Para aprender cómo vender suscripciones utilizando Cashier y Stripe Checkout, consideremos el simple escenario de un servicio de suscripción con un plan mensual básico (`price_basic_monthly`) y un plan anual (`price_basic_yearly`). Estos dos precios podrían agruparse bajo un producto "Básico" (`pro_basic`) en nuestro panel de control de Stripe. Además, nuestro servicio de suscripción podría ofrecer un plan Experto como `pro_expert`.

Primero, descubramos cómo un cliente puede suscribirse a nuestros servicios. Por supuesto, puedes imaginar que el cliente podría hacer clic en un botón de "suscribirse" para el plan Básico en la página de precios de nuestra aplicación. Este botón o enlace debería dirigir al usuario a una ruta de Laravel que crea la sesión de Stripe Checkout para su plan elegido:

    use Illuminate\Http\Request;

    Route::get('/subscription-checkout', function (Request $request) {
        return $request->user()
            ->newSubscription('default', 'price_basic_monthly')
            ->trialDays(5)
            ->allowPromotionCodes()
            ->checkout([
                'success_url' => route('your-success-route'),
                'cancel_url' => route('your-cancel-route'),
            ]);
    });

Como puedes ver en el ejemplo anterior, redirigiremos al cliente a una sesión de Stripe Checkout que le permitirá suscribirse a nuestro plan Básico. Después de un checkout exitoso o una cancelación, el cliente será redirigido de vuelta a la URL que proporcionamos al método `checkout`. Para saber cuándo su suscripción ha comenzado realmente (ya que algunos métodos de pago requieren unos segundos para procesarse), también necesitaremos [configurar el manejo de webhooks de Cashier](#handling-stripe-webhooks).

Ahora que los clientes pueden iniciar suscripciones, necesitamos restringir ciertas partes de nuestra aplicación para que solo los usuarios suscritos puedan acceder a ellas. Por supuesto, siempre podemos determinar el estado actual de la suscripción de un usuario a través del método `subscribed` proporcionado por el trait `Billable` de Cashier:

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

Para mayor comodidad, es posible que desees crear un [middleware](/docs/{{version}}/middleware) que determine si la solicitud entrante proviene de un usuario suscrito. Una vez que este middleware ha sido definido, puedes asignarlo fácilmente a una ruta para evitar que los usuarios que no están suscritos accedan a la ruta:

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
                return redirect('/billing');
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

Por supuesto, los clientes pueden querer cambiar su plan de suscripción a otro producto o "nivel". La forma más fácil de permitir esto es dirigiendo a los clientes al [Portal de Facturación del Cliente](https://stripe.com/docs/no-code/customer-portal) de Stripe, que proporciona una interfaz de usuario alojada que permite a los clientes descargar facturas, actualizar su método de pago y cambiar planes de suscripción.

Primero, define un enlace o botón dentro de tu aplicación que dirija a los usuarios a una ruta de Laravel que utilizaremos para iniciar una sesión del Portal de Facturación:

```blade
<a href="{{ route('billing') }}">
    Facturación
</a>
```

A continuación, definamos la ruta que inicia una sesión del Portal de Facturación del Cliente de Stripe y redirige al usuario al Portal. El método `redirectToBillingPortal` acepta la URL a la que los usuarios deben ser devueltos al salir del Portal:

    use Illuminate\Http\Request;

    Route::get('/billing', function (Request $request) {
        return $request->user()->redirectToBillingPortal(route('dashboard'));
    })->middleware(['auth'])->name('billing');

> [!NOTE]  
> Siempre que hayas configurado el manejo de webhooks de Cashier, Cashier mantendrá automáticamente las tablas de base de datos relacionadas con Cashier en tu aplicación sincronizadas al inspeccionar los webhooks entrantes de Stripe. Así que, por ejemplo, cuando un usuario cancela su suscripción a través del Portal de Facturación del Cliente de Stripe, Cashier recibirá el webhook correspondiente y marcará la suscripción como "cancelada" en la base de datos de tu aplicación.

<a name="customers"></a>
## Clientes

<a name="retrieving-customers"></a>
### Recuperando Clientes

Puedes recuperar un cliente por su ID de Stripe utilizando el método `Cashier::findBillable`. Este método devolverá una instancia del modelo facturable:

    use Laravel\Cashier\Cashier;

    $user = Cashier::findBillable($stripeId);

<a name="creating-customers"></a>
### Creando Clientes

Ocasionalmente, es posible que desees crear un cliente de Stripe sin comenzar una suscripción. Puedes lograr esto utilizando el método `createAsStripeCustomer`:

    $stripeCustomer = $user->createAsStripeCustomer();

Una vez que el cliente ha sido creado en Stripe, puedes comenzar una suscripción en una fecha posterior. Puedes proporcionar un array opcional `$options` para pasar cualquier [parámetro de creación de cliente que sea compatible con la API de Stripe](https://stripe.com/docs/api/customers/create):

    $stripeCustomer = $user->createAsStripeCustomer($options);

Puedes usar el método `asStripeCustomer` si deseas devolver el objeto de cliente de Stripe para un modelo facturable:

    $stripeCustomer = $user->asStripeCustomer();

El método `createOrGetStripeCustomer` puede ser utilizado si deseas recuperar el objeto de cliente de Stripe para un modelo facturable dado, pero no estás seguro de si el modelo facturable ya es un cliente dentro de Stripe. Este método creará un nuevo cliente en Stripe si no existe uno:

    $stripeCustomer = $user->createOrGetStripeCustomer();

<a name="updating-customers"></a>
### Actualizando Clientes

Ocasionalmente, es posible que desees actualizar directamente el cliente de Stripe con información adicional. Puedes lograr esto utilizando el método `updateStripeCustomer`. Este método acepta un array de [opciones de actualización de cliente compatibles con la API de Stripe](https://stripe.com/docs/api/customers/update):

    $stripeCustomer = $user->updateStripeCustomer($options);

<a name="balances"></a>
### Saldos

Stripe te permite acreditar o debitar el "saldo" de un cliente. Más tarde, este saldo será acreditado o debitado en nuevas facturas. Para verificar el saldo total del cliente, puedes usar el método `balance` que está disponible en tu modelo facturable. El método `balance` devolverá una representación de cadena formateada del saldo en la moneda del cliente:

    $balance = $user->balance();

Para acreditar el saldo de un cliente, puedes proporcionar un valor al método `creditBalance`. Si lo deseas, también puedes proporcionar una descripción:

    $user->creditBalance(500, 'Recarga de cliente premium.');

Proporcionar un valor al método `debitBalance` debitará el saldo del cliente:

    $user->debitBalance(300, 'Penalización por mal uso.');

El método `applyBalance` creará nuevas transacciones de saldo para el cliente. Puedes recuperar estos registros de transacciones utilizando el método `balanceTransactions`, que puede ser útil para proporcionar un registro de créditos y débitos para que el cliente lo revise:

    // Recuperar todas las transacciones...
    $transactions = $user->balanceTransactions();

    foreach ($transactions as $transaction) {
        // Monto de la transacción...
        $amount = $transaction->amount(); // $2.31

        // Recuperar la factura relacionada cuando esté disponible...
        $invoice = $transaction->invoice();
    }

<a name="tax-ids"></a>
### IDs de Impuestos

Cashier ofrece una forma fácil de gestionar los IDs de impuestos de un cliente. Por ejemplo, el método `taxIds` puede ser utilizado para recuperar todos los [IDs de impuestos](https://stripe.com/docs/api/customer_tax_ids/object) que están asignados a un cliente como una colección:

    $taxIds = $user->taxIds();

También puedes recuperar un ID de impuesto específico para un cliente por su identificador:

    $taxId = $user->findTaxId('txi_belgium');

Puedes crear un nuevo ID de impuesto proporcionando un [tipo](https://stripe.com/docs/api/customer_tax_ids/object#tax_id_object-type) y valor válidos al método `createTaxId`:

    $taxId = $user->createTaxId('eu_vat', 'BE0123456789');

El método `createTaxId` añadirá inmediatamente el ID de IVA a la cuenta del cliente. [La verificación de los IDs de IVA también es realizada por Stripe](https://stripe.com/docs/invoicing/customer/tax-ids#validation); sin embargo, este es un proceso asincrónico. Puedes ser notificado de las actualizaciones de verificación suscribiéndote al evento de webhook `customer.tax_id.updated` e inspeccionando el parámetro de `verificación` de los IDs de IVA [aquí](https://stripe.com/docs/api/customer_tax_ids/object#tax_id_object-verification). Para más información sobre el manejo de webhooks, consulta la [documentación sobre la definición de manejadores de webhooks](#handling-stripe-webhooks).

Puedes eliminar un ID de impuesto utilizando el método `deleteTaxId`:

    $user->deleteTaxId('txi_belgium');

<a name="syncing-customer-data-with-stripe"></a>
### Sincronizando Datos de Clientes con Stripe

Típicamente, cuando los usuarios de tu aplicación actualizan su nombre, dirección de correo electrónico u otra información que también es almacenada por Stripe, debes informar a Stripe sobre las actualizaciones. Al hacerlo, la copia de la información de Stripe estará sincronizada con la de tu aplicación.

Para automatizar esto, puedes definir un listener de eventos en tu modelo facturable que reaccione al evento `updated` del modelo. Luego, dentro de tu listener de eventos, puedes invocar el método `syncStripeCustomerDetails` en el modelo:

    use App\Models\User;
    use function Illuminate\Events\queueable;

    /**
     * El método "booted" del modelo.
     */
    protected static function booted(): void
    {
        static::updated(queueable(function (User $customer) {
            if ($customer->hasStripeId()) {
                $customer->syncStripeCustomerDetails();
            }
        }));
    }

Ahora, cada vez que se actualice tu modelo de cliente, su información se sincronizará con Stripe. Para mayor comodidad, Cashier sincronizará automáticamente la información de tu cliente con Stripe en la creación inicial del cliente.

Puedes personalizar las columnas utilizadas para sincronizar la información del cliente con Stripe sobrescribiendo una variedad de métodos proporcionados por Cashier. Por ejemplo, puedes sobrescribir el método `stripeName` para personalizar el atributo que debe considerarse como el "nombre" del cliente cuando Cashier sincroniza la información del cliente con Stripe:

    /**
     * Obtener el nombre del cliente que debe ser sincronizado con Stripe.
     */
    public function stripeName(): string|null
    {
        return $this->company_name;
    }

De manera similar, puedes sobrescribir los métodos `stripeEmail`, `stripePhone`, `stripeAddress` y `stripePreferredLocales`. Estos métodos sincronizarán la información con sus parámetros correspondientes del cliente al [actualizar el objeto de cliente de Stripe](https://stripe.com/docs/api/customers/update). Si deseas tener control total sobre el proceso de sincronización de la información del cliente, puedes sobrescribir el método `syncStripeCustomerDetails`.

<a name="billing-portal"></a>
### Portal de Facturación

Stripe ofrece [una forma fácil de configurar un portal de facturación](https://stripe.com/docs/billing/subscriptions/customer-portal) para que tu cliente pueda gestionar su suscripción, métodos de pago y ver su historial de facturación. Puedes redirigir a tus usuarios al portal de facturación invocando el método `redirectToBillingPortal` en el modelo facturable desde un controlador o ruta:

    use Illuminate\Http\Request;

    Route::get('/billing-portal', function (Request $request) {
        return $request->user()->redirectToBillingPortal();
    });

Por defecto, cuando el usuario termine de gestionar su suscripción, podrá regresar a la ruta `home` de tu aplicación a través de un enlace dentro del portal de facturación de Stripe. Puedes proporcionar una URL personalizada a la que el usuario debería regresar pasando la URL como argumento al método `redirectToBillingPortal`:

    use Illuminate\Http\Request;

    Route::get('/billing-portal', function (Request $request) {
        return $request->user()->redirectToBillingPortal(route('billing'));
    });

Si deseas generar la URL al portal de facturación sin generar una respuesta de redirección HTTP, puedes invocar el método `billingPortalUrl`:

    $url = $request->user()->billingPortalUrl(route('billing'));

<a name="payment-methods"></a>
## Métodos de Pago

<a name="storing-payment-methods"></a>
### Almacenando Métodos de Pago

Para crear suscripciones o realizar cargos "únicos" con Stripe, necesitarás almacenar un método de pago y recuperar su identificador de Stripe. El enfoque utilizado para lograr esto difiere según si planeas usar el método de pago para suscripciones o cargos únicos, así que examinaremos ambos a continuación.

<a name="payment-methods-for-subscriptions"></a>
#### Métodos de Pago para Suscripciones

Al almacenar la información de la tarjeta de crédito de un cliente para su uso futuro en una suscripción, se debe utilizar la API de "Setup Intents" de Stripe para recopilar de manera segura los detalles del método de pago del cliente. Un "Setup Intent" indica a Stripe la intención de cargar el método de pago de un cliente. El trait `Billable` de Cashier incluye el método `createSetupIntent` para crear fácilmente un nuevo Setup Intent. Debes invocar este método desde la ruta o controlador que renderizará el formulario que recopila los detalles del método de pago de tu cliente:

```php
    return view('update-payment-method', [
        'intent' => $user->createSetupIntent()
    ]);
```

Después de haber creado el Setup Intent y haberlo pasado a la vista, debes adjuntar su secreto al elemento que recopilará el método de pago. Por ejemplo, considera este formulario de "actualizar método de pago":

```html
<input id="card-holder-name" type="text">

<!-- Stripe Elements Placeholder -->
<div id="card-element"></div>

<button id="card-button" data-secret="{{ $intent->client_secret }}">
    Update Payment Method
</button>
```

A continuación, se puede utilizar la biblioteca Stripe.js para adjuntar un [Stripe Element](https://stripe.com/docs/stripe-js) al formulario y recopilar de manera segura los detalles de pago del cliente:

```html
<script src="https://js.stripe.com/v3/"></script>

<script>
    const stripe = Stripe('stripe-public-key');

    const elements = stripe.elements();
    const cardElement = elements.create('card');

    cardElement.mount('#card-element');
</script>
```

Luego, la tarjeta puede ser verificada y se puede recuperar un "identificador de método de pago" seguro de Stripe utilizando [el método `confirmCardSetup` de Stripe](https://stripe.com/docs/js/setup_intents/confirm_card_setup):

```js
const cardHolderName = document.getElementById('card-holder-name');
const cardButton = document.getElementById('card-button');
const clientSecret = cardButton.dataset.secret;

cardButton.addEventListener('click', async (e) => {
    const { setupIntent, error } = await stripe.confirmCardSetup(
        clientSecret, {
            payment_method: {
                card: cardElement,
                billing_details: { name: cardHolderName.value }
            }
        }
    );

    if (error) {
        // Display "error.message" to the user...
    } else {
        // The card has been verified successfully...
    }
});
```

Después de que la tarjeta haya sido verificada por Stripe, puedes pasar el identificador resultante `setupIntent.payment_method` a tu aplicación Laravel, donde puede ser adjuntado al cliente. El método de pago puede ser [agregado como un nuevo método de pago](#adding-payment-methods) o [utilizado para actualizar el método de pago predeterminado](#updating-the-default-payment-method). También puedes usar inmediatamente el identificador del método de pago para [crear una nueva suscripción](#creating-subscriptions).

> [!NOTE]  
> Si deseas más información sobre Setup Intents y la recopilación de detalles de pago del cliente, por favor [revisa esta descripción general proporcionada por Stripe](https://stripe.com/docs/payments/save-and-reuse#php).

<a name="payment-methods-for-single-charges"></a>
#### Métodos de Pago para Cargos Únicos

Por supuesto, al realizar un cargo único contra el método de pago de un cliente, solo necesitaremos usar un identificador de método de pago una vez. Debido a las limitaciones de Stripe, no puedes usar el método de pago predeterminado almacenado de un cliente para cargos únicos. Debes permitir que el cliente ingrese los detalles de su método de pago utilizando la biblioteca Stripe.js. Por ejemplo, considera el siguiente formulario:

```html
<input id="card-holder-name" type="text">

<!-- Stripe Elements Placeholder -->
<div id="card-element"></div>

<button id="card-button">
    Process Payment
</button>
```

Después de definir dicho formulario, se puede utilizar la biblioteca Stripe.js para adjuntar un [Stripe Element](https://stripe.com/docs/stripe-js) al formulario y recopilar de manera segura los detalles de pago del cliente:

```html
<script src="https://js.stripe.com/v3/"></script>

<script>
    const stripe = Stripe('stripe-public-key');

    const elements = stripe.elements();
    const cardElement = elements.create('card');

    cardElement.mount('#card-element');
</script>
```

A continuación, la tarjeta puede ser verificada y se puede recuperar un "identificador de método de pago" seguro de Stripe utilizando [el método `createPaymentMethod` de Stripe](https://stripe.com/docs/stripe-js/reference#stripe-create-payment-method):

```js
const cardHolderName = document.getElementById('card-holder-name');
const cardButton = document.getElementById('card-button');

cardButton.addEventListener('click', async (e) => {
    const { paymentMethod, error } = await stripe.createPaymentMethod(
        'card', cardElement, {
            billing_details: { name: cardHolderName.value }
        }
    );

    if (error) {
        // Display "error.message" to the user...
    } else {
        // The card has been verified successfully...
    }
});
```

Si la tarjeta se verifica con éxito, puedes pasar el `paymentMethod.id` a tu aplicación Laravel y procesar un [cargo único](#simple-charge).

<a name="retrieving-payment-methods"></a>
### Recuperando Métodos de Pago

El método `paymentMethods` en la instancia del modelo facturable devuelve una colección de instancias de `Laravel\Cashier\PaymentMethod`:

    $paymentMethods = $user->paymentMethods();

Por defecto, este método devolverá métodos de pago de cada tipo. Para recuperar métodos de pago de un tipo específico, puedes pasar el `type` como argumento al método:

    $paymentMethods = $user->paymentMethods('sepa_debit');

Para recuperar el método de pago predeterminado del cliente, se puede utilizar el método `defaultPaymentMethod`:

    $paymentMethod = $user->defaultPaymentMethod();

Puedes recuperar un método de pago específico que esté adjunto al modelo facturable utilizando el método `findPaymentMethod`:

    $paymentMethod = $user->findPaymentMethod($paymentMethodId);

<a name="payment-method-presence"></a>
### Presencia del Método de Pago

Para determinar si un modelo facturable tiene un método de pago predeterminado adjunto a su cuenta, invoca el método `hasDefaultPaymentMethod`:

    if ($user->hasDefaultPaymentMethod()) {
        // ...
    }

Puedes usar el método `hasPaymentMethod` para determinar si un modelo facturable tiene al menos un método de pago adjunto a su cuenta:

    if ($user->hasPaymentMethod()) {
        // ...
    }

Este método determinará si el modelo facturable tiene algún método de pago en absoluto. Para determinar si existe un método de pago de un tipo específico para el modelo, puedes pasar el `type` como argumento al método:

    if ($user->hasPaymentMethod('sepa_debit')) {
        // ...
    }

<a name="updating-the-default-payment-method"></a>
### Actualizando el Método de Pago Predeterminado

El método `updateDefaultPaymentMethod` se puede utilizar para actualizar la información del método de pago predeterminado de un cliente. Este método acepta un identificador de método de pago de Stripe y asignará el nuevo método de pago como el método de pago predeterminado de facturación:

    $user->updateDefaultPaymentMethod($paymentMethod);

Para sincronizar la información de tu método de pago predeterminado con la información del método de pago predeterminado del cliente en Stripe, puedes usar el método `updateDefaultPaymentMethodFromStripe`:

    $user->updateDefaultPaymentMethodFromStripe();

> [!WARNING]  
> El método de pago predeterminado de un cliente solo puede ser utilizado para facturación y creación de nuevas suscripciones. Debido a las limitaciones impuestas por Stripe, no puede ser utilizado para cargos únicos.

<a name="adding-payment-methods"></a>
### Agregando Métodos de Pago

Para agregar un nuevo método de pago, puedes llamar al método `addPaymentMethod` en el modelo facturable, pasando el identificador del método de pago:

    $user->addPaymentMethod($paymentMethod);

> [!NOTE]  
> Para aprender cómo recuperar identificadores de métodos de pago, por favor revisa la [documentación de almacenamiento de métodos de pago](#storing-payment-methods).

<a name="deleting-payment-methods"></a>
### Eliminando Métodos de Pago

Para eliminar un método de pago, puedes llamar al método `delete` en la instancia de `Laravel\Cashier\PaymentMethod` que deseas eliminar:

    $paymentMethod->delete();

El método `deletePaymentMethod` eliminará un método de pago específico del modelo facturable:

    $user->deletePaymentMethod('pm_visa');

El método `deletePaymentMethods` eliminará toda la información del método de pago para el modelo facturable:

    $user->deletePaymentMethods();

Por defecto, este método eliminará métodos de pago de cada tipo. Para eliminar métodos de pago de un tipo específico, puedes pasar el `type` como argumento al método:

    $user->deletePaymentMethods('sepa_debit');

> [!WARNING]  
> Si un usuario tiene una suscripción activa, tu aplicación no debería permitirle eliminar su método de pago predeterminado.

<a name="subscriptions"></a>
## Suscripciones

Las suscripciones proporcionan una forma de establecer pagos recurrentes para tus clientes. Las suscripciones de Stripe gestionadas por Cashier ofrecen soporte para múltiples precios de suscripción, cantidades de suscripción, pruebas y más.

<a name="creating-subscriptions"></a>
### Creando Suscripciones

Para crear una suscripción, primero recupera una instancia de tu modelo facturable, que típicamente será una instancia de `App\Models\User`. Una vez que hayas recuperado la instancia del modelo, puedes usar el método `newSubscription` para crear la suscripción del modelo:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $request->user()->newSubscription(
            'default', 'price_monthly'
        )->create($request->paymentMethodId);

        // ...
    });

El primer argumento pasado al método `newSubscription` debe ser el tipo interno de la suscripción. Si tu aplicación solo ofrece una única suscripción, podrías llamarla `default` o `primary`. Este tipo de suscripción es solo para uso interno de la aplicación y no está destinado a ser mostrado a los usuarios. Además, no debe contener espacios y nunca debe ser cambiado después de crear la suscripción. El segundo argumento es el precio específico al que el usuario se está suscribiendo. Este valor debe corresponder al identificador del precio en Stripe.

El método `create`, que acepta [un identificador de método de pago de Stripe](#storing-payment-methods) o un objeto `PaymentMethod` de Stripe, comenzará la suscripción y actualizará tu base de datos con el ID de cliente de Stripe del modelo facturable y otra información de facturación relevante.

> [!WARNING]  
> Pasar un identificador de método de pago directamente al método de suscripción `create` también lo agregará automáticamente a los métodos de pago almacenados del usuario.

<a name="collecting-recurring-payments-via-invoice-emails"></a>
#### Recolección de Pagos Recurrentes a través de Correos Electrónicos de Factura

En lugar de recopilar automáticamente los pagos recurrentes de un cliente, puedes instruir a Stripe para que envíe un correo electrónico con una factura al cliente cada vez que su pago recurrente esté vencido. Luego, el cliente puede pagar manualmente la factura una vez que la reciba. El cliente no necesita proporcionar un método de pago por adelantado al recopilar pagos recurrentes a través de facturas:

    $user->newSubscription('default', 'price_monthly')->createAndSendInvoice();

El tiempo que un cliente tiene para pagar su factura antes de que su suscripción sea cancelada está determinado por la opción `days_until_due`. Por defecto, esto es 30 días; sin embargo, puedes proporcionar un valor específico para esta opción si lo deseas:

    $user->newSubscription('default', 'price_monthly')->createAndSendInvoice([], [
        'days_until_due' => 30
    ]);

<a name="subscription-quantities"></a>
#### Cantidades

Si deseas establecer una [cantidad](https://stripe.com/docs/billing/subscriptions/quantities) específica para el precio al crear la suscripción, debes invocar el método `quantity` en el constructor de la suscripción antes de crear la suscripción:

    $user->newSubscription('default', 'price_monthly')
         ->quantity(5)
         ->create($paymentMethod);

<a name="additional-details"></a>
#### Detalles Adicionales

Si deseas especificar opciones adicionales de [cliente](https://stripe.com/docs/api/customers/create) o [suscripción](https://stripe.com/docs/api/subscriptions/create) admitidas por Stripe, puedes hacerlo pasándolas como el segundo y tercer argumento al método `create`:

    $user->newSubscription('default', 'price_monthly')->create($paymentMethod, [
        'email' => $email,
    ], [
        'metadata' => ['note' => 'Alguna información extra.'],
    ]);

<a name="coupons"></a>
#### Cupones

Si deseas aplicar un cupón al crear la suscripción, puedes usar el método `withCoupon`:

    $user->newSubscription('default', 'price_monthly')
         ->withCoupon('code')
         ->create($paymentMethod);

O, si deseas aplicar un [código de promoción de Stripe](https://stripe.com/docs/billing/subscriptions/discounts/codes), puedes usar el método `withPromotionCode`:

    $user->newSubscription('default', 'price_monthly')
         ->withPromotionCode('promo_code_id')
         ->create($paymentMethod);

El ID del código de promoción dado debe ser el ID de API de Stripe asignado al código de promoción y no el código de promoción que enfrenta al cliente. Si necesitas encontrar un ID de código de promoción basado en un código de promoción que enfrenta al cliente, puedes usar el método `findPromotionCode`:

    // Encontrar un ID de código de promoción por su código que enfrenta al cliente...
    $promotionCode = $user->findPromotionCode('SUMMERSALE');

    // Encontrar un ID de código de promoción activo por su código que enfrenta al cliente...
    $promotionCode = $user->findActivePromotionCode('SUMMERSALE');

En el ejemplo anterior, el objeto `$promotionCode` devuelto es una instancia de `Laravel\Cashier\PromotionCode`. Esta clase decora un objeto subyacente `Stripe\PromotionCode`. Puedes recuperar el cupón relacionado con el código de promoción invocando el método `coupon`:

    $coupon = $user->findPromotionCode('SUMMERSALE')->coupon();

La instancia de cupón te permite determinar el monto del descuento y si el cupón representa un descuento fijo o un descuento porcentual:

    if ($coupon->isPercentage()) {
        return $coupon->percentOff().'%'; // 21.5%
    } else {
        return $coupon->amountOff(); // $5.99
    }

También puedes recuperar los descuentos que están actualmente aplicados a un cliente o suscripción:

    $discount = $billable->discount();

    $discount = $subscription->discount();

Las instancias devueltas de `Laravel\Cashier\Discount` decoran una instancia de objeto subyacente `Stripe\Discount`. Puedes recuperar el cupón relacionado con este descuento invocando el método `coupon`:

    $coupon = $subscription->discount()->coupon();

Si deseas aplicar un nuevo cupón o código de promoción a un cliente o suscripción, puedes hacerlo a través de los métodos `applyCoupon` o `applyPromotionCode`:

    $billable->applyCoupon('coupon_id');
    $billable->applyPromotionCode('promotion_code_id');

    $subscription->applyCoupon('coupon_id');
    $subscription->applyPromotionCode('promotion_code_id');

Recuerda, debes usar el ID de API de Stripe asignado al código de promoción y no el código de promoción que enfrenta al cliente. Solo se puede aplicar un cupón o código de promoción a un cliente o suscripción a la vez.

Para más información sobre este tema, consulta la documentación de Stripe sobre [cupones](https://stripe.com/docs/billing/subscriptions/coupons) y [códigos de promoción](https://stripe.com/docs/billing/subscriptions/coupons/codes).

<a name="adding-subscriptions"></a>
#### Agregando Suscripciones

Si deseas agregar una suscripción a un cliente que ya tiene un método de pago predeterminado, puedes invocar el método `add` en el constructor de la suscripción:

    use App\Models\User;

    $user = User::find(1);

    $user->newSubscription('default', 'price_monthly')->add();

<a name="creating-subscriptions-from-the-stripe-dashboard"></a>
#### Creando Suscripciones Desde el Panel de Control de Stripe

También puedes crear suscripciones desde el propio panel de control de Stripe. Al hacerlo, Cashier sincronizará las suscripciones recién agregadas y les asignará un tipo de `default`. Para personalizar el tipo de suscripción que se asigna a las suscripciones creadas en el panel, [define controladores de eventos de webhook](#defining-webhook-event-handlers).

Además, solo puedes crear un tipo de suscripción a través del panel de control de Stripe. Si tu aplicación ofrece múltiples suscripciones que utilizan diferentes tipos, solo se puede agregar un tipo de suscripción a través del panel de control de Stripe.

Finalmente, siempre debes asegurarte de agregar solo una suscripción activa por tipo de suscripción ofrecida por tu aplicación. Si un cliente tiene dos suscripciones `default`, solo se utilizará la suscripción más recientemente agregada por Cashier, aunque ambas se sincronicen con la base de datos de tu aplicación.

<a name="checking-subscription-status"></a>
### Comprobando el Estado de la Suscripción

Una vez que un cliente está suscrito a tu aplicación, puedes verificar fácilmente su estado de suscripción utilizando una variedad de métodos convenientes. Primero, el método `subscribed` devuelve `true` si el cliente tiene una suscripción activa, incluso si la suscripción está actualmente dentro de su período de prueba. El método `subscribed` acepta el tipo de suscripción como su primer argumento:

    if ($user->subscribed('default')) {
        // ...
    }

El método `subscribed` también es un gran candidato para un [middleware de ruta](/docs/{{version}}/middleware), lo que te permite filtrar el acceso a rutas y controladores según el estado de suscripción del usuario:

```php
    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Symfony\Component\HttpFoundation\Response;

    class EnsureUserIsSubscribed
    {
        /**
         * Handle an incoming request.
         *
         * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
         */
        public function handle(Request $request, Closure $next): Response
        {
            if ($request->user() && ! $request->user()->subscribed('default')) {
                // Este usuario no es un cliente que paga...
                return redirect('/billing');
            }


            return $next($request);
        }
    }
```

Si deseas determinar si un usuario todavía está dentro de su período de prueba, puedes usar el método `onTrial`. Este método puede ser útil para determinar si debes mostrar una advertencia al usuario de que todavía está en su período de prueba:

    if ($user->subscription('default')->onTrial()) {
        // ...
    }

El método `subscribedToProduct` puede ser utilizado para determinar si el usuario está suscrito a un producto dado basado en el identificador de un producto de Stripe. En Stripe, los productos son colecciones de precios. En este ejemplo, determinaremos si la suscripción `default` del usuario está activamente suscrita al producto "premium" de la aplicación. El identificador de producto de Stripe dado debe corresponder a uno de los identificadores de tu producto en el panel de control de Stripe:

    if ($user->subscribedToProduct('prod_premium', 'default')) {
        // ...
    }

Al pasar un array al método `subscribedToProduct`, puedes determinar si la suscripción `default` del usuario está activamente suscrita al producto "basic" o "premium" de la aplicación:

    if ($user->subscribedToProduct(['prod_basic', 'prod_premium'], 'default')) {
        // ...
    }

El método `subscribedToPrice` puede ser utilizado para determinar si la suscripción de un cliente corresponde a un ID de precio dado:

    if ($user->subscribedToPrice('price_basic_monthly', 'default')) {
        // ...
    }

El método `recurring` puede ser utilizado para determinar si el usuario está actualmente suscrito y ya no está dentro de su período de prueba:

    if ($user->subscription('default')->recurring()) {
        // ...
    }

> [!WARNING]  
> Si un usuario tiene dos suscripciones del mismo tipo, la suscripción más reciente siempre será devuelta por el método `subscription`. Por ejemplo, un usuario podría tener dos registros de suscripción con el tipo `default`; sin embargo, una de las suscripciones puede ser una suscripción antigua y caducada, mientras que la otra es la suscripción activa actual. La suscripción más reciente siempre será devuelta mientras que las suscripciones más antiguas se mantienen en la base de datos para revisión histórica.

<a name="cancelled-subscription-status"></a>
#### Estado de Suscripción Cancelada

Para determinar si el usuario fue una vez un suscriptor activo pero ha cancelado su suscripción, puedes usar el método `canceled`:

    if ($user->subscription('default')->canceled()) {
        // ...
    }

También puedes determinar si un usuario ha cancelado su suscripción pero todavía está en su "período de gracia" hasta que la suscripción expire por completo. Por ejemplo, si un usuario cancela una suscripción el 5 de marzo que originalmente estaba programada para expirar el 10 de marzo, el usuario está en su "período de gracia" hasta el 10 de marzo. Ten en cuenta que el método `subscribed` aún devuelve `true` durante este tiempo:

    if ($user->subscription('default')->onGracePeriod()) {
        // ...
    }

Para determinar si el usuario ha cancelado su suscripción y ya no está dentro de su "período de gracia", puedes usar el método `ended`:

    if ($user->subscription('default')->ended()) {
        // ...
    }

<a name="incomplete-and-past-due-status"></a>
#### Estado Incompleto y Vencido

Si una suscripción requiere una acción de pago secundaria después de la creación, la suscripción se marcará como `incomplete`. Los estados de suscripción se almacenan en la columna `stripe_status` de la tabla de base de datos `subscriptions` de Cashier.

De manera similar, si se requiere una acción de pago secundaria al cambiar precios, la suscripción se marcará como `past_due`. Cuando tu suscripción está en cualquiera de estos estados, no estará activa hasta que el cliente haya confirmado su pago. Determinar si una suscripción tiene un pago incompleto puede lograrse utilizando el método `hasIncompletePayment` en el modelo facturable o en una instancia de suscripción:

    if ($user->hasIncompletePayment('default')) {
        // ...
    }

    if ($user->subscription('default')->hasIncompletePayment()) {
        // ...
    }

Cuando una suscripción tiene un pago incompleto, debes dirigir al usuario a la página de confirmación de pago de Cashier, pasando el identificador `latestPayment`. Puedes usar el método `latestPayment` disponible en la instancia de suscripción para recuperar este identificador:

```html
<a href="{{ route('cashier.payment', $subscription->latestPayment()->id) }}">
    Por favor confirma tu pago.
</a>
```

Si deseas que la suscripción siga considerándose activa cuando está en un estado `past_due` o `incomplete`, puedes usar los métodos `keepPastDueSubscriptionsActive` y `keepIncompleteSubscriptionsActive` proporcionados por Cashier. Típicamente, estos métodos deben ser llamados en el método `register` de tu `App\Providers\AppServiceProvider`:

    use Laravel\Cashier\Cashier;

    /**
     * Registrar cualquier servicio de la aplicación.
     */
    public function register(): void
    {
        Cashier::keepPastDueSubscriptionsActive();
        Cashier::keepIncompleteSubscriptionsActive();
    }

> [!WARNING]  
> Cuando una suscripción está en un estado `incomplete`, no puede ser cambiada hasta que el pago sea confirmado. Por lo tanto, los métodos `swap` y `updateQuantity` lanzarán una excepción cuando la suscripción esté en un estado `incomplete`.

<a name="subscription-scopes"></a>
#### Alcances de Suscripción

La mayoría de los estados de suscripción también están disponibles como alcances de consulta para que puedas consultar fácilmente tu base de datos en busca de suscripciones que estén en un estado dado:

    // Obtener todas las suscripciones activas...
    $subscriptions = Subscription::query()->active()->get();

    // Obtener todas las suscripciones canceladas para un usuario...
    $subscriptions = $user->subscriptions()->canceled()->get();

Una lista completa de los alcances disponibles se encuentra a continuación:

    Subscription::query()->active();
    Subscription::query()->canceled();
    Subscription::query()->ended();
    Subscription::query()->incomplete();
    Subscription::query()->notCanceled();
    Subscription::query()->notOnGracePeriod();
    Subscription::query()->notOnTrial();
    Subscription::query()->onGracePeriod();
    Subscription::query()->onTrial();
    Subscription::query()->pastDue();
    Subscription::query()->recurring();

<a name="changing-prices"></a>
### Cambiando Precios

Después de que un cliente esté suscrito a tu aplicación, puede que ocasionalmente desee cambiar a un nuevo precio de suscripción. Para cambiar a un cliente a un nuevo precio, pasa el identificador del precio de Stripe al método `swap`. Al cambiar precios, se asume que el usuario desea reactivar su suscripción si fue cancelada anteriormente. El identificador de precio dado debe corresponder a un identificador de precio de Stripe disponible en el panel de control de Stripe:

    use App\Models\User;

    $user = App\Models\User::find(1);

    $user->subscription('default')->swap('price_yearly');

Si el cliente está en prueba, se mantendrá el período de prueba. Además, si existe una "cantidad" para la suscripción, esa cantidad también se mantendrá.

Si deseas cambiar precios y cancelar cualquier período de prueba en el que el cliente esté actualmente, puedes invocar el método `skipTrial`:

    $user->subscription('default')
            ->skipTrial()
            ->swap('price_yearly');

Si deseas cambiar precios e facturar al cliente de inmediato en lugar de esperar su próximo ciclo de facturación, puedes usar el método `swapAndInvoice`:

    $user = User::find(1);

    $user->subscription('default')->swapAndInvoice('price_yearly');

<a name="prorations"></a>
#### Prorrateos

Por defecto, Stripe prorratea los cargos al cambiar entre precios. El método `noProrate` puede ser utilizado para actualizar el precio de la suscripción sin prorratear los cargos:

    $user->subscription('default')->noProrate()->swap('price_yearly');

Para más información sobre el prorrateo de suscripciones, consulta la [documentación de Stripe](https://stripe.com/docs/billing/subscriptions/prorations).

> [!WARNING]  
> Ejecutar el método `noProrate` antes del método `swapAndInvoice` no tendrá efecto en el prorrateo. Siempre se emitirá una factura.

<a name="subscription-quantity"></a>
### Cantidad de Suscripción

A veces, las suscripciones se ven afectadas por la "cantidad". Por ejemplo, una aplicación de gestión de proyectos podría cobrar $10 por mes por proyecto. Puedes usar los métodos `incrementQuantity` y `decrementQuantity` para incrementar o decrementar fácilmente la cantidad de tu suscripción:

    use App\Models\User;

    $user = User::find(1);

    $user->subscription('default')->incrementQuantity();

    // Agregar cinco a la cantidad actual de la suscripción...
    $user->subscription('default')->incrementQuantity(5);

    $user->subscription('default')->decrementQuantity();

    // Restar cinco de la cantidad actual de la suscripción...
    $user->subscription('default')->decrementQuantity(5);

Alternativamente, puedes establecer una cantidad específica usando el método `updateQuantity`:

    $user->subscription('default')->updateQuantity(10);

El método `noProrate` puede ser utilizado para actualizar la cantidad de la suscripción sin prorratear los cargos:

    $user->subscription('default')->noProrate()->updateQuantity(10);

Para más información sobre las cantidades de suscripción, consulta la [documentación de Stripe](https://stripe.com/docs/subscriptions/quantities).

<a name="quantities-for-subscription-with-multiple-products"></a>
#### Cantidades para Suscripciones con Múltiples Productos

Si tu suscripción es una [suscripción con múltiples productos](#subscriptions-with-multiple-products), debes pasar el ID del precio cuya cantidad deseas incrementar o decrementar como el segundo argumento a los métodos de incremento / decremento:

    $user->subscription('default')->incrementQuantity(1, 'price_chat');

<a name="subscriptions-with-multiple-products"></a>
### Suscripciones con Múltiples Productos

[La suscripción con múltiples productos](https://stripe.com/docs/billing/subscriptions/multiple-products) te permite asignar múltiples productos de facturación a una sola suscripción. Por ejemplo, imagina que estás construyendo una aplicación de "mesa de ayuda" de servicio al cliente que tiene un precio de suscripción base de $10 por mes, pero ofrece un producto adicional de chat en vivo por $15 adicionales por mes. La información para suscripciones con múltiples productos se almacena en la tabla de base de datos `subscription_items` de Cashier.

Puedes especificar múltiples productos para una suscripción dada pasando un array de precios como el segundo argumento al método `newSubscription`:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $request->user()->newSubscription('default', [
            'price_monthly',
            'price_chat',
        ])->create($request->paymentMethodId);

        // ...
    });

En el ejemplo anterior, el cliente tendrá dos precios adjuntos a su suscripción `default`. Ambos precios se cobrarán en sus respectivos intervalos de facturación. Si es necesario, puedes usar el método `quantity` para indicar una cantidad específica para cada precio:

    $user = User::find(1);

    $user->newSubscription('default', ['price_monthly', 'price_chat'])
        ->quantity(5, 'price_chat')
        ->create($paymentMethod);

Si deseas agregar otro precio a una suscripción existente, puedes invocar el método `addPrice` de la suscripción:

    $user = User::find(1);

    $user->subscription('default')->addPrice('price_chat');

El ejemplo anterior agregará el nuevo precio y el cliente será facturado por él en su próximo ciclo de facturación. Si deseas facturar al cliente de inmediato, puedes usar el método `addPriceAndInvoice`:

    $user->subscription('default')->addPriceAndInvoice('price_chat');

Si deseas agregar un precio con una cantidad específica, puedes pasar la cantidad como el segundo argumento de los métodos `addPrice` o `addPriceAndInvoice`:

    $user = User::find(1);

    $user->subscription('default')->addPrice('price_chat', 5);

Puedes eliminar precios de las suscripciones usando el método `removePrice`:

    $user->subscription('default')->removePrice('price_chat');

> [!WARNING]  
> No puedes eliminar el último precio de una suscripción. En su lugar, simplemente debes cancelar la suscripción.

<a name="swapping-prices"></a>
#### Cambiando Precios

También puedes cambiar los precios adjuntos a una suscripción con múltiples productos. Por ejemplo, imagina que un cliente tiene una suscripción `price_basic` con un producto adicional `price_chat` y deseas actualizar al cliente de `price_basic` a `price_pro`:

    use App\Models\User;

    $user = User::find(1);

    $user->subscription('default')->swap(['price_pro', 'price_chat']);

Al ejecutar el ejemplo anterior, el elemento de suscripción subyacente con el `price_basic` se elimina y el de `price_chat` se preserva. Además, se crea un nuevo elemento de suscripción para el `price_pro`.

También puedes especificar opciones de elementos de suscripción pasando un array de pares clave / valor al método `swap`. Por ejemplo, es posible que necesites especificar las cantidades de precios de suscripción:

    $user = User::find(1);

    $user->subscription('default')->swap([
        'price_pro' => ['quantity' => 5],
        'price_chat'
    ]);

Si deseas cambiar un solo precio en una suscripción, puedes hacerlo usando el método `swap` en el propio elemento de suscripción. Este enfoque es particularmente útil si deseas preservar todos los metadatos existentes sobre los otros precios de la suscripción:

    $user = User::find(1);

    $user->subscription('default')
            ->findItemOrFail('price_basic')
            ->swap('price_pro');

<a name="proration"></a>
#### Prorrateo

Por defecto, Stripe prorrateará los cargos al agregar o eliminar precios de una suscripción con múltiples productos. Si deseas hacer un ajuste de precio sin prorrateo, debes encadenar el método `noProrate` a tu operación de precio:

    $user->subscription('default')->noProrate()->removePrice('price_chat');

<a name="swapping-quantities"></a>
#### Cantidades

Si deseas actualizar cantidades en precios de suscripción individuales, puedes hacerlo utilizando los [métodos de cantidad existentes](#subscription-quantity) pasando el ID del precio como un argumento adicional al método:

    $user = User::find(1);

    $user->subscription('default')->incrementQuantity(5, 'price_chat');

    $user->subscription('default')->decrementQuantity(3, 'price_chat');

    $user->subscription('default')->updateQuantity(10, 'price_chat');

> [!WARNING]  
> Cuando una suscripción tiene múltiples precios, los atributos `stripe_price` y `quantity` en el modelo `Subscription` serán `null`. Para acceder a los atributos de precio individuales, debes usar la relación `items` disponible en el modelo `Subscription`.

<a name="subscription-items"></a>
#### Elementos de Suscripción

Cuando una suscripción tiene múltiples precios, tendrá múltiples "elementos" de suscripción almacenados en la tabla `subscription_items` de tu base de datos. Puedes acceder a estos a través de la relación `items` en la suscripción:

    use App\Models\User;

    $user = User::find(1);

    $subscriptionItem = $user->subscription('default')->items->first();

    // Recuperar el precio de Stripe y la cantidad para un elemento específico...
    $stripePrice = $subscriptionItem->stripe_price;
    $quantity = $subscriptionItem->quantity;

También puedes recuperar un precio específico utilizando el método `findItemOrFail`:

    $user = User::find(1);

    $subscriptionItem = $user->subscription('default')->findItemOrFail('price_chat');

<a name="multiple-subscriptions"></a>
### Múltiples Suscripciones

Stripe permite que tus clientes tengan múltiples suscripciones simultáneamente. Por ejemplo, puedes tener un gimnasio que ofrece una suscripción de natación y una suscripción de levantamiento de pesas, y cada suscripción puede tener diferentes precios. Por supuesto, los clientes deberían poder suscribirse a uno o ambos planes.

Cuando tu aplicación crea suscripciones, puedes proporcionar el tipo de suscripción al método `newSubscription`. El tipo puede ser cualquier cadena que represente el tipo de suscripción que el usuario está iniciando:

    use Illuminate\Http\Request;

    Route::post('/swimming/subscribe', function (Request $request) {
        $request->user()->newSubscription('swimming')
            ->price('price_swimming_monthly')
            ->create($request->paymentMethodId);

        // ...
    });

En este ejemplo, iniciamos una suscripción mensual de natación para el cliente. Sin embargo, pueden querer cambiar a una suscripción anual en un momento posterior. Al ajustar la suscripción del cliente, simplemente podemos cambiar el precio en la suscripción `swimming`:

    $user->subscription('swimming')->swap('price_swimming_yearly');

Por supuesto, también puedes cancelar la suscripción por completo:

    $user->subscription('swimming')->cancel();

<a name="metered-billing"></a>
### Facturación Medida

[La facturación medida](https://stripe.com/docs/billing/subscriptions/metered-billing) te permite cobrar a los clientes en función de su uso del producto durante un ciclo de facturación. Por ejemplo, puedes cobrar a los clientes en función del número de mensajes de texto o correos electrónicos que envían por mes.

Para comenzar a usar la facturación medida, primero necesitarás crear un nuevo producto en tu panel de control de Stripe con un precio medido. Luego, usa el `meteredPrice` para agregar el ID del precio medido a una suscripción de cliente:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $request->user()->newSubscription('default')
            ->meteredPrice('price_metered')
            ->create($request->paymentMethodId);

        // ...
    });

También puedes iniciar una suscripción medida a través de [Stripe Checkout](#checkout):

    $checkout = Auth::user()
            ->newSubscription('default', [])
            ->meteredPrice('price_metered')
            ->checkout();

    return view('your-checkout-view', [
        'checkout' => $checkout,
    ]);

<a name="reporting-usage"></a>
#### Reportando Uso

A medida que tu cliente utiliza tu aplicación, deberás reportar su uso a Stripe para que puedan ser facturados con precisión. Para incrementar el uso de una suscripción medida, puedes usar el método `reportUsage`:

    $user = User::find(1);

    $user->subscription('default')->reportUsage();

Por defecto, se agrega una "cantidad de uso" de 1 al período de facturación. Alternativamente, puedes pasar una cantidad específica de "uso" para agregar al uso del cliente para el período de facturación:

    $user = User::find(1);

    $user->subscription('default')->reportUsage(15);

Si tu aplicación ofrece múltiples precios en una sola suscripción, necesitarás usar el método `reportUsageFor` para especificar el precio medido para el cual deseas reportar el uso:

    $user = User::find(1);

    $user->subscription('default')->reportUsageFor('price_metered', 15);

A veces, puede que necesites actualizar el uso que has reportado previamente. Para lograr esto, puedes pasar una marca de tiempo o una instancia de `DateTimeInterface` como segundo parámetro a `reportUsage`. Al hacerlo, Stripe actualizará el uso que fue reportado en ese momento dado. Puedes continuar actualizando registros de uso anteriores mientras la fecha y hora dadas aún estén dentro del período de facturación actual:

    $user = User::find(1);

    $user->subscription('default')->reportUsage(5, $timestamp);

<a name="retrieving-usage-records"></a>
#### Recuperando Registros de Uso

Para recuperar el uso pasado de un cliente, puedes usar el método `usageRecords` de una instancia de suscripción:

    $user = User::find(1);

    $usageRecords = $user->subscription('default')->usageRecords();

Si tu aplicación ofrece múltiples precios en una sola suscripción, puedes usar el método `usageRecordsFor` para especificar el precio medido del cual deseas recuperar los registros de uso:

    $user = User::find(1);

    $usageRecords = $user->subscription('default')->usageRecordsFor('price_metered');

Los métodos `usageRecords` y `usageRecordsFor` devuelven una instancia de Collection que contiene un array asociativo de registros de uso. Puedes iterar sobre este array para mostrar el uso total de un cliente:

    @foreach ($usageRecords as $usageRecord)
        - Periodo de Inicio: {{ $usageRecord['period']['start'] }}
        - Periodo de Fin: {{ $usageRecord['period']['end'] }}
        - Uso Total: {{ $usageRecord['total_usage'] }}
    @endforeach

Para una referencia completa de todos los datos de uso devueltos y cómo usar la paginación basada en curso de Stripe, consulta [la documentación oficial de la API de Stripe](https://stripe.com/docs/api/usage_records/subscription_item_summary_list).

<a name="subscription-taxes"></a>
### Impuestos de Suscripción

> [!WARNING]  
> En lugar de calcular las tasas de impuestos manualmente, puedes [calcular impuestos automáticamente usando Stripe Tax](#tax-configuration)

Para especificar las tasas de impuestos que un usuario paga en una suscripción, debes implementar el método `taxRates` en tu modelo facturable y devolver un array que contenga los IDs de las tasas de impuestos de Stripe. Puedes definir estas tasas de impuestos en [tu panel de control de Stripe](https://dashboard.stripe.com/test/tax-rates):

    /**
     * Las tasas de impuestos que deben aplicarse a las suscripciones del cliente.
     *
     * @return array<int, string>
     */
    public function taxRates(): array
    {
        return ['txr_id'];
    }

El método `taxRates` te permite aplicar una tasa de impuestos de manera individual a cada cliente, lo cual puede ser útil para una base de usuarios que abarca múltiples países y tasas de impuestos.

Si ofreces suscripciones con múltiples productos, puedes definir diferentes tasas de impuestos para cada precio implementando un método `priceTaxRates` en tu modelo facturable:

    /**
     * Las tasas de impuestos que deben aplicarse a las suscripciones del cliente.
     *
     * @return array<string, array<int, string>>
     */
    public function priceTaxRates(): array
    {
        return [
            'price_monthly' => ['txr_id'],
        ];
    }

> [!WARNING]  
> El método `taxRates` solo se aplica a los cargos de suscripción. Si usas Cashier para hacer cargos "únicos", necesitarás especificar manualmente la tasa de impuestos en ese momento.

<a name="syncing-tax-rates"></a>
#### Sincronizando Tasas de Impuestos

Al cambiar los IDs de tasas de impuestos codificados que devuelve el método `taxRates`, la configuración de impuestos en cualquier suscripción existente para el usuario permanecerá igual. Si deseas actualizar el valor de impuestos para suscripciones existentes con los nuevos valores de `taxRates`, debes llamar al método `syncTaxRates` en la instancia de suscripción del usuario:

    $user->subscription('default')->syncTaxRates();

Esto también sincronizará cualquier tasa de impuestos de los artículos para una suscripción con múltiples productos. Si tu aplicación ofrece suscripciones con múltiples productos, debes asegurarte de que tu modelo facturable implemente el método `priceTaxRates` [discutido anteriormente](#subscription-taxes).

<a name="tax-exemption"></a>
#### Exención de Impuestos

Cashier también ofrece los métodos `isNotTaxExempt`, `isTaxExempt` y `reverseChargeApplies` para determinar si el cliente está exento de impuestos. Estos métodos llamarán a la API de Stripe para determinar el estado de exención de impuestos de un cliente:

    use App\Models\User;

    $user = User::find(1);

    $user->isTaxExempt();
    $user->isNotTaxExempt();
    $user->reverseChargeApplies();

> [!WARNING]  
> Estos métodos también están disponibles en cualquier objeto `Laravel\Cashier\Invoice`. Sin embargo, cuando se invocan en un objeto `Invoice`, los métodos determinarán el estado de exención en el momento en que se creó la factura.

<a name="subscription-anchor-date"></a>
### Fecha Ancla de Suscripción

Por defecto, el ancla del ciclo de facturación es la fecha en que se creó la suscripción o, si se utiliza un período de prueba, la fecha en que finaliza el período de prueba. Si deseas modificar la fecha ancla de facturación, puedes usar el método `anchorBillingCycleOn`:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $anchor = Carbon::parse('primer día del próximo mes');

        $request->user()->newSubscription('default', 'price_monthly')
                    ->anchorBillingCycleOn($anchor->startOfDay())
                    ->create($request->paymentMethodId);

        // ...
    });

Para más información sobre cómo gestionar los ciclos de facturación de suscripciones, consulta la [documentación del ciclo de facturación de Stripe](https://stripe.com/docs/billing/subscriptions/billing-cycle)

<a name="cancelling-subscriptions"></a>
### Cancelando Suscripciones

Para cancelar una suscripción, llama al método `cancel` en la suscripción del usuario:

    $user->subscription('default')->cancel();

Cuando una suscripción es cancelada, Cashier automáticamente establecerá la columna `ends_at` en tu tabla de base de datos `subscriptions`. Esta columna se utiliza para saber cuándo el método `subscribed` debería comenzar a devolver `false`.

Por ejemplo, si un cliente cancela una suscripción el 1 de marzo, pero la suscripción no estaba programada para finalizar hasta el 5 de marzo, el método `subscribed` seguirá devolviendo `true` hasta el 5 de marzo. Esto se hace porque generalmente se permite a un usuario continuar utilizando una aplicación hasta el final de su ciclo de facturación.

Puedes determinar si un usuario ha cancelado su suscripción pero aún está en su "período de gracia" usando el método `onGracePeriod`:

    if ($user->subscription('default')->onGracePeriod()) {
        // ...
    }

Si deseas cancelar una suscripción de inmediato, llama al método `cancelNow` en la suscripción del usuario:

    $user->subscription('default')->cancelNow();

Si deseas cancelar una suscripción de inmediato y facturar cualquier uso medido no facturado restante o nuevos elementos de factura pendientes, llama al método `cancelNowAndInvoice` en la suscripción del usuario:

    $user->subscription('default')->cancelNowAndInvoice();

También puedes optar por cancelar la suscripción en un momento específico:

    $user->subscription('default')->cancelAt(
        now()->addDays(10)
    );

Finalmente, siempre debes cancelar las suscripciones de usuario antes de eliminar el modelo de usuario asociado:

    $user->subscription('default')->cancelNow();

    $user->delete();

<a name="resuming-subscriptions"></a>
### Reanudando Suscripciones

Si un cliente ha cancelado su suscripción y deseas reanudarla, puedes invocar el método `resume` en la suscripción. El cliente aún debe estar dentro de su "período de gracia" para poder reanudar una suscripción:

    $user->subscription('default')->resume();

Si el cliente cancela una suscripción y luego reanuda esa suscripción antes de que la suscripción haya expirado completamente, el cliente no será facturado de inmediato. En su lugar, su suscripción será reactivada y se les facturará en el ciclo de facturación original.

<a name="subscription-trials"></a>
## Pruebas de Suscripción

<a name="with-payment-method-up-front"></a>
### Con Método de Pago por Adelantado

Si deseas ofrecer períodos de prueba a tus clientes mientras aún recopilas información del método de pago por adelantado, debes usar el método `trialDays` al crear tus suscripciones:

    use Illuminate\Http\Request;

    Route::post('/user/subscribe', function (Request $request) {
        $request->user()->newSubscription('default', 'price_monthly')
                    ->trialDays(10)
                    ->create($request->paymentMethodId);

        // ...
    });

Este método establecerá la fecha de finalización del período de prueba en el registro de suscripción dentro de la base de datos e instruirá a Stripe para no comenzar a facturar al cliente hasta después de esta fecha. Al usar el método `trialDays`, Cashier sobrescribirá cualquier período de prueba predeterminado configurado para el precio en Stripe.

> [!WARNING]  
> Si la suscripción del cliente no se cancela antes de la fecha de finalización del período de prueba, se les cobrará tan pronto como expire el período de prueba, por lo que debes asegurarte de notificar a tus usuarios sobre la fecha de finalización de su prueba.

El método `trialUntil` te permite proporcionar una instancia de `DateTime` que especifica cuándo debe finalizar el período de prueba:

    use Carbon\Carbon;

    $user->newSubscription('default', 'price_monthly')
                ->trialUntil(Carbon::now()->addDays(10))
                ->create($paymentMethod);

Puedes determinar si un usuario está dentro de su período de prueba usando ya sea el método `onTrial` de la instancia de usuario o el método `onTrial` de la instancia de suscripción. Los dos ejemplos a continuación son equivalentes:

    if ($user->onTrial('default')) {
        // ...
    }

    if ($user->subscription('default')->onTrial()) {
        // ...
    }

Puedes usar el método `endTrial` para finalizar inmediatamente un período de prueba de suscripción:

    $user->subscription('default')->endTrial();

Para determinar si un período de prueba existente ha expirado, puedes usar los métodos `hasExpiredTrial`:

    if ($user->hasExpiredTrial('default')) {
        // ...
    }

    if ($user->subscription('default')->hasExpiredTrial()) {
        // ...
    }

<a name="defining-trial-days-in-stripe-cashier"></a>
#### Definiendo Días de Prueba en Stripe / Cashier

Puedes optar por definir cuántos días de prueba recibe tu precio en el panel de control de Stripe o siempre pasarlos explícitamente usando Cashier. Si eliges definir los días de prueba de tu precio en Stripe, debes tener en cuenta que las nuevas suscripciones, incluidas las nuevas suscripciones para un cliente que tuvo una suscripción en el pasado, siempre recibirán un período de prueba a menos que llames explícitamente al método `skipTrial()`.

<a name="without-payment-method-up-front"></a>
### Sin Método de Pago por Adelantado

Si deseas ofrecer períodos de prueba sin recopilar la información del método de pago del usuario por adelantado, puedes establecer la columna `trial_ends_at` en el registro del usuario a tu fecha de finalización de prueba deseada. Esto se hace típicamente durante el registro del usuario:

    use App\Models\User;

    $user = User::create([
        // ...
        'trial_ends_at' => now()->addDays(10),
    ]);

> [!WARNING]  
> Asegúrate de agregar un [cast de fecha](/docs/{{version}}/eloquent-mutators#date-casting) para el atributo `trial_ends_at` dentro de la definición de clase de tu modelo facturable.

Cashier se refiere a este tipo de prueba como una "prueba genérica", ya que no está adjunta a ninguna suscripción existente. El método `onTrial` en la instancia del modelo facturable devolverá `true` si la fecha actual no ha pasado el valor de `trial_ends_at`:

    if ($user->onTrial()) {
        // El usuario está dentro de su período de prueba...
    }

Una vez que estés listo para crear una suscripción real para el usuario, puedes usar el método `newSubscription` como de costumbre:

    $user = User::find(1);

    $user->newSubscription('default', 'price_monthly')->create($paymentMethod);

Para recuperar la fecha de finalización del período de prueba del usuario, puedes usar el método `trialEndsAt`. Este método devolverá una instancia de fecha Carbon si un usuario está en un período de prueba o `null` si no lo está. También puedes pasar un parámetro opcional de tipo de suscripción si deseas obtener la fecha de finalización del período de prueba para una suscripción específica diferente a la predeterminada:

    if ($user->onTrial()) {
        $trialEndsAt = $user->trialEndsAt('main');
    }

También puedes usar el método `onGenericTrial` si deseas saber específicamente que el usuario está dentro de su período de prueba "genérico" y aún no ha creado una suscripción real:

```php
    if ($user->onGenericTrial()) {
        // El usuario está dentro de su período de prueba "genérico"...
    }

<a name="extending-trials"></a>
### Extender Pruebas

El método `extendTrial` te permite extender el período de prueba de una suscripción después de que la suscripción ha sido creada. Si la prueba ya ha expirado y el cliente ya está siendo facturado por la suscripción, aún puedes ofrecerle una prueba extendida. El tiempo transcurrido dentro del período de prueba se deducirá de la próxima factura del cliente:

    use App\Models\User;

    $subscription = User::find(1)->subscription('default');

    // Termina la prueba en 7 días a partir de ahora...
    $subscription->extendTrial(
        now()->addDays(7)
    );

    // Agrega 5 días adicionales a la prueba...
    $subscription->extendTrial(
        $subscription->trial_ends_at->addDays(5)
    );

<a name="handling-stripe-webhooks"></a>
## Manejo de Webhooks de Stripe

> [!NOTE]  
> Puedes usar [la Stripe CLI](https://stripe.com/docs/stripe-cli) para ayudar a probar webhooks durante el desarrollo local.

Stripe puede notificar a tu aplicación sobre una variedad de eventos a través de webhooks. Por defecto, una ruta que apunta al controlador de webhook de Cashier se registra automáticamente por el proveedor de servicios de Cashier. Este controlador manejará todas las solicitudes de webhook entrantes.

Por defecto, el controlador de webhook de Cashier manejará automáticamente la cancelación de suscripciones que tienen demasiados cargos fallidos (según lo definido por tu configuración de Stripe), actualizaciones de clientes, eliminaciones de clientes, actualizaciones de suscripciones y cambios en el método de pago; sin embargo, como pronto descubriremos, puedes extender este controlador para manejar cualquier evento de webhook de Stripe que desees.

Para asegurarte de que tu aplicación pueda manejar webhooks de Stripe, asegúrate de configurar la URL del webhook en el panel de control de Stripe. Por defecto, el controlador de webhook de Cashier responde a la ruta de URL `/stripe/webhook`. La lista completa de todos los webhooks que deberías habilitar en el panel de control de Stripe son:

- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `customer.updated`
- `customer.deleted`
- `payment_method.automatically_updated`
- `invoice.payment_action_required`
- `invoice.payment_succeeded`

Para conveniencia, Cashier incluye un comando Artisan `cashier:webhook`. Este comando creará un webhook en Stripe que escucha todos los eventos requeridos por Cashier:

```shell
php artisan cashier:webhook
```

Por defecto, el webhook creado apuntará a la URL definida por la variable de entorno `APP_URL` y la ruta `cashier.webhook` que se incluye con Cashier. Puedes proporcionar la opción `--url` al invocar el comando si deseas usar una URL diferente:

```shell
php artisan cashier:webhook --url "https://example.com/stripe/webhook"
```

El webhook que se crea utilizará la versión de API de Stripe con la que tu versión de Cashier es compatible. Si deseas usar una versión diferente de Stripe, puedes proporcionar la opción `--api-version`:

```shell
php artisan cashier:webhook --api-version="2019-12-03"
```

Después de la creación, el webhook estará inmediatamente activo. Si deseas crear el webhook pero tenerlo deshabilitado hasta que estés listo, puedes proporcionar la opción `--disabled` al invocar el comando:

```shell
php artisan cashier:webhook --disabled
```

> [!WARNING]  
> Asegúrate de proteger las solicitudes de webhook entrantes de Stripe con la verificación de [firma de webhook](#verifying-webhook-signatures) incluida en Cashier.

<a name="webhooks-csrf-protection"></a>
#### Webhooks y Protección CSRF

Dado que los webhooks de Stripe necesitan eludir la [protección CSRF](/docs/{{version}}/csrf) de Laravel, debes asegurarte de que Laravel no intente validar el token CSRF para los webhooks de Stripe entrantes. Para lograr esto, debes excluir `stripe/*` de la protección CSRF en el archivo `bootstrap/app.php` de tu aplicación:

    ->withMiddleware(function (Middleware $middleware) {
        $middleware->validateCsrfTokens(except: [
            'stripe/*',
        ]);
    })

<a name="defining-webhook-event-handlers"></a>
### Definiendo Manejadores de Eventos de Webhook

Cashier maneja automáticamente las cancelaciones de suscripciones por cargos fallidos y otros eventos comunes de webhook de Stripe. Sin embargo, si tienes eventos de webhook adicionales que te gustaría manejar, puedes hacerlo escuchando los siguientes eventos que son despachados por Cashier:

- `Laravel\Cashier\Events\WebhookReceived`
- `Laravel\Cashier\Events\WebhookHandled`

Ambos eventos contienen la carga útil completa del webhook de Stripe. Por ejemplo, si deseas manejar el webhook `invoice.payment_succeeded`, puedes registrar un [listener](/docs/{{version}}/events#defining-listeners) que manejará el evento:

    <?php

    namespace App\Listeners;

    use Laravel\Cashier\Events\WebhookReceived;

    class StripeEventListener
    {
        /**
         * Manejar webhooks de Stripe recibidos.
         */
        public function handle(WebhookReceived $event): void
        {
            if ($event->payload['type'] === 'invoice.payment_succeeded') {
                // Manejar el evento entrante...
            }
        }
    }

<a name="verifying-webhook-signatures"></a>
### Verificando Firmas de Webhook

Para asegurar tus webhooks, puedes usar [las firmas de webhook de Stripe](https://stripe.com/docs/webhooks/signatures). Para conveniencia, Cashier incluye automáticamente un middleware que valida que la solicitud de webhook de Stripe entrante sea válida.

Para habilitar la verificación de webhook, asegúrate de que la variable de entorno `STRIPE_WEBHOOK_SECRET` esté configurada en el archivo `.env` de tu aplicación. El `secreto` del webhook puede ser recuperado desde el panel de control de tu cuenta de Stripe.

<a name="single-charges"></a>
## Cargos Únicos

<a name="simple-charge"></a>
### Cargo Simple

Si deseas realizar un cargo único contra un cliente, puedes usar el método `charge` en una instancia de modelo facturable. Necesitarás [proporcionar un identificador de método de pago](#payment-methods-for-single-charges) como segundo argumento al método `charge`:

    use Illuminate\Http\Request;

    Route::post('/purchase', function (Request $request) {
        $stripeCharge = $request->user()->charge(
            100, $request->paymentMethodId
        );

        // ...
    });

El método `charge` acepta un array como su tercer argumento, lo que te permite pasar cualquier opción que desees a la creación del cargo subyacente de Stripe. Más información sobre las opciones disponibles al crear cargos se puede encontrar en la [documentación de Stripe](https://stripe.com/docs/api/charges/create):

    $user->charge(100, $paymentMethod, [
        'custom_option' => $value,
    ]);

También puedes usar el método `charge` sin un cliente o usuario subyacente. Para lograr esto, invoca el método `charge` en una nueva instancia de tu modelo facturable de la aplicación:

    use App\Models\User;

    $stripeCharge = (new User)->charge(100, $paymentMethod);

El método `charge` lanzará una excepción si el cargo falla. Si el cargo es exitoso, se devolverá una instancia de `Laravel\Cashier\Payment` desde el método:

    try {
        $payment = $user->charge(100, $paymentMethod);
    } catch (Exception $e) {
        // ...
    }

> [!WARNING]  
> El método `charge` acepta el monto del pago en el denominador más bajo de la moneda utilizada por tu aplicación. Por ejemplo, si los clientes están pagando en dólares estadounidenses, los montos deben especificarse en centavos.

<a name="charge-with-invoice"></a>
### Cargo con Factura

A veces, es posible que necesites realizar un cargo único y ofrecer una factura PDF a tu cliente. El método `invoicePrice` te permite hacer exactamente eso. Por ejemplo, facturamos a un cliente por cinco camisetas nuevas:

    $user->invoicePrice('price_tshirt', 5);

La factura se cargará inmediatamente contra el método de pago predeterminado del usuario. El método `invoicePrice` también acepta un array como su tercer argumento. Este array contiene las opciones de facturación para el ítem de la factura. El cuarto argumento aceptado por el método también es un array que debe contener las opciones de facturación para la factura en sí:

    $user->invoicePrice('price_tshirt', 5, [
        'discounts' => [
            ['coupon' => 'SUMMER21SALE']
        ],
    ], [
        'default_tax_rates' => ['txr_id'],
    ]);

De manera similar a `invoicePrice`, puedes usar el método `tabPrice` para crear un cargo único por múltiples ítems (hasta 250 ítems por factura) agregándolos al "tab" del cliente y luego facturando al cliente. Por ejemplo, podemos facturar a un cliente por cinco camisetas y dos tazas:

    $user->tabPrice('price_tshirt', 5);
    $user->tabPrice('price_mug', 2);
    $user->invoice();

Alternativamente, puedes usar el método `invoiceFor` para hacer un cargo "único" contra el método de pago predeterminado del cliente:

    $user->invoiceFor('One Time Fee', 500);

Aunque el método `invoiceFor` está disponible para que lo uses, se recomienda que utilices los métodos `invoicePrice` y `tabPrice` con precios predefinidos. Al hacerlo, tendrás acceso a mejores análisis y datos dentro de tu panel de control de Stripe sobre tus ventas por producto.

> [!WARNING]  
> Los métodos `invoice`, `invoicePrice` y `invoiceFor` crearán una factura de Stripe que volverá a intentar los intentos de facturación fallidos. Si no deseas que las facturas vuelvan a intentar cargos fallidos, deberás cerrarlas utilizando la API de Stripe después del primer cargo fallido.

<a name="creating-payment-intents"></a>
### Creando Intenciones de Pago

Puedes crear una nueva intención de pago de Stripe invocando el método `pay` en una instancia de modelo facturable. Llamar a este método creará una intención de pago que está envuelta en una instancia de `Laravel\Cashier\Payment`:

    use Illuminate\Http\Request;

    Route::post('/pay', function (Request $request) {
        $payment = $request->user()->pay(
            $request->get('amount')
        );

        return $payment->client_secret;
    });

Después de crear la intención de pago, puedes devolver el secreto del cliente al frontend de tu aplicación para que el usuario pueda completar el pago en su navegador. Para leer más sobre cómo construir flujos de pago completos utilizando intenciones de pago de Stripe, consulta la [documentación de Stripe](https://stripe.com/docs/payments/accept-a-payment?platform=web).

Al usar el método `pay`, los métodos de pago predeterminados que están habilitados dentro de tu panel de control de Stripe estarán disponibles para el cliente. Alternativamente, si solo deseas permitir que se utilicen algunos métodos de pago específicos, puedes usar el método `payWith`:

    use Illuminate\Http\Request;

    Route::post('/pay', function (Request $request) {
        $payment = $request->user()->payWith(
            $request->get('amount'), ['card', 'bancontact']
        );

        return $payment->client_secret;
    });

> [!WARNING]  
> Los métodos `pay` y `payWith` aceptan el monto del pago en el denominador más bajo de la moneda utilizada por tu aplicación. Por ejemplo, si los clientes están pagando en dólares estadounidenses, los montos deben especificarse en centavos.

<a name="refunding-charges"></a>
### Reembolsando Cargos

Si necesitas reembolsar un cargo de Stripe, puedes usar el método `refund`. Este método acepta el [ID de intención de pago](#payment-methods-for-single-charges) de Stripe como su primer argumento:

    $payment = $user->charge(100, $paymentMethodId);

    $user->refund($payment->id);

<a name="invoices"></a>
## Facturas

<a name="retrieving-invoices"></a>
### Recuperando Facturas

Puedes recuperar fácilmente un array de las facturas de un modelo facturable utilizando el método `invoices`. El método `invoices` devuelve una colección de instancias de `Laravel\Cashier\Invoice`:

    $invoices = $user->invoices();

Si deseas incluir facturas pendientes en los resultados, puedes usar el método `invoicesIncludingPending`:

    $invoices = $user->invoicesIncludingPending();

Puedes usar el método `findInvoice` para recuperar una factura específica por su ID:

    $invoice = $user->findInvoice($invoiceId);

<a name="displaying-invoice-information"></a>
#### Mostrando Información de la Factura

Al listar las facturas para el cliente, puedes usar los métodos de la factura para mostrar la información relevante de la factura. Por ejemplo, puedes desear listar cada factura en una tabla, permitiendo al usuario descargar fácilmente cualquiera de ellas:

    <table>
        @foreach ($invoices as $invoice)
            <tr>
                <td>{{ $invoice->date()->toFormattedDateString() }}</td>
                <td>{{ $invoice->total() }}</td>
                <td><a href="/user/invoice/{{ $invoice->id }}">Descargar</a></td>
            </tr>
        @endforeach
    </table>

<a name="upcoming-invoices"></a>
### Facturas Próximas

Para recuperar la próxima factura de un cliente, puedes usar el método `upcomingInvoice`:

    $invoice = $user->upcomingInvoice();

De manera similar, si el cliente tiene múltiples suscripciones, también puedes recuperar la próxima factura para una suscripción específica:

    $invoice = $user->subscription('default')->upcomingInvoice();

<a name="previewing-subscription-invoices"></a>
### Previsualizando Facturas de Suscripción

Usando el método `previewInvoice`, puedes previsualizar una factura antes de realizar cambios de precio. Esto te permitirá determinar cómo se verá la factura de tu cliente cuando se realice un cambio de precio dado:

    $invoice = $user->subscription('default')->previewInvoice('price_yearly');

Puedes pasar un array de precios al método `previewInvoice` para previsualizar facturas con múltiples nuevos precios:

    $invoice = $user->subscription('default')->previewInvoice(['price_yearly', 'price_metered']);

<a name="generating-invoice-pdfs"></a>
### Generando PDFs de Factura

Antes de generar PDFs de factura, debes usar Composer para instalar la biblioteca Dompdf, que es el renderizador de facturas predeterminado para Cashier:

```php
composer require dompdf/dompdf
```

Desde una ruta o controlador, puedes usar el método `downloadInvoice` para generar una descarga PDF de una factura dada. Este método generará automáticamente la respuesta HTTP adecuada necesaria para descargar la factura:

    use Illuminate\Http\Request;

    Route::get('/user/invoice/{invoice}', function (Request $request, string $invoiceId) {
        return $request->user()->downloadInvoice($invoiceId);
    });

Por defecto, todos los datos de la factura se derivan de los datos del cliente y de la factura almacenados en Stripe. El nombre del archivo se basa en el valor de configuración `app.name`. Sin embargo, puedes personalizar algunos de estos datos proporcionando un array como segundo argumento al método `downloadInvoice`. Este array te permite personalizar información como los detalles de tu empresa y producto:

    return $request->user()->downloadInvoice($invoiceId, [
        'vendor' => 'Tu Empresa',
        'product' => 'Tu Producto',
        'street' => 'Calle Principal 1',
        'location' => '2000 Amberes, Bélgica',
        'phone' => '+32 499 00 00 00',
        'email' => 'info@example.com',
        'url' => 'https://example.com',
        'vendorVat' => 'BE123456789',
    ]);

El método `downloadInvoice` también permite un nombre de archivo personalizado a través de su tercer argumento. Este nombre de archivo se sufijará automáticamente con `.pdf`:

    return $request->user()->downloadInvoice($invoiceId, [], 'mi-factura');

<a name="custom-invoice-render"></a>
#### Renderizador de Factura Personalizado

Cashier también hace posible usar un renderizador de factura personalizado. Por defecto, Cashier utiliza la implementación `DompdfInvoiceRenderer`, que utiliza la biblioteca PHP [dompdf](https://github.com/dompdf/dompdf) para generar las facturas de Cashier. Sin embargo, puedes usar cualquier renderizador que desees implementando la interfaz `Laravel\Cashier\Contracts\InvoiceRenderer`. Por ejemplo, puedes desear renderizar un PDF de factura utilizando una llamada a una API de un servicio de renderizado de PDF de terceros:

```php
    use Illuminate\Support\Facades\Http;
    use Laravel\Cashier\Contracts\InvoiceRenderer;
    use Laravel\Cashier\Invoice;

    class ApiInvoiceRenderer implements InvoiceRenderer
    {
        /**
         * Render the given invoice and return the raw PDF bytes.
         */
        public function render(Invoice $invoice, array $data = [], array $options = []): string
        {
            $html = $invoice->view($data)->render();

            return Http::get('https://example.com/html-to-pdf', ['html' => $html])->get()->body();
        }
    }
```
Una vez que hayas implementado el contrato de renderizador de facturas, debes actualizar el valor de configuración `cashier.invoices.renderer` en el archivo de configuración `config/cashier.php` de tu aplicación. Este valor de configuración debe establecerse en el nombre de la clase de tu implementación de renderizador personalizada.

<a name="checkout"></a>
## Checkout

Cashier Stripe también proporciona soporte para [Stripe Checkout](https://stripe.com/payments/checkout). Stripe Checkout elimina la dificultad de implementar páginas personalizadas para aceptar pagos al proporcionar una página de pago alojada y preconstruida.

La siguiente documentación contiene información sobre cómo comenzar a usar Stripe Checkout con Cashier. Para obtener más información sobre Stripe Checkout, también deberías considerar revisar [la documentación de Stripe sobre Checkout](https://stripe.com/docs/payments/checkout).

<a name="product-checkouts"></a>
### Product Checkouts

Puedes realizar un checkout para un producto existente que ha sido creado dentro de tu panel de control de Stripe utilizando el método `checkout` en un modelo facturable. El método `checkout` iniciará una nueva sesión de Stripe Checkout. Por defecto, se requiere que pases un ID de Precio de Stripe:

    use Illuminate\Http\Request;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()->checkout('price_tshirt');
    });

Si es necesario, también puedes especificar una cantidad de producto:

    use Illuminate\Http\Request;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()->checkout(['price_tshirt' => 15]);
    });

Cuando un cliente visita esta ruta, será redirigido a la página de Checkout de Stripe. Por defecto, cuando un usuario completa o cancela una compra con éxito, será redirigido a la ubicación de tu ruta `home`, pero puedes especificar URLs de callback personalizadas utilizando las opciones `success_url` y `cancel_url`:

    use Illuminate\Http\Request;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()->checkout(['price_tshirt' => 1], [
            'success_url' => route('your-success-route'),
            'cancel_url' => route('your-cancel-route'),
        ]);
    });

Al definir tu opción de checkout `success_url`, puedes instruir a Stripe para que agregue el ID de sesión de checkout como un parámetro de cadena de consulta al invocar tu URL. Para hacerlo, agrega la cadena literal `{CHECKOUT_SESSION_ID}` a tu cadena de consulta `success_url`. Stripe reemplazará este marcador de posición con el ID de sesión de checkout real:

    use Illuminate\Http\Request;
    use Stripe\Checkout\Session;
    use Stripe\Customer;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()->checkout(['price_tshirt' => 1], [
            'success_url' => route('checkout-success').'?session_id={CHECKOUT_SESSION_ID}',
            'cancel_url' => route('checkout-cancel'),
        ]);
    });

    Route::get('/checkout-success', function (Request $request) {
        $checkoutSession = $request->user()->stripe()->checkout->sessions->retrieve($request->get('session_id'));

        return view('checkout.success', ['checkoutSession' => $checkoutSession]);
    })->name('checkout-success');

<a name="checkout-promotion-codes"></a>
#### Promotion Codes

Por defecto, Stripe Checkout no permite [códigos de promoción canjeables por el usuario](https://stripe.com/docs/billing/subscriptions/discounts/codes). Afortunadamente, hay una manera fácil de habilitar estos para tu página de Checkout. Para hacerlo, puedes invocar el método `allowPromotionCodes`:

    use Illuminate\Http\Request;

    Route::get('/product-checkout', function (Request $request) {
        return $request->user()
            ->allowPromotionCodes()
            ->checkout('price_tshirt');
    });

<a name="single-charge-checkouts"></a>
### Single Charge Checkouts

También puedes realizar un cargo simple para un producto ad-hoc que no ha sido creado en tu panel de control de Stripe. Para hacerlo, puedes usar el método `checkoutCharge` en un modelo facturable y pasarle un monto cobrable, un nombre de producto y una cantidad opcional. Cuando un cliente visita esta ruta, será redirigido a la página de Checkout de Stripe:

    use Illuminate\Http\Request;

    Route::get('/charge-checkout', function (Request $request) {
        return $request->user()->checkoutCharge(1200, 'T-Shirt', 5);
    });

> [!WARNING]  
> Al usar el método `checkoutCharge`, Stripe siempre creará un nuevo producto y precio en tu panel de control de Stripe. Por lo tanto, recomendamos que crees los productos por adelantado en tu panel de control de Stripe y uses el método `checkout` en su lugar.

<a name="subscription-checkouts"></a>
### Subscription Checkouts

> [!WARNING]  
> Usar Stripe Checkout para suscripciones requiere que habilites el webhook `customer.subscription.created` en tu panel de control de Stripe. Este webhook creará el registro de suscripción en tu base de datos y almacenará todos los elementos de suscripción relevantes.

También puedes usar Stripe Checkout para iniciar suscripciones. Después de definir tu suscripción con los métodos de constructor de suscripción de Cashier, puedes llamar al método `checkout`. Cuando un cliente visita esta ruta, será redirigido a la página de Checkout de Stripe:

    use Illuminate\Http\Request;

    Route::get('/subscription-checkout', function (Request $request) {
        return $request->user()
            ->newSubscription('default', 'price_monthly')
            ->checkout();
    });

Al igual que con los checkouts de productos, puedes personalizar las URLs de éxito y cancelación:

    use Illuminate\Http\Request;

    Route::get('/subscription-checkout', function (Request $request) {
        return $request->user()
            ->newSubscription('default', 'price_monthly')
            ->checkout([
                'success_url' => route('your-success-route'),
                'cancel_url' => route('your-cancel-route'),
            ]);
    });

Por supuesto, también puedes habilitar códigos de promoción para los checkouts de suscripción:

    use Illuminate\Http\Request;

    Route::get('/subscription-checkout', function (Request $request) {
        return $request->user()
            ->newSubscription('default', 'price_monthly')
            ->allowPromotionCodes()
            ->checkout();
    });

> [!WARNING]  
> Desafortunadamente, Stripe Checkout no admite todas las opciones de facturación de suscripción al iniciar suscripciones. Usar el método `anchorBillingCycleOn` en el constructor de suscripción, establecer el comportamiento de prorrateo o establecer el comportamiento de pago no tendrá ningún efecto durante las sesiones de Stripe Checkout. Consulta [la documentación de la API de sesión de Stripe Checkout](https://stripe.com/docs/api/checkout/sessions/create) para revisar qué parámetros están disponibles.

<a name="stripe-checkout-trial-periods"></a>
#### Stripe Checkout and Trial Periods

Por supuesto, puedes definir un período de prueba al construir una suscripción que se completará utilizando Stripe Checkout:

    $checkout = Auth::user()->newSubscription('default', 'price_monthly')
        ->trialDays(3)
        ->checkout();

Sin embargo, el período de prueba debe ser de al menos 48 horas, que es la cantidad mínima de tiempo de prueba admitida por Stripe Checkout.

<a name="stripe-checkout-subscriptions-and-webhooks"></a>
#### Subscriptions and Webhooks

Recuerda, Stripe y Cashier actualizan los estados de suscripción a través de webhooks, por lo que existe la posibilidad de que una suscripción aún no esté activa cuando el cliente regrese a la aplicación después de ingresar su información de pago. Para manejar este escenario, es posible que desees mostrar un mensaje informando al usuario que su pago o suscripción está pendiente.

<a name="collecting-tax-ids"></a>
### Collecting Tax IDs

Checkout también admite la recopilación del ID fiscal de un cliente. Para habilitar esto en una sesión de checkout, invoca el método `collectTaxIds` al crear la sesión:

    $checkout = $user->collectTaxIds()->checkout('price_tshirt');

Cuando se invoca este método, habrá una nueva casilla de verificación disponible para el cliente que les permite indicar si están comprando como una empresa. Si es así, tendrán la oportunidad de proporcionar su número de ID fiscal.

> [!WARNING]  
> Si ya has configurado [la recolección automática de impuestos](#tax-configuration) en el proveedor de servicios de tu aplicación, entonces esta función se habilitará automáticamente y no hay necesidad de invocar el método `collectTaxIds`.

<a name="guest-checkouts"></a>
### Guest Checkouts

Usando el método `Checkout::guest`, puedes iniciar sesiones de checkout para los invitados de tu aplicación que no tienen una "cuenta":

    use Illuminate\Http\Request;
    use Laravel\Cashier\Checkout;

    Route::get('/product-checkout', function (Request $request) {
        return Checkout::guest()->create('price_tshirt', [
            'success_url' => route('your-success-route'),
            'cancel_url' => route('your-cancel-route'),
        ]);
    });

De manera similar a cuando se crean sesiones de checkout para usuarios existentes, puedes utilizar métodos adicionales disponibles en la instancia `Laravel\Cashier\CheckoutBuilder` para personalizar la sesión de checkout de invitados:

    use Illuminate\Http\Request;
    use Laravel\Cashier\Checkout;

    Route::get('/product-checkout', function (Request $request) {
        return Checkout::guest()
            ->withPromotionCode('promo-code')
            ->create('price_tshirt', [
                'success_url' => route('your-success-route'),
                'cancel_url' => route('your-cancel-route'),
            ]);
    });

Después de que se complete un checkout de invitado, Stripe puede enviar un evento de webhook `checkout.session.completed`, así que asegúrate de [configurar tu webhook de Stripe](https://dashboard.stripe.com/webhooks) para enviar realmente este evento a tu aplicación. Una vez que el webhook se haya habilitado dentro del panel de control de Stripe, puedes [manejar el webhook con Cashier](#handling-stripe-webhooks). El objeto contenido en la carga útil del webhook será un [`checkout` object](https://stripe.com/docs/api/checkout/sessions/object) que puedes inspeccionar para cumplir con el pedido de tu cliente.

<a name="handling-failed-payments"></a>
## Handling Failed Payments

A veces, los pagos por suscripciones o cargos únicos pueden fallar. Cuando esto sucede, Cashier lanzará una excepción `Laravel\Cashier\Exceptions\IncompletePayment` que te informa que esto ha sucedido. Después de capturar esta excepción, tienes dos opciones sobre cómo proceder.

Primero, podrías redirigir a tu cliente a la página de confirmación de pago dedicada que está incluida con Cashier. Esta página ya tiene una ruta nombrada asociada que está registrada a través del proveedor de servicios de Cashier. Así que puedes capturar la excepción `IncompletePayment` y redirigir al usuario a la página de confirmación de pago:

    use Laravel\Cashier\Exceptions\IncompletePayment;

    try {
        $subscription = $user->newSubscription('default', 'price_monthly')
                                ->create($paymentMethod);
    } catch (IncompletePayment $exception) {
        return redirect()->route(
            'cashier.payment',
            [$exception->payment->id, 'redirect' => route('home')]
        );
    }

En la página de confirmación de pago, se le pedirá al cliente que ingrese nuevamente su información de tarjeta de crédito y realice cualquier acción adicional requerida por Stripe, como la confirmación de "3D Secure". Después de confirmar su pago, el usuario será redirigido a la URL proporcionada por el parámetro `redirect` especificado anteriormente. Al ser redirigido, se agregarán las variables de cadena de consulta `message` (cadena) y `success` (entero) a la URL. La página de pago actualmente admite los siguientes tipos de métodos de pago:

<div class="content-list" markdown="1">

- Tarjetas de Crédito
- Alipay
- Bancontact
- BECS Direct Debit
- EPS
- Giropay
- iDEAL
- SEPA Direct Debit

</div>

Alternativamente, podrías permitir que Stripe maneje la confirmación de pago por ti. En este caso, en lugar de redirigir a la página de confirmación de pago, puedes [configurar los correos electrónicos de facturación automática de Stripe](https://dashboard.stripe.com/account/billing/automatic) en tu panel de control de Stripe. Sin embargo, si se captura una excepción `IncompletePayment`, aún deberías informar al usuario que recibirá un correo electrónico con más instrucciones de confirmación de pago.

Las excepciones de pago pueden lanzarse para los siguientes métodos: `charge`, `invoiceFor` e `invoice` en modelos que utilizan el rasgo `Billable`. Al interactuar con suscripciones, el método `create` en el `SubscriptionBuilder`, y los métodos `incrementAndInvoice` y `swapAndInvoice` en los modelos `Subscription` y `SubscriptionItem` pueden lanzar excepciones de pago incompleto.

Determinar si una suscripción existente tiene un pago incompleto puede lograrse utilizando el método `hasIncompletePayment` en el modelo facturable o una instancia de suscripción:

    if ($user->hasIncompletePayment('default')) {
        // ...
    }

    if ($user->subscription('default')->hasIncompletePayment()) {
        // ...
    }

Puedes derivar el estado específico de un pago incompleto inspeccionando la propiedad `payment` en la instancia de excepción:

    use Laravel\Cashier\Exceptions\IncompletePayment;

    try {
        $user->charge(1000, 'pm_card_threeDSecure2Required');
    } catch (IncompletePayment $exception) {
        // Obtener el estado de la intención de pago...
        $exception->payment->status;

        // Verificar condiciones específicas...
        if ($exception->payment->requiresPaymentMethod()) {
            // ...
        } elseif ($exception->payment->requiresConfirmation()) {
            // ...
        }
    }

<a name="confirming-payments"></a>
### Confirming Payments

Algunos métodos de pago requieren datos adicionales para confirmar los pagos. Por ejemplo, los métodos de pago SEPA requieren datos adicionales de "mandato" durante el proceso de pago. Puedes proporcionar estos datos a Cashier utilizando el método `withPaymentConfirmationOptions`:

    $subscription->withPaymentConfirmationOptions([
        'mandate_data' => '...',
    ])->swap('price_xxx');

Puedes consultar la [documentación de la API de Stripe](https://stripe.com/docs/api/payment_intents/confirm) para revisar todas las opciones aceptadas al confirmar pagos.

<a name="strong-customer-authentication"></a>
## Strong Customer Authentication

Si tu negocio o uno de tus clientes está basado en Europa, necesitarás cumplir con las regulaciones de Autenticación Fuerte del Cliente (SCA) de la UE. Estas regulaciones fueron impuestas en septiembre de 2019 por la Unión Europea para prevenir el fraude en los pagos. Afortunadamente, Stripe y Cashier están preparados para construir aplicaciones compatibles con SCA.

> [!WARNING]  
> Antes de comenzar, revisa [la guía de Stripe sobre PSD2 y SCA](https://stripe.com/guides/strong-customer-authentication) así como su [documentación sobre las nuevas API de SCA](https://stripe.com/docs/strong-customer-authentication).

<a name="payments-requiring-additional-confirmation"></a>
### Payments Requiring Additional Confirmation

Las regulaciones de SCA a menudo requieren verificación adicional para confirmar y procesar un pago. Cuando esto sucede, Cashier lanzará una excepción `Laravel\Cashier\Exceptions\IncompletePayment` que te informa que se necesita verificación adicional. Más información sobre cómo manejar estas excepciones se puede encontrar en la documentación sobre [manejo de pagos fallidos](#handling-failed-payments).

Las pantallas de confirmación de pago presentadas por Stripe o Cashier pueden adaptarse al flujo de pago de un banco o emisor de tarjetas específico e incluir confirmación adicional de la tarjeta, un cargo temporal pequeño, autenticación de dispositivo separada u otras formas de verificación.

<a name="incomplete-and-past-due-state"></a>
#### Estado Incompleto y Vencido

Cuando un pago necesita confirmación adicional, la suscripción permanecerá en un estado `incomplete` o `past_due`, como se indica en su columna de base de datos `stripe_status`. Cashier activará automáticamente la suscripción del cliente tan pronto como se complete la confirmación del pago y su aplicación sea notificada por Stripe a través de webhook de su finalización.

Para obtener más información sobre los estados `incomplete` y `past_due`, consulte [nuestra documentación adicional sobre estos estados](#incomplete-and-past-due-status).

<a name="off-session-payment-notifications"></a>
### Notificaciones de Pago Fuera de Sesión

Dado que las regulaciones de SCA requieren que los clientes verifiquen ocasionalmente sus detalles de pago incluso mientras su suscripción está activa, Cashier puede enviar una notificación al cliente cuando se requiera confirmación de pago fuera de sesión. Por ejemplo, esto puede ocurrir cuando una suscripción se está renovando. La notificación de pago de Cashier se puede habilitar configurando la variable de entorno `CASHIER_PAYMENT_NOTIFICATION` a una clase de notificación. Por defecto, esta notificación está deshabilitada. Por supuesto, Cashier incluye una clase de notificación que puede usar para este propósito, pero puede proporcionar su propia clase de notificación si lo desea:

```ini
CASHIER_PAYMENT_NOTIFICATION=Laravel\Cashier\Notifications\ConfirmPayment
```

Para asegurarse de que las notificaciones de confirmación de pago fuera de sesión se entreguen, verifique que [los webhooks de Stripe estén configurados](#handling-stripe-webhooks) para su aplicación y que el webhook `invoice.payment_action_required` esté habilitado en su panel de control de Stripe. Además, su modelo `Billable` también debe usar el trait `Illuminate\Notifications\Notifiable` de Laravel.

> [!WARNING]  
> Las notificaciones se enviarán incluso cuando los clientes estén realizando manualmente un pago que requiera confirmación adicional. Desafortunadamente, no hay forma de que Stripe sepa que el pago se realizó manualmente o "fuera de sesión". Pero, un cliente simplemente verá un mensaje de "Pago Exitoso" si visita la página de pago después de haber confirmado ya su pago. El cliente no podrá confirmar accidentalmente el mismo pago dos veces y incurrir en un segundo cargo accidental.

<a name="stripe-sdk"></a>
## Stripe SDK

Muchos de los objetos de Cashier son envolturas alrededor de los objetos del SDK de Stripe. Si desea interactuar directamente con los objetos de Stripe, puede recuperarlos convenientemente utilizando el método `asStripe`:

    $stripeSubscription = $subscription->asStripeSubscription();

    $stripeSubscription->application_fee_percent = 5;

    $stripeSubscription->save();

También puede usar el método `updateStripeSubscription` para actualizar una suscripción de Stripe directamente:

    $subscription->updateStripeSubscription(['application_fee_percent' => 5]);

Puede invocar el método `stripe` en la clase `Cashier` si desea usar directamente el cliente `Stripe\StripeClient`. Por ejemplo, podría usar este método para acceder a la instancia de `StripeClient` y recuperar una lista de precios de su cuenta de Stripe:

    use Laravel\Cashier\Cashier;

    $prices = Cashier::stripe()->prices->all();

<a name="testing"></a>
## Pruebas

Al probar una aplicación que utiliza Cashier, puede simular las solicitudes HTTP reales a la API de Stripe; sin embargo, esto requiere que reimplemente parcialmente el comportamiento de Cashier. Por lo tanto, recomendamos permitir que sus pruebas accedan a la API real de Stripe. Aunque esto es más lento, proporciona más confianza en que su aplicación está funcionando como se espera y cualquier prueba lenta puede colocarse dentro de su propio grupo de pruebas Pest / PHPUnit.

Al probar, recuerde que Cashier ya tiene un excelente conjunto de pruebas, por lo que solo debe centrarse en probar el flujo de suscripción y pago de su propia aplicación y no cada comportamiento subyacente de Cashier.

Para comenzar, agregue la versión **de prueba** de su secreto de Stripe a su archivo `phpunit.xml`:

    <env name="STRIPE_SECRET" value="sk_test_<your-key>"/>

Ahora, cada vez que interactúe con Cashier mientras prueba, enviará solicitudes API reales a su entorno de prueba de Stripe. Para su conveniencia, debe prellenar su cuenta de prueba de Stripe con suscripciones / precios que puede usar durante las pruebas.

> [!NOTE]  
> Para probar una variedad de escenarios de facturación, como denegaciones y fallos de tarjetas de crédito, puede utilizar la amplia gama de [números de tarjetas y tokens de prueba](https://stripe.com/docs/testing) proporcionados por Stripe.
