package pt.ulusofona.lp2.greatprogrammingjourney;

import java.util.ArrayList;

public class Player {
    private String id;
    private String name;
    private int currentPosition;
    private int previousPosition;
    private String color;
    private ArrayList<String> languages;
    private String status;
    private ArrayList<Tool> tools;
    private int lastDiceRoll;
    private ArrayList<Integer> positionHistory;
    private int moveCount;

    public Player(String id, String name) {
        this.id = id;
        this.name = name;
        this.currentPosition = 1;
        this.previousPosition = 1;
        this.color = "";
        this.languages = new ArrayList<>();
        this.status = "Em Jogo";
        this.tools = new ArrayList<>();
        this.lastDiceRoll = 0;
        this.positionHistory = new ArrayList<>();
        this.positionHistory.add(1);
        this.moveCount = 0;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getCurrentPosition() {
        return currentPosition;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public ArrayList<String> getLanguages() {
        return languages;
    }

    public String getLanguagesAsString() {
        if (languages.size() == 0) {
            return "";
        }

        ArrayList<String> sorted = new ArrayList<>();
        for (int i = 0; i < languages.size(); i++) {
            sorted.add(languages.get(i));
        }

        for (int i = 0; i < sorted.size() - 1; i++) {
            for (int j = 0; j < sorted.size() - i - 1; j++) {
                if (sorted.get(j).compareTo(sorted.get(j + 1)) > 0) {
                    String temp = sorted.get(j);
                    sorted.set(j, sorted.get(j + 1));
                    sorted.set(j + 1, temp);
                }
            }
        }

        String result = "";
        for (int i = 0; i < sorted.size(); i++) {
            if (i > 0) {
                result += "; ";
            }
            result += sorted.get(i);
        }
        return result;
    }

    public void addLanguage(String language) {
        languages.add(language);
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void moveBy(int spaces) {
        currentPosition += spaces;
    }

    public void setPosition(int position) {
        this.previousPosition = this.currentPosition;
        this.currentPosition = position;
        this.positionHistory.add(position);
        this.moveCount++;
    }

    public int getMoveCount() {
        return moveCount;
    }

    public void setPositionFromEffect(int position) {
        this.currentPosition = position;
    }

    public int getPreviousPosition() {
        return previousPosition;
    }

    public int getPositionFromNMovesAgo(int n) {
        int size = positionHistory.size();
        if (size <= n) {
            return positionHistory.get(0);
        }
        return positionHistory.get(size - 1 - n);
    }

    public boolean isTrapped() {
        return "Preso".equals(status);
    }

    public void addTool(Tool tool) {
        tools.add(tool);
    }

    public void removeTool(Tool tool) {
        tools.remove(tool);
    }

    public ArrayList<Tool> getTools() {
        return tools;
    }

    public boolean hasTool(int toolId) {
        for (int i = 0; i < tools.size(); i++) {
            if (tools.get(i).getId() == toolId) {
                return true;
            }
        }
        return false;
    }

    public Tool findCounterTool(Abyss abyss) {
        for (int i = 0; i < tools.size(); i++) {
            Tool tool = tools.get(i);
            if (tool.counters(abyss)) {
                return tool;
            }
        }
        return null;
    }

    public boolean isEliminated() {
        return "Derrotado".equals(status);
    }

    public String getToolsAsString() {
        if (tools.size() == 0) {
            return "";
        }

        ArrayList<String> toolNames = new ArrayList<>();
        for (int i = 0; i < tools.size(); i++) {
            toolNames.add(tools.get(i).getName());
        }

        for (int i = 0; i < toolNames.size() - 1; i++) {
            for (int j = 0; j < toolNames.size() - i - 1; j++) {
                String name1 = toolNames.get(j);
                String name2 = toolNames.get(j + 1);
                if (name1.compareTo(name2) > 0) {
                    toolNames.set(j, name2);
                    toolNames.set(j + 1, name1);
                }
            }
        }

        String result = "";
        for (int i = 0; i < toolNames.size(); i++) {
            if (i > 0) {
                result += ";";
            }
            result += toolNames.get(i);
        }
        return result;
    }

    public String getToolIdsAsString() {
        if (tools.size() == 0) {
            return "";
        }
        String result = "";
        for (int i = 0; i < tools.size(); i++) {
            if (i > 0) {
                result += ";";
            }
            result += tools.get(i).getId();
        }
        return result;
    }

    public int getLastDiceRoll() {
        return lastDiceRoll;
    }

    public void setLastDiceRoll(int diceRoll) {
        this.lastDiceRoll = diceRoll;
    }

    public int getPositionHistorySize() {
        return positionHistory.size();
    }

    public int getPositionFromHistory(int index) {
        if (index < 0 || index >= positionHistory.size()) {
            return 1;  
        }
        return positionHistory.get(index);
    }
}
