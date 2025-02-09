#include <cstrike>
#include <csgo_colors>
#include <vip_core>    // Подключаем инклуд VIP плагина

// Указываем VIP-группы для балансировки
char gsVIPGroups[][] = { "spons", "deluxe", "premium", "vip" };

bool g_bMSG;

public Plugin myinfo =
{
    name    = "Auto balance VIPs",
    author  = "Shabure",
    version = "1.0",
    url     = ""
};

public void OnPluginStart()
{
    // LoadTranslations("AutoBalanceVIPS.phrases");
    // HookEvent("player_death", Event_Death);
    HookEvent("round_prestart", Event_RoundPreStart, EventHookMode_PostNoCopy);
    RegConsoleCmd("sm_check_balance", Command_CheckBalance, "Показывает текущий баланс VIP");
    // KeyValues hKv = new KeyValues("FAB");
    // if(!FileToKeyValues(hKv, "addons/sourcemod/configs/FAB.cfg"))
    // {
    //     SetFailState("Не удалось открыть файл %s", "addons/sourcemod/configs/FAB.cfg");
    //     return;
    // }

    g_bMSG = true;
}

public void Event_RoundPreStart(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    CheckAndBalanceTeams();
}

void CheckAndBalanceTeams()
{
    int vipT, vipCT, totalT, totalCT;
    CountVIPPlayers(vipT, vipCT, totalT, totalCT);

    int imbalance    = vipT - vipCT;
    int absImbalance = AbsoluteValue(imbalance);

    if (absImbalance >= 2)
    {
        int fromTeam         = (imbalance > 0) ? CS_TEAM_T : CS_TEAM_CT;
        int toTeam           = (fromTeam == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T;

        // Ищем только мертвых игроков
        int vipCandidate     = FindTopScoringVIP(fromTeam);
        int regularCandidate = FindBottomRegularPlayer(toTeam);

        if (vipCandidate != -1 && regularCandidate != -1)
        {
            // Меняем команды с сохранением общего баланса
            CS_SwitchTeam(vipCandidate, toTeam);
            CS_SwitchTeam(regularCandidate, fromTeam);

            // Обновляем счетчики после перемещения
            CountVIPPlayers(vipT, vipCT, totalT, totalCT);

            if (g_bMSG)
            {
                CGOPrintToChatAll("Произведен VIP баланс: \x04%dT \x01- \x0B%dCT", vipT, vipCT);
                PrintToServer("Произведен VIP баланс: %dT - %dCT", vipT, vipCT);
                // Для VIP-игрока
                CGOPrintToChat(vipCandidate,
                               " \x08[VIP Balance]\x01 \x04•\x01 Вы \x0Bперемещены\x01 как \x08VIP\x01 игрок с \x04высоким\x01 рейтингом \x0E(Счет: %d)",
                               CS_GetClientContributionScore(vipCandidate));

                // Для обычного игрока
                CGOPrintToChat(regularCandidate,
                               " \x08[VIP Balance]\x01 \x04•\x01 Вы \x0Bперемещены\x01 как \x08обычный\x01 игрок с \x02низким\x01 рейтингом \x0E(Счет: %d)",
                               CS_GetClientContributionScore(regularCandidate));
            }
        }
    }
}

bool IsClientInVIPGroup(int client)
{
    char sClientGroup[32];
    VIP_GetClientVIPGroup(client, sClientGroup, sizeof(sClientGroup));

    for (int i = 0; i < sizeof(gsVIPGroups); i++)
    {
        if (StrEqual(sClientGroup, gsVIPGroups[i], false))
            return true;
    }
    return false;
}

void CountVIPPlayers(int &vipT, int &vipCT, int &totalT, int &totalCT)
{
    vipT = vipCT = totalT = totalCT = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (ValidClient(i))
        {
            int team = GetClientTeam(i);
            if (team == CS_TEAM_T)
            {
                totalT++;
                if (IsClientInVIPGroup(i)) vipT++;
            }
            else if (team == CS_TEAM_CT)
            {
                totalCT++;
                if (IsClientInVIPGroup(i)) vipCT++;
            }
        }
    }
}

int FindTopScoringVIP(int team)
{
    int maxScore  = -1;
    int candidate = -1;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (ValidClient(i) && GetClientTeam(i) == team && IsClientInVIPGroup(i))
        {
            int score = CS_GetClientContributionScore(i);
            if (score > maxScore)
            {
                maxScore  = score;
                candidate = i;
            }
        }
    }
    return candidate;
}

// Поиск обычного игрока с минимальным счетом
int FindBottomRegularPlayer(int team)
{
    int minScore  = 999999;
    int candidate = -1;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (ValidClient(i) && GetClientTeam(i) == team && !IsClientInVIPGroup(i))
        {
            int score = CS_GetClientContributionScore(i);
            if (score < minScore)
            {
                minScore  = score;
                candidate = i;
            }
        }
    }
    return candidate;
}

int AbsoluteValue(int value)
{
    return value < 0 ? -value : value;
}

stock bool ValidClient(int client, bool bots = true, bool dead = true)
{
    if (client <= 0 || client > MaxClients) return false;
    if (!IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client)) return false;
    if (!IsPlayerAlive(client) && !dead) return false;
    return true;
}

stock bool CheckFlags(int client, const char[] flags)
{
    return (ReadFlagString(flags) & GetUserFlagBits(client)) != 0;
}

public Action Command_CheckBalance(int client, int args)
{
    if (!client) return Plugin_Handled;

    int vipT, vipCT, totalT, totalCT;
    CountVIPPlayers(vipT, vipCT, totalT, totalCT);

    int vipImbalance   = vipT - vipCT;
    int totalImbalance = totalT - totalCT;

    CGOPrintToChat(client, " \x04[Balance Info]");
    CGOPrintToChat(client, " \x0B• VIP T: \x05%d \x0B| VIP CT: \x05%d \x0B| Дисбаланс: \x05%d", vipT, vipCT, AbsoluteValue(vipImbalance));
    CGOPrintToChat(client, " \x0B• Игроков T: \x05%d \x0B| Игроков CT: \x05%d \x0B| Дисбаланс: \x05%d", totalT, totalCT, AbsoluteValue(totalImbalance));
    CGOPrintToChat(client, " \x0B• Порог VIP дисбаланса: \x05≥2");

    return Plugin_Handled;
}
