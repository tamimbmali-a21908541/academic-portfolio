package pt.ulusofona.lp2.greatprogrammingjourney;

public class InheritanceTool extends Tool {

    public InheritanceTool() {
        super(0, "Heran\u00E7a");
    }

    @Override
    public String getImageName() {
        return "inheritance.png";
    }

    @Override
    public boolean counters(Abyss abyss) {
        return abyss.getId() == 5;
    }
}
