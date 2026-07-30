package pt.ulusofona.lp2.greatprogrammingjourney;

import java.util.ArrayList;
import java.util.HashMap;
import javax.swing.JPanel;
import javax.swing.JLabel;
import javax.swing.BoxLayout;
import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.IOException;


public class GameManager {

    private ArrayList<Player> players;
    private Board board;
    private int currentPlayerIndex;
    private int lastMovedPlayerIndex;
    private boolean gameStarted;
    private boolean gameOver;
    private int turnCounter;

    public GameManager() {
        players = new ArrayList<>();
        currentPlayerIndex = 0;
        lastMovedPlayerIndex = 0;
        gameStarted = false;
        gameOver = false;
        turnCounter = 1;
    }

    public boolean createInitialBoard(String[][] playerInfo, int worldSize) {
        try {
            players = new ArrayList<>();
            board = null;
            currentPlayerIndex = 0;
            lastMovedPlayerIndex = 0;
            gameStarted = false;
            gameOver = false;
            turnCounter = 1;

            if (playerInfo == null || playerInfo.length < 2 || playerInfo.length > 4) {
                return false;
            }

            int minWorldSize = playerInfo.length * 2;
            if (worldSize < minWorldSize) {
                return false;
            }

            ArrayList<String> usedIds = new ArrayList<>();
            ArrayList<String> usedColors = new ArrayList<>();

            for (int i = 0; i < playerInfo.length; i++) {
            if (playerInfo[i] == null || playerInfo[i].length < 2) {
                return false;
            }

            String id = playerInfo[i][0];
            String name = playerInfo[i][1];
            String languagesStr = playerInfo[i].length > 2 ? playerInfo[i][2] : "";
            String color = playerInfo[i].length > 3 ? playerInfo[i][3] : "";

            if (id == null) {
                return false;
            }

            String trimmedId = id.trim();
            if (trimmedId.isEmpty()) {
                return false;
            }
            int numericId = 0;
            boolean isValidId = true;
            for (int j = 0; j < trimmedId.length(); j++) {
                char c = trimmedId.charAt(j);
                if (c < '0' || c > '9') {
                    isValidId = false;
                    break;
                }
                numericId = numericId * 10 + (c - '0');
            }
            if (!isValidId || numericId <= 0) {
                return false;
            }

            if (name == null) {
                return false;
            }
            String trimmedName = name.trim();
            if (trimmedName.isEmpty()) {
                return false;
            }

            if (usedIds.contains(trimmedId)) {
                return false;
            }
            usedIds.add(trimmedId);

            if (color != null && !color.trim().isEmpty()) {
                String trimmedColor = color.trim();

                boolean isValidColor = false;
                if (trimmedColor.equals("Purple") || trimmedColor.equals("Blue") ||
                    trimmedColor.equals("Green") || trimmedColor.equals("Brown")) {
                    isValidColor = true;
                }

                if (!isValidColor) {
                    return false;
                }

                if (usedColors.contains(trimmedColor)) {
                    return false;
                }
                usedColors.add(trimmedColor);
            }

            Player player = new Player(trimmedId, trimmedName);
            if (color != null && !color.trim().isEmpty()) {
                player.setColor(color.trim());
            }

            if (languagesStr != null && !languagesStr.trim().isEmpty()) {
                String[] langs = languagesStr.split(";");
                for (int j = 0; j < langs.length; j++) {
                    if (langs[j] != null) {
                        String lang = langs[j].trim();
                        if (!lang.isEmpty()) {
                            player.addLanguage(lang);
                        }
                    }
                }
            }

            players.add(player);
        }

            board = new Board(worldSize);
            gameStarted = true;

            return true;
        } catch (Exception e) {
            System.err.println("DEBUG: createInitialBoard failed with exception: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean createInitialBoard(String[][] playerInfo, int worldSize, String[][] abyssesAndTools) {
        boolean success = createInitialBoard(playerInfo, worldSize);
        if (!success) {
            return false;
        }

        if (abyssesAndTools != null) {
            for (int i = 0; i < abyssesAndTools.length; i++) {
                String[] elementData = abyssesAndTools[i];
                if (elementData == null || elementData.length < 3) {
                    return false;
                }
                String type = elementData[0];
                int id = 0;
                try {
                    id = Integer.parseInt(elementData[1].trim());
                } catch (NumberFormatException e) {
                    return false;
                }
                if ("0".equals(type)) {
                    if (id < 0 || (id > 10 && id != 20)) {
                        return false;
                    }
                } else if ("1".equals(type)) {
                    if (id < 0 || id > 5) {
                        return false;
                    }
                } else {
                    return false;
                }
            }
        }

        if (abyssesAndTools != null && board != null) {
            board.placeElements(abyssesAndTools);
        }

        return true;
    }

    public String getImagePng(int nrSquare) {
        if (board == null) {
            return "";
        }

        Abyss abyss = board.getAbyssAt(nrSquare);
        if (abyss != null) {
            return abyss.getImageName();
        }

        Tool tool = board.getToolAt(nrSquare);
        if (tool != null) {
            return tool.getImageName();
        }

        Tile tile = board.getTileAt(nrSquare);
        if (tile != null) {
            return tile.getImageName();
        }

        return "";
    }

    public String[] getProgrammerInfo(int id) {
        Player player = findPlayerById(String.valueOf(id));
        if (player == null) {
            return null;
        }

        String toolsStr = player.getToolsAsString();
        if (toolsStr.isEmpty()) {
            toolsStr = "No tools";
        }

        String color = player.getColor();

        return new String[] {
            player.getId(),                              // [0] ID
            player.getName(),                            // [1] Name
            player.getLanguagesAsString(),               // [2] Languages
            color,                                       // [3] Color
            String.valueOf(player.getCurrentPosition()), // [4] Position
            toolsStr,                                    // [5] Tools
            player.getStatus()                           // [6] Status
        };
    }

    private Player findPlayerById(String id) {
        for (int i = 0; i < players.size(); i++) {
            Player player = players.get(i);
            if (player.getId().equals(id)) {
                return player;
            }
        }
        return null;
    }
    

    public String getProgrammerInfoAsStr(int id) {
        Player player = findPlayerById(String.valueOf(id));
        if (player == null) {
            return null;
        }

        String toolsStr = player.getToolsAsString();
        if (toolsStr.isEmpty()) {
            toolsStr = "No tools";
        }

        return player.getId() + " | " + player.getName() + " | " +
               player.getCurrentPosition() + " | " + toolsStr + " | " +
               player.getLanguagesAsString() + " | " + player.getStatus();
    }

    public String getProgrammersInfo() {
        if (players == null || players.isEmpty()) {
            return "";
        }

        StringBuilder sb = new StringBuilder();
        boolean first = true;
        for (int i = 0; i < players.size(); i++) {
            Player player = players.get(i);
            if (player.isEliminated()) {
                continue;
            }
            if (!first) {
                sb.append(" | ");
            }
            first = false;
            sb.append(player.getName());
            sb.append(" : ");
            String tools = player.getToolsAsString();
            if (tools.isEmpty()) {
                tools = "No tools";
            }
            sb.append(tools);
        }
        return sb.toString();
    }

    public String[] getSlotInfo(int position) {
        if (board == null) {
            return new String[] {"", "", ""};
        }

        String playerIds = "";
        if (players != null) {
            for (int i = 0; i < players.size(); i++) {
                Player player = players.get(i);
                if (player != null && player.getCurrentPosition() == position) {
                    if (!playerIds.isEmpty()) {
                        playerIds += ",";
                    }
                    playerIds += player.getId();
                }
            }
        }

        Abyss abyss = board.getAbyssAt(position);
        if (abyss != null) {
            return new String[] {
                playerIds,
                abyss.getName(),
                "A:" + abyss.getId()
            };
        }

        Tool tool = board.getToolAt(position);
        if (tool != null) {
            return new String[] {
                playerIds,
                tool.getName(),
                "T:" + tool.getId()
            };
        }

        return new String[] {
            playerIds,
            "",
            ""
        };
    }

    public int getCurrentPlayerID() {
        if (players == null || players.size() == 0 || !gameStarted) {
            return -1;
        }
        if (currentPlayerIndex < 0 || currentPlayerIndex >= players.size()) {
            return -1;
        }

        Player currentPlayer = players.get(currentPlayerIndex);
        if (currentPlayer == null) {
            return -1;
        }

        int playerId = 0;
        String idStr = currentPlayer.getId();
        for (int i = 0; i < idStr.length(); i++) {
            char c = idStr.charAt(i);
            if (c >= '0' && c <= '9') {
                playerId = playerId * 10 + (c - '0');
            }
        }

        return playerId;
    }

    public boolean moveCurrentPlayer(int nrSpaces) {
        if (!gameStarted || gameOver || players == null || players.size() == 0) {
            return false;
        }
        if (board == null) {
            return false;
        }
        if (currentPlayerIndex < 0 || currentPlayerIndex >= players.size()) {
            return false;
        }

        if (nrSpaces < 1 || nrSpaces > 6) {
            return false;
        }

        Player currentPlayer = players.get(currentPlayerIndex);
        if (currentPlayer == null) {
            return false;
        }

        if (currentPlayer.isEliminated()) {
            return false;
        }

        if (currentPlayer.isTrapped()) {
            int position = currentPlayer.getCurrentPosition();
            Tool toolOnGround = board.getToolAt(position);
            Abyss infiniteLoop = AbyssFactory.create(8);

            Tool counterToolInInventory = currentPlayer.findCounterTool(infiniteLoop);
            if (counterToolInInventory != null) {
                currentPlayer.removeTool(counterToolInInventory);
                currentPlayer.setStatus("Em Jogo");
                return true;
            }

            if (toolOnGround != null) {
                boolean toolCounters = infiniteLoop.isCounteredBy(toolOnGround) ||
                                       toolOnGround.counters(infiniteLoop);
                if (toolCounters) {
                    currentPlayer.setStatus("Em Jogo");
                    if (!currentPlayer.hasTool(toolOnGround.getId())) {
                        currentPlayer.addTool(toolOnGround);
                    }
                    return true;
                }
            }

            return false;
        }

        int maxMove = getMaxMovementForPlayer(currentPlayer);
        if (nrSpaces > maxMove) {
            return false;
        }

        int currentPosition = currentPlayer.getCurrentPosition();
        int newPosition = currentPosition + nrSpaces;

        if (newPosition < 1) {
            return false;
        }

        int worldSize = board.getWorldSize();
        if (newPosition > worldSize) {
            newPosition = worldSize - (newPosition - worldSize);
        }

        currentPlayer.setPosition(newPosition);
        currentPlayer.setLastDiceRoll(nrSpaces);

        if (newPosition >= board.getWorldSize()) {
            gameOver = true;
        }

        return true;
    }

    private int getMaxMovementForPlayer(Player player) {
        ArrayList<String> languages = player.getLanguages();

        if (languages.size() > 0) {
            String firstLang = languages.get(0);
            if (firstLang.equalsIgnoreCase("Assembly")) {
                return 2;
            } else if (firstLang.equalsIgnoreCase("C")) {
                return 3;
            }
        }

        return 6;
    }

    private void advanceToNextActivePlayer() {
        int startIndex = currentPlayerIndex;
        int attempts = 0;
        do {
            currentPlayerIndex = (currentPlayerIndex + 1) % players.size();
            Player next = players.get(currentPlayerIndex);
            if (!next.isEliminated()) {
                return;
            }
            attempts++;
        } while (attempts < players.size());

        gameOver = true;
    }

    public String reactToAbyssOrTool() {
        if (!gameStarted || players == null || board == null) {
            return null;
        }

        Player player = players.get(currentPlayerIndex);

        if (player.isEliminated()) {
            int position = player.getCurrentPosition();
            Abyss abyssAtPos = board.getAbyssAt(position);
            Tool toolAtPos = board.getToolAt(position);
            advanceToNextActivePlayer();
            turnCounter++;
            if (abyssAtPos != null) {
                return player.getName() + " está derrotado";
            }
            if (toolAtPos != null) {
                return player.getName() + " está derrotado";
            }
            return null;
        }

        if (player.isTrapped()) {
            int position = player.getCurrentPosition();
            Abyss abyssAtPos = board.getAbyssAt(position);
            Tool toolAtPos = board.getToolAt(position);
            advanceToNextActivePlayer();
            turnCounter++;
            if (abyssAtPos != null) {
                return player.getName() + " continua preso no " + abyssAtPos.getName();
            }
            if (toolAtPos != null) {
                return player.getName() + " continua preso";
            }
            return null;
        }

        int position = player.getCurrentPosition();

        Tool toolOnGround = board.getToolAt(position);

        String reactionResult = null;

        Abyss abyss = board.getAbyssAt(position);
        if (abyss != null) {
            if (abyss.getId() == 9) {
                reactionResult = handleSegFault(player, abyss, position, toolOnGround);
            } else if (abyss.getId() == 8) {
                Player trappedPlayer = findTrappedPlayerAtPosition(position, player);

                Tool counterTool = player.findCounterTool(abyss);
                if (counterTool != null) {
                    player.removeTool(counterTool);
                    reactionResult = player.getName() + " usou " + counterTool.getName() + " para evitar " + abyss.getName();
                } else {
                    if (trappedPlayer != null) {
                        trappedPlayer.setStatus("Em Jogo");
                    }
                    reactionResult = abyss.applyEffect(player);
                }
            } else if (abyss.getId() == 20) {
                reactionResult = handleLLMAbyss(player, abyss);
            } else {
                Tool counterTool = player.findCounterTool(abyss);
                if (counterTool != null) {
                    player.removeTool(counterTool);
                    reactionResult = player.getName() + " usou " + counterTool.getName() + " para evitar " + abyss.getName();
                } else {
                    reactionResult = abyss.applyEffect(player);
                    checkAllPlayersEliminated();
                }
            }
        } else {
            if (toolOnGround != null) {
                if (!player.hasTool(toolOnGround.getId())) {
                    reactionResult = toolOnGround.applyEffect(player);
                } else {
                    reactionResult = player.getName() + " já tem " + toolOnGround.getName();
                }
            }
        }

        advanceToNextActivePlayer();
        turnCounter++;

        return reactionResult;
    }

    private int countPlayersAtPosition(int position) {
        int count = 0;
        for (int i = 0; i < players.size(); i++) {
            Player p = players.get(i);
            if (p.getCurrentPosition() == position && !p.isEliminated()) {
                count++;
            }
        }
        return count;
    }

    private String handleSegFault(Player player, Abyss abyss, int position, Tool toolOnGround) {
        int playersBeforeMove = countPlayersAtPosition(position) - 1;
        if (playersBeforeMove < 1) {
            if (toolOnGround != null && !player.hasTool(toolOnGround.getId())) {
                return toolOnGround.applyEffect(player);
            }
            return "Segmentation Fault não satisfez as condições";
        }
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < players.size(); i++) {
            Player p = players.get(i);
            if (p.getCurrentPosition() == position && !p.isEliminated()) {
                Tool counterTool = p.findCounterTool(abyss);
                if (counterTool != null) {
                    p.removeTool(counterTool);
                    if (result.length() > 0) {
                        result.append(" | ");
                    }
                    result.append(p.getName() + " usou " + counterTool.getName() + " para evitar " + abyss.getName());
                } else {
                    if (result.length() > 0) {
                        result.append(" | ");
                    }
                    result.append(abyss.applyEffect(p));
                }
            }
        }
        checkAllPlayersEliminated();
        return result.toString();
    }

    private Player findTrappedPlayerAtPosition(int position, Player excludePlayer) {
        for (int i = 0; i < players.size(); i++) {
            Player p = players.get(i);
            if (p != excludePlayer && p.getCurrentPosition() == position && p.isTrapped()) {
                return p;
            }
        }
        return null;
    }

    private String handleLLMAbyss(Player player, Abyss abyss) {
        int playerMoveCount = player.getMoveCount();
        Tool counterTool = player.findCounterTool(abyss);

        if (playerMoveCount < 4) {
            if (counterTool != null) {
                player.removeTool(counterTool);
                return player.getName() + " usou " + counterTool.getName() + " para evitar " + abyss.getName();
            } else {
                int previousPosition = player.getPreviousPosition();
                if (previousPosition < 1) {
                    previousPosition = 1;
                }
                player.setPositionFromEffect(previousPosition);
                return player.getName() + " voltou para a posição " + previousPosition;
            }
        } else {
            int lastDiceRoll = player.getLastDiceRoll();
            int currentPosition = player.getCurrentPosition();
            int newPosition = currentPosition + lastDiceRoll;
            player.setPositionFromEffect(newPosition);
            return player.getName() + " com LLM já tem experiência";
        }
    }

    private void checkAllPlayersEliminated() {
        int activeCount = 0;
        for (int i = 0; i < players.size(); i++) {
            if (!players.get(i).isEliminated()) {
                activeCount++;
            }
        }
        if (activeCount == 0) {
            gameOver = true;
        }
    }

    public boolean gameIsOver() {
        if (gameOver) {
            return true;
        }

        if (board == null || players == null || !gameStarted) {
            return false;
        }

        // Check if a player reached the end
        for (int i = 0; i < players.size(); i++) {
            Player player = players.get(i);
            if (player != null && player.getCurrentPosition() >= board.getWorldSize()) {
                gameOver = true;
                return true;
            }
        }

        // Check if only 1 or 0 players are alive (not eliminated)
        // Trapped players ("Preso") are still considered alive for this check
        int aliveCount = 0;
        for (int i = 0; i < players.size(); i++) {
            Player player = players.get(i);
            if (player != null && !player.isEliminated()) {
                aliveCount++;
            }
        }
        if (aliveCount <= 1) {
            gameOver = true;
            return true;
        }

        // Check for tie condition: no players can move (all are either trapped or eliminated)
        int canMoveCount = 0;
        for (int i = 0; i < players.size(); i++) {
            Player player = players.get(i);
            if (player != null && !player.isEliminated() && !player.isTrapped()) {
                canMoveCount++;
            }
        }
        if (canMoveCount == 0) {
            gameOver = true;
            return true;
        }

        return false;
    }

    public ArrayList<String> getGameResults() {
        ArrayList<String> results = new ArrayList<>();

        results.add("THE GREAT PROGRAMMING JOURNEY");

        results.add("");

        results.add("NR. DE TURNOS");

        results.add(String.valueOf(turnCounter));

        results.add("");

        Player winner = null;
        if (gameOver && board != null && players != null) {
            for (int i = 0; i < players.size(); i++) {
                Player player = players.get(i);
                if (player != null && player.getCurrentPosition() >= board.getWorldSize()) {
                    winner = player;
                    break;
                }
            }
        }

        boolean isTie = false;
        if (winner == null && gameOver && players != null) {
            int canMoveCount = 0;
            for (int i = 0; i < players.size(); i++) {
                Player player = players.get(i);
                if (player != null && !player.isEliminated() && !player.isTrapped()) {
                    canMoveCount++;
                }
            }
            if (canMoveCount == 0) {
                isTie = true;
            }
        }

        if (winner != null) {
            results.add("VENCEDOR");
            results.add(winner.getName());

            results.add("");

            results.add("RESTANTES");

            if (players != null) {
                ArrayList<Player> remainingPlayers = new ArrayList<>();
                for (int i = 0; i < players.size(); i++) {
                    Player player = players.get(i);
                    if (player != null && player != winner) {
                        remainingPlayers.add(player);
                    }
                }

                sortPlayersByPositionAndName(remainingPlayers);

                for (int i = 0; i < remainingPlayers.size(); i++) {
                    Player player = remainingPlayers.get(i);
                    results.add(player.getName() + " " + player.getCurrentPosition());
                }
            }
        } else if (isTie) {
            results.add("O jogo terminou empatado.");

            results.add("");

            results.add("Participantes:");

            if (players != null) {
                ArrayList<Player> allPlayers = new ArrayList<>();
                for (int i = 0; i < players.size(); i++) {
                    Player player = players.get(i);
                    if (player != null) {
                        allPlayers.add(player);
                    }
                }

                sortPlayersByPositionAndName(allPlayers);

                for (int i = 0; i < allPlayers.size(); i++) {
                    Player player = allPlayers.get(i);
                    int pos = player.getCurrentPosition();
                    Abyss abyssAtPos = board != null ? board.getAbyssAt(pos) : null;
                    if (abyssAtPos != null) {
                        results.add(player.getName() + " : " + pos + " : " + abyssAtPos.getName());
                    } else {
                        results.add(player.getName() + " : " + pos);
                    }
                }
            }
        } else {
            results.add("RESTANTES");

            if (players != null) {
                ArrayList<Player> remainingPlayers = new ArrayList<>();
                for (int i = 0; i < players.size(); i++) {
                    Player player = players.get(i);
                    if (player != null) {
                        remainingPlayers.add(player);
                    }
                }

                sortPlayersByPositionAndName(remainingPlayers);

                for (int i = 0; i < remainingPlayers.size(); i++) {
                    Player player = remainingPlayers.get(i);
                    results.add(player.getName() + " " + player.getCurrentPosition());
                }
            }
        }

        return results;
    }

    private void sortPlayersByPositionAndName(ArrayList<Player> playerList) {
        for (int i = 0; i < playerList.size() - 1; i++) {
            for (int j = 0; j < playerList.size() - i - 1; j++) {
                Player p1 = playerList.get(j);
                Player p2 = playerList.get(j + 1);

                boolean shouldSwap = false;

                if (p1.getCurrentPosition() < p2.getCurrentPosition()) {
                    shouldSwap = true;
                } else if (p1.getCurrentPosition() == p2.getCurrentPosition()) {
                    String name1 = p1.getName();
                    String name2 = p2.getName();

                    int minLen = name1.length() < name2.length() ? name1.length() : name2.length();
                    for (int k = 0; k < minLen; k++) {
                        if (name1.charAt(k) < name2.charAt(k)) {
                            break;
                        } else if (name1.charAt(k) > name2.charAt(k)) {
                            shouldSwap = true;
                            break;
                        }
                    }
                    if (!shouldSwap && name1.length() > name2.length()) {
                        shouldSwap = true;
                    }
                }

                if (shouldSwap) {
                    Player temp = playerList.get(j);
                    playerList.set(j, playerList.get(j + 1));
                    playerList.set(j + 1, temp);
                }
            }
        }
    }

    public JPanel getAuthorsPanel() {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));

