<?php

namespace App\Http\Actions\Api;

use Pawon\Http\Middleware\FrameInterface;
use Pawon\Http\Middleware\MiddlewareInterface;
use Psr\Http\Message\ServerRequestInterface as Request;
use function Itertools\zip;
use function Itertools\map;

class CitiesApi implements MiddlewareInterface
{
    /**
     *
     */
    public function handle(Request $request, FrameInterface $frame)
    {
        $file = 'resources/static/cities.json';
        $cities = json_decode(file_get_contents($file), true);
        $state = strtoupper($request->getAttribute('state'));
        $citiesOnState = isset($cities[$state]) ? $cities[$state] : [];

        $pairMap = map(function ($elem) {
            return [
                'code' => $elem[0],
                'name' => $elem[1]
            ];
        }, zip(array_keys($citiesOnState), array_values($citiesOnState)));

        json_encode(null);
        // JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT | JSON_UNESCAPED_SLASHES
        $json = json_encode(iterator_to_array($pairMap), 79);
        return $frame->getResponseFactory()->make($json, 200, [
            'Content-Type'  => 'application/json; charset=utf-8'
        ]);
    }
}
