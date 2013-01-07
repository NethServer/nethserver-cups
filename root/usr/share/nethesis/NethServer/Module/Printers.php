<?php
namespace NethServer\Module;

/*
 * Copyright (C) 2011 Nethesis S.r.l.
 * 
 * This script is part of NethServer.
 * 
 * NethServer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * NethServer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with NethServer.  If not, see <http://www.gnu.org/licenses/>.
 */

use Nethgui\System\PlatformInterface as Validate;

/**
 * Enable or disable cups print server
 *
 * @author Giacomo Sanchietti<giacomo.sanchietti@nethesis.it>
 */
class Printers extends \Nethgui\Controller\AbstractController
{

    protected function initializeAttributes(\Nethgui\Module\ModuleAttributesInterface $base)
    {
        return \Nethgui\Module\SimpleModuleAttributesProvider::extendModuleAttributes($base, 'Configuration', 30);
    }

    public function initialize()
    {
        parent::initialize();
        $this->declareParameter('status', Validate::SERVICESTATUS, array('configuration', 'cups', 'status'));
    }

    protected function onParametersSaved($changes)
    {
        $this->getPlatform()->signalEvent('nethserver-cups-save@post-process');
    }

    public function prepareView(\Nethgui\View\ViewInterface $view)
    {
        parent::prepareView($view);
        $view['port'] = $this->getPlatform()->getDatabase('configuration')->getProp('cups','TCPPort');
        $hostname = $this->getPlatform()->getDatabase('configuration')->getType('SystemName');
        $domain = $this->getPlatform()->getDatabase('configuration')->getType('DomainName');
        $view['fqdn'] = "$hostname.$domain";
        $status = $this->getPlatform()->getDatabase('configuration')->getProp('cups','status');
        if ($status == 'enabled') {
	    $view['url'] = $view->translate('url_access_label', array($view['fqdn'], $view['port']));
        } else { 
            $view['url'] = "";
        }
    }

}