        JLabel title = new JLabel("Authors:");
        JLabel author1 = new JLabel("a21908541 - Tamim Mohamed Ali");
        JLabel author2 = new JLabel("a21908516 - Boshra Alalou");

        panel.add(title);
        panel.add(author1);
        panel.add(author2);

        return panel;
    }

    public HashMap<String, String> customizeBoard() {
        HashMap<String, String> customizations = new HashMap<>();
        customizations.put("hasNewAbyss", "true");
        customizations.put("newAbyssId", "10");
        customizations.put("newAbyssName", "Stack Overflow");
        customizations.put("newAbyssImage", "stack_overflow.png");
        return customizations;
    }

    public boolean saveGame(File file) {
        if (file == null || !gameStarted) {
            return false;
        }

        try {
            PrintWriter writer = new PrintWriter(new FileWriter(file));

            writer.println("VERSION:1");
            writer.println("WORLD_SIZE:" + board.getWorldSize());
            writer.println("TURN:" + turnCounter);
            writer.println("CURRENT_PLAYER_INDEX:" + currentPlayerIndex);
            writer.println("GAME_OVER:" + gameOver);

            for (int i = 0; i < players.size(); i++) {
                Player player = players.get(i);
                writer.println("PLAYER:" +
                    player.getId() + "," +
                    player.getName() + "," +
                    player.getCurrentPosition() + "," +
                    player.getColor() + "," +
                    player.getLanguagesAsString().replace("; ", ";") + "," +
                    player.getStatus() + "," +
                    player.getToolIdsAsString());
            }

            ArrayList<Abyss> abysses = board.getAbysses();
            for (int i = 0; i < abysses.size(); i++) {
                Abyss abyss = abysses.get(i);
                writer.println("ABYSS:" + abyss.getId() + "," + abyss.getPosition());
            }

            ArrayList<Tool> toolsOnBoard = board.getToolsOnBoard();
            for (int i = 0; i < toolsOnBoard.size(); i++) {
                Tool tool = toolsOnBoard.get(i);
                writer.println("TOOL:" + tool.getId() + "," + tool.getPosition());
            }

            writer.close();
            return true;
        } catch (IOException e) {
            return false;
        }
    }

    public void loadGame(File file) throws InvalidFileException, FileNotFoundException {
        if (file == null) {
            throw new InvalidFileException("File is null");
        }

        if (!file.exists()) {
            throw new FileNotFoundException("File not found: " + file.getPath());
        }

        try {
            BufferedReader reader = new BufferedReader(new FileReader(file));

            players = new ArrayList<>();
            board = null;
            lastMovedPlayerIndex = 0;
            int worldSize = 0;
            ArrayList<String[]> abyssesAndToolsData = new ArrayList<>();

            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }

                int colonIndex = line.indexOf(':');
                if (colonIndex == -1) {
                    continue;
                }

                String key = line.substring(0, colonIndex);
                String value = line.substring(colonIndex + 1);

                if ("VERSION".equals(key)) {
                    // Validate version if needed
                } else if ("WORLD_SIZE".equals(key)) {
                    worldSize = Integer.parseInt(value.trim());
                } else if ("TURN".equals(key)) {
                    turnCounter = Integer.parseInt(value.trim());
                } else if ("CURRENT_PLAYER_INDEX".equals(key)) {
                    currentPlayerIndex = Integer.parseInt(value.trim());
                } else if ("GAME_OVER".equals(key)) {
                    gameOver = Boolean.parseBoolean(value.trim());
                } else if ("PLAYER".equals(key)) {
                    loadPlayer(value);
                } else if ("ABYSS".equals(key)) {
                    String[] parts = value.split(",");
                    if (parts.length >= 2) {
                        abyssesAndToolsData.add(new String[]{"0", parts[0].trim(), parts[1].trim()});
                    }
                } else if ("TOOL".equals(key)) {
                    String[] parts = value.split(",");
                    if (parts.length >= 2) {
                        abyssesAndToolsData.add(new String[]{"1", parts[0].trim(), parts[1].trim()});
                    }
                }
            }

            reader.close();

            board = new Board(worldSize);

            String[][] abyssesAndTools = abyssesAndToolsData.toArray(new String[0][]);
            board.placeElements(abyssesAndTools);

            gameStarted = true;

        } catch (IOException e) {
            throw new InvalidFileException("Error reading save file: " + e.getMessage());
        } catch (NumberFormatException e) {
            throw new InvalidFileException("Error parsing save file: " + e.getMessage());
        }
    }

    private void loadPlayer(String data) throws InvalidFileException {
        String[] parts = data.split(",");
        if (parts.length < 6) {
            throw new InvalidFileException("Invalid player data");
        }

        Player player = new Player(parts[0].trim(), parts[1].trim());
        player.setPosition(Integer.parseInt(parts[2].trim()));
        player.setColor(parts[3].trim());

        if (!parts[4].trim().isEmpty()) {
            String[] langs = parts[4].split(";");
            for (int i = 0; i < langs.length; i++) {
                String lang = langs[i].trim();
                if (!lang.isEmpty()) {
                    player.addLanguage(lang);
                }
            }
        }

        player.setStatus(parts[5].trim());

        if (parts.length > 6 && !parts[6].trim().isEmpty()) {
            String[] toolIds = parts[6].split(";");
            for (int i = 0; i < toolIds.length; i++) {
                String toolIdStr = toolIds[i].trim();
                if (!toolIdStr.isEmpty()) {
                    int toolId = Integer.parseInt(toolIdStr);
                    Tool tool = ToolFactory.create(toolId);
                    if (tool != null) {
                        player.addTool(tool);
                    }
                }
            }
        }

        players.add(player);
    }

}
