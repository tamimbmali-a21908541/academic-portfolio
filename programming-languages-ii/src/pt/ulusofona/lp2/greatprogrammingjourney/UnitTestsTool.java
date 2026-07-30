package pt.ulusofona.lp2.greatprogrammingjourney;

public class UnitTestsTool extends Tool {

    public UnitTestsTool() {
        super(2, "Testes Unit\u00E1rios");
    }

    @Override
    public String getImageName() {
        return "unit-tests.png";
    }

    @Override
    public boolean counters(Abyss abyss) {
        return abyss.getId() == 1;
    }
}
