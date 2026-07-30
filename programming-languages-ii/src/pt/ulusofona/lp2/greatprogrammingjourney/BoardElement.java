package pt.ulusofona.lp2.greatprogrammingjourney;

public abstract class BoardElement {
    protected int id;
    protected String name;
    protected int position;

    public BoardElement(int id, String name) {
        this.id = id;
        this.name = name;
        this.position = -1;
    }

    public abstract String getType();

    public abstract String getImageName();

    public abstract String applyEffect(Player player);

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }
}
