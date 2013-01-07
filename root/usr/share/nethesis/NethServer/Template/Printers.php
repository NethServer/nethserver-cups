<?php

echo $view->header()->setAttribute('template', $T('Printers'));

echo $view->panel()
    ->insert($view->checkbox('status', 'enabled')->setAttribute('uncheckedValue', 'disabled'))
    ->insert($view->textLabel('url'));

echo $view->buttonList($view::BUTTON_SUBMIT | $view::BUTTON_HELP);
?>
