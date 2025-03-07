window.addEventListener('message', (event) => {
    switch (event.data.action) {
        case 'showBoard':
            var topPlayers = JSON.parse(event.data.topPlayers);
            if (event.data.board == "scoreboard") {
                var personalStats = JSON.parse(event.data.personalStats);

                $('#boardtitle').text("GUNGAME SCOREBOARD")
                $('#currentmap').text(event.data.currentMap)
                $('#personalkills').html(personalStats['kills'])
                $('#personaldeaths').text(personalStats['deaths'])
                $('#personalkd').text(personalStats['kd'])
                $('#scoreboardstats').show();
            } else {
                $('#boardtitle').text("GUNGAME LEADERBOARD")
                $('#scoreboardstats').hide();
            }
            
            $('#players').empty()

            for (var i = 0; i < topPlayers.length; i++) {
                var playerName = topPlayers[i].name;
                var playerKills = topPlayers[i].kills;
                var playerDeaths = topPlayers[i].deaths;
                var playerKD = topPlayers[i].kd;

                switch (i)  {
                    case 0:
                        $('#players').append(`<tr id=${i} class="group bg-gray-800 bg-opacity-75 border-l-2 border-amber-300 hover:bg-gray-700"></tr>`);
                        break;
                    case 1:
                        $('#players').append(`<tr id=${i} class="group bg-gray-800 bg-opacity-75 border-l-2 border-stone-300 hover:bg-gray-700"></tr>`);
                        break;
                    case 2:
                        $('#players').append(`<tr id=${i} class="group bg-gray-800 bg-opacity-75 border-l-2 border-amber-900 hover:bg-gray-700"></tr>`);
                        break;
                    default:
                        $('#players').append(`<tr id=${i} class="group bg-gray-800 bg-opacity-75 border-l-2 hover:bg-gray-700"></tr>`);
                        break;
                }

                $(`#${i}`).append(`<th scope="row" class="px-6 py-2.5 font-medium whitespace-nowrap text-white group-hover:font-bold"> ${i + 1}</th>
                        <td class="px-6 py-2.5 font-medium whitespace-nowrap text-white group-hover:font-bold">
                            ${playerName}
                        </td>
                        <td class="px-6 py-2.5 group-hover:text-white">
                            ${playerKills}
                        </td>
                        <td class="px-6 py-2.5 group-hover:text-white">
                            ${playerDeaths}
                        </td>
                        <td class="px-6 py-2.5 group-hover:text-white">
                            ${playerKD}
                        </td>
                `)
            }

            $('#board').fadeIn(500);
            break;
        case 'hideBoard':
            $('#board').fadeOut(500);
        default:
            break;
    }
});

