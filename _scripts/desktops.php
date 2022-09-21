#!/usr/bin/php8.1
<?php

function dd ($val)
{
    var_dump($val);
    exit();
}

$desktops = shell_exec('wmctrl -d');
$desktops = preg_replace('/\n$/', '', $desktops);
$desktops = explode("\n", $desktops);
$apps = shell_exec('wmctrl -l');
$apps = preg_replace('/\n$/', '', $apps);
$apps = explode("\n", $apps);


$desktopIds = [];
$map = [];
foreach ($desktops as $desktop) {
    preg_match_all('/^([0-9]+).*([a-z]+)$/', $desktop, $matches);
    $desktopIds[$matches[1][0]] = strtoupper($matches[2][0]);
    $map[$matches[2][0]] = [];
}

foreach ($apps as $app) {
    preg_match_all('#^[0-9a-z]+\s+([0-9]+)\s+[a-zA-Z\/]+ (.*)$#', $app, $matches);
    $id = $matches[1][0];
    $name = $matches[2][0];
    $map[$desktopIds[$id]][] = $name;
}


$list = "";

$width = 39;
$maxapps = 5;
$height = 3 + $maxapps;

//$rows = ["qwerty", "asdf i","zxcvg","   bnm"];
$rows = ["qwertyi", "asdfg","zxcvbnm"];

$sorted = [];
foreach ($rows as $row) {
    $letters = str_split($row);
    foreach ($letters as $d) {
        $d = strtoupper($d);
        if (isset($map[$d])) {
            $sorted[$row] = $sorted[$row] ?? [];
            $sorted[$row][] = [$d, $map[$d]];
        } else {
            $sorted[$row][] = [$d, []];       
        }
    }
}


$textRows = [];
foreach ($sorted as $row => $contents) {

    $thisRow = "";

    foreach ($contents as $desktop => $apps) {
        
        $desktop = $apps[0];
        $apps = $apps[1];

        //$block = str_pad($desktop, $width, " ", STR_PAD_BOTH) . "\n";
        $block = str_pad($desktop, $width, " ", STR_PAD_RIGHT) . "\n";
        $block .= str_pad("-----", $width, ' ') . "\n";

        $appcount = count($apps);

        if ($appcount > $maxapps) {
            $moreApps = 1 + $appcount - $maxapps;
            $apps[$maxapps-1] = sprintf("And %s more...", $moreApps);
        }

        for ($i = 0; $i < $maxapps; $i++) {

            if (!isset($apps[$i])) {
                $block .= str_pad("", $width) . "\n";
                continue;
            }

            $app = substr($apps[$i], 0, $width - 4);
            $app = str_pad($app, $width);

            $block .= sprintf("%s\n", $app);

        }
        $block .= "\n";
        $thisRow .= $block;
    }

    $horizontal = "";

    $lines = explode("\n", $thisRow);

    foreach (range(0, $height-1) as $i) {

        $a = 0;

        while (isset($lines[$i + ($a * $height)])) {
            $text = $lines[$i + ($a * $height)];
            $horizontal .= preg_replace('/\n/', '', $text);
            $horizontal .= "  ";
            $a++;
        }
        $horizontal .= "\n";

    }
    $textRows[$row] = $horizontal;
}

$output = "";
foreach ($textRows as $row) {
    $output .= $row;
    $output .= "\n\n";
}

file_put_contents('/tmp/workspaces.txt', $output);

echo 'done';
exit();
