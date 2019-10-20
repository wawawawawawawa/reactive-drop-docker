/*  SM Translator
 *
 *  Copyright (C) 2018 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 *
 * @author RD specific adjustments added by Gandalf under GPL
 */

#include <sdktools>
#include <SteamWorks>
#include <colorvariables>


#define DATA "1.0"

public Plugin myinfo =
{
	name = "SM Translator RD",
	description = "Translate chat messages",
	author = "Franc1sco franug, +Gandalf",
	version = DATA,
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	CreateConVar("sm_translator_version", DATA, "SM Translator Version", FCVAR_SPONLY|FCVAR_NOTIFY);
	
	AddCommandListener(Command_Say, "say");	
}

public Action Command_Say(int client, const char[] command, int args)
{
	if (!IsValidClient(client))return;
	
	char buffer[255];
	GetCmdArgString(buffer,sizeof(buffer));
	StripQuotes(buffer);
	
	if (strlen(buffer) < 1)return;
	
	char commands[255];
	
	GetCmdArg(1, commands, sizeof(commands));
	ReplaceString(commands, sizeof(commands), "!", "sm_", false);
	
	if (CommandExists(commands))return;
	
	char temp[3];

	for(int i = 1; i <= MaxClients; i++)
	{
		// only send messages to others
		if(IsValidClient(i) && i != client) {
				GetLanguageInfo(GetClientLanguage(i), temp, 3); // get Foreign language
				Handle request = CreateRequest(buffer, temp, i, client); // Translate not Foreign msg to Foreign player
				SteamWorks_SendHTTPRequest(request);
		}
	}
}

Handle CreateRequest(char[] input, char[] target, int other = 0)
{
	// send it to the local webserver
    Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, "http://localhost/");
    SteamWorks_SetHTTPRequestGetOrPostParameter(request, "input", input);
    SteamWorks_SetHTTPRequestGetOrPostParameter(request, "target", target);
    
    SteamWorks_SetHTTPRequestContextValue(request, other>0?GetClientUserId(other):0);
    SteamWorks_SetHTTPCallbacks(request, Callback_OnHTTPResponse);
    return request;
}

public int Callback_OnHTTPResponse(Handle request, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, int other)
{
    if (!bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK)
    {        
		return;
    }
	
    int iBufferSize;
    SteamWorks_GetHTTPResponseBodySize(request, iBufferSize);
    
    char[] result = new char[iBufferSize];
    SteamWorks_GetHTTPResponseBodyData(request, result, iBufferSize);
    delete request;

	// other is the person who sent it
    int sender = GetClientOfUserId(other);

	// userid is the user who it was sent to
    int receiver = GetClientOfUserId(userid);

	// fetch the sender username
    char[] username = new char[iBufferSize];
    GetClientName(sender, username, 50);

    CPrintToChat(receiver, "%s: %s", username, result);
}  

stock bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}