# FearProject Lab
Проект создан для обучения разработки и улучшения проекта FearProject.ru
Функциональность FearLab

## Проверка конфигурации сервера

Из корня репозитория запустите валидатор:

```powershell
pwsh -File ./scripts/Test-ServerConfig.ps1
```

По умолчанию проверяется `config/server.json` относительно расположения
скрипта. Для другого файла укажите параметр `-Path`:

```powershell
pwsh -File ./scripts/Test-ServerConfig.ps1 -Path ./config/server.json
```

Для запуска воспроизводимых проверок используйте:

```powershell
pwsh -File ./scripts/Test-ServerConfig.Tests.ps1
```

В Windows PowerShell 5.1 используйте `powershell.exe` вместо `pwsh`.
