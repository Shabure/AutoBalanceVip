# Auto Balance VIP for CS:GO

[![Version](https://img.shields.io/badge/Version-1.3-blue)](https://github.com/Shabure/autobalancevip)
[![License](https://img.shields.io/badge/License-GPLv3-green)](LICENSE)

Плагин для автоматической балансировки VIP-игроков на CS:GO серверах. Решает проблему дисбаланса между командами по количеству VIP-игроков, сохраняя общий баланс сервера.

## 🔥 Особенности
- Балансировка только для VIP-игроков (игнорирует общий баланс)
- Перемещение:
  - VIP → из команды с избытком (с максимальным счетом)
  - Обычные игроки → из команды с недостатком (с минимальным счетом)
- Поддержка RGB-цветов в чате


## 📥 Установка
1. Требования:
   - [SourceMod 1.10+](https://www.sourcemod.net/)
   - [VIP-Core](https://github.com/R1KO/VIP-CSGO)
   - [CS:GO Colored Chat](https://forums.alliedmods.net/showthread.php?t=267743)

2. Скопируйте в папку сервера:
  
   addons/sourcemod/plugins/AutoBalanceVIP.smx
 

## 🎮 Использование
### Основная логика
- Дисбаланс VIP считается по формуле: `|VIP_T - VIP_CT|`
- Балансировка срабатывает при **дисбалансе ≥2**
- Перемещение происходит **между раундами**

### Примеры сценариев
| Ситуация | Действие |
|----------|----------|
| 3 VIP_T vs 1 VIP_CT | Перемещает 1 VIP_T → 2v2 |
| 10 VIP_T vs 5 VIP_CT | Перемещает 1 VIP_T → 9v6 → повтор до баланса |

### Команды
```bash
sm_check_balance  # Показать текущий баланс
```


## ❗ Важно
- VIP-группы должны быть настроены в конфигурационном файле /addons/sourcemod/configs/vip_balance_groups.txt
- Для RGB-цветов требуется **SourceMod 1.10+**

## 📄 Лицензия
GNU General Public License v3.0. См. [LICENSE](LICENSE).

---
**Автор:** Shabure  
**Поддержка:** [Issues](https://github.com/yourname/autobalance-vip/issues)

