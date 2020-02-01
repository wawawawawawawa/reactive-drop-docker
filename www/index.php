<?php
/*  SM Translator
 *
 *  Copyright (C) 2019
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 *
 * @author Gandalf
 */

class Translation
{
    const API_KEY='/opt/translation_key.txt';
    const CACHE_TTL=604800;
    const MAX_LENGTH=508;

    private $text;
    private $cache;

    public function __construct($text)
    {
        $this->text = trim($text);
        $this->cache = $this->createCache();
    }

    private function createCache()
    {
        $cache = new Memcache;
        $cache->addServer('127.0.0.1', 11211);

        return $cache;
    }

    private function getApiKey()
    {
        $cacheKey = 'translation_key';
        $apiKey = $this->cache->get($cacheKey);

        if (!$apiKey) {
            $apiKey = trim(file_get_contents(self::API_KEY));
            $this->cache->set($cacheKey, $apiKey, null, self::CACHE_TTL);
        }

        return $apiKey;
    }

    private function fetchTranslation($lang)
    {
        if (preg_match('/\b(lag)|(lagging)|(lags)\b', $this->text)) {
            $this->text = "No lag, it's only you";
        }
                       
        $uri = sprintf(
            'https://translate.yandex.net/api/v1.5/tr.json/translate?key=%s&text=%s&lang=%s',
            $this->getApiKey(),
            urlencode($this->text),
            $lang
        );

        $response = json_decode(file_get_contents($uri));
        if (!$response) {
            throw new Exception('no response');
        }

        return $response;
    }

    private function sendHeader($code)
    {
        header(
            sprintf('X-Status: %d', $code),
            true,
            $code
        );
    }

    public function translate($lang)
    {
        $key = sprintf('%s:%s', $lang, hash('md4', $this->text));

        $response = $this->cache->get($key);
        if (!$response) {
            $response = $this->fetchTranslation($lang);
            $this->cache->set($key, $response, null, self::CACHE_TTL);
        }

        if ($response->code == 200 && $this->text == trim(current($response->text))) {
            $response->code = 204; // no-content
        }

        $this->sendHeader($response->code);
        if ($response->code == 200) {
            echo substr(current($response->text), 0, self::MAX_LENGTH);
        }
    }
}

$text = $_REQUEST['input'] ?? 'Bonjour';
$lang = $_REQUEST['target'] ?? 'en';

$translator = new Translation($text);
$translator->translate($lang);

exit;
