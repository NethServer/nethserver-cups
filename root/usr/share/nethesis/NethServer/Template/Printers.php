<?php

echo $view->header()->setAttribute('template', $T('Printers'));

echo $view->panel()
    ->insert($view->checkbox('status', 'enabled')->setAttribute('uncheckedValue', 'disabled'));

if ($view['status'] == 'enabled') {
    echo "<p>".$T("url_access_label").$view['port']."</p>";
}

echo $view->buttonList($view::BUTTON_SUBMIT | $view::BUTTON_HELP);
?>
