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
    
    -- Проверяем предметы в сети
    if me.getItemsInNetwork then
        local success, items = pcall(me.getItemsInNetwork)
        if success then
            print("✅ Предметы в сети: " .. #items .. " типов")
            if #items > 0 then
                print("   Примеры предметов:")
                for i = 1, math.min(3, #items) do
                    local item = items[i]
                    print("   - " .. (item.label or item.name or "Неизвестный") .. " x" .. (item.size or 0))
                end
            end
        else
            print("❌ Ошибка getItemsInNetwork(): " .. items)
        end
    else
        print("⚠️ getItemsInNetwork() недоступен")
    end
    

    
    -- Проверяем CPU
    if me.getCpus then
        local success, cpus = pcall(me.getCpus)
        if success then
            print("✅ CPU в сети: " .. #cpus)
            local busyCpus = 0
            for _, cpu in ipairs(cpus) do
                if cpu.busy then
                    busyCpus = busyCpus + 1
                end
            end
            if busyCpus > 0 then
                print("   Занято CPU: " .. busyCpus)
            end
        else
            print("❌ Ошибка getCpus(): " .. cpus)
        end
    else
        print("⚠️ getCpus() недоступен")
    end
    
    -- Проверяем крафтабельные предметы
    if me.getCraftables then
        local success, craftables = pcall(me.getCraftables)
        if success then
            print("✅ Доступно рецептов: " .. #craftables)
        else
            print("❌ Ошибка getCraftables(): " .. craftables)
        end
    else
        print("⚠️ getCraftables() недоступен")
    end
    
    print()
    print("=== Информация о питании сети ===")
    
    -- Проверяем питание сети
    if me.getStoredPower then
        local success, storedPower = pcall(me.getStoredPower)
        if success then
            print("Накопленная энергия: " .. string.format("%.1f", storedPower) .. " AE")
        else
            print("❌ Ошибка getStoredPower(): " .. storedPower)
        end
    end
    
    if me.getMaxStoredPower then
        local success, maxStoredPower = pcall(me.getMaxStoredPower)
        if success then
            print("Максимум накопления: " .. string.format("%.1f", maxStoredPower) .. " AE")
        else
            print("❌ Ошибка getMaxStoredPower(): " .. maxStoredPower)
        end
    end
    
    if me.getAvgPowerUsage then
        local success, avgUsage = pcall(me.getAvgPowerUsage)
        if success then
            print("Среднее потребление: " .. string.format("%.2f", avgUsage) .. " AE/t")
        else
            print("❌ Ошибка getAvgPowerUsage(): " .. avgUsage)
        end
    end
    
    if me.getAvgPowerInjection then
        local success, avgInjection = pcall(me.getAvgPowerInjection)
        if success then
            print("Среднее поступление: " .. string.format("%.2f", avgInjection) .. " AE/t")
        else
            print("❌ Ошибка getAvgPowerInjection(): " .. avgInjection)
        end
    end
    
    if me.getIdlePowerUsage then
        local success, idleUsage = pcall(me.getIdlePowerUsage)
        if success then
            print("Потребление в покое: " .. string.format("%.2f", idleUsage) .. " AE/t")
        else
            print("❌ Ошибка getIdlePowerUsage(): " .. idleUsage)
        end
    end
    
    return true
end

-- Функция для детального анализа сети
function analyzeNetwork()
    if not component.isAvailable("me_controller") then
        print("ME Controller недоступен для анализа!")
        return
    end
    
    local me = component.me_controller
    term.clear()
    print("=== Детальный анализ ME сети ===")
    print("Адрес контроллера: " .. me.address)
    print()
    
    -- Анализ предметов
    local success, items = pcall(me.getItemsInNetwork)
    if success then
        print("📦 ПРЕДМЕТЫ В СЕТИ:")
        print("Всего типов предметов: " .. #items)
        
        if #items > 0 then
            -- Сортируем по количеству
            table.sort(items, function(a, b) return (a.size or 0) > (b.size or 0) end)
            
            print("Топ-5 предметов по количеству:")
            for i = 1, math.min(5, #items) do
                local item = items[i]
                local name = item.label or item.name or "Неизвестный"
                local size = item.size or 0
                print(string.format("  %d. %s - %s шт.", i, name, size))
            end
            
            -- Подсчет общего количества предметов
            local totalItems = 0
            for _, item in ipairs(items) do
                totalItems = totalItems + (item.size or 0)
            end
            print("Общее количество предметов: " .. totalItems)
        end
        print()
    end
    

    
    -- Анализ процессоров
    local success, cpus = pcall(me.getCpus)
    if success then
        print("⚡ ПРОЦЕССОРЫ:")
        print("Всего CPU: " .. #cpus)
        
        local busyCpus = 0
        local craftingJobs = {}
        
        for i, cpu in ipairs(cpus) do
            if cpu.busy then
                busyCpus = busyCpus + 1
                if cpu.activeItems and #cpu.activeItems > 0 then
                    for _, item in ipairs(cpu.activeItems) do
                        table.insert(craftingJobs, item.label or item.name or "Неизвестный")
                    end
                end
            end
        end
        
        print("Занято CPU: " .. busyCpus)
        
        if #craftingJobs > 0 then
            print("Текущие задачи крафта:")
            for i, job in ipairs(craftingJobs) do
                print("  - " .. job)
            end
        end
        print()
    end
    
    -- Анализ питания
    print("🔋 АНАЛИЗ ПИТАНИЯ:")
    
    local power = {}
    local success, val
    
    success, val = pcall(me.getStoredPower)
    if success then power.stored = val end
    
    success, val = pcall(me.getMaxStoredPower)
    if success then power.maxStored = val end
    
    success, val = pcall(me.getAvgPowerUsage)
    if success then power.usage = val end
    
    success, val = pcall(me.getAvgPowerInjection)
    if success then power.injection = val end
    
    success, val = pcall(me.getIdlePowerUsage)
    if success then power.idle = val end
    
    if power.stored and power.maxStored then
        local percentage = power.maxStored > 0 and (power.stored / power.maxStored * 100) or 0
        print(string.format("Накопленная энергия: %.1f / %.1f AE (%.1f%%)", power.stored, power.maxStored, percentage))
    end
    
    if power.usage and power.injection then
        local balance = power.injection - power.usage
        print(string.format("Потребление: %.2f AE/t", power.usage))
        print(string.format("Поступление: %.2f AE/t", power.injection))
        print(string.format("Баланс: %s%.2f AE/t", balance >= 0 and "+" or "", balance))
        
        if power.stored and balance ~= 0 then
            local timeLeft = balance < 0 and (power.stored / (-balance)) or -1
            if timeLeft > 0 then
                print(string.format("⚠️ Энергия закончится через: %.1f тиков (%.1f сек)", timeLeft, timeLeft / 20))
            end
        end
    end
    
    if power.idle then
        print(string.format("Потребление в покое: %.2f AE/t", power.idle))
    end
    
    print()
    print("Нажмите Enter для возврата в меню...")
    io.read()
end
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
        
        -- Информация об энергии контроллера
        local success, energy = pcall(me.getEnergyStored)
        local success2, maxEnergy = pcall(me.getMaxEnergyStored)
        
        if success and success2 then
            local percentage = maxEnergy > 0 and math.floor((energy / maxEnergy) * 100) or 0
            print("Энергия контроллера: " .. energy .. " / " .. maxEnergy .. " AE (" .. percentage .. "%)")
            
            -- Индикатор энергии
            local barLength = 40
            local filled = math.floor((energy / maxEnergy) * barLength)
            local bar = "[" .. string.rep("=", filled) .. string.rep("-", barLength - filled) .. "]"
            print(bar)
        else
            print("❌ Ошибка получения информации об энергии контроллера")
        end
        
        print()
        
        -- Информация о питании сети
        local success3, netPower = pcall(me.getStoredPower)
        local success4, netMaxPower = pcall(me.getMaxStoredPower)
        local success5, avgUsage = pcall(me.getAvgPowerUsage)
        local success6, avgInjection = pcall(me.getAvgPowerInjection)
        
        if success3 and success4 then
            local netPercentage = netMaxPower > 0 and math.floor((netPower / netMaxPower) * 100) or 0
            print("Питание сети: " .. string.format("%.1f", netPower) .. " / " .. string.format("%.1f", netMaxPower) .. " AE (" .. netPercentage .. "%)")
        end
        
        if success5 and success6 then
            local balance = avgInjection - avgUsage
            local balanceStr = balance >= 0 and ("+" .. string.format("%.2f", balance)) or string.format("%.2f", balance)
            print("Потребление: " .. string.format("%.2f", avgUsage) .. " AE/t | Поступление: " .. string.format("%.2f", avgInjection) .. " AE/t | Баланс: " .. balanceStr .. " AE/t")
        end
        
        -- Информация о предметах и процессорах
        local success7, items = pcall(me.getItemsInNetwork)
        local success8, cpus = pcall(me.getCpus)
        
        if success7 then
            print("Предметы в сети: " .. #items .. " типов")
        end
        
        if success8 then
            local busyCpus = 0
            for _, cpu in ipairs(cpus) do
                if cpu.busy then
                    busyCpus = busyCpus + 1
                end
            end
            print("CPU: " .. #cpus .. " всего, " .. busyCpus .. " занято")
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
        print("2. Детальный анализ сети")
        print("3. Мониторинг статуса в реальном времени")
        print("4. 📜 Мониторинг изменений предметов")
        print("5. Выход")
        print()
        print("Выберите опцию (1-5): ")
        
        local input = io.read()
        
        if input == "1" then
            term.clear()
            checkMEController()
            print()
            print("Нажмите Enter для продолжения...")
            io.read()
        elseif input == "2" then
            analyzeNetwork()
        elseif input == "3" then
            term.clear()
            monitorME()
        elseif input == "4" then
            term.clear()
            monitorItemChanges()
        elseif input == "5" then
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
