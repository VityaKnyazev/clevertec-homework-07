<h1>CLEVERTEC (homework-07)</h1>

<p>CLEVERTEC homework-07 SQL:</p>
<ol>
<li>Установить docker, docker-compose</li>
<li>Выкачать https://github.com/sh00terGit/db</li>
<li>3)Запустить compose: docker-compose up -d</li>
<li>Подконнектиться через ui или idea http://localhost:5050, 
object -> create -> server 
* password postgres
</li>
<li>Задание. 
Написать sql запросы: 
Сохранить запросы в файле sql-task.sql в resourсes/sql в отдельной ветке и сделать PR. 
PS. В пулл-реквесте должен быть только один файл
</li>
</ol>

<h2>Что сделано:</h2>
<ol>
<li>Установлен docker и docker-compose.</li>
<li>Клонирован https://github.com/sh00terGit/db в локальный git-репозиторий.</li>
<li>Запущен compose: docker-compose up -d</li>
<li>Подключение производилось через ui (localhost:5050) и docker exec -it [container name] bin/bash, psql -U postgres -W -d demo.
<li>
Написаны sql-запросы в соответствии с заданием и сохранены в файле sql-task.sql в resourсes/sql в ветке homework/database. 
Сделан pull request с файлом задания.
</li>
</li>
</ol>