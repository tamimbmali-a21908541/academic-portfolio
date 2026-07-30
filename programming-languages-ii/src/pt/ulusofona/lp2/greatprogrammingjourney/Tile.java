package pt.ulusofona.lp2.greatprogrammingjourney;

public class Tile {
    private int position;
    private String type;
    private String description;
    private String imageName;

    public Tile(int position, String type, String imageName) {
        this.position = position;
        this.type = type;
        this.imageName = imageName;
        this.description = "";
    }

    public int getPosition() {
        return position;
    }

    public String getType() {
        return type;
    }

    public String getImageName() {
        return imageName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setImageName(String imageName) {
        this.imageName = imageName;
    }
}
