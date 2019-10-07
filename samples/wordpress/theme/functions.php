<?php

// SETUP

// INCLUDES


/**
 * Theme assets
 */
add_action('wp_enqueue_scripts', function () {
	$manifest = json_decode(file_get_contents('_build/assets.json', true));
	$main = $manifest->main;
	var_dump($main);
	wp_enqueue_style('theme-css', get_template_directory_uri() . "/_build/" . $main->css,  false, null);
	wp_enqueue_script('theme-js', get_template_directory_uri() . "/_build/" . $main->js, [], null, true);
}, 100);


// HOOKS
// add_action('wp_enqueue_scripts', 'st_enqueue');

// SHORCODES
