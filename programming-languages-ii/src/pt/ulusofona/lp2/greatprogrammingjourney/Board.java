	package pt.ulusofona.lp2.greatprogrammingjourney;

import java.util.ArrayList;

public class Board {
    private ArrayList<Tile> tiles;
    private int worldSize;
    private ArrayList<Abyss> abysses;
    private ArrayList<Tool> toolsOnBoard;

    public Board(int worldSize) {
        this.worldSize = worldSize;
        this.tiles = new ArrayList<>();
        this.abysses = new ArrayList<>();
        this.toolsOnBoard = new ArrayList<>();
        initializeTiles();
    }

    private void initializeTiles() {
        for (int i = 1; i <= worldSize; i++) {
            String type = determineTileType(i);
            String imageName = determineImageName(type);
            tiles.add(new Tile(i, type, imageName));
        }
    }

    private String determineTileType(int position) {
        return "GRASS";
    }

    private String determineImageName(String type) {
        return "blank.png";
    }

    public Tile getTileAt(int position) {
        for (int i = 0; i < tiles.size(); i++) {
            Tile tile = tiles.get(i);
            if (tile.getPosition() == position) {
                return tile;
            }
        }
        return null;
    }

    public int getWorldSize() {
        return worldSize;
    }

    public void placeElements(String[][] abyssesAndTools) {
        if (abyssesAndTools == null) {
            return;
        }

        for (int i = 0; i < abyssesAndTools.length; i++) {
            String[] elementData = abyssesAndTools[i];
            if (elementData == null || elementData.length < 3) {
                continue;
            }

            String type = elementData[0];
            int id = 0;
            int position = 0;

            try {
                id = Integer.parseInt(elementData[1].trim());
                position = Integer.parseInt(elementData[2].trim());
            } catch (NumberFormatException e) {
                continue;
            }

            if ("0".equals(type)) {
                Abyss abyss = AbyssFactory.create(id);
                if (abyss != null) {
                    abyss.setPosition(position);
                    abysses.add(abyss);
                    Tile tile = getTileAt(position);
                    if (tile != null) {
                        tile.setType("ABYSS");
                    }
                }
            } else if ("1".equals(type)) {
                Tool tool = ToolFactory.create(id);
                if (tool != null) {
                    tool.setPosition(position);
                    toolsOnBoard.add(tool);
                    Tile tile = getTileAt(position);
                    if (tile != null) {
                        tile.setType("TOOL");
                    }
                }
            }
        }
    }

    public Abyss getAbyssAt(int position) {
        for (int i = 0; i < abysses.size(); i++) {
            Abyss abyss = abysses.get(i);
            if (abyss.getPosition() == position) {
                return abyss;
            }
        }
        return null;
    }

    public Tool getToolAt(int position) {
        for (int i = 0; i < toolsOnBoard.size(); i++) {
            Tool tool = toolsOnBoard.get(i);
            if (tool.getPosition() == position) {
                return tool;
            }
        }
        return null;
    }

    public void removeToolFromBoard(Tool tool) {
        toolsOnBoard.remove(tool);
        Tile tile = getTileAt(tool.getPosition());
        if (tile != null) {
            tile.setType("GRASS");
        }
    }

    public ArrayList<Abyss> getAbysses() {
        return abysses;
    }

    public ArrayList<Tool> getToolsOnBoard() {
        return toolsOnBoard;
    }

    public ArrayList<Tile> getTiles() {
        return tiles;
    }
}
