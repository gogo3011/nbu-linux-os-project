# CSCB534 Проект: Операционни системи (UNIX/Linux)
### Георги Ивов Димитров - F9722
## Задание
> Изгответе скрипт с меню за филтриране на всички потребители в сървъра и филтрирането на тези, които имат 1 в потребителското си име. Работете в Linux. 
## Първоначална настройка на работна среда
Работата по заданието започна със създаването и настройването на нужната за изпълнението на задачата работна среда. 
Тъй като основната и най-мощната компютърна система на мое разположение работи с Windows 10, удобният и удачен вариант е да настоя една виртуална десктоп среда, като за това използвах Oracle VirtualBox версия `7.0.10`.

Изборът на Linux дистрибуция, която да ползвам за създаването и тестването на този скрипт, няма пряко влияние върху командите в него, тъй като за работата му са нужни стандартни команди налични в (почти) всички UNIX-like операционни системи. В този случай, избрах Linux Mint, по-точно `21.2 Cinnamon` версията, защото предоставя добър графичен интерфейс, с който съм сравнително запознат. Имам и лични наблюдения под формата на сървър работещ с него и хостващ няколко web приложения за лично ползване.

Създадената виртуалната машина разполага с `8GB` RAM памет, 6 процесори ядра и `50GB` виртуално място за съхранение. За разработването/тестването/ползването на този скрипт тези параметри за повече от достатъчни, но предвиждах да използвам виртуалната машина за целия процес на работата ми, включително проучване на източници, ползването на интегрирани среди за разработка, контрол върху версиите и други. (браузър, git, vs code etc.).

Инсталацията на операционната система протече изключително лесно благодарение на добрия графичен инсталационен гид. Той създава минимално нужните два `Ext4` и `FAT` дяла, пита за login детайлите на главния потребител (потребителско име, парола), както и под какво име самата система да се представя в мрежа (network name). След бърз рестарт операционната система е инсталирана на виртуалната памет за съхранение. 

За удобство се инсталират и така наречените `гост допълнения`, т.е. софтуерен пакет, който подобрява комуникациите между хост софтуера (`Virtual Box`) и операционната система във виртуалната машина. Това отключва функции като споделен буфер за копиране и поставяне, както и активно оразмеряване на изходната резолюция на виртуализираната операционна система спрямо размера на прозореца на виртуалната система в хост операционната система.

След тези стъпки работната среда е настроена и системата е готова за ползване. Разработката на скрипта може да започне.

## Разработка
За улеснение на потребителите скриптът предоставя меню с наличните опции, всяка с кратко описание и индекси, които да послужат като механизъм на избора. Ако той е валиден, скриптът продължава към избраната функция, а в противен случай информира потребителя за невалидния параметър. И в двата случая потребителят отново има право на избор, включително и да излезе от скрипта.

Следното представлява flowchart на процеса на скрипта:

![flowchart](flowchart.png)


Според изискванията скриптът трябва да показва потребителите в операционната система. В UNIX за това отговаря `passwd` NSS. По подразбиране в LINUX записите за съществуващите потребители се пазят във файл `/etc/passwd`, служещ като база данни. Структурата му е сравнително проста, представлява текстов файл, в който всеки нов ред е запис потребител, а стойностите в колоните са разделени с двоеточие `:`. Форматът напомня на `csv` файл с разделител. Това е само един от възможните начини за съхранение на информацията за потребителите. Като друга възможност може да имаме и LDAP система (отдалечена или не).

Като пример за запис нека разгледаме реда на текущия потребител от базата данни на Mint виртуалната машина.

```
georgi-vm:x:1000:1000:georgi-vm,,,:/home/georgi-vm:/bin/bash
```

Структурата е следната, имайки предвид, че колоните са разделени от двоеточие:
1. Потребителско име
2. Информация за наличието на парола за достъп, като тя се пази в хеширан вид
3. Уникален идентификационен номер на потребителя (uid)
4. Уникален идентификационен номер на главната група, в която потребителят членува и до която има достъп
5. Допълнителна информация за контактите на потребителя, разделена от запетаи (пълно име, лице за контакт, имейл адрес и т.н)
6. Адрес на потребителската директория в системата
7. Терминалът (още наричан shell в Linux), стартиран по подразбиране за потребителя при вход в системата, като системните потребители често имат `usr/sbin/nologin` за стойност (т.е нямат такъв, вместо това виждат съобщение, което информира за невалидното действие)

Базите от данни от това естество в UNIX системи се достъпват от инструмента `getent`. Като параметър той приема името на базата, записите на която трябва да бъдат изведени. Командата, която изпълняваме, за да видим всички потребители, е `getent passwd`. Това всъщност е и командата за първата опция от изисквания скрипт.

За втората опция скриптът ще предостави възможност за филтриране на потребителите спрямо някакъв pattern за търсене. Както знаем, в Linux може да изпълняваме и навързваме няколко команди една след друга, като изходът на едната може да служи за вход на следващата. За нужното филтриране е удачно да се ползва `grep` (global regular expression print) командата, която търси за regex шаблони и извежда за резултат попаденията. В нашия случай командата ни за опция две трябва да търси въведен от потребителя pattern в резултата на `getent passwd`. За да прочетем входа на потребителя, използваме `read` bash командата, с която в променливата `filter` ще запазим шаблона. Следващата команда (или връзка от команди) трябва да бъде `getent passwd | grep $filter`.

Третата опция ще позволи филтрирането на записите спрямо низ, наличен в потребителското им име. Ако погледнем списъка с колони, ще видим, че първата колона съдържа потребителското име. Следователно ни трябва начин, по който да търсим само в нея. Това отново може да бъде постигнато с помощта на възможността за нанизване на команди. За разделението и търсенето в записите ще използваме `awk`. Това е цял език за скриптиране, създаден за филтриране на текстови данни. Той е много мощен и функционален. Възможностите с него са много големи, но ние ще използваме много малка част от тях. Отново с `read`  записваме в променлива текста, по който ще филтрираме. За да го използваме в awk, трябва да използваме опционалния флаг `-v`, като в него трябва да назначим тази shell променлива към променлива, която ще се ползва в `awk` скрипта. След този флаг трябва да инструктираме awk да раздели текста на колони, ползвайки `:` за разделител, като данните в тези колони стават достъпни чрез номериране, т.е. първата колона, която съдържа потребителското име, ще е достъпна под променливата `$1`. Следващият параметър към командата е самият `awk` скрипт, който трябва да се изпълни върху данните. По изискването на задачата трябва да търсим дали даден низ от знаци се съдържа в потребителското име. За това може да използваме `index(str1, str2)` функцията на awk. Първият параметър е текстът, в който ще търсим; вторият е низът, който е търсен. Като резултат методът връща индекса на намерения низ или 0, ако той не е наличен. Всичко това означава, че командата, която ще използваме, изглежда така: `getent passwd | awk -v u="$userNameFilter" : 'index($1, u)'`

Четвъртата опция излиза от скрипта и връща потребителя към неговия терминал. Това става с командата `exit`.

Благодарение на switch case-а, който чете и изпълнява избраните функции, има и default опция, която хваща всички невалидни стойности, въведени от потребителя. В тази ситуация скриптът известява за това и менюто отново бива показано.

## Източници
> todo
