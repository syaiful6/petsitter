<?php

namespace App\Http\Middleware;

use Pawon\Contrib\Http\WebMiddlewareFactory as BaseFactory;

class WebMiddlewareFactory extends BaseFactory
{
    /**
     * Add your middleware here to run them on web. So we can differentiate it
     * with api.
     *
     * @var array
     */
    protected $webStack = [
        'Pawon\Cookie\QueueMiddleware',
        'Pawon\Session\SessionMiddleware',
        'Pawon\Middleware\Csrf',
        'Pawon\Auth\AuthenticationMiddleware',
        'Pawon\Flash\FlashMessageMiddleware',
        'Pawon\Middleware\ContextProcessor',
    ];
}
