<?php

return [
    'dependencies' => [
        'factories' => [
            Zend\Expressive\Template\TemplateRendererInterface::class =>
                Zend\Expressive\Twig\TwigRendererFactory::class,
        ],
    ],

    'templates' => [
        'extension' => 'twig.html',
        'paths'     => [
            'app'    => ['resources/templates/app'],
            'layout' => ['resources/templates/layout'],
            'error'  => ['resources/templates/error'],
        ],
        'context_processors' => [
            'Pawon\Contrib\ContextProcessor\UserContext',
            'Pawon\Contrib\ContextProcessor\CsrfContexProcessor',
            'Pawon\Flash\FlashContextProcessor',
        ],
    ],

    'twig' => [
        'cache_dir'      => 'data/cache/twig',
        'assets_url'     => '/',
        'assets_version' => null,
        'extensions'     => [
            // extension service names or instances
        ],
    ],
];
