<?php
use Pawon\Core\Application;
use Pawon\Core\AppFactory;
use Zend\Expressive\Helper;

return [
    // Provides application-wide services.
    // We recommend using fully-qualified class names whenever possible as
    // service names.
    'dependencies' => [
        // Use 'invokables' for constructor-less services, or services that do
        // not require arguments to the constructor. Map a service name to the
        // class name.
        'invokables' => [
            // Fully\Qualified\InterfaceName::class => Fully\Qualified\ClassName::class,
            Helper\ServerUrlHelper::class => Helper\ServerUrlHelper::class,
        ],
        // Use 'factories' for services provided by callbacks/factory classes.
        'factories' => [
            Application::class => AppFactory::class,
            Helper\UrlHelper::class => Helper\UrlHelperFactory::class,
            Pawon\Session\Store::class => Pawon\Session\StoreFactory::class,
            'Pawon\Cookie\QueueingCookieFactory' => 'Pawon\Cookie\CookieJarFactory',
            'Pawon\Translation\LoaderInterface' => 'Pawon\Translation\TranslatorFactory',
            'Pawon\Cache\Backends\BaseCache' => 'Pawon\Cache\CacheFactory',
            'Pawon\Cache\RateLimiter' => 'Pawon\Cache\CacheFactory',
            'Symfony\Component\Translation\TranslatorInterface' =>
                'Pawon\Translation\TranslatorFactory',
            'Pawon\Validation\PresenceVerifierInterface' =>
                'Pawon\Validation\ValidationServiceFactory',
            'Illuminate\Contracts\Validation\Factory' =>
                'Pawon\Validation\ValidationServiceFactory',
            'Illuminate\Contracts\Encryption\Encrypter' =>
                'Pawon\Core\EncrypterFactory',
            'Pawon\Flash\Storage\BaseStorage' => 'Pawon\Flash\FlashServiceFactory',
            'Pawon\Flash\FlashMessageInterface' => 'Pawon\Flash\FlashServiceFactory',
            'Pawon\Flash\FlashMessageMiddleware' => 'Pawon\Flash\FlashServiceFactory',
            'League\Tactician\CommandBus' => 'Pawon\Contrib\Bus\CommandBusFactory',
        ],
        'abstract_factories' => [
            'Pawon\Core\AbstractFactoryReflection'
        ],
        'initializers' => [
            'Pawon\Contrib\GenericFactoryInitializer'
        ]
    ],
];
