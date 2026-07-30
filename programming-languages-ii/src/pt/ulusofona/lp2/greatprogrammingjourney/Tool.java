package pt.ulusofona.lp2.greatprogrammingjourney;

public abstract class Tool extends BoardElement {

    public Tool(int id, String name) {
        super(id, name);
    }

    @Override
    public String getType() {
        return "TOOL";
    }

    public abstract boolean counters(Abyss abyss);

    @Override
    public String applyEffect(Player player) {
        player.addTool(this);
        return player.getName() + " apanhou " + getName();
    }
}
