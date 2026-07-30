package pt.ulusofona.lp2.greatprogrammingjourney;

public abstract class Abyss extends BoardElement {

    public Abyss(int id, String name) {
        super(id, name);
    }

    @Override
    public String getType() {
        return "ABYSS";
    }

    public abstract boolean isCounteredBy(Tool tool);

    @Override
    public String applyEffect(Player player) {
        player.setStatus("Derrotado");
        return player.getName() + " caiu no abismo " + getName();
    }
}
