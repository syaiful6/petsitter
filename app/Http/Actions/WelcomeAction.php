<?php

namespace App\Http\Actions;

use Pawon\Http\Middleware\FrameInterface;
use Pawon\Http\Middleware\MiddlewareInterface;
use Psr\Http\Message\ServerRequestInterface as Request;
use Zend\Expressive\Template\TemplateRendererInterface;

class WelcomeAction implements MiddlewareInterface
{
    /**
     * @var Zend\Expressive\Template\TemplateRendererInterface
     */
    protected $templateRenderer;

    /**
    *
    */
    public function __construct(TemplateRendererInterface $templateRenderer)
    {
        $this->templateRenderer = $templateRenderer;
    }

    /**
     *
     */
    public function handle(Request $request, FrameInterface $frame)
    {
        $html = $this->templateRenderer->render('app::welcome');

        return $frame->getResponseFactory()->make($html, 200, [
            'Content-Type'  => 'text/html; charset=utf-8'
        ]);
    }
}
