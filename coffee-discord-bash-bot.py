import discord
import subprocess
import datetime

client = discord.Client()

def process_message(message):
    args = message.content.split(" ")

    return args

@client.event
async def on_ready():
    print('We have logged in as {0.user}'.format(client))

@client.event
async def on_message(message):
    if message.author == client.user:
        return

    if message.content.startswith('$hello'):
        await message.channel.send('`Hello! ITguy is online`')
        
    if message.content.startswith('$help'):
        await message.channel.send('```rust\nOptions are:\n$check\n$reboot <server>    (where <server> can be: "plex, jf")\n$help```')
        
    if message.content.startswith('$check'):
        result1 = subprocess.run(['/opt/utils/cdbb/coffee-discord-bash-bot.sh', 'plex', 'check'])
        if (result1.returncode == 0):
            result1msg = 'Plex server is "down" with code 502. Please run "$reboot plex"'
        else:
            result1msg = 'Plex server is ok'
        result2 = subprocess.run(['/opt/utils/cdbb/coffee-discord-bash-bot.sh', 'jf', 'check'])
        if (result2.returncode == 0):
            result2msg = 'Jellyfin server is "down" with code 502. Please run "$reboot jf"'
        else:
            result2msg = 'Jellyfin server is ok'
        now = datetime.datetime.now()
        datenow = now.strftime("%H:%M %p")
        await message.channel.send( '```rust\n"{}" ran a check at {}:\n- {} \n- {}```'.format(message.author.display_name, datenow, result1msg, result2msg))
        
    if message.content.startswith('$reboot'):
        args = process_message(message)
        server = args[1]
#        link = args[2]
        result = subprocess.run(['/opt/utils/cdbb/coffee-discord-bash-bot.sh', server])
        return_code = result.returncode
        if (return_code == 0):
            result2 = 'Server was "down" and was rebooted "successfully"'
        else:
            result2 = 'Server was fine and was left alone'
        now = datetime.datetime.now()
        datenow = now.strftime("%H:%M %p")
        await message.channel.send( '```rust\n"{}" server was rebooted by "{}" at {} with result: \n- {}```'.format(server, message.author.display_name, datenow, result2))

client.run('xxxxxxx')
