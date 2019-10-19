<?php
function translate($text, $lang='en')
{
    // cache key
    $key = sprintf('%s:%s', $lang, hash('md4', $text));

    // lookup the key
    $mc = new Memcache;
    $mc->addServer('127.0.0.1', 11211);

    // fetch translation key
    $apiKey = $mc->get('translation_key');
    if (!$apiKey) {
        $apiKey = get_api_key();
        $mc->set('translation_key', $apiKey);
    }

    $json = $mc->get($key);
    if (!$json) {

        // translate
        $uri = sprintf(
            'https://translate.yandex.net/api/v1.5/tr.json/translate?key=%s&text=%s&lang=%s',
            $apiKey,
            urlencode($text),
            $lang
        );

        $json = (array)json_decode(file_get_contents($uri));
    
        // store the response for one day
        $mc->set($key, $json, null, 86400);
    }

    header(
        sprintf('X-Translation-Status: %d', $json['code']),
        true,
        $json['code']
    );

    if ($json['code'] == 200) {
        echo substr(
            current($json['text']),
            0,
            500
        );
    }
}

function get_api_key()
{
    return trim(file_get_contents('/opt/translation_key.txt'));
}

translate(
    $_REQUEST['input'],
    $_REQUEST['target']
);

exit;