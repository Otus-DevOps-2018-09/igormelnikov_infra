# igormelnikov_infra
igormelnikov Infra repository

Подключение ко внутреннему хосту при помощи команды ssh someinternalhost:

Файл ~/.ssh/config:

Host someinternalhost
        User appuser
        IdentityFile ~/.ssh/appuser
        ProxyCommand ssh appuser@bastion -W %h:%p
Host bastion
        User appuser
        HostName 35.210.200.77
        IdentityFile ~/.ssh/appuser

bastion_IP = 35.204.149.219
someinternalhost_IP = 10.164.0.3
testapp_IP = 35.209.154.150
testapp_port = 9292
