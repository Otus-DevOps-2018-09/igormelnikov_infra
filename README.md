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
testapp_IP = 35.208.236.82
testapp_port = 9292

Startup script: файл install.sh
Команда gcloud:
gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family=ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --metadata-from-file startup-script=install.sh

Команда gcloud, если скрипт находится в бакете infra-reddit-storage:
gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family=ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --scopes storage-ro --metadata startup-script-url=gs://infra-reddit-storage/install.sh

Команда gcloud для создания правила фаервола default-puma-server:
gcloud compute --project=infra-219315 firewall-rules create default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server

В main.tf описано добавление нескольких ssh-ключей в метаданные проекта. Если добавить ключ appuser_web через веб-интерфейс, при следующем terraform apply он будет удалён, поскольку не прописан в terraform. Таким образом, все изменения инфраструктуры должны производиться через код.

При описании второго инстанса reddit-app2 мы имеем одинаковые конфигурации, каждую из которых придётся поддерживать и обновлять по отдельности, следя при этом за повторяемостью и проч. Кроме того, мы не можем воспользоваться managed группой инстансов в GCP.

main.tf - описание группы инстансов reddit-app1, reddit-app2 etc. count = 2
lb.tf - описание http-балансировщика
outputs.tf:
	all_app_external_ips - список внешних адресов каждого инстанса
	lb_external_ip - внешний адрес балансировщика
