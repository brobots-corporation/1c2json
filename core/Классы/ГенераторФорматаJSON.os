#Использовать fs
#Использовать ".\internal"

Перем Лог;
Перем ОбработаноФайлов;
Перем РазмерыФайлов;
Перем КаталогИсходников;
Перем КаталогРезультатов;

Процедура ПриСозданииОбъекта(Настройки)

	Лог = Константы1c2json.ПолучитьЛог();

	КаталогИсходников = Настройки.КаталогИсходников;
	Если НЕ Настройки.Свойство("КаталогРезультатов", КаталогРезультатов)
	 ИЛИ ПустаяСтрока(КаталогРезультатов) Тогда
		КаталогРезультатов = КаталогИсходников;
	КонецЕсли;
	Лог.Информация("Каталог результатов JSON: " + КаталогРезультатов);

КонецПроцедуры

#Область ПрограммныйИнтерфейс

Процедура ПередОбработкой() Экспорт

	ОбработаноФайлов = 0;
	РазмерыФайлов = 0;

КонецПроцедуры

Процедура ПослеОбработки() Экспорт

	Лог.Информация("Создано файлов данных: " + ОбработаноФайлов);
	Лог.Информация("Размер файлов данных (Кб): " + Цел(РазмерыФайлов / 1024));

КонецПроцедуры

Процедура ОбработатьФайл(ОписаниеФайла) Экспорт

	Если ОписаниеФайла.Тип = "Module" Тогда
		ОбработатьМодуль(ОписаниеФайла);
	Иначе
		ОбработатьМетаданные(ОписаниеФайла);
	КонецЕсли;
	ОбработаноФайлов = ОбработаноФайлов + 1;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыФункции

Процедура ОбработатьМодуль(ОписаниеФайла)

	ФайлДанных = СтрЗаменить(ОписаниеФайла.ПолноеИмяФайла, ".bsl", ".json");
	Если КаталогРезультатов <> КаталогИсходников Тогда
		ФайлДанных = СтрЗаменить(ФайлДанных, КаталогИсходников, КаталогРезультатов);
		ТестФайл = Новый Файл(ФайлДанных);
		ФС.ОбеспечитьКаталог(ТестФайл.Путь);
	КонецЕсли;

	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.ОткрытьФайл(ФайлДанных);

	ОписаниеМодуля = Новый Структура;
	ОписаниеМодуля.Вставить("Object", ОписаниеФайла.ОбъектМетаданных);
	ОписаниеМодуля.Вставить("LocalLink", ОписаниеФайла.ИмяФайла);
	ОписаниеМодуля.Вставить("Link", ОписаниеФайла.ПолноеИмяФайла);
	ОписаниеМодуля.Вставить("Metods", Новый Массив);

	Для Каждого СтрокаМетода Из ОписаниеФайла.Методы Цикл

		ОписаниеМетода = Новый Структура;
		ОписаниеМетода.Вставить("Name", СтрокаМетода.Имя);
		ОписаниеМетода.Вставить("Type", СтрокаМетода.Вид); // Процедура / Функция
		ОписаниеМетода.Вставить("Description", СтрокаМетода.Описание);
		ОписаниеМетода.Вставить("Result", СтрокаМетода.Результат);
		ОписаниеМетода.Вставить("Scope", СтрокаМетода.Директива);
		ОписаниеМетода.Вставить("Export", СтрокаМетода.Экспорт);
		ОписаниеМетода.Вставить("Params", Новый Массив);

		Для Каждого СтрокаПараметра Из СтрокаМетода.Параметры Цикл
			ОписаниеПараметра = Новый Структура;
			ОписаниеПараметра.Вставить("Name", СтрокаПараметра.Имя);
			ОписаниеПараметра.Вставить("Type", СтрокаПараметра.Тип);
			ОписаниеПараметра.Вставить("Name", СтрокаПараметра.Описание);
			ОписаниеПараметра.Вставить("ByValue", СтрокаПараметра.ПоЗначению);
			ОписаниеПараметра.Вставить("ByDefault", СтрокаПараметра.ПоУмолчанию);
			ОписаниеМетода.Params.Добавить(ОписаниеПараметра);
		КонецЦикла;

		ОписаниеМодуля.Metods.Добавить(ОписаниеМетода);
	КонецЦикла;

	ЗаписатьJSON(ЗаписьJSON, ОписаниеМодуля);

	ЗаписьJSON.Закрыть();

	Файл = Новый Файл(ФайлДанных);
	РазмерыФайлов = РазмерыФайлов + Файл.Размер();  

	//Лог.Отладка("Записан файл %1", ФайлДанных);

КонецПроцедуры

Процедура ОбработатьМетаданные(ОписаниеФайла)

	ФайлДанных = СтрЗаменить(ОписаниеФайла.ПолноеИмяФайла, ".xml", ".json");

	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.ОткрытьФайл(ФайлДанных);

	ОписаниеМодуля = Новый Структура;
	ОписаниеМодуля.Вставить("Object", ОписаниеФайла.ОбъектМетаданных);
	ОписаниеМодуля.Вставить("LocalLink", ОписаниеФайла.ИмяФайла);
	ОписаниеМодуля.Вставить("Link", ОписаниеФайла.ПолноеИмяФайла);
	ОписаниеМодуля.Вставить("Metadata", ОписаниеФайла.Метаданные);

	ЗаписатьJSON(ЗаписьJSON, ОписаниеМодуля);

	ЗаписьJSON.Закрыть();

	Файл = Новый Файл(ФайлДанных);
	РазмерыФайлов = РазмерыФайлов + Файл.Размер();  

	//Лог.Отладка("Записан файл %1", ФайлДанных);

КонецПроцедуры

#КонецОбласти