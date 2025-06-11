local component = require("component")
local term = require("term")
local os = require("os")

-- Функция для проверки подключения ME Controller
function checkMEController()
    print("=== ME Controller Connection Checker ===")
    print()
    
    -- Проверяем наличие ME Controller
    if not component.isAvailable("me_controller") then
        print("❌ ME Controller не найден!")
        print("Убедитесь что:")
        print("- ME Controller подключен к компьютеру через кабель")
        print("- Адаптер правильно настроен")
        print("- ME сеть запитана")
        return false
    end
    
    print("✅ ME Controller найден!")
    
    -- Получаем компонент ME Controller
    local me = component.me_controller
    print("Адрес: " .. me.address)
    print()
    
    -- Проверяем методы энергии
    print("=== Информация об энергии ===")
    
    local success, energy = pcall(me.getEnergyStored)
    if success then
        print("Текущая энергия: " .. energy .. " AE")
    else
        print("❌ Ошибка получения текущей энергии: " .. energy)
    end
    
    local success, maxEnergy = pcall(me.getMaxEnergyStored)
    if success then
        print("Максимальная энергия: " .. maxEnergy .. " AE")
        if energy and maxEnergy > 0 then
            local percentage = math.floor((energy / maxEnergy) * 100)
            print("Заполнение: " .. percentage .. "%")
        end
    else
        print("❌ Ошибка получения максимальной энергии: " .. maxEnergy)
    end
    
    local success, canExtract = pcall(me.canExtract)
    if success then
        print("Можно извлекать энергию: " .. (canExtract and "Да" or "Нет"))
    else
        print("❌ Ошибка проверки извлечения энергии: " .. canExtract)
    end
    
    local success, canReceive = pcall(me.canReceive)
    if success then
        print("Можно получать энергию: " .. (canReceive and "Да" or "Нет"))
    else
        print("❌ Ошибка проверки получения энергии: " .. canReceive)
    end
    
    print()
    print("=== Тест Common Network API ===")
    
    -- Проверяем методы Common Network API (если доступны)
    if me.getItems then
        local success, items = pcall(me.getItems)
        if success then
            print("✅ getItems() работает, найдено предметов: " .. #items)
        else
            print("❌ Ошибка getItems(): " .. items)
        end
    else
        print("⚠️ getItems() недоступен")
    end
    
    if me.getFluids then
        local success, fluids = pcall(me.getFluids)
        if success then
            print("✅ getFluids() работает, найдено жидкостей: " .. #fluids)
        else
            print("❌ Ошибка getFluids(): " .. fluids)
        end
    else
        print("⚠️ getFluids() недоступен")
    end
    
    return true
end

-- Функция для мониторинга в реальном времени
function monitorME()
    if not component.isAvailable("me_controller") then
        print("ME Controller недоступен для мониторинга!")
        return
    end
    
    local me = component.me_controller
    print("=== Мониторинг ME Controller ===")
    print("Нажмите Ctrl+C для выхода")
    print()
    
    while true do
        term.clear()
        print("=== Мониторинг ME Controller ===")
        print("Время: " .. os.date())
        print("Адрес: " .. me.address)
        print()
        
        local success, energy = pcall(me.getEnergyStored)
        local success2, maxEnergy = pcall(me.getMaxEnergyStored)
        
        if success and success2 then
            local percentage = maxEnergy > 0 and math.floor((energy / maxEnergy) * 100) or 0
            print("Энергия: " .. energy .. " / " .. maxEnergy .. " AE (" .. percentage .. "%)")
            
            -- Индикатор энергии
            local barLength = 40
            local filled = math.floor((energy / maxEnergy) * barLength)
            local bar = "[" .. string.rep("=", filled) .. string.rep("-", barLength - filled) .. "]"
            print(bar)
        else
            print("❌ Ошибка получения информации об энергии")
        end
        
        print()
        print("Обновление каждые 2 секунды...")
        os.sleep(2)
    end
end

-- Главное меню
function main()
    while true do
        term.clear()
        print("=== ME Controller Utility ===")
        print("1. Проверить подключение")
        print("2. Мониторинг в реальном времени")
        print("3. Выход")
        print()
        print("Выберите опцию (1-3): ")
        
        local input = io.read()
        
        if input == "1" then
            term.clear()
            checkMEController()
            print()
            print("Нажмите Enter для продолжения...")
            io.read()
        elseif input == "2" then
            term.clear()
            monitorME()
        elseif input == "3" then
            print("До свидания!")
            break
        else
            print("Неверный выбор!")
            os.sleep(1)
        end
    end
end

-- Запуск программы
main()
