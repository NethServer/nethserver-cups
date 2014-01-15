<?php

if (count(array_keys($view['printers'])) == 0) {
    echo "<div class='printer-item'>";
    echo "<h2>".$T('no_printers')."</h2>";
    echo "</div>";
}

foreach ($view['printers'] as $printer => $props) {
    echo "<div class='printer-item'>";
    echo "<h2>$printer</h2>";
    echo "<dl>";
    echo "<dt>".$T('printer_state')."</dt><dd>"; echo $T($props['state']); echo "</dd>";
    echo "<dt>".$T('printer_enabled')."</dt><dd>"; echo $T($props['enabled']); echo "</dd>";
    echo "</dl>";
    echo "</div>";
}


$view->includeCSS("
  div.printer-item {
    margin: 5px;
    padding: 5px;
    border: 1px solid #ccc;
    max-width: 400px;
  }
  .printer-item dt {
    float: left;
    clear: left;
    text-align: right;
    font-weight: bold;
    margin-right: 0.5em;
    padding: 0.1em;
  }
  .printer-item dt:after {
    content: \":\";
  }
  .printer-item dd {
    padding: 0.1em;
  }
  .printer-item h2 {
    font-weight: bold;
    font-size: 120%;
    text-align: center;
    padding: 0.2em;
  }
  .printer-item pre {
      margin-top: 2px;
      padding: 2px;
  }
");

